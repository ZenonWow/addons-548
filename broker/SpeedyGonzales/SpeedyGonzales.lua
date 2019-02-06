local floor = math.floor
local deg = math.deg
local GetUnitSpeed = GetUnitSpeed
local GetUnitPitch = GetUnitPitch
local IsFlying = IsFlying
local IsSwimming = IsSwimming
local IsFalling = IsFalling

local BASE_WIDTH = 80

local db, unit
local speeder = "player"

-- data for the various unit displays
local unitData = {
	percent = "%",
	yards = " yd/s",
	miles = " mph",
	kilometers = " km/h",
	meters = " m/s",
}

local unitWidth = {
	percent = -16,
	kilometers = 8,
}

local unitTransformations = {
	percent = function(n)
		return floor(n / 7 * 100 + 0.1)
	end,
	yards = function(n)
		return floor(n * 10 + 0.01) / 10
	end,
	miles = function(n)
		return floor(n / 1.76 * 36 + 0.01) / 10
	end,
	kilometers = function(n)
		return floor(n * 9.144 * 3.6 + 0.01) / 10
	end,
	meters = function(n)
		return floor(n * 9.144 + 0.01) / 10
	end,
}

local function transform(speed)
	return unitTransformations[db.units](speed)
end

local dataobj = LibStub("LibDataBroker-1.1"):NewDataObject(..., {
	type = "data source",
	text = "Speed",
	icon = [[Interface\Icons\Ability_Rogue_Sprint]],
	label = "Speed",
	OnTooltipShow = function(self)
		local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
		local speed = runSpeed
		if IsSwimming() then
			speed = swimSpeed
		elseif IsFlying() then
			speed = flightSpeed
		end
		self:AddLine(format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MOVEMENT_SPEED).." "..format("%d%%", transform(speed)), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		self:AddLine(format(STAT_MOVEMENT_GROUND_TOOLTIP, transform(runSpeed)))
		self:AddLine(format(STAT_MOVEMENT_FLIGHT_TOOLTIP, transform(flightSpeed)))
		self:AddLine(format(STAT_MOVEMENT_SWIM_TOOLTIP, transform(swimSpeed)))
	end,
})

-- create the speed-o-meter frame
local addon = CreateFrame("Frame", "SpeedyGonzalesFrame", UIParent)
addon:SetMovable(true)
addon:SetToplevel(true)
addon:SetHeight(32)
addon:SetBackdrop({
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	edgeSize = 12,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
})
addon:SetBackdropColor(0, 0, 0, 0.8)
addon:SetBackdropBorderColor(0.5, 0.5, 0.5)
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
addon:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
addon:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, ...)
end)
addon:SetScript("OnMouseDown", addon.StartMoving)
addon:SetScript("OnMouseUp", function(self) self:OnMouseUp() end)
addon:SetScript("OnHide", function(self) self:OnMouseUp() end)

do
	local frame = CreateFrame("Frame")
	frame:SetScript("OnUpdate", function(self)
		local flying = IsFlying()
		local swimming = IsSwimming()
		local floating = flying or swimming
		local pitch = db.pitch and deg(GetUnitPitch(speeder))
		if db.showTopSpeed then
			local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed(speeder)
			
			-- Determine whether to display running, flying, or swimming speed
			local speed = runSpeed
			if swimming then
				speed = swimSpeed
			elseif flying then
				speed = flightSpeed
			end
			
			-- Hack so that your speed doesn't appear to change when jumping out of the water
			if IsFalling() then
				if self.wasSwimming then
					speed = swimSpeed
				end
			else
				self.wasSwimming = swimming
			end
			
			speed = transform(speed)
			
			addon.text:SetFormattedText(("%d%s"..(pitch and (floating and "\n%.1f \194\176" or "\n-") or "")), speed, unit, pitch)
			dataobj.text = format(("%d%s"..(pitch and floating and " %.1f \194\176" or "")), speed, unit, pitch)
		else
			local speed = transform(GetUnitSpeed(speeder))
			addon.text:SetFormattedText(("%d%s"..(pitch and (floating and "\n%.1f \194\176" or "\n-") or "")), speed, unit, pitch)
			dataobj.text = format(("%d%s"..(pitch and floating and " %.1f \194\176" or "")), speed, unit, pitch)
		end
	end)
end

-- create font string for the actual speed text
local addonText = addon:CreateFontString()
addonText:SetPoint("CENTER", addon)
addonText:SetFontObject(GameFontHighlight)
addon.text = addonText

local optionsFrame = CreateFrame("Frame")
optionsFrame.name = "SpeedyGonzales"
InterfaceOptions_AddCategory(optionsFrame)

