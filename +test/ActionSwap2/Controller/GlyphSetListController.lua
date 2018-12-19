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
local GlyphSetList = AS2.Model.GlyphSetList
local GlyphSetListController = AS2.Controller.GlyphSetListController
local SetListControllerBase = AS2.Controller.SetListControllerBase
local UIOperations = AS2.Controller.UIOperations

function GlyphSetListController:Create(listView)
	assert(listView)
	self = SetListControllerBase.Create(self, listView, true)

	-- Customize the base controller functionality
	self.GetSetCountFn = GlyphSetList.GetGlyphSetCount
	self.GetSetAtFn = GlyphSetList.GetGlyphSetAt
	self.GetActiveFn = GlyphSetList.GetActiveGlyphSet
	self.NEW_SET_TEXT = L["New Glyph Set"]
	self.EDIT_SET_TEXT = L["Edit Glyph Set"]
	self.SET_TYPE_TEXT = L["glyph set"]
	self.hasBackupsButtons = true
	self.hasSaveButtons = true

	AS2:AddCallback(AS2, "GlyphAdded", self.private_OnGlyphChanged, self)
	AS2:AddCallback(AS2, "GlyphRemoved", self.private_OnGlyphChanged, self)

	AS2:SetTutorialInfo("TUTORIAL_FIRST_GLYPH_SET", self, self.listView, self.listView, 0, 0, self.listView, "TOPRIGHT", 0, -AS2.LIST_ITEM_HEIGHT / 2)
	AS2:SetTutorialInfo("TUTORIAL_SECOND_GLYPH_SET", self, self.listView, self.listView, 0, 0, self.listView, "TOPRIGHT", 0, -AS2.LIST_ITEM_HEIGHT / 2)

	return self
end

function GlyphSetListController:ListView_UpdateButton(button, index, count)
	SetListControllerBase.ListView_UpdateButton(self, button, index, count)
	if index == count then	-- (the New Set button)
		AS2:SetTutorialInfo("TUTORIAL_FIRST_GLYPH_SET", self, self.listView, button, 0, 0, button, "TOPRIGHT", 0, -AS2.LIST_ITEM_HEIGHT / 2 - 2)
		AS2:SetTutorialInfo("TUTORIAL_SECOND_GLYPH_SET", self, self.listView, button, 0, 0, button, "TOPRIGHT", 0, -AS2.LIST_ITEM_HEIGHT / 2 - 2)
	end
end

-- Called when the mouse enters a button in the list.
function GlyphSetListController:protected_Button_OnEnter(button)
	SetListControllerBase.protected_Button_OnEnter(button)

	if button.set and AS2.mainWindow then
		local parent = AS2.mainWindow.activeSecondaryFrame	-- Binding to the ListView doesn't seem to work... bind to the secondary frame instead.
		if parent then
			self.previewFrame = AS2:CreateGlyphPreviewFrame(parent, self)
			self.previewFrame:SetDisplay(button.set:GetGlyphsTable())
			self.previewFrame:SetPoint("TOPLEFT", parent, "TOPRIGHT")
			self.previewFrame:Show()
		end
	end
end

-- Called when the mouse leaves a button in the list.
function GlyphSetListController:protected_Button_OnLeave(button)
	SetListControllerBase.protected_Button_OnLeave(button)

	if self.previewFrame and self.previewFrame.owner == self then
		self.previewFrame:Hide()
		self.previewFrame:SetDisplay(nil)
	end
end

-- Called when a glyph is added or removed.
function GlyphSetListController:private_OnGlyphChanged(slot)
	if self.previewFrame then
		self.previewFrame:Refresh()
	end
end

-- Called by the base controller to create a new set with the given name and icon.
function GlyphSetListController:protected_CreateSet(name, icon)
	local glyphSet = UIOperations:CreateGlyphSet(name, icon)
	local newGlyphSetCount = AS2.activeModel.glyphSetList:GetGlyphSetCount()
	
	-- Complete the tutorials in reverse order - completion of one will activate another.
	if newGlyphSetCount >= 2 then AS2:CompleteTutorial("TUTORIAL_SECOND_GLYPH_SET") end
	if newGlyphSetCount >= 1 then AS2:CompleteTutorial("TUTORIAL_FIRST_GLYPH_SET") end
	return glyphSet
end

-- Called when the user clicks "Yes" to the save set dialog.
function GlyphSetListController:protected_SaveSet(set)
	return UIOperations:SaveGlyphSet(set)
end
