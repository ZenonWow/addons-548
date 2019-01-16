--[[
/run Explorer.CreateZoneWaypoints(  )
/run Explorer.CreateZoneWaypoints( true )
/run Explorer:ToggleCompleted()
/run Explorer:ToggleCompleted( true )
/run Explorer:ToggleCompleted( false )
/dump Explorer.showCompleted
/run	Explorer.UpdatePins(true)
/dump Explorer.Achi
/dump Explorer.Pins
/dump GetCurrentMapAreaID()
/dump Explorer.Pins.mapID
/dump Explorer.Pins.achiId
/dump Explorer.GetAchiCriterias( Explorer.Pins.achiId )
/dump Explorer.Pins[1]:IsVisible()
/run Explorer.Pins[1]:Show()

/run Explorer.debug = true
/run Explorer.showMissingCriterias = not Explorer.showMissingCriterias ; Explorer.UpdateMap(true)

Renamed  areaID -> mapID  (MapAreaID is commonly called mapID, in ex. Astrolabe, HandyNotes)
--]]
local ADDON_NAME, addon = ...
local Overlays = addon.Overlays
Explorer = { Achi = {}, Pins = { numValid = 0 } }
Explorer.showCompleted = true
local Explorer = Explorer
local Pins = Explorer.Pins

local PinFrame = CreateFrame('frame', nil, WorldMapButton)
PinFrame:SetAllPoints()
Explorer.PinFrame = PinFrame

Explorer.textureUnexplored = [[Interface\AddOns\Explorer\images\coordicon]]
--Explorer.textureCompleted = [[Interface\AddOns\Explorer\images\coordicon]]
Explorer.textureCompleted = [[Interface\AddOns\Explorer\images\completed]]

local CLICK_DELAY, DOUBLECLICK_DELAY = 0.1, 0.2  -- seconds
-- Locale:
local EXPLORE_S = 'Explore: %s'
local CLICK_WAYPOINT = 'Ctrl-Click to add waypoint'
if GetLocale() == 'deDE' then
	EXPLORE_S = 'Erkundet: %s'
	CLICK_WAYPOINT = 'Strg-Klick, um einen Zielpunkt zu setzen'
elseif GetLocale():match('es') then
	EXPLORE_S = 'Explora: %s'
	CLICK_WAYPOINT = 'Ctrl-Clic para establecer un waypoint'
end



function Explorer:ToggleCompleted(showCompleted)
	if  showCompleted == nil  then  showCompleted = not Explorer.showCompleted  end
	Explorer.showCompleted = showCompleted
	Explorer.UpdatePins(true)
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



--[[
/dump WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()  ->  1000, 668
local mapWidth, mapHeight = 1000, 668
--]]
local mapWidth, mapHeight = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()

local function GetDataToXY(dataX, dataY)
	-- Convert to [0-1] range
	local x = dataX / mapWidth
	-- Round y to 3 decimals:  0.yyy
	local y = math.floor(dataY / mapHeight * 1000) / 1000
	return x, y
end


local lastMouseDown, lastClick

function Explorer.Pin_OnClick(pin)
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
		return Explorer.Pin_OnDoubleClick(pin)
	end
	
	-- Double Click
	if  lastClick  and  (now - lastClick < DOUBLECLICK_DELAY)  then
		lastClick = nil
		return Explorer.Pin_OnDoubleClick(pin)
	end
	
	lastClick = now
end

function Explorer.Pin_OnDoubleClick(pin)
	local mapID, mapFloor = GetCurrentMapAreaID(), 0
	local _, _, _, posX, posY = pin:GetPoint()
	local x, y = GetDataToXY(posX, -posY)
	local name = pin.crit[3]
	local title = string.format( EXPLORE_S, name )
	AddWaypoint(mapID, mapFloor, x, y, title)
end


