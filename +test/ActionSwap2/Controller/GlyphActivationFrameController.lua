--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local GlyphActivationFrameController = AS2.Controller.GlyphActivationFrameController
local Utilities = AS2.Model.Utilities

function GlyphActivationFrameController:Create(frame)
	assert(frame)
	self = self:Derive()
	self.frame = frame

	assert(frame:GetScript("OnShow") == nil)
	frame:SetScript("OnShow", function(frame)
		PlaySound("igCharacterInfoOpen")

		-- Put stuff into the slots
		self:Refresh()
	end)

	-- Cancel glyph activation when the window is closed
	assert(frame:GetScript("OnHide") == nil)
	frame:SetScript("OnHide", function(frame)
		PlaySound("igCharacterInfoClose")

		-- (must be BEFORE cancel operation; cancel counts as activation finished)
		local previousSet = self.previousSet

		-- Cancel glyph set activation, if it is occurring.
		AS2.activeModel:CancelGlyphSetActivation()

		-- Try to equip the previous set, but only if it finishes instantaneously
		if previousSet then
			local previousSetIndex = AS2.activeModel.glyphSetList:FindGlyphSet(previousSet)
			if previousSetIndex then
				AS2.activeModel:BeginActivatingGlyphSet(previousSetIndex)
				if AS2.activeModel:IsActivatingGlyphSet() then	-- (if not instantaneous)
					AS2.activeModel:CancelGlyphSetActivation()
				end
			end
		end
		self.previousSet = nil	-- (don't accidentally redo this operation)

		-- Re-show the main window, since it was hidden when this frame was opened.
		if AS2.mainWindow and not AS2.activeModel:IsActivatingTalentSet() then AS2.mainWindow:Show() end
	end)

	AS2:AddCallback(AS2, "GlyphAdded", self.private_OnGlyphChanged, self)
	AS2:AddCallback(AS2, "GlyphRemoved", self.private_OnGlyphChanged, self)
	AS2:AddCallback(AS2, "ActivationFinished", self.private_OnActivationFinished, self)

	self.needsValidate = true

	return self
end

-- Forces a refresh of the contents of each slot.
function GlyphActivationFrameController:Refresh()
	self.needsValidate = true
	AS2:Dispatch(self.Validate, self)
end

function GlyphActivationFrameController:SetPreviousSet(set)
	if not set or AS2.activeModel:IsActivatingGlyphSet() then
		self.previousSet = set
	end
end

function GlyphActivationFrameController:private_OnGlyphChanged(slot)
	self:Refresh()
end

function GlyphActivationFrameController:private_OnActivationFinished(kind)
	-- Wait a bit (so the user sees the checkmark), then hide the window
	if kind == "GlyphSet" then
		self.previousSet = nil	-- (Don't accidentally restore later; the activation was completed!)
		if self.frame:IsShown() and not self.hideTimer then
			self.hideTimer = AS2:ScheduleTimer(self.private_OnHideTimerElapsed, 0.5, self)
		end
	end
end

function GlyphActivationFrameController:private_OnHideTimerElapsed()
	self.hideTimer = nil	-- (timers handles are invalid once elapsed)
	self.frame:Hide()
	AS2:CompleteTutorial("TUTORIAL_EQUIP_GLYPH_SET")
end

function GlyphActivationFrameController:Validate()
	if self.needsValidate then
		self.needsValidate = false
		
		local glyphPlacements = Utilities:ComputeGlyphPlacements()
		for slot = 1, AS2.NUM_GLYPH_SLOTS do
			local glyph = AS2.activeGameModel:GetGlyph(slot)
			local targetGlyph = glyphPlacements[slot]
			local check = not targetGlyph
			if AS2.DEBUG then assert(not targetGlyph or glyph ~= targetGlyph) end	-- (shouldn't ever happen, or ComputeGlyphPlacements() didn't work right)
			self.frame.glyphDisplay:SetGlyphIcon(slot,
				glyph and GetSpellTexture(glyph),
				check,		-- (check)
				nil,		-- (highlight)
				targetGlyph and GetSpellTexture(targetGlyph),
				targetGlyph and GetSpellInfo(targetGlyph))

			-- Cancel the hide timer if a discrepency is detected! (i.e., equipped a different set before the window hides)
			if self.hideTimer and not check then
				AS2:CancelTimer(self.hideTimer)
				self.hideTimer = nil
			end
		end
	end
end
