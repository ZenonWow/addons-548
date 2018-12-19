--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local SecondaryFrame = AS2.View.SecondaryFrame
local Widgets = AS2.View.Widgets

function SecondaryFrame:Create(name, parent)
	assert(parent)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:Hide()		-- (by default, all secondary frames are hidden)
	self:SetPoint("TOPLEFT", parent, "TOPRIGHT", -9, -10)
	self:SetPoint("BOTTOM", 0, 10)
	self:SetWidth(AS2.LIST_ITEM_WIDTH + 64)

	Widgets:MakeTooltipFrame(self)

	return self
end

-- Places this frame (and the backup frame) below the given one
function SecondaryFrame:PositionBelow(frame)
	Widgets:PositionBelowFrame(self, frame)
	if AS2.backupFrame then AS2.backupFrame:PositionBelow(self) end
end
