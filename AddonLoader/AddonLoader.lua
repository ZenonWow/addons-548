--[[ Purpose of AddonLoader: save memory and fps before raiding, speed up load times when switching characters (too many bank alts?).
-- For ex. don't load accounting/auctioning until you go to the auction house.
-- If you just go raiding you get better fps without those addons running in the background.
-- If you did some trading, crafting, petbattling then reload your ui before raiding
-- to unload the unneccessary addons, save memory and disable their background processing.
-- On the other hand when jumping between bank alts you can save the time taken by loading the raid addons.
--]]


local ADDON_NAME, private = ...
local _G = _G
-- GLOBALS: GetAddOnInfo GetAddOnMetadata IsAddOnLoaded IsAddOnLoadOnDemand GetNumAddOns LoadAddOn
-- GLOBALS: AddonLoaderSV
local tostring, pairs, select, next, string = 
      tostring, pairs, select, next, string
local InCombatLockdown = InCombatLockdown


local AddonLoader = CreateFrame('Frame', 'AddonLoader')
--AddonLoader:Hide()
_G.AddonLoader = AddonLoader
local ConditionManager = CreateFrame('Frame')    -- , 'AddonLoaderConditionManager')
ConditionManager:Hide()
AddonLoader.ConditionManager = ConditionManager
AddonLoader.frame = ConditionManager  -- deprecated: easy reference for use in X-LoadOn-Events

-- Debug(...) messages
function private.Debug(...)  if  AddonLoader.logFrame  then  AddonLoader.logFrame:AddMessage( string.join(", ", tostringall(...)) )  end end
local Debug = private.Debug
AddonLoader.logFrame = tekDebug  and  tekDebug:GetFrame("AddonLoader")  or  ChatFrame4
if  not tekDebug  then  ChatFrame4:Show()  end

AddonLoader.loadReason = {}
AddonLoader.loadError = {}

AddonLoader.slashes = {} -- ["AddonName"] = { "ADDON_SLASH"="/slash", "ADDON_DOTHIS"="/dothis", ... }, ["AnotherAddon"] = ...
AddonLoader.conditiontexts = {}

ConditionManager.EventHooks = {}
ConditionManager.ScriptHooks = {}
ConditionManager.SecureHooks = {}

local textColors = {
	error = { 1,0,0,1 },		-- red
	notify = { 1,1,0,1 },		-- yellow
	white = { 1,1,1,1 },
}

function AddonLoader:Print(text)
	_G.DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF99AddonLoader|r: ".. tostring(text))
end

function AddonLoader:Toast(text, color)
	_G.DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF99AddonLoader|r: ".. tostring(text))
	UIErrorsFrame:AddMessage(text, unpack(color or textColors.white))
end




-- Lua-kind error (exception) handling: a try-catch block around unsafeFunc(...)
-- Report eventual error to standard geterrorhandler(): BugGrabber or Swatter or Lua error popup.
-- Then continue processing without the aborting all code in the current event handler.
function private.safecall(unsafeFunc, ...)
	if type(unsafeFunc) ~= "function" then  return  end
	-- Without parameters call the function directly
	if  0 == select('#',...)  then
		return xpcall(unsafeFunc, geterrorhandler())
  end

	-- Pack the parameters to pass to the actual function
	local params =  { ... }
	-- Unpack the parameters in the thunk
	local function safecallThunk()  unsafeFunc( unpack(params) )  end
	-- Do the call through the thunk
	return xpcall(safecallThunk, geterrorhandler())
end
local safecall = private.safecall

-- Return true if no function provided
local function safecallOpt(unsafeFunc, ...)  return  not unsafeFunc  or  safecall(unsafeFunc, ...)  end




------------------------------
-- Captain Hook's registrar --
------------------------------

local function CheckFrameExists(frameName)
	local frame = _G[frameName]
	if  not frame  then  print("AddonLoader:  frame  "..tostring(frameName).."  referenced in addon metadata does not exist")  end
	return frame
end

local function CheckFuncExists(objectName, hookedFuncName)
	local object =  not objectName  and  _G  or  _G[objectName]
	local hookedFunc =  object  and  object[hookedFuncName] 
	if  objectName  and  not object  then  print("AddonLoader:  global object  "..tostring(objectName).."  referenced in addon metadata does not exist")
	elseif  not hookedFunc  then  print("AddonLoader:  function  "..tostring(objectName or "_G").."."..hookedFuncName.."()  referenced in addon metadata does not exist")
  end
	return object, hookedFunc
end


local function GetEventBase(self, objectName, eventName)
	local eventKey =  not objectName  and  eventName  or  objectName..'.'..eventName
	local eventObj = self[eventKey]
	if  eventObj  then  return  eventObj  end
	eventObj = {}
	self[eventKey] = eventObj
	self:RegEvent(objectName, eventName, eventObj)
	return eventObj, eventKey
