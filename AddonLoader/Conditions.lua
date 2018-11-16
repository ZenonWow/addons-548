local ADDON_NAME, private = ...
local _G = _G
local AddonLoader = AddonLoader
local safecall = private.safecall


-- GLOBALS: INTERFACEOPTIONS_ADDONCATEGORIES InterfaceOptionsFrame_OpenToCategory InterfaceOptions_AddCategory
-- GLOBALS: IsInInstance InCombatLockdown GetNumRaidMembers GetNumPartyMembers
-- GLOBALS: GetRealmName IsInGuild UnitIsPVP UnitClass IsResting UnitLevel
-- GLOBALS: GetAddOnDependencies
-- GLOBALS: CreateFrame hooksecurefunc geterrorhandler LibStub UIParent setfenv
-- GLOBALS: IsAddOnLoaded

local tonumber, string, type, next, select, ipairs, tremove, tostring, pcall, loadstring = 
      tonumber, string, type, next, select, ipairs, tremove, tostring, pcall, loadstring

local function dontParse()  return false  end

local function formatError(errorMessage, addonName, condName, handler)
	return ("In "..addonName..".toc / ## "..condName..": "..handler.. "\n\n" .. errorMessage)
end




-- There should be a cleaner way to handle this
local hookenv = setmetatable({}, {__index = getfenv(0)})
function hookenv.LoadAddOn(addonName)
	return AddonLoader:LoadAddOn(addonName)
end

local function LoadWithMetadataFunc(condition, event, ...)
	-- Evaluate the metadata provided code
	local ran, result =  condition.metadataFunc  and  safecall(condition.metadataFunc, ...)
	-- If it ran and returned false then stop.
	if  ran  and  result == false  then  return false  end
	
	-- If the metadata code returned a function then call it AFTER the addon was loaded.
	--local afterLoadFunc =  ran  and  type(result) == 'function'  and  result  or  condition.afterLoadFunc
	
	-- Load the addon
	return  result  or  true
	--[[
	local loaded = AddonLoader:LoadAddOn(condition.addonName)
	
	-- If the metadata code returned a function then call it AFTER the addon was loaded.
	if  loaded  and  afterLoadFunc  then  safecall(postLoadFunc)  end
	--]]
end


local function AddCondition(eventsTable, addonName, frameName, eventName, condName, metadataFunc)
	if  metadataFunc  then  setfenv(metadataFunc, hookenv)  end
	
	local eventObj = eventsTable:GetEventObj(frameName, eventName)
	local conditions = eventObj[addonName] or {}
	eventObj[addonName] = conditions
	conditions[condName] = {
		handler = LoadWithMetadataFunc,
		metadataFunc = metadataFunc,
	}
end

local function RegisterEventHook(addonName, eventName, condName, metadataFunc)
	return AddCondition(ConditionManager.EventHooks, addonName, nil, eventName, condName, metadataFunc)
end

local function RegisterFrameHook(addonName, frameName, scriptName, condName, metadataFunc)
	return AddCondition(ConditionManager.scriptHooks, addonName, frameName, scriptName, condName, metadataFunc)
end

local function RegisterSecureHook(addonName, objectName, hookedFuncName, condName, metadataFunc)
	return AddCondition(ConditionManager.secureHooks, addonName, objectName, hookedFuncName, condName, metadataFunc)
end




function AddonLoader:ReadChildConditions(addonName, condName, condValue)
	-- special handling for condName == "X-LoadOn-Events" or condName == "X-LoadOn-Hooks"
	for event in condValue:gmatch("[^ ,]+") do
		local childCondValue = GetAddOnMetadata(addonName, "X-LoadOn-"..event)
		if childCondValue then
			self.conditiontexts[addonName] = self.conditiontexts[addonName].."X-LoadOn-"..event..": "..childCondValue.."\n"
		end
	end
end


function AddonLoader:GetConditionValue(addonName, conditionName)
	local conditiontext = self.conditiontexts[addonName]
	for  _, line  in ipairs({strsplit("\n", conditiontext)}) do
		--local condName, condValue = string.match(line, "^([^:]*):? ?(.*)$")
		-- conditionName has no special/escape characters
		local condName, condValue = string.match(line, "^("..conditionName.."):? ?(.*)$")
		if  condValue  and  condName == conditionName  then
			return condValue
		end
	end
	return nil
end

