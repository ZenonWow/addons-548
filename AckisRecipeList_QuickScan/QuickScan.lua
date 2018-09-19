-------------------------------------------------------------------------------
-- Localized globals
-------------------------------------------------------------------------------
local _G = getfenv(0)

local table = _G.table

local pairs = _G.pairs

-------------------------------------------------------------------------------
-- Localized Blizzard API
-------------------------------------------------------------------------------
local GetSpellInfo = _G.GetSpellInfo

-------------------------------------------------------------------------------
-- AddOn namespace
-------------------------------------------------------------------------------
local ADDON_NAME, common = ...

local LibStub = _G.LibStub
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local ARL = LibStub("AceAddon-3.0"):GetAddon("Ackis Recipe List")

_G.assert(ARL, "Ackis Recipe List is required.")

local QuickScan = _G.CreateFrame("Frame", "ARL_QuickScan", _G.UIParent)
QuickScan:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		return self[event](self, event, ...)
	end
end)
QuickScan:RegisterEvent("ADDON_LOADED")

local DropDown = _G.CreateFrame("Frame", "ARL_QuickScan_DropDown")
DropDown.displayMode = "MENU"
DropDown.info = {}
DropDown.levelAdjust = 0

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local MINING_NAME = GetSpellInfo(32606)
local SMELTING_NAME = GetSpellInfo(61422)

local VALID_PROFESSIONS = {
	[GetSpellInfo(2259)] = true, -- Alchemy
	[GetSpellInfo(2018)] = true, -- Blacksmithing
	[GetSpellInfo(2550)] = true, -- Cooking
	[GetSpellInfo(7411)] = true, -- Enchanting
	[GetSpellInfo(4036)] = true, -- Engineering
	[GetSpellInfo(746)] = true, -- First Aid
	[GetSpellInfo(2108)] = true, -- Leatherworking
	[SMELTING_NAME] = true, -- Smelting
	[GetSpellInfo(3908)] = true, -- Tailoring
	[GetSpellInfo(25229)] = true, -- Jewelcrafting
	[GetSpellInfo(45357)] = true, -- Inscription
	[GetSpellInfo(53428)] = true, -- Runeforging
}

-------------------------------------------------------------------------------
-- Variables.
-------------------------------------------------------------------------------
local known_professions = {
	["prof1"] = false,
	["prof2"] = false,
	["archaeology"] = false,
	["fishing"] = false,
	["cooking"] = false,
	["firstaid"] = false,
}

-------------------------------------------------------------------------------
-- Main functions
-------------------------------------------------------------------------------
local function ARL_Scan(self, profession, rank)
	_G.CastSpellByName(profession)

	QuickScan.data_obj.text = ("%s: %d"):format(profession, rank)

	if ARL.Frame and ARL.Frame:IsVisible() then
		ARL.Frame:Hide()
	else
		ARL:Scan()
	end
end

function QuickScan.MakeMenu(self, level)
	if not level then
		return
	end
	local info = DropDown.info

	table.wipe(info)

	if level == 1 then
		info.isTitle = true
		info.notCheckable = true
		info.text = _G.TRADE_SKILLS
		_G.UIDropDownMenu_AddButton(info, level)

		-- Blank space in menu
		table.wipe(info)
		info.disabled = true
		info.notCheckable = true
		_G.UIDropDownMenu_AddButton(info, level)

		info.disabled = nil
		info.notCheckable = nil

		for profession, index in pairs(known_professions) do
			if index then
				local name, icon, rank, maxrank, numspells, spelloffset, skillline = _G.GetProfessionInfo(index)

				if name == MINING_NAME then
					name = SMELTING_NAME
				end

				if VALID_PROFESSIONS[name] then
					info.arg1 = name
					info.arg2 = rank
					info.text = ("|T%s:24:24|t %s (%d)"):format(icon, name, rank)
					info.func = ARL_Scan
					info.notCheckable = true
					info.keepShownOnClick = true
					_G.UIDropDownMenu_AddButton(info, level)
				end
			end
		end
	end
end

local function GetAnchor(frame)
	if not frame then
		return "CENTER", _G.UIParent, 0, 0
	end

	local x, y = frame:GetCenter()

	if not x or not y then
		return "TOPLEFT", "BOTTOMLEFT"
	end

	local hhalf = (x > _G.UIParent:GetWidth() * 2 / 3) and "RIGHT" or (x < _G.UIParent:GetWidth() / 3) and "LEFT" or ""
	local vhalf = (y > _G.UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"

	return vhalf .. hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP") .. hhalf
end

-------------------------------------------------------------------------------
-- Event functions
-------------------------------------------------------------------------------
function QuickScan:ADDON_LOADED(event, addon)
	if addon ~= ADDON_NAME then
		return
	end
	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil

	if _G.IsLoggedIn() then
		self:PLAYER_LOGIN()
	else
		self:RegisterEvent("PLAYER_LOGIN")
	end
end

function QuickScan:PLAYER_LOGIN()
	self.data_obj = LDB:NewDataObject(ADDON_NAME, {
		type = "data source",
		label = ADDON_NAME,
		text = _G.TRADESKILLS,
		icon = "Interface\\Icons\\INV_Misc_Note_05",
		OnEnter = function(display, motion)
			local known = known_professions

			known.prof1, known.prof2, known.archaeology, known.fishing, known.cooking, known.firstaid = _G.GetProfessions()

			if DropDown.initialize ~= self.MakeMenu then
				_G.CloseDropDownMenus()
				DropDown.initialize = self.MakeMenu
			end
			local point, relativeTo, relativePoint = GetAnchor(display)

			DropDown.point = point
			DropDown.relativeTo = relativeTo
			DropDown.relativePoint = relativePoint

			-- Only toggle the menu if it isn't already showing.
			local list_frame = _G["DropDownList1"]

			if not list_frame:IsShown() then
				_G.ToggleDropDownMenu(1, nil, DropDown, self:GetName(), 0, 0)
			end
		end,
		-- OnLeave is an empty function because some LDB displays refuse to display a plugin that has an OnEnter but no OnLeave.
		OnLeave = function()
		end,
		OnClick = function(display, button)
			if button ~= "LeftButton" then
				return
			end
			local options_frame = _G.InterfaceOptionsFrame

			if options_frame:IsVisible() then
				options_frame:Hide()
			else
				_G.InterfaceOptionsFrame_OpenToCategory("Ackis Recipe List")
				_G.InterfaceOptionsFrame_OpenToCategory("Ackis Recipe List")
			end
		end,
	})
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end
