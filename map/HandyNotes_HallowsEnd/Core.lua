------------------------------------------
--  This addon was heavily inspired by  --
--    HandyNotes_Lorewalkers            --
--    HandyNotes_LostAndFound           --
--  by Kemayo                           --
------------------------------------------
--[[
/run HallowsEnd:CreateContinentWaypoints(  )
/run HallowsEnd:CreateContinentWaypoints( true )
/dump select(GetCurrentMapZone(), GetMapZones(GetCurrentMapContinent()))
/dump HallowsEnd.points[ select(GetCurrentMapZone(), GetMapZones(GetCurrentMapContinent())) ]
/run a={ GetMapZones( GetCurrentMapContinent () ) }
/dump GetMapZones(GetCurrentMapContinent())
/dump GetMapContinents()
/dump GetCurrentMapAreaID()
/dump GetAreaMapInfo(GetCurrentMapAreaID())

/dump HandyNotes:GetZoneToMapID('Dread Wastes')  
/dump HandyNotes:GetMapIDtoMapFile(858)
--]]


local function print(...)  DEFAULT_CHAT_FRAME:AddMessage(...)  end

-- declaration
local ID, HallowsEnd = ...
HallowsEnd.points = {}
_G.HallowsEnd = HallowsEnd
--[[
/run HallowsEnd.debug = true
/run HallowsEnd.oldcreateWaypoint = true
--]]

-- our db and defaults
local db
local defaults = { profile = { completed = false, icon_scale = 1.4, icon_alpha = 0.8 } }
local CLICK_DELAY, DOUBLECLICK_DELAY = 0.1, 0.2  -- seconds


-- upvalues
local _G = getfenv(0)

local CloseDropDownMenus = _G.CloseDropDownMenus
local GameTooltip = _G.GameTooltip
local gsub = _G.string.gsub
local IsQuestFlaggedCompleted = _G.IsQuestFlaggedCompleted
local LibStub = _G.LibStub
local next = _G.next
local pairs = _G.pairs
local ToggleDropDownMenu = _G.ToggleDropDownMenu
local UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton
local UIParent = _G.UIParent
local WorldMapButton = _G.WorldMapButton
local WorldMapTooltip = _G.WorldMapTooltip

local Cartographer_Waypoints = _G.Cartographer_Waypoints
local HandyNotes = _G.HandyNotes
local NotePoint = _G.NotePoint
local TomTom = _G.TomTom

local points = HallowsEnd.points


-- plugin handler for HandyNotes
function HallowsEnd:OnEnter(mapFile, coord)
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip

	if self:GetCenter() > UIParent:GetCenter() then -- compare X coordinate
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end

	local zonePoints = points[mapFile]
	local questID = zonePoints  and  zonePoints[coord]  or  '<unknown>'
	tooltip:SetText("Candy Bucket\n[quest="..questID.."]")
	tooltip:Show()
end

function HallowsEnd:OnLeave()
	if self:GetParent() == WorldMapButton then
		WorldMapTooltip:Hide()
	else
		GameTooltip:Hide()
	end
end



local function AddWaypoint(mapID, mapFloor, x, y, title)
	if  TomTom  then  TomTom:AddMFWaypoint( mapID, mapFloor, x, y, {title = title, persistent = false} )  end
	if  TomTomLite  then  TomTomLite:AddWaypoint( mapID, mapFloor, x, y, {title = title, persistent = false} )  end
	if  Cartographer_Waypoints  then  Cartographer_Waypoints:AddWaypoint( NotePoint:new(mapID, x, y, title) )  end
end

local function SetClosestWaypoint()
	if  TomTom  then  TomTom:SetClosestWaypoint()  end
	if  TomTomLite  then  TomTomLite:UpdateArrow()  end
	if  Cartographer_Waypoints  then  end  --Cartographer_Waypoints:SetClosestWaypoint()  end  -- TODO
end

if  HandyNotes  then
	AddWaypoint = HandyNotes.AddWaypoint or AddWaypoint ; HandyNotes.AddWaypoint = AddWaypoint
	SetClosestWaypoint = HandyNotes.SetClosestWaypoint or SetClosestWaypoint ; HandyNotes.SetClosestWaypoint = SetClosestWaypoint
end



