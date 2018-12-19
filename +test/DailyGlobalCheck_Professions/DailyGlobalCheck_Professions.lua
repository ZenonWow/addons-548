-- Daily Global Check - Professions plugin
-- Jadya EU-Well of Eternity
local addonName, addonTable = ...

local low, sfind, sgsub, tinsert = string.lower, string.find, string.gsub, table.insert

local prof_names = {}

DGC_ProfSaves = {}

local pID
local plugintitle = "Professions"
local pluginicon = "Interface\\Icons\\Trade_Alchemy"
local pTable
local profession_cd_ids = {}

-- seal of tempered fate weekly quests
local seal_quests = {36058,36060,37452,37453,36057,37458,37459,36054,37454,37455,36056,37456,37457}

local function get_cache_reset(pid)
 if DGC_ProfSaves[pid] then return
  DGC_ProfSaves[pid].garrison_cache_reset
 end
end

local function calculate_garrison_cache_quantity(pid)
 local t = get_cache_reset(pid)
 
 if not t or t == 0 then return "|cffFF0000"..GM_SURVEY_NOT_APPLICABLE.."|r" end
 
 local result = math.floor((time() - t) / 600)
 if result >= 500 then 
  result = "500 |cffFF0000("..LOC_TYPE_FULL..")|r"
 else
  result = result .. " / 500"
 end
 return result
end

local function isquestcompleted(questID)
 if type(questID) == "number" then
  return IsQuestFlaggedCompleted(questID)
 elseif questID == "seal_of_tempered_fate" then
  local counter = 0
  for _,v in pairs(seal_quests) do
   if IsQuestFlaggedCompleted(v) then counter = counter + 1 end
   if counter == 3 then break end
  end
  return true, counter.." / 3"
 elseif questID == "garrison_cache" then
  local quantity = calculate_garrison_cache_quantity(DailyGlobalCheck.selectedpID)
  return true, quantity
 elseif questID == "profession1" and profession_cd_ids[1] then
  local result = GetSpellCooldown(profession_cd_ids[1])
  return result > 0 and true or false, prof_names[1]
 elseif questID == "profession2" and profession_cd_ids[2] then
  local result = GetSpellCooldown(profession_cd_ids[2])	
  return result > 0 and true or false, prof_names[2]
 end
end

local function onshow()
 local data = DailyGlobalCheck_CharData[DailyGlobalCheck.selectedpID] and DailyGlobalCheck_CharData[DailyGlobalCheck.selectedpID].data
 
 data = data and data["garrison_cache"]

 if not data then return end

 
 data[2] = calculate_garrison_cache_quantity(DailyGlobalCheck.selectedpID)
end

local plugin_data = {
 ["Title"] = plugintitle,
 ["Icon"]  = pluginicon,
 ["Data"]  = {["garrison_cache"] = {GARRISON_LOCATION_TOOLTIP,GARRISON_CACHE,"","",nil,nil,"Q"},
              ["seal_of_tempered_fate"] = {GARRISON_LOCATION_TOOLTIP,"Seal of Tempered Fate","","",nil,nil,"W"},
              ["profession1"] = {"",BATTLE_PET_SOURCE_4..1,"",""},
			  ["profession2"] = {"",BATTLE_PET_SOURCE_4..2,"",""},
			  [37319] = {GARRISON_LOCATION_TOOLTIP,"gem boutique daily","",""}}, -- 37320 37321 37323 37324 37325
 ["Order"] = {
              { -- page 1
               {GARRISON_LOCATION_TOOLTIP,"garrison_cache","seal_of_tempered_fate"},
			   {BATTLE_PET_SOURCE_4,"profession1","profession2",--[[37319]]},
			  },
             },
 ["Overrides"] = {["isquestcompleted"] = isquestcompleted},
 ["OnShow"] = onshow,
 MultiCharsEnabled = true,
}

local function Initialize()
 if not DailyGlobalCheck then return end
 DailyGlobalCheck:LoadPlugin(plugin_data)
 pTable = DailyGlobalCheck_CharData
end

local initialized
local eventframe = CreateFrame("Frame")
eventframe:RegisterEvent("ADDON_LOADED")
eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:RegisterEvent("SHOW_LOOT_TOAST")
local function eventhandler(self, event, ...)
 if event == "ADDON_LOADED" and ... == addonName then
  local pName = GetUnitName("player")
  local pRealm = GetRealmName()
  pID = pName.."-"..pRealm
 
  Initialize()
  initialized = true
 elseif event == "PLAYER_ENTERING_WORLD" then
  if not initialized then Initialize() end
  eventframe:UnregisterEvent("PLAYER_ENTERING_WORLD")
  
  -- seal of fate localization
  local Sname, _, Sicon  = GetCurrencyInfo(994)
  plugin_data["Data"]["seal_of_tempered_fate"][2] = Sname
  plugin_data["Data"]["seal_of_tempered_fate"][3] = "|T"..Sicon..":12|t"

  local p1, p2 = GetProfessions()

   local function addProfession(p, index)
	if p == GetSpellInfo(158758) then -- tailoring
	 profession_cd_ids[index] = 168835
	 prof_names[index] = GetSpellInfo(168835)
	elseif p == GetSpellInfo(158716) then -- enchanting
	 profession_cd_ids[index] = 169092
	 prof_names[index] = GetSpellInfo(169092)
	elseif p == GetSpellInfo(156606) then -- alchemy
	 profession_cd_ids[index] = 156587
	 prof_names[index] = GetSpellInfo(156587)
	elseif p == GetSpellInfo(158748) then -- inscription
	 profession_cd_ids[index] = 169081
	 prof_names[index] = GetSpellInfo(169081)
	elseif p == GetSpellInfo(110403) then -- engineering
	 profession_cd_ids[index] = 169080
	 prof_names[index] = GetSpellInfo(169080)
    elseif p == GetSpellInfo(110423) then -- leatherworking
	 profession_cd_ids[index] = 171391
	 prof_names[index] = GetSpellInfo(171391)
    elseif p == GetSpellInfo(158737) then -- blacksmithing
	 profession_cd_ids[index] = 171690
	 prof_names[index] = GetSpellInfo(171690)
    elseif p == GetSpellInfo(158750) then -- jewelcrafting
	 profession_cd_ids[index] = 170700
	 prof_names[index] = GetSpellInfo(170700)
	end
   end
  
  local pname
  if p1 then
   pname = GetProfessionInfo(p1)
   addProfession(pname, 1)
  end
  if p2 then
   pname = GetProfessionInfo(p2)
   addProfession(pname, 2)
  end
  
 elseif event == "SHOW_LOOT_TOAST" then
  local z = GetZoneText()
  -- not in garrison
  if z ~= GetMapNameByID(971) and z ~= GetMapNameByID(976) then
   return
  end
   
  local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lootSource = ...
  
  if not typeIdentifier or low(typeIdentifier) ~= low(CURRENCY) then return end

  local _, _, Color, Ltype, ID, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name =
  string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
  
  if lootSource == 10 and ID == "824" then
   if not DGC_ProfSaves[pID] then
    DGC_ProfSaves[pID] = {}
   end
   DGC_ProfSaves[pID].garrison_cache_reset = time()
  end
 end
end
eventframe:SetScript("OnEvent", eventhandler)