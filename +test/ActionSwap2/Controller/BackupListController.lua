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
local Action = AS2.Model.Action
local BackupListController = AS2.Controller.BackupListController
local ListControllerBase = AS2.Controller.ListControllerBase
local UIOperations = AS2.Controller.UIOperations

local NEW_BACKUP_PLACEHOLDER = 0	-- (just an item to put into the list to hold the place of the "new backup" button)

function BackupListController:Create(listView)
	assert(listView)
	self = ListControllerBase.Create(self, listView)
	self.items = { }

	AS2:RegisterMessage(self, "NewBackup")
	AS2:RegisterMessage(self, "RestoreBackup")

	return self
end

function BackupListController:SetContext(backupList)
	if self.context then
		AS2:RemoveCallback(self.context, "ContentChanged", self.private_OnContentChanged, self)
		AS2:RemoveCallback(AS2, "SpellsChanged", self.private_OnContentChanged, self)
	end

	self.context = backupList

	if self.context then
		AS2:AddCallback(self.context, "ContentChanged", self.private_OnContentChanged, self)
		AS2:AddCallback(AS2, "SpellsChanged", self.private_OnContentChanged, self)
	end

	self:private_RefreshItems()
	self.listView:Refresh()
end

-- Called by ListView when a new button needs to be created.
function BackupListController:ListView_CreateButton(parent)
	local button = AS2.View.BackupListButton:Create(nil, parent)
	button.owner = self
	button.deleteButton:SetScript("OnClick", self.private_DeleteButton_OnClick)
	button.editButton:SetScript("OnClick", self.private_EditButton_OnClick)
	AS2:AddCallback(button, "MouseEnter", self.protected_Button_OnEnter, self)
	AS2:AddCallback(button, "MouseLeave", self.protected_Button_OnLeave, self)
	return button
end

function BackupListController:private_RefreshItems()
	wipe(self.items)
	if self.context then
		for i = 1, self.context:GetAutomatedBackupCount() do
			tinsert(self.items, {
				backupEntry = self.context:GetAutomatedBackupAt(i),
				automated = true,
				localIndex = i
			})
		end
		for i = 1, self.context:GetManualBackupCount() do
			tinsert(self.items, {
				backupEntry = self.context:GetManualBackupAt(i),
				automated = false,
				localIndex = i
			})
		end
		tinsert(self.items, NEW_BACKUP_PLACEHOLDER)	-- (for ease, just put the new backup button in the list)

		sort(self.items, function(a, b)	-- (less than)
			if a == NEW_BACKUP_PLACEHOLDER and b ~= NEW_BACKUP_PLACEHOLDER then return true end
			if b == NEW_BACKUP_PLACEHOLDER then return false end
			return a.backupEntry.time > b.backupEntry.time	-- (most recent is first, and therefore "less")
		end)
	end
end

-- Returns the number of items in the list.
function BackupListController:ListView_GetItemCount()
	if self.context then
		return #self.items
	else
		return 0
	end
end

