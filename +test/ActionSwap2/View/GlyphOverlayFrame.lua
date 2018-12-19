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
local GlyphOverlayFrame = AS2.View.GlyphOverlayFrame
local Utilities = AS2.Model.Utilities
local Widgets = AS2.View.Widgets

function GlyphOverlayFrame:Create(name, parent)
	assert(name)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:Hide()					-- (by default, this frame is hidden)
	self:SetPoint("TOPLEFT")	-- (this frame should not be positioned manually)
	self:SetSize(1, 1)			-- (we have to have nonzero size, or our children won't be displayed)
	self:SetFrameStrata("DIALOG")

	-- Load the glyph UI now (if not already) - we need to reference several items from it.
	AS2:LoadGlyphUI()

	self.buttons = { }
	for slot = 1, AS2.NUM_GLYPH_SLOTS do
		self.buttons[slot] = Widgets:CreateGlyphOverlayButton(name .. "_Overlay" .. slot, self)
		self.buttons[slot]:SetSize(36, 36)
		self.buttons[slot]:SetPoint("BOTTOMLEFT", _G["GlyphFrameGlyph" .. slot], "TOPRIGHT")
	end

	AS2:AddCallback(AS2, "GlyphAdded", self.private_OnGlyphChanged, self)
	AS2:AddCallback(AS2, "GlyphRemoved", self.private_OnGlyphChanged, self)
	AS2:AddCallback(AS2, "ActivationFinished", self.private_OnActivationFinished, self)

	-- Refresh the frame's contents before displaying.
	self:SetScript("OnShow", function(self)
		self:Refresh()
	end)

	self.needsValidate = true

	return self
end

-- Forces a refresh of all glyph slots.
function GlyphOverlayFrame:Refresh()
	self.needsValidate = true
	AS2:Dispatch(self.Validate, self)
end

-- Called when a glyph is added or removed
function GlyphOverlayFrame:private_OnGlyphChanged(slot)
	self:Refresh()
end

-- Called when glyph set activation finishes or is canceled
function GlyphOverlayFrame:private_OnActivationFinished(kind)
	if kind == "GlyphSet" then
		-- Hide the window; it will be re-displayed on the next equip
		self:Hide()
	end
end

-- Validates the glyph overlay display.
function GlyphOverlayFrame:Validate()
	if self.needsValidate then
		self.needsValidate = false
		
		-- (technically should be in the controller, but meh)
		local glyphPlacements = Utilities:ComputeGlyphPlacements()
		for slot = 1, AS2.NUM_GLYPH_SLOTS do
			local glyph = AS2.activeGameModel:GetGlyph(slot)
			local targetGlyph = glyphPlacements[slot]
			if AS2.DEBUG then assert(not targetGlyph or glyph ~= targetGlyph) end	-- (shouldn't ever happen, or ComputeGlyphPlacements() didn't work right)
			if targetGlyph then
				local targetGlyphIcon = GetSpellTexture(targetGlyph)
				local tooltipText = GetSpellInfo(targetGlyph)
				self.buttons[slot].texture:SetTexture(targetGlyphIcon)
				self.buttons[slot].tooltip = tooltipText
				self.buttons[slot]:Show()
			else
				self.buttons[slot]:Hide()
			end
		end
	end
end