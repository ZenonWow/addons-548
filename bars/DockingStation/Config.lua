local addonName, addon = ...

local L = addon.L

addon.CONFIG_IS_OPEN = false
addon.PanelList = { Add = addon.DoNothing, Delete = addon.DoNothing, Refresh = addon.DoNothing, Select = addon.DoNothing }
addon.PluginList = addon.PanelList												-- Will assign a seperate table when needed

--[[----------------------------------------------------------------------------
Config mode support
------------------------------------------------------------------------------]]
addon.GetSubTable(_G, 'CONFIGMODE_CALLBACKS')[addonName] = function(action)
	local lock
	if action == 'ON' then
		lock = false
	elseif action == 'OFF' then
		lock = true
	else
		return
	end
	addon.settings.lockPanel = lock
	for _, settings in pairs(addon.settings.panels) do
		settings.lockPanel = nil
	end
	addon:AllPanels(lock and "Lock" or "Unlock")
	if addon.CONFIG_IS_OPEN then
		addon.CONFIG_IS_OPEN:Refresh()
	end
end

--[[----------------------------------------------------------------------------
LoD support
------------------------------------------------------------------------------]]
local LOA = LibStub('LibOptionsAssist-1.0', true)
if not (LOA and select(2, GetAddOnInfo(addonName .. '_Config'))) then return end	-- Make sure config support exists

local function LoadOnDemand()
	local config = addonName .. '_Config'
	addon.addonName, _G[config], addon.PluginList = addonName, addon, { }		-- PanelList and PluginList are shared while they are dummies
	LibStub('LibOptionsAssist-1.0'):LoadModule(config)
	addon.addonName, _G[config] = nil, nil
end

addon.ConfigFrames = {
	[0] = LOA:AddEntry(addonName, nil, LoadOnDemand),
	[1] = LOA:AddEntry(L["Panels"], addonName, "parent"),
	[2] = LOA:AddEntry(L["Plugins"], addonName, "parent"),
	[3] = LOA:AddEntry(L["Profiles"], addonName, "parent")
}

--[[----------------------------------------------------------------------------
Quicklauncher
------------------------------------------------------------------------------]]
LibStub('LibDataBroker-1.1'):NewDataObject(addonName, {
	type = 'launcher',
	icon = [[Interface\AddOns\]] .. addonName .. [[\Media\Icon]],
	iconCoords = { 2/64, 61/64, 3/64, 61/64 },
	label = addonName,
	OnClick = function()
		local configFrames, open = addon.ConfigFrames, 0
		for index = 0, #configFrames do
			if configFrames[index]:IsShown() then
				open = configFrames[index]:IsVisible() and index + 1 or index
				break
			end
		end
		configFrames[open % (#configFrames + 1)]()
	end,
	OnTooltipShow = function(tooltip)
		local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR
		tooltip:SetText(addonName, 1, 1, 1)
		tooltip:AddLine(L["Click to open the configuration panel."], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
	end
})

--[[----------------------------------------------------------------------------
Slash command
------------------------------------------------------------------------------]]
_G['SLASH_' .. addonName .. 1] = '/' .. addonName:lower()
SlashCmdList[addonName] = addon.ConfigFrames[0]
