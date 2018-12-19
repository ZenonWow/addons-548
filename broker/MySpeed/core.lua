local ADDON = ...

local UPDATEPERIOD, elapsed = 0.2, 0
local speed
local pitch
local string_format = string.format
local math_deg = math.deg
local prgname = "MySpeed"

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject("MySpeed", {
	type = "data source",
	icon = "Interface\\Icons\\Ability_Druid_FlightForm",
	text = "100%",
})

local frame_ms = CreateFrame("Frame", ADDON.."_LDB")
frame_ms:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < UPDATEPERIOD then return end
	elapsed = 0
	speed = (GetUnitSpeed("Player") / 7) * 100
	pitch = math_deg(GetUnitPitch("Player"))
	dataobj.text = string_format("%.1f %.1f", pitch, speed)
end
)