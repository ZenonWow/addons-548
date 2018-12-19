local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local L = LibStub("AceLocale-3.0"):GetLocale("LorewalkersHelper", not debug)

local Astrolabe = DongleStub("Astrolabe-1.0")

LorewalkersHelper = LibStub("AceAddon-3.0"):NewAddon("LorewalkersHelper", "AceConsole-3.0")

local defaultSettings = {
  global = {
    hintFrame = {
      locked = false,
      left = false,
      top = false,
      distance = 100
      -- TODO limit missing or all (configurable)
    }
  }
}

-- locations of every achievement criteria
local achiMap = {
  {7230, {p={
    {m=857, x=81.36, y=11.34, id=20415},
    {m=806, x=37.38, y=30.11, id=20416},
    {m=809, x=44.66, y=52.40, id=20417}
  }}},
  {6856, {p={
    {m=807, x=20.21, y=55.86, id=19793},
    {m=807, x=55.06, y=47.13, id=19794},
    {m=807, x=34.58, y=63.83, id=19795},
    {m=857, x=72.20, y=30.96, id=19796}
  }}},
  {6716, {p={
    {m=806, x=67.71, y=29.35, id=19618},
    {m=873, f=5, x=77.55, y=95.35, id=19619}, -- dungeon entrance (57.93, 13.15) or (50.58, 40.95) or (m=809 73.08, 94.46)
    {m=858, x=67.42, y=60.80, id=19620},
    {m=857, x=32.84, y=29.39, id=19621}
  }}},
  {6846, {p={
    {m=806, x=66.01, y=87.58, id=19768},
    {m=807, x=61.20, y=34.82, id=19769},
    {m=857, x=30.53, y=38.63, id=19771},
    {m=809, x=74.47, y=83.57, id=19772}
  }}},
  {6857, {p={
    {m=858, x=48.36, y=32.85, id=19797},
    {m=858, x=59.90, y=55.12, id=19798},
    {m=858, x=52.54, y=10.03, id=19799}, -- structure entrance (53.66, 15.75)
    {m=858, x=35.55, y=32.64, id=19800}
  }}},
  {6850, {p={
    {m=806, x=26.37, y=28.35, id=19781},
    {m=857, x=52.42, y=87.71, id=19782}, -- structure entrance (52.25, 85.98)
    {m=807, x=83.23, y=21.17, id=19783},
    {m=809, x=45.77, y=61.88, id=19784}
  }}},
  {6754, {p={
    {m=809, x=50.58, y=48.06, id=19662}, -- dungeon entrance (53.04, 46.46), inside coord (58.3, 71.5)
    {m=857, x=50.93, y=31.65, id=19663},
    {m=806, x=42.28, y=17.48, id=19664},
    {m=811, x=40.27, y=77.48, id=19665}
  }}},
  {6855, {p={
    {m=806, x=47.08, y=45.11, id=19785},
    {m=809, x=43.84, y=51.21, id=19790},
    {m=806, x=55.89, y=56.83, id=19786},
    {m=857, x=40.50, y=56.65, id=19787}, -- structure entrance (40.45, 50.38)
    {m=810, x=37.77, y=62.91, id=19789},
    {m=809, x=67.74, y=48.34, id=19788},
    {m=809, x=40.98, y=42.37, id=19791},
    {m=811, x=68.87, y=44.26, id=19792}
  }}},
  {6847, {p={
    {m=809, x=50.40, y=79.29, id=19773},
    {m=810, x=65.39, y=49.98, id=19774},
    {m=809, x=71.74, y=63.00, id=19775},
    {m=810, x=84.07, y=72.92, id=19776}
  }}},
  {6858, {p={
    {m=807, x=18.82, y=31.67, id=19801},
    {m=811, x=52.92, y=68.67, id=19802},
    {m=806, x=35.76, y=30.45, id=19803},
    {m=811, x=26.57, y=21.41, id=19804},
    {m=809, x=63.02, y=40.80, id=19809}
  }}}
}

