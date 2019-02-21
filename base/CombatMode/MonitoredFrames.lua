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
	
	"ImmersionFrame",			"BagnonFrameinventory",		"ElephantFrame",
	"AdiBagsContainer1","AdiBackpack","AdiBank",
	"GwCharacterWindow",	"GwCharacterWindowsMoverFrame",
	
	--"WhoFrame","ChannelFrame",	-- new in client 7.0?  these are children of FriendsFrame, only need to monitor that
	"CinematicFrameCloseDialog",		-- new in client 7.0? (source: MouselookHandler)
  --"MovieFrame.CloseDialog",		-- getglobal(), _G  can't resolve this
	
	-- "NxMap1",			-- Carbonite's world map breaks mouselook
	-- "StoreFrame",	-- causes taint?
}  -- end CombatMode.FramesToHook




local tDeleteItem = _G.tDeleteItem  -- from FrameXML/Util.lua

-- tableProto is prototype (class) for tables with shorthand functions:
local tableProto= {}
Addon.tableProto= tableProto
setmetatable(tableProto, { __index= table } )		-- inheriting methods from builtin table:  insert(), remove()

function  tableProto:indexOf(item)
	for  i= 1,#self  do
		if  self[i] == item  then  return i  end
	end
end

tableProto.removeFirst = tDeleteItem
--[[
function  tableProto:removeFirst(item)
	-- not using  self:indexOf()  so it's not necessary to set as metatable (inherit) tableProto
	-- also it makes  self:indexOf()  non-virtual, that is cannot be overridden in a subclass/instance
	local i= tableProto.indexOf(self, item)
	return  i  and  table.remove(self, i)
end
--]]

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

CombatMode.FramesOnScreen= setmetatable({}, { __index= tableProto } )

-- Weak valued hashmap to allow garbagecollecting frames
CombatMode.HookedFrames= setmetatable({}, { __mode = "v" })



-- Does not support square brackets (eg. MovieFrame["CloseDialog"]), that would require intricate logic, unnecessary in this use-case.
local function getfield(root, name)
	for i,fieldname in ipairs({ string.split(".", name) }) do
		if not root then  return nil  end
		root = root[fieldname]
	end
	return root
end


function  CombatMode:HookFrame(frameName)
	if self.HookedFrames[frameName] then  return  end

	-- _G[frameName] and getglobal(frameName) does not work for child frames like "MovieFrame.CloseDialog"
	local frame =  _G[frameName]  or  getfield(_G, frameName)
	if  not frame  then   return  end
	
	self.HookedFrames[frameName] = frame
	
	frame:HookScript('OnShow', FrameOnShow)
	if  not frame:GetScript('OnShow')  then  frame:SetScript('OnShow', FrameOnShow)  end
	frame:HookScript('OnHide', FrameOnHide)
	if  not frame:GetScript('OnHide')  then  frame:SetScript('OnHide', FrameOnHide)  end
	
	if  frame:IsVisible()  then
		CombatMode:LogFrame('  CM:HookUpFrames():  '.. CombatMode.colors.show .. frame:GetName() ..'|r is already visible')
		CombatMode.FramesOnScreen:setInsertLast(frame)
	end
end


function  CombatMode:HookUpFrames()
	self:LogInit('CombatMode:HookUpFrames()')
	local missingFrames = {}

	-- Monitor UISpecialFrames[]:  some windows added by bliz FrameXML and also addons. No need to list them by name.
	for  idx, frameName  in  ipairs(_G.UISpecialFrames)  do
		local frame= self:HookFrame(frameName)
	end
	
	-- UIChildWindows[]:  parents should be monitored.
	-- UIMenus[]:  
	

	for  idx, frameName  in  ipairs(self.FramesToHook)  do
		-- if  self.HookedFrames[frameName]  then  print('CombatMode:HookUpFrames(): frame hooked again:  ' .. frameName)  end
		local frame= self:HookFrame(frameName)
		if  not frame  then	
			-- missing frames stored for a next round
			missingFrames[frameName] = frameName
			missingFrames[#missingFrames+1]= frameName
		end
	end

	self.FramesToHook= missingFrames
	if  0 < #missingFrames  and  self:IsLogging('Init')  and  self.logging.Anomaly  then
		--local missingList= table.concat(missingFrames, ', ')		-- this can be long
		self:LogInit('  CM:HookUpFrames():  missing '.. #missingFrames ..' frames.  List them by entering   /dump CombatMode.FramesToHook')
	end
end


hooksecurefunc('CreateFrame', function(frameType, frameName, ...)
	if  not CombatMode.FramesToHook[frameName]  then  return  end
	
	local frame = CombatMode:HookFrame(frameName)
  if  frame  then
		CombatMode.FramesToHook[frameName] = nil
		tDeleteItem(CombatMode.FramesToHook, frameName)
	end
end)



