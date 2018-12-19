-- Daily Global Check - Hallow's End
-- Mindie EU-Well of Eternity

local addonName, addonTable = ...

local plugintitle = "Hallow's End"
local pluginicon = "Interface\\Icons\\INV_Misc_Bag_28_Halloween"

local questsdata = {}

local function isquestcompleted(questID)
 if questID == "12404a" or questID == "12404b" or questID == "12409a" or questID == "12409b" then
  local tmp = questID:gsub("(%a)", "")
  return IsQuestFlaggedCompleted(tonumber(tmp))
 elseif questID == "headless" then
  local _, _, completed = GetLFGDungeonRewardCapBarInfo(285)
  return completed == 1 and true or false
 else
  return IsQuestFlaggedCompleted(questID)
 end
end

local list = {
 ["Title"] = plugintitle,
 ["Icon"]  = pluginicon,
 ["Version"] = 1003,
 ["Order"] = { 
               { -- page 1
			   {DAILY}
			   },
               { -- page 2
               {"Candy Buckets "..GetMapNameByID(13),12398,28993,28994,12400,29014,12399,29018,12401,12396,28999,29001,29000,29016,29017},
			   },
			   {-- page 3
			   {"Candy Buckets "..GetMapNameByID(14),12402,28965,28955,28967,12397,28981,28982},
			   },
			   {-- page 4
			   {"Candy Buckets "..GetMapNameByID(466),12408,12407,12403,"12404a","12404b","12409a","12409b",12406},
			   },
			   {-- page 5
			   {"Candy Buckets "..GetMapNameByID(485),12941,12940,12950,13461,13462,13452,13456,13459,13472,13463,13460},
			   },
			   {-- page 6
			   {"Candy Buckets "..GetMapNameByID(862),32024,32023,32027,32029,32032,32031,32021,32034,32036,32039,32041,32037,32051,32026,32043,32044,32048,32046},
			  }
             },
 ["Overrides"] = {["isquestcompleted"] = isquestcompleted},
 MultiCharsEnabled = true,
 }

local function setup_faction_orders()
 local faction = DailyGlobalCheck.player_faction and DailyGlobalCheck.player_faction or UnitFactionGroup("player")
 
 local o = list["Order"]

 if faction == "Alliance" then
  o[1][1] = {"","headless"}
  o[1][2] = {"Requires Creepy Crawlers Decoration" ,39617}
  o[1][3] = {DAILY,39716,39719,39720,39721,11131,12133,29054,29144,29075,29371}
  -- kalimdor
  o[2][2] = {"",29006,29007,29008,12349,12350,28952,12348,12347,29010,29011,29013,29012,12345,28995,28951,12334,12331,12341,12333,12337}
  -- eastern kingdoms
  o[3][2] = {"",28988,12351,28970,28990,12343,28991,12339,28963,12332,12335,28956,12336,12286,12342,28968,28960,28961,12344,12340,28964,28954,28978,28977,28980,28979,28983,28985,}
  -- outland
  o[4][2] = {"",12359,12358,12355,12354,12353,12352,12360,12356,12357}
  -- northrend
  o[5][2] = {"",13437,13436,13473,13438,13439,12944,12945,13435,13433,13434,13448}
  -- pandaria
  o[6][2] = {"",32049,32033,32042,32052}
 elseif faction == "Horde" then
  o[1][1] = {"","headless"}
  o[1][2] = {"Requires Creepy Crawlers Decoration" ,39617}
  o[1][3] = {DAILY,39716,39719,39720,39721,11219,12155,29374,29375,29377,29376}
  -- kalimdor
  o[2][2] = {"",28989,28958,28953,12377,28992,12383,12381,12386,28998,28996,29005,29004,12362,12367,12378,29009,29003,29002,12374,12361,12366}
  -- eastern kingdoms
  o[3][2] = {"",12369,12370,12364,12365,12373,28987,28972,12363,12368,28966,12371,12376,28962,28971,12387,12380,28957,12384,28959,12382,28969,28974,28973,28976,28975,28984,28986,}
  -- outland
  o[4][2] = {"",12394,12393,12390,12388,12389,12392,12391,12395}
  -- northrend
  o[5][2] = {"",13548,13471,13466,13465,13464,12946,13947,13470,13469,13474,13468,13501,13467}
  -- pandaria
  o[6][2] = {"",32028,32050,32020,32047,32040,32022}
 end
end
 
local function show_aldor()
 local _, _, standingInfo = GetFactionInfoByID(932)
 return standingInfo == 0 or standingInfo >= 4
end
 
local function show_scryers()
 local _, _, standingInfo = GetFactionInfoByID(934)
 return standingInfo == 0 or standingInfo >= 4
end