function AddonLoader:GetConditionValue2(addonName, conditionName)
	local conditiontext = self.conditiontexts[addonName]
	for line in conditiontext:gmatch("[^\n]+") do
		local condName, condValue = string.match(line, "^([^:]*):? ?(.*)$")
		if  condValue  and  condName == conditionName  then
			return condValue
		end
	end
	return nil
end


function AddonLoader:GetConditionFunc(addonName, condName)
	local condValue = self:GetConditionValue(addonName, condName)
	return self.ParseConditionFunc(nil, addonName, condName, condValue)
end


function AddonLoader.ParseConditionFunc(condition, addonName, condName, condValue)
	if  not condValue  then  return nil  end
	--local ran, result = pcall(loadstring, condValue)
	local ran, result = safecall(loadstring, condValue)
	if  ran  then  return result  end
	
	geterrorhandler()( formatError(result, addonName, condName, condValue) )
	return nil
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
		-- load addon
		AddonLoader:LoadAddOn(self.addonName)
		-- refresh optionsframe
		InterfaceOptionsFrame_OpenToCategory(self.name)
		InterfaceOptionsFrame_OpenToCategory(self.name)
	end
end


local function SlashCmdHandler(addonName, commandLong, argument)
	local slash = _G['SLASH_'..commandLong]
	local msg = slash..' '..argument
	AddonLoader:LoadAddOn(addonName)
	_G.ChatFrame_OpenChat(msg)
	--[[
	local editbox = _G.ChatFrameEditBox
		or  _G.ChatEdit_GetActiveWindow()  -- Support for 3.3.5 and newer
	assert(editbox, "Failed to open chat message box to run the loaded addon's command.")
	editbox:SetText(msg)  -- ChatFrame_OpenChat(msg) did this already
	--]]
	_G.ChatEdit_SendText(editbox, 1)
end