local last_update = 0
local hintFrame, updaterFrame

function LorewalkersHelper:OnInitialize()
  -- Called when the addon is loaded
  self:RegisterChatCommand("lorewalkershelper", "SlashCommand")
  self:RegisterChatCommand("lwh", "SlashCommand")

  self.settings = LibStub("AceDB-3.0"):New("LWH_Settings", defaultSettings, true)
end

function LorewalkersHelper:PrintUsage()
  local s

  s = "\n"
  s = s .. "|cff7777ff/lorewalkershelper ...|r\n"
  s = s .. "|cff7777ff/lwh ...|r\n"
  s = s .. "|cff7777ff/lwh missing|r " .. L["add waypoints to missing criteria in current zone"] .. "\n"
  s = s .. "|cff7777ff/lwh all missing|r " .. L["add waypoints to missing criteria in all Pandaria zones"] .. "\n"
  s = s .. "|cff7777ff/lwh all|r " .. L["add waypoints to every criteria across Pandaria"] .. "\n"
  s = s .. "|cff7777ff/lwh all zone|r " .. L["add waypoints to every criteria in current zone"] .. "\n"
  s = s .. "|cff7777ff/lwh lock|r " .. L["lock info panel"] .. "\n"
  s = s .. "|cff7777ff/lwh move|r " .. L["unlock info panel"] .. "\n"
  s = s .. "|cff7777ff/lwh distance <yards>|r " .. L["set the range that will trigger the hint panel"] .. "\n"
  s = s .. "|cff7777ff/lwh debug|r " .. L["esable/disable debug mode"]

  self:Print(s)
end

function LorewalkersHelper:SlashCommand(command)
  local limitZone, limitMissing, addWaypoints, distance
  -- commands: all (everything everywhere), all zone (all in current zone), missing (missing in current zone, default), all missing (missing in every zone)
  addWaypoints = false
  if command:match"^%s*all%s*$" then
    limitZone = false
    limitMissing = false
    addWaypoints = true
  elseif command:match"^%s*all%s+zone%s*$" then
    limitZone = true
    limitMissing = false
    addWaypoints = true
  elseif command:match"^%s*all%s+missing%s*$" then
    limitZone = false
    limitMissing = true
    addWaypoints = true
  elseif command:match"^%s*missing%s*$" then
    limitZone = true
    limitMissing = true
    addWaypoints = true
  elseif command:match"^%s*move%s*$" or command:match"^%s*move%s*frame%s*$" then
    LorewalkersHelper:MoveHintFrame()
    addWaypoints = false
  elseif command:match"^%s*lock%s*$" or command:match"^%s*lock%s*frame%s*$" then
    LorewalkersHelper:LockHintFrame()
    addWaypoints = false
  elseif command:match"^%s*distance%s+%d+%s*$" then
    distance = command:gsub("^%s*distance%s+(%d+)%s*$", "%1")
    distance = distance and tonumber(distance)
    if distance then
      LorewalkersHelper.settings.global.hintFrame.distance = distance
    end
    addWaypoints = false
  elseif command:match"^%s*debug%s*$" then
    debug = not debug
    local str = "\n"
    if debug then
      str = str .. L['Debug mode enabled']
    else
      str = str .. L['Debug mode disabled']
    end
    self:Print(str)
    addWaypoints = false
  else
    LorewalkersHelper:PrintUsage()
    addWaypoints = false
  end

  if addWaypoints then
    LorewalkersHelper:SetWaypoints(limitZone, limitMissing)
  end

end

