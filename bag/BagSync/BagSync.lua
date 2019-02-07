--[[
	BagSync.lua
		A item tracking addon similar to Bagnon_Forever (special thanks to Tuller).
		Works with practically any Bag mod available, Bagnon not required.

	NOTE: Parts of this mod were inspired by code from Bagnon_Forever by Tuller.
	
	This project was originally done a long time ago when I used the default blizzard bags.  I wanted something like what
	was available in Bagnon for tracking items, but I didn't want to use Bagnon.  So I decided to code one that works with
	pretty much any inventory addon.
	
	It was intended to be a beta addon as I never really uploaded it to a interface website.  Instead I used the
	SVN of wowace to work on it.  The last revision done on the old BagSync was r50203.11 (29 Sep 2007).
	Note: This addon has been completely rewritten. 

	Author: Xruptor

--]]

--[[ To enable debug logging:
/run BagSync.Debug(true)
--]]


-- Addon private namespace
local _G, ADDON_NAME, _ADDON = _G, ...
-- local _G, _ADDON = LibEnv.UseAddonEnv(...)
local GetTime = GetTime

-- Seconds to wait before initial scan.
BagSync.LOGIN_SCAN_DELAY_SEC = 5
-- Throttling:  seconds between container scans.
BagSync.MIN_SCAN_INTERVAL = 1



-- Event handler frame
local BagSync = CreateFrame("Frame", "BagSync", UIParent)
BagSync:Hide()
LibStub("AceTimer-3.0"):Embed(BagSync)

_G.BagSync = BagSync
--_G[ADDON_NAME] = BagSync



-- Debug(...) messages
function _ADDON.Debug(...)  if  BagSync.logFrame  then  BagSync.logFrame:AddMessage( string.join(", ", tostringall(...)) )  end end
BagSync.logFrame = tekDebug  and  tekDebug:GetFrame("BagSync")
function BagSync.Debug(enable)  BagSync.logFrame =  enable  and  (tekDebug  and  tekDebug:GetFrame("BagSync")  or  DEFAULT_CHAT_FRAME)  end
local Debug =  _ADDON.Debug

