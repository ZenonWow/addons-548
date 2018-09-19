-- Configuration
local chatOutput = 1 -- Displays output when you toggle level flying. 1 - on, nil - off.

-- Local Table
local aName, aTable = ...

-- Locals
local level
local pName = aName..": "

function aTable.FlyLevel()
	if level then
		ConsoleExec("pitchlimit 88") -- 88 prevents the camera from doing strange things when you hit the top or bottom of your axis.
		level = nil
		aTable.Print(pName..aTable.LEVEL_FLIGHT_OFF)
	else
		ConsoleExec("pitchlimit 0")
		level = 1
		aTable.Print(pName..aTable.LEVEL_FLIGHT_ON)
	end
end

function aTable.Print(msg) 
	if not DEFAULT_CHAT_FRAME then
		return
	end
	if chatOutput then
		DEFAULT_CHAT_FRAME:AddMessage("|cff20ff20"..msg)
	else
		return
	end
end

-- For keybinding purposes. Might be useful in the future as well.
local button = CreateFrame("Button", "LevelFlightButton", nil, "SecureHandlerClickTemplate")
button:SetScript("OnClick", aTable.FlyLevel)

-- Localization
aTable.LEVEL_FLIGHT_ON = "Flying level."
aTable.LEVEL_FLIGHT_OFF = "Flying free."
aTable.KEYBIND_LEVEL_FLIGHT_ON = "Toggle level flying"

-- Bindings
BINDING_HEADER_LEVELFLIGHT = aName
_G["BINDING_NAME_CLICK LevelFlightButton:LeftButton"] = aTable.KEYBIND_LEVEL_FLIGHT_ON
