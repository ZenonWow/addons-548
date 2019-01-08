if not _G[...] then return end
local addon = _G[...]
local addonName = addon.addonName

local max, min, pairs_iter, rawget = max, min, pairs(addon), rawget

local pluginType, ConfigFrames = addon.pluginType, addon.ConfigFrames

local GetPluginLocation = addon.GetPluginLocation

local L = addon.L

local RESOLUTION_WIDTH, RESOLUTION_HEIGHT = LibStub('LibDisplayAssist-1.3').GetResolutionInfo()
local MAX_HEIGHT, MAX_WIDTH = RESOLUTION_HEIGHT / 16, RESOLUTION_WIDTH
local MIN_HEIGHT, MIN_WIDTH = RESOLUTION_HEIGHT / 64, RESOLUTION_WIDTH / 64

local panelOptions

--[[----------------------------------------------------------------------------
Helpers
------------------------------------------------------------------------------]]
local panelIDs, panelList = { }, { }

function addon.UpdatePanelList()												-- Global to addon for use in SideBarMenu
	wipe(panelIDs)
	wipe(panelList)
	local PanelList = addon.PanelList
	for index = 1, #PanelList do
		panelIDs[index], panelList[index] = PanelList[index].key, PanelList[index].label
	end
end
addon.UpdatePanelList()

LibStub('LibDisplayAssist-1.3').Register(ConfigFrames, function(event, screenWidth, screenHeight, resolutionWidth, resolutionHeight)
	RESOLUTION_HEIGHT, RESOLUTION_WIDTH = resolutionHeight, resolutionWidth
	MAX_HEIGHT, MAX_WIDTH = resolutionHeight / 16, resolutionWidth
	MIN_HEIGHT, MIN_WIDTH = resolutionHeight / 64, resolutionWidth / 64
	local sizeArgs = panelOptions.args.size.args
	sizeArgs.height.max, sizeArgs.height.min = MAX_HEIGHT, MIN_HEIGHT
	sizeArgs.width.max, sizeArgs.width.min = MAX_WIDTH, MIN_WIDTH
	if addon.CONFIG_IS_OPEN == ConfigFrames[1] then
		addon.CONFIG_IS_OPEN:Refresh()
	end
end)

--[[----------------------------------------------------------------------------
Common for all options
------------------------------------------------------------------------------]]
local _branch, _object, _selection, _settings									-- Set via UpdateConfigVariables()

