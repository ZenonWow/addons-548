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
local TalentActivationFrame = AS2.View.TalentActivationFrame
local Widgets = AS2.View.Widgets

function TalentActivationFrame:Create(name, parent)
	assert(parent)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:Hide()
	self:SetToplevel()
	self:SetWidth(450)
	self:SetHeight(365)
	self:SetMovable(true)
	self:SetClampedToScreen(true)
	self:RegisterForDrag("LeftButton")	-- (needed for moveable)
	self:EnableMouse(true)				-- (needed for moveable)

	local contentInsets = Widgets:MakeParchmentFrame(self)

	-- Create the text
	self.text = self:CreateFontString()
	self.text:SetFontObject("GameFontNormalLeft")
	self.text:SetText(L["TALENT_SET_ACTIVATION_INSTRUCTIONS"])

	-- Create the close button
	self.closeButton = CreateFrame("Button", nil, self, "UIPanelCloseButton")
	self.closeButton:SetPoint("TOPRIGHT", 0, 0)

	-- Create the talent display
	self.talentDisplay = AS2.View.TalentDisplay:Create(name .. "_TalentDisplay", self)

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

	self.talentDisplay:SetSize(400, 400 / self.talentDisplay:GetPreferredAspectRatio())
	self.talentDisplay:SetPoint("TOP", 0, -contentInsets.top - 27)

	self.cancelButton:SetSize(250, 40)
	self.cancelButton:SetPoint("BOTTOM", 0, contentInsets.bottom)

	return self
end
