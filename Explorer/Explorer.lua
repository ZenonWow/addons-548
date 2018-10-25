--[[
/run Explorer:ToggleCompleted()
/run Explorer:ToggleCompleted( true )
/run Explorer:ToggleCompleted( false )
/dump Explorer.showCompleted
/run	Explorer.UpdatePins(true)
/dump Explorer.Achi
/dump Explorer.Pins
/dump Explorer.Pins[1]:IsVisible()
/run Explorer.Pins[1]:Show()
--]]
local _, addon = ...
local Overlays = addon.Overlays
Explorer = { Achi = {}, Pins = {} }
Explorer.showCompleted = true
local Explorer = Explorer
local Achi = Explorer.Achi
local Pins = Explorer.Pins

local PinFrame = CreateFrame('frame', nil, WorldMapButton)
PinFrame:SetAllPoints()
Explorer.PinFrame = PinFrame

Explorer.textureUnexplored = [[Interface\AddOns\Explorer\images\coordicon]]
--Explorer.textureCompleted = [[Interface\AddOns\Explorer\images\coordicon]]
Explorer.textureCompleted = [[Interface\AddOns\Explorer\images\completed]]

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


local function Pin_OnMouseUp(self)
	if TomTom and IsControlKeyDown() then
		local mapID, mapFloor = GetCurrentMapAreaID()
		local width, height = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
		local _, _, _, x, y = self:GetPoint()
		x = x / width
		y = -y / height
		TomTom:AddMFWaypoint(mapID, mapFloor, x, y, {
			title = format(EXPLORE_S, self.text),
			persistent = false,
		})
	end
end

local function Pin_OnEnter(self)
	--if self.text then
		WorldMapPOIFrame.allowBlobTooltip = false
		WorldMapTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
		WorldMapTooltip:ClearLines()
		
		if  self.name  then  WorldMapTooltip:AddLine(self.name)  end
		WorldMapTooltip:AddLine(self.text)
		WorldMapTooltip:AddLine(self.coord)
		
		if TomTom then
			WorldMapTooltip:AddLine(CLICK_WAYPOINT, 1, 1, 1, true)
		end
		WorldMapTooltip:Show()
	--end
end

local function Pin_OnLeave()
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
	pin:SetScript('OnMouseUp', Pin_OnMouseUp)
	pin:SetScript('OnEnter', Pin_OnEnter)
	pin:SetScript('OnLeave', Pin_OnLeave)
	return pin
end

local function SetPinCompleted(pin, completed)
	pin.completed = completed
	if  completed == unknown  then
		pin:Hide()
		return
	end
	
	pin:SetShown(Explorer.showCompleted  or  not completed)
	local size = completed  and  9  or  18
	local texture = completed  and  Explorer.textureCompleted  or  Explorer.textureUnexplored
	pin:SetSize(size, size)
	pin.texture:SetTexture(texture)
end



local function GetAchiCriterias(achiId)
	Achi = { achiId = achiId }
	Explorer.Achi = Achi
	if  not achiId  then  return  end
	
	for i = 1, GetAchievementNumCriteria(achiId) do
		local name, _, completed, _, _, _, _, zoneID = GetAchievementCriteriaInfo(achiId, i)
		Achi[zoneID]= { completed, i, name }
	end
end

--local unknown = nil
local unknown = { "unknown" }  -- marker object
local function GetZoneCompleted(achiId, crit)
	if  not crit  then  return unknown  end
	local i = crit[2]
	crit[1] = select(3, GetAchievementCriteriaInfo(achiId, i) )
	return  crit[1]  -- completed
	--[[
	local name, _, completed, _, _, _, _, zoneID = GetAchievementCriteriaInfo(achiId, crit[2])
	return  completed
	--]]
end


function Explorer.UpdatePins(refresh)
	for  idx = 1, #Pins  do
		local pin = Pins[idx]
		local completed = GetZoneCompleted(Achi.achiId, pin.crit)
		if  (pin.completed ~= completed)  or  refresh  then  SetPinCompleted(pin, completed)  end
	end
end



--[[
/dump GetCurrentMapAreaID()
/dump Explorer.Pins.areaID
--]]
function Explorer.UpdateMap()
	local areaID = GetCurrentMapAreaID()
	if  Pins.areaID == areaID  then  return  Explorer.UpdatePins()  end
	Pins.areaID = areaID
	
	local mapName, _, _, isMicroDungeon, microDungeonPath = GetMapInfo()
	local info = not isMicroDungeon  and  Overlays[areaID]  or  {}
	--if  isMicroDungeon  or  not info  then  return  end
	
	local achiId = info[1]
	GetAchiCriterias(achiId)
	
	local idx = 0
	for i = 2, #info, 3 do
		idx = idx + 1
		local pin = Pins[idx]
		if  not pin  then
			pin = CreatePin()
			Pins[idx] = pin
		end
		
		local zoneId, x, y = info[i], info[i + 1], info[i + 2]
		local crit = Achi[zoneId]
		local completed = unknown
		if  crit  then  completed = crit[1]  end
		
		pin.zoneId = zoneId
		pin.crit = crit
		pin.name = crit  and  crit[3]
		pin.text = crit  and  'achi='.. achiId ..'/crit='.. zoneId
		pin.coord = crit  and  '/way '.. x/10 ..' '.. math.floor(y * 3/2 + 0.5)/10

		--[[
/dump WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()  ->  1000, 668
		--]]
		pin:SetPoint('CENTER', WorldMapDetailFrame, 'TOPLEFT', x, -y)
		SetPinCompleted(pin, completed)
	end
	
	while  idx < #Pins  do
		idx = idx + 1
		local pin = Pins[idx]
		--pin:Hide()
		SetPinCompleted(pin, unknown)
	end
end



hooksecurefunc('WorldMapFrame_Update', Explorer.UpdateMap)



