--[[ Purpose of AddonLoader: save memory and fps before raiding, speed up load times when switching characters (too many bank alts?).
-- For ex. don't load accounting/auctioning until you go to the auction house.
-- If you just go raiding you get better fps without those addons running in the background.
-- If you did some trading, crafting, petbattling then reload your ui before raiding
-- to unload the unneccessary addons, save memory and disable their background processing.
-- On the other hand when jumping between bank alts you can save the time taken by loading the raid addons.
--
--   Public API to use:
-- AddonLoader.QueueLoadAddOn(addonName, loadCondition)
-- AddonLoader.LoadAddOn(addonName, loadCondition)
-- AddonLoader:LoadAddOn(addonName, loadCondition)
--]]

local ADDON_NAME, private = ...
local safecall = private.safecall
local _G, tostringall, tostring, string, strjoin, pairs, ipairs, select, next, date, time, GetTime, InCombatLockdown = 
      _G, tostringall, tostring, string, strjoin, pairs, ipairs, select, next, date, time, GetTime, InCombatLockdown
local EMPTY = {}  -- constant empty object to use in place of nil table reference

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: GetAddOnInfo GetAddOnMetadata IsAddOnLoaded IsAddOnLoadOnDemand GetNumAddOns LoadAddOn
-- GLOBALS: AddonLoaderSV


local AddonLoader = CreateFrame('Frame', 'AddonLoader')
--AddonLoader:Hide()
_G.AddonLoader = AddonLoader


-- Debug(...) messages
function private.tostrjoin(separator, ...)  return strjoin(separator, tostringall(...))  end
local tostrjoin = private.tostrjoin
function private.Debug(...)  if  AddonLoader.logFrame  then  AddonLoader.logFrame:AddMessage( tostrjoin(", ", ...) )  end end
local Debug = private.Debug

AddonLoader.logFrame = tekDebug  and  tekDebug:GetFrame("AddonLoader")  or  ChatFrame4
if  not tekDebug  then  ChatFrame4:Show()  end


AddonLoader.loadReason = {}
AddonLoader.loadError = {}

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





--------------------------------------
-- Addon loading and initialization --
--------------------------------------

-- The public API: substitute for builtin LoadAddOn(addonName).
-- The builtin LoadAddOn can be hooked and replaced.
-- Can be called either as a function or as a method:
-- AddonLoader.LoadAddOn(addonName, loadCondition)
-- AddonLoader:LoadAddOn(addonName, loadCondition)
function AddonLoader:LoadAddOn(addonName, loadCondition)
  -- Check if this is a function call like AddonLoader.LoadAddOn(addonName, loadCondition)
	if  type(self) == 'table'  and  self.LoadAndInitialize  then
		-- Owns the method that will be called next, therefore it qualifies as AddonLoader.
	else
		-- Function call, shifting parameters to make place for self = AddonLoader
		self, addonName, loadCondition, _nil  =  AddonLoader, self, addonName, loadCondition
	end
	assert( type(addonName) == 'string', "Usage: AddonLoader.LoadAddOn(addonName, loadCondition), expects string addonName, received "..type(addonName) )
	-- Use safecall to protect callers from any error that might occur while hacking the addon initialization.
	--safecall( function() self:LoadAndInitialize(addonName, loadCondition) end )
	-- Alternative:
	local ran, loaded, result = safecall(self.LoadAndInitialize, self, addonName, loadCondition)
	if  ran  then  return  loaded, result  end
	
	print( "AddonLoader.LoadAndInitialize("..tostring(addonName)..") failed, reverting to original LoadAddOn. Error:  "..tostring(loaded) )
	return AddonLoader.origLoadAddOn(addonName)
end

--[[
function AddonLoader.LoadAddOn(addonName, loadCondition, _shift)
	local self = AddonLoader
  -- Check if this is a method call like AddonLoader:LoadAddOn(addonName, loadCondition)
	if  type(addonName) == 'table'  and  addonName.LoadAndInitialize  then
		-- Owns the method that will be called next, therefore it qualifies as self. Also shift the other parameters one left.
		self, addonName, loadCondition  =  addonName, loadCondition, _shift
	else
		assert( type(addonName) == 'string', "Usage: AddonLoader.LoadAddOn(addonName, loadCondition), expects string addonName, received "..type(addonName) )
	end
	-- Use safecall to protect callers from any error that might occur while hacking the addon initialization.
	--safecall( function() self:LoadAndInitialize(addonName, loadCondition) end )
	-- Alternative:
	local ran, result = safecall(self.LoadAndInitialize, self, addonName, loadCondition)
	if  not ran  then  print( "AddonLoader.LoadAddOn("..tostring(addonName)..") error:  "..tostring(result) )  end
	return  ran  and  result
end
--]]