local function DisableIfDefault(info)
	return info.type ~= 'group' and rawget(_settings, info[#info]) == nil
end

local function DisableIfDefaultColor(info)
	return rawget(_settings, info[#info] .. "R") == nil
end

local function Get(info)
	return _settings[info[#info]]
end

local function GetColor(info)
	local field = info[#info]
	return _settings[field .. "R"], _settings[field .. "G"], _settings[field .. "B"], _settings[field .. "A"]
end

local function GetDefaultStatus(info)
	if info.arg[1] ~= true then
		return rawget(_settings, info.arg[1]) == nil
	else
		return rawget(_settings, info[#info - 1] .. info.arg[2]) == nil
	end
end

local function GetTriState(info)
	if _branch then
		return _settings[info[#info]] or false
	end
	local field, set, unset = info[#info]
	for _, settings in pairs_iter, addon.settings.panels, nil do
		if settings[field] then
			if unset then return end
			set = true
		else
			if set then return end
			unset = true
		end
	end
	return set and true or false
end

local function HideDualPosition(info)
	return #info == 1
end

local function IsLauncher()
	return _branch == "Plugins" and pluginType[_selection] == 'launcher'
end

local function MassClear(info, fields)
	if fields[1] ~= true then
		for index = 1, #fields do
			_settings[fields[index]] = nil
		end
	else
		local category = info[#info - 1]
		for index = 2, #fields do
			_settings[category .. fields[index]] = nil
		end
	end
end

local function MassLoad(info, fields)
	if fields[1] ~= true then
		for index = 1, #fields do
			_settings[fields[index]] = _settings[fields[index]]
		end
	else
		local category, field = info[#info - 1]
		for index = 2, #fields do
			field = category .. fields[index]
			_settings[field] = _settings[field]
		end
	end
end

local function RefreshSettings()
	if _branch then
		if _object then
			_object:Refresh()
		end
	else
		addon:AllPanels("Refresh")
	end
end

local function Set(info, value)
	if not info.arg then
		_settings[info[#info]] = value or false
		if not _branch and info.option.tristate then
			local field = info[#info]
			for _, settings in pairs_iter, addon.settings.panels, nil do
				settings[field] = nil
			end
		end
	elseif value then
		MassClear(info, info.arg)
	else
		MassLoad(info, info.arg)
	end
end

local function SetColor(info, red, green, blue, alpha)
	local field = info[#info]
	_settings[field .. "R"], _settings[field .. "G"], _settings[field .. "B"], _settings[field .. "A"] = red, green, blue, alpha
	RefreshSettings()
end

local function SetWithRefresh(info, value)
	Set(info, value)
	RefreshSettings()
end

--[[-----------------------------------------------------------------------------
String Options
-------------------------------------------------------------------------------]]
local baseArg = { true, "Hide", "Fixed", "UseLabel", "UseName" }
local sharedArg = { true, "ColorA", "ColorB", "ColorG", "ColorR", "Effect", "Font", "Override", "Size", "VertAdj" }

local function DisableIfDefaultString(info)
	return info.type ~= 'group' and rawget(_settings, info[#info - 1] .. info[#info]) == nil
end

local function GetString(info)
	return _settings[info[#info - 1] .. info[#info]]
end

local function SetString(info, value)
	_settings[info[#info - 1] .. info[#info]] = value
	RefreshSettings()
end

local stringArgs = {
	defaults = {
		type = 'toggle',
		order = 1,
		name = L["Defaults"],
		desc = L["Use defaults for these settings."],
		width = 'half',
		disabled = false,
		arg = baseArg,
		get = GetDefaultStatus,
		set = function(info, value)
			if value then
				MassClear(info, baseArg)
				MassClear(info, sharedArg)
			else
				MassLoad(info, baseArg)
				if not _settings[info[#info - 1] .. "UseLabel"] then
					MassLoad(info, sharedArg)
				end
			end
			RefreshSettings()
		end
	},
	Hide = {
		type = 'toggle',
		order = 2,
		name = L["Hide"],
		desc = L["Determines if this component should be hidden."],
		width = 'half'
	},
	UseLabel = {
		type = 'toggle',
		order = 3,
		name = L["Same as Label"],
		desc = L["Use the same settings as for the label."],
		hidden = function(info)
			return info[#info - 1] == 'label'
		end,
		set = function(info, value)
			if value then
				MassClear(info, sharedArg)
			else
				MassLoad(info, sharedArg)
			end
			_settings[info[#info - 1] .. "UseLabel"] = value
			RefreshSettings()
		end
	},
	UseName = {
		type = 'toggle',
		order = 3.5,
		name = L["Use Name"],
		desc = L["Determines if the name of the plugin, as it appears in the selection window, should replace any provided label."],
		hidden = function(info)
			return info[#info - 1] ~= 'label'
		end
	},
	Font = {
		type = 'select', control = 'LSM30_Font',
		order = 4,
		name = L["Font"],
		desc = L["Choose a font to use."],
		values = AceGUIWidgetLSMlists.font
	},
	Effect = {
		type = 'select',
		order = 5,
		name = L["Effect"],
		desc = L["Choose an effect to apply to the font."],
		values = { [0] = L["None"], [1] = L["Outline"], [2] = L["Outline, Thick"], [3] = L["Shadow"], [4] = L["Shadow, Distinct"] }
	},
	Size = {
		type = 'range', isPercent = true,
		order = 6,
		name = L["Size"],
		desc = L["Set the size of the font."],
		min = 0.2, max = 1, step = 0.01
	},
	VertAdj = {
		type = 'range', isPercent = true,
		order = 7,
		name = L["Vertical Adjust"],
		desc = L["Align the font vertically."],
		min = -1, max = 1, step = 0.01
	},
	Color = {
		type = 'color',
		order = 8,
		name = L["Color"],
		desc = L["Change the color of the font."],
		width = 'half',
		disabled = function(info)
			return rawget(_settings, info[#info - 1] .. "ColorR") == nil
		end,
		get = function(info)
			local category = info[#info - 1]
			return _settings[category .. "ColorR"], _settings[category .. "ColorG"], _settings[category .. "ColorB"], _settings[category .. "ColorA"]
		end,
		set = function(info, red, green, blue, alpha)
			local category = info[#info - 1]
			_settings[category .. "ColorR"], _settings[category .. "ColorG"], _settings[category .. "ColorB"], _settings[category .. "ColorA"] = red, green, blue, alpha
			RefreshSettings()
		end
	},
	Override = {
		type = 'toggle',
		order = 9,
		name = L["Override"],
		desc = L["Ignore native plugin font coloring."],
		width = 'half'
	},
	Fixed = {
		type = 'input',
		order = 10,
		name = L["Fixed Width"],
		desc = L["Enter a value that best represents the width to be maintained.\n\nExample: 8888.88 DPS"],
		hidden = function(info)
			return info[#info - 1] ~= 'text'
		end,
		set = function(info, value)
			value = strtrim(value)
			if value == "" then
				value = false
			end
			SetString(info, value)
		end
	}
}

--[[-----------------------------------------------------------------------------
Plugin Options
-------------------------------------------------------------------------------]]
local function HidePanelAndSectionOption(info)
	return _branch == "Panels" or #info == 1
end

local panel = {
	type = 'select',
	order = -2,
	name = L["Panel"],
	desc = function(info)
		if _branch then
			return L["Choose which panel should display this plugin."]
		end
		return L["Choose which panel should be the default display for plugins."]
	end,
	values = panelList,
	disabled = false,
	hidden = HidePanelAndSectionOption,
	get = function(info)
		local id = _branch and GetPluginLocation(_selection) or addon.settings.defaultPanel
		for index = 1, #panelIDs do
			if panelIDs[index] == id then
				return index
			end
		end
	end,
	set = function(info, value)
		if _branch then
			local id, sectionType = GetPluginLocation(_selection)
			if id ~= panelIDs[value] then
				addon.SetPluginLocation(_selection, panelIDs[value], sectionType)
			end
		else
			addon.settings.defaultPanel = panelIDs[value]
		end
	end
}

local section = {
	type = 'select',
	order = -1,
	name = L["Section"],
	desc = function(info)
		if _branch then
			return L["Choose the section of a panel to display this plugin."]
		end
		return L["Choose the default section of panels to display plugins."]
	end,
	values = addon.sectionTypes,
	disabled = false,
	hidden = HidePanelAndSectionOption,
	get = function(info)
		if _branch then
			local _, section = GetPluginLocation(_selection)
			return section or addon.settings.defaultSection
		end
		return addon.settings.defaultSection
	end,
	set = function(info, value)
		if _branch then
			local id, section = GetPluginLocation(_selection)
			if section ~= value then
				addon.SetPluginLocation(_selection, id, value)
			end
		else
			addon.settings.defaultSection = value
		end
	end
}

local pluginOptions = {
	type = 'group',
	order = -1,
	name = L["Plugin Defaults"],
	desc = function(info)
		if info[1] == "Panels" then
			return L["Set the default behavior for plugins in this panel."]
		end
		return L["Set the default behavior for plugins."]
	end,
	disabled = DisableIfDefault,
	hidden = function(info)
		return info[1] == "panels"
	end,
	get = Get,
	set = SetWithRefresh,
	args = {
		lockPlugin = {
			type = 'toggle', tristate = true,
			order = 1,
			name = L["Lock"],
			width = 'half',
			desc = function(info)
				if info[1] == "Panels" then
					return L["Determines whether or not the plugins in this panel can be dragged by the mouse."]
				end
				return L["Determines whether or not plugins can be dragged by the mouse."]
			end,
			disabled = false,
			hidden = function(info)
				return #info == 1
			end,
			get = GetTriState,
			set = Set
		},
		panel = panel,
		section = section,
		general = {
			type = 'group',
			order = 1,
			name = L["General"],
			desc = L["General settings."],
			disabled = false,
			hidden = function(info)
				return info[1] ~= "general"
			end,
			args = {
				enable = {
					type = 'toggle',
					order = 1,
					name = L["Enable"],
					desc = L["Determines if this plugin should be shown or not."],
					width = 'half',
					set = function(info, value)
						Set(info, value)
						if value then
							local id = GetPluginLocation(_selection)
							if not id then
								addon.SetPluginLocation(_selection)
							end
							if not _object and addon.dataObj[_selection] then
								_object = addon.CreatePlugin(_selection)
							end
						elseif _object then
							_object:SetState()
							_object = nil
						end
					end
				},
				panel = panel,
				section = section
			}
		},
		icon = {
			type = 'group',
			name = L["Icon"],
			desc = L["Icon related settings."],
			args = {
				defaults = {
					type = 'toggle',
					order = 1,
					name = L["Defaults"],
					desc = L["Use defaults for these settings."],
					width = 'half',
					disabled = false,
					arg = { "iconFlip", "iconHide", "iconSize", "iconTrim", "iconVertAdj", "iconZoom" },
					get = GetDefaultStatus
				},
				iconHide = {
					type = 'toggle',
					order = 2,
					name = L["Hide"],
					desc = L["Determines if the icon should be hidden."],
					width = 'half'
				},
				iconSize = {
					type = 'range', isPercent = true,
					order = 3,
					name = L["Size"],
					desc = L["Set the size of the icon."],
					min = 0.2, max = 1, step = 0.01
				},
				iconVertAdj = {
					type = 'range', isPercent = true,
					order = 4,
					name = L["Vertical Adjust"],
					desc = L["Align the icon vertically."],
					min = -1, max = 1, step = 0.01
				},
				iconZoom = {
					type = 'range', isPercent = true,
					order = 5,
					name = L["Zoom"],
					desc = L["Set how much to zoom in on the icon by."],
					min = 0, max = 1, step = 0.01,
					get = function(info)
						return _settings[info[#info]] * 2
					end,
					set = function(info, value)
						_settings[info[#info]] = value * 0.5
						RefreshSettings()
					end
				},
				iconFlip = {
					type = 'toggle',
					order = 6,
					name = L["Flip"],
					desc = L["Determines if the icon should be placed on the far end of the plugin."],
					width = 'half'
				},
				iconTrim = {
					type = 'toggle',
					order = 7,
					name = L["Trim"],
					desc = L["Automatically remove the border from stock icons."],
					width = 'half'
				}
			}
		},
		label = {
			type = 'group',
			name = L["Label"],
			desc = L["Label related settings."],
			disabled = DisableIfDefaultString,
			get = GetString,
			set = SetString,
			args = stringArgs
		},
		suffix = {
			type = 'group',
			name = L["Suffix"],
			desc = L["Suffix related settings."],
			disabled = DisableIfDefaultString,
			hidden = IsLauncher,
			get = GetString,
			set = SetString,
			args = stringArgs
		},
		text = {
			type = 'group',
			name = L["Text"],
			desc = L["Text related settings."],
			disabled = DisableIfDefaultString,
			hidden = IsLauncher,
			get = GetString,
			set = SetString,
			args = stringArgs
		},
		tooltip = {
			type = 'group',
			name = L["Tooltip"],
			desc = L["Tooltip related settings."],
			args = {
				defaults = {
					type = 'toggle',
					order = 1,
					name = L["Defaults"],
					desc = L["Use defaults for these settings."],
					width = 'half',
					disabled = false,
					arg = { "tooltipParameters" , "tooltipScale" },
					get = GetDefaultStatus,
					set = Set
				},
				tooltipParameters = {
					type = 'input', multiline = 5,
					order = 2,
					name = L["Visibility, Parameters"],
					desc = L["Enter parameters that will be evaluated to determine if the tooltip will be shown or hidden.\n\nExample: [combat] hide; show"],
					width = 'full'
				},
				tooltipScale = {
					type = 'range', isPercent = true,
					order = 3,
					name = L["Scale"],
					desc = L["Set the scale of the tooltip.\n\nMay not work for some plugins."],
					min = 0.5, max = 1.5, step = 0.01
				}
			}
		}
	}
}

--[[-----------------------------------------------------------------------------
Panel Options
-------------------------------------------------------------------------------]]
local function HideForNonPanels(info)
	return info[1] == "panels"
end

local allowGlobals = {
	type = 'toggle', tristate = true,
	order = 4,
	name = L["Global"],
	desc = function(info)
		if info[1] == "Panels" then
			return L["Allow a global reference to this panel for compatibility with other addons."]
		end
		return L["Allow global references to panels for compatibility with other addons."]
	end,
	width = 'half',
	disabled = false,
	hidden = HideDualPosition,
	get = GetTriState,
	set = function(info, value)
		Set(info, value)
		if _branch == "Panels" then
			_G[addon.GetPanelName(_selection)] = value and _object or nil
		else
			local panels, GetPanelName = addon.panels, addon.GetPanelName
			for id, settings in pairs_iter, addon.settings.panels, nil do
				_G[GetPanelName(id)] = value and panels[id] or nil
			end
		end
	end
}

local newPanel = {
	type = 'execute',
	order = 1,
	name = L["Create New Panel"],
	desc = L["Create a new panel and switch to it's options."],
	disabled = false,
	hidden = HideDualPosition,
	func = function()
		addon.PanelList:Select(addon.CreatePanel().id)
		addon.UpdatePanelList()
		ConfigFrames[1]()
	end
}

local rightClickConfig = {
	type = 'toggle', tristate = true,
	order = 3,
	name = L["Config"],
	desc = function(info)
		if info[1] == "Panels" then
			return L["Determines if this panel will open it's configuration panel on a right click."]
		end
		return L["Determines if panels will open their configuration panel on a right click."]
	end,
	width = 'half',
	disabled = false,
	hidden = HideDualPosition,
	get = GetTriState,
	set = Set
}

panelOptions = {																-- Declared local earlier
	type = 'group',
	order = -1,
	name = L["Panel Options"],
	desc = L["Set the default behavior for panels."],
	disabled = DisableIfDefault,
	hidden = function(info)
		return info[#info] == "plugins"
	end,
	get = Get,
	set = SetWithRefresh,
	args = {
		newPanel = newPanel,
		allowGlobals = allowGlobals,
		rightClickConfig = rightClickConfig,
		general = {
			type = 'group',
			order = 1,
			name = L["General"],
			desc = L["General settings."],
			disabled = false,
			hidden = HideForNonPanels,
			args = {
				newPanel = newPanel,
				enable = {
					type = 'toggle',
					order = 2,
					name = L["Enable"],
					desc = L["Determines if this panel is active or not."],
					width = 'half',
					disabled = false,
					set = function(info, value)
						Set(info, value)
						if value then
							_object = addon.CreatePanel(_selection)
						elseif _object then
							_object:Recycle()
							_object = nil
						end
					end
				},
				allowGlobals = allowGlobals,
				rightClickConfig = rightClickConfig
			}
		},
		bg = {
			type = 'group',
			name = L["Background"],
			desc = L["Background related settings."],
			args = {
				defaults = {
					type = 'toggle',
					order = 1,
					name = L["Defaults"],
					desc = L["Use defaults for these settings."],
					width = 'half',
					disabled = false,
					arg = { "bgColorA", "bgColorB", "bgColorG", "bgColorR", "bgInset", "bgTexture" },
					get = GetDefaultStatus
				},
				bgColor = {
					type = 'color', hasAlpha = true,
					order = 2,
					name = L["Color"],
					desc = L["Change the color and transparency of the background."],
					width = 'half',
					disabled = DisableIfDefaultColor,
					get = GetColor,
					set = SetColor
				},
				bgTexture = {
					type = 'select', control = 'LSM30_Statusbar',
					order = 3,
					name = L["Texture"],
					desc = L["Choose a texture to use for the background."],
					values = AceGUIWidgetLSMlists.statusbar
				},
				bgInset = {
					type = 'range',
					order = 4,
					name = L["Inset"],
					desc = L["Set the distance inside the panel before the background begins."],
					min = -1, max = 8, step = 1
				}
			}
		},
		border = {
			type = 'group',
			name = L["Border"],
			desc = L["Border related settings."],
			args = {
				defaults = {
					type = 'toggle',
					order = 1,
					name = L["Defaults"],
					desc = L["Use defaults for these settings."],
					width = 'half',
					disabled = false,
					arg = { "borderColorA", "borderColorB", "borderColorG", "borderColorR", "borderSize", "borderTexture" },
					get = GetDefaultStatus
				},
				borderColor = {
					type = 'color', hasAlpha = true,
					order = 2,
					name = L["Color"],
					desc = L["Change the color and transparency of the border."],
					width = 'half',
					disabled = DisableIfDefaultColor,
					get = GetColor,
					set = SetColor
				},
				borderTexture = {
					type = 'select', control = 'LSM30_Border',
					order = 3,
					name = L["Texture"],
					desc = L["Choose a texture to use for the border."],
					values = AceGUIWidgetLSMlists.border
				},
				borderSize = {
					type = 'range',
					order = 4,
					name = L["Size"],
					desc = L["Set how thick the border will be."],
					min = 1, max = 16, step = 1
				}
			}
		},
		overlay = {
			type = 'group',
			name = L["Overlay"],
			desc = L["Overlay related settings."],
			args = {
				defaults = {
					type = 'toggle',
					order = 1,
					name = L["Defaults"],
					desc = L["Use defaults for these settings."],
					width = 'half',
					disabled = false,
					arg = { "overlayColorA", "overlayColorB", "overlayColorG", "overlayColorR", "overlayFlip", "overlayFlop", "overlayTexture" },
					get = GetDefaultStatus
				},
				overlayColor = {
					type = 'color', hasAlpha = true,
					order = 2,
					name = L["Color"],
					desc = L["Change the color and transparency of the overlay."],
					width = 'half',
					disabled = DisableIfDefaultColor,
					get = GetColor,
					set = SetColor
				},
				overlayTexture = {
					type = 'select', control = 'LSM30_Statusbar_Overlay',
					order = 3,
					name = L["Texture"],
					desc = L["Choose a texture to apply as an overlay to the panel."],
					values = AceGUIWidgetLSMlists.statusbar_overlay
				},
				overlayFlip = {
					type = 'toggle',
					order = 4,
					name = L["Flip"],
					desc = L["Reverse the texture horizontally."],
					width = 'half'
				},
				overlayFlop = {
					type = 'toggle',
					order = 5,
					name = L["Flop"],
					desc = L["Reverse the texture vertically."],
					width = 'half'
				}
			}
		},
		position = {
			type = 'group',
			name = L["Position"],
			desc = L["Position related settings."],
			args= {
				reset = {
					type = 'execute',
					order = 1,
					name = L["Reset Position"],
					desc = L["Reset position to the current anchor."],
					disabled = false,
					hidden = HideForNonPanels,
					func = function(info)
						if _object then
							_object:SetOffset(0, 0)
						else
							_settings.offsetX, _settings.offsetY = 0, 0
						end
					end
				},
				lockPanel = {
					type = 'toggle', tristate = true,
					order = 2,
					name = L["Lock"],
					desc = function(info)
						if info[1] == "Panels" then
							return L["Determines whether or not this panel can be dragged by the mouse."]
						end
						return L["Determines whether or not panels can be dragged by the mouse."]
					end,
					width = 'half',
					disabled = false,
					get = GetTriState,
					set = function(info, value)
						Set(info, value)
						if _branch == "Panels" then
							if _object then
								_object[value and "Lock" or "Unlock"](_object)
							end
						else
							addon:AllPanels(value and "Lock" or "Unlock")
						end
					end
				},
				defaults = {
					type = 'toggle',
					order = 3,
					name = L["Defaults"],
					desc = L["Use defaults for these settings."],
					width = 'half',
					disabled = false,
					arg = { "anchor", "level", "moveBlizzard", "screenClamp", "strata" },
					get = GetDefaultStatus
				},
				anchor = {
					type = 'select',
					order = 4,
					name = L["Anchor"],
					desc = L["Choose the screen region for positioning to be relative to."],
					values = LibStub('LibDisplayAssist-1.3').AnchorPoints
				},
				screenClamp = {
					type = 'range',
					order = 5,
					name = L["Screen Clamp"],
					desc = L["Set how much off-screen movement to allow."],
					min = 0, max = 5, step = 1
				},
				strata = {
					type = 'select',
					order = 6,
					name = L["Strata"],
					desc = L["Set the frame strata layer."],
					values = LibStub('LibDisplayAssist-1.3').StrataLayers
				},
				level = {
					type = 'range',
					order = 7,
					name = L["Level"],
					desc = L["Set the frame level."],
					min = 1, max = 127, step = 1
				},
				moveBlizzard = {
					type = 'toggle',
					order = 8,
					name = L["Move Blizzard Frames"],
					desc = L["Determines if the default Blizzard frames should be moved."]
				}
			}
		},
		size = {
			type = 'group',
			name = L["Size"],
			desc = L["Size related settings."],
			args= {
				defaults = {
					type = 'toggle',
					order = 1,
					name = L["Defaults"],
					desc = L["Use defaults for these settings."],
					disabled = false,
					arg = { "height", "width" },
					get = GetDefaultStatus
				},
				height = {
					type = 'range',
					order = 2,
					name = L["Height"],
					desc = L["Set the height."],
					min = MIN_HEIGHT, max = MAX_HEIGHT, step = 0.01,
					get = function(info)
						return _settings[info[#info]] * RESOLUTION_HEIGHT
					end,
					set = function(info, value)
						_settings[info[#info]] = max(min(value, MAX_HEIGHT), MIN_HEIGHT) / RESOLUTION_HEIGHT
						RefreshSettings()
					end
				},
				width = {
					type = 'range',
					order = 3,
					name = L["Width"],
					desc = L["Set the width."],
					min = MIN_WIDTH, max = MAX_WIDTH, step = 0.01,
					get = function(info)
						return _settings[info[#info]] * RESOLUTION_WIDTH
					end,
					set = function(info, value)
						_settings[info[#info]] = max(min(value, MAX_WIDTH), MIN_WIDTH) / RESOLUTION_WIDTH
						RefreshSettings()
					end
				}
			}
		},
		spacing = {
			type = 'group',
			name = L["Spacing"],
			desc = L["Spacing related settings."],
			args= {
				defaults = {
					type = 'toggle',
					order = 1,
					name = L["Defaults"],
					desc = L["Use defaults for these settings."],
					disabled = false,
					arg = { "spacingCenter", "spacingLeft", "spacingLeftEdge", "spacingRight", "spacingRightEdge" },
					get = GetDefaultStatus
				},
				spacingLeftEdge = {
					type = 'range', isPercent = true,
					order = 2,
					name = L["Left Edge"],
					desc = L["Set how much distance to place between the left panel edge and the first left-side plugin."],
					min = 0, max = 3, step = 0.01
				},
				spacingRightEdge = {
					type = 'range', isPercent = true,
					order = 3,
					name = L["Right Edge"],
					desc = L["Set how much distance to place between the right panel edge and the first right-side plugin."],
					min = 0, max = 3, step = 0.01
				},
				spacingCenter = {
					type = 'range', isPercent = true,
					order = 4,
					name = L["Center Plugins"],
					desc = L["Set how much distance to place between the center plugins."],
					min = 0, max = 3, step = 0.01
				},
				spacingLeft = {
					type = 'range', isPercent = true,
					order = 5,
					name = L["Left Plugins"],
					desc = L["Set how much distance to place between the left-side plugins."],
					min = 0, max = 3, step = 0.01
				},
				spacingRight = {
					type = 'range', isPercent = true,
					order = 6,
					name = L["Right Plugins"],
					desc = L["Set how much distance to place between the right-side plugins."],
					min = 0, max = 3, step = 0.01
				}
			}
		},
		alpha = {
			type = 'group',
			name = L["Visibility"],
			desc = L["Visibility related settings."],
			args= {
				defaults = {
					type = 'toggle',
					order = 1,
					name = L["Defaults"],
					desc = L["Use defaults for these settings."],
					disabled = false,
					arg = { "alphaMouse", "alphaNormal", "alphaParameters" },
					get = GetDefaultStatus
				},
				alphaNormal = {
					type = 'range',
					order = 2,
					name = L["Alpha, Base"],
					desc = L["Set the base alpha level to use for the panel."],
					min = 0, max = 1, step = 0.01
				},
				alphaParameters = {
					type = 'input', multiline = 5,
					order = 3,
					name = L["Alpha, Parameters"],
					desc = L["Enter parameters that will be evaluated to set the alpha level of the panel, falling back to the base alpha as needed.\n\nExample: [group:raid] 0; [combat] 0.5"],
					width = 'full'
				},
				alphaMouse = {
					type = 'toggle',
					order = 4,
					name = L["Mouse Reveal"],
					desc = L["Determines if the panel should be set to full visibility if it has the focus of the mouse."],
				}
			}
		},
		plugins = pluginOptions
	}
}

--[[-----------------------------------------------------------------------------
Base Options
-------------------------------------------------------------------------------]]
local baseOptions = {
	type = 'group',
	get = Get,
	set = Set,
	args = {
		general = {
			type = 'group',
			name = L["General"],
			desc = L["General settings."],
			args = {
				hideErrors = {
					type = 'toggle',
					order = 1,
					name = L["Hide Errors"],
					desc = L["Suppress errors generated by plugins."]
				},
				scaleSideBar = {
					type = 'range',
					order = 2,
					name = L["Side Bar Scale"],
					desc = L["Set the scale of the panel and plugin selection window."],
					min = 0.5, max = 1, step = 0.01,
					set = function(info, value)
						Set(info, value)
						addon.SideBar:ShowScale(value)
					end
				}
			}
		},
		panels = panelOptions,
		plugins = pluginOptions
	}
}

--[[-----------------------------------------------------------------------------
Global to addon
-------------------------------------------------------------------------------]]
function addon.UpdateConfigVariables()
	if addon.CONFIG_IS_OPEN == ConfigFrames[2] then
		_selection = addon.PluginList.selection
		_object, _branch, _settings = addon.plugins[_selection], "Plugins", addon.settings.plugins[_selection]
	elseif addon.CONFIG_IS_OPEN == ConfigFrames[1] then
		_selection = addon.PanelList.selection 
		_object, _branch, _settings = addon.panels[_selection], "Panels", addon.settings.panels[_selection]
	else
		_object, _branch, _selection, _settings = nil, nil, nil, addon.settings
	end
end

--[[-----------------------------------------------------------------------------
Initialize
-------------------------------------------------------------------------------]]
local ACR = LibStub('AceConfigRegistry-3.0')

ACR:RegisterOptionsTable(addonName, baseOptions)
ACR:RegisterOptionsTable(addonName .. "Panels", panelOptions)
ACR:RegisterOptionsTable(addonName .. "Plugins", pluginOptions)
ACR:RegisterOptionsTable(addonName .. "Profiles", LibStub('AceDBOptions-3.0'):GetOptionsTable(addon.db))

ConfigFrames[0]:AssignOptions(addonName)
ConfigFrames[1]:AssignOptions(addonName .. "Panels")
ConfigFrames[2]:AssignOptions(addonName .. "Plugins")
ConfigFrames[3]:AssignOptions(addonName .. "Profiles")

ConfigFrames[0]:SetDesc(L["These options allow you to change the appearance and behavior of %s."]:format(addonName))
ConfigFrames[1]:SetDesc(L["These options allow you to change the appearance and behavior of each panel individually."])
ConfigFrames[2]:SetDesc(L["These options allow you to change the appearance and behavior of each plugin individually."])

ConfigFrames[0]:SetInfo(L["Version: %s"]:format(GetAddOnMetadata(addonName, 'Version')))

local function OnHide()
	addon.CONFIG_IS_OPEN = false
	addon.SideBar:Hide()
	local frame = GetMouseFocus()
	for index = 1, #addon do
		if addon[index] == frame then
			frame:HideTooltip(true)
			return frame:ShowTooltip()
		end
	end
end

local function OnShow(self)
	addon.CONFIG_IS_OPEN = self
	addon.UpdateConfigVariables()
	if ConfigFrames[1] == self or ConfigFrames[2] == self then
		addon.SideBar:Show()
	end
	local frame = GetMouseFocus()
	for index = 1, #addon do
		if addon[index] == frame then
			return frame:ShowTooltip()
		end
	end
end

for index = 0, #ConfigFrames do
	ConfigFrames[index]:SetScript('OnHide', OnHide)
	ConfigFrames[index]:SetScript('OnShow', OnShow)
end