function LorewalkersHelper:SetWaypoints(limitZone, limitMissing)
  -- Set waypoints for current zone
  local i, a, c, zoneName, count, doAdd

  -- check zone: must be in Pandaria
  -- check level: suggest level 90
	-- check zone: strongly reccomend 90 in Veiled Stair ;)

  zoneName = GetZoneText()
  count = 0
  for i,a in pairs(achiMap) do
    for i,c in pairs(a[2].p) do
      doAdd = true
      -- check zone
      if limitZone and zoneName ~= GetMapNameByID(c.m) then
        doAdd = false
      end
      -- check complete
      if limitMissing and
        select(3, GetAchievementCriteriaInfoByID(a[1], c.id)) then
        doAdd = false
      end
      if doAdd then
        --[===[@alpha@
        LorewalkersHelper:AddWaypoint(c.m, c.f or nil, c.x / 100, c.y / 100,
            select(1, GetAchievementCriteriaInfoByID(a[1], c.id)) .. " (" .. c.id .. ")")
        --@end-alpha@]===]
        --@non-alpha@
        LorewalkersHelper:AddWaypoint(c.m, c.f or nil, c.x / 100, c.y / 100,
            select(1, GetAchievementCriteriaInfoByID(a[1], c.id)))
        --@end-non-alpha@
        count = count + 1
      end
    end
  end
  if limitZone then
    self:Print(L['Added %d waypoints in %s']:format(count, zoneName))
  else
    self:Print(L['Added %d waypoints in %s']:format(count,
                                                  select(6, GetMapContinents())))
  end
  if count > 0 then
    LorewalkersHelper:SetClosestWaypoint()
  end
end

function LorewalkersHelper:ToggleMoveHintFrame()
  --[===[@debug@
  LorewalkersHelper:Print('ToggleMoveHintFrame')
  --@end-debug@]===]
  if hintFrame:IsMovable() then
    LorewalkersHelper:LockHintFrame()
  else
    LorewalkersHelper:MoveHintFrame()
  end
end

function LorewalkersHelper:MoveHintFrame()
  --[===[@debug@
  LorewalkersHelper:Print('LorewalkersHelper:MoveHintFrame')
  --@end-debug@]===]
  LorewalkersHelper.settings.global.hintFrame.locked = false
  hintFrame:SetMovable(true)
  hintFrame:EnableMouse(true)

  hintFrame.mover:Show()
  hintFrame.mover.title:Show()
  hintFrame.mover.desc:Show()
  hintFrame.texture:Hide()
  hintFrame.imageFrame:Hide()
  hintFrame.title:Hide()
  hintFrame.desc:Hide()

  hintFrame:Show()

end

function LorewalkersHelper:LockHintFrame()
  --[===[@debug@
  LorewalkersHelper:Print('LorewalkersHelper:LockHintFrame')
  --@end-debug@]===]
  LorewalkersHelper.settings.global.hintFrame.locked = true
  hintFrame:SetMovable(false)
  --hintFrame:EnableMouse(false)

  hintFrame.mover:Hide()
  hintFrame.mover.title:Hide()
  hintFrame.mover.desc:Hide()
  hintFrame.texture:Show()
  hintFrame.imageFrame:Show()
  hintFrame.title:Show()
  hintFrame.desc:Show()

  LorewalkersHelper:ShowNearestHint()
end

function LorewalkersHelper:AddWaypoint(map, floorNum, x, y, title)
  local s
  if TomTom and TomTom.AddMFWaypoint then
    TomTom:AddMFWaypoint(map, floorNum or nil, x, y, {title = title})
  elseif TomTomLite and TomTomLite.AddWaypoint then
    TomTomLite.AddWaypoint(map, floorNum or nil, x, y, {title = title})
  else
    s = GetMapNameByID(map)
    -- show floor?
    s = s .. " (" .. x*100 .. ", " .. y*100 .. "): " .. title
    self:Print(s)
  end
end

function LorewalkersHelper:SetClosestWaypoint()
  if TomTom and TomTom.SetClosestWaypoint then
    TomTom:SetClosestWaypoint()
  end
end

