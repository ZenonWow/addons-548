local ADDON_NAME, private = ...
local AddonLoader = AddonLoader
local tostrjoin = private.tostrjoin
local Debug = private.Debug
local _G, tostringall, tostring, string, strjoin, pairs, ipairs, select, next, date, time, GetTime, InCombatLockdown = 
      _G, tostringall, tostring, string, strjoin, pairs, ipairs, select, next, date, time, GetTime, InCombatLockdown
local EMPTY = {}  -- constant empty object to use in place of nil table reference

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: GetAddOnInfo GetAddOnMetadata IsAddOnLoaded IsAddOnLoadOnDemand GetNumAddOns LoadAddOn
-- GLOBALS: AddonLoaderSV


local ConditionManager = CreateFrame('Frame')    -- , 'AddonLoaderConditionManager')
ConditionManager:Hide()
AddonLoader.ConditionManager = ConditionManager
AddonLoader.frame = ConditionManager  -- Deprecated: easy reference for use in X-LoadOn-Events


-- Metatable to auto-create empty inner tables when first referenced.
local AutoCreateInnerTablesMT = { __index = function(self, key)  local subTable = {} ; self[key] = subTable ; return subTable  end }
-- Want optimized lua syntax: local AutoCreateInnerTablesMT = { __index = function(self, key)  return self[key] = {}  end }

ConditionManager.AddonMetadata = setmetatable({}, AutoCreateInnerTablesMT)
ConditionManager.AddonOverrides = setmetatable({}, AutoCreateInnerTablesMT)
ConditionManager.MergedConditions = setmetatable({}, AutoCreateInnerTablesMT)

ConditionManager.EventHooks = {}
ConditionManager.FrameHooks = {}
ConditionManager.SecureHooks = {}

-- Slashes:  ["AddonName"] = { "ADDON_SLASH"="/slash", "ADDON_DOTHIS"="/dothis", .. }, ["AnotherAddon"] = ..
ConditionManager.Slashes = setmetatable({}, AutoCreateInnerTablesMT)




--------------------------
-- Error source logging --
--------------------------

local function formatSourceField()
	local field = ConditionManager.parsedField or ConditionManager.evaluatedCondition
	return  not field  and  ""  or  ("\nIn addon "..field.addonName.." / ## "..field.fieldName..": "..field.fieldValue)
end


-- Lua-kind error (exception) handling: a try-catch block around unsafeFunc(...)
-- Report eventual error to standard geterrorhandler(): BugGrabber or Swatter or Lua error popup.
-- Then continue processing without the aborting all code in the current event handler.
function private.safecall(unsafeFunc, ...)
	local errorhandlerBeforeCall = geterrorhandler()
	local function localErrorHandler(...)
		local msg = "AddonLoader: safecall failed (no params): "  -- extra space intentional
		print(msg .. tostrjoin(" ",...) .. formatSourceField())
		return errorhandlerBeforeCall(...)
	end

	if type(unsafeFunc) ~= "function" then  return  end
	-- Without parameters call the function directly
	local nParams = select('#',...)
	if  0 == nParams  then
		return xpcall(unsafeFunc, localErrorHandler)
  end

	-- Pack the parameters to pass to the actual function
	local tParams = { ... }

	local function localErrorHandler(...)
		local msg = "AddonLoader: safecall failed (params: " .. tostrjoin(", ", unpack(tParams,1,nParams)) .. "): "
		print(msg .. tostrjoin(" ",...) .. formatSourceField())
		return errorhandlerBeforeCall(...)
	end

	-- Unpack the parameters in the thunk
	local function safecallThunk()  unsafeFunc( unpack(tParams,1,nParams) )  end
	-- Do the call through the thunk
	return xpcall(safecallThunk, localErrorHandler)
end

local safecall = private.safecall





-------------------------
-- String manipulation --
-------------------------

