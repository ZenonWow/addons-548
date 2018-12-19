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
local GlobalKeysetsFrame = AS2.View.GlobalKeysetsFrame
local ListView = AS2.View.ListView
local SecondaryFrame = AS2.View.SecondaryFrame
local Widgets = AS2.View.Widgets

function GlobalKeysetsFrame:Create(name, parent)
	self = SecondaryFrame.Create(self, name, parent)

	-- Create the text at the top
	self.descriptionText = self:CreateFontString()
	self.descriptionText:SetFontObject("GameFontNormalLeft")
	self.descriptionText:SetText(L["KEYSET_DESCRIPTION"])

	-- Create the "Keybinding sets:" text
	self.keysetsText = self:CreateFontString()
	self.keysetsText:SetFontObject("GameFontNormal")
	self.keysetsText:SetText(L["Keybinding sets:"])

	-- Create the keyset list
	self.keysetList = ListView:Create(name .. "_KeysetList", self)

	-- Create the "Equip" button
	self.equipButton = CreateFrame("Button", name .. "_EquipButton", self, "UIPanelButtonTemplate")
	self.equipButton:SetText(L["Equip"])

	-- Create the note about automatic saving
	self.autosaveText = self:CreateFontString()
	self.autosaveText:SetFontObject("GameFontNormalLeft")
	self.autosaveText:SetText(L["KEYSET_AUTOSAVE_NOTE"])

	-- Lay out the window
	self.descriptionText:SetPoint("TOP", 0, -20)

	self.keysetsText:SetPoint("TOP", self.descriptionText, "BOTTOM", 0, -16)

	self.keysetList:SetWidth(AS2.LIST_ITEM_WIDTH)
	self.keysetList:SetPoint("TOP", self.keysetsText, "BOTTOM", 0, -2)
	self.keysetList:SetPoint("BOTTOM", self.equipButton, "TOP", 0, 4)

	self.equipButton:SetPoint("BOTTOM", self.autosaveText, "TOP", 0, 16)
	self.equipButton:SetSize(150, 40)

	self.autosaveText:SetPoint("BOTTOM", 0, 20)

	return self
end
