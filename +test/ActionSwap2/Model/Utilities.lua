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
local Utilities = AS2.Model.Utilities
local Action = AS2.Model.Action

-- Mapping from action button command prefix to the index of its first button, minus one
local COMMAND_MAPPING = {
	ACTIONBUTTON = 0,				-- Primary buttons; SHARED between first 6 pages
	MULTIACTIONBAR1BUTTON = 60,		-- Bottom left buttons; also page 6
	MULTIACTIONBAR2BUTTON = 48,		-- Bottom right buttons; also page 5
	MULTIACTIONBAR3BUTTON = 24,		-- Right buttons; also page 3
	MULTIACTIONBAR4BUTTON = 36		-- Right buttons 2; also page 4
}

local recognizedOverrides
local memorizedSlots
local memorizedButtons = { }

local GLYPH_TYPES = {
	[GLYPH_ID_MAJOR_1] = GLYPH_TYPE_MAJOR,
	[GLYPH_ID_MAJOR_2] = GLYPH_TYPE_MAJOR,
	[GLYPH_ID_MAJOR_3] = GLYPH_TYPE_MAJOR,
	[GLYPH_ID_MINOR_1] = GLYPH_TYPE_MINOR,
	[GLYPH_ID_MINOR_2] = GLYPH_TYPE_MINOR,
	[GLYPH_ID_MINOR_3] = GLYPH_TYPE_MINOR
}
assert(#GLYPH_TYPES == AS2.NUM_GLYPH_SLOTS)

local previousGlyphPlacements	-- Previous glyph placement; reset every time the target glyphs are cleared

-- Initializes certain pieces of data the first time they are used.
function Utilities:private_Init()
	if not memorizedSlots then
		-- As I have yet to find an example of an override binding being used for anything other than action buttons
		-- 1 through 12.  Only allow these slots to prevent unforseen addon incompatibilities.
		assert(not recognizedOverrides)
		recognizedOverrides = { }
		for offset = 1, 12 do
			recognizedOverrides["ACTIONBUTTON" .. offset] = true
		end

		-- Pre-memorize certain commands so we don't have to parse them later.
		memorizedSlots = { }
		local _, class = UnitClassBase("PLAYER")
		for prefix, baseIndex in pairs(COMMAND_MAPPING) do
			for offset = 1, 12 do
				memorizedSlots[prefix .. offset] = baseIndex + offset
			end
		end
	end
end

-- (Helper function for QuickParseSlotFromCommand)
function Utilities:private_QuickParseSlotFromCommand(command)
	if not command then return nil end

	-- Return the already-memorized slot if possible.
	local slot = memorizedSlots[command]
	if slot then return slot end

	-- Try to parse a button from the command instead, then calculate it's action.
	local button = self:private_QuickParseButtonFromCommand(command)
	if button then
		local slot = ActionButton_CalculateAction(button, "LeftButton")
		if type(slot) == "number" and slot >= 1 and slot <= AS2.NUM_ACTION_SLOTS then return slot else return nil end
	end

	return nil	-- No slot known for this command.
end

-- (Helper function for QuickParseButtonFromCommand)
function Utilities:private_QuickParseButtonFromCommand(command)
	if not command then return nil end

	-- If we've already figured out which button it corresponds to.
	local button = memorizedButtons[command]
	if button then return button end

	-- MAINTENANCE: Does case matter?  Can you use click or Click?  Or LEFTBUTTON?
	-- Test for clicks on secure template buttons; this should work for most action bar addons.
	if strsub(command, 1, 6) == "CLICK " then	-- (for efficiency)
		local buttonName = strmatch(command, "^CLICK (.+):LeftButton$")
		if buttonName then
			button = _G[buttonName]
			if button then
				memorizedButtons[command] = button
				return button
			end
		end
	end

	return nil	-- No button known for this command.
end

-- Returns the slot associated with the given keybinding command.
-- (memorizes the results when possible)
function Utilities:QuickParseSlotFromCommand(command)
	if not command then return nil end

	self:private_Init()

	-- If we've previously encountered an override for this command, try that first.  But only
	-- if the command corresponds to one of the predefined slots (otherwise, it starts thinking
	-- pet buttons correspond to action slots 1-12, and all kinds of other bad things)
	if memorizedSlots[command] then
		local override = AS2.activeModel:GetLastKnownOverride(command)
		if override and override ~= command then
			local slot = Utilities:private_QuickParseSlotFromCommand(override)
			if slot then	-- (default to original command if can't find a slot)
				return slot
			end
		end
	end

	return Utilities:private_QuickParseSlotFromCommand(command)
end


-- Returns the button associated with the given keybinding command.
-- (memorizes the results when possible)
function Utilities:QuickParseButtonFromCommand(command)
	if not command then return nil end

	self:private_Init()

	-- If there's a known override for this command, try that first.
	local override = AS2.activeModel:GetLastKnownOverride(command)
	if override and override ~= command then
		local button = Utilities:private_QuickParseButtonFromCommand(override)
		if button then	-- (default to original command if can't find a button)
			return button
		end
	end

	return Utilities:private_QuickParseButtonFromCommand(command)
end

-- Returns true if override bindings are recognized / accepted for the given command.
function Utilities:AreOverridesRecognized(originalCommand)
	self:private_Init()
	return recognizedOverrides[originalCommand]
end

-- Returns the ID of the opposite spec.
function Utilities:GetOtherSpec(spec)
	if not spec then spec = AS2.activeGameModel:GetActiveSpec() end
	if spec == 1 then return 2
	elseif spec == 2 then return 1
	else error("INVALID_ID") end
end

-- Returns the slot the given glyph is equipped in, or nil if it's not equipped.
function Utilities:FindEquippedGlyph(glyphID)
	for slot = 1, AS2.NUM_GLYPH_SLOTS do
		if AS2.activeGameModel:GetGlyph(slot) == glyphID then
			return slot
		end
	end
	return nil
end

-- Computes which target glyphs should be placed where, taking into account current glyph placement.  This
-- function is responsible for glyph slot insensitivity; before it was added, glyphs needed to be placed
-- in specific slots.
--
-- THIS IS AN EXTREMELY EXPENSIVE OPERATION.  DO NOT CALL IT OFTEN.
--
-- Note: The results of this function must be consistent between one call and the next until either a glyph
-- or target glyph chanages.
function Utilities:ComputeGlyphPlacements()
	-- Every time the glyph targets are cleared, also clear the memorized glyph placements.
	if not previousGlyphPlacements then
		previousGlyphPlacements = { }
		AS2:AddCallback(AS2, "GlyphTargetsCleared", function(self)
			wipe(previousGlyphPlacements)
		end, self)
	end

	local result = { }			-- Mapping from slot => target glyph
	local finalGlyphSet = { }	-- Set of target glyphs overlaid on set of current glyphs
	local targetGlyphMap = { }	-- Mapping from unplaced target glyph => desired slot
	local currentGlyphMap = { }	-- Mapping from slot => glyph currently in slot

	local function pickGlyphOfType(type)
		for targetGlyph, slot in pairs(targetGlyphMap) do
			if GLYPH_TYPES[slot] == type then
				return targetGlyph, slot
			end
		end
	end

	-- Compute the final set of glyphs that should remain.
	for slot = 1, AS2.NUM_GLYPH_SLOTS do
		local targetGlyph = AS2.activeGameModel:GetTargetGlyph(slot)
		local actualGlyph = AS2.activeGameModel:GetGlyph(slot)
		currentGlyphMap[slot] = actualGlyph
		if targetGlyph then
			finalGlyphSet[targetGlyph] = true
			targetGlyphMap[targetGlyph] = slot
		elseif actualGlyph then
			finalGlyphSet[actualGlyph] = true
		end
	end

	-- Remove any target glyphs that are already placed.
	for slot, actualGlyph in pairs(currentGlyphMap) do
		targetGlyphMap[actualGlyph] = nil
	end

	-- Place each remaining target glyph in its desired slot, but only if (a) the glyph already there isn't part of the final set, or (b) there is no glyph placed there.
	for targetGlyph, slot in pairs(targetGlyphMap) do
		local actualGlyph = currentGlyphMap[slot]
		if not result[slot] and (not actualGlyph or not finalGlyphSet[actualGlyph]) then
			result[slot] = targetGlyph
			targetGlyphMap[targetGlyph] = nil		-- (prevent the glyph from being placed again)
		end
	end

	-- Place each remaining target glyph in the slot it was previously placed in if possible. (needed for consistency)
	for targetGlyph, oldSlot in pairs(targetGlyphMap) do
		local slot = previousGlyphPlacements[targetGlyph]
		if slot then	-- (don't need to check the slot type)
			local actualGlyph = currentGlyphMap[slot]
			if not result[slot] and (not actualGlyph or not finalGlyphSet[actualGlyph]) then
				result[slot] = targetGlyph
				targetGlyphMap[targetGlyph] = nil		-- (prevent the glyph from being placed again)
			end
		end
	end

	-- Place any remaining target glyphs in any non-empty slot for which the glyph isn't part of the target set.
	-- (don't needlessly use up extra slots - it's bad for low-level chars that don't have them all unlocked)
	for slot = 1, AS2.NUM_GLYPH_SLOTS do
		local actualGlyph = currentGlyphMap[slot]
		if not result[slot] and (actualGlyph and not finalGlyphSet[actualGlyph]) then
			local targetGlyph = pickGlyphOfType(GLYPH_TYPES[slot])
			if targetGlyph then
				result[slot] = targetGlyph
				targetGlyphMap[targetGlyph] = nil		-- (prevent the glyph from being placed again)
			end
		end
	end

	-- Place any remaining target glyph in any slot that's empty.
	for slot = 1, AS2.NUM_GLYPH_SLOTS do
		local actualGlyph = currentGlyphMap[slot]
		if not result[slot] and not actualGlyph then
			local targetGlyph = pickGlyphOfType(GLYPH_TYPES[slot])
			if targetGlyph then
				result[slot] = targetGlyph
				targetGlyphMap[targetGlyph] = nil		-- (prevent the glyph from being placed again)
			end
		end
	end

	-- Record the glyph placements for next time.
	for slot, glyph in pairs(result) do
		previousGlyphPlacements[glyph] = slot
	end

	if AS2.DEBUG then assert(next(targetGlyphMap, nil) == nil, "There were leftover glyphs!") end

	return result
end

-- Returns a string containing the names of all spells in the given action set that couldn't be
-- picked up (i.e., aren't part of the current specialization).  Returns nil if all spells were
-- able to be picked up, or the button set couldn't be found.  Non-spell actions are not checked
-- by this function.
function Utilities:GenerateSpellNotFoundString(buttonSetList, buttonSet, actionSet)
	local result = nil
	ClearCursor()
	if buttonSet and actionSet then
		local buttonSetIndex = buttonSetList:FindButtonSet(buttonSet)
		if buttonSetIndex then
			local actionsTable = actionSet:GetActionsTable()
			for slot, action in actionsTable:Pairs() do
				if buttonSetList:GetAssignedButtonSetForSlot(slot) == buttonSetIndex then
					if action ~= Action.NIL then
						local actionType, actionID = Action:GetTypeAndID(action)
						if actionType == "spell" and actionID then
							PickupSpell(actionID)
							if GetCursorInfo() == nil then
								local spellName = GetSpellInfo(actionID) or ("(" .. L["unknown spell"] .. " #" .. actionID .. ")")
								if result then
									result = result .. ", " .. spellName
								else
									result = spellName
								end
							end
							ClearCursor()
						end
					end
				end
			end
		end
	end
	return result
end
