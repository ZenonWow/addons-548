
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Speed" -- L["Speed"]
local tt = nil
local string,GetUnitSpeed,UnitInVehicle = string,GetUnitSpeed,UnitInVehicle


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Icons\\Ability_Rogue_Sprint",coords={0.05,0.95,0.05,0.95}}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["How fast are you swimming, walking, riding or flying."],
	events = {},
	updateinterval = 0.1, -- false or integer
	config_defaults = {
		precision = 0
	},
	config_allowed = nil,
	config = {
		height = 62,
		elements = {
			{
				type = "slider",
				name = "precision",
				label = L["Precision"],
				desc = "",
				minText = "0",
				maxText = "3",
				minValue = 0,
				maxValue = 3,
				default = 0
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------


------------------------------------
-- module (BE internal) functions --
------------------------------------

module.onupdate = function(self)
	local unit = "player"
	if UnitInVehicle("player") then unit = "vehicle" end

	local speed = ("%."..Broker_EverythingDB[name].precision.."f"):format(GetUnitSpeed(unit) / 7 * 100 ) .. "%"

	self.obj.text = speed
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
module.onenter = function(self) end -- tt prevention (currently not on all broker panels...)

module.onclick = function(self,button)
	--if not PetJournalParent then PetJournal_LoadUI() end 
	--securecall("TogglePetJournal",1)
end


-- final module registration --
-------------------------------
ns.modules[name] = module

