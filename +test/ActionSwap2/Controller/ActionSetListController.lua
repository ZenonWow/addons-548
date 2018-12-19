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
local ActionSetListController = AS2.Controller.ActionSetListController
local ButtonSet = AS2.Model.ButtonSet
local SetListControllerBase = AS2.Controller.SetListControllerBase
local UIOperations = AS2.Controller.UIOperations

function ActionSetListController:Create(listView)
	assert(listView)
	self = SetListControllerBase.Create(self, listView, true)

	-- Customize the base controller functionality
	self.GetSetCountFn = ButtonSet.GetActionSetCount
	self.GetSetAtFn = ButtonSet.GetActionSetAt
	self.GetActiveFn = ButtonSet.GetActiveActionSet
	self.NEW_SET_TEXT = L["New Action Set"]
	self.EDIT_SET_TEXT = L["Edit Action Set"]
	self.SET_TYPE_TEXT = L["action set"]
	self.hasBackupsButtons = true
	self.hasSaveButtons = true

	AS2:SetTutorialInfo("TUTORIAL_FIRST_ACTION_SET", self, self.listView, self.listView, 0, 0, self.listView, "TOPRIGHT", 0, -AS2.LIST_ITEM_HEIGHT / 2)
	AS2:SetTutorialInfo("TUTORIAL_SECOND_ACTION_SET", self, self.listView, self.listView, 0, 0, self.listView, "TOPRIGHT", 0, -AS2.LIST_ITEM_HEIGHT / 2)

	return self
end

function ActionSetListController:ListView_UpdateButton(button, index, count)
	SetListControllerBase.ListView_UpdateButton(self, button, index, count)
	if index == count then	-- (the New Set button)
		AS2:SetTutorialInfo("TUTORIAL_FIRST_ACTION_SET", self, self.listView, button, 0, 0, button, "TOPRIGHT", 0, -AS2.LIST_ITEM_HEIGHT / 2 - 2)
		AS2:SetTutorialInfo("TUTORIAL_SECOND_ACTION_SET", self, self.listView, button, 0, 0, button, "TOPRIGHT", 0, -AS2.LIST_ITEM_HEIGHT / 2 - 2)
	end
end

-- Called when the mouse enters a button in the list.
function ActionSetListController:protected_Button_OnEnter(button)
	SetListControllerBase.protected_Button_OnEnter(button)

	if button.set then
		local buttonSet = self.context
		AS2.actionBarPreviewFrame:DisplaySet(button.set:GetActionsTable(), button.set:GetKeybindingsTable(), function(slot)
			local bsList = AS2.activeModel.buttonSetList
			return buttonSet and bsList:GetButtonSetAt(bsList:GetAssignedButtonSetForSlot(slot)) == buttonSet
		end)
		AS2.actionBarPreviewFrame:Show()
	end
end

-- Called when the mouse leaves a button in the list.
function ActionSetListController:protected_Button_OnLeave(button)
	SetListControllerBase.protected_Button_OnLeave(button)

	AS2.actionBarPreviewFrame:Hide()
	AS2.actionBarPreviewFrame:DisplaySet(nil)	-- (release the textures)
end

-- Called by the base controller to create a new set with the given name and icon.
function ActionSetListController:protected_CreateSet(name, icon)
	local actionSet = UIOperations:CreateActionSet(name, self.context, icon)
	local newActionSetCount = self.context:GetActionSetCount()
	
	-- Complete the tutorials in reverse order - completion of one will activate another.
	if newActionSetCount >= 2 then AS2:CompleteTutorial("TUTORIAL_SECOND_ACTION_SET") end
	if newActionSetCount >= 1 then AS2:CompleteTutorial("TUTORIAL_FIRST_ACTION_SET") end
	return actionSet
end

-- Called when the user clicks "Yes" to the save set dialog.
function ActionSetListController:protected_SaveSet(set)
	return UIOperations:SaveActionSet(self.context, set)
end
