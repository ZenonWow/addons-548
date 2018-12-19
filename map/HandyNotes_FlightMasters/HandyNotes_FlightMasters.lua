---------------------------------------------------------
-- Addon declaration
HandyNotes_FlightMasters = LibStub("AceAddon-3.0"):NewAddon("HandyNotes_FlightMasters", "AceEvent-3.0")
local HFM = HandyNotes_FlightMasters
local Astrolabe = DongleStub("Astrolabe-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes_FlightMasters", false)
local G = {}
local GameVersion = select(4, GetBuildInfo())


---------------------------------------------------------
-- Our db upvalue and db defaults
local db
local defaults = {
	profile = {
		icon_scale         = 1.0,
		icon_alpha         = 1.0,
		show_both_factions = true,
		show_on_continent  = true,
		show_lines         = true,
		show_lines_zone    = true,
	},
}


---------------------------------------------------------
-- Localize some globals
local next = next
local GameTooltip = GameTooltip
local WorldMapTooltip = WorldMapTooltip


---------------------------------------------------------
-- Constants

local playerFaction = UnitFactionGroup("player") == "Alliance" and 1 or 2

local icons = {
	"Interface\\TaxiFrame\\UI-Taxi-Icon-Green",  -- Your faction  [1] Green
	"Interface\\TaxiFrame\\UI-Taxi-Icon-Red",    -- Enemy faction [2] Red
	"Interface\\TaxiFrame\\UI-Taxi-Icon-Yellow", -- Both factions [3] Orange
}

local colors = {
	{0, 1, 0, 1},     -- Your faction       [1] Green
	{1, 0, 0, 1},     -- Enemy faction      [2] Red
	{1, 0.5, 0, 1},   -- Both factions      [3] Orange
	{1, 1, 0, 1},     -- Special, Alliance  [4] Yellow
}
colors[5] = colors[4] -- Special, Horde     [5] Yellow
colors[6] = colors[5] -- Special, Neutral   [6] Yellow

local HFM_DataType = {
	[1] = L["Alliance FlightMaster"],
	[2] = L["Horde FlightMaster"],
	[3] = L["Neutral FlightMaster"],
	[4] = L["Druid FlightMaster"],
	[5] = L["PvP FlightMaster"],
	[6] = L["Aldor FlightMaster"],
	[7] = L["Scryer FlightMaster"],
	[8] = L["Skyguard FlightMaster"],
	[9] = L["Death Knight FlightMaster"],
}

