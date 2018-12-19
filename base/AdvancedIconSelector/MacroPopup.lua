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

local AIS = AdvancedIconSelector
AIS.MacroPopup = { }
local MacroPopup = AIS.MacroPopup
local L = LibStub("AceLocale-3.0"):GetLocale("AdvancedIconSelector", true)

local replaced = false
local popup

-- Replaces the standard Blizzard macro popup with one having advanced icon search controls.
function MacroPopup:ReplaceMacroPopup()
	if not replaced then
		replaced = true

		AIS:Debug("Replaced macro popup.")
	
		local customFrame = CreateFrame("Frame", nil, nil)
		customFrame:SetHeight(60)
	
		local options = {
			customFrame = customFrame,
			headerText = L["Edit Macro"],
			showDynamicText = true,
			sectionOrder = {
				"DynamicIcon",
				"SpellIcons",
				"MacroIcons",
				"ItemIcons"
			}
		}

		assert(_G["MacroPopupFrame"])
		popup = AIS:CreateIconSelectorWindow("MacroPopupFrame", nil, options)
		_G["MacroPopupFrame"] = popup

		popup.nameText = customFrame:CreateFontString()
		popup.nameText:SetFontObject("GameFontHighlightSmall")
		popup.nameText:SetText(MACRO_POPUP_TEXT)
		popup.nameText:SetPoint("TOPLEFT", 0, 0)

		popup.chooseIconText = customFrame:CreateFontString()
		popup.chooseIconText:SetFontObject("GameFontHighlightSmall")
		popup.chooseIconText:SetText(MACRO_POPUP_CHOOSE_ICON)
		popup.chooseIconText:SetPoint("TOPLEFT", 0, -48)
	
		popup.editBox = CreateFrame("EditBox", "MacroPopupEditBox", customFrame, "InputBoxTemplate")
		popup.editBox:SetAutoFocus(true)
		popup.editBox:SetMaxLetters(16)
		popup.editBox:SetFontObject("ChatFontNormal")
		popup.editBox:SetSize(182, 20)
		popup.editBox:SetPoint("TOPLEFT", 5, -14)
		_G["MacroPopupEditBox"] = popup.editBox

		-- Hook the altered functions
		local OldGetSpellorMacroIconInfo = GetSpellorMacroIconInfo
		_G["MacroPopupFrame_Update"] = MacroPopup.MacroPopupFrame_Update
		_G["GetSpellorMacroIconInfo"] = MacroPopup.GetSpellorMacroIconInfo

		-- (altered version of Blizzard_MacroUI.xml:MacroPopupFrame:MacroPopupEditBox:OnTextChanged)
		popup.editBox:SetScript("OnTextChanged", function(self, userInput)
			local text = self:GetText()
			if text ~= "" then
				popup.name = text
			else
				popup.name = nil
			end
			MacroPopup:MacroPopupOkayButton_Update()
			MacroFrameSelectedMacroName:SetText(self:GetText())
		end)

		-- (altered version of Blizzard_MacroUI.xml:MacroPopupFrame:MacroPopupEditBox:OnEscapePressed)
		popup.editBox:SetScript("OnEscapePressed", MacroPopupFrame_CancelEdit)

		-- (altered version of Blizzard_MacroUI.xml:MacroPopupFrame:MacroPopupEditBox:OnEnterPressed)
		popup.editBox:SetScript("OnEnterPressed", function(self)
			if popup.okButton:IsEnabled() then
				popup.okButton:Click()
			end
		end)

		popup.iconsFrame:SetScript("BeforeShow", function(self)

			-- Extract the spell icons from the Blizzard UI.  It's inefficient, but preferable
			-- to copy and paste, or using all icons and losing the "kind" and "ID" data.
			RefreshPlayerSpellIconInfo()
			local spellTextures = { }
			local textures = { }
			local index = 1
			repeat
				local texture = OldGetSpellorMacroIconInfo(index)
				if texture then	-- (skip the first texture, 'cause it's the question mark)
					tinsert(textures, texture)
				end
				index = index + 1
			until not texture

			for i = 2, #textures - AIS:GetNumMacroIcons() - AIS:GetNumItemIcons() do
				tinsert(spellTextures, textures[i])
			end

			popup.iconsFrame:ReplaceSection("SpellIcons", { count = #spellTextures, GetIconInfo = function(index) return index, "Spell", spellTextures[index] end })

			-- Clear the search parameter.
			popup:SetSearchParameter(nil, true)
		end)
	
		-- (altered version of Blizzard_MacroUI.lua:MacroPopupFrame_OnShow)
		local originalWidth = popup:GetWidth()
		popup:SetScript("OnShow", function(self)
			-- Size to match the macro frame by default.
			popup:SetPoint("TOPLEFT", _G["MacroFrame"], "TOPRIGHT", 0, 0)
			popup:SetPoint("BOTTOM", _G["MacroFrame"], "BOTTOM", 0, 0)
			popup:SetWidth(originalWidth)
			MacroPopupFrame_OnShow(self)
		end)

		-- (no altering needed)
		popup:SetScript("OnHide", MacroPopupFrame_OnHide)
		popup:SetScript("OnOkayClicked", function(...) PlaySound("gsTitleOptionOK"); MacroPopupOkayButton_OnClick(...) end)
		popup:SetScript("OnCancelClicked", function(...) PlaySound("gsTitleOptionOK"); MacroPopupFrame_CancelEdit(...) end)

		-- (no equivalent function)
		popup.iconsFrame:SetScript("OnSelectedIconChanged", function(iconsFrame)
			popup.selectedIcon = popup.iconsFrame:GetSelectedIcon()
			MacroPopup:MacroPopupOkayButton_Update()
		end)
	end
end

-- (altered version of Blizzard_MacroUI.lua:MacroPopupOkayButton_Update)
function MacroPopup:MacroPopupOkayButton_Update()
	if popup.name and (popup.selectedIcon or popup.mode == "edit") then
		popup.okButton:Enable()
	else
		popup.okButton:Disable()
	end
end

-- (altered version of Blizzard_MacroUI.lua:MacroPopupFrame_Update)
function MacroPopup.MacroPopupFrame_Update()
	if popup.mode == "new" then
		popup.editBox:SetText("")
		popup.headerText:SetText(L["New Macro"])
	elseif popup.mode == "edit" then
		local name, _, _ = GetMacroInfo(MacroFrame.selectedMacro)
		popup.editBox:SetText(name)
		popup.headerText:SetText(L["Edit Macro"])
	end

	-- Set the initial selection by either ID or texture, depending on which is set.
	if popup.selectedIconTexture then	-- (this one seems to take priority in Blizzard UI)
		popup.iconsFrame:SetSelectionByName(gsub(strupper(popup.selectedIconTexture), "INTERFACE\\ICONS\\", ""))
	elseif popup.selectedIcon then
		popup.iconsFrame:SetSelectedIcon(popup.selectedIcon)
	else
		popup.iconsFrame:SetSelectedIcon(nil)
	end
end

-- (altered version of Blizzard_MacroUI.lua:GetSpellorMacroIconInfo)
-- This method gives us control of the result texture, which is why we no longer have to stay ID-sync'd with Blizzard's icon frame.
function MacroPopup.GetSpellorMacroIconInfo(index)
	local _, _, texture = popup.iconsFrame:GetIconInfo(index)
	return texture
end
