--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- ActionSwap2.lua - This file contains the main addon functions, like OnInitialized, OnEnabled, etc.

local AS2 = ActionSwap2
local L = LibStub("AceLocale-3.0"):GetLocale("ActionSwap2", true)
local REVISION = tonumber(GetAddOnMetadata("ActionSwap2", "X-Revision"))
local CODE_REVISION = 13
local EventHandlers = AS2.Controller.EventHandlers

if AS2.DEBUG and LibDebug then LibDebug() end

-- Global frames, etc.
-- (AS2.mainWindow = nil)
AS2.actionButtonManager = AS2.Controller.ActionButtonManager	-- (singleton)
-- (AS2.includeButtonsFrame = nil)
-- (AS2.actionBarPreviewFrame = nil)
-- (AS2.setEditorDialog = nil)
-- (AS2.backupFrame = nil)
-- (AS2.tutorialFrame = nil)
-- (AS2.glyphSetActivationFrame = nil)
-- (AS2.glyphPreviewFrame = nil)
-- (AS2.glyphOverlayFrame = nil)
-- (AS2.talentSetActivationFrame = nil)
-- (AS2.talentPreviewFrame = nil)
-- (AS2.talentOverlayFrame = nil)
-- (AS2.discrepencies = nil)
-- (AS2.removals = nil)
-- (AS2.previousRevision = nil)

-- Debug levels
AS2.NOTE = "Note"
AS2.WARNING = "Warning"
AS2.BEGIN_TEST = "Begin test"
AS2.TEST_CASE = "Test case"
AS2.WAIT = "Wait"
AS2.RESUME = "Resume"
AS2.APPLY = "Apply"
AS2.DISCREPENCY = "Discrepency"
AS2.EVENT = "Event"
AS2.ACTION = "Action"

AS2.DebugLevels = {
	[AS2.NOTE]			= true,
	[AS2.WARNING]		= true,
	[AS2.BEGIN_TEST]	= true,
	[AS2.TEST_CASE]		= true,
	[AS2.WAIT]			= false,
	[AS2.RESUME]		= false,
	[AS2.APPLY]			= false,
	[AS2.DISCREPENCY]	= true,
	[AS2.EVENT]			= false,
	[AS2.ACTION]		= true
}

