-- AddOns-server-548-Tau.lua
--[[ Make symbolic link to enabled AddOns.txt  as Administrator:
In AddOns folder:
cmd /c mklink ..\..\WTF\AddOns.txt ..\Interface\AddOns\AddOns.txt 
Or in WTF folder:
cmd /c mklink AddOns.txt ..\Interface\AddOns\AddOns.txt 
In account folder:
cmd /c mklink AddOns.txt ..\..\AddOns.txt 
--]]

dofile('../AddOnz-makelinks.lua')
_G.linkExpaAddOns = linkAddOns.addons(548)
_G.linkServerAddOns = linkAddOns.server(548, 'Tauri')


linkExpaAddOns('+my') [=[
ZenShortcuts: true
ZenTestZone: true
ZenTools: true
]=]


linkExpaAddOns('base/Ace3') [=[
AceAddon-3.0: true
AceBucket-3.0: true
AceComm-3.0: true
AceConfig-3.0: true
AceConfigCmd-3.0: AceConfig-3.0/
AceConfigDialog-3.0: AceConfig-3.0/
AceConfigRegistry-3.0: AceConfig-3.0/
AceConsole-3.0: true
AceDB-3.0: true
AceDBOptions-3.0: true
AceEvent-3.0: true
AceGUI-3.0: true
AceGUI-3.0-SharedMediaWidgets: true
AceHook-3.0: true
AceLocale-3.0: true
AceSerializer-3.0: true
AceTab-3.0: true
AceTimer-3.0: true
CallbackHandler-1.0: true
LibCommon: true
LibDataBroker-1.1: true
LibDataBrokerIcon-1.0: true
LibSharedMedia-3.0: true
LibStub: true
]=]


linkServerAddOns [=[

Blizzard_AchievementUI: true
Blizzard_ArchaeologyUI: true
Blizzard_ArenaUI: true
Blizzard_AuctionUI: true
Blizzard_AuthChallengeUI: true
Blizzard_BarbershopUI: true
Blizzard_BattlefieldMinimap: true
Blizzard_BindingUI: true
Blizzard_BlackMarketUI: true
Blizzard_Calendar: true
Blizzard_ChallengesUI: true
Blizzard_ClientSavedVariables: true
Blizzard_CombatLog: true
Blizzard_CombatText: true
Blizzard_CompactRaidFrames: true
Blizzard_CUFProfiles: true
Blizzard_DebugTools: true
Blizzard_EncounterJournal: true
Blizzard_GlyphUI: true
Blizzard_GMChatUI: true
Blizzard_GMSurveyUI: true
Blizzard_GuildBankUI: true
Blizzard_GuildControlUI: true
Blizzard_GuildUI: true
Blizzard_InspectUI: true
Blizzard_ItemAlterationUI: true
Blizzard_ItemSocketingUI: true
Blizzard_ItemUpgradeUI: true
Blizzard_LookingForGuildUI: true
Blizzard_MacroUI: true
Blizzard_MovePad: true
Blizzard_PetBattleUI: true
Blizzard_PetJournal: true
Blizzard_PVPUI: true
Blizzard_QuestChoice: true
Blizzard_RaidUI: true
Blizzard_ReforgingUI: true
Blizzard_StoreUI: true
Blizzard_TalentUI: true
Blizzard_TimeManager: true
Blizzard_TokenUI: true
Blizzard_TradeSkillUI: true
Blizzard_TrainerUI: true
Blizzard_VoidStorageUI: true

]=]


