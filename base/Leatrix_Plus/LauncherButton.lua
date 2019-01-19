----------------------------------------------------------------------
--	Minimap button
----------------------------------------------------------------------

-- Import
local IsShiftKeyDown,IsControlKeyDown = IsShiftKeyDown,IsControlKeyDown
local ActionStatus_DisplayMessage = ActionStatus_DisplayMessage

local _G, _ADDON = LibEnv.UseAddonEnv(...)
-- _ADDON = addon environment/namespace
-- local ADDON_NAME = _ADDON.ADDON_NAME    -- ADDON_NAME = ... = name of addon folder
-- local OptionDesc = _ADDON.OptionDesc


-- Global vars/functions common for all files in this addon. Format also understood by Mikk's FindGlobals script.
local FGDATA = _G.FindGlobals  and  _G.FindGlobals([==[
	-- GLOBALS: ADDON_NAME,OptionDesc,LeaPlusLC,LeaPlusDB
]==])

local LibDBIcon = _G.LibStub('LibDBIcon-1.0')


OptionDesc.ShowMinimapIcon = {
	get = function (desc)
		return  not (_ADDON.LeaPlusDB.minimap and _ADDON.LeaPlusDB.minimap.hide)
	end,
	set = function (desc, value)
		local LeaPlusDB = _ADDON.LeaPlusDB
		LeaPlusDB.minimap = LeaPlusDB.minimap or {}
		LeaPlusDB.minimap.hide = not value or nil
		if  value  then  LibDBIcon:Show(ADDON_NAME)
		else  LibDBIcon:Hide(ADDON_NAME)
		end
	end,
	onLoaded = function (desc)
		LibDBIcon:Register(ADDON_NAME, _ADDON.DataObject, _ADDON.LeaPlusDB.minimap)
	end,
}


local DataObject = {
	type = "launcher",
	icon = "Interface/COMMON/Indicator-Green.png",
	label = "Leatrix Plus",
	OnTooltipShow = function(tooltip)
		if  not tooltip  or  not tooltip.AddLine  then  return  end
		tooltip:AddLine("Leatrix Plus")
		tooltip:AddLine("Left-Click: toggles the options panel")
		tooltip:AddLine("Ctrl+Left-Click: toggles target tracking")
		tooltip:AddLine("Shift+Left-Click: toggles the music")
		tooltip:AddLine("Shift+Ctrl+Left-Click: toggles Zygor addon")
		tooltip:AddLine("Right-Click: toggles error text")
		tooltip:AddLine("Shift+Right-Click: toggles coordinates")
		tooltip:AddLine("Shift+Ctrl+Right-Click: toggles maximised window mode")
	end,
}


function DataObject.OnClick(frame, mouseButton)
	local LeaPlusLC = _ADDON.LeaPlusLC
	-- Prevent options panel from showing if version panel or Blizzard options panel is showing
	-- if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then return end
	if LeaPlusLC["VersionPanel"] and LeaPlusLC["VersionPanel"]:IsShown() then  return LeaPlusLC["VersionPanel"]:Hide()  end
	-- Left button down
	if mouseButton == "LeftButton" then

		-- Control key modifier toggles target tracking
		if IsControlKeyDown() and not IsShiftKeyDown() then
			local GetTrackingInfo,SetTracking = _G.GetTrackingInfo,_G.SetTracking
			for i = 1, _G.GetNumTrackingTypes() do
				local name, texture, active, category = GetTrackingInfo(i)
				if name == _G.MINIMAP_TRACKING_TARGET then
					if active == 1 then
						SetTracking(i, false)
						ActionStatus_DisplayMessage("Target Tracking Disabled", true);
					else
						SetTracking(i, true)
						ActionStatus_DisplayMessage("Target Tracking Enabled", true);
					end
				end
			end
			return
		end

		-- Shift key modifier toggles the music
		if IsShiftKeyDown() and not IsControlKeyDown() then
			_G.Sound_ToggleMusic();
			return
		end

		-- Shift key and control key toggles Zygor addon
		if IsShiftKeyDown() and IsControlKeyDown() then
			LeaPlusLC:ZygorToggle();
			return
		end

		-- No modifier key toggles the options panel
		if LeaPlusLC["PageF"]:IsShown() then
			LeaPlusLC:HideFrames();
		else
			LeaPlusLC:HideFrames();
			LeaPlusLC["PageF"]:Show();
		end
		if LeaPlusLC["OpenPlusAtHome"] == false then
			LeaPlusLC["Page"..LeaPlusLC["LeaStartPage"]]:Show()
		else
			LeaPlusLC["Page0"]:Show();
		end
	end

	-- Right button down
	if mouseButton == "RightButton" then

		-- Control key modifier does nothing (yet)
		if IsControlKeyDown() and not IsShiftKeyDown() then
			return
		end

		-- Shift key modifier toggles coordinates
		if IsShiftKeyDown() and not IsControlKeyDown() then
			if LeaPlusLC["StaticCoordsEn"] then
				if LeaPlusLC["StaticCoords"] then
					LeaPlusLC["StaticCoords"] = false
					ActionStatus_DisplayMessage("Coordinates Disabled", true);
				else
					LeaPlusLC["StaticCoords"] = true
					_G.SetMapToCurrentZone();
					ActionStatus_DisplayMessage("Coordinates Enabled", true);
				end
				-- Run the coordinates refresh function
				LeaPlusLC:RefreshStaticCoords();
				-- Update side panel checkbox if it's showing
				local StaticCoords = _ADDON.StaticCoords
				if StaticCoords:IsShown() then
					StaticCoords:Hide()
					StaticCoords:Show()
				end
			end
			return
		end

		-- Shift key and control key toggles maximised window mode
		if IsShiftKeyDown() and IsControlKeyDown() then
			if _G.GetCVar("gxWindow") == "1" then
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					_G.SetCVar("gxMaximize", tostring(1 - _G.GetCVar("gxMaximize")));
					_G.RestartGx();
				end
			end
			return
		end

		-- No modifier key toggles error text
		if _ADDON.LeaPlusDB["HideErrorFrameText"] then -- Checks global
			if LeaPlusLC["ShowErrorsFlag"] == 1 then 
				LeaPlusLC["ShowErrorsFlag"] = 0
				minibtn:SetNormalTexture("Interface/COMMON/Indicator-Red.png")
				minibtn:SetPushedTexture("Interface/COMMON/Indicator-Red.png")
				minibtn:SetHighlightTexture("Interface/COMMON/Indicator-Red.png")
				ActionStatus_DisplayMessage("Error frame text will be shown", true);
			else
				LeaPlusLC["ShowErrorsFlag"] = 1
				minibtn:SetNormalTexture("Interface/COMMON/Indicator-Green.png")
				minibtn:SetPushedTexture("Interface/COMMON/Indicator-Green.png")
				minibtn:SetHighlightTexture("Interface/COMMON/Indicator-Green.png")
				ActionStatus_DisplayMessage("Error frame text will be hidden", true);
			end
			return
		end
	end

	-- Middle button modifier
	if mouseButton == "MiddleButton" then
		-- Nothing (yet)
	end
end





-- Register launcher dataobject, make into a proxy
_ADDON.DataObject = _G.LibStub("LibDataBroker-1.1"):NewDataObject(ADDON_NAME, DataObject)



