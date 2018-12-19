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
local ListView = AS2.View.ListView
local MainWindow = AS2.View.MainWindow
local Widgets = AS2.View.Widgets

function MainWindow:Create(name, parent)
	assert(parent)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:Hide()
	self:SetFrameStrata("HIGH")
	-- MAINTENANCE: Would like to be toplevel on medium strata, but haven't yet found a good way to make it happen without creating problems.
	self:SetFrameLevel(57)	-- (should be higher than max cascade level)
	self:SetToplevel(true)
	self:SetWidth(AS2.LIST_ITEM_WIDTH + 64)
	self:SetHeight(492)
	self:SetMovable(true)
	self:SetClampedToScreen(true)
	self:RegisterForDrag("LeftButton")	-- (needed for moveable)
	self:EnableMouse(true)				-- (needed for moveable)

	local contentInsets = Widgets:MakeMainFrame(self)
	local spacing = 2

	-- Set the header
	self.header = self:CreateTexture()
	self.header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
	self.header:SetWidth(256)
	self.header:SetPoint("TOP", 0, 12)

	self.headerText = self:CreateFontString()
	self.headerText:SetFontObject("GameFontNormal")
	self.headerText:SetPoint("TOP", self.header, "TOP", 0, -14)
	self.headerText:SetText(L["ADDON"])

	-- Create the close button
	self.closeButton = CreateFrame("Button", nil, self, "UIPanelCloseButton")
	self.closeButton:SetPoint("TOPRIGHT", 0, 0)

	-- Create the "Button Sets" text
	self.buttonSetsText = self:CreateFontString()
	self.buttonSetsText:SetFontObject("GameFontNormal")
	self.buttonSetsText:SetText(L["Button sets:"])

	-- Create the button set list
	self.buttonSetList = ListView:Create(name .. "_ButtonSetList", self)

	local makeIcon = function(parent, texture)
		local icon = parent:CreateTexture()
		icon:SetDrawLayer("OVERLAY", 1)
		icon:SetTexture(texture)
		icon:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 1, 1, 1, 1, 0)
		icon:SetSize(36, 36)
		icon:SetPoint("LEFT", 8, 0)
		return icon
	end

	-- Create the "Talent Sets" button
	self.talentSetsButton = Widgets:CreateButton_BigToggleButtonTemplate(name .. "_TalentSetsButton", self)
	self.talentSetsButton.text:SetText(L["Talent sets"])
	self.talentSetsIcon = makeIcon(self.talentSetsButton, "Interface\\Icons\\Ability_DualWield")
	self.talentSetsIcon:SetTexCoord(3/36.0, 1, 3/36, (36-3)/36.0)

	-- Create the "Glyph Sets" button
	self.glyphSetsButton = Widgets:CreateButton_BigToggleButtonTemplate(name .. "_GlyphSetsButton", self)
	self.glyphSetsButton.text:SetText(L["Glyph sets"])
	self.glyphSetsIcon = makeIcon(self.glyphSetsButton, "Interface\\Icons\\INV_Inscription_MajorGlyph20")
	self.glyphSetsIcon:SetTexCoord(3/36.0, 1, 3/36, (36-3)/36.0)

	-- Create the "Global Keysets" button
	self.globalKeysetsButton = Widgets:CreateButton_BigToggleButtonTemplate(name .. "_GlobalKeysetsButton", self)
	self.globalKeysetsButton.text:SetText(L["Keybinding sets"])
	self.globalKeysetsIcon = makeIcon(self.globalKeysetsButton, "Interface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME")
	self.globalKeysetsIcon:SetTexCoord(80/512.0, 160/512.0, 415/512.0, 495/512.0)
	self.globalKeysetsIcon:SetPoint("LEFT", 8, -2)

	-- Layout the items in the window
	self.buttonSetsText:SetPoint("TOP", 0, -contentInsets.top)

	self.globalKeysetsButton:SetHeight(50)
	self.globalKeysetsButton:SetPoint("BOTTOMLEFT", contentInsets.left, contentInsets.bottom)
	self.globalKeysetsButton:SetPoint("RIGHT", self, "RIGHT", -contentInsets.right, 0)

	self.glyphSetsButton:SetHeight(50)
	self.glyphSetsButton:SetPoint("BOTTOMLEFT", self.globalKeysetsButton, "TOPLEFT", 0, 0)
	self.glyphSetsButton:SetPoint("RIGHT", self.globalKeysetsButton, "TOPRIGHT")

	self.talentSetsButton:SetHeight(50)
	self.talentSetsButton:SetPoint("BOTTOMLEFT", self.glyphSetsButton, "TOPLEFT", 0, 0)
	self.talentSetsButton:SetPoint("RIGHT", self.glyphSetsButton, "TOPRIGHT")

	self.buttonSetList:SetWidth(AS2.LIST_ITEM_WIDTH)
	self.buttonSetList:SetPoint("TOP", self.buttonSetsText, "BOTTOM", 0, -spacing)
	self.buttonSetList:SetPoint("BOTTOM", self.talentSetsButton, "TOP", 0, spacing * 2)

	self:SetScript("OnShow", function(self)
		AS2.Controller.ActionButtonManager:Refresh()	-- Find any new action buttons, remove hidden ones
		AS2.includeButtonsFrame:Refresh()				-- Invalidate the "included" button states, since the set of buttons may have changed
		PlaySound("igCharacterInfoOpen")
	end)

	self:SetScript("OnHide", function(self)
		PlaySound("igCharacterInfoClose")

		-- Shouldn't be necessary now that mouse exit code is fixed for set buttons, but just in case, hide the preview frames.
		if AS2.actionBarPreviewFrame then AS2.actionBarPreviewFrame:Hide() end
		if AS2.glyphPreviewFrame then AS2.glyphPreviewFrame:Hide() end
	end)

	self:SetScript("OnMouseDown", function(self, button)
		self:AssistToplevel()
	end)

	self:SetScript("OnDragStart", function(self, button)
		self:StartMoving()
	end)
	
	self:SetScript("OnDragStop", function(self, button)
		self:StopMovingOrSizing()
	end)

	return self
end

-- Activates (shows) the given secondary frame, hiding any previously active one.  Pass nil to hide
-- all secondary frames.
function MainWindow:ActivateSecondaryFrame(frame)
	-- (note: do NOT hide/show the frame too quickly or the list may disappear)
	if self.activeSecondaryFrame and self.activeSecondaryFrame ~= frame then
		AS2:HideDialogs()
		self.activeSecondaryFrame:Hide()
	end
	self.activeSecondaryFrame = frame
	if frame then
		frame:PositionBelow(self)
		frame:Show()
	end
end

-- Deactivates the given secondary frame, but only if it was the active one.
function MainWindow:DeactivateSecondaryFrame(frame)
	if self.activeSecondaryFrame == frame then
		self:ActivateSecondaryFrame(nil)
	end
end

-- Toplevel doesn't cascade our windows correctly; give it some help.
function MainWindow:AssistToplevel(childFrame)
	--[[local targetLevel = self:GetFrameLevel() + 30
	Widgets:PositionAboveFrameLevel(self, targetLevel)]]

	-- Position the secondary frame below us, which will in turn place the backup frame below itself.
	if self.activeSecondaryFrame then self.activeSecondaryFrame:PositionBelow(self) end
end
