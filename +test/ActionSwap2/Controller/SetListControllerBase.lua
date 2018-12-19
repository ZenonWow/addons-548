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
local ListControllerBase = AS2.Controller.ListControllerBase
local SetListControllerBase = AS2.Controller.SetListControllerBase
local UIOperations = AS2.Controller.UIOperations
local Utilities = AS2.Model.Utilities

function SetListControllerBase:Create(listView)
	assert(listView)
	self = ListControllerBase.Create(self, listView)

	AS2:AddCallback(AS2, "ActivationFinished", self.OnActivationFinished, self)
	AS2:AddCallback(AS2, "AfterActiveSpecChanged", self.AfterActiveSpecChanged, self)

	AS2:RegisterMessage(self, "EditSet")
	AS2:RegisterMessage(self, "ViewBackups")
	AS2:RegisterMessage(self, "SetDoubleClicked")

	return self
end

function SetListControllerBase:OnActivationFinished(kind)	-- MAINTENANCE: May no longer be necessary.
	self.listView:Refresh()
end

function SetListControllerBase:AfterActiveSpecChanged(kind)	-- MAINTENANCE: May no longer be necessary.
	self.listView:Refresh()
end

function SetListControllerBase:SetContext(setList)
	if self.context then
		AS2:RemoveCallback(self.context, "ContentChanged", self.private_OnContentChanged, self)
	end

	self.context = setList

	if self.context then
		AS2:AddCallback(self.context, "ContentChanged", self.private_OnContentChanged, self)
	end

	self.listView:Refresh()
end

-- Called by ListView when a new button needs to be created.
function SetListControllerBase:ListView_CreateButton(parent)
	local button = AS2.View.SetListButton:Create(nil, parent)
	button.owner = self
	button.deleteButton:SetScript("OnClick", self.private_DeleteButton_OnClick)
	button.editButton:SetScript("OnClick", self.private_EditButton_OnClick)
	button.saveButton:SetScript("OnClick", self.private_SaveButton_OnClick)
	button.viewBackupsButton:SetScript("OnClick", self.private_ViewBackupsButton_OnClick)
	button.moveUpButton:SetScript("OnClick", self.private_MoveUpButton_OnClick)
	button.moveDownButton:SetScript("OnClick", self.private_MoveDownButton_OnClick)
	AS2:AddCallback(button, "MouseEnter", self.protected_Button_OnEnter, self)
	AS2:AddCallback(button, "MouseLeave", self.protected_Button_OnLeave, self)
	return button
end

-- Returns the number of items in the list.
function SetListControllerBase:ListView_GetItemCount()
	if self.context then
		return self.GetSetCountFn(self.context) + 1
	else
		return 0
	end
end

-- Updates the given button to display the item at the given list index.
function SetListControllerBase:ListView_UpdateButton(button, index, count)
	assert(button and index and count)
	
	if self.context then
		local set = self.GetSetAtFn(self.context, index)
		button.set = set
		button.index = index

		if index < count and set then
			local active = 0
			if self.GetActiveFn then
				if self.GetActiveFn(self.context) == index then
					active = 1
				elseif self.GetActiveFn(self.context, Utilities:GetOtherSpec()) == index then
					active = 2
				end
			end
			
			button:SetDisplay_SetItem(set:GetName(), set:GetIcon(), active)
			button.hasDeleteButton = true
			button.hasEditButton = true
			button.hasMoveUpButton = true
			button.hasMoveDownButton = true
			button.hasBackupsButton = self.hasBackupsButtons
			button.hasSaveButton = self.hasSaveButtons

		elseif index == count then
			button:SetDisplay_NewSet()
			button.hasDeleteButton = false
			button.hasEditButton = false
			button.hasMoveUpButton = false
			button.hasMoveDownButton = false
			button.hasBackupsButton = false
			button.hasSaveButton = false
		end

		-- Refresh the mini-buttons in case the mouse is already over the item.
		button:RefreshMiniButtons()

		-- Update the features common to all set list buttons.
		ListControllerBase.ListView_UpdateButton(self, button, index, count, set)
	end
end

