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
local TalentSetsFrame = AS2.View.TalentSetsFrame
local ListView = AS2.View.ListView
local SecondaryFrame = AS2.View.SecondaryFrame
local Widgets = AS2.View.Widgets

function TalentSetsFrame:Create(name, parent)
	self = SecondaryFrame.Create(self, name, parent)

	-- Create the "Talent sets:" text
	self.talentSetsText = self:CreateFontString()
	self.talentSetsText:SetFontObject("GameFontNormal")
	self.talentSetsText:SetText(L["Talent sets:"])

	-- Create the talent set list
	self.talentSetList = ListView:Create(name .. "_TalentSetList", self)

	-- Create the "Equip" button
	self.equipButton = CreateFrame("Button", name .. "_EquipButton", self, "UIPanelButtonTemplate")
	self.equipButton:SetText(L["Equip"])

	-- Create the note about automatic saving
	self.autosaveText = self:CreateFontString()
	self.autosaveText:SetFontObject("GameFontNormalLeft")
	self.autosaveText:SetText(L["TALENTSET_AUTOSAVE_NOTE"])

	-- Lay out the window
	self.talentSetsText:SetPoint("TOP", 0, -20)

	self.talentSetList:SetWidth(AS2.LIST_ITEM_WIDTH)
	self.talentSetList:SetPoint("TOP", self.talentSetsText, "BOTTOM", 0, -2)
	self.talentSetList:SetPoint("BOTTOM", self.equipButton, "TOP", 0, 4)

	self.equipButton:SetPoint("BOTTOM", self.autosaveText, "TOP", 0, 16)
	self.equipButton:SetSize(150, 40)

	self.autosaveText:SetPoint("BOTTOM", 0, 20)

	return self
end