AddonLoader.origLoadAddOn = LoadAddOn
-- Hook LoadAddOn() globally. I wonder if UIParent will survive.
--_G.LoadAddOn = AddonLoader.LoadAddOn




function AddonLoader:BeforeLoadAddOn(addonName, loadCondition)
	-- If there are Slashes registered for the the addon, remove them
	local Slashes = self.Slashes[addonName]
	if  Slashes  then
		local SlashCmdList, hash_SlashCmdList, hash_ChatTypeInfoList = _G.SlashCmdList, _G.hash_SlashCmdList, _G.hash_ChatTypeInfoList
		for  commandLong, slash  in pairs(Slashes) do
			if  not _G['SLASH_'..commandLong..'1']  then  print("BeforeLoadAddOn(): SLASH_"..commandLong.."1 == nil, missing slash command")  end
			if  not SlashCmdList[commandLong]  then  print("BeforeLoadAddOn(): SlashCmdList["..commandLong.."] == nil, missing slash command")  end
			_G['SLASH_'..commandLong..'1'] = nil	-- command -> slash(es)
			SlashCmdList[commandLong] = nil		-- command -> function map
			hash_SlashCmdList[slash] = nil				-- slash -> function map
			hash_ChatTypeInfoList[slash] = nil		-- slash -> function map
		end
		self.Slashes[addonName] = nil   -- and nil out our list. saves resources and prevents us NILling again if someone calls this function on a loaded addon.
	end

	Debug(addonName.." is loading.")
	if not AddonLoaderSV.silent then
		--self:Print("Loading " .. addonName)
		self:Toast(addonName.." is loading...", textColors.notify)
	end
end


function AddonLoader:LoadAndInitialize(addonName, loadCondition)
	if  IsAddOnLoaded(addonName)  then  return true, "Already loaded"  end

	-- Verify that the addon isn't disabled
	local exactName, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonName)
	--[[ https://wow.gamepedia.com/API_GetAddOnInfo
	--  Patch 6.0.2 (2014-10-14): Removed 'enabled' return. 'loadable' return was changed from a flag to a boolean. Added 'newVersion' return. The enabled state of an addon can now be queried with GetAddOnEnableState. 
	--local exactName, title, notes, loadable, reason, security = GetAddOnInfo(addonName)
	--]]
	if  not enabled  or  not exactName  then  return false, (reason  and  _G['ADDON_'..reason]   or  reason  or  "Addon disabled")  end

	-- Make sure addonName has the proper original casing. Table indexes must be exact.
	addonName = exactName

	--if  self.loadError[addonName]  then  return false, "Failed loading before"  end
	if  self.loadReason[addonName]  then  return false, "Tried to load before"  end
	self.loadReason[addonName] =  loadCondition  or  "notset"

	-- Before load cleanup is not as important as loading the addon. Ignore if it fails, Buggrabber's errorhandler will catch the error.
	local this = self  -- need to save in closure
	local ran, result = safecall(function() this:BeforeLoadAddOn(addonName) end)

	-- AddonCapture is loaded after AddonLoader. If the hooked _G.LoadAddOn() is called in the meantime, capturing is not possible.
	local AddonCapture = private.AddonCapture
	-- Initialize capturing frames, event handlers and hooks interested in receiveing the events occuring during a normal addon load
	local capture = AddonCapture  and  AddonCapture:StartCapture()

	-- Load the addon
	local status, err = AddonLoader.origLoadAddOn(addonName)
	
	-- Collect captured frames
	local captureOk =  capture  and  capture:StopCapture()
	
	if  not status  then
		self.loadError[addonName]  = err
		self:Print(addonName.."  addon load error: "..err)
		self:Toast(addonName.."  addon failed to load", textColors.error)
		return status, err
	elseif  not IsAddOnLoaded(addonName)  then
		self.loadError[addonName]  = "No error, but not loaded"
	end
	
	if  capture  then
		-- Replay the standard events of addon loading
		local eventsOk, eventsErr =  capture:SendAddOnLoadEvents()
		if  not eventsOk  then
			self:Print(addonName.."  addon initialization error: "..eventsErr)
			self:Toast(addonName.."  addon failed to initialize properly", textColors.error)
			-- Report the error, but return the loading succeeded.
		end
	end
	
	-- After load callback function loaded from metadata
	local afterLoadFunc =  loadCondition  and  loadCondition.afterLoadFunc
	if  loaded  and  afterLoadFunc  then
		local ran, result = safecall(afterLoadFunc)
		if  not ran  then  print()  end
	end
	
	return status, err
