--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- TutorialFrame - a single tutorial frame that is shared among all frames.

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local L = LibStub("AceLocale-3.0"):GetLocale("ActionSwap2", true)
local TutorialFrame = AS2.View.TutorialFrame
local ListView = AS2.View.ListView
local Widgets = AS2.View.Widgets

local TOP_HEIGHT = 80
local MIDDLE_HEIGHT = 10
local BOTTOM_HEIGHT = 30
local WIDTH = 364
	
function TutorialFrame:Create(name, parent)
	assert(name and parent)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self:SetToplevel(true)
	self:SetMovable(true)
	self:SetClampedToScreen(true)
	self:RegisterForDrag("LeftButton")	-- (needed for moveable)
	self:EnableMouse(true)				-- (needed for moveable)
	self:Hide()

	local contentInsets = { left = 33, top = 75, right = 20, bottom = 35 }

	-- All texture coordinates and sizes are derived from TutorialFrame.xml / lua.
	self.bgTex = self:CreateTexture(nil, "BACKGROUND")
	self.bgTex:SetTexture(0, 0, 0, 1)

	self.topTex = self:CreateTexture(nil, "BORDER")
	self.topTex:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
	self.topTex:SetTexCoord(0.0019531, 0.7109375, 0.0019531, 0.1562500)

	self.bottomTex = self:CreateTexture(nil, "BORDER")
	self.bottomTex:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
	self.bottomTex:SetTexCoord(0.0019531, 0.6953125, 0.1621094, 0.2187500)

	self.header = self:CreateFontString()
	self.header:SetFontObject("GameFontHighlight")
	self.header:SetTextColor(1.0, 0.82, 0)
	self.header:SetText(L["Tutorial"])

	self.closeButton = CreateFrame("Button", name .. "_CloseButton", self, "UIPanelCloseButton")

	self.closeButton2 = CreateFrame("Button", name .. "_CloseButton2", self, "UIPanelButtonTemplate")
	self.closeButton2:SetText(L["Close"])

	self.text = self:CreateFontString()
	self.text:SetFontObject("GameFontWhite")
	self.text:SetJustifyH("LEFT")

	self.title = self:CreateFontString()
	self.title:SetFontObject("GameFontWhite")

	self.arrowTex = self:CreateTexture()
	self.arrowTex:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
	self.arrowTex:SetSize(89 / 2, 68 / 2)

	self.prevButton = CreateFrame("Button", name .. "_PrevButton", self)
	self.prevButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	self.prevButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	self.prevButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
	self.prevButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	self.prevButton:SetSize(26, 26)
	self.prevButton:SetPoint("BOTTOMLEFT", 30, 3)

	self.nextButton = CreateFrame("Button", name .. "_NextButton", self)
	self.nextButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
	self.nextButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
	self.nextButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
	self.nextButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	self.nextButton:SetSize(26, 26)
	self.nextButton:SetPoint("BOTTOMRIGHT", -132, 3)

	self.skipButton = CreateFrame("Button", name .. "_SkipButton", self, "UIPanelButtonTemplate")
	self.skipButton:SetPoint("TOPLEFT", self.prevButton, "TOPRIGHT", 20, -2)
	self.skipButton:SetPoint("BOTTOMRIGHT", self.nextButton, "BOTTOMLEFT", -20, 3)
	self.skipButton:SetNormalFontObject("GameFontHighlightSmall")
	self.skipButton:SetHighlightFontObject("GameFontHighlightSmall")
	self.skipButton:SetText("Skip this step")

	-- Create the arrow animation
	local animGroup = self.arrowTex:CreateAnimationGroup(nil)
	self.arrowTex:Hide()
	animGroup:SetLooping("BOUNCE")
	self.anim1 = animGroup:CreateAnimation("Translation")
	self.anim1:SetDuration(0.4)
	self.anim1:SetOrder(1)
	self.anim1:SetSmoothing("IN_OUT")
	animGroup:Play()

	self.leftTex = { }
	self.rightTex = { }

	-- Lay out the frame.
	self.bgTex:SetPoint("TOPLEFT", 13, -35)
	self.bgTex:SetPoint("BOTTOMRIGHT", -3, 5)
	self.topTex:SetPoint("TOPLEFT")
	self.topTex:SetSize(364, TOP_HEIGHT)
	self.bottomTex:SetHeight(30)
	self.header:SetPoint("TOP", 15, -17)
	self.closeButton:SetPoint("TOPRIGHT", 4, -8)
	self.closeButton2:SetPoint("BOTTOMRIGHT", -7, 7)
	self.closeButton2:SetSize(108, 22)
	self.text:SetPoint("TOPLEFT", self, "TOPLEFT", contentInsets.left, -contentInsets.top)
	self.text:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -contentInsets.right, contentInsets.bottom)
	self.title:SetPoint("BOTTOM", self.text, "TOP", 0, 10)

	self:SetScript("OnDragStart", function(self, button)
		self:StartMoving()
	end)
	
	self:SetScript("OnDragStop", function(self, button)
		self:StopMovingOrSizing()
	end)
	
	return self
end

function TutorialFrame:SetTileHeight(tileHeight)
	for i = 1, tileHeight do
		if not self.leftTex[i] then
			self.leftTex[i] = self:CreateTexture(nil, "BORDER")
			self.leftTex[i]:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
			self.leftTex[i]:SetTexCoord(0.3066406, 0.3261719, 0.656250025, 0.675781275)
			self.leftTex[i]:SetSize(11, MIDDLE_HEIGHT)
			if i == 1 then
				self.leftTex[i]:SetPoint("TOPLEFT", self.topTex, "BOTTOMLEFT", 6, 0)
			else
				self.leftTex[i]:SetPoint("TOPLEFT", self.leftTex[i - 1], "BOTTOMLEFT")
			end
		else
			self.leftTex[i]:Show()
		end

		if not self.rightTex[i] then
			self.rightTex[i] = self:CreateTexture(nil, "BORDER")
			self.rightTex[i]:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
			self.rightTex[i]:SetTexCoord(0.3496094, 0.3613281, 0.656250025, 0.675781275)
			self.rightTex[i]:SetSize(7, MIDDLE_HEIGHT)
			if i == 1 then
				self.rightTex[i]:SetPoint("TOPRIGHT", self.topTex, "BOTTOMRIGHT", -1, 0)
			else
				self.rightTex[i]:SetPoint("TOPLEFT", self.rightTex[i - 1], "BOTTOMLEFT")
			end
		else
			self.rightTex[i]:Show()
		end
	end

	self.bottomTex:SetPoint("TOPLEFT", self.leftTex[tileHeight], "BOTTOMLEFT")
	self.bottomTex:SetPoint("TOPRIGHT", self.rightTex[tileHeight], "BOTTOMRIGHT")

	assert(#self.leftTex == #self.rightTex)
	for i = tileHeight + 1, #self.leftTex do
		self.leftTex[i]:Hide()
		self.rightTex[i]:Hide()
	end

	local height = TOP_HEIGHT + tileHeight * MIDDLE_HEIGHT + BOTTOM_HEIGHT
	self:SetSize(WIDTH, height)
end

function TutorialFrame:SetContent(title, text, closeText)
	self.title:SetText(title)
	self.text:SetText(text)
	self.closeButton2:SetText(closeText)
end

function TutorialFrame:SetArrowAnchor(isRight, anchor, point, offX, offY)
	if anchor then
		self.arrowTex:ClearAllPoints()
		local l, r, t, b = 0.3066406, 0.4785156, 0.2246094, 0.3554688
		if isRight then
			self.arrowTex:SetTexCoord(l, t, l, b, r, t, r, b)	-- Not flipped
			self.arrowTex:SetPoint("RIGHT", anchor or "LEFT", point, offX, offY)
			self.anim1:SetOffset(-10, 0)
		else
			self.arrowTex:SetTexCoord(r, t, r, b, l, t, l, b)	-- Flipped
			self.arrowTex:SetPoint("LEFT", anchor or "RIGHT", point, offX, offY)
			self.anim1:SetOffset(10, 0)
		end
		self.arrowTex:Show()
	else
		self.arrowTex:Hide()
	end
end
