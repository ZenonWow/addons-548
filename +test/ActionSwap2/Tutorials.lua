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
local Widgets = AS2.View.Widgets

local tutorialOffset = -1
local activeTutorial = nil
local startedTutorials = { }

local tutorials = {
	TUTORIAL_WELCOME = {
		prereqs = { },
		tileHeight = 16,
		closeText = L["Next"],
		completeOnClose = true },
	TUTORIAL_FIRST_BUTTON_SET = {
		prereqs = { "TUTORIAL_WELCOME" },
		tileHeight = 11 },
	TUTORIAL_CLICK_SELECT_BUTTONS = {
		prereqs = { "TUTORIAL_FIRST_BUTTON_SET" },	-- Toggles w/ next one based on state of button
		tileHeight = 8 },
	TUTORIAL_PICK_BUTTONS = {
		prereqs = { "TUTORIAL_FIRST_BUTTON_SET" },	-- Toggles w/ previous one based on state of button
		tileHeight = 18 },
	TUTORIAL_FIRST_ACTION_SET = {
		prereqs = { "TUTORIAL_PICK_BUTTONS" },
		tileHeight = 20,
		skippable = true },
	TUTORIAL_SECOND_ACTION_SET = {
		prereqs = { "TUTORIAL_FIRST_ACTION_SET" },
		tileHeight = 13,
		skippable = true },
	TUTORIAL_RETURN_FIRST_ACTION_SET = {
		prereqs = { "TUTORIAL_SECOND_ACTION_SET" },
		tileHeight = 17,
		skippable = true },
	TUTORIAL_ACTION_SET_TIPS = {
		prereqs = { "TUTORIAL_RETURN_FIRST_ACTION_SET" },
		tileHeight = 21,
		closeText = L["Next"],
		completeOnClose = true },
	TUTORIAL_ACTION_SET_TIPS_2 = {
		prereqs = { "TUTORIAL_ACTION_SET_TIPS" },
		tileHeight = 20,
		closeText = L["Next"],
		completeOnClose = true },
	TUTORIAL_VIEW_BACKUPS = {
		prereqs = { "TUTORIAL_ACTION_SET_TIPS_2" },
		tileHeight = 10 },
	TUTORIAL_CREATE_MANUAL_BACKUP = {
		prereqs = { "TUTORIAL_VIEW_BACKUPS" },
		tileHeight = 18,
		arrowDirection = "RIGHT",
		skippable = true },
	TUTORIAL_CLICK_GLYPH_SETS_BUTTON = {
		prereqs = { "TUTORIAL_CREATE_MANUAL_BACKUP" },
		tileHeight = 9 },
	TUTORIAL_FIRST_GLYPH_SET = {
		prereqs = { "TUTORIAL_CLICK_GLYPH_SETS_BUTTON" },
		tileHeight = 7,
		skippable = true },
	TUTORIAL_SECOND_GLYPH_SET = {
		prereqs = { "TUTORIAL_FIRST_GLYPH_SET" },
		tileHeight = 5,
		skippable = true },
	TUTORIAL_EQUIP_GLYPH_SET = {
		prereqs = { "TUTORIAL_SECOND_GLYPH_SET" },
		tileHeight = 20,
		skippable = true },
	TUTORIAL_TALENT_SETS = {
		prereqs = { "TUTORIAL_EQUIP_GLYPH_SET" },
		tileHeight = 13,
		closeText = L["Next"],
		completeOnClose = true },
	TUTORIAL_KEYBINDING_SETS = {
		prereqs = { "TUTORIAL_TALENT_SETS" },
		tileHeight = 27,
		closeText = L["Next"],
		completeOnClose = true },
	TUTORIAL_END = {
		prereqs = { "TUTORIAL_KEYBINDING_SETS" },
		tileHeight = 16,
		closeText = L["Finish"],
		completeOnClose = true,
		isEnd = true },
}

function AS2:SetTutorialInfo(tutorialName, owner, parent, anchor, offX, offY, arrowAnchor, arrowPoint, arrowOffX, arrowOffY)
	local tutorialData = tutorials[tutorialName]
	assert(tutorialData, "Reference to nonexisting tutorial")
	if not parent then
		AS2:Debug(AS2.WARNING, "Trying to assign a tutorial frame to a nil parent")
	end
	tutorialData.owner = owner
	tutorialData.parent = parent
	tutorialData.anchor = anchor
	tutorialData.offX = (offX or 0) + (arrowAnchor and 60 or 8)
	tutorialData.offY = (offY or 0) + 16
	tutorialData.arrowAnchor = arrowAnchor
	tutorialData.arrowPoint = arrowPoint
	tutorialData.arrowOffX = (arrowOffX or 0) + 4
	tutorialData.arrowOffY = (arrowOffY or 0)
	tutorialData.setUp = true

	-- Update the active tutorial.
	if activeTutorial == tutorialName then
		AS2:DisplayTutorial(tutorialName, true)
	end

	AS2:SendMessage(AS2, "TutorialsChanged")
