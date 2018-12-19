local ADDON_NAME = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true, false)
if not L then return end

L["Tiller Tracker"] = true
L["Loaded"] = true
L["Loading..."] = true

L["A Dish for Chee Chee"] = true
L["A Dish for Ella"] = true
L["A Dish for Farmer Fung"] = true
L["A Dish for Fish"] = true
L["A Dish for Gina"] = true
L["A Dish for Haohan"] = true
L["A Dish for Jogu"] = true
L["A Dish for Old Hillpaw"] = true
L["A Dish for Sho"] = true
L["A Dish for Tina"] = true

L["|cFF00FF00Complete|r"] = true
L["|cFFFF0000Not Complete|r"] = true
L["|cFFFFFF00Click|r a quest in the tooltip to set a TomTom waypoint at the farmer's home"] = true
L["|cFFFFFF00Click|r the main button to toggle whether the tooltip stays open"] = true 
L["|cFFFFFF00Right Click|r the main button to cycle through which ingredient to track"] = true
L["|cFFFFFF00Ctrl-Click|r the main button to queue craftable foods in Skillet"] = true
L["|cFFFFFF00Ctrl-Click|r the main button to queue craftable foods in Advanced Trade Skill Window"] = true

L["Quest"] = true
L["Food"] = true
L["Have"] = true
L["Status"] = true
L["Need"] = true

L["Gather:"] = true
L["Done"] = true
L["Disabled until level 90"] = true

L["Best Friends with everyone"] = true

L["Show minimap icon"] = true
L["Shows or hides the minimap icon"] = true

L["Plan ahead"] = true
L["Number of days worth of quests to plan ahead for"] = true

L["tillertracker"] = true
L["Available commands:"] = true
L["config"] = true
L["Show configuration"] = true
L["minimap"] = true
L["Toggles the minimap icon"] = true
L["plan"] = true
L["Sets the number of days worth of quests to plan ahead for"] = true
L["Current value:"] = true
L["New value:"] = true
L["Value must be a number between 1 and 30"] = true