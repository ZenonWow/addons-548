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
local TalentSetList = AS2.Model.TalentSetList
local TalentSetListController = AS2.Controller.TalentSetListController
local SetListControllerBase = AS2.Controller.SetListControllerBase
local UIOperations = AS2.Controller.UIOperations

function TalentSetListController:Create(listView)
	assert(listView)
	self = SetListControllerBase.Create(self, listView, true)

	-- Customize the base controller functionality
	self.GetSetCountFn = TalentSetList.GetTalentSetCount
	self.GetSetAtFn = TalentSetList.GetTalentSetAt
	self.GetActiveFn = TalentSetList.GetActiveTalentSet
	self.NEW_SET_TEXT = L["New Talent Set"]
	self.EDIT_SET_TEXT = L["Edit Talent Set"]
	self.SET_TYPE_TEXT = L["talent set"]
	self.hasBackupsButtons = true
	self.hasSaveButtons = true

	AS2:AddCallback(AS2, "TalentAdded", self.private_OnTalentChanged, self)
	AS2:AddCallback(AS2, "TalentRemoved", self.private_OnTalentChanged, self)

	return self
end

-- Called when the mouse enters a button in the list.
function TalentSetListController:protected_Button_OnEnter(button)
	SetListControllerBase.protected_Button_OnEnter(button)

	if button.set and AS2.mainWindow then
		local parent = AS2.mainWindow.activeSecondaryFrame	-- Binding to the ListView doesn't seem to work... bind to the secondary frame instead.
		if parent then
			self.previewFrame = AS2:CreateTalentPreviewFrame(parent, self)
			self.previewFrame:SetDisplay(button.set:GetTalentsTable())
			self.previewFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT")
			self.previewFrame:Show()
		end
	end
end

-- Called when the mouse leaves a button in the list.
function TalentSetListController:protected_Button_OnLeave(button)
	SetListControllerBase.protected_Button_OnLeave(button)

	if self.previewFrame and self.previewFrame.owner == self then
		self.previewFrame:Hide()
		self.previewFrame:SetDisplay(nil)
	end
end

-- Called when a talent is added or removed.
function TalentSetListController:private_OnTalentChanged(slot)
	if self.previewFrame then
		self.previewFrame:Refresh()
	end
end

-- Called by the base controller to create a new set with the given name and icon.
function TalentSetListController:protected_CreateSet(name, icon)
	local talentSet = UIOperations:CreateTalentSet(name, icon)
	return talentSet
end

-- Called when the user clicks "Yes" to the save set dialog.
function TalentSetListController:protected_SaveSet(set)
	return UIOperations:SaveTalentSet(set)
end
