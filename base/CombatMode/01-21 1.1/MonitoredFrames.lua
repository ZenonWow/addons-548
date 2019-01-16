CombatMode.FramesOnScreen= {}


-- List of frames that need the mousecursor.
-- If one of these frames show up Mouselook is stopped as soon as you stop pressing any movement buttons.
-- That means if some mildly important message pops up in the heat of the battle
-- you don't loose mouse control over your movement direction until you actually stop moving.
-- AutoRun is ignored, so you can use the mousecursor while you are flying/swimming/trampling over the meadow.

CombatMode.FramesReleasingMouse = {
	"AuctionFrame",       "BankFrame",          "BattlefieldFrame",   "CharacterFrame",
	"ChatMenu",           "EmoteMenu",          "LanguageMenu",       "VoiceMacroMenu",
	"ClassTrainerFrame",  "CoinPickupFrame",    "CraftFrame",         "FriendsFrame",
	"GameMenuFrame",      "GossipFrame",        "GuildRegistrarFrame","HelpFrame",
	"InspectFrame",       "KeyBindingFrame",    "LoXXXotFrame",       "MacroFrame",
	"MailFrame",          "MerchantFrame",      "OptionsFrame",       "PaperDollFrame",
	"PetPaperDollFrame",  "PetRenamePopup",     "PetStable",          "QuestFrame",
	"QuestLogFrame",      "RaidFrame",          "ReputationFrame",    "ScriptErrors",
	"SkillFrame",         "SoundOptionsFrame",  "SpellBookFrame",     "StackSplitFrame",
	"StatsFrame",         "SuggestFrame",       "TabardFrame",        "TalentFrame",
	"TalentTrainerFrame", "TaxiFrame",          "TradeFrame",         "TradeSkillFrame",
	"TutorialFrame",      "UIOptionsFrame",     "UnitPopup",          "WorldMapFrame",
	"CosmosMasterFrame",  "CosmosDropDown",     "ChooseItemsFrame",   "ImprovedErrorFrame",
	"TicTacToeFrame",     "OthelloFrame",       "MinesweeperFrame",   "GamesListFrame",
	"ConnectFrame",       "ChessFrame",         "QuestShareFrame",    "TotemStomperFrame",
	"StaticPopXXXup1",    "StaticPopup2",       "StaticPopup3",       "StaticPopup4",
	"DropDownList1",      "DropDownList2",      "DropDownList3",      "WantAds",
	"CosmosDropDownBis",  "InventoryManagerFrame", "InspectPaperDollFrame",
	"ContainerFrame1",    "ContainerFrame2",    "ContainerFrame3",    "ContainerFrame4",
	"ContainerFrame5",    "ContainerFrame6",    "ContainerFrame7",    "ContainerFrame8",
	"ContainerFrame9",    "ContainerFrame10",   "ContainerFrame11",   "ContainerFrame12",
	"ContainerFrame13",   "ContainerFrame14",   "ContainerFrame15",   "ContainerFrame16",
	"ContainerFrame17",   "AutoPotion_Template_Dialog","NxSocial",    "ARKINV_Frame1",
	"AchievementFrame",   "LookingForGuildFrame", "PVPUIFrame",       "GuildFrame",
	"WorldMapFrame",      "VideoOptionsFrame",  "InterfaceOptionsFrame", "WardrobeFrame",
	"ACP_AddonList",      "PlayerTalentFrame",  "PVEFrame",           "EncounterJournal",
	"PetJournalParent",   "AccountantFrame",    "ImmersionFrame",     "BagnonFrameinventory",
	"GwCharacterWindow", "GwCharacterWindowsMoverFrame", "StaticPopup1",
	"ElephantFrame",
	"AdiBagsContainer1",
}

