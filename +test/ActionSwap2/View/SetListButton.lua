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
local SetListButton = AS2.View.SetListButton
local ListButtonBase = AS2.View.ListButtonBase
local Widgets = AS2.View.Widgets

function SetListButton:Create(name, parent)
	assert(parent)
	self = ListButtonBase.Create(self, name, parent)
	self.isMouseOver = false

	-- (Note: This button template is based largely off of PaperDollFrame.xml:GearSetButtonTemplate)

	-- Create an extra region to hold the move up / down buttons.  We need this region for its enter/leave
	-- handler; otherwise we'd have to write an OnUpdate function.
	self.extraRegion = CreateFrame("Frame", nil, self)
	self.extraRegion:EnableMouse(false)
	self.extraRegion.owner = self
	self.extraRegion:SetScript("OnEnter", function(button, _) button.owner:private_UpdateMouseState() end)
	self.extraRegion:SetScript("OnLeave", function(button, _) button.owner:private_UpdateMouseState() end)

	self.text = self:CreateFontString()
	self.text:SetFontObject("GameFontNormalLeft")
	self.text:SetSize(98, 38)
	self.text:SetPoint("LEFT", 44, 0)

	self.check = self:CreateTexture(nil, "BORDER")
	self.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
	self.check:SetSize(16, 16)
	self.check:SetPoint("RIGHT", -8, 0)
	self.check:Hide()

	self.check2 = self:CreateTexture(nil, "BORDER")
	self.check2:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	self.check2:SetSize(16, 16)
	self.check2:SetPoint("RIGHT", -8, 0)
	self.check2:SetAlpha(0.5)
	self.check2:Hide()

	self.icon = self:CreateTexture()
	self.icon:SetSize(36, 36)
	self.icon:SetPoint("LEFT", 4, 0)

	-- (tex coords, size, position come from PaperDollFrame.xml:$parentDeleteButton)
	self.deleteButton = Widgets:CreateSmallIconButton(L["DELETE"], self, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", self.private_UpdateMouseState)
	self.deleteButton.owner = self
	self.deleteButton:SetSize(14, 14)	-- (has a different size than the other buttons)
	self.deleteButton:SetPoint("BOTTOMRIGHT", -2, 2)
	self.deleteButton:Hide()

	self.editButton = Widgets:CreateSmallIconButton(L["EDIT"], self, "Interface\\WorldMap\\GEAR_64GREY", self.private_UpdateMouseState)
	self.editButton.owner = self
	self.editButton:SetSize(16, 16)
	self.editButton:SetPoint("RIGHT", self.deleteButton, "LEFT", -1, 0)
	self.editButton:Hide()

	self.saveButton = Widgets:CreateSmallIconButton(L["OVERWRITE"], self, "Interface\\BUTTONS\\UI-GuildButton-PublicNote-Up", self.private_UpdateMouseState)
	self.saveButton.owner = self
	self.saveButton:SetSize(16, 16)
	self.saveButton:SetPoint("BOTTOM", self.deleteButton, "TOP", 0, 11)
	self.saveButton:Hide()

	self.viewBackupsButton = Widgets:CreateSmallIconButton(L["VIEW_BACKUPS"], self, "Interface\\AddOns\\ActionSwap2\\Images\\Backups.tga", self.private_UpdateMouseState)
	self.viewBackupsButton.owner = self
	self.viewBackupsButton:SetSize(16, 16)
	self.viewBackupsButton:SetPoint("RIGHT", self.saveButton, "LEFT", 0, 0)
	self.viewBackupsButton:Hide()

	self.moveDownButton = Widgets:CreateSmallIconButton(L["MOVE_DOWN"], self.extraRegion, "Interface\\BUTTONS\\UI-SpellBookIcon-NextPage-Up", self.private_UpdateMouseState)
	self.moveDownButton.owner = self
	self.moveDownButton:SetSize(22, 22)
	self.moveDownButton.texture:SetTexCoord(0, 1, 1, 1, 0, 0, 1, 0)
	self.moveDownButton:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 1, 1)
	self.moveDownButton:Hide()
	
	self.moveUpButton = Widgets:CreateSmallIconButton(L["MOVE_UP"], self.extraRegion, "Interface\\BUTTONS\\UI-SpellBookIcon-NextPage-Up", self.private_UpdateMouseState)
	self.moveUpButton.owner = self
	self.moveUpButton:SetSize(22, 22)
	self.moveUpButton.texture:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1)
	self.moveUpButton:SetPoint("TOPRIGHT", self, "TOPLEFT", 1, -1)
	self.moveUpButton:Hide()

	self.extraRegion:SetPoint("TOPRIGHT", self, "TOPLEFT")
	self.extraRegion:SetPoint("BOTTOM", self, "BOTTOM")
	self.extraRegion:SetPoint("LEFT", self.moveUpButton, "LEFT")

	AS2:RegisterMessage(self, "MouseEnter")
	AS2:RegisterMessage(self, "MouseLeave")

	self:SetScript("OnEnter", function(self, motion)
		self:private_UpdateMouseState()
	end)

	self:SetScript("OnLeave", function(self, motion)
		self:private_UpdateMouseState()
	end)

	return self