end

-- Poor man's inheritance. It is cheap indeed with one less __index lookup.
ConditionManager.EventHooks.GetEventObj = GetEventBase
ConditionManager.ScriptHooks.GetEventObj = GetEventBase
ConditionManager.SecureHooks.GetEventObj = GetEventBase

function ConditionManager.EventHooks:RegEvent(frameName, eventName, eventObj)
	-- frameName == nil  -- Could be '_G'
	ConditionManager:RegisterEvent(eventName)
end

function ConditionManager.ScriptHooks:RegEvent(frameName, scriptName, eventObj)
	if  not frameName  then
		ConditionManager:RegisterEvent(scriptName)
	else
		local frame = CheckFrameExists(frameName)
		if  not frame  then  return false  end
		local function dispatchFunc(...)  ConditionManager:EvaluateEvent(eventObj, scriptName, ...)  end
		frame:HookScript(scriptName, dispatchFunc)
  end
end

function ConditionManager.SecureHooks:RegEvent(objectName, hookedFuncName, eventObj)
	local object, hookedFunc = CheckFuncExists(objectName, hookedFuncName)
	if  not hookedFunc  then  return false  end
	
	local function dispatchFunc(...)  ConditionManager:EvaluateEvent(eventObj, hookedFuncName, ...)  end
	if  not objectName  then
		-- object == _G
		hooksecurefunc(hookedFuncName, dispatchFunc)
  else
		hooksecurefunc(object, hookedFuncName, dispatchFunc)
  end
end




---------------------------------------------------------
-- Loading conditions from metadata and saved settings --
---------------------------------------------------------

local EMPTY = {}
function ConditionManager:AddCondition(addonName, condTmpl, condValue)
	if  not condTmpl  then  print("AddCondition("..addonName.."): condTmpl == nil") ; return false  end
	
	local condition = {
		addonName = addonName,
		condTmpl = condTmpl,
		--handler = condTmpl.handler,
		condValue = condValue,
		arg = condValue,
	}
	-- condition inherits from the template:  .parser(condValue), .onload(condition),
	-- .handler(condition, eventName, ... event params)
	setmetatable(condition, { __index = condTmpl })
	
	if  condition.onload  then
		-- Do necessary preprocessing, reading dependant conditions
		-- It should register event handlers base on the condValue.
		-- It can add additional conditions from further metadata fields.
		local ran, result = safecall(condition.onload, condition)
	end
	
	for  _, eventName  in pairs(condition.eventList or EMPTY) do
		local eventObj = self.EventHooks:GetEventObj(nil, eventName)
		local conditions = eventObj[addonName] or {}
		eventObj[addonName] = conditions
		conditions[condition.condName] = condition
	end
	return condition
end


function AddonLoader:LoadMetadataField(addonName, condTmpl)
	local condName = condTmpl.condName
	local condValue = GetAddOnMetadata(addonName, condName)
	if  not condValue  then  return false  end
	
	-- Build the textblock as base for overrides
	local condText = self.conditiontexts[addonName]  or  ""
	condText = condText .. condName..": "..condValue.."\n"
	self.conditiontexts[addonName] = condText
	
	ConditionManager:AddCondition(addonName, condTmpl, condValue)
end


function AddonLoader:LoadAddonMetadata(addonName)
	-- scan metadata.
	-- inject events with the correct handlers for all addons.
	-- register for those events on our frame
	local this = self
	for  condName, condTmpl  in pairs(self.conditions) do
		-- If any metadata field should cause an error, the other fields will still load and work
		safecall(function() this:LoadMetadataField(addonName, condTmpl) end)
	end
end


-- scan all addons and their metadata for X-LoadOn directives.
function AddonLoader:LoadAllMetadata()
	-- Init builtin conditions
	for  condName, condTmpl  in pairs(self.conditions) do
		condTmpl.condName = condName
	end
	-- Iterate addons
	local this = self
	for  i = 1, GetNumAddOns()  do
		local addonName, _, _, enabled = GetAddOnInfo(i)
		if  enabled  and  IsAddOnLoadOnDemand(i)  and  not IsAddOnLoaded(i)  then
			safecall(function() this:LoadAddonMetadata(addonName) end)
		end
	end
end


-- this will be called at PLAYER_LOGIN at which point the saved vars should be present
function AddonLoader:LoadOverrides()
	if not AddonLoaderSV then
		AddonLoaderSV = { -- overrides
			overrides = {},
		}
	end
	self.originals = {}
	for k, v in pairs(self.conditiontexts) do
		self.originals[k] = v
	end
	for addonName, conditiontext in pairs(AddonLoaderSV.overrides) do
		-- we have an addon lets clear the events for this addon and override unconditionaly.
		for eventName, eventObj in pairs(ConditionManager.EventHooks) do
			eventObj[addonName] = nil -- nuke
		end
		self.conditiontexts[addonName] = conditiontext
		-- we have a conditiontext override lets do it.
		for line in conditiontext:gmatch("[^\n]+") do
			local condName, condValue = string.match(line, "^([^:]*): (.*)$")
			if condName and condValue then
				ConditionManager:AddCondition(addonName, self.conditions[condName], condValue)
			end
		end
	end