-- Constants
AS2.NUM_ACTION_SLOTS = 120	-- Total number of action slots available in WoW
AS2.NUM_MACRO_SLOTS = 36 + 18	-- Total number of macro slots available (so that we don't have to load the Macro UI)		MAINTENANCE: Add a test against MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS
AS2.NUM_GLYPH_SLOTS = 6		-- Number of glyph slots
AS2.NUM_TALENT_SLOTS = 6	-- Number of talent "slots" - i.e., rows
AS2.NUM_TALENTS_PER_SLOT = 3	-- Number of talents per slot
AS2.APPLY_INTERVAL = 2.0	-- How often to attempt re-applying of actions (in seconds)
AS2.APPLY_INTERVAL_0 = 0.5	--  ... and for the first retry?
AS2.NUM_SPECS = 2			-- Number of specs available

AS2.LIST_ITEM_WIDTH = 169
AS2.LIST_ITEM_HEIGHT = EQUIPMENTSET_BUTTON_HEIGHT

if not AS2.DEBUG then
	function AS2:Debug() end
else
	function AS2:Debug(level, ...)
		local value = AS2.DebugLevels[level]
		assert(value ~= nil, "Invalid debug level")
		if value then
			self:Print(_G["ChatFrame1"], "[" .. level .. "]", ...)
		end
	end
end

-- Register the chat command as soon as this file is loaded, so that the user at least gets an error message if loading fails.
AS2:RegisterChatCommand(L["CHAT_COMMAND_1"], "OnSlashCommand")
AS2:RegisterChatCommand(L["CHAT_COMMAND_2"], "OnSlashCommand")

function AS2:OnInitialize()
	-- Load / embed LibAdvancedIconSelector.
	local libAIS = LibStub("LibAdvancedIconSelector-1.0", true)
	if not libAIS then error(L["ERROR_NO_LAIS"]) end
	if not libAIS.GetRevision or libAIS.GetRevision() < 11 then error(L["ERROR_OLD_LAIS"]) end
	libAIS:Embed(AS2)

	if not _G.ActionSwap2CharacterData then _G.ActionSwap2CharacterData = { } end

	-- Make sure the correct TOC is being used.
	assert(REVISION == CODE_REVISION, "TOC and code revision numbers are out of sync - please restart World of Warcraft.  If this error happens again, please report it.")

	-- Check for data written by future, incompatible versions, so that we don't accidentally mess it up.
	if ActionSwap2CharacterData.minimumRevision and ActionSwap2CharacterData.minimumRevision > REVISION then
		AS2:ShowDialog(AS2.Popups.MINIMUM_VERSION)
		return	-- (abort loading this addon)
	end

	-- For upgrade purposes, remember the revision that the SavedVariables was last written under.
	AS2.previousRevision = ActionSwap2CharacterData.currentRevision or REVISION

	self:RegisterMessage(self, "ActionBarPageChanged")
	self:RegisterMessage(self, "ApplyFinished")
	self:RegisterMessage(self, "AfterActiveSpecChanged")
	self:RegisterMessage(self, "ActivationFinished")
	self:RegisterMessage(self, "SlotRecorded")
	self:RegisterMessage(self, "GlyphAdded")
	self:RegisterMessage(self, "GlyphRemoved")
	self:RegisterMessage(self, "GlyphTargetsCleared")
	self:RegisterMessage(self, "SpellsChanged")
	self:RegisterMessage(self, "TalentAdded")
	self:RegisterMessage(self, "TalentRemoved")
	self:RegisterMessage(self, "TalentTargetsCleared")
	self:RegisterMessage(self, "TutorialsChanged")

	self.activeModel = AS2.Model.Model:CreateWithDataSource(ActionSwap2CharacterData)
	self.activeGameModel = AS2.Model.RealGameModel

	self:RegisterEvent("CONFIRM_TALENT_WIPE", function(_,_,id) EventHandlers:OnPrepareTalentWipe(id) end)
	hooksecurefunc("ConfirmTalentWipe", function() EventHandlers:OnConfirmTalentWipe() end)
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED", function(_,slot) EventHandlers:OnActionChanged(slot) end)
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", function() EventHandlers:OnActiveSpecChanged() end)
	self:RegisterEvent("UPDATE_BINDINGS", function() EventHandlers:OnUpdateBindings() end)
	self:RegisterEvent("GLYPH_ADDED", function(_,slot) EventHandlers:OnGlyphAdded(slot) end)
	self:RegisterEvent("GLYPH_REMOVED", function(_,slot) EventHandlers:OnGlyphRemoved(slot) end)
	self:RegisterEvent("GLYPH_UPDATED", function(_,slot) EventHandlers:OnGlyphUpdated(slot) end)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", function(_) EventHandlers:OnTalentsUpdated() end)
	self:RegisterEvent("PLAYER_LOGIN", function() AS2:OnLogin() end)

	-- No differentiation between shapeshift / action bar paging... they currently mean the same thing to this addon
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", function() AS2:Debug(AS2.EVENT, "ACTIONBAR_PAGE_CHANGED"); AS2:SendMessage(AS2, "ActionBarPageChanged") end)
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", function() AS2:Debug(AS2.EVENT, "UPDATE_SHAPESHIFT_FORM"); AS2:SendMessage(AS2, "ActionBarPageChanged") end)
	self:RegisterEvent("SPELLS_CHANGED", function() EventHandlers:OnSpellsChanged() end)

	self.tempFrame = CreateFrame("Frame", "AS2TempFrame")
	self.tempFrame:SetScript("OnUpdate", self.OnUpdate)
	self.tempFrame:SetPoint("TOPLEFT")

	AS2.includeButtonsFrame = AS2.View.IncludeButtonsFrame:Create("ActionSwap2_IncludeButtonsFrame", UIParent)
	AS2.actionBarPreviewFrame = AS2.View.ActionBarPreviewFrame:Create("ActionSwap2_ActionBarPreviewFrame", UIParent)

	self.activeModel:SetLoaded(true)	-- Good enough if we reach this point without error!  Let the addon be used!

	if AS2.previousRevision < 8 then
		-- If upgrading from Cataclysm data (revision 7-) to Mists of Pandaria data (revision 8+), warn that the
		-- glyph sets are being reset.
		if self.activeModel.glyphSetList:GetGlyphSetCount() > 0 then
			AS2:ShowDialog(AS2.Popups.GLYPH_SETS_RESET)
		end
		
		-- Also unequip all sets, to prevent recording before a new specialization has been chosen.
		if self.activeModel:UnequipAllSets() > 0 then
			AS2:ShowDialog(AS2.Popups.ALL_SETS_UNEQUIPPED)
		end
	end
	
	EventHandlers:OnModelSwitch()		-- Need to fire this event for the initial model.

	-- (do this AFTER the load / upgrade has completed successfuly)
	_G.ActionSwap2CharacterData.minimumRevision = 8	-- (save may not be opened by a version of ActionSwap2 released before Mists of Pandaria)
	_G.ActionSwap2CharacterData.currentRevision = REVISION

	self:Debug(AS2.EVENT, "Addon loaded")
end

function AS2:OnEnable()		-- MAINTENANCE: Can this ever actually be called?
	self:Debug(AS2.EVENT, "Addon enabled")
end

function AS2:OnDisable()	-- MAINTENANCE: Can this ever actually be called?
	self:Debug(AS2.EVENT, "Addon disabled")
end

-- Returns true if the addon was initialized successfully.
function AS2:IsLoaded()
	return self.activeModel and self.activeModel:IsLoaded()
end

function AS2:OnLogin()
	if not AS2:IsLoaded() then return end

	-- Optimize the tables if upgrading from a version that didn't always optimize perfectly.
	if AS2.previousRevision < 5 then
		AS2:Debug(AS2.NOTE, "Optimizing tables...")
		self.activeModel.dataContext.qcTableCache:Optimize()
	end

	-- If in debug mode, verify that all tables are still optimal; this will expose any optimization errors
	if AS2.DEBUG then assert(self.activeModel.dataContext.qcTableCache:CheckIsOptimal()) end

	-- Handle the login event (records all actions, etc.)
	EventHandlers:OnLogin()
end

function AS2.OnUpdate()

	EventHandlers:ProcessDelayedRecords()

	-- Run any dispatched functions.
	AS2:RunDispatched()

	-- (coroutines are sometimes used in tests to wait for asynchronous action bar changes)
	if AS2.coResume and AS2.co1 then
		AS2.coResume = false
		local status, message = coroutine.resume(AS2.co1)
		if not status or coroutine.status(AS2.co1) == "dead" then
			if message then _ERRORMESSAGE(message .. "\n---- BEGIN STACK ----\n" .. debugstack(AS2.co1, 1)) end
			AS2.co1 = nil
		end
	end

	-- Delay the rest of the update code until we're actually loaded.
	if not AS2:IsLoaded() then return end

	-- Since there's no event fired after the actions associated with a spec change are applied, make
	-- one of our own, fired on the 2nd update after the spec change.
	if AS2.ticksSinceSpecChange then
		AS2:Debug(AS2.EVENT, "OnUpdate after spec change")
		AS2.ticksSinceSpecChange = AS2.ticksSinceSpecChange + 1
		if AS2.ticksSinceSpecChange == 2 then
			AS2.ticksSinceSpecChange = nil
			EventHandlers:AfterActiveSpecChanged()
		end
	end
end

-- Restores the original model, if it had been replaced.
function AS2:RestoreOriginalModels()
	-- This is a good place to ensure all tables were left in an optimized state after the unit tests have run.
	if AS2.DEBUG and self.activeModel then
		assert(self.activeModel.dataContext.qcTableCache:CheckIsOptimal())
	end
	if self.originalModel then
		self.activeModel = self.originalModel
		self.originalModel = nil
	end
	if self.originalGameModel then
		self.activeGameModel = self.originalGameModel
		self.originalGameModel = nil
	end
	EventHandlers:OnModelSwitch()
end

-- Used in unit testing, this function replaces the "model" (effectively, the saved variables) with the specified one.
function AS2:SwitchToVirtualModel(model)
	if not self.originalModel then self.originalModel = self.activeModel end
	self.activeModel = model
	model:SetLoaded(true)
	EventHandlers:OnModelSwitch()
end

-- Used in unit testing, this function replaces the "game model" (interface to WoW) with the specified one.
function AS2:SwitchToVirtualGameModel(model)
	if not self.originalGameModel then self.originalGameModel = self.activeGameModel end
	self.activeGameModel = model
	EventHandlers:OnModelSwitch()
end

-- Creates, or reuses a set editor dialog.
function AS2:CreateOrGetSetEditorDialog(parent)
	if not AS2.setEditorDialog then
		AS2.setEditorDialog = AS2.View.SetEditorDialog:Create("ActionSwap2_SetEditorDialog", parent)
	else
		AS2.setEditorDialog:SetParent(parent)
	end
	AS2.setEditorDialog:Hide()	-- (the caller may need to set parameters before the dialog is displayed)
	return AS2.setEditorDialog
end

-- Creates, or reuses the backup frame.
function AS2:CreateBackupFrame(parent, owner)
	assert(owner)	-- (the backup frame should be owned at all times, even if hidden)
	if not AS2.backupFrame then
		AS2.backupFrame = AS2.View.BackupFrame:Create("ActionSwap2_BackupFrame", parent)
		AS2.backupFrame.controller = AS2.Controller.BackupFrameController:Create(AS2.backupFrame)

		-- Let the "new backup" and "restore backup" messages pass through to the backup frame's owner
		AS2:AddCallback(AS2.backupFrame.controller, "NewBackup", function(backupFrame, sender, ...)
			backupFrame.owner:OnNewBackup(backupFrame, ...)
		end, AS2.backupFrame)

		AS2:AddCallback(AS2.backupFrame.controller, "RestoreBackup", function(backupFrame, sender, ...)
			backupFrame.owner:OnRestoreBackup(backupFrame, ...)
		end, AS2.backupFrame)
	else
		AS2.backupFrame:SetParent(parent)
	end
	AS2.backupFrame:Hide()		-- (the caller may need to set parameters before the dialog is displayed)
	AS2.backupFrame.owner = owner
	if parent then AS2.backupFrame:PositionBelow(parent) end	-- (initial position is BELOW the parent frame)
	return AS2.backupFrame
end

-- Creates, or reuses the glyph activation frame.
function AS2:ShowGlyphActivationFrame(glyphSet, previousSet)
	if not AS2.glyphSetActivationFrame then
		AS2.glyphSetActivationFrame = AS2.View.GlyphActivationFrame:Create("ActionSwap2_GlyphActivationFrame", UIParent)
		AS2.glyphSetActivationFrame.controller = AS2.Controller.GlyphActivationFrameController:Create(AS2.glyphSetActivationFrame)
		AS2.glyphSetActivationFrame:SetPoint("CENTER", 250, 50)
	else
		-- (refresh the frame, regardless of whether we're activating)
		AS2.glyphSetActivationFrame.controller:Refresh()
	end

	-- Don't actually SHOW the frame unless we're really activating.
	if AS2.activeModel:IsActivatingGlyphSet() then
		AS2.glyphSetActivationFrame.controller:SetPreviousSet(previousSet)
		AS2.glyphSetActivationFrame:Show()
	end
end

-- Creates, or reuses the talent activation frame.
function AS2:ShowTalentActivationFrame(talentSet, previousSet)
	if not AS2.talentSetActivationFrame then
		AS2.talentSetActivationFrame = AS2.View.TalentActivationFrame:Create("ActionSwap2_TalentActivationFrame", UIParent)
		AS2.talentSetActivationFrame.controller = AS2.Controller.TalentActivationFrameController:Create(AS2.talentSetActivationFrame)
		AS2.talentSetActivationFrame:SetPoint("CENTER", 250, 50)
	else
		-- (refresh the frame, regardless of whether we're activating)
		AS2.talentSetActivationFrame.controller:Refresh()
	end

	-- Don't actually SHOW the frame unless we're really activating.
	if AS2.activeModel:IsActivatingTalentSet() then
		AS2.talentSetActivationFrame.controller:SetPreviousSet(previousSet)
		AS2.talentSetActivationFrame:Show()
	end
end

-- Creates, or reuses the glyph preview frame.
function AS2:CreateGlyphPreviewFrame(parent, owner)
	if not AS2.glyphPreviewFrame then
		AS2.glyphPreviewFrame = AS2.View.GlyphPreviewFrame:Create("ActionSwap2_GlyphPreviewFrame", parent)
	else
		AS2.glyphPreviewFrame:SetParent(parent)
	end
	AS2.glyphPreviewFrame.owner = owner
	return AS2.glyphPreviewFrame
end

-- Creates, or reuses the talent preview frame.
function AS2:CreateTalentPreviewFrame(parent, owner)
	if not AS2.talentPreviewFrame then
		AS2.talentPreviewFrame = AS2.View.TalentPreviewFrame:Create("ActionSwap2_TalentPreviewFrame", parent)
	else
		AS2.talentPreviewFrame:SetParent(parent)
	end
	AS2.talentPreviewFrame.owner = owner
	return AS2.talentPreviewFrame
end

-- Creates and shows the glyph overlay frame.
function AS2:ShowGlyphOverlayFrame()
	if not AS2.glyphOverlayFrame then
		AS2.glyphOverlayFrame = AS2.View.GlyphOverlayFrame:Create("ActionSwap2_GlyphOverlayFrame", UIParent)
		_G.GlyphFrame:HookScript("OnShow", function()
			if AS2.activeModel:IsActivatingGlyphSet() then
				AS2.glyphOverlayFrame:Show()
			end
		end)
		_G.GlyphFrame:HookScript("OnHide", function()
			AS2.glyphOverlayFrame:Hide()
		end)
	end

	-- If the frame is already visible, don't wait for an OnShow()!  Show the overlays immediately!
	if _G.GlyphFrame:IsVisible() then
		AS2.glyphOverlayFrame:Show()
	end
end

-- Creates and shows the talent overlay frame.
function AS2:ShowTalentOverlayFrame()
	if not AS2.talentOverlayFrame then
		AS2.talentOverlayFrame = AS2.View.TalentOverlayFrame:Create("ActionSwap2_TalentOverlayFrame", UIParent)
		_G.PlayerTalentFrameTalentsTalentRow1Talent1:HookScript("OnShow", function()
			if AS2.activeModel:IsActivatingTalentSet() then
				AS2.talentOverlayFrame:Show()
			end
		end)
		_G.PlayerTalentFrameTalentsTalentRow1Talent1:HookScript("OnHide", function()
			AS2.talentOverlayFrame:Hide()
		end)
	end

	-- If the frame is already visible, don't wait for an OnShow()!  Show the overlays immediately!
	if _G.PlayerTalentFrameTalentsTalentRow1Talent1:IsVisible() then
		AS2.talentOverlayFrame:Show()
	end
end

-- Shows the specified dialog
function AS2:ShowDialog(template, ...)
	local dialog = AS2.View.DialogUI:CreateDialog(template, ...)
	AS2.View.DialogUI:ShowDialog(dialog)
	return dialog
end

-- Hides / cancels many of the dialogs used in this addon.
function AS2:HideDialogs(keepBackupFrame)
	if AS2.setEditorDialog then AS2.setEditorDialog:Hide() end
	if AS2.backupFrame and not keepBackupFrame then AS2.backupFrame:Hide() end
	AS2.View.DialogUI:HideDialogsWithTemplate(AS2.Popups.DELETE_SET)
	AS2.View.DialogUI:HideDialogsWithTemplate(AS2.Popups.DELETE_BACKUP)
	AS2.View.DialogUI:HideDialogsWithTemplate(AS2.Popups.EDIT_BACKUP)
	AS2.View.DialogUI:HideDialogsWithTemplate(AS2.Popups.RESTORE_SET)
	AS2.View.DialogUI:HideDialogsWithTemplate(AS2.Popups.SAVE_SET)
	AS2.View.DialogUI:HideDialogsWithTemplate(AS2.Popups.EQUIP_WARNING)
	AS2.View.DialogUI:HideDialogsWithTemplate(AS2.Popups.EQUIP_WARNING_SPELL_NOT_FOUND)
	AS2.View.DialogUI:HideDialogsWithTemplate(AS2.Popups.DISINCLUDE_WARNING)
	AS2.View.DialogUI:HideDialogsWithTemplate(AS2.Popups.SELECTALL_CONFIRM)
	AS2.View.DialogUI:HideDialogsWithTemplate(AS2.Popups.SELECTNONE_CONFIRM)
end

-- Loads the glyph UI if it hasn't already been loaded
local glyphUILoaded = false
function AS2:LoadGlyphUI()
	if not glyphUILoaded then
		glyphUILoaded = true

		-- (The glyph UI will start glitching horribly if we don't load the talent UI first)
		AS2:LoadTalentUI()

		AS2:Debug(AS2.NOTE, "Loading glyph UI")
		LoadAddOn("Blizzard_GlyphUI")
	end
end

-- Loads the talent UI if it hasn't already been loaded
local talentUILoaded = false
function AS2:LoadTalentUI()
	if not talentUILoaded then
		talentUILoaded = true

		AS2:Debug(AS2.NOTE, "Loading talent UI")
		LoadAddOn("Blizzard_TalentUI")
	end
end