-- Packed data in strings, which we unpack on demand. Format as follows:
-- [mapFile] = {
--      [coord] = "type|mapFile,coord,type|mapFile,coord,type" -- Flight path links
--      [coord] = "type|mapFile,coord,type|mapFile,coord,type"
-- }
local HFM_Data = {
	-- Eastern Kingdoms
	["Arathi"] = {
		[68163339] = "2|Undercity,63404850,2|HillsbradFoothills,56064608,2|Hinterlands,81708176,2|Badlands,17194001,2",
		[39884734] = "1|Hinterlands,11074615,1|Wetlands,9455958,1|Ironforge,55704770,1|LochModan,33945096,1|TwilightHighlands,28552486,1|Wetlands,49901856,1|Hinterlands,65774487,1",
		[13313482] = "2",},
	["Badlands"] = {
		[17194001] = "2|Undercity,63404850,2|Arathi,68163339,2|SearingGorge,34843088,2|BurningSteppes,54172423,2|SwampOfSorrows,47785521,2|StranglethornJungle,39015125,2|TheCapeOfStranglethorn,40607342,2",
		[21715780] = "1|BurningSteppes,72096570,1|Badlands,48993620,1|Badlands,64333502,1",
		[52405074] = "2",
		[48993620] = "1|Badlands,21715780,1|LochModan,33945096,1|Badlands,64333502,1",
		[64333502] = "3|Badlands,21715780,1|Badlands,48993620,1|LochModan,81886407,1|EasternPlaguelands,75865341,1|EasternPlaguelands,75815329,2",},
	["BlastedLands"] = {
		[61252158] = "1|BurningSteppes,72096570,1|StormwindCity,70937247,1|Duskwood,77494429,1|SwampOfSorrows,70053857,1|BlastedLands,47138935,1",
		[43711425] = "2",
		[50927288] = "2",
		[47138935] = "1|BlastedLands,61252158,1|TheCapeOfStranglethorn,41677453,1",},
	["BurningSteppes"] = {
		[54172423] = "2|SearingGorge,34843088,2|Badlands,17194001,2|SwampOfSorrows,47785521,2",
		[72096570] = "1|SearingGorge,37943086,1|StormwindCity,70937247,1|BlastedLands,61252158,1|Redridge,29425376,1|BurningSteppes,46154180,1|Badlands,21715780,1|SwampOfSorrows,72021204,1",
		[17785277] = "3|SearingGorge,41066879,3|BurningSteppes,46154180,3",
		[46154180] = "3|BurningSteppes,17785277,3|BurningSteppes,72096570,1",},
	["DunMorogh"] = {
		[75875444] = "1|DunMorogh,53805276,1|Ironforge,55704770,1",
		[53805276] = "1|DunMorogh,75875444,1|Ironforge,55704770,1",
		[75235278] = "1|DunMorogh,75941681,1",
		[75941681] = "1|DunMorogh,75235278,1",},
	["Duskwood"] = {
		[77494429] = "1|StormwindCity,70937247,1|Redridge,29425376,1|BlastedLands,61252158,1|TheCapeOfStranglethorn,41677453,1|StranglethornJungle,47871186,1|Westfall,56644944,1|Elwynn,41716464,1|Duskwood,21085644,1",
		[21085644] = "1|Duskwood,77494429,1|StranglethornJungle,47871186,1|Westfall,56644944,1",},
	["EasternPlaguelands"] = {
		[75815329] = "2|Ghostlands,45413053,2|Undercity,63404850,2|Hinterlands,81708176,2|EasternPlaguelands,83895044,5|EasternPlaguelands,10096566,2|EasternPlaguelands,61654384,2|EasternPlaguelands,52775357,2|Badlands,64333502,2",
		[75865341] = "1|Ironforge,55704770,1|WesternPlaguelands,42938506,1|Hinterlands,11074615,1|Ghostlands,74766715,1|Sunwell,48452514,1|EasternPlaguelands,83895044,4|EasternPlaguelands,10096566,1|Hinterlands,65774487,1|EasternPlaguelands,61654384,1|EasternPlaguelands,52775357,1|Badlands,64333502,1",
		[83895044] = "9|EasternPlaguelands,75865341,4|EasternPlaguelands,75815329,5",
		[18462736] = "3|WesternPlaguelands,44661847,3|EasternPlaguelands,51362131,3|EasternPlaguelands,61654384,3|EasternPlaguelands,52775357,3|EasternPlaguelands,34906789,3",
		[51362131] = "3|EasternPlaguelands,18462736,3|EasternPlaguelands,61654384,3|EasternPlaguelands,34906789,3",
		[61654384] = "3|EasternPlaguelands,18462736,3|EasternPlaguelands,51362131,3|EasternPlaguelands,52775357,3|EasternPlaguelands,75865341,1",
		[52775357] = "3|EasternPlaguelands,34906789,3|EasternPlaguelands,61654384,3|EasternPlaguelands,18462736,3|EasternPlaguelands,75865341,1",
		[34906789] = "3|EasternPlaguelands,10096566,3|EasternPlaguelands,52775357,3|EasternPlaguelands,51362131,3|EasternPlaguelands,18462736,3",
		[10096566] = "3|WesternPlaguelands,42938506,1|EasternPlaguelands,75865341,1|EasternPlaguelands,75815329,2|Tirisfal,83586994,2|Hinterlands,65774487,1|WesternPlaguelands,50505222,3|EasternPlaguelands,34906789,3",},
	["Elwynn"] = {
		[41716464] = "1|Elwynn,81836656,1|StormwindCity,70937247,1|Duskwood,77494429,1",
		[81836656] = "1|Redridge,29425376,1|Elwynn,41716464,1",},
	["EversongWoods"] = {
		[54365071] = "2|Ghostlands,45413053,2|Sunwell,48452514,2",},
	["Ghostlands"] = {
		[45413053] = "2|EversongWoods,54365071,2|EasternPlaguelands,75815329,2|Ghostlands,74766715,2",
		[74766715] = "3|EasternPlaguelands,75865341,1|Ghostlands,45413053,2|Sunwell,48452514,3",},
	["HillsbradFoothills"] = {
		[56064608] = "2|Undercity,63404850,2|Hinterlands,81708176,2|Arathi,68163339,2|Silverpine,45414249,2",
		[59626325] = "2",
		[49026621] = "2|HillsbradFoothills,29136441,2",
		[29136441] = "2|Silverpine,50876363,2|HillsbradFoothills,49026621,2",
		[58232648] = "2",},
	["Hinterlands"] = {
		[81708176] = "2|EasternPlaguelands,75815329,2|Undercity,63404850,2|HillsbradFoothills,56064608,2|Arathi,68163339,2",
		[32455808] = "2",
		[11074615] = "1|WesternPlaguelands,42938506,1|EasternPlaguelands,75865341,1|Ironforge,55704770,1|Arathi,39884734,1|Hinterlands,65774487,1",
		[65774487] = "1|Hinterlands,11074615,1|Arathi,39884734,1|EasternPlaguelands,75865341,1|EasternPlaguelands,10096566,1",},
	["Ironforge"] = {
		[55704770] = "1|EasternPlaguelands,75865341,1|WesternPlaguelands,42938506,1|Hinterlands,11074615,1|Arathi,39884734,1|Wetlands,9455958,1|LochModan,33945096,1|SearingGorge,37943086,1|StormwindCity,70937247,1|Sunwell,48452514,1|VashjirRuins,57041704,1|TwilightHighlands,28552486,1|DunMorogh,53805276,1|DunMorogh,75875444,1",},
	["LochModan"] = {
		[33945096] = "1|Arathi,39884734,1|Wetlands,9455958,1|Ironforge,55704770,1|SearingGorge,37943086,1|TwilightHighlands,81667712,1|Wetlands,56867110,1|LochModan,81886407,1|Badlands,48993620,1",
		[81886407] = "1|LochModan,33945096,1|Badlands,64333502,1",},
	["Redridge"] = {
		[29425376] = "1|StormwindCity,70937247,1|Westfall,56644944,1|Duskwood,77494429,1|BurningSteppes,72096570,1|Redridge,52925464,1|Elwynn,81836656,1|SwampOfSorrows,30783461,1",
		[52925464] = "1|Redridge,29425376,1|Redridge,77976591,1",
		[77976591] = "1|Redridge,52925464,1|SwampOfSorrows,72021204,1",
		},
	["SearingGorge"] = {
		[34843088] = "2|Badlands,17194001,2|BurningSteppes,54172423,2|SearingGorge,41066879,1",
		[37943086] = "1|Ironforge,55704770,1|BurningSteppes,72096570,1|LochModan,33945096,1|StormwindCity,70937247,1|SearingGorge,41066879,1",
		[41066879] = "3|SearingGorge,37943086,1|SearingGorge,34843088,2|BurningSteppes,17785277,3",},
	["Silverpine"] = {
		[45414249] = "2|Undercity,63404850,2|HillsbradFoothills,56064608,2|Silverpine,50876363,2|Silverpine,45932188,2",
		[50876363] = "2|Silverpine,45414249,2|HillsbradFoothills,29136441,2",
		[45932188] = "2|Silverpine,45414249,2|Silverpine,57910870,2",
		[57910870] = "2|Silverpine,45932188,2",},
	["StormwindCity"] = {
		[70937247] = "1|Ironforge,55704770,1|BurningSteppes,72096570,1|Redridge,29425376,1|BlastedLands,61252158,1|TheCapeOfStranglethorn,41677453,1|StranglethornJungle,47871186,1|Westfall,56644944,1|Duskwood,77494429,1|SearingGorge,37943086,1|Elwynn,41716464,1|Westfall,49791869,1",},
	["StranglethornJungle"] = {
		[47871186] = "1|StormwindCity,70937247,1|Westfall,56644944,1|Duskwood,77494429,1|TheCapeOfStranglethorn,41677453,1|Duskwood,21085644,1|StranglethornJungle,52646610,1",
		[52646610] = "1|StranglethornJungle,47871186,1|TheCapeOfStranglethorn,55744122,1",
		[62403924] = "2",
		[39015125] = "2|TheCapeOfStranglethorn,40607342,2|Badlands,17194001,2|SwampOfSorrows,47785521,2",},
	["Sunwell"] = {
		[48452514] = "3|Ghostlands,74766715,3|EversongWoods,54365071,2|EasternPlaguelands,75865341,1",},
	["SwampOfSorrows"] = {
		[47785521] = "2|Badlands,17194001,2|BurningSteppes,54172423,2|StranglethornJungle,39015125,2|TheCapeOfStranglethorn,40607342,2",
		[30783461] = "1|Redridge,29425376,1|SwampOfSorrows,70053857,1",
		[70053857] = "1|BlastedLands,61252158,1|SwampOfSorrows,30783461,1|SwampOfSorrows,72021204,1",
		[72021204] = "3|SwampOfSorrows,70053857,1|Redridge,77976591,1|BurningSteppes,72096570,1",},
	["TheCapeOfStranglethorn"] = {
		[40607342] = "2|StranglethornJungle,39015125,2|Badlands,17194001,2|SwampOfSorrows,47785521,2",
		[41677453] = "1|StormwindCity,70937247,1|Westfall,56644944,1|Duskwood,77494429,1|StranglethornJungle,47871186,1|BlastedLands,47138935,1|TheCapeOfStranglethorn,55744122,1",
		[55744122] = "1|TheCapeOfStranglethorn,41677453,1|StranglethornJungle,52646610,1",
		[35142939] = "2",},
	["Tirisfal"] = {
		[83586994] = "2|EasternPlaguelands,10096566,2|Undercity,63404850,2|Tirisfal,58845194,2",
		[58845194] = "2|Undercity,63404850,2|Tirisfal,83586994,2",},
	["TwilightHighlands"] = {
		[81667712] = "1|LochModan,33945096,1|TwilightHighlands,56781511,1|TwilightHighlands,60425765,1",
		[56781511] = "1|TwilightHighlands,81667712,1|TwilightHighlands,60425765,1|TwilightHighlands,48542810,1",
		[60425765] = "1|TwilightHighlands,81667712,1|TwilightHighlands,56781511,1|TwilightHighlands,43895727,1|TwilightHighlands,48542810,1",
		[43895727] = "1|TwilightHighlands,60425765,1|TwilightHighlands,48542810,1",
		[48542810] = "1|TwilightHighlands,43895727,1|TwilightHighlands,60425765,1|TwilightHighlands,56781511,1|TwilightHighlands,28552486,1",
		[28552486] = "3|TwilightHighlands,48542810,1|Arathi,39884734,1|Ironforge,55704770,1|Wetlands,56314185,1",
		[73785279] = "2",
		[54164222] = "2",
		[45767619] = "2", -- find out why 2 wind masters
		[45747604] = "2", -- find out why 2 wind masters
		[36903799] = "2",},
		-- Add Krazzworks
	["Undercity"] = {
		[63404850] = "2|Hinterlands,81708176,2|Arathi,68163339,2|Silverpine,45414249,2|EasternPlaguelands,75815329,2|HillsbradFoothills,56064608,2|Badlands,17194001,2|Tirisfal,83586994,2|VashjirRuins,61022843,2|Tirisfal,58845194,2",},
	["Vashjir"] = {
		[69487533] = "1|VashjirRuins,57041704,1",
		[64926808] = "2|VashjirRuins,61022843,2",},
	["VashjirDepths"] = {
		[56907553] = "1|VashjirRuins,57117517,1|VashjirRuins,48555742,1",
		[53875963] = "2|VashjirRuins,49476556,2|VashjirRuins,50756346,2",},
	["VashjirKelpForest"] = {
		[42426614] = "1|VashjirKelpForest,56133111,1|VashjirRuins,49524122,1",
		[49288789] = "2|VashjirKelpForest,56133111,2|VashjirRuins,49524122,1",
		[56133111] = "3|VashjirKelpForest,42426614,1|VashjirKelpForest,49288789,2|VashjirRuins,49524122,3",},
	["VashjirRuins"] = {
		[57041704] = "1|Ironforge,55704770,1|Vashjir,69487533,1",
		[57117517] = "1|VashjirDepths,56907553,1|VashjirRuins,48555742,1",
		[48555742] = "1|VashjirRuins,57117517,1|VashjirDepths,56907553,1|VashjirRuins,49524122,1",
		[61022843] = "2|Undercity,63404850,2|Vashjir,64926808,2",
		[49476556] = "2|VashjirDepths,53875963,2|VashjirRuins,50756346,2",
		[50756346] = "2|VashjirRuins,49476556,2|VashjirDepths,53875963,2|VashjirRuins,49524122,2",
		[49524122] = "3|VashjirKelpForest,56133111,3|VashjirKelpForest,42426614,1|VashjirKelpForest,49288789,2|VashjirRuins,48555742,1|VashjirRuins,50756346,2",},
	["WesternPlaguelands"] = {
		[42938506] = "1|Hinterlands,11074615,1|EasternPlaguelands,75865341,1|Ironforge,55704770,1|EasternPlaguelands,10096566,1|WesternPlaguelands,50505222,1|WesternPlaguelands,39436954,1",
		[50505222] = "3|WesternPlaguelands,42938506,1|EasternPlaguelands,10096566,3|WesternPlaguelands,44661847,3|WesternPlaguelands,39436954,1",
		[44661847] = "3|WesternPlaguelands,50505222,3|EasternPlaguelands,18462736,3",
		[39436954] = "1|WesternPlaguelands,42938506,1|WesternPlaguelands,50505222,1",
		[46526471] = "2",},
	["Westfall"] = {
		[56644944] = "1|StormwindCity,70937247,1|Redridge,29425376,1|Duskwood,77494429,1|TheCapeOfStranglethorn,41677453,1|StranglethornJungle,47871186,1|Duskwood,21085644,1|Westfall,49791869,1|Westfall,42096328,1",
		[49791869] = "1|Westfall,56644944,1|StormwindCity,70937247,1",
		[42096328] = "1|Westfall,56644944,1",},
	["Wetlands"] = {
		[9455958] = "1|Arathi,39884734,1|LochModan,33945096,1|Ironforge,55704770,1|Wetlands,38783904,1",
		[38783904] = "1|Wetlands,9455958,1|Wetlands,49901856,1|Wetlands,56314185,1",
		[49901856] = "1|Wetlands,38783904,1|Arathi,39884734,1|Wetlands,56314185,1",
		[56314185] = "1|Wetlands,49901856,1|Wetlands,38783904,1|TwilightHighlands,28552486,1|Wetlands,56867110,1",
		[56867110] = "1|Wetlands,56314185,1|LochModan,33945096,1",},
	-- Kalimdor
	["Ashenvale"] = {
		[34414799] = "1|Darkshore,51721765,1|Felwood,51538088,1|Ashenvale,85094345,1|Dustwallow,67485130,1|Barrens,69127070,1|StonetalonMountains,40123196,1|Ashenvale,18142059,1|Ashenvale,35027207,1|Darkshore,44417547,1",
		[73186159] = "2|Ashenvale,11173443,2|Felwood,51538088,2|Aszhara,14356502,2|Barrens,48705866,2|Orgrimmar,49665922,2",
		[11173443] = "2|Ashenvale,73186159,2|Felwood,51538088,2|Felwood,56360864,2|StonetalonMountains,48476193,2|Barrens,48705866,2",
		[85094345] = "1|Felwood,51538088,1|Ashenvale,34414799,1|Hyjal,71627534,1",
		[35027207] = "1|Desolace,64661054,1|SouthernBarrens,38931088,1|StonetalonMountains,70928058,1|StonetalonMountains,58815428,1|StonetalonMountains,40123196,1|Ashenvale,34414799,1",
		[18142059] = "1|Ashenvale,34414799,1|StonetalonMountains,40123196,1|Felwood,51538088,1|Darkshore,44417547,1",
		[26803600] = "1|Ashenvale,34764853,1",
		[34764853] = "1|Ashenvale,26803600,1",
		[38084222] = "2",
		[49296525] = "2",},
	["Aszhara"] = {
		[14356502] = "2|Winterspring,58844826,2|Felwood,56360864,2|Ashenvale,73186159,2|ThunderBluff,46905000,2|Barrens,48705866,2|Orgrimmar,49665922,2",
		[51497428] = "2",
		[52924985] = "2",
		[66502101] = "2",
		[66352102] = "2|Aszhara,42532456,2",
		[42532456] = "2|Aszhara,66352102,2|Aszhara,25934964,2",
		[25934964] = "2|Aszhara,42532456,2|Aszhara,29486620,2",
		[29486620] = "2|Aszhara,25934964,2|Aszhara,50707421,2",
		[50707421] = "2|Aszhara,29486620,2",},
	["AzuremystIsle"] = {
		[49724910] = "1|TheExodar,54503628,1"},
	["Barrens"] = {
		[48705866] = "2|SouthernBarrens,41247076,2|StonetalonMountains,48476193,2|Ashenvale,73186159,2|Ashenvale,11173443,2|Felwood,56360864,2|Aszhara,14356502,2|Orgrimmar,49665922,2|Barrens,69127070,2|Dustwallow,35563188,2|Tanaris,52042761,2|ThousandNeedles,79197189,2|ThunderBluff,46905000,2|Feralas,75454436,2",
		[69127070] = "3|Ashenvale,34414799,1|Dustwallow,67485130,1|Tanaris,51352949,1|Barrens,48705866,2|SouthernBarrens,66384713,1|SouthernBarrens,38931088,1",
		[41981588] = "2",
		[62311711] = "2",},
	["BloodmystIsle"] = {
		[57685387] = "1|TheExodar,54503628,1",},
	["Darkshore"] = {
		[51721765] = "1|Teldrassil,55418840,1|Moonglade,48116735,1|Felwood,60522529,1|Dustwallow,67485130,1|Ashenvale,34414799,1|Desolace,64661054,1|StonetalonMountains,40123196,1|Feralas,46774535,1|Darkshore,44417547,1",
		[44417547] = "1|Ashenvale,34414799,1|Ashenvale,18142059,1|StonetalonMountains,40123196,1|Darkshore,51721765,1|Felwood,60522529,1|Felwood,51538088,1|Felwood,44296187,1",
		[52222228] = "1|Darkshore,58572000,1",
		[58572000] = "1|Darkshore,52222228,1|Darkshore,69111887,1",
		[69111887] = "1|Darkshore,52222228,1",
		[51032274] = "1|Darkshore,46853318,1",
		[46853318] = "1|Darkshore,51032274,1",},
	["Darnassus"] = {
		[36614783] = "1|Teldrassil,55418840,1|Teldrassil,55475042,1",},
	["Desolace"] = {
		[21607413] = "2|StonetalonMountains,48476193,2|ThunderBluff,46905000,2|Feralas,75454436,2",
		[64661054] = "1|StonetalonMountains,40123196,1|Feralas,46774535,1|Darkshore,51721765,1|Dustwallow,67485130,1|Desolace,36767168,1|Desolace,57724975,1|Desolace,39072693,1|Desolace,70663289,1|StonetalonMountains,70928058,1|StonetalonMountains,58815428,1|StonetalonMountains,32026184,1|Ashenvale,35027207,1",
		[36767168] = "1|Feralas,46774535,1|Feralas,50211672,1|Desolace,64661054,1|Desolace,57724975,1|Desolace,39072693,1|StonetalonMountains,40123196,1",
		[57724975] = "3|Desolace,36767168,1|Desolace,64661054,1|Desolace,39072693,3|Desolace,70663289,3|StonetalonMountains,40123196,1",
		[39072693] = "3|Desolace,36767168,1|Desolace,57724975,3|Desolace,64661054,1|Desolace,70663289,3",
		[44272967] = "2",
		[70663289] = "3|Desolace,39072693,3|Desolace,57724975,3|Desolace,64661054,1",},
	["Durotar"] = {
		[53094358] = "2",
		[55387331] = "2",},
	["Dustwallow"] = {
		[35563188] = "2|ThunderBluff,46905000,2|Orgrimmar,49665922,2|Barrens,48705866,2|Tanaris,52042761,2|Dustwallow,42827243,2",
		[67485130] = "1|Darkshore,51721765,1|Ashenvale,34414799,1|Barrens,69127070,1|Desolace,64661054,1|Feralas,77315679,1|Tanaris,51352949,1|Dustwallow,42827243,1|SouthernBarrens,66384713,1",
		[42827243] = "3|Dustwallow,67485130,1|Feralas,77315679,1|Dustwallow,35563188,2|ThousandNeedles,79197189,2|ThousandNeedles,79157195,1|SouthernBarrens,49206780,1",},
	["Felwood"] = {
		[51538088] = "3|Felwood,60522529,1|Ashenvale,34414799,1|Ashenvale,85094345,1|Felwood,56360864,2|Ashenvale,11173443,2|Ashenvale,73186159,2|Ashenvale,18142059,1|Darkshore,44417547,1|Felwood,44296187,3|Felwood,43592870,3",
		[56360864] = "2|Moonglade,32106660,2|Winterspring,58844826,2|Aszhara,14356502,2|Orgrimmar,49665922,2|Barrens,48705866,2|Ashenvale,11173443,2|Felwood,51538088,2",
		[60522529] = "1|Darkshore,51721765,1|Moonglade,48116735,1|Winterspring,60994862,1|Felwood,51538088,1|Darkshore,44417547,1|Felwood,43592870,1",
		[44296187] = "3|Felwood,51538088,3|Darkshore,44417547,1|Felwood,43592870,3",
		[43592870] = "3|Felwood,44296187,3|Felwood,51538088,3|Felwood,60522529,1",},
	["Feralas"] = {
		[46774535] = "1|Darkshore,51721765,1|Desolace,64661054,1|Feralas,77315679,1|Silithus,54403272,1|Feralas,57085395,1|Feralas,32614566,1|Feralas,50211672,1|Desolace,36767168,1",
		[75454436] = "2|Desolace,21607413,2|ThunderBluff,46905000,2|Barrens,48705866,2|Tanaris,52042761,2|ThousandNeedles,79197189,2|Silithus,52773464,2",
		[77315679] = "1|Dustwallow,67485130,1|Feralas,46774535,1|Tanaris,51352949,1|Dustwallow,42827243,1|ThousandNeedles,79157195,1|Feralas,57085395,1",
		[57085395] = "1|Feralas,46774535,1|Feralas,77315679,1",
		[45274278] = "1|Feralas,33744416,1",
		[32614566] = "1|Feralas,46774535,1",
		[50211672] = "1|Feralas,46774535,1|Desolace,36767168,1",
		[51004844] = "2",
		[41531545] = "2",},
	["Hyjal"] = {
		[62132159] = "3|Winterspring,60994862,1|Winterspring,58844826,2|Moonglade,48116735,1|Moonglade,32106660,2|Hyjal,41184259,3|Hyjal,19603638,3",
		[41184259] = "3|Hyjal,62132159,3|Hyjal,19603638,3|Hyjal,71627534,3",
		[19603638] = "3|Hyjal,62132159,3|Hyjal,41184259,3",
		[71627534] = "3|Hyjal,41184259,3|Ashenvale,85094345,1",},
	["Mulgore"] = {
		[47445863] = "2",},
	["Moonglade"] = {
		[44154523] = "4|Teldrassil,55418840,4",
		[44284587] = "4|ThunderBluff,46905000,5",
		[32106660] = "2|Felwood,56360864,2|Winterspring,58844826,2|Hyjal,62132159,2",
		[48116735] = "1|Darkshore,51721765,1|Felwood,60522529,1|Winterspring,60994862,1|Hyjal,62132159,1",},
	["Orgrimmar"] = {
		[49665922] = "2|Felwood,56360864,2|Winterspring,58844826,2|Aszhara,14356502,2|Ashenvale,73186159,2|ThunderBluff,46905000,2|Barrens,48705866,2|Dustwallow,35563188,2|Tanaris,52042761,2",},
	["Silithus"] = {
		[52773464] = "2|Feralas,75454436,2|UngoroCrater,44114028,2|UngoroCrater,55986417,2|Tanaris,52042761,2|Uldum,26610837,2",
		[54403272] = "1|Feralas,46774535,1|UngoroCrater,44114028,1|UngoroCrater,55986417,1|Tanaris,51352949,1|Uldum,26610837,1",},
	["SouthernBarrens"] = {
		[41247076] = "2|Barrens,48705866,2|ThousandNeedles,79197189,2|ThunderBluff,46905000,2",
		[49206780] = "1|Dustwallow,42827243,1|SouthernBarrens,66384713,1|SouthernBarrens,38931088,1",
		[66384713] = "1|SouthernBarrens,49206780,1|Dustwallow,67485130,1|Barrens,69127070,1|SouthernBarrens,38931088,1",
		[39782026] = "2",
		[38931088] = "1|SouthernBarrens,49206780,1|SouthernBarrens,66384713,1|Barrens,69127070,1|StonetalonMountains,70928058,1|Ashenvale,35027207,1",},
	["StonetalonMountains"] = {
		[48476193] = "2|Ashenvale,11173443,2|Barrens,48705866,2|ThunderBluff,46905000,2|Desolace,21607413,2",
		[40123196] = "1|Darkshore,51721765,1|Ashenvale,34414799,1|Desolace,64661054,1|Desolace,36767168,1|Desolace,57724975,1|StonetalonMountains,70928058,1|StonetalonMountains,58815428,1|StonetalonMountains,48645152,1|StonetalonMountains,32026184,1|Ashenvale,35027207,1|Ashenvale,18142059,1|Darkshore,44417547,1",
		[70618946] = "2",
		[66526275] = "2",
		[53874012] = "2",
		[45113087] = "2",
		[70928058] = "1|SouthernBarrens,38931088,1|Desolace,64661054,1|StonetalonMountains,58815428,1|StonetalonMountains,40123196,1|StonetalonMountains,32026184,1|Ashenvale,35027207,1",
		[58815428] = "1|Desolace,64661054,1|StonetalonMountains,70928058,1|StonetalonMountains,48645152,1|StonetalonMountains,40123196,1|StonetalonMountains,32026184,1|Ashenvale,35027207,1",
		[48645152] = "1|StonetalonMountains,58815428,1|StonetalonMountains,40123196,1|StonetalonMountains,32026184,1",
		[32026184] = "1|StonetalonMountains,70928058,1|StonetalonMountains,58815428,1|StonetalonMountains,48645152,1|Desolace,64661054,1|StonetalonMountains,40123196,1",},
	["Tanaris"] = {
		[52042761] = "2|Silithus,52773464,2|UngoroCrater,44114028,2|UngoroCrater,55986417,2|Feralas,75454436,2|ThousandNeedles,79197189,2|ThunderBluff,46905000,2|Orgrimmar,49665922,2|Barrens,48705866,2|Dustwallow,35563188,2|Tanaris,55886060,2|Tanaris,33307736,2",
		[51352949] = "1|Silithus,54403272,1|UngoroCrater,44114028,1|UngoroCrater,55986417,1|Feralas,77315679,1|Dustwallow,67485130,1|Barrens,69127070,1|Tanaris,55886060,1|Tanaris,40057754,1|ThousandNeedles,79157195,1",
		[55886060] = "3|Tanaris,51352949,1|Tanaris,52042761,2",
		[40057754] = "1|Uldum,56203360,1|Tanaris,55886060,1|Tanaris,51352949,1",
		[33307736] = "2|Uldum,56203360,2|Tanaris,55886060,2|Tanaris,52042761,2",},
	["Teldrassil"] = {
		[55418840] = "1|Darkshore,51721765,1|Moonglade,44154523,4|Darnassus,36614783,1|TheExodar,54503628,1",
		[55475042] = "1|Darnassus,36614783,1",},
	["TheExodar"] = {
		[54503628] = "1|BloodmystIsle,57685387,1|Teldrassil,55418840,1|AzuremystIsle,49724910,1",},
	["ThousandNeedles"] = {
		[79197189] = "2|Tanaris,52042761,2|Feralas,75454436,2|ThunderBluff,46905000,2|Barrens,48705866,2|SouthernBarrens,41247076,2|Dustwallow,42827243,2",
		[79157195] = "1|Tanaris,51352949,1|Dustwallow,42827243,1|Feralas,77315679,1",},
	["ThunderBluff"] = {
		[46905000] = "2|Desolace,21607413,2|StonetalonMountains,48476193,2|Aszhara,14356502,2|Orgrimmar,49665922,2|Barrens,48705866,2|SouthernBarrens,41247076,2|Dustwallow,35563188,2|Tanaris,52042761,2|ThousandNeedles,79197189,2|Feralas,75454436,2|Moonglade,44284587,5",},
	["Uldum"] = {
		[56203360] = "3|Uldum,26610837,3|Uldum,22296493,3|Tanaris,40057754,1|Tanaris,33307736,2",
		[26610837] = "3|Uldum,56203360,3|Uldum,22296493,3|Silithus,54403272,1|Silithus,52773464,2",
		[22296493] = "3|Uldum,56203360,3|Uldum,26610837,3",},
	["UngoroCrater"] = {
		[44114028] = "3|Tanaris,51352949,1|Tanaris,52042761,2|Silithus,54403272,1|Silithus,52773464,2|UngoroCrater,55986417,3",
		[55986417] = "3|Tanaris,51352949,1|Tanaris,52042761,2|Silithus,54403272,1|Silithus,52773464,2|UngoroCrater,44114028,3",},
	["Winterspring"] = {
		[58844826] = "2|Moonglade,32106660,2|Felwood,56360864,2|Aszhara,14356502,2|Orgrimmar,49665922,2|Hyjal,62132159,2",
		[60994862] = "1|Moonglade,48116735,1|Felwood,60522529,1|Hyjal,62132159,1",},
	-- Outlands
	["BladesEdgeMountains"] = {
		[37826140] = "1|Zangarmarsh,41292899,1|Zangarmarsh,67835146,1|BladesEdgeMountains,61157044,1|BladesEdgeMountains,61683962,1|Netherstorm,33746399,1|Netherstorm,45313487,1",
		[76376593] = "2|Zangarmarsh,84765511,2|BladesEdgeMountains,52055412,2|Netherstorm,33746399,2",
		[61157044] = "1|Zangarmarsh,67835146,1|BladesEdgeMountains,37826140,1|BladesEdgeMountains,61683962,1|Netherstorm,33746399,1",
		[61683962] = "3|BladesEdgeMountains,37826140,1|BladesEdgeMountains,61157044,1|Netherstorm,33746399,3|BladesEdgeMountains,52055412,2",
		[52055412] = "2|Zangarmarsh,84765511,2|Zangarmarsh,33075107,2|BladesEdgeMountains,76376593,2|BladesEdgeMountains,61683962,2|Netherstorm,45313487,2|Netherstorm,33746399,2",
		[28285210] = "8|TerokkarForest,63506582,6",},
	["Hellfire"] = {
		[56293624] = "2|Hellfire,87354813,2|Hellfire,61668119,2|Hellfire,27795997,2|TerokkarForest,49194342,2",
		[61668119] = "2|Hellfire,56293624,2",
		[78263445] = "1|Hellfire,68662823,1",
		[87365241] = "1|Hellfire,54686235,1|Hellfire,78413490,1|Hellfire,25193723,1",
		[78413490] = "1|Hellfire,54686235,1|Hellfire,87365241,1",
		[87354813] = "2|Hellfire,56293624,2|Hellfire,27795997,2",
		[54686235] = "1|TerokkarForest,59455543,1|ShattrathCity,64064111,1|Hellfire,87365241,1|Hellfire,78413490,1|Hellfire,25193723,1",
		[71416248] = "1|Hellfire,78413490,1",
		[68662823] = "1|Hellfire,78263445,1",
		[25193723] = "1|Hellfire,54686235,1|Zangarmarsh,67835146,1",
		[27795997] = "2|Hellfire,56293624,2|Zangarmarsh,84765511,2|Zangarmarsh,33075107,2|ShattrathCity,64064111,2|Nagrand,57193524,2",},
	["Nagrand"] = {
		[57193524] = "2|Zangarmarsh,33075107,2|ShattrathCity,64064111,2|Hellfire,27795997,2",
		[54177506] = "1|ShattrathCity,64064111,1|Zangarmarsh,67835146,1|TerokkarForest,59455543,1",},
	["Netherstorm"] = {
		[45313487] = "3|Netherstorm,33746399,3|Netherstorm,65206681,3|BladesEdgeMountains,37826140,1|BladesEdgeMountains,52055412,2",
		[33746399] = "3|Netherstorm,45313487,3|Netherstorm,65206681,3|BladesEdgeMountains,37826140,1|BladesEdgeMountains,61157044,1|BladesEdgeMountains,61683962,3|BladesEdgeMountains,52055412,2|BladesEdgeMountains,76376593,2",
		[65206681] = "3|Netherstorm,45313487,3|Netherstorm,33746399,3",},
	["ShadowmoonValley"] = {
		[63333039] = "6|ShadowmoonValley,37615545,4|ShadowmoonValley,30342919,5",
		[30342919] = "2|TerokkarForest,49194342,2|ShadowmoonValley,56325781,5|ShadowmoonValley,63333039,5",
		[37615545] = "1|TerokkarForest,59455543,1|ShadowmoonValley,56325781,4|ShadowmoonValley,63333039,4",
		[56325781] = "7|ShadowmoonValley,37615545,4|ShadowmoonValley,30342919,5",},
	["ShattrathCity"] = {
		[64064111] = "3|Zangarmarsh,67835146,1|Nagrand,54177506,1|TerokkarForest,59455543,1|Hellfire,54686235,1|TerokkarForest,49194342,2|Nagrand,57193524,2|Zangarmarsh,84765511,2|Zangarmarsh,33075107,2|Hellfire,27795997,2",},
	["TerokkarForest"] = {
		[49194342] = "2|ShattrathCity,64064111,2|ShadowmoonValley,30342919,2|Hellfire,56293624,2",
		[59455543] = "1|ShattrathCity,64064111,1|Hellfire,54686235,1|ShadowmoonValley,37615545,1|Nagrand,54177506,1",
		[63506582] = "8|BladesEdgeMountains,28285210,6",},
	["Zangarmarsh"] = {
		[41292899] = "1|Zangarmarsh,67835146,1|BladesEdgeMountains,37826140,1",
		[84765511] = "2|Zangarmarsh,33075107,2|ShattrathCity,64064111,2|Hellfire,27795997,2|BladesEdgeMountains,52055412,2|BladesEdgeMountains,76376593,2",
		[33075107] = "2|Zangarmarsh,84765511,2|ShattrathCity,64064111,2|Nagrand,57193524,2|Hellfire,27795997,2|BladesEdgeMountains,52055412,2",
		[67835146] = "1|Hellfire,25193723,1|ShattrathCity,64064111,1|Nagrand,54177506,1|Zangarmarsh,41292899,1|BladesEdgeMountains,37826140,1|BladesEdgeMountains,61157044,1",},
	-- Northrend
    ["IcecrownGlacier"] = {
        [87807807] = "3|IcecrownGlacier,79407236,3|Dalaran,72174581,3|IcecrownGlacier,43742437,3|TheStormPeaks,36194939,2|TheStormPeaks,29507433,1",
        [43742437] = "3|IcecrownGlacier,79407236,3|IcecrownGlacier,87807807,3|IcecrownGlacier,19334777,3|TheStormPeaks,30643631,3|IcecrownGlacier,72592261,3|LakeWintergrasp,71973095,1|LakeWintergrasp,21623495,2",
        [19334777] = "3|SholazarBasin,50136134,3|SholazarBasin,25265844,3|IcecrownGlacier,43742437,3|LakeWintergrasp,71973095,1|LakeWintergrasp,21623495,2|IcecrownGlacier,79407236,3",
        [79407236] = "3|Dalaran,72174581,3|IcecrownGlacier,43742437,3|IcecrownGlacier,87807807,3|IcecrownGlacier,72592261,3|LakeWintergrasp,71973095,1|LakeWintergrasp,21623495,2|IcecrownGlacier,19334777,3",
		[72592261] = "3|IcecrownGlacier,43742437,3|IcecrownGlacier,79407236,3|TheStormPeaks,30643631,3|Dalaran,72174581,3",
    },
    ["Dragonblight"] = {
        [76476219] = "2|HowlingFjord,25982507,2|GrizzlyHills,22006442,2|Dragonblight,48517438,2|ZulDrak,14007359,2|HowlingFjord,52006738,2|Dragonblight,60315155,2|ZulDrak,32187437,2|Dragonblight,43841694,2|Dragonblight,37514576,2",
        [48517438] = "3|HowlingFjord,24665776,3|Dragonblight,76476219,2|Dragonblight,60315155,3|Dalaran,72174581,3|BoreanTundra,78535153,3|Dragonblight,37514576,2|Dragonblight,77004978,1|Dragonblight,29185532,1",
        [60315155] = "3|Dalaran,72174581,3|Dragonblight,76476219,2|ZulDrak,14007359,3|Dragonblight,48517438,3|Dragonblight,43841694,2|Dragonblight,37514576,2|Dragonblight,77004978,1|Dragonblight,29185532,1|Dragonblight,39522591,1",
        [37514576] = "2|Dragonblight,76476219,2|Dragonblight,60315155,2|Dragonblight,48517438,2|Dragonblight,43841694,2|BoreanTundra,77753776,2|LakeWintergrasp,21623495,2",
        [43841694] = "2|Dragonblight,76476219,2|Dragonblight,60315155,2|Dalaran,72174581,2|ZulDrak,14007359,2|Dragonblight,37514576,2",
		[77004978] = "1|HowlingFjord,31264398,1|GrizzlyHills,31305911,1|ZulDrak,32187437,1|ZulDrak,14007359,1|CrystalsongForest,72168096,1|Dragonblight,60315155,1|Dragonblight,48517438,1|Dragonblight,29185532,1|Dragonblight,39522591,1",
		[29185532] = "1|Dragonblight,60315155,1|Dragonblight,77004978,1|Dragonblight,48517438,1|Dragonblight,39522591,1|BoreanTundra,78535153,1|BoreanTundra,58966829,1|BoreanTundra,56572006,1|LakeWintergrasp,71973095,1",
		[39522591] = "1|Dalaran,72174581,1|ZulDrak,14007359,1|Dragonblight,77004978,1|Dragonblight,60315155,1|Dragonblight,29185532,1|LakeWintergrasp,71973095,1",
    },
    ["SholazarBasin"] = {
        [50136134] = "3|BoreanTundra,49651104,2|SholazarBasin,25265844,3|IcecrownGlacier,19334777,3|BoreanTundra,56572006,1|Dalaran,72174581,3|LakeWintergrasp,71973095,1|LakeWintergrasp,21623495,2",
        [25265844] = "3|SholazarBasin,50136134,3|IcecrownGlacier,19334777,3|BoreanTundra,49651104,2|BoreanTundra,56572006,1",
    },
    ["GrizzlyHills"] = {
        [22006442] = "2|HowlingFjord,49561159,2|HowlingFjord,25982507,2|ZulDrak,32187437,2|Dragonblight,76476219,2|GrizzlyHills,64964693,2",
        [64964693] = "2|HowlingFjord,79042970,2|HowlingFjord,49561159,2|GrizzlyHills,22006442,2|ZulDrak,32187437,2|ZulDrak,41556442,2|ZulDrak,60045670,2",
		[59892668] = "1|HowlingFjord,60051610,1|GrizzlyHills,31305911,1|ZulDrak,41556442,1|ZulDrak,60045670,1",
		[31305911] = "1|HowlingFjord,60051610,1|HowlingFjord,31264398,1|GrizzlyHills,59892668,1|ZulDrak,32187437,1|Dragonblight,77004978,1",
    },
    ["CrystalsongForest"] = {
        [78545041] = "2|TheStormPeaks,40758454,2|Dalaran,72174581,2|ZulDrak,14007359,2",
		[72168096] = "1|TheStormPeaks,40758454,1|Dalaran,72174581,1|ZulDrak,14007359,1|Dragonblight,77004978,1",
    },
    ["BoreanTundra"] = {
        [78535153] = "3|BoreanTundra,40355139,2|Dragonblight,48517438,3|BoreanTundra,77753776,2|Dragonblight,29185532,1|BoreanTundra,58966829,1|BoreanTundra,56572006,1",
        [49651104] = "2|BoreanTundra,40355139,2|SholazarBasin,50136134,2|SholazarBasin,25265844,2|BoreanTundra,45273437,2|BoreanTundra,77753776,2",
        [77753776] = "2|BoreanTundra,40355139,2|BoreanTundra,49651104,2|BoreanTundra,78535153,2|BoreanTundra,45273437,2|Dragonblight,37514576,2|LakeWintergrasp,21623495,2",
        [40355139] = "2|BoreanTundra,49651104,2|BoreanTundra,78535153,2|BoreanTundra,45273437,2|BoreanTundra,77753776,2",
        [33133444] = "3|BoreanTundra,45273437,3",
        [45273437] = "3|BoreanTundra,33133444,3|BoreanTundra,40355139,2|BoreanTundra,49651104,2|BoreanTundra,77753776,2|BoreanTundra,58966829,1|BoreanTundra,56572006,1",
		[58966829] = "1|BoreanTundra,45273437,1|BoreanTundra,78535153,1|Dragonblight,29185532,1|BoreanTundra,56572006,1",
		[56572006] = "1|SholazarBasin,50136134,1|SholazarBasin,25265844,1|Dragonblight,29185532,1|BoreanTundra,78535153,1|BoreanTundra,58966829,1|BoreanTundra,45273437,1",
    },
    ["HowlingFjord"] = {
        [49561159] = "2|HowlingFjord,79042970,2|HowlingFjord,52006738,2|HowlingFjord,25982507,2|GrizzlyHills,22006442,2|GrizzlyHills,64964693,2",
        [24665776] = "3|Dragonblight,48517438,3|HowlingFjord,52006738,2|HowlingFjord,25982507,2|HowlingFjord,59786323,1|HowlingFjord,31264398,1",
        [25982507] = "2|HowlingFjord,49561159,2|Dragonblight,76476219,2|GrizzlyHills,22006442,2|HowlingFjord,24665776,2|HowlingFjord,52006738,2",
        [79042970] = "2|GrizzlyHills,64964693,2|HowlingFjord,49561159,2|HowlingFjord,52006738,2",
        [52006738] = "2|HowlingFjord,79042970,2|HowlingFjord,49561159,2|HowlingFjord,25982507,2|HowlingFjord,24665776,2|Dragonblight,76476219,2",
		[59786323] = "1|HowlingFjord,24665776,1|HowlingFjord,31264398,1|HowlingFjord,60051610,1",
		[31264398] = "1|HowlingFjord,59786323,1|HowlingFjord,24665776,1|HowlingFjord,60051610,1|GrizzlyHills,31305911,1|Dragonblight,77004978,1",
		[60051610] = "1|HowlingFjord,59786323,1|HowlingFjord,31264398,1|GrizzlyHills,59892668,1|GrizzlyHills,31305911,1",
    },
    ["Dalaran"] = {
        [72174581] = "3|TheStormPeaks,40758454,3|Dragonblight,43841694,2|IcecrownGlacier,79407236,3|IcecrownGlacier,87807807,3|Dragonblight,60315155,3|Dragonblight,48517438,3|ZulDrak,14007359,3|CrystalsongForest,78545041,2|Dragonblight,39522591,1|CrystalsongForest,72168096,1|SholazarBasin,50136134,3|LakeWintergrasp,71973095,1|LakeWintergrasp,21623495,2|IcecrownGlacier,72592261,3",
    },
    ["ZulDrak"] = {
        [60045670] = "3|TheStormPeaks,65405060,2|GrizzlyHills,64964693,2|ZulDrak,70462328,3|TheStormPeaks,44482819,3|ZulDrak,41556442,3|TheStormPeaks,62636092,3|GrizzlyHills,59892668,1",
        [41556442] = "3|ZulDrak,60045670,3|ZulDrak,32187437,3|ZulDrak,14007359,3|GrizzlyHills,64964693,2|GrizzlyHills,59892668,1",
        [14007359] = "3|TheStormPeaks,40758454,3|ZulDrak,41556442,3|Dalaran,72174581,3|Dragonblight,76476219,2|Dragonblight,60315155,3|ZulDrak,32187437,3|Dragonblight,43841694,2|CrystalsongForest,78545041,2|CrystalsongForest,72168096,1|Dragonblight,77004978,1|Dragonblight,39522591,1",
        [70462328] = "3|ZulDrak,60045670,3",
        [32187437] = "3|GrizzlyHills,64964693,2|Dragonblight,76476219,2|GrizzlyHills,22006442,2|ZulDrak,41556442,3|ZulDrak,14007359,3|GrizzlyHills,31305911,1|Dragonblight,77004978,1",
    },
    ["TheStormPeaks"] = {
        [44482819] = "3|TheStormPeaks,65405060,2|TheStormPeaks,36194939,2|TheStormPeaks,62636092,3|TheStormPeaks,30643631,3|ZulDrak,60045670,3|TheStormPeaks,29507433,1",
        [40758454] = "3|TheStormPeaks,65405060,2|TheStormPeaks,36194939,2|TheStormPeaks,62636092,3|Dalaran,72174581,3|ZulDrak,14007359,3|CrystalsongForest,78545041,2|TheStormPeaks,29507433,1|CrystalsongForest,72168096,1",
        [30643631] = "3|TheStormPeaks,36194939,2|IcecrownGlacier,43742437,3|TheStormPeaks,44482819,3|TheStormPeaks,29507433,1|IcecrownGlacier,72592261,3",
        [62636092] = "3|TheStormPeaks,40758454,3|TheStormPeaks,44482819,3|TheStormPeaks,65405060,2|ZulDrak,60045670,3",
        [36194939] = "2|TheStormPeaks,40758454,2|TheStormPeaks,30643631,2|TheStormPeaks,44482819,2|IcecrownGlacier,87807807,2|TheStormPeaks,65405060,2",
        [65405060] = "2|TheStormPeaks,40758454,2|TheStormPeaks,36194939,2|TheStormPeaks,62636092,2|ZulDrak,60045670,2|TheStormPeaks,44482819,2",
		[29507433] = "1|TheStormPeaks,44482819,1|TheStormPeaks,30643631,1|TheStormPeaks,40758454,1|IcecrownGlacier,87807807,1",
    },
	["LakeWintergrasp"] = {
		[71973095] = "1|SholazarBasin,50136134,1|Dragonblight,29185532,1|Dalaran,72174581,1|IcecrownGlacier,79407236,1|Dragonblight,39522591,1|IcecrownGlacier,19334777,1|IcecrownGlacier,43742437,1",
		[21623495] = "2|SholazarBasin,50136134,2|BoreanTundra,77753776,2|Dragonblight,37514576,2|Dalaran,72174581,2|IcecrownGlacier,79407236,2|IcecrownGlacier,19334777,2|IcecrownGlacier,43742437,2",
	},
}

