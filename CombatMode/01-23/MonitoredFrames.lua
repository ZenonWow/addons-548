--[[ List visible frames releasing mouse:
/dump CombatMode.FramesOnScreen
--]]


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
	"TutorialFrame",      "UIOptionsFrame",     "UnitPopup",          
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
	"PetJournalParent",   "AccountantFrame",
	
	"ImmersionFrame",			"BagnonFrameinventory","AdiBagsContainer1",	"ElephantFrame",
	"GwCharacterWindow",	"GwCharacterWindowsMoverFrame",
	
	--"WhoFrame","ChannelFrame",	-- new in client 7.0?  these are children of FriendsFrame, only need to monitor that
  "MovieFrame.CloseDialog","CinematicFrameCloseDialog",		-- new in client 7.0? (source: MouselookHandler)
	
	-- "NxMap1",			-- Carbonite's world map breaks mouselook
	-- "StoreFrame",	-- causes taint?
}  -- end CombatMode.FramesReleasingMouse




-- tableProto is prototype (class) for tables with shorthand functions:
local tableProto= {}
setmetatable(tableProto, { __index= table } )		-- inheriting from builtin table

function  tableProto:indexOf(item)
	for  i= 1,#self	do
		if  self[i] == item  then  return i  end
	end
end

function  tableProto:setInsert(item)
	if  tableProto.indexOf(self, item)  then  return false  end
	table.insert(self, item)
	return true
end

function  tableProto:removeValue(item)
	-- not using  self:indexOf()  so it's not necessary to set as metatable (inherit) tableProto
	-- also it makes  self:indexOf()  non-virtual, that is cannot be overridden in a subclass/instance
	local i= tableProto.indexOf(self, item)
	return  i  and  table.remove(self, i)
end




function CombatMode:LogFrame(...)
	if  self.logging  and  self.loggingFrame  then  print(...)  end
end


local function FrameOnShow(frame)
	CombatMode:LogFrame('  CM_FrameOnShow('.. CombatMode.colors.green .. frame:GetName() ..'|r)')
	
	-- if already shown do nothing
	if  not CombatMode.FramesOnScreen:setInsert(frame)  then  return  end
	
	CombatMode:UpdateMouselook(false, 'FrameOnShow')
end


local function FrameOnHide(frame)
	CombatMode:LogFrame('  CM_FrameOnHide('.. CombatMode.colors.lightblue .. frame:GetName() ..'|r)')
	
	local removed= CombatMode.FramesOnScreen:removeValue(frame)
	if  not removed  then  return  end
	
	CombatMode:UpdateMouselook(true, 'FrameOnHide')
end

CombatMode.FramesOnScreen= {}
setmetatable(CombatMode.FramesOnScreen, { __index= tableProto } )




function  CombatMode:HookUpFrames()
	self:LogInit('CombatMode:HookUpFrames()')
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
			self:LogInit('Frame hooked again:  ' .. frameName)
		elseif  frame then
			self.HookedFrames[frameName]= frame
			frame:HookScript('OnShow', FrameOnShow)
			frame:HookScript('OnHide', FrameOnHide)
		else
			-- missing frames returned
			-- to be indexed if loaded later
			self:LogInit('CombatMode - Yet missing frame:  ' .. frameName)
			missingFrames= missingFrames or {}
			table.insert(missingFrames, frameName)
			--missingFrames[#missingFrames+1]= frameName
		end
  end
	-- frames not found are kept
	self.FramesReleasingMouse= missingFrames
end



