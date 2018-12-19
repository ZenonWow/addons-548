--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- UIOperations - provides simple wrappers around model functionality to make UI code easier to write and maintain.
-- Many of these functions, for example, fail silently, whereas their model equivalents would've complained for
-- testing purposes.

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local L = LibStub("AceLocale-3.0"):GetLocale("ActionSwap2", true)
local ActionSet = AS2.Model.ActionSet
local ButtonSet = AS2.Model.ButtonSet
local GlobalKeyset = AS2.Model.GlobalKeyset
local GlyphSet = AS2.Model.GlyphSet
local TalentSet = AS2.Model.TalentSet
local UIOperations = AS2.Controller.UIOperations

-- Creates a new button set and fills it with data.
function UIOperations:CreateButtonSet(name, icon)
	assert(name, "NIL_ARGUMENT")
	local buttonSetIndex, buttonSet = AS2.activeModel.buttonSetList:AddButtonSet(ButtonSet:Create(name, AS2.activeModel:GetDataContext()))
	assert(buttonSetIndex and buttonSet)
	buttonSet:SetIcon(icon)
	-- (don't need to record anything; the new button set is empty upon creation)
	return buttonSetIndex, buttonSet
end

-- Creates a new action set and fills it with data (fails silently if buttonSet doesn't exist).
function UIOperations:CreateActionSet(name, buttonSet, icon)
	assert(name and buttonSet, "NIL_ARGUMENT")
	local buttonSetIndex = AS2.activeModel.buttonSetList:FindButtonSet(buttonSet)
	if buttonSetIndex then
		local actionSetIndex, actionSet = buttonSet:AddActionSet(ActionSet:Create(name, AS2.activeModel:GetDataContext()))
		assert(actionSetIndex and actionSet)
		actionSet:SetIcon(icon)

		-- The new set should contain the current setup.
		AS2.activeModel:SaveToActionSet(buttonSetIndex, actionSetIndex,
			true,	-- (overwrite flag)
			nil)	-- (slot selector)

		-- The new set should be active after creation.
		AS2.activeModel:ActivateActionSet(buttonSetIndex, actionSetIndex)

		return actionSetIndex, actionSet
	end
end

-- Creates a new glyph set and fills it with data.
function UIOperations:CreateGlyphSet(name, icon)
	assert(name, "NIL_ARGUMENT")
	local glyphSetIndex, glyphSet = AS2.activeModel.glyphSetList:AddGlyphSet(GlyphSet:Create(name, AS2.activeModel:GetDataContext()))
	assert(glyphSetIndex and glyphSet)
	glyphSet:SetIcon(icon)

	AS2.activeModel:SaveToGlyphSet(glyphSetIndex,
		true,	-- (overwrite flag)
		nil)	-- (slot selector)

	-- The new set should be active after creation.
	AS2.activeModel:BeginActivatingGlyphSet(glyphSetIndex)

	return glyphSetIndex, glyphSet
end

-- Creates a new talent set and fills it with data.
function UIOperations:CreateTalentSet(name, icon)
	assert(name, "NIL_ARGUMENT")
	local talentSetIndex, talentSet = AS2.activeModel.talentSetList:AddTalentSet(TalentSet:Create(name, AS2.activeModel:GetDataContext()))
	assert(talentSetIndex and talentSet)
	talentSet:SetIcon(icon)

	AS2.activeModel:SaveToTalentSet(talentSetIndex,
		true,	-- (overwrite flag)
		nil)	-- (slot selector)

	-- The new set should be active after creation.
	AS2.activeModel:BeginActivatingTalentSet(talentSetIndex)

	return talentSetIndex, talentSet
end

-- Creates a new global keyset and fills it with data.
function UIOperations:CreateGlobalKeyset(name, icon)
	assert(name, "NIL_ARGUMENT")
	local globalKeysetIndex, globalKeyset = AS2.activeModel.globalKeysetList:AddKeyset(GlobalKeyset:Create(name, AS2.activeModel:GetDataContext()))
	assert(globalKeysetIndex and globalKeyset)
	globalKeyset:SetIcon(icon)

	-- The new set should contain the current setup.
	AS2.activeModel:SaveToGlobalKeyset(globalKeysetIndex,
		true,	-- (overwrite flag)
		nil)	-- (slot selector)

	-- The new set should be active after creation.
	AS2.activeModel:ActivateGlobalKeyset(globalKeysetIndex)

	return globalKeysetIndex, globalKeyset
end

-- Sets the includeKeybindings flag on a button set and then records data if necessary.
function UIOperations:SetIncludeKeybindings(buttonSetIndex, include)
	-- Do not allow this feature unless character-specific keybindings are enabled.
	if include and not AS2.activeGameModel:IsCharSpecificBindings() then
		AS2:ShowDialog(AS2.Popups.CANNOT_USE_FEATURE_WITHOUT_CHARSPECIFIC)
		return
	end

	assert(buttonSetIndex and include ~= nil, "NIL_ARGUMENT")
	local buttonSet = AS2.activeModel.buttonSetList:GetButtonSetAt(buttonSetIndex)
	if buttonSet then
		buttonSet:friend_SetIncludeKeybindings(include)
		AS2.activeModel:RecordAll()
	end
end

-- Equips an action set (silent failure)
function UIOperations:EquipActionSet(buttonSet, actionSet)
	local missingSpellsString = AS2.Model.Utilities:GenerateSpellNotFoundString(AS2.activeModel.buttonSetList, buttonSet, actionSet)
	-- Missing spells?  Warn the user that switching to this set will remove them.
	if missingSpellsString then
		PlaySound("igMainMenuOptionCheckBoxOn")
		AS2:HideDialogs(true)
		local dialog = AS2:ShowDialog(AS2.Popups.EQUIP_WARNING_SPELL_NOT_FOUND, actionSet:GetName(), missingSpellsString)
		if dialog then
			dialog.owner = self
			dialog.buttonSet = buttonSet
			dialog.actionSet = actionSet
		end
	else
		-- No missing spells?  Go ahead and equip the action set!
		UIOperations:EquipActionSet_2(buttonSet, actionSet)
	end
end

-- (helper for EquipActionSet)
function UIOperations:private_EquipWarningSpellNotFoundPopup_OnAccept(dialog)
	-- Create a backup, in case the user wants to undo the change
	dialog.actionSet:CreateProtectedAutomatedBackup()

	self:EquipActionSet_2(dialog.buttonSet, dialog.actionSet)
end

-- (helper for EquipActionSet)
function UIOperations:EquipActionSet_2(buttonSet, actionSet)
	local buttonSetIndex = AS2.activeModel.buttonSetList:FindButtonSet(buttonSet)
	if buttonSetIndex then
		local actionSetIndex = buttonSet:FindActionSet(actionSet)
		if actionSetIndex then
			AS2.activeModel:ActivateActionSet(buttonSetIndex, actionSetIndex)
		end
	end
end

-- Equips a glyph set (silent failure)
function UIOperations:EquipGlyphSet(glyphSet)
	local glyphSetIndex = AS2.activeModel.glyphSetList:FindGlyphSet(glyphSet)
	if glyphSetIndex then
		-- Save the previously active glyph set, in case we get canceled
		local previousSet = AS2.activeModel.glyphSetList:GetGlyphSetAt(AS2.activeModel.glyphSetList:GetActiveGlyphSet())

		AS2.activeModel:BeginActivatingGlyphSet(glyphSetIndex)

		-- Only if we're waiting on activation...
		if AS2.activeModel:IsActivatingGlyphSet() then 
			-- Hide the main window
			if AS2.mainWindow then AS2.mainWindow:Hide() end

			-- This is the first point glyph overlays may need to be shown, so create and show the frame
			AS2:ShowGlyphOverlayFrame()
		end

		-- Show / refresh the glyph set activation frame (regardless of whether we're waiting)
		AS2:ShowGlyphActivationFrame(glyphSet, previousSet)
	end
end

-- Equips a talent set (silent failure)
function UIOperations:EquipTalentSet(talentSet)
	local talentSetIndex = AS2.activeModel.talentSetList:FindTalentSet(talentSet)
	if talentSetIndex then
		-- Save the previously active talent set, in case we get canceled
		local previousSet = AS2.activeModel.talentSetList:GetTalentSetAt(AS2.activeModel.talentSetList:GetActiveTalentSet())

		AS2.activeModel:BeginActivatingTalentSet(talentSetIndex)

		-- Only if we're waiting on activation...
		if AS2.activeModel:IsActivatingTalentSet() then 
			-- Hide the main window
			if AS2.mainWindow then AS2.mainWindow:Hide() end

			-- This is the first point talent overlays may need to be shown, so create and show the frame
			AS2:ShowTalentOverlayFrame()
		end

		-- Show / refresh the talent set activation frame (regardless of whether we're waiting)
		AS2:ShowTalentActivationFrame(talentSet, previousSet)
	end
end

-- Equips a global keyset (silent failure)
function UIOperations:EquipGlobalKeyset(keyset)
	local keysetIndex = AS2.activeModel.globalKeysetList:FindKeyset(keyset)
	if keysetIndex then
		AS2.activeModel:ActivateGlobalKeyset(keysetIndex)
	end
end

-- Deletes the specified set from the specified set list (silent failure)
function UIOperations:DeleteSet(setList, buttonSet)
	if setList then
		local index = setList:FindSet(buttonSet)
		if index then
			setList:RemoveSetAt(index)
		end
	end
end

-- Moves the set at the specified index one position up (silent failure)
function UIOperations:MoveSetUp(setList, index)
	if setList then
		local set = setList:GetSetAt(index)		-- (make sure it exists to prevent error)
		if set then
			setList:MoveUp(index)
		end
	end
end

-- Moves the set at the specified index one position down (silent failure)
function UIOperations:MoveSetDown(setList, index)
	if setList then
		local set = setList:GetSetAt(index)		-- (make sure it exists to prevent error)
		if set then
			setList:MoveDown(index)
		end
	end
end

-- Deletes the given backup from the given backup list (silent failure)
function UIOperations:RemoveBackup(backupList, type, index)
	if backupList and index then
		if type == "AUTOMATED" then
			if index >= 1 and index <= backupList:GetAutomatedBackupCount() then
				backupList:RemoveAutomatedBackupAt(index)
			end
		elseif type == "MANUAL" then
			if index >= 1 and index <= backupList:GetManualBackupCount() then
				backupList:RemoveManualBackupAt(index)
			end
		end
	end
end

-- Sets the name of the manual backup at the given index in the given list (silent failure)
function UIOperations:SetManualBackupName(backupList, index, name)
	if backupList and index and name then
		if index >= 1 and index <= backupList:GetManualBackupCount() then
			backupList:SetManualBackupName(index, name)
		end
	end
end

-- Restores an action set from backup (silent failure)
function UIOperations:RestoreActionSetFromBackup(buttonSet, actionSet, backupEntry)
	local buttonSetIndex = AS2.activeModel.buttonSetList:FindButtonSet(buttonSet)
	if buttonSetIndex then
		local actionSetIndex = buttonSet:FindActionSet(actionSet)
		if actionSetIndex then
			AS2.activeModel:RestoreActionSetFromBackup(buttonSetIndex, actionSetIndex, backupEntry)
		end
	end
end

-- Restores a glyph set from backup (silent failure)
function UIOperations:RestoreGlyphSetFromBackup(glyphSet, backupEntry)
	local glyphSetIndex = AS2.activeModel.glyphSetList:FindGlyphSet(glyphSet)
	local activeSet = AS2.activeModel.glyphSetList:GetActiveGlyphSet()
	if glyphSetIndex then
		AS2.activeModel:RestoreGlyphSetFromBackup(glyphSetIndex, backupEntry)

		-- Activate the glyph set if it was previously active; the model doesn't do this for glyph sets because it involves a UI component.
		if glyphSetIndex == activeSet then
			self:EquipGlyphSet(glyphSet)
		end
	end
end

-- Restores a talent set from backup (silent failure)
function UIOperations:RestoreTalentSetFromBackup(talentSet, backupEntry)
	local talentSetIndex = AS2.activeModel.talentSetList:FindTalentSet(talentSet)
	local activeSet = AS2.activeModel.talentSetList:GetActiveTalentSet()
	if talentSetIndex then
		AS2.activeModel:RestoreTalentSetFromBackup(talentSetIndex, backupEntry)

		-- Activate the talent set if it was previously active; the model doesn't do this for talent sets because it involves a UI component.
		if talentSetIndex == activeSet then
			self:EquipTalentSet(talentSet)
		end
	end
end

-- Restores a global keyset from backup (silent failure)
function UIOperations:RestoreGlobalKeysetFromBackup(keyset, backupEntry)
	local keysetIndex = AS2.activeModel.globalKeysetList:FindKeyset(keyset)
	if keysetIndex then
		AS2.activeModel:RestoreGlobalKeysetFromBackup(keysetIndex, backupEntry)
	end
end

-- Saves the current setup to the given action set (silent failure)
function UIOperations:SaveActionSet(buttonSet, actionSet)
	local buttonSetIndex = AS2.activeModel.buttonSetList:FindButtonSet(buttonSet)
	if buttonSetIndex then
		local actionSetIndex = buttonSet:FindActionSet(actionSet)
		if actionSetIndex then
			AS2.activeModel:SaveToActionSet(buttonSetIndex, actionSetIndex,
				true,	-- (overwrite flag)
				nil)	-- (slot selector)

			-- Equip the set that was overwritten - the user will likely forget to.
			self:EquipActionSet(buttonSet, actionSet)
		end
	end
end

-- Saves the current setup to the given glyph set (silent failure)
function UIOperations:SaveGlyphSet(glyphSet)
	local glyphSetIndex = AS2.activeModel.glyphSetList:FindGlyphSet(glyphSet)
	if glyphSetIndex then
		AS2.activeModel:SaveToGlyphSet(glyphSetIndex,
			true,	-- (overwrite flag)
			nil)	-- (slot selector)

		-- Equip the glyph set that was overwritten - the user will likely forget to.
		self:EquipGlyphSet(glyphSet)

		-- Cancel glyph set activation if it wasn't instantaneous for some reason.
		if AS2.activeModel:IsActivatingGlyphSet() then
			AS2.activeModel:CancelGlyphSetActivation()
		end
	end
end

-- Saves the current setup to the given talent set (silent failure)
function UIOperations:SaveTalentSet(talentSet)
	local talentSetIndex = AS2.activeModel.talentSetList:FindTalentSet(talentSet)
	if talentSetIndex then
		AS2.activeModel:SaveToTalentSet(talentSetIndex,
			true,	-- (overwrite flag)
			nil)	-- (slot selector)

		-- Equip the talent set that was overwritten - the user will likely forget to.
		self:EquipTalentSet(talentSet)

		-- Cancel talent set activation if it wasn't instantaneous for some reason.
		if AS2.activeModel:IsActivatingTalentSet() then
			AS2.activeModel:CancelTalentSetActivation()
		end
	end
end

-- Saves the current setup to the given global keyset (silent failure)
function UIOperations:SaveGlobalKeyset(keyset)
	local keysetIndex = AS2.activeModel.globalKeysetList:FindKeyset(keyset)
	if keysetIndex then
		AS2.activeModel:SaveToGlobalKeyset(keysetIndex,
			true,	-- (overwrite flag)
			nil)	-- (slot selector)

		-- Equip the global keyset that was overwritten - the user will likely forget to.
		self:EquipGlobalKeyset(keyset)
	end
end

-- Includes all unused slots in the given button set.
function UIOperations:IncludeAllUnusedSlots(buttonSet)
	local bsList = AS2.activeModel.buttonSetList
	local buttonSetIndex = bsList:FindButtonSet(buttonSet)
	if buttonSetIndex then
		for slot = 1, AS2.NUM_ACTION_SLOTS do
			local oldBS = bsList:GetAssignedButtonSetForSlot(slot)
			if oldBS == nil then
				bsList:AssignSlotToButtonSet(slot, buttonSetIndex)
			end
		end
	end
end

-- Removes all slots from the given button set.
function UIOperations:DisincludeAllSlots(buttonSet)
	local bsList = AS2.activeModel.buttonSetList
	local buttonSetIndex = bsList:FindButtonSet(buttonSet)
	if buttonSetIndex then
		for slot = 1, AS2.NUM_ACTION_SLOTS do
			local oldBS = bsList:GetAssignedButtonSetForSlot(slot)
			if oldBS == buttonSetIndex then
				bsList:AssignSlotToButtonSet(slot, nil)
			end
		end
	end
end

-- Computes and returns the number of slots assigned to the given button set.
function UIOperations:CountSlotsMatchingButtonSet(buttonSet)
	local bsList = AS2.activeModel.buttonSetList
	local bsIndex = bsList:FindButtonSet(buttonSet)
	if not bsIndex then return 0 end
	local count = 0
	for i = 1, AS2.NUM_ACTION_SLOTS do
		if bsList:GetAssignedButtonSetForSlot(i) == bsIndex then
			count = count + 1
		end
	end
	return count
end

-- Unequips all action sets under the current spec, and displays a message.
function UIOperations:UnequipActionSets()
	if AS2.activeModel:UnequipActionSets() > 0 then
		AS2:ShowDialog(AS2.Popups.UNEQUIPPED_SETS, L["action sets"])
	end
end

-- Unequips all glyph sets under the current spec, and displays a message.
function UIOperations:UnequipGlyphSets()
	if AS2.activeModel:UnequipGlyphSets() > 0 then
		AS2:ShowDialog(AS2.Popups.UNEQUIPPED_SETS, L["glyph sets"])
	end
end

-- Unequips all talent sets under the current spec, and displays a message.
function UIOperations:UnequipTalentSets()
	if AS2.activeModel:UnequipTalentSets() > 0 then
		AS2:ShowDialog(AS2.Popups.UNEQUIPPED_SETS, L["talent sets"])
	end
end
