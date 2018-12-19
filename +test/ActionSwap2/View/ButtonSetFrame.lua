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
local ButtonSetFrame = AS2.View.ButtonSetFrame
local ListView = AS2.View.ListView
local SecondaryFrame = AS2.View.SecondaryFrame
local Widgets = AS2.View.Widgets

function ButtonSetFrame:Create(name, parent)
	self = SecondaryFrame.Create(self, name, parent)

	-- Create the "Select Buttons" button
	self.selectButtonsButton = CreateFrame("Button", name .. "_SelectButtonsButton", self, "UIPanelButtonTemplate")

	-- Create the "Also swap keybindings" button
	self.includeKeybindingsButton = CreateFrame("CheckButton", name .. "_IncludeKeybindingsButton", self, "UICheckButtonTemplate")
	self.includeKeybindingsButton.text:SetText(L["Also swap keybindings"])

	-- Create the "Equip" button
	self.equipButton = CreateFrame("Button", name .. "_EquipButton", self, "UIPanelButtonTemplate")
	self.equipButton:SetText(L["Equip"])

	-- Create the action set list
	self.actionSetList = ListView:Create(name .. "_ActionSetList", self)

	-- Create the "Action sets:" text
	self.actionSetsText = self:CreateFontString()
	self.actionSetsText:SetFontObject("GameFontNormal")
	self.actionSetsText:SetText(L["Action sets:"])

	-- Create the note about automatic saving
	self.autosaveText = self:CreateFontString()
	self.autosaveText:SetFontObject("GameFontNormalLeft")
	self.autosaveText:SetText(L["ACTIONSET_AUTOSAVE_NOTE"])

	-- Create the selection tools helper dialog
	self.selectionToolsFrame = CreateFrame("Frame", name .. "_SelectionToolsFrame", self)
	self.selectionToolsFrame:Hide()		-- (by default, this frame is hidden)
	Widgets:MakeTooltipFrame(self.selectionToolsFrame, true)

	-- Create the "Select all unused" button
	self.selectUnusedButton = CreateFrame("Button", name .. "_SelectUnusedButton", self.selectionToolsFrame, "UIPanelButtonTemplate")
	self.selectUnusedButton:SetText(L["SELECT_UNUSED"])

	-- Create the "Deselect all" button
	self.deselectAllButton = CreateFrame("Button", name .. "_DeselectAllButton", self.selectionToolsFrame, "UIPanelButtonTemplate")
	self.deselectAllButton:SetText(L["DESELECT_ALL"])

	-- Lay out the window
	self.selectButtonsButton:SetPoint("TOP", 0, -16)
	self.selectButtonsButton:SetSize(150, 40)

	self.includeKeybindingsButton:SetSize(22, 22)
	self.includeKeybindingsButton:SetPoint("TOPLEFT", self.selectButtonsButton, "BOTTOMLEFT", 6, 0)

	self.actionSetsText:SetPoint("TOP", self.selectButtonsButton, "BOTTOM", 0, -40)

	self.actionSetList:SetWidth(AS2.LIST_ITEM_WIDTH)
	self.actionSetList:SetPoint("TOP", self.actionSetsText, "BOTTOM", 0, -2)
	self.actionSetList:SetPoint("BOTTOM", self.equipButton, "TOP", 0, 4)

	self.equipButton:SetPoint("BOTTOM", self.autosaveText, "TOP", 0, 16)
	self.equipButton:SetSize(150, 40)

	self.autosaveText:SetPoint("BOTTOM", 0, 20)

	self.selectionToolsFrame:SetPoint("TOPLEFT", self.selectButtonsButton, "TOPRIGHT", 0, 0)
	self.selectionToolsFrame:SetSize(150, 80)

	self.selectUnusedButton:SetPoint("TOPLEFT", self.selectionToolsFrame, 10, -10)
	self.selectUnusedButton:SetPoint("TOPRIGHT", self.selectionToolsFrame, -10, -10)
	self.selectUnusedButton:SetPoint("BOTTOM", self.selectionToolsFrame, "CENTER", 0, 2)

	self.deselectAllButton:SetPoint("BOTTOMLEFT", self.selectionToolsFrame, 10, 10)
	self.deselectAllButton:SetPoint("BOTTOMRIGHT", self.selectionToolsFrame, -10, 10)
	self.deselectAllButton:SetPoint("TOP", self.selectionToolsFrame, "CENTER", 0, -2)

	AS2:RegisterMessage(self, "ContextChanged")

	return self
end

-- Sets the context of this frame (which button set it displays information for)
function ButtonSetFrame:SetContext(buttonSet)
	if buttonSet ~= self.context then
		self.context = buttonSet
		AS2:SendMessage(self, "ContextChanged", self, buttonSet)
	end
end