AddonLoader.conditions = {
	["X-LoadOn-Bank"] = {
		events = {"BANKFRAME_OPENED"},
	},
	["X-LoadOn-Mailbox"] = {
		events = {"MAIL_SHOW"},
	},
	["X-LoadOn-Merchant"] = {
		events = {"MERCHANT_SHOW"},
	},
	["X-LoadOn-AuctionHouse"] = {
		events = {"AUCTION_HOUSE_SHOW"},
	},
	["X-LoadOn-Crafting"] = {
		events = {"TRADE_SKILL_SHOW", "CRAFT_SHOW"},
	},

	["X-LoadOn-Arena"] = {
		events = {"ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD"},
		handler = function() return select(2, IsInInstance()) == "arena" end,
	},
	["X-LoadOn-Battleground"] = {
		events = {"ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD"},
		handler = function() return select(2, IsInInstance()) == "pvp" end,
	},
	["X-LoadOn-Instance"] = {
		events = {"ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD"},
		handler = function()
			local instanceType = select(2, IsInInstance())
			return instanceType == "party" or instanceType == "raid"
		end,
	},
	["X-LoadOn-Combat"] = {
		events = {"PLAYER_REGEN_DISABLED", "PLAYER_ENTERING_WORLD"},
		handler = function()
			if event == "PLAYER_REGEN_DISABLED" then return true end
			if event == "PLAYER_ENTERING_WORLD" then return InCombatLockdown() end
		end,
	},

	["X-LoadOn-Resting"] = {
		events = {"PLAYER_UPDATE_RESTING", "PLAYER_ENTERING_WORLD"},
		handler = function() return IsResting() end,
	},
	["X-LoadOn-NotResting"] = {
		events = {"PLAYER_UPDATE_RESTING", "PLAYER_ENTERING_WORLD"},
		handler = function() return not IsResting() end,
	},

	["X-LoadOn-PvPFlagged"] = {
		events = {"UNIT_FACTION", "PLAYER_ENTERING_WORLD"},
		handler = function() return UnitIsPVP("player") end,
	},
	["X-LoadOn-Group"] = {
		events = {"GROUP_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD"},
		handler = function() return GetNumGroupMembers() > 0 or GetNumSubgroupMembers() > 0 end,
	},
	["X-LoadOn-Raid"] = {
		events = {"GROUP_ROSTER_UPDATE", "PLAYER_ENTERING_WORLD"},
		handler = function() return GetNumGroupMembers() > 0 and IsInRaid() end,
	},
	["X-LoadOn-Guild"] = {
		events = {"PLAYER_LOGIN", "GUILD_ROSTER_UPDATE", "GUILD_XP_UPDATE"},
		handler = function() return IsInGuild() end,
	},

	["X-LoadOn-Realm"] = {
		events = {"PLAYER_LOGIN"},
		parser = dontParse,
		handler = function(cond, event, ...)  return GetRealmName() == cond.condValue  end,
	}, 
	["X-LoadOn-Zone"] = {
		events = {"ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "MINIMAP_ZONE_CHANGED"},
		parser = dontParse,
		handler = function(cond, event, ...)
			local BZ = LibStub and LibStub("LibBabble-Zone-3.0", true) -- silent check for BZ
			local subzone = string.trim(GetSubZoneText()) -- yeah really...
			local realzone = GetRealZoneText()
			for zone in cond.condValue:gmatch('(%w[^,]+%w)') do
				if (BZ and BZ[zone] and (realzone == BZ[zone] or subzone == BZ[zone])) or 
					realzone == zone or subzone == zone then
					return true
				end
			end
		end,
	},
	["X-LoadOn-Level"] = {
		events = {"PLAYER_LEVEL_UP", "PLAYER_ENTERING_WORLD"},
		parser = dontParse,
		handler = function(cond, event, ...)
			local level = UnitLevel("player")
			for chunk in cond.condValue:gmatch('([%d%p^,]+)') do
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
	},
	["X-LoadOn-Class"] = {
		events = {"PLAYER_LOGIN"},
		parser = dontParse,
		handler = function(cond, event, ...)
			local _, classKey = UnitClass('player')
			for class in cond.condValue:gmatch("[^ ,]+") do
				if  class:upper() == classKey  then
					return true
				end
			end
		end,
	},

	["X-LoadOn-Always"] = {
		events = {"PLAYER_LOGIN"},
		parser = function (cond)
			cond.delayed =  (cond.condValue or ""):sub(1,7):lower() == "delayed"
			local extraParam = cond.delayed  and  cond.condValue:sub(8):trim()  or  cond.condValue
			return extraParam
		end,
		handler = function(cond, event, ...)
			if  not cond.delayed  then  return true  end
			AddonLoader:RegisterDelayedLoad(cond.addonName, cond)
		end,
	},

	["X-LoadOn-Slash"] = {
		parser = function (cond)
			--local name_upper = cond.addonName:upper():gsub('[^%w]','')
			local slashes = AddonLoader.slashes[cond.addonName] or {}
			AddonLoader.slashes[cond.addonName] = slashes
			local SlashCmdList = _G.SlashCmdList
			
			for slash in cond.condValue:gmatch('([^, ]+)') do
				local command = slash
				if slash:sub(1,1) ~= '/' then
					slash = '/'..slash
				else
					command = slash:sub(1,2)
				end
				
				local commandLong = cond.addonName:upper().."_LOADER_"..command:upper()
				_G['SLASH_'..commandLong..'1'] = slash
				slashes[commandLong] = slash
				SlashCmdList[commandLong] = function(...)  SlashCmdHandler(cond.addonName, commandLong, ...)  end
			end
			
			-- We specifically DO NOT return true here, this handler just sets up the other conditions. And will remain dorment for the remainder
			return nil
		end,
	},

	["X-LoadOn-LDB-Launcher"] = {
		parser = function (cond)
			local dataobj = ParseEvalTable(cond.condValue)
			if  not dataobj  then
				dataobj = {}
				dataobj.icon, dataobj.name = string.split(" ", condValue)
			end

			dataobj.type = dataobj.type  or  'launcher'
			dataobj.tocname = dataobj.tocname  or  cond.addonName
			dataobj.OnClick = dataobj.OnClick  or  function (...)
				AddonLoader.LoadAddOn(cond.addonName)
				if OnClick ~= dataobj.OnClick then dataobj.OnClick(...) end
			end
			dataobj.OnTooltipShow = dataobj.OnTooltipShow  or  function(tt)
				tt:AddLine(dataobj.name)
				tt:AddLine(AddonLoader.L.clicktoload, 0.2, 1, 0.2, 1)
			end
			
			dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(dataobj.name, dataobj)
			-- We specifically DO NOT return true here, this handler just sets up the other conditions. And will remain dorment for the remainder
			return nil
		end,
	},

	["X-LoadOn-InterfaceOptions"] = {
		-- frameList = { InterfaceOptionsPanel }
		-- Runs on startup
		handler = function(cond, event, ...)
			local frame = CreateFrame('Frame', nil, UIParent)
			frame.name = cond.condValue
			frame.addonName = cond.addonName
			frame:Hide()
			frame:SetScript('OnShow', InterfaceOptions_OnShow)
			InterfaceOptions_AddCategory(frame)
			-- we do not return true here, the InterfaceOptions_OnShow function will actually load the addon
		end,
	},

	["X-LoadOn-FrameShown"] = {
		parser = function (cond)
			for  frameName  in cond.condValue:gmatch("[^ ,]+") do
				local frame = _G[frameName]
				if  not frame  then
					geterrorhandler()( formatError("_G."..frameName.." does not exist", cond.addonName, "X-LoadOn-FrameShown", cond.condValue) )
				elseif  type(frame) ~= 'table'  then
					geterrorhandler()( formatError("_G."..frameName.." is not an object", cond.addonName, "X-LoadOn-FrameShown", cond.condValue) )
				elseif  not frame.HookScript  then
					geterrorhandler()( formatError("_G."..frameName.." is not a frame", cond.addonName, "X-LoadOn-FrameShown", cond.condValue) )
				else
					local childCond = "X-LoadOn-"..frameName
					local beforeLoadFunc = AddonLoader:GetConditionFunc(cond.addonName, childCond)
					RegisterFrameHook(cond.addonName, frameName, 'OnShow', childCond, beforeLoadFunc)
				end
			end
			return nil
		end,
	},

	["X-LoadOn-Events"] = {
		onload = function (cond)
			AddonLoader:ReadChildConditions(cond.addonName, cond.condName, cond.condValue)
		end,
		parser = function (cond)
			for  eventName  in cond.condValue:gmatch("[^ ,]+") do
				local childCond = "X-LoadOn-"..eventName
				local beforeLoadFunc = AddonLoader:GetConditionFunc(addonName, childCond)
				RegisterEventHook(cond.addonName, eventName, childCond, beforeLoadFunc)
			end
			-- We specifically DO NOT return true here, this handler just sets up the other conditions. And will remain dorment for the remainder
			return nil
		end,
	},

	["X-LoadOn-Hooks"] = {
		onload = function (cond)
			AddonLoader:ReadChildConditions(cond.addonName, cond.condName, cond.condValue)
		end,
		parser = function (cond)
			for  hookedFuncName  in cond.condValue:gmatch("[^ ,]+") do
				if  not _G[hookedFuncName]  then
					geterrorhandler()( formatError("_G."..hookedFuncName.." does not exist", addonName, cond.condName, cond.condValue) )
				elseif type(_G[hookedFuncName]) ~= "function" then
					geterrorhandler()( formatError("_G."..hookedFuncName.." is not a function", addonName, cond.condName, cond.condValue) )
				else
					local childCond = "X-LoadOn-"..hookedFuncName
					local beforeLoadFunc = AddonLoader:GetConditionFunc(cond.addonName, childCond)
					RegisterSecureHook(cond.addonName, nil, hookedFuncName, childCond, beforeLoadFunc)
				end
			end
			-- We specifically DO NOT return true here, this handler just sets up the other conditions. And will remain dorment for the remainder
			return nil
		end,
	},

	["X-LoadOn-Execute"] = {
		onload = function (cond)
			-- Load the extra metadata fields
			local conditiontext = AddonLoader.conditiontexts[cond.addonName]
			for i = 2, 5 do
				local continuedValue = GetAddOnMetadata(cond.addonName, cond.condName..i)
				if  not continuedValue  then  break  end
				conditiontext = conditiontext .. condName..i..": "..continuedValue.."\n"
			end
			AddonLoader.conditiontexts[addonName] = conditiontext
		end,
		
		parser = function (cond)
			-- Custom parser: concat 5 metadata fields for longer possible code
			local condBody = cond.condValue
			for i = 2, 5 do
				local continuedValue = AddonLoader:GetConditionValue(cond.addonName, cond.condName..i)
				if  not continuedValue  then  break  end
				condBody = condBody..'\n'..continuedValue
			end
			cond.condBody = condBody
			local ran, result = pcall(loadstring, cond.condBody)
			-- result holds the compiled function or the error message, depending on status
			if  not ran  then  geterrorhandler()( formatError(result, cond.addonName, cond.condName, condBody) )  end
			cond.beforeLoadFunc =  ran  and  result
			--return  ran  and  result
		end,
		
		-- Runs on startup because eventList == nil
		--[[ No need for handler, beforeLoadFunc is implicitly ran.
		handler = function(cond, event, ...)
			return  cond.beforeLoadFunc  and  safecall(cond.metadataFunc, ...)
		end,
		--]]
	},
}
