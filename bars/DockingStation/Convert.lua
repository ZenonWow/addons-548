local addonName, addon = ...

local format, pairs_iter, pcall, select = string.format, pairs(addon), pcall, select

local function Relocate(table, oldKey, newKey, newTable)
	if table[oldKey] ~= nil then
		if (newTable or table)[newKey] == nil then
			(newTable or table)[newKey] = table[oldKey]
		end
		table[oldKey] = nil
	end
end

local function Update(settings, ConvertProfile, ConvertPanel, ConvertPlugin, UpdatePanels, UpdatePlugins)
	for name, settings in pairs_iter, settings.profiles, nil do
		if settings.plugins then
			if UpdatePlugins then
				UpdatePlugins(settings.plugins, settings)
			end
			for name, settings in pairs_iter, settings.plugins, nil do
				ConvertPlugin(settings, name)
			end
		end
		if settings.panels then
			if UpdatePanels then
				UpdatePanels(settings.panels, settings)
			end
			for id, settings in pairs_iter, settings.panels, nil do
				ConvertPanel(settings, id)
			end
		end
		ConvertProfile(settings, name)
	end
end

local function Void(table, ...)
	for index = 1, select('#', ...) do
		table[select(index, ...)] = nil
	end
end

function addon.Convert(settings)
	local major, minor, revision = tostring(settings.version):match("([0-9]*)%.?([0-9]*)%.?([0-9]*)")
	local version = (tonumber(major) or 0) * 1000000 + (tonumber(minor) or 0) * 1000 + (tonumber(revision) or 0)

	--[[------------------------------------------------------------------------
	Update settings to version 0.3
	--------------------------------------------------------------------------]]
	if version < 3000 then
		local function ConvertPlugin(settings)
			if settings.tooltipDefaults == false then
				if settings.tooltipHideCombat == nil then
					if settings.tooltipHide ~= nil then
						settings.tooltipHideCombat, settings.tooltipHideNoCombat = settings.tooltipHide, settings.tooltipHide
					elseif settings.tooltipRestrict ~= nil then
						settings.tooltipHideCombat, settings.tooltipHideNoCombat = settings.tooltipRestrict, false
					end
				end
				if settings.tooltipNoScale ~= nil then
					settings.tooltipScale = 1
				end
			end
			Void(settings, "tooltipHide", "tooltipNoScale", "tooltipRestrict")
		end

		local function ConvertPanel(settings)
			if settings.template ~= nil then
				local ok, result = pcall(format, settings.template, "$id", "$#")
				if ok then
					settings.template = result
				else
					settings.template = nil
				end
			end
			ConvertPlugin(settings)
		end

		Update(settings, ConvertPanel, ConvertPanel, ConvertPlugin)
	end

	--[[------------------------------------------------------------------------
	Update settings to version 0.4
	--------------------------------------------------------------------------]]
	if version < 4000 then
		local pluginAlias, pluginType = settings.pluginAlias, settings.pluginType
		local function ConvertPlugin(settings, name)
			if name then
				if settings.label ~= name then
					Relocate(settings, 'label', name, pluginAlias)
				end
				Relocate(settings, 'type', name, pluginType)
			end
			if settings.iconDefaults == false then
				settings.iconFlip, settings.iconTrim, settings.iconVertAdj = false, true, 0
			end
			if settings.tooltipHideCombat then
				if settings.tooltipHideNoCombat then
					settings.tooltipParameters = "hide"
				else
					settings.tooltipParameters = "[combat] hide"
				end
			elseif settings.tooltipHideNoCombat then
				settings.tooltipParameters = "[nocombat] hide"
			elseif settings.tooltipDefaults == false then
				settings.tooltipParameters = ""
			end
			Void(settings, "iconDefaults", "labelDefaults", "suffixDefaults", "textDefaults", "tooltipDefaults")
			Void(settings, "labelColorA", "labelColorB", "labelColorG", "labelColorR", "labelEffect", "labelFont", "labelHide", "labelOverride", "labelSize", "labelUseText", "labelVertAdj")
			Void(settings, "suffixColorA", "suffixColorB", "suffixColorG", "suffixColorR", "suffixEffect", "suffixFont", "suffixHide", "suffixOverride", "suffixSize", "suffixUseText", "suffixVertAdj")
			Void(settings, "textColorA", "textColorB", "textColorG", "textColorR", "textEffect", "textFixed", "textFont", "textHide", "textOverride", "textSize", "textVertAdj")
			Void(settings, "tooltipAllowScaling", "tooltipHideCombat", "tooltipHideNoCombat")
		end

		local function ConvertPanel(settings)
			if settings.alphaCombat then
				settings.alphaParameters = "[combat] " .. settings.alphaFaded
			elseif settings.alphaDefaults == false then
				settings.alphaParameters = ""
			end
			Relocate(settings, "bgOverlay", "overlayTexture")
			Relocate(settings, "bgOverlayColorA", "overlayColorA")
			Relocate(settings, "bgOverlayColorB", "overlayColorB")
			Relocate(settings, "bgOverlayColorG", "overlayColorG")
			Relocate(settings, "bgOverlayColorR", "overlayColorR")
			Relocate(settings, "bgOverlayFlip", "overlayFlip")
			Relocate(settings, "bgOverlayFlop", "overlayFlop")
			Void(settings, "alphaDefaults", "appearanceDefaults", "bgDefaults", "borderDefaults", "positionDefaults", "spacingDefaults")
			Void(settings, "alphaCombat", "alphaFaded", "template")
			Void(settings, "spacingCenter", "spacingLeft", "spacingLeftEdge", "spacingRight", "spacingRightEdge")
			ConvertPlugin(settings)
		end

		local function ConvertProfile(settings)
			Void(settings, "centerConfig", "panelOrder", "report")
			ConvertPanel(settings)
		end

		local function UpdatePanels(panels, profile)
			local numPanels = #panels
			for id = numPanels, 1, -1 do
				local settings = panels[id]
				settings.alias = (settings.template or profile.template or "Panel $id"):gsub("$id", id):gsub("$#", numPanels)
				panels[id], panels[GenerateUniqueKey()] = nil, settings
			end
		end

		local configName = addonName .. "_Config"
		local function UpdatePlugins(plugins, profile)
			if plugins[configName] then
				if not plugins[addonName] then
					plugins[addonName] = plugins[configName]
					if profile.panels then
						addon.settings = profile
						local id, section, index = addon.GetPluginLocation(configName)
						if id then
							profile.panels[id][section][index] = addonName
						end
					end
				end
				plugins[configName] = nil
			end
		end

		Update(settings, ConvertProfile, ConvertPanel, ConvertPlugin, UpdatePanels, UpdatePlugins)
	end

	--[[------------------------------------------------------------------------
	Update settings to version 0.4.2
	--------------------------------------------------------------------------]]
	if version < 4002 then
		local function ConvertPlugin(settings)
			if settings.iconZoom and settings.iconZoom < 0 then
				settings.iconZoom = 0
			end
		end
		
		Update(settings, ConvertPlugin, ConvertPlugin, ConvertPlugin)
	end

	--[[------------------------------------------------------------------------
	Update settings to version 0.4.5
	--------------------------------------------------------------------------]]
	if version < 4005 then
		local function ConvertPlugin(settings)
			if settings.labelHide ~= nil then
				settings.labelUseName = false
			end
		end
		
		Update(settings, ConvertPlugin, ConvertPlugin, ConvertPlugin)
	end

	settings.version = GetAddOnMetadata(addonName, 'Version')
end
