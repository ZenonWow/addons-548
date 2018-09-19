--[[========================================================================================
      AdvancedIconSelector, a World of Warcraft icon selector replacement with search
      functionality.
      
      Copyright (c) 2011 - 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:
      
      The above copyright notice and this permission notice shall be included in
      all copies or substantial portions of the Software.
      
      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
      THE SOFTWARE.
    ========================================================================================]]

AdvancedIconSelector = LibStub("AceAddon-3.0"):NewAddon("AdvancedIconSelector", "AceConsole-3.0")
local lib = LibStub("LibAdvancedIconSelector-1.0")
if not lib.GetRevision or lib.GetRevision() < 3 then error("You are using an old, incompatible version of LibAdvancedIconSelector-1.0 - please update it!") end
lib:Embed(AdvancedIconSelector)
local L = LibStub("AceLocale-3.0"):GetLocale("AdvancedIconSelector", true)
local AIS = AdvancedIconSelector

local DEBUG = false
function AIS:Debug(...)
	if DEBUG then
		print("|cff00ff00[AIS] [Debug]|r", ...)
	end
end

AIS:Debug("Addon loaded.")

function AIS:OnInitialize()
	-- Register the "icon browser" commands
	AIS:RegisterChatCommand("ais", "OnSlashCommand")
	AIS:RegisterChatCommand("icons", "OnSlashCommand")

	-- In case AddonLoader isn't installed, hook into certain function calls to replace the
	-- standard Blizzard icon selector dialogs with the custom ones.
	hooksecurefunc("CharacterFrame_Expand", function() AIS.EquipmentSetPopup:ReplaceEquipmentSetPopup() end)
	hooksecurefunc("MacroFrame_LoadUI", function() AIS.MacroPopup:ReplaceMacroPopup() end)
	hooksecurefunc("GuildBankFrame_LoadUI", function() AIS.GuildBankPopup:ReplaceGuildBankPopup() end)

	-- (copied from TOC)
	-- Certain addons such as ArkInventory don't ever load the guild bank UI.  Therefore, we must install special hooks.
	if not AIS_EventFrame then
		AIS_EventFrame = CreateFrame("Frame")
		AIS_EventFrame:RegisterEvent("ADDON_LOADED")
		local function f() if ArkInventory and ArkInventory.LISTEN_VAULT_ENTER then hooksecurefunc(ArkInventory, "LISTEN_VAULT_ENTER", AdvancedIconSelector_ReplaceGuildBankPopup) end end
		f()
		AIS_EventFrame:SetScript("OnEvent", function(self,e,a)
			if a == "ArkInventory" then f() end
		end)
	end
end

function AIS:OnSlashCommand(input)
	if not AIS.iconBrowser then
		local options = {
			okayCancel = false,
			visibilityButtons = {
				{ "MacroIcons", L["Macro icons"] },
				{ "ItemIcons", L["Item icons"] }
			}
		}
		AIS.iconBrowser = AIS:CreateIconSelectorWindow("AIS_IconBrowser", nil, options)
		AIS.iconBrowser:SetPoint("CENTER")
	end
	AIS.iconBrowser:Show()
end

-- If your addon doesn't ever load the Guild Bank UI via GuildBankFrame_LoadUI(),
-- you may need to call this function to tell AdvancedIconSelector to replace the
-- guild bank tab icon selector.
function AdvancedIconSelector_ReplaceGuildBankPopup()
	AIS.GuildBankPopup:ReplaceGuildBankPopup()
end
