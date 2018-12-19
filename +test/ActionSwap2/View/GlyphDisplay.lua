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
local GlyphDisplay = AS2.View.GlyphDisplay
local Widgets = AS2.View.Widgets

-- Size of the glyph frame in the Blizzard UI
local GLYPH_FRAME_WIDTH = 437
local GLYPH_FRAME_HEIGHT = 413

-- These positions are derived from Blizzard_GlyphUI.xml
local glyphPositions = {
	{ 110, 43 },
	{ 0, 156 },
	{ -111, 43 },
	{ -155, -109 },
	{ 0, -150 },
	{ 151, -109 }
}

local glyphTypes = {
	[GLYPH_ID_MAJOR_1] = GLYPH_TYPE_MAJOR,
	[GLYPH_ID_MAJOR_2] = GLYPH_TYPE_MAJOR,
	[GLYPH_ID_MAJOR_3] = GLYPH_TYPE_MAJOR,
	[GLYPH_ID_MINOR_1] = GLYPH_TYPE_MINOR,
	[GLYPH_ID_MINOR_2] = GLYPH_TYPE_MINOR,
	[GLYPH_ID_MINOR_3] = GLYPH_TYPE_MINOR
}

function GlyphDisplay:Create(name, parent)
	assert(parent)
	self = self:MixInto(CreateFrame("Frame", name, parent))

	-- Load the glyph UI now (if not already) - we need to reference several items from it.
	AS2:LoadGlyphUI()

	-- Texture coords are derived from Blizzard_GlyphUI.xml
	local background = self:CreateTexture()
	background:SetDrawLayer("ARTWORK", 0)
	background:SetTexture("Interface\\TALENTFRAME\\glyph-bg")
	background:SetTexCoord(0.00195313, 0.85546875, 0.00097656, 0.40429688)
	background:SetAllPoints()

	-- Create the glyph buttons
	self.buttons = { }
	for i = 1, AS2.NUM_GLYPH_SLOTS do
		local info = GLYPH_TYPE_INFO[ glyphTypes[i] ]
		self.buttons[i] = CreateFrame("Button", name .. "_Glyph" .. i, self, "SecureActionButtonTemplate")
		self.buttons[i]:SetAttribute("type", "click")
		self.buttons[i]:SetAttribute("clickbutton", _G["GlyphFrameGlyph" .. i])
		self.buttons[i].highlight = self.buttons[i]:CreateTexture()
		self.buttons[i].highlight:SetDrawLayer("ARTWORK", 1)
		self.buttons[i].highlight:SetTexture("Interface\\TALENTFRAME\\glyph-main")
		self.buttons[i].highlight:SetTexCoord(info.highlight.left, info.highlight.right, info.highlight.top, info.highlight.bottom)
		self.buttons[i].highlight:SetBlendMode("ADD")
		self.buttons[i].highlight:SetVertexColor(1, 0, 0)
		self.buttons[i].highlight:SetPoint("CENTER")
		self.buttons[i].glyph = self.buttons[i]:CreateTexture()
		self.buttons[i].glyph:SetDrawLayer("ARTWORK", 2)
		self.buttons[i].glyph:SetAllPoints()
		self.buttons[i].ring = self.buttons[i]:CreateTexture()
		self.buttons[i].ring:SetTexture("Interface\\TALENTFRAME\\glyph-main")
		self.buttons[i].ring:SetDrawLayer("ARTWORK", 3)
		self.buttons[i].ring:SetPoint("CENTER")
		self.buttons[i].ring:SetTexCoord(info.ring.left, info.ring.right, info.ring.top, info.ring.bottom)
		self.buttons[i].check = self.buttons[i]:CreateTexture()
		self.buttons[i].check:SetDrawLayer("ARTWORK", 4)
		self.buttons[i].check:SetAllPoints()
		self.buttons[i].overlay = Widgets:CreateGlyphOverlayButton(name .. "_Overlay" .. i, self.buttons[i])
	end

	-- Lay out the window only when the size changed message is fired
	self:SetScript("OnSizeChanged", function(self, width, height)
		local xScale = width / GLYPH_FRAME_WIDTH
		local yScale = height / GLYPH_FRAME_HEIGHT
		for i = 1, AS2.NUM_GLYPH_SLOTS do
			local info = GLYPH_TYPE_INFO[ glyphTypes[i] ]
			self.buttons[i]:SetSize(57.0 * xScale, 57.0 * yScale)
			self.buttons[i]:SetPoint("CENTER", glyphPositions[i][1] * xScale, glyphPositions[i][2] * yScale)
			self.buttons[i].ring:SetSize(info.ring.size * xScale, info.ring.size * yScale)
			self.buttons[i].highlight:SetSize(info.highlight.size * xScale, info.highlight.size * yScale)
			self.buttons[i].overlay:SetPoint("BOTTOMLEFT", self.buttons[i], "TOPRIGHT")
			self.buttons[i].overlay:SetSize(36 * xScale, 36 * yScale)
		end
	end)

	return self
end

-- Sets a glyph's icon and/or checked state. (use nil for no check)
function GlyphDisplay:SetGlyphIcon(slot, glyphIcon, check, highlight, targetGlyphIcon, targetGlyphTooltip)
	assert(slot >= 1 and slot <= AS2.NUM_GLYPH_SLOTS)

	if glyphIcon then
		-- (this is like SetTexture, but makes the icon round so it fits in the slot)
		-- (be careful though, it does NOT call SetTexture(nil) if nil is given)
		SetPortraitToTexture(self.buttons[slot].glyph, glyphIcon)
	else
		self.buttons[slot].glyph:SetTexture(nil)
	end

	if targetGlyphIcon then
		self.buttons[slot].overlay.texture:SetTexture(targetGlyphIcon)
		self.buttons[slot].overlay.tooltip = targetGlyphTooltip
		self.buttons[slot].overlay:Show()
	else
		self.buttons[slot].overlay.texture:SetTexture(nil)
		self.buttons[slot].overlay.tooltip = nil
		self.buttons[slot].overlay:Hide()
	end

	if check == true then
		self.buttons[slot].check:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
	elseif check == false then
		self.buttons[slot].check:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	else
		self.buttons[slot].check:SetTexture(nil)
	end

	if highlight then
		self.buttons[slot].highlight:Show()
	else
		self.buttons[slot].highlight:Hide()
	end
end

-- Returns the aspect ratio of the actual glyph pane
function GlyphDisplay:GetPreferredAspectRatio()
	return GLYPH_FRAME_WIDTH / GLYPH_FRAME_HEIGHT
end