-- To deal with map phasing on some maps
-- Changing phases will still break Astrolabe and HandyNotes
HFM_Data["Uldum_terrain1"] = HFM_Data["Uldum"]
HFM_Data["TwilightHighlands_terrain1"] = HFM_Data["TwilightHighlands"]
HFM_Data["Hyjal_terrain1"] = HFM_Data["Hyjal"]
-- No flightpaths in these zones
--HFM_Data["Gilneas_terrain1"] = HFM_Data["Gilneas"]
--HFM_Data["Gilneas_terrain2"] = HFM_Data["Gilneas"]
--HFM_Data["BattleforGilneas"] = HFM_Data["GilneasCity"]
--HFM_Data["TheLostIsles_terrain1"] = HFM_Data["TheLostIsles"]
--HFM_Data["TheLostIsles_terrain2"] = HFM_Data["TheLostIsles"]


-- This table will contain a list of every zone in Kalimdor,
-- Eastern Kingdom and Northrend for the World Map of Azeroth
local AzerothZoneList = {}
do
	local t = Astrolabe.ContinentList
	for C = 1, #t do
		if C ~= 3 then -- Skip Outlands
			for i = 1, #t[C] do
				tinsert(AzerothZoneList, t[C][i])
			end
		end
	end
end


---------------------------------------------------------
-- Line drawing helper functions

-- Function to get the intersection point of 2 lines (x1,y1)-(x2,y2) and (sx,sy)-(ex,ey)
-- If there is no intersection point, it returns (x2, y2)
local function GetIntersection(x1, y1, x2, y2, sx, sy, ex, ey)
	local dx = x2-x1
	local dy = y2-y1
	local numer = dx*(sy-y1) - dy*(sx-x1)
	local demon = dx*(sy-ey) + dy*(ex-sx)
	if demon ~= 0 and dx ~= 0 then
		local u = numer / demon
		local t = (sx + (ex-sx)*u - x1)/dx
		if u >= 0 and u <= 1 and t >= 0 and t <= 1 then
			return sx + (ex-sx)*u, sy + (ey-sy)*u --return true
		end
	end
	return x2, y2 --return false
end

-- Function to draw a line between 2 coordinates on map (M,L)
-- (x1,y1) is already translated to map (M,L)
local function drawline(M, L, x1, y1, mapFile2, coord2, color)
	color = tonumber(color)
	if color == playerFaction then -- Same faction
		color = 1
	elseif color + playerFaction == 3 then -- Different faction
		if not db.show_both_factions then return end
		color = 2
	elseif color + playerFaction == 6 then -- Different faction, but special
		if not db.show_both_factions then return end
		color = 4
	end
	local M2 = HandyNotes:GetMapFiletoMapID(mapFile2)
	local x2, y2 = HandyNotes:getXY(coord2)
	x2, y2 = Astrolabe:TranslateWorldMapPosition(M2, nil, x2, y2, M, L)
	x2, y2 = GetIntersection(x1, y1, x2, y2, 0, 0, 0, 1)
	x2, y2 = GetIntersection(x1, y1, x2, y2, 0, 0, 1, 0)
	x2, y2 = GetIntersection(x1, y1, x2, y2, 0, 1, 1, 1)
	x2, y2 = GetIntersection(x1, y1, x2, y2, 1, 0, 1, 1)
	local w, h = WorldMapButton:GetWidth(), WorldMapButton:GetHeight()
	G:DrawLine(WorldMapButton, x1*w, (1-y1)*h, x2*w, (1-y2)*h, 25, colors[color], "OVERLAY")
end

-- Function to draw all lines from the given flightmaster
local function drawlines(mapFile, coord, fpType, ...)
	if db.show_lines then
		local C, Z = GetCurrentMapContinent(), GetCurrentMapZone()
		local M, L = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
		if C <= 0 then M = C end -- For "World" and "Cosmic"
		if Z > 0 and not db.show_lines_zone then return fpType end
		local M2 = HandyNotes:GetMapFiletoMapID(mapFile)
		local x2, y2 = HandyNotes:getXY(coord)
		x2, y2 = Astrolabe:TranslateWorldMapPosition(M2, nil, x2, y2, M, L)
		for i = 1, select("#", ...) do
			drawline(M, L, x2, y2, strsplit(",", (select(i, ...))))
		end
	end
	return fpType
end


---------------------------------------------------------
-- Plugin Handlers to HandyNotes

local HFMHandler = {}

function HFMHandler:OnEnter(mapFile, coord)
	local tooltip, fpType
	if self:GetParent() == WorldMapButton then
		tooltip = WorldMapTooltip
		fpType = tonumber(drawlines(mapFile, coord, strsplit("|", HFM_Data[mapFile][coord])))
		tooltip:SetOwner(self, "ANCHOR_NONE")
		tooltip:SetPoint("BOTTOMRIGHT", WorldMapButton)
	else
		tooltip = GameTooltip
		fpType = tonumber((strsplit("|", HFM_Data[mapFile][coord])))
		-- compare X coordinate
		tooltip:SetOwner(self, self:GetCenter() > UIParent:GetCenter() and "ANCHOR_LEFT" or "ANCHOR_RIGHT")
	end
	tooltip:SetText(HFM_DataType[fpType])
	tooltip:Show()
end

function HFMHandler:OnLeave(mapFile, coord)
	if self:GetParent() == WorldMapButton then
		WorldMapTooltip:Hide()
		G:HideLines(WorldMapButton)
	else
		GameTooltip:Hide()
	end
end

do
	local emptyTbl = {}
	local tablepool = setmetatable({}, {__mode = 'k'})

	-- This is a custom iterator we use to iterate over every node in a given zone
	local function iter(t, prestate)
		if not t then return end
		local state, value = next(t, prestate)
		while state do -- Have we reached the end of this zone?
			value = tonumber((strsplit("|", value)))
			if value == playerFaction then
				-- Same faction flightpoint
				return state, nil, icons[1], db.icon_scale, db.icon_alpha
			elseif db.show_both_factions and value + playerFaction == 3 then
				-- Enemy faction flightpoint
				return state, nil, icons[2], db.icon_scale, db.icon_alpha
			elseif value >= 3 then
				-- Both factions flightpoint
				return state, nil, icons[3], db.icon_scale, db.icon_alpha
			end
			state, value = next(t, state) -- Get next data
		end
	end

	-- This is a funky custom iterator we use to iterate over every zone's nodes in a given continent
	local function iterCont(t, prestate)
		if not t then return end
		local mapID = t.C[t.Z]
		local mapFile = HandyNotes:GetMapIDtoMapFile(mapID)
		local data = HFM_Data[mapFile]
		local state, value
		while mapFile do
			if data then -- Only if there is data for this zone
				state, value = next(data, prestate)
				while state do -- Have we reached the end of this zone?
					value = tonumber((strsplit("|", value)))
					local x, y = HandyNotes:getXY(state)
					local x, y = Astrolabe:TranslateWorldMapPosition(mapID, nil, x, y, t.mapID, t.level)
					if x > 0 and x < 1 and y > 0 and y < 1 then
						local level
						if mapFile == "Orgrimmar" or mapFile == "Dalaran" then
							level = 1
						end
						if value == playerFaction then
							-- Same faction flightpoint
							return state, mapFile, icons[1], db.icon_scale, db.icon_alpha, level
						elseif db.show_both_factions and value + playerFaction == 3 then
							-- Enemy faction flightpoint
							return state, mapFile, icons[2], db.icon_scale, db.icon_alpha, level
						elseif value >= 3 then
							-- Both factions flightpoint
							return state, mapFile, icons[3], db.icon_scale, db.icon_alpha, level
						end
					end
					state, value = next(data, state) -- Get next data
				end
			end
			-- Get next zone
			t.Z = t.Z + 1
			mapID = t.C[t.Z]
			mapFile = HandyNotes:GetMapIDtoMapFile(mapID)
			data = HFM_Data[mapFile]
			prestate = nil
		end
		tablepool[t] = true
	end

	function HFMHandler:GetNodes(mapFile, minimap, dungeonLevel)
		local C, Z = HandyNotes:GetCZ(mapFile)
		local mapID = HandyNotes:GetMapFiletoMapID(mapFile)
		if not mapID then return next, emptyTbl, nil end
		if minimap then -- Return only the requested zone's data for the minimap
			return iter, HFM_Data[mapFile], nil
		elseif C and Z and C >= 0 then
			-- Not minimap, so whatever map it is, we return the entire continent of nodes
			-- C and Z can be nil if we're in a battleground
			if Z > 0 or (Z == 0 and db.show_on_continent) then
				local tbl = next(tablepool) or {}
				tablepool[tbl] = nil
				tbl.C = C == 0 and AzerothZoneList or Astrolabe.ContinentList[C]
				tbl.Z = 1
				tbl.mapID = mapID
				tbl.level = dungeonLevel
				return iterCont, tbl, nil
			end
		end
		return next, emptyTbl, nil
	end
end

do
	local clickedFlightPoint = nil
	local clickedFlightPointZone = nil
	local info = {}

	local function createWaypoint(button, mapFile, coord)
		if GameVersion < 30000 then
			coord = mapFile
			mapFile = button
		end
		local c, z = HandyNotes:GetCZ(mapFile)
		local x, y = HandyNotes:getXY(coord)
		local name = HFM_DataType[ tonumber((strsplit("|", HFM_Data[mapFile][coord]))) ]
		if TomTom then
			TomTom:AddZWaypoint(c, z, x*100, y*100, name)
		elseif Cartographer_Waypoints then
			Cartographer_Waypoints:AddWaypoint(NotePoint:new(HandyNotes:GetCZToZone(c, z), x, y, name))
		end
	end

	local function generateMenu(button, level)
		if GameVersion < 30000 then
			level = button
		end
		if (not level) then return end
		for k in pairs(info) do info[k] = nil end
		if (level == 1) then
			-- Create the title of the menu
			info.isTitle      = 1
			info.text         = L["HandyNotes - FlightMasters"]
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)

			if TomTom or Cartographer_Waypoints then
				-- Waypoint menu item
				info.disabled     = nil
				info.isTitle      = nil
				info.notCheckable = nil
				info.text = L["Create waypoint"]
				info.icon = nil
				info.func = createWaypoint
				info.arg1 = clickedFlightPointZone
				info.arg2 = clickedFlightPoint
				UIDropDownMenu_AddButton(info, level);
			end

			-- Close menu item
			info.text         = CLOSE
			info.icon         = nil
			info.func         = function() CloseDropDownMenus() end
			info.arg1         = nil
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level);
		end
	end
	local HFM_Dropdown = CreateFrame("Frame", "HandyNotes_FlightMastersDropdownMenu")
	HFM_Dropdown.displayMode = "MENU"
	HFM_Dropdown.initialize = generateMenu

	function HFMHandler:OnClick(button, down, mapFile, coord)
		if TomTom or Cartographer_Waypoints then
			if button == "RightButton" and not down then
				clickedFlightPointZone = mapFile
				clickedFlightPoint = coord
				ToggleDropDownMenu(1, nil, HFM_Dropdown, self, 0, 0)
			end
		end
	end
end

---------------------------------------------------------
-- Options table
local options = {
	type = "group",
	name = L["FlightMasters"],
	desc = L["FlightMasters"],
	get = function(info) return db[info.arg] end,
	set = function(info, v)
		db[info.arg] = v
		HFM:SendMessage("HandyNotes_NotifyUpdate", "FlightMasters")
	end,
	args = {
		desc = {
			name = L["These settings control the look and feel of the FlightMaster icons."],
			type = "description",
			order = 0,
		},
		flight_icons = {
			type = "group",
			name = L["FlightMaster Icons"],
			desc = L["FlightMaster Icons"],
			order = 20,
			inline = true,
			args = {
				icon_scale = {
					type = "range",
					name = L["Icon Scale"],
					desc = L["The scale of the icons"],
					min = 0.25, max = 2, step = 0.01,
					arg = "icon_scale",
					order = 10,
				},
				icon_alpha = {
					type = "range",
					name = L["Icon Alpha"],
					desc = L["The alpha transparency of the icons"],
					min = 0, max = 1, step = 0.01,
					arg = "icon_alpha",
					order = 20,
				},
				show_both_factions = {
					type = "toggle",
					name = L["Show both factions"],
					desc = L["Show all flightmasters instead of only those that you can use"],
					arg = "show_both_factions",
					order = 30,
				},
				show_on_continent = {
					type = "toggle",
					name = L["Show on continent maps"],
					desc = L["Show flightmasters on continent level maps as well"],
					arg = "show_on_continent",
					order = 40,
				},
			},
		},
		flight_lines = {
			type = "group",
			name = L["Flight path lines"],
			desc = L["Flight path lines"],
			order = 50,
			inline = true,
			args = {
				show_lines = {
					type = "toggle",
					name = L["Show flight path lines"],
					desc = L["Show flight path lines on the world map"],
					arg = "show_lines",
					order = 50,
				},
				show_lines_zone = {
					type = "toggle",
					name = L["Show in zones"],
					desc = L["Show flight path lines on the zone maps as well"],
					arg = "show_lines_zone",
					order = 50,
					disabled = function() return not db.show_lines end,
				},
			},
		},
	},
}


---------------------------------------------------------
-- Addon initialization, enabling and disabling

function HFM:OnInitialize()
	-- Set up our database
	self.db = LibStub("AceDB-3.0"):New("HandyNotes_FlightMastersDB", defaults)
	db = self.db.profile

	-- Initialize our database with HandyNotes
	HandyNotes:RegisterPluginDB("FlightMasters", HFMHandler, options)
end

function HFM:OnEnable()
end

function HFM:OnDisable()
	G:HideLines(WorldMapButton)
end


------------------------------------------------------------------------------------------------------
-- The following function is used with permission from Daniel Stephens <iriel@vigilance-committee.org>
-- with reference to TaxiFrame.lua in Blizzard's UI and Graph-1.0 Ace2 library (by Cryect) which I now
-- maintain after porting it to LibGraph-2.0 LibStub library -- Xinhuan
local TAXIROUTE_LINEFACTOR = 128/126; -- Multiplying factor for texture coordinates
local TAXIROUTE_LINEFACTOR_2 = TAXIROUTE_LINEFACTOR / 2; -- Half of that

-- T        - Texture
-- C        - Canvas Frame (for anchoring)
-- sx,sy    - Coordinate of start of line
-- ex,ey    - Coordinate of end of line
-- w        - Width of line
-- relPoint - Relative point on canvas to interpret coords (Default BOTTOMLEFT)
function G:DrawLine(C, sx, sy, ex, ey, w, color, layer)
	local relPoint = "BOTTOMLEFT"

	if not C.HandyNotesFM_Lines then
		C.HandyNotesFM_Lines = {}
		C.HandyNotesFM_Lines_Used = {}
	end

	local T = tremove(C.HandyNotesFM_Lines) or C:CreateTexture(nil, "ARTWORK")
	T:SetTexture("Interface\\AddOns\\HandyNotes_FlightMasters\\line")
	tinsert(C.HandyNotesFM_Lines_Used,T)

	T:SetDrawLayer(layer or "ARTWORK")

	T:SetVertexColor(color[1],color[2],color[3],color[4]);
	-- Determine dimensions and center point of line
	local dx,dy = ex - sx, ey - sy;
	local cx,cy = (sx + ex) / 2, (sy + ey) / 2;

	-- Normalize direction if necessary
	if (dx < 0) then
		dx,dy = -dx,-dy;
	end

	-- Calculate actual length of line
	local l = ((dx * dx) + (dy * dy)) ^ 0.5;

	-- Sin and Cosine of rotation, and combination (for later)
	local s,c = -dy / l, dx / l;
	local sc = s * c;

	-- Calculate bounding box size and texture coordinates
	local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy;
	if (dy >= 0) then
		Bwid = ((l * c) - (w * s)) * TAXIROUTE_LINEFACTOR_2;
		Bhgt = ((w * c) - (l * s)) * TAXIROUTE_LINEFACTOR_2;
		BLx, BLy, BRy = (w / l) * sc, s * s, (l / w) * sc;
		BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx;
		TRy = BRx;
	else
		Bwid = ((l * c) + (w * s)) * TAXIROUTE_LINEFACTOR_2;
		Bhgt = ((w * c) + (l * s)) * TAXIROUTE_LINEFACTOR_2;
		BLx, BLy, BRx = s * s, -(l / w) * sc, 1 + (w / l) * sc;
		BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy;
		TRx = TLy;
	end

	-- Thanks Blizzard for adding (-)10000 as a hard-cap and throwing errors!
	-- The cap was added in 3.1.0 and I think it was upped in 3.1.1
	--  (way less chance to get the error)
	if TLx > 10000 then TLx = 10000 elseif TLx < -10000 then TLx = -10000 end
	if TLy > 10000 then TLy = 10000 elseif TLy < -10000 then TLy = -10000 end
	if BLx > 10000 then BLx = 10000 elseif BLx < -10000 then BLx = -10000 end
	if BLy > 10000 then BLy = 10000 elseif BLy < -10000 then BLy = -10000 end
	if TRx > 10000 then TRx = 10000 elseif TRx < -10000 then TRx = -10000 end
	if TRy > 10000 then TRy = 10000 elseif TRy < -10000 then TRy = -10000 end
	if BRx > 10000 then BRx = 10000 elseif BRx < -10000 then BRx = -10000 end
	if BRy > 10000 then BRy = 10000 elseif BRy < -10000 then BRy = -10000 end

	-- Set texture coordinates and anchors
	T:ClearAllPoints();
	T:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy);
	T:SetPoint("BOTTOMLEFT", C, relPoint, cx - Bwid, cy - Bhgt);
	T:SetPoint("TOPRIGHT",   C, relPoint, cx + Bwid, cy + Bhgt);
	T:Show()
	return T
end

function G:HideLines(C)
	if C.HandyNotesFM_Lines then
		for i = #C.HandyNotesFM_Lines_Used, 1, -1 do
			C.HandyNotesFM_Lines_Used[i]:Hide()
			tinsert(C.HandyNotesFM_Lines, tremove(C.HandyNotesFM_Lines_Used))
		end
	end
end
