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
local GlyphActivationFrame = AS2.View.GlyphActivationFrame
local Widgets = AS2.View.Widgets

function GlyphActivationFrame:Create(name, parent)
	assert(parent)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:Hide()
	self:SetToplevel()
	self:SetWidth(300)
	self:SetHeight(375)
	self:SetMovable(true)
	self:SetClampedToScreen(true)
	self:RegisterForDrag("LeftButton")	-- (needed for moveable)
	self:EnableMouse(true)				-- (needed for moveable)

	local contentInsets = Widgets:MakeParchmentFrame(self)

	-- Create the text
	self.text = self:CreateFontString()
	self.text:SetFontObject("GameFontNormalLeft")
	self.text:SetText(L["GLYPH_SET_ACTIVATION_INSTRUCTIONS"])

	-- Create the close button
	self.closeButton = CreateFrame("Button", nil, self, "UIPanelCloseButton")
	self.closeButton:SetPoint("TOPRIGHT", 0, 0)

	-- Create the glyph display
	self.glyphDisplay = AS2.View.GlyphDisplay:Create(name .. "_GlyphDisplay", self)

	-- Create the cancel button
	self.cancelButton = CreateFrame("Button", name .. "_CancelButton", self, "UIPanelButtonTemplate")
	self.cancelButton:SetText(L["Cancel this set change"])
	self.cancelButton:SetScript("OnClick", function() self:Hide() end)

	self:SetScript("OnDragStart", function(self, button)
		self:StartMoving()
	end)
	
	self:SetScript("OnDragStop", function(self, button)
		self:StopMovingOrSizing()
	end)

	-- Lay out the window
	self.text:SetPoint("TOP", 0, -contentInsets.top + 10)

	self.glyphDisplay:SetSize(250, 250 / AS2.View.GlyphDisplay:GetPreferredAspectRatio())
	self.glyphDisplay:SetPoint("TOP", 0, -contentInsets.top - 40)

	self.cancelButton:SetSize(250, 40)
	self.cancelButton:SetPoint("BOTTOM", 0, contentInsets.bottom)

	return self
end