end

-- Tests whether the tutorial with the given name is able to be activated.
function AS2:TryActivateTutorial(tutorialName)
	-- Tutorials cannot be activated unless they are shown.
	if not AS2.activeModel:AreTutorialsShown() then
		return false
	end

	local tutorialData = tutorials[tutorialName]
	assert(tutorialData, "Reference to nonexisting tutorial")

	-- Don't activate a tutorial if the info hasn't been set up yet.
	if not tutorialData.setUp then
		return false
	end

	-- Don't do anything if this tutorial is already the active one.
	if activeTutorial == tutorialName then
		return false
	end

	-- Don't activate tutorials that are already completed.
	if AS2.activeModel:IsTutorialCompleted(tutorialName) then
		return false
	end

	-- Don't activate tutorials for which prereqs aren't met.
	for _, prereq in ipairs(tutorialData.prereqs) do
		assert(tutorials[prereq], "Reference to nonexisting tutorial")
		if not AS2.activeModel:IsTutorialCompleted(prereq) then
			return false
		end
	end

	-- Don't activate a tutorial unless its parent is visible.
	if tutorialData.parent and not tutorialData.parent:IsVisible() then
		return false
	end

	-- Set the active tutorial, and show the tutorial frame.
	AS2.activeModel:AddTutorialToHistory(tutorialName)
	tutorialOffset = -1
	activeTutorial = tutorialName
	startedTutorials[tutorialName] = true
	self:DisplayTutorial(tutorialName, true)
	self:private_UpdateTutorialButtonStates()

	return true
end

-- Completes the given tutorial, but only if been activated.
function AS2:CompleteTutorial(tutorialName)
	-- Tutorials cannot be completed unless they are shown.
	if not AS2.activeModel:AreTutorialsShown() then
		return false
	end

	local tutorialData = tutorials[tutorialName]
	assert(tutorialData, "Reference to nonexisting tutorial")

	if startedTutorials[tutorialName] then
		if tutorialName == activeTutorial then
			activeTutorial = nil	-- (Do this FIRST)
			if AS2.tutorialFrame then AS2.tutorialFrame:Hide() end
		end
		AS2.activeModel:friend_MarkTutorialCompleted(tutorialName)	-- (may fire an event!)

		-- In case more minor tutorial steps are added in the future, hide tutorials when the tutorial is finished.
		if tutorialData.isEnd then
			AS2.activeModel:SetShowTutorials(false)
		end
	end
end

-- Returns the owner of the active tutorial.
function AS2:GetActiveTutorial()
	return activeTutorial
end

function AS2:RedisplayTutorial()
	tutorialOffset = -1		-- (go back to the most recent one)
	local name = AS2.activeModel:GetTutorialHistory(tutorialOffset)
	if name then
		AS2:DisplayTutorial(name, true)
		self:private_UpdateTutorialButtonStates()
	end
end

-- Shows the tutorial window, properly anchored and arrow-ed for the currently active tutorial.
function AS2:DisplayTutorial(tutorialName, reanchor)
	local tutorialData = tutorials[tutorialName]
	assert(tutorialData, "Reference to nonexisting tutorial")

	-- Re-enable tutorials.  Otherwise, some tutorials (i.e., the select buttons one) can act bizarre and never hide.
	AS2.activeModel:SetShowTutorials(true)

	-- Create the tutorial frame if it doesn't exist.
	if not AS2.tutorialFrame then
		AS2.tutorialFrame = AS2.View.TutorialFrame:Create("ActionSwap2_TutorialFrame", UIParent)

		-- (Some tutorials need to be completed when the tutorial frame is closed.)
		AS2.tutorialFrame.closeButton:SetScript("OnClick", self.private_Tutorial_XButton_OnClick)
		AS2.tutorialFrame.closeButton2:SetScript("OnClick", self.private_Tutorial_CloseButton_OnClick)
		AS2.tutorialFrame.prevButton:SetScript("OnClick", self.private_PrevButton_OnClick)
		AS2.tutorialFrame.nextButton:SetScript("OnClick", self.private_NextButton_OnClick)
		AS2.tutorialFrame.skipButton:SetScript("OnClick", self.private_SkipButton_OnClick)
		AS2.tutorialFrame:SetScript("OnShow", function() self:private_UpdateTutorialButtonStates() end)
	end

	AS2.tutorialFrame:Show()

	-- Update the contents of the tutorial frame.
	local frame = AS2.tutorialFrame
	frame:SetTileHeight(tutorialData.tileHeight)
	frame:SetContent(L[tutorialName .. "_HEADER"],	-- Tutorial header text
		L[tutorialName],							-- Tutorial text
		tutorialName == activeTutorial and tutorialData.closeText or L["Close"])		-- Close button text
	
	if reanchor then
		-- Set the parent, but only if it exists and is visible.
		if tutorialData.parent and tutorialData.parent:IsVisible() then
			frame:SetParent(tutorialData.parent)
			
			-- Position the tutorial frame significantly above its parent, in case other child frames are created.
			-- We can't put it on a different strata because dialogs need to show up above it, yet the main window is already on the HIGH strata.
			Widgets:PositionAboveFrameLevel(frame, tutorialData.parent:GetFrameLevel() + 10)
		else
			frame:SetParent(UIParent)
		end

		-- Set the anchor, but only if it exists and is visible.
		frame:ClearAllPoints()
		if tutorialData.anchor and tutorialData.anchor:IsVisible() then
			local right = tutorialData.arrowDirection and tutorialData.arrowDirection == "RIGHT"
			if right then 
				frame:SetPoint("TOPRIGHT", tutorialData.anchor, "TOPLEFT", -tutorialData.offX, tutorialData.offY)
			else
				frame:SetPoint("TOPLEFT", tutorialData.anchor, "TOPRIGHT", tutorialData.offX, tutorialData.offY)
			end
			
			if tutorialData.arrowAnchor and tutorialData.arrowAnchor:IsVisible() then
				if right then 
					frame:SetArrowAnchor(right, tutorialData.arrowAnchor, tutorialData.arrowPoint, -tutorialData.arrowOffX, tutorialData.arrowOffY)
				else
					frame:SetArrowAnchor(right, tutorialData.arrowAnchor, tutorialData.arrowPoint, tutorialData.arrowOffX, tutorialData.arrowOffY)
				end
			else
				frame:SetArrowAnchor(nil)
			end
		else
			frame:SetPoint("CENTER")
			frame:SetArrowAnchor(nil)
		end
	end
