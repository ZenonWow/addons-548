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
local ButtonSetFrameController = AS2.Controller.ButtonSetFrameController
local UIOperations = AS2.Controller.UIOperations

function ButtonSetFrameController:Create(frame)
	assert(frame)
	self = self:Derive()
	self.frame = frame

	frame.selectButtonsButton:SetScript("OnClick", self.OnClick_SelectButtons)
	frame.selectButtonsButton.controller = self

	frame.includeKeybindingsButton:SetScript("OnClick", self.OnClick_IncludeKeybindings)
	frame.includeKeybindingsButton.controller = self

	frame.selectUnusedButton:SetScript("OnClick", self.OnClick_SelectUnused)
	frame.selectUnusedButton.controller = self

	frame.deselectAllButton:SetScript("OnClick", self.OnClick_DeselectAll)
	frame.deselectAllButton.controller = self

	self.actionSetListController = AS2.Controller.ActionSetListController:Create(frame.actionSetList)
	AS2:AddCallback(self.actionSetListController, "EditSet", function(self, ...) AS2:SendMessage(self, "EditSet", ...) end, self)	-- (let it pass through to main window)
	AS2:AddCallback(self.actionSetListController, "ViewBackups", self.OnViewBackups, self)
	AS2:AddCallback(self.actionSetListController, "SetDoubleClicked", self.OnDoubleClickSet, self)

	AS2:AddCallback(AS2, "TutorialsChanged", self.TryActivateTutorials, self)
	AS2:SetTutorialInfo("TUTORIAL_CLICK_SELECT_BUTTONS", self, frame, frame.selectButtonsButton, 0, 0, frame.selectButtonsButton, "RIGHT")
	AS2:SetTutorialInfo("TUTORIAL_PICK_BUTTONS", self, frame.selectionToolsFrame, frame.selectionToolsFrame, 0, 0)
	AS2:SetTutorialInfo("TUTORIAL_RETURN_FIRST_ACTION_SET", self, frame, frame.equipButton, 0, 0, frame.equipButton, "RIGHT", 0, 0)
	AS2:SetTutorialInfo("TUTORIAL_ACTION_SET_TIPS", self, frame, frame, 0, 0)
	AS2:SetTutorialInfo("TUTORIAL_ACTION_SET_TIPS_2", self, frame, frame, 0, 0)
	AS2:SetTutorialInfo("TUTORIAL_VIEW_BACKUPS", self, frame.actionSetList, frame.actionSetList, 0, 0, frame.actionSetList, "TOPRIGHT", 0, -AS2.LIST_ITEM_HEIGHT / 2)

	assert(frame:GetScript("OnShow") == nil)
	frame:SetScript("OnShow", function()
		self:UpdateButtonStates()
		AS2.includeButtonsFrame:Show()
		self:TryActivateTutorials()
	end)

	frame:SetScript("OnHide", function()
		AS2.includeButtonsFrame:Hide()
		AS2.includeButtonsFrame:EnableEditing(false)
	end)

	frame.equipButton:SetScript("OnClick", self.OnClick_EquipButton)
	frame.equipButton.controller = self

	AS2:RegisterMessage(self, "EditSet")	-- (pass-through from list controller to main window)

	-- Listen for when the button set we're displaying information for changes
	AS2:AddCallback(frame, "ContextChanged", self.OnContextChanged, self)

	return self
end

function ButtonSetFrameController.OnClick_SelectButtons(button, _, _)
	AS2:HideDialogs(true)

	PlaySound("igMainMenuOptionCheckBoxOn")
	local self = button.controller

	-- Toggle the "enable editing" state
	local oldState = AS2.includeButtonsFrame:IsEditingEnabled()
	AS2.includeButtonsFrame:EnableEditing(not oldState)

	self:UpdateButtonStates()

	-- Complete the button-selecting tutorial only after a button has been added to the set.
	local buttonSet = self.frame.context
	local activeTutorial = AS2:GetActiveTutorial()
	if (activeTutorial == "TUTORIAL_CLICK_SELECT_BUTTONS" or activeTutorial == "TUTORIAL_PICK_BUTTONS") and buttonSet and oldState then
		local count = UIOperations:CountSlotsMatchingButtonSet(buttonSet)
		if count > 0 then
			AS2:CompleteTutorial("TUTORIAL_CLICK_SELECT_BUTTONS")
			AS2:CompleteTutorial("TUTORIAL_PICK_BUTTONS")
		end
	end
	self:TryActivateTutorials()	-- switch tutorials, even though the previous one hasn't completed
end

function ButtonSetFrameController.OnClick_IncludeKeybindings(button, _, _)
	AS2:HideDialogs(true)

	PlaySound("igMainMenuOptionCheckBoxOn")
	local self = button.controller
	local buttonSet = self.frame.context
	if not button:GetChecked() then
		local dialog = AS2:ShowDialog(AS2.Popups.DISINCLUDE_WARNING)
		if dialog then
			dialog.owner = self
			dialog.buttonSet = buttonSet
		end
	else
		local buttonSetIndex = AS2.activeModel.buttonSetList:FindButtonSet(buttonSet)
		if buttonSetIndex then
			UIOperations:SetIncludeKeybindings(buttonSetIndex, true)
		end
	end
	self:UpdateButtonStates()
end

function ButtonSetFrameController:private_DisincludeWarningPopup_OnAccept(dialog)
	local buttonSetIndex = AS2.activeModel.buttonSetList:FindButtonSet(dialog.buttonSet)
	if buttonSetIndex then
		UIOperations:SetIncludeKeybindings(buttonSetIndex, false)
	end
	self:UpdateButtonStates()
end

function ButtonSetFrameController:private_DoEquipActionSet(buttonSet, actionSet)
	local previousActionSet = buttonSet:GetActionSetAt(buttonSet:GetActiveActionSet())
	UIOperations:EquipActionSet(buttonSet, actionSet)
	if previousActionSet ~= nil and previousActionSet ~= actionSet then
		AS2:CompleteTutorial("TUTORIAL_RETURN_FIRST_ACTION_SET")
	end
end

function ButtonSetFrameController:OnDoubleClickSet(actionSet)
	PlaySound("igMainMenuOptionCheckBoxOn")
	AS2:HideDialogs(true)
	local buttonSet = self.frame.context
	if not buttonSet:GetActiveActionSet() then
		local dialog = AS2:ShowDialog(AS2.Popups.EQUIP_WARNING, L["action set"], L["action set"])
		if dialog then
			dialog.owner = self
			dialog.buttonSet = buttonSet
			dialog.actionSet = actionSet
		end
	else
		self:private_DoEquipActionSet(buttonSet, actionSet)
	end
end

function ButtonSetFrameController.OnClick_EquipButton(button, _, _)
	local self = button.controller
	local actionSet = self.actionSetListController:GetSelectedItem()
	self:OnDoubleClickSet(actionSet)
end

function ButtonSetFrameController:private_EquipWarningPopup_OnAccept(dialog)
	self:private_DoEquipActionSet(dialog.buttonSet, dialog.actionSet)
end

function ButtonSetFrameController:UpdateButtonStates()
	local editingState = AS2.includeButtonsFrame:IsEditingEnabled()
	if editingState then
		self.frame.selectButtonsButton:SetText(L["Stop Selecting"])
		self.frame.selectionToolsFrame:Show()
	else
		self.frame.selectButtonsButton:SetText(L["Select Buttons..."])
		self.frame.selectionToolsFrame:Hide()
	end
	if self.frame.context then
		self.frame.includeKeybindingsButton:SetChecked(self.frame.context:AreKeybindingsIncluded())
	end
end

-- Called when we need to display information about a different button set
function ButtonSetFrameController:OnContextChanged(_, buttonSet)
	AS2.includeButtonsFrame:EnableEditing(false)
	self:UpdateButtonStates()
	self.actionSetListController:SetContext(buttonSet)
end

-- Called when the "View Backups" button is clicked on an action set
function ButtonSetFrameController:OnViewBackups(_, actionSet)
	local backupFrame = AS2:CreateBackupFrame(self.frame, self)
	backupFrame:AnchorTo(self.frame)
	backupFrame:SetContext(actionSet:GetBackupList())
	backupFrame.owner = self
	backupFrame.actionSet = actionSet
	backupFrame:Show()
end

-- Called when the user clicks the "New Backup" button on the backup list
function ButtonSetFrameController:OnNewBackup(backupFrame)
	if backupFrame.actionSet then
		backupFrame.actionSet:CreateManualBackup()
		AS2:CompleteTutorial("TUTORIAL_CREATE_MANUAL_BACKUP")
	end
end

-- Called when the user clicks one of the backups on the backup list
function ButtonSetFrameController:OnRestoreBackup(backupFrame, backupEntry)
	assert(backupEntry.time)	-- (if there is no time field, it's not a backup entry... restoring from nil could be dangerous)
	if not backupEntry.actionsTable then AS2:Debug(AS2.WARNING, "WARNING: the backup being restored has no actions table") end

	if backupFrame.actionSet then
		AS2:HideDialogs(true)
		local dialog = AS2:ShowDialog(AS2.Popups.RESTORE_SET, L["action set"], backupFrame.actionSet:GetName())
		if dialog then
			dialog.owner = self
			dialog.buttonSet = self.frame.context
			dialog.actionSet = backupFrame.actionSet
			dialog.backupEntry = backupEntry
		end
	end
end

-- Called when the "Yes" button is clicked in the restore backup popup.
function ButtonSetFrameController:private_RestoreSetPopup_OnAccept(dialog)
	UIOperations:RestoreActionSetFromBackup(dialog.buttonSet, dialog.actionSet, dialog.backupEntry)
end

-- Called when the user clicks the "Select Unused" button
function ButtonSetFrameController.OnClick_SelectUnused(button, _, _)
	local self = button.controller
	AS2:HideDialogs(true)
	local dialog = AS2:ShowDialog(AS2.Popups.SELECTALL_CONFIRM)
	if dialog then
		dialog.owner = self
		dialog.buttonSet = self.frame.context
	end
end

-- Called when the "Yes" button is clicked in the "Select Unused" confirmation dialog.
function ButtonSetFrameController:private_SelectAllConfirmPopup_OnAccept(dialog)
	UIOperations:IncludeAllUnusedSlots(dialog.buttonSet)
	AS2.includeButtonsFrame:Refresh()
end

-- Called when the user clicks the "Select None" button
function ButtonSetFrameController.OnClick_DeselectAll(button, _, _)
	local self = button.controller
	AS2:HideDialogs(true)
	local dialog = AS2:ShowDialog(AS2.Popups.SELECTNONE_CONFIRM)
	if dialog then
		dialog.owner = self
		dialog.buttonSet = self.frame.context
	end
end

-- Called when the "Yes" button is clicked in the "Select None" confirmation dialog.
function ButtonSetFrameController:private_SelectNoneConfirmPopup_OnAccept(dialog)
	UIOperations:DisincludeAllSlots(dialog.buttonSet)
	AS2.includeButtonsFrame:Refresh()
end

-- Checks whether any tutorials can be activated.
function ButtonSetFrameController:TryActivateTutorials()
	if AS2.includeButtonsFrame:IsEditingEnabled() then
		AS2:TryActivateTutorial("TUTORIAL_PICK_BUTTONS")
	else
		AS2:TryActivateTutorial("TUTORIAL_CLICK_SELECT_BUTTONS")
	end
	AS2:TryActivateTutorial("TUTORIAL_FIRST_ACTION_SET")
	AS2:TryActivateTutorial("TUTORIAL_SECOND_ACTION_SET")
	AS2:TryActivateTutorial("TUTORIAL_RETURN_FIRST_ACTION_SET")
	AS2:TryActivateTutorial("TUTORIAL_ACTION_SET_TIPS")
	AS2:TryActivateTutorial("TUTORIAL_ACTION_SET_TIPS_2")
	AS2:TryActivateTutorial("TUTORIAL_VIEW_BACKUPS")
end