function Explorer.Pin_OnEnter(self)
	--if self.text then
		WorldMapPOIFrame.allowBlobTooltip = false
		WorldMapTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
		WorldMapTooltip:ClearLines()
		
		if  self.name  then  WorldMapTooltip:AddLine(self.name)  end
		if  self.text  then  WorldMapTooltip:AddLine(self.text)  end
		if  self.coord  then  WorldMapTooltip:AddLine(self.coord)  end
		
		if TomTom then
			WorldMapTooltip:AddLine(CLICK_WAYPOINT, 1, 1, 1, true)
		end
		WorldMapTooltip:Show()
	--end
end

function Explorer.Pin_OnLeave()
	WorldMapPOIFrame.allowBlobTooltip = true
	WorldMapTooltip:Hide()
end



local function CreatePin()
	local pin = CreateFrame('frame', nil, PinFrame)
	pin:SetSize(18, 18)
	pin.texture = pin:CreateTexture()
	pin.texture:SetAllPoints()
	--pin.texture:SetTexture(Explorer.textureUnexplored)

	pin:EnableMouse(true)
	--pin:SetScript('OnMouseDown', Explorer.Pin_OnClick)
	pin:SetScript('OnMouseUp', Explorer.Pin_OnClick)
	--pin:RegisterForClicks("AnyUp")
	--pin:SetScript('Pin_OnClick', Explorer.Pin_OnClick)
	--pin:SetScript('OnDoubleClick', Explorer.Pin_OnDoubleClick)
	pin:SetScript('OnEnter', Explorer.Pin_OnEnter)
	pin:SetScript('OnLeave', Explorer.Pin_OnLeave)
	return pin
end

local function SetPinCompleted(pin, completed)
	pin.completed = completed
	pin:SetShown(Explorer.showCompleted  or  not completed)
	local size = completed  and  12  or  18
	local texture = completed  and  Explorer.textureCompleted  or  Explorer.textureUnexplored
	pin:SetSize(size, size)
	pin.texture:SetTexture(texture)
end



function Explorer.GetAchiCriterias(achiId)
	local achiCrits = { achiId = achiId }
	Explorer.Achi = achiCrits
	if  not achiId  then  return achiCrits  end
	
	for critIdx = 1, GetAchievementNumCriteria(achiId) do
		local name, _, completed, _, _, _, _, zoneID = GetAchievementCriteriaInfo(achiId, critIdx)
		achiCrits[zoneID]= { completed, critIdx, name }
	end
	
	return achiCrits
end
local GetAchiCriterias = Explorer.GetAchiCriterias


local function UpdateZoneCompleted(achiId, crit)
	local critIdx = crit[2]
	if  not critIdx  then  return crit[1]  end
	
	crit[1] = select(3, GetAchievementCriteriaInfo(achiId, critIdx) )
	return  crit[1]  -- completed
	--[[
	local name, _, completed, _, _, _, _, zoneID = GetAchievementCriteriaInfo(achiId, crit[2])
	return  completed
	--]]
end



local function AddPin(criteria, zoneId, dataX, dataY)
	local idx = Pins.numValid + 1
	local pin = Pins[idx]
	if  not pin  then
		pin = CreatePin()
		Pins[idx] = pin
	end
	
	--local zoneId, x, y = zoneData[i], zoneData[i + 1], zoneData[i + 2]
	--local criteria = achiCrits[zoneId]
	local completed = criteria[1]
	pin.zoneId = zoneId
	pin.crit = criteria
	pin.name = criteria[3]
	local critIdx = criteria[2]
	local critIdxStr = critIdx  and  ' ('..critIdx..'.)'  or  ' (missing)'
	pin.text = '[achievement='.. Pins.achiId ..'/criteria='.. zoneId .. critIdxStr ..']'
	local x, y = GetDataToXY(dataX, dataY)
	pin.coord = string.format('/way %.2f %.2f', x*100, y*100)  -- convert from [0-1] range to [0-100] range

	pin:SetPoint('CENTER', WorldMapDetailFrame, 'TOPLEFT', dataX, -dataY)
	SetPinCompleted(pin, completed)
	Pins.numValid = idx
end

local function ResetUnusedPins()
	for  idx = Pins.numValid+1,#Pins  do
		local pin = Pins[idx]
		pin.crit = nil
		pin.name = nil
		pin.coord = nil
		pin.text = nil
		pin:Hide()
	end
