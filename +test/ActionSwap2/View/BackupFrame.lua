--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- BackupFrame - the single backup frame is shared among all set list frames.
local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local L = LibStub("AceLocale-3.0"):GetLocale("ActionSwap2", true)
local BackupFrame = AS2.View.BackupFrame
local ListView = AS2.View.ListView
local Widgets = AS2.View.Widgets

function BackupFrame:Create(name, parent)
	assert(name and parent)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:SetWidth(AS2.LIST_ITEM_WIDTH + 64)
	local contentInsets = Widgets:MakeMainFrame(self)

	-- Create the backup list
	self.backupList = ListView:Create(name .. "_BackupList", self)

	-- Create the "Backups:" text
	self.backupsText = self:CreateFontString()
	self.backupsText:SetFontObject("GameFontNormal")
	self.backupsText:SetText(L["Backups:"])

	-- Lay out the frame contents
	self.backupsText:SetPoint("TOP", 0, -(contentInsets.top - 7))

	self.backupList:SetWidth(AS2.LIST_ITEM_WIDTH)
	self.backupList:SetPoint("TOP", self.backupsText, "BOTTOM", 0, -2)
	self.backupList:SetPoint("BOTTOM", self, "BOTTOM", 0, contentInsets.bottom + 5)

	AS2:RegisterMessage(self, "ContextChanged")

	return self
end

-- Anchors the backup frame to the given one.
function BackupFrame:AnchorTo(frame)
	-- Anchor the backup frame to the main one
	self:SetPoint("TOPLEFT", frame, "TOPRIGHT", -10, -10)
	self:SetPoint("BOTTOM", frame, "BOTTOM", -10, 10)
end

-- Sets the context of this frame (which backup set it displays information for)
function BackupFrame:SetContext(backupSet)
	if backupSet ~= self.context then
		self.context = backupSet
		AS2:SendMessage(self, "ContextChanged", self, backupSet)
	end
end

-- Places this frame below the given one
function BackupFrame:PositionBelow(frame)
	Widgets:PositionBelowFrame(self, frame)
end
