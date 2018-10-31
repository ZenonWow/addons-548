-- AddOns-Tau-raid-v548.txt
--  cmd /c mklink AddOns.txt  ..\..\WTF\AddOns.txt

dofile('../mkAddOnsLinks.lua')


linkAddOnsMap {
_AceLibs = [[d:\Games\WowConf\548\Iface\]]
}

linkAddOns.A715 {
oUF_MovableFrames = true,
}

linkAddOns.Adev {
Binder = true,
CombatMode = true,
MyAdd = true,
MyBindings = true,
ViragDevTool = true,
}

linkAddOns.A548 {
["!BugGrabber"] = true,
BugSack = true,

AdiBags = true,
AdiBags_Config = true,
BagSync = true,
BagBrother = true,
Combuctor = true,
Combuctor_Config = true,
Combuctor_Sets = true,
Combuctor_BindToAccount = true,
Combuctor_EquipmentSets = true,
ArkInventory = true,
ArkInventoryConfig = true,
ArkInventoryRules = true,
ArkInventoryRules_Example = true,

AutoBar = true,
Bazooka = true,
Bazooka_Options = true,
Dominos = true,
Dominos_Auras = true,
Dominos_Bufftimes = true,
Dominos_Cast = true,
Dominos_Config = true,
Dominos_Encounter = true,
Dominos_Quest = true,
Dominos_Roll = true,
Dominos_XP = true,

Broker_Everything = true,
Broker_Garbage = true,
Broker_Garbage-Config = true,
Broker_Garbage-LootManager = true,

oUF_Adirelle = true,
oUF_Adirelle_Arena = true,
oUF_Adirelle_Boss = true,
oUF_Adirelle_Config = true,
oUF_Adirelle_Raid = true,
oUF_Adirelle_Single = true,
oUF_Freebgrid = true,
oUF_Freebgrid_Config = true,
oUF_Lanerra = true,
--oUF_Phanx = true,
--oUF_Phanx_Config = true,
Kui_Media = true,
Kui_Nameplates = true,
Kui_Nameplates_Auras = true,
Ellipsis = true,
Ellipsis_Options = true,
Raven = true,
Raven_Options = true,
["xCT+"] = true,
--Doom_CooldownPulse = true,

LoseControlFix = true,
--GTFO = true,

Skada = true,
Spy = true,

Postal = true,
InboxMailBag = true,

["Prat-3.0"] = true,
["Prat-3.0_Libraries"] = true,
Elephant = true,

idTip = true,
TipTop = true,

Mappy = true,
Mapster = true,
TomTom = true,
SilverDragon = true,
SilverDragon_Data = true,
Explorer = true,
MozzFullWorldMap = true,

AddonLoader = true,
BlizzMove = true,
Viewporter = true,
Leatrix_Plus = true,
MacroBank = true,
AdvancedIconSelector = true,
["AdvancedIconSelector-KeywordData"] = true,

TinyPad = true,
--ViragDevTool = true, -- linkAddOns.Adev
--Hack = true,
--LuaBrowser = true,
--WowLua = true,
--_DevPad = true,
--["_DevPad.GUI"] = true,
--ImprovedFrameStack = true,
--iCPU = true,

FasterCamera = true,
FriendsShare = true,
AllPlayed = true,
Examiner = true,
--EmoteLDB = true,
LiteMount = true,

Archy = true,

GnomishVendorShrinker = true,
Auctionator = true,

MogIt = true,

}


linkAddOns.A548raid {  -- BigWigs
BigWigs\
BigWigs_BlackrockFoundry\
BigWigs_Cataclysm\
BigWigs_CommonAuras\
BigWigs_Core\
BigWigs_Draenor\
BigWigs_EndlessSpring\
BigWigs_HeartOfFear\
BigWigs_Highmaul\
BigWigs_Mogushan\
BigWigs_Options\
BigWigs_Pandaria\
BigWigs_Plugins\
BigWigs_SiegeOfOrgrimmar\
BigWigs_ThroneOfThunder\
LittleWigs\
oRA3\
}

