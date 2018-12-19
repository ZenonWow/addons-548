--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local Action = AS2.Model.Action

Action.NIL = 0	-- Explicit representation of "no action", as opposed to nil, which can mean "no data / not known"

-- Creates an action from the specified type and id.
function Action:Create(type, id)
	assert(type and id)

	-- Save extra information for macros and equipment sets, since they don't have global IDs to identify them with.
	local name, texture, body
	if type == "macro" then
		name, texture, body = GetMacroInfo(id)
	elseif type == "equipmentset" then
		name, texture = GetEquipmentSetInfo(id)
	end

	return { type, id, name, texture, body }
end

-- Returns the type and ID of the action
function Action:GetTypeAndID(action)
	if action == Action.NIL then
		return nil
	else
		return action[1], action[2]
	end
end

-- Returns the index of the given flyout in the spellbook.
function Action:private_FindFlyoutInSpellbook(flyoutID)
	for spellTab = 1, GetNumSpellTabs() do
		local _, _, offset, numSpells = GetSpellTabInfo(spellTab)
		for slot = offset + 1, offset + numSpells do
			local skillType, spellID = GetSpellBookItemInfo(slot, "SPELL")	-- (returns flyout ID, not a real spell ID)
			if skillType == "FLYOUT" and flyoutID == spellID then
				return slot
			end
		end
	end
end

-- Scores a macro based on how closely its name, texture, and body match the target.
local function getMacroScore(id, searchName, searchTexture, searchBody)
	local name, texture, body = GetMacroInfo(id)
	return (name and searchName and strlower(name) == strlower(searchName) and 4 or 0) +		-- 4 points for a name match
		(body and searchBody and strlower(body) == strlower(searchBody) and 2 or 0) +			-- 2 points for a body match
		(texture and searchTexture and strlower(texture) == strlower(searchTexture) and 1 or 0)	-- 1 point for a texture match
end

-- Finds the best guess for the given macro, given its last-known state.
-- This is a workaround for the fact that macros don't have identifiers, and there is no exact technique to identify a macro based on a previous state.
local function findBestMacroMatch(guessID, name, texture, body)
	local score = getMacroScore(guessID, name, texture, body)

	-- If the first guess yields at least 4 points (a name match), then don't go any further.
	if score >= 4 then return guessID end

	-- Otherwise, take the macro with the best score (and the least distance, if competition)
	local bestScore = 0
	local bestDistance = 999	-- (anything higher than the max distance)
	local bestID = nil
	for i = 1, AS2.NUM_MACRO_SLOTS do
		score = getMacroScore(i, name, texture, body)
		if score > 0 then
			if score > bestScore then
				bestID = i
				bestScore = score
				bestDistance = abs(i - guessID)
			elseif score == bestScore then
				local distance = abs(i - guessID)
				if distance < bestDistance then
					bestID = i
					bestDistance = distance
					-- (bestScore already equal)
				end
			end
		end
	end
	return bestID
end