local function GenerateQuestsData()
 local faction = DailyGlobalCheck.player_faction and DailyGlobalCheck.player_faction or UnitFactionGroup("player")

 if faction == "Alliance" then
  local elwynn = GetMapNameByID(30)
  local lunarfall = GetMapNameByID(971)
  -- Dailies
  questsdata["headless"] = {GetMapNameByID(874), select(8, GetAchievementInfo(255)), nil}
  questsdata[39617] = {lunarfall, "Arachnis","","",{[971] = {71.9,37.1}},971}-- Requires Creepy Crawlers Decoration
  questsdata[39716] = {lunarfall, "Smashing Squashlings"}
  questsdata[39719] = {lunarfall, "Mutiny on the Boneship"}
  questsdata[39720] = {lunarfall, "Foul Fertilizer"}
  questsdata[39721] = {lunarfall, "Culling the Crew"}
  questsdata[11131] = {elwynn, "Stop the Fires"} -- 12135 let-the-fires-come
  questsdata[12133] = {elwynn, "Smash the Pumpkin"} 
  questsdata[29054] = {elwynn, GetAchievementCriteriaInfo(1040,2), nil} -- stink bombs away
  questsdata[29144] = {elwynn, GetAchievementCriteriaInfo(1040,1), nil} -- clean up in stormwind
  questsdata[29075] = {elwynn, GetAchievementCriteriaInfo(1040,3), nil} -- a time to gain
  questsdata[29371] = {elwynn, GetAchievementCriteriaInfo(1040,4), nil} -- a time to lose
  --Kalimdor --Alliance
  questsdata[29006] = {nil, GetAchievementCriteriaInfo(963,21), "", "", {[607] = {39.0,11.0}},607,"Q"}--Z.SOUTHERN_BARRENS Honor's Stand
  questsdata[29007] = {nil, GetAchievementCriteriaInfo(963,22), "", "", {[607] = {65.6,46.5}},607,"Q"}--Z.SOUTHERN_BARRENS Northwatch Hold
  questsdata[29008] = {nil, GetAchievementCriteriaInfo(963,20), "", "", {[607] = {49.0,68.5}},607,"Q"}--Z.SOUTHERN_BARRENS Fort Triumph
  questsdata[12349] = {nil, GetAchievementCriteriaInfo(850,2),  "", "", {[141] = {66.6,45.3}},141,"Q"}--Z.DUSTWALLOW_MARSH Theramore Isle (not part of meta achievement)
  questsdata[12350] = {nil, GetAchievementCriteriaInfo(963,2),  "", "", {[121] = {46.3,45.2}},121,"Q"}--Z.FERALAS Feathermoon Stronghold
  questsdata[28952] = {nil, GetAchievementCriteriaInfo(963,19), "", "", {[121] = {51.1,17.8}},121,"Q"}--Z.FERALAS Dreamer's Rest
  questsdata[12348] = {nil, GetAchievementCriteriaInfo(963,12), "", "", {[101] = {66.3,6.6}},101,"Q"}--Z.DESOLACE Nijel's Point
  questsdata[12347] = {nil, GetAchievementCriteriaInfo(847,10), "", "", {[81] = {40.6,17.7}},81,"Q"}--Z.STONETALON_MOUNTAINS Stonetalon Peak (not part of meta achievement)
  questsdata[29010] = {nil, GetAchievementCriteriaInfo(963,24), "", "", {[81] = {71.0,79.0}},81,"Q"}--Z.STONETALON_MOUNTAINS Northwatch Expedition Base Camp
  questsdata[29011] = {nil, GetAchievementCriteriaInfo(963,25), "", "", {[81] = {59.0,56.3}},81,"Q"}--Z.STONETALON_MOUNTAINS Windshear Hold
  questsdata[29013] = {nil, GetAchievementCriteriaInfo(963,23), "", "", {[81] = {31.5,60.7}},81,"Q"}--Z.STONETALON_MOUNTAINS Farwatcher's Glen
  questsdata[29012] = {nil, GetAchievementCriteriaInfo(963,13), "", "", {[81] = {39.5,32.8}},81,"Q"}--Z.STONETALON_MOUNTAINS Thal'darah Overlook
  questsdata[12345] = {nil, GetAchievementCriteriaInfo(963,15), "", "", {[43] = {37.0,49.3}},43,"Q"}--Z.ASHENVALE Astranaar	
  questsdata[28995] = {nil, GetAchievementCriteriaInfo(963,18), "", "", {[182] = {61.9,26.7}},182,"Q"}--Z.FELWOOD Talonbranch Glade
  questsdata[28951] = {nil, GetAchievementCriteriaInfo(963,11), "", "", {[42] = {50.8,18.8}},42,"Q"}--Z.DARKSHORE Lor'danel	
  questsdata[12334] = {nil, GetAchievementCriteriaInfo(963,1),  "", "", {[381] = {62.2,33.1}},381,"Q"}--Z.DARNASSUS Craftsmen's Terrace
  questsdata[12331] = {nil, GetAchievementCriteriaInfo(963,3),  "", "", {[41] = {55.4,52.3}},41,"Q"}--Z.TELDRASSIL Dolanaar	
  questsdata[12341] = {nil, GetAchievementCriteriaInfo(963,9),  "", "", {[476] = {55.7,60.0}},476,"Q"}--Z.BLOODMYST_ISLE Blood Watch
  questsdata[12333] = {nil, GetAchievementCriteriaInfo(963,14), "", "", {[464] = {48.5,49.0}},464,"Q"}--Z.AZUREMYST_ISLE Azure Watch
  questsdata[12337] = {nil, GetAchievementCriteriaInfo(963,8),  "", "", {[471] = {59.3,19.2}},471,"Q"}--Z.THE_EXODAR Seat of the Naaru
  --Eastern Kingdoms --Alliance
  questsdata[28988] = {nil, GetAchievementCriteriaInfo(966,21), "", "", {[22] = {43.4,84.4}},22,"Q"}--Z.WESTERN_PLAGUELANDS Chillwind Camp
  questsdata[12351] = {nil, GetAchievementCriteriaInfo(966,6), "", "", {[26] = {14.2,44.7}},26,"Q"}--Z.THE_HINTERLANDS Aerie Peak
  questsdata[28970] = {nil, GetAchievementCriteriaInfo(966,20), "", "", {[26] = {66.2,44.4}},26,"Q"}--Z.THE_HINTERLANDS Stormfeather Outpost
  questsdata[28990] = {nil, GetAchievementCriteriaInfo(966,23), "", "", {[40] = {26.1,26.0}},40,"Q"}--Z.WETLANDS Swiftgear Station
  questsdata[12343] = {nil, GetAchievementCriteriaInfo(966,4), "", "", {[40] = {10.8,61.0}},40,"Q"}--Z.WETLANDS Menethil Harbor
  questsdata[28991] = {nil, GetAchievementCriteriaInfo(966,22), "", "", {[40] = {58.2,39.2}},40,"Q"}--Z.WETLANDS Greenwarden's Grove
  questsdata[12339] = {nil, GetAchievementCriteriaInfo(966,3), "", "", {[35] = {35.5,48.5}},35,"Q"}--Z.LOCH_MODAN Thelsamar
  questsdata[28963] = {nil, GetAchievementCriteriaInfo(966,17), "", "", {[35] = {83.0,63.5}},35,"Q"}--Z.LOCH_MODAN Farstrider Lodge
  questsdata[12332] = {nil, GetAchievementCriteriaInfo(966,1), "", "", {[27] = {54.5,50.8}},27,"Q"}--Z.DUN_MOROGH Kharanos
  questsdata[12335] = {nil, GetAchievementCriteriaInfo(966,10), "", "", {[341] = {18.5,50.9}},341,"Q"}--Z.IRONFORGE The Commons
  questsdata[28956] = {nil, GetAchievementCriteriaInfo(966,14), "", "", {[17] = {20.9,56.3}},17,"Q"}--Z.BADLANDS Dragon's Mouth
  questsdata[12336] = {nil, GetAchievementCriteriaInfo(966,8), "", "", {[301] = {60.5,75.2}},301,"Q"}--Z.STORMWIND_CITY Trade District
  questsdata[12286] = {nil, GetAchievementCriteriaInfo(966,2), "", "", {[30] = {43.8,66.0}},30,"Q"}--Z.ELWYNN_FOREST Goldshire
  questsdata[12342] = {nil, GetAchievementCriteriaInfo(966,5), "", "", {[36] = {26.5,41.5}},36,"Q"}--Z.REDRIDGE_MOUNTAINS Lakeshire
  questsdata[28968] = {nil, GetAchievementCriteriaInfo(966,19), "", "", {[38] = {28.9,32.4}},38,"Q"}--Z.SWAMP_OF_SORROWS The Harborage
  questsdata[28960] = {nil, GetAchievementCriteriaInfo(966,15), "", "", {[19] = {60.7,14.1}},19,"Q"}--Z.BLASTED_LANDS Nethergarde Keep
  questsdata[28961] = {nil, GetAchievementCriteriaInfo(966,16), "", "", {[19] = {44.4,87.6}},19,"Q"}--Z.BLASTED_LANDS Surwich
  questsdata[12344] = {nil, GetAchievementCriteriaInfo(966,11), "", "", {[34] = {73.8,44.2}},34,"Q"}--Z.DUSKWOOD Darkshire
  questsdata[12340] = {nil, GetAchievementCriteriaInfo(966,12), "", "", {[39] = {52.9,53.7}},39,"Q"}--Z.WESTFALL Sentinel Hill
  questsdata[28964] = {nil, GetAchievementCriteriaInfo(966,18), "", "", {[37] = {53.2,67.0}},37,"Q"}--Z.NORTHERN_STRANGLETHORN Fort Livingston
  questsdata[28954] = {nil, GetAchievementCriteriaInfo(966,13), "", "", {[16] = {40.1,49.0}},16,"Q"}--Z.ARATHI_HIGHLANDS Refuge Point
  --Eastern Kingdoms --Alliance(Cataclysm)
  questsdata[28978] = {nil, GetAchievementCriteriaInfo(5837,6), "", "", {[700] = {49.6,30.4}},700,"Q"}--Z.TWILIGHT_HIGHLANDS Thundermar
  questsdata[28977] = {nil, GetAchievementCriteriaInfo(5837,3), "", "", {[700] = {60.3,58.2}},700,"Q"}--Z.TWILIGHT_HIGHLANDS Firebeard's Patrol
  questsdata[28980] = {nil, GetAchievementCriteriaInfo(5837,9), "", "", {[700] = {79.5,78.5}},700,"Q"}--Z.TWILIGHT_HIGHLANDS Highbank
  questsdata[28979] = {nil, GetAchievementCriteriaInfo(5837,14), "", "", {[700] = {43.5,57.3}},700,"Q"}--Z.TWILIGHT_HIGHLANDS Victor's Point
  questsdata[28983] = {nil, GetAchievementCriteriaInfo(5837,8), "", "", {[615] = {49.7,57.4}},615,"Q"}--Z.SHIMMERING_EXPANSE Tranquil Wash
  questsdata[28985] = {nil, GetAchievementCriteriaInfo(5837,11), "", "", {[614] = {54.7,72.1}},614,"Q"}--Z.ABYSSAL_DEPTHS Darkbreak Cove
  --Outland --Alliance
  questsdata[12359] = {nil, GetAchievementCriteriaInfo(969,2), "", "", {[475] = {61.1,68.1}},475,"Q"}--Z.BLADES_EDGE_MOUNTAINS Toshley's Station
  questsdata[12358] = {nil, GetAchievementCriteriaInfo(969,10), "", "", {[475] = {35.8,63.7}},475,"Q"}--Z.BLADES_EDGE_MOUNTAINS Sylvanaar
  questsdata[13255] = {nil, GetAchievementCriteriaInfo(969,15), "", "", {[467] = {41.9,26.2}},467,"Q"}--Z.ZANGARMARSH Orebor Harborage
  questsdata[12354] = {nil, GetAchievementCriteriaInfo(969,9), "", "", {[467] = {67.2,48.9}},467,"Q"}--Z.ZANGARMARSH Telredor
  questsdata[12353] = {nil, GetAchievementCriteriaInfo(969,7), "", "", {[465] = {23.4,36.4}},465,"Q"}--Z.HELLFIRE_PENINSULA Temple of Telhamat
  questsdata[12352] = {nil, GetAchievementCriteriaInfo(969,3), "", "", {[465] = {54.2,63.7}},465,"Q"}--Z.HELLFIRE_PENINSULA Honor Hold
  questsdata[12360] = {nil, GetAchievementCriteriaInfo(969,14), "", "", {[473] = {37.0,58.3}},473,"Q"}--Z.SHADOWMOON_VALLEY Wildhammer Stronghold
  questsdata[12356] = {nil, GetAchievementCriteriaInfo(969,1), "", "", {[478] = {56.6,53.2}},478,"Q"}--Z.TEROKKAR_FOREST Allerian Stronghold
  questsdata[12357] = {nil, GetAchievementCriteriaInfo(969,12), "", "", {[477] = {54.2,75.9}},477,"Q"}--Z.NAGRAND Telaar
  --Northrend --Alliance
  questsdata[13437] = {nil, GetAchievementCriteriaInfo(5836,2), "", "", {[486] = {57.1,18.8}},486,"Q"}--Z.BOREAN_TUNDRA Fizzcrank Airstrip
  questsdata[13436] = {nil, GetAchievementCriteriaInfo(5836,3), "", "", {[486] = {58.5,67.8}},486,"Q"}--Z.BOREAN_TUNDRA Valiance Keep
  questsdata[13473] = {nil, GetAchievementCriteriaInfo(5836,12), "", "", {[504] = {42.3,63}},504,"Q"}--Z.DALARAN_THE_SITUATION Silver Enclave
  questsdata[13438] = {nil, GetAchievementCriteriaInfo(5836,6), "", "", {[488] = {28.9,56.2}},488,"Q"}--Z.DRAGONBLIGHT Stars' Rest
  questsdata[13439] = {nil, GetAchievementCriteriaInfo(5836,4), "", "", {[488] = {77.5,51.2}},488,"Q"}--Z.DRAGONBLIGHT Wintergarde Keep
  questsdata[12944] = {nil, GetAchievementCriteriaInfo(5836,7), "", "", {[490] = {31.9,60.2}},490,"Q"}--Z.GRIZZLY_HILLS Amberpine Lodge
  questsdata[12945] = {nil, GetAchievementCriteriaInfo(5836,15), "", "", {[490] = {59.6,26.3}},490,"Q"}--Z.GRIZZLY_HILLS Westfall Brigade
  questsdata[13435] = {nil, GetAchievementCriteriaInfo(5836,5), "", "", {[491] = {60.4,15.9}},491,"Q"}--Z.HOWLING_FJORD Fort Wildervar
  questsdata[13433] = {nil, GetAchievementCriteriaInfo(5836,16), "", "", {[491] = {58.3,62.8}},491,"Q"}--Z.HOWLING_FJORD Valgarde
  questsdata[13434] = {nil, GetAchievementCriteriaInfo(5836,8), "", "", {[491] = {30.8,41.4}},491,"Q"}--Z.HOWLING_FJORD Westguard Keep
  questsdata[13448] = {nil, GetAchievementCriteriaInfo(5836,18), "", "", {[495] = {28.7,74.2}},495,"Q"}--Z.THE_STORM_PEAKS Frosthold
  --Pandaria --Alliance
  questsdata[32049] = {nil, GetAchievementCriteriaInfo(7601,1), "", "", {[806] = {44.8,84.4}},806,"Q"}--Z.THE_JADE_FOREST Paw'don Village
  questsdata[32033] = {nil, GetAchievementCriteriaInfo(7601,2), "", "", {[806] = {59.6,83.2}},806,"Q"}--Z.THE_JADE_FOREST Pearlfin Village
  questsdata[32042] = {nil, GetAchievementCriteriaInfo(7601,3), "", "", {[809] = {54.1,82.8}},809,"Q"}--Z.KUN_LAI_SUMMIT Westwind Rest
  questsdata[32052] = {nil, GetAchievementCriteriaInfo(7601,4), "", "", {[811] = {87.0,69.0}},811,"Q"}--Z.VALE_OF_ETERNAL_BLOSSOMS Shrine of Seven Stars
 elseif faction == "Horde" then
  local undercity = GetMapNameByID(382)
  local frostwall   = GetMapNameByID(976)

  -- Dailies
  questsdata["headless"] = {GetMapNameByID(874), select(8, GetAchievementInfo(255)), nil}
  questsdata[39617] = {frostwall, "Arachnis","","",{[976] = {56.8,88.9}},976}-- Requires Creepy Crawlers Decoration
  questsdata[39716] = {frostwall, "Smashing Squashlings"}
  questsdata[39719] = {frostwall, "Mutiny on the Boneship"}
  questsdata[39720] = {frostwall, "Foul Fertilizer"}
  questsdata[39721] = {frostwall, "Culling the Crew"}
  questsdata[11219] = {undercity, "Stop the Fires"} -- 12139 let-the-fires-come
  questsdata[12155] = {undercity, "Smash the Pumpkin"}
  questsdata[29374] = {undercity, GetAchievementCriteriaInfo(1041,1), nil} -- stink bombs away
  questsdata[29375] = {undercity, GetAchievementCriteriaInfo(1041,2), nil} -- clean up in undercity
  questsdata[29377] = {undercity, GetAchievementCriteriaInfo(1041,3), nil} -- a time to break
  questsdata[29376] = {undercity, GetAchievementCriteriaInfo(1041,4), nil} -- a time to build
  --Kalimdor --Horde
  questsdata[28989] = {nil, GetAchievementCriteriaInfo(965,25), "", "", {[43] = {12.9,34.1}},43,"Q"}--Z.ASHENVALE Zoram'gar Outpost
  questsdata[28958] = {nil, GetAchievementCriteriaInfo(965,18), "", "", {[43] = {38.6,42.4}},43,"Q"}--Z.ASHENVALE Hellscream's Watch
  questsdata[28953] = {nil, GetAchievementCriteriaInfo(965,16), "", "", {[43] = {50.2,67.3}},43,"Q"}--Z.ASHENVALE Silverwind Refuge
  questsdata[12377] = {nil, GetAchievementCriteriaInfo(965,14), "", "", {[43] = {73.9,60.6}},43,"Q"}--Z.ASHENVALE Splintertree Post
  questsdata[28992] = {nil, GetAchievementCriteriaInfo(965,21), "", "", {[181] = {57.0,50.3}},181,"Q"}--Z.AZSHARA Bilgewater Harbor
  questsdata[12383] = {nil, GetAchievementCriteriaInfo(965,2), "", "", {[141] = {36.8,32.4}},141,"Q"}--Z.DUSTWALLOW_MARSH Brackenwall Village
  questsdata[12381] = {nil, GetAchievementCriteriaInfo(965,11), "", "", {[101] = {24.1,68.3}},101,"Q"}--Z.DESOLACE Shadowprey Village
  questsdata[12386] = {nil, GetAchievementCriteriaInfo(965,13), "", "", {[121] = {74.8,45.1}},121,"Q"}--Z.FERALAS Camp Mojache
  questsdata[28998] = {nil, GetAchievementCriteriaInfo(965,20), "", "", {[121] = {52.0,47.6}},121,"Q"}--Z.FERALAS Stonemaul Hold
  questsdata[28996] = {nil, GetAchievementCriteriaInfo(965,19), "", "", {[121] = {41.4,15.7}},121,"Q"}--Z.FERALAS Camp Ataya
  questsdata[29005] = {nil, GetAchievementCriteriaInfo(965,23), "", "", {[607] = {40.7,69.3}},607,"Q"}--Z.SOUTHERN_BARRENS Desolation Hold
  questsdata[29004] = {nil, GetAchievementCriteriaInfo(965,28), "", "", {[607] = {39.3,20.1}},607,"Q"}--Z.SOUTHERN_BARRENS Hunter's Hill
  questsdata[12362] = {nil, GetAchievementCriteriaInfo(965,10), "", "", {[9] = {46.8,60.4}},9,"Q"}--Z.MULGORE Bloodhoof Village
  questsdata[12367] = {nil, GetAchievementCriteriaInfo(965,4), "", "", {[362] = {45.6,64.9}},362,"Q"}--Z.THUNDER_BLUFF Lower Rise
  questsdata[12378] = {nil, GetAchievementCriteriaInfo(965,3), "", "", {[81] = {50.4,63.8}},81,"Q"}--Z.STONETALON_MOUNTAINS Sun Rock Retreat
  questsdata[29009] = {nil, GetAchievementCriteriaInfo(965,24), "", "", {[81] = {66.5,64.2}},81,"Q"}--Z.STONETALON_MOUNTAINS Krom'gar Fortress
  questsdata[29003] = {nil, GetAchievementCriteriaInfo(965,22), "", "", {[11] = {62.5,16.6}},11,"Q"}--Z.NORTHERN_BARRENS Nozzlepot's Outpost
  questsdata[29002] = {nil, GetAchievementCriteriaInfo(965,17), "", "", {[11] = {56.2,40.0}},11,"Q"}--Z.NORTHERN_BARRENS Grol'dom Farm
  questsdata[12374] = {nil, GetAchievementCriteriaInfo(965,1), "", "", {[11] = {49.5,57.9}},11,"Q"}--Z.NORTHERN_BARRENS Crossroads
  questsdata[12361] = {nil, GetAchievementCriteriaInfo(965,15), "", "", {[4] = {51.6,41.6}},4,"Q"}--Z.DUROTAR Razor Hill
  questsdata[12366] = {nil, GetAchievementCriteriaInfo(965,9), "", "", {[321] = {53.6,78.7}},321,"Q"}--Z.ORGRIMMAR Valley of Strength
 --Eastern Kingdoms --Horde
  questsdata[12369] = {nil, GetAchievementCriteriaInfo(967,8), "", "", {[480] = {79.4,57.7}},480,"Q"}--Z.SILVERMOON_CITY Silvermoon City Inn
  questsdata[12370] = {nil, GetAchievementCriteriaInfo(967,3), "", "", {[480] = {67.6,72.9}},480,"Q"}--Z.SILVERMOON_CITY Wayfarer's Rest
  questsdata[12364] = {nil, GetAchievementCriteriaInfo(967,2), "", "", {[462] = {48.2,47.9}},462,"Q"}--Z.EVERSONG_WOODS Falconwing Square
  questsdata[12365] = {nil, GetAchievementCriteriaInfo(967,12), "", "", {[462] = {43.7,71.0}},462,"Q"}--Z.EVERSONG_WOODS Fairbreeze Village
  questsdata[12373] = {nil, GetAchievementCriteriaInfo(967,13), "", "", {[463] = {48.7,31.9}},463,"Q"}--Z.GHOSTLANDS	Tranquillien
  questsdata[28987] = {nil, GetAchievementCriteriaInfo(967,22), "", "", {[22] = {48.3,63.7}},22,"Q"}--Z.WESTERN_PLAGUELANDS Andorhal
  questsdata[28972] = {nil, GetAchievementCriteriaInfo(967,21), "", "", {[20] = {83.0,72.1}},20,"Q"}--Z.TIRISFAL_GLADES The Bulwark
  questsdata[12363] = {nil, GetAchievementCriteriaInfo(967,4), "", "", {[20] = {61.0,51.4}},20,"Q"}--Z.TIRISFAL_GLADES Brill
  questsdata[12368] = {nil, GetAchievementCriteriaInfo(967,5), "", "", {[382] = {67.7,37.5}},382,"Q"}--Z.UNDERCITY Trade Quarter
  questsdata[28966] = {nil, GetAchievementCriteriaInfo(967,19), "", "", {[21] = {44.3,20.3}},21,"Q"}--Z.SILVERPINE_FOREST Forsaken Rear Guard
  questsdata[12371] = {nil, GetAchievementCriteriaInfo(967,9), "", "", {[21] = {46.4,42.7}},21,"Q"}--Z.SILVERPINE_FOREST The Sepulcher
  questsdata[12376] = {nil, GetAchievementCriteriaInfo(967,7), "", "", {[24] = {57.9,47.3}},24,"Q"}--Z.HILLSBRAD_FOOTHILLS Tarren Mill
  questsdata[28962] = {nil, GetAchievementCriteriaInfo(967,16), "", "", {[24] = {60.3,63.7}},24,"Q"}--Z.HILLSBRAD_FOOTHILLS Eastpoint Tower
  questsdata[28971] = {nil, GetAchievementCriteriaInfo(967,23), "", "", {[26] = {31.8,57.9}},26,"Q"}--Z.THE_HINTERLANDS Hiri'watha Research Station
  questsdata[12387] = {nil, GetAchievementCriteriaInfo(967,14), "", "", {[26] = {78.2,81.5}},26,"Q"}--Z.THE_HINTERLANDS Revantusk Village
  questsdata[12380] = {nil, GetAchievementCriteriaInfo(967,15), "", "", {[16] = {69.0,33.3}},16,"Q"}--Z.ARATHI_HIGHLANDS Hammerfall
  questsdata[28957] = {nil, GetAchievementCriteriaInfo(967,18), "", "", {[17] = {18.4,42.7}},17,"Q"}--Z.BADLANDS New Kargath
  questsdata[12384] = {nil, GetAchievementCriteriaInfo(967,11), "", "", {[38] = {46.9,56.9}},38,"Q"}--Z.SWAMP_OF_SORROWS Stonard
  questsdata[28959] = {nil, GetAchievementCriteriaInfo(967,24), "", "", {[19] = {40.5,11.3}},19,"Q"}--Z.BLASTED_LANDS Dreadmaul Hold
  questsdata[12382] = {nil, GetAchievementCriteriaInfo(967,10), "", "", {[37] = {37.4,51.8}},37,"Q"}--Z.NORTHERN_STRANGLETHORN Grom'gol Base Camp
  questsdata[28969] = {nil, GetAchievementCriteriaInfo(967,20), "", "", {[673] = {35.0,27.2}},673,"Q"}--Z.THE_CAPE_OF_STRANGLETHORN Hardwrench Hideaway
  --Horde (Cataclysm)
  questsdata[28974] = {nil, GetAchievementCriteriaInfo(5838,6), "", "", {[700] = {45.1,76.8}},700,"Q"}--Z.TWILIGHT_HIGHLANDS Crushblow
  questsdata[28973] = {nil, GetAchievementCriteriaInfo(5838,3), "", "", {[700] = {53.4,42.8}},700,"Q"}--Z.TWILIGHT_HIGHLANDS Bloodgulch
  questsdata[28976] = {nil, GetAchievementCriteriaInfo(5838,1), "", "", {[700] = {75.4,16.5}},700,"Q"}--Z.TWILIGHT_HIGHLANDS The Krazzworks
  questsdata[28975] = {nil, GetAchievementCriteriaInfo(4866,8), "", "", {[700] = {75.3,54.9}},700,"Q"}--Z.TWILIGHT_HIGHLANDS Dragonmaw Port (not for meta)
  questsdata[28984] = {nil, GetAchievementCriteriaInfo(5838,8), "", "", {[615] = {51.4,62.3}},615,"Q"}--Z.SHIMMERING_EXPANSE Legion's Rest
  questsdata[28986] = {nil, GetAchievementCriteriaInfo(5838,11), "", "", {[614] = {51.3,60.5}},614,"Q"}--Z.ABYSSAL_DEPTHS Tenebrous Cavern		 
  --Outland --Horde
  questsdata[12394] = {nil, GetAchievementCriteriaInfo(968,8), "", "", {[475] = {76.2,60.4}},475,"Q"}--Z.BLADES_EDGE_MOUNTAINS Mok'Nathal Village
  questsdata[12393] = {nil, GetAchievementCriteriaInfo(968,2), "", "", {[475] = {53.4,55.5}},475,"Q"}--Z.BLADES_EDGE_MOUNTAINS Thunderlord Stronghold
  questsdata[12390] = {nil, GetAchievementCriteriaInfo(968,1), "", "", {[467] = {30.7,50.9}},467,"Q"}--Z.ZANGARMARSH Zabra'jin
  questsdata[12388] = {nil, GetAchievementCriteriaInfo(968,3), "", "", {[465] = {56.8,37.5}},465,"Q"}--Z.HELLFIRE_PENINSULA Thrallmar
  questsdata[12389] = {nil, GetAchievementCriteriaInfo(968,13), "", "", {[465] = {26.9,59.6}},465,"Q"}--Z.HELLFIRE_PENINSULA Falcon Watch
  questsdata[12392] = {nil, GetAchievementCriteriaInfo(968,14), "", "", {[477] = {56.7,34.6}},477,"Q"}--Z.NAGRAND Garadar
  questsdata[12391] = {nil, GetAchievementCriteriaInfo(968,7), "", "", {[478] = {48.8,45.2}},478,"Q"}--Z.TEROKKAR_FOREST Stonebreaker Hold
  questsdata[12395] = {nil, GetAchievementCriteriaInfo(968,4), "", "", {[473] = {30.3,27.8}},473,"Q"}--Z.SHADOWMOON_VALLEY Shadowmoon Village
  --Northrend  --Horde
  questsdata[13548] = {nil, GetAchievementCriteriaInfo(5835,9), "", "", {[495] = {37,49.5}},495,"Q"}--Z.THE_STORM_PEAKS Grom'arsh Crash Site
  questsdata[13471] = {nil, GetAchievementCriteriaInfo(5835,17), "", "", {[495] = {67.6,50.6}},495,"Q"}--Z.THE_STORM_PEAKS Camp Tunka'lo
  questsdata[13466] = {nil, GetAchievementCriteriaInfo(5835,3), "", "", {[491] = {79.2,30.6}},491,"Q"}--Z.HOWLING_FJORD Vengeance Landing
  questsdata[13465] = {nil, GetAchievementCriteriaInfo(5835,10), "", "", {[491] = {52.1,66.1}},491,"Q"}--Z.HOWLING_FJORD New Agamand
  questsdata[13464] = {nil, GetAchievementCriteriaInfo(5835,6), "", "", {[491] = {49.4,10.7}},491,"Q"}--Z.HOWLING_FJORD Camp Winterhoof
  questsdata[12946] = {nil, GetAchievementCriteriaInfo(5835,19), "", "", {[490] = {20.8,64.7}},490,"Q"}--Z.GRIZZLY_HILLS Conquest Hold
  questsdata[12947] = {nil, GetAchievementCriteriaInfo(5835,18), "", "", {[490] = {65.3,47}},490,"Q"}--Z.GRIZZLY_HILLS Camp Onegwah
  questsdata[13470] = {nil, GetAchievementCriteriaInfo(5835,13), "", "", {[488] = {76.8,63.2}},488,"Q"}--Z.DRAGONBLIGHT Venomspite
  questsdata[13469] = {nil, GetAchievementCriteriaInfo(5835,2), "", "", {[488] = {37.8,46.4}},488,"Q"}--Z.DRAGONBLIGHT Agmar's Hammer
  questsdata[13474] = {nil, GetAchievementCriteriaInfo(5835,4), "", "", {[504] = {66.8,29.6}},504,"Q"}--Z.DALARAN_THE_SITUATION Sunreaver's Sanctuary
  questsdata[13468] = {nil, GetAchievementCriteriaInfo(5835,20), "", "", {[486] = {41.7,54.4}},486,"Q"}--Z.BOREAN_TUNDRA Warsong Hold
  questsdata[13501] = {nil, GetAchievementCriteriaInfo(5835,22), "", "", {[486] = {49.7,9.9}},486,"Q"}--Z.BOREAN_TUNDRA Bor'gorok Outpost
  questsdata[13467] = {nil, GetAchievementCriteriaInfo(5835,1), "", "", {[486] = {76.6,37.4}},486,"Q"}--Z.BOREAN_TUNDRA Taunka'le Village
  --Pandaria --Horde
  questsdata[32028] = {nil, GetAchievementCriteriaInfo(7602,19), "", "", {[806] = {28,47.4}},806,"Q"}--Z.THE_JADE_FOREST Grookin Hill
  questsdata[32050] = {nil, GetAchievementCriteriaInfo(7602,20), "", "", {[806] = {28.4,13.2}},806,"Q"}--Z.THE_JADE_FOREST Honeydew Village
  questsdata[32020] = {nil, GetAchievementCriteriaInfo(7602,21), "", "", {[857] = {28.2,50.7}},857,"Q"}--Z.KRASARANG_WILDS Dawnchaser Retreat
  questsdata[32047] = {nil, GetAchievementCriteriaInfo(7602,24), "", "", {[857] = {61.0,25.1}},857,"Q"}--Z.KRASARANG_WILDS Thunder Cleft
  questsdata[32040] = {nil, GetAchievementCriteriaInfo(7602,22), "", "", {[809] = {62.7,80.5}},809,"Q"}--Z.KUN_LAI_SUMMIT Eastwind Rest
  questsdata[32022] = {nil, GetAchievementCriteriaInfo(7602,23), "", "", {[811] = {61.9,16.2}},811,"Q"}--Z.VALE_OF_ETERNAL_BLOSSOMS Shrine of Two Moons
 end
 
  --Kalimdor
  --Neutral (9)
  questsdata[12398] = {nil, GetAchievementCriteriaInfo(963,10), "", "", {[141] = {41.9,74.1}},141,"Q"} --Z.DUSTWALLOW_MARSH Mudsprocket
  questsdata[28993] = {nil, GetAchievementCriteriaInfo(963,16), "", "", {[101] = {56.7,50.1}},101,"Q"}--Z.DESOLACE Karnum's Glade
  questsdata[28994] = {nil, GetAchievementCriteriaInfo(963,17), "", "", {[182] = {44.7,29.0}},182,"Q"}--Z.FELWOOD Whisperwind Grove
  questsdata[12400] = {nil, GetAchievementCriteriaInfo(963,6),  "", "", {[281] = {59.8,51.1}},281,"Q"}--Z.WINTERSPRING Everlook
  questsdata[29014] = {nil, GetAchievementCriteriaInfo(963,26), "", "", {[161] = {55.7,61.0}},161,"Q"}--Z.TANARIS Bootlegger Outpost
  questsdata[12399] = {nil, GetAchievementCriteriaInfo(963,7),  "", "", {[161] = {52.6,27.1}},161,"Q"}--Z.TANARIS Gadgetzan
  questsdata[29018] = {nil, GetAchievementCriteriaInfo(963,27), "", "", {[201] = {55.3,62.1}},201,"Q"}--Z.UNGORO_CRATER Marshal's Stand
  questsdata[12401] = {nil, GetAchievementCriteriaInfo(963,5),  "", "", {[261] = {55.5,36.8}},261,"Q"}--Z.SILITHUS Cenarion Hold
  questsdata[12396] = {nil, GetAchievementCriteriaInfo(963,4),  "", "", {[11] = {67.3,74.6}},11,"Q"}--Z.NORTHERN_BARRENS Ratchet	
  --Neutral (Cataclysm) 
  questsdata[28999] = {nil, GetAchievementCriteriaInfo(5837,5),  "", "", {[606] = {63.1,24.1}},606,"Q"}--Z.MOUNT_HYJAL Nordrassil Inn
  questsdata[29001] = {nil, GetAchievementCriteriaInfo(5837,2),  "", "", {[606] = {42.7,45.7}},606,"Q"}--Z.MOUNT_HYJAL Shrine of Aviana
  questsdata[29000] = {nil, GetAchievementCriteriaInfo(5837,13), "", "", {[606] = {18.6,37.3}},606,"Q"}--Z.MOUNT_HYJAL Grove of Aessina
  questsdata[29016] = {nil, GetAchievementCriteriaInfo(5837,1),  "", "", {[720] = {26.6,7.2}},720,"Q"}--Z.ULDUM Oasis of Vir'sar
  questsdata[29017] = {nil, GetAchievementCriteriaInfo(5837,7),  "", "", {[720] = {54.7,33.0}},720,"Q"}--Z.ULDUM Ramkahen
  --Eastern Kingdoms
  --Neutral
  questsdata[12402] = {nil, GetAchievementCriteriaInfo(966,7), "", "", {[23] = {75.6,52.3}},23,"Q"}--Z.EASTERN_PLAGUELANDS Light's Hope Chapel
  questsdata[28965] = {nil, GetAchievementCriteriaInfo(966,25), "", "", {[28] = {39.5,66.1}},28,"Q"}--Z.SEARING_GORGE Iron Summit
  questsdata[28955] = {nil, GetAchievementCriteriaInfo(966,24), "", "", {[17] = {65.8,35.6}},17,"Q"}--Z.BADLANDS Fuselight
  questsdata[28967] = {nil, GetAchievementCriteriaInfo(966,26), "", "", {[38] = {71.6,14.1}},38,"Q"}--Z.SWAMP_OF_SORROWS Bogpaddle
  questsdata[12397] = {nil, GetAchievementCriteriaInfo(966,9), "", "", {[673] = {40.9,73.7}},673,"Q"}--Z.THE_CAPE_OF_STRANGLETHORN Booty Bay
  --Neutral Cataclysm
  questsdata[28981] = {nil, GetAchievementCriteriaInfo(5837,12), "", "", {[610] = {63.5,60.2}},610,"Q"}--Z.KELPTHAR_FOREST Deepmist Grotto
  questsdata[28982] = {nil, GetAchievementCriteriaInfo(5837,10), "", "", {[615] = {49.2,41.8}},615,"Q"}--Z.SHIMMERING_EXPANSE Silver Tide Hollow
  --Outland
  --Neutral
  questsdata[12408] = {nil, GetAchievementCriteriaInfo(969,6), "", "", {[479] = {43.4,36.1}},479,"Q"}--Z.NETHERSTORM Stormspire
  questsdata[12407] = {nil, GetAchievementCriteriaInfo(969,5), "", "", {[479] = {32.1,64.5}},479,"Q"}--Z.NETHERSTORM Area 52
  questsdata[12403] = {nil, GetAchievementCriteriaInfo(969,13), "", "", {[467] = {78.5,62.9}},467,"Q"}--Z.ZANGARMARSH Cenarion Refuge
  questsdata["12404a"] = {nil, GetAchievementCriteriaInfo(867,5), "", "", {[481] = {28.1,49.0}},481,"Q", nil, show_aldor}--Z.SHATTRATH_CITY Aldor Rise
  questsdata["12404b"] = {nil, GetAchievementCriteriaInfo(867,5), "", "", {[481] = {56.2,81.8}},481,"Q", nil, show_scryers}--Z.SHATTRATH_CITY Scryers Tier
  questsdata["12409a"] = {nil, GetAchievementCriteriaInfo(864,9), "", "", {[473] = {61.0,28.2}},473,"Q", nil, show_aldor}--Z.SHADOWMOON_VALLEY Altar of Sha’tar
  questsdata["12409b"] = {nil, GetAchievementCriteriaInfo(864,12), "", "", {[473] = {56.3,59.8}},473,"Q", nil, show_scryers}--Z.SHADOWMOON_VALLEY Sanctum of the Stars
  questsdata[12406] = {nil, GetAchievementCriteriaInfo(969,4), "", "", {[475] = {62.9,38.3}},475,"Q"}--Z.BLADES_EDGE_MOUNTAINS Evergrove
  --Northrend
  --Neutral
  questsdata[12941] = {nil, GetAchievementCriteriaInfo(5836,22), "", "", {[496] = {40.8,66.0}},496,"Q"}--Z.ZULDRAK The Argent Stand
  questsdata[12940] = {nil, GetAchievementCriteriaInfo(5836,19), "", "", {[496] = {59.3,57.1}},496,"Q"}--Z.ZULDRAK Zim'Torga
  questsdata[12950] = {nil, GetAchievementCriteriaInfo(5836,1), "", "", {[493] = {26.6,59.2}},493,"Q"}--Z.SHOLAZAR_BASIN Nesingwary Base Camp
  questsdata[13461] = {nil, GetAchievementCriteriaInfo(5836,17), "", "", {[495] = {41,85.8}},495,"Q"}--Z.THE_STORM_PEAKS K3
  questsdata[13462] = {nil, GetAchievementCriteriaInfo(5836,9), "", "", {[495] = {30.9,37.1}},495,"Q"}--Z.THE_STORM_PEAKS Bouldercrag's Refuge
  questsdata[13452] = {nil, GetAchievementCriteriaInfo(5836,21), "", "", {[491] = {25.4,59.8}},491,"Q"}--Z.HOWLING_FJORD Kamagua
  questsdata[13456] = {nil, GetAchievementCriteriaInfo(5836,20), "", "", {[488] = {60.1,53.4}},488,"Q"}--Z.DRAGONBLIGHT Wyrmrest Temple
  questsdata[13459] = {nil, GetAchievementCriteriaInfo(5836,14), "", "", {[488] = {48.1,74.6}},488,"Q"}--Z.DRAGONBLIGHT Moa'ki Harbor
  questsdata[13472] = {nil, GetAchievementCriteriaInfo(5836,13), "", "", {[504] = {37.8,46.4}},504,"Q"}--Z.DALARAN_THE_SITUATION The Underbelly
  questsdata[13463] = {nil, GetAchievementCriteriaInfo(5836,11), "", "", {[504] = {48.3,40.8}},504,"Q"}--Z.DALARAN_THE_SITUATION The Legerdemain Lounge
  questsdata[13460] = {nil, GetAchievementCriteriaInfo(5836,10), "", "", {[486] = {78.4,49.1}},486,"Q"}--Z.BOREAN_TUNDRA Unu'pe
  --Pandaria
  --Neutral
  questsdata[32024] = {nil, GetAchievementCriteriaInfo(7601,5), "", "", {[858] = {55.9,32.2}},858,"Q"}--Z.DREAD_WASTES Klaxxi'vess
  questsdata[32023] = {nil, GetAchievementCriteriaInfo(7601,6), "", "", {[858] = {55.2,71.2}},858,"Q"}--Z.DREAD_WASTES Soggy's Gamble
  questsdata[32027] = {nil, GetAchievementCriteriaInfo(7601,7), "", "", {[806] = {45.7,43.6}},806,"Q"}--Z.THE_JADE_FOREST Dawn's Blossom
  questsdata[32029] = {nil, GetAchievementCriteriaInfo(7601,8), "", "", {[806] = {48.0,34.6}},806,"Q"}--Z.THE_JADE_FOREST Greenstone Village
  questsdata[32032] = {nil, GetAchievementCriteriaInfo(7601,9), "", "", {[806] = {54.6,63.3}},806,"Q"}--Z.THE_JADE_FOREST Jade Temple Grounds
  questsdata[32031] = {nil, GetAchievementCriteriaInfo(7601,10), "", "", {[806] = {55.7,24.4}},806,"Q"}--Z.THE_JADE_FOREST Sri-La Village
  questsdata[32021] = {nil, GetAchievementCriteriaInfo(7601,11), "", "", {[806] = {41.6,23.1}},806,"Q"}--Z.THE_JADE_FOREST Tian Monastery
  questsdata[32034] = {nil, GetAchievementCriteriaInfo(7601,12), "", "", {[857] = {51.4,77.2}},857,"Q"}--Z.KRASARANG_WILDS Marista
  questsdata[32036] = {nil, GetAchievementCriteriaInfo(7601,13), "", "", {[857] = {75.9,6.87}},857,"Q"}--Z.KRASARANG_WILDS Zhu's Watch
  questsdata[32039] = {nil, GetAchievementCriteriaInfo(7601,14), "", "", {[809] = {72.7,92.2}},809,"Q"}--Z.KUN_LAI_SUMMIT Binan Village
  questsdata[32041] = {nil, GetAchievementCriteriaInfo(7601,16), "", "", {[809] = {64.2,61.2}},809,"Q"}--Z.KUN_LAI_SUMMIT The Grummle Bazaar
  questsdata[32037] = {nil, GetAchievementCriteriaInfo(7601,15), "", "", {[809] = {57.4,59.9}},809,"Q"}--Z.KUN_LAI_SUMMIT One Keg
  questsdata[32051] = {nil, GetAchievementCriteriaInfo(7601,17), "", "", {[809] = {62.3,29}},809,"Q"}--Z.KUN_LAI_SUMMIT Zouchin Village
  questsdata[32026] = {nil, GetAchievementCriteriaInfo(7601,18), "", "", {[873] = {55.0,72.2}},873,"Q"}--Z.THE_VEILED_STAIR Tavern in the Mists
  questsdata[32043] = {nil, GetAchievementCriteriaInfo(7601,19), "", "", {[810] = {71.1,57.8}},810,"Q"}--Z.TOWNLONG_STEPPES Longying Outpost
  questsdata[32044] = {nil, GetAchievementCriteriaInfo(7601,20), "", "", {[811] = {35.1,77.7}},811,"Q"}--Z.VALE_OF_ETERNAL_BLOSSOMS Mistfall Village
  questsdata[32048] = {nil, GetAchievementCriteriaInfo(7601,21), "", "", {[807] = {83.6,20.1}},807,"Q"}--Z.VALLEY_OF_THE_FOUR_WINDS Pang's Stead
  questsdata[32046] = {nil, GetAchievementCriteriaInfo(7601,22), "", "", {[807] = {19.8,55.7}},807,"Q"}--Z.VALLEY_OF_THE_FOUR_WINDSStoneplow
