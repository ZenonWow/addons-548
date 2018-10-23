-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2011.11.06					---
--- Version: 1.6 [2013.12.15]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/fastercamera
--- WoWInterface	http://www.wowinterface.com/downloads/info20483-FasterCamera.html
--[[
/dump GetCVar("cameraDistance")
/dump GetCameraDistance()
/run OldZoomIn=OldZoomIn or CameraZoomIn ; function CameraZoomIn(distance) ChatFrame1:AddMessage('CameraZoomIn('.. distance ..')') end
/run CameraZoomIn=OldZoomIn or CameraZoomIn
end

--]]


local NAME, S = ...
local VERSION = GetAddOnMetadata(NAME, "Version")

local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local L = S.L
local db

	----------------
	--- Prehooks ---
	----------------

local oldZoomIn = CameraZoomIn
local oldZoomOut = CameraZoomOut

local function GetIncrement(distance)
	return  IsAltKeyDown()  and  db.incrementAlt
	or  IsShiftKeyDown()  and  db.incrementShift
	or  IsControlKeyDown()  and  db.incrementCtrl
	or  db.increment
end

local function doZoom(zoomFunc, distance)
	distance = distance * GetIncrement(distance)
	while  5 < distance  do
		zoomFunc(5)
		distance = distance - 5
	end
	zoomFunc(distance)
end

function CameraZoomIn(distance)
	doZoom(oldZoomIn, distance)
end

function CameraZoomOut(distance)
	doZoom(oldZoomOut, distance)
end

-- tried this out in the SotA demolishers
-- the normal camera zoom functions seemed to be used instead
-- I suppose both can be used interchangeably
local oldVehicleZoomIn = VehicleCameraZoomIn
local oldVehicleZoomOut = VehicleCameraZoomOut

function VehicleCameraZoomIn(distance)
	doZoom(oldVehicleZoomIn, distance)
end

function VehicleCameraZoomOut(distance)
	doZoom(oldVehicleZoomOut, distance)
end

	---------------
	--- Options ---
	---------------

local cvar = {
	"cameraDistanceMoveSpeed",
	"cameraDistanceMax",
	"cameraDistanceMaxFactor",
}

local defaults = {
	db_version = 1.3, -- update this on (major) savedvars changes
	--increment = 4,
	increment = 3,
	incrementAlt = 1,
	incrementShift = 5,
	incrementCtrl = 10,
	speed = 20,
	distance = 50,
}

local options = {
	type = "group",
	name = format("%s |cffADFF2Fv%s|r", NAME, VERSION),
	args = {
		blockSpeed = {
			type = "group", order = 1,
			name = " ",
			inline = true,
			args = {
				increment = {
					type = "range", order = 1,
					width = "double", descStyle = "",
					name = L.CAMERA_ZOOM_INCREMENT,
					get = function(i) return db.increment end,
					set = function(i, v) db.increment = v end,
					min = 1,
					max = 50, softMax = 10,
					step = 1,
				},
				incrementAlt = {
					type = "range", order = 2,
					width = "double", descStyle = "",
					name = L.CAMERA_ZOOM_INCREMENT ..' (Alt pressed)',
					get = function(i) return db.incrementAlt end,
					set = function(i, v) db.incrementAlt = v end,
					min = 1,
					max = 50, softMax = 10,
					step = 1,
				},
				incrementShift = {
					type = "range", order = 3,
					width = "double", descStyle = "",
					name = L.CAMERA_ZOOM_INCREMENT ..' (Shift pressed)',
					get = function(i) return db.incrementShift end,
					set = function(i, v) db.incrementShift = v end,
					min = 1,
					max = 100, softMax = 30,
					step = 1,
				},
				incrementCtrl = {
					type = "range", order = 4,
					width = "double", descStyle = "",
					name = L.CAMERA_ZOOM_INCREMENT ..' (Ctrl pressed)',
					get = function(i) return db.incrementCtrl end,
					set = function(i, v) db.incrementCtrl = v end,
					min = 1,
					max = 100, softMax = 30,
					step = 1,
				},
			},
		},
		blockDistance = {
			type = "group", order = 2,
			name = " ",
			inline = true,
			args = {
				newline1 = {type = "description", order = 2, name = "\n"},
				cameraDistanceMoveSpeed = {
					type = "range", order = 3,
					width = "double", descStyle  = "",
					name = L.CAMERA_ZOOM_SPEED,
					get = function(i) return tonumber(GetCVar("cameraDistanceMoveSpeed")) end,
					set = function(i, v) SetCVar("cameraDistanceMoveSpeed", v); db.speed = v end,
					min = 1,
					max = 200, softMax = 100,
					step = 1,
				},
				newline2 = {type = "description", order = 4, name = "\n"},
				cameraDistanceMax = {
					type = "range", order = 5,
					width = "double", 	descStyle = "",
					name = MAX_FOLLOW_DIST,
					get = function(i) return tonumber(GetCVar("cameraDistanceMax")) end,
					set = function(i, v) SetCVar("cameraDistanceMax", v); db.distance = v end,
					min = 1,
					max = 50,
					step = 1,
				},
			},
		},
		defaults = {
			type = "execute", order = 3,
			descStyle = "",
			name = DEFAULTS,
			confirm = true, confirmText = RESET_TO_DEFAULT.."?",
			func = function()
				db.increment = defaults.increment
				db.incrementAlt = defaults.incrementAlt
				db.incrementShift = defaults.incrementShift
				db.incrementCtrl = defaults.incrementCtrl
				db.speed = tonumber(GetCVarDefault("cameraDistanceMoveSpeed"))
				db.distance = tonumber(GetCVarDefault("cameraDistanceMax"))
				for _, v in ipairs(cvar) do
					SetCVar(v, GetCVarDefault(v))
				end
			end,
		},
	},
}

	----------------------
	--- Initialization ---
	----------------------

