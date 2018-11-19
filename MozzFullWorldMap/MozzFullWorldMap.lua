--[[--------------------------------------------------------------------------------------------

MozzFullWorldMap.lua

*****************************************************************
SEE ReadMe.txt for latest Patch Notes for (Fan's Update) versions
*****************************************************************

--]]--------------------------------------------------------------------------------------------

-- "MozzFullWorldMap"
BINDING_HEADER_MFWM = MFWM.L["BINDING_HEADER_MFWM"]
-- "Show Unexplored Areas"
BINDING_NAME_MOZZ_WM_CHECKBOX = MFWM.L["BINDING_NAME_MOZZ_WM_CHECKBOX"]

-- we use this table to keep a cache of the overlays we're working with one pass to
-- the next so we know what we need to tweak

MFWM.Panels = {};
MFWM.Labels = {};

-- this is where the runtime merged map data is cached (known data + errata + pixed fixes)

MFWM.Cache = {};

-- string names of the continents and zones by ID

MFWM.Continents = {};

------------------------------------------------------------------------------------------------
-- Default addon state saved in the player's account saved variables for MFWM

MFWM.DefaultOptions = 
{
	colorStyle    = 0,		-- how to color the reveal map
	transparency  = 1.0,	-- applies to the world map only
	enabled       = true,	-- whether or not MFWM reveals are enabled
	debug         = false,	-- set true to log the world map updates (chatty!)
	labelPanels   = false,	-- set true to attach a label to every panel in the map
	showKnownData = false,	-- set true to cause all known data to be colored -- emerald for default, red for errata
	dumpData      = false,	-- set true to cause the working map cache to be dumped into the debug output on logout
};

------------------------------------------------------------------------------------------------

MFWM.white       = { r = 1.0, g = 1.0, b = 1.0 };
MFWM.emerald     = { r = 0.2, g = 0.6, b = 1.0 };
MFWM.errata      = { r = 1.0, g = 0.2, b = 0.2 };

------------------------------------------------------------------------------------------------
-- this method is responsible for performing a deep copy of a table
-- inclusive of preserving the metatable if applicable

MFWM.TableCopy = function( item )

    local hashTable = {}

    local function CopyItem( item )
    
        if type( item ) ~= "table" then return item;
        elseif hashTable[item]     then return hashTable[item];
        end
        
        local newTable = {};
        
        hashTable[item] = newTable;
        
        for index, value in pairs( item ) do
            newTable[CopyItem( index )] = CopyItem( value );
        end
        
        return setmetatable( newTable, CopyItem( getmetatable( item ) ) );
        
    end
    
    return CopyItem( item );
    
end

------------------------------------------------------------------------------------------------
-- player's saved variables data

MFWM_PlayerData =
{
	Options  = MFWM.TableCopy( MFWM.DefaultOptions ),
	Errata   = {};	-- this is where we record any errata we find at runtime
	Debug    = {};	-- if debugging is enabled, the debug messages are stored here in the saved vars
	MapData  = {};	-- if the dumpData option is enabled, this is where we'll store the map cache data
};

local function Debug(message)
	if  MFWM_PlayerData.Options.debug  then  table.insert(MFWM_PlayerData.Debug, message)  end
end

------------------------------------------------------------------------------------------------
-- build a map of zone names per continent as a quick lookup table
-- for handling errata while the player is busy

local function BuildContinentInfo( continentData, id, name )

	local zones = { GetMapZones( id ) };
	
	continentData[id] = 
	{
		name = name,
		zones = {}
	};

	for i,zone in pairs( zones ) do
		continentData[id].zones[i] = zone;
	end	
	
end

------------------------------------------------------------------------------------------------

local function SlashCommand(msg)
	InterfaceOptionsFrame_OpenToCategory( MFWM_OptionsFrame );
end

SLASH_MFWM1          = "/mozzfullworldmap";
SLASH_MFWM2          = "/mfwm";
SlashCmdList["MFWM"] = SlashCommand;

------------------------------------------------------------------------------------------------

local function MergeErrata( errata )

	local continent     = errata.continent;
	local zone          = errata.zone;
	local map           = errata.map;
	local overlay       = errata.overlay;
	local continentData = nil;
	local zoneData      = nil;
	local mapData       = nil;
	
	-- if the continent is new to us, add it to the map cache
	
	if continent 
	then
		if not MFWM.Cache[continent] 
		then
			MFWM.Cache[continent] = 
			{
				name  = MFWM.Continents[continent].name,
				zones = {}
			};
		end

		continentData = MFWM.Cache[continent];
		
	end
	
	-- if the zone is new to us, add it to the continent's zone table in the map cache
	
	if  zone
	and continentData
	then
		
		if not continentData.zones[zone] 
		then
			continentData.zones[zone] =
			{
				name = MFWM.Continents[continent].zones[zone],
				maps = {}
			};
		end
		
		zoneData = continentData.zones[zone];
		
	end
		
	-- if the zone is new to us, add it to the continent's zone table in the map cache
	
	if  map
	and zoneData
	then
	
		if not zoneData.maps[map]
		then
			zoneData.maps[map] = {};
		end
		
		mapData = zoneData.maps[map];
		
	end
		
	-- now overlay the map cache with the passed errata
	
	if  mapData
	and overlay
	then
		mapData[overlay] =
		{
			height    = errata.height,
			width     = errata.width,
			xOfs      = errata.xOfs,
			yOfs      = errata.yOfs,
			mapX      = errata.mapX,
			mapY      = errata.mapY,
			validated = errata.validated,
			errata    = errata.errata
		};
	end
	
end

------------------------------------------------------------------------------------------------
-- get the right set of overlays based on which continent we're in, which zone in the continent 
-- and which map in the zone... this deconflicts cosmic maps, dungeon maps, cave maps and 
-- special starting area maps. Note that the continent and the zone are used in the key index
-- to shorten the string-compares in the table lookups... we could use just the map name, but
-- that causes the key index to grow exponentially.

local function GetOverlayData( continent, zone, mapFileName )

	local overlayData = continent 
					and zone 
					and mapFileName 
					and MFWM.Cache[continent] 
					and MFWM.Cache[continent].zones[zone] 
					and MFWM.Cache[continent].zones[zone].maps[mapFileName]
					or nil;	
	   
	return overlayData;
end

------------------------------------------------------------------------------------------------

local function DisplayOverlays( 
	prefix, mapFileName, detailFrame, overlayName, knownOverlays, panelCache, 
	labelCache, overlayData, panelCount, enabled, showKnownData, scaling, displayMode 
)
	for texture,overlay in pairs( overlayData or {} ) do

		local textureName = prefix..mapFileName.."\\"..texture; -- root name of the texture for this overlay
		local discovered  = knownOverlays[texture];				-- true if the player has discovered this overlay
		local numColumns  = ceil( overlay.width / 256 );		-- the number of panels across the map
		local numRows     = ceil( overlay.height / 256 );		-- the number of panels down the map
		local numPanels   = numRows * numColumns;				-- how many panels it will take to display this overlay
		local panelAlpha;
		local panelColor;
		
		if enabled 
		or showKnownData
		or discovered == displayMode
		then
			
			-- select an alpha and a color for the panels we will be displaying for this overlay

			if showKnownData 
			then
			
				panelAlpha = 1;
				
				if overlay.errata then
					panelColor = MFWM.errata;
				else
					panelColor = MFWM.emerald;
				end
				
			elseif discovered 
			or not enabled
			then
			
				panelAlpha = (discovered or enabled) and 1 or 0;
				panelColor = MFWM.white;
				
			else
			
				panelAlpha = MFWM_PlayerData.Options.transparency or 1;
				
				if MFWM_PlayerData.Options.colorStyle == 2 
				and MFWM_PlayerData.Options.colorArray 
				then panelColor = MFWM_PlayerData.Options.colorArray;
				
				elseif MFWM_PlayerData.Options.colorStyle == 1
				then panelColor = MFWM.white;
				
				else panelColor = MFWM.emerald;
				end
				
			end

			if debug then
				table.insert( 
					MFWM_PlayerData.Debug, 
					texture.." "..
					(discovered and " (discovered)" or " (undiscovered)").." / "..
					"width = "..overlay.width..", "..
					"height = "..overlay.height..", "..
					"rows = "..numRows..", "..
					"columns = "..numColumns..", "..
					"xOfs = "..overlay.xOfs..", "..
					"yOfs = "..overlay.yOfs..", "..
					"Color = { "..panelColor.r..", "..panelColor.g..", "..panelColor.b.." }, "..
					"Alpha = "..panelAlpha 
				);
			end
			
			-- display the panels for this overlay one row at a time if
			-- either the overlay has been discovered or reveal is enabled
						
			for row = 1,numRows do
			
				local panelHeight = (row < numRows) and 256 or (overlay.height % 256);
				local fileHeight  = (row < numRows) and 256 or 16;
				local panel;
				
				if panelHeight == 0 then 
					panelHeight = 256; 
				end
				
				while fileHeight < panelHeight do
					fileHeight = fileHeight * 2;
				end
				
				-- display the unique panel for each column in the row
				
				for col = 1,numColumns do
										
					panelCount = panelCount+1;
					
					local overlayID   = (row-1)*numColumns + col;
					local texturePath = textureName..overlayID;
					local panelWidth  = (col < numColumns) and 256 or (overlay.width % 256);
					local fileWidth   = (col < numColumns) and 256 or 16;
					local xOfs        = (overlay.xOfs + (256 * (col-1))) * scaling;
					local yOfs        = (overlay.yOfs + (256 * (row-1))) * scaling;
					local panel       = panelCache[panelCount] or detailFrame:CreateTexture( "MFWM_"..overlayName..panelCount, "ARTWORK");
																			
					panelCache[panelCount] = panel;
			
					if panelWidth == 0 then 
						panelWidth = 256; 
					end
							
					while fileWidth < panelWidth do
						fileWidth = fileWidth * 2;
					end						
										
					panel:ClearAllPoints();
					panel:SetPoint( "TOPLEFT", detailFrame, "TOPLEFT", xOfs, -yOfs );
					
					panel:SetTexture( texturePath );
					panel:SetWidth( panelWidth * scaling );
					panel:SetHeight( panelHeight * scaling );
					panel:SetTexCoord( 0, panelWidth/fileWidth, 0, panelHeight/fileHeight);
					panel:SetVertexColor( panelColor.r, panelColor.g, panelColor.b );
					panel:SetAlpha( panelAlpha );
					panel:Show();
	
					if labelPanels then

						local label       = labelCache[panelCount] or detailFrame:CreateFontString( panel:GetName().."_Label", "OVERLAY" );

						if not labelCache[panelCount] then
							label:ClearAllPoints();
							label:SetPoint( "TOPLEFT", panel, "TOPLEFT", 0, 0 );					
							label:SetFont( "Fonts\\ARIALN.TTF", 12, "OUTLINE" );
							label:SetJustifyH( "LEFT" );
							label:SetJustifyV( "TOP" );
							label:SetText( "" );
						end
						
						labelCache[panelCount] = label;
					
						label:SetText( ("%s\n%s%d\n(%d,%d)"):format( panel:GetName(), texture, overlayID, row, col ) );
						label:Show();
						
					end
					
					if debug then
						table.insert( 
							MFWM_PlayerData.Debug, 
							("%s: row %d, col %d: width = %d, height = %d, scale = %0.1f) @ x = %0.01f, y = %0.01f / %s (%dx%d)"):format( panel:GetName() or "nil", row, col, panelWidth, panelHeight, scaling, xOfs, yOfs, texturePath, fileWidth, fileHeight ) 
						);
					end
				end
			end
		end
	end					

	return panelCount;
	
end
------------------------------------------------------------------------------------------------

local function UpdateOverlays( detailFrame, overlayName, scaling, alpha )

	if MFWM.isLoaded then
		
		local mapFileName   = GetMapInfo();
		local continent     = GetCurrentMapContinent();
		local zone          = GetCurrentMapZone();
		local numOverlays   = GetNumMapOverlays() or 0;
		local mapLevel      = GetCurrentMapDungeonLevel() or 0;
		local prefix        = "Interface\\WorldMap\\";
		local overlayData   = GetOverlayData( continent, zone, mapFileName );
		local enabled       = MFWM_PlayerData.Options.enabled;
		local showKnownData = MFWM_PlayerData.Options.showKnownData;
		local debug         = MFWM_PlayerData.Options.debug and overlayName == "WorldMapOverlay";
		local labelPanels   = MFWM_PlayerData.Options.labelPanels and overlayName == "WorldMapOverlay";
		local panelCache    = MFWM.Panels[overlayName] or {};
		local labelCache    = MFWM.Labels[overlayName] or {};
		local panelCount    = 0;
		
		if debug then

			local continentName = continent 
							  and MFWM.Continents[continent] 
							  and MFWM.Continents[continent].name 
							  or "nil";
					          
			local zoneName = continent 
						 and zone 
						 and MFWM.Continents[continent] 
						 and MFWM.Continents[continent].zones[zone]
						 or "nil";
			
			table.insert( 
				MFWM_PlayerData.Debug, 
				"==== MFWM Update "..overlayName..": "..
				continentName.." / "..
				zoneName..
				" ("..(continent or "?")..","..(zone or "?")..") / "..
				"Map Level = "..mapLevel.." / "..
				"Discovered Overlays = "..numOverlays.." / "..
				"Map File = "..(mapFileName or "nil").." ===="
			);
		end
		
		-- we use this cache to keep track of what overlays we're manipulating
		
		MFWM.Panels[overlayName] = panelCache;
		MFWM.Labels[overlayName] = labelCache;
		
		-- hide all of the panels we know about but the default Blizz code 
		-- does not... we presume Blizz has already dealt with hiding the
		-- panels it does know about but doesn't want to show
		
		for i,panel in pairs( panelCache ) do
			panel:Hide();
		end
		
		for i,label in pairs( labelCache ) do
			label:Hide();
		end
		
		-- if there is overlay data and we need to update the map, then here's where...
		
		if  mapLevel == 0
		and (overlayData or numOverlays > 0)
		then
			
			local knownOverlays = {};

			-- hide the panels that Blizz created -- we'll make our own
			
			for i=1,NUM_WORLDMAP_OVERLAYS do
			
				local panel = _G[overlayName..i];
				
				if panel then panel:Hide(); end
				
			end
			
			-- build a list of discovered zones in the map
			
			for i = 1,numOverlays do
			
				local texture, width, height, xOfs, yOfs, mapX, mapY = GetMapOverlayInfo( i );
				
				-- if this overlay has been discovered, then we need to process for the key value
				-- and check for errata if we haven't already
				
				if texture and texture ~= "" then
				
					local key     = texture:gsub( prefix..mapFileName.."\\", "" );
					local overlay = overlayData and overlayData[key] or nil;
					
					-- mark this key value as known
					
					knownOverlays[key] = true;
					
					-- if we have the overlay in the map cache, then validate
					-- it against the data we just got if we haven't already
					
					if overlay 
					and not overlay.validated
					then
						if  overlay.width  == width
						and overlay.height == height
						and overlay.xOfs   == xOfs
						and overlay.yOfs   == yOfs
						and overlay.mapX   == mapX
						and overlay.mapY   == mapY
						then
						
							overlay.validated = true;
							
							if debug then
								table.insert( 
									MFWM_PlayerData.Debug, 
									"Validated: "..key
								);
							end
							
						else
							
							if debug then
								table.insert( 
									MFWM_PlayerData.Debug, 
									"Errata: "..key.. " (changed) -- "..
									"height="..(overlay.height or "nil").."/"..(height or "nil")..", "..
									"width="..(overlay.width or "nil").."/"..(width or "nil")..", "..
									"xOfs="..(overlay.xOfs or "nil").."/"..(xOfs or "nil")..", "..
									"yOfs="..(overlay.yOfs or "nil").."/"..(yOfs or "nil")..", "..
									"mapX="..(overlay.mapX or "nil").."/"..(mapX or "nil")..", "..
									"mapY="..(overlay.mapY or "nil").."/"..(mapY or "nil")
								);
							end
						
							overlay = nil;
							
						end
						
					elseif not overlay
					then
							
						if debug then
							table.insert( 
								MFWM_PlayerData.Debug, 
								"Errata: "..key.. " (added) -- "..
								"height="..(height or "nil")..", "..
								"width="..(width or "nil")..", "..
								"xOfs="..(xOfs or "nil")..", "..
								"yOfs="..(yOfs or "nil")..", "..
								"mapX="..(mapX or "nil")..", "..
								"mapY="..(mapY or "nil")
							);
						end
					end
									
					-- if we don't have the right data in the map cache, then
					-- record the errata into the player's saved variables
					
					if not overlay then
					
						-- add the new data to the map cache
						
						local errata = 
						{
							continent = continent,
							zone      = zone,
							map       = mapFileName,
							overlay   = key,
							width     = width,
							height    = height,
							xOfs      = xOfs,
							yOfs      = yOfs,
							mapX      = mapX,
							mapY      = mapY,
							validated = true,
							errata    = true
						};

						MergeErrata( errata );
							
						table.insert( MFWM_PlayerData.Errata, errata );
						
						-- this might not have already existed, so we'll grab it here in case
						-- we just created it
						
						overlayData = GetOverlayData( continent, zone, mapFileName );
						
					end
				end
			end

			-- display that undiscovered overlays first
						
			panelCount = DisplayOverlays( 
				prefix, mapFileName, detailFrame, overlayName, knownOverlays, panelCache, 
				labelCache, overlayData, panelCount, enabled, showKnownData, scaling, nil 
			); 
			
			-- then display the discovered overlays over top of the them
			-- to produce smooth edges around the known zones (sorta -- as much as we can anyway)
			
			panelCount = DisplayOverlays( 
				prefix, mapFileName, detailFrame, overlayName, knownOverlays, panelCache, 
				labelCache, overlayData, panelCount, enabled, showKnownData, scaling, true 
			);
			
			-- forget which overlays were discovered
				
			wipe( knownOverlays );
			
		end
	end
end

------------------------------------------------------------------------------------------------

local function WorldMapUpdateOverlays()

	UpdateOverlays(
		WorldMapDetailFrame,
		"WorldMapOverlay", 
		1, 
		nil
	);
	
end

------------------------------------------------------------------------------------------------

local function BattlefieldMinimapUpdateOverlays()

	UpdateOverlays(
		BattlefieldMinimap, 
		"BattlefieldMinimapOverlay", 
		BattlefieldMinimap1:GetWidth()/256, 
		1 - ( BattlefieldMinimapOptions.opacity or 0 )
	);
	
end

------------------------------------------------------------------------------------------------

MFWM.RefreshMapOverlays = function()
	
	MFWM_PlayerData.Options.enabled = MozzWorldMapShowAllCheckButton:GetChecked();

	WorldMapUpdateOverlays();
	BattlefieldMinimapUpdateOverlays();
	
end

------------------------------------------------------------------------------------------------

local function AnchorMapOptions()

	if ( WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE ) 
	then
		if ( Gatherer_WorldMapDisplay ) 
		then
			MozzWorldMapShowAllCheckButton:SetPoint( "TOPLEFT", Gatherer_WorldMapDisplay, "TOPRIGHT", 5, 3 );
			MozzWorldMapShowAllCheckButton:SetScale( 0.9 );
		else
			MozzWorldMapShowAllCheckButton:SetPoint( "TOPLEFT", WorldMapPositioningGuide, "TOPLEFT", 10, -3 );
			MozzWorldMapShowAllCheckButton:SetScale( 0.9 );
		end
	else
		if ( Gatherer_WorldMapDisplay ) 
		then
			MozzWorldMapShowAllCheckButton:SetPoint( "TOPLEFT", Gatherer_WorldMapDisplay, "TOPRIGHT", 5, 3 );
			MozzWorldMapShowAllCheckButton:SetScale( 1 );
		else
			MozzWorldMapShowAllCheckButton:SetPoint( "TOPLEFT", WorldMapPositioningGuide, "TOPLEFT", 5, -2 );
			MozzWorldMapShowAllCheckButton:SetScale( 1 );
		end
	end
end

------------------------------------------------------------------------------------------------

local function OnEvent( self, event, ... )

	local arg1 = ...;
	
	-- at player logout, we validate the player's collected map data against the built
	-- in map data and record new errata as required
	
	if event == "PLAYER_LOGOUT"
	then
	
		if MFWM_PlayerData.Options.dumpData 
		then
		
			for i,continent in pairs( MFWM.Cache ) do
				for j,zone in pairs( continent.zones ) do
					for k,map in pairs( zone.maps ) do
						for l,overlay in pairs( map ) do
							overlay.errata = nil;
							overlay.validated = nil;
						end
					end
				end
			end
			
			MFWM_PlayerData.MapData = MFWM.TableCopy( MFWM.Cache );
			
		end
				
	-- if we've just loaded the addon, then we need to check if our map data
	-- needs fixing and rebuild the player table if required. 
	
	elseif event == "ADDON_LOADED" 
	and (arg1 == "MozzFullWorldMap" or arg1 == "nUI6")
	then

		-- if nUI6 is running, then MFWM should not be loaded as a standalone mod
		
		if (arg1 == "MozzFullWorldMap" and IsAddOnLoaded( "nUI6" ))
		or (arg1 == "nUI6" and IsAddOnLoaded( "MozzFullWorldMap" ))
		then
			DisableAddOn( "MozzFullWorldMap" );
			ReloadUI();
			return;
		end
		
		-- if the options table has been damaged, replace it with the default table
		
		if not MFWM_PlayerData.Options then
			MFWM_PlayerData.Options = MFWM.TableCopy( MFWM.DefaultOptions );
		end
		
		if not MFWM_PlayerData.Errata then 
			MFWM_PlayerData.Errata = {};
		end
		
		if not MFWM_PlayerData.Debug then 
			MFWM_PlayerData.Debug = {};
		end
		
		if not MFWM_PlayerData.MapData then 
			MFWM_PlayerData.MapData = {};
		end
		
		wipe( MFWM_PlayerData.Debug );
		wipe( MFWM_PlayerData.MapData );
		
		-- set up the options configuration panel
		
		MFWM.InitSettingsPanel();
									
		-- set up the check button on the map
		
		MozzWorldMapShowAllLabel:SetText( MFWM.L["BINDING_NAME_MOZZ_WM_CHECKBOX"] );
		MozzWorldMapShowAllCheckButton:SetChecked( MFWM_PlayerData.Options.enabled );
		
		-- set up the click function on the world map checkbox
		
		MozzWorldMapShowAllCheckButton:SetScript( "OnClick", MFWM.RefreshMapOverlays );
		
		-- collect the names of the continents and zones and cache
		-- them away. It saves us from futzing with it while were
		-- in the world and things are busy
					
		local continents, id, name = { GetMapContinents() };
		
		BuildContinentInfo( MFWM.Continents, -1, "Cosmic Map" );
		BuildContinentInfo( MFWM.Continents, 0, "Azeroth" );
		
		for id,continent in pairs( continents ) do
			BuildContinentInfo( MFWM.Continents, id, continent );
		end

		-- if the build number has changed, then we clear the player's map zone cache
		-- so the map can be rebuilt. This change fixes the issue of MFWM being
		-- out of date every time there is a new WoW map. MFWM is now self healing
		
		local mfwm_version = GetAddOnMetadata( arg1, "Version" );
		local wowBuild = MFWM_PlayerData.Options.wowBuild or {};
		local version, build, buildDate, toc = GetBuildInfo();
		
		if MFWM_PlayerData.Options.version ~= mfwm_version
		or wowBuild.version ~= version
		or wowBuild.build ~= build
		then
				
			wowBuild.version     = version;
			wowBuild.build       = build;
			wowBuild.date        = buildDate;
			wowBuild.toc         = toc;
			MFWM_PlayerData.Errata = {};		
			
			MFWM_PlayerData.Options.wowBuild = wowBuild;
			MFWM_PlayerData.Options.version  = mfwm_version;
			
		end		

		-- start building the map cache by plugging in what we know about the map
		-- as of the current version of MFWM
		
		MFWM.Cache = MFWM.TableCopy( MFWM.MapData );
		
		-- now overlay the built in data with the player's errata if they have any
		
		if #MFWM_PlayerData.Errata > 0 then

			for i,errata in ipairs( MFWM_PlayerData.Errata ) do
				MergeErrata( errata );
			end
    end

		if #MFWM_PlayerData.Errata > 0  and  not MFWM_PlayerData.ErrataNotified  then
			-- encourage the user to share their errata with us
			MFWM_PlayerData.ErrataNotified = date()
			local formatString = MFWM.L["ERRATA1"].." "..MFWM.L["ERRATA2"].." "..MFWM.L["ERRATA3"].." "..MFWM.L["ERRATA4"];
			
			DEFAULT_CHAT_FRAME:AddMessage( 
				formatString:format( 
					"|cFFFF00FF"..arg1.."|r",
					"|cFFFF00FF"..arg1.."|r",
					"|cFF00FFFFWorld of Warcraft > WTF > {account} > SavedVariables > "..arg1..".lua|r",
					"|cFF00FFFF"..GetAddOnMetadata( arg1, "X-Email" ).."|r",
					"|cFF00FFFF"..GetAddOnMetadata( arg1, "X-Feedback" ).."|r",
					"|cFFFF00FF"..arg1.."|r"
				), 1, 0.83, 0 
			);
			
		end
		
		-- lastly, overlay the map cache with any pixel twiddling we need to do

		for i,errata in ipairs( MFWM.PixelFix ) do
			MergeErrata( errata );
		end
   
		-- and we're ready to roll
				
		if arg1 == "MozzFullWorldMap" and MFWM_PlayerData.Options.debug then
			print( MFWM.L["LOADED"].." |c0000FF00"..mfwm_version.."|r", 0.64, 0.21, 0.93 );
		end
		
		MFWM.isLoaded = true;
		
	end
end

MFWM:SetScript( "OnEvent", OnEvent );

MFWM:RegisterEvent( "ADDON_LOADED" );
MFWM:RegisterEvent( "PLAYER_LOGOUT" );

------------------------------------------------------------------------------------------------

function MFWM_KeyBind_Toggle()

	if not InCombatLockdown() then
	
		if ( MFWM_PlayerData.Options.enabled == true ) then
			MFWM_PlayerData.Options.enabled = false;
			MozzWorldMapShowAllCheckButton:SetChecked(0);
		else
			MFWM_PlayerData.Options.enabled = true;
			MozzWorldMapShowAllCheckButton:SetChecked(1);
		end
		
		if ( AlphaMapFrame_Update ) then
			AlphaMapFrame_Update();
		end
		
		WorldMapUpdateOverlays();
		BattlefieldMinimapUpdateOverlays();
		
	end
end

------------------------------------------------------------------------------------------------

if WorldMapFrame_Update then
	hooksecurefunc(	"WorldMapFrame_Update", WorldMapUpdateOverlays );
end

if BattlefieldMinimap_Update then 
	hooksecurefunc(	"BattlefieldMinimap_Update", BattlefieldMinimapUpdateOverlays );
end

if BattlefieldMinimap_UpdateOpacity then 
	hooksecurefunc(	"BattlefieldMinimap_UpdateOpacity", BattlefieldMinimapUpdateOverlays );
end

if BattlefieldMinimap_SetOpacity then 
	hooksecurefunc(	"BattlefieldMinimap_SetOpacity", BattlefieldMinimapUpdateOverlays );
end

------------------------------------------------------------------------------------------------

hooksecurefunc( "ToggleFrame", function( who ) if who == WorldMapFrame then AnchorMapOptions(); end end );
hooksecurefunc( "WorldMapFrame_ToggleWindowSize", AnchorMapOptions );
hooksecurefunc( "WorldMap_ToggleSizeUp", AnchorMapOptions );
hooksecurefunc( "WorldMap_ToggleSizeDown", AnchorMapOptions );

------------------------------------------------------------------------------------------------
-- end of file