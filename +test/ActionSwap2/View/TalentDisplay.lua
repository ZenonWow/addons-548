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
local TalentDisplay = AS2.View.TalentDisplay
local Widgets = AS2.View.Widgets

-- Size of the talent frame in the Blizzard UI
--  (PlayerTalentFrame is 646, 468)
--  (PlayerTalentFrameInset is anchored to TOPLEFT, 4, -60, and BOTTOMRIGHT, -6, 26)
--  (Thus, PlayerTalentFrameTalents is 579, 382)
local TALENT_FRAME_WIDTH = 636
local TALENT_FRAME_HEIGHT = 382
local TALENT_FRAME_ROW_WIDTH = 627	-- (= 3 * 190 + 57 (for level info))

local TALENT_BUTTON_WIDTH = 190		-- Original width of PlayerTalentButtonTemplate
local TALENT_BUTTON_HEIGHT = 50		-- Original height of PlayerTalentButtonTemplate

-- These positions are derived from Blizzard_TalentUI.xml
local TEX_COORDS = {
	-- Golden border
	TopLeftBorder = { 0.00390625, 0.25390625, 0.70117188, 0.80859375 },		-- (from $parentTLCorner of PlayerTalentFrameTalents)
	TopRightBorder = { 0.00390625, 0.25390625, 0.58984375, 0.69726563 },	-- (from $parentTRCorner of ...)
	BottomLeftBorder = { 0.27734375, 0.52734375, 0.47656250, 0.58398438 },	-- (from $parentBLCorner of ...)
	BottomRightBorder = { 0.53515625, 0.78515625, 0.47656250, 0.58398438 }, -- (from $parentBRCorner of ...)
	TopBorder = { 0.00000000, 1.00000000, 0.05468750, 0.14062500 },
	BottomBorder = { 0.00000000, 1.00000000, 0.00781250, 0.03906250 },
	-- Frame background
	Background = { 0.00390625, 0.82421875, 0.18554688, 0.58984375 },		-- (from $parentBg of PlayerTalentFrameTalents)
	-- Row background
	RowBackground = { 0.00000000, 1.00000000, 0.15625000, 0.53906250 },		-- (from $parentBg of PlayerTalentRowTemplate)
	-- Column separators
	LeftCap = { 0.140625, 0.26953125, 0.47656250, 0.58593750 },				-- (from $parentLeftCap)
	RightCap = { 0.00390625, 0.140625, 0.47656250, 0.58593750 },			-- (from $parentRightCap)
	Separator = { 0.00390625, 0.26953125, 0.47656250, 0.58593750 },			-- (from $parentSeparator1)
	-- Column highlights
	KnownOverlay = { 0.00390625, 0.74609375, 0.37304688, 0.47265625 },		-- (from $parentSelection / knownSelection)
}

function TalentDisplay:Create(name, parent, borderless)
	assert(parent)
	self = self:MixInto(CreateFrame("Frame", name, parent))
	self.borderless = borderless
	self.preferredWidth = TALENT_FRAME_WIDTH - (borderless and 57 or 0)
	self.preferredHeight = TALENT_FRAME_HEIGHT
	self.preferredRowWidth = TALENT_FRAME_ROW_WIDTH - (borderless and 57 or 0)

	-- Load the talent UI now (if not already) - we need to reference several items from it.
	AS2:LoadTalentUI()

	-- Texture coords are derived from Blizzard_TalentUI.xml
	self.background = self:CreateTexture()
	self.background:SetDrawLayer("ARTWORK", 0)
	self.background:SetTexture("Interface\\Common\\bluemenu-main")
	self.background:SetTexCoord(unpack(TEX_COORDS["Background"]))
	self.background:SetAllPoints()

	self.borderTL = self:CreateTexture()
	self.borderTL:SetDrawLayer("ARTWORK", 1)
	self.borderTL:SetTexture("Interface\\TalentFrame\\talent-main")
	self.borderTL:SetTexCoord(unpack(TEX_COORDS["TopLeftBorder"]))

	self.borderTR = self:CreateTexture()
	self.borderTR:SetDrawLayer("ARTWORK", 1)
	self.borderTR:SetTexture("Interface\\TalentFrame\\talent-main")
	self.borderTR:SetTexCoord(unpack(TEX_COORDS["TopRightBorder"]))

	self.borderBL = self:CreateTexture()
	self.borderBL:SetDrawLayer("ARTWORK", 1)
	self.borderBL:SetTexture("Interface\\TalentFrame\\talent-main")
	self.borderBL:SetTexCoord(unpack(TEX_COORDS["BottomLeftBorder"]))

	self.borderBR = self:CreateTexture()
	self.borderBR:SetDrawLayer("ARTWORK", 1)
	self.borderBR:SetTexture("Interface\\TalentFrame\\talent-main")
	self.borderBR:SetTexCoord(unpack(TEX_COORDS["BottomRightBorder"]))

	self.borderTop = self:CreateTexture()
	self.borderTop:SetDrawLayer("ARTWORK", 1)
	self.borderTop:SetTexture("Interface\\TalentFrame\\talent-horiz", true)	-- (second secret parameter to actually enable tiling?)
	self.borderTop:SetTexCoord(unpack(TEX_COORDS["TopBorder"]))
	self.borderTop:SetHorizTile(true)

	self.borderBottom = self:CreateTexture()
	self.borderBottom:SetDrawLayer("ARTWORK", 1)
	self.borderBottom:SetTexture("Interface\\TalentFrame\\talent-horiz", true)
	self.borderBottom:SetTexCoord(unpack(TEX_COORDS["BottomBorder"]))
	self.borderBottom:SetHorizTile(true)

	self.rows = { }
	for i = 1, AS2.NUM_TALENT_SLOTS do
		self.rows[i] = { }
		self.rows[i].bg = self:CreateTexture()
		self.rows[i].bg:SetDrawLayer("ARTWORK", 1)
		self.rows[i].bg:SetTexture("Interface\\TalentFrame\\talent-horiz")
		self.rows[i].bg:SetTexCoord(unpack(TEX_COORDS["RowBackground"]))
		self.rows[i].bgLeftCap = self:CreateTexture()
		self.rows[i].bgLeftCap:SetDrawLayer("ARTWORK", 2)
		self.rows[i].bgLeftCap:SetTexture("Interface\\TalentFrame\\talent-main")
		self.rows[i].bgLeftCap:SetTexCoord(unpack(TEX_COORDS["LeftCap"]))
		self.rows[i].bgSeparator1 = self:CreateTexture()
		self.rows[i].bgSeparator1:SetDrawLayer("ARTWORK", 2)
		self.rows[i].bgSeparator1:SetTexture("Interface\\TalentFrame\\talent-main")
		self.rows[i].bgSeparator1:SetTexCoord(unpack(TEX_COORDS["Separator"]))
		self.rows[i].bgSeparator2 = self:CreateTexture()
		self.rows[i].bgSeparator2:SetDrawLayer("ARTWORK", 2)
		self.rows[i].bgSeparator2:SetTexture("Interface\\TalentFrame\\talent-main")
		self.rows[i].bgSeparator2:SetTexCoord(unpack(TEX_COORDS["Separator"]))
		self.rows[i].bgSeparator3 = self:CreateTexture()
		self.rows[i].bgSeparator3:SetDrawLayer("ARTWORK", 2)
		self.rows[i].bgSeparator3:SetTexture("Interface\\TalentFrame\\talent-main")
		self.rows[i].bgSeparator3:SetTexCoord(unpack(TEX_COORDS["Separator"]))
		self.rows[i].bgRightCap = self:CreateTexture()
		self.rows[i].bgRightCap:SetDrawLayer("ARTWORK", 2)
		self.rows[i].bgRightCap:SetTexture("Interface\\TalentFrame\\talent-main")
		self.rows[i].bgRightCap:SetTexCoord(unpack(TEX_COORDS["RightCap"]))
		self.rows[i].check = self:CreateTexture()
		self.rows[i].check:SetDrawLayer("ARTWORK", 3)
		self.rows[i].overlayButton = Widgets:CreateTalentOverlayButton(name .. "_Overlay" .. i, self)
		
		self.rows[i].buttons = { }
		for j = 1, AS2.NUM_TALENTS_PER_SLOT do
			self.rows[i].buttons[j] = self:private_CreateButton(name .. "_Button_" .. tostring(i) .. "_" .. tostring(j), self)
		end
	end

	-- Lay out the window only when the size changed message is fired
	self:SetScript("OnSizeChanged", function(self, width, height)
		local xScale = width / self.preferredWidth
		local yScale = height / self.preferredHeight
		
		self.borderTL:SetSize(64.0 * xScale, 55.0 * yScale)
		self.borderTL:SetPoint("TOPLEFT", 3.0 * xScale, -2.0 * yScale)
		self.borderTR:SetSize(64.0 * xScale, 55.0 * yScale)
		self.borderTR:SetPoint("TOPRIGHT", -3.0 * xScale, -2.0 * yScale)
		self.borderBL:SetSize(64.0 * xScale, 55.0 * yScale)
		self.borderBL:SetPoint("BOTTOMLEFT", 3.0 * xScale, 2.0 * yScale)
		self.borderBR:SetSize(64.0 * xScale, 55.0 * yScale)
		self.borderBR:SetPoint("BOTTOMRIGHT", -3.0 * xScale, 2.0 * yScale)
		self.borderTop:SetSize(0, 11.0 * yScale)
		self.borderTop:SetPoint("TOPLEFT", self.borderTL, "TOPRIGHT")
		self.borderTop:SetPoint("TOPRIGHT", self.borderTR, "TOPLEFT")
		self.borderBottom:SetSize(0, 4.0 * yScale)
		self.borderBottom:SetPoint("BOTTOMLEFT", self.borderBL, "BOTTOMRIGHT")
		self.borderBottom:SetPoint("BOTTOMRIGHT", self.borderBR, "BOTTOMLEFT")

		for i = 1, AS2.NUM_TALENT_SLOTS do
			local leftBorder = self.borderless and 0 or 57
			self.rows[i].bg:SetSize(0, 49.0 * yScale)
			if i == 1 then
				self.rows[i].bg:SetPoint("TOPLEFT", 5.0 * xScale, -17.0 * yScale)
				self.rows[i].bg:SetPoint("TOPRIGHT", self, "TOPLEFT", (5.0 + self.preferredRowWidth) * xScale, -17.0 * yScale)
			else
				self.rows[i].bg:SetPoint("TOPLEFT", self.rows[i - 1].bg, "BOTTOMLEFT", 0, -11.0 * yScale)
				self.rows[i].bg:SetPoint("TOPRIGHT", self.rows[i - 1].bg, "BOTTOMRIGHT", 0, -11.0 * yScale)
			end
			self.rows[i].bgLeftCap:SetSize(34.0 * xScale, 56.0 * yScale)
			self.rows[i].bgRightCap:SetSize(34.0 * xScale, 56.0 * yScale)
			self.rows[i].bgSeparator1:SetSize(68.0 * xScale, 56.0 * yScale)
			self.rows[i].bgSeparator2:SetSize(68.0 * xScale, 56.0 * yScale)
			self.rows[i].bgSeparator3:SetSize(68.0 * xScale, 56.0 * yScale)
			self.rows[i].bgLeftCap:SetPoint("LEFT", self.rows[i].bg, "LEFT")
			self.rows[i].bgRightCap:SetPoint("RIGHT", self.rows[i].bg, "RIGHT")
			if not self.borderless then
				self.rows[i].bgSeparator1:SetPoint("CENTER", self.rows[i].bgLeftCap, "LEFT", 57.0 * xScale, 0)
				self.rows[i].bgSeparator2:SetPoint("CENTER", self.rows[i].bgSeparator1, "CENTER", 190.0 * xScale, 0)
			else
				self.rows[i].bgSeparator1:Hide()
				self.rows[i].bgSeparator2:SetPoint("CENTER", self.rows[i].bgLeftCap, "LEFT", 190.0 * xScale, 0)
			end
			self.rows[i].bgSeparator3:SetPoint("CENTER", self.rows[i].bgSeparator2, "CENTER", 190.0 * xScale, 0)
			self.rows[i].check:SetSize(56.0 * xScale, 56.0 * yScale)
			self.rows[i].check:SetPoint("CENTER", self.rows[i].bgLeftCap, "RIGHT", -5 * xScale, 0)
			
			for j = 1, AS2.NUM_TALENTS_PER_SLOT do
				-- Unfortunately, we have to compute secure button positions manually because you can't SetPoint() them to a texture
				local x = (5.0 + leftBorder + (j - 1) * 190.0) * xScale	-- (border: 5 + 57, width: 190, separation: 0, adjustment)
				local y = (-17.0 - 25.0 - (i - 1) * 60.0) * yScale		-- (border: 17, height: 50, separation: 10, adjustment)
				self.rows[i].buttons[j]:SetSize(TALENT_BUTTON_WIDTH * xScale, TALENT_BUTTON_HEIGHT * yScale)
				self.rows[i].buttons[j]:SetPoint("LEFT", self, "TOPLEFT", x, y)
			end
		end
	end)

	return self
end

function TalentDisplay:private_CreateButton(name, parent)
	local button = CreateFrame("Button", name, self, "SecureActionButtonTemplate")
	
	-- NOTE: The button currently doesn't do anything when pressed.  While it can
	-- be successfully mapped to the talent frame buttons, it doesn't work properly
	-- until the talent tab is actually opened (which currently can't be done without
	-- tainting it).  Thus, I'm leaving it as a secure button since it has special
	-- positioning requirements (i.e., you can't SetPoint it to a texture), but the
	-- button itself doesn't actually do anything.
	
	button.icon = button:CreateTexture()
	button.icon:SetDrawLayer("ARTWORK", 3)

	button.nameText = button:CreateFontString()
	button.nameText:SetFontObject("GameFontNormalSmall")
	button.nameText:SetTextColor(1.0, 1.0, 1.0, 1.0)

	button.knownOverlay = button:CreateTexture()
	button.knownOverlay:SetDrawLayer("ARTWORK", 4)
	button.knownOverlay:SetTexture("Interface\\TalentFrame\\talent-main")
	button.knownOverlay:SetTexCoord(unpack(TEX_COORDS["KnownOverlay"]))
	button.knownOverlay:SetBlendMode("ADD")

	button:SetScript("OnSizeChanged", function(self, width, height)
		local xScale = width / TALENT_BUTTON_WIDTH
		local yScale = height / TALENT_BUTTON_HEIGHT
		self.icon:SetSize(40.0 * xScale, 40.0 * yScale)
		self.icon:SetPoint("LEFT", 35.0 * xScale, 0)
		self.nameText:SetSize(90.0 * xScale, 35.0 * yScale)
		self.nameText:SetPoint("LEFT", self.icon, "RIGHT", 10.0 * xScale, 0)
		self.knownOverlay:SetSize(190.0 * xScale, 51.0 * yScale)
		self.knownOverlay:SetPoint("CENTER")
	end)
	return button
end

-- Changes the state of one of the talent rows.
function TalentDisplay:SetRowState(rowIndex, checked, arrowIndex)
	assert(rowIndex >= 1 and rowIndex <= AS2.NUM_TALENT_SLOTS)
	local row = self.rows[rowIndex]

	if checked == true then
		row.check:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-Ready")
	elseif checked == false then
		row.check:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	else
		row.check:SetTexture(nil)
	end

	-- Move the arrow
	if arrowIndex and arrowIndex >= 1 and arrowIndex <= AS2.NUM_TALENTS_PER_SLOT then
		row.overlayButton:SetAllPoints(row.buttons[arrowIndex])
		row.overlayButton:Show()
	else
		row.overlayButton:Hide()
	end
end

-- Changes the state of one of the talent buttons
function TalentDisplay:SetButtonState(row, column, talentName, talentIcon, learned, available, desired)
	local button = self.rows[row].buttons[column]
	button.nameText:SetText(tostring(talentName))
	button.icon:SetTexture(talentIcon)

	-- Put a gold border around it
	if learned then
		button.knownOverlay:Show()
		if desired then 
			button.knownOverlay:SetVertexColor(1, 1, 1)			-- Lit means learned and desired
		else
			button.knownOverlay:SetVertexColor(0.4, 0.4, 0.4)	-- Dim means learned but not desired
		end
	else
		if desired then
			button.knownOverlay:Show()
			button.knownOverlay:SetVertexColor(1, 0, 0)		-- Red means desired but not learned
		else
			button.knownOverlay:Hide()
		end
	end

	-- Gray it out if it's beyond current level
	if available then
		button.icon:SetDesaturated(false)
	else
		button.icon:SetDesaturated(true)
	end
end

-- Returns the aspect ratio of the actual talent pane
function TalentDisplay:GetPreferredAspectRatio()
	return self.preferredWidth / self.preferredHeight
end