function HallowsEnd:CreateContinentWaypoints(showCompleted)
	local continentIdx = GetCurrentMapContinent()
	print('CreateContinentWaypoints(): continentIdx='.. continentIdx)
	local count = 0
	local zones = { GetMapZones(continentIdx) }
	for  zoneIdx, zoneName  in  ipairs(zones)  do
		local mapID, mapFloor = HandyNotes:GetZoneToMapID(zoneName), 0
		local mapFile = HandyNotes:GetMapIDtoMapFile(mapID)
		mapFile = gsub(mapFile, "_terrain%d+$", "")
		local zonePoints = points[mapFile]
		if  not zonePoints  then
			print('    ==> |cffff8080'.. zoneName .. '|r (|cff33ff99'.. mapFile .. '|r)  has no data')
			zonePoints = {}
		elseif  HallowsEnd.debug  then  print('  '.. zoneName .. ' (|cff33ff99'.. mapFile .. '|r)')
		end
		for  coord, questID  in  pairs(zonePoints)  do  if  showCompleted  or  not IsQuestFlaggedCompleted(questID)  then
			local x, y = HandyNotes:getXY(coord)
			AddWaypoint(mapID, mapFloor, x, y, "Candy Bucket "..questID.." in "..zoneName)  -- .." [quest="..questID.."]")
			count = count + 1
		end end
	end
	
	print('CreateContinentWaypoints('..(showCompleted and 'showCompleted' or '')..'): '.. count .. ' waypoints')
	SetClosestWaypoint()
	
	local isHorde = UnitFactionGroup('player') == 'Horde'  and  1  or  0
	if  continentIdx == 6  then    -- Pandaria
		AddTrackedAchievement(7601+isHorde)    -- Tricks and Treats of Pandaria
	elseif  continentIdx == 5  then    -- The Maelstrom
		AddTrackedAchievement(5837+isHorde)    -- Tricks and Treats of the Cataclysm
	elseif  continentIdx == 4  then    -- Northrend
		AddTrackedAchievement(5836-isHorde)    -- Tricks and Treats of Northrend -- consistency: 10 points, Blizzard
	elseif  continentIdx == 3  then    -- Outland
		AddTrackedAchievement(969-isHorde)    -- Tricks and Treats of Outland -- consistency: -10 points, Blizzard
	elseif  continentIdx == 2  then    -- Eastern Kingdoms
		AddTrackedAchievement(966+isHorde)    -- Tricks and Treats of Eastern Kingdoms
		AddTrackedAchievement(5837+isHorde)    -- Tricks and Treats of the Cataclysm
	elseif  continentIdx == 1  then    -- Kalimdor
		AddTrackedAchievement(963+2*isHorde)    -- Tricks and Treats of Kalimdor
		AddTrackedAchievement(5837+isHorde)    -- Tricks and Treats of the Cataclysm
	end

end


local function CreateWaypointAt(mapFile, coord)
	local mapID, mapFloor = HandyNotes:GetMapFiletoMapID(mapFile), 0
	local x, y = HandyNotes:getXY(coord)
	
	local c, z = HandyNotes:GetCZ(mapFile)
	local zoneName = HandyNotes:GetCZToZone(c,z)
	
	--[[
	local mapIDCurrent = GetCurrentMapAreaID()
	local zoneNameCurrent = select(GetCurrentMapZone(), GetMapZones(GetCurrentMapcontinentIdx()))  or  '<unknown zone>'
	--]]
	
	local zonePoints = points[mapFile]
	local questID = zonePoints  and  zonePoints[coord]  or  '<unknown>'
	
	if  HallowsEnd.debug  then
		print(string.format( 'CreateWaypointAt(): mapID=%d, mapIDCurrent=%d, c,z,zone=%d,%d,%s, x,y=%.2f,%.2f coord=%d',
			mapID, mapIDCurrent or '', c,z,zoneName, x*100, y*100, coord ))
	end
	
	AddWaypoint(mapID, mapFloor, x, y, "Candy Bucket "..questID.." in "..zoneName)  -- .." [quest="..questID.."]")
end

local function createWaypoint(button, mapFile, coord)
	local c, z = HandyNotes:GetCZ(mapFile)
	local x, y = HandyNotes:getXY(coord)

	if TomTom then
		TomTom:AddZWaypoint(c, z, x * 100, y * 100, "Candy Bucket")
	elseif Cartographer_Waypoints then
		Cartographer_Waypoints:AddWaypoint( NotePoint:new(HandyNotes:GetCZToZone(c, z), x, y, "Candy Bucket") )
	end
end


--[[
do
	-- context menu generator
	local info = {}
	local currentZone, currentCoord

	local function close()
		-- we need to do this to avoid "for initial value must be a number" errors
		CloseDropDownMenus()
	end
	local function generateMenu(button, level)
		if not level then return end

		for k in pairs(info) do info[k] = nil end

		if level == 1 then
			-- create the title of the menu
			info.isTitle = 1
			info.text = "Candy Bucket"
			info.notCheckable = 1

			UIDropDownMenu_AddButton(info, level)

			if TomTom or Cartographer_Waypoints then
				-- waypoint menu item
				info.notCheckable = nil
				info.disabled = nil
				info.isTitle = nil
				info.icon = nil
				info.text = "Create waypoint"
				info.func = createWaypoint
				info.arg1 = currentZone
				info.arg2 = currentCoord

				UIDropDownMenu_AddButton(info, level)
			end

			-- close menu item
			info.text = "Close"
			info.func = close
			info.arg1 = nil
			info.arg2 = nil
			info.icon = nil
			info.isTitle = nil
			info.disabled = nil
			info.notCheckable = 1

			UIDropDownMenu_AddButton(info, level)
		end
	end

	local dropdown = CreateFrame("Frame", "HandyNotes_HallowsEndDropdownMenu")
	dropdown.displayMode = "MENU"
	dropdown.initialize = generateMenu

	function HallowsEnd:OnClick(button, down, mapFile, coord)
		if button == "RightButton" and not down then
			currentZone = mapFile
			currentCoord = coord

			ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
		end
	end
end
--]]


