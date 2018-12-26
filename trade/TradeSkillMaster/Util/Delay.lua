-- ------------------------------------------------------------------------------ --
--                                TradeSkillMaster                                --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- This file contains various delay APIs

local TSM = select(2, ...)
LibStub("AceTimer-3.0"):Embed(TSM)

--[[
local delays = {}
local events = {}
--]]
local private = {} -- registers for tracing at the end
local timers = {}
local repeatOnUpdates = {}
local updateFrame
local asyncCallbacks = {}
local eventBuckets = {}
local fireBuckets = {}


--[[
-- OnUpdate script handler for delay frames
local function DelayFrameOnUpdate(self, elapsed)
	if self.inUse == "repeat" then
		self.callback()
	elseif self.inUse == "delay" then
		self.timeLeft = self.timeLeft - elapsed
		if self.timeLeft <= 0 then
			if self.repeatDelay then
				self.timeLeft = self.repeatDelay
			else
				TSMAPI:CancelFrame(self)
			end
			if self.callback then
				self.callback()
			end
		end
	end
end

-- Helper function for creating delay frames
local function CreateDelayFrame()
	local delay = CreateFrame("Frame")
	delay:Hide()
	delay:SetScript("OnUpdate", DelayFrameOnUpdate)
	return delay
end
--]]

--- Creates a time-based delay. The callback function will be called after the specified duration.
-- Use TSMAPI:CancelFrame(label) to cancel delays (usually just used for repetitive delays).
-- @param label An arbitrary label for this delay. If a delay with this label has already been started, the request will be ignored.
-- @param duration How long before the callback should be called. This is generally accuate within 50ms (depending on frame rate).
-- @param callback The function to be called after the duration expires.
-- @param repeatDelay If you want this delay to repeat until canceled, after the initial duration expires, will restart the callback with this duration. Passing nil means no repeating.
-- @return Returns an error message as the second return value on error.
function TSMAPI:CreateTimeDelay(...)
	local label, duration, callback, repeatDelay = ...
	if  type(label) == 'number'  then  label, duration, callback, repeatDelay = nil, ...  end
	if not label or type(duration) ~= "number" or type(callback) ~= "function" then return nil, "invalid args", label, duration, callback, repeatDelay end
	local timerID
	
	-- Timer with label already registered?
	if  timers[label]  then  return  end
	
	if  not repeatDelay  then
		if  duration == 0  then
			asyncCallbacks[callback] = callback
		else
			timerID = TSM:ScheduleTimer(callback, duration)
		end
	else
		if  duration ~= repeatDelay  then
			-- Core/Mover.lua gives smaller duration than repeatDelay.
			-- AceTimer does not support this out-of-the-box and an extra callback round would be overshoot, therefore the initial delay is also the repeatDelay.
		end
		timerID = TSM:ScheduleRepeatingTimer(callback, repeatDelay)
	end
	
	if  label  then  timers[label] = timerID  end
end

--[[
function TSMAPI:CreateTimeDelay(...)
	local label, duration, callback, repeatDelay
	if type(select(1, ...)) == "number" then
		-- use unique string as placeholder label if none specified
		label = tostring({})
		duration, callback, repeatDelay = ...
	else
		label, duration, callback, repeatDelay = ...
	end
	if not label or type(duration) ~= "number" or type(callback) ~= "function" then return nil, "invalid args", label, duration, callback, repeatDelay end

	local frameNum
	for i, frame in ipairs(delays) do
		if frame.label == label then return end
		if not frame.inUse then
			frameNum = i
		end
	end
	
	if not frameNum then
		-- all the frames are in use, create a new one
		tinsert(delays, CreateDelayFrame())
		frameNum = #delays
	end
	
	local frame = delays[frameNum]
	frame.inUse = "delay"
	frame.repeatDelay = repeatDelay
	frame.label = label
	frame.timeLeft = duration
	frame.callback = callback
	frame:Show()
end
--]]

--- The passed callback function will be called once every OnUpdate until canceled via TSMAPI:CancelFrame(label).
-- @param label An arbitrary label for this delay. If a delay with this label has already been started, the request will be ignored.
-- @param callback The function to be called every OnUpdate.
-- @return Returns an error message as the second return value on error.
function TSMAPI:CreateFunctionRepeat(label, callback)
	if not label or label == "" or type(callback) ~= "function" then return nil, "invalid args", label, callback end
	
	if  repeatOnUpdates[label]  then  return  end
	
	repeatOnUpdates[label] = callback
	
	--CreateUpdateFrame()
	if  not updateFrame:IsShown()  then  updateFrame:Show()  end
end

--[[
function TSMAPI:CreateFunctionRepeat(label, callback)
	if not label or label == "" or type(callback) ~= "function" then return nil, "invalid args", label, callback end

	local frameNum
	for i, frame in ipairs(delays) do
		if frame.label == label then return end
		if not frame.inUse then
			frameNum = i
		end
	end
	
	if not frameNum then
		-- all the frames are in use, create a new one
		tinsert(delays, CreateDelayFrame())
		frameNum = #delays
	end
	
	local frame = delays[frameNum]
	frame.inUse = "repeat"
	frame.label = label
	frame.callback = callback
	frame:Show()
end
--]]

