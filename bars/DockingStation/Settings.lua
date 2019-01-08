local addonName, addon = ...

local pairs_iter = pairs(addon)

--[[----------------------------------------------------------------------------
Local to module
------------------------------------------------------------------------------]]
local CheckStringDefaults
do
	local default = { "labelColorA", "labelColorB", "labelColorG", "labelColorR", "labelEffect", "labelFont", "labelOverride", "labelSize", "labelVertAdj" }
	local watched = {
		suffixColorA	= -1,		textColorA		= 1,
		suffixColorB	= -2,		textColorB		= 2,
		suffixColorG	= -3,		textColorG		= 3,
		suffixColorR	= -4,		textColorR		= 4,
		suffixEffect	= -5,		textEffect		= 5,
		suffixFont		= -6,		textFont		= 6,
		suffixOverride	= -7,		textOverride	= 7,
		suffixSize		= -8,		textSize		= 8,
		suffixVertAdj	= -9,		textVertAdj		= 9
	}
	CheckStringDefaults = function(self, key)
		key = watched[key]
		if key then
			if key > 0 then
				if self["textUseLabel"] then
					return self[default[key]]
				end
			else
				if self["suffixUseLabel"] then
					return self[default[-key]]
				end
			end
		end
	end
end

local DEFAULT_SETTINGS = {
	allowGlobals		= false,
	alphaMouse			= false,
	alphaNormal			= 1,
	alphaParameters		= "",
	anchor				= 'CENTER',
	bgColorA			= 1,
	bgColorB			= 0,
	bgColorG			= 0,
	bgColorR			= 0,
	bgInset				= 0,
	bgTexture			= 'Solid',
	borderColorA		= 1,
	borderColorB		= 0.85,
	borderColorG		= 0.85,
	borderColorR		= 0.85,
	borderSize			= 11,
	borderTexture		= 'None',
	defaultPanel		= false,
	defaultSection		= "Left",
	height				= 20 / 768,
	hideErrors			= true,
	iconFlip			= false,
	iconHide			= false,
	iconSize			= 0.85,
	iconTrim			= true,
	iconVertAdj			= 0,
	iconZoom			= 0,
	labelColorA			= 1,
	labelColorB			= 1,
	labelColorG			= 1,
	labelColorR			= 1,
	labelEffect			= 0,
	labelFont			= 'Friz Quadrata TT',
	labelHide			= false,
	labelOverride		= false,
	labelSize			= 0.55,
	labelUseName		= false,
	labelVertAdj		= 0,
	level				= 32,
	lockPanel			= true,
	lockPlugin			= false,
	moveBlizzard		= false,
	overlayColorA		= 1,
	overlayColorB		= 1,
	overlayColorG		= 1,
	overlayColorR		= 1,
	overlayFlip			= false,
	overlayFlop			= false,
	overlayTexture		= "None",
	rightClickConfig	= true,
	scaleSideBar		= 0.85,
	screenClamp			= 0,
	spacingCenter		= 0.5,
	spacingLeft			= 0.5,
	spacingLeftEdge		= 0.25,
	spacingRight		= 0.5,
	spacingRightEdge	= 0.25,
	strata				= 4,
	suffixColorA		= 1,
	suffixColorB		= 1,
	suffixColorG		= 1,
	suffixColorR		= 1,
	suffixEffect		= 0,
	suffixFont			= 'Friz Quadrata TT',
	suffixHide			= false,
	suffixOverride		= false,
	suffixSize			= 0.55,
	suffixUseLabel		= true,
	suffixVertAdj		= 0,
	textColorA			= 1,
	textColorB			= 1,
	textColorG			= 1,
	textColorR			= 1,
	textEffect			= 0,
	textFixed			= false,
	textFont			= 'Friz Quadrata TT',
	textHide			= false,
	textOverride		= false,
	textSize			= 0.55,
	textUseLabel		= true,
	textVertAdj			= 0,
	tooltipParameters	= "",
	tooltipScale		= 0.8,
	width				= 1
}