local lastMouseDown, lastClick

function HallowsEnd:OnClick(self, down, mapFile, coord)
	local now = GetTime()
	
	if  down  then
		lastMouseDown = now
		-- Action on mouse UP only
		return
  end
	
	-- if  not lastMouseDown  then  return  end    -- Button was pressed over some other widget
	
	local longClick = lastMouseDown  and  CLICK_DELAY < now - lastMouseDown
	lastMouseDown = nil
	if  longClick  then  return  end    -- Holding button for some time is not a click
	
	-- Ctrl-Click
	if  IsModifiedClick('ADDWAYPOINT')  then
		return HallowsEnd:OnDoubleClick(self, down, mapFile, coord)
	end
	
	-- Double Click
	if  lastClick  and  (now - lastClick < DOUBLECLICK_DELAY)  then
		lastClick = nil
		return HallowsEnd:OnDoubleClick(self, down, mapFile, coord)
	end
	
	lastClick = now
end

function HallowsEnd:OnDoubleClick(self, down, mapFile, coord)
	-- Action on mouse UP only
	if  down  then  return  end
	
	--createWaypoint(currentZone, currentCoord)
	if  HallowsEnd.oldcreateWaypoint  then  createWaypoint(self, mapFile, coord)
	else  CreateWaypointAt(mapFile, coord)
	end
end



do
	-- custom iterator we use to iterate over every node in a given zone
	local function iter(zonePoints, prevCoord)
		if not zonePoints then return nil end

		local nextCoord, questID = next(zonePoints, prevCoord)

		while nextCoord do -- have we reached the end of this zone?
			if questID and (db.completed or not IsQuestFlaggedCompleted(questID)) then
				return nextCoord, nil, "interface\\icons\\achievement_halloween_candy_01", db.icon_scale, db.icon_alpha
			end

			nextCoord, questID = next(zonePoints, nextCoord) -- get next data
		end

		return nil, nil, nil, nil
	end

	-- Iterator function for HandyNotes
	function HallowsEnd:GetNodes(mapFile)
		if  HallowsEnd.debug  then  print('HallowsEnd:GetNodes("|cff33ff99'..mapFile..'|r")')  end
		mapFile = gsub(mapFile, "_terrain%d+$", "")
		return iter, points[mapFile], nil
	end
end



-- config
local options = {
	type = "group",
	name = "Hallow's End",
	desc = "Hallow's End candy bucket locations.",
	get = function(info) return db[info[#info]] end,
	set = function(info, v)
		db[info[#info]] = v
		HallowsEnd:Refresh()
	end,
	args = {
		desc = {
			name = "These settings control the look and feel of the icon.",
			type = "description",
			order = 1,
		},
		completed = {
			name = "Show completed",
			desc = "Show icons for candy buckets you have already visited.",
			type = "toggle",
			width = "full",
			arg = "completed",
			order = 2,
		},
		icon_scale = {
			type = "range",
			name = "Icon Scale",
			desc = "Change the size of the icons.",
			min = 0.25, max = 2, step = 0.01,
			arg = "icon_scale",
			order = 3,
		},
		icon_alpha = {
			type = "range",
			name = "Icon Alpha",
			desc = "Change the transparency of the icons.",
			min = 0, max = 1, step = 0.01,
			arg = "icon_alpha",
			order = 4,
		},
	},
}



-- initialise
function HallowsEnd:OnEnable()
	local _, month, day = CalendarGetDate()

	if (month == 10 and (day >= 18 and day <= 31))
	or (month == 11 and day == 01)  then
		HandyNotes:RegisterPluginDB("HallowsEnd", self, options)
		self:RegisterEvent("QUEST_FINISHED", "Refresh")

		db = LibStub("AceDB-3.0"):New("HandyNotes_HallowsEndDB", defaults, "Default").profile
	else
		self:Disable()
	end
end

function HallowsEnd:Refresh()
	self:SendMessage("HandyNotes_NotifyUpdate", "HallowsEnd")
end


-- activate
HallowsEnd = LibStub("AceAddon-3.0"):NewAddon(HallowsEnd, ID, "AceEvent-3.0")
