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
local ActionBarPreviewFrame = AS2.View.ActionBarPreviewFrame
local Utilities = AS2.Model.Utilities
local Widgets = AS2.View.Widgets

local libKeyBound		-- LibKeyBound-1.0 library
local libLoadAttempted = false

-- Attempt to load LibKeyBound, if not already loaded.
local function LoadLibKeyBound()
	if not libLoadAttempted then
		libLoadAttempted = true
		libKeyBound = LibStub("LibKeyBound-1.0", true)
		if not libKeyBound then
			LoadAddOn("LibKeyBound-1.0")
			libKeyBound = LibStub("LibKeyBound-1.0", true)
		end
	end
end

-- Returns the abbreviation for the given key.
local function GetShortName(key)
	if libKeyBound then
		return libKeyBound:ToShortKey(key)
	else
		-- Generally, LibKeyBound-1.0 provides our short key names.  Since it is an optional dependency,
		-- however, we need to be able to function without it.  This addon defines some of the simpler
		-- replacements.
		key = gsub(key, L["NUMPAD-S"], L["NUMPAD-T"])
		key = gsub(key, L["CTRL-S"], L["CTRL-T"])
		key = gsub(key, L["ALT-S"], L["ALT-T"])
		key = gsub(key, L["SHIFT-S"], L["SHIFT-T"])
		return key
	end
end

function ActionBarPreviewFrame:Create(name, parent)
	assert(name)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:Hide()					-- (by default, this frame is hidden)
	self:SetPoint("TOPLEFT")	-- (this frame should not be positioned manually)
	self:SetSize(1, 1)			-- (we have to have nonzero size, or our children won't be displayed)

	self.invalid = true
	self.buttons = { }
	-- (self.actionsTable = nil)
	-- (self.keybindingsTable = nil)
	-- (self.slotSelectorFn = nil)

	self:SetScript("OnShow", function(self)
		self:Validate()
	end)

	-- Create the fade in-out animation
	self.animGroup = self:CreateAnimationGroup(name .. "_Animation")
	self.animGroup:SetLooping("REPEAT")
	local anim1 = self.animGroup:CreateAnimation("Alpha")
	anim1:SetDuration(0.9)
	anim1:SetChange(-1)
	anim1:SetOrder(1)
	anim1:SetSmoothing("IN")
	local anim2 = self.animGroup:CreateAnimation("Alpha")
	anim2:SetDuration(0.9)
	anim2:SetChange(1)
	anim2:SetOrder(2)
	anim2:SetSmoothing("OUT")
	self.animGroup:Play()

	return self
end

-- Sets the action set, etc. that's displayed in this frame
function ActionBarPreviewFrame:DisplaySet(actionsTable, keybindingsTable, slotSelectorFn)
	if not actionsTable and not keybindingsTable then
		for _, button in pairs(self.buttons) do
			self:private_HideButton_Key(button)
			self:private_HideButton_Action(button)
			button.frame:Hide()
		end
		self.actionsTable = nil
		self.keybindingsTable = nil
		self.slotSelectorFn = nil
		self.animGroup:Pause()
	else
		self.actionsTable = actionsTable
		self.keybindingsTable = keybindingsTable
		self.slotSelectorFn = slotSelectorFn
		self:Refresh()
		self.animGroup:Play()
	end
end

-- Invalidates the state of the buttons, and schedules validation
function ActionBarPreviewFrame:Refresh()
	self.invalid = true
	AS2:Dispatch(self.Validate, self)
end

-- (helper function for Validate(); makes an action button display the given key)
function ActionBarPreviewFrame:Validate_ProcessActionButton(actionButton, key)
	local button = self:private_GetOrMakeButton(actionButton, self)
					
	if not button.keyText then
		-- Try to use LibKeyBound, but if it's not available, use a smaller font and word wrapping instead.
		LoadLibKeyBound()
		button.keyText = button.frame:CreateFontString()
		if libKeyBound then
			button.keyText:SetFontObject("GameFontGreenLarge")
			button.keyText:SetPoint("CENTER", actionButton)
		else
			button.keyText:SetFontObject("SystemFont_Tiny")
			button.keyText:SetPoint("BOTTOMRIGHT", actionButton)
			button.keyText:SetPoint("TOPLEFT", actionButton)
			button.keyText:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
			button.keyText:SetWordWrap(true)
		end
		button.keyText:SetShadowOffset(2, -2)
	end

	button.keyText:SetText(GetShortName(key))
	button.keyText:Show()
	button.frame:Show()
	self:private_PositionButton(button, actionButton)

	button.processedKey = true
end

-- Validates the state of the frame and its buttons
function ActionBarPreviewFrame:Validate()
	if self.invalid and self:IsVisible() then
		self.invalid = false

		-- Children should only be created while the parent's alpha is 1.0; they seem to inherit it somehow, which makes
		-- them fade back and forth to the parent's instantaneous alpha instead of 1.0.
		self:SetAlpha(1.0)

		-- Create / update buttons for each action button
		for actionButton, slot in AS2.actionButtonManager:ButtonActionPairs() do

			local button = self.buttons[actionButton]
			local action = self.actionsTable and self.actionsTable:GetValue(slot)
			local actionInSlot = AS2.activeGameModel:GetAction(slot)
			local isSelected = not self.slotSelectorFn or self.slotSelectorFn(slot)

			if action and isSelected and not Action:Equals(action, actionInSlot, true) then
				local button = self:private_GetOrMakeButton(actionButton, self)

				if not button.icon then
					button.icon = button.frame:CreateTexture()
					button.icon:SetPoint("BOTTOMRIGHT", actionButton)
					button.icon:SetPoint("TOPLEFT", actionButton)
				end

				if not button.highlight then
					button.highlight = button.frame:CreateTexture()
					button.highlight:SetTexture("Interface\\BUTTONS\\CheckButtonGlow")
					button.highlight:SetPoint("CENTER", button.icon)
				end
				
				button.highlight:SetSize(button.icon:GetWidth() * 2, button.icon:GetHeight() * 2)

				local icon = Action:GetIcon(action)
				if icon then
					button.icon:SetTexture(icon)
				else
					if action == Action.NIL then
						button.icon:SetTexture(0, 0, 0)			-- Black means the slot is empty
					else
						button.icon:SetTexture(0.15, 0, 0)		-- Deep red means the action can't be found
					end
				end

				button.icon:Show()
				button.highlight:Show()
				button.frame:Show()
				self:private_PositionButton(button, actionButton)

				button.processed = true
			end
		end

		-- Now go through keybindings
		if self.keybindingsTable then
			for key, command in self.keybindingsTable:Pairs() do
				local slot = Utilities:QuickParseSlotFromCommand(command)
				local currentSlot = Utilities:QuickParseSlotFromCommand(AS2.activeGameModel:GetKeybinding(key))
				local isSelected = not self.slotSelectorFn or self.slotSelectorFn(slot)

				if slot and slot ~= currentSlot and isSelected then
					-- Get a button specific to the command, if possible.
					local actionButton = Utilities:QuickParseButtonFromCommand(command)

					-- Display only on the specific button if there is one, or any action button matching the slot otherwise.
					if actionButton then
						self:Validate_ProcessActionButton(actionButton, key)
					else
						for _, actionButton in AS2.actionButtonManager:IndexButtonPairs(slot) do
							self:Validate_ProcessActionButton(actionButton, key)
						end
					end
				end
			end
		end
	
		-- Hide any icons that weren't updated (maybe they weren't selected, or maybe the action button doesn't exist anymore)
		for _, button in pairs(self.buttons) do
			-- No keys were set
			if not button.processedKey then
				self:private_HideButton_Key(button)
			end
			button.processedKey = nil

			-- No actions were set
			if not button.processed then
				self:private_HideButton_Action(button)
			end
			button.processed = nil
		end
	end
end

function ActionBarPreviewFrame:private_GetOrMakeButton(actionButton, parent)
	assert(actionButton and parent)
	local button = self.buttons[actionButton]
	if not button then
		button = { }
		button.frame = CreateFrame("Frame", "AS2Preview_" .. tostring(actionButton:GetName()), parent)
		button.frame:SetPoint("TOPLEFT", actionButton)
		button.frame:SetPoint("BOTTOMRIGHT", actionButton)
		AS2.actionButtonManager:SetFrameForButton(actionButton, "PreviewButton", button.frame)
		self.buttons[actionButton] = button
	end
	return button
end

function ActionBarPreviewFrame:private_PositionButton(button, actionButton)
	-- Position the button above the action button, but below the include slot button
	Widgets:PositionAboveFrame(button.frame, actionButton)
	local includeSlotButton = AS2.actionButtonManager:GetFrameForButton(actionButton, "IncludeSlotButton")
	if includeSlotButton then Widgets:PositionAboveFrame(includeSlotButton, button.frame) end
end

function ActionBarPreviewFrame:private_HideButton_Key(button)
	if button then
		if button.keyText then button.keyText:Hide() end
	end
end

function ActionBarPreviewFrame:private_HideButton_Action(button)
	if button then
		if button.icon then button.icon:SetTexture(nil); button.icon:Hide() end
		if button.highlight then button.highlight:Hide() end
	end
end
