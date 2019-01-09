-- AddOns-Tau-light-v548.txt
dofile('../mkAddOnsLinks.lua')
local linkExpaAddOns = linkAddOns.A548
local linkServerAddOns = linkAddOns.A735Fs


linkExpaAddOns('base') {
Ace3 =true,

AddonLoader =false,
ACP =false,
stAddonmanager =false,

Binder =true,
BlizzMove =true,
CombatMode =true,
FasterCamera =true,

Viewporter =false,
Leatrix_Plus =true,

idTip =true,
TipTop =true,

}


linkExpaAddOns('_my') {
ZenShortcuts =true,
ZenTestZone =true,
ZenTools =true,
}




linkExpaAddOns('bars') {
Bazooka =true,
Bazooka_Options =true,

Dominos =true,
Dominos_Auras =true,
Dominos_Bufftimes =true,
Dominos_Cast =true,
Dominos_Config =true,
Dominos_Encounter =true,
Dominos_Quest =true,
Dominos_Roll =true,
Dominos_XP =true,
}


linkExpaAddOns('bag') {
BankStack =false,

AdiBags =true,
AdiBags_Config =true,
BagSync =true,

BagBrother =false,
Combuctor =false,
Combuctor_Config =false,
Combuctor_Sets =false,
Combuctor_BindToAccount =false,
Combuctor_EquipmentSets =false,

ArkInventory =false,
ArkInventoryConfig =false,
ArkInventoryRules =false,
ArkInventoryRules_Example =false,

XLoot =false,
XLoot_Frame =false,
XLoot_Group =false,
XLoot_Master =false,
XLoot_Monitor =false,
XLoot_Options =false,
}




linkExpaAddOns('unitframe') {
oUF_Adirelle =true,
oUF_Adirelle_Single =true,
oUF_Adirelle_Arena =true,
oUF_Adirelle_Boss =true,
oUF_Adirelle_Raid =true,
oUF_Adirelle_Config =true,

oUF_Freebgrid =false,
oUF_Freebgrid_Config =false,
oUF_Phanx =false,
oUF_Phanx_Config =false,

oUF =false,
oUF_MovableFrames =false,
oUF_Mlight =false,
oUF_Lanerra =false,
oUF_Phanx =false,
}


linkExpaAddOns('nameplate') {
Kui_Media =true,
Kui_Nameplates =true,
Kui_Nameplates_Auras =true,

PlateBuffs =false,

TidyPlates =false,
TidyPlatesHub =false,
TidyPlatesWidgets =false,
TidyPlates_Graphite =false,
TidyPlates_Slim_Horizontal =false,
TidyPlates_Slim_Vertical =false,
TidyPlates_ThreatPlates =false,
}


linkExpaAddOns('combat') {
Quartz =false,
CoolLine =false,
Ellipsis =false,
Ellipsis_Options =false,
Raven =false,
Raven_Options =false,

MikScrollingBattleText =true,
MSBTOptions =true,
["xCT+"] =false,
Doom_CooldownPulse =false,

LoseControlFix =false,
LoseControl =false,
GTFO =false,

Spy =true,
}




linkExpaAddOns('chat') {

["Prat-3.0"] =true,
["Prat-3.0_Libraries"] =false,
["Prat-3.0_HighCPUUsageModules"] =false,
Elephant =true,
}


linkExpaAddOns('mail') {
Postal =true,
GnomishInboxShrinker =false,
InboxMailBag =false,
}


linkExpaAddOns('players') {
}




linkExpaAddOns('map') {
Mapster =true,
TomTom =true,

Explorer =true,
MozzFullWorldMap =false,


Routes =true,
HandyNotes =false,
HandyNotes_LostAndFound =false,

NPCScan =false,
["NPCScan.Overlay"] =false,
RareSpawnOverlay =false,
SilverDragon =true,
SilverDragon_Data =true,
}




linkExpaAddOns('broker') {
AllPlayed =false,
Broker_Everything =true,
Broker_Garbage =false,
["Broker_Garbage-Config"] =false,
["Broker_Garbage-LootManager"] =false,
EmoteLDB =false,
LiteMount =true,
}


linkExpaAddOns('cpu') {
AddonUsage =true,
iCPU =false,
Broker_CPU =true,
}


linkExpaAddOns('dev') {
["!BugGrabber"] =true,
BugSack =true,

AdvancedEventTrace =false,
ImprovedFrameStack =false,

TinyPad =false,
ViragDevTool =false,

Hack =false,
LuaBrowser =false,
WowLua =false,
DevPad =false,
["DevPad.GUI"] =false,
tekDebug =true,
}




linkExpaAddOns('trade') {
GnomishVendorShrinker =true,
Auctionator =true,

}


linkExpaAddOns('prof') {
Archy =false,
Milling =false,
Panda =false,
Skillet =false,
}




linkExpaAddOns('gear') {
Examiner =true,
MogIt =true,
}



linkServerAddOns {

Blizzard_AchievementUI =true,
Blizzard_ArchaeologyUI =true,
Blizzard_ArenaUI =true,
Blizzard_AuctionUI =true,
Blizzard_AuthChallengeUI =true,
Blizzard_BarbershopUI =true,
Blizzard_BattlefieldMinimap =true,
Blizzard_BindingUI =true,
Blizzard_BlackMarketUI =true,
Blizzard_Calendar =true,
Blizzard_ChallengesUI =true,
Blizzard_ClientSavedVariables =true,
Blizzard_CombatLog =true,
Blizzard_CombatText =true,
Blizzard_CompactRaidFrames =true,
Blizzard_CUFProfiles =true,
Blizzard_DebugTools =true,
Blizzard_EncounterJournal =true,
Blizzard_GlyphUI =true,
Blizzard_GMChatUI =true,
Blizzard_GMSurveyUI =true,
Blizzard_GuildBankUI =true,
Blizzard_GuildControlUI =true,
Blizzard_GuildUI =true,
Blizzard_InspectUI =true,
Blizzard_ItemAlterationUI =true,
Blizzard_ItemSocketingUI =true,
Blizzard_ItemUpgradeUI =true,
Blizzard_LookingForGuildUI =true,
Blizzard_MacroUI =true,
Blizzard_MovePad =true,
Blizzard_PetBattleUI =true,
Blizzard_PetJournal =true,
Blizzard_PVPUI =true,
Blizzard_QuestChoice =true,
Blizzard_RaidUI =true,
Blizzard_ReforgingUI =true,
Blizzard_StoreUI =true,
Blizzard_TalentUI =true,
Blizzard_TimeManager =true,
Blizzard_TokenUI =true,
Blizzard_TradeSkillUI =true,
Blizzard_TrainerUI =true,
Blizzard_VoidStorageUI =true,

}


linkAddOns.commitLinks()

