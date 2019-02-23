-- AddOns-server-548-Tau.lua

dofile('../AddOnz-makelinks.lua')
_G.linkExpaAddOns = linkAddOns.addons(548)
_G.linkServerAddOns = linkAddOns.server(548, 'Tauri')



linkExpaAddOns('+my') [=[
!DevTools
!EarlyLoad
ZenShortcuts
ZenTestZone
ZenTools
]=]


linkExpaAddOns('base/Ace3') [=[
AceAddon-3.0
AceBucket-3.0
AceComm-3.0
AceConfig-3.0
AceConfigCmd-3.0: AceConfig-3.0/
AceConfigDialog-3.0: AceConfig-3.0/
AceConfigRegistry-3.0: AceConfig-3.0/
AceConsole-3.0
AceDB-3.0
AceDBOptions-3.0
AceEvent-3.0
AceGUI-3.0
AceGUI-3.0-SharedMediaWidgets
AceHook-3.0
AceLocale-3.0
AceSerializer-3.0
AceTab-3.0
AceTimer-3.0
CallbackHandler-1.0
LibShared
LibDataBroker-1.1
LibDataBrokerIcon-1.0
LibSharedMedia-3.0
LibStub
]=]



linkServerAddOns [=[

Blizzard_AchievementUI
Blizzard_ArchaeologyUI
Blizzard_ArenaUI
Blizzard_AuctionUI
Blizzard_AuthChallengeUI
Blizzard_BarbershopUI
Blizzard_BattlefieldMinimap
Blizzard_BindingUI
Blizzard_BlackMarketUI
Blizzard_Calendar
Blizzard_ChallengesUI
Blizzard_ClientSavedVariables
Blizzard_CombatLog
Blizzard_CombatText
Blizzard_CompactRaidFrames
Blizzard_CUFProfiles
Blizzard_DebugTools
Blizzard_EncounterJournal
Blizzard_GlyphUI
Blizzard_GMChatUI
Blizzard_GMSurveyUI
Blizzard_GuildBankUI
Blizzard_GuildControlUI
Blizzard_GuildUI
Blizzard_InspectUI
Blizzard_ItemAlterationUI
Blizzard_ItemSocketingUI
Blizzard_ItemUpgradeUI
Blizzard_LookingForGuildUI
Blizzard_MacroUI
Blizzard_MovePad
Blizzard_PetBattleUI
Blizzard_PetJournal
Blizzard_PVPUI
Blizzard_QuestChoice
Blizzard_RaidUI
Blizzard_ReforgingUI
Blizzard_StoreUI
Blizzard_TalentUI
Blizzard_TimeManager
Blizzard_TokenUI
Blizzard_TradeSkillUI
Blizzard_TrainerUI
Blizzard_VoidStorageUI

]=]


