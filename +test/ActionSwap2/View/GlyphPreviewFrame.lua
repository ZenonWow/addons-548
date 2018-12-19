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
local GlyphPreviewFrame = AS2.View.GlyphPreviewFrame
local Utilities = AS2.Model.Utilities
local Widgets = AS2.View.Widgets

function GlyphPreviewFrame:Create(name, parent)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:Hide()			-- (this window is hidden by default)
	self:SetSize(300, 300 / AS2.View.GlyphDisplay:GetPreferredAspectRatio())
	self:SetFrameStrata("DIALOG")
	self:SetFrameLevel(0)
	local contentInsets = Widgets:MakeTooltipFrame(self)

	self.glyphDisplay = AS2.View.GlyphDisplay:Create(name .. "_GlyphDisplay", self)
	self.glyphDisplay:SetPoint("TOPLEFT", contentInsets.left, -contentInsets.top)
	self.glyphDisplay:SetPoint("BOTTOMRIGHT", -contentInsets.right, contentInsets.bottom)

	return self
end

-- Sets the glyphs table that should be displayed
function GlyphPreviewFrame:SetDisplay(glyphsTable)
	self.glyphsTable = glyphsTable
	self:Refresh()
end

-- Refreshes the glyph display to match reality
function GlyphPreviewFrame:Refresh()
	-- (technically, this should be part of a controller, but meh)
	-- Fill in the glyphs; highlight those that don't match the current setup
	for slot = 1, AS2.NUM_GLYPH_SLOTS do
		if self.glyphsTable then
			local glyph = self.glyphsTable:GetValue(slot)
			local highlight = glyph and not Utilities:FindEquippedGlyph(glyph)
			self.glyphDisplay:SetGlyphIcon(slot, glyph and GetSpellTexture(glyph), nil, highlight)
		else
			self.glyphDisplay:SetGlyphIcon(slot, nil, nil, nil)
		end
	end
end
