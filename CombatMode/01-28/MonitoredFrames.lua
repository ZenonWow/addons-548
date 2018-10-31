local AddonName, Addon = ...

--[[ List visible frames releasing mouse:
/dump CombatMode.FramesOnScreen
List frames not hooked / missing:
/dump CombatMode.FramesToHook
--]]


-- List of frames that need the mousecursor.
-- If one of these frames show up Mouselook is stopped as soon as you stop pressing any movement buttons.
-- That means if some mildly important message pops up in the heat of the battle
-- you don't loose mouse control over your movement direction until you actually stop moving.
-- AutoRun is ignored, so you can use the mousecursor while you are flying/swimming/trampling over the meadow.

CombatMode.FramesToHook = {
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
	"CinematicFrameCloseDialog",		-- new in client 7.0? (source: MouselookHandler)
  --"MovieFrame.CloseDialog",		-- getglobal(), _G  can't resolve this
	
	-- "NxMap1",			-- Carbonite's world map breaks mouselook
	-- "StoreFrame",	-- causes taint?
}  -- end CombatMode.FramesToHook




-- tableProto is prototype (class) for tables with shorthand functions:
local tableProto= {}
Addon.tableProto= tableProto
setmetatable(tableProto, { __index= table } )		-- inheriting methods from builtin table:  insert(), remove()

function  tableProto:indexOf(item)
	for  i= 1,#self	do
		if  self[i] == item  then  return i  end
	end
end

function  tableProto:removeFirst(item)
	-- not using  self:indexOf()  so it's not necessary to set as metatable (inherit) tableProto
	-- also it makes  self:indexOf()  non-virtual, that is cannot be overridden in a subclass/instance
	local i= tableProto.indexOf(self, item)
	return  i  and  table.remove(self, i)
end

function  tableProto:setInsertLast(item)
	if  tableProto.indexOf(self, item)  then  return false  end
	table.insert(self, item)
	return true
end

function  tableProto:setReInsertLast(item)
	local replaced= tableProto.removeFirst(self, item)
	table.insert(self, item)
	return replaced
end

--[[
function  tableProto:setInsert(...)		-- parameters:  [index, ]item
	local args= {...}
	local item= args[#args < 2 and 1 or 2]
	if  tableProto.indexOf(self, item)  then  return false  end
	
	table.insert(self, ...)
	return true
end

function  tableProto:setReInsert(item, index)		-- index == nil: insert last
	local i= tableProto.indexOf(self, item)
	local replaced=  i  and  table.remove(self, i)
	
	-- if the removed item was before the insertion index, then index moved 1 to the left
	if  i  and  index  and  i < index  then  index= index - 1  end
	
	table.insert(self, item, index)
	return replaced
end
--]]




local function FrameOnShow(frame)
	CombatMode:LogFrame('  CM_FrameOnShow('.. CombatMode.colors.show .. frame:GetName() ..'|r)')
	
	-- if already visible do nothing
	if  not CombatMode.FramesOnScreen:setInsertLast(frame)  then  return  end
	
	CombatMode:UpdateMouselook(false, 'FrameOnShow')
end


local function FrameOnHide(frame)
	CombatMode:LogFrame('  CM_FrameOnHide('.. CombatMode.colors.hide .. frame:GetName() ..'|r)')
	
	local removed= CombatMode.FramesOnScreen:removeFirst(frame)
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
  for  idx, frameName  in  ipairs(self.FramesToHook)  do
		
		local frame= _G[frameName]		-- does not work for child frames like "MovieFrame.CloseDialog"
		-- local frame= getglobal(frameName)		-- neither does this
		
		if  self.HookedFrames  and  self.HookedFrames[frameName]  then
			self:LogInit('Frame hooked again:  ' .. frameName)
			
		elseif  frame  then
			self.HookedFrames[frameName]= frame
			frame:HookScript('OnShow', FrameOnShow)
			frame:HookScript('OnHide', FrameOnHide)
			if  frame:IsVisible()  then
				CombatMode:LogFrame('  CM:HookUpFrames():  '.. CombatMode.colors.show .. frame:GetName() ..'|r is already visible')
				CombatMode.FramesOnScreen:setInsertLast(frame)
			end
			
		else
			-- missing frames returned
			-- to be indexed if loaded later
			missingFrames= missingFrames or {}
			table.insert(missingFrames, frameName)
			--missingFrames[#missingFrames+1]= frameName
		end
  end
	
	-- frames not found are kept
	if  missingFrames  and  self:IsLogging('Init')  and  self.logging.Anomaly  then
		--local missingList= table.concat(missingFrames, ', ')		-- this can be long
		self:LogInit('  CM:HookUpFrames():  missing '.. #missingFrames ..' frames.  List them by entering   /dump CombatMode.FramesToHook')
	end
	self.FramesToHook= missingFrames
end



