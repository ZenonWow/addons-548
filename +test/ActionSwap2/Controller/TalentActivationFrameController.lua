--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local TalentActivationFrameController = AS2.Controller.TalentActivationFrameController
local Utilities = AS2.Model.Utilities

function TalentActivationFrameController:Create(frame)
	assert(frame)
	self = self:Derive()
	self.frame = frame

	assert(frame:GetScript("OnShow") == nil)
	frame:SetScript("OnShow", function(frame)
		PlaySound("igCharacterInfoOpen")

		-- Put stuff into the slots
		self:Refresh()
	end)

	-- Cancel talent activation when the window is closed
	assert(frame:GetScript("OnHide") == nil)
	frame:SetScript("OnHide", function(frame)
		PlaySound("igCharacterInfoClose")

		-- (must be BEFORE cancel operation; cancel counts as activation finished)
		local previousSet = self.previousSet

		-- Cancel talent set activation, if it is occurring.
		AS2.activeModel:CancelTalentSetActivation()

		-- Try to equip the previous set, but only if it finishes instantaneously
		if previousSet then
			local previousSetIndex = AS2.activeModel.talentSetList:FindTalentSet(previousSet)
			if previousSetIndex then
				AS2.activeModel:BeginActivatingTalentSet(previousSetIndex)
				if AS2.activeModel:IsActivatingTalentSet() then	-- (if not instantaneous)
					AS2.activeModel:CancelTalentSetActivation()
				end
			end
		end
		self.previousSet = nil	-- (don't accidentally redo this operation)

		-- Re-show the main window, since it was hidden when this frame was opened.
		if AS2.mainWindow and not AS2.activeModel:IsActivatingGlyphSet() then AS2.mainWindow:Show() end
	end)

	AS2:AddCallback(AS2, "TalentAdded", self.private_OnTalentChanged, self)
	AS2:AddCallback(AS2, "TalentRemoved", self.private_OnTalentChanged, self)
	AS2:AddCallback(AS2, "ActivationFinished", self.private_OnActivationFinished, self)

	self.needsValidate = true

	return self
end

-- Forces a refresh of the contents of each slot.
function TalentActivationFrameController:Refresh()
	self.needsValidate = true
	AS2:Dispatch(self.Validate, self)
end

function TalentActivationFrameController:SetPreviousSet(set)
	if not set or AS2.activeModel:IsActivatingTalentSet() then
		self.previousSet = set
	end
end

function TalentActivationFrameController:private_OnTalentChanged(slot)
	self:Refresh()
end

function TalentActivationFrameController:private_OnActivationFinished(kind)
	-- Wait a bit (so the user sees the checkmark), then hide the window
	if kind == "TalentSet" then
		self.previousSet = nil	-- (Don't accidentally restore later; the activation was completed!)
		if self.frame:IsShown() and not self.hideTimer then
			self.hideTimer = AS2:ScheduleTimer(self.private_OnHideTimerElapsed, 0.5, self)
		end
	end
end

function TalentActivationFrameController:private_OnHideTimerElapsed()
	self.hideTimer = nil	-- (timers handles are invalid once elapsed)
	self.frame:Hide()
end

function TalentActivationFrameController:Validate()
	if self.needsValidate then
		self.needsValidate = false

		for slot = 1, AS2.NUM_TALENT_SLOTS do
			local talent = AS2.activeGameModel:GetTalent(slot)
			local targetTalent = AS2.activeGameModel:GetTargetTalent(slot)
			local checked = (not targetTalent) or (targetTalent == talent)
			local arrowIndex = (not checked) and targetTalent
			self.frame.talentDisplay:SetRowState(slot, checked, arrowIndex)

			for column = 1, AS2.NUM_TALENTS_PER_SLOT do
				local name, icon, _, _, learned, available = GetTalentInfo((slot - 1) * 3 + column)
				local actuallyAvailable = talent or available
				self.frame.talentDisplay:SetButtonState(slot, column, name, icon, learned, actuallyAvailable, learned)
			end

			-- Cancel the hide timer if a discrepency is detected! (i.e., equipped a different set before the window hides)
			if self.hideTimer and not checked then
				AS2:CancelTimer(self.hideTimer)
				self.hideTimer = nil
			end
		end
	end
end
