local MM = LibStub("AceAddon-3.0"):NewAddon("MiniMapster", "AceConsole-3.0")

local border = nil
local scrollzoom = nil
local db

local classcolor = RAID_CLASS_COLORS[select(2,UnitClass("player"))]

local WoD = select(4, GetBuildInfo()) >= 60000

local defaults = {
	profile = {
		lock = false,
		x = 9, y = -92,
		anchor = "TOP",
		anchorframe = "MinimapCluster",
		mask = "SQUARE",
		border = "Thin",
		bordercolor = { r = 1, g = 1, b = 1, a = 1 },
		classborder = false,
		scale = 1.0,
		showcalendar = false,
		showclock = true,
	},
}

local roundShapes = {
	{
		["ROUND"] = true,
		["CORNER-TOPLEFT"] = true,
		["SIDE-LEFT"] = true,
		["SIDE-TOP"] = true,
		["TRICORNER-TOPRIGHT"] = true,
		["TRICORNER-TOPLEFT"] = true,
		["TRICORNER-BOTTOMLEFT"] = true,
	},
	{
		["ROUND"] = true,
		["CORNER-TOPRIGHT"] = true,
		["SIDE-RIGHT"] = true,
		["SIDE-TOP"] = true,
		["TRICORNER-BOTTOMRIGHT"] = true,
		["TRICORNER-TOPRIGHT"] = true,
		["TRICORNER-TOPLEFT"] = true,
	},
	{
		["ROUND"] = true,
		["CORNER-BOTTOMLEFT"] = true,
		["SIDE-LEFT"] = true,
		["SIDE-BOTTOM"] = true,
		["TRICORNER-TOPLEFT"] = true,
		["TRICORNER-BOTTOMLEFT"] = true,
		["TRICORNER-BOTTOMRIGHT"] = true,
	},
	{
		["ROUND"] = true,
		["CORNER-BOTTOMRIGHT"] = true,
		["SIDE-RIGHT"] = true,
		["SIDE-BOTTOM"] = true,
		["TRICORNER-BOTTOMLEFT"] = true,
		["TRICORNER-BOTTOMRIGHT"] = true,
		["TRICORNER-TOPRIGHT"] = true,
	},
}
		
		
local function giveOptions()
	local options = {
		type = "group",
		name = "MiniMapster",
		get = function( k ) return db[k.arg] end,
		set = function( k, v ) db[k.arg] = v; MM:SetBorder(); MM:SetMask(); end,
		args = {
			title = {
				type = "description",
				name = "Minimapster is Mapsters minimap brother. You can configure the look and feel of the minimap below.",
				order = 0,
			},
			shape = {
				name = "Shape",
				type = "select",
				arg = "mask",
				values = {
					["SQUARE"] = "Square",
					["ROUND"] = "Round",
					["CORNER-BOTTOMLEFT"] = "Corner Bottom Left",
					["CORNER-BOTTOMRIGHT"] = "Corner Bottom Right",
					["CORNER-TOPLEFT"] = "Corner Top Left",
					["CORNER-TOPRIGHT"] = "Corner Top Right",
					["TRICORNER-BOTTOMLEFT"] = "Tricorner Bottom Left",
					["TRICORNER-BOTTOMRIGHT"] = "Tricorner Bottom Right",
					["TRICORNER-TOPLEFT"] = "Tricorner Top Left",
					["TRICORNER-TOPRIGHT"] = "Tricorner Top Right",
					["SIDE-BOTTOM"] = "Side Bottom",
					["SIDE-RIGHT"] = "Side Right",
					["SIDE-TOP"] = "Side Top",
					["SIDE-LEFT"] = "Side Left",
				},
				order = 10,
			},
			breaka = {
				type = "description",
				name = "",
				order = 15,
			},
			border = {
				name = "Border",
				type = "select",
				arg = "border",
				values = {
					["Blizzard"] = "Blizzard",
					["Flat"] = "Flat",
					["Thin"] = "Thin",
					["Tooltip"] = "Tooltip",
				},
				order = 20,
			},
			bordercolor = {
				name = "Border Color",
				type = "color",
				arg = "bordercolor",
				hasAlpha = true,
				get = function( k ) return db[k.arg].r, db[k.arg].g, db[k.arg].b, db[k.arg].a end,
				set = function( k, r, g, b, a ) MM:SetBorderColor(r,g,b,a) end,
				order = 30,
			},
			classborder = {
				name = "Class Border Color",
				type = "toggle",
				arg = "classborder",
				desc = "Use class color for the border. Alpha setting from the border color settings will be used.",
				order = 35,
				set = function( k, v ) db.classborder = v; MM:SetBorderColor() end,
			},
			breakie = {
				name = "",
				type = "description",
				order = 40,
			},
			scale = {
				name = "Scale",
				type = "range",
				min = 0.1, max = 2.0, step = 0.01,
				arg = "scale",
				desc = "Change the scale of the Minimap frame.",
				order = 45,
				set = function( k, v ) db.scale = v; MM:SetScale() end,
			},
			breakie2 = {
				name = "",
				type = "description",
				order = 49,
			},
			lock = {
				name = "Lock",
				type = "toggle",
				arg = "lock",
				order = 50,
			},
			showcalendar = {
				name = "Show Calendar",
				type = "toggle",
				arg = "showcalendar",
				order = 51,
				set = function( k, v ) db.showcalendar = v; MM:FixButtons() end,
			},
			showclock = {
				name = "Show Clock",
				type = "toggle",
				arg = "showclock",
				order = 52,
				set = function( k, v ) db.showclock = v; MM:FixButtons() end,
			}
		},
	}
	return options
