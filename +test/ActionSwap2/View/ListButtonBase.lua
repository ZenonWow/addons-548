--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local ListButtonBase = AS2.View.ListButtonBase

local STRIPE_COLOR = { r = 0.9, g = 0.9, b = 1 }	-- As defined in PaperDollFrame.lua

function ListButtonBase:Create(name, parent)
	assert(parent)
	self = self:MixInto(CreateFrame("Button", name, parent))
	
	-- (Note: This button template is based largely off of PaperDollFrame.xml:GearSetButtonTemplate)

	self:SetSize(AS2.LIST_ITEM_WIDTH, AS2.LIST_ITEM_HEIGHT)

	self.highlightBar = self:CreateTexture(nil, "OVERLAY", nil, -1)
	self.highlightBar:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar-Blue")
	self.highlightBar:SetAlpha(0.4)
	self.highlightBar:SetBlendMode("ADD")
	self.highlightBar:SetTexCoord(0.2, 0.8, 0, 1)
	self.highlightBar:SetAllPoints(self)
	self.highlightBar:Hide()

	self.selectedBar = self:CreateTexture(nil, "OVERLAY")
	self.selectedBar:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
	self.selectedBar:SetAlpha(0.4)
	self.selectedBar:SetBlendMode("ADD")
	self.selectedBar:SetTexCoord(0.2, 0.8, 0, 1)
	self.selectedBar:SetAllPoints(self)
	self.selectedBar:Hide()

	-- (tex coords and size come from CharacterFrame.xml:Char-Stat-Top)
	self.bgTop = self:CreateTexture(nil, "BACKGROUND")
	self.bgTop:SetTexture("Interface\\CharacterFrame\\Char-Paperdoll-Parts")
	self.bgTop:SetTexCoord(0.00390625, 0.66406250, 0.50781250, 0.57812500)
	self.bgTop:SetSize(169, 9)	-- (original size in equip. manager is 169,9)

	-- (tex coords and size come from CharacterFrame.xml:Char-Stat-Bottom)
	self.bgBottom = self:CreateTexture(nil, "BACKGROUND")
	self.bgBottom:SetTexture("Interface\\CharacterFrame\\Char-Paperdoll-Parts")
	self.bgBottom:SetTexCoord(0.00390625, 0.66406250, 0.00781250, 0.36718750)
	self.bgBottom:SetSize(169, 46)	-- (original size in equip. manager is 169,46)

	-- (tex coords and size come from PaperDollFrame.xml:Char-Stat-Middle)
	self.bgMiddle = self:CreateTexture(nil, "BACKGROUND")
	self.bgMiddle:SetTexture("Interface\\CharacterFrame\\Char-Stat-Middle", true)
	self.bgMiddle:SetTexCoord(0.00390625, 0.66406250, 0.0, 1.0)
	self.bgMiddle:SetWidth(169)

	-- (tex color comes from PaperDollFrame.xml)
	self.bgStripe = self:CreateTexture(nil, "ARTWORK")
	self.bgStripe:SetTexture(STRIPE_COLOR.r, STRIPE_COLOR.g, STRIPE_COLOR.b)
	self.bgStripe:SetAlpha(0.1)		-- (from PaperDollFrame.lua)
	self.bgStripe:SetAllPoints()

	return self
end

-- Shows / hides elements based on the button's position in the list.
function ListButtonBase:UpdateDisplayForPosition(index, count, isSelected)
	assert(count)	-- (index can be nil, but count cannot)
	if not index or index < 1 or index > count then
		self:Hide()
	else
		-- Place the background texture.
		if index == 1 then
			self.bgTop:Show()
			self.bgTop:SetPoint("TOPLEFT", 0, 1)									-- (0,1 according to PaperDollFrame.xml:$parentBgTop)
			self.bgMiddle:SetPoint("TOPLEFT", self.bgTop, "BOTTOMLEFT", 1, 0)		-- (1,0 according to PaperDollFrame.xml:$parentBgMiddle)
		else
			self.bgTop:Hide()
			self.bgMiddle:SetPoint("TOPLEFT", self, "TOPLEFT", 1, 0)
		end

		if index == count then
			self.bgBottom:Show()
			self.bgBottom:SetPoint("BOTTOMLEFT", 0, -4)								-- (0,-4 according to PaperDollFrame.xml:$parentBgBottom)
			self.bgMiddle:SetPoint("BOTTOMLEFT", self.bgBottom, "TOPLEFT", 1, 0)	-- (1,0 according to PaperDollFrame.xml:$parentBgMiddle)
		else
			self.bgBottom:Hide()
			self.bgMiddle:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 0)
		end

		-- Show the stripe if the index is even.
		if index % 2 == 0 then
			self.bgStripe:Show()
		else
			self.bgStripe:Hide()
		end

		-- Show the selection bar if isSelected is set.
		if isSelected then
			self.selectedBar:Show()
		else
			self.selectedBar:Hide()
		end

		self:Show()
	end
end