function LorewalkersHelper:GetNearestPOI(limitZone, limitMissing)
  local closest_poi = nil
  local closest_dist = nil
  local evaluateCurrent, dist, poi, m, f, x, y

  m, f, x, y = Astrolabe:GetUnitPosition("player")

  for i,a in pairs(achiMap) do
    for i,c in pairs(a[2].p) do
      evaluateCurrent = true
      -- check zone
      if limitZone and zoneName ~= GetMapNameByID(c.m) then
        evaluateCurrent = false
      end
      -- check complete
      if limitMissing and
        select(3, GetAchievementCriteriaInfoByID(a[1], c.id)) then
        evaluateCurrent = false
      end
      if evaluateCurrent then
        c["a"] = a[1]
        dist = Astrolabe:ComputeDistance(m, f, x, y, c.m, c.f, c.x / 100, c.y / 100)
        --[===[@debug@
        -- if dist then
        --   LorewalkersHelper:Print('GetNearestPOI: ',
        --                           "\nPlayer position: " .. m .. " " .. f .. " " .. x .. " " .. y,
        --                           "\nCriteria: " .. a[1] .. "." .. c.id .. "",
        --                           "\nCriteria position" .. c.m .. " " .. (c.f or 0) .. " " .. c.x .. " " .. c.y,
        --                           "\nDistance: " .. dist)
        -- end
        --@end-debug@]===]
        if not dist then
          -- can't compute distance
        elseif not closest_dist then
          closest_dist = dist
          closest_poi = c
        elseif dist < closest_dist then
          closest_dist = dist
          closest_poi = c
        end
      end
    end
  end

  return closest_dist, closest_poi
end

function LorewalkersHelper:ShowNearestHint()
  --hintFrame:Hide()
  local closest_dist, closest_poi, hideHint

  -- TODO limit missing or all (configurable)
  closest_dist, closest_poi = LorewalkersHelper:GetNearestPOI(false, not debug)

  if closest_dist and closest_poi then
    --[===[@debug@
    --LorewalkersHelper:Print('ShowNearestHint: ',  closest_dist, closest_poi.a, closest_poi.id)
    --@end-debug@]===]

    if closest_dist > LorewalkersHelper.settings.global.hintFrame.distance then
      hideHint = true
    else
      hideHint = false

      hintFrame.poi = closest_poi
      hintFrame.poi["title"] = select(1, GetAchievementCriteriaInfoByID(closest_poi.a, closest_poi.id))

      hintFrame.title:SetText(hintFrame.poi.title)

      hintFrame.image:SetTexture("Interface\\Addons\\LorewalkersHelper\\images\\" .. closest_poi.id, false)

      if closest_poi.hint then
        hintFrame.desc:SetText(L[closest_poi.hint])
        hintFrame.desc:Show()
      else
        hintFrame.desc:Hide()
      end
      hintFrame:Show()
    end
  else
    hideHint = true
  end

  if hideHint then
    --[===[@debug@
    --LorewalkersHelper:Print('ShowNearestHint: nothing to show')
    --@end-debug@]===]
    if LorewalkersHelper.settings.global.hintFrame.locked then
      hintFrame.poi = nil
      hintFrame:Hide()
    end
  end

end

 -- Functions for Frame Movement --
local function StartMoving(self, button)
  --[===[@debug@
  LorewalkersHelper:Print('StartMoving: ', button)
  --@end-debug@]===]

  if ( button ~= "LeftButton" ) then
    -- add waypoint on right click 8-)
    LorewalkersHelper:ShowNearestHint()
    if hintFrame.poi then
      LorewalkersHelper:AddWaypoint(hintFrame.poi.m, hintFrame.poi.f,
                                    hintFrame.poi.x/100, hintFrame.poi.y/100,
                                    hintFrame.poi.title)
      LorewalkersHelper:SetClosestWaypoint()
    end
  end

  if ( ( not self.isLocked ) or ( self.isLocked == 0 ) ) then
    if ( self:IsMovable() ) then
      self:StartMoving();
      self.isMoving = true;
      self.hasMoved = false;
    end
  end
end