end

function MM:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("MiniMapsterDB", defaults, "Default")
	db = self.db.profile
	
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("MiniMapster", giveOptions)
	local frame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MiniMapster", "MiniMapster")

	self:RegisterChatCommand("minimapster", function() InterfaceOptionsFrame_OpenToCategory(frame) end)
	self:RegisterChatCommand("mm", function() InterfaceOptionsFrame_OpenToCategory(frame) end)
	
end

function MM:OnEnable()
	self:FixButtons()
	self:SetBorder()
	self:SetBorderColor()
	self:SetMask()
	self:SetScrollZoom()
	self:SetMovable()
	self:SetScale()
end

function MM:SetScrollZoom()
	if not scrollzoom then
		scrollzoom = CreateFrame("Frame", nil, Minimap)
	end
	scrollzoom:SetFrameStrata("LOW")
	scrollzoom:EnableMouse(false)
	scrollzoom:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
	scrollzoom:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT")
	scrollzoom:EnableMouseWheel(true)
	scrollzoom:SetScript("OnMouseWheel", function(frame, delta)
		if delta > 0 then MinimapZoomIn:Click()
		elseif delta < 0 then MinimapZoomOut:Click() end
	end)
end

function MM:FixButtons()
	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetPoint("BOTTOM", Minimap, "TOP", -8, 10)
	MinimapZoneTextButton:SetScript("OnClick", ToggleMinimap)
	
	MinimapZoneText:SetPoint("TOP", MinimapZoneTextButton, "TOP", 9, 1)

	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("RIGHT", Minimap, "TOPLEFT", 0, -10)

	MiniMapChallengeMode:ClearAllPoints()
	MiniMapChallengeMode:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 13, -6)

	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:SetPoint("CENTER", Minimap, "LEFT", -10, 0)

	if WoD then
		GarrisonLandingPageMinimapButton:ClearAllPoints()
		GarrisonLandingPageMinimapButton:SetPoint("TOP", Minimap, "BOTTOM", -41, 18)
	end

	MiniMapWorldMapButton:Hide()
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	
	if db.showcalendar then
		GameTimeFrame:Show()
	else
		GameTimeFrame:Hide()
	end

	if db.showclock then
		TimeManagerClockButton:Show()
	else
		TimeManagerClockButton:Hide()
	end
end

function MM:SetMovable()
	Minimap:SetMovable(true)
	Minimap:EnableMouse(true)
	MinimapCluster:EnableMouse(false)
	Minimap:SetClampedToScreen(true)
	Minimap:RegisterForDrag("LeftButton")
	Minimap:SetScript("OnDragStart", function(frame) if not db.lock then frame:StartMoving() end end)
	Minimap:SetScript("OnDragStop", function(frame)
		if db.lock then return end
		frame:StopMovingOrSizing()
		db.x, db.y = frame:GetCenter()
		db.anchorframe, db.anchor = "UIParent", "BOTTOMLEFT"
	end)

	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER", db.anchorframe, db.anchor, db.x, db.y)	
end

local borders

function MM:SetBorder()
	MinimapBorderTop:Hide()
	MinimapBorder:Hide()
	-- Bordercode thanks to Ckknight (Chinchilla)
	if not borders then
		borders = {}
		for i=1,4 do
			local t = MinimapBackdrop:CreateTexture("MiniMapsterCorner" .. i, "ARTWORK")
			t:SetWidth(80)
			t:SetHeight(80)
			borders[i] = t
		end
		borders[1]:SetPoint("BOTTOMRIGHT", Minimap, "CENTER")
		borders[1]:SetTexCoord(0, 0.5, 0, 0.5)
		
		borders[2]:SetPoint("BOTTOMLEFT", Minimap, "CENTER")
		borders[2]:SetTexCoord(0.5, 1, 0, 0.5)
		
		borders[3]:SetPoint("TOPRIGHT", Minimap, "CENTER")
		borders[3]:SetTexCoord(0, 0.5, 0.5, 1)
		
		borders[4]:SetPoint("TOPLEFT", Minimap, "CENTER")
		borders[4]:SetTexCoord(0.5, 1, 0.5, 1)		
	end
	local style = db.border or "Blizzard"
	local round = "Interface\\AddOns\\MiniMapster\\borders\\round\\" .. style
	local square = "Interface\\AddOns\\MiniMapster\\borders\\square\\" .. style
	for i,v in ipairs(borders) do
		v:SetTexture(roundShapes[i][db.mask] and round or square)
	end
end

function MM:SetBorderColor(r,g,b,a)
	if r then
		db.bordercolor.r, db.bordercolor.g, db.bordercolor.b, db.bordercolor.a = r,g,b,a
	else
		r, g, b, a = db.bordercolor.r, db.bordercolor.g, db.bordercolor.b, db.bordercolor.a
	end
	if db.classborder then -- obey alpha 
		r, g, b = classcolor.r, classcolor.g, classcolor.b
	end
	if borders then
		for i, v in ipairs(borders) do
			v:SetVertexColor(r, g, b, a)
		end
	end
end

function MM:SetMask()
	Minimap:SetMaskTexture("Interface\\AddOns\\MiniMapster\\masks\\".. db.mask)
end

function MM:SetScale()
	Minimap:SetScale(db.scale)
end

function GetMinimapShape() return db.mask end
