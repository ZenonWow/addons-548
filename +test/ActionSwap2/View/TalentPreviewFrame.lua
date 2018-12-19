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
local TalentPreviewFrame = AS2.View.TalentPreviewFrame
local Utilities = AS2.Model.Utilities
local Widgets = AS2.View.Widgets

function TalentPreviewFrame:Create(name, parent)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:Hide()			-- (this window is hidden by default)
	self:SetFrameStrata("DIALOG")
	self:SetFrameLevel(0)
	local contentInsets = Widgets:MakeTooltipFrame(self)

	self.talentDisplay = AS2.View.TalentDisplay:Create(name .. "_TalentDisplay", self, true)

	self:SetSize(450, 450 / self.talentDisplay:GetPreferredAspectRatio())
	self.talentDisplay:SetPoint("TOPLEFT", contentInsets.left, -contentInsets.top)
	self.talentDisplay:SetPoint("BOTTOMRIGHT", -contentInsets.right, contentInsets.bottom)

	return self
end

-- Sets the talents table that should be displayed
function TalentPreviewFrame:SetDisplay(talentsTable)
	self.talentsTable = talentsTable
	self:Refresh()
end

-- Refreshes the talent display to match reality
function TalentPreviewFrame:Refresh()
	-- (technically, this should be part of a controller, but meh)
	-- Fill in the talents; highlight those that don't match the current setup
	for slot = 1, AS2.NUM_TALENT_SLOTS do
		local talentInSlot = AS2.activeGameModel:GetTalent(slot)
		for column = 1, AS2.NUM_TALENTS_PER_SLOT do
			if self.talentsTable then
				local name, icon, _, _, learned, available = GetTalentInfo((slot - 1) * 3 + column)
				local actuallyAvailable = talentInSlot or available
				local targetTalent = self.talentsTable:GetValue(slot)
				local desired = targetTalent == column
				self.talentDisplay:SetButtonState(slot, column, name, icon, learned, actuallyAvailable, desired)
			else
				self.talentDisplay:SetButtonState(slot, column, nil, nil, false, false)
			end
		end
	end
end
