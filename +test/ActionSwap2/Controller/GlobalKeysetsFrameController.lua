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
local GlobalKeysetsFrameController = AS2.Controller.GlobalKeysetsFrameController
local UIOperations = AS2.Controller.UIOperations

function GlobalKeysetsFrameController:Create(frame)
	assert(frame)
	self = self:Derive()
	self.frame = frame

	self.keysetListController = AS2.Controller.GlobalKeysetListController:Create(frame.keysetList)
	self.keysetListController:SetContext(AS2.activeModel.globalKeysetList)
	AS2:AddCallback(self.keysetListController, "EditSet", function(self, ...) AS2:SendMessage(self, "EditSet", ...) end, self)	-- (let it pass through to main window)
	AS2:AddCallback(self.keysetListController, "ViewBackups", self.OnViewBackups, self)
	AS2:AddCallback(self.keysetListController, "SetDoubleClicked", self.OnDoubleClickSet, self)

	frame.equipButton:SetScript("OnClick", self.OnClick_EquipButton)
	frame.equipButton.controller = self

	AS2:RegisterMessage(self, "EditSet")	-- (pass-through from list controller to main window)

	return self
end

function GlobalKeysetsFrameController:OnDoubleClickSet(keyset)
	PlaySound("igMainMenuOptionCheckBoxOn")
	AS2:HideDialogs(true)
	if not AS2.activeModel.globalKeysetList:GetActiveKeyset() then
		local dialog = AS2:ShowDialog(AS2.Popups.EQUIP_WARNING, L["keybinding set"], L["keybinding set"])
		if dialog then
			dialog.owner = self
			dialog.keyset = keyset
		end
	else
		UIOperations:EquipGlobalKeyset(keyset)
	end
end

function GlobalKeysetsFrameController.OnClick_EquipButton(button, _, _)
	local self = button.controller
	local keyset = self.keysetListController:GetSelectedItem()
	self:OnDoubleClickSet(keyset)
end

function GlobalKeysetsFrameController:private_EquipWarningPopup_OnAccept(dialog)
	UIOperations:EquipGlobalKeyset(dialog.keyset)
end


-- Called when the "View Backups" button is clicked on a set
function GlobalKeysetsFrameController:OnViewBackups(_, keyset)
	local backupFrame = AS2:CreateBackupFrame(self.frame, self)
	backupFrame:AnchorTo(self.frame)
	backupFrame:SetContext(keyset:GetBackupList())
	backupFrame.owner = self
	backupFrame.keyset = keyset
	backupFrame:Show()
end

-- Called when the user clicks the "New Backup" button on the backup list
function GlobalKeysetsFrameController:OnNewBackup(backupFrame)
	if backupFrame.keyset then
		backupFrame.keyset:CreateManualBackup()
	end
end

-- Called when the user clicks one of the backups on the backup list
function GlobalKeysetsFrameController:OnRestoreBackup(backupFrame, backupEntry)
	assert(backupEntry.time)	-- (if there is no time field, it's not a backup entry... restoring from nil could be dangerous)
	if not backupEntry.keybindingsTable then AS2:Debug(AS2.WARNING, "WARNING: the backup being restored has no keybindings table") end

	if backupFrame.keyset then
		AS2:HideDialogs(true)
		local dialog = AS2:ShowDialog(AS2.Popups.RESTORE_SET, L["keybinding set"], backupFrame.keyset:GetName())
		if dialog then
			dialog.owner = self
			dialog.keyset = backupFrame.keyset
			dialog.backupEntry = backupEntry
		end
	end
end

-- Called when the "Yes" button is clicked in the restore backup popup.
function GlobalKeysetsFrameController:private_RestoreSetPopup_OnAccept(dialog)
	UIOperations:RestoreGlobalKeysetFromBackup(dialog.keyset, dialog.backupEntry)
end
