--[[
## X-LoadOn:  Login
## X-Load-OnlyOne:  Crafting
## X-Load-OnlyOne:  ToolTip
## X-Load-OnlyOne:  Nameplate
## X-Load-OnlyOne:  UnitFrame
-- TODO: 'Synchronous'  'Instant'  'UserInterface'  'Quick'  'Queued'  'Broker'  'LowPrio'  "N sec"  "N min"
## X-LoadOn-Login:  UserInterface
## X-LoadOn-Login:  Broker
## X-LoadOn-Login:  LowPrio
## X-LoadOn-Login-Delay:  30 sec
## X-LoadOn-Login-Delay:  1 min
## X-LoadOn-Addon:
## X-LoadOn-Slash:
## X-LoadOn-Binding:  -- TODO
## X-LoadOn-Tab:  -- TODO: AuctionHouse addons
## X-LoadOn-LDB-Launcher:
## X-Load-Delay:
## X-Load-Condition:
## X-Load-Early:  BeforeAddonLoader, BeforeSavedVariables, AfterAddonLoader, OptionalBeforeAddon (in X-Load-Before)
## X-Load-Before:
--]]

local ADDON_NAME, private = ...
local AddonLoader = AddonLoader
local tostrjoin = private.tostrjoin
local Debug = private.Debug
local safecall = private.safecall
local ConditionManager = AddonLoader.ConditionManager
local _G, tostringall, tonumber, tostring, string, strjoin, type, pairs, ipairs, tremove, select, next, pcall, xpcall = 
      _G, tostringall, tonumber, tostring, string, strjoin, type, pairs, ipairs, tremove, select, next, pcall, xpcall
local EMPTY = {}  -- constant empty object to use in place of nil table reference

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: INTERFACEOPTIONS_ADDONCATEGORIES InterfaceOptionsFrame_OpenToCategory InterfaceOptions_AddCategory
-- GLOBALS: IsInInstance InCombatLockdown GetNumRaidMembers GetNumPartyMembers
-- GLOBALS: GetRealmName IsInGuild UnitIsPVP UnitClass IsResting UnitLevel
-- GLOBALS: GetAddOnDependencies
-- GLOBALS: CreateFrame hooksecurefunc geterrorhandler LibStub UIParent setfenv
-- GLOBALS: IsAddOnLoaded



-- Called from metadata: global function to check if any frame is shown from the parameters
function _G.IsFrameShown(...)
	for  i = 1,select('#', ...)  do
		local f = select(i, ...)
		-- Accept name of frame
		if  type(f) == 'string'  then  f = _G[f]  end
		-- If it looks like a frame then check if shown
		if  type(f) == 'object'  and  type(f.IsShown) == 'function'  and  f:IsShown()  then  return true  end
	end
	return false
end





--local function dontParse(fieldValue)  return fieldValue  end
local dontParse = nil

local function  tindexof(arr, item)
	for  i= 1,#arr	do  if  arr[i] == item  then  return i  end end
end

local function strsplitObjectKey(hookedName)
	local object, key = strsplit(".:", hookedName)
	if  not key  then  return nil, object  end
	return object, key
end

local packNonEmpty = private.packNonEmpty

--[[
local function strsplitPack(separator, str)
	return packNonEmpty(strsplit( separator, str ))
end

local function strsplitSkipEmpty(separator, str)
	return unpack(packNonEmpty(strsplit( separator, str )))
end
--]]

