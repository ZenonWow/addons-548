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
local GlyphSetsFrame = AS2.View.GlyphSetsFrame
local ListView = AS2.View.ListView
local SecondaryFrame = AS2.View.SecondaryFrame
local Widgets = AS2.View.Widgets

function GlyphSetsFrame:Create(name, parent)
	self = SecondaryFrame.Create(self, name, parent)

	-- Create the "Glyph sets:" text
	self.glyphSetsText = self:CreateFontString()
	self.glyphSetsText:SetFontObject("GameFontNormal")
	self.glyphSetsText:SetText(L["Glyph sets:"])

	-- Create the glyph set list
	self.glyphSetList = ListView:Create(name .. "_GlyphSetList", self)

	-- Create the "Equip" button
	self.equipButton = CreateFrame("Button", name .. "_EquipButton", self, "UIPanelButtonTemplate")
	self.equipButton:SetText(L["Equip"])

	-- Create the note about automatic saving
	self.autosaveText = self:CreateFontString()
	self.autosaveText:SetFontObject("GameFontNormalLeft")
	self.autosaveText:SetText(L["GLYPHSET_AUTOSAVE_NOTE"])

	-- Lay out the window
	self.glyphSetsText:SetPoint("TOP", 0, -20)

	self.glyphSetList:SetWidth(AS2.LIST_ITEM_WIDTH)
	self.glyphSetList:SetPoint("TOP", self.glyphSetsText, "BOTTOM", 0, -2)
	self.glyphSetList:SetPoint("BOTTOM", self.equipButton, "TOP", 0, 4)

	self.equipButton:SetPoint("BOTTOM", self.autosaveText, "TOP", 0, 16)
	self.equipButton:SetSize(150, 40)

	self.autosaveText:SetPoint("BOTTOM", 0, 20)

	return self
end