end

-- Called when the X button is clicked.
function AS2.private_Tutorial_XButton_OnClick(button)
	AS2.tutorialFrame:Hide()
	AS2:private_ShowHideTutorialsPopup()
end

-- Called when the close / next button is clicked.
function AS2.private_Tutorial_CloseButton_OnClick(button)
	AS2.tutorialFrame:Hide()	-- Hide BEFORE completing the tutorial; otherwise we might be hiding the next one!
	if activeTutorial and tutorials[activeTutorial].completeOnClose then
		AS2:CompleteTutorial(activeTutorial)	-- (may fire an event)
	else
		AS2:private_ShowHideTutorialsPopup()
	end
end

-- Asks the user if they want to disable tutorials, if not already completed.
function AS2:private_ShowHideTutorialsPopup()
	-- Show the dialog asking if the user wants to abandon the tutorial, but only if we haven't already completed them.
	if not AS2.activeModel:IsTutorialCompleted("TUTORIAL_END") then
		local dialog = AS2:ShowDialog(AS2.Popups.HIDE_TUTORIALS)
		if dialog then
			dialog.owner = self
		end
	end
end

-- Called when the user clicks "Yes" on the "Hide tutorials" dialog.
function AS2:private_HideTutorialsPopup_OnAccept(dialog)
	AS2.activeModel:SetShowTutorials(false)
end

-- Called when the user clicks "No" on the "Hide tutorials" dialog.
function AS2:private_HideTutorialsPopup_OnCancel(dialog)
	self:RedisplayTutorial()	-- Bring the tutorial back; this tutorial is very linear and won't make sense if hidden.
end

function AS2:private_UpdateTutorialButtonStates()
	if AS2.activeModel:GetTutorialHistory(tutorialOffset - 1) ~= nil then
		AS2.tutorialFrame.prevButton:Enable()
	else
		AS2.tutorialFrame.prevButton:Disable()
	end
	if AS2.activeModel:GetTutorialHistory(tutorialOffset + 1) ~= nil then
		AS2.tutorialFrame.nextButton:Enable()
		AS2.tutorialFrame.skipButton:Hide()
	else
		AS2.tutorialFrame.nextButton:Disable()
		if activeTutorial and tutorials[activeTutorial].skippable then
			AS2.tutorialFrame.skipButton:Show()
		else
			AS2.tutorialFrame.skipButton:Hide()
		end
	end
end

function AS2:private_PrevButton_OnClick(button)
	local name = AS2.activeModel:GetTutorialHistory(tutorialOffset - 1)
	if name then
		tutorialOffset = tutorialOffset - 1
		AS2:DisplayTutorial(name, false)
		AS2:private_UpdateTutorialButtonStates()
	end
end

function AS2:private_NextButton_OnClick(button)
	local name = AS2.activeModel:GetTutorialHistory(tutorialOffset + 1)
	if name then
		tutorialOffset = tutorialOffset + 1
		AS2:DisplayTutorial(name, false)
		AS2:private_UpdateTutorialButtonStates()
	end
end

function AS2:private_SkipButton_OnClick(button)
	if activeTutorial and tutorials[activeTutorial].skippable then
		AS2:CompleteTutorial(activeTutorial)
	end
end

-- Resets all tutorials, including history and setting showTutorials to true.
function AS2:ResetTutorials()
	tutorialOffset = -1
	activeTutorial = nil
	AS2.activeModel:friend_ResetTutorials()
end