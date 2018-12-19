---------------------
-- SEE LICENSE.TXT --
---------------------

-------------------
-- SPELL FILTERS --
-------------------
if (not Watcher) then
    return;
end


---------------
-- LIBRARIES --
---------------
local LibDispellable = LibStub:GetLibrary("LibDispellable-1.0");


-------------
-- GLOBALS --
-------------
Watcher.events = {
    --["EVENT_NAME"] = {["usability"] = true,};
};


-------------------
-- LOOKUP TABLES --
-------------------
Watcher.spellFilterFunctions = {
    ["usability"] = function(spellId, filterSetId, filterId) return Watcher:CheckUsability(spellId, filterSetId, filterId) end,
    ["auras"] = function(spellId, filterSetId, filterId) return Watcher:CheckAura(spellId, filterSetId, filterId) end,
    ["power"] = function(spellId, filterSetId, filterId) return Watcher:CheckPower(spellId, filterSetId, filterId) end,
    ["secondaryResource"] = function(spellId, filterSetId, filterId) return Watcher:CheckSecondaryResource(spellId, filterSetId, filterId) end,
    ["health"] = function(spellId, filterSetId, filterId) return Watcher:CheckHealth(spellId, filterSetId, filterId) end,
    --["timeToLive"] = function(spellId, filterSetId, filterId) return Watcher:CheckTimeToLive(spellId, filterSetId, filterId) end,
    ["classification"] = function(spellId, filterSetId, filterId) return Watcher:CheckClassification(spellId, filterSetId, filterId) end,
    ["targetAura"] = function(spellId, filterSetId, filterId) return Watcher:CheckTargetAura(spellId, filterSetId, filterId) end,
    ["targetCastingInterruptable"] = function(spellId, filterSetId, filterId) return Watcher:CheckTargetCastingInterruptable(spellId, filterSetId, filterId) end,
    --["aoe"] = function(spellId, filterSetId, filterId) return Watcher:CheckAOE(spellId, filterSetId, filterId) end,
    ["totem"] = function(spellId, filterSetId, filterId) return Watcher:CheckTotem(spellId, filterSetId, filterId) end,
    ["spec"] = function(spellId, filterSetId, filterId) return Watcher:CheckSpellSpec(spellId, filterSetId, filterId) end,
    ["talent"] = function(spellId, filterSetId, filterId) return Watcher:CheckSpellTalent(spellId, filterSetId, filterId) end,
    ["glyph"] = function(spellId, filterSetId, filterId) return Watcher:CheckSpellGlyph(spellId, filterSetId, filterId) end,
};
Watcher.priorityListFilterFunctions = {
    ["spec"] = function(priorityListId, filterId) return Watcher:CheckSpec(priorityListId, filterId); end,
    ["talent"] = function(priorityListId, filterId) return Watcher:CheckTalent(priorityListId, filterId); end,
    ["glyph"] = function(priorityListId, filterId) return Watcher:CheckGlyph(priorityListId, filterId); end,
};
Watcher.spellFilterEvents = {
    ["usability"] = {
        ["CURRENT_SPELL_CAST_CHANGED"] = {},
        ["SPELL_UPDATE_USABLE"] = {},
        ["UNIT_AURA"] = {"player"},
    },
    ["auras"] = {
        ["UNIT_AURA"] = {"player", "target"},
    },
    ["power"] = {
        ["UNIT_MAXPOWER"] = {"player"},
        ["UNIT_POWER_FREQUENT"] = {"player"},
    },
    ["secondaryResource"] = {
        ["UNIT_MAXPOWER"] = {"player"},
        ["UNIT_POWER_FREQUENT"] = {"player"},
        ["RUNE_POWER_UPDATE"] = {},
        ["RUNE_TYPE_UPDATE"] = {},
        ["UNIT_COMBO_POINTS"] = {},
    },
    ["health"] = {
        ["UNIT_HEALTH_FREQUENT"] = {"player", "target"},
    },
    ["targetAura"] = {
        ["UNIT_AURA"] = {"target"},
    },
    ["targetCastingInterruptable"] = {
        ["UNIT_SPELLCAST_INTERRUPTIBLE"] = {"target"},
        ["UNIT_SPELLCAST_NOT_INTERRUPTIBLE"] = {"target"},
        ["UNIT_SPELLCAST_CHANNEL_START"] = {"target"},
        ["UNIT_SPELLCAST_CHANNEL_STOP"] = {"target"},
        ["UNIT_SPELLCAST_CHANNEL_UPDATE"] = {"target"},
        ["UNIT_SPELLCAST_DELAYED"] = {"target"},
        ["UNIT_SPELLCAST_INTERRUPTED"] = {"target"},
        ["UNIT_SPELLCAST_START"] = {"target"},
        ["UNIT_SPELLCAST_STOP"] = {"target"},
        ["UNIT_SPELLCAST_SUCCEEDED"] = {"target"},
    },
    ["totem"] = {
        ["PLAYER_TOTEM_UPDATE"] = {},
    },
    ["spec"] = {
        ["ACTIVE_TALENT_GROUP_CHANGED"] = {},
    },
    ["talent"] = {
        ["CHARACTER_POINTS_CHANGED"] = {},
    },
    ["glyph"] = {
        ["GLYPH_ADDED"] = {},
        ["GLYPH_DISABLED"] = {},
        ["GLYPH_ENABLED"] = {},
        ["GLYPH_REMOVED"] = {},
        ["GLYPH_UPDATED"] = {},
    },
};
Watcher.bucketTimers = {
    --[[
    ["filterType"] = aceTimerID,
    --]]
};
Watcher.buckets = {
    --[[
    ["filterType"] = 0
    --]]
};

----------------------
-- EVALUATE FILTERS --
----------------------
function Watcher:EvaluatePriorityListFilters()
    for priorityListId, priorityList in pairs(self.db.char.priorityLists) do
        local evaluate = true;
        for filterId, filter in pairs(priorityList.filters) do
            evaluate = evaluate and self.priorityListFilterFunctions[filter.filterType](priorityListId, filterId);
        end

        if (evaluate) then
            self.activePriorityList = priorityListId;
            self:UnregisterFilterEvents();
            self:RegisterFilterEvents();
            return;
        end
    end
end

function Watcher:EvaluateSpellFilter(spellId, filterSetId, filterType)
    local evaluate = 0;
    local results = {}

    for filterId, filter in pairs(self.db.char.filterSets[filterSetId].filters) do
        if ((not filterType) or (filterType == filter.filterType)) then
            local filterResult = self.spellFilterFunctions[filter.filterType](spellId, filterSetId, filterId);
            results[filter.filterType] = filterResult;

            if ((not filterResult) or (not evaluate)) then
                evaluate = nil;
            else
                evaluate = math.max(evaluate, filterResult);
            end
        end
    end

    return evaluate, results;
end

function Watcher:EvaluateEvent(eventName, firstArg)
    if (self.events[eventName]) then
        for filterType, exists in pairs(self.events[eventName]) do
            if (self.spellFilterEvents[filterType][eventName]) then
                if (table.getn(self.spellFilterEvents[filterType][eventName]) ~= 0) then
                    -- check args for first arg match
                    for i, arg in pairs(self.spellFilterEvents[filterType][eventName]) do
                        if (firstArg == arg) then
                            -- arg check successful, pass it on
                            self:AddToBucket(filterType);
                        end
                    end
                else
                    -- no arg check, pass it on
                    self:AddToBucket(filterType);
                end
            end
        end
    end
end


----------------------
-- EVENT THROTTLING --
----------------------
function Watcher:AddToBucket(filterType)
    if (not self.buckets[filterType]) then
        self.buckets[filterType] = 1;
        self:BucketTriggered(filterType);
    else
        self.buckets[filterType] = self.buckets[filterType] + 1;
    end
end

function Watcher:BucketTriggered(filterType)
    if (self.buckets[filterType] and (self.buckets[filterType] == 0)) then
        --empty bucket, clean up
        self.bucketTimers[filterType] = nil;
        self.buckets[filterType] = nil;
        return;
    end

    -- something in bucket, update
    self:UpdateByFilterType(filterType);

    -- empty bucket and reschedule timer
    self.buckets[filterType] = 0;
    self.bucketTimers[filterType] = self:ScheduleTimer("BucketTriggered", .05, filterType);
end


------------
-- EVENTS --
------------
function Watcher:RegisterFilterEvents()
    if (self.activePriorityList) then
        local priorityList = self.db.char.priorityLists[self.activePriorityList];
        for priorityNum, spellCondition in ipairs(priorityList.spellConditions) do
            for filterId, filter in pairs(self.db.char.filterSets[spellCondition.filterSetId].filters) do
                if (self.spellFilterEvents[filter.filterType]) then
                    for eventName, argsTable in pairs(self.spellFilterEvents[filter.filterType]) do
                        if (not self.events[eventName]) then
                            -- event not registered yet
                            self.events[eventName] = {};
                            self:RegisterEvent(eventName, "EvaluateEvent");
                        end
                        self.events[eventName][filter.filterType] = true;
                    end
                end
            end
        end
    end
end

function Watcher:UnregisterFilterEvents()
    self:CancelAllTimers();
    if (next(self.events)) then
        for eventName, filterTypeTable in pairs(self.events) do
            self:UnregisterEvent(eventName);
        end
        self.events = {};
        self.bucketTimers = {};
        self.buckets = {};
    end
end


------------
-- HELPER --
------------
function Watcher:CheckForFilterType(filterSetId, filterType)
    for filterId, filter in pairs(self.db.char.filterSets[filterSetId].filters) do
        if (filterType == filter.filterType) then
            return true;
        end
    end

    return false;
end


-------------------
-- SPELL FILTERS --
-------------------
-- these functions return math.huge if the filter is not met; a number meaning expireTime/metTime; and 0 for met now
-- basically these return the time that spell can be used (as related to GetTime()). 0 for met now; nil for never/false;
function Watcher:CheckUsability(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local startTime, duration, enabled = GetSpellCooldown(spellId);

    -- check usability
    if ((not IsUsableSpell(spellId))
     and (not filter.ignore)
	 and ((startTime == 0) or (((startTime + duration) - GetTime()) < 1.5))) then
		return;
	end

    if(enabled == 0) then
      return;
	end

	if((GetSpellBaseCooldown(spellId) ~= 0) and ((UnitCastingInfo("player")) and (UnitCastingInfo("player") == GetSpellInfo(spellId)))) then
        return;
    end

    -- check cooldown
    if (startTime ~= 0) then
        return (startTime + duration);
    end

    return 0;
end

function Watcher:CheckAura(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];

    -- need to check if the aura exists on the correct unit with the correct unitAuraFilter
    local unitAuraFilter = "";
    if (filter.playerIsCaster) then
        unitAuraFilter = "PLAYER|";
    end

    -- if buff, then aura is on player, if not, it's on target
    -- buffs are helpful and debuffs are harmful
    local unit;
    if (filter.isBuff) then
        unit = "player";
        unitAuraFilter = unitAuraFilter.."HELPFUL";
    else
        unit = "target";
        unitAuraFilter = unitAuraFilter.."HARMFUL";
    end

    -- apply our unitAuraFilter and go
    local name, _, _, count, _, _, expirationTime = UnitAura(unit, filter.auraName, nil, unitAuraFilter);

    if (name) then
        -- check count
        if ((filter.stackCount == 0) or ((filter.invert and ((count >= filter.stackCount)) or ((not filter.invert) and (count < filter.stackCount))))) then
            -- let's check remaining time
            if (not filter.invert) then
                triggerTime = expirationTime - filter.refreshThreshold;

                if (triggerTime < 0) then
                    triggerTime = 0;
                end

                return triggerTime;
            else
                return 0;
            end
        end
    elseif ((not name) and (not filter.invert)) then
        --doesn't exist and looking for the lack of existance
        return 0;
    end
end

function Watcher:CheckPower(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];

    -- TODO: implement keep enough resources
    -- TODO: implement time until power percent

    if (filter.invert) then
        if (self:GetPowerPercent("player") <= filter.threshold/100) then
            return 0;
        end
    else
        if (self:GetPowerPercent("player") >= filter.threshold/100) then
            return 0;
        end
    end
end

function Watcher:CheckSecondaryResource(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local value = self:GetSecondaryResource(filter.resourceType);

    if (filter.resourceType and filter.relationship and filter.value) then
        if (filter.relationship == "At Least") then
            if (filter.value <= value) then
                return 0;
            end
        elseif (filter.relationship == "At Most") then
            if (filter.value >= value) then
                return 0;
            end
        elseif (filter.relationship == "Equals") then
            if (filter.value == value) then
                return 0;
            end
        end
    end
end

function Watcher:CheckHealth(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];

    -- TODO: implement time until health percent

    local unit = "target";

    if (filter.player) then
        unit = "player";
    end

    if (filter.invert) then
        if (self:GetHealthPercent(unit) >= filter.threshold/100) then
            return 0;
        end
    else
        if (self:GetHealthPercent(unit) <= filter.threshold/100) then
            return 0;
        end
    end
end

function Watcher:CheckTimeToLive(spellId, filterSetId, filterId) -- TODO
end

function Watcher:CheckClassification(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local unitClassification = UnitClassification("target");

    if (filter.relationship == "At Least") then
        if (self.unitClassificationsValues[filter.value] <= self.unitClassificationsValues[unitClassification]) then
            return 0;
        end
    elseif (filter.relationship == "At Most") then
        if (self.unitClassificationsValues[filter.value] >= self.unitClassificationsValues[unitClassification]) then
            return 0;
        end
    elseif (filter.relationship == "Equals") then
        if (self.unitClassificationsValues[filter.value] == self.unitClassificationsValues[unitClassification]) then
            return 0;
        end
    end
end

function Watcher:CheckTargetAura(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local i = 1;

    local name, dispelType, isStealable, _;

    repeat
        name, _, _, _, dispelType, _, _, _, isStealable, _, auraSpellId = UnitAura("target", i);

        if (name and ((not filter.useWhitelist) or filter.whitelist[name])) then
            if (UnitIsEnemy("player", "target") and filter.stealable and isStealable) then
                return 0;
            end

            if (LibDispellable:CanDispelWith("target", spellId)) then
                return 0;
            end
        end

        i = i + 1;
    until (not name)

end

function Watcher:CheckTargetCastingInterruptable(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local name, _, _, _, _, _, _, _, notInterruptible = UnitCastingInfo("target");

    if (filter.useWhitelist) then
        if (not filter.whitelist[name]) then
            return;
        end
    end

    if (name and not notInterruptible) then
        return 0;
    end
end

function Watcher:CheckAOE(spellId, filterSetId, filterId) -- TODO
end

function Watcher:CheckTotem(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local haveTotem, name, startTime, duration, icon = GetTotemInfo(filter.slot);
    local expireTime = 0;

    if (filter.exists and not haveTotem) then
        return;
    elseif (not filter.exists and not haveTotem) then
        return expireTime;
    end

    if ((filter.name ~= "") and not (name == filter.name)) then
        return;
    end

    expireTime = startTime + duration

    if (filter.refreshThreshold > 0) then
        expireTime = (expireTime - filter.refreshThreshold);
        if (expireTime < 0) then
            expireTime = 0;
        end
    end

    return expireTime;
end

function Watcher:CheckSpellSpec(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];

    if (filter.specNum == GetSpecialization()) then
        return 0;
    end
end

function Watcher:CheckSpellTalent(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];
    local _, _, _, _, selected, _ = GetTalentInfo(filter.talentNum);

    if (selected) then
        return 0;
    end
end

function Watcher:CheckSpellGlyph(spellId, filterSetId, filterId)
    local filter = self.db.char.filterSets[filterSetId].filters[filterId];

    for i = 1, GetNumGlyphSockets() do
        local _, _, _, glyphSpellId, _ = GetGlyphSocketInfo(i);
        if (glyphSpellId == filter.glyphSpellId) then
            return 0;
        end
    end
end


---------------------------
-- PRIORITY LIST FILTERS --
---------------------------
-- these functions return false if not met or true if met
function Watcher:CheckSpec(priorityListId, filterId)
    local filter = self.db.char.priorityLists[priorityListId].filters[filterId];

    return (filter.specNum == GetSpecialization());
end

function Watcher:CheckTalent(priorityListId, filterId)
    local filter = self.db.char.priorityLists[priorityListId].filters[filterId];

    local _, _, _, _, selected, _ = GetTalentInfo(filter.talentNum);

    return selected;
end

function Watcher:CheckGlyph(priorityListId, filterId)
    local filter = self.db.char.priorityLists[priorityListId].filters[filterId];

    for i = 1, GetNumGlyphSockets() do
        local _, _, _, glyphSpellId, _ = GetGlyphSocketInfo(i);
        if (glyphSpellId == filter.glyphSpellId) then
            return true;
        end
    end

    return false;
end
