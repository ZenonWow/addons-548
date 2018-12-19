--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- IncludeButtonButton - this overlay button is placed on each action button to include / exclude it from
-- a button set.  (the reason we can't use a regular CheckButton is that it won't allow tooltips while
-- in a disabled state)

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local IncludeButtonButton = AS2.View.IncludeButtonButton

function IncludeButtonButton:Create(name, parent)
	assert(parent)
	self = self:MixInto(CreateFrame("Button", name, parent))

	-- (The white background texture is conditionally displayed based on the mouse enable state of the button)
	self.backgroundTexture = self:CreateTexture(nil, "BACKGROUND")
	self.backgroundTexture:SetTexture(1, 1, 1, 0.5)
	self.backgroundTexture:SetPoint("TOPLEFT", 1, -1)
	self.backgroundTexture:SetPoint("BOTTOMRIGHT", -1, 1)

	-- (The checked texture is a cross-out)
	self.checkedTexture = self:CreateTexture(nil, "ARTWORK")
	self.checkedTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")
	self.checkedTexture:SetAllPoints()
	self.checkedTexture:Hide()

	self.disabledCheckedTexture = self:CreateTexture(nil, "ARTWORK")
	self.disabledCheckedTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")
	self.disabledCheckedTexture:SetAllPoints()
	if not self.disabledCheckedTexture:SetDesaturated(true) then
		self.disabledCheckedTexture:SetVertexColor(0.5, 0.5, 0.5)
	end
	self.disabledCheckedTexture:Hide()

	-- (The pushed texture is a highlight)
	self.pushedTexture = self:CreateTexture(nil, "OVERLAY")
	self.pushedTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-ItemButton-Highlight")
	self.pushedTexture:SetTexCoord(0, 0.75, 0, 0.75)
	self.pushedTexture:SetAllPoints()
	self.pushedTexture:Hide()

	self:SetScript("OnClick", self.OnClick)
	self:SetScript("OnMouseDown", self.OnMouseDown)
	self:SetScript("OnMouseUp", self.OnMouseUp)

	self.invalidVisual = false
	self.isChecked = false
	self.isEnabled = true
	self.isPushed = false

	AS2:RegisterMessage(self, "StateChanged")

	return self
end

-- Updates the visual state of the button.
function IncludeButtonButton:UpdateVisualState()
	if self.invalidVisual then
		self.invalidVisual = false
		if self.isChecked then
			if self.isEnabled then
				self.checkedTexture:Show()
				self.disabledCheckedTexture:Hide()
			else
				self.checkedTexture:Hide()
				self.disabledCheckedTexture:Show()
			end
		else
			self.checkedTexture:Hide()
			self.disabledCheckedTexture:Hide()
		end
	end
end

-- Sets the state of the button.  Unlike a regular check button though, mouse input will still be received in
-- a disabled state, allowing for tooltips, etc.
function IncludeButtonButton:SetCustomButtonState(checked, enabled)
	if self.isChecked ~= checked then
		self.isChecked = checked
		self.invalidVisual = true
	end
	if self.isEnabled ~= enabled then
		self.isEnabled = enabled
		self.invalidVisual = true
	end
	self:UpdateVisualState()
end

-- Returns the custom button state as (checked, enabled)
function IncludeButtonButton:GetCustomButtonState()
	return self.isChecked, self.isEnabled
end

-- Called when the user clicks the button.
function IncludeButtonButton:OnClick(_, _)
	if self.isEnabled then
		self.isChecked = not self.isChecked
		self.invalidVisual = true
		self:UpdateVisualState()
		AS2:SendMessage(self, "StateChanged", self, self.isChecked)
	end
end

-- Called when the user presses the mouse on the button - displays the pushed texture.
function IncludeButtonButton:OnMouseDown(mouseButton, _)
	if mouseButton == "LeftButton" then
		if not self.isPushed and self.isEnabled then
			self.isPushed = true
			self.pushedTexture:Show()
		end
	end
end

-- Called when the user releases the mouse after pressing it on the button - hides the pushed texture.
function IncludeButtonButton:OnMouseUp(mouseButton, _)
	if mouseButton == "LeftButton" then
		if self.isPushed then
			self.isPushed = false
			self.pushedTexture:Hide()
		end
	end
end
