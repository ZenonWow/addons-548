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
local GlobalKeysetList = AS2.Model.GlobalKeysetList
local GlobalKeysetListController = AS2.Controller.GlobalKeysetListController
local SetListControllerBase = AS2.Controller.SetListControllerBase
local UIOperations = AS2.Controller.UIOperations

function GlobalKeysetListController:Create(listView)
	assert(listView)
	self = SetListControllerBase.Create(self, listView, true)

	-- Customize the base controller functionality
	self.GetSetCountFn = GlobalKeysetList.GetKeysetCount
	self.GetSetAtFn = GlobalKeysetList.GetKeysetAt
	self.GetActiveFn = GlobalKeysetList.GetActiveKeyset
	self.NEW_SET_TEXT = L["New Keybinding Set"]
	self.EDIT_SET_TEXT = L["Edit Keybinding Set"]
	self.SET_TYPE_TEXT = L["keybinding set"]
	self.hasBackupsButtons = true
	self.hasSaveButtons = true

	return self
end

-- Called when the mouse enters a button in the list.
function GlobalKeysetListController:protected_Button_OnEnter(button)
	SetListControllerBase.protected_Button_OnEnter(button)

	if button.set then
		AS2.actionBarPreviewFrame:DisplaySet(nil, button.set:GetKeybindingsTable(), function(slot)
			local bsList = AS2.activeModel.buttonSetList
			local assignedButtonSet = bsList:GetButtonSetAt(bsList:GetAssignedButtonSetForSlot(slot))
			return not assignedButtonSet or not assignedButtonSet:AreKeybindingsIncluded()
		end)
		AS2.actionBarPreviewFrame:Show()
	end
end

-- Called when the mouse leaves a button in the list.
function GlobalKeysetListController:protected_Button_OnLeave(button)
	SetListControllerBase.protected_Button_OnLeave(button)

	AS2.actionBarPreviewFrame:Hide()
	AS2.actionBarPreviewFrame:DisplaySet(nil)	-- (release the textures)
end

-- Called by the base controller to create a new set with the given name and icon.
function GlobalKeysetListController:protected_CreateSet(name, icon)
	return UIOperations:CreateGlobalKeyset(name, icon)
end

-- Called when the user clicks "Yes" to the save set dialog.
function GlobalKeysetListController:protected_SaveSet(set)
	return UIOperations:SaveGlobalKeyset(set)
end