local function GetDefaultPanelSettings()
	return {
		enable = true,
		lockPanel = false,
		offsetX = 0,
		offsetY = 0,
		Center = { },
		Left = { },
		Right = { }
	}
end

local function GetDefaultPluginSettings()
	return {
		enable = false
	}
end

local function GetSettingsMT(defaults)
	return { __index = function(value, index)
		value = CheckStringDefaults(value, index)
		if value == nil then
			return defaults[index]
		end
		return value
	end }
end

local mt_defaults, mt_panels, mt_settings = GetSettingsMT(DEFAULT_SETTINGS), { }

--[[----------------------------------------------------------------------------
Global to addon
------------------------------------------------------------------------------]]
function addon.GetSettings()
	local settings = setmetatable(addon.db.profile, mt_defaults)
	addon.settings = settings

	mt_panels, mt_settings = wipe(mt_panels), GetSettingsMT(settings)
	if not addon.sectionTypes[settings.defaultSection] then
		settings.defaultSection = nil
	end

	local panels = addon.GetSubTable(settings, "panels")
	if not next(panels) then
		local id = addon.GenerateUniqueKey()
		panels[id] = GetDefaultPanelSettings()
		panels[id][settings.defaultSection][1] = addonName
		settings.defaultPanel = id
	elseif not panels[settings.defaultPanel] then
		settings.defaultPanel = next(panels)
	end
	for id in pairs_iter, panels, nil do
		addon.GetPanelSettings(id)
	end

	local plugins, GetPluginSettings = addon.GetSubTable(settings, "plugins"), addon.GetPluginSettings
	if not plugins[addonName] then
		plugins[addonName] = GetDefaultPluginSettings()
		plugins[addonName].enable = true
	end
	for name in pairs_iter, plugins, nil do
		GetPluginSettings(name)
	end

	return settings
end

function addon.GetPanelSettings(id)
	if not addon.settings.panels[id] then
		addon.settings.panels[id] = GetDefaultPanelSettings()
	end
	return setmetatable(addon.settings.panels[id], mt_settings)
end

function addon.GetPluginSettings(name)
	if not addon.settings.plugins[name] then
		addon.settings.plugins[name] = GetDefaultPluginSettings()
	end
	return addon.SetInheritance(name, addon.GetPluginLocation(name))
end

function addon.SetInheritance(name, id)
	if id then
		if not mt_panels[id] then
			mt_panels[id] = GetSettingsMT(addon.settings.panels[id])
		end
		return setmetatable(addon.settings.plugins[name], mt_panels[id])
	else
		return setmetatable(addon.settings.plugins[name], mt_settings)
	end
end

--[[----------------------------------------------------------------------------
Initialize on load
------------------------------------------------------------------------------]]
addon:RegisterEvent('ADDON_LOADED', function(_, name)
	if name ~= addonName then return end
	addon:UnregisterEvent('ADDON_LOADED')

	local GetSubTable = addon.GetSubTable
	local settings = GetSubTable(_G, addonName .. "Settings")
	addon.pluginAlias = GetSubTable(settings, "pluginAlias")
	addon.pluginType = GetSubTable(settings, "pluginType")
	GetSubTable(settings, 'profileKeys')
	GetSubTable(settings, 'profiles')

	if addon.Convert then														-- Convert.lua may be deleted after it has run once
		addon.Convert(settings)
		addon.Convert = nil
	end
	addon.db = LibStub('AceDB-3.0'):New(addonName .. "Settings", nil, 'Default')
end)

--[[----------------------------------------------------------------------------
Clean up on log out
------------------------------------------------------------------------------]]
addon:RegisterEvent('PLAYER_LOGOUT', function()
	local pluginAlias, pluginType = addon.pluginAlias, addon.pluginType
	local remove = { }
	for name in pairs_iter, pluginType, nil do
		remove[name] = true
	end
	for _, settings in pairs_iter, _G[addonName .. "Settings"].profiles, nil do
		settings = settings.plugins
		for name in pairs_iter, remove, nil do
			if settings[name] then
				remove[name] = nil
			end
		end
	end
	for name in pairs_iter, remove, nil do
		pluginAlias[name], pluginType[name] = nil, nil
	end
end)