local function StopMoving(self, button)
  --[===[@debug@
  LorewalkersHelper:Print('StopMoving: ', button)
  --@end-debug@]===]

  if ( button ~= "LeftButton" ) then return end
  if ( self.isMoving ) then
    self:StopMovingOrSizing();
    self.isMoving = false;
    self.hasMoved = true;
    LorewalkersHelper.settings.global.hintFrame.top = self:GetTop()
    LorewalkersHelper.settings.global.hintFrame.left = self:GetLeft()
  end
end
-- END --

local function updaterFrameOnUpdate(frame, elapsed)
  last_update = last_update + elapsed
  if last_update > 1 then
    -- compute updates every second
    last_update = 0
    LorewalkersHelper:ShowNearestHint()
  else
    -- meh
  end
end


function LorewalkersHelper:OnEnable()
  -- Called when the addon is enabled
  if not updaterFrame then
    --[===[@debug@
    LorewalkersHelper:Print('CreateFrame: LorewalkersHelperUpdaterFrame')
    --@end-debug@]===]
    updaterFrame = CreateFrame("frame")
    updaterFrame:SetScript("OnUpdate", updaterFrameOnUpdate)
    updaterFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    updaterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  end
  updaterFrame:Show()

  if not hintFrame then
    hintFrame = CreateFrame("Frame", "LorewalkersHelperHint", UIParent, nil)

    hintFrame:SetWidth(128)
    hintFrame:SetHeight(186)
    hintFrame:SetClampedToScreen(true)
    hintFrame:SetScale(1, 1)

    hintFrame:SetPoint("LEFT", UIParent, "LEFT")
    if LorewalkersHelper.settings.global.hintFrame.left then
      hintFrame:SetPoint("LEFT", UIParent, "LEFT", LorewalkersHelper.settings.global.hintFrame.left, 0)
    end
    if LorewalkersHelper.settings.global.hintFrame.top then
      hintFrame:SetPoint("TOP", UIParent, "BOTTOM", 0, LorewalkersHelper.settings.global.hintFrame.top)
    end

    hintFrame.texture = hintFrame:CreateTexture(nil, "BACKGROUND")
    hintFrame.texture:SetTexture(0, 0, 0)
    hintFrame.texture:SetAllPoints(hintFrame)
    hintFrame.texture:SetAlpha(0.2)

    hintFrame.mover = hintFrame:CreateTexture(nil, "BACKGROUND")
    hintFrame.mover:SetTexture("Interface\\Addons\\LorewalkersHelper\\images\\mover", false)
    hintFrame.mover:SetAllPoints(hintFrame)
    hintFrame.mover:SetAlpha(0.4)
    hintFrame.mover.title = hintFrame:CreateFontString("OVERLAY", hintFrame.mover, "GameFontHighlightSmall")
    hintFrame.mover.title:SetPoint("TOPLEFT", hintFrame.mover, "TOPLEFT", 0, -8)
    hintFrame.mover.title:SetPoint("TOPRIGHT", hintFrame.mover, "TOPRIGHT", 0, -8)
    hintFrame.mover.title:SetText("LorewalkersHelper")

    hintFrame.mover.desc = hintFrame:CreateFontString("OVERLAY", hintFrame.mover, "GameFontNormalSmall")
    hintFrame.mover.desc:SetPoint("TOPLEFT", hintFrame.mover.title, "BOTTOMLEFT", 4, 0)
    hintFrame.mover.desc:SetPoint("BOTTOMRIGHT", hintFrame.mover, "BOTTOMRIGHT", -4, 8)
    hintFrame.mover.desc:SetWordWrap(true)
    hintFrame.mover.desc:SetJustifyH("LEFT")
    hintFrame.mover.desc:SetText(L["This panel shows up when you are near a point of interest."] ..
                                "\n" ..
                                "\n" ..
                                L["Drag to move"] ..
                                "\n" ..
                                "\n" ..
                                L["Right click LDB plugin or type \"/lwh lock\" in chat to lock frame"])
    hintFrame.mover.desc:SetWordWrap(true)
    hintFrame.mover:Hide()


    hintFrame.imageFrame = CreateFrame("Frame", "LorewalkersHelperHintImageFrame", hintFrame, nil)
    hintFrame.imageFrame:SetWidth(hintFrame:GetWidth())
    hintFrame.imageFrame:SetHeight(hintFrame:GetWidth())
    hintFrame.imageFrame:SetPoint("TOPLEFT", hintFrame, "TOPLEFT")
    hintFrame.imageFrame:SetPoint("TOPRIGHT", hintFrame, "TOPRIGHT")
    hintFrame.imageFrame:Show()

    hintFrame.image = hintFrame.imageFrame:CreateTexture(nil, "OVERLAY")
    hintFrame.image:SetTexture("Interface\\Icons\\achievement_faction_lorewalkers", false)
    hintFrame.image:SetAllPoints(hintFrame.imageFrame)

    hintFrame.title = hintFrame:CreateFontString("OVERLAY", nil, "GameFontHighlightSmall")
    hintFrame.title:SetWordWrap(true)
    hintFrame.title:SetJustifyH("LEFT")
    hintFrame.title:SetPoint("TOPLEFT", hintFrame.imageFrame, "BOTTOMLEFT", 0, 0)
    hintFrame.title:SetPoint("TOPRIGHT", hintFrame.imageFrame, "BOTTOMRIGHT", 0, 0)

    hintFrame.desc = hintFrame:CreateFontString("OVERLAY", nil, "GameFontNormalSmall")
    hintFrame.desc:SetWordWrap(true)
    hintFrame.desc:SetJustifyH("LEFT")
    --hintFrame.desc:SetMaxLines(3)
    --hintFrame.desc:SetSize(128, 42)
    hintFrame.desc:SetPoint("TOPLEFT", hintFrame.title, "BOTTOMLEFT", 0, 0)
    hintFrame.desc:SetPoint("BOTTOMRIGHT", hintFrame, "BOTTOMRIGHT", 0, 0)


    hintFrame.title:SetText("titolo...")
    hintFrame.desc:SetText("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed eleifend hendrerit metus eget fermentum. Maecenas sed gravida risus. Donec sed dignissim dolor. In quis ligula sed tellus viverra sodales in....")

    hintFrame:Show()
    hintFrame:SetScript("OnMouseDown", StartMoving)
    hintFrame:SetScript("OnMouseUp", StopMoving)

    if not LorewalkersHelper.settings.global.hintFrame.locked then
      LorewalkersHelper:MoveHintFrame()
    else
      LorewalkersHelper:LockHintFrame()
    end
  end

