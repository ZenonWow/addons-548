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
local GlyphSetsFrameController = AS2.Controller.GlyphSetsFrameController
local UIOperations = AS2.Controller.UIOperations

function GlyphSetsFrameController:Create(frame)
	assert(frame)
	self = self:Derive()
	self.frame = frame

	self.glyphSetListController = AS2.Controller.GlyphSetListController:Create(frame.glyphSetList)
	self.glyphSetListController:SetContext(AS2.activeModel.glyphSetList)
	AS2:AddCallback(self.glyphSetListController, "EditSet", function(self, ...) AS2:SendMessage(self, "EditSet", ...) end, self)	-- (let it pass through to main window)
	AS2:AddCallback(self.glyphSetListController, "ViewBackups", self.OnViewBackups, self)
	AS2:AddCallback(self.glyphSetListController, "SetDoubleClicked", self.OnDoubleClickSet, self)

	frame.equipButton:SetScript("OnClick", self.OnClick_EquipButton)
	frame.equipButton.controller = self

	AS2:RegisterMessage(self, "EditSet")	-- (pass-through from list controller to main window)

	AS2:AddCallback(AS2, "TutorialsChanged", self.TryActivateTutorials, self)
	AS2:SetTutorialInfo("TUTORIAL_EQUIP_GLYPH_SET", self, frame, frame, 0, 0)

	assert(frame:GetScript("OnShow") == nil)
	frame:SetScript("OnShow", function()
		self:TryActivateTutorials()
	end)

	return self
end

function GlyphSetsFrameController:OnDoubleClickSet(glyphSet)
	PlaySound("igMainMenuOptionCheckBoxOn")
	AS2:HideDialogs(true)
	if not AS2.activeModel.glyphSetList:GetActiveGlyphSet() then
		local dialog = AS2:ShowDialog(AS2.Popups.EQUIP_WARNING, L["glyph set"], L["glyph set"])
		if dialog then
			dialog.owner = self
			dialog.glyphSet = glyphSet
		end
	else
		UIOperations:EquipGlyphSet(glyphSet)
	end
end

function GlyphSetsFrameController.OnClick_EquipButton(button, _, _)
	local self = button.controller
	local glyphSet = self.glyphSetListController:GetSelectedItem()
	self:OnDoubleClickSet(glyphSet)
end

function GlyphSetsFrameController:private_EquipWarningPopup_OnAccept(dialog)
	UIOperations:EquipGlyphSet(dialog.glyphSet)
end

-- Called when the "View Backups" button is clicked on a set
function GlyphSetsFrameController:OnViewBackups(_, glyphSet)
	local backupFrame = AS2:CreateBackupFrame(self.frame, self)
	backupFrame:AnchorTo(self.frame)
	backupFrame:SetContext(glyphSet:GetBackupList())
	backupFrame.owner = self
	backupFrame.glyphSet = glyphSet
	backupFrame:Show()
end

-- Called when the user clicks the "New Backup" button on the backup list
function GlyphSetsFrameController:OnNewBackup(backupFrame)
	if backupFrame.glyphSet then
		backupFrame.glyphSet:CreateManualBackup()
	end
end

-- Called when the user clicks one of the backups on the backup list
function GlyphSetsFrameController:OnRestoreBackup(backupFrame, backupEntry)
	assert(backupEntry.time)	-- (if there is no time field, it's not a backup entry... restoring from nil could be dangerous)
	if not backupEntry.glyphsTable then AS2:Debug(AS2.WARNING, "WARNING: the backup being restored has no glyphs table") end

	if backupFrame.glyphSet then
		AS2:HideDialogs(true)
		local dialog = AS2:ShowDialog(AS2.Popups.RESTORE_SET, L["glyph set"], backupFrame.glyphSet:GetName())
		if dialog then
			dialog.owner = self
			dialog.glyphSet = backupFrame.glyphSet
			dialog.backupEntry = backupEntry
		end
	end
end

-- Called when the "Yes" button is clicked in the restore backup popup.
function GlyphSetsFrameController:private_RestoreSetPopup_OnAccept(dialog)
	UIOperations:RestoreGlyphSetFromBackup(dialog.glyphSet, dialog.backupEntry)
end

-- Checks whether any tutorials can be activated.
function GlyphSetsFrameController:TryActivateTutorials()
	AS2:TryActivateTutorial("TUTORIAL_FIRST_GLYPH_SET")
	AS2:TryActivateTutorial("TUTORIAL_SECOND_GLYPH_SET")
	AS2:TryActivateTutorial("TUTORIAL_EQUIP_GLYPH_SET")
end
