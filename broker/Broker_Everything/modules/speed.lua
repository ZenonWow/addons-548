
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
-- I[name] = {iconfile="Interface\\Icons\\Ability_Rogue_Sprint",coords={0.05,0.95,0.05,0.95}}
-- Icon credits go to gmSpeed addon.
I[name] = {iconfile=[[Interface\Addons\"..addon.."\media\speed]]}


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
	if UnitInVehicle(unit) then unit = "vehicle" end

	local speed = GetUnitSpeed(unit) / 7 * 100
	local pitch = math.deg( GetUnitPitch(unit) )
	
	-- local speedFormat = "%."..module.modDB.precision.."f%% %.0f°"
	local speedFormat = "%.0f%%  %.0f°"
	self.obj.text = speedFormat:format(speed, pitch)
	
	-- local numFormat, degFormat = "%."..module.modDB.precision.."f%%", "%.0f°"
	-- self.obj.text = numFormat:format(speed) .."% ".. degFormat:format(pitch) .."°"
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
module.onenter = function(self) end -- tt prevention (currently not on all broker panels...)

module.onclick = function(self,button)
	--if not PetJournalParent then PetJournal_LoadUI() end 
	--TogglePetJournal(1)
end


-- final module registration --
-------------------------------
ns.modules[name] = module