-- Scores an equipment set based on how closely its name and texture match the target.
local function getEquipmentSetScore(id, searchName, searchTexture)
	local name, texture = GetEquipmentSetInfo(id)
	return (name and searchName and strlower(name) == strlower(searchName) and 4 or 0) +		-- 4 points for a name match
		(texture and searchTexture and strlower(texture) == strlower(searchTexture) and 2 or 0)	-- 2 point for a texture match
																			-- (would be 1 point for a content match, but we're not checking contents)
end

-- Finds the best guess for the given equipment set, given its last-known state.
-- This is a workaround for the fact that equipment sets don't have identifiers, and there is no exact technique to identify a equipment set based on a previous state.
local function findBestEquipmentSetMatch(guessID, name, texture)
	local score = getEquipmentSetScore(guessID, name, texture)

	-- If the first guess yields at least 4 points (a name match), then don't go any further.
	if score >= 4 then return guessID end

	-- Otherwise, take the equipment set with the best score (and the least distance, if competition)
	local bestScore = 0
	local bestDistance = 999	-- (anything higher than the max distance)
	local bestID = nil
	for i = 1, GetNumEquipmentSets() do
		score = getEquipmentSetScore(i, name, texture)
		if score > 0 then
			if score > bestScore then
				bestID = i
				bestScore = score
				bestDistance = abs(i - guessID)
			elseif score == bestScore then
				local distance = abs(i - guessID)
				if distance < bestDistance then
					bestID = i
					bestDistance = distance
					-- (bestScore already equal)
				end
			end
		end
	end
	return bestID
end

-- Picks up the given action.  Returns the coerced action if something other than the specified action was picked up.
function Action:Pickup(action)
	if action == Action.NIL then
		-- (Do nothing)
	elseif action[1] == "spell" or action[1] == "companion" then
		PickupSpell(action[2])
	elseif action[1] == "macro" then
		local bestMatch = findBestMacroMatch(action[2], action[3], action[4], action[5])
		if bestMatch then
			PickupMacro(bestMatch)
			if bestMatch ~= action[2] then	-- (coerce to best match)
				local name, texture, body = GetMacroInfo(bestMatch)
				return { action[1], bestMatch, name, texture, body }
			end
		end
	elseif action[1] == "item" then
		PickupItem(action[2])
	elseif action[1] == "equipmentset" then
		local bestMatch = findBestEquipmentSetMatch(action[2], action[3], action[4])
		if bestMatch then
			PickupEquipmentSet(bestMatch)
			if bestMatch ~= action[2] then	-- (coerce to best match)
				local name, texture = GetEquipmentSetInfo(bestMatch)
				return { action[1], bestMatch, name, texture }
			end
		end
	elseif action[1] == "flyout" then
		-- Since there is no PickupFlyout function, we have to scan the spellbook manually.
		local slot = self:private_FindFlyoutInSpellbook(action[2])
		if slot then PickupSpellBookItem(slot, "SPELL") end
	elseif action[1] == "summonpet" then
		C_PetJournal.PickupPet(action[2])
	else
		assert(false, "Unknown action type: " .. tostring(action[1]))
	end
	return action
end

-- Returns the icon for the action represented, or nil if there is none
function Action:GetIcon(action)
	if action == Action.NIL then
		return nil
	elseif action[1] == "spell" or action[1] == "companion" then
		return GetSpellTexture(action[2])
	elseif action[1] == "macro" then
		local bestMatch = findBestMacroMatch(action[2], action[3], action[4], action[5])
		if bestMatch then
			local _, icon = GetMacroInfo(bestMatch)
			return icon
		end
	elseif action[1] == "item" then
		return GetItemIcon(action[2])
	elseif action[1] == "equipmentset" then
		local bestMatch = findBestEquipmentSetMatch(action[2], action[3], action[4])
		if bestMatch then
			local _, icon = GetEquipmentSetInfo(bestMatch)
			return icon
		end
	elseif action[1] == "flyout" then
		-- Since there is no GetFlyoutTexture function, we have to scan the spellbook manually.
		local slot = self:private_FindFlyoutInSpellbook(action[2])
		if slot then return GetSpellBookItemTexture(slot, "SPELL") end
	elseif action[1] == "summonpet" then
		-- As of patch 5.2, the pet ID must be a 64-bit hexadecimal *string*, so convert any integer
		-- pet number that may have come from previous patches.
		local hexString = action[2]
		if type(hexString) == "number" then
			hexString = format("0x%016X", hexString)
		end
		return select(9, C_PetJournal.GetPetInfoByPetID(hexString))
	else
		assert(false, "Unknown action type: " .. tostring(action[1]))
	end
end

-- Returns true if the specified actions are equivalent or false otherwise.
-- (if coerce is specified, allows for macro / equipment set coersion)
function Action:Equals(action1, action2, coerce)
	if not action1 or not action2 or action1 == Action.NIL or action2 == Action.NIL then
		return action1 == action2
	elseif coerce and action1[1] == "macro" and action2[1] == "macro" then		-- (allow macro coersion)
		return findBestMacroMatch(action1[2], action1[3], action1[4], action1[5]) == findBestMacroMatch(action2[2], action2[3], action2[4], action2[5])
	elseif coerce and action1[1] == "equipmentset" and action2[1] == "equipmentset" then	-- (allow equipment set coersion)
		return findBestEquipmentSetMatch(action1[2], action1[3], action1[4]) == findBestEquipmentSetMatch(action2[2], action2[3], action2[4])
	else
		-- (compare de-morphed spell IDs, where known)
		local id1 = action1[2]
		local id2 = action2[2]
		if action1[1] == "spell" then id1 = AS2.activeGameModel:GetUnmorphedSpellID(id1) end
		if action2[1] == "spell" then id2 = AS2.activeGameModel:GetUnmorphedSpellID(id2) end
		return action1[1] == action2[1] and id1 == id2
	end
end

-- Returns true if the data contained in the specified action objects is exactly equal.
function Action.Comparator(action1, action2)
	if not action1 or not action2 or action1 == Action.NIL or action2 == Action.NIL then
		return action1 == action2
	else
		return action1[1] == action2[1] and action1[2] == action2[2] and action1[3] == action2[3] and action1[4] == action2[4] and action1[5] == action2[5]
	end
end

-- Formats the given action for printing.
function Action:ToString(action)
	if action == Action.NIL then
		return "action:NIL"
	else
		return "action:(" .. tostring(action[1]) .. " " .. tostring(action[2]) .. " " .. tostring(action[3]) .. " " .. tostring(action[4]) .. " " .. tostring(action[5]) .. ")"
	end
end