end


function LorewalkersHelper:OnDisable()
    -- Called when the addon is disabled
  if hintFrame then
    hintFrame:Hide()
    hintFrame:SetParent(nil)
    hintFrame = nil
  end
  if updaterFrame then
    updaterFrame:Hide()
    updaterFrame:SetParent(nil)
    updaterFrame = nil
  end
end


-- LDB

local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)

-- local LibQTip = LibStub('LibQTip-1.0')
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("LorewalkersHelper",
{
  type = "data source",
  label = "Lorewalkers Helper",
  text = "Lorewalkers Helper",
  -- icon = "Interface\\Icons\\Ability_mount_cloudmount",
  icon = "Interface\\Icons\\achievement_faction_lorewalkers",
  OnClick = function(clickedFrame, button)
    -- Click to add waypoints to missing criteria in current zone. (default)
    -- Shift-Click to add waypoints to missing criteria in Pandaria.
    -- Alt-Click to add waypoints to all criteria in current zone.
    -- Alt-Shift-Click to add waypoints to all criteria in Pandaria.
    if button == "LeftButton" then
      -- LorewalkersHelper:SetWaypoints(limitZone, limitMissing)
      LorewalkersHelper:SetWaypoints(not IsShiftKeyDown(), not IsAltKeyDown())
    elseif button == "RightButton" then
      LorewalkersHelper:ToggleMoveHintFrame()
    end
  end,
});

function LDB:OnTooltipShow()
  local zoneName, zoneId, counts, i, a, c
  self:AddLine("Lorewalkers Helper")

  self:AddLine(L["Missing achievements criteria in current zone"])

  zoneId = -1
  zoneName = GetZoneText()
  counts = {}
  for i, a in pairs(achiMap) do
    for i, c in pairs(a[2].p) do
      --[===[@alpha@
      if not select(3, GetAchievementCriteriaInfoByID(a[1], c.id)) then
        if counts[c.m] then
          counts[c.m] = counts[c.m] + 1
        else
          counts[c.m] = 1
        end
        if zoneName == GetMapNameByID(c.m) then
          zoneId = c.m -- store it for later use ^^
          self:AddLine("|cffff0000" ..
                       select(1, GetAchievementCriteriaInfoByID(a[1], c.id)) ..
                       "|r" ..
                       " (" .. a[1] .. " - " .. c.id .. ")")
        end
      else
        if zoneName == GetMapNameByID(c.m) then
          zoneId = c.m -- store it for later use ^^
          self:AddLine("|cff00ff00" ..
                       select(1, GetAchievementCriteriaInfoByID(a[1], c.id)) ..
                       "|r" ..
                       " (" .. a[1] .. " - " .. c.id .. ")")
        end
      end
      --@end-alpha@]===]
      --@non-alpha@
      if not select(3, GetAchievementCriteriaInfoByID(a[1], c.id)) then
        if counts[c.m] then
          counts[c.m] = counts[c.m] + 1
        else
          counts[c.m] = 1
        end
        if zoneName == GetMapNameByID(c.m) then
          zoneId = c.m -- store it for later use ^^
          self:AddLine("|cffff0000" ..
                       select(1, GetAchievementCriteriaInfoByID(a[1], c.id)) ..
                       "|r")
        end
      end
      --@end-non-alpha@
    end
  end

  if zoneId >= 0 and not counts[zoneId]  then
    self:AddLine(L["Nothing missing in current zone!"])
  end

  self:AddLine(" ")
  self:AddLine(L["Missing criteria in other zones"])

  for i, c in pairs(counts) do
    if i ~= zoneId then
      if not c then
        self:AddLine(GetMapNameByID(i) ..
                     ": |cff00ff00" ..
                     c ..
                     "|r")
      else
        self:AddLine(GetMapNameByID(i) ..
                     ": |cffff0000" ..
                     c ..
                     "|r")
      end
    end
  end

  self:AddLine(" ")
  -- colors are Alpha Red Green Blue
  self:AddLine("|cffed55aaClick|r: " .. L["add waypoints to missing criteria in current zone"])
  self:AddLine("|cffed55aaShift-Click|r: " .. L["add waypoints to missing criteria in all Pandaria zones"])
  self:AddLine("|cffed55aaAlt-Click|r: " .. L["add waypoints to every criteria in current zone"])
  self:AddLine("|cffed55aaAlt-Shift-Click|r: " .. L["add waypoints to every criteria across Pandaria"])
  self:AddLine("|cffed55aaRightClick|r: " .. L["lock/unlock info panel"])


  --[===[@debug@
  -- for i, a in pairs(achiMap) do
  --   for i, c in pairs(a[2].p) do
  --     self:AddLine(a[1] .. "." .. c.id .. " (" .. c.m .. ": " .. c.x .. ", " .. c.y .. "): " ..
  --                  "|cffff0000" ..
  --                  select(1, GetAchievementCriteriaInfoByID(a[1], c.id)) ..
  --                  "|r")
  --   end
  -- end
  --@end-debug@]===]
  --[===[@non-debug@
  --@non-debug@]===]

end

function LDB:OnEnter()
  GameTooltip:SetOwner(self, "ANCHOR_NONE")
  GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
  GameTooltip:ClearLines()
  LDB.OnTooltipShow(GameTooltip)
  GameTooltip:Show()
end

function LDB:OnLeave()
  GameTooltip:Hide()
end
