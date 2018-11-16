--[[
	capture_CreateFrame()
	capture_RegisterEvent(eventName)
	-- Replay VARIABLES_LOADED, PLAYER_LOGIN, PLAYER_ENTERING_WORLD
	-- + replay <eventName>
	trigger_OnEvent(eventName)

	capture_hooksecurefunc(funcName)
	AddonLoader:LoadAddOn(addonName)
	trigger_hooksecurefunc(funcName)
--]]

local ADDON_NAME, private = ...
local AddonLoader = AddonLoader
local AddonCapture = {}
local Debug = private.Debug



local function arrayToMap(arr)
	local map = {}
	for  i, frame  in ipairs(arr) do  arr[frame] = frame  end
	return map
end

function AddonCapture:SaveEventHandlers(eventName)
	self.framesBefore[eventName] = arrayToMap({ GetFramesRegisteredForEvent(eventName) })
end

function AddonCapture:New()
	return setmetatable({}, { __index = self })
end

function AddonCapture:StartCapture()
	self.framesBefore = {}
	-- If this is after the PLAYER_LOGIN event then make up for the missed one-time event
	if  AddonLoader:IsVariablesLoaded()  then  self:SaveEventHandlers('VARIABLES_LOADED')  end
	if  AddonLoader:IsSpellsLoaded()  then  self:SaveEventHandlers('SPELLS_CHANGED')  end
	if  IsLoggedIn()  then  self:SaveEventHandlers('PLAYER_LOGIN')  end
	if  IsPlayerInWorld()  then  self:SaveEventHandlers('PLAYER_ENTERING_WORLD')  end
	return self
end


function AddonLoader:StartCapture()
	--return AddonCapture:StartCapture()
	AddonCapture:StartCapture()
	return AddonCapture
	--return (AddonCapture:New()):StartCapture()
end



function AddonCapture:SaveNewEventHandlers(eventName)
	local framesBefore = self.framesBefore[eventName]
	if  not framesBefore  then  return  end
	local newFrames = {}
	for  i, frame  in ipairs({ GetFramesRegisteredForEvent(eventName) }) do
		if  not framesBefore[frame]  then  newFrames[#newFrames+1] = frame  end
	end
	self.newFrames[eventName] = newFrames
end

function AddonCapture:StopCapture()
	self.newFrames = {}
	self:SaveNewEventHandlers('VARIABLES_LOADED')
	self:SaveNewEventHandlers('SPELLS_CHANGED')
	self:SaveNewEventHandlers('PLAYER_LOGIN')
	self:SaveNewEventHandlers('PLAYER_ENTERING_WORLD')
	return self
end



function SendFrameEvent(frame, eventName, ...)
	if  not frame  then  return nil  end
	local OnEvent = frame:GetScript('OnEvent')
	if  not OnEvent  then  return nil  end
	local ran, result = safecall(OnEvent, frame, eventName, ...)
	return ran, result
end

function AddonCapture:SendEvent(eventName)  -- ?
	local newFrames = self.newFrames[eventName]
	if  not newFrames  then  return  end
	Debug("AddonCapture:SendEvent("..eventName..")")
	
	local eventParams = AddonLoader[eventName] or {}
	for  i, frame  in ipairs(newFrames) do
		Debug("SendFrameEvent("..eventName..") to ".. (frame:GetName() or tostring(frame)) )
		local ran, result = SendFrameEvent(frame, eventName, unpack(eventParams))
		if  not ran  then
			self.frameErrors = self.frameErrors or {}
			self.frameErrors[#self.frameErrors+1] = { frame, eventName }
			AddonLoader.frameErrors = self.frameErrors
			print( "Error when sending event  "..eventName.."  to frame  "..(frame:GetName() or "<unnamed>")..". See  /dump AddonLoader.frameErrors" )
		end
	end
	return self
end

function AddonCapture:SendAddOnLoadEvents()
	self:SendEvent('VARIABLES_LOADED')
	self:SendEvent('SPELLS_CHANGED')
	self:SendEvent('PLAYER_LOGIN')
	self:SendEvent('PLAYER_ENTERING_WORLD')
	return self
end




