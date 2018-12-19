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
local TalentSetsFrameController = AS2.Controller.TalentSetsFrameController
local UIOperations = AS2.Controller.UIOperations

function TalentSetsFrameController:Create(frame)
	assert(frame)
	self = self:Derive()
	self.frame = frame

	self.talentSetListController = AS2.Controller.TalentSetListController:Create(frame.talentSetList)
	self.talentSetListController:SetContext(AS2.activeModel.talentSetList)
	AS2:AddCallback(self.talentSetListController, "EditSet", function(self, ...) AS2:SendMessage(self, "EditSet", ...) end, self)	-- (let it pass through to main window)
	AS2:AddCallback(self.talentSetListController, "ViewBackups", self.OnViewBackups, self)
	AS2:AddCallback(self.talentSetListController, "SetDoubleClicked", self.OnDoubleClickSet, self)

	frame.equipButton:SetScript("OnClick", self.OnClick_EquipButton)
	frame.equipButton.controller = self

	AS2:RegisterMessage(self, "EditSet")	-- (pass-through from list controller to main window)

	return self
end

function TalentSetsFrameController:OnDoubleClickSet(talentSet)
	PlaySound("igMainMenuOptionCheckBoxOn")
	AS2:HideDialogs(true)
	if not AS2.activeModel.talentSetList:GetActiveTalentSet() then
		local dialog = AS2:ShowDialog(AS2.Popups.EQUIP_WARNING, L["talent set"], L["talent set"])
		if dialog then
			dialog.owner = self
			dialog.talentSet = talentSet
		end
	else
		UIOperations:EquipTalentSet(talentSet)
	end
end

function TalentSetsFrameController.OnClick_EquipButton(button, _, _)
	local self = button.controller
	local talentSet = self.talentSetListController:GetSelectedItem()
	self:OnDoubleClickSet(talentSet)
end

function TalentSetsFrameController:private_EquipWarningPopup_OnAccept(dialog)
	UIOperations:EquipTalentSet(dialog.talentSet)
end

-- Called when the "View Backups" button is clicked on a set
function TalentSetsFrameController:OnViewBackups(_, talentSet)
	local backupFrame = AS2:CreateBackupFrame(self.frame, self)
	backupFrame:AnchorTo(self.frame)
	backupFrame:SetContext(talentSet:GetBackupList())
	backupFrame.owner = self
	backupFrame.talentSet = talentSet
	backupFrame:Show()
end

-- Called when the user clicks the "New Backup" button on the backup list
function TalentSetsFrameController:OnNewBackup(backupFrame)
	if backupFrame.talentSet then
		backupFrame.talentSet:CreateManualBackup()
	end
end

-- Called when the user clicks one of the backups on the backup list
function TalentSetsFrameController:OnRestoreBackup(backupFrame, backupEntry)
	assert(backupEntry.time)	-- (if there is no time field, it's not a backup entry... restoring from nil could be dangerous)
	if not backupEntry.talentsTable then AS2:Debug(AS2.WARNING, "WARNING: the backup being restored has no talents table") end

	if backupFrame.talentSet then
		AS2:HideDialogs(true)
		local dialog = AS2:ShowDialog(AS2.Popups.RESTORE_SET, L["talent set"], backupFrame.talentSet:GetName())
		if dialog then
			dialog.owner = self
			dialog.talentSet = backupFrame.talentSet
			dialog.backupEntry = backupEntry
		end
	end
end

-- Called when the "Yes" button is clicked in the restore backup popup.
function TalentSetsFrameController:private_RestoreSetPopup_OnAccept(dialog)
	UIOperations:RestoreTalentSetFromBackup(dialog.talentSet, dialog.backupEntry)
end
