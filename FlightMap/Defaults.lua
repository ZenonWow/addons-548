-- Default neutral data sets for FlightMap
--
-- Some default flight times thanks to Krwaz, author of FlightPath.
-- 
-- This file is loaded after the localisations

-- Prepare LibBabble -> replaced by MagicBabble
--local B = LibStub('LibBabble-Zone-3.0');
--BabbleZone = B:GetLookupTable();

-- Default options
FLIGHTMAP_DEFAULT_OPTS = {
     ["showPaths"]   = true,
     ["showPOIs"]    = true,
     ["showAllInfo"] = true,
     ["useTimer"]    = true,
     ["showCosts"]   = false,
     ["showTimes"]   = false,
     ["fullTaxiMap"] = true,
     ["largerTimer"] = false,
     ["xlTimer"] = false,
     ["noZoneTip"] = false,
};

-- Sub-zones
FLIGHTMAP_SUBZONES = {
    [BabbleZone["Orgrimmar"]]     = BabbleZone["Durotar"],
    [BabbleZone["Thunder Bluff"]] = BabbleZone["Mulgore"],
    [BabbleZone["Undercity"]]     = BabbleZone["Tirisfal Glades"],
    [BabbleZone["Ironforge"]]     = BabbleZone["Dun Morogh"],
    [BabbleZone["Stormwind City"]]     = BabbleZone["Elwynn Forest"],
    [BabbleZone["Shattrath City"]]     = BabbleZone["Terokkar Forest"],
    [BabbleZone["Dalaran"]]       = BabbleZone["Crystalsong Forest"],

    [BabbleZone["Kelp'thar Forest"]]       = BabbleZone["Vashj'ir"],
    [BabbleZone["Abyssal Depths"]]       = BabbleZone["Vashj'ir"],
    [BabbleZone["Shimmering Expanse"]]       = BabbleZone["Vashj'ir"],

    [BabbleZone["Northern Stranglethorn"]]       = BabbleZone["Stranglethorn Vale"],
    [BabbleZone["The Cape of Stranglethorn"]]       = BabbleZone["Stranglethorn Vale"],
};

FlightMap = {
    ["Opts"]             = FLIGHTMAP_DEFAULT_OPTS,
    ["Knowledge"]        = {},
};
