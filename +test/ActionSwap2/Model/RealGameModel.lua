--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- RealGameModel - defines the interface between ActionSwap and WoW, which can be virtualized for test code.
-- See also: VirtualGameModel

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local L = LibStub("AceLocale-3.0"):GetLocale("ActionSwap2", true)
local Action = AS2.Model.Action
local Binding = AS2.Model.Binding
local RealGameModel = AS2.Model.RealGameModel

RealGameModel.queuedActions = { }
RealGameModel.queuedKeybindings = { }
RealGameModel.targetGlyphs = { }
RealGameModel.targetTalents = { }
RealGameModel.applyActionsTimer = nil
RealGameModel.lastWarningTime = nil
RealGameModel.retryCount = 0
RealGameModel.unmorphedSpellMap = nil	-- (mapping from morphed spell name to unmorphed spell ID)

-- Sets the action that is queued to be placed in the given action bar slot.
-- (things like combat may prevent it from happening immediately)
function RealGameModel:SetQueuedAction(slot, action)
	assert(slot >= 1 and slot <= AS2.NUM_ACTION_SLOTS, "INVALID_ID")
	self.queuedActions[slot] = action

	-- Start the "apply actions" timer if not already started. (immediate the first time)
	if not self.applyActionsTimer then
		self.applyActionsTimer = AS2:ScheduleTimer(self.private_OnApplyActionsTimerElapsed, 0)
	end
end

-- Returns the action queued to be placed in the given slot.  (nil if nothing is queued)
function RealGameModel:GetQueuedAction(slot)
	assert(slot >= 1 and slot <= AS2.NUM_ACTION_SLOTS, "INVALID_ID")
	return self.queuedActions[slot]
end

-- Returns the action that is currently in the given slot, or Action.NIL if the slot is empty.
function RealGameModel:GetAction(slot)
	assert(slot >= 1 and slot <= AS2.NUM_ACTION_SLOTS, "INVALID_ID")
	local type, id = GetActionInfo(slot)
	if not type then
		return Action.NIL
	else
		-- GetActionInfo() returns names for equipment sets instead of IDs.  Get the ID.
		if type == "equipmentset" then
			id = self:private_FindEquipmentSet(id)
			assert(id ~= nil)	-- (should have been guaranteed to find it)

		-- De-morph spell IDs, if possible.
		elseif type == "spell" then
			id = self:GetUnmorphedSpellID(id)
		end

		return Action:Create(type, id)
	end
end

-- Returns true if there is currently a pending apply operation, or false otherwise.
function RealGameModel:IsApplyPending()
	return self.applyActionsTimer ~= nil
end

-- Clears any queued actions.
function RealGameModel:ClearQueued()
	wipe(self.queuedActions)
	wipe(self.queuedKeybindings)
end

-- Clears all glyph targets.
function RealGameModel:ClearGlyphTargets()
	wipe(self.targetGlyphs)
	AS2:SendMessage(AS2, "GlyphTargetsCleared")
end

-- Clears all talent targets.
function RealGameModel:ClearTalentTargets()
	wipe(self.targetTalents)
	AS2:SendMessage(AS2, "TalentTargetsCleared")
end

-- (no-op, as auto-apply of glyphs only happens on the virtual model)
function RealGameModel:AutoApplyGlyphs()
end

-- (no-op, as auto-apply of talents only happens on the virtual model)
function RealGameModel:AutoApplyTalents()
end

-- Returns the ID of the specified equipment set, since GetActionInfo returns a name
-- and there's currently no API mechanism to get from name to ID.
function RealGameModel:private_FindEquipmentSet(name)
	for i = 1,GetNumEquipmentSets() do
		if (GetEquipmentSetInfo(i)) == name then
			return i
		end
	end
	return nil
end

-- Returns the currently active talent spec (1 or 2)
function RealGameModel:GetActiveSpec()
	return GetActiveSpecGroup(false, false)
end

-- Sets the active talent spec (1 or 2) [used by test code]
function RealGameModel:SetActiveSpec(spec)
	assert(spec >= 1 and spec <= AS2.NUM_SPECS, "INVALID_ID")
	SetActiveSpecGroup(spec)
end

