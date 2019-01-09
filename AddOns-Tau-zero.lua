-- AddOns-Tau-zero-v548.txt
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

idTip =false,
TipTop =false,

}


linkExpaAddOns('_my') {
ZenShortcuts =true,
ZenTestZone =true,
ZenTools =true,
}




linkExpaAddOns('bars') {
Bazooka =false,
Bazooka_Options =false,

Dominos =true,
--Dominos_Auras =false,
--Dominos_Bufftimes =false,
--Dominos_Cast =false,
--Dominos_Config =false,
--Dominos_Encounter =false,
--Dominos_Quest =false,
--Dominos_Roll =false,
Dominos_XP =true,
}



linkExpaAddOns('chat') {

["Prat-3.0"] =true,
["Prat-3.0_Libraries"] =false,
["Prat-3.0_HighCPUUsageModules"] =false,
Elephant =true,
}



linkExpaAddOns('map') {
Mapster =false,
TomTom =false,

Explorer =true,
MozzFullWorldMap =true,

}




linkExpaAddOns('dev') {
["!BugGrabber"] =true,
BugSack =true,

}




linkExpaAddOns('trade') {
GnomishVendorShrinker =true,
Auctionator =false,

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