--- Cancels a frame created through TSMAPI:CreateTimeDelay() or TSMAPI:CreateFunctionRepeat().
-- Frames are automatically recycled to avoid memory leaks.
-- @param label The label of the frame you want to cancel.
function TSMAPI:CancelFrame(label)
	local timerID = timers[label]
	if  timerID  then  return TSM:CancelTimer(timerID)  end
	
	local callback = repeatOnUpdates[label]
	if  callback  then
		repeatOnUpdates[label] = nil
		return true
	else
		-- No TimeDelay or FunctionRepeat found with this label.
  end
end

--[[
function TSMAPI:CancelFrame(label)
	if label == "" then return end
	local delayFrame
	if type(label) == "table" then
		delayFrame = label
	else
		for i, frame in ipairs(delays) do
			if frame.label == label then
				delayFrame = frame
			end
		end
	end
	
	if delayFrame then
		delayFrame:Hide()
		delayFrame.label = nil
		delayFrame.inUse = nil
		delayFrame.validate = nil
		delayFrame.timeLeft = nil
	end
end
--]]



local function FireBucket(bucket, byTimer)
	if  byTimer  then  bucket.timerID = nil  end
	bucket.lastCallback = GetTime()
	bucket.callback()
end

local function BucketHandler(bucket, event, ...)
	-- Do nothing if already scheduled
	if  bucket.timerID  then  return  end

	local sinceLast = GetTime() - bucket.lastCallback
	if  sinceLast > bucket.bucketTime  then
		fireBuckets[bucket] = bucket
		if  not updateFrame:IsShown()  then  updateFrame:Show()  end
	else
		bucket.timerID = TSM:ScheduleTimer(FireBucket, bucket.bucketTime - sinceLast, bucket, 'timer')
	end
end


-- TSMAPI:CreateEventBucket(event, callback, bucketTime) works slightly differently from AceBucket.
-- After no events for bucketTime period the first event triggers the callback in the next framedraw (next OnUpdate cycle).
-- In comparison AceBucket delays the first event by bucketTime in every case.
function TSMAPI:CreateEventBucket(event, callback, bucketTime)
	local bucket = { event = event, callback = callback, bucketTime = bucketTime or 0, lastCallback = 0 }
	eventBuckets[event] = eventBuckets[event] or {}
	tinsert(eventBuckets[event], bucket)
	TSM:RegisterEvent(event, BucketHandler, bucket)
	--CreateUpdateFrame()
end



--[[
local function EventFrameOnUpdate(self)
	for event, data in pairs(self.eventPending) do
		if GetTime() > (data.lastCallback + data.bucketTime) then
			--data.eventPending = nil
			data.lastCallback = GetTime()
			data.callback()
		end
	end
end

local function CreateEventFrame()
	local event = CreateFrame("Frame")
	event:SetScript("OnEvent", EventFrameOnEvent)
	event:SetScript("OnUpdate", EventFrameOnUpdate)
	event.events = {}
	return event
end

function TSMAPI:CreateEventBucket(event, callback, bucketTime)
	local eventFrame
	for _, frame in ipairs(events) do
		if not frame.events[event] then
			eventFrame = frame
			break
		end
	end
	if not eventFrame then
		eventFrame = CreateEventFrame()
		tinsert(events, eventFrame)
	end
	
	eventFrame:RegisterEvent(event)
	eventFrame.events[event] = {callback=callback, bucketTime=bucketTime, lastCallback=0}
end
--]]


local function OnUpdate(self, elapsed)
	--for  bucket  in fireBuckets do
	local bucket = next(fireBuckets)
	if  bucket  then
		fireBuckets[bucket] = nil
		-- Remove first, order matters: if bucket.callback() causes an error there will be no infinite loop.
		FireBucket(bucket)
		return
	end
	
	for  callback  in pairs(asyncCallbacks) do
		asyncCallbacks[callback] = nil
		callback()
	end
	
	for  callback  in pairs(repeatOnUpdates) do
		callback()
	end
	
	-- No buckets or FunctionRepeat to call: hide frame to stop OnUpdate()
	if  not next(repeatOnUpdates)  then  self:Hide()  end
end

local function CreateUpdateFrame()
	if  updateFrame  then  return  end
	updateFrame = CreateFrame("Frame")
	updateFrame:Hide()
	updateFrame:SetScript('OnUpdate', OnUpdate)
end

CreateUpdateFrame()



TSMAPI:CreateTimeDelay(0.1, function()
		-- This MUST be at the end for this file since RegisterForTracing uses TSMAPI:CreateTimeDelay() which is defined in this file.
		TSMAPI:RegisterForTracing(private, "TradeSkillMaster.Delay_private")
	end)