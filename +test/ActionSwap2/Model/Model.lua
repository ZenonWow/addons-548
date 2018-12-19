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
local Binding = AS2.Model.Binding
local Model = AS2.Model.Model
local Utilities = AS2.Model.Utilities

-- Creates a new, empty model.
function Model:Create()
	return self:CreateWithDataSource({ })
end

-- Creates a model object around an existing data source.
function Model:CreateWithDataSource(dataSource)
	assert(dataSource, "NIL_ARGUMENT")
	self = self:Derive()

	-- Validate the data source
	if not dataSource.buttonSetList then dataSource.buttonSetList = { } end
	if not dataSource.glyphSetList then dataSource.glyphSetList = { } end
	if not dataSource.talentSetList then dataSource.talentSetList = { } end
	if not dataSource.globalKeysetList then dataSource.globalKeysetList = { } end
	if not dataSource.dataContext then dataSource.dataContext = { } end
	if not dataSource.lastKnownOverrides then dataSource.lastKnownOverrides = { } end
	if not dataSource.completedTutorials then dataSource.completedTutorials = { } end
	if not dataSource.tutorialHistory then dataSource.tutorialHistory = { } end
	if dataSource.showTutorials == nil then dataSource.showTutorials = true end

	-- Synchronize the object model to the data source
	self.dataSource = dataSource
	self.dataContext = AS2.Model.DataContext:CreateWithDataSource(dataSource.dataContext)
	self.buttonSetList = AS2.Model.ButtonSetList:CreateWithDataSource(dataSource.buttonSetList, self.dataContext)
	self.glyphSetList = AS2.Model.GlyphSetList:CreateWithDataSource(dataSource.glyphSetList, self.dataContext)
	self.talentSetList = AS2.Model.TalentSetList:CreateWithDataSource(dataSource.talentSetList, self.dataContext)
	self.globalKeysetList = AS2.Model.GlobalKeysetList:CreateWithDataSource(dataSource.globalKeysetList, self.dataContext)
	self.activatingActionSets = { } -- (one entry per button set)
	-- (self.activatingGlyphSet = nil)
	-- (self.activatingTalentSet = nil)
	-- (self.activatingGlobalKeyset = nil)

	-- Garbage collect any tables that weren't explicitly kept during the initialization of the object model.
	self.dataContext:GetQCTableCache():CollectGarbage()

	AS2:AddCallback(self.buttonSetList, "SlotAssignedToButtonSet", self.OnSlotAssignedToButtonSet, self)
	AS2:AddCallback(AS2, "ApplyFinished", self.private_OnApplyFinished, self)

	return self
end

-- Sets whether this model has been loaded successfully.
function Model:SetLoaded(isLoaded)
	self.isLoaded = isLoaded
end

-- Returns whether this model has been loaded successfully.
function Model:IsLoaded()
	return self.isLoaded == true
end

-- Returns the DataContext object associated with this model.
function Model:GetDataContext()
	return self.dataContext
end

-- Returns true if an action set is currently being activated.
function Model:IsActivatingActionSet()
	return next(self.activatingActionSets) ~= nil
end

-- Returns true if a glyph set is currently being activated.
function Model:IsActivatingGlyphSet()
	return self.activatingGlyphSet ~= nil
end

-- Returns true if a talent set is currently being activated.
function Model:IsActivatingTalentSet()
	return self.activatingTalentSet ~= nil
end

-- Returns true if a global keyset is currently being activated.
function Model:IsActivatingGlobalKeyset()
	return self.activatingGlobalKeyset ~= nil
end

-- Applies action bar / keybinding changes, then sets the active action set.
-- You CAN reactivate an already-active set to refresh changes; i.e., this is done
-- when restoring from backup.
function Model:ActivateActionSet(buttonSetID, actionSetID)
	local buttonSet = self.buttonSetList:GetButtonSetAt(buttonSetID)
	assert(buttonSet, "INVALID_ID")
	local actionSet = buttonSet:GetActionSetAt(actionSetID)
	assert(actionSet, "INVALID_ID")
	local spec = AS2.activeGameModel:GetActiveSpec()
	assert(spec >= 1 and spec <= AS2.NUM_SPECS)
	local actionsApplied = false

	-- UPGRADE: At revision 11 - each time an action set is applied, first attempt to
	-- de-morph all spells in it, and any of its backups, based on the morphing rules of
	-- the current spellbook.
	actionSet:UpgradeToRevision11()

	-- TODO: After 1/1/2013, remove this invariant demorphing.
	-- (for the time being, demorphing occurs whether upgrading or not)
	actionSet:DemorphAllSpells()

	-- Until the apply is complete, set the active set to nil.  That way, if we get
	-- disconnected while applying actions, it won't record the messed up apply the
	-- next time we log in.
	buttonSet:friend_SetActiveActionSet(spec, nil)
	self.activatingActionSets[buttonSet] = { spec, actionSet }

	-- Actually apply the actions in the action set.
	local slotSelectorFn = function(slot) return self.buttonSetList:GetAssignedButtonSetForSlot(slot) == buttonSetID end
	self:private_ApplyActionsWithClip(actionSet:GetActionsTable(), slotSelectorFn)
	if buttonSet:AreKeybindingsIncluded() then
		self:private_ApplyKeybindingsWithClip(actionSet:GetKeybindingsTable(), slotSelectorFn)
	end

	-- If nothing was actually queued, simulate the OnApplyFinished message ourselves,
	-- since it'll never happen otherwise.
	if not AS2.activeGameModel:IsApplyPending() then
		self:private_OnApplyFinished()
	end
