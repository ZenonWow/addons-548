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
local ActionButtonManager = AS2.Controller.ActionButtonManager
local ButtonSetListController = AS2.Controller.ButtonSetListController
local SetListControllerBase = AS2.Controller.SetListControllerBase
local UIOperations = AS2.Controller.UIOperations

function ButtonSetListController:Create(listView)
	assert(listView)
	self = SetListControllerBase.Create(self, listView)

	self.GetSetCountFn = AS2.Model.ButtonSetList.GetButtonSetCount
	self.GetSetAtFn = AS2.Model.ButtonSetList.GetButtonSetAt
	self.NEW_SET_TEXT = L["New Button Set"]
	self.EDIT_SET_TEXT = L["Edit Button Set"]
	self.SET_TYPE_TEXT = L["button set"]
	self.selectItemSound = "igCharacterInfoTab"
	self:SetContext(AS2.activeModel.buttonSetList)

	AS2:AddCallback(AS2, "ActionBarPageChanged", self.private_OnActionBarPageChanged, self)

	return self
end

function ButtonSetListController:ListView_OnClickButton(button, index, count)
	SetListControllerBase.ListView_OnClickButton(self, button, index, count)
	if index < count then	-- (not the New Set button)
		AS2:CompleteTutorial("TUTORIAL_FIRST_BUTTON_SET")
	end
end

-- Determines whether a slot should be checked / enabled in the "include buttons" frame.
function ButtonSetListController:IncludeButtonsFrame_GetSlotState(slot)
	assert(slot)
	local assignedButtonSet = AS2.activeModel.buttonSetList:GetButtonSetAt(AS2.activeModel.buttonSetList:GetAssignedButtonSetForSlot(slot))
	local isChecked = self.selectedItem and assignedButtonSet ~= self.selectedItem
	local isEnabled = self.selectedItem and (not assignedButtonSet or assignedButtonSet == self.selectedItem)
	return isChecked, isEnabled
end

-- Called when the button associated with the given slot is clicked.
function ButtonSetListController:IncludeButtonsFrame_OnButtonStateChanged(checked, slot)
	assert(checked ~= nil and slot)
	if self.selectedItem ~= nil then	-- (make sure what is selected actually corresponds to an existing button set, in case something wasn't up to date)
		local selectedIndex = AS2.activeModel.buttonSetList:FindButtonSet(self.selectedItem)
		assert(selectedIndex)
		local assignedIndex = AS2.activeModel.buttonSetList:GetAssignedButtonSetForSlot(slot)
		local newIgnoreState = checked		-- (note: checked = slot is ignored!)

		-- (Note that we aren't allowed to change assignment unless (a) the slot is unassigned or (b) the slot belongs to us already.)
		if newIgnoreState and assignedIndex == selectedIndex then
			AS2.activeModel.buttonSetList:AssignSlotToButtonSet(slot, nil)				-- Ignore the slot.
		elseif not newIgnoreState and assignedIndex == nil then
			AS2.activeModel.buttonSetList:AssignSlotToButtonSet(slot, selectedIndex)	-- Include the slot.
		end
	end

	-- Refresh all button states in case two action buttons share a single slot number.
	AS2.includeButtonsFrame:Refresh()
end

function ButtonSetListController:private_OnActionBarPageChanged()
	if AS2.includeButtonsFrame:IsVisible() then	-- (prevent paging delay when unnecessary)
		-- Bonus buttons may have been shown / hidden due to the page change, so refresh the entire set of buttons.
		ActionButtonManager:Refresh()
		AS2.includeButtonsFrame:Refresh()
		AS2:Debug(AS2.NOTE, "Action bar page changed!")
	end
end

-- Called by the base controller to create a new set with the given name and icon.
function ButtonSetListController:protected_CreateSet(name, icon)
	return UIOperations:CreateButtonSet(name, icon)
end
