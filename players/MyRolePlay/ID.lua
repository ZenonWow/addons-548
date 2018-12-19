--[[
	MyRolePlay 4 (C) 2010-2013 Etarna Moonshyne <etarna@moonshyne.org>
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	ID.lua - A list of users to specially identify i.e. debug/beta/dev users
]]

local L = mrp.L

-- ['guid'] = { "Realm-REGION", "identification" }
mrp.id = {
	-- Joel RMM, Author of MyRolePlay 5.x <captainlepper@gmail.com>
	['0x018000000696F1E8'] = { "Wyrmrest Accord-US", L["(( MyRolePlay Author ))"] }, -- Mackinzee
	['0x018000000691E19A'] = { "Wyrmrest Accord-US", L["(( MyRolePlay Author ))"] }, -- Oxenbow
	-- The alpha testers of <Oathsworn Vanguard>, Wyrmrest Accord-US
	['0x01800000069A4241'] = { "Wyrmrest Accord-US", L["(( MRP Alpha Tester ))"] }, -- Inte
	-- The beta testers of <Sorrows End>, Wyrmrest Accord-US
	['0x01800000069A4205'] = { "Wyrmrest Accord-US", L["(( MRP Beta Tester ))"] }, -- Wisperi
	['0x0100000006E3F10E'] = { "Moon Guard-US", L["(( MRP Beta Tester ))"] }, -- Syphr
	['0x01800000069A3D8E'] = { "Wyrmrest Accord-US", L["(( MRP Beta Tester ))"] }, -- Lunaxia
}
mrp.idrealm = setmetatable({}, {
	__index = function( table, key )
		return key
	end,
})
mrp.idrealm['WyrmrestAccord'] = "Wyrmrest Accord"