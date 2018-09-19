-- Mop up untranslated strings here

if not FLIGHTMAP_SUBCOMMANDS[FLIGHTMAP_REPAIR] then
	FLIGHTMAP_SUBCOMMANDS[FLIGHTMAP_REPAIR] = "Repair the database to add missing nodes if any"
end

if not FLIGHTMAP_SUBCOMMANDS[FLIGHTMAP_HARDRESET] then
	FLIGHTMAP_SUBCOMMANDS[FLIGHTMAP_HARDRESET] = "Perform a total factory clear of the flight times (careful!!)"
end

if not FLIGHTMAP_OPTIONS[13] then
	FLIGHTMAP_OPTIONS[13] = {   -- Option 13: Hide zone tooltip
	    label = "Do not show the zone tooltip overlay with flight information",
	    option = "noZoneTip",
	    tooltip = "The overlay tooltip will not be shown on the zone map",
	};
end

-- TODO Add these strings to appropriate language files, translated.
-- TODO Modernise translation system