-- Updates the given button to display the item at the given list index.
function BackupListController:ListView_UpdateButton(button, index, count)
	assert(button and index and count)
	
	if self.context then
		button.item = self.items[index]

		if self.items[index] == NEW_BACKUP_PLACEHOLDER then
			button:SetDisplay_NewBackup()

		elseif self.items[index] then

			local backupEntry = button.item.backupEntry

			-- Fill in the preview icons (action set)
			local j = 1
			local qcTableCache = self.context:GetDataContext():GetQCTableCache()
			if backupEntry.actionsTable and button.iconCount > 0 then
				local actionsTable = qcTableCache:GetTableAt(backupEntry.actionsTable)
				local slotAssignmentsTable = qcTableCache:GetTableAt(backupEntry.slotAssignmentsTable)
				local buttonSetAtBackup = backupEntry.buttonSetAtBackup
				if actionsTable then
					for i = 1, AS2.NUM_ACTION_SLOTS do
						-- (don't forget about the implicit clip at backup creation!)
						if not slotAssignmentsTable or not buttonSetAtBackup or slotAssignmentsTable:GetValue(i) == buttonSetAtBackup then
							local action = actionsTable:GetValue(i)
							if action then
								local icon = Action:GetIcon(action)
								if icon then
									button:SetIcon(j, icon)
									j = j + 1
									if j > button.iconCount then break end
								end
							end
						end
					end
				end
			end

			-- Fill in any remaining icons
			for j = j, button.iconCount do
				button:SetIcon(j, nil)
			end

			button:SetDisplay_BackupItem(
				button.item.automated,
				backupEntry.time,
				backupEntry.name)
		end

		-- Refresh the mini-buttons in case the mouse is already over the item.
		button:RefreshMiniButtons()

		-- Update the features common to all set list buttons.
		ListControllerBase.ListView_UpdateButton(self, button, index, count, nil)
	end
end

-- Called when the user clicks the button at the given index.
function BackupListController:ListView_OnClickButton(button, index, count)
	if self.items then
		if self.items[index] == NEW_BACKUP_PLACEHOLDER then
			AS2:SendMessage(self, "NewBackup", self)
		elseif index <= count then
			AS2:SendMessage(self, "RestoreBackup", self, self.items[index].backupEntry)
		end
	end
end

-- Called when the list changes, or when the details of an item within the list changes.
function BackupListController:private_OnContentChanged()
	self:private_RefreshItems()
	self.listView:Refresh()
end

-- Called when the "Delete backup" button is clicked.
function BackupListController.private_DeleteButton_OnClick(deleteButton, _, _)
	AS2:HideDialogs(true)
	local button = deleteButton.owner
	local self = button.owner
	if button.item and button.item ~= NEW_BACKUP_PLACEHOLDER then
		local dialog = AS2:ShowDialog(AS2.Popups.DELETE_BACKUP)
		if dialog then dialog.owner = self; dialog.type = button.item.automated and "AUTOMATED" or "MANUAL"; dialog.index = button.item.localIndex end
	end
end

-- Called when the user clicks "Yes" on the "Delete Backup" dialog.
function BackupListController:private_DeleteBackupPopup_OnAccept(dialog)
	UIOperations:RemoveBackup(self.context, dialog.type, dialog.index)
end

-- Called when the "Edit" button is clicked.
function BackupListController.private_EditButton_OnClick(editButton, _, _)
	AS2:HideDialogs(true)
	local button = editButton.owner
	local self = button.owner
	if button.item and button.item ~= NEW_BACKUP_PLACEHOLDER and button.item.backupEntry and not button.item.automated then
		local dialog = AS2:ShowDialog(AS2.Popups.EDIT_BACKUP)
		if dialog then dialog.owner = self; dialog.index = button.item.localIndex end
		dialog.editBox:SetText(button.item.backupEntry.name or "")
		dialog.editBox:HighlightText()
	end
end

-- Called when the user clicks "Okay" on the "Edit Backup" dialog.
function BackupListController:private_EditBackupPopup_OnAccept(dialog)
	UIOperations:SetManualBackupName(self.context, dialog.index, dialog.editBox:GetText())
end

-- Called when the mouse enters a button in the list.
function BackupListController:protected_Button_OnEnter(button)
	if self.context and button.item and button.item ~= NEW_BACKUP_PLACEHOLDER then
		local backupEntry = button.item.backupEntry
		local qcTableCache = self.context:GetDataContext():GetQCTableCache()
		local actionsTable = qcTableCache:GetTableAt(backupEntry.actionsTable)
		local keybindingsTable = qcTableCache:GetTableAt(backupEntry.keybindingsTable)
		local glyphsTable = qcTableCache:GetTableAt(backupEntry.glyphsTable)
		local talentsTable = qcTableCache:GetTableAt(backupEntry.talentsTable)
		
		-- Display an action set preview if there's an actions table or keybindings table
		if actionsTable or keybindingsTable then
			local slotAssignmentsTable = qcTableCache:GetTableAt(backupEntry.slotAssignmentsTable)
			local buttonSetAtBackup = backupEntry.buttonSetAtBackup
			AS2.actionBarPreviewFrame:DisplaySet(actionsTable, keybindingsTable, function(slot)
				-- (don't forget about the implicit clip at backup creation!)
				return not slotAssignmentsTable or not buttonSetAtBackup or slotAssignmentsTable:GetValue(slot) == buttonSetAtBackup
			end)
		elseif glyphsTable then
			local parent = self.listView:GetParent()
			self.previewFrame = AS2:CreateGlyphPreviewFrame(parent, self)
			self.previewFrame:SetDisplay(glyphsTable)

			-- Binding to the ListView doesn't seem to work... bind to the secondary frame instead.
			if parent then
				self.previewFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT")
				self.previewFrame:Show()
			end
		elseif talentsTable then
			local parent = self.listView:GetParent()
			self.previewFrame = AS2:CreateTalentPreviewFrame(parent, self)
			self.previewFrame:SetDisplay(talentsTable)

			-- Binding to the ListView doesn't seem to work... bind to the secondary frame instead.
			if parent then
				self.previewFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT")
				self.previewFrame:Show()
			end
		end

		AS2.actionBarPreviewFrame:Show()
	end
end

-- Called when the mouse leaves a button in the list.
function BackupListController:protected_Button_OnLeave(button)
	AS2.actionBarPreviewFrame:Hide()
	AS2.actionBarPreviewFrame:DisplaySet(nil)	-- (release the textures)
	if self.previewFrame and self.previewFrame.owner == self then
		self.previewFrame:Hide()
		self.previewFrame:SetDisplay(nil)
	end
end