local title = optionsFrame:CreateFontString(nil, nil, "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetPoint("RIGHT", -16, 0)
title:SetJustifyH("LEFT")
title:SetJustifyV("TOP")
title:SetText(optionsFrame.name)
optionsFrame.title = title

local function onClick(self)
	local checked = self:GetChecked() == 1
	PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
	db[self.setting] = checked
	if self.func then
		addon[self.func](addon)
	end
end

function optionsFrame:NewOption()
	local button = CreateFrame("CheckButton", nil, self, "OptionsBaseCheckButtonTemplate")
	button:SetPushedTextOffset(0, 0)
	button:SetScript("OnClick", onClick)
	
	local buttonText = button:CreateFontString(nil, nil, "GameFontHighlight")
	buttonText:SetPoint("LEFT", button, "RIGHT", 0, 1)
	button:SetFontString(buttonText)

	return button
end

-- check buttons data
local options = {
	{
		text = "Show",
		setting = "shown",
		func = "SetVisibility",
	},
	{
		text = "Lock",
		setting = "locked",
		func = "SetLock",
	},
	{
		text = "Pitch display",
		setting = "pitch",
		func = "SetPitchDisplay",
	},
	{
		text = "Show top speed",
		setting = "showTopSpeed",
	},
}

optionsFrame.options = {}

for i, v in ipairs(options) do
	local option = optionsFrame:NewOption()
	if i == 1 then
		option:SetPoint("TOPLEFT", optionsFrame.title, "BOTTOMLEFT", -2, -16)
	else
		option:SetPoint("TOP", optionsFrame.options[i - 1], "BOTTOM", 0, -8)
	end
	option:SetText(v.text)
	option.setting = v.setting
	option.func = v.func
	optionsFrame.options[i] = option
end

local dropdown = CreateFrame("Frame", "SpeedyGonzalesUnitsMenu", optionsFrame, "UIDropDownMenuTemplate")
dropdown:SetPoint("TOPLEFT", optionsFrame.options[#options], "BOTTOMLEFT", -13, -24)
dropdown.label = dropdown:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
dropdown.label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 16, 3)
dropdown.label:SetText("Units")

-- slash command opens options frame
SLASH_SPEEDYGONZALES1 = "/speedy"
SlashCmdList["SPEEDYGONZALES"] = function(msg)
	msg = msg:trim()
	if msg:lower() == "config" then
		InterfaceOptionsFrame_OpenToCategory(optionsFrame)
	elseif msg == "" then
		db.shown = not db.shown
		optionsFrame.options[1]:SetChecked(db.shown)
		addon:SetVisibility()
	else
		print("|cffffff00SpeedyGonzales:|r Type '/speedy' to toggle the frame or '/speedy config' to open the configuration.")
	end
end

function addon:ADDON_LOADED(addon)
	if addon == "SpeedyGonzales" then
		-- create options defaults if they do not exist
		db = SpeedyGonzalesDB or {
			units = "percent",
			shown = true,
			locked = false,
			pitch = false,
			showTopSpeed = false,
		}
		db.pos = db.pos or {
			point = "CENTER",
			xOff = 0,
			yOff = -100
		}
		SpeedyGonzalesDB = db
		self:Initialize()
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function addon:PLAYER_ENTERING_WORLD()
	if UnitInVehicle("player") then
		speeder = "vehicle"
	end
end

function addon:UNIT_ENTERED_VEHICLE()
	speeder = "vehicle"
end

function addon:UNIT_EXITED_VEHICLE()
	speeder = "player"
end

function addon:Initialize()
	for i, button in ipairs(optionsFrame.options) do
		button:SetChecked(db[button.setting])
	end
	
	local function onClick(self)
		local value = self.value
		UIDropDownMenu_SetSelectedValue(dropdown, value)
		db.units = value
		unit = unitData[value]
		addon:FixWidth()
	end
	
	local items = {
		"Percent",
		"Yards per second",
		"Miles per hour",
		"Kilometers per hour",
		"Meters per second",
	}
	local values = {
		"percent",
		"yards",
		"miles",
		"kilometers",
		"meters",
	}
	
	UIDropDownMenu_Initialize(dropdown, function(self)
		for i, v in ipairs(items) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = values[i]
			info.func = onClick
			UIDropDownMenu_AddButton(info)
		end
	end)
	UIDropDownMenu_SetWidth(dropdown, 120)
	UIDropDownMenu_SetSelectedValue(dropdown, db.units)
	
	unit = unitData[db.units]
	
	self:SetPosition()
	for k, v in pairs(options) do
		if v.func then self[v.func](self) end
	end
	self:FixWidth()
end

function addon:OnMouseUp()
	self:StopMovingOrSizing()
	local point, _, _, xOff, yOff = self:GetPoint()
	local pos = db.pos
	pos.point = point
	pos.xOff = xOff
	pos.yOff = yOff
end

function addon:SetPosition()
	local pos = db.pos
	self:SetPoint(pos.point, pos.xOff, pos.yOff)
end

function addon:SetVisibility()
	self:SetShown(db.shown)
end

function addon:SetLock()
	self:EnableMouse(not db.locked)
end

-- resize frame so the pitch display fits
function addon:SetPitchDisplay()
	if db.pitch then
		self:SetHeight(48)
	else
		self:SetHeight(32)
	end
end

-- set width depending on displayed unit type
function addon:FixWidth()
	self:SetWidth(BASE_WIDTH + (unitWidth[db.units] or 0))
end