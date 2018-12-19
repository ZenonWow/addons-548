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
AIS.EquipmentSetPopup = { }
local EquipmentSetPopup = AIS.EquipmentSetPopup
local L = LibStub("AceLocale-3.0"):GetLocale("AdvancedIconSelector", true)

local replaced = false
local popup

-- Replaces the standard Blizzard equipment set editor popup with one having advanced icon search controls.
function EquipmentSetPopup:ReplaceEquipmentSetPopup()
	if not replaced then
		replaced = true
		
		AIS:Debug("Replaced equipment set popup.")

		local customFrame = CreateFrame("Frame", nil, nil)
		customFrame:SetHeight(60)
	
		local options = {
			customFrame = customFrame,
			headerText = L["Edit Equipment Set"],
			headerWidth = 300,
			sectionOrder = {
				"DynamicIcon",
				"EquipmentIcons",
				"ItemIcons",
				"MacroIcons"
			}
		}

		local oldPopup = _G["GearManagerDialogPopup"]
		assert(oldPopup)
		popup = AIS:CreateIconSelectorWindow("GearManagerDialogPopup", nil, options)
		_G["GearManagerDialogPopup"] = popup

		popup.nameText = customFrame:CreateFontString()
		popup.nameText:SetFontObject("GameFontHighlightSmall")
		popup.nameText:SetText(GEARSETS_POPUP_TEXT)
		popup.nameText:SetPoint("TOPLEFT", 0, 0)

		popup.chooseIconText = customFrame:CreateFontString()
		popup.chooseIconText:SetFontObject("GameFontHighlightSmall")
		popup.chooseIconText:SetText(MACRO_POPUP_CHOOSE_ICON)
		popup.chooseIconText:SetPoint("TOPLEFT", 0, -48)
	
		popup.editBox = CreateFrame("EditBox", nil, customFrame, "InputBoxTemplate")
		popup.editBox:SetAutoFocus(true)
		popup.editBox:SetMaxLetters(16)
		popup.editBox:SetFontObject("ChatFontNormal")
		popup.editBox:SetSize(182, 20)
		popup.editBox:SetPoint("TOPLEFT", 5, -14)

		-- Hook the altered functions
		local OldGetEquipmentSetIconInfo = GetEquipmentSetIconInfo
		_G["RecalculateGearManagerDialogPopup"] = EquipmentSetPopup.RecalculateGearManagerDialogPopup
		_G["GearManagerDialogPopup_Update"] = EquipmentSetPopup.GearManagerDialogPopup_Update
		_G["GetEquipmentSetIconInfo"] = EquipmentSetPopup.GetEquipmentSetIconInfo

		-- Copy the SetSelection function from the old popup.
		popup.SetSelection = oldPopup.SetSelection

		-- (altered version of PaperDollFrame.xml:GearManagerDialogPopup:$parentEditBox:OnTextChanged)
		popup.editBox:SetScript("OnTextChanged", function(self, userInput)
			local text = self:GetText()
			if text ~= "" then
				popup.name = text
			else
				popup.name = nil
			end
			EquipmentSetPopup:GearManagerDialogPopupOkay_Update()
		end)

		-- (altered version of PaperDollFrame.xml:GearManagerDialogPopup:$parentEditBox:OnEscapePressed)
		popup.editBox:SetScript("OnEscapePressed", function(self)
			popup.cancelButton:Click()
		end)

		-- (altered version of PaperDollFrame.xml:GearManagerDialogPopup:$parentEditBox:OnEnterPressed)
		popup.editBox:SetScript("OnEnterPressed", function(self)
			if popup.okButton:IsEnabled() then
				popup.okButton:Click()
			end
		end)
	
		popup.iconsFrame:SetScript("BeforeShow", function(self)

			-- Extract the equipment icons from the Blizzard UI.  It's inefficient, but preferable
			-- to copy and paste, or using all icons and losing the "kind" and "ID" data.
			RefreshEquipmentSetIconInfo()
			local equipmentTextures = { }
			local textures = { }
			local index = 1
			repeat
				local texture = OldGetEquipmentSetIconInfo(index)
				if texture then	-- (skip the first texture, 'cause it's the question mark)
					tinsert(textures, texture)
				end
				index = index + 1
			until not texture

			for i = 2, #textures - AIS:GetNumMacroIcons() - AIS:GetNumItemIcons() do
				tinsert(equipmentTextures, textures[i])
			end

			popup.iconsFrame:ReplaceSection("EquipmentIcons", { count = #equipmentTextures, GetIconInfo = function(index) return index, "Equipment", equipmentTextures[index] end })

			-- Clear the search parameter.
			popup:SetSearchParameter(nil, true)
		end)

		-- (altered version of PaperDollFrame.lua:GearManagerDialogPopup_OnShow)
		local originalWidth = popup:GetWidth()
		popup:SetScript("OnShow", function(self)
			-- Size to match the paper doll frame by default.
			popup:SetPoint("TOPLEFT", _G["PaperDollFrame"], "TOPRIGHT", 0, 0)
			popup:SetPoint("BOTTOM", _G["PaperDollFrame"], "BOTTOM", 0, 0)
			popup:SetWidth(originalWidth)

			GearManagerDialogPopup_OnShow(self)
		end)

		-- (no altering needed)
		popup:SetScript("OnHide", GearManagerDialogPopup_OnHide)
		popup:SetScript("OnOkayClicked", function(...) PlaySound("gsTitleOptionOK"); GearManagerDialogPopupOkay_OnClick(...) end)
		popup:SetScript("OnCancelClicked", function(...) PlaySound("gsTitleOptionOK"); GearManagerDialogPopupCancel_OnClick(...) end)

		-- (altered version of PaperDollFrame.lua:GearSetPopupButton_OnClick)
		popup.iconsFrame:SetScript("OnSelectedIconChanged", function(iconsFrame)
			popup.selectedIcon = popup.iconsFrame:GetSelectedIcon()
			EquipmentSetPopup:GearManagerDialogPopupOkay_Update()
		end)
	end
end

-- (altered version of PaperDollFrame.lua:RecalculateGearManagerDialogPopup)
function EquipmentSetPopup.RecalculateGearManagerDialogPopup(setName, iconTexture)
	if setName and setName ~= "" then
		popup.editBox:SetText(setName)
		popup.editBox:HighlightText()
	else
		popup.editBox:SetText("")
	end

	if iconTexture then
		popup:SetSelection(true, iconTexture)
	else
		popup:SetSelection(false, 1)
	end

	popup.headerText:SetText(popup.isEdit and L["Edit Equipment Set"] or L["New Equipment Set"])

	GearManagerDialogPopup_Update()
end

-- (altered version of PaperDollFrame.lua:GearManagerDialogPopup_Update ()
function EquipmentSetPopup.GearManagerDialogPopup_Update()
	RefreshEquipmentSetIconInfo();

	-- Set the initial selection by either ID or texture, depending on which is set.
	if popup.selectedTexture then	-- (this one seems to take priority in Blizzard UI)
		popup.iconsFrame:SetSelectionByName(gsub(strupper(popup.selectedTexture), "INTERFACE\\ICONS\\", ""))
	elseif popup.selectedIcon then
		popup.iconsFrame:SetSelectedIcon(popup.selectedIcon)
	else
		popup.iconsFrame:SetSelectedIcon(nil)
	end
end

-- (altered version of PaperDollFrame.lua:GearManagerDialogPopupOkay_Update)
function EquipmentSetPopup:GearManagerDialogPopupOkay_Update()
	if popup.selectedIcon and popup.name then
		popup.okButton:Enable()
	else
		popup.okButton:Disable()
	end
end

-- (altered version of PaperDollFrame.lua:GetEquipmentSetIconInfo)
-- This method gives us control of the result texture, which is why we no longer have to stay ID-sync'd with Blizzard's icon frame.
function EquipmentSetPopup.GetEquipmentSetIconInfo(index)
	local _, _, texture = popup.iconsFrame:GetIconInfo(index)
	return texture
end