end




-------------------------
-- Delaying addon load --
-------------------------

function AddonLoader.QueueLoadAddOn(addonName, loadCondition)
	local self = AddonLoader
	--if  type(addonName) == 'table'  then  addonName, loadCondition = addonName.addonName, addonName  end
	
	loadCondition =  loadCondition  or  { addonName = addonName }
	if  loadCondition.loadTiming == 'Synchronous'  then
		-- Addons flagged for Synchronous loading are not queued
		return self:LoadAddOn(addonName, loadCondition)
	end
	
	if  loadCondition.loadTiming == 'Instant'  then
		table.insert(self.addonsToLoad, 1, loadCondition)
	else
		table.insert(self.addonsToLoad, loadCondition)
	end
	
	self.addonDeps[addonName] = AddonLoader.GetDepAddonsToLoad(addon, self.addonDeps)
	self:Show()
	return true
end


function AddonLoader:SetNextLoadDelay(framesDelay, framesToSkip)
	AddonLoader.delayNextLoad = framesDelay
	AddonLoader.framesDrawn = -(framesToSkip or 1)
	AddonLoader.elapsedSum = 0
end



local function addDependencies(myDeps, visited, addonList)
	for  _, addonName  in ipairs(addonList) do
		if  IsAddOnLoaded(addonName)  then
			-- Skipping loaded addons
		elseif  myDeps[addonName]  then
			-- Addon already in list, not repeating
		else
			local addonDeps = AddonLoader.GetDepAddonsToLoad(addonName, visited)
			-- Save the dependencies of this addon
			visited[addonName] = addonDeps
			
			if  type(addonDeps) == 'table'  then
				for  _, addonDep  in ipairs(addonDeps) do
					if  not myDeps[addonDep]  then
						myDeps[#myDeps+1] = addonDep
						myDeps[addonDep] = visited[addonDep]  or  true
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
function AddonLoader.GetDepAddonsToLoad(addonName, visited)
	visited = visited or {}
	if  visited[addonName]  then  return visited[addonName], visited  end
	-- Do not recurse into this addon if the dependency links are circular
	visited[addonName] = 'visiting'
	
	-- Recurse into dependencies first:  depth-first search of the dependency tree
	local myDeps = {}
	myDeps[addonName] = 'self'
	-- Dual recursion: call addDependencies(depAddon) -> call GetDepAddonsToLoad(depAddon)
	addDependencies(myDeps, visited, {GetAddOnDependencies(depAddon)} )
	addDependencies(myDeps, visited, {GetAddOnOptionalDependencies(depAddon)} )
	
	-- Include the addon itself last in the list
	myDeps[#myDeps+1] = addonName
	--myDeps[addonName] = 'self'
	
	print("GetDepAddonsToLoad("..addonName.."):  { "..strjoin(", ", myDeps).." }")
	return myDeps, visited
end





---------------------
-- Delayed loading --
---------------------

-- Load one addon, or one dependency of it, one at a time.
-- Returns name of addon loaded. Nil, if nothing to load.
-- Should any error occur it will take down the current OnUpdate() call only.
-- Next time it will continue with the next addon, skipping the one that failed.
function AddonLoader:LoadOneAddon()
	local addonsToLoad, addonDeps =  self.addonsToLoad, self.addonDeps
	local toload = addonsToLoad[1]
	-- Empty list?
	if  toload == nil  then  return nil  end
	
	-- Function can be queued too, ex. ConditionManager.StartHandlers() for initialization
	if  type(toload) == 'function'  then
		-- Remove first. If it errs it will be skipped next time.
		table.remove(addonsToLoad, 1)
		-- Run function
		toload(self)
		return toload
	end
	
	if  type(toload) ~= 'string'  then
		print("LoadOneAddon():  addon name "..tostring(toload).." must be a string")
		table.remove(addonsToLoad, 1)
		return nil
	end
	
	if  not addonDeps[toload]  then  print("LoadOneAddon():  addonDeps["..tostring(toload).."] == nil")  end
	local deps, loadIdx = addonDeps[toload]  or  EMPTY
	for  i = 1, #deps  do
		if  not IsAddOnLoaded(deps[i])  then  loadIdx, toload = i, deps[i] ; break  end
	end
	
	if  IsAddOnLoaded(toload)  then
		Debug("LoadOneAddon():  "..toload.." was loaded since the last OnUpdate()")
		table.remove(addonsToLoad, 1)
	else
		if  addonName == toload  then
			-- All dependencies loaded, loading top-level addon: remove from addonsToLoad list.
			table.remove(addonsToLoad, 1)
		else
			-- Remove loadIdx elements -> move loadIdx+i to i, nil the rest.
			local remaining = #deps - loadIdx
			for  i = 1, remaining  do  deps[i] = deps[loadIdx+i] ; deps[loadIdx+i] = nil  end
			for  i = loadIdx, remaining+1, -1  do  deps[i] = nil  end
		end
		-- Load it
		self:LoadAddOn(addonName)
	end
	return addonName
end



----------------------------------
-- The heartbeat of AddonLoader --
----------------------------------

-- Delayed loading, 10 frames drawn between two addons loaded
function AddonLoader:OnUpdate(elapsed)
	self.framesDrawn = (self.framesDrawn or -1) + 1
	if  0 < self.framesDrawn  then
		self.elapsedSum = (self.elapsedSum or 0) + elapsed
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
	local msg = self.framesDrawn.." frames: "..("%.3f"):format(self.elapsedSum).."sec "..("%.2f"):format(fps).."fps "..("%.4f"):format(spf).."s/f"
	Debug( "AddonLoader:OnUpdate(elapsed="..("%.3f"):format(elapsed).."): GetTime() difference="..(now-self.lastUpdateGetTime)..", "..msg )
	self.lastUpdateGetTime = now
	-- Next addon after 0.15 sec on 60fps, 0.3 sec on 30fps, in framesDrawn. First frame is delayed arbitrarily by the addon loading, therefore skipped.
	--self:SetNextLoadDelay(9, 5)
	self:SetNextLoadDelay(30, 5)   -- slow for testing
	
	local loaded = self:LoadOneAddon(self.addonsToLoad)
	now = GetTime()
	Debug( "Delayed loaded "..tostring(loaded)..":  GetTime() difference="..(now-self.lastUpdateGetTime) )
	self.lastUpdateGetTime = now
	
	if  0 == #self.addonsToLoad  then
		self:Hide()
	end
end

AddonLoader.addonsToLoad = {}
AddonLoader.lastUpdateTime = time()
AddonLoader.lastUpdateGetTime = GetTime()
AddonLoader.lastLoadTime = time()
AddonLoader.lastLoadGetTime = GetTime()




-----------------------------
-- The ears of AddonLoader --
-----------------------------

-- Monitoring addon load events, delaying StartHandlers (scanning metadata)
function AddonLoader:OnEvent(...)
	local eventName, addonName = ...
	Debug("AddonLoader:OnEvent(".. tostrjoin(", ", ...) ..")")
	
	if  eventName == 'ADDON_LOADED'  then
		local addonLoadEvent = { addonName = addonName, timeStamp = date("%H:%M:%S"), time = time(), GetTime = GetTime(), select(3, ...) }
		self:AddAddonLoaded(addonLoadEvent)
		
		local now, nowGet = time(), GetTime()
		Debug("ADDON_LOADED("..addonName.."):  time since last="..(now - self.lastLoadTime).." sec, GetTime() elapsed="..(nowGet - self.lastLoadGetTime).." sec")
		self.lastLoadTime = now
		self.lastLoadGetTime = nowGet
		
		-- That's all to do for other addons. Only continue if THIS_ADDON_LOADED.
		if  addonName ~= ADDON_NAME  then  return  end
		
		self:THIS_ADDON_LOADED()
	end
	
	if  self.addonLoadEvents[eventName]  then
		-- Last event overwrites previous event (only PLAYER_ENTERING_WORLD is fired multiple times).
		local cachedEvent = self.cachedEvents[eventName]
		if  cachedEvent  then  tDeleteItem(self.cachedEvents, cachedEvent)  end
		
		-- Save event parameters for replay, although these events are not supposed to have parameters.
		self:AddCachedEvent(...)
		Debug("Cached "..eventName.."(".. tostrjoin(', ', select(2, ...)) ..")")
	end
	
	-- If the delayed loader has been delay-loaded, then this is the only event guaranteed to fire, so schedule initialization.
	local delayLoaded =  eventName == 'ADDON_LOADED'  and  IsLoggedIn()
	self.delayLoaded = delayLoaded
	
	-- Loading conditions from metadata and SavedVariables
	if  eventName == self.InitOnEvent  or  delayLoaded  then
		Debug("AddonLoader:  Load metadata after event "..eventName)
		-- Schedule LoadConfiguration()
		self:ScheduleInitFunc(self.InitOnEvent, self.ConditionManager.LoadConfiguration)
		self.InitOnEvent = nil
	end
	
	-- Running Startup and Login handlers
	if  eventName == self.StartOnEvent  or  delayLoaded  then
		Debug("AddonLoader:  Start Login handlers after event "..eventName)
		-- Schedule RunStartupHandlers(), RunHandlersForCachedEvents()
		self:ScheduleInitFunc(self.StartOnEvent, self.ConditionManager.RunStartupHandlers)
		self:ScheduleInitFunc(self.StartOnEvent, self.ConditionManager.RunHandlersForCachedEvents)
		self.StartOnEvent = nil
	end
	
	-- Restart scheduled loading if player was in combat.
	if  eventName == 'PLAYER_REGEN_ENABLED'  and  0 < #self.addonsToLoad  then
		-- 2 sec on 60fps, 4 sec on 30fps, in framesDrawn
		self:SetNextLoadDelay(4*30, 1)
		-- Start OnUpdate()
		self:Show()
		Debug(eventName..": Start OnUpdate()")
	end
end


function AddonLoader:ScheduleInitFunc(eventName, scheduledFunc)
	if  eventName == 'PLAYER_ENTERING_WORLD'  then
		-- Delay loading addon metadata until after the loading screen to make it faster.
		self:SetNextLoadDelay(10, 1)
		table.insert(self.addonsToLoad, scheduledFunc)
		-- Get OnUpdate events
		self:Show()
	else
		-- Load addon metadata synchronously if some addon needs to be processed early.
		scheduledFunc()
	end
end


-- SavedVariables loaded. Decide when to do StartHandlers() initialization.
function AddonLoader:THIS_ADDON_LOADED()
	--self.InitOnEvent  = 'ADDON_LOADED'
	--self.InitOnEvent  = 'PLAYER_LOGIN'
	-- PLAYER_ENTERING_WORLD means to schedule after the loading screen vanished and the player gained control.
	self.InitOnEvent  = 'PLAYER_ENTERING_WORLD'
	--self.StartOnEvent = 'VARIABLES_LOADED'
	--self.StartOnEvent = 'SPELLS_CHANGED'
	--self.StartOnEvent = 'PLAYER_LOGIN'
	self.StartOnEvent = 'PLAYER_ENTERING_WORLD'
	
	-- Trigger events can be set by user.
	if  AddonLoaderSV  then
		if  AddonLoaderSV.InitOnEvent   then  self.InitOnEvent  = AddonLoaderSV.InitOnEvent   end
		if  AddonLoaderSV.StartOnEvent  then  self.StartOnEvent = AddonLoaderSV.StartOnEvent  end
	end
	
	-- Its already registered if one of the addonLoadEvents
	AddonLoader:RegisterEvent(self.InitOnEvent )
	AddonLoader:RegisterEvent(self.StartOnEvent)
end




-----------------------------
-- What happened until now --
-----------------------------

-- Check if the ADDON_LOADED event was properly received for loaded addon.
function AddonLoader:CheckAddOnLoaded(addonName)
	local isLoaded = IsAddOnLoaded(addonName)
	local loadedEvt = self.addonsLoaded[addonName]
	if  not isLoaded == not loadedEvt  then  return isLoaded  end
	
	Debug("EvaluateCondition("..addonName.."):  IsAddOnLoaded()="..tostring(isLoaded)
	.." addonsLoaded[] time: "..(not loadedEvt and "nil" or (loadedEvt.timeStamp.." "..loadedEvt.GetTime)) )
	return isLoaded
end


function AddonLoader:AddAddonLoaded(addonLoadEvent)
	self.addonsLoaded[addonLoadEvent.addonName] = addonLoadEvent
	self.addonsLoaded[#self.addonsLoaded+1] = addonLoadEvent
	addonLoadEvent.idx = #self.addonsLoaded
end


-- ADDON_LOADED events are captured after AddonLoader is loaded.
AddonLoader.addonsLoaded = {}

-- Missed a few debug addons (BugGrabber, Swatter, tekDebug, nLog) loaded before.
-- Create mock events for those missed.
for  i = 1, GetNumAddOns()  do
	if  IsAddOnLoaded(i)  then
		local addonName, _, _, enabled = GetAddOnInfo(i)
		local addonLoadEvent = { addonName = addonName, timeStamp = "before "..date("%H:%M:%S"), time = time(), GetTime = GetTime(), source = "Mock event created after-the-fact" }
		AddonLoader:AddAddonLoaded(addonLoadEvent)
	end
end




function AddonLoader:IsVariablesLoaded()  return self.cachedEvents.VARIABLES_LOADED       end
function AddonLoader:IsLoggedIn()         return self.cachedEvents.PLAYER_LOGIN           end
function AddonLoader:IsPlayerInWorld()    return self.cachedEvents.PLAYER_ENTERING_WORLD  end
function AddonLoader:IsSpellsLoaded()     return self.cachedEvents.SPELLS_CHANGED         end
AddonLoader.cachedEvents = {}

function AddonLoader:ReplayCachedEvents(recipient)
	local cachedEvents = self.cachedEvents
	local replayedEvents = {}
	self.replayedEvents = replayedEvents
	
	-- Replay in order as received
	for  i, cachedEvent  in ipairs(cachedEvents) do
		local eventName = cachedEvent[1]
		replayedEvents[#replayedEvents+1] = cachedEvent
		replayedEvents[eventName] = cachedEvent
		recipient:FireEvent( unpack(cachedEvent) )
	end
	
	-- Mock the most important events if we missed them
	if  IsLoggedIn()  and  not cachedEvents.VARIABLES_LOADED  then  recipient:FireEvent('VARIABLES_LOADED')  end
	if  IsLoggedIn()  and  not cachedEvents.PLAYER_LOGIN  then  recipient:FireEvent('PLAYER_LOGIN')  end
	if  IsPlayerInWorld()  and  not cachedEvents.PLAYER_ENTERING_WORLD  then  recipient:FireEvent('PLAYER_ENTERING_WORLD')  end
	-- Can't know if SPELLS_CHANGED was fired if  AddonLoader.delayLoaded:  this might be after PLAYER_ENTERING_WORLD but before SPELLS_CHANGED
	-- Coolline addon expects this event, others like Quartz initialize spells even without it.
	-- Possible to mock it if necessary.
end


function AddonLoader:AddCachedEvent(...)
	local eventName = ...
	local cachedEvent = { timeStamp = date("%H:%M:%S"), time = time(), GetTime = GetTime(), ... }
	self.cachedEvents[#self.cachedEvents+1] = cachedEvent
	self.cachedEvents[eventName] = cachedEvent
end




----------------------------
-- The events that matter --
----------------------------

-- Events of the addon initilization process saved for replay to addons loaded later
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
	'PLAYER_LOGIN',
	--[[ PLAYER_LOGIN is the favored event to initialize and start OnUpdate processing, causing a lagspike.
	-- The purpose is to delay initilization further, in the best case to implement proper lazy initialization, only loading addons when you start using them.
	--]]
	'PLAYER_ENTERING_WORLD',
	'SPELLS_CHANGED',
	-- Spells of player has been loaded...
}


-- Registering addon load events and handlers
AddonLoader:SetScript('OnEvent', AddonLoader.OnEvent)
AddonLoader:SetScript('OnUpdate', AddonLoader.OnUpdate)
AddonLoader:Show()
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
VARIABLES_LOADED has not been a reliable part of the addon loading process since Patch 3.0.2. It is now fired only in response to CVars, Keybindings and other associated "Blizzard" variables being loaded, and may therefore be delayed until after PLAYER_ENTERING_WORLD. The event may still be useful to override positioning data stored in layout-cache.txt.
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

Somewhere around Patch 5.4.0, PLAYER_ALIVE stopped being fired on login. It now only fires when a player is resurrected (before releasing spirit) or when a player releases spirit. Previously, PLAYER_ALIVE was used to by addons to signal that quest and talent information were available because it was the last event to fire (fired after PLAYER_ENTERING_WORLD), but this is no longer accurate.

Load On Demand behavior
Load on Demand addons cannot rely on most of the event sequence being fired for them; only ADDON_LOADED is a reliable indication that the saved variables for your LoD addon have been loaded.
--]]