do
	local SPLIT_CHARS = ", \t"
	local function packNonEmpty(...)
		local arr = {}
		for  i = 1, select('#', ...)  do  local  v = select(i, ...) ; if  v  and  v ~= ""  then  arr[#arr+1] = v  end end
		return arr
	end
	local function splitValue(fieldValue)
		return packNonEmpty(strsplit( SPLIT_CHARS, fieldValue ))
	end

	private.SPLIT_CHARS = SPLIT_CHARS
	private.packNonEmpty = packNonEmpty
	private.splitValue = splitValue
end

local splitValue = private.splitValue




local LoadOnFuncEnvironment = setmetatable({}, {__index = getfenv(0)})
LoadOnFuncEnvironment.LoadAddOn = AddonLoader.LoadAddOn
--[[
function LoadOnFuncEnvironment.LoadAddOn(addonName, ...)
	return AddonLoader:LoadAddOn(addonName, ...)
end  --]]


function ConditionManager.ParseLoadOnFunc(fieldOrCond)
	if  not fieldOrCond  then  return nil  end
	local fieldValue =  fieldOrCond.mainValue  or  fieldOrCond.fieldValue
	if  not fieldValue  then  return nil  end
	
	ConditionManager.parsedField = fieldOrCond
	
	--local ran, result = pcall(loadstring, fieldValue)
	local ran, result = safecall(loadstring, fieldValue)
	if  ran  and  type(result) == 'function'  then  setfenv(result, LoadOnFuncEnvironment)  end
	
	-- Caller might do more processing on this field, not finished with it yet
	--ConditionManager.parsedField = nil
	return  ran  and  result
end





------------------------------
-- Captain Hook's registrar --
------------------------------

do
	local function formatFieldReference(objectName)
		local field = ConditionManager.parsedField  or  EMPTY
		local addonName = field.addonName or ""
		local fieldName = field.fieldName and " "..field.fieldName or ""
		return "_G."..tostring(objectName).."  referenced in "..addonName.." metadata"..fieldName
	end
	
	
	local function CheckFrameExists(frameName)
		local frame = _G[frameName]
		if  frame == nil  then
			print("AddonLoader:  frame "..formatFieldReference(frameName).." does not exist")
		elseif  type(frame) ~= 'table'  then
			print("AddonLoader:  "..formatFieldReference(frameName).." is not an object")
		elseif  type(frame.HookScript) ~= 'function'  then
			print("AddonLoader:  "..formatFieldReference(frameName).." is not a frame")
		else
			return frame
		end
		return nil
	end

	local function CheckFuncExists(objectName, hookedFuncName, eventKey)
		local object =  not objectName  and  _G  or  _G[objectName]
		local hookedFunc =  object  and  object[hookedFuncName] 
		if  objectName  and  object == nil  then
			print("AddonLoader:  object "..formatFieldReference(objectName).." does not exist")
		elseif  objectName  and  type(object) ~= 'table'  then
			object = false
			print("AddonLoader:  "..formatFieldReference(objectName).." is not an object")
		elseif  hookedFunc == nil  then
			print("AddonLoader:  function "..formatFieldReference(eventKey).." does not exist")
		elseif  type(hookedFunc) ~= 'function'  then
			hookedFunc = false
			print("AddonLoader:  function "..formatFieldReference(eventKey).." is not a function")
		end
		return object, hookedFunc
	end
	
	ConditionManager.CheckFrameExists = CheckFrameExists
	ConditionManager.CheckFuncExists = CheckFuncExists


	--[[
	local EventObjBase = {}
	EventObjBase.__index = EventObjBase
	
	function EventObjBase:GetAddon(addonName)
		local addonConds = eventObj[addonName]
		if  addonConds  then  return addonConds  end
		
		addonConds = {}
		eventObj[addonName] = addonConds
		return addonConds
	end
	--]]

	local function InitEventObj(Hooks, objectName, eventName)
		local eventKey =  not objectName  and  eventName  or  objectName..':'..eventName
		local eventObj = Hooks[eventKey]
		-- Already created?
		if  eventObj  then  return  eventObj  end
		
		-- First time reference, create it
		eventObj = setmetatable({}, AutoCreateInnerTablesMT)
		Hooks[eventKey] = eventObj
		-- Tries to install the dispatcher only the first time the EventObj is requested. If it fails there's no errormessage spam.
		Hooks:InstallDispatcher(objectName, eventName, eventKey)
		
		return eventObj, eventKey
	end

	local function AddConditionHook(Hooks, objectName, eventName, field)
		local eventObj = InitEventObj(Hooks, objectName, eventName)
		eventObj[field.addonName][field.fieldName] = field
	end


	-- Copy AddConditionHook() method instead of inheriting it to save one __index lookup
	local EventHooksBase  = { AddConditionHook = AddConditionHook }
	local FrameHooksBase  = { AddConditionHook = AddConditionHook }
	local SecureHooksBase = { AddConditionHook = AddConditionHook }

	function EventHooksBase.InstallDispatcher(Hooks, frameName, eventName, eventKey)
		-- frameName is the "global environment" for EventHooks
		-- frameName == nil  could be '_G' instead
		ConditionManager:RegisterEvent(eventName)
		-- dispatchFunc is ConditionManager:OnEvent() in this case
		-- calling ConditionManager:EvaluateEvent(eventObj, eventName, ...)
	end

	function FrameHooksBase.InstallDispatcher(Hooks, frameName, scriptName, eventKey)
		local frame = CheckFrameExists(frameName)
		if  not frame  then  return false  end
		
		-- Only difference to ScriptHooksBase was: the 2nd parameter to EvaluateEvent is  frameName  instead of  eventKey ("frameName:scriptName")
		local function dispatchFunc(...)
			local eventObj = Hooks[eventKey]
			return eventObj and ConditionManager:EvaluateEvent(eventObj, frameName, ...)
		end
		
		local ran, result = safecall(function()  frame:HookScript(scriptName, dispatchFunc)  end)
		if  not ran  then  print("Failed to hook script "..eventKey..":  "..tostring(result) )  end
	end

	function SecureHooksBase.InstallDispatcher(Hooks, objectName, hookedFuncName, eventKey)
		local object, hookedFunc = CheckFuncExists(objectName, hookedFuncName, eventKey)
		if  not hookedFunc  then  return false  end
		
		local function dispatchFunc(...)
			local eventObj = Hooks[eventKey]
			return eventObj and ConditionManager:EvaluateEvent(eventObj, eventKey, ...)
		end
		
		local ran, result = not objectName    -- object == _G
			and  safecall(function()  hooksecurefunc(hookedFuncName, dispatchFunc)  end)
			or   safecall(function()  hooksecurefunc(object, hookedFuncName, dispatchFunc)  end)
		
		if  not ran  then  print("Failed to hook securefunc "..eventKey..":  "..tostring(result) )  end
	end

	EventHooksBase.__index  = EventHooksBase
	FrameHooksBase.__index  = FrameHooksBase
	SecureHooksBase.__index = SecureHooksBase
	setmetatable(ConditionManager.EventHooks , EventHooksBase )
	setmetatable(ConditionManager.FrameHooks , FrameHooksBase )
	setmetatable(ConditionManager.SecureHooks, SecureHooksBase)
end





--------------------------------------------
-- Loading conditions from saved settings --
--------------------------------------------

-- This method must be delayed until AddonLoader's ADDON_LOADED event. SavedVariables are loaded at that time.
-- Usually the StartupHandlers() runs after PLAYER_ENTERING_WORLD or ADDON_LOADED so this is not an issue.
function ConditionManager:LoadAllOverrides()
	if  not AddonLoaderSV  or  not AddonLoaderSV.overrides  then  return  end
	for  addonName, overridePage  in pairs(AddonLoaderSV.overrides) do
		local overrideFields = self.AddonOverrides[addonName]
		--for  i, line  in  ipairs({ strsplit('\n', overridePage) }) do
		for  line  in  overridePage:gmatch("[^\n]+") do
			--local key, value =  line:sub(1,2) == "##"  and  strsplit(':', line, 2)
			local key, value = strsplit(':', line, 2)
			local disable =  key[1] == '-'
			if  disable  then  key = key:sub(2)  end
			--local fieldName = key:sub(3):trim()
			local fieldName, fieldValue = key:trim(), value and value:trim() or ""
			if  disable  then  fieldValue = false  end
			overrideFields[#overrideFields+1] = fieldName
			overrideFields[fieldName] = fieldValue
		end
	end
end


function ConditionManager:SaveAddonOverrides(addonName)
	AddonLoaderSV =  AddonLoaderSV  or  {}
  AddonLoaderSV.overrides =  AddonLoaderSV.overrides  or  {}
	local fieldStrs = {}
	local overrideFields = self.AddonOverrides[addonName]
	
	for  i, fieldName  in ipairs(overrideFields) do
		local fieldValue = overrideFields[fieldName]
		if  not fieldValue  then
			-- Disabled field marked by '-' before the key.
			fieldStrs[#fieldStrs+1] = '-'
			-- fieldValue is ignored when loading. Saving original value that was disabled, for readability.
			fieldValue = GetAddOnMetadata(addonName, fieldName)
		end
		fieldStrs[#fieldStrs+1] = fieldName
		fieldStrs[#fieldStrs+1] = ": "
		fieldStrs[#fieldStrs+1] = fieldValue
		fieldStrs[#fieldStrs+1] = '\n'
	end
	AddonLoaderSV.overrides[addonName] = strjoin('', fieldStrs)
end




function ConditionManager:GetMergedField(addonName, fieldName)
	-- See if the field is overridden or disabled.
	local fieldValue = self.AddonOverrides[addonName][fieldName]
	if  fieldValue == false  then  return fieldValue  end
	
	-- If no override then load metadata.
	fieldValue =  fieldValue  or  GetAddOnMetadata(addonName, fieldName)
	if  not fieldValue  then  return fieldValue  end
	
	-- Return temporary object
	return { addonName = addonName, fieldName = fieldName, fieldValue = fieldValue }
end


function ConditionManager:RemoveField(addonName, fieldName)
	--if  GetAddOnMetadata(addonName, fieldName)  then
	self.AddonOverrides[addonName][fieldName] = false
end




--------------------------------------
-- Loading conditions from metadata --
--------------------------------------

function ConditionManager.LoadChildren(cond)
	cond.childList = splitValue(cond.mainValue)
	local childConds = {}
	cond.childConds = childConds
	for  i, childName  in ipairs(cond.childList) do
		local childCond = ConditionManager:LoadCondition(cond.addonName, 'X-LoadOn-'..childName)
		if  childCond  then
			childCond.parent = cond
			childConds[#childConds+1] = childCond
			childConds[childName] = childCond
			-- For backward compatibility parse main field's value as -If condition
			childCond.beforeLoadFunc =  childCond.beforeLoadFunc  or  ConditionManager.ParseLoadOnFunc(childCond)
		end
	end
end


function ConditionManager:LoadCondition(addonName, fieldName, condTmpl, cond)
	--local fieldName =  condTmpl  and  condTmpl.fieldName  or  cond  and  cond.fieldName
	-- The main field: X-LoadOn-*
	local mainField = self:GetMergedField(addonName, fieldName)
	-- The condition field: X-LoadOn-*-If
	local ifField = self:GetMergedField(addonName, fieldName.."-If")
	-- The initialization field: X-LoadOn-*-Init  or  X-LoadOn-*-DoAfter  or  X-AfterLoad-*
	local initField = self:GetMergedField(addonName, fieldName.."-Init")
	
	if  mainField  or  ifField  or  initField  then
		cond =  cond  or  condTmpl  and  setmetatable({ addonName = addonName, fieldName = fieldName }, { __index = condTmpl } )  or  {}
		if  mainField  then
			cond.mainValue = mainField.fieldValue
			local ran, result =  condTmpl  and  condTmpl.parseMain  and  safecall(condTmpl.parseMain, cond)
		end
		cond.beforeLoadFunc = self.ParseLoadOnFunc(ifField)
		cond.afterLoadFunc  = self.ParseLoadOnFunc(initField)
	end
	
	if  cond  and  cond.loadChildren  then
		local ran, result = safecall(cond.loadChildren, cond)
	end
	
	self.parsedField = nil
	return cond
end


function ConditionManager:LoadAddonConditions(addonName)
	local addonConds = self.MergedConditions[addonName]
	-- TODO: X-Load-Condition, X-Load-Delay, X-Load-OnlyOne, X-Load-Before, X-Load-Early
	for  i, condTmpl  in ipairs(self.ConditionTemplates) do
		local condName =  condTmpl.condName  or  condTmpl[1]
		condTmpl.condName = condName
		local cond = addonConds[condName]
		addonConds[condName] = self:LoadCondition(addonName, 'X-LoadOn-'..condName, condTmpl, cond)
	end
end


function ConditionManager:LoadAllConditions()
	for  i = 1, GetNumAddOns()  do
		local addonName, _, _, enabled = GetAddOnInfo(i)
		if  enabled  and  IsAddOnLoadOnDemand(i)  and  not IsAddOnLoaded(i)  then
			self:LoadAddonConditions(addonName)
		end
	end
end





---------------------------------
-- Registering condition hooks --
---------------------------------

function ConditionManager:RegisterConditionHooks(addonName, condition)
	self.parsedField = condition

	-- Register for events in condition.eventList
	for  _, eventName  in pairs(condition.eventList or EMPTY) do
		self.EventHooks:AddConditionHook(nil, eventName, condition)
	end

	if  condition.registerHook  then
		local ran, result = safecall(condition.registerHook, condition)
	end
	
	local registerChildHook =  condition.registerChildHook
	if  registerChildHook  then
		for  i, childName  in ipairs(condition.childList or EMPTY) do
			local childCond = condition.childConds[childName]
			local ran, result = safecall(registerChildHook, childCond or condition, childName)
		end
	end
	
	self.parsedField = nil
	return condition
end


function ConditionManager:RegisterAllConditionHooks()
	for  addonName, addonConds  in pairs(self.MergedConditions) do
		for  condName, condition  in ipairs(addonConds) do
			self:RegisterConditionHooks(addonName, condition)
		end
	end
end





---------------------------------------------------
-- Run-once initialization and startup functions --
---------------------------------------------------

-- Run-once StartupHandlers() initializes all addon metadata --
function ConditionManager.LoadConfiguration()
	local self = ConditionManager

	self:LoadAllOverrides()
	self:LoadAllConditions()
	self:RegisterAllConditionHooks()
	
	--[[
	-- Release memory of the one-time call methods
	self.LoadConfiguration = nil
	self.LoadAllOverrides = nil
	self.LoadAllConditions = nil
	self.RegisterAllConditionHooks = nil
	--]]
end


function ConditionManager.RunStartupHandlers()
	local self = ConditionManager
	for  addonName, addonConds  in pairs(self.MergedConditions) do
		for  condName, condition  in ipairs(addonConds) do
			if  not condition.eventList  or  0 == #condition.eventList  then
				-- If not waiting for events then the handler and beforeLoadFunc is called once after initialization with nil event passed.
				self:EvaluateCondition(addonName, condition, nil)    -- eventName == nil
			end
		end
	end
	
	-- Release memory of the one-time call method
	--self.RunStartupHandlers = nil
end


function ConditionManager.RunHandlersForCachedEvents()
	AddonLoader:ReplayCachedEvents(ConditionManager)
	
	-- Release memory of the one-time call method
	--self.RunHandlersForCachedEvents = nil
end





-------------------------------
-- Evaluating trigger events --
-------------------------------

-- Replayed events start evaluation here
function ConditionManager:FireEvent(eventName, ...)
	local eventObj = self.EventHooks[eventName]
	return  eventObj  and  self:EvaluateEvent(eventObj, eventName, ...)
end


-- Frame events start evaluation here
function ConditionManager:OnEvent(eventName, ...)
	local eventObj = self.EventHooks[eventName]
	if  not eventObj  then
		print("ConditionManager:OnEvent("..eventName.."): no more handlers, should not be registered.")
		return self:UnregisterEvent(eventName)
	end
	return self:EvaluateEvent(eventObj, eventName, ...)
end


-- Tl;Dr version of EvaluateEvent() without comments and error handling
-- EvaluateEvent() with called functions is 60 lines brutto
-- ConditionManager.EventHooks[eventKey][addonName][fieldName]
-- eventObj[addonName][fieldName]
function ConditionManager:EvaluateEventTlDr(eventObj, ...)
	-- eventName == ...
	local loading = false
	for  addonName, conditions  in pairs(eventObj) do
		for  fieldName, condition  in pairs(conditions) do
			local ran, result = safecall(condition.handler, condition, ...)
			ran, result = (not ran or result)  and  safecall(condition.beforeLoadFunc, condition, ...)
			local loadingThis = (not ran or result)  and  self:RegisterToLoad(addonName, condition)
			if  loadingThis  then  loading = true ;  break  end    -- exit inner loop, continue with next addon
		end
	end
	return loading
end



-- Event hub for addons' handlers
-- ConditionManager.EventHooks[eventKey][addonName][fieldName]
-- eventObj[addonName][fieldName]
function ConditionManager:EvaluateEvent(eventObj, ...)
	-- eventName == ...
	local loading = false
	-- Check each managed addon
	for  addonName, conditions  in pairs(eventObj) do  if  not conditions.error  then
		-- Do safecall so any error will only stop one addon's evaluation
		local ran, result = safecall(self.EvaluateAddon, self, addonName, conditions, ...)
		if  not ran  then
			-- If AddonLoader was unable to evaluate the conditions then
			-- load the addon regardless of conditions, otherwise the user won't be able to use this addon.
			conditions.error = result
			result = AddonLoader:RegisterToLoad(addonName, condition)
		end
		loading = loading or result
	end  end  -- closing for + if
	return loading
end


function ConditionManager:EvaluateAddon(addonName, conditions, ...)
	-- eventName == ...
	local loading = false
	if  not IsAddOnLoaded(addonName)  then
		-- Check if tried to load before
		if  AddonLoader.loadReason[addonName]  then  return false  end
		
		for  fieldName, condition  in pairs(conditions) do
			-- This code is reentrant to support the case when another addon is loaded recursively while initializing an addon.
			local parentEvaluatedCondition = self.evaluatedCondition
			loading = self:EvaluateCondition(addonName, condition, ...)
			self.evaluatedCondition = parentEvaluatedCondition
			-- If condition is true then stop iterating
			if  loading  then  break  end
		end
	end
	
	return loading
end


function ConditionManager:EvaluateCondition(addonName, condition, ...)
	if  condition.error  then  return false  end
	self.evaluatedCondition = condition
	-- If a handler fails with error then it is ignored to load the addon early instead of never. This includes the case when  condition.handler == nil
	local ran, result = nil, nil
	if  condition.handler  then  ran, result = safecall(condition.handler, condition, ...)  end
	-- It is possible the beforeLoadFunc will load the addon and return nil.
	if  not ran or result  then  ran, result = safecall(condition.beforeLoadFunc, condition, ...)  end
	-- The beforeLoadFunc must return some Trueish value to load the addon.
	-- nil is used as false. (1nil type.. 1nilla..)
	-- The beforeLoadFunc might have loaded the addon, check consistency with ADDON_LOADED event.
	AddonLoader:CheckAddOnLoaded(addonName)
	
	--self.evaluatedCondition = condition    -- will set when actually loading
	local loading = (not ran or result)  and  AddonLoader.QueueLoadAddOn(addonName, condition)
	return loading
end


function ConditionManager:ForgetAddon(addonName)
	for  eventName, eventObj  in self.EventHooks do
		eventObj[addonName] = nil
		local more = next(eventObj)
		if  not more  then
			self.EventHooks[eventName] = nil
			self:UnregisterEvent(eventName)
		end
	end
	for  eventKey, eventObj  in self.FrameHooks do
		eventObj[addonName] = nil
		-- eventObj will be referenced by the HookScript until reload
		-- as there is no way to "unregister" HookScript
		-- removing it from FrameHooks would not save memory
	end
	for  eventKey, eventObj  in self.SecureHooks do
		eventObj[addonName] = nil
		-- Same applies here: there is no way to "unregister" SecureHooks
	end
	return true
end





