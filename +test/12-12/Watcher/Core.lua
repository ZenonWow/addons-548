---------------------
-- SEE LICENSE.TXT --
---------------------

---------------
-- LIBRARIES --
---------------
local AceAddon = LibStub("AceAddon-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("Watcher");
local media = LibStub:GetLibrary("LibSharedMedia-3.0");


----------
-- CORE --
----------
Watcher = AceAddon:NewAddon("Watcher", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");


-------------
-- GLOBALS --
-------------
Watcher.activePriorityList = nil;


-----------------------------
-- DEFAULT SAVED VARIABLES --
-----------------------------
Watcher.defaults = {
	global = {
		--version is to be used to handle structural changes made by addon developers.
		version = 0
	},
    char = {
        enable = true,



		-- position settings
        unlocked = false,
        point = "CENTER",
        relativeTo = "UIParent",
        relativePoint = "CENTER",
        xOffset = 0,
        yOffset = -200,

        -- visiblity settings
        showOnlyInCombat = false,
        showOnlyOnAttackableTarget = true,
        showInRaid = true,
        showInParty = true,
        showWhilePVP = true,
        showWhileSolo = true,

        -- display settings
        iconAlpha = 1,
        backgroundAlpha = 0.6,
        iconFont = "Friz Quadrata TT",
        iconFontEffect = "OUTLINE",
        iconFontSize = 24,
        scale = 1,
        textAnchor =  "center",
        growDir = "right",
        showCooldownText = true,
        showLabel = true,
        iconSize = 50,
        labelColor = {r = 1, g = 1, b = 1, a = 1},
        labelVertPos = 0,
        labelHoriPos = 0,
        numIcons = 12,

        -- timeline settings
        maxStackedIcons = 3;
        stackHeight = .3;
        showIncrementText = true,
        timeIncrements = {},
        timeSegmentWidth = 50,
        barFontSize = 12,


        -- indexed by spellId
        spells = {
            ['*'] = {
                settings = {
                    label = "",
                    keepEnoughResources = false,
                },
                filterSetIds = {},
            },
        },

        -- indexed by filterSetId which will just be number incremented up
        filterSets = {
            ['*'] = {
                name = "",
                spellId = 0,
                settings = {
                },
                filters = {
                    ['*'] = {
                        filterType = "", -- filters are documented in Filter.lua
                    },
                },
            },
        },

        -- indexed by priorityListId which is just a number incremented up
        priorityLists = {
            ['*'] = {
                name = "",
                spellConditions = {},
                settings = {
                },
                filters = {
                    ['*'] = {
                        filterType = "", -- filters are documented in Filter.lua
                    },
                },
            },
        },
    },

	class = {
	}
}


----------------
-- SETUP/INIT --
----------------
function Watcher:OnInitialize()
    -- Setup database and register defaults
    self.db = LibStub("AceDB-3.0"):New("WatcherDB", Watcher.defaults, "char");
    -- self.WatcherSerializer = LibStub("AceAddon-3.0"):NewAddon("WatcherSerializer", "AceSerializer-3.0");
    -- self.WatcherSerializer = self:NewModule("WatcherSerializer", "AceSerializer-3.0");

    -- Get versioning information
    self.version = GetAddOnMetadata("Watcher", "Version");
    self.generalOptions.name = self.generalOptions.name.." "..self.version;

    -- register options
    Watcher:RegisterOptions(); -- TODO: move into load on demand module to reduce memory usage

    self:RegisterChatCommand("watcher", "HandleChatCommand");
    self:RegisterChatCommand("watch", "HandleChatCommand");
    self:RegisterChatCommand("Watcher", "HandleChatCommand");

    if (not self.db.char.enable) then
        self:Disable();
    end
end

function Watcher:OnEnable()
	self.db.char.enable = true;

    -- create default spec priority lists
    -- TODO: more elegant default system
    if ((not self.db.char.priorityLists) or (not next(self.db.char.priorityLists))) then
        self:GetDefaultPriorityListsSpellsAndFilterSets();
	end


	--Wrong version of watcher, delete profile info
	if((not self.db.char.version)) then

	elseif(self.db.char.version <  self.db.global.version) then
		self:MigrateProfileToNewStructure();
	elseif(self.db.char.version >  self.db.global.version) then
		--Well this should not happen..
		--TODO
		--Tell user there is a problem with versions and give the option to reset to default
	end

    -- Register events
    self:RegisterEvent("PLAYER_REGEN_ENABLED");
    self:RegisterEvent("PLAYER_REGEN_DISABLED");
    self:RegisterEvent("PLAYER_TALENT_UPDATE");

    self:RegisterEvent("PLAYER_ENTERING_WORLD", "SetupPriorityFrame");
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "SetupPriorityFrame");

    self:RegisterEvent("RAID_ROSTER_UPDATE", "ShowHidePriorityFrame");
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", "ShowHidePriorityFrame");

    if (not self.db.char.timeIncrements or table.getn(self.db.char.timeIncrements) == 0) then
        self:ResetTimeSegments();
    end

    self:EvaluatePriorityListFilters();

    self:SetupPriorityFrame();
end

function Watcher:GetDefaultPriorityListsSpellsAndFilterSets()

    -- get class
	local className = UnitClass("player");

	--Save to characters own
	local classDefaults = Watcher.defaults.class[className];

	self.db.char.priorityLists = classDefaults.priorityLists;
	self.db.char.filterSets = classDefaults.filterSets;
	self.db.char.spells = classDefaults.spells;

        local specs = self:GetSpecList();
        for k, v in pairs(specs) do
            if (v == name) then
                -- add spec filter for the spec
                (self:AddNewPriorityListFilter("spec", priorityListId)).specNum = k;
            end
        end

        self:InjectPriorityOptions();

end

function Watcher:OnDisable()
    self.db.char.enable = false;

    -- Register events
    self:UnregisterEvent("PLAYER_REGEN_ENABLED");
    self:UnregisterEvent("PLAYER_REGEN_DISABLED");

    self:UnregisterEvent("PLAYER_TALENT_UPDATE");
    self:UnregisterEvent("PLAYER_TARGET_CHANGED");

    self:UnregisterEvent("RAID_ROSTER_UPDATE");
    self:UnregisterEvent("PARTY_MEMBERS_CHANGED");

    self:UnregisterFilterEvents();

    self.activePriorityList = false;

    self:SetupPriorityFrame();
end

function Watcher:HandleChatCommand(input)
    if (not input or (input:trim() == "")) then
        InterfaceOptionsFrame_OpenToCategory("Watcher");
        InterfaceOptionsFrame_OpenToCategory("Watcher");
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(Watcher, "watcher", "Watcher", input)
    end
end

function Watcher:Reset()
    self.db:ResetDB();
    self:ResetTimeSegments();
    ReloadUI();
end



-----------------
-- MISC/HELPER --
-----------------
function Watcher:GetDurationString(duration)
    local durationString = (("%1.1f"):format(duration % 120));

    -- check and correct durationString for more than 2 minutes or 2 hours
    if (duration >= 60) then
        duration = floor(duration - (duration % 60)) / 60; -- minutes
        durationString = (duration % 60) .."m ";

        if (duration >= 120) then
            duration = (duration - (duration % 60)) / 60; -- hours
            durationString = (duration + 1).. "h ";
        end
    end

    return durationString;
end

function Watcher:GetHealthPercent(unit)
    return (UnitHealth(unit)/UnitHealthMax(unit));
end

function Watcher:GetPowerPercent(unit)
    return (UnitPower(unit)/UnitPowerMax(unit));
end

function Watcher:GetSecondaryResource(resourceType)
    -- [-1] = L["Combo Points (Druid) (Rogue)"],
    -- [-2] = L["Death Runes (Death Knight)"],
    -- [-3] = L["Blood Runes (Death Knight)"],
    -- [-4] = L["Frost Runes (Death Knight)"],
    -- [-5] = L["Unholy Runes (Death Knight)"],
	-- [7] = L["Soul Shards (Warlock)"],
    -- [8] = L["Eclipse (Druid)"],
    -- [9] = L["Holy Power (Paladin)"],
    -- [12] = L["Chi (Monk)"],
	-- [13] = L["Shadow Orbs (Priest)"],
    -- [14] = L["Burning Embers (Warlock)"],
    -- [15] = L["Demonic Fury (Warlock)"],

    if (resourceType > 0) then
        return UnitPower("player", resourceType);
    elseif (resourceType == -5) then
        -- unholy runes
        local numActive = 0;
        for i = 1, 6 do
            if (GetRuneType(i) == 2) then
                numActive = numActive + GetRuneCount(i);
            end
        end
        return numActive;
    elseif (resourceType == -4) then
        -- frost runes
        local numActive = 0;
        for i = 1, 6 do
            if (GetRuneType(i) == 3) then
                numActive = numActive + GetRuneCount(i);
            end
        end
        return numActive;
    elseif (resourceType == -3) then
        -- blood runes
        local numActive = 0;
        for i = 1, 6 do
            if (GetRuneType(i) == 1) then
                numActive = numActive + GetRuneCount(i);
            end
        end
        return numActive;
    elseif (resourceType == -2) then
        -- death runes
        local numActive = 0;
        for i = 1, 6 do
            if (GetRuneType(i) == 4) then
                numActive = numActive + GetRuneCount(i);
            end
        end
        return numActive;
    elseif (resourceType == -1) then
        return GetComboPoints("player", "target");
    end
end

function Watcher:GetSecondaryResourceList()
    local secondaryResourceList = {};
    local class = UnitClass("player"); -- there are other returns, but all we care about is localized name

    for k, v in pairs(self.resourceTypes) do
        if (string.find(v, "("..class..")")) then
            secondaryResourceList[k] = v;
        end
    end

    return secondaryResourceList;
end

function Watcher:CheckClassSecondaryResource()
    local secondaryResourceList = self:GetSecondaryResourceList();

    for k, v in pairs(secondaryResourceList) do
        return false;
    end

    return true;
end

function Watcher:GetSpecList()
    local specList = {};

    for i = 1, GetNumSpecializations() do
        local _, name = GetSpecializationInfo(i); -- there are other returns, only care about name
        specList[i] = name;
    end

    return specList;
end

function Watcher:GetTalentList()
    local talentList = {};

    for i = 1, GetNumTalents() do
        name = GetTalentInfo(i); -- there are other returns, only care about name
        talentList[i] = name;
    end

    return talentList;
end

function Watcher:GetGlyphList()
    local glyphList = {};

    for i = 1, GetNumGlyphs() do
        local name, _, _, _, spellId = GetGlyphInfo(i);
        if (spellId) then
            glyphList[spellId] = name;
        end
    end

    return glyphList;
end

function Watcher:GetSpellIdFromName(name)
    local spellLink = GetSpellLink(name);
    local spellId;

    if (spellLink) then
        local i, j = string.find(spellLink, "spell:(%d+)");
        spellId = tonumber(string.sub(spellLink, i+6, j));
    end

    return spellId
end

function Watcher:GetFontList()
    local fonts = {};

    -- get fonts
    for k, v in pairs(media:List("font")) do
        fonts[v] = v;
    end

    return fonts;
end


--------------------
-- EVENT HANDLING --
--------------------
function Watcher:PLAYER_REGEN_DISABLED()
    self:ShowHidePriorityFrame(true);
end

function Watcher:PLAYER_REGEN_ENABLED()
    self:ShowHidePriorityFrame(false);
end

function Watcher:PLAYER_TALENT_UPDATE()
    self:EvaluatePriorityListFilters();
    self:SetupPriorityFrame();
end


------------
-- SPELLS --
------------
function Watcher:AddNewSpell(spellId)
    if (spellId and tonumber(spellId)) then
        -- TODO: get rid of hack here and figure it out
        if (not (self.db.char.spells[spellId] and (table.getn(self.db.char.spells[spellId].filterSetIds) > 0))) then
            self.db.char.spells[spellId] = {
                settings = {
                    label = "",
                    keepEnoughResources = false,
                },
                filterSetIds = {},
            };

            -- add default condition
            self:AddNewFilterSet(L["Usable"], spellId);

            self.configurationSelections.spellId = spellId;
        end
    end
end

function Watcher:GetSpellList()
    local spellList = {};

    -- get all of the spells names
    for k, v in pairs(self.db.char.spells) do
        if (tonumber(k)) then
            spellList[k] = GetSpellInfo(k); -- first return is name
        end
    end

    return spellList;
end

function Watcher:RemoveSpell(spellId)
    if (spellId and self.db.char.spells[spellId]) then
        -- remove all of the filters sets associated
        for k, v in pairs(self.db.char.spells[spellId].filterSetIds) do
            self:RemoveFilterSet(k);
        end

        self.db.char.spells[spellId].settings = nil;
        self.db.char.spells[spellId].filterSetIds = nil;
        self.db.char.spells[spellId] = nil;

        if (spellId == self.configurationSelections.spellId) then
            self.configurationSelections.spellId = next(self.db.char.spells);
        end

        for priorityListID, priorityList in pairs(self.db.char.priorityLists) do
            for i, spellCondition in ipairs(self.db.char.priorityLists[priorityListID].spellConditions) do
                if (spellCondition.spellId == spellId) then
                    table.remove(self.db.char.priorityLists[priorityListID].spellConditions, i);
                    self:InjectPriorityOptions();
                end
            end
        end

        LibStub("AceConfigRegistry-3.0"):NotifyChange("Watcher");
    end
end


-------------------
-- SPELL FILTERS --
-------------------
function Watcher:AddNewFilterSet(name, spellId)
    if (name and (name ~= "") and spellId and (spellId > 0) and (self.db.char.spells[spellId])) then
        -- valid input

        -- make new id and set it to the spell
        local newId = table.getn(self.db.char.filterSets) + 1;
        self.db.char.spells[spellId].filterSetIds[newId] = true;

        self.db.char.filterSets[newId]= {};
		self.db.char.filterSets[newId].name = name;
        self.db.char.filterSets[newId].spellId = spellId;
        self.db.char.filterSets[newId].settings = {};
        self.db.char.filterSets[newId].filters = {};

        Watcher:AddFilter("usability", newId);

        self.configurationSelections.filterSetId = newId;
        self:InjectFilterOptions();
    end
end

function Watcher:GetFilterSets(spellId)
    local conditionList = {};

    if (self.db.char.spells[spellId]) then
        -- get all of the filterSets attached to spellId and their names
        for k, v in pairs(self.db.char.spells[spellId].filterSetIds) do
            conditionList[k] = self.db.char.filterSets[k].name;
        end
    end

    return conditionList;
end

function Watcher:RemoveFilterSet(filterSetId)
    if (filterSetId and (self.db.char.filterSets[filterSetId])) then
        local spellId = self.db.char.filterSets[filterSetId].spellId;
        self.db.char.spells[spellId].filterSetIds[filterSetId] = nil;
        self.db.char.filterSets[filterSetId] = nil;

        if (self.configurationSelections.filterSetId == filterSetId) then
            self.configurationSelections.filterSetId = next(self.db.char.spells[spellId].filterSetIds);
        end

        for priorityListID, priorityList in pairs(self.db.char.priorityLists) do
            for i, spellCondition in ipairs(self.db.char.priorityLists[priorityListID].spellConditions) do
                if (spellCondition.filterSetId == filterSetId) then
                    table.remove(self.db.char.priorityLists[priorityListID].spellConditions, i);
                    self:InjectPriorityOptions();
                end
            end
        end

        self:InjectFilterOptions();
    end
end

function Watcher:AddFilter(filterType, filterSetId)
    local conditionFilterDefaults = {
        ["usability"] = {
            ignore = false,
        },
        ["auras"] = {
            invert = false,
            auraName = "",
            isBuff = false,
            refreshThreshold = 0,
            playerIsCaster = true,
            stackCount = 0,
        },
        ["power"] = {
            threshold = 0,
            invert = false,
        },
        ["secondaryResource"] = {
            resourceType = 0, -- look at http://www.wowwiki.com/PowerType, as well as specific runes and combo points
            relationship = "At Least", -- accepted values 'At Least', 'At Most', 'Equals'
            value = 0,
        },
        ["health"] = {
            threshold = 0,
            invert = false,
            player = false,
        },
        ["timeToLive"] = {
            value = 0,
            invert = false,
        },
        ["classification"] = {
            value = "normal", -- look at http://www.wowwiki.com/API_UnitClassification for acceptible values
            relationship = "At Least", -- accepted values 'At Least', 'At Most', 'Equals'
        },
        ["targetAura"] = {
            stealable = false,
            dispellable = false,
            useWhitelist = false,
            whitelist = {},
        },
        ["targetCastingInterruptable"] = {
            useWhitelist = false, -- see http://www.wowwiki.com/API_UnitCastingInfo
            whitelist = {},
        },
        ["aoe"] = {
            activeEnemies = 1,
            relationship = "At Least", -- accepted values 'At Least', 'At Most', 'Equals'
            grouped = false,
        },
        ["totem"] = {
            slot = 1,
            name = "",
            refreshThreshold = 0,
            exists = true,
        },
        ["spec"] = {
            specNum = 1, -- see http://www.wowwiki.com/API_GetSpecialization
        },
        ["talent"] = {
            talentNum = 1, -- see http://www.wowpedia.org/API_GetTalentInfo
        },
        ["glyph"] = {
            glyphSpellId = 0, -- see http://www.wowwiki.com/API_GetGlyphSocketInfo
        },
    };

    if (filterType and conditionFilterDefaults[filterType]) then
        -- make new index
        local i = table.getn(self.db.char.filterSets[filterSetId].filters) + 1;

        self.db.char.filterSets[filterSetId].filters[i] = conditionFilterDefaults[filterType];
        self.db.char.filterSets[filterSetId].filters[i].filterType = filterType;

        Watcher:InjectFilterOptions();
    end
end

function Watcher:GetFilters()
    local filterList = {};

    -- get all of the spells names
    for k, v in pairs(self.spellFilterFunctions) do
        if (k ~= "usability") then
            filterList[k] = L[k];
        end
    end

    return filterList;
end


--------------------
-- PRIORITY LISTS --
--------------------
function Watcher:AddNewPriorityList(name)
    if (name and name ~= "") then
        local priorityListId = (table.getn(self.db.char.priorityLists) or 0) + 1;
        self.db.char.priorityLists[priorityListId] = {};
        self.db.char.priorityLists[priorityListId].name = name;
        self.db.char.priorityLists[priorityListId].filters = {};
        self.db.char.priorityLists[priorityListId].settings = {};
        self.db.char.priorityLists[priorityListId].spellConditions = {};

        local specs = self:GetSpecList();
        for k, v in pairs(specs) do
            if (v == name) then
                -- add spec filter for the spec
                (self:AddNewPriorityListFilter("spec", priorityListId)).specNum = k;
            end
        end

        self:InjectPriorityOptions();
    end
end

function Watcher:AddNewPriorityListFilter(filterType, priorityListId)
    local priorityListFilterDefaults = {
        ["spec"] = {
            specNum = 1, -- see http://www.wowwiki.com/API_GetSpecialization
        },
        ["talent"] = {
            talentNum = 1, -- see http://www.wowpedia.org/API_GetTalentInfo
        },
        ["glyph"] = {
            glyphSpellId = 0, -- see http://www.wowwiki.com/API_GetGlyphSocketInfo
        },
    };

    if (filterType and priorityListFilterDefaults[filterType]) then
        local filterId = table.getn(self.db.char.priorityLists[priorityListId].filters) + 1;
        self.db.char.priorityLists[priorityListId].filters[filterId] = priorityListFilterDefaults[filterType];
        self.db.char.priorityLists[priorityListId].filters[filterId].filterType = filterType;

        return self.db.char.priorityLists[priorityListId].filters[filterId];
    end
end

function Watcher:AddSpellToPriorityList(spellId, filterSetId, priorityListId)
    if (spellId and filterSetId and priorityListId) then
        local newSpell = {};
        newSpell.spellId = spellId;
        newSpell.filterSetId = filterSetId;
		newSpell.name = GetSpellInfo(spellId);


        table.insert(self.db.char.priorityLists[priorityListId].spellConditions, newSpell);

        self:InjectPriorityOptions();
    end
end

function Watcher:SetActivePriorityList(priorityListId)
    self.activePriorityList = priorityListId;
end


--------------------
-- PRETTY PRINT --
--------------------


--[[
   Author: Julio Manuel Fernandez-Diaz
   Date:   January 12, 2007
   (For Lua 5.1)

   Modified slightly by RiciLake to avoid the unnecessary table traversal in tablecount()

   Formats tables with cycles recursively to any depth.
   The output is returned as a string.
   References to other tables are shown as values.
   Self references are indicated.

   The string returned is "Lua code", which can be procesed
   (in the case in which indent is composed by spaces or "--").
   Userdata and function keys and values are shown as strings,
   which logically are exactly not equivalent to the original code.

   This routine can serve for pretty formating tables with
   proper indentations, apart from printing them:

      print(table.show(t, "t"))   -- a typical use

   Heavily based on "Saving tables with cycles", PIL2, p. 113.

   Arguments:
      t is the table.
      name is the name of the table (optional)
      indent is a first indentation (optional).
--]]
function table.show(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   --[[ counts the number of elements in a table
   local function tablecount(t)
      local n = 0
      for _, _ in pairs(t) do n = n+1 end
      return n
   end
   ]]
   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
      local so = tostring(o)
      if type(o) == "function" then
         local info = debug.getinfo(o, "S")
         -- info.name is nil because o is not a calling level
         if info.what == "C" then
            return string.format("%q", so .. ", C function")
         else
            -- the information is defined through lines
            return string.format("%q", so .. ", defined in (" ..
                info.linedefined .. "-" .. info.lastlinedefined ..
                ")" .. info.source)
         end
      elseif type(o) == "number" or type(o) == "boolean" then
         return so
      else
         return string.format("%q", so)
      end
   end

   local function addtocart (value, name, indent, saved, field)
      indent = indent or ""
      saved = saved or {}
      field = field or name

      cart = cart .. indent .. field

      if type(value) ~= "table" then
         cart = cart .. " = " .. basicSerialize(value) .. ";\n"
      else
         if saved[value] then
            cart = cart .. " = {}; -- " .. saved[value]
                        .. " (self reference)\n"
            autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
         else
            saved[value] = name
            --if tablecount(value) == 0 then
            if isemptytable(value) then
               cart = cart .. " = {};\n"
            else
               cart = cart .. " = {\n"
               for k, v in pairs(value) do
                  k = basicSerialize(k)
                  local fname = string.format("%s[%s]", name, k)
                  field = string.format("[%s]", k)
                  -- three spaces between levels
                  addtocart(v, fname, indent .. "   ", saved, field)
               end
               cart = cart .. indent .. "};\n"
            end
         end
      end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
      return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end
