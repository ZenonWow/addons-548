--[[
/run EventTracker.PrintLog()
--]]

PlaySound([[Interface\Addons\TellMeWhen\Sounds\Ding3.ogg]])

local  EventTracker = CreateFrame('Frame', 'EventTracker', UIParent)
EventTracker:RegisterEvent('ADDON_LOADED')
EventTracker:RegisterEvent('SAVED_VARIABLES_TOO_LARGE')
EventTracker:RegisterEvent('VARIABLES_LOADED')
EventTracker:RegisterEvent('PLAYER_LOGIN')
EventTracker:RegisterEvent('PLAYER_ENTERING_WORLD')
EventTracker:RegisterEvent('PLAYER_LEAVING_WORLD')
EventTracker:RegisterEvent('SPELLS_CHANGED')
EventTracker:RegisterEvent('PLAYER_ALIVE')
--EventTracker:RegisterEvent('PLAYER_LOGOUT')

-- First timestamp when starting to load
EventTracker.LogMsgs = {}
--EventTracker.LogFrame = nil
EventTracker.LastLoadEventMs = debugprofilestop()
EventTracker.LastLoggedIn = false

local LogMsgs = EventTracker.LogMsgs
local LogFrame = nil

local function log(msg)
	local nowMs = debugprofilestop()
	msg = "["..date("%H:%M:%S").." ("..nowMs.." ms)] ".. msg
	if  LogMsgs  then  table.insert(LogMsgs, msg)  end
	if  LogFrame  then  LogFrame:AddMessage(msg)  end
end

function EventTracker.PrintLog(frame)
	if  not LogMsgs  then  return false  end
	frame =  frame  or  DEFAULT_CHAT_FRAME
	for  i, msg  in ipairs(LogMsgs) do  frame:AddMessage(msg)  end
	return true
end


local addCount = 0
function EventTracker:ADDON_LOADED(event, addonName)
	addCount = addCount + 1
	if  addCount >= 10  then  
		addCount = 0
		PlaySound([[Interface\Addons\TellMeWhen\Sounds\Ding4.ogg]])
	end
end

function EventTracker:VARIABLES_LOADED()
	PlaySound([[Interface\Addons\TellMeWhen\Sounds\Ding5.ogg]])
end

function EventTracker:PLAYER_LOGIN()
	PlaySound([[Interface\Addons\TellMeWhen\Sounds\Ding6.ogg]])
end

function EventTracker:PLAYER_ENTERING_WORLD()
	PlaySound([[Interface\Addons\TellMeWhen\Sounds\Ding7.ogg]])
	LogFrame = tekDebug  and  tekDebug:GetFrame("EventTracker")
	if  LogFrame  then
		self.LogFrame = LogFrame
		self.PrintLog(LogFrame)
		LogMsgs = nil
		self.LogMsgs = LogMsgs
	end
end


function EventTracker:CheckLoggedIn()
	local loggedIn = IsLoggedIn()
	if  self.LastLoggedIn ~= loggedIn  then
		log("EventTracker:CheckLoggedIn(): "..tostring(self.LastLoggedIn).." -> "..tostring(loggedIn))
		self.LastLoggedIn = loggedIn
	end
end


local tostringall = tostringall

function EventTracker:OnEvent(event, ...)
	local nowMs = debugprofilestop()
	local params = string.join(', ', tostringall(...))
	log(event.."("..params.."): elapsed: ".. (nowMs - self.LastLoadEventMs) .." ms")
	self.LastLoadEventMs = nowMs
	
	if  self[event]  then  self[event](self, event, ...)  end
end


EventTracker:CheckLoggedIn()
EventTracker:SetScript('OnEvent', EventTracker.OnEvent)
EventTracker:Show()


-- Order test
EventTracker:OnEvent("before LoadAddOn", "Blizzard_BindingUI")
LoadAddOn('Blizzard_BindingUI')
EventTracker:OnEvent("after LoadAddOn", "Blizzard_BindingUI")