end



function Explorer.UpdatePins(refresh)
	if  Explorer.debug  then  print('Explorer.UpdatePins('.. (refresh and 'refresh' or '') ..'): mapID='..Pins.mapID)  end
	for  idx = 1, Pins.numValid  do
		local pin = Pins[idx]
		local completed = UpdateZoneCompleted(Pins.achiId, pin.crit)
		if  (pin.completed ~= completed)  or  refresh  then  SetPinCompleted(pin, completed)  end
	end
end

-- criteria = { completed, critIdx, name }
local missingCriteria = { nil, nil, "<zone criteria missing from achievement>" }

function Explorer.UpdateMap(refresh)
	local mapID = GetCurrentMapAreaID()
	if  not refresh  and  Pins.mapID == mapID  then
		-- Still on the same map, just update the completed flag of the pins
		return  Explorer.UpdatePins()
	end
	
	local mapFile, _, _, isMicroDungeon, microDungeonPath = GetMapInfo()
	if  Explorer.debug  then  print( 'Explorer.UpdateMap(): mapID: '..tostring(Pins.mapID)..'->'..tostring(mapID)..' mapFile='..tostring(mapFile)..(isMicroDungeon and '  isMicroDungeon' or '') )  end
	
	Pins.numValid = 0
	Pins.achiId = nil
	Pins.mapID = mapID
	
	if  isMicroDungeon  then  return  end
	local zoneData = Overlays[mapID]
	if  not zoneData  then
		print('Explorer.UpdateMap()  ==> |cffff8080map='..mapID..' '.. tostring(mapFile) .. '|r  has no data')
		zoneData = {}
	end
	
	local achiId = zoneData[1]
	local achiCrits = GetAchiCriterias(achiId)
	Pins.achiId = achiId
	
	local showMissing = not not Explorer.showMissingCriterias
	for i = 2, #zoneData, 3 do
		local zoneId = zoneData[i]
		local criteria = achiCrits[zoneId]
		if  criteria  or  showMissing  then
			AddPin(criteria  or  missingCriteria, zoneId, zoneData[i+1], zoneData[i+2])
		end
	end
	
	ResetUnusedPins()
	if  Explorer.debug  then  print('Explorer.UpdateMap(): '.. count .. ' waypoints')  end
end

hooksecurefunc('WorldMapFrame_Update', Explorer.UpdateMap)



--[[
/dump GetCurrentMapAreaID()
/dump Explorer.Pins.mapID
--]]
function Explorer.CreateZoneWaypoints(showCompleted)
	local mapID, mapFloor = GetCurrentMapAreaID(), 0
	local mapFile, _, _, isMicroDungeon, microDungeonPath = GetMapInfo()
	if  Explorer.debug  then  print( 'Explorer.CreateZoneWaypoints(): mapID='..mapID..' mapFile='..mapFile..(isMicroDungeon and '  isMicroDungeon' or '') )  end
	
	if  isMicroDungeon  then  return  end
	local zoneData = Overlays[mapID]
	if  not zoneData  then
		print('CreateZoneWaypoints()  ==> |cffff8080'.. mapFile .. '|r  has no data')
		return
	end
	
	local achiId = zoneData[1]
	local achiCrits = GetAchiCriterias(achiId)
	
	local count = 0
	for i = 2, #zoneData, 3 do
		local zoneId = zoneData[i]
		local criteria = achiCrits[zoneId]  or  missingCriteria
		local completed = criteria[1]
		if  showCompleted  or  not completed  then
			local x, y = GetDataToXY(zoneData[i+1], zoneData[i+2])
			local name = criteria[3]
			local title = string.format( EXPLORE_S, name )
			AddWaypoint(mapID, mapFloor, x, y, title)
			count = count + 1
		end
	end
	
	print('CreateZoneWaypoints('..(showCompleted and 'showCompleted' or '')..'): |cffff8080'.. mapFile .. '|r has '.. count .. ' waypoints')
	SetClosestWaypoint()
	
	-- Show remaining areas in achievement tracker
	AddTrackedAchievement(achiId)
end



