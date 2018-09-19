-- ********************************************************************************
-- Data Broker Dual Specialization (Broker_DualSpec)
-- A dual specialization switch for Data Broker.
-- By: Shenton
--
-- Core.lua
-- ********************************************************************************

-- Ace libs (<3)
local A = LibStub("AceAddon-3.0"):NewAddon("Broker_DualSpec", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("Broker_DualSpec", false);

-- Addon global
_G["BrokerDualSpecGlobal"] = A;

-- LibDBIcon
A.icon = LibStub("LibDBIcon-1.0");

-- Lua globals
local ipairs, strtrim = ipairs, strtrim;
local sgsub, sformat, sfind, smatch = string.gsub, string.format, string.find, string.match;

-- Bindings locales
BINDING_HEADER_BROKERDUALSPEC = L["BINDINGS_HEADER"];
BINDING_NAME_BROKERDUALSPECSWITCH = L["SWITCH_SPECIALIZATION"];
BINDING_NAME_BROKERDUALSPEC1 = L["PRIMARY_SPEC_BIND"];
BINDING_NAME_BROKERDUALSPEC2 = L["SECONDARY_SPEC_BIND"];

-- ********************************************************************************
-- Variables
-- ********************************************************************************

-- AddOn version
A.version = GetAddOnMetadata("Broker_DualSpec", "Version");

-- Text colors
A.color =
{
    RED = "|cffff3333";
    GREEN = "|cff33ff99";
    WHITE = "|cffffffff";
    WARRIOR = "|cffc79c6e";
    RESET = "|r";
};

-- ********************************************************************************
-- Dropdown Menu
-- ********************************************************************************

--- The dropdown menu structure function
-- @usage Called by ToggleDropDownMenu()
-- @param self Frame object
-- @param level Nesting level
local function DropdownMenu(self, level)
    if ( not level ) then return; end

    local info = self.info;
    local db = A.db.profile;
    local sets = A:GetGearSets();

    if ( level == 1 ) then
        -- Menu title
        info.isTitle = 1;
        info.text = L["ADDON_NAME"];
        info.notCheckable = 1;
        info.icon = nil;
        UIDropDownMenu_AddButton(info, level);

        -- Set options
        info.keepShownOnClick = 1;
        info.hasArrow = 1;
        info.disabled = nil;
        info.isTitle = nil;

        local group = GetActiveSpecGroup(false);

        -- Primary spec gear set
        if ( group == 1 ) then
            info.text = "   "..L["PRIMARY_SPEC"].." !";
        else
            info.text = "   "..L["PRIMARY_SPEC"];
        end
        info.value = "PRIMARY";
        UIDropDownMenu_AddButton(info, level);

        -- Secondary spec gear set
        if ( group == 2 ) then
            info.text = "   "..L["SECONDARY_SPEC"].." !";
        else
            info.text = "   "..L["SECONDARY_SPEC"];
        end
        info.value = "SECONDARY";
        UIDropDownMenu_AddButton(info, level);

        -- Blank separator
        info.text = nil;
        info.value = nil;
        info.hasArrow = nil;
        info.disabled = 1;
        info.notCheckable = 1;
        UIDropDownMenu_AddButton(info, level);

        -- Set options
        info.disabled = nil;

        -- Gear set switch
        info.text = "   "..L["GEAR_SETS"];
        info.value = "GEARSETS";
        info.hasArrow = 1;
        UIDropDownMenu_AddButton(info, level);

        -- Blank separator
        info.text = nil;
        info.value = nil;
        info.hasArrow = nil;
        info.disabled = 1;
        info.notCheckable = 1;
        UIDropDownMenu_AddButton(info, level);

        -- Set options
        info.disabled = nil;

        -- Options
        info.text = "   "..L["OPTIONS"];
        info.value = "OPTIONS";
        info.hasArrow = 1;
        UIDropDownMenu_AddButton(info, level);

        -- Set options
        info.keepShownOnClick = nil;
        info.hasArrow = nil;

        -- Close
        info.text = L["CLOSE"];
        info.func = function() CloseDropDownMenus(); end;
        UIDropDownMenu_AddButton(info, level);
    elseif ( level == 2 ) then
        if ( UIDROPDOWNMENU_MENU_VALUE == "PRIMARY" ) then -- Primary spec gear set
            local spec,_, points = A:GetSpecInfos(1);

            info.isTitle = 1;
            info.text = spec.." ("..points..")";
            info.notCheckable = 1;
            info.icon = nil;
            info.keepShownOnClick = 1;
            UIDropDownMenu_AddButton(info, level);

            info.text = L["CLOAK"];
            info.isTitle = nil;
            info.disabled = nil;
            info.notCheckable = nil;
            info.checked = function()
                if ( db.primaryCloak == 0 ) then
                    return nil;
                else
                    return 1;
                end
            end;
            info.func = function()
                local current = GetActiveSpecGroup(false);

                if ( db.primaryCloak == 0 ) then
                    db.primaryCloak = 1;

                    if ( current == 1 ) then ShowCloak(1); end
                else
                    db.primaryCloak = 0;

                    if ( current == 1 ) then ShowCloak(nil); end
                end
            end;
            UIDropDownMenu_AddButton(info, level);

            info.text = L["HELM"];
            info.checked = function()
                if ( db.primaryHelm == 0 ) then
                    return nil;
                else
                    return 1;
                end
            end;
            info.func = function()
                local current = GetActiveSpecGroup(false);

                if ( db.primaryHelm == 0 ) then
                    db.primaryHelm = 1;

                    if ( current == 1 ) then ShowHelm(1); end
                else
                    db.primaryHelm = 0;

                    if ( current == 1 ) then ShowHelm(nil); end
                end
            end;
            UIDropDownMenu_AddButton(info, level);

            if ( sets ) then
                -- Blank separator
                info.text = nil;
                info.disabled = 1;
                info.notCheckable = 1;
                info.keepShownOnClick = nil;
                UIDropDownMenu_AddButton(info, level);

                -- Options
                info.disabled = nil;
                info.notCheckable = nil;

                for _,t in ipairs(sets) do
                    info.text = t.name;
                    info.icon = t.icon;
                    info.checked = function()
                        if ( t.name == db.primary ) then
                            return 1;
                        else
                            return nil;
                        end
                    end;
                    info.func = function() db.primary = t.name; end;
                    UIDropDownMenu_AddButton(info, level);
                end
            end
        elseif ( UIDROPDOWNMENU_MENU_VALUE == "SECONDARY" ) then -- Secondary spec gear set
            local spec,_, points = A:GetSpecInfos(2);

            info.isTitle = 1;
            info.text = spec.." ("..points..")";
            info.notCheckable = 1;
            info.icon = nil;
            info.keepShownOnClick = 1;
            UIDropDownMenu_AddButton(info, level);

            info.text = L["CLOAK"];
            info.isTitle = nil;
            info.disabled = nil;
            info.notCheckable = nil;
            info.checked = function()
                if ( db.secondaryCloak == 0 ) then
                    return nil;
                else
                    return 1;
                end
            end;
            info.func = function()
                local current = GetActiveSpecGroup(false);

                if ( db.secondaryCloak == 0 ) then
                    db.secondaryCloak = 1;

                    if ( current == 2 ) then ShowCloak(1); end
                else
                    db.secondaryCloak = 0;

                    if ( current == 2 ) then ShowCloak(nil); end
                end
            end;
            UIDropDownMenu_AddButton(info, level);

            info.text = L["HELM"];
            info.checked = function()
                if ( db.secondaryHelm == 0 ) then
                    return nil;
                else
                    return 1;
                end
            end;
            info.func = function()
                local current = GetActiveSpecGroup(false);

                if ( db.secondaryHelm == 0 ) then
                    db.secondaryHelm = 1;

                    if ( current == 2 ) then ShowHelm(1); end
                else
                    db.secondaryHelm = 0;

                    if ( current == 2 ) then ShowHelm(nil); end
                end
            end;
            UIDropDownMenu_AddButton(info, level);

            if ( sets ) then
                -- Blank separator
                info.text = nil;
                info.disabled = 1;
                info.notCheckable = 1;
                info.keepShownOnClick = nil;
                UIDropDownMenu_AddButton(info, level);

                -- Options
                info.disabled = nil;
                info.notCheckable = nil;

                for _,t in ipairs(sets) do
                    info.text = t.name;
                    info.icon = t.icon;
                    info.checked = function()
                        if ( t.name == db.secondary ) then
                            return 1;
                        else
                            return nil;
                        end
                    end;
                    info.func = function() db.secondary = t.name; end;
                    UIDropDownMenu_AddButton(info, level);
                end
            end
        elseif ( UIDROPDOWNMENU_MENU_VALUE == "GEARSETS" ) then -- Gear sets switch
            if ( sets ) then
                for _,t in ipairs(sets) do
                    info.text = "   "..t.name;
                    info.icon = t.icon;
                    info.notCheckable = 1;
                    info.func = function() UseEquipmentSet(t.name); end;
                    UIDropDownMenu_AddButton(info, level);
                end
            end
        elseif ( UIDROPDOWNMENU_MENU_VALUE == "OPTIONS" ) then -- Options
            -- Set options
            info.keepShownOnClick = 1;
            info.notCheckable = nil;
            info.icon = nil;

            -- Display spec name
            info.text = L["DISPLAY_SPEC_NAME"];
            info.checked = db.specname;
            info.func = function()
                db.specname = not db.specname;
                A:UpdateBroker()
            end;
            UIDropDownMenu_AddButton(info, level);

            -- Display spec points
            info.text = L["DISPLAY_SPEC_POINTS"];
            info.checked = db.points;
            info.func = function()
                db.points = not db.points;
                A:UpdateBroker()
            end;
            UIDropDownMenu_AddButton(info, level);

            -- Switch gear too
            info.text = L["SWITCH_GEAR_TOO"];
            info.checked = db.gear;
            info.func = function() db.gear = not db.gear; end;
            UIDropDownMenu_AddButton(info, level);

            -- Hide spam
            info.text = L["HIDE_SPAM"];
            info.checked = db.chatFilter;
            info.func = function() db.chatFilter = not db.chatFilter; end;
            UIDropDownMenu_AddButton(info, level);

            -- Show/hide minimap icon
            info.text = L["SHOW_HIDE_MINIMAP"];
            info.checked = not db.minimap.hide;
            info.func = function()
                db.minimap.hide = not db.minimap.hide;
                A:ShowHideMinimap();
            end;
            UIDropDownMenu_AddButton(info, level);
        end
    end
end

-- ********************************************************************************
-- Chat filter (spec change spam)
-- ********************************************************************************

--- Build the strings filter table
-- Basically removing format conversion characters from GlobalStrings
function A:BuildFilterTable()
    local _, str;
    local globalStrings =
    {
        ERR_SPELL_UNLEARNED_S,
        ERR_LEARN_ABILITY_S,
        ERR_LEARN_PASSIVE_S,
        ERR_LEARN_SPELL_S,
    };

    A.filterTable = {};

    for _,v in ipairs(globalStrings) do
        str = sgsub(v, "%.", "");
        str = sgsub(str, "%%s", ".+");
        A.filterTable[#A.filterTable+1] = str;
    end
end

--- Filter callback function
-- Called by "ChatFrame_MessageEventHandler" from ChatFrame.lua
A.ChatFilter = function(self, event, msg, ...)
    if ( not A.chatFilterActive ) then return; end

    if ( not A.filterTable ) then A:BuildFilterTable(); end

    for _,v in ipairs(A.filterTable) do
        if ( sfind(msg, v) ) then return 1; end
    end

    return nil;
end

--- Set or unset the chat filter callback
-- @param unset Force unsetting callback
function A:ChatFilterSetCallback(unset)
    if ( unset ) then
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", A.ChatFilter);
        return;
    end

    if ( A.db.profile.chatFilter ) then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", A.ChatFilter);
    else
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", A.ChatFilter);
    end
end

-- Hook Blizzard switch spec function
-- Used to set chat filter state var
hooksecurefunc("SetActiveSpecGroup", function()
    if ( A.db.profile.chatFilter ) then
        A.chatFilterActive = 1;
        A:CancelTimer(A.chatFilterTimer, 1);
        A.chatFilterTimer = A:ScheduleTimer("ChatFilterTimer", 15);
    end
end);

--- Timer callback
-- Chat is filtered for 10 sec after spec change
function A:ChatFilterTimer()
    A.chatFilterActive = nil;
end

-- ********************************************************************************
-- Functions
-- ********************************************************************************

--- Send a message to the chat frame with the addon name colored
-- @param text The message to display
-- @param color Bool, if true will color in red
function A:Message(text, color)
    if ( color ) then
        color = A.color["RED"];
    else
        color = A.color["GREEN"]
    end

    DEFAULT_CHAT_FRAME:AddMessage(color..L["ADDON_NAME"]..": "..A.color["RESET"]..text);
end

--- Update the button and icon
function A:UpdateBroker()
    local spec, icon, talents = A:GetSpecInfos();

    if ( spec and icon and talents ) then
        if ( A.db.profile.specname and A.db.profile.points ) then
            A.ldb.text = spec.." ("..talents..")";
        elseif ( A.db.profile.specname ) then
            A.ldb.text = spec;
        elseif ( A.db.profile.points ) then
            A.ldb.text = "("..talents..")";
        else
            A.ldb.text = "";
        end
        A.ldb.icon = icon;
    else
        A.ldb.text = L["NOT_AVAILABLE"];
    end
end

--- Show or hide the minimap icon
function A:ShowHideMinimap()
    if ( A.db.profile.minimap.hide ) then
        A:Message(L["HIDE_MINIMAP"], true);
        A.icon:Hide("Broker_DualSpecObject");
    else
        A.icon:Show("Broker_DualSpecObject");
    end
end

--- Handle the slash command
-- @param input The string returned after the command
function A:SlashCommand(input)
    local arg1, arg2 = smatch(input, "(%a*)%s?(.*)");

    if ( arg1 == "" ) then
        A:SwitchSpec();
    elseif ( arg1 == "show" ) then
        A.db.profile.minimap.hide = false;
        A:ShowHideMinimap();
    elseif ( arg1 == "list" ) then
        local sets = A:GetGearSets();

        if ( sets ) then
            local out = "";

            for _,t in ipairs(sets) do
                out = out..", "..out;
            end
            out = strtrim(out, " ,");
            A:Message(out);
        else
            A:Message(L["NO_GEAR_SETS"], true);
        end
    elseif ( arg1 == "primary" ) then
        if ( arg2 ) then
            local exists,_ = GetEquipmentSetInfoByName(arg2);

            if ( exists ) then
                A.db.profile.primary = arg2;
            else
                A:Message(L["GEAR_NOT_EXISTS"], true);
            end
        end
    elseif ( arg1 == "secondary" ) then
        if ( arg2 ) then
            local exists,_ = GetEquipmentSetInfoByName(arg2);

            if ( exists ) then
                A.db.profile.secondary = arg2;
            else
                A:Message(L["GEAR_NOT_EXISTS"], true);
            end
        end
    else
        A:Message(L["COMMAND_USAGE_1"]);
        A:Message(L["COMMAND_USAGE_2"]);
        A:Message(L["COMMAND_USAGE_3"]);
        A:Message(L["COMMAND_USAGE_4"]);
    end
end

--- Get informations about the given spec
-- @param group The spec group number (1 or 2)
-- @return The spec name, the spec icon, the points spent
function A:GetSpecInfos(group)
    local talents = "";
    local spec = L["NOT_AVAILABLE"];
    local icon = "Interface\\ICONS\\INV_Misc_QuestionMark";
    local maxNumTalents, column, selected, _ = 18, nil, nil, nil;

    if ( not group ) then group = GetActiveSpecGroup(false); end

    local specId = GetSpecialization(false, false, group);

    if ( specId ) then
        _, spec, _, icon = GetSpecializationInfo(specId, false, false);
    end

    for i=1,maxNumTalents do
        _, _, _, column, selected = GetTalentInfo(i, false, group);

        if ( selected ) then
            talents = talents.."/"..column;
        end
    end

    if ( talents == "" ) then
        talents = "0/0/0/0/0/0";
    else
        talents = strtrim(talents, "/");
    end

    return spec, icon, talents;
end

--- Get gear sets names and icons
-- @return A table with gear sets and icons
function A:GetGearSets()
    local num = GetNumEquipmentSets();

    if ( num == 0 ) then
        return false;
    else
        local sets = {};

        for i=1,GetNumEquipmentSets() do
            local name, icon,_ = GetEquipmentSetInfo(i);

            sets[i] = {};
            sets[i]["name"] = name;
            sets[i]["icon"] = icon;
        end

        return sets;
    end
end

--- Switch between spec
function A:SwitchSpec()
    if ( UnitAffectingCombat("player") ) then
        A:Message(L["IN_COMBAT"], true);
        return;
    end

    if ( UnitCastingInfo("player") ) then return; end

    local current = GetActiveSpecGroup(false);

    if ( current == 1 ) then
        SetActiveSpecGroup(2);
    else
        SetActiveSpecGroup(1);
    end
end

--- Set display options depending on config and spec
-- @param spec 1 or 2
function A:SetDisplayOptions(spec)
    if ( spec == 2 ) then
        if ( A.db.profile.secondaryCloak == 0 ) then
            ShowCloak(nil);
        else
            ShowCloak(1);
        end

        if ( A.db.profile.secondaryHelm == 0 ) then
            ShowHelm(nil);
        else
            ShowHelm(1);
        end
    else
        if ( A.db.profile.primaryCloak == 0 ) then
            ShowCloak(nil);
        else
            ShowCloak(1);
        end

        if ( A.db.profile.primaryHelm == 0 ) then
            ShowHelm(nil);
        else
            ShowHelm(1);
        end
    end
end

-- ********************************************************************************
-- Callbacks
-- ********************************************************************************

--- Callback function for event ZONE_CHANGED_NEW_AREA
-- Used to update icon and text on login
function A:ZONE_CHANGED_NEW_AREA()
    A:UpdateBroker();
    A:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
end

--- Callback function for event PLAYER_ENTERING_WORLD
-- Fire every time there is a loading screen
-- but too soon so we use ZONE_CHANGED_NEW_AREA
-- Added update function here in case of reloadui
function A:PLAYER_ENTERING_WORLD()
    A:UpdateBroker();
end

--- Callback function for event ACTIVE_TALENT_GROUP_CHANGED
-- Set the gear set attached to the given spec
function A:ACTIVE_TALENT_GROUP_CHANGED()
    if ( A.db.profile.gear ) then
        local current = GetActiveSpecGroup(false);

        if ( current == 1 ) then
            if ( A.db.profile.primary ~= "" )then
                UseEquipmentSet(A.db.profile.primary);
                A:SetDisplayOptions(1);
            else
                A:Message(L["NO_GEAR_DEFINED"], true);
            end
        else
            if ( A.db.profile.secondary ~= "" )then
                UseEquipmentSet(A.db.profile.secondary);
                A:SetDisplayOptions(2);
            else
                A:Message(L["NO_GEAR_DEFINED"], true);
            end
        end
    end

    A:UpdateBroker();
end

--- Callback function for event CHARACTER_POINTS_CHANGED
function A:CHARACTER_POINTS_CHANGED()
    A:UpdateBroker();
end

-- ********************************************************************************
-- Configuration DB
-- ********************************************************************************

--- Default configuration table for AceDB
local defaults =
{
    profile =
    {
        primary = "",
        secondary = "",
        specname = 1,
        points = 1,
        gear = 1,
        chatFilter = 1,
        primaryCloak = nil,
        primaryHelm = nil,
        secondaryCloak = nil,
        secondaryHelm = nil,
        minimap =
        {
            hide = false
        }
    }
};

-- ********************************************************************************
-- Main
-- ********************************************************************************

--- AceAddon callback
-- Called after the addon is fully loaded
function A:OnInitialize()
    -- Config db
    A.db = LibStub("AceDB-3.0"):New("Broker_DualSpecDB", defaults);
end

--- AceAddon callback
-- Called during the PLAYER_LOGIN event
function A:OnEnable()
    -- LDB
    A.ldb = LibStub("LibDataBroker-1.1"):NewDataObject("Broker_DualSpecObject",
    {
        type = "data source",
        text = L["NOT_AVAILABLE"],
        label = L["ADDON_NAME"],
        icon = "Interface\\ICONS\\INV_Misc_QuestionMark",
        tocname = "Broker_DualSpec",
        OnClick = function(self, button)
            if (button == "LeftButton") then
                A:SwitchSpec();
            elseif ( button == "RightButton" ) then
                if ( A.menuFrame.initialize ~= DropdownMenu ) then
                    CloseDropDownMenus();
                    A.menuFrame.initialize = DropdownMenu;
                end
                ToggleDropDownMenu(1, nil, A.menuFrame, self, 0, 0);
                GameTooltip:Hide();
            end
        end,
        OnTooltipShow = function(tooltip)
            local spec, points, currentGroup, altGroup, display, _;
            local current = GetActiveSpecGroup(false);

            if ( current == 1 ) then
                currentGroup = L["PRIMARY_SPEC"];
                altGroup = L["SECONDARY_SPEC"];
            else
                altGroup = L["PRIMARY_SPEC"];
                currentGroup = L["SECONDARY_SPEC"];
            end

            tooltip:AddDoubleLine(A.color["WHITE"]..L["ADDON_NAME"], A.color["GREEN"].." v"..A.version);
            tooltip:AddLine(" ");

            spec,_, points = A:GetSpecInfos();
            tooltip:AddLine(L["CURRENT_SPEC"]..": "..spec.." ("..points..") ("..currentGroup..")");
            tooltip:AddLine(" ");

            if ( current == 1 ) then
                spec,_, points = A:GetSpecInfos(2);
            else
                spec,_, points = A:GetSpecInfos(1);
            end
            tooltip:AddLine(L["SWITCH_TO"]..": "..spec.." ("..points..") ("..altGroup..")");

            if ( A.db.profile.gear ) then
                if ( current == 1 ) then
                    -- Gear set switch
                    tooltip:AddLine(L["WITH_GEAR_SET"]..": "..A.db.profile.secondary);

                    -- Helm hidden/shown
                    if ( A.db.profile.secondaryHelm == 0 ) then
                        display = L["HIDDEN"];
                    else
                        display = L["SHOWN"];
                    end
                    tooltip:AddLine(L["HELM"]..": "..display);

                    -- Cloak hidden/shown
                    if ( A.db.profile.secondaryCloak == 0 ) then
                        display = L["HIDDEN"];
                    else
                        display = L["SHOWN"];
                    end
                    tooltip:AddLine(L["CLOAK"]..": "..display);
                else
                    -- Gear set switch
                    tooltip:AddLine(L["WITH_GEAR_SET"]..": "..A.db.profile.primary);

                    -- Helm hidden/shown
                    if ( A.db.profile.primaryHelm == 0 ) then
                        display = L["HIDDEN"];
                    else
                        display = L["SHOWN"];
                    end
                    tooltip:AddLine(L["HELM"]..": "..display);

                    -- Cloak hidden/shown
                    if ( A.db.profile.primaryCloak == 0 ) then
                        display = L["HIDDEN"];
                    else
                        display = L["SHOWN"];
                    end
                    tooltip:AddLine(L["CLOAK"]..": "..display);
                end
            end

            tooltip:AddLine(" ");
            tooltip:AddLine(sformat(L["TOOLTIP_TIPS"], A.color["WARRIOR"], A.color["GREEN"], A.color["WARRIOR"], A.color["GREEN"]));
        end,
    });

    -- LDBIcon
    A.icon:Register("Broker_DualSpecObject", A.ldb, A.db.profile.minimap);
    A.icon:IconCallback("ZONE_CHANGED_NEW_AREA", "Broker_DualSpecObject", nil, nil, A.ldb);
    A.icon:IconCallback("ACTIVE_TALENT_GROUP_CHANGED", "Broker_DualSpecObject", nil, nil, A.ldb);
    A.icon:IconCallback("PLAYER_ENTERING_WORLD", "Broker_DualSpecObject", nil, nil, A.ldb);
    A.icon:IconCallback("CHARACTER_POINTS_CHANGED", "Broker_DualSpecObject", nil, nil, A.ldb);

    -- Menu frame & table
    A.menuFrame = CreateFrame("Frame", "Broker_DualSpecMenuFrame");
    A.menuFrame.displayMode = "MENU";
    A.menuFrame.info = {};

    -- Events
    A:RegisterEvent("ZONE_CHANGED_NEW_AREA");
    A:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
    A:RegisterEvent("PLAYER_ENTERING_WORLD");
    A:RegisterEvent("CHARACTER_POINTS_CHANGED");

    -- Slash command
    A:RegisterChatCommand("brokerdualspec", "SlashCommand");
    A:RegisterChatCommand("bds", "SlashCommand");
    A:RegisterChatCommand("ds", "SlashCommand");

    -- DB update for older version
    if ( not A.db.profile.secondaryCloak and not A.db.profile.secondaryHelm and not A.db.profile.primaryCloak and not A.db.profile.primaryHelm ) then
        if ( ShowingCloak() ) then
            A.db.profile.secondaryCloak = 1;
            A.db.profile.primaryCloak = 1;
        else
            A.db.profile.secondaryCloak = 0;
            A.db.profile.primaryCloak = 0;
        end

        if ( ShowingHelm() ) then
            A.db.profile.secondaryHelm = 1;
            A.db.profile.primaryHelm = 1;
        else
            A.db.profile.secondaryHelm = 0;
            A.db.profile.primaryHelm = 0;
        end
    end

    -- Chat filter init
    A:ChatFilterSetCallback();
end

--- AceAddon callback
-- Called when the addon is manually disabled
function A:OnDisable()
    -- Chat filter unset callback
    A:ChatFilterSetCallback(1);

    -- Chat filter timer
    A:CancelTimer(A.chatFilterTimer, 1);

    -- Slash command
    A:UnregisterChatCommand("brokerdualspec");
    A:UnregisterChatCommand("bds");
    A:UnregisterChatCommand("ds");

    -- Events
    A:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
    A:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
    A:UnregisterEvent("PLAYER_ENTERING_WORLD");
    A:UnregisterEvent("CHARACTER_POINTS_CHANGED");
end