-- Called when the user clicks the button at the given index.
function SetListControllerBase:ListView_OnClickButton(button, index, count)
	AS2:HideDialogs()
	if index < count then
		PlaySound(self.selectItemSound or "igMainMenuOptionCheckBoxOn")
		self:SetSelectedItem(button.set)
	else	-- "New Set" button
		PlaySound("igCharacterInfoOpen")
		AS2:SendMessage(self, "EditSet", self, nil, self.private_EditSetDialog_OnAccept)
	end
end

-- Called when the user double-clicks the button at the given index.
function SetListControllerBase:ListView_OnDoubleClickButton(button, index, count)
	if index < count then	-- (not the New Set button)
		AS2:SendMessage(self, "SetDoubleClicked", button.set)
	end
end

-- Called when the "Delete Set" button is clicked.
function SetListControllerBase.private_DeleteButton_OnClick(deleteButton, _, _)
	AS2:HideDialogs()

	local button = deleteButton.owner
	local self = button.owner
	if button.set then
		local dialog = AS2:ShowDialog(AS2.Popups.DELETE_SET, self.SET_TYPE_TEXT, button.set:GetName())
		if dialog then dialog.owner = self; dialog.set = button.set end
	end
end

-- Called when the "Overwrite" button is clicked.
function SetListControllerBase.private_SaveButton_OnClick(saveButton, _, _)
	AS2:HideDialogs()

	local button = saveButton.owner
	local self = button.owner
	if button.set then
		local dialog = AS2:ShowDialog(AS2.Popups.SAVE_SET, self.SET_TYPE_TEXT, button.set:GetName())
		if dialog then dialog.owner = self; dialog.set = button.set end
	end
end

-- Called when the "View Backups" button is clicked.
function SetListControllerBase.private_ViewBackupsButton_OnClick(viewBackupsButton, _, _)
	AS2:HideDialogs()

	local button = viewBackupsButton.owner
	local self = button.owner

	self:SetSelectedItem(button.set)
	
	PlaySound("igCharacterInfoOpen")
	AS2:SendMessage(self, "ViewBackups", self, button.set)
	AS2:CompleteTutorial("TUTORIAL_VIEW_BACKUPS")
end

-- Called when the "Edit Set" button is clicked.
function SetListControllerBase.private_EditButton_OnClick(editButton, _, _)
	AS2:HideDialogs()
	local button = editButton.owner
	local self = button.owner
	AS2:SendMessage(self, "EditSet", self, button.set, self.private_EditSetDialog_OnAccept)
end

-- Called when the list changes, or when the details of an item within the list changes.
function SetListControllerBase:private_OnContentChanged()
	self.listView:Refresh()
end

function SetListControllerBase:private_DeleteSetPopup_OnAccept(dialog)
	UIOperations:DeleteSet(self.context, dialog.set)
end

function SetListControllerBase:private_SaveSetPopup_OnAccept(dialog)
	self:protected_SaveSet(dialog.set)
end

function SetListControllerBase.private_MoveUpButton_OnClick(moveUpButton, _, _)
	PlaySound("igMainMenuOptionCheckBoxOn")
	AS2:HideDialogs()
	local button = moveUpButton.owner
	local self = button.owner
	UIOperations:MoveSetUp(self.context, button.index)
end

function SetListControllerBase.private_MoveDownButton_OnClick(moveDownButton, _, _)
	PlaySound("igMainMenuOptionCheckBoxOn")
	AS2:HideDialogs()
	local button = moveDownButton.owner
	local self = button.owner
	UIOperations:MoveSetDown(self.context, button.index)
end

-- Called when the "accept" button is clicked on the edit set dialog.
function SetListControllerBase:private_EditSetDialog_OnAccept(set, name, icon)
	assert(name and icon)
	if set then
		set:SetName(name)
		set:SetIcon(icon)
	else
		self:protected_CreateSet(name, icon)
	end
end

-- Called when the mouse enters a button in the list.
function SetListControllerBase:protected_Button_OnEnter(button) end

-- Called when the mouse leaves a button in the list.
function SetListControllerBase:protected_Button_OnLeave(button) end
