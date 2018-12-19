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
local BackupListButton = AS2.View.BackupListButton
local ListButtonBase = AS2.View.ListButtonBase
local Widgets = AS2.View.Widgets

function BackupListButton:Create(name, parent)
	assert(parent)
	self = ListButtonBase.Create(self, name, parent)
	self.isMouseOver = false

	self.iconCount = 8

	self.backupTypeText = self:CreateFontString()
	self.backupTypeText:SetFontObject("GameFontWhiteTiny")
	self.backupTypeText:SetPoint("TOPRIGHT", -4, -4)
	self.backupTypeText:SetTextColor(0.5, 0.5, 0.5)

	self.timeText = self:CreateFontString()
	self.timeText:SetFontObject("GameFontWhiteTiny")
	self.timeText:SetPoint("TOPLEFT", 4, -4)
	self.timeText:SetTextColor(0.5, 0.5, 0.5)

	-- (tex coords, size, position come from PaperDollFrame.xml:$parentDeleteButton)
	self.deleteButton = Widgets:CreateSmallIconButton(L["DELETE"], self, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", self.private_UpdateMouseState)
	self.deleteButton.owner = self
	self.deleteButton:SetSize(14, 14)	-- (has a different size than the other buttons)
	self.deleteButton:SetPoint("BOTTOMRIGHT", -2, 2)
	self.deleteButton:Hide()

	self.editButton = Widgets:CreateSmallIconButton(L["EDIT_BACKUP"], self, "Interface\\WorldMap\\GEAR_64GREY", self.private_UpdateMouseState)
	self.editButton.owner = self
	self.editButton:SetSize(16, 16)
	self.editButton:SetPoint("RIGHT", self.deleteButton, "LEFT", -1, 0)
	self.editButton:Hide()

	self.newIcon = self:CreateTexture()
	self.newIcon:SetTexture("Interface\\PaperDollInfoFrame\\Character-Plus")
	self.newIcon:SetSize(36, 36)
	self.newIcon:SetPoint("LEFT", 4, 0)

	-- Create the preview icons
	self.icons = { }
	for i = self.iconCount, 1, -1 do
		self.icons[i] = self:CreateTexture()
		self.icons[i]:SetSize(27 - i * 2, 27 - i * 2)
		self.icons[i]:SetAlpha(1.0 - (i - 1) * (0.9 / self.iconCount))
		self.icons[i]:SetDrawLayer("ARTWORK", 7 - i)
	end

	-- Lay out the preview icons
	for i = 1, self.iconCount do
		if i == 1 then
			self.icons[i]:SetPoint("BOTTOMLEFT", 4, 4)
		else
			self.icons[i]:SetPoint("LEFT", self.icons[i - 1], "RIGHT", -2, 0)
		end
	end

	self.banner = self:CreateTexture(nil, "OVERLAY")
	self.banner:SetTexture("Interface\\FriendsFrame\\PendingFriendNameBG-New")

	self.nameTextHighlight = self:CreateFontString(nil, "BACKGROUND")
	self.nameTextHighlight:SetFontObject("GameFontNormalLeft")
	self.nameTextHighlight:SetTextColor(0.1, 0.5, 0.1)
	self.nameTextHighlight:SetShadowColor(0, 0, 0, 0)	-- (no shadow)

	self.nameText = self:CreateFontString(nil, "OVERLAY")
	self.nameText:SetFontObject("GameFontNormalLeft")

	self.nameTextHighlight:SetPoint("TOPLEFT", self.nameText, -1, 1)

	self.banner:SetPoint("TOP", self.nameText, 0, 2)
	self.banner:SetPoint("LEFT", self, 8, 0)
	self.banner:SetPoint("RIGHT", self, -8, 0)
	self.banner:SetHeight(32)

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
function BackupListButton:RefreshMiniButtons()
	-- (simulate a mouse leave / enter)
	self:private_RealOnLeave()
	self:private_UpdateMouseState()
end

-- Called on enter / exit of a child item to update the enter / exit state of the parent button
function BackupListButton:private_UpdateMouseState()
	local newMouseOver = self:IsMouseOver() and self:IsVisible()
	if newMouseOver and not self.isMouseOver then
		self:private_RealOnEnter()
	end
	if not newMouseOver and self.isMouseOver then
		self:private_RealOnLeave()
	end
end

-- Called when the mouse REALLY enters self (taking children into account)
function BackupListButton:private_RealOnEnter()
	self.isMouseOver = true
	self.highlightBar:Show()
	if self.hasDeleteButton then self.deleteButton:Show() end
	if self.hasEditButton then self.editButton:Show() end
	AS2:SendMessage(self, "MouseEnter", self)
end

-- Called when the mouse REALLY leaves self (taking children into account)
function BackupListButton:private_RealOnLeave()
	self.isMouseOver = false
	self.highlightBar:Hide()
	self.deleteButton:Hide()
	self.editButton:Hide()
	AS2:SendMessage(self, "MouseLeave", self)
end

-- Transforms this button to display "New Backup"
function BackupListButton:SetDisplay_NewBackup()
	self.newIcon:Show()
	self.timeText:SetText(nil)
	self.backupTypeText:SetText(nil)
	self.banner:Hide()
	self.nameText:SetText(L["New Backup"])
	self.nameText:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	self.nameText:ClearAllPoints()
	self.nameText:SetPoint("LEFT", 44, 0)
	self.nameText:Show()
	self.nameTextHighlight:Hide()
	
	self.hasDeleteButton = false
	self.hasEditButton = false

	for i = 1, #self.icons do
		self.icons[i]:Hide()
	end
end

-- Transforms this button to display a backup item
function BackupListButton:SetDisplay_BackupItem(isAutomated, backupTime, backupName)
	self.newIcon:Hide()
	self.timeText:SetText(date("%m/%d/%y %I:%M%p", backupTime))
	self.backupTypeText:SetText(isAutomated and "Automatic" or "Manual")

	if backupName then
		self.nameText:SetText(backupName)
		self.nameText:ClearAllPoints()
		self.nameText:SetPoint("BOTTOMLEFT", 16, 16)
		self.nameText:Show()
		self.nameText:SetTextColor(1, 1, 1)

		self.nameTextHighlight:SetText(backupName)
		self.nameTextHighlight:Show()

		self.banner:Show()
	else
		self.nameText:Hide()
		self.nameTextHighlight:Hide()
		self.banner:Hide()
	end
	
	for i = 1, #self.icons do
		self.icons[i]:Show()
	end
	
	self.hasDeleteButton = true
	self.hasEditButton = not isAutomated
end

-- Sets the icon at the given index.
function BackupListButton:SetIcon(index, icon)
	assert(index >= 1 and index <= self.iconCount)
	self.icons[index]:SetTexture(icon)
end
