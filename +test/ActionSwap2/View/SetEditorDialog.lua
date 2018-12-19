--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local L = LibStub("AceLocale-3.0"):GetLocale("ActionSwap2", true)
local SetEditorDialog = AS2.View.SetEditorDialog

function SetEditorDialog:Create(name, parent)
	assert(name and parent)

	local customFrame = CreateFrame("Frame", nil, nil)

	local options = {
		keywordAddonName = "ActionSwap2-IconKeywords",
		customFrame = customFrame,
		sectionOrder = {
			"MacroIcons",
			"ItemIcons"
		}
	}

	self = self:MixInto(AS2:CreateIconSelectorWindow(name, parent, options))
	self:SetFrameStrata("DIALOG")
	self:SetToplevel(true)

	self.nameText = customFrame:CreateFontString()
	self.nameText:SetFontObject("GameFontHighlightSmall")
	self.nameText:SetText(L["Enter Set Name:"])

	self.aisText = customFrame:CreateFontString()
	self.aisText:SetFontObject("GameFontHighlightSmallLeft")
	self.aisText:SetText(L["AIS_NOTE"])
	self.aisText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	self.chooseIconText = customFrame:CreateFontString()
	self.chooseIconText:SetFontObject("GameFontHighlightSmall")
	self.chooseIconText:SetText(L["Choose an Icon:"])
	
	self.editBox = CreateFrame("EditBox", nil, customFrame, "InputBoxTemplate")
	self.editBox:SetAutoFocus(true)
	self.editBox:SetMaxLetters(16)
	self.editBox:SetFontObject("ChatFontNormal")

	self.nameText:SetPoint("TOPLEFT", 0, 0)
	self.editBox:SetSize(182, 20)
	self.editBox:SetPoint("TOPLEFT", 5, -14)
	local _, _, _, aisEnabled = GetAddOnInfo("AdvancedIconSelector")
	self.aisEnabled = aisEnabled
	if aisEnabled then	-- (AdvancedIconSelector is installed)
		self.chooseIconText:SetPoint("TOPLEFT", 0, -48)
		customFrame:SetHeight(60)
	else		-- (AdvancedIconSelector is not installed)
		self.aisText:SetPoint("TOPLEFT", 0, -40)
		self.chooseIconText:SetPoint("TOPLEFT", 0, -68)
		customFrame:SetHeight(76)
	end

	self.initialWidth = self:GetWidth()
	self:SetSize(self:GetDefaultSize())

	self.iconsFrame:SetScript("BeforeShow", function(iconsFrame)

		-- Do an initial state update before show
		self:UpdateButtonStates()

		-- Clear the search parameter and name.
		self:SetSearchParameter(nil, true)
		self.editBox:SetText(self.name or "")

		-- Find the currently selected item.
		self.iconsFrame:SetSelectionByName(self.icon)

		PlaySound("igCharacterInfoOpen")
	end)

	self.iconsFrame:SetScript("OnHide", function(iconsFrame)
		PlaySound("igMainMenuOptionCheckBoxOn")
	end)

	self.iconsFrame:SetScript("OnSelectedIconChanged", function(iconsFrame)
		_, _, self.icon = iconsFrame:GetIconInfo(iconsFrame:GetSelectedIcon())
		self:UpdateButtonStates()
	end)

	self.editBox:SetScript("OnTextChanged", function(editBox, userInput)
		local text = editBox:GetText()
		if text ~= "" then
			self.name = text
		else
			self.name = nil
		end
		self:UpdateButtonStates()
	end)

	self.editBox:SetScript("OnEscapePressed", function(editBox)
		self.cancelButton:Click()
	end)

	self.editBox:SetScript("OnEnterPressed", function(editBox)
		if self.okButton:IsEnabled() then
			self.okButton:Click()
		end
	end)

	return self
end

function SetEditorDialog:ResetState()
	self.icon = nil
	self.name = nil
end

function SetEditorDialog:GetDefaultSize()
	if self.aisEnabled then
		return self.initialWidth, 384
	else
		return self.initialWidth, 400
	end
end

function SetEditorDialog:UpdateButtonStates()
	if self.icon and self.name then
		self.okButton:Enable()
	else
		self.okButton:Disable()
	end
end

-- Resets the dialogs' state, size, and anchors it to the given window.
function SetEditorDialog:ResetStateAndPosition(anchorWindow)
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", anchorWindow, "TOPRIGHT")
	self:SetSize(self:GetDefaultSize())
	self:ResetState()
end