end

local function Initialize()
 DailyGlobalCheck:LoadPlugin(list, questsdata)
end

local function generateList()
 setup_faction_orders()
 GenerateQuestsData()
 DailyGlobalCheck:PushData(questsdata, isquestcompleted, plugintitle, true)
end

local questslocalizationdata = { {11131,11219}, {12133,12155} }

local eventframe = CreateFrame("FRAME") 
eventframe:RegisterEvent("VARIABLES_LOADED")
eventframe:RegisterEvent("ADDON_LOADED")
eventframe:RegisterEvent("QUEST_LOG_UPDATE")
local function eventhandler(self, event, ...)
 if (event == "ADDON_LOADED" and ... == addonName) or event == "VARIABLES_LOADED" then
  if not DailyGlobalCheck then return end
  Initialize()
  C_Timer.After(math.random(200)/100, generateList)
  if not DGCHallowsLocalizedStrings then DGCHallowsLocalizedStrings = {} end
  eventframe:UnregisterEvent("ADDON_LOADED")
  eventframe:UnregisterEvent("VARIABLES_LOADED")
 elseif event == "QUEST_LOG_UPDATE" and DailyGlobalCheck then
  if DailyGlobalCheck:LocalizeQuestNames(plugintitle, DGCHallowsLocalizedStrings, questslocalizationdata) then
   eventframe:UnregisterEvent("QUEST_LOG_UPDATE")
  end
 end
end
eventframe:SetScript("OnEvent", eventhandler)