local function parseLuaObject(str)
	if  not str  or  str[1] ~= '{'  or  str[#str] ~= '}'  then  return nil  end
	
	local body = "return "..str
	local ran, result = safecall(loadstring, body)
	local ran, object =  ran  and  type(result) == 'function'  and  safecall(result)
	return  ran  and  object
end




local function DeleteDataObject(dataobj)
	-- Will this break? DataBrokers still have the reference.
	-- Hopefully they overwrite it when the addon creates the real DataObject.
	local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
	local name = ldb.namestorage[dataobj]
	if  name  then  ldb.proxystorage[name] = nil  end
	ldb.namestorage[dataobj] = nil
	ldb.attributestorage[dataobj] = nil
end



local function RemoveInterfaceOptions(name)
	for k, f in ipairs(INTERFACEOPTIONS_ADDONCATEGORIES) do
		if f == name or f.name == name then
			tremove(INTERFACEOPTIONS_ADDONCATEGORIES, k)
			break
		end
	end
end

local function InterfaceOptions_OnShow(self)
	if  not IsAddOnLoaded(self.addonName)  then
		-- remove from options frame
		RemoveInterfaceOptions(self)
		self:Hide()
		-- Load addon without delay
		AddonLoader:LoadAddOn(self.addonName, self.loadCondition)
		
		-- refresh InterfaceOptionsFrame
		safecall(InterfaceOptionsFrame_OpenToCategory, self.name)
		safecall(InterfaceOptionsFrame_OpenToCategory, self.name)
	end
end




--[[
-- Credit: https://wow.gamepedia.com/RunSlashCmd
function RunSlashCmd(cmd)
  local slash, rest = cmd:match("^(%S+)%s*(.-)$")
  for name, func in pairs(SlashCmdList) do
     local i, slashCmd = 1
     repeat
        slashCmd, i = _G["SLASH_"..name..i], i + 1
        if slashCmd == slash then
           return true, func(rest)
        end
     until not slashCmd
  end
  -- Okay, so it's not a slash command. It may also be an emote.
  local i = 1
  while _G["EMOTE" .. i .. "_TOKEN"] do
     local j, cn = 2, _G["EMOTE" .. i .. "_CMD1"]
     while cn do
        if cn == slash then
           return true, DoEmote(_G["EMOTE" .. i .. "_TOKEN"], rest);
        end
        j, cn = j+1, _G["EMOTE" .. i .. "_CMD" .. j]
     end
     i = i + 1
  end
end 
--]]

--[[
local function SlashCmdRunner1(cond)
	local editbox = _G.ChatFrameEditBox
		or  _G.ChatEdit_GetActiveWindow()  -- Support for 3.3.5 and newer
	assert(editbox, "Failed to open chat message box to run the loaded addon's command.")
	editbox:SetText(msg)
	_G.ChatEdit_SendText(editbox, 1)
end
--]]

local function SlashCmdRunner2(cond)
	_G.ChatFrame_OpenChat(cond.replaySlashCommand)
	_G.ChatEdit_SendText(editbox, 1)
end

local function SlashCmdRunner3(cond)
	-- From FrameXML/ChatFrame.lua / ChatFrame_ImportAllListsToHash():
	ChatFrame_ImportListToHash(SlashCmdList, hash_SlashCmdList)
	-- Is hash_SlashCmdList[] sensitive to tainting?  Cause ChatEdit_SendText() will taint it too.
	local slashFunc = _G.hash_SlashCmdList[cond.slashCommand]
	if  not slashFunc  then
		print("Addon "..cond.addonName.." did not register the command: "..cond.slashCommand)
		return
	end
	local ran, result = safecall(slashFunc, cond.slashArgument, cond.editBox)
end

local function SlashCmdRunner(cond)
  local slashFunc
	-- SlashCmdList should contain only the newly registered commands. It is hashed and wiped at each chat command execution.
	for name, handler in pairs(SlashCmdList) do
		for i = 1,100 do
			slash = _G["SLASH_"..name..i]
			if slash == cond.slashCommand then
				slashFunc = handler ; break
			end
		end
  end
	if  not slashFunc  then
		print("Addon "..cond.addonName.." did not register the command: "..cond.slashCommand)
		return
	end
	local ran, result = safecall(slashFunc, cond.slashArgument, cond.editBox)
end

local function SlashCmdHandler(cond, slash, ...)
	--local slash = _G['SLASH_'..commandLong]
	cond.slashCommand = slash
	cond.slashArgument, cond.editBox = ...
	cond.afterLoadFunc = SlashCmdRunner
	-- Load addon asynchronously
	cond.delayPriority = 'instant'
	AddonLoader.QueueLoadAddOn(cond.addonName, cond)
end







ConditionManager.OptionTemplates = {
	{
		-- X-Load-Condition
		-- General precondition for loading an addon. Applies to all event, script, securehook triggers.
		-- Does not effect Slash and Launcher triggers: those are explicit user commands more important than automated conditions.
		condName = "Condition",
		parseMain = function(cond)
			-- TODO:
			ConditionManager.AddonOptions[cond.addonName].Condition = ConditionManager:ParseLoadOnFunc(cond)
		end,
	},
	
	{
		condName = "Delay",
		parseMain = function(cond)
			--delayPriority = cond.fieldValue
			--local addonFields = ConditionManager.MergedConditions[cond.addonName]
			-- 'Synchronous'  'Instant'  'UserInterface'  'Quick'  'Queued'  'Broker'  'LowPrio'  "N sec"  "N min"
			ConditionManager.AddonOptions[cond.addonName].Delay = field.mainValue
		end,
	},
	
	{
		condName = "Early",
		--delayPriority = 'synchronous',
		-- OnUpdate is not fireing while addons are loaded therefore only synchronous loading will happen. This is what the custom handler code does anyway.
		--addonNames = { ADDON_NAME },    -- Load after AddonLoader SavedVariables
		options = {
			BeforeSavedVariables = function(cond)  LoadAddOn(cond.addonName)  end,
			AfterAddonLoader = function(cond)  cond.eventList = {"ADDON_LOADED"}  end,
		},
		handler = function(cond, event, addonName)
			-- AfterAddonLoader triggers when AddonLoader's SavedVariables has been loaded, therefore overrides are available, but not parsed yet.
			return  event ~= 'ADDON_LOADED'  or  addonName == ADDON_NAME
		end,
	},
}





--[[ TODO: document
-- parseMain(cond)
-- Optional. Parse the textual value to cond.properties, as the handler expects.
-- loadChildren = ConditionManager.LoadChildren,
-- Split fieldValue into eventName(s), and load the childConds named X-Load-<eventName>-If, if present.
-- LoadCondition() will call for all eventNames registerChildHook(childCond or cond, eventName) 
-- registerChildHook(condition, eventName)
-- It registers the event handler hook for the condition. The way to register the hook is specific to each condition template.
-- handler(condition, event, ...)
-- Called when the event occurs, returns truthy value if the addon should be loaded.
-- The lack of handler() signals to load the addon whenever the event occurs.
--]]

ConditionManager.ConditionTemplates = {
	{
		condName = "Bank",
		eventList = {"BANKFRAME_OPENED"},
		--frameList = {'BankFrame'},
	},{
		condName = "Mailbox",
		eventList = {"MAIL_SHOW"},
		--frameList = {'MailFrame'},
	},{
		condName = "Merchant",
		eventList = {"MERCHANT_SHOW"},
		--frameList = {'MerchantFrame'},
	},{
		condName = "AuctionHouse",
		eventList = {"AUCTION_HOUSE_SHOW"},
		--frameList = {'AuctionFrame'},
	},{
		condName = "Crafting",
		eventList = {"TRADE_SKILL_SHOW", "CRAFT_SHOW"},
		--frameList = {'TradeSkillFrame'},
	},

	{
		condName = "Arena",
		eventList = {"ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD"},
		handler = function()  return  'arena' == select(2, IsInInstance())  end,
	},{
		condName = "Battleground",
		eventList = {"ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD"},
		handler = function()  return  'pvp' == select(2, IsInInstance())  end,
	},{
		condName = "Instance",
		eventList = {"ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD"},
		handler = function()
			local _, instanceType = IsInInstance()
			return  instanceType == 'party'  or  instanceType == 'raid'
		end,
	},

	{
		condName = "Combat",
		eventList = {"PLAYER_REGEN_DISABLED", "PLAYER_ENTERING_WORLD"},
		handler = InCombatLockdown,
		-- Slowing down by loading an addon when entering combat is generally not a good idea, therefore
		-- this will load "sometime" after entering combat when fps is above half of the top fps.
		-- To load on the very next frame set  X-LoadOn-Combat-Delay: instant
		delayPriority = 'goodfps',
		delayFrames = 60,    -- Minimum delay:  1 sec with 60fps, 2 sec with 30fps
		--[[
		handler = function(eventName)
			if eventName == "PLAYER_REGEN_DISABLED" then return true end
			if eventName == "PLAYER_ENTERING_WORLD" then return InCombatLockdown() end
		end,
		--]]
	},{
		condName = "LeaveCombat",
		eventList = {"PLAYER_REGEN_ENABLED"},
	},

	{
		condName = "Resting",
		eventList = {"PLAYER_UPDATE_RESTING", "PLAYER_ENTERING_WORLD"},
		handler = IsResting,
	},{
		condName = "NotResting",
		eventList = {"PLAYER_UPDATE_RESTING", "PLAYER_ENTERING_WORLD"},
		handler = function() return not IsResting() end,
	},


	{
		condName = "PvPFlagged",
		eventList = {"UNIT_FACTION", "PLAYER_ENTERING_WORLD"},
		handler = function() return UnitIsPVP("player") end,
	},{
		condName = "Group",
		eventList = {"GROUP_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD"},
		handler = function() return GetNumGroupMembers() > 0 or GetNumSubgroupMembers() > 0 end,
	},{
		condName = "Raid",
		eventList = {"GROUP_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD"},
		handler = function() return GetNumGroupMembers() > 0 and IsInRaid() end,
	},{
		condName = "Guild",
		eventList = {"PLAYER_LOGIN", "GUILD_ROSTER_UPDATE", "GUILD_XP_UPDATE"},
		handler = IsInGuild,
	},


	{
		condName = "Realm",
		eventList = {"PLAYER_LOGIN"},
		parseMain = dontParse,
		handler = function(cond, event, ...)  return GetRealmName() == cond.mainValue  end,
	},{
		condName = "Zone",
		eventList = {"ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "MINIMAP_ZONE_CHANGED"},
		parseMain = dontParse,
		handler = function(cond, event, ...)
			local BZ = LibStub and LibStub("LibBabble-Zone-3.0", true) -- silent check for BZ
			local subzone = string.trim(GetSubZoneText()) -- yeah really..
			local realzone = GetRealZoneText()
			for zone in cond.mainValue:gmatch('(%w[^,]+%w)') do
				if (BZ and BZ[zone] and (realzone == BZ[zone] or subzone == BZ[zone])) or 
					realzone == zone or subzone == zone then
					return true
				end
			end
		end,
	},{
		condName = "Level",
		eventList = {"PLAYER_LEVEL_UP", "PLAYER_ENTERING_WORLD"},
		parseMain = dontParse,
		handler = function(cond, event, ...)
			local level = UnitLevel("player")
			for chunk in cond.mainValue:gmatch('([%d%p^,]+)') do
				if tonumber(chunk) then -- '68'
					if level == tonumber(chunk) then return true end
				elseif chunk:match('%+') then -- '40+'
					if level >= tonumber(chunk:match('%d+')) then return true end
				elseif chunk:match('%-$') then -- '30-'
					if level <= tonumber(chunk:match('%d+')) then return true end
				elseif chunk:match('%d+%-%d+') then -- '20-47'
					local low, high = tonumber(chunk:match('(%d+)%-(%d+)'))
					if level >= low and level <= high then return true end
				end
			end
		end,
	},{
		condName = "Class",
		eventList = {"PLAYER_LOGIN"},
		parseMain = dontParse,
		handler = function(cond, event, ...)
			local _, classKey = UnitClass('player')
			for class in cond.mainValue:gmatch("[^ ,]+") do
				if  class:upper() == classKey  then
					return true
				end
			end
		end,
	},


	{
		-- For Keybinding manager addons
		condName = "BindingsLoaded",
		eventList = {"VARIABLES_LOADED"},
	},{
		-- For AdvancedInterfaceOptions?
		condName = "CVarsLoaded",
		eventList = {"VARIABLES_LOADED"},
	},{
		-- Spell info loaded
		condName = "SpellsLoaded",
		eventList = {"SPELLS_CHANGED"},
	},

	-- For the generic delayed load sometime after login. Will wait until the fps is above a certain level (eg. 1/4 max fps), but at most 10 sec, or so.
	-- A lua field can be provided like with all fields in the form (eg. to load on Saturday):  X-LoadOn-Login-If:  date('*t').wday == 7
	{
		condName = "Login",
		eventList = {"PLAYER_LOGIN"},
		parseMain = function(cond)
			-- TODO: 'Synchronous'  'Instant'  'UserInterface'  'Quick'  'Queued'  'Broker'  'LowPrio'  "N sec"  "N min"
			cond.loadTiming = cond.mainValue
			-- Handled by AddonLoader.QueueLoadAddOn(addonName, loadCondition)
		end,
	},

	-- Deprecated. Use X-LoadOn-Login without "delayed" (delayed is the default).
	-- If your addon relies on synchronous loading in the event handler,
	-- as opposed to async (delayed) loading a few frames later then set  X-LoadOn-Login-Delay: synchronous
	{
		condName = "Always",
		eventList = {"PLAYER_LOGIN"},
		loadChildren = function(cond)
			if  ConditionManager:GetMergedField(cond.addonName, "X-LoadOn-Login")  then
				-- X-LoadOn-Login overwrites X-LoadOn-Always.
				-- The field in the metadata is kept for backward compatibility with older AddonLoader.
				ConditionManager:RemoveField(cond.addonName, "X-LoadOn-Always")
				return false
			end
			
			local delayed =  (cond.mainValue or ""):sub(1,7):lower() == "delayed"
			if  not delayed  then  cond.delayPriority = 'quick'  end
		end,
	},


	{
		condName = "Addon",
		eventList = {"ADDON_LOADED"},
		loadChildren = ConditionManager.LoadChildren,
		handler = function(cond, event, ...)
			local loadedAddon = ...
			-- If the loaded addon is in addonList then return a truthy value (the index in the list)
			local addonList = cond.childList
			if  tindexof(addonList, loadedAddon)  then
				return  cond.childConds[loadedAddon]  or  cond
			end
		end,
	},{
		condName = "Events",
		loadChildren = ConditionManager.LoadChildren,
		registerChildHook = function(cond, eventName)
			ConditionManager.EventHooks:AddConditionHook(nil, eventName, cond)
		end,
	},

	{
		condName = "FrameShown",
		loadChildren = ConditionManager.LoadChildren,
		registerChildHook = function(cond, frameName)
			ConditionManager.FrameHooks:AddConditionHook(frameName, 'OnShow', cond)
		end,
	},{
		condName = "Click",
		loadChildren = ConditionManager.LoadChildren,
		registerChildHook = function(cond, frameName)
			ConditionManager.FrameHooks:AddConditionHook(frameName, 'OnClick', cond)
		end,
	},

	{
		condName = "Scripts",
		loadChildren = ConditionManager.LoadChildren,
		registerChildHook = function(cond, frameScriptName)
			local frameName, scriptName = strsplitObjectKey(frameScriptName)
			ConditionManager.FrameHooks:AddConditionHook(frameName, scriptName, cond)
		end,
	},{
		condName = "Hooks",
		loadChildren = ConditionManager.LoadChildren,
		registerChildHook = function(cond, objectFuncName)
			local objectName, hookedFuncName = strsplitObjectKey(objectFuncName)
			ConditionManager.SecureHooks:AddConditionHook(objectName, hookedFuncName, cond)
		end,
	},


	{
		condName = "Slash",
		loadChildren = ConditionManager.LoadChildren,
		registerChildHook = function(cond, slash)
			local addonName = cond.addonName
			--local name_upper = addonName:upper():gsub('[^%w]','')
			local Slashes = ConditionManager.Slashes[addonName]
			-- AutoCreateInnerTables metatable creates it first-time
			local SlashCmdList = _G.SlashCmdList
			
			local command
			if slash:sub(1,1) ~= '/' then
				command, slash = slash, '/'..slash
			else
				command, slash = slash:sub(1,2), slash
			end
			
			local commandLong = addonName.."_Loader_"..command
			--commandLong = commandLong:upper()
			_G['SLASH_'..commandLong..'1'] = slash
			Slashes[commandLong] = slash
			SlashCmdList[commandLong] = function(...)  SlashCmdHandler(cond, slash, ...)  end
		end,
	},{
		condName = "LDB-Launcher",
		parseMain = function(cond)
			local icon, rest = strsplit(private.SPLIT_CHARS, cond.mainValue, 2)
			rest = rest  and  rest:trim()
			-- the second part can be a string  or  an object definining any property
			local dataobj, name = parseLuaObject(rest), nil
			if  not dataobj  then
				name, rest = rest  and  strsplit(private.SPLIT_CHARS, rest, 2)
				rest = rest  and  rest:trim()
				dataobj = parseLuaObject(rest)  or  {}
			end
			dataobj.icon = icon
			dataobj.type = dataobj.type  or  'launcher'
			dataobj.tocname = dataobj.tocname  or  cond.addonName
			cond.dataobj = dataobj
		end,
		
		--handler = function(cond)
		registerHook = function(cond)
			local dataobj = cond.mainValue
			if  not dataobj  then  return  end
			
			dataobj.OnTooltipShow = dataobj.OnTooltipShow  or  function(tt)
				tt:AddLine(cond.dataobjName)
				tt:AddLine(AddonLoader.L.clicktoload, 0.2, 1, 0.2, 1)
			end
			function dataobj.OnClick(...)
				-- Delete the mock DataObject.
				DeleteDataObject(dataobj)
				-- Save parameters to call addon's OnClick
				cond.dataobjOnClickParams = { ... }
				AddonLoader.QueueLoadAddOn(cond.addonName, cond)
			end
			
			cond.dataobjName =  name  or  dataobj.name  or  cond.addonName
			cond.dataobjOnClick = dataobj.OnClick
			cond.afterLoadFunc = function(cond)
				local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):GetDataObjectByName(cond.dataobjName)
				if  not dataobj  then  return  end
				if  dataobj.OnClick == cond.dataobjOnClick  then  return  end
				dataobj.OnClick( unpack(cond.dataobjOnClickParams or {}) )
			end
		
			LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(cond.dataobjName, dataobj)
		end,
	},


	{
		condName = "InterfaceOptions",
		-- Adds a category for the addon to InterfaceOptionsPanel when it is opened.
		-- Opening the category will load the addon which can replace the category with a populated options panel.
		--frameList = { InterfaceOptionsPanel },
		registerHook = function(cond)
			ConditionManager.FrameHooks:AddConditionHook('InterfaceOptionsPanel', 'OnShow', cond)
		end,
		
		-- Runs when InterfaceOptionsPanel is first opened
		handler = function(cond, event, ...)
			-- Added category already?
			if  cond.optionsFrame  then  return nil  end
			-- Create frame for InterfaceOptionsPanel category
			local frame = CreateFrame('Frame', nil, UIParent)
			cond.optionsFrame = frame
			frame.name = cond.mainValue
			frame.addonName = cond.addonName
			frame.loadCondition = cond
			frame:Hide()
			frame:SetScript('OnShow', InterfaceOptions_OnShow)
			InterfaceOptions_AddCategory(frame)
			-- we do not return true here, the InterfaceOptions_OnShow function will actually load the addon
			return nil
		end,
	},

	{
		-- Runs on StartHandlers, the parsed beforeLoadFunc is implicitly executed.
		condName = "Execute",
		loadChildren = function(cond)
			-- Concat 5 metadata fields for longer possible code
			local addonName = cond.addonName
			local childFields
			for i = 2, 5 do
				local childField = ConditionManager:GetMergedField(addonName, cond.fieldName..i)
				if  not childField  then  break  end
				--childField.parent = cond
				childFields = childFields or {}
				childFields[#childFields+1] = childField
				cond.mainValue = cond.mainValue..'\n'..childField.fieldValue
			end
			cond.childFields = childFields
			cond.beforeLoadFunc =  ConditionManager:ParseLoadOnFunc(cond)
		end,
	},
}