local f = CreateFrame("Frame")

-- delay setting/overriding the CVars because it's either
-- not yet ready or is being reverted/overridden by something else
function f:OnUpdate(elapsed)
	f.delay = (f.delay or 0) + elapsed
	if f.delay > 1 then
		SetCVar("cameraDistanceMoveSpeed", db.speed)
		SetCVar("cameraDistanceMax", db.distance)
		-- cameraDistanceMax should be the only thing controlling
		-- the max camera distance, for accuracy and simplicity's sake
		SetCVar("cameraDistanceMaxFactor", 1)
		self:SetScript("OnUpdate", nil)
	end
end

function f:OnEvent(event, addon)
	if addon ~= NAME then return end
	
	if not FasterCameraDB2 or FasterCameraDB2.db_version ~= defaults.db_version then
		FasterCameraDB2 = defaults
	end
	db = FasterCameraDB2
	ACR:RegisterOptionsTable("FasterCamera", options)
	ACD:AddToBlizOptions("FasterCamera", NAME)
	ACD:SetDefaultSize("FasterCamera", 420, 700)
	self:SetScript("OnUpdate", f.OnUpdate)
	self:UnregisterEvent(event)
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

	---------------------
	--- Slash Command ---
	---------------------

for i, v in ipairs({"fc", "fastercam", "fastercamera"}) do
	_G["SLASH_FASTERCAMERA"..i] = "/"..v
end

SlashCmdList.FASTERCAMERA = function(msg, editbox)
	ACD:Open("FasterCamera")
end

	---------------------
	--- LibDataBroker ---
	---------------------

local function distance()
	local maxDistance = GetCVar("cameraDistanceMax") * GetCVar("cameraDistanceMaxFactor")
	return maxDistance<=50 and maxDistance or 50
end

local dataobject = {
	type = "launcher",
	icon = "Interface\\Icons\\inv_misc_spyglass_03",
	text = NAME,
	OnClick = function(clickedframe, button)
		ACD[ACD.OpenFrames.FasterCamera and "Close" or "Open"](ACD, "FasterCamera")
	end,
	OnTooltipShow = function(tt)
		tt:AddLine("|cffADFF2F"..NAME.."|r")
		tt:AddDoubleLine(L.CAMERA_ZOOM_INCREMENT, "|cffFFFFFF"..db.increment.."|r")
		tt:AddDoubleLine(L.CAMERA_ZOOM_SPEED, "|cffFFFFFF"..db.speed.."|r")
		tt:AddDoubleLine(MAX_FOLLOW_DIST, "|cffFFFFFF"..distance().."|r")
	end,
}

LibStub("LibDataBroker-1.1"):NewDataObject(NAME, dataobject)