end



----------------------------------------
-- Initializing conditions on startup --
----------------------------------------

function AddonLoader:ParseConditions()
	for  eventName, eventObj  in pairs(ConditionManager.EventHooks) do
		for  addonName, conditions  in pairs(eventObj) do
			for  condName, condition  in pairs(conditions) do
				if  condition.parser  then
					-- Optional. Parse the textual value to a function or data object, as the handler expects.
					local ran, result = safecall(condition.parser, condition)
					if  ran  then  condition.parsedValue = result  end
				else
					-- In the common case parse as a condition
					condition.beforeLoadFunc = self.ParseConditionFunc(condition)
				end
			end
		end
	end
end
	
	
function AddonLoader:RunStartupHandlers()
	for  eventName, eventObj  in pairs(ConditionManager.EventHooks) do
		for  addonName, conditions  in pairs(eventObj) do
			for  condName, condition  in pairs(conditions) do
				if  not condition.eventList  or  0 == #condition.eventList  then
					-- If not waiting for events then the handler and beforeLoadFunc is called once after initialization without event.
					self:EvaluateCondition(condition, nil)    -- event == nil
				end
			end
		end
	end
end




-- One-time startup event handler initializes all the addons
function AddonLoader:LoadConditions()
	assert(self.StartOnEvent, "AddonLoader:LoadConditions() must be called only once")
	self.StartOnEvent = nil    -- no more triggers
	
	-- Initialize addon metadata
	self:LoadAllMetadata()
	self:LoadOverrides()
end


function AddonLoader:InitConditions()
	self:ParseConditions()
	self:RunStartupHandlers()
	
	self.replayedEvents = {}
	self:EvaluateCachedEvent('VARIABLES_LOADED')
	self:EvaluateCachedEvent('SPELLS_CHANGED')
	self:EvaluateCachedEvent('PLAYER_LOGIN', IsLoggedIn())
	self:EvaluateCachedEvent('PLAYER_ENTERING_WORLD', IsPlayerInWorld())
	
	--[[
	-- Release memory of the one-time call methods
	self.LoadConditions = nil
	self.LoadAllMetadata = nil
	self.LoadOverrides = nil
	self.InitConditions = nil
	self.ParseConditions = nil
	self.RunStartupHandlers = nil
	self.EvaluateCachedEvent = nil
	--]]
end


function AddonLoader:EvaluateCachedEvent(event, happened)
	local cachedEvent = self.cachedEvents[event]
	if  typeof(cachedEvent) ~= 'table'  then  cachedEvent = nil  end
	if  cachedEvent  or  happened  then
		self.replayedEvents[event] = cachedEvent
		ConditionManager:OnEvent(event, cachedEvent and unpack(cachedEvent))
	end
end


function AddonLoader:IsVariablesLoaded()  return self.cachedEvents.VARIABLES_LOADED  end
function AddonLoader:IsSpellsLoaded()  return self.cachedEvents.SPELLS_CHANGED  end



-------------------------------
-- Evaluating trigger events --
-------------------------------

-- Frame events start evaluation here
function ConditionManager:OnEvent(event, ...)
	local eventObj = self.EventHooks[event]
	if  eventObj  then
		self:EvaluateEvent(eventObj, event, ...)
	else
		print("ConditionManager:OnEvent("..event.."): no more handlers, should not be registered.")
		self:UnregisterEvent(event)
	end
end


-- Tl;Dr version of EvaluateEvent() without comments, error handling and corner cases
-- EvaluateEvent() with called functions is 60 lines brutto
-- ConditionManager.EventHooks[eventKey][addonName][condName]
-- eventObj[addonName][condName]
function ConditionManager:EvaluateEventTlDr(eventObj, event, ...)
	for  addonName, conditions  in pairs(eventObj) do
		for  condName, condition  in pairs(conditions) do
			local ran, result = safecall(condition.handler, condition, event, ...)
			ran, result = (not ran or result)  and  safecall(condition.beforeLoadFunc, condition, event, ...)
			local loaded = (not ran or result)  and  self:LoadAddOn(addonName, condition, afterLoadFunc)
		end
	end
end



-- Event hub for addons' handlers
-- ConditionManager.EventHooks[eventKey][addonName][condName]
-- eventObj[addonName][condName]
function ConditionManager:EvaluateEvent(eventObj, event, ...)
	-- Check each managed addon
	for  addonName, conditions  in pairs(eventObj) do  if  not conditions.error  then
		-- Do safecall so any error will only stop one addon's evaluation
		local ran, result = safecall(self.EvaluateAddon, self, addonName, conditions, event, ...)
		-- If this caused an error, then not trying next time
		if  not ran  then  conditions.error = result  end
	end  end  -- closing for - if
