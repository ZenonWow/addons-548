--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local Widgets = AS2.View.Widgets

-- Creates a CheckButton based on UIPanelButtonTemplate
function Widgets:CreateButton_BigToggleButtonTemplate(name, parent)
	local button = CreateFrame("CheckButton", name, parent)

	local normalTexture = button:CreateTexture()
	normalTexture:SetTexture("Interface\\Common\\bluemenu-main")
	normalTexture:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813)
	normalTexture:SetAllPoints()
	button:SetNormalTexture(normalTexture)
	
	local checkedTexture = button:CreateTexture()
	checkedTexture:SetTexture("Interface\\Common\\bluemenu-main")
	checkedTexture:SetTexCoord(0.00390625, 0.87890625, 850.0/1024, 930.0/1024)
	checkedTexture:SetAlpha(0.8)
	checkedTexture:SetAllPoints()
	checkedTexture:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 1, 1, 1, 1, 0)
	button:SetCheckedTexture(checkedTexture)

	local highlightTexture = button:CreateTexture()
	highlightTexture:SetTexture("Interface\\Common\\bluemenu-main")
	highlightTexture:SetTexCoord(0.00390625, 0.87890625, 0.75195313, 0.83007813)
	highlightTexture:SetAlpha(0.8)
	highlightTexture:SetAllPoints()
	button:SetHighlightTexture(highlightTexture, "ADD")

	button.text = button:CreateFontString(nil, "OVERLAY")
	button.text:SetFontObject("GameFontNormal")
	button.text:SetPoint("CENTER")
	button:SetScript("OnDisable", function(button) button.text:SetFontObject("GameFontDisable") end)
	button:SetScript("OnEnable", function(button) button.text:SetFontObject("GameFontNormal") end)

	return button
end

-- Sets the backdrop for the given frame to the "main frame" type, then returns the
-- standard content insets for that frame type.
function Widgets:MakeMainFrame(frame)
	local frameInsets = { left = 11, right = 11, top = 11, bottom = 10 }

	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 32,
		insets = frameInsets
	})
	
	return {
		left = frameInsets.left + 10,
		right = frameInsets.right + 10,
		top = frameInsets.top + 20,
		bottom = frameInsets.bottom + 10
	}
end

-- Sets the backdrop for the given frame to the "parchment frame" type, then returns the
-- standard content insets for that frame type.
function Widgets:MakeParchmentFrame(frame)
	local frameInsets = { left = 11, right = 11, top = 11, bottom = 10 }

	frame:SetBackdrop({
		bgFile = "Interface\\HELPFRAME\\Tileable-Parchment",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		edgeSize = 32,
		insets = frameInsets
	})
	
	return {
		left = frameInsets.left + 10,
		right = frameInsets.right + 10,
		top = frameInsets.top + 20,
		bottom = frameInsets.bottom + 10
	}
end

-- Sets the backdrop for the given frame to the "tooltip frame" type, then returns the
-- standard content insets for that frame type.
function Widgets:MakeTooltipFrame(frame, isLight)
	local frameInsets = { left = 4, right = 4, top = 4, bottom = 4 }

	frame:SetBackdrop({
		bgFile = isLight and "Interface\\DialogFrame\\UI-DialogBox-Background" or "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = frameInsets
	})
	
	return {
		left = frameInsets.left + 10,
		right = frameInsets.right + 10,
		top = frameInsets.top + 10,
		bottom = frameInsets.bottom + 10
	}
end

-- Helper method to create one of the several small buttons that line the bottom of a list item.
-- (layout and scripts come from PaperDollFrame.xml:$parentDeleteButton)
function Widgets:CreateSmallIconButton(tooltip, parent, icon, updateMouseStateFn)
	local button = CreateFrame("Button", nil, parent)
	button.texture = button:CreateTexture()
	button.texture:SetTexture(icon)
	button.texture:SetAlpha(0.5)
	button.texture:SetAllPoints()
	button:SetScript("OnEnter", function(button, _)
		button.texture:SetAlpha(1.0)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
		GameTooltip:SetText(tooltip)
		updateMouseStateFn(button.owner)
	end)
	button:SetScript("OnLeave", function(button, _)
		button.texture:SetAlpha(0.5)
		GameTooltip:Hide()
		updateMouseStateFn(button.owner)
	end)
	button:SetScript("OnMouseDown", function(button, _)
		button.texture:SetPoint("TOPLEFT", 1, -1)
	end)
	button:SetScript("OnMouseUp", function(button, _)
		button.texture:SetPoint("TOPLEFT")
	end)

	return button
end

-- Ensures a frame is above the given frame level.
function Widgets:PositionAboveFrameLevel(frame, frameLevel)
	local attempts = 0
	while frame:GetFrameLevel() <= frameLevel and attempts < 25 do
		frame:SetFrameLevel(frameLevel + 1)
		attempts = attempts + 1
	end
	if attempts == 25 then
		AS2:Debug(AS2.WARNING, "WARNING: Failed to position above frame level", frameLevel)
	end
end

-- Ensures a frame is above the given frame. (also, places it in the same strata)
function Widgets:PositionAboveFrame(frame, frame2)
	if frame:GetFrameStrata() ~= frame2:GetFrameStrata() then frame:SetFrameStrata(frame2:GetFrameStrata()) end

	local attempts = 0
	while frame:GetFrameLevel() <= frame2:GetFrameLevel() and attempts < 25 do
		frame:SetFrameLevel(frame2:GetFrameLevel() + 1)
		attempts = attempts + 1
	end
	if attempts == 25 then
		AS2:Debug(AS2.WARNING, "WARNING: Failed to position above other frame", frameLevel)
	end
end

-- Ensures a frame is below the given frame. (also, places it in the same strata)
function Widgets:PositionBelowFrame(frame, frame2)
	if frame:GetFrameStrata() ~= frame2:GetFrameStrata() then frame:SetFrameStrata(frame2:GetFrameStrata()) end

	local attempts = 0
	while frame:GetFrameLevel() >= frame2:GetFrameLevel() and attempts < 25 do
		frame:SetFrameLevel(frame2:GetFrameLevel() - 1)
		attempts = attempts + 1
	end
	if attempts == 25 then
		AS2:Debug(AS2.WARNING, "WARNING: Failed to position above other frame", frameLevel)
	end
end

-- Creates a glyph overlay button
function Widgets:CreateGlyphOverlayButton(name, parent)
	assert(name and parent)
	local button = CreateFrame("Button", name, parent)
	button.texture = button:CreateTexture()
	button.texture:SetDrawLayer("OVERLAY", 0)
	button.texture:SetAllPoints()
	button:SetNormalTexture(button.texture)
	button.highlight = button:CreateTexture()
	button.highlight:SetDrawLayer("OVERLAY", 1)
	button.highlight:SetTexture("Interface\\BUTTONS\\CheckButtonGlow")
	button.highlight:SetPoint("CENTER")
	button.arrow = button:CreateTexture()
	button.arrow:SetDrawLayer("OVERLAY", 2)
	button.arrow:SetTexture("Interface\\MINIMAP\\MiniMap-QuestArrow")
	button.arrow:SetRotation(PI * 3 / 4)

	-- Create the arrow animation
	local animGroup = button.arrow:CreateAnimationGroup(nil)
	animGroup:SetLooping("BOUNCE")
	local anim1 = animGroup:CreateAnimation("Translation")
	anim1:SetDuration(0.4)
	anim1:SetOffset(-5, -5)
	anim1:SetOrder(1)
	anim1:SetSmoothing("IN_OUT")
	animGroup:Play()

	-- Create the highlight animation
	local animGroup2 = button.highlight:CreateAnimationGroup(nil)
	animGroup2:SetLooping("BOUNCE")
	local anim2 = animGroup2:CreateAnimation("Alpha")
	anim2:SetDuration(2.0)
	anim2:SetChange(-0.4)
	anim2:SetOrder(1)
	anim2:SetSmoothing("IN_OUT")
	animGroup2:Play()

	button:SetScript("OnSizeChanged", function(self, width, height)
		local xScale = width / 36
		local yScale = height / 36
		button:SetSize(36 * xScale, 36 * yScale)
		button.highlight:SetSize(36 * 2 * xScale, 36 * 2 * yScale)
		button.arrow:SetSize(48 * xScale, 48 * yScale)
		button.arrow:SetPoint("CENTER", -20 * xScale, -20 * yScale)
		anim1:SetOffset(-5 * xScale, -5 * yScale)
	end)

	button:SetScript("OnEnter", function(button, _)
		if button.tooltip then
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
			GameTooltip:SetText(button.tooltip)
		end
	end)
	button:SetScript("OnLeave", function(button, _)
		GameTooltip:Hide()
	end)

	return button
end

-- Creates a talent overlay button
function Widgets:CreateTalentOverlayButton(name, parent)
	assert(name and parent)
	local REAL_BUTTON_WIDTH = 190	-- (default width of each talent frame button)
	local button = CreateFrame("Frame", name, parent)	-- (the button is really just a frame so that it doesn't intercept mouse events)
	button.highlight = button:CreateTexture()
	button.highlight:SetDrawLayer("OVERLAY", 1)
	button.highlight:SetTexture("Interface\\BUTTONS\\CheckButtonGlow")
	button.highlight:SetPoint("CENTER")
	button.arrow = button:CreateTexture()
	button.arrow:SetDrawLayer("OVERLAY", 2)
	button.arrow:SetTexture("Interface\\MINIMAP\\MiniMap-QuestArrow")
	button.arrow:SetRotation(-PI * 1 / 2)

	-- Create the arrow animation
	local animGroup = button.arrow:CreateAnimationGroup(nil)
	animGroup:SetLooping("BOUNCE")
	local anim1 = animGroup:CreateAnimation("Translation")
	anim1:SetDuration(0.4)
	anim1:SetOffset(5, 0)
	anim1:SetOrder(1)
	anim1:SetSmoothing("IN_OUT")

	-- Create the highlight animation
	local animGroup2 = button.highlight:CreateAnimationGroup(nil)
	animGroup2:SetLooping("BOUNCE")
	local anim2 = animGroup2:CreateAnimation("Alpha")
	anim2:SetDuration(2.0)
	anim2:SetChange(-0.4)
	anim2:SetOrder(1)
	anim2:SetSmoothing("IN_OUT")

	button:SetScript("OnSizeChanged", function(self, width, height)
		local xScale = width / REAL_BUTTON_WIDTH
		local yScale = xScale		-- (always uniform)
		self.highlight:SetSize(36 * 2 * xScale, 36 * 2 * yScale)
		self.highlight:SetPoint("CENTER", self, "LEFT", (35 + 20) * xScale, 0)
		self.arrow:SetSize(48 * xScale, 48 * yScale)
		self.arrow:SetPoint("CENTER", self, "LEFT", 22 * xScale, 0)
		anim1:SetOffset(5 * xScale, 0 * yScale)
	end)

	button:SetScript("OnShow", function(self)
		animGroup:Play()
		animGroup2:Play()
	end)

	button:SetScript("OnHide", function(self)
		animGroup:Stop()
		animGroup2:Stop()
	end)

	return button
end
