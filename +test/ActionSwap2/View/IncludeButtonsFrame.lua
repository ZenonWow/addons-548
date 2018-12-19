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
local IncludeButtonButton = AS2.View.IncludeButtonButton
local IncludeButtonsFrame = AS2.View.IncludeButtonsFrame
local Widgets = AS2.View.Widgets

local BRING_TO_FRONT_INTERVAL = 1.0

function IncludeButtonsFrame:Create(name, parent)
	assert(name)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:Hide()					-- (by default, this frame is hidden)
	self:SetPoint("TOPLEFT")	-- (this frame should not be positioned manually)
	self:SetSize(1, 1)			-- (we have to have nonzero size, or our children won't be displayed)

	self.invalid = true
	self.editingEnabled = false
	self.buttons = { }

	self:SetScript("OnShow", function(self)
		self:Validate()

		-- Schedule a timer to bring the slots to the foreground every once in a while in case a toplevel
		-- parent frame alters the frame level of some action buttons.
		self.bringToFrontTimer = AS2:ScheduleRepeatingTimer(self.BringToFrontTimerElapsed, BRING_TO_FRONT_INTERVAL, self)
	end)

	self:SetScript("OnHide", function(self)
		-- Stop the bring-to-front timer when the frame is hidden
		if self.bringToFrontTimer then
			AS2:CancelTimer(self.bringToFrontTimer)
			self.bringToFrontTimer = nil
		end
	end)

	return self
end

-- Sets the delegate, which provides button state information
function IncludeButtonsFrame:SetDelegate(delegate)
	assert(self.delegate == nil)	-- (not designed for delegate switching)
	self.delegate = delegate
	self:Refresh()
end

-- Enables the editability of the buttons
-- (i.e., the white background is shown when they are editable)
function IncludeButtonsFrame:EnableEditing(enable)
	self.editingEnabled = enable
	self:Refresh()
end

-- Returns true if editing is enabled, false if not (mouse passes through)
function IncludeButtonsFrame:IsEditingEnabled()
	return self.editingEnabled
end

-- Invalidates the state of the buttons, and schedules validation
function IncludeButtonsFrame:Refresh()
	self.invalid = true
	AS2:Dispatch(self.Validate, self)
end

-- Validates the state of the frame and its buttons
function IncludeButtonsFrame:Validate()
	if self.invalid and self.delegate and self:IsVisible() then
		self.invalid = false

		-- Create / update buttons for each action button
		for actionButton, slot in AS2.actionButtonManager:ButtonActionPairs() do
			local button = self.buttons[actionButton]
			if not button then
				button = IncludeButtonButton:Create("AS2Include_" .. tostring(actionButton:GetName()), self)
				button.owner = self
				AS2.actionButtonManager:SetFrameForButton(actionButton, "IncludeSlot", button)
				self.buttons[actionButton] = button

				button:SetPoint("TOPLEFT", actionButton)
				button:SetPoint("BOTTOMRIGHT", actionButton)

				button:SetScript("OnEnter", self.Button_OnEnter)
				button:SetScript("OnLeave", self.Button_OnLeave)
				AS2:AddCallback(button, "StateChanged", self.Button_OnStateChanged, self)
			end
			button.action = slot
			if self.delegate then
				local isChecked, isEnabled = self.delegate:IncludeButtonsFrame_GetSlotState(slot)

				-- Button appearance should differ based on the enableEditing state.
				if self.editingEnabled then
					button:EnableMouse(true)
					button.backgroundTexture:Show()
				else
					button:EnableMouse(false)
					isEnabled = true	-- (when not editing, display red crosses instead of gray ones)
					button.backgroundTexture:Hide()
				end

				button:SetCustomButtonState(isChecked, isEnabled)
			end

			-- Do our best to ensure the button is above the action button
			Widgets:PositionAboveFrame(button, actionButton)

			button:Show()
			button.processed = true
		end
	
		-- Hide any extra buttons
		for _, button in pairs(self.buttons) do
			if not button.processed then
				button:Hide()
			end
			button.processed = nil
		end
	end
end

-- Called upon clicking one of the buttons.
function IncludeButtonsFrame:Button_OnStateChanged(button, checked)
	PlaySound("igMainMenuOptionCheckBoxOn")
	if button.owner.delegate then button.owner.delegate:IncludeButtonsFrame_OnButtonStateChanged(checked, button.action) end	-- (do NOT replace with slot; it can change w/ paging)
end

-- Called upon entering one of the buttons.
function IncludeButtonsFrame.Button_OnEnter(button, _)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	local checked, enabled = button:GetCustomButtonState()
	if enabled then
		if checked then
			GameTooltip:SetText(L["INCLUDE_SLOT"])
		else
			GameTooltip:SetText(L["EXCLUDE_SLOT"])
		end
	else
		GameTooltip:SetText(L["DISABLED_SLOT"])
	end
end

-- Called upon leaving one of the buttons.
function IncludeButtonsFrame.Button_OnLeave(button, _)
	GameTooltip:Hide()
end

function IncludeButtonsFrame:BringToFrontTimerElapsed()
	-- Bring all slot-include buttons in front of their corresponding action buttons.
	for actionButton, slot in AS2.actionButtonManager:ButtonActionPairs() do
		local button = self.buttons[actionButton]
		Widgets:PositionAboveFrame(button, actionButton)
	end
end
