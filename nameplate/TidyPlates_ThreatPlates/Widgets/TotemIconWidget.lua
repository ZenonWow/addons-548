---------------
-- Totem Icon Widget
---------------

local path = "Interface\\Addons\\TidyPlates_ThreatPlates\\Widgets\\TotemIconWidget\\"

function tL(number)
	local name = GetSpellInfo(number)
	return name
end

ThreatPlates_Totems = {
	-- Air Totem
	["Orgrimmar Grunt"] = "A1",
	[tL(8177)] = 	"A1", 	-- Grounding Totem
	[tL(120668)] = 	"A2", 	-- Stormlash Totem
	[tL(108273)] = 	"A3", 	-- Windwalk Totem
	[tL(98008)] = 	"A4", 	-- Spirit Link Totem
	[tL(108269)] = 	"A5", 	-- Capacitor Totem
	-- Earth Totems
	[tL(2062)] = "E1", -- Earth Elemental Totem
	[tL(2484)] = "E2", -- Earthbind Totem
	[tL(51485)] = "E3", -- Earthgrab Totem
	[tL(108270)] = "E4", -- Stone Bulwark Totem
	[tL(8143)] = "E5", -- Tremor Totem
	-- Fire Totems
	[tL(2894)] = "F1", -- Fire Elemental Totem
	[tL(8190)] = "F2", -- Magma Totem
	[tL(3599)] = "F3", -- Searing Totem
	-- Water Totems
	[tL(5394)] = "W1", -- Healing Stream Totem
	[tL(16190)] = "W2", -- Mana Tide Totem
	[tL(108280)] = "W3", -- Healing Tide Totem
}

local function enabled()
	local db = TidyPlatesThreat.db.profile.totemWidget
	return db.ON	
end

local function GetTotemInfo(name)
	local totem = ThreatPlates_Totems[name]
	local db = TidyPlatesThreat.db.profile.totemSettings
	if totem then
		local texture =  path..db[totem][7].."\\"..totem
		return db[totem][3],texture
	else
		return false, nil
	end
end

local function UpdateSettings(frame)
	local db = TidyPlatesThreat.db.profile.totemWidget
	frame:SetHeight(db.scale)
	frame:SetWidth(db.scale)
	frame:SetFrameLevel(frame:GetParent():GetFrameLevel()+1)
	frame:SetPoint(db.anchor,frame:GetParent(),db.x, db.y)
	frame:Show()
end

local function UpdateTotemIconWidget(frame, unit)
	local isActive, texture = GetTotemInfo(unit.name)
	if isActive then
		frame.Icon:SetTexture(texture)
		UpdateSettings(frame)
	else
		frame:Hide()
	end
end

local function CreateTotemIconWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(64)
	frame:SetHeight(64)
	frame.Icon = frame:CreateTexture(nil, "OVERLAY")
	frame.Icon:SetPoint("CENTER",frame)
	frame.Icon:SetAllPoints(frame)
	frame:Hide()
	frame.Update = UpdateTotemIconWidget
	return frame
end

ThreatPlatesWidgets.RegisterWidget("TotemIconWidget",CreateTotemIconWidget,false,enabled)