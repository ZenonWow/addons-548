--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local ActionButtonManager = AS2.Controller.ActionButtonManager

ActionButtonManager.buttonTable = { }	-- Mapping from button to a table of info, including action, x, y, etc.
ActionButtonManager.reverseTable = { }	-- Mapping from slot to button

function ActionButtonManager:Refresh()
	AS2:Debug(AS2.NOTE, "ActionButtonManager:Refresh()")

	-- Update existing buttons, removing those that that no longer qualify.
	for button, entry in pairs(self.buttonTable) do
		local oldAction = entry.action
		local newAction = self:private_TryGetAction(button)
		if newAction ~= oldAction then
			self:private_RemoveFromSlot(oldAction, button)
			if newAction then
				entry.action = newAction
				self:private_AddToSlot(newAction, button)
			else
				self.buttonTable[button] = nil
			end
		end
	end

	-- Search for any new action buttons 
	for k, v in pairs(_G) do
		if type(v) == "table" and not self.buttonTable[v] then
			local action = self:private_TryGetAction(v)
			if action then
				self.buttonTable[v] = {
					action = action,
					x = v:GetLeft(),
					y = v:GetBottom(),
					frames = { }
				}
				self:private_AddToSlot(action, v)
			end
		end
	end
end

-- Determines the action of the given button, if it qualifies to be an action button.
function ActionButtonManager:private_TryGetAction(v)
	-- See also: ActionButton_CalculateAction in ActionButton.lua - this demonstrates how the action is computed for buttons without an "action" attribute.
	if v and type(v) == "table" and
			type(v.GetAttribute) == "function" and	-- (Type check is required for TomTom compatibility; localization variables sometimes have an indexer that echoes string values; nil test is not enough)
			type(v.GetParent) == "function" and
			type(v.GetLeft) == "function" and
			type(v.GetBottom) == "function" and
			type(v.IsVisible) == "function" and
			type(v.GetName) == "function" then
	
		-- Process only secure action buttons
		if SecureButton_GetAttribute(v, "type") == "action" then
			local parent = v:GetParent()
			
			-- Ignore all "MultiCast" and "Extra" and "Vehicle" buttons.
			if v.isExtra or v.buttonType == "MULTICASTACTIONBUTTON" then return end

			-- Macaroon uses per-button visibility, so to provide support for empty slots, use its "stateshown" attribute
			-- to determine whether each button is currently in a state where it is displayed.
			local visibleOverride = SecureButton_GetAttribute(v, "stateshown")	-- false if hidden, true if shown
		
			-- Use the parent's visibility to determine whether to this action button should be used - we want
			-- empty slots to be included, yet the UI may have hidden them if the grid is off.
			if visibleOverride or ( visibleOverride == nil and ( (parent and parent:IsVisible()) or v:IsVisible() ) ) then
			
				local action = ActionButton_CalculateAction(v, "LeftButton")
				if type(action) == "number" and action >= 1 and action <= AS2.NUM_ACTION_SLOTS then
					return action
				end
				
			end
		end
	end
end

-- Adds the given button to the given slot in the reverse mapping.
function ActionButtonManager:private_AddToSlot(slot, button)
	local entry = self.reverseTable[slot]
	if not entry then entry = { }; self.reverseTable[slot] = entry end
	tinsert(entry, button)
end

-- Removes the given button from the given slot in the reverse mapping.
function ActionButtonManager:private_RemoveFromSlot(slot, button)
	local entry = self.reverseTable[slot]
	if entry then
		for i = #entry, 1, -1 do
			if entry[i] == button then
				tremove(entry, i)
			end
		end
	end
end

-- Returns an iterator over all button, action pairs.
function ActionButtonManager:ButtonActionPairs()
	local f, s, k = pairs(self.buttonTable)
	return function(s, k)
		local v1, v2 = f(s, k)
		return v1, v2 and v2.action
	end, s, k
end

function ActionButtonManager:IndexButtonPairs(slot)
	local v = self.reverseTable[slot]
	if v then
		return ipairs(v)
	else
		return ipairs({ })	-- (empty iterator)
	end
end

-- Associates the given frame with the given button
function ActionButtonManager:SetFrameForButton(actionButton, key, frame)
	local buttonInfo = self.buttonTable[actionButton]
	assert(buttonInfo)
	buttonInfo.frames[key] = frame
end

-- Returns the named frame associated with the given button
function ActionButtonManager:GetFrameForButton(actionButton, key)
	local buttonInfo = self.buttonTable[actionButton]
	if buttonInfo then
		return buttonInfo.frames[key]
	end
end