local LogMsgs = {}
local function log(msg) LogMsgs[#LogMsgs+1] = msg  end
function BsPrintLog()  for  i, msg  in ipairs(LogMsgs) do  _G.print(msg)  end  end
--[[
/run BsPrintLog()
--]]



-- Event routing to methods named like the event
BagSync:SetScript('OnEvent', function(self, event, p1, ...)
	--log("[".. date('%H:%M:%S') .."] "..tostring(event).."("..tostring(p1)..")")
	if  self[event]  then  self[event](self, event, p1, ...)  end
end)


-- Bulk event registration
function BagSync:SetRegisterEvents(enable, list)
	local RegOrUnregEvent = enable  and  self.RegisterEvent  or  self.UnregisterEvent
	for  i, event  in ipairs(list) do
		RegOrUnregEvent(self, event)
	end
end



------------------------------
--    LOGIN HANDLER         --
------------------------------

--[[
https://wow.gamepedia.com/AddOn_loading_process
--
PLAYER_LOGIN
This event fires immediately before PLAYER_ENTERING_WORLD.
Most information about the game world should now be available to the UI.
All sizing and positioning of frames is supposed to be completed before this event fires.
Addons that want to do one-time initialization procedures once the player has "entered the world" should use this event instead of PLAYER_ENTERING_WORLD.
PLAYER_ENTERING_WORLD
This event fires immediately after PLAYER_LOGIN
Most information about the game world should now be available to the UI. If this is an interface reload rather than a fresh log in, talent information should also be available.
All sizing and positioning of frames is supposed to be completed before this event fires.
This event also fires whenever the player enters/leaves an instance and generally whenever the player sees a loading screen
VARIABLES_LOADED
Since Patch 3.0.2, VARIABLES_LOADED has not been a reliable part of the addon loading process. It is now fired only in response to CVars, Keybindings and other associated "Blizzard" variables being loaded, and may therefore be delayed until after PLAYER_ENTERING_WORLD. The event may still be useful to override positioning data stored in layout-cache.txt.
PLAYER_ALIVE
Somewhere around Patch 5.4.0, PLAYER_ALIVE stopped being fired on login. It now only fires when a player is resurrected (before releasing spirit) or when a player releases spirit. Previously, PLAYER_ALIVE was used to by addons to signal that quest and talent information were available because it was the last event to fire (fired after PLAYER_ENTERING_WORLD), but this is no longer accurate.
--]]

BagSync:RegisterEvent('ADDON_LOADED')    -- SavedVariables loaded
BagSync:RegisterEvent('PLAYER_ENTERING_WORLD')    -- After PLAYER_LOGIN
Debug("[".. date('%H:%M:%S') .."] BagSync:RegisterEvent('ADDON_LOADED')")


-- ADDON_LOADED event sent for all addons after their SavedVariables has been loaded
function BagSync:ADDON_LOADED(event, addonName)
	if  addonName == ADDON_NAME  then
		self:UnregisterEvent('ADDON_LOADED')
		self.ADDON_LOADED = nil
		Debug("[".. date('%H:%M:%S') .."] BagSync:ADDON_LOADED("..addonName..")")
		-- SavedVariables loaded: check and reference it
		_ADDON.InitSavedDB()
		self:SetRegisterEvents(true, _ADDON.EventsToScan)
		
		local BagSyncOpt = _G.BagSyncOpt
		BagSyncOpt.minimap = BagSyncOpt.minimap or {}
		local LibDBIcon = _G.LibStub('LibDBIcon-1.0')
		LibDBIcon:Register(ADDON_NAME, self.dataobj, BagSyncOpt.minimap)
		
		if  IsLoggedIn()  and  self.PLAYER_ENTERING_WORLD  then
			-- This is not happening in normal addon loading. IsLoggedIn() becomes true after all addons and SavedVariables are loaded.
			-- Maybe can happen in delayed loading. In that case PLAYER_LOGIN and PLAYER_ENTERING_WORLD events were already fired earlier.
			-- Call our event handler to make up for the missed event.
			self:PLAYER_ENTERING_WORLD()
		end
	end
end


--[[
Waiting for PLAYER_ENTERING_WORLD event sent _after_ PLAYER_LOGIN to delay initial scan.
Hopefully the loading screen is over by now and the player gains control earlier by delaying the scan.
This event might be called multiple times.
--function BagSync:PLAYER_LOGIN()
--]]
function BagSync:PLAYER_ENTERING_WORLD()
	Debug("[".. date('%H:%M:%S') .."] BagSync:PLAYER_ENTERING_WORLD()")
	
	BagSync:CheckTmoggableSlotIDs()
	
	-- If we missed the ADDON_LOADED event then do it now
	if  self.ADDON_LOADED  then  _ADDON.InitSavedDB()  end

	self:ScheduleTimer( self.AfterLoginScan, self.LOGIN_SCAN_DELAY_SEC )
	self.LOGIN_SCAN_DELAY_SEC = nil
	
	-- Unregister event and release memory
	self:UnregisterEvent('PLAYER_ENTERING_WORLD')
	self.PLAYER_ENTERING_WORLD = nil
end


local taskQueue  = {}
local taskLocks  = {}
local taskTimers = {}

function BagSync:OnUpdate(elapsed)
	-- Survives #self.taskQueue == 0, which can happen if the only scheduled taskFunc is removed while self:IsShown().
	local taskFunc = next(taskQueue)
	if  not taskFunc  then  return self:Hide()  end
	
	-- Remove taskFunc from list. If it causes error, won't be called over and over again.
	taskQueue[taskFunc] = nil
	taskLocks[taskFunc] = GetTime()
	
	local callAgain = taskFunc  and  taskFunc(self)
	if  callAgain  then  taskQueue[taskFunc] = taskFunc  end
	
end


--[[
local function  tremovebyvalRev(t, item)
	for  i = #t,1,-1  do
		if  t[i] == item  then  table.remove(t, i)  return i  end
	end
end
--]]

function BagSync:Schedule(taskFunc, minInterval)
	if  taskQueue[taskFunc]  then  return false  end
	
	minInterval = minInterval or self.MIN_SCAN_INTERVAL
	local now, lastRun, timerId = GetTime(), taskLocks[taskFunc] or 0, taskTimers[taskFunc]
	
	-- Delaying taskFunc until the lock expires. How much is left?
	local lockLeft = lastRun + minInterval - now
	if  lockLeft <= 0  then
		if  timerId  then  self:CancelTimer(timerId) ; taskTimers[taskFunc] = nil  end
		taskQueue[taskFunc] = taskFunc
		return false
	end
	
	if  not timerId  or  not AceTimer.activeTimers[bucket.timer]  then
		taskTimers[taskFunc] = self:ScheduleTimer('Schedule', lockLeft, taskFunc, 0)
	end
	return true
end





--------------------------
-- Item link shortening --
--------------------------

--[=[
https://wow.gamepedia.com/ItemLink
--local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
ItemRef.lua:
if ( strsub(link, 1, 9) == "battlepet" ) then
	local linkType, speciesID, level, breedQuality, maxHealth, power, speed, battlePetID = strsplit(":", link);
end
XLoot test:
|cff0070dd|Hbattlepet:868:1:3:158:10:12:0x0000000000000000|h[Pandaren Water Spirit]|h|r
--]=]

local COUNT_SEP = '*'
local COUNT_SEP_LIST = ",*"
--local COUNT_SEP = '×'  -- because of UTF-8 encoding Multiplication Sign (×) (0xd7) would not work as it is encoded into 2 bytes,
-- supplying 2 unrelated characters to strsplit which works with raw bytes, unaware of UTF-8 encoding
--local COUNT_SEP = ','  -- was comma originally

-- METADATA_SEP could be: ~&%#$^|/,.:;<=>
-- Tilde is chosen for readability, visual separation of loosely coupled information.
-- | would be good visually, but confusing as the escape character for wow links, textures, friend names...
local MD_SEP, METADATA_SEP = '~','~'
-- Colon separates metadata fields just like in Blizz links
local MF_SEP, METAFIELD_SEP = ':',':'
-- Equal sign separates metadata field name and value
local MF_EQ, METAFIELD_EQUAL = '=','='

-- Each metadata consists of fields. First field is the typeID.
local MD_TYPE_STATS = 'Stats'
local MD_TYPE_TMOG = 'Tmog'
-- Following fields are formatted  <fieldName>=<value>  or  plain <value>

--[[ What comes after the | escape character: (METADATA_SEP follows the pattern of | separator)
|H<linkRef>|h<linkText>|h
|T<texturePath>|t  -> icon in text.  Full format:  |T<texturePath>:size1:size2:xoffset:yoffset(:dimx:dimy:coordx1:coordx2:coordy1:coordy2)|t
|K[gsf][0-9]+|k[0]+|k -> battle.net friend name	
|n -> newline
|| -> escaped |
--]]


function BagSync.ToEquipData(link, tmogItemID)
	if  not link  then  return nil  end
	local _,_,itemRarity,ilvl = GetItemInfo(link)
	--effectiveIlvl, isPreview, baseIlvl = GetDetailedItemLevelInfo(link)
	--local ilvl=  effectiveIlvl  or  baseIlvl
	
	local itemData = link:match("item:([^\124]+\124h[^\124]*)")
	itemData =  itemData  or  link:match("item:([^\124]+")
	if  not itemData  then
		reportDataError("BagSync.ToEquipData(): Unrecognized link: '"..link.."'")
		return false
	end
	
	if  ilvl  then  itemData = itemData..MD_SEP..MD_TYPE_STATS..MF_SEP.."ilvl"..MF_EQ..ilvl  end
	if  tmogItemID  then
		itemData = itemData..MD_SEP..MD_TYPE_TMOG..MF_SEP..tmogItemID
		local tmogItemName = GetItemInfo(tmogItemID)
		if  tmogItemName  then  itemData = itemData..MF_SEP..tmogItemName  end
	end
	return itemData
end


function BagSync.ToItemData(link, count, metaDataType, metaData)
	if  not link  then  return nil  end
	assert(type(link) == 'string', "link must be a string")
	assert(count == nil  or  type(count) == 'number', "count must be a number or nil")
	assert(metaDataType == nil  and  metaData == nil  or  type(metaDataType) == 'string', "metaDataType must be a string")
	--count = count or 1
	
	--local itemData = link:match("item:(%d+):")  or  link
	--local itemData = link:match("item:(%w+):")  or  link
	--local itemData = link:match("item:(.-):")  or  link
	--local itemData, rest = link:match("item:([^\124:]+)(.*)")  or  link
	--local itemID, enchantID, gemID1, gemID2, gemID3, gemID4, suffixID, uniqueID, linkLevel = link:match("item:([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)")

	-- If not enchanted or gemmed than shorten the link.
	-- Should determine if it's soulbound, but that needs a tooltip hack, which has no place here.
	local itemData = link:match("item:([^\124:]+):0:0:0:0:0:")
	--itemData =  itemData  or  link:match("item:([^\124:]+)::::::")  -- As of 7.0.3 unused delimited segments will be empty rather than 0 (the old ":0:0:0:" is now "::::").
	
	-- Store item linkRef without name
	itemData =  itemData  or  link:match("item:[^\124]*")
	-- Store battlepet with name, strip link escape at ends, shorten battlepet: -> pet:
	local petData =  not itemData  and  link:match("battle(pet:[^\124]+\124h[^\124]*)\124h")
	petData =  petData  and  petData:gsub(":0x0000000000000000\124","\124")
	itemData =  itemData  or  petData
	--itemData =  itemData  or  link:match("battle(pet:[^\124]+\124h[^\124]*)\124h")
	-- Unknown links (not item: or battlepet:) store all information, including the name. Link escape at ends is stripped.
	itemData =  itemData  or  link:match("\124H([^\124]+\124h[^\124]*)\124h")
	-- If it's not a full link then see if it quacks like the reference part of a link
	itemData =  itemData  or  link:match("^[^\124:]+:[^\124]+$")
	if  not itemData  then
		reportDataError("BagSync.ToItemData(): Unrecognized link: '"..link.."'")
		return false
	end
	
	if  count  and  count ~= 1  then  itemData = itemData..COUNT_SEP..tostring(count)  end
	if  metaData  then  itemData = itemData..METADATA_SEP..metaDataType..tostring(metaData)  end
	return itemData
end


function BagSync.ToItemData2(link, count, metaDataType, metaData)
	if  not link  then  return nil  end
	assert(type(link) == 'string', "link must be string")
	assert(count == nil  or  type(count) == 'number', "count must be a number or nil")
	assert(metaDataType == nil  and  metaData == nil  or  (type(metaDataType) == 'string'  and  1 == #metaDataType), "metaDataType must be one character")
	--count = count or 1
	
	--local itemData = link:match("item:(%d+):")  or  link
	--local itemData = link:match("item:(%w+):")  or  link
	--local itemData = link:match("item:(.-):")  or  link
	--local itemData, rest = link:match("item:([^:]+)(.*)")  or  link
	local itemData, rest = link:match("item:([^\124:]+)")
		or  link:match("battle(pet:[^\124]+\124h[^\124]*)\124h")
		or  link:match("\124H([^\124]+\124h[^\124]*)\124h")
		or  link:match("^[^\124:]+:[^\124]+$")
	
	-- Store name of battlepets (rest is parsed only from battlepet: links)
	local name =  rest  and  rest:match("(\124h%[[^%]]*%])")
	-- Unknown links (not item: or battlepet:) store all information, including the name. Link escape at ends is stripped.
	
	if  name  then  itemData = itemData..name  end
	if  count  and  count ~= 1  then  itemData = itemData..COUNT_SEP..tostring(count)  end
	if  metaData  then  itemData = itemData..METADATA_SEP..metaDataType..tostring(metaData)  end
	return itemData
end


function BagSync.ToSearchData(link)
	if  not link  then  return nil  end
	assert(type(link) == 'string', "link must be string")

	-- From item links take out only itemID
	local itemData = link:match("item:([^\124:]+)")
	-- Shorten battlepet: -> pet:
	itemData =  itemData  or  link:match("battle(pet:[^\124:]+)")
	-- Unknown links (not item: or battlepet:) store all information, including the name. Link escape at ends is stripped.
	itemData =  itemData  or  link:match("\124H([^\124:]+:[^\124:]*)")
	-- If it's not a full link then see if it quacks like the reference part of a link
	itemData =  itemData  or  link:match("^([^\124:]+:[^\124:]*)[^\124]*$")
	if  not itemData  then
		reportDataError("BagSync.ToSearchData(): Unrecognized link: '"..link.."'")
		return false
	end
	
	return itemData
end




--[[ Returns type, ID, count, restoredLink (or nil), metaPart containing (metaType..metaData)*
local linkType, ID, count, link = ParseItemData(itemData)
--]]
function BagSync.ParseItemData(itemData)
	local metaPart, sepIdx = nil, itemData:find(METADATA_SEP)
	if  sepIdx  then
		-- Split off:  (METADATA_SEP..metaDataType..metaData)*
		metaPart =  metaSep  and  itemData:sub(sepIdx)
		itemData = itemData:sub(1, sepIdx - 1)
	end

	-- If it starts with a number then it's an item ID or linkRef with count, the most frequent case:  <itemID>(*<count>(~<metaData>))  or  <itemID>(,<count>(,<auctionData>))
	local itemLink = tonumber(itemData[0])
	local maxSep =  itemLink  and  3  or  2
	local COUNT_SEP =  itemLink  and  COUNT_SEP_LIST  or  COUNT_SEP
	
	local linkPart, countstr, auctionstr, checkNil = strsplit(COUNT_SEP, itemData)
	-- If there is an extra Comma or Asterisk (*) then it splits to more than 3 parts (if itemLink)
	-- If there is an extra Asterisk (*) then it splits to more than 2 parts (not itemLink)
	if  not itemLink  then  checkNil = auctionstr  end
	if  checkNil ~= nil  then  reportDataError("BagSync.ParseItemData(): Malformed item data has > "..maxSep.." separators from '"..COUNT_SEP.."', itemData='"..itemData.."'.")  end
	
	local linkType, IDstr, link, enchantID
	if  itemLink  then
		linkType = 'item'
		IDstr, enchantID = strsplit(':', linkPart)
		link = "|Hitem:"..linkPart.."|h"
		-- The link was not stripped-shortened if it has enchantID, so it can be reconstructed and returned.
		--if  not enchantID  then  link = IDstr  end
		--if  not enchantID  then  link = linkType..':'..IDstr  end
		metaPart = auctionstr or metaPart
	else
		-- Any other link type is only shortened
		if  linkPart:sub(1,4) == 'pet:'  then  linkPart = 'battle'..linkPart  end
		linkType, IDstr = strsplit(':', linkPart)
		link = "|H"..linkPart.."|h"
	end
	
	local ID = tonumber(IDstr)  or  IDstr
	local count = tonumber(countstr)
	if  countstr  and  not count  then
		reportDataError("BagSync.ParseCount(): Malformed item data has non-numeric count value '"..countstr.."', itemData='"..itemData.."'.")
		-- BagSync.MatchItemData() returns nil if it can't parse countstr
		count = countstr
	end
	return linkType, ID, count, link, metaPart
end



-- Returns count 
-- Returns false if ID is not matching
-- Returns nil if count cannot be parsed
function BagSync.MatchItemData(itemData, searchData)
	local searchDataLen = searchData:len()
	if  searchData ~= itemData:sub(1, searchDataLen)  then  return false  end
	
	-- 50% of BagSync.ParseItemData() copied here
	local itemLink = tonumber(itemData[1])
	local COUNT_SEP =  itemLink  and  COUNT_SEP_LIST  or  COUNT_SEP

	local itemPart, metaPart = strsplit(METADATA_SEP, itemData, 2)
	local linkPart, countstr, auctionstr, checkNil = strsplit(COUNT_SEP, itemPart)

	local count = not countstr  and  1  or  tonumber(countstr)
	if  countstr  and  not count  then
		reportDataError("BagSync.MatchItemData(): Malformed item data has non-numeric count value '"..countstr.."', itemData='"..itemData.."'.")
		-- BagSync.ParseItemData() returns the string if it can't parse countstr
		return nil
	end
	return  count
end




