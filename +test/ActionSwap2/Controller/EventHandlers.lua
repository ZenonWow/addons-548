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
local Action = AS2.Model.Action
local ActionSet = AS2.Model.ActionSet
local EventHandlers = AS2.Controller.EventHandlers
local SlotData = AS2.Model.SlotData
local UIOperations = AS2.Controller.UIOperations
local Utilities = AS2.Model.Utilities

local lastKnownBindingsList = { }		-- (mapping of command => { key1=true, key2=true, ... } - used for detecting changes)
local lastKnownTalents = { }			-- (mapping of slot => talent - used for detecting changes)
local firstBindingsUpdate = true		-- (prevents add / remove messages on the first update)
local firstTalentsUpdate = true			-- (prevents add / remove messages on the first update)
local loginOccurred = false				-- Has the login event occurred?
local initialRecord = true				-- Have we recorded for the first time?
local backups = { }
local delayedActionRecords = { }
local delayedTalentRemoved = { }
local delayedTalentAdded = { }

local talentWipeID = nil
local TALENT_WIPE_TALENTS = 1
local TALENT_WIPE_SPECIALIZATION = 2
local TALENT_WIPE_GLYPHS = 3

function EventHandlers:OnLogin()
	if not AS2:IsLoaded() then return end
	AS2:Debug(AS2.EVENT, "OnLogin")

	-- NOTE: Don't do anything that should only be done once in this function; logins will be simulated many times by the test code.

	loginOccurred = true
	initialRecord = true	-- (calling OnLogin resets the initial record; used by test code)

	-- Ignore any spec change event that may have occurred at login. (this generally
	-- happens the first time you log into a character, but not on reload UI)
	AS2.ticksSinceSpecChange = nil
end

function EventHandlers:OnModelSwitch()
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnModelSwitch")

	-- Make sure an initial binding / talent update occurs, so that change detection works.
	firstTalentsUpdate = true
	firstBindingsUpdate = true
	EventHandlers:OnUpdateBindings()	-- TODO: If bindings update is delayed, then how is RecordAll() not recording before the initial update?
	EventHandlers:OnTalentsUpdated()
end

function EventHandlers:OnActionChanged(slot)
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnActionChanged slot:", slot)

	if slot and slot >= 1 and slot <= AS2.NUM_ACTION_SLOTS then
		-- Ignore all action changes caused by a spec change.
		if not AS2.ticksSinceSpecChange then
			-- (action changes caused by apply are already ignored, as active sets go to nil as they are being applied)

			-- Delay the record of the action, in case the change was in response to an unlearned spell.
			-- There's no event corresponding to the unlearning of a spell, so we have to make sure NOT
			-- to record the downgrade of "Inferno Blast" to "Fire Blast" and the like by waiting to see
			-- if we get a ACTIVE_TALENT_GROUP_CHANGED event.
			tinsert(delayedActionRecords, slot)
		end
	end
end

-- Processes all pending action record operations
function EventHandlers:ProcessDelayedRecords()
	while true do
		local slot = tremove(delayedActionRecords)
		if not slot then break end

		-- Record the change to the active action set for the slot.
		AS2.activeModel:RecordActionForSlot(slot)
	end

	while true do
		local slot = tremove(delayedTalentRemoved)
		if not slot then break end
		AS2.activeModel:RecordTalentForSlot(slot)
		AS2:SendMessage(AS2, "TalentRemoved", slot)
	end

	while true do
		local slot = tremove(delayedTalentAdded)
		if not slot then break end
		AS2.activeModel:RecordTalentForSlot(slot)
		AS2:SendMessage(AS2, "TalentAdded", slot)
	end
end

-- Cancels all pending action record operations
function EventHandlers:CancelDelayedRecords()
	wipe(delayedActionRecords)
	wipe(delayedTalentRemoved)
	wipe(delayedTalentAdded)
end

