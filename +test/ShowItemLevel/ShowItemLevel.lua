-- ShowItemLevel v1.00 by d07.RiV (Iroared)
-- All rights reserved

ShowItemLevel = CreateFrame ("Frame", nil, UIParent)
local SIL = ShowItemLevel

--[[                            ACTUAL UNIT DATA FUNCTIONS                            ]]--

local function chsize (char)
  if not char then
    return 0
  elseif char > 240 then
    return 4
  elseif char > 225 then
    return 3
  elseif char > 192 then
    return 2
  else
    return 1
  end
end

function SIL:GetFullKey (name)
  local size = chsize (name:byte (1))
  local capname = name:sub (1, size):upper () .. name:sub (size + 1)
  return capname .. " - " .. GetRealmName ()
end
function SIL:ColorUnitName (name, class)
  if name:find ("-") then
    local lname, server = name:match ("^([^-%s]+)%s*-%s*([^%s]*)")
    if not server or server == GetRealmName () then
      name = lname
    end
  end
  local color = RAID_CLASS_COLORS[class]
  if color then
    return string.format ("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, name)
  else
    return name
  end
end

function SIL:GetUnitKey (unit)
  if not UnitPlayerControlled (unit) then return nil end
  local name, server = UnitName (unit)
  server = server or GetRealmName ()
  return name .. " - " .. server
end
function SIL:GetKeyByName (fullname)
  if fullname:find ("-") then
    local name, server = strmatch (fullname, "^([^-%s]+)%s*-%s*([^%s]*)")
    return name .. " - " .. (server or GetRealmName ())
  else
    return fullname .. " - " .. GetRealmName ()
  end
end
function SIL:GetUnitDataRaw (unit)
  local itemLevel = 0
  local numPVE, numPVP = 0, 0
  local slots = {}
  local empty = false
  for i, v in ipairs (self.itemSlots) do
    local item = GetInventoryItemLink (unit, v)
    local iLevel, equipSlot = 0, nil
    if item then
      _, _, _, iLevel, _, _, _, _, equipSlot = GetItemInfo (item)
      local stats = GetItemStats (item)
      if stats["ITEM_MOD_RESILIENCE_RATING_SHORT"] and stats["ITEM_MOD_RESILIENCE_RATING_SHORT"] > 0 then
        numPVP = numPVP + 1
      else
        numPVE = numPVE + 1
      end
    elseif i ~= 16 then
      empty = true
    end
    slots[i] = {level = iLevel, slot = equipSlot}
    itemLevel = itemLevel + iLevel
  end
  if slots[16].slot == nil and slots[15].slot == "INVTYPE_2HWEAPON" then
    itemLevel = itemLevel + slots[15].level
  end
  local _, class = UnitClass (unit)
  local result = {ilvl = itemLevel / 17, pve = numPVE, pvp = numPVP, date = date ("*t"), class = class}
  if self.db then
    self.db.players[self:GetUnitKey (unit)] = result
  end
  return result, empty
end
function SIL:ProbeUnitData (unit)
  for i = 1, #self.itemSlots do
    if GetInventoryItemLink (unit, self.itemSlots[i]) then
      return true
    end
  end
  return false
end

function SIL:CanInspect ()
  return not (InspectFrame and InspectFrame:IsShown ())
end

function SIL:FormatDate (when)
  local diff = time () - time (when)
  if diff <= 0 then
    return nil
  end
  if diff < 60 then
    return string.format ("%d seconds ago", diff)
  elseif diff < 3600 then
    return string.format ("%d minutes ago", diff / 60)
  elseif diff < 3600 * 24 then
    return string.format ("%d hours ago", diff / 3600)
  elseif diff < 3600 * 24 * 7 then
    return string.format ("%d days ago", diff / (3600 * 24))
  else
    return string.format ("%02d/%02d/%04d", when.day, when.month, when.year)
  end
end
function SIL:FormatData (data, real)
  local suffix = ""
  if not real then
    local ago = self:FormatDate (data.date)
    if ago then
      suffix = " |cffff5599[" .. ago .. "]|r"
    end
  end
  local pvp = ""
  if data.pvp > 0 then
    pvp = string.format (" (%d%% PvP)", 100 * data.pvp / (data.pve + data.pvp))
  end
  return string.format ("%.1f%s%s", data.ilvl, pvp, suffix)
end

--[[                               UNIT TRACKER SYSTEM                                ]]--

function SIL:UNIT_INVENTORY_CHANGED (unitId)
  local unit = self:GetUnitKey (unitId)
  if self.unitTrackers[unit] then
    for display, tracker in pairs (self.unitTrackers[unit]) do
      if not UnitIsUnit (tracker.unitId, unitId) then
        self.trackers[display] = nil
        self.unitTrackers[unit][display] = nil
      else
        if self:ProbeUnitData (unitId) then
          local data = self:GetUnitDataRaw (unitId)
          if not tracker.handler (self, unitId, display, data, true) then
            self.trackers[display] = nil
            self.unitTrackers[unit][display] = nil
          end
        end
      end
    end
  end
end
function SIL:ReInspect (unitId)
  self.inspectTimeout = 0.5
  self.inspectUnit = unitId
  if self.failUnit == unitId then
    self.failCount = (self.failCount or 0) + 1
  else
    self.failCount = 1
    self.failUnit = unitId
  end
  if self.failCount > 5 then
    self.inspectUnit = nil
  end
end
function SIL:OnUpdate (elapsed)
  if self.inspectTimeout then
    self.inspectTimeout = self.inspectTimeout - elapsed
    if self.inspectTimeout < 0 then
      self.inspectTimeout = nil
    end
  end
  if not self.inspectTimeout and self.inspectUnit and self:CanInspect () and CanInspect (self.inspectUnit) then
    local unitId = self.inspectUnit
    self.inspectUnit = nil
    NotifyInspect (unitId)
    local unit = self:GetUnitKey (unitId)
    if self.unitTrackers[unit] then
      for display, tracker in pairs (self.unitTrackers[unit]) do
        if not UnitIsUnit (tracker.unitId, unitId) then
          self.trackers[display] = nil
          self.unitTrackers[unit][display] = nil
        else
          if self:ProbeUnitData (unitId) then
            local data, empty = self:GetUnitDataRaw (unitId)
            if not tracker.handler (self, unitId, display, data, true) then
              self.trackers[display] = nil
              self.unitTrackers[unit][display] = nil
            elseif empty then
              self:ReInspect (unitId)
            end
          else
            self:ReInspect (unitId)
          end
        end
      end
    end
  end
end
function SIL:AddTracker (unitId, display, handler)
  local unit = self:GetUnitKey (unitId)
  if not unit then
    return
  end
  if self.trackers[display] then
    local other = self.trackers[display].unit
    if self.unitTrackers[other] then
      self.unitTrackers[other][display] = nil
    end
  end
  self.trackers[display] = {
    unitId = unitId,
    unit = unit,
    handler = handler
  }
  self.unitTrackers[unit] = self.unitTrackers[unit] or {}
  self.unitTrackers[unit][display] = self.trackers[display]
  local data, real
  if unitId == "player" then
    data = self:GetUnitDataRaw (unitId)
    real = true
  else
    if InspectFrame and InspectFrame:IsShown () and InspectFrame.unit == unitId then
      data = self:GetUnitDataRaw (unitId)
      real = true
    end
    self.inspectUnit = unitId
  end
  if not data and self.db then
    data = self.db.players[key]
    real = false
  end
  if data then
    if not handler (self, unitId, display, data, real) then
      self.trackers[display] = nil
      self.unitTrackers[unit][display] = nil
    end
  end
end

--[[                                 INTERFACE HOOKS                                  ]]--

function SIL:UpdateHooks ()
  self.hooks = self.hooks or {}
  self.objecthooks = self.objecthooks or {}
  self.objecthooked = self.objecthooked or {}
  self.scripthooks = self.scripthooks or {}
  self.scripthooked = self.scripthooked or {}
  
  for funcname, hookfunc in pairs (self.hooks) do
    if type (_G[funcname]) == "function" then
      hooksecurefunc (funcname, hookfunc)
      self.hooks[funcname] = nil
    end
  end
  for objectname, hooklist in pairs (self.objecthooks) do
    local object = _G[objectname]
    if type (object) == "table" and not self.objecthooked[object] then
      self.objecthooked[object] = true
      for funcname, hookfunc in pairs (hooklist) do
        if type (object[funcname]) == "function" then
          hooksecurefunc (object, funcname, hookfunc)
        end
      end
    end
  end
  for objectname, hooklist in pairs (self.scripthooks) do
    local object = _G[objectname]
    if type (object) == "table" and not self.scripthooked[object] then
      self.scripthooked[object] = true
      for funcname, hookfunc in pairs (hooklist) do
        object:HookScript (funcname, hookfunc)
      end
    end
  end
end
function SIL:AddHook (funcname, hookfunc)
  self.hooks = self.hooks or {}
  self.hooks[funcname] = hookfunc
end
function SIL:AddObjectHook (objectname, funcname, hookfunc)
  self.objecthooks = self.objecthooks or {}
  self.objecthooks[objectname] = self.objecthooks[objectname] or {}
  self.objecthooks[objectname][funcname] = hookfunc
end
function SIL:AddScriptHook (objectname, funcname, hookfunc)
  self.scripthooks = self.scripthooks or {}
  self.scripthooks[objectname] = self.scripthooks[objectname] or {}
  self.scripthooks[objectname][funcname] = hookfunc
end

function SIL:UpdatePlayerTip ()
  if self.playerData then
    CharacterLevelText:SetText (string.format ("%s (iL %.1f)", self.characterText, self.playerData.ilvl))
  end
end
function SIL:OnUpdatePlayer (unit, display, data, real)
  self.playerData = data
  self:UpdatePlayerTip ()
  return true
end

function SIL:UpdateInspectTip ()
  if self.inspectData then
    InspectLevelText:SetText (string.format ("%s (iL %.1f)", self.inspectText, self.inspectData.ilvl))
  end
end
function SIL:OnUpdateInspect (unit, display, data, real)
  if not InspectFrame:IsShown () or not UnitIsUnit (InspectFrame.unit, unit) then
    return false
  end
  self.inspectData = data
  self:UpdateInspectTip ()
  return true
end

function SIL:OnUpdateTooltip (unit, display, data, real)
  if not unit or GameTooltip:IsUnit (unit) then
    local dummy = "~~DUMMY~~"
    if not self.unitTooltipLine then
      GameTooltip:AddLine (dummy, 0.7, 0.7, 1)
      local regions = {GameTooltip:GetRegions ()}
      for _, region in pairs (regions) do
        if region:GetObjectType () == "FontString" and region:GetText () == dummy then
          self.unitTooltipLine = region
          break
        end
      end
    end
    self.unitTooltipLine:SetText ("Item level: " .. self:FormatData (data, real))
    GameTooltip:Show ()
    return true
  end
  return false
end

function SIL:OnGameTooltipSetUnit ()
  self.unitTooltipLine = nil
  local fullname, unit = GameTooltip:GetUnit ()
  if unit then
    self:AddTracker (unit, "GameTooltip", self.OnUpdateTooltip)
  else
    local data = self.db.players[self:GetKeyByName (fullname)]
    if data then
      self:OnUpdateTooltip (nil, nil, data, false)
    end
  end
end

function SIL:OnUnitPopup ()
  if self.unitPopup then
    self.unitPopup = false
    local name = UIDROPDOWNMENU_INIT_MENU.name
    local server = UIDROPDOWNMENU_INIT_MENU.server or GetRealmName ()
    local key = (name and (name .. " - " .. server))
    if key and self.db and self.db.players[key] then
      local info = UIDropDownMenu_CreateInfo ()

      local data = self.db.players[key]
      info.text = "Item level: " .. self:FormatData (data)
      info.notCheckable = 1
      info.notClickable = 1
      UIDropDownMenu_AddButton (info)
    end
  end
end

--[[                                 INIT FUNCTIONS                                   ]]--

function SIL:OnInitialize ()
  -- Apparently InspectFix doesn't like it...
  -- hooksecurefunc ("NotifyInspect", function (unit) self.inspectPending = self:GetUnitKey (unit) end)
  
  self:AddScriptHook ("PaperDollFrame", "OnShow", function ()
    self:AddTracker ("player", "PaperDoll", self.OnUpdatePlayer)
  end)
  self:AddObjectHook ("CharacterLevelText", "SetFormattedText", function (frame)
    self.characterText = frame:GetText ()
    self:UpdatePlayerTip ()
  end)

  self:AddScriptHook ("InspectPaperDollFrame", "OnShow", function ()
    self.inspectData = nil
    self:AddTracker (InspectFrame.unit, "InspectFrame", self.OnUpdateInspect)
  end)
  self:AddObjectHook ("InspectLevelText", "SetFormattedText", function (frame)
    self.inspectText = frame:GetText ()
    self:UpdateInspectTip ()
  end)

  self:AddScriptHook ("GameTooltip", "OnTooltipSetUnit", function ()
    self:OnGameTooltipSetUnit ()
  end)
--[[
  self:AddHook ("UnitPopup_HideButtons", function ()
    self.unitPopup = (UIDROPDOWNMENU_MENU_LEVEL == 1)
  end)
  self:AddHook ("UnitPopup_ShowMenu", function ()
    self.unitPopup = false
  end)
  self:AddHook ("UIDropDownMenu_AddButton", function ()
    self:OnUnitPopup ()
  end)
  ]]
  self:SetScript ("OnUpdate", self.OnUpdate)
end

function SIL:OnCommand (cmd)
  local args = {}
  for w in cmd:gmatch ("[^%s]+") do
    table.insert (args, w:lower ())
  end
  if #args == 0 then
    print ("|cffb2b2ffShowItemLevel Commands:|r")
    print ("  |cffb2b2ff/sil reset yes|r - Resets the database")
    print ("  |cffb2b2ff/sil find <name> [<max>]|r - Find all players containing name, optionally display up to max")
    print ("  |cffb2b2ff/sil <name>|r - Show info about a player")
  elseif args[1] == "reset" then
    if args[2] == "yes" then
      self.db.players = {}
    else
      print ("|cffb2b2ff[SIL]|r|cffffcc00Type '/sil reset yes' to reset the database|r")
    end
  elseif args[1] == "find" and args[2] then
    local name = args[2]
    local count = 0
    local limit = args[3] and tonumber (args[3])
    if limit == nil then
      limit = 10
    end
    for key, data in pairs (self.db.players) do
      if key:lower ():find (name) then
        print ("|cffb2b2ff[SIL]|r " .. self:ColorUnitName (key, data.class) .. ": " .. self:FormatData (data))
        count = count + 1
        if count >= limit then
          print ("|cffb2b2ff(showing first " .. count .. " results|r")
          break
        end
      end
    end
    if count == 0 then
      print ("|cffb2b2ff[SIL]|r|cffffcc00Player " .. args[2] .. " not found|r")
    end
  else
    local key = self:GetFullKey (args[1])
    if self.db.players[key] then
      local data = self.db.players[key]
      print ("|cffb2b2ff[SIL]|r " .. self:ColorUnitName (key, data.class) .. ": " .. self:FormatData (data))
    else
      print ("|cffb2b2ff[SIL]|r|cffffcc00Player " .. args[1] .. " not found|r")
    end
  end
end

--[[                                 BASIC ADDON CODE                                 ]]--

function SIL:OnEvent (event, ...)
  if self[event] then
    self[event] (self, ...)
  end
end
function SIL:ADDON_LOADED (addon)
  if addon == "ShowItemLevel" then
    ShowItemLevelDB = ShowItemLevelDB or {}
    SIL.db = ShowItemLevelDB
    SIL.db.players = SIL.db.players or {}
    self:OnInitialize ()

    SlashCmdList["ShowItemLevel"] = function (cmd) self:OnCommand (cmd) end
    SLASH_ShowItemLevel1 = "/sil"
  end
  self:UpdateHooks ()
end

do
  SIL.inspectText = ""
  SIL.characterText = ""

  SIL.trackers = {}
  SIL.unitTrackers = {}

  local itemSlots = {
    "HeadSlot",
    "NeckSlot",
    "ShoulderSlot",
    "BackSlot",
    "ChestSlot",
    "WristSlot",
    "HandsSlot",
    "WaistSlot",
    "LegsSlot",
    "FeetSlot",
    "Finger0Slot",
    "Finger1Slot",
    "Trinket0Slot",
    "Trinket1Slot",
    "MainHandSlot",
    "SecondaryHandSlot",
    --"RangedSlot"
  }
  SIL.itemSlots = {}
  for i = 1, #itemSlots do
    SIL.itemSlots[i] = GetInventorySlotInfo (itemSlots[i])
  end
end

SIL:SetScript ("OnEvent", SIL.OnEvent)
SIL:RegisterEvent ("ADDON_LOADED")
SIL:RegisterEvent ("UNIT_INVENTORY_CHANGED")