end

-- Refreshes the mini-buttons on this button
function SetListButton:RefreshMiniButtons()
	-- (use a dispatcher to avoid a bug where the backup list button gets hidden if it causes a selection change)
	AS2:Dispatch(self.private_RefreshMiniButtonsDispatch, self)
end

function SetListButton:private_RefreshMiniButtonsDispatch()
	-- (simulate a mouse leave / enter)
	self:private_RealOnLeave()
	self:private_UpdateMouseState()
end

-- Called on enter / exit of a child item to update the enter / exit state of the parent button
function SetListButton:private_UpdateMouseState()
	local newMouseOver = (self:IsMouseOver() or self.extraRegion:IsMouseOver()) and self:IsVisible()
	if not newMouseOver and self.isMouseOver then
		self:private_RealOnLeave()
	end
	if newMouseOver and not self.isMouseOver then
		self:private_RealOnEnter()
	end
end

-- Called when the mouse REALLY enters self (taking children into account)
function SetListButton:private_RealOnEnter()
	self.isMouseOver = true
	self.highlightBar:Show()
	if self.hasDeleteButton then self.deleteButton:Show() end
	if self.hasEditButton then self.editButton:Show() end
	if self.hasSaveButton then self.saveButton:Show() end
	if self.hasBackupsButton then self.viewBackupsButton:Show() end
	if self.hasMoveUpButton then self.moveUpButton:Show() end
	if self.hasMoveDownButton then self.moveDownButton:Show() end
	AS2:SendMessage(self, "MouseEnter", self)
end

-- Called when the mouse REALLY leaves self (taking children into account)
function SetListButton:private_RealOnLeave()
	self.isMouseOver = false
	self.highlightBar:Hide()
	self.deleteButton:Hide()
	self.editButton:Hide()
	self.saveButton:Hide()
	self.viewBackupsButton:Hide()
	self.moveUpButton:Hide()
	self.moveDownButton:Hide()
	AS2:SendMessage(self, "MouseLeave", self)
end

-- Transforms this button to display "New Set"
function SetListButton:SetDisplay_NewSet()
	self.icon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus")
	self.text:SetText(L["New Set"])
	self.text:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	self.check:Hide()
	self.check2:Hide()
end

-- Transforms this button to display an item
function SetListButton:SetDisplay_SetItem(name, icon, active)
	self.icon:SetTexture(icon)
	
	self.text:SetText(name)
	self.text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

	if active == 1 then
		self.check:Show()
		self.check2:Hide()
	else
		self.check:Hide()
		if active == 2 then
			self.check2:Show()
		else
			self.check2:Hide()
		end
	end
end
