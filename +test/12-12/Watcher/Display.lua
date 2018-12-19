---------------------
-- SEE LICENSE.TXT --
---------------------

-----------------------
-- DISPLAY AND FRAME --
-----------------------
if (not Watcher) then
    return;
end


---------------
-- LIBRARIES --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("Watcher");
local media = LibStub:GetLibrary("LibSharedMedia-3.0");
local MSQ = LibStub:GetLibrary("Masque", true);


-------------
-- GLOBALS --
-------------
Watcher.SpellIcons = {
    --changedFlag, set if the icon has changed
    --displayTexture, the icon texture set, nil if no texture
    --priorityNum, the number that represents how will stack, nil if not assigned
    --endTime, set if on cooldown or other timing event, 0 or nil if not
};
Watcher.PriorityFrame = CreateFrame("Frame", "Watcher.PriorityFrame", UIParent);
Watcher.IconSpellCache = {};
Watcher.SpellConditionCache = {};
Watcher.filterTypeEvaluateCache = {};

-------------------
-- DISPLAY SETUP --
-------------------
function Watcher:SetupPriorityFrame()
    -- hide if disabled
    if (not self:IsEnabled()) then
        self.PriorityFrame:Hide();
        return;
    end

    -- reset all attributes of the icon
    self.PriorityFrame:ClearAllPoints();
    self.PriorityFrame:SetScale(self.db.char.scale);
    self.PriorityFrame:SetFrameStrata("BACKGROUND");
    self.PriorityFrame:SetAlpha(self.db.char.iconAlpha);

    -- setup width and height for the grow direction
    if (self.db.char.growDir == "right") then
        self.PriorityFrame:SetWidth( Watcher.db.char.timeSegmentWidth * table.getn(self.db.char.timeIncrements));
        self.PriorityFrame:SetHeight(self.db.char.iconSize);
    elseif (self.db.char.growDir == "down") then
        self.PriorityFrame:SetHeight( Watcher.db.char.timeSegmentWidth * table.getn(self.db.char.timeIncrements));
        self.PriorityFrame:SetWidth(self.db.char.iconSize);
    elseif (self.db.char.growDir == "left") then
        self.PriorityFrame:SetWidth( Watcher.db.char.timeSegmentWidth * table.getn(self.db.char.timeIncrements));
        self.PriorityFrame:SetHeight(self.db.char.iconSize);
    elseif (self.db.char.growDir == "up") then
        self.PriorityFrame:SetHeight( Watcher.db.char.timeSegmentWidth * table.getn(self.db.char.timeIncrements));
        self.PriorityFrame:SetWidth(self.db.char.iconSize);
    end

    self.PriorityFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        tile = false,
        tileSize = 0,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    });
    self.PriorityFrame:SetBackdropColor(0, 0, 0, self.db.char.backgroundAlpha);
    self.PriorityFrame:SetMovable(true);
    self.PriorityFrame:RegisterForDrag("LeftButton");
    self.PriorityFrame:SetPoint(self.db.char.point, self.db.char.relativeTo, self.db.char.relativePoint, self.db.char.xOffset, self.db.char.yOffset);
    self.PriorityFrame:SetScript("OnDragStart",
        function()
            self.PriorityFrame:StartMoving();
        end
    );
    self.PriorityFrame:SetScript("OnDragStop",
        function()
            local point, relativeTo, relativePoint, xOffset, yOffset = self.PriorityFrame:GetPoint();
            self.PriorityFrame:StopMovingOrSizing();
            self.db.char.point = point;
            self.db.char.relativeTo = relativeTo;
            self.db.char.relativePoint = relativePoint;
            self.db.char.xOffset = xOffset;
            self.db.char.yOffset = yOffset;
        end
    );

    -- Individual spell icons
    for i = 1, self.db.char.numIcons do
        if (not self.SpellIcons[i]) then
            self.SpellIcons[i] = CreateFrame("Button", "Watcher.SpellIcons["..i.."]", self.PriorityFrame);
        end
        self:SetupSpellIcon(self.SpellIcons[i], i);
    end

    if (not self.PriorityFrame.incrementText) then
        self.PriorityFrame.incrementText = {};
    end

    -- clear text from all text fields
    for k,v in pairs(self.PriorityFrame.incrementText) do
        self.PriorityFrame.incrementText[k]:SetText("");
    end

    -- setup the timeIncrements text
    for i, timeIncrement in ipairs(self.db.char.timeIncrements) do
        if (not self.PriorityFrame.incrementText[i]) then
            self.PriorityFrame.incrementText[i] = Watcher.PriorityFrame:CreateFontString(nil, "OVERLAY");
        end

        self.PriorityFrame.incrementText[i]:SetFont(media:Fetch("font", self.db.char.iconFont), self.db.char.barFontSize, self.db.char.iconFontEffect);
        self.PriorityFrame.incrementText[i]:ClearAllPoints();

        -- set anchors due to growth direction
        if (self.db.char.growDir == "right") then
            self.PriorityFrame.incrementText[i]:SetPoint("CENTER", self.PriorityFrame, "BOTTOMLEFT", Watcher.db.char.iconSize/2 + Watcher.db.char.timeSegmentWidth * (i-1), Watcher.db.char.iconSize/2);
        elseif (self.db.char.growDir == "left") then
            self.PriorityFrame.incrementText[i]:SetPoint("CENTER", self.PriorityFrame, "BOTTOMRIGHT", -Watcher.db.char.iconSize/2 - Watcher.db.char.timeSegmentWidth * (i-1), Watcher.db.char.iconSize/2);
        elseif (self.db.char.growDir == "up") then
            self.PriorityFrame.incrementText[i]:SetPoint("CENTER", self.PriorityFrame, "BOTTOMRIGHT", -(Watcher.db.char.iconSize/2), Watcher.db.char.iconSize/2 + Watcher.db.char.timeSegmentWidth * (i-1));
        elseif (self.db.char.growDir == "down") then
            self.PriorityFrame.incrementText[i]:SetPoint("CENTER", self.PriorityFrame, "TOPRIGHT", -(Watcher.db.char.iconSize/2), -Watcher.db.char.iconSize/2 - Watcher.db.char.timeSegmentWidth * (i-1));
        end

        -- format the text
        self.PriorityFrame.incrementText[i]:SetText(self:GetDurationString(self.db.char.timeIncrements[i]));

        -- hide if option is taken, show otherwise
        if (not self.db.char.showIncrementText) then
            self.PriorityFrame.incrementText[i]:Hide();
        else
            self.PriorityFrame.incrementText[i]:Show();
        end
    end

    -- if currently moving icon, enable the mouse
    if (self.db.char.unlocked) then
		self.PriorityFrame:EnableMouse(1);
    else
        self.PriorityFrame:EnableMouse(0);
    end

    -- Masque support
    if (MSQ) then
        local group = MSQ:Group("Watcher");
        group:ReSkin();
    end

    self:UnregisterFilterEvents()
    self:RegisterFilterEvents()
    self:ShowHidePriorityFrame(false);
    self:ClearAllIcons();
    self:UpdateAll();

    -- Masque support
    if (MSQ) then
        local group = MSQ:Group("Watcher");
        group:ReSkin();
    end

    self.PriorityFrame:SetScript("OnUpdate", function() self:DrawPriorityFrame(); end);
