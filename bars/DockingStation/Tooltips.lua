--[[----------------------------------------------------------------------------
Support for LDB tooltips handled via OnEnter/OnLeave
------------------------------------------------------------------------------]]

local addonName, addon = ...

local GetMouseFocus, GetPoint, MouseIsOver = GetMouseFocus, UIParent.GetPoint, MouseIsOver

local MONITOR_INTERVAL = 0.05

--[[----------------------------------------------------------------------------
Helpers
------------------------------------------------------------------------------]]
local tooltipCache, activeTooltips, lastFrame = { }

local function FindTooltip(plugin, tooltips)
	for _, tooltip in pairs(tooltips) do
		local _, relFrame = GetPoint(tooltip, 1)
		if relFrame == plugin then
			return tooltip
		end
	end
end

local function UpdateTooltipCache()
	local EnumerateFrames, IsObjectType = EnumerateFrames, UIParent.IsObjectType
	local frame = EnumerateFrames(lastFrame)
	while frame do
		if IsObjectType(frame, 'GameTooltip') then
			tooltipCache[frame] = frame
		end
		frame, lastFrame = EnumerateFrames(frame), frame
	end
end

--[[----------------------------------------------------------------------------
Monitor

Do not force :EnableMouse(true) as it can break some addons with tooltips that
open at the cursor.  Use tooltip:IsMouseOver() as a work around.
------------------------------------------------------------------------------]]
local monitor = CreateFrame('Frame', nil, UIParent)
monitor:Hide()

do
	local delay, timer, timeOut = 0, 0, 0

	local isValidFocus = setmetatable({ }, {
		__index = function(self, frame)
			if frame then
				local _, relFrame = GetPoint(frame, 1)
				self[frame] = relFrame and self[relFrame] or false
				return self[frame]
			end
			return false
		end,

		__newindex = function(self, frame, isValid)
			rawset(self, frame, isValid)
			if isValid then
				if activeTooltips and frame.key and activeTooltips[frame.key] == frame then
					local autoHide = frame.autoHideTimerFrame
					if autoHide then
						if autoHide.alternateFrame then
							self[autoHide.alternateFrame] = true
						end
						if autoHide.parent then
							self[autoHide.parent] = true
						end
					end
				end
			end
		end
	})

	monitor:SetScript('OnHide', function(self)
		local tooltip = self.tooltip
		if tooltip.SetAutoHideDelay then
			tooltip:SetAutoHideDelay()
		end
		if tooltip.Release then
			tooltip:Release()
		else
			tooltip:Hide()
		end
		self.plugin:DetachFrame()
		self.plugin, self.tooltip = nil, nil
		wipe(isValidFocus)
	end)

	monitor:SetScript('OnShow', function(self)
		local autoHide = self.tooltip.autoHideTimerFrame
		delay, timer, timeOut = tonumber(autoHide and autoHide.delay) or 0, 0, 0
		isValidFocus[self.plugin] = true
		isValidFocus[self.tooltip] = true
		isValidFocus[UIParent] = false
		isValidFocus[WorldFrame] = false
	end)

	monitor:SetScript('OnUpdate', function(self, elapsed)
		timer = timer + elapsed
		if timer < MONITOR_INTERVAL then return end

		if isValidFocus[GetMouseFocus()] or self.tooltip:IsMouseOver() then
			timeOut = 0
		else
			timeOut = timeOut + timer
			if timeOut >= delay then
				self:Hide()
			end
		end
		timer = 0
	end)
end

--[[----------------------------------------------------------------------------
Global to addon
------------------------------------------------------------------------------]]
function addon.AcquireTooltip(plugin)
	local tooltip = plugin.attached
	if not tooltip and activeTooltips then
		tooltip = FindTooltip(plugin, activeTooltips)
	end
	if not tooltip then
		UpdateTooltipCache()
		tooltip = FindTooltip(plugin, tooltipCache)
		if tooltip and tooltip:GetAnchorType() ~= 'ANCHOR_NONE' then
			tooltip:SetAnchorType('ANCHOR_NONE')
		end
	end
	if tooltip then
		monitor:Hide()
		if plugin.attached ~= tooltip then
			plugin:AttachFrame(tooltip)
		end
		monitor.plugin, monitor.tooltip = plugin, tooltip
		monitor:Show()
	end
end

function addon.ReleaseTooltip(plugin)
	if plugin then
		local tooltip = plugin.attached
		if tooltip and tooltip:IsShown() then
			return
		end
	end
	monitor:Hide()
end

--[[----------------------------------------------------------------------------
Initialize
------------------------------------------------------------------------------]]
monitor:SetScript('OnEvent', function(self, event)
	local LQT = LibStub('LibQTip-1.0', true)
	if not LQT then return end
	activeTooltips = LQT.activeTooltips
	self:SetScript('OnEvent', nil)
	self:UnregisterEvent(event)
end)
monitor:RegisterEvent('ADDON_LOADED')

UpdateTooltipCache()
