

local lib, oldminor = LibStub:NewLibrary("SlimPanel", 1)
if not lib then return end
oldminor = oldminor or 0

--[[
local function createtex(parent, layer, w, h, ...)
	local tex = parent:CreateTexture(nil, layer)
	tex:SetWidth(w) tex:SetHeight(h)
	tex:SetPoint(...)
	return tex
end

local function AddTex(frame, name, layer, texturePath)
	assert(not frame[name], "AddTex(): Frame already has a member named "..name)
	local tex = frame:CreateTexture(nil, layer)
	tex:SetTexture(texturePath)
	return tex
end

local function AddBG(frame, name, texturePath)
	local tex = AddTex(frame, name, 'BACKGROUND', texturePath)
	tex:SetAllPoints()
	return tex
end

local function AddBorder(frame, name, texturePath)
	local tex = AddTex(frame, name, 'BACKGROUND', texturePath)
	tex:SetAllPoints()
	return tex
end
--]]
local fbd = {
	insets = { left=0, right=0, top=0, bottom=0 },
	bgColor = { .09, .09, .19, 1 },
	bgFile = [[Interface\AddOns\TipTop\media\brushed.tga]],
	borderWidth = 2.5,
	borderColor = { .6, .6, .6, 1 },
	edgeFile = [[Interface\AddOns\TipTop\media\SeerahSolidBorder.blp]],
}

local tbd = {
	insets = { left=0, right=0, top=0, bottom=0 },
	bgColor = { 0, 0, 0, .4 },
	bgFile = [[Interface\AddOns\TipTop\media\brushed.tga]],
	--[==[
	borderWidth = 2.5,
	borderColor = { .6, .6, .6, 1 },
	edgeFile = [[Interface\AddOns\TipTop\media\SeerahSolidBorder.blp]],
	--]==]
}

local function AddBD(frame, backdrop)
	frame:SetBackdrop(backdrop)
	if  backdrop.bgColor  then  frame:SetBackdropColor(unpack(backdrop.bgColor))  end
	if  backdrop.borderColor  then  frame:SetBackdropBorderColor(unpack(backdrop.borderColor))  end
	return frame
end


function lib.new(name, titletext, splitstyle)
	local frame = CreateFrame('Frame', name, UIParent)
	frame:Hide()
	frame:CreateTitleRegion()
	frame:SetFrameStrata('DIALOG')
	--frame:SetWidth(832) frame:SetHeight(447)
	frame:SetWidth(800) frame:SetHeight(500)
	frame:SetPoint('TOPLEFT', 20, -50)
	AddBD(frame, fbd)

	--[[
	frame:SetAttribute("UIPanelLayout-defined", true)
	frame:SetAttribute("UIPanelLayout-enabled", true)
	frame:SetAttribute("UIPanelLayout-area", "doublewide")
	frame:SetAttribute("UIPanelLayout-whileDead", true)
	--]]
	table.insert(UISpecialFrames, name)

	local TitleRegion = frame:GetTitleRegion()
	TitleRegion:SetHeight(20)
	--TitleRegion:SetWidth(757)
	-- 832-757 = 75
	TitleRegion:SetPoint('TOPLEFT',  0, 0)
	TitleRegion:SetPoint('TOPRIGHT', 0, 0)
	--AddBD(TitleRegion, tbd)
	frame.TitleRegion = TitleRegion
	--[==[
	AddBG(TitleRegion, 'tBackground', [[Interface\AddOns\TipTop\media\bar2.blp]]")
	AddBG(frame, 'tBackground', [[Interface\AddOns\TipTop\media\brushed.tga]]")
	AddBorder(frame, 'tBorder', [[Interface\AddOns\TipTop\media\SeerahSolidBorder.blp]]")
	--]==]

	--[[
	local portrait = createtex(frame, "OVERLAY", 57, 57, "TOPLEFT", 9, -7)
	SetPortraitTexture(portrait, "player")
	frame:SetScript("OnEvent", function(self, event, unit) if unit == "player" then SetPortraitTexture(portrait, "player") end end)
	frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	--]]

	local TitleText = frame:CreateFontString(nil, 'OVERLAY')
	TitleText:SetFontObject(GameFontNormal)
	TitleText:SetPoint('TOP', 0, -3)
	TitleText:SetText(titletext)
	frame.TitleText = TitleText

	--[[
	local topleft = createtex(frame, "ARTWORK", 256, 256, "TOPLEFT", 0, 0)
	local top = createtex(frame, "ARTWORK", 320, 256, "TOPLEFT", 256, 0)
	local topright = createtex(frame, "ARTWORK", 256, 256, "TOPLEFT", top, "TOPRIGHT")
	local bottomleft = createtex(frame, "ARTWORK", 256, 256, "TOPLEFT", 0, -256)
	local bottom = createtex(frame, "ARTWORK", 320, 256, "TOPLEFT", 256, -256)
	local bottomright = createtex(frame, "ARTWORK", 256, 256, "TOPLEFT", bottom, "TOPRIGHT")

	if splitstyle then
		topleft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft")
		top:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top")
		topright:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight")
		bottomleft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft")
		bottom:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Bot")
		bottomright:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotRight")
	else
		topleft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft")
		top:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-Top")
		topright:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopRight")
		bottomleft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft")
		bottom:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-Bot")
		bottomright:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight")
	end
	--]]

	local CloseBtn = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
	CloseBtn:SetPoint('TOPRIGHT', 3, -8)
	CloseBtn:SetScript('OnClick', function() HideUIPanel(frame) end)
	frame.CloseBtn = CloseBtn

	return frame
end