end


function ConditionManager:EvaluateAddon(addonName, conditions, event, ...)
	local result
	if  not IsAddOnLoaded(addonName)  then
		-- Check if tried to load before
		if  self.loadReason[addonName]  then  return false  end
		
		for  condName, condition  in pairs(conditions) do
			local parentEvaluatedCondition = self.currentEvaluatedCondition
			result = self:EvaluateCondition(condition, event, ...)
			-- This code is reentrant in case some event during addon load triggers it recursively.
			self.currentEvaluatedCondition = parentEvaluatedCondition
			-- If addon loading was attempted then stop iterating
			if  result ~= nil  then  break  end
		end
	end
	
	if  IsAddOnLoaded(addonName)  then
		self:ForgetAddon(addonName)
		return true
	end
	return result
end


function ConditionManager:EvaluateCondition(condition, event, ...)
	if  condition.error  then  return nil  end
	if  condition.handler  then
		self.currentEvaluatedCondition = condition
		local ran, result = safecall(condition.handler, condition, event, ...)
		-- Mark the condition as failing
		--if  not ran  then  condition.error = result  end
		-- If the builtin handler caused an error, that won't be fixed in the shortterm.
		-- To leave the user with a usable addon, load it unconditionally, ignoring the faulty handler.
		-- If the handler returned without truthy result then do not load yet
		if  ran  and  not result  then  return nil  end
	end
	local afterLoadFunc
	if  condition.beforeLoadFunc  then
		self.currentEvaluatedCondition = condition
		-- It is possible the beforeLoadFunc will load the addon and return nil.
		local ran, result = safecall(condition.beforeLoadFunc, condition, event, ...)
		-- If this caused an error, then not trying next time
		--if  not ran  then  condition.error = result  end
		-- The handler must return some Trueish value to load the addon.
		-- NIL is used as false in wow style programming. (1nil type... 1nilla...)
		if  ran  and  not result  then  return nil  end
		-- If the beforeLoadFunc returned a function it will be called after the addon loaded.
		afterLoadFunc =  ran  and  type(result) == 'function'  and  result
	end
	
	-- Flagged for loading
	self.currentEvaluatedCondition = condition
	return self:LoadAddOn(addonName, condition, afterLoadFunc)
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
	for  eventKey, eventObj  in self.ScriptHooks do
		eventObj[addonName] = nil
		-- eventObj will be referenced by the ScriptHook until reload
		-- as there is no way to "unregister" ScriptHooks
		-- removing it from ScriptHooks would not save memory
	end
	for  eventKey, eventObj  in self.SecureHooks do
		eventObj[addonName] = nil
		-- Same applies here: there is no way to "unregister" SecureHooks
	end
	return true
end






--------------------------------------
-- Addon loading and initialization --
--------------------------------------

-- The public API: substitute for builtin LoadAddOn(addonName)
-- Can be called either as a function or as a method:
-- AddonLoader.LoadAddOn(addonName, loadCondition, afterLoadFunc)
-- AddonLoader:LoadAddOn(addonName, loadCondition, afterLoadFunc)
function AddonLoader:LoadAddOn(addonName, loadCondition, afterLoadFunc)
  -- Check if this is a function call like AddonLoader.LoadAddOn(addonName, loadCondition, afterLoadFunc)
	if  type(self) == 'table'  and  self.LoadAndInitialize  then
		-- Owns the method that will be called next, therefore it qualifies as AddonLoader.
	else
		-- Function call, shifting parameters to make place for self = AddonLoader
		self, addonName, loadCondition, afterLoadFunc  =  AddonLoader, self, addonName, loadCondition
	end
	assert( type(addonName) == 'string', "Usage: AddonLoader.LoadAddOn(addonName, loadCondition, afterLoadFunc), expects string addonName, received "..type(addonName) )
	-- Use safecall to protect callers from any error that might occur while hacking the addon initialization.
	--safecall( function() self:LoadAndInitialize(addonName, loadCondition, afterLoadFunc) end )
	-- Alternative:
	local ran, result = safecall(self.LoadAndInitialize, self, addonName, loadCondition, afterLoadFunc)
	if  not ran  then  print( "AddonLoader.LoadAddOn("..tostring(addonName)..") error:  "..tostring(result) )  end
	return  ran  and  result