function RealGameModel.private_OnApplyActionsTimerElapsed()
	local self = RealGameModel

	-- If in combat lockdown, apply will fail.
	if InCombatLockdown() then
		local currentTime = time()
		if not self.lastWarningTime or currentTime - self.lastWarningTime >= 5 then
			AS2:Print(L["APPLY_FAILED_IN_COMBAT"])
			self.lastWarningTime = currentTime
		end

		self.applyActionsTimer = AS2:ScheduleTimer(self.private_OnApplyActionsTimerElapsed, AS2.APPLY_INTERVAL)
		return
	end

	-- After the first attempt, accept anything placed that's not nil.  Pre-nil each slot
	-- to make sure we're not accepting old items.
	local tryAcceptIfNotNil = self.retryCount > 0
	
	local applyFailed = false
	local bindingsChanged = false
	if GetCursorInfo() ~= nil then	-- (if the user picked up something, don't clear it!)
		applyFailed = true
	else
		for slot,action in pairs(self.queuedActions) do
			
			local acceptIfNotNil = false	-- ACTUALLY accept anything that's not nil?  Safeguard against placement failure.

			if not Action:Equals(action, self:GetAction(slot)) then
				
				if action ~= Action.NIL then

					-- Pre-clear the slot if accepting anything that's not nil
					if tryAcceptIfNotNil then
						PickupAction(slot)
						ClearCursor()
					end

					-- Try to pick up the action and put it into the slot.
					action = Action:Pickup(action)
					if GetCursorInfo() then
						PlaceAction(slot)
						ClearCursor()	-- (exchange may have occurred)
						acceptIfNotNil = tryAcceptIfNotNil		-- We placed something!  Allow "accept if not nil", if that's what we're doing.
						AS2:Debug(AS2.ACTION, "Placed", Action:ToString(action), "into slot", slot)
					else
						AS2:Debug(AS2.WARNING, "PICKUP FAILURE:", Action:ToString(action))
						action = Action.NIL		-- (clear the slot instead)
					end
				end

				-- Remove an action from the slot if needed.
				if action == Action.NIL then	-- (do NOT use elseif)
					PickupAction(slot)
					ClearCursor()
				end
			end

			-- Verify that the put was successful
			local newAction = self:GetAction(slot)
			if Action:Equals(action, newAction) or (acceptIfNotNil and action ~= Action.NIL) then
				self.queuedActions[slot] = nil
			else
				applyFailed = true
			end
		end
	end

	for key,command in pairs(self.queuedKeybindings) do
		-- If not already placed...
		local commandInSlot = self:GetKeybinding(key)
		if command == commandInSlot then
			self.queuedKeybindings[key] = nil
		else
			local actualCommand = command ~= Binding.NIL and command or nil -- (... ? command : nil)
			if SetBinding(key, actualCommand) == 1 then
				AS2:Debug(AS2.ACTION, "Bound", actualCommand, "to key", key)
				self.queuedKeybindings[key] = nil
				bindingsChanged = true
			else
				applyFailed = true
			end
		end

		-- Note: We can't verify keybindings in the way we can actions, since it doesn't report
		-- failure when setting / getting a nonexistant keybinding.  Therefore, we assume the
		-- success result given by SetBinding is accurate.
	end

	-- Save the bindings if something changed.
	if bindingsChanged then
		SaveBindings(2) -- 2 = char-specific
	end

	-- Re-schedule the apply if not done.
	if applyFailed then
		self.retryCount = self.retryCount + 1
		if self.retryCount == 1 then
			-- (shorter delay the first time, and no error message)
			self.applyActionsTimer = AS2:ScheduleTimer(self.private_OnApplyActionsTimerElapsed, AS2.APPLY_INTERVAL_0)
		else
			self.applyActionsTimer = AS2:ScheduleTimer(self.private_OnApplyActionsTimerElapsed, AS2.APPLY_INTERVAL)

			local currentTime = time()
			if not self.lastWarningTime or currentTime - self.lastWarningTime >= 5 then
				AS2:Print(L["APPLY_FAILED"])
				self.lastWarningTime = currentTime
			end
		end
	else
		self.retryCount = 0
		self.applyActionsTimer = nil
		AS2:SendMessage(AS2, "ApplyFinished")
	end
end

-- Returns the current time, in seconds since 1/1/1970.
function RealGameModel:GetTime()
	return time()	-- (yes, this method is necessary; the virtual version can return false time values for testing backup creation)
end

-- Returns true if character-specific bindings are enabled, or false otherwise.
function RealGameModel:IsCharSpecificBindings()
	return GetCurrentBindingSet() == 2
end

-- Returns the command queued to be bound to the given key, Binding.NIL if it's to be unbound, or nil if no binding is queued.
function RealGameModel:GetQueuedKeybinding(key)
	assert(key, "NIL_ARGUMENT")
	return self.queuedKeybindings[key]
end

-- Returns the command bound to a given key, or Binding.NIL if the key is unbound.
function RealGameModel:GetKeybinding(key)
	assert(key, "NIL_ARGUMENT")
	local result = GetBindingByKey(key)
	if not result or result == "" then return Binding.NIL end
	return result
end

-- Queues the given command to be bound to the given key.  Use Binding.NIL to unbind the key.
function RealGameModel:SetQueuedKeybinding(key, command)
	assert(key and command, "NIL_ARGUMENT")
	self.queuedKeybindings[key] = command

	-- Start the "apply actions" timer if not already started. (immediate the first time)
	if not self.applyActionsTimer then
		self.applyActionsTimer = AS2:ScheduleTimer(self.private_OnApplyActionsTimerElapsed, 0)
	end
end

-- Returns the number of keybinding commands currently set.
function RealGameModel:GetNumKeybindings()
	return GetNumBindings()
end

-- Returns command, key1, key2, ... for the binding at the given index.
function RealGameModel:GetKeybindingByIndex(index)
	return GetBinding(index)
end

-- (this is only implemented in the virtual model)
function RealGameModel:MakeCommandInvalid(command)
end

-- Sets the target glyph for the given glyph slot.
function RealGameModel:SetTargetGlyph(slot, glyphID)
	assert(slot >= 1 and slot <= AS2.NUM_GLYPH_SLOTS, "INVALID_ID")
	self.targetGlyphs[slot] = glyphID
end

-- Returns the target glyph for the given glyph slot. (nil if no target)
function RealGameModel:GetTargetGlyph(slot)
	assert(slot >= 1 and slot <= AS2.NUM_GLYPH_SLOTS, "INVALID_ID")
	return self.targetGlyphs[slot]
end

-- Returns the ID of the glyph actually in the given glyph slot. (nil if empty)
function RealGameModel:GetGlyph(slot)
	assert(slot >= 1 and slot <= AS2.NUM_GLYPH_SLOTS, "INVALID_ID")
	local _, _, _, glyphID = GetGlyphSocketInfo(slot)
	return glyphID
end

-- Sets the target talent for the given talent slot.
function RealGameModel:SetTargetTalent(slot, talentID)
	assert(slot >= 1 and slot <= AS2.NUM_TALENT_SLOTS, "INVALID_ID")
	self.targetTalents[slot] = talentID
end

-- Returns the ID (1 - 3) of the target talent for the given talent slot (1 - 6). (nil if no target)
function RealGameModel:GetTargetTalent(slot)
	assert(slot >= 1 and slot <= AS2.NUM_TALENT_SLOTS, "INVALID_ID")
	return self.targetTalents[slot]
end

-- Returns the ID (1 - 3) of the talent actually in the given talent slot (1 - 6). (nil if empty)
function RealGameModel:GetTalent(slot)
	assert(slot >= 1 and slot <= AS2.NUM_TALENT_SLOTS, "INVALID_ID")
	local baseIndex = (slot - 1) * AS2.NUM_TALENTS_PER_SLOT		-- (one less than the first)
	for i = 1, AS2.NUM_TALENTS_PER_SLOT do
		local _, _, _, _, learned = GetTalentInfo(baseIndex + i)
		if learned then return i end
	end
	return nil	-- (no talent in this slot)
end

-- Resets the unmorphed spell map - this should be done anytime the spellbook changes.
function RealGameModel:ResetSpellMap()
	self.unmorphedSpellMap = nil
end

-- Validates the unmorphed spell map - this is called automatically by GetUnmorphedSpellID.
function RealGameModel:ValidateSpellMap()
	if not self.unmorphedSpellMap then
		self.unmorphedSpellMap = { }
		
		-- Currently, the WoW API has no direct means of mapping from morphed spell ID to
		-- base spell ID, so we have to take a guess by matching the spell name to information
		-- in the spellbook.  To prevent increasing the complexity of record operations, generate
		-- a mapping every time the spell book changes.
		for i = 1, GetNumSpellTabs() do
			local _, _, offset, numSpells, _, offSpecID = GetSpellTabInfo(i)
			for j = offset + 1, offset + numSpells do
				local skillType, unmorphedSpellID = GetSpellBookItemInfo(j, "spell")
				if skillType == "SPELL" and unmorphedSpellID then
					local morphedSpellName = GetSpellBookItemName(j, "spell")
					if morphedSpellName then
						if self.unmorphedSpellMap[morphedSpellName] == nil then		-- (only accept the first one - this prioritizes the active spec)
							self.unmorphedSpellMap[morphedSpellName] = unmorphedSpellID
						end
					end
				elseif skillType == "FLYOUT" and unmorphedSpellID then
					local flyoutID = unmorphedSpellID
					local _, _, numFlyoutSlots = GetFlyoutInfo(flyoutID)
					for k = 1, numFlyoutSlots do
						local unmorphedSpellID, _, _, morphedSpellName = GetFlyoutSlotInfo(flyoutID, k)
						if morphedSpellName and unmorphedSpellID then
							if self.unmorphedSpellMap[morphedSpellName] == nil then		-- (only accept the first one - this prioritizes the active spec)
								self.unmorphedSpellMap[morphedSpellName] = unmorphedSpellID
							end
						end
					end
				end
			end
		end
	end
end

-- Attempts to transform a morphed spell ID into an unmorphed spell ID.
-- Returns the same ID if an unmorphed version could not be found.
function RealGameModel:GetUnmorphedSpellID(morphedSpellID)
	self:ValidateSpellMap()
	local spellName = GetSpellInfo(morphedSpellID)
	if self.unmorphedSpellMap[spellName] then
		return self.unmorphedSpellMap[spellName]
	else
		return morphedSpellID
	end
end
