-- AddOns-Tau-light-v548.txt
--  cmd /c mklink AddOns.txt  ..\..\WTF\AddOns.txt

dofile('../mkAddOnsLinks.lua')


linkAddOns.A715 {
oUF_MovableFrames =false,
}

linkAddOns.Adev {
Binder =true,
CombatMode =true,
MyAdd =false,
MyBindings =false,
ZenShortcuts =true,
ZenTools =true,
ViragDevTool =true,
}

linkAddOns.A548('base') {  -- World Events
CandyBuckets = false,
HandyNotes_CamelFigurines =false,
HandyNotes_HallowsEnd =false,
--HandyNotes_SummerFestival =true,
kAutoOpen =false,
}

linkAddOns.A548('base') {
Ace3 =true,
["!BugGrabber"] =true,
BugSack =true,

AdiBags =true,
AdiBags_Config =true,
BagSync =true,
BagBrother =true,
Combuctor =true,
Combuctor_Config =true,
Combuctor_Sets =true,
Combuctor_BindToAccount =true,
Combuctor_EquipmentSets =true,
ArkInventory =true,
ArkInventoryConfig =true,
ArkInventoryRules =true,
ArkInventoryRules_Example =true,

AutoBar =false,
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

Broker_Everything =true,
Broker_Garbage =true,
["Broker_Garbage-Config"] =true,
["Broker_Garbage-LootManager"] =true,

oUF_Adirelle =true,
oUF_Adirelle_Single =true,
oUF_Adirelle_Arena =true,
oUF_Adirelle_Boss =true,
oUF_Adirelle_Raid =true,
oUF_Adirelle_Config =true,
oUF_Freebgrid =false,
oUF_Freebgrid_Config =false,
oUF_Lanerra =false,
oUF_Phanx =false,
oUF_Phanx_Config =false,
Kui_Media =true,
Kui_Nameplates =true,
Kui_Nameplates_Auras =true,
TidyPlates =false,
TidyPlates_Graphite =false,
TidyPlatesHub =false,
TidyPlatesWidgets =false,
Ellipsis =true,
Ellipsis_Options =true,
Raven =true,
Raven_Options =true,
["xCT+"] =true,
--Doom_CooldownPulse =true,

LoseControlFix =true,
--GTFO =true,

Skada =true,
Spy =true,

Postal =true,
InboxMailBag =false,

["Prat-3.0"] =true,
["Prat-3.0_Libraries"] =true,
Elephant =true,

idTip =true,
TipTop =true,

Mappy =true,
Mapster =true,
TomTom =true,

Explorer =true,
MozzFullWorldMap =false,
Routes =false,
HandyNotes =false,
HandyNotes_LostAndFound =false,

NPCScan =false,
["NPCScan.Overlay"] =false,
_NPCScan = false,
["_NPCScan.Overlay"] = false,

SilverDragon =true,
SilverDragon_Data =true,


AddonLoader =true,
BlizzMove =true,
Viewporter =true,
Leatrix_Plus =true,
MacroBank =false,
AdvancedIconSelector =false,
["AdvancedIconSelector-KeywordData"] =false,

TinyPad =true,
--ViragDevTool =true, -- linkAddOns.Adev

FasterCamera =true,
FriendsShare =true,
AllPlayed =false,
Examiner =true,
--EmoteLDB =true,
LiteMount =true,

Archy =true,
Skillet =false,
Accountant =false,
GnomishVendorShrinker =true,
Auctionator =true,

MogIt =true,

}

linkAddOns.A548Tau {

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


pause('Finished')