--[[
linkAddOns.A548raid {  -- DBM
DBM-BaradinHold\
DBM-BastionTwilight\
DBM-BlackwingDescent\
DBM-Brawlers\
DBM-Core\
DBM-DefaultSkin\
DBM-DMF\
DBM-DragonSoul\
DBM-Firelands\
DBM-GUI\
DBM-HeartofFear\
DBM-MogushanVaults\
DBM-Pandaria\
DBM-Party-Cataclysm\
DBM-Party-MoP\
DBM-Scenario-MoP\
DBM-SiegeOfOrgrimmar\
DBM-StatusBarTimers\
DBM-TerraceofEndlessSpring\
DBM-ThroneFourWinds\
DBM-ThroneofThunder\
DBM-WorldEvents\
}

linkAddOns.A548Tau {

Blizzard_AchievementUI = true,
Blizzard_ArchaeologyUI = true,
Blizzard_ArenaUI = true,
Blizzard_AuctionUI = true,
Blizzard_AuthChallengeUI = true,
Blizzard_BarbershopUI = true,
Blizzard_BattlefieldMinimap = true,
Blizzard_BindingUI = true,
Blizzard_BlackMarketUI = true,
Blizzard_Calendar = true,
Blizzard_ChallengesUI = true,
Blizzard_ClientSavedVariables = true,
Blizzard_CombatLog = true,
Blizzard_CombatText = true,
Blizzard_CompactRaidFrames = true,
Blizzard_CUFProfiles = true,
Blizzard_DebugTools = true,
Blizzard_EncounterJournal = true,
Blizzard_GlyphUI = true,
Blizzard_GMChatUI = true,
Blizzard_GMSurveyUI = true,
Blizzard_GuildBankUI = true,
Blizzard_GuildControlUI = true,
Blizzard_GuildUI = true,
Blizzard_InspectUI = true,
Blizzard_ItemAlterationUI = true,
Blizzard_ItemSocketingUI = true,
Blizzard_ItemUpgradeUI = true,
Blizzard_LookingForGuildUI = true,
Blizzard_MacroUI = true,
Blizzard_MovePad = true,
Blizzard_PetBattleUI = true,
Blizzard_PetJournal = true,
Blizzard_PVPUI = true,
Blizzard_QuestChoice = true,
Blizzard_RaidUI = true,
Blizzard_ReforgingUI = true,
Blizzard_StoreUI = true,
Blizzard_TalentUI = true,
Blizzard_TimeManager = true,
Blizzard_TokenUI = true,
Blizzard_TradeSkillUI = true,
Blizzard_TrainerUI = true,
Blizzard_VoidStorageUI = true,

}

                                                                                                                                                                                                                                                                                                                                                                                 ouselookStart()
		print('  MouselookLocked->   ' .. MouselookChange() )
  end
end
--]]


local function  HookCommandPrefixed(cmds, cmdName, suffixStart, suffixStop)
	suffixStart= suffixStart or 'Start'
	suffixStop=  suffixStop  or 'Stop'
	hooksecurefunc(cmdName .. suffixStart, function ()  cmds:StartHook(cmdName, cmdName .. suffixStart)  end)
	hooksecurefunc(cmdName .. suffixStop , function ()  cmds:StopHook (cmdName, cmdName .. suffixStop )  end)
end

function  CombatMode:HookCommands()
	CombatMode:LogInit('HookCommands()')
	if  not CommandsLockingMouseList  then  return false  end
	
	--[[
	for  funcName, hookFunc  in  pairs(CommandHooks)  do
		hooksecurefunc(funcName, hookFunc)
	end
	--]]
	for  idx,cmdName  in  ipairs(CommandsLockingMouseList)  do
		-- CommandLockStartHook and co. are defined as locals therefore need to be before this line
		HookCommandPrefixed(CombatMode.CommandsLockingMouse, cmdName)
	end
	for  idx,cmdName  in  ipairs(CommandsReleasingMouseList)  do
		HookCommandPrefixed(CombatMode.CommandsReleasingMouse, cmdName)
	end
	
	HookCommandPrefixed(CombatMode.CommandsLockingMouse, 'TargetPriorityHighlight', 'Start', 'End')
	
	-- drop entries: not used until /reload, secure hooking is non-reversible
	CommandsLockingMouseList= nil
	CommandsReleasingMouseList= nil
	
	return true
end