end
--[[
function AddonLoader.LoadAddOn(addonName, loadCondition, afterLoadFunc, ...)
	local self = AddonLoader
  -- Check if this is a method call like AddonLoader:LoadAddOn(addonName, loadCondition, afterLoadFunc)
	if  type(addonName) == 'table'  and  addonName.LoadAndInitialize  then
		-- Owns the method that will be called next, therefore it qualifies as self. Also shift the other parameters one left.
		self, addonName, loadCondition, afterLoadFunc =  addonName, loadCondition, afterLoadFunc, ...
	else
		assert( type(addonName) == 'string', "Usage: AddonLoader.LoadAddOn(addonName, loadCondition, afterLoadFunc), expects string addonName, received "..type(addonName) )
	end
	-- Use safecall to protect callers from any error that might occur while hacking the addon initialization.
	--safecall( function() self:LoadAndInitialize(addonName, loadCondition, afterLoadFunc) end )
	-- Alternative:
	local ran, result = safecall(self.LoadAndInitialize, self, addonName, loadCondition, afterLoadFunc)
	if  not ran  then  print( "AddonLoader.LoadAddOn("..tostring(addonName)..") error:  "..tostring(result) )  end
	return  ran  and  result
end
--]]



function AddonLoader:BeforeLoadAddOn(addonName, loadCondition)
	-- If there are slashes registered for the the addon, remove them
	local slashes = self.slashes[addonName]
	if  slashes  then
		local SlashCmdList, hash_SlashCmdList, hash_ChatTypeInfoList = _G.SlashCmdList, _G.hash_SlashCmdList, _G.hash_ChatTypeInfoList
		for  commandLong, slash  in pairs(slashes) do
			if  not _G['SLASH_'..commandLong..'1']  then  print("BeforeLoadAddOn(): SLASH_"..commandLong.."1 == nil, missing slash command")  end
			if  not SlashCmdList[commandLong]  then  print("BeforeLoadAddOn(): SlashCmdList["..commandLong.."] == nil, missing slash command")  end
			_G['SLASH_'..commandLong..'1'] = nil	-- command -> slash(es)
			SlashCmdList[commandLong] = nil		-- command -> function map
			hash_SlashCmdList[slash] = nil				-- slash -> function map
			hash_ChatTypeInfoList[slash] = nil		-- slash -> function map
		end
		self.slashes[addonName] = nil   -- and nil out our list. saves resources and prevents us NILling again if someone calls this function on a loaded addon.
	end

	Debug(addonName.." is loading.")
	if not AddonLoaderSV.silent then
		--self:Print("Loading " .. addonName)
		self:Toast(addonName.." is loading...", textColors.notify)
	end
end


function AddonLoader:LoadAndInitialize(addonName, loadCondition, afterLoadFunc)
	if  IsAddOnLoaded(addonName)  then  return true  end

	-- Verify that the addon isn't disabled
	local exactName, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonName)
	if  not enabled  or  not exactName  then  return false  end

	-- Make sure addonName has the proper original casing. Table indexes must be exact.
	addonName = exactName

	--if  self.loadError[addonName]  then  return false  end
	if  self.loadReason[addonName]  then  return false  end
	self.loadReason[addonName] = loadCondition

	-- Before load cleanup is not as important as loading the addon. Ignore if it fails, Buggrabber's errorhandler will catch the error.
	local this = self  -- need to save in closure
	local ran, result = safecall(function() this:BeforeLoadAddOn(addonName) end)
	--if  not ran  then  Debug("AddonLoader:BeforeLoadAddOn("..tostring(addonName)..") error:  "..tostring(result))  end

	-- Initialize capturing frames, event handlers and hooks interested in receiveing the events occuring during a normal addon load
	local capture = self:StartCapture()

	-- Load the addon
	local status, err = LoadAddOn(addonName)
	capture:StopCapture()
	
	if  not status  then
		self.loadError[addonName]  = err
		self:Print(addonName.."  addon load error: "..err)
		self:Toast(addonName.."  addon failed to load", textColors.error)
		return status, err
	elseif  not IsAddOnLoaded(addonName)  then
		self.loadError[addonName]  = "No error, but not loaded"
	end
	
	-- Replay the standard events of addon loading
	local eventsOk, eventsErr = capture:SendAddOnLoadEvents()
	if  not eventsOk  then
		self:Print(addonName.."  addon initialization error: "..eventsErr)
		self:Toast(addonName.."  addon failed to initialize properly", textColors.error)
		-- Report the error, but return the loading succeeded.
	end
	
	-- After load callback function loaded from metadata
	afterLoadFunc =  afterLoadFunc  or  loadCondition.afterLoadFunc
	if  loaded  and  afterLoadFunc  then  safecall(afterLoadFunc)  end
	
	return status, err
end




----------------------------------------
-- Delayed / background addon loading --
----------------------------------------

-- Load one addon, or one dependency of it, one at a time.
-- Returns name of addon loaded. Nil, if nothing to load.
-- Should any error occur it will take down the current OnUpdate() call only.
-- Next time it will continue with the next addon, skipping the one that failed.
function AddonLoader:LoadOneAddon(addonsToLoad)
	addonsToLoad =  addonsToLoad  or  self.addonsToLoad
	local toload = addonsToLoad[1]
	-- Function can be queued too, ex. self:LoadConditions() for initialization
	if  type(toload) == 'function'  then
		-- Remove first. If it errs it will be skipped next time.
		table.remove(addonsToLoad, 1)
		-- Run function
		toload(self)
		return toload
	end
	
	local deps = addonsToLoad[toload]
	local loadIdx
	for  i = 1, #deps  do
		if  not IsAddOnLoaded(deps[i])  then  loadIdx = i ; break  end
	end
	
	local addonName =  loadIdx  and  deps[loadIdx]
	if  not addonName  then
		Debug("LoadOneAddon():  "..tostring(toload).." was loaded since the last OnUpdate()")
		table.remove(addonsToLoad, 1)
	else
		if  addonName == toload  then
			-- All dependencies loaded, loading top-level addon: remove from toload list.
			table.remove(addonsToLoad, 1)
		else
			-- Remove loadIdx elements -> move loadIdx+i to i, nil the rest.
			for  i = 1, #deps - loadIdx  do  deps[i] = deps[loadIdx+i] ; deps[loadIdx+i] = nil  end
		end
		-- Load it
		self:LoadAddOn(addonName)
	end
	return addonName
end



local function addDependencies(myDeps, visited, addonList)
	for  _, addon  in ipairs(addonList) do
		if  IsAddOnLoaded(addon)  then
			-- Skipping loaded addons
		elseif  myDeps[addon]  then
			-- Addon already in list, not repeating
		else
			local addonDeps = AddonLoader.GetAddonsToLoad(addon, visited)
			if  type(addonDeps) == 'table'  then
				for  _, dep  in ipairs(addonDeps) do
					if  not myDeps[dep]  then
						myDeps[#myDeps] = dep
						myDeps[dep] = visited[dep]  or  true
					end
				end
			end
		end
	end
end

--[[ getAddonsToLoad differs from getAddonDependencies in 2 distinct features:
-- Exludes addons that are loaded already.
-- Includes the queried addon itself in the list of addons to load. Makes sense. getAddonDependencies would not include the addon itself.
--]]
function AddonLoader.GetAddonsToLoad(addonName, visited)
	visited = visited or {}
	if  visited[addonName]  then  return visited[addonName], visited  end
	-- Do not recurse into this addon if the dependency links are circular
	visited[addonName] = 'visiting'
	
	-- Recurse into dependencies first:  depth-first search of the dependency tree
	local myDeps = {}
	myDeps[addonName] = 'self'
	-- Dual recursion: call addDependencies(depAddon) -> call GetAddonsToLoad(depAddon)
	addDependencies(myDeps, visited, {GetAddOnDependencies(depAddon)} )
	addDependencies(myDeps, visited, {GetAddOnOptionalDependencies(depAddon)} )
	
	-- Include the addon itself last in the list
	myDeps[#myDeps] = addonName
	--myDeps[addonName] = 'self'
	
	-- Save the dependencies of this addon
	visited[addonName] = myDeps
	return myDeps, visited
end


function AddonLoader:RegisterDelayedLoad(addonName, loadCondition)
	self.GetAddonsToLoad(addonName, self.addonsToLoad)
	--self.addonsToLoad[name] = getAddonsToLoad(addon, self.addonsToLoad)
	self.addonsToLoad[#self.addonsToLoad] = addonName
	self:Show()
end


function AddonLoader:SetDelayNextLoad(framesDelay, framesToSkip)
	AddonLoader.delayNextLoad = framesDelay
	AddonLoader.framesDrawn = -(framesToSkip or 1)
	AddonLoader.elapsedSum = 0
end



-- The heartbeat of AddonLoader
-- Delayed loading, 10 frames drawn between addons
function AddonLoader:OnUpdate(elapsed)
	self.framesDrawn = self.framesDrawn + 1
	if  0 < self.framesDrawn  then
		self.elapsedSum = self.elapsedSum + elapsed
	else
		local now = GetTime()
		Debug( "AddonLoader:OnUpdate(elapsed="..("%.3f"):format(elapsed).."): GetTime() difference="..(now-self.lastUpdateGetTime)..", slowdown expected" )
		self.lastUpdateGetTime = now
		--self.elapsed = 0
	end
	if  not self.delayNextLoad  or  self.framesDrawn < self.delayNextLoad  then  return  end
	
	if  InCombatLockdown()  then
		-- 5.2 hates using too much CPU during combat
		-- While loading addons might do some actions not allowed in combat.
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		self:Hide()
		return
	end
	
	local now = GetTime()
	local fps = self.framesDrawn / self.elapsedSum
	local spf = self.elapsedSum / self.framesDrawn
	local msg = self.framesDrawn.." frames: "..("%.3f"):format(self.elapsedSum).."sec "..("%.2f"):format(fps).."fps "..("%.2f"):format(spf).."s/f"
	Debug( "AddonLoader:OnUpdate(elapsed="..("%.3f"):format(elapsed).."): GetTime() difference="..(now-self.lastUpdateGetTime)..", "..msg )
	self.lastUpdateGetTime = now
	-- Next addon after 0.15 sec on 60fps, 0.3 sec on 30fps, in framesDrawn. First frame is delayed arbitrarily by the addon loading, therefore skipped.
	--self:SetDelayNextLoad(9, 5)
	self:SetDelayNextLoad(30, 5)   -- slow for testing
	
	local loaded = self:LoadOneAddon(self.addonsToLoad)
	now = GetTime()
	Debug( "Delayed loaded "..tostring(loaded)..":  GetTime() difference="..(now-self.lastUpdateGetTime) )
	self.lastUpdateGetTime = now
	
	if  0 == #self.addonsToLoad  then
		self:Hide()
	end
end



AddonLoader.lastUpdateTime = time()
AddonLoader.lastUpdateGetTime = GetTime()
AddonLoader.lastLoadTime = time()
AddonLoader.lastLoadGetTime = GetTime()
AddonLoader.addonsLoaded = {}

-- The ears of AddonLoader
-- Monitoring addon load events, delaying startup (scanning metadata)
function AddonLoader:OnEvent(event, ...)
	Debug("AddonLoader:OnEvent(".. strjoin(", ", event, tostringall(...)) ..")")
	if  self.addonLoadEvents[event]  then
		-- Last event overwrites previous event (only PLAYER_ENTERING_WORLD is fired multiple times).
		local cached = self.cachedEvents[event]
		if  cached  then  tDeleteItem(self.cachedEvents, cached)  end
		-- Save event parameters for replay. Tho these events are not supposed to have parameters.
		cached = { event = event, timeStamp = date("%H:%M:%S"), time = time(), GetTime = GetTime(), ... }
		self.cachedEvents[#self.cachedEvents+1] = cached
		self.cachedEvents[event] = cached
		Debug("Cached "..event.."(".. strjoin(', ', tostringall(...)) ..")")
	end
	
	if  event == 'ADDON_LOADED'  then
		local addonName = select(1, ...)
		local addonLoadEvent = { addonName = addonName, timeStamp = date("%H:%M:%S"), time = time(), GetTime = GetTime(), select(2, ...) }
		self.addonsLoaded[#self.addonsLoaded+1] = addonLoadEvent
		addonLoadEvent.idx = #self.addonsLoaded
		self.addonsLoaded[addonName] = addonLoadEvent
		local now, nowGet = time(), GetTime()
		Debug("ADDON_LOADED("..addonName.."):  time since last="..(now - self.lastLoadTime).." sec, GetTime() elapsed="..(nowGet - self.lastLoadGetTime).." sec")
		self.lastLoadTime = now
		self.lastLoadGetTime = nowGet
	end
	
	-- Before loading metadata
	if  event == self.StartOnEvent  then
		if  event == 'ADDON_LOADED'  and  select(1, ...) ~= ADDON_NAME  then  return  end
		-- Load addon metadata asynchronously
		self:SetDelayNextLoad(4, 1)
		-- Is already registered to be loaded
		assert(self.addonsToLoad[1] == self.LoadConditions)
		self:Show()
		Debug("AddonLoader.StartOnEvent: "..event)
		--self:LoadConditions()
		
	elseif  event == 'PLAYER_REGEN_ENABLED'  and  0 < #self.addonsToLoad  then
		-- 2 sec on 60fps, 4 sec on 30fps, in framesDrawn
		self:SetDelayNextLoad(4*30, 1)
		-- Start OnUpdate()
		self:Show()
		Debug(event..": Start OnUpdate()")
	end
end




---------------------------------------------------------------------
-- Finally: Setup of startup events that will bootstrap the loader --
---------------------------------------------------------------------

-- Events of the addon initilization process saved for replay to delayed loadded addons
AddonLoader.cachedEvents = {}
AddonLoader.addonLoadEvents = {
	'ADDON_LOADED',
	--[[ ADDON_LOADED will be the first event received, right after saved variables has been loaded for the addon named in its event parameter.
	-- If your addon loads another addon then your dependency might load before and fire its own event, not the one you expect.
	--]]
	'SAVED_VARIABLES_TOO_LARGE',
	--[[ Almost never happens, nobody cares about it. The addon will load as if it was reset.
	Presumably this reset state will not be saved to preserve the previous poper state.
	--]]
	'VARIABLES_LOADED',
	--[[ Avoid using VARIABLES_LOADED. It can happen before or after PLAYER_LOGIN, you can't rely on its timing.
	-- Use it only if you are into saving and loading keybindings: since 3.0.2 (WotLK) it signals that keybindings and cvars have been loaded.
	-- For usual purposes you can do SetOverrideBinding() on your frame even before these are loaded.
	--]]
	'SPELLS_CHANGED',
	-- Spells of player has been loaded...
	'PLAYER_LOGIN',
	--[[ PLAYER_LOGIN is that favored event to initialize and start OnUpdate processing, causing a lagspike.
	-- The purpose is to delay initilization further, in the best case to implement proper lazy initialization, only loading addons when you start using them.
	--]]
	'PLAYER_ENTERING_WORLD',
}

--AddonLoader.StartOnEvent = 'ADDON_LOADED'
--AddonLoader.StartOnEvent = 'VARIABLES_LOADED'
--AddonLoader.StartOnEvent = 'PLAYER_LOGIN'
AddonLoader.StartOnEvent = 'PLAYER_ENTERING_WORLD'

if  IsLoggedIn()  then
	-- Well, the delayed loader has just been delay-loaded, hasn't it.
	-- The only event guaranteed to fire is ADDON_LOADED, so wait for that.
	AddonLoader.StartOnEvent = 'ADDON_LOADED'
end

-- Startup of AddonLoader is done by these delayed methods. Without it nothing will happen.
AddonLoader.addonsToLoad = { AddonLoader.LoadConditions, AddonLoader.InitConditions }
-- Load metadata the latest after 1 min on 60fps, 2 min on 30fps, in framesDrawn
AddonLoader:SetDelayNextLoad(1*60*60, 1)


-- The heartbeat of AddonLoader
AddonLoader:SetScript('OnEvent', AddonLoader.OnEvent)
AddonLoader:SetScript('OnUpdate', AddonLoader.OnUpdate)
AddonLoader:RegisterEvent(AddonLoader.StartOnEvent)
for  idx, eventName  in ipairs(AddonLoader.addonLoadEvents) do
	AddonLoader.addonLoadEvents[eventName] = idx
	AddonLoader:RegisterEvent(eventName)
end



--[[
https://wow.gamepedia.com/AddOn_loading_process
--
Order of events fired during loading
After the addon code has been loaded, the loading process can be followed by registering for various events, listed here in order of firing. This information is very important because many addons rely on information that is not available when addons first load, such as buffs, spells, talents, quests, pets, pvp information, etc. By monitoring one of the following events with a blank frame, you can trigger the appropriate "OnEvent" handler and execute code that is dependent on that information as soon as it is available.

ADDON_LOADED
This event fires whenever an addon has finished loading and the SavedVariables for that addon have been loaded from their file.
SAVED_VARIABLES_TOO_LARGE (Error Condition)
Generally will not fire. This event indicates an error state where the SavedVariables of an addon failed to load due to an out-of-memory error. (The old error state was a client crash!)
The upshot here is that your addon could be in a state where the saved variables did not load. This event's purpose is to indicate that you are in this error state.
If you are in this state your addon's SavedVariables will NOT be saved back to disk at the next logout. This was done with the reasoning that it will prevent valid data from accidentally being wiped by defaults.
It is possible for an addon's account wide SavedVariables to load, but for the character specific SavedVariables to fail, or vice versa. There is no way to detect the difference between no variables loaded and some.
SPELLS_CHANGED
This event fires shortly before the PLAYER_LOGIN event and signals that information on the user's spells has been loaded and is available to the UI.
PLAYER_LOGIN
This event fires immediately before PLAYER_ENTERING_WORLD.
Most information about the game world should now be available to the UI.
All sizing and positioning of frames is supposed to be completed before this event fires.
Addons that want to do one-time initialization procedures once the player has "entered the world" should use this event instead of PLAYER_ENTERING_WORLD.
PLAYER_ENTERING_WORLD
This event fires immediately after PLAYER_LOGIN
Most information about the game world should now be available to the UI. If this is an interface reload rather than a fresh log in, talent information should also be available.
All sizing and positioning of frames is supposed to be completed before this event fires.
This event also fires whenever the player enters/leaves an instance and generally whenever the player sees a loading screen
Since Patch 3.0.2, VARIABLES_LOADED has not been a reliable part of the addon loading process. It is now fired only in response to CVars, Keybindings and other associated "Blizzard" variables being loaded, and may therefore be delayed until after PLAYER_ENTERING_WORLD. The event may still be useful to override positioning data stored in layout-cache.txt.

Somewhere around Patch 5.4.0, PLAYER_ALIVE stopped being fired on login. It now only fires when a player is resurrected (before releasing spirit) or when a player releases spirit. Previously, PLAYER_ALIVE was used to by addons to signal that quest and talent information were available because it was the last event to fire (fired after PLAYER_ENTERING_WORLD), but this is no longer accurate.

Load On Demand behavior
Load on Demand addons cannot rely on most of the event sequence being fired for them; only ADDON_LOADED is a reliable indication that the saved variables for your LoD addon have been loaded.
--]]