CombatMode.FramesReleasingMouse2 = {
	'GameMenuFrame',
	'InterfaceOptionsFrame',
	'VideoOptionsFrame',

	'WorldMapFrame',

	'AuctionFrame',
	'BankFrame',
	'CharacterFrame',

	'BattlefieldFrame',

	'ChatMenu',
	'EmoteMenu',
	'LanguageMenu',
	'VoiceMacroMenu',
	'CoinPickupFrame',
	'CraftFrame',

	'FriendsFrame',
	'WhoFrame',			-- new in 8.0
	'ChannelFrame',	-- new in 8.0
	'RaidFrame',

	'GossipFrame',
	'ClassTrainerFrame',
	'GuildRegistrarFrame',
	'HelpFrame',
	'InspectFrame',
	'KeyBindingFrame',
	'LoXXXotFrame',
	'MacroFrame',
	'MailFrame',
	'MerchantFrame',
	'OptionsFrame',
	'PaperDollFrame',
	'PetPaperDollFrame',
	'PetRenamePopup',
	'PetStable',
	'QuestFrame',
	'QuestLogFrame',
	'ReputationFrame',
	'ScriptErrors',
	'SkillFrame',
	'SoundOptionsFrame',
	'SpellBookFrame',
	'StackSplitFrame',
	'StatsFrame',
	'SuggestFrame',
	'TabardFrame',
	'TalentFrame',
	'TalentTrainerFrame',
	'TaxiFrame',
	'TradeFrame',
	'TradeSkillFrame',
	'TutorialFrame',
	'UIOptionsFrame',
	'UnitPopup',
	'WorldMapFrame',
	'CosmosMasterFrame',
	'CosmosDropDown',
	'ChooseItemsFrame',
	'ImprovedErrorFrame',
	'TicTacToeFrame',
	'OthelloFrame',
	'MinesweeperFrame',
	'GamesListFrame',
	'ConnectFrame',
	'ChessFrame',
	'QuestShareFrame',
	'TotemStomperFrame',
	'StaticPopXXXup1',
	'StaticPopup2',
	'StaticPopup3',
	'StaticPopup4',
	'DropDownList1',
	'DropDownList2',
	'DropDownList3',
	'WantAds',
	'CosmosDropDownBis',
	'InventoryManagerFrame',
	'InspectPaperDollFrame',
	'ContainerFrame1',
	'ContainerFrame2',
	'ContainerFrame3',
	'ContainerFrame4',
	'ContainerFrame5',
	'ContainerFrame6',
	'ContainerFrame7',
	'ContainerFrame8',
	'ContainerFrame9',
	'ContainerFrame10',
	'ContainerFrame11',
	'ContainerFrame12',
	'ContainerFrame13',
	'ContainerFrame14',
	'ContainerFrame15',
	'ContainerFrame16',
	'ContainerFrame17',
	'AutoPotion_Template_Dialog',
	'NxSocial',
	'ARKINV_Frame1',
	'AchievementFrame',
	'LookingForGuildFrame',
	'PVPUIFrame',
	'GuildFrame',
	'ACP_AddonList',
	'PlayerTalentFrame',
	'PVEFrame',
	'EncounterJournal',
	'PetJournalParent',
	'AccountantFrame',
	-- NxMap1',  (carbonite's world map breaks mouselook)
	-- StoreFrame', (causes taint??!??  wtf, blizzard?)
	"StaticPopup1",
	
	'ImmersionFrame',
	'BagnonFrameinventory',
	'GwCharacterWindow',
  'GwCharacterWindowsMoverFrame',
	"ElephantFrame",
	"AdiBagsContainer1",
	
	-- new in 8.0 (source: MouselookHandler)
  'MovieFrame.CloseDialog',
  'CinematicFrameCloseDialog',
  
}  -- end CombatMode.FramesReleasingMouse






local function tindexof(arr, item)
	for i = 1,#arr  do  if  arr[i] == item  then  return i  end end
end

local function  tremovevalue(array, item)
	local i= tindexof(array, item)
	return  i  and  table.remove(array, i)
end


CombatMode.FramesOnScreen= {}
local function FrameWithMouse_OnShow(frame)
	print('Mouselook_OnShow():  ' .. frame:GetName())  -- colors.green .. 
	
	-- if already shown do nothing
	if  tindexof(CombatMode.FramesOnScreen, frame)  then  return  end
	
	table.insert(CombatMode.FramesOnScreen, frame)
	CombatMode:UpdateState(false, 'FrameOnShow')
end

local function FrameWithMouse_OnHide(frame)
	print('Mouselook_OnHide():  ' .. frame:GetName())  -- colors.lightblue .. 
	
	local removed= tremovevalue(CombatMode.FramesOnScreen, frame)
	if  not removed  then  return  end
	
	CombatMode:UpdateState(true, 'FrameOnHide')
end


function  CombatMode:HookUpFrames()
	local missingFrames
	self.HookedFrames= self.HookedFrames or {}
	-- there is no way to unhook/rehook frames, therefore HookedFrames can be dropped/removed
  for  idx, frameName  in  pairs(self.FramesReleasingMouse)  do
		-- convert  [frameName]= true  format entries to  [idx]= frameName
		--if  type(idx) == 'string'  then  frameName= idx  end
		if  frameName == true  then  frameName= idx  end
			
		local frame= _G[frameName]
		if  not frameName  then  -- skip  [frameName]= false  format entries
		elseif  self.HookedFrames  and  self.HookedFrames[frameName]  then
			print('Frame hooked again:  ' .. frameName)
		elseif  frame then
			self.HookedFrames[frameName]= frame
			frame:HookScript('OnShow', FrameWithMouse_OnShow)
			frame:HookScript('OnHide', FrameWithMouse_OnHide)
		else
			-- missing frames returned
			-- to be indexed if loaded later
			--print('Yet missing frame:  ' .. frameName)
			missingFrames= missingFrames or {}
			missingFrames[#missingFrames+1]= frameName
		end
  end
	-- frames not found are kept
	self.FramesReleasingMouse= missingFrames
end




--[[
--MLL.FramesOnScreen= {}
MLL.LastFrameOnScreen= false
function  CombatMode:UnmouseableFrameOnScreen()
	
	if  MLL.LastFrameOnScreen  and  MLL.LastFrameOnScreen:IsVisible()
	then  return MLL.LastFrameOnScreen  end
	
	if  MLL.LastFrameOnScreen  then  Print('UnmouseableFrameOnScreen(): Last visible frame was hidden: ' .. (MLL.LastFrameOnScreen:GetName() or 'nil') )  end
	MLL.LastFrameOnScreen= false
	for  frameName, frame  in  pairs(MLL.FramesToShowMouse)  do
		if  frame and frame ~= true and frame:IsVisible()  then
			local  globalName= ''
			if  frameName ~= frame:GetName()  then  globalName= '  -> _G.' .. frameName  end
			Print('UnmouseableFrameOnScreen(): Found frame on screen: ' .. (frame:GetName() or 'nil') .. globalName )
			MLL.LastFrameOnScreen= frame
			return frame
		end
	end
	Print('UnmouseableFrameOnScreen(): No frame found on screen' )
	return nil
end
--]]