end

-- Cancels action set and global keyset activation early (if activating).
function Model:CancelActionSetAndGlobalKeysetActivations()
	if self.activatingActionSets then
		wipe(self.activatingActionSets)
		AS2.activeGameModel:ClearQueued()
		AS2:Debug(AS2.EVENT, "Activation canceled (action set)")
		AS2:SendMessage(AS2, "ActivationFinished", "ActionSet")
	end

	if self.activatingGlobalKeyset then
		self.activatingGlobalKeyset = nil
		AS2.activeGameModel:ClearQueued()
		AS2:Debug(AS2.EVENT, "Activation canceled (global keyset)")
		AS2:SendMessage(AS2, "ActivationFinished", "GlobalKeyset")
	end
end

-- Called when an apply operation finishes.
function Model:private_OnApplyFinished()
	AS2:Debug(AS2.EVENT, "Apply finished")
	for buttonSet, v in pairs(self.activatingActionSets) do
		-- Switch from the nil set to the set that was activated.
		local spec = v[1]
		local actionSet = v[2]
		assert(buttonSet and spec and actionSet)
		local buttonSetID = self.buttonSetList:FindButtonSet(buttonSet)
		local actionSetID = buttonSet:FindActionSet(actionSet)
		self.activatingActionSets[buttonSet] = nil	-- (must happen BEFORE setting the active set)
		if buttonSetID and actionSetID then	-- (only activate if hasn't been deleted)
			buttonSet:friend_SetActiveActionSet(spec, actionSetID)

			-- Fill in any missing information in the action set's data.
			self:SaveToActionSet(buttonSetID, actionSetID, true, nil)
		end
		AS2:Debug(AS2.EVENT, "Activation finished (action set)", buttonSetID, actionSetID)
		AS2:SendMessage(AS2, "ActivationFinished", "ActionSet")
	end

	if self.activatingGlobalKeyset then
		-- Switch from the nil set to the set that was activated.
		local spec = self.activatingGlobalKeyset[1]
		local globalKeyset = self.activatingGlobalKeyset[2]
		assert(spec and globalKeyset)
		local globalKeysetID = self.globalKeysetList:FindKeyset(globalKeyset)
		self.activatingGlobalKeyset = nil	-- (must happen BEFORE setting the active set)
		if globalKeysetID then	-- (only activate if hasn't been deleted)
			self.globalKeysetList:friend_SetActiveKeyset(spec, globalKeysetID)

			-- Fill in any missing information in the action set's data.
			self:SaveToGlobalKeyset(globalKeysetID, true, nil)
		end
		AS2:Debug(AS2.EVENT, "Activation finished (global keyset)", globalKeysetID)
		AS2:SendMessage(AS2, "ActivationFinished", "GlobalKeyset")
	end
end

-- Begins the activation of the given glyph set.
function Model:BeginActivatingGlyphSet(glyphSetID)
	local glyphSet = self.glyphSetList:GetGlyphSetAt(glyphSetID)
	assert(glyphSet, "INVALID_ID")
	local spec = AS2.activeGameModel:GetActiveSpec()
	assert(spec >= 1 and spec <= AS2.NUM_SPECS)

	-- Until the apply is complete, set the active set to nil.  That way, if we get
	-- disconnected while applying, it won't record the messed up apply the
	-- next time we log in.
	self.glyphSetList:friend_SetActiveGlyphSet(spec, nil)
	self.activatingGlyphSet = { spec, glyphSet }

	-- Just set the glyph targets; it's up to the user to update.
	local changeMade = false
	for slot = 1, AS2.NUM_GLYPH_SLOTS do
		local targetGlyphID = glyphSet:GetGlyph(slot)
		AS2.activeGameModel:SetTargetGlyph(slot, targetGlyphID)	-- (OK for targetGlyphID to be nil; this will clear out any previously unfinished activation)
		if targetGlyphID and not Utilities:FindEquippedGlyph(targetGlyphID) then
			changeMade = true
		end
	end

	-- If no changes were made, finish activation immediately.
	if not changeMade then
		self:FinishActivatingGlyphSet()
	end
end

-- Begins the activation of the given talent set.
function Model:BeginActivatingTalentSet(talentSetID)
	local talentSet = self.talentSetList:GetTalentSetAt(talentSetID)
	assert(talentSet, "INVALID_ID")
	local spec = AS2.activeGameModel:GetActiveSpec()
	assert(spec >= 1 and spec <= AS2.NUM_SPECS)

	-- Until the apply is complete, set the active set to nil.  That way, if we get
	-- disconnected while applying, it won't record the messed up apply the
	-- next time we log in.
	self.talentSetList:friend_SetActiveTalentSet(spec, nil)
	self.activatingTalentSet = { spec, talentSet }

	-- Just set the talent targets; it's up to the user to update.
	local changeMade = false
	for slot = 1, AS2.NUM_TALENT_SLOTS do
		local targetTalentID = talentSet:GetTalent(slot)
		local oldTalentID = AS2.activeGameModel:GetTalent(slot)
		if targetTalentID and targetTalentID ~= oldTalentID then
			AS2.activeGameModel:SetTargetTalent(slot, targetTalentID)	-- (OK for targetTalentID to be nil; this will clear out any previously unfinished activation)
			changeMade = true
		end
	end

	-- If no changes were made, finish activation immediately.
	if not changeMade then
		self:FinishActivatingTalentSet()
	end
end

-- Cancels glyph set activation early (if activating).
function Model:CancelGlyphSetActivation()
	if self.activatingGlyphSet then
		self.activatingGlyphSet = nil
		AS2.activeGameModel:ClearGlyphTargets()
		AS2:Debug(AS2.EVENT, "Activation canceled (glyph set)")
		AS2:SendMessage(AS2, "ActivationFinished", "GlyphSet")
	end
end

-- Cancels talent set activation early (if activating).
function Model:CancelTalentSetActivation()
	if self.activatingTalentSet then
		self.activatingTalentSet = nil
		AS2.activeGameModel:ClearTalentTargets()
		AS2:Debug(AS2.EVENT, "Activation canceled (talent set)")
		AS2:SendMessage(AS2, "ActivationFinished", "TalentSet")
	end
end

-- Completes an already-started glyph set activation.
function Model:FinishActivatingGlyphSet()
	if self.activatingGlyphSet then
		local spec = self.activatingGlyphSet[1]
		local glyphSet = self.activatingGlyphSet[2]
		assert(spec and glyphSet)
		local glyphSetID = self.glyphSetList:FindGlyphSet(glyphSet)
		self.activatingGlyphSet = nil
		AS2.activeGameModel:ClearGlyphTargets()
		if glyphSetID then	-- (only activate if hasn't been deleted)
			self.glyphSetList:friend_SetActiveGlyphSet(spec, glyphSetID)

			-- Fill in any missing information in the glyph set's data.
			self:SaveToGlyphSet(glyphSetID, true, nil)
		end
		AS2:Debug(AS2.EVENT, "Activation finished (glyph set)", glyphSetID)
		AS2:SendMessage(AS2, "ActivationFinished", "GlyphSet")
	end
end

-- Completes an already-started talent set activation.
function Model:FinishActivatingTalentSet()
	if self.activatingTalentSet then
		local spec = self.activatingTalentSet[1]
		local talentSet = self.activatingTalentSet[2]
		assert(spec and talentSet)
		local talentSetID = self.talentSetList:FindTalentSet(talentSet)
		self.activatingTalentSet = nil
		AS2.activeGameModel:ClearTalentTargets()
		if talentSetID then	-- (only activate if hasn't been deleted)
			self.talentSetList:friend_SetActiveTalentSet(spec, talentSetID)

			-- Fill in any missing information in the talent set's data.
			self:SaveToTalentSet(talentSetID, true, nil)
		end
		AS2:Debug(AS2.EVENT, "Activation finished (talent set)", talentSetID)
		AS2:SendMessage(AS2, "ActivationFinished", "TalentSet")
	end
end

-- Applies global keyset changes, then sets the active global keyset.
-- You CAN reactivate an already-active set to refresh changes; i.e., this is done
-- when restoring from backup.
function Model:ActivateGlobalKeyset(globalKeysetID)
	local keyset = self.globalKeysetList:GetKeysetAt(globalKeysetID)
	assert(keyset, "INVALID_ID")
	local spec = AS2.activeGameModel:GetActiveSpec()
	assert(spec >= 1 and spec <= AS2.NUM_SPECS)

	-- Until the apply is complete, set the active set to nil.  That way, if we get
	-- disconnected while applying actions, it won't record the messed up apply the
	-- next time we log in.
	self.globalKeysetList:friend_SetActiveKeyset(spec, nil)
	self.activatingGlobalKeyset = { spec, keyset }

	-- Actually apply the keys in the keyset (but only where not assigned to a button set that has keybindings enabled)
	local slotSelectorFn = function(slot)
		local bsList = self.buttonSetList
		local buttonSet = bsList:GetButtonSetAt(bsList:GetAssignedButtonSetForSlot(slot))
		return not buttonSet or not buttonSet:AreKeybindingsIncluded()
	end
	self:private_ApplyKeybindingsWithClip(keyset:GetKeybindingsTable(), slotSelectorFn)

	-- If nothing was actually queued, simulate the OnApplyFinished message ourselves,
	-- since it'll never happen otherwise.
	if not AS2.activeGameModel:IsApplyPending() then
		self:private_OnApplyFinished()
	end
end

-- Applies all actions in the given table (maps from slot => action), with the given slot selector.
-- Returns true if something was actually queued, or false otherwise.
function Model:private_ApplyActionsWithClip(actionsTable, includeSlotFn)
	for slot, action in pairs(slotData.actions) do
		if includeSlotFn(slot) then
			AS2.activeGameModel:SetQueuedAction(slot, action)
		end
	end
end

function Model:LogRemoval(object, slot, action)
	if AS2.removals then
		assert(object and slot and action)
		local entry = AS2.removals[object]
		if not entry then
			entry = { }
			AS2.removals[object] = entry
		end
		entry[slot] = action
	end
end

function Model:LogDiscrepency(type, object)
	if AS2.discrepencies then
		assert(type and object)
		local entry = AS2.discrepencies[object]
		if not entry then
			entry = { type = type, count = 0 }
			AS2.discrepencies[object] = entry
		end
		entry.count = entry.count + 1
	end
end

function Model:LogActionRecorded(buttonSetIndex, actionSetIndex, slot, oldAction, newAction)
	AS2:Debug(AS2.ACTION, "Recording", Action:ToString(newAction), "to slot", slot, "of BS:AS", buttonSetIndex, ":", actionSetIndex)
	if AS2.discrepencies then
		local buttonSet = self.buttonSetList:GetButtonSetAt(buttonSetIndex)
		local actionSet = buttonSet:GetActionSetAt(actionSetIndex)
		if oldAction and oldAction ~= Action.NIL and newAction == Action.NIL then
			self:LogRemoval(actionSet, slot, oldAction)
		else
			-- Only count it as a discrepency if coersion doesn't make the two actions equal.
			if not Action:Equals(newAction, oldAction, true) then
				--AS2:Debug(AS2.DISCREPENCY, "ActionSet discrepency:", newAction and Action:ToString(newAction), oldAction and Action:ToString(oldAction))
				self:LogDiscrepency("ActionSet", actionSet)
			end
		end
	end
end

function Model:LogKeybindingRecorded(buttonSetIndex, actionSetIndex, globalKeysetIndex, key, command)
	AS2:Debug(AS2.ACTION, "Recording keybinding", key, "=", command, "to BS:AS", buttonSetIndex, ":", actionSetIndex)
	if AS2.discrepencies then
		if globalKeysetIndex then
			local globalKeyset = self.globalKeysetList:GetKeysetAt(globalKeysetIndex)
			self:LogDiscrepency("GlobalKeyset", globalKeyset)
		else
			local buttonSet = self.buttonSetList:GetButtonSetAt(buttonSetIndex)
			local actionSet = buttonSet:GetActionSetAt(actionSetIndex)
			self:LogDiscrepency("ActionSet", actionSet)
		end
	end
end

function Model:LogGlyphRecorded(glyphSetIndex, slot, glyphID)
	AS2:Debug(AS2.ACTION, "Recording glyph", glyphID, "to slot", slot, "of GS", glyphSetIndex)
	if AS2.discrepencies then
		local glyphSet = self.glyphSetList:GetGlyphSetAt(glyphSetIndex)
		self:LogDiscrepency("GlyphSet", glyphSet)
	end
end

function Model:LogTalentRecorded(talentSetIndex, slot, talentID)
	AS2:Debug(AS2.ACTION, "Recording talent", talentID, "to slot", slot, "of TS", talentSetIndex)
	if AS2.discrepencies then
		local talentSet = self.talentSetList:GetTalentSetAt(talentSetIndex)
		self:LogDiscrepency("TalentSet", talentSet)
	end
end

-- Records the action that's in a slot to that slot's assigned button set's active action set, if it exists.
function Model:RecordActionForSlot(slot)
	local buttonSetIndex = self.buttonSetList:GetAssignedButtonSetForSlot(slot)
	local buttonSet = self.buttonSetList:GetButtonSetAt(buttonSetIndex)
	if buttonSet then
		local actionSetIndex = buttonSet:GetActiveActionSet()
		local actionSet = buttonSet:GetActionSetAt(actionSetIndex)
		if actionSet then
			local action = AS2.activeGameModel:GetAction(slot)
			local oldValue = actionSet:GetActionsTable():GetValue(slot)
			if not Action:Equals(action, oldValue) then
				actionSet:GetActionsTable():SetValue(slot, action)
				self:LogActionRecorded(buttonSetIndex, actionSetIndex, slot, oldValue, action)
				AS2:SendMessage(AS2, "SlotRecorded", "Action", slot)
			end
		end
	end
end

-- Records the addition of a keybinding.
function Model:RecordKeybindingAdded(key, command)
	assert(key and command, "NIL_ARGUMENT")
	assert(command ~= Binding.NIL, "INVALID_ARGUMENT")

	-- If the key corresponds to a slot...
	local slot = Utilities:QuickParseSlotFromCommand(command)
	local buttonSetIndex = self.buttonSetList:GetAssignedButtonSetForSlot(slot)
	local buttonSet = self.buttonSetList:GetButtonSetAt(buttonSetIndex)
	if buttonSet and buttonSet:AreKeybindingsIncluded() then
		-- If the slot is part of a button set which has keybindings enabled, then record it to the active action set.
		local actionSetIndex = buttonSet:GetActiveActionSet()
		local actionSet = buttonSet:GetActionSetAt(actionSetIndex)
		if actionSet then
			local oldCommand = actionSet:GetKeybindingsTable():GetValue(key)
			if command ~= oldCommand then
				actionSet:GetKeybindingsTable():SetValue(key, command)
				self:LogKeybindingRecorded(buttonSetIndex, actionSetIndex, nil, key, command)
			end
		end

		-- Remove the key from all other button sets.
		self:RemoveKeyFromOtherButtonSets(buttonSetIndex, key)
	else
		-- If the slot is not part of a button set which has keybindings enabled, bind it in the global keyset instead.
		local globalKeysetIndex = self.globalKeysetList:GetActiveKeyset()
		local globalKeyset = self.globalKeysetList:GetKeysetAt(globalKeysetIndex)
		if globalKeyset then
			local oldCommand = globalKeyset:GetKeybindingsTable():GetValue(key)
			if command ~= oldCommand then
				globalKeyset:GetKeybindingsTable():SetValue(key, command)
				self:LogKeybindingRecorded(nil, nil, globalKeysetIndex, key, command)
			end
		end

		-- Remove the key from all button sets.  This needs to be done even if no global keyset exists, because
		-- otherwise the new binding will be removed when something from the button set is re-equipped.
		self:RemoveKeyFromOtherButtonSets(nil, key)
	end	
end

-- Records the removal of a keybinding.
function Model:RecordKeybindingRemoved(key, command)
	assert(key and command, "NIL_ARGUMENT")
	assert(command ~= Binding.NIL, "INVALID_ARGUMENT")

	-- Explicitly unbind the key from it's active action set, if it corresponds to a slot.
	local slot = Utilities:QuickParseSlotFromCommand(command)
	local buttonSetIndex = self.buttonSetList:GetAssignedButtonSetForSlot(slot)
	local buttonSet = self.buttonSetList:GetButtonSetAt(buttonSetIndex)
	if buttonSet and buttonSet:AreKeybindingsIncluded() then
		-- If the slot is part of a button set which has keybindings enabled, then explicitly unbind it from the active action set.
		local actionSetIndex = buttonSet:GetActiveActionSet()
		local actionSet = buttonSet:GetActionSetAt(actionSetIndex)
		if actionSet then
			local oldCommand = actionSet:GetKeybindingsTable():GetValue(key)
			if Binding.NIL ~= oldCommand then
				actionSet:GetKeybindingsTable():SetValue(key, Binding.NIL)
				self:LogKeybindingRecorded(buttonSetIndex, actionSetIndex, nil, key, Binding.NIL)
			end
		end
	else
		-- If the slot is not part of a button set which has keybindings enabled, explicitly unbind it in the global keyset.
		local globalKeysetIndex = self.globalKeysetList:GetActiveKeyset()
		local globalKeyset = self.globalKeysetList:GetKeysetAt(globalKeysetIndex)
		if globalKeyset then
			local oldCommand = globalKeyset:GetKeybindingsTable():GetValue(key)
			if Binding.NIL ~= oldCommand then
				globalKeyset:GetKeybindingsTable():SetValue(key, Binding.NIL)
				self:LogKeybindingRecorded(nil, nil, globalKeysetIndex, key, Binding.NIL)
			end
		end
	end
end

-- Makes the given key exclusive to the given button set, removing it from all others (incl. global keysets).
-- Can specify nil to remove the key from all button sets except the global keyset.
function Model:RemoveKeyFromOtherButtonSets(buttonSetIndex, key)
	for otherButtonSetIndex = 1, self.buttonSetList:GetButtonSetCount() do
		if otherButtonSetIndex ~= buttonSetIndex then	-- (buttonSetIndex may be nil, but that's okay)
			local otherButtonSet = self.buttonSetList:GetButtonSetAt(otherButtonSetIndex)
			for otherActionSetIndex = 1, otherButtonSet:GetActionSetCount() do
				local otherActionSet = otherButtonSet:GetActionSetAt(otherActionSetIndex)
				local oldCommand = otherActionSet:GetKeybindingsTable():GetValue(key)
				if nil ~= oldCommand then
					otherActionSet:GetKeybindingsTable():SetValue(key, nil)
					self:LogKeybindingRecorded(otherButtonSetIndex, otherActionSetIndex, nil, key, nil)
				end
			end
		end
	end

	if buttonSetIndex then	-- If nil, then we clear everything but the global keyset.  If not nil, we clear the global keyset.
		for globalKeysetIndex = 1, self.globalKeysetList:GetKeysetCount() do
			local globalKeyset = self.globalKeysetList:GetKeysetAt(globalKeysetIndex)
			local oldCommand = globalKeyset:GetKeybindingsTable():GetValue(key)
			if oldCommand ~= nil then
				globalKeyset:GetKeybindingsTable():SetValue(key, nil)
				self:LogKeybindingRecorded(nil, nil, globalKeysetIndex, key, nil)
			end
		end
	end
end

-- Records the glyph in the given slot to the currently active glyph set.
function Model:RecordGlyphForSlot(slot)
	local activeGlyphSetIndex = self.glyphSetList:GetActiveGlyphSet()
	local activeGlyphSet = self.glyphSetList:GetGlyphSetAt(activeGlyphSetIndex)
	if activeGlyphSet then
		local glyphID = AS2.activeGameModel:GetGlyph(slot)
		local oldGlyph = activeGlyphSet:GetGlyph(slot)
		if glyphID ~= oldGlyph then
			activeGlyphSet:SetGlyph(slot, glyphID)
			self:LogGlyphRecorded(activeGlyphSetIndex, slot, glyphID)
		end
		AS2:SendMessage(AS2, "SlotRecorded", "Glyph", slot)
	end
end

-- Records the talent in the given slot to the currently active talent set.
function Model:RecordTalentForSlot(slot)
	local activeTalentSetIndex = self.talentSetList:GetActiveTalentSet()
	local activeTalentSet = self.talentSetList:GetTalentSetAt(activeTalentSetIndex)
	if activeTalentSet then
		local talentID = AS2.activeGameModel:GetTalent(slot)
		local oldTalent = activeTalentSet:GetTalent(slot)
		if talentID ~= oldTalent then
			activeTalentSet:SetTalent(slot, talentID)
			self:LogTalentRecorded(activeTalentSetIndex, slot, talentID)
		end
		AS2:SendMessage(AS2, "SlotRecorded", "Talent", slot)
	end
end

-- TODO: After 1/1/2013, remove this function.
function Model:DemorphAll()
	local buttonSetList = AS2.activeModel.buttonSetList
	for buttonSetIndex = 1, buttonSetList:GetButtonSetCount() do
		local buttonSet = buttonSetList:GetButtonSetAt(buttonSetIndex)
		for actionSetIndex = 1, buttonSet:GetActionSetCount() do
			local actionSet = buttonSet:GetActionSetAt(actionSetIndex)
			actionSet:DemorphAllSpells()
		end
	end
end

-- Re-records everything.  This is generally only done at login.
function Model:RecordAll()
	-- Record each slot to its assigned button set's active action set (if there is one).
	for slot = 1, AS2.NUM_ACTION_SLOTS do
		AS2.activeModel:RecordActionForSlot(slot)
	end

	-- Record each glyph to the active glyph set (if there is one).
	for slot = 1, AS2.NUM_GLYPH_SLOTS do
		AS2.activeModel:RecordGlyphForSlot(slot)
	end

	-- Record each talent to the active talent set (if there is one).
	for slot = 1, AS2.NUM_TALENT_SLOTS do
		AS2.activeModel:RecordTalentForSlot(slot)
	end

	-- Go through all commands, since we can't go through them by slot.
	local numBindings = AS2.activeGameModel:GetNumKeybindings()
	for bindingSlot = 1,numBindings do
		local command = select(1, AS2.activeGameModel:GetKeybindingByIndex(bindingSlot))
		local keys = { select(2, AS2.activeGameModel:GetKeybindingByIndex(bindingSlot)) }
		for _, key in ipairs(keys) do
			self:RecordKeybindingAdded(key, command)
		end
	end
end

-- Called when a slot is assigned to a button set.
function Model:OnSlotAssignedToButtonSet(slot, buttonSetIndex)
	AS2:Debug(AS2.EVENT, "OnSlotAssignedToButtonSet", slot, buttonSetIndex)
	assert(slot, "NIL_ARGUMENT")

	-- Save the actions/keybindings for this slot to all action sets, unless they already have data.
	local buttonSet = self.buttonSetList:GetButtonSetAt(buttonSetIndex)
	if buttonSet then	-- (will be nil if the slot is unassigned)
		local activeActionSetIndex = buttonSet:GetActiveActionSet()
		for actionSetIndex = 1, buttonSet:GetActionSetCount() do
			
			-- (only the active action set has its values overwritten, and the active action set for the other spec is implicitly overwritten)
			local overwrite = actionSetIndex == activeActionSetIndex

			self:SaveToActionSet(buttonSetIndex, actionSetIndex, overwrite,
				function(slotToTest) return slotToTest == slot end)
		end
	else
		local activeGlobalKeysetIndex = self.globalKeysetList:GetActiveKeyset()
		for globalKeysetIndex = 1, self.globalKeysetList:GetKeysetCount() do

			-- (only the active global keyset has its values overwritten)
			local overwrite = globalKeysetIndex == activeGlobalKeysetIndex

			self:SaveToGlobalKeyset(globalKeysetIndex, overwrite,
				function(slotToTest) return slotToTest == slot end)
		end
	end
end

-- Applies the actions in the specified QuickCloneTable, but only those associated with slots for which
-- the specified function returns true.
function Model:private_ApplyActionsWithClip(actionsTable, slotSelectorFn)
	assert(actionsTable and slotSelectorFn, "NIL_ARGUMENT")
	for slot, action in actionsTable:Pairs() do
		if slotSelectorFn(slot) then
			AS2.activeGameModel:SetQueuedAction(slot, action)
		end
	end
end

-- Applies the keybindings in the specified QuickCloneTable, but only those associated with slots for which
-- the specified function returns true.
function Model:private_ApplyKeybindingsWithClip(keybindingsTable, slotSelectorFn)
	assert(keybindingsTable and slotSelectorFn, "NIL_ARGUMENT")
	for key, command in keybindingsTable:Pairs() do
		if command == Binding.NIL then
			AS2.activeGameModel:SetQueuedKeybinding(key, Binding.NIL)
		else
			local slot = Utilities:QuickParseSlotFromCommand(command)
			if slotSelectorFn(slot) then	-- (do NOT test for nil; nil is okay!)
				AS2.activeGameModel:SetQueuedKeybinding(key, command)
			end
		end
	end
end

-- Restores an action set from a backup object.
function Model:RestoreActionSetFromBackup(buttonSetIndex, actionSetIndex, backupEntry)
	local buttonSet = AS2.activeModel.buttonSetList:GetButtonSetAt(buttonSetIndex)
	assert(buttonSet, "INVALID_ID")
	local actionSet = buttonSet:GetActionSetAt(actionSetIndex)
	assert(actionSet, "INVALID_ID")
	assert(backupEntry ~= actionSet) -- (can't restore from self)

	-- First, apply the backup to the action set.
	actionSet:RestoreFromBackup(backupEntry)

	-- Now, re-activate the action set if it was the active one.
	if buttonSet:GetActiveActionSet() == actionSetIndex then
		self:ActivateActionSet(buttonSetIndex, actionSetIndex)
	end
end

-- Restores a glyph set from a backup object.
function Model:RestoreGlyphSetFromBackup(glyphSetIndex, backupEntry)
	local glyphSet = AS2.activeModel.glyphSetList:GetGlyphSetAt(glyphSetIndex)
	assert(glyphSet, "INVALID_ID")
	assert(backupEntry ~= glyphSet)

	-- First, apply the backup to the glyph set.
	glyphSet:RestoreFromBackup(backupEntry)	-- (can't restore from self)

	-- Now, re-activate the glyph set if it was the active one.
	if AS2.activeModel.glyphSetList:GetActiveGlyphSet() == glyphSetIndex then
		self:BeginActivatingGlyphSet(glyphSetIndex)
	end
end

-- Restores a talent set from a backup object.
function Model:RestoreTalentSetFromBackup(talentSetIndex, backupEntry)
	local talentSet = AS2.activeModel.talentSetList:GetTalentSetAt(talentSetIndex)
	assert(talentSet, "INVALID_ID")
	assert(backupEntry ~= talentSet)

	-- First, apply the backup to the talent set.
	talentSet:RestoreFromBackup(backupEntry)	-- (can't restore from self)

	-- Now, re-activate the talent set if it was the active one.
	if AS2.activeModel.talentSetList:GetActiveTalentSet() == talentSetIndex then
		self:BeginActivatingTalentSet(talentSetIndex)
	end
end

-- Restores a global keyset from a backup object.
function Model:RestoreGlobalKeysetFromBackup(globalKeysetIndex, backupEntry)
	local globalKeyset = AS2.activeModel.globalKeysetList:GetKeysetAt(globalKeysetIndex)
	assert(globalKeyset, "INVALID_ID")
	assert(backupEntry ~= globalKeyset)	-- (can't restore from self)

	-- First, apply the backup to the global keyset.
	globalKeyset:RestoreFromBackup(backupEntry)

	-- Now, re-activate the global keyset if it was the active one.
	if AS2.activeModel.globalKeysetList:GetActiveKeyset() == globalKeysetIndex then
		self:ActivateGlobalKeyset(globalKeysetIndex)
	end
end

-- Saves current actions / keybindings to the given action set, clipped to the slots selected
-- by the the given function.  If overwrite isn't set to true, then only nil values will be replaced.
function Model:SaveToActionSet(buttonSetIndex, actionSetIndex, overwrite, slotSelectorFn)
	local buttonSet = self.buttonSetList:GetButtonSetAt(buttonSetIndex)
	assert(buttonSet, "INVALID_ID")
	local actionSet = buttonSet:GetActionSetAt(actionSetIndex)
	assert(actionSet, "INVALID_ID")
	local keybindingsTable = actionSet:GetKeybindingsTable()
	local actionsTable = actionSet:GetActionsTable()

	-- We can't iterate over keybindings by slot, so go through all keybindings.  If the slot
	-- the command is associated with is selected, record it.
	if buttonSet:AreKeybindingsIncluded() then
		local numBindings = AS2.activeGameModel:GetNumKeybindings()
		for bindingSlot = 1, numBindings do
			local command = select(1, AS2.activeGameModel:GetKeybindingByIndex(bindingSlot))
			local commandSlot = Utilities:QuickParseSlotFromCommand(command)
			if (not slotSelectorFn or slotSelectorFn(commandSlot))
					and self.buttonSetList:GetAssignedButtonSetForSlot(commandSlot) == buttonSetIndex then	-- (keybindings included check is above)
				local keys = { select(2, AS2.activeGameModel:GetKeybindingByIndex(bindingSlot)) }
				for _, key in ipairs(keys) do
					if overwrite or keybindingsTable:GetValue(key) == nil then
						self:RemoveKeyFromOtherButtonSets(buttonSetIndex, key)	-- (needed if, say, transferring a key from one button set to another by changing slot assignment)
						keybindingsTable:SetValue(key, command)
						self:LogKeybindingRecorded(buttonSetIndex, actionSetIndex, nil, key, command)
					end
				end
			end
		end
	end

	-- Go through all slots - if selected, record the action.
	for slot = 1, AS2.NUM_ACTION_SLOTS do
		if (not slotSelectorFn or slotSelectorFn(slot))
				and self.buttonSetList:GetAssignedButtonSetForSlot(slot) == buttonSetIndex
				and (overwrite or actionsTable:GetValue(slot) == nil) then
			local action = AS2.activeGameModel:GetAction(slot)
			actionsTable:SetValue(slot, action)
			self:LogActionRecorded(buttonSetIndex, actionSetIndex, slot, nil, action)
			AS2:SendMessage(AS2, "SlotRecorded", "Action", slot)
		end
	end
end

-- Saves current glyphs to the given glyph set, clipped to the slots selected by the the given function.
-- If overwrite isn't set to true, then only nil values will be replaced.
function Model:SaveToGlyphSet(glyphSetIndex, overwrite, slotSelectorFn)
	local glyphSet = self.glyphSetList:GetGlyphSetAt(glyphSetIndex)
	assert(glyphSet, "INVALID_ID")

	-- Go through all slots - if selected, record the glyph.
	for slot = 1, AS2.NUM_GLYPH_SLOTS do
		if (not slotSelectorFn or slotSelectorFn(slot))
				and (overwrite or glyphSet:GetGlyph(slot) == nil) then
			local glyphID = AS2.activeGameModel:GetGlyph(slot)
			glyphSet:SetGlyph(slot, glyphID)
			self:LogGlyphRecorded(glyphSetIndex, slot, glyphID)
			AS2:SendMessage(AS2, "SlotRecorded", "Glyph", slot)
		end
	end
end

-- Saves current talents to the given talent set, clipped to the slots selected by the the given function.
-- If overwrite isn't set to true, then only nil values will be replaced.
function Model:SaveToTalentSet(talentSetIndex, overwrite, slotSelectorFn)
	local talentSet = self.talentSetList:GetTalentSetAt(talentSetIndex)
	assert(talentSet, "INVALID_ID")

	-- Go through all slots - if selected, record the talent.
	for slot = 1, AS2.NUM_TALENT_SLOTS do
		if (not slotSelectorFn or slotSelectorFn(slot))
				and (overwrite or talentSet:GetTalent(slot) == nil) then
			local talentID = AS2.activeGameModel:GetTalent(slot)
			talentSet:SetTalent(slot, talentID)
			self:LogTalentRecorded(talentSetIndex, slot, talentID)
			AS2:SendMessage(AS2, "SlotRecorded", "Talent", slot)
		end
	end
end

-- Saves current keybindings to the given global keyset, clipped to the slots selected
-- by the the given function.  If overwrite isn't set to true, then only nil values will be replaced.
function Model:SaveToGlobalKeyset(globalKeysetIndex, overwrite, slotSelectorFn)
	local globalKeyset = self.globalKeysetList:GetKeysetAt(globalKeysetIndex)
	assert(globalKeyset, "INVALID_ID")
	local keybindingsTable = globalKeyset:GetKeybindingsTable()

	-- We can't iterate over keybindings by slot, so go through all keybindings.  If the slot
	-- the command is associated with is selected, record it.
	local numBindings = AS2.activeGameModel:GetNumKeybindings()
	for bindingSlot = 1, numBindings do
		local command = select(1, AS2.activeGameModel:GetKeybindingByIndex(bindingSlot))
		local commandSlot = Utilities:QuickParseSlotFromCommand(command)
		local slotBSi = self.buttonSetList:GetAssignedButtonSetForSlot(commandSlot)
		if (not slotSelectorFn or slotSelectorFn(commandSlot))
				and (not slotBSi or not self.buttonSetList:GetButtonSetAt(slotBSi):AreKeybindingsIncluded()) then
			local keys = { select(2, AS2.activeGameModel:GetKeybindingByIndex(bindingSlot)) }
			for _, key in ipairs(keys) do
				if overwrite or keybindingsTable:GetValue(key) == nil then
					self:RemoveKeyFromOtherButtonSets(nil, key)	-- (keys can't be bound to a button set and a GKS at the same time)
					keybindingsTable:SetValue(key, command)
					self:LogKeybindingRecorded(nil, nil, globalKeysetIndex, key, command)
				end
			end
		end
	end
end

-- Sets the last known override binding associated with the given command.
function Model:SetLastKnownOverride(command, override)
	-- (Only save the override if it's recognized)
	if Utilities:AreOverridesRecognized(command) then
		self.dataSource.lastKnownOverrides[command] = override
	end
end

-- Returns the last known override binding associated with the given command, or nil if there is none.
function Model:GetLastKnownOverride(command)
	-- (Only return the override if it's recognized - only really necessary if the set of overrides changes)
	if Utilities:AreOverridesRecognized(command) then
		return self.dataSource.lastKnownOverrides[command]
	end
end

-- Returns true if the given tutorial has been marked completed, or false if not.
function Model:IsTutorialCompleted(tutorialName)
	return self.dataSource.completedTutorials[tutorialName]
end

-- Marks the given tutorial as completed.  Call AS2:CompleteTutorial() instead, so it gets
-- added to history.
function Model:friend_MarkTutorialCompleted(tutorialName)
	if not self.dataSource.completedTutorials[tutorialName] then
		self.dataSource.completedTutorials[tutorialName] = true
		AS2:SendMessage(AS2, "TutorialsChanged")
	end
end

-- Adds a tutorial to history.
function Model:AddTutorialToHistory(tutorialName)
	if self.dataSource.tutorialHistory[#self.dataSource.tutorialHistory] ~= tutorialName then
		tinsert(self.dataSource.tutorialHistory, tutorialName)
	end
end

-- Returns the history at the given offset (-1 being the latest entry, -2 is second, etc.)
function Model:GetTutorialHistory(offset)
	local index = #self.dataSource.tutorialHistory + 1 + offset
	return self.dataSource.tutorialHistory[index]	-- will be nil if offset is out of range
end

-- Resets all tutorials.
function Model:friend_ResetTutorials()
	self.dataSource.completedTutorials = { }
	self.dataSource.tutorialHistory = { }
	self.dataSource.showTutorials = true
	AS2:SendMessage(AS2, "TutorialsChanged")
end

-- Sets whether tutorials are enabled.
function Model:SetShowTutorials(show)
	self.dataSource.showTutorials = show
end

-- Returns true if tutorials are enabled.
function Model:AreTutorialsShown()
	return self.dataSource.showTutorials
end

-- Unequips all action sets, then returns the count.
function Model:UnequipActionSets(spec)
	local count = 0
	for i = 1, self.buttonSetList:GetButtonSetCount() do
		count = count + ((self.buttonSetList:GetButtonSetAt(i):GetActiveActionSet(spec) ~= nil) and 1 or 0)
		self.buttonSetList:GetButtonSetAt(i):friend_SetActiveActionSet(spec, nil)
	end
	return count
end

-- Unequips all glyph sets, then returns the count.
function Model:UnequipGlyphSets(spec)
	local count = (self.glyphSetList:GetActiveGlyphSet(spec) ~= nil) and 1 or 0
	self.glyphSetList:friend_SetActiveGlyphSet(spec, nil)
	return count
end

-- Unequips all talent sets, then returns the count.
function Model:UnequipTalentSets(spec)
	local count = (self.talentSetList:GetActiveTalentSet(spec) ~= nil) and 1 or 0
	self.talentSetList:friend_SetActiveTalentSet(spec, nil)
	return count
end

-- Unequips all global keysets, then returns the count.
function Model:UnequipGlobalKeysets(spec)
	local count = (self.globalKeysetList:GetActiveKeyset(spec) ~= nil) and 1 or 0
	self.globalKeysetList:friend_SetActiveKeyset(spec, nil)
	return count
end

-- Unequips all sets under all specs, then returns the count.
function Model:UnequipAllSets()
	local count = 0
	for spec = 1, AS2.NUM_SPECS do
		count = count + self:UnequipActionSets(spec)
		count = count + self:UnequipGlyphSets(spec)
		count = count + self:UnequipTalentSets(spec)
		count = count + self:UnequipGlobalKeysets(spec)
	end
	return count
end
