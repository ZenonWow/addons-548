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
local UIOperations = AS2.Controller.UIOperations

-- Searches all action, glyph, and keybinding sets and returns the one with the given name.
-- Returns: type ("ActionSet", "GlyphSet", "TalentSet", "GlobalKeyset", "Duplicate"), set[, context]
local function findSet(name)
	assert(name ~= nil)
	name = strlower(name)
	local objectType = nil
	local objectContext = nil
	local object = nil
	local limitTo = nil
	local function tryLimit(prefix, limitToValue)
		if strsub(name, 1, strlen(prefix)) == prefix then limitTo = limitToValue; name = strsub(name, 1 + strlen(prefix)) end
	end
	tryLimit(L["COMMAND_EQUIP_PREFIX_ACTION_SET"], "ActionSet")
	tryLimit(L["COMMAND_EQUIP_PREFIX_GLYPH_SET"], "GlyphSet")
	tryLimit(L["COMMAND_EQUIP_PREFIX_TALENT_SET"], "TalentSet")
	tryLimit(L["COMMAND_EQUIP_PREFIX_KEY_SET_1"], "GlobalKeyset")
	tryLimit(L["COMMAND_EQUIP_PREFIX_KEY_SET_2"], "GlobalKeyset")
	local function saveResult(type, objectToSave, contextToSave)
		if object then
			objectType = "Duplicate"
		else
			objectType = type
			object = objectToSave
			objectContext = contextToSave
		end
	end
	if not limitTo or limitTo == "ActionSet" then
		for i = 1, AS2.activeModel.buttonSetList:GetButtonSetCount() do
			local buttonSet = AS2.activeModel.buttonSetList:GetButtonSetAt(i)
			for j = 1, buttonSet:GetActionSetCount() do
				local actionSet = buttonSet:GetActionSetAt(j)
				if name == strlower(actionSet:GetName()) then
					saveResult("ActionSet", actionSet, buttonSet)
				end
			end
		end
	end
	if not limitTo or limitTo == "GlyphSet" then
		for i = 1, AS2.activeModel.glyphSetList:GetGlyphSetCount() do
			local glyphSet = AS2.activeModel.glyphSetList:GetGlyphSetAt(i)
			if name == strlower(glyphSet:GetName()) then
				saveResult("GlyphSet", glyphSet)
			end
		end
	end
	if not limitTo or limitTo == "TalentSet" then
		for i = 1, AS2.activeModel.talentSetList:GetTalentSetCount() do
			local talentSet = AS2.activeModel.talentSetList:GetTalentSetAt(i)
			if name == strlower(talentSet:GetName()) then
				saveResult("TalentSet", talentSet)
			end
		end
	end
	if not limitTo or limitTo == "GlobalKeyset" then
		for i = 1, AS2.activeModel.globalKeysetList:GetKeysetCount() do
			local keyset = AS2.activeModel.globalKeysetList:GetKeysetAt(i)
			if name == strlower(keyset:GetName()) then
				saveResult("GlobalKeyset", keyset)
			end
		end
	end
	return objectType, object, objectContext
end

-- Called when the user types a chat command.
function AS2:OnSlashCommand(msg)
	if not AS2:IsLoaded() then print(L["LOAD_FAILED"]); return end

	local nextWord = gmatch(msg, "[^%s]+")
	local command = nextWord()
	command = command and strlower(command)

	if not command or command == L["COMMAND_SHOW"] then
		-- Show the main window, but not if activating a glyph set.
		if not AS2.activeModel:IsActivatingGlyphSet() and not AS2.activeModel:IsActivatingTalentSet() then
			if self.mainWindow and self.mainWindow:IsShown() then
				self.mainWindow:Hide()
			else
				-- Create the main window, if it doesn't already exist.
				if not self.mainWindow then
					self.mainWindow = AS2.View.MainWindow:Create("ActionSwap2_MainWindow", UIParent)
					AS2.Controller.MainWindowController:Create(self.mainWindow)
					self.mainWindow:SetPoint("TOPLEFT", 150, -100)
				end

				self.mainWindow:Show()
			end
		end
	else
		if command == L["COMMAND_EQUIP"] then
			-- Put all the remaining text together.
			local setNames = nil
			local word = nextWord()
			while word do
				if not setNames then setNames = word else setNames = setNames .. " " .. word end
				word = nextWord()
			end

			-- Equip each set specified.
			if setNames then
				local nextSetName = gmatch(setNames, "[^,;]+")
				local setName = nextSetName()
				while setName ~= nil do
					setName = strtrim(setName)
					local setType, set, setContext = findSet(setName)
					if setType == nil then
						AS2:Printf(L["LESS_THAN_ONE"], setName)
					elseif setType == "Duplicate" then
						AS2:Printf(L["MORE_THAN_ONE"], setName)
					elseif setType == "ActionSet" then
						assert(setContext ~= nil)
						UIOperations:EquipActionSet(setContext, set)
					elseif setType == "GlyphSet" then
						UIOperations:EquipGlyphSet(set)
					elseif setType == "TalentSet" then
						UIOperations:EquipTalentSet(set)
					elseif setType == "GlobalKeyset" then
						UIOperations:EquipGlobalKeyset(set)
					else
						assert(false, "Unrecognized set type")
					end
					setName = nextSetName()
				end
			else
				AS2:Print(L["SYNTAX_EQUIP"])
			end

		elseif command == L["COMMAND_TUTORIAL"] then
			local word = nextWord()
			word = word and strlower(word)
			if not word or word == "show" then
				AS2:RedisplayTutorial()
			elseif word == "reset" then
				AS2:ResetTutorials()
			else
				AS2:Print(L["SYNTAX_TUTORIAL"])
			end

		else
			AS2:Print(L["SYNTAX"])
		end
	end
end
