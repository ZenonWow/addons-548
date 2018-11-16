--[[
	BagSync.lua
		A item tracking addon similar to Bagnon_Forever (special thanks to Tuller).
		Works with practically any Bag mod available, Bagnon not required.

	NOTE: Parts of this mod were inspired by code from Bagnon_Forever by Tuller.
	
	This project was originally done a long time ago when I used the default blizzard bags.  I wanted something like what
	was available in Bagnon for tracking items, but I didn't want to use Bagnon.  So I decided to code one that works with
	pretty much any inventory addon.
	
	It was intended to be a beta addon as I never really uploaded it to a interface website.  Instead I used the
	SVN of wowace to work on it.  The last revision done on the old BagSync was r50203.11 (29 Sep 2007).
	Note: This addon has been completely rewritten. 

	Author: Xruptor

--]]

--[[ To enable debug logging:
/run BagSync.Debug(true)
--]]


-- Addon private namespace
local ADDON_NAME, ns = ...

-- Frames to draw before starting background scanning
local SCHEDULE_DELAY_TICKS = 60


-- Event handler frame
local BagSync = CreateFrame("Frame", "BagSync", UIParent)
_G.BagSync = BagSync
--_G[ADDON_NAME] = BagSync



-- Debug(...) messages
function ns.Debug(...)  if  BagSync.logFrame  then  BagSync.logFrame:AddMessage( string.join(", ", tostringall(...)) )  end end
BagSync.logFrame = tekDebug  and  tekDebug:GetFrame("BagSync")
function BagSync.Debug(enable)  BagSync.logFrame =  enable  and  (tekDebug  and  tekDebug:GetFrame("BagSync")  or  DEFAULT_CHAT_FRAME)  end
local Debug =  ns.Debug

local LogMsgs = {}
local function log(msg) LogMsgs[#LogMsgs+1] = msg  end
function BsPrintLog()  for  i, msg  in ipairs(LogMsgs) do  _G.print(msg)  end  end
--[[
/run BsPrintLog()
--]]



-- Event routing to methods named like the event
BagSync:SetScript('OnEvent', function(self, event, p1, ...)
	--log("[".. date('%H:%M:%S') .."] "..tostring(event).."("..tostring(p1)..")")
	if  self[event]  then  self[event](self, event, p1, ...)  end
end)


-- Bulk event registration
function BagSync:SetRegisterEvents(enable, list)
	local RegOrUnregEvent = enable  and  self.RegisterEvent  or  self.UnregisterEvent
	for  i, event  in ipairs(list) do
		RegOrUnregEvent(self, event)
	end
end



------------------------------
--    LOGIN HANDLER         --
------------------------------

--[[
https://wow.gamepedia.com/AddOn_loading_process
--
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
VARIABLES_LOADED
Since Patch 3.0.2, VARIABLES_LOADED has not been a reliable part of the addon loading process. It is now fired only in response to CVars, Keybindings and other associated "Blizzard" variables being loaded, and may therefore be delayed until after PLAYER_ENTERING_WORLD. The event may still be useful to override positioning data stored in layout-cache.txt.
PLAYER_ALIVE
Somewhere around Patch 5.4.0, PLAYER_ALIVE stopped being fired on login. It now only fires when a player is resurrected (before releasing spirit) or when a player releases spirit. Previously, PLAYER_ALIVE was used to by addons to signal that quest and talent information were available because it was the last event to fire (fired after PLAYER_ENTERING_WORLD), but this is no longer accurate.
--]]

BagSync:RegisterEvent('ADDON_LOADED')    -- SavedVariables loaded
BagSync:RegisterEvent('PLAYER_ENTERING_WORLD')    -- After PLAYER_LOGIN
Debug("[".. date('%H:%M:%S') .."] BagSync:RegisterEvent('ADDON_LOADED')")


-- ADDON_LOADED event sent for all addons after their SavedVariables has been loaded
function BagSync:ADDON_LOADED(event, addonName)
	if  addonName == ADDON_NAME  then
		Debug("[".. date('%H:%M:%S') .."] BagSync:ADDON_LOADED("..addonName..")")
		-- SavedVariables loaded: check and reference it
		ns.InitSavedDB()
		self:SetRegisterEvents(true, ns.EventsToScan)
		self:UnregisterEvent('ADDON_LOADED')
		self.ADDON_LOADED = nil
		if  IsLoggedIn()  and  self.PLAYER_ENTERING_WORLD  then
			-- This is not happening in normal addon loading. IsLoggedIn() becomes true after all addons and SavedVariables are loaded.
			-- Maybe can happen in delayed loading. In that case PLAYER_LOGIN and PLAYER_ENTERING_WORLD events were already fired earlier.
			-- Call our event handler to make up for the missed event.
			self:PLAYER_ENTERING_WORLD()
		end
	end
end


--[[
Waiting for PLAYER_ENTERING_WORLD event sent _after_ PLAYER_LOGIN to delay initial scan.
Hopefully the loading screen is over by now and the player gains control earlier by delaying the scan.
This event might be called multiple times.
--function BagSync:PLAYER_LOGIN()
--]]
function BagSync:PLAYER_ENTERING_WORLD()
	Debug("[".. date('%H:%M:%S') .."] BagSync:PLAYER_ENTERING_WORLD()")
	
	-- If we missed the ADDON_LOADED event then do it now
	if  self.ADDON_LOADED  then  ns.InitSavedDB()  end

	-- Update player info after login
	playerName = UnitName('player')
	playerRealm = GetRealmName()
	playerClass = select(2, UnitClass('player'))
	playerFaction = UnitFactionGroup('player')
	
	-- Register OnUpdate script to delay the initial scan with a fixed number of frames drawn.
	-- With 30fps this should delay scan with 5 seconds. On a fast system with 60fps this will be 2.5 seconds.
	--local setDelay = not self.scheduleDelay
	self:Schedule( self.AfterLoginScan )
	self.scheduleDelay = 150
	
	-- Unregister event and release memory
	self:UnregisterEvent('PLAYER_ENTERING_WORLD')
	self.PLAYER_ENTERING_WORLD = nil
end



function BagSync:OnUpdate(elapsed)
	if  self.scheduleDelay  then
		self.scheduleDelay = self.scheduleDelay - 1
		if  0 < self.scheduleDelay  then  return  end
		
		self.scheduleDelay = SCHEDULE_DELAY_TICKS
		local method = self.scheduled[#self.scheduled]
		self.scheduled[#self.scheduled] = nil
		
		local callAgain = method  and  method(self)
		if  callAgain  then  table.insert(self.scheduled, method)  end
		
		if  0 == #self.scheduled  then  self.scheduleDelay = nil  end
	end
		
	if  not self.scheduleDelay  then
		self:SetScript('OnUpdate', nil)
	end
end




local function  tremovebyval(tab, item)
	for  i,v  in  ipairs(tab)  do
		if  v == item  then  table.remove(tab, i)  return v  end
	end
	return nil
end


function BagSync:Schedule(method)
	self.scheduled = self.scheduled or {}
	if  not self.scheduleDelay  then
		self:SetScript('OnUpdate', self.OnUpdate)
		self.scheduleDelay = SCHEDULE_DELAY_TICKS
	else
		if  self.scheduleDelay < SCHEDULE_DELAY_TICKS  then  self.scheduleDelay = SCHEDULE_DELAY_TICKS  end
	end
	
	local wasScheduled = tremovebyval(self.scheduled, method)
	table.insert(self.scheduled, method)
end