function EventHandlers:OnActiveSpecChanged()
	if not AS2:IsLoaded() or initialRecord then return end
	-- ** IMPORTANT NOTE ** This is called BEFORE the actions associated with a spec are placed.
	AS2:Debug(AS2.EVENT, "OnActiveSpecChanged", AS2.activeGameModel:GetActiveSpec())
	
	-- Assume any action changes that occurred this update were caused by a spec change.
	self:CancelDelayedRecords()

	AS2.ticksSinceSpecChange = 0		-- (for the AfterActiveSpecChanged event)
end

function EventHandlers:AfterActiveSpecChanged()
	-- ** IMPORTANT NOTE ** This will only be called if at least one action changes as a result of the spec change.
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "AfterActiveSpecChanged")

	assert(AS2.NUM_SPECS == 2)	-- The following code is hardcoded for two specs.

	local buttonSetList = AS2.activeModel.buttonSetList
	local glyphSetList = AS2.activeModel.glyphSetList
	local talentSetList = AS2.activeModel.talentSetList
	local globalKeysetList = AS2.activeModel.globalKeysetList

	-- Cancel any in-progress spec changes.
	AS2.activeModel:CancelActionSetAndGlobalKeysetActivations()
	AS2.activeModel:CancelGlyphSetActivation()
	AS2.activeModel:CancelTalentSetActivation()

	-- Start keeping track of discrepencies / removals.
	self:private_BeginWatchingDiscrepencies()

	-- Record all slots that don't share an action set between specs.
	for slot = 1, AS2.NUM_ACTION_SLOTS do
		local buttonSetIndex = buttonSetList:GetAssignedButtonSetForSlot(slot)
		local buttonSet = buttonSetList:GetButtonSetAt(buttonSetIndex)
		if buttonSet then
			local actionSet_spec1 = buttonSet:GetActiveActionSet(1)
			local actionSet_spec2 = buttonSet:GetActiveActionSet(2)
			if actionSet_spec1 == nil or actionSet_spec1 ~= actionSet_spec2 then
				AS2.activeModel:RecordActionForSlot(slot)
			end
		end
	end

	-- Record all glyphs if the glyph set is not shared.
	local glyphSet_spec1 = glyphSetList:GetActiveGlyphSet(1)
	local glyphSet_spec2 = glyphSetList:GetActiveGlyphSet(2)
	if glyphSet_spec1 == nil or glyphSet_spec1 ~= glyphSet_spec2 then
		for slot = 1, AS2.NUM_GLYPH_SLOTS do
			AS2.activeModel:RecordGlyphForSlot(slot)
		end
	end

	-- [ MAINTENANCE: Ideally, discrepency detection should be tested.  E2E test 2.2 doesn't really test this code because the apply below does a record afterward. ]
	-- Record all talents if the talent set is not shared.
	local talentSet_spec1 = talentSetList:GetActiveTalentSet(1)
	local talentSet_spec2 = talentSetList:GetActiveTalentSet(2)
	if talentSet_spec1 == nil or talentSet_spec1 ~= talentSet_spec2 then
		for slot = 1, AS2.NUM_TALENT_SLOTS do
			AS2.activeModel:RecordTalentForSlot(slot)
		end
	end

	-- Report discrepencies / removals to the user. (note that keybinding discrepencies cannot occur on spec switch)
	self:private_EndWatchingDiscrepencies()

	-- Apply all action sets associated with the new spec.
	for buttonSetIndex = 1, buttonSetList:GetButtonSetCount() do
		local buttonSet = buttonSetList:GetButtonSetAt(buttonSetIndex)
		local actionSetIndex = buttonSet:GetActiveActionSet()
		if actionSetIndex then
			AS2.activeModel:ActivateActionSet(buttonSetIndex, actionSetIndex)
		end
	end

	-- Apply all global keysets associated with the new spec.
	local globalKeysetIndex = globalKeysetList:GetActiveKeyset()
	if globalKeysetIndex then
		AS2.activeModel:ActivateGlobalKeyset(globalKeysetIndex)
	end

	-- Apply the active glyph sets associated with the new spec.
	local glyphSetIndex = glyphSetList:GetActiveGlyphSet()
	if glyphSetIndex then
		UIOperations:EquipGlyphSet(glyphSetList:GetGlyphSetAt(glyphSetIndex))	-- (use the UI for this one)
	end

	-- Apply the active talent sets associated with the new spec.
	local talentSetIndex = talentSetList:GetActiveTalentSet()
	if talentSetIndex then
		UIOperations:EquipTalentSet(talentSetList:GetTalentSetAt(talentSetIndex))	-- (use the UI for this one)
	end

	-- Notify of the spec change.
	AS2:SendMessage(AS2, "AfterActiveSpecChanged")
end

function EventHandlers:OnUpdateBindings()
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnUpdateBindings")

	-- Do not detect changes during in-combat lockdown; certain addons like Bartender may
	-- not set their override bindings until afterward.
	if not firstBindingsUpdate and InCombatLockdown() then return end

	-- Delay the update until well after the event is processed, so that addons like
	-- Bartender get a chance to set override bindings.
	AS2:Dispatch(EventHandlers.DoUpdateBindings, self)
end

function EventHandlers:DoUpdateBindings()
	AS2:Debug(AS2.EVENT, "DoUpdateBindings")

	-- For each binding...
	local removedBindings = { }
	local addedBindings = { }

	local numBindings = GetNumBindings()
	for bindingSlot = 1,numBindings do
		local command = select(1, GetBinding(bindingSlot))
		local newKeys = { select(2, GetBinding(bindingSlot)) }
		if command then
			local lastKnownKeys = lastKnownBindingsList[command]
			if not lastKnownKeys then lastKnownKeys = { }; lastKnownBindingsList[command] = lastKnownKeys end

			-- Detect removal
			for oldKey,_ in pairs(lastKnownKeys) do
				if not tContains(newKeys, oldKey) then
					lastKnownKeys[oldKey] = nil
					removedBindings[oldKey] = command
				end
			end

			-- Detect addition
			for _,newKey in ipairs(newKeys) do
				if not lastKnownKeys[newKey] then
					local override = GetBindingByKey(newKey)
					if override and command ~= override then
						AS2.activeModel:SetLastKnownOverride(command, override)
					end
					lastKnownKeys[newKey] = true
					if not firstBindingsUpdate then
						addedBindings[newKey] = command
					end
				end
			end
		end
	end

	if firstBindingsUpdate then
		AS2:Debug(AS2.ACTION, "Initial bindings update complete")
		firstBindingsUpdate = false
	end

	-- Removed bindings MUST be processed first, otherwise we might explicitly unbind a key from a button set
	-- after removing the binding due to the key's inclusion in another button set.
	for key, command in pairs(removedBindings) do
		EventHandlers:OnKeybindingRemoved(command, key)
	end

	for key, command in pairs(addedBindings) do
		EventHandlers:OnKeybindingAdded(command, key)
	end
end

function EventHandlers:OnKeybindingAdded(command, key)
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnKeybindingAdded", command, key)

	AS2.activeModel:RecordKeybindingAdded(key, command)
end

function EventHandlers:OnKeybindingRemoved(command, key)
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnKeybindingRemoved", command, key)

	AS2.activeModel:RecordKeybindingRemoved(key, command)

	-- NOTE: Be aware that the removed event may occur AFTER an added event on another command.
end

-- Called when a glyph is replaced in its slot.
function EventHandlers:OnGlyphUpdated(slot)
	-- (we don't currently need change notification in this addon, so treat it as a remove + add)
	self:OnGlyphRemoved(slot)
	self:OnGlyphAdded(slot)
end

-- Called when a glyph is added to a slot.
function EventHandlers:OnGlyphAdded(slot)
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnGlyphAdded", slot)

	AS2.activeModel:RecordGlyphForSlot(slot)

	-- Finish applying the glyph set if all glyphs are now correct.
	if AS2.activeModel:IsActivatingGlyphSet() then
		local match = true
		for slot = 1, AS2.NUM_GLYPH_SLOTS do
			local targetGlyphID = AS2.activeGameModel:GetTargetGlyph(slot)
			if targetGlyphID and not Utilities:FindEquippedGlyph(targetGlyphID) then
				match = false; break
			end
		end
		if match then
			AS2.activeModel:FinishActivatingGlyphSet()
		end
	end

	AS2:SendMessage(AS2, "GlyphAdded", slot)
end

-- Called when a glyph is removed from a slot.
function EventHandlers:OnGlyphRemoved(slot)
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnGlyphRemoved", slot)

	AS2.activeModel:RecordGlyphForSlot(slot)

	-- (note: removing a glyph should never cause apply to complete)

	AS2:SendMessage(AS2, "GlyphRemoved", slot)
end

-- Called when a talent change occurs (learn, unlearn, etc.).
function EventHandlers:OnTalentsUpdated()
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnTalentsUpdated")

	-- Detect talent changes (or record the talents for the first time)
	for slot = 1, AS2.NUM_TALENT_SLOTS do
		local talentID = AS2.activeGameModel:GetTalent(slot)
		local oldTalentID = lastKnownTalents[slot]
		if talentID ~= oldTalentID then
			if oldTalentID and not firstTalentsUpdate then self:OnTalentRemoved(slot) end
			if talentID and not firstTalentsUpdate then self:OnTalentAdded(slot) end
			lastKnownTalents[slot] = talentID
		end
	end

	-- Finish applying the talent set if all talents are now correct.
	if AS2.activeModel:IsActivatingTalentSet() then
		local match = true
		for slot = 1, AS2.NUM_TALENT_SLOTS do
			local targetTalentID = AS2.activeGameModel:GetTargetTalent(slot)
			local currentTalentID = AS2.activeGameModel:GetTalent(slot)
			if targetTalentID and targetTalentID ~= currentTalentID then
				match = false; break
			end
		end
		if match then
			AS2.activeModel:FinishActivatingTalentSet()
		end
	end

	if firstTalentsUpdate then
		AS2:Debug(AS2.ACTION, "Initial talents update complete")
		firstTalentsUpdate = false
	end
end

-- Called when a talent is added to a slot.
function EventHandlers:OnTalentAdded(slot)
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnTalentAdded", slot)

	tinsert(delayedTalentAdded, slot)
end

-- Called when a talent is removed from a slot.
function EventHandlers:OnTalentRemoved(slot)
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnTalentRemoved", slot)

	tinsert(delayedTalentRemoved, slot)

	-- (note: removing a talent should never cause apply to complete)
end

-- Deletes the tables in the given backup early instead of waiting for garbage collection.
function EventHandlers:private_DeleteBackup(backupEntry, backupList)
	assert(backupEntry and backupList)
	local qcTableCache = backupList:GetDataContext():GetQCTableCache()
	if backupEntry.actionsTable then qcTableCache:RemoveTableAt(backupEntry.actionsTable); backupEntry.actionsTable = nil end
	if backupEntry.keybindingsTable then qcTableCache:RemoveTableAt(backupEntry.keybindingsTable); backupEntry.keybindingsTable = nil end
	if backupEntry.slotAssignmentsTable then qcTableCache:RemoveTableAt(backupEntry.slotAssignmentsTable); backupEntry.slotAssignmentsTable = nil end
	if backupEntry.glyphsTable then qcTableCache:RemoveTableAt(backupEntry.glyphsTable); backupEntry.glyphsTable = nil end
	if backupEntry.talentsTable then qcTableCache:RemoveTableAt(backupEntry.talentsTable); backupEntry.talentsTable = nil end
end

-- Creates backup entries for all sets, begins watching for discrepencies
function EventHandlers:private_BeginWatchingDiscrepencies()
	AS2.removals = { }
	AS2.discrepencies = { }

	-- Create backups for each set.
	for buttonSetIndex = 1, AS2.activeModel.buttonSetList:GetButtonSetCount() do
		local buttonSet = AS2.activeModel.buttonSetList:GetButtonSetAt(buttonSetIndex)
		for actionSetIndex = 1, buttonSet:GetActionSetCount() do
			local actionSet = buttonSet:GetActionSetAt(actionSetIndex)
			backups[actionSet] = actionSet:CreateBackup()
		end
	end

	for glyphSetIndex = 1, AS2.activeModel.glyphSetList:GetGlyphSetCount() do
		local glyphSet = AS2.activeModel.glyphSetList:GetGlyphSetAt(glyphSetIndex)
		backups[glyphSet] = glyphSet:CreateBackup()
	end

	for talentSetIndex = 1, AS2.activeModel.talentSetList:GetTalentSetCount() do
		local talentSet = AS2.activeModel.talentSetList:GetTalentSetAt(talentSetIndex)
		backups[talentSet] = talentSet:CreateBackup()
	end

	for globalKeysetIndex = 1, AS2.activeModel.globalKeysetList:GetKeysetCount() do
		local globalKeyset = AS2.activeModel.globalKeysetList:GetKeysetAt(globalKeysetIndex)
		backups[globalKeyset] = globalKeyset:CreateBackup()
	end
end

-- Records backups, stops watching discrepencies, reports information to user
function EventHandlers:private_EndWatchingDiscrepencies()
	self.discrepencies = AS2.discrepencies
	self.removals = AS2.removals
	AS2.discrepencies = nil
	AS2.removals = nil

	-- Create automated backups, if needed.
	for buttonSetIndex = 1, AS2.activeModel.buttonSetList:GetButtonSetCount() do
		local buttonSet = AS2.activeModel.buttonSetList:GetButtonSetAt(buttonSetIndex)
		for actionSetIndex = 1, buttonSet:GetActionSetCount() do
			local actionSet = buttonSet:GetActionSetAt(actionSetIndex)
			local backup = backups[actionSet]
			if backup then
				if self.discrepencies[actionSet] or self.removals[actionSet] then	-- Force the backup to be kept if discrepencies were detected
					backup.isProtected = true
				end
				local backupList = actionSet:GetBackupList()
				if not backupList:AddAutomatedBackup(backup) then
					self:private_DeleteBackup(backup, backupList)	-- (delete immediately instead of waiting until next login)
				end
			end
		end
	end

	for glyphSetIndex = 1, AS2.activeModel.glyphSetList:GetGlyphSetCount() do
		local glyphSet = AS2.activeModel.glyphSetList:GetGlyphSetAt(glyphSetIndex)
		local backup = backups[glyphSet]
		if backup then
			if self.discrepencies[glyphSet] or self.removals[glyphSet] then			-- Force the backup to be kept if discrepencies were detected
				backup.isProtected = true
			end
			local backupList = glyphSet:GetBackupList()
			if not backupList:AddAutomatedBackup(backup) then
				self:private_DeleteBackup(backup, backupList)	-- (delete immediately instead of waiting until next login)
			end
		end
	end

	for talentSetIndex = 1, AS2.activeModel.talentSetList:GetTalentSetCount() do
		local talentSet = AS2.activeModel.talentSetList:GetTalentSetAt(talentSetIndex)
		local backup = backups[talentSet]
		if backup then
			if self.discrepencies[talentSet] or self.removals[talentSet] then			-- Force the backup to be kept if discrepencies were detected
				backup.isProtected = true
			end
			local backupList = talentSet:GetBackupList()
			if not backupList:AddAutomatedBackup(backup) then
				self:private_DeleteBackup(backup, backupList)	-- (delete immediately instead of waiting until next login)
			end
		end
	end

	for globalKeysetIndex = 1, AS2.activeModel.globalKeysetList:GetKeysetCount() do
		local globalKeyset = AS2.activeModel.globalKeysetList:GetKeysetAt(globalKeysetIndex)
		local backup = backups[globalKeyset]
		if backup then
			if self.discrepencies[globalKeyset] or self.removals[globalKeyset] then		-- Force the backup to be kept if discrepencies were detected
				backup.isProtected = true
			end
			local backupList = globalKeyset:GetBackupList()
			if not backupList:AddAutomatedBackup(backup) then
				self:private_DeleteBackup(backup, backupList)	-- (delete immediately instead of waiting until next login)
			end
		end
	end

	-- Functionality disabled for the time being, as many items can potentially appear removed from the action bar
	-- by the fact that we can no longer place items on the action bar that are no longer in the spellbook as of
	-- Mists of Pandaria.  This dialog was appearing much more often due to this, than due to an actual removal.
	--[[-- If there are any removals, ask the user if they want to restore these.
	for actionSet, items in pairs(self.removals) do
		local dialog = AS2:ShowDialog(AS2.Popups.REMOVALS)
		dialog.owner = self
		break	-- (one is enough)
	end ]]

	-- Show any discrepencies found (note: removals count as discrepencies only if there are
	-- discrepencies that aren't removals!)
	local typeMapping = {
		ActionSet = L["[action set]"],
		GlobalKeyset = L["[keybinding set]"],
		GlyphSet = L["[glyph set]"],
		TalentSet = L["[talent set]"]
	}
	local string = ""
	for object, info in pairs(self.discrepencies) do
		local count = info.count
		
		-- Include removals in the discrepency count
		if self.removals[object] then
			for _, _ in pairs(self.removals[object]) do
				count = count + 1
			end
		end
		
		string = string .. "\n" .. GRAY_FONT_COLOR_CODE .. typeMapping[info.type] .. " ".. GREEN_FONT_COLOR_CODE .. object:GetName() .. YELLOW_FONT_COLOR_CODE .. L[" ("] .. count .. L[" changes)"] .. FONT_COLOR_CODE_CLOSE
	end
	if strlen(string) > 0 then
		AS2:ShowDialog(AS2.Popups.DISCREPENCIES, string)
	end
end

-- Called when the user clicks "Yes" on the removals popup.
function EventHandlers:private_RemovalsPopup_OnAccept()
	for actionSet, items in pairs(self.removals) do
		for slot, action in pairs(items) do
			AS2.activeGameModel:SetQueuedAction(slot, action)
		end
	end
end

-- Called just before the confirmation dialog is displayed - this is the only time to obtain the ID of what's
-- being cleared.
function EventHandlers:OnPrepareTalentWipe(id)
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnPrepareTalentWipe", id)
	talentWipeID = id
end

-- Called just after the talent wipe confirmation dialog is accepted, but before the talents are actually wiped.
function EventHandlers:OnConfirmTalentWipe()
	if not AS2:IsLoaded() or initialRecord then return end
	AS2:Debug(AS2.EVENT, "OnConfirmTalentWipe")
	if talentWipeID == TALENT_WIPE_TALENTS then
		UIOperations:UnequipTalentSets()
	elseif talentWipeID == TALENT_WIPE_GLYPHS then
		UIOperations:UnequipGlyphSets()
	elseif talentWipeID == TALENT_WIPE_SPECIALIZATION then
		UIOperations:UnequipActionSets()
	end
end

function EventHandlers:OnSpellsChanged()
	if not AS2:IsLoaded() then return end
	AS2:Debug(AS2.EVENT, "OnSpellsChanged")

	-- Update the demorphed spell mapping the next time it is queried.
	AS2.activeGameModel:ResetSpellMap()

	-- On login, re-record everything to active sets... actions, keys, glyphs, etc.
	-- We'd normally do this in OnLogin, but we need to wait for the spell morph information to become available.
	if loginOccurred and initialRecord then
		initialRecord = false
		self:private_BeginWatchingDiscrepencies()
		AS2.activeModel:RecordAll()
		self:private_EndWatchingDiscrepencies()
	end

	-- TODO: After 1/1/2013, remove this call, and replace the one in Model.lua with
	-- UpgradeToRevision11().  At this point, sets will no longer be de-morphed as
	-- frequently.
	AS2.activeModel:DemorphAll()

	AS2:SendMessage(AS2, "SpellsChanged")
end