end

function Watcher:SetupSpellIcon(icon, iconNum)
    icon:ClearAllPoints();
    icon:SetFrameStrata("BACKGROUND");
    icon:SetWidth(self.db.char.iconSize);
    icon:SetHeight(self.db.char.iconSize);
    icon:EnableMouse(0);
    icon.iconNum = iconNum;

    -- Configure icon texture
    if (not icon.texture) then
        icon.texture = icon:CreateTexture(nil, "OVERLAY");
    end

    icon.texture:SetPoint("CENTER", icon, "CENTER", 0, 0);

    -- Masque support
    if (MSQ) then
        local group = MSQ:Group("Watcher");

        local buttonData = {};
        buttonData.Icon = icon.texture;
        buttonData.Normal = icon:GetNormalTexture();
        buttonData.Cooldown = icon.cooldown;

        group:AddButton(icon, buttonData);
    else
        icon.texture:SetWidth(self.db.char.iconSize);
        icon.texture:SetHeight(self.db.char.iconSize);
    end

    -- create an animation group to play different animations when spells are ready
    if (not icon.animGrp) then
        icon.animGrp = icon:CreateAnimationGroup("Watcher.SpellIcons["..iconNum.."].".."animGrp");
        icon.scaleUp = icon.animGrp:CreateAnimation("Scale");
        icon.scaleUp:SetDuration(0.1);
        icon.scaleUp:SetScale(1.2, 1.2);
        icon.scaleUp:SetOrder(1);
        icon.scaleDown = icon.animGrp:CreateAnimation("Scale");
        icon.scaleDown:SetDuration(0.1);
        icon.scaleDown:SetScale(1/1.2, 1/1.2);
        icon.scaleDown:SetOrder(2);
        icon.scaleNormal = icon.animGrp:CreateAnimation("Scale");
        icon.scaleNormal:SetDuration(0.1);
        icon.scaleNormal:SetScale(1, 1);
        icon.scaleNormal:SetOrder(3);
    end

    -- setup labels
    if (self.db.char.showLabel) then
        if (not icon.Label) then
            icon.Label = icon:CreateFontString(nil, "OVERLAY");
        end

        icon.Label:Show();
        icon.Label:ClearAllPoints();
        icon.Label:SetTextColor(self.db.char.labelColor.r, self.db.char.labelColor.g, self.db.char.labelColor.b, self.db.char.labelColor.a);
        icon.Label:SetFont(media:Fetch("font", self.db.char.iconFont), self.db.char.iconFontSize, self.db.char.iconFontEffect);
        icon.Label:SetPoint("CENTER", icon, "CENTER", self.db.char.labelHoriPos, self.db.char.labelVertPos);
    else
        if (icon.Label) then
            icon.Label:Hide();
        end
    end

    icon.playFlag = false;
    icon.cooldown = CreateFrame("Cooldown", "Watcher.SpellIcons["..iconNum.."].".."cooldown", icon);
    icon.cooldown:SetAllPoints(icon);
    icon.endTime = 0;

    -- setup cooldown text
    if (not icon.Text) then
        icon.Text = icon:CreateFontString(nil, "OVERLAY");
    end

    icon.Text:ClearAllPoints();
    icon.Text:SetTextColor(1, 1, 1, 1);
    icon.Text:SetFont(media:Fetch("font", self.db.char.iconFont), self.db.char.iconFontSize, self.db.char.iconFontEffect);

    -- anchor cooldown text in correct position
    if (self.db.char.textAnchor == "top") then
        icon.Text:SetPoint("TOP", icon, "TOP", 0, self.db.char.iconFontSize + 2);
    elseif (self.db.char.textAnchor == "bottom") then
        icon.Text:SetPoint("BOTTOM", icon, "BOTTOM", 0, -self.db.char.iconFontSize + 2);
    elseif (self.db.char.textAnchor == "center") then
        icon.Text:SetPoint("CENTER", icon, "CENTER", 0, 0);
    end

    -- show or hide cooldown text according to options
    if (self.db.char.showCooldownText) then
        icon.Text:Show()
    else
        icon.Text:Hide()
    end

    icon:SetAlpha(0);
end

function Watcher:ShowHidePriorityFrame(combat)
    -- show or hide according to options
    if (self.db.char.unlocked and self:IsEnabled()) then
        self.PriorityFrame:Show();
        return;
    end

    -- get active spec (1 if primary, 2 if secondary)
    local groupIndex = GetActiveSpecGroup();


    -- TODO: show only when player has control
    --PLAYER_CONTROL_GAINED
    --PLAYER_CONTROL_LOST
    -- TODO: show only when alive and not a ghost
    -- TODO: only show in vehicle if can use own abilities
    if ((not self:IsEnabled())
     or ((groupIndex == 1 and self.db.char.hideInPrimarySpec) or (groupIndex == 2 and self.db.char.hideInSecondarySpec))
     or (self.db.char.showOnlyInCombat and not (InCombatLockdown() or combat))
     or (self.db.char.showOnlyOnAttackableTarget and not (UnitExists("target") and (UnitCanAttack("player", "target") or UnitIsEnemy("player", "target")) and not UnitIsDead("target")))
     or (not self.db.char.showWhilePVP and inPvpInstance)
     or (not self.db.char.showInRaid and (IsInRaid() and not inPvpInstance))
     or (not self.db.char.showInParty and ((IsInGroup() and not IsInRaid()) and not inPvpInstance))
     or (not self.db.char.showWhileSolo and (not IsInGroup()))
     or (not self.activePriorityList or (table.getn(self.db.char.priorityLists[self.activePriorityList].spellConditions) == 0))) then
        self.PriorityFrame:Hide();
    else
        self.PriorityFrame:Show();
    end
end


---------------------
-- DISPLAY REFRESH --
---------------------
function Watcher:DrawPriorityFrame()
    -- refresh at most at 60fps
    if ((not self.updateTime) or (GetTime() - self.updateTime ) > 0.0167) then
        --self:UpdateAll(); -- FOR TESTING ONLY, WILL BE EVENT BASED BY RELEASE

        -- simply draws the frame without checking anything relying on information already set
        self.updateTime = GetTime();

        for index, icon in ipairs(self.SpellIcons) do
            -- set frame if changed
            if (icon.changedFlag) then
                if (icon.priorityNum) then
                    icon:SetFrameLevel(self.db.char.numIcons * 30 - (icon.priorityNum * 10));
                end

                if (icon.displayTexture) then
                    icon.texture:SetTexture(icon.displayTexture);
                end

                icon.changedFlag = nil;
            end

            if (icon.priorityNum and icon.displayTexture) then
                local stackPos = self:GetIconStackPosition(icon);
                local barPos = self:GetIconBarPosition(icon);

                if (barPos and stackPos) then
                    icon:SetAlpha(1);

                    if (self.db.char.growDir == "up") then
                        icon:SetPoint("BOTTOMRIGHT", self.PriorityFrame, "BOTTOMRIGHT",  -stackPos , barPos);
                    elseif (self.db.char.growDir == "down") then
                        icon:SetPoint("TOPLEFT", self.PriorityFrame, "TOPLEFT",  -stackPos , -barPos);
                    elseif (self.db.char.growDir == "right") then
                        icon:SetPoint("BOTTOMLEFT", self.PriorityFrame, "BOTTOMLEFT",  barPos , stackPos);
                    elseif (self.db.char.growDir == "left") then
                        icon:SetPoint("BOTTOMRIGHT", self.PriorityFrame, "BOTTOMRIGHT",  -barPos, stackPos);
                    end
                else
                    icon:SetAlpha(0);
                end
            end
        end
    end
end


------------------------------
-- DISPLAY HELPER FUNCTIONS --
------------------------------
function Watcher:GetIconBarPosition(icon)
    local timeLeft = 0;
    local barPos = 0;

    -- set timeLeft if on timer
    if (icon.endTime) then
        timeLeft = icon.endTime - GetTime();
        if (timeLeft < 0) then
            timeLeft = 0;
            icon.endTime = 0;
        end
    end

    -- check if doesn't fit into time segments
    if (timeLeft > self.db.char.timeIncrements[table.getn(self.db.char.timeIncrements)]) then
        return;
    end

    for num = table.getn(self.db.char.timeIncrements), 2, -1 do
        if ((timeLeft <= self.db.char.timeIncrements[num]) and (timeLeft > self.db.char.timeIncrements[num-1])) then
            local t = timeLeft - self.db.char.timeIncrements[num-1];
            local i = self.db.char.timeIncrements[num] - self.db.char.timeIncrements[num-1];

            barPos = (self.db.char.timeSegmentWidth * (num - 2)) + ((t / i) * self.db.char.timeSegmentWidth);
        end
    end

    return barPos;
end

function Watcher:GetIconStackPosition(icon)
    local pos = 0;

    -- for all icons ahead in priority
    for i = 1, self.db.char.numIcons do
        if ((self.SpellIcons[i].priorityNum and icon.priorityNum) and (self.SpellIcons[i].priorityNum < icon.priorityNum)) then
            -- check if on cooldown within 1.5 seconds of each other

            local thatEndTime = self.SpellIcons[i].endTime;
            local thisEndTime = icon.endTime;

            if (thisEndTime ~= 0) then
                thisEndTime = icon.endTime - GetTime();
            end

            if (thatEndTime ~= 0) then
                thatEndTime = self.SpellIcons[i].endTime - GetTime();
            end

            if (math.abs(thisEndTime - thatEndTime) <= 1.5)  then -- TODO: make dynamic with timeIncrements
                pos = pos + 1;
            end
        end
    end

    if (pos > (self.db.char.maxStackedIcons - 1)) then
        return;
    end

    return (pos * (self.db.char.iconSize * self.db.char.stackHeight));
end

function Watcher:Play(icon)
    icon.cooldown:SetCooldown(0, 0);
    icon.animGrp:Play();
end

function Watcher:GetNextAvailableIcon()
    for i = 1, self.db.char.numIcons do
        if (not self.SpellIcons[i].priorityNum) then
            return self.SpellIcons[i];
        end
    end
end

function Watcher:ClearAllIcons()
    for i = 1, self.db.char.numIcons do
        self:ClearIcon(self.SpellIcons[i]);
    end
end

function Watcher:ClearIcon(icon)
    icon:SetAlpha(0);
    icon.changedFlag = true;
    icon.displayTexture = nil;

    if (icon.priorityNum) then
        self.SpellConditionCache[icon.priorityNum] = nil;
        icon.priorityNum = nil;
    end

    if (icon.Label) then
        icon.Label:SetText("");
    end

    icon.endTime = 0;

    for spellId, iconValue in pairs(self.IconSpellCache) do
        if (iconValue == icon) then
            self.IconSpellCache[spellId] = nil;
        end
    end
end


--------------------
-- UPDATE METHODS --
--------------------
function Watcher:UpdateAll()
    --checks all spell filters in active priority list
    --updates the frame with information

    if (not self.activePriorityList) then
        return;
    end

    local priorityList = self.db.char.priorityLists[self.activePriorityList];

    for priorityNum, spellCondition in ipairs(priorityList.spellConditions) do
        local icon = nil;
        if (self.SpellConditionCache[priorityNum]) then
            icon = self.SpellConditionCache[priorityNum];
        else
            icon = self:GetNextAvailableIcon();
        end

        local endTime, results = self:EvaluateSpellFilter(spellCondition.spellId, spellCondition.filterSetId);
        self:UpdateIcon(icon, spellCondition.spellId, priorityNum, endTime);

        if (not self.filterTypeEvaluateCache[priorityNum]) then
            self.filterTypeEvaluateCache[priorityNum] = {};
        end

        self.filterTypeEvaluateCache[priorityNum] = results;
    end
end

function Watcher:UpdateIcon(icon, spellId, priorityNum, endTime)
    if (self.IconSpellCache[spellId] and self.IconSpellCache[spellId] ~= icon) then
        if ((endTime and self.IconSpellCache[spellId].endTime) and (self.IconSpellCache[spellId].endTime > endTime)) then
            self:ClearIcon(self.IconSpellCache[spellId]);
        else
            return;
        end
    end

    if (endTime) then
        local name, _, texture, _, _, _, _, _, _ = GetSpellInfo(spellId);
        icon.changedFlag = true;
        icon.endTime = endTime;

        if (icon.Label and self.db.char.spells[spellId].settings) then
            icon.Label:SetText(self.db.char.spells[spellId].settings.label);
        end

        icon.displayTexture = texture;
        icon.priorityNum = priorityNum;

        self.IconSpellCache[spellId] = icon;
        self.SpellConditionCache[priorityNum] = icon;
    elseif (not endTime) then
        -- doesn't match filters, clear icon
        self:ClearIcon(icon);
    end
end

function Watcher:UpdateByFilterType(filterType)
    --only checks the active priority list for all spell filters containining filterType
    --updates the frame with information
    --self:Print(GetTime()..": Updating by filterType: "..filterType);

    if (not self.activePriorityList) then
        return;
    end

    local priorityList = self.db.char.priorityLists[self.activePriorityList];

    for priorityNum, spellCondition in ipairs(priorityList.spellConditions) do
        if (self:CheckForFilterType(spellCondition.filterSetId, filterType)) then
            local icon = nil;
            if (self.SpellConditionCache[priorityNum]) then
                icon = self.SpellConditionCache[priorityNum];
            else
                icon = self:GetNextAvailableIcon();
            end

            local filterEndTime, results = self:EvaluateSpellFilter(spellCondition.spellId, spellCondition.filterSetId, filterType);

            if (not self.filterTypeEvaluateCache[priorityNum]) then
                self.filterTypeEvaluateCache[priorityNum] = {};
            end

            self.filterTypeEvaluateCache[priorityNum][filterType] = filterEndTime;

            local cachedEndTime = 0;

            for filterId, filter in pairs(self.db.char.filterSets[spellCondition.filterSetId].filters) do
                if (not self.filterTypeEvaluateCache[priorityNum][filter.filterType]) then
                    cachedEndTime = nil;
                    break;
                end

                cachedEndTime = math.max(cachedEndTime, self.filterTypeEvaluateCache[priorityNum][filter.filterType]);
            end

            self:UpdateIcon(icon, spellCondition.spellId, priorityNum, cachedEndTime);
        end
    end
end


-------------------
-- TIME SEGMENTS --
-------------------
function Watcher:AddTimeSegment(newSegment)
    if (not self.db.char.timeIncrements or table.getn(self.db.char.timeIncrements) == 0) then
        table.insert(self.db.char.timeIncrements, newSegment);
    end

    for i, curSegment in ipairs(self.db.char.timeIncrements) do
        if (newSegment == curSegment) then
            -- already exists
            return;
        end
        if (newSegment < curSegment) then
            table.insert(self.db.char.timeIncrements, i, newSegment);
            self:SetupPriorityFrame();
            return;
        end
        if ((newSegment > curSegment) and ((not self.db.char.timeIncrements[i+1]) or newSegment < self.db.char.timeIncrements[i+1])) then
            table.insert(self.db.char.timeIncrements, i+1, newSegment);
            self:SetupPriorityFrame();
            return;
        end
    end
end

function Watcher:RemoveTimeSegment(oldSegment)
    for i, timeIncrement in ipairs(self.db.char.timeIncrements) do
        if (oldSegment == timeIncrement) then
            -- already exists
            table.remove(self.db.char.timeIncrements, i);
            self:SetupPriorityFrame()
            return;
        end
    end
end

function Watcher:ResetTimeSegments()
    self.db.char.timeIncrements = {};
    self:AddTimeSegment(0);
    self:AddTimeSegment(1.5);
    self:AddTimeSegment(3);
    self:AddTimeSegment(4.5);
    self:AddTimeSegment(6);
    self:AddTimeSegment(7.5);
    self:AddTimeSegment(15);
    self:AddTimeSegment(60);
    self:AddTimeSegment(300);
    self:SetupPriorityFrame();
end


--[[
function Watcher:UpdateSpell(icon, optionNum, k)
    local spellConditions = self.db.char.spell;
    local timeLeft = self:GetCooldownLeft(k);

    if (self:CheckUsability(k) and timeLeft) then
        auraTimeLeft = self:GetAuraTimeLeft(k);

        -- get timeleft on aura and update because of that
        -- this will make the icon display
        if (auraTimeLeft and (auraTimeLeft > timeLeft)) then
            timeLeft = auraTimeLeft;
        end

        -- update cooldown text and make sure that timeLeft is >= 0
        if (timeLeft <= 0) then
            icon.Text:Hide();
            timeLeft = 0;
        elseif (self.db.char.showCooldownText) then
            icon.Text:SetText(self:GetDurationString(timeLeft));
            icon.Text:Show();
        end

        -- TODO: investigate self.timeLeft
        self.timeLeft[optionNum] = timeLeft;
        self.timeLeft[optionNum+self.db.char.priority.num] = timeLeft;

        if ((not icon.playFlag) and (timeLeft > 1)) then
            icon.playFlag = true;
        end

        -- doesn't fit into time segments
        if (timeLeft > self.db.char.timeIncrements[table.getn(self.db.char.timeIncrements)]) then
            icon:SetAlpha(0);
            self.timeLeft[optionNum] = -1;
            self.timeLeft[optionNum+self.db.char.priority.num] = -1;
            return;
        end

        if (self:CheckPower(k) and self:CheckHealth(k) and self:CheckCombo(k) and self:CheckAura(k)) then
            if (timeLeft == 0) then
                local place = self:FindStackPlace(timeLeft, optionNum, k);
                if (icon.playFlag and place == 0) then
                    self:Play(icon);
                    icon.playFlag = false;
                end
            end

            self.timeLeft[optionNum+self.db.char.priority.num] = -1;
            self:MoveIcon(icon, timeLeft, optionNum);
            self:ColorIcon(icon);
        else
            self.timeLeft[optionNum] = -1;
            self:MoveIcon(icon, timeLeft, optionNum+self.db.char.priority.num);

            if (timeLeft == 0) then
                icon.playFlag = true;
            end

            self:ColorIconUnusable(icon);
        end

        return;
    end

    icon:SetAlpha(0);
    self.timeLeft[optionNum] = -1;
    self.timeLeft[optionNum+self.db.char.priority.num] = -1;
end
--]]
