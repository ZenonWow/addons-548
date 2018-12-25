local _,class = UnitClass("player")
local AuraType = {
	DEATHKNIGHT = "presences",
	DRUID = "shapeshifts",
	PALADIN = "auras",
	WARRIOR = "stances"
}
local function ShapeshiftUpdate()
	local db = TidyPlatesThreat.db.char[AuraType[class]]	
	if db.ON then
		TidyPlatesThreat.db.char.spec[t.Active()] = _db[GetShapeshiftForm()]
		t.Update()
	end
end

TidyPlatesThreat.ShapeshiftUpdate = ShapeshiftUpdate