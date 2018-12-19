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
local TalentOverlayFrame = AS2.View.TalentOverlayFrame
local Utilities = AS2.Model.Utilities
local Widgets = AS2.View.Widgets

function TalentOverlayFrame:Create(name, parent)
	assert(name)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:Hide()					-- (by default, this frame is hidden)
	self:SetPoint("TOPLEFT")	-- (this frame should not be positioned manually)
	self:SetSize(1, 1)			-- (we have to have nonzero size, or our children won't be displayed)
	self:SetFrameStrata("DIALOG")

	-- Load the talent UI now (if not already) - we need to reference several items from it.
	AS2:LoadTalentUI()

	self.buttons = { }
	for slot = 1, AS2.NUM_TALENT_SLOTS do
		self.buttons[slot] = Widgets:CreateTalentOverlayButton(name .. "_Overlay" .. slot, self)
	end

	AS2:AddCallback(AS2, "TalentAdded", self.private_OnTalentChanged, self)
	AS2:AddCallback(AS2, "TalentRemoved", self.private_OnTalentChanged, self)
	AS2:AddCallback(AS2, "ActivationFinished", self.private_OnActivationFinished, self)

	-- Refresh the frame's contents before displaying.
	self:SetScript("OnShow", function(self)
		self:Refresh()
	end)

	self.needsValidate = true

	return self
end

-- Forces a refresh of all talent slots.
function TalentOverlayFrame:Refresh()
	self.needsValidate = true
	AS2:Dispatch(self.Validate, self)
end

-- Called when a talent is added or removed
function TalentOverlayFrame:private_OnTalentChanged(slot)
	self:Refresh()
end

-- Called when talent set activation finishes or is canceled
function TalentOverlayFrame:private_OnActivationFinished(kind)
	if kind == "TalentSet" then
		-- Hide the window; it will be re-displayed on the next equip
		self:Hide()
	end
end

-- Validates the talent overlay display.
function TalentOverlayFrame:Validate()
	if self.needsValidate then
		self.needsValidate = false

		-- (technically should be in the controller, but meh)
		for slot = 1, AS2.NUM_TALENT_SLOTS do
			local talent = AS2.activeGameModel:GetTalent(slot)
			local targetTalent = AS2.activeGameModel:GetTargetTalent(slot)
			local checked = (not targetTalent) or (targetTalent == talent)
			local arrowIndex = (not checked) and targetTalent
			if arrowIndex and arrowIndex >= 1 and arrowIndex <= AS2.NUM_TALENTS_PER_SLOT then
				self.buttons[slot]:SetAllPoints(_G["PlayerTalentFrameTalentsTalentRow" .. slot .. "Talent" .. targetTalent])
				self.buttons[slot]:Show()
			else
				self.buttons[slot]:Hide()
			end
		end
	end
end