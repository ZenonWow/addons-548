--local addon = LibStub("AceAddon-3.0"):GetAddon("Broker_MountQ");
local MountQData = {};

-- Mount Categories
local AQUATIC_TEXT, AQUATIC = "Aquatic"
local HORSE_TEXT, HORSE = "Horses"
local WOLF_TEXT, WOLF = "Wolves"
local FELINE_TEXT, FELINE = "Felines"
local BEAR_TEXT, BEAR = "Bears"
local RAM_TEXT, RAM = "Rams"
local TALBUK_TEXT, TALBUK = "Talbuks"
local KODO_TEXT, KODO = "Kodos"
local ELEPHANT_TEXT, ELEPHANT = "Elephants"
local RAPTOR_TEXT, RAPTOR = "Raptors"
local MECHANICAL_TEXT, MECHANICAL = "Mechanical"
local CRAFTED_TEXT, CRAFTED = "Crafted"
local WINDRIDER_TEXT, WINDRIDER = "Windriders"
local INSECT_TEXT, INSECT = "Insects"
local BIRD_TEXT, BIRD = "Birds"
local DRAGON_TEXT, DRAGON = "Dragons"
local NETHERRAY_TEXT, NETHERRAY = "Nether Rays"
local GRYPHON_TEXT, GRYPHON = "Gryphons"
local PVP_TEXT, PVP = "PvP Mounts"
local CAMEL_TEXT, CAMEL = "Camels"
local GOAT_TEXT, GOAT = "Goats"
local YAK_TEXT, YAK = "Yaks"
local BAT_TEXT, BAT = "Bats"
local DIREHORN_TEXT, DIREHORN = "Direhorns"
local SEASONAL_TEXT, SEASONAL = "Seasonal"
local SPECIAL_TEXT, SPECIAL = "Specials"
local UNKNOWN_TEXT, UNKNOWN = "Unknown"
local GENERAL_TEXT, GENERAL = "General"
local ALL_TEXT, ALL = "All"

-- Mount SubCategories
--Elephants
local MAMMOTH_TEXT, MAMMOTH = "Mammoth"
local ELEKK_TEXT, ELEKK = "Elekks"

--BIRDS
local HAWKSTRIDER_TEXT, HAWKSTRIDER = "Hawkstriders"
local HIPPOGRYPH_TEXT, HIPPOGRYPH = "Hyppogryphs"
local STRIDER_TEXT, STRIDER = "Striders"
local PHOENIX_TEXT, PHOENIX = "Phoenix"
local CRANE_TEXT, CRANE = "Cranes"

--Mechanical
local MECHANOSTRIDER_TEXT, MECHANOSTRIDER = "Mechanostriders"

--Dragons
local DRAKE_TEXT, DRAKE = "Drakes"
local NETHERWING_TEXT, NETHERWING = "Netherwings"
local PROTO_TEXT, PROTO = "Proto Drakes"
local STONEDRAKE_TEXT, STONEDRAKE = "Stone Drakes"
local DRAGONSERPENT_TEXT, DRAGONSERPENT = "Serpents"

-- Specials
local TGC_TEXT, TCG = "Trading Game Cards"

-- Aquatic
local TURTLE_TEXT, TURTLE = "Turtles"
local WATERSTRIDER_TEXT, WATERSTRIDER = "Water Striders"

-- Generic global types
MountQGeneralType = GENERAL_TEXT
MountQAllType = ALL_TEXT

local CategoryCnt = 0;
local function AddCat(text)
	if MountQData["Cat"] == nil then
		MountQData["Cat"] = {};
	end

	CategoryCnt = CategoryCnt + 1;
	MountQData["Cat"][CategoryCnt] = text;
	return CategoryCnt;
end

local function AddSubCat(text, cat)
	if MountQData["SubCat"] == nil then
		MountQData["SubCat"] = {};
		MountQData["SubCatCat"] = {};
	end

	CategoryCnt = CategoryCnt + 1;

	-- Convert SubCategory ID to text
	MountQData["SubCat"][CategoryCnt] = text;

	-- Convert Subcateogry to Category
	MountQData["SubCatCat"][CategoryCnt] = cat;
	return CategoryCnt;
end

local function MountQData_InitializeCategories()
	MountQData["Cat"] = {};
	AQUATIC = AddCat(AQUATIC_TEXT);
	HORSE = AddCat(HORSE_TEXT);
	WOLF = AddCat(WOLF_TEXT);
	FELINE = AddCat(FELINE_TEXT);
	BEAR = AddCat(BEAR_TEXT);
	RAM = AddCat(RAM_TEXT);
	TALBUK = AddCat(TALBUK_TEXT);
	KODO = AddCat(KODO_TEXT);
	ELEPHANT = AddCat(ELEPHANT_TEXT);
	RAPTOR = AddCat(RAPTOR_TEXT);
	MECHANICAL = AddCat(MECHANICAL_TEXT);
	CRAFTED = AddCat(CRAFTED_TEXT);
	WINDRIDER = AddCat(WINDRIDER_TEXT);
	INSECT = AddCat(INSECT_TEXT);
	BIRD = AddCat(BIRD_TEXT);
	DRAGON = AddCat(DRAGON_TEXT);
	NETHERRAY = AddCat(NETHERRAY_TEXT);
	GRYPHON = AddCat(GRYPHON_TEXT);
	PVP = AddCat(PVP_TEXT);
	CAMEL = AddCat(CAMEL_TEXT);
	YAK = AddCat(YAK_TEXT);
	BAT = AddCat(BAT_TEXT);
	DIREHORN = AddCat(DIREHORN_TEXT);
	GOAT = AddCat(GOAT_TEXT);
	SEASONAL = AddCat(SEASONAL_TEXT);
	SPECIAL = AddCat(SPECIAL_TEXT);
	GENERAL = AddCat(GENERAL_TEXT);
	ALL = AddCat(ALL_TEXT);
end

local function MountQData_InitializeSubCategories()
	MAMMOTH = AddSubCat(MAMMOTH_TEXT, ELEPHANT);
	ELEKK = AddSubCat(ELEKK_TEXT, ELEPHANT);
	HAWKSTRIDER = AddSubCat(HAWKSTRIDER_TEXT, BIRD);
	STRIDER = AddSubCat(STRIDER_TEXT, BIRD);
	HIPPOGRYPH = AddSubCat(HIPPOGRYPH_TEXT, BIRD);
	MECHANOSTRIDER = AddSubCat(MECHANOSTRIDER_TEXT, MECHANICAL);
	DRAKE = AddSubCat(DRAKE_TEXT, DRAGON);
	NETHERWING = AddSubCat(NETHERWING_TEXT, DRAGON);
	PROTO = AddSubCat(PROTO_TEXT, DRAGON);
	STONEDRAKE = AddSubCat(STONEDRAKE_TEXT, DRAGON);
	DRAGONSERPENT = AddSubCat(DRAGONSERPENT_TEXT, DRAGON);
	TURTLE = AddSubCat(TURTLE_TEXT, AQUATIC);
	WATERSTRIDER = AddSubCat(WATERSTRIDER_TEXT, AQUATIC);
	PHOENIX = AddSubCat(PHOENIX_TEXT, BIRD);
	CRANE = AddSubCat(CRANE_TEXT, BIRD);
	TGC = AddSubCat(TCG_TEXT, SPECIAL);
end

function MountQData_Initialize()
	MountQData_InitializeCategories();
	MountQData_InitializeSubCategories();

	MountQData["Name"] = {};

	MountQData_LoadMounts();
end

function MountQData_IsKnown(name)
	if MountQData["Name"][name] ~= nil then return 1 else return nil end;
end

function MountQData_AddKnownMount(spellid, name, icon, flags)
	MountQData["Name"][name] = { spellid, icon, flags };
end

local function MountQData_GetCategory(id)
	local text = MountQData["Cat"][id];
	
	if text == nil then
		cat = MountQData["SubCatCat"][id];
		return MountQData["Cat"][cat];
	end
	return text;
end

function MountQData_GetSpellID(pet)
	return MountQData["Name"][pet][1];
end

function MountQData_GetIcon(pet)
	return MountQData["Name"][pet][2];
end

local function MountQData_MountCategories(spellid)
	return MountQData["MountTypes"][spellid];
end

function MountQData_IsMountInCat(name, category)
	if category == ALL_TEXT then return true end;

	local spellid = MountQData["Name"][name][1];
	local types = MountQData_MountCategories(spellid);

	if types == nil then return false end;

	for i, j in pairs(types) do
		local cat = MountQData_GetCategory(j);
		if cat == category then return true end
	end
	return false;
end

function MountQData_BestGuess(SpellId, FullName)
	local Categories = {};
	local name = string.lower(FullName);


	if string.match(name, "steed") then
		table.insert(Categories, 1, HORSE);
	end
	if string.match(name, "horse") then
		table.insert(Categories, 1, HORSE);
	end
	if string.match(name, "bear") then
		table.insert(Categories, 1, BEAR);
	end
	if string.match(name, "hawkstrider") then
		table.insert(Categories, 1, HAWKSTRIDER);
	elseif string.match(name, "water strider") then
		table.insert(Categories, 1, WATERSTRIDER);
	elseif string.match(name, "strider") then
		table.insert(Categories, 1, STRIDER);
	end
	if string.match(name, "phoenix") then
		table.insert(Categories, 1, BIRD);
	end
	if string.match(name, "machine") then
		table.insert(Categories, 1, MECHANICAL);
	end
	if string.match(name, "rocket") then
		table.insert(Categories, 1, MECHANICAL);
	end
	if string.match(name, "proto-drake") then
		table.insert(Categories, 1, PROTO);
	elseif string.match(name, "netherwing") then
		table.insert(Categories, 1, NETHERWING);
	elseif string.match(name, "drake") then
		table.insert(Categories, 1, DRAKE);
	elseif string.match(name, "dragon") then
		table.insert(Categories, 1, DRAGON);
	end

	if string.match(name, "serpent") then
		table.insert(Categories, 1, DRAGONSERPENT);
	end
	if string.match(name, "gryphon") then
		table.insert(Categories, 1, GRYPHON);
	end
	if string.match(name, "nether ray") then
		table.insert(Categories, 1, NETHERRAY);
	end
	if string.match(name, "turtle") then
		table.insert(Categories, 1, AQUATIC);
	end
	if string.match(name, "camel") then
		table.insert(Categories, 1, CAMEL);
	end
	if string.match(name, "elekk") then
		table.insert(Categories, 1, ELEKK);
	end
	if string.match(name, "mammoth") then
		table.insert(Categories, 1, MAMMOTH);
	end
	if string.match(name, "saber") then
		table.insert(Categories, 1, FELINE);
	elseif string.match(name, "panther") then
		table.insert(Categories, 1, FELINE);
	elseif string.match(name, "tiger") then
		table.insert(Categories, 1, FELINE);
	end
	if string.match(name, "qiraji") then
		table.insert(Categories, 1, INSECT);
	end
	if string.match(name, "kodo") then
		table.insert(Categories, 1, KODO);
	end
	if string.match(name, "mechanostrider") then
		table.insert(Categories, 1, MECHANOSTRIDER);
	end
	if string.match(name, " ram") then
		table.insert(Categories, 1, RAM);
	end
	if string.match(name, "raptor") then
		table.insert(Categories, 1, RAPTOR);
	end
	if string.match(name, "talbuk") then
		table.insert(Categories, 1, TALBUK);
	end
	if string.match(name, "wolf") then
		table.insert(Categories, 1, WOLF);
	end
	if string.match(name, "wind rider") then
		table.insert(Categories, 1, WINDRIDER);
	end
	if string.match(name, "wind rider") then
		table.insert(Categories, 1, WINDRIDER);
	end
	if string.match(name, "crane") then
		table.insert(Categories, 1, CRANE);
	end
	if string.match(name, "yak") then
		table.insert(Categories, 1, YAK);
	end
	if string.match(name, "phoenix") then
		table.insert(Categories, 1, PHOENIX);
	end
	if string.match(name, "goat") then
		table.insert(Categories, 1, GOAT);
	end
	if #Categories > 0 then
		MountQData["MountTypes"][SpellId] = Categories;
	end
end


function MountQData_GetCatList(spellid, name) 
	local CatList = {};
	table.insert(CatList, 1, {ALL_TEXT, GENERAL_TEXT});

	local types = MountQData_MountCategories(spellid); 

	if types == nil then
		MountQData_BestGuess(spellid, name);
		--DEFAULT_CHAT_FRAME:AddMessage("Unknown Mount: "..name..", taking best guess for categories");
		types = MountQData_MountCategories(spellid); 
	end

	if types == nil then
		table.insert(CatList, 1, {UNKNOWN_TEXT, GENERAL_TEXT});
		return CatList;
	end

	for i, j in pairs(types) do
		local cat = MountQData_GetCategory(j);
		local subcat = MountQData["SubCat"][j];

		if subcat == nil then
			subcat = GENERAL_TEXT;
		end
		table.insert(CatList, 1, {cat, subcat})
	end
	return CatList;
end

function MountQData_IsAquatic(name)
	if MountQData["Name"][name] == nil then return false end;
	local mountFlags = MountQData["Name"][name][3];

	if bit.band(mountFlags, 0x08) == 0x08 and bit.band(mountFlags, 0x01) ~= 0x01 then
		return true;
	else
		return false;
	end
end

function MountQData_IsGround(name)
	if MountQData["Name"][name] == nil then return false end;
	local mountFlags = MountQData["Name"][name][3];

	if bit.band(mountFlags, 0x10) == 0x10 and bit.band(mountFlags, 0x01) == 0x01 then
		return true;
	else
		return false;
	end
end

function MountQData_IsFlier(name)
	if MountQData["Name"][name] == nil then return false end;
	local mountFlags = MountQData["Name"][name][3];

	if bit.band(mountFlags, 0x02) == 0x02 then
		return true;
	else
		return false;
	end
end

function MountQData_IsForm(spell)
	if spell == nil then return false end;
	local check = MountQData_GetSpellID(spell);
	if check == 40120 or check == 33943 or check == 87840 or check == 1066 then
		return true;
	end
	return false;
end

function MountQData_LoadMounts()
MountQData["MountTypes"] = {
	[40120]={ BIRD },	-- Swift Flight Form
	[33943]={ BIRD }, 	-- Flight Form
	[87840]={ WOLF }, 	-- Running Wild (Worgen)
	[1066]={ AQUATIC },	-- Aquatic Form

	[75207]={ AQUATIC },   -- Abyssal Seahorse
	[60025]={ DRAKE },	-- Albino Drake
	[98204]={ BEAR },	-- Amani Battle Bear
	[43688]={ BEAR },	-- Amani War Bear
	[63844]={ HYPOGRYPH },	-- Argent Hippogryph
	[67466]={ HORSE },	-- Argent Warhorse
	[96491]={ RAPTOR}, 	-- Armored Razzashi Raptor
	[40192]={ SPECIAL, PHOENIX },	-- Ashes of Al'ar
	[41514]={ NETHERWING },	-- Azure Netherwing Drake
	[59567]={ DRAKE },	-- Azure Drake
	[51412]={ BEAR },	-- Big Battle Bear
	[58983]={ BEAR },	-- Big Blizzard Bear
	[71342]={ MECHANICAL, SEASONAL },	-- Big Love Rocket
	[59650]={ DRAKE },	-- Black Drake
	[59976]={ PROTO },	-- Black Proto-Drake
	[26656]={ INSECT },	-- Black Qiraji Battle Tank
	[107842]={ DRAKE },	-- Blazing Drake
	[72808]={ DRAKE },	-- Bloodbathed Frostbrood Vanquisher
	[59568]={ DRAKE },	-- Blue Drake
	[59996]={ PROTO },	-- Blue Proto-Drake
	[25953]={INSECT },	-- Blue Qiraji Battle Tank
	[39803]={ NETHERRAY },	-- Blue Riding Nether Ray
	[43899]={ RAM, SEASONAL },	-- Brewfest Ram
	[59569]={ DRAKE },	-- Bronze Drake
	[88748]={ CAMEL },	-- Brown Riding Camel
	[75614]={ HORSE },	-- Celestial Steed
	[43927]={ HYPOGRYPH },	-- Cenarion War Hippogryph
	[41515]={ NETHERWING },	-- Cobalt Netherwing Drake
	[39315]={ TALBUK },	-- Cobalt Riding Talbuk
	[34896]={ TALBUK },	-- Cobalt War Talbuk
	[73313]={ HORSE },	-- Crimson Deathcharger
	[97560]={ BIRD },	-- Corrupted Fire Hawk
	[88990]={ PHOENIX },	-- Dark Phoenix
	[39316]={ TALBUK, PVP },	-- Dark Riding Talbuk
	[34790]={ TALBUK, PVP },	-- Dark War Talbuk
	[103081]={ BEAR },	-- Darkmoon Dancing Bear
	[64927]={ PROTO, PVP },	-- Deadly Gladiator's Frostwyrm
	[88335]={ STONEDRAKE }, -- Drake of the East Wind
	[88742]={ STONEDRAKE }, -- Drake of the North Wind
	[88744]={ STONEDRAKE }, -- Drake of the South Wind
	[88741]={ PVP, STONEDRAKE }, -- Drake of the West Wind
	[110039]={ DRAKE }, 	-- Experiment 12-B
	[84751]={ RAPTOR },	-- Fossilized Raptor
	[36702]={ HORSE },	-- Fiery Warhors
	[101542]={ BIRD },	-- Flametalon of Alyzrazor
	[97359]={ HYPOGRYPH },	-- Flameward Hippogryph
	[49379]={ KODO, SEASONAL },	-- Great Brewfest Kodo
	[61294]={ PROTO },	-- Green Proto-Drake
	[26056]={ INSECT },	-- Green Qiraji Battle Tank
	[39798]={ NETHERRAY },	-- Green Riding Nether Ray
	[88750]={ CAMEL }, 	-- Grey Riding Camel
	[48025]={ HORSE, SEASONAL },	-- Headless Horseman's Mount
	[110051]={ DRAGONSERPENT },	-- Heart of the Aspects
	[72807]={ DRAKE },	-- Icebound Frostbrood Vanquisher
	[72286]={ HORSE },	-- Invincible
	[63956]={ PROTO },	-- Ironbound Proto-Drake
	[133023]={ MECHANICAL, SPECIAL }, -- Jade Pandaren Kite 
	[107845]={ DRAKE }, 	-- Life-Binder's Handmaiden
	[65917]={ TCG },	-- Magic Rooster
	[44744]={ DRAKE, PVP },	-- Merciless Nether Drake
	[63796]={ MECHANICAL },	-- Mimiron's Head
	[93623]={ DRAKE, TCG },	-- Mottled Drake
	[69395]={ DRAKE },	-- Onyxian Drake
	[41513]={ NETHERWING },	-- Onyx Netherwing Drake
	[88718]={ STONEDRAKE },	-- Phosphorescent Stone Drake
	[60021]={ PROTO },	-- Plagued Proto-Drake
	[97493]={ BIRD },	-- Pureblood Fire Hawk
	[41516]={ NETHERWING },	-- Purple Netherwing Drake
	[39801]={ NETHERRAY },	-- Purple Riding Nether Ray
	[41252]={ BIRD },	-- Raven Lord
	[59570]={ DRAKE },	-- Red Drake
	[59961]={ PROTO },	-- Red Proto-Drake
	[26054]={INSECT },	-- Red Qiraji Battle Tank
	[39800]={ NETHERRAY },	-- Red Riding Nether Ray
	[17481]={ HORSE },	-- Rivendare's Deathcharger
	[63963]={ PROTO },	-- Rusted Proto-Drake
	[93326]={ STONEDRAKE },	-- Sandstone Drake
	[64731]={ TURTLE },	-- Sea Turtle
	[39802]={ NETHERRAY },	-- Silver Riding Nether Ray
	[39317]={TALBUK },	-- Silver Riding Talbuk
	[34898]={TALBUK },	-- Silver War Talbuk
	[42776]={TALBUK },	-- Spectral Tiger
	[98718]={ AQUATIC },	-- Subdued Seahorse
	[69820]={ KODO }, 	-- Sunwalker Kodo
	[102346]={ STRIDER }, 	-- Swift Forest Strider
	[43900]={ RAM, SEASONAL },	-- Swift Brewfest Ram
	[102350]={ STRIDER, SEASONAL }, 	-- Swift Lovebird
	[37015]={ DRAKE, PVP },	-- Swift Nether Drake
	[24242]={ RAPTOR },	-- Swift Razzashi Raptor
	[42777]={ FELINE },	-- Swift Spectral Tiger
	[102349]={ STRIDER, SEASONAL }, 	-- Swift Springstrider
	[46628]={ HAWKSTRIDER },	-- Swift White Hawkstrider
	[49322]={ SPECIAL },	-- Swift Zhevra
	[96499]={ FELINE }, 	-- Swift Zulian Panther
	[24252]={ FELINE },	-- Swift Zulian Tiger
	[88749]={ CAMEL },	-- Tan Riding Camel
	[39318]={ TALBUK },	-- Tan Riding Talbuk
	[34899]={ TALBUK },	-- Tan War Talbuk
	[60002]={ PROTO },	-- Time-Lost Proto-Drake
	[59571]={ DRAKE },	-- Twilight Drake
	[107844]={ DRAKE }, 	-- Twilight Harbinger
	[107203]={ HORSE },	-- Tyrael's Charger
	[92155]={ INSECT }, 	-- Ultramarine Qiraji Battle Tank
	[49193]={ DRAKE },	-- Vengeful Nether Drake
	[41517]={ NETHERWING },	-- Veridian Netherwing Drake
	[88746]={ STONEDRAKE },	-- Vitreous Stone Drake
	[41518]={ NETHERWING },	-- Violet Netherwing Drake
	[60024]={ PROTO },	-- Violet Proto-Drake
	[88331]={ STONEDRAKE },	-- Volcanic Stone Drake
	[54753]= {BEAR },	-- White Polar Bear Mount
	[39319]={ TALBUK },	-- White Riding Talbuk
	[34897]={ TALBUK },	-- White War Talbuk
	[98727]={ FELINE },	-- Winged Guardian
	[74918]={ TCG }, 	-- Wooly White Rhino
	[46197]={ MECHANICAL, TCG },	-- X-51 Nether-Rocket
	[46199]={ MECHANICAL, TCG },	-- X-51 Nether-Rocket X-TREME
	[75973]={ MECHANICAL, SPECIAL },	-- X-53 Touring Rocket
	[26055]={ INSECT },	-- Yellow Qiraji Battle Tank

-- alliance mounts
	[60114]={ BEAR },	-- Armored Brown Bear
	[61229]={ GRYPHON },	-- Armored Snowy Gryphon
	[22719]={ MECHANOSTRIDER, PVP },	-- Black Battlestrider
	[470]={ HORSE },	-- Black Stallion Bridle
	[60118]={ BEAR },	-- Black War Bear
	[48027]={ ELEKK, PVP },	-- Black War Elekk
	[59785]={ MAMMOTH, PVP},	-- Black War Mammoth
	[22720]={ RAM, PVP },	-- Black War Ram
	[22717]={ HORSE, PVP },	-- Black War Steed
	[22723]={ FELINE, PVP },	-- Black War Tiger
	[61996]={ SPECIAL, DRAGON },	-- Blue Dragonhawk
	[10969]={ MECHANOSTRIDER },	-- Blue Mechanostrider
	[34406]={ ELEKK },	-- Brown Elekk
	[458]={ HORSE },	-- Brown Horse
	[6899]={ RAM },	-- Brown Ram
	[6648]={ HORSE },	-- Chestnut Mare
	[63637]={ FELINE },	-- Darnassian Nightsaber
	[32239]={ GRYPHON },	-- Ebon Gryphon
	[63639]={ ELEKK },	-- Exodar Elekk
	[63638]={ MECHANOSTRIDER },	-- Gnomeregan Mechanostrider
	[32235]={ GRYPHON },	-- Golden Gryphon
	[90621]={ FELINE },	-- Golden King
	[135416]={ GRYPHON },	-- Grand Armored Gryphon
	[61465]={ MAMMOTH, PVP },	-- Grand Black War Mammoth
	[61470]={ MAMMOTH },	-- Grand Ice Mammoth
	[35710]={ ELEKK },	-- Gray Elekk
	[6777]={ RAM },	-- Gray Ram
	[35713]={ ELEKK },	-- Great Blue Elekk
	[35712]={ ELEKK },	-- Great Green Elekk
	[35714]={ ELEKK },	-- Great Purple Elekk
	[65637]={ ELEKK },	-- Great Red Elekk
	[17453]={ MECHANOSTRIDER },	-- Green Mechanostrider
	[59799]={ MAMMOTH },	-- Ice Mammoth
	[63636]={ RAM },	-- Ironforge Ram
	[60424]={ MECHANICAL, CRAFTED },	-- Mekgineer's Chopper
	[103195]={ HORSE },	-- Mountain Horse
	[130985]={ MECHANICAL, SPECIAL }, -- Pandaren Kite (Alliance)
	[472]={ HORSE },	-- Pinto
	[35711]={ ELEKK },	-- Purple Elekk
	[66090]={ HORSE },	-- Quel'dorei Steed
	[10873]={ MECHANOSTRIDER },	-- Red Mechanostrider
	[66087]={ HYPOGRYPH },	-- Silver Covenant Hippogryph
	[32240]={ GRYPHON },	-- Snowy Gryphon
	[92231]={ HORSE, PVP },	-- Spectral Steed
	[10789]={ FELINE },	-- Spotted Frostsaber
	[23510]={ RAM, PVP },	-- Stormpike Battle Charger
	[107516]={ GRYPHON, SPECIAL },	-- Spectral Gryphon
	[63232]={ HORSE },	-- Stormwind Steed
	[66847]={ FELINE },	-- Striped Dawnsaber
	[8394]={ FELINE },	-- Striped Frostsaber
	[10793]={ FELINE },	-- Striped Nightsaber
	[68057]={ HORSE },	-- Swift Alliance Steed
	[32242]={ GRYPHON },	-- Swift Blue Gryphon
	[23238]={ RAM },	-- Swift Brown Ram
	[23229]={ HORSE },	-- Swift Brown Steed
	[23221]={ FELINE },	-- Swift Frostsaber
	[23239]={ RAM },	-- Swift Gray Ram
	[65640]={ HORSE },	-- Swift Gray Steed
	[32290]={ GRYPHON },	-- Swift Green Gryphon
	[23225]={ MECHANOSTRIDER },	-- Swift Green Mechanostrider
	[23219]={ FELINE },	-- Swift Mistsaber
	[103196]={ HORSE },	-- Swift Mountain Horse
	[65638]={ FELINE },	-- Swift Moonsaber
	[23227]={ HORSE },	-- Swift Palomino
	[32292]={ GRYPHON },	-- Swift Purple Gryphon
	[32289]={ GRYPHON },	-- Swift Red Gryphon
	[23338]={ FELINE },	-- Swift Stormsaber
	[65643]={ RAM },	-- Swift Violet Ram
	[23223]={ MECHANOSTRIDER },	-- Swift White Mechanostrider
	[23240]={ RAM },	-- Swift White Ram
	[23228]={ HORSE },	-- Swift White Steed
	[23222]={ MECHANOSTRIDER },	-- Swift Yellow Mechanostrider
	[61425]={ MAMMOTH },	-- Traveler's Tundra Mammoth
	[65642]={ MECHANOSTRIDER },	-- Turbostrider
	[17454]={ MECHANOSTRIDER },	-- Unpainted Mechanostrider
	[100332]={ HORSE, PVP },	-- Vicious War Steed
	[6898]={ RAM },	-- White Ram
	[17229]={ FELINE },	-- Winterspring Frostsaber
	[59791]={ MAMMOTH },	-- Wooly Mammoth

-- horde mounts
	[61230]={ WINDRIDER },	-- Armored Blue Wind Rider
	[60116]={ BEAR },	-- Armored Brown Bear
	[35022]={ HAWKSTRIDER },	-- Black Hawkstrider
	[64977]={ HORSE },	-- Black Skeletal Horse
	[60119]={ BEAR, PVP },	-- Black War Bear
	[22718]={ KODO, PVP },	-- Black War Kodo
	[59788]={ MAMMOTH, PVP },	-- Black War Mammoth
	[22721]={ RAPTOR, PVP },	-- Black War Raptor
	[22724]={ WOLF, PVP },	-- Black War Wolf
	[64658]={ WOLF },	-- Black Wolf
	[35020]={ HAWKSTRIDER },	-- Blue Hawkstrider
	[17463]={ HORSE },	-- Blue Skeletal Horse
	[32244]={  WINDRIDER },	-- Blue Wind Rider
	[18990]={ KODO },	-- Brown Kodo
	[17464]={ HORSE },	-- Brown Skeletal Horse
	[6654]={ WOLF },	-- Brown Wolf
	[63635]={ RAPTOR },	-- Darkspear Raptor
	[6653]={ WOLF },	-- Dire Wolf
	[8395]={ RAPTOR },	-- Emerald Raptor
	[63643]={ HORSE },	-- Forsaken Warhorse
	[23509]={ WOLF, PVP },	-- Frostwolf Howler
	[87090]={ MECHANICAL }, -- Goblin Trike
	[87091]={ MECHANICAL }, -- Goblin Turbo-Trike
	[135418]={ DRAGON },	-- Grand Armored Wyvern
	[61467]={ MAMMOTH, PVP },	-- Grand Black War Mammoth
	[61469]={ MAMMOTH },	-- Grand Ice Mammoth
	[18989]={ KODO },	-- Gray Kodo
	[23249]={ KODO },	-- Great Brown Kodo
	[65641]={ KODO },	-- Great Golden Kodo
	[23248]={ KODO },	-- Great Gray Kodo
	[23247]={ KODO },	-- Great White Kodo
	[17465]={ HORSE },	-- Green Skeletal Warhorse
	[32245]={ WINDRIDER },	-- Green Wind Rider
	[59797]={ MAMMOTH },	-- Ice Mammoth
	[93644]={ INSECT },	-- Kor'kron Annihilator
	[55531]={ MECHANICAL, CRAFTED },	-- Mechano-Hog
	[66846]={ HORSE },	-- Ochre Skeletal Warhorse
	[63640]={ WOLF },	-- Orgrimmar Wolf
	[118737]={ MECHANICAL, SPECIAL }, -- Pandaren Kite (Horde)
	[35018]={ HAWKSTRIDER },	-- Purple Hawkstrider
	[23246]={ HORSE },	-- Purple Skeletal Warhorse
	[61997]={ SPECIAL, DRAGON },	-- Red Dragonhawk
	[34795]={ HAWKSTRIDER },	-- Red Hawkstrider
	[17462]={ HORSE },	-- Red Skeletal Horse
	[22722]={ HORSE, PVP },	-- Red Skeletal Warhorse
	[63642]={ HAWKSTRIDER },	-- Silvermoon Hawkstrider
	[107517]={ WINDRIDER, SPECIAL },	-- Spectral Wind Rider
	[92232]={ PVP, HORSE },	-- Spectral Wolf
	[66088]={ SPECIAL, DRAGON },	-- Sunreaver Dragonhawk
	[66091]={ HAWKSTRIDER },	-- Sunreaver Hawkstrider
	[23241]={ RAPTOR },	-- Swift Blue Raptor
	[23250]={ WOLF },	-- Swift Brown Wolf
	[65646]={ WOLF },	-- Swift Burgundy Wolf
	[23252]={ WOLF },	-- Swift Gray Wolf
	[35025]={ HAWKSTRIDER },	-- Swift Green Hawkstrider
	[32295]={ WINDRIDER },	-- Swift Green Wind Rider
	[68056]={ WOLF },	-- Swift Horde Wolf
	[23242]={ RAPTOR },	-- Swift Olive Raptor
	[23243]={ RAPTOR },	-- Swift Orange Raptor
	[33660]={ HAWKSTRIDER },	-- Swift Pink Hawkstrider
	[35027]={ HAWKSTRIDER },	-- Swift Purple Hawkstrider
	[65644]={ RAPTOR },	-- Swift Purple Raptor
	[32297]={ WINDRIDER },	-- Swift Purple Wind Rider
	[65639]={ HAWKSTRIDER },	-- Swift Red Hawkstrider
	[32246]={ WINDRIDER },	-- Swift Red Wind Rider
	[23251]={ WOLF },	-- Swift Timber Wolf
	[35028]={ HAWKSTRIDER, PVP },	-- Swift Warstrider
	[32296]={ WINDRIDER },	-- Swift Yellow Wind Rider
	[32243]={ WINDRIDER },	-- Tawny Wind Rider
	[63641]={ KODO },	-- Thunder Bluff Kodo
	[580]={ WOLF },	-- Timber Wolf
	[61447]={ MAMMOTH },	-- Traveler's Tundra Mammoth
	[10796]={ RAPTOR },	-- Turquoise Raptor
	[64659]={ RAPTOR },	-- Venomhide Ravasaur
	[100333]={ WOLF, PVP },	-- Vicious War Wolf
	[10799]={ RAPTOR },	-- Violet Raptor
	[64657]={ KODO },	-- White Kodo
	[65645]={ HORSE },	-- White Skeletal Warhorse
	[59793]={ MAMMOTH },	-- Wooly Mammoth

-- paladin mounts
	[23214]={ HORSE },	-- Alliance Charger
	[13819]={ HORSE },	-- Alliance Warhorse
	[66906]={ HORSE },	-- Argent Charger
	[73629]={ ELEKK }, 	-- Exarch's Elekk
	[73630]={ ELEKK },	-- Great Exarch's Elekk
	[69826]={ KODO },	-- Great Sunwalker Kodo
	[34767]={ HORSE },	-- Horde Charger
	[34769]={ HORSE },	-- Horde Warhorse

-- warlock mounts
	[23161]={ HORSE },	-- Dreadsteed
	[5784]={ HORSE },	-- Felsteed

-- deathknight mounts
	[48778]={ HORSE },	-- Acherus Deathcharger
	[54729]={ HORSE },	-- Winged Steed of the Ebon Blade

-- egineering mounts
	[44153]={ MECHANICAL, CRAFTED },	-- Flying Machine
	[44151]={ MECHANICAL, CRAFTED },	-- Turbo-Charged Flying Machine

-- tailoring mounts
	[61451]={ CRAFTED },	-- Flying Carpet
	[75596]={ CRAFTED },	-- Frosty Flying Carpet
	[61309]={ CRAFTED },	-- Magnificent Flying Carpet
	[61444]={ CRAFTED },	-- Swift Shadoweave (Ebonweave) Carpet
	[61442]={ CRAFTED },	-- Swift Mooncloth Carpet
	[61446]={ CRAFTED },	-- Swift Spellfire Carpet

-- trading card game
	[51412]={ BEAR, TCG },	-- Big Battle Bear
	[74856]={ TCG, HYPOGRYPH }, -- Blazing Hippogryph
	[65917]={ TCG },	-- Magic Rooster
	[30174]={ TCG, TURTLE },	-- Riding Turtle
	[97581]={ RAPTOR, TCG },	-- Savage Raptor
	[42776]={ FELINE, TCG },	-- Spectral Tiger
	[42777]={ FELINE, TCG },	-- Swift Spectral Tiger
	[46197]={ MECHANICAL, TCG },	-- X-51 Nether-Rocket
	[46199]={ MECHANICAL, TCG },	-- X-51 Nether-Rocket X-TREME 

-- Pandarian Mounts
	[127170]={ DRAGONSERPENT },	-- Astral Cloud Serpent
	[123992]={ DRAGONSERPENT },	-- Azure Cloud Serpent
	[127156]={ DRAGONSERPENT },	-- Crimson Cloud Serpent
	[127169]={ DRAGONSERPENT },	-- Heavenly Azure Cloud Serpent
	[127161]={ DRAGONSERPENT },	-- Heavenly Crimson Cloud Serpent
	[127164]={ DRAGONSERPENT },	-- Heavenly Golden Cloud Serpent
	[127165]={ DRAGONSERPENT },	-- Heavenly Jade Cloud Serpent
	[127158]={ DRAGONSERPENT },	-- Heavenly Onyx Cloud Serpent
	[123993]={ DRAGONSERPENT },	-- Golden Cloud Serpent
	[113199]={ DRAGONSERPENT },	-- Jade Cloud Serpent
	[127154]={ DRAGONSERPENT },	-- Onyx Cloud Serpent
	[129918]={ DRAGONSERPENT },	-- Thundering August Cloud Serpent
	[132036]={ DRAGONSERPENT },	-- Thundering Ruby Cloud Serpen
	[124408]={ DRAGONSERPENT },	-- Thundering Jade Cloud Serpent


	[127286]={ TURTLE },	-- Black Dragon Turtle
	[127287]={ TURTLE },	-- Blue Dragon Turtle
	[127288]={ TURTLE },	-- Brown Dragon Turtle
	[120395]={ TURTLE },	-- Green Dragon Turtle
	[127289]={ TURTLE },	-- Purple Dragon Turtle
	[127290]={ TURTLE },	-- Red Dragon Turtle
	[127295]={ TURTLE },	-- Great Black Dragon Turtle
	[127302]={ TURTLE },	-- Great Blue Dragon Turtle
	[127308]={ TURTLE },	-- Great Brown Dragon Turtle
	[127293]={ TURTLE },	-- Great Green Dragon Turtle
	[127310]={ TURTLE },	-- Great Purple Dragon Turtle
	[120822]={ TURTLE },	-- Great Red Dragon Turtle

	[127180]={ CRANE },	-- Albino Riding Crane
	[127174]={ CRANE },	-- Azure Riding Crane
	[123160]={ CRANE },	-- Crimson Riding Crane
	[127176]={ CRANE },	-- Golden Riding Crane
	[127178]={ CRANE },	-- Jungle Riding Crane
	[127177]={ CRANE },	-- Regal Riding Crane

	[127209]={ YAK },	-- Black Riding Yak
	[127220]={ YAK },	-- Blonde Riding Yak
	[127213]={ YAK },	-- Brown Riding Yak
	[122708]={ YAK },	-- Grand Expedition Yak
	[127216]={ YAK },	-- Grey Riding Yak
	[123182]={ YAK },	-- White Riding Yak

	[118089]={ WATERSTRIDER },	-- Azure Water Strider
	[127271]={ WATERSTRIDER },	-- Crimson Water Strider
	[127278]={ WATERSTRIDER },	-- Golden Water Strider
	[127274]={ WATERSTRIDER },	-- Jade Water Strider
	[127272]={ WATERSTRIDER },	-- Orange Water Strider

	[124659]={ SPECIAL },	-- Imperial Quilen
	[121820]={ SPECIAL },	-- Obsidian Nightwing
	[123886]={ INSECT },	-- Amber Scorpion

	[129934]={ FELINE },	-- Blue Shado-Pan Riding Tiger
	[129932]={ FELINE },	-- Green Shado-Pan Riding Tiger
	[129935]={ FELINE },	-- Red Shado-Pan Riding Tiger

	[121837]={ FELINE, CRAFTED },	-- Jade Panther
	[120043]={ FELINE, CRAFTED },	-- Jeweled Onyx Panther
	[121838]={ FELINE, CRAFTED },	-- Ruby Panther
	[121836]={ FELINE, CRAFTED },	-- Sapphire Panther
	[121839]={ FELINE, CRAFTED },	-- Sunstone Panther

	[126507]={ MECHANICAL, CRAFTED },	-- Depleted-Kyparium Rocket
	[126508]={ MECHANICAL, CRAFTED },	-- Geosynchronous World Spinner

	[129552]={ PHOENIX },	-- Crimson Pandaren Phoenix

	[130138]={ GOAT },	-- Black Riding Goat
	[130086]={ GOAT },	-- Brown Riding Goat
	[130137]={ GOAT },	-- White Riding Goat

	[130092]={ MECHANICAL },	-- Red Flying Cloud
	[130965]={ KODO },	-- Son of Galleon

-- 5.2 Mounts
	[139595]={ BAT },	-- Armored Bloodwing 
	[139448]={ PHOENIX },	-- Clutch of Ji-Kun
	[136505]={ HORSE, TCG },	-- Ghastly Charger's Skull
	[138424]={ DIREHORN },	-- Reins of the Amber Primordial Direhorn 
	[136400]={ DRAGON },	-- Reins of the Armored Skyscreamer
	[138642]={ RAPTOR },	-- Reins of the Black Primal Raptor
	[138640]={ RAPTOR },	-- Reins of the Bone-White Primal Raptor
	[138423]={ DIREHORN },	-- Reins of the Cobalt Primordial Direhorn 
	[140250]={ DIREHORN },	-- Reins of the Crimson Primal Direhorn
	[140249]={ DIREHORN },	-- Reins of the Crimson Golden Direhorn 
	[138643]={ RAPTOR },	-- Reins of the Green Primal Raptor
	[138426]={ DIREHORN },	-- Reins of the Jade Primordial Direhorn 
	[138425]={ DIREHORN },	-- Reins of the Slate Primordial Direhorn
	[139442]={ DRAGONSERPENT },	-- Reins of the Thundering Cobalt Cloud Serpent
	[136471]={ DIREHORN },	-- Spawn of Horridon

-- 5.3
	[142266]={ DRAGON, SPECIAL },	-- Armored Red Dragonhawk
	[142478]={ DRAGON, SPECIAL },	-- Armored Blue Dragonhawk
	[142878]={ DRAGON, SPECIAL },	-- Enchanted Fey Dragon

-- 5.4
	[145133]={ WOLF },	-- Moonfang	
	[146615]={ PVP, FELINE },	-- Vicious Warsaber
	[146622]={ HORSE, PVP },	-- Vicious Skeletal Warhorse
	[134359]={ MECHANICAL, CRAFTED },	-- Sky Golem	
	[148428]={ KODO, PVP },	-- Ashhide Mushan Beast
	[127164]={ DRAGONSERPENT },	-- Heavenly Golden Cloud Serpent	
	[148476]={ DRAGONSERPENT },	-- Thundering Onyx Cloud Serpent
	[148618]={ DRAGONSERPENT, PVP },-- Tyrannical Gladiator's Cloud Serpent
	[148392]={ PROTO },	-- Spawn of Galakras
	[148417]={ INSECT },	-- Kor'kron Juggernaut
	[148396]={ WOLF },	-- Kor'kron War Wolf

	[147595]={ BIRD },	-- Stormcrow
	[148619]={ DRAGONSERPENT, PVP },-- Grevious Gladiator's Cloud Serpent
	[148620]={ DRAGONSERPENT, PVP },-- Prideful Gladiator's Cloud Serpent
	[142073]={ HORSE, SPECIAL },	-- Hearthsteed	
	[30174]={ TURTLE },	-- Lucky Riding Turtle	

};
end
