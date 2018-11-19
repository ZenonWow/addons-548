--[[
/run print( format("BagSync:AfterLoginScan() ran for %.3f seconds", BagSync.AfterLoginScanTime) )
/dump GetInventoryItemID('player', 68)
/dump GetInventoryItemLink('player', 68)
/run for bagID=1,11 do local invSlotID=ContainerIDToInventoryID(bagID); print(bagID..'. invSlotID='..tostring(invSlotID)..' item='..(GetInventoryItemID('player', invSlotID) or 'nil')..' '..(GetInventoryItemLink('player', invSlotID) or 'nil') ) end
/run for bagID=1,11 do local l=GetBagLink(bagID); if l then print(bagID..'. '..l..'  '..gsub(l,'|','||')) else print(bagID..'. <no bag>') end end
--]]


-- Addon private namespace
local ADDON_NAME, ns = ...
-- Addon global namespace
local BagSync = BagSync
-- Localization
local L = BAGSYNC_L
-- Imported from BagSync.lua
local Debug =  ns.Debug

local reportDataError = print
	

-----------------------------------------------------
-- Database variables initialized in InitSavedDB() --
-----------------------------------------------------
local BagSyncOpt      -- Cached from global namespace

-- These database variables are not cached, but rather references into the current realm's part
--local BagSyncDB
--local BagSyncTOKEN_DB
--local BagSyncCRAFT_DB
--local BagSyncGUILD_DB
--local BagSyncBLACKLIST_DB

-- Static references into the SavedVariables database for the current realm
local RealmCharDB      -- BagSyncDB[playerRealm]
local RealmTokenDB     -- BagSyncTOKEN_DB[playerRealm]
local RealmCraftDB     -- BagSyncCRAFT_DB[playerRealm]
local RealmGuildDB     -- BagSyncGUILD_DB[playerRealm]
local RealmBlacklistDB -- BagSyncBLACKLIST_DB[playerRealm]

-- Static references into the SavedVariables database for the current character
local PlayerDB         -- RealmCharDB[playerName]
local PlayerCraftDB    -- RealmCraftDB[playerName]


-------------------------------------------------
-- Basic player info is available when loading --
-------------------------------------------------
local playerName = UnitName('player')
local playerRealm = GetRealmName()
local playerClass = select(2, UnitClass('player'))
local playerFaction = UnitFactionGroup('player')


-- Blizzard constants from FrameXML\Constants.lua cached in local namespace
local INVSLOT_FIRST_EQUIPPED = INVSLOT_FIRST_EQUIPPED    -- 1
local INVSLOT_LAST_EQUIPPED = INVSLOT_LAST_EQUIPPED    -- 19
local ATTACHMENTS_MAX_RECEIVE = ATTACHMENTS_MAX_RECEIVE    -- 16  MailFrame.lua
local MAX_GUILDBANK_TABS = MAX_GUILDBANK_TABS    -- 8
local MAX_GUILDBANK_SLOTS_PER_TAB = 98    -- not defined in FrameXML
local HEARTHSTONE_ITEM_ID = HEARTHSTONE_ITEM_ID or 6948

-- State of scanning
local doTokenUpdate = 0
local guildTabQueryQueue = {}
local atBank = false
local atVoidBank = false
local atGuildBank = false
local isCheckingMail = false

-- Events monitored
ns.EventsToScan = {
	'BANKFRAME_OPENED',
	'BANKFRAME_CLOSED',
	'GUILDBANKFRAME_OPENED',
	'GUILDBANKFRAME_CLOSED',
	'GUILDBANKBAGSLOTS_CHANGED',
	'MAIL_SHOW',
	'MAIL_INBOX_UPDATE',
	'AUCTION_HOUSE_SHOW',
	'AUCTION_OWNED_LIST_UPDATE',
	
	--void storage
	'VOID_STORAGE_OPEN',
	'VOID_STORAGE_CLOSE',
	'VOID_STORAGE_UPDATE',
	'VOID_STORAGE_CONTENTS_UPDATE',
	'VOID_TRANSFER_DONE',
	
	--this will be used for getting the tradeskill link
	'TRADE_SKILL_SHOW',
}
ns.EventsToScanAfterInitial = {
	'PLAYER_MONEY',
	'CURRENCY_DISPLAY_UPDATE',
	'BAG_UPDATE',
	'UNIT_INVENTORY_CHANGED',
	'GUILD_ROSTER_UPDATE',
}




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


local ToEquipData = BagSync.ToEquipData
local ToItemData = BagSync.ToItemData
local ToSearchData = BagSync.ToSearchData
local ParseItemData = BagSync.ParseItemData
local MatchItemData = BagSync.MatchItemData





-------------------------
-- SavedVariables init --
-------------------------

local OptionDefaults = {
	enableMinimap = true,
	enableFaction = true,
	enableUnitClass = false,
	showTotal = true,
	enableMailbox = true,
	enableAuction = true,
	enableGuild = true,
	showGuildNames = false,
	tooltipOnlySearch = false,
	enableTooltips = true,
	enableTooltipSeperator = true,
}

--local function StartupDB()
function ns.InitSavedDB()
	print("[".. date('%H:%M:%S') .."] BagSync.InitSavedDB()")

  -- The local reference BagSyncOpt is different from the SavedVariable stored in the global namespace: _G.BagSyncOpt
	local dbversion = _G.BagSyncOpt  and  (tonumber(_G.BagSyncOpt.dbversion)  or  -1)
	if  dbversion  and  dbversion < 7  then
		--[[
		BagSyncDB = {}
		BagSyncGUILD_DB = {}
		print("|cFFFF0000BagSync: You have been updated to latest database version!  You will need to rescan all your characters again!|r")
		--]]
		print("|cFFFF0000BagSync: New database version!  You need to rescan all your characters.|r")
	end
	
	-- Add default settings to the SavedVariable with inheritance (using metatable)
	_G.BagSyncOpt = setmetatable(_G.BagSyncOpt or {}, { __index = OptionDefaults })
	-- Set the local reference to the SavedVariable
	BagSyncOpt = _G.BagSyncOpt
	
	-- Initialize database for current realm
	BagSyncDB = BagSyncDB or {}
	BagSyncDB[playerRealm] = BagSyncDB[playerRealm] or {}
	
	BagSyncTOKEN_DB = BagSyncTOKEN_DB or {}
	BagSyncTOKEN_DB[playerRealm] = BagSyncTOKEN_DB[playerRealm] or {}
	
	BagSyncCRAFT_DB = BagSyncCRAFT_DB or {}
	BagSyncCRAFT_DB[playerRealm] = BagSyncCRAFT_DB[playerRealm] or {}
	
	BagSyncGUILD_DB = BagSyncGUILD_DB or {}
	BagSyncGUILD_DB[playerRealm] = BagSyncGUILD_DB[playerRealm] or {}

	BagSyncBLACKLIST_DB = BagSyncBLACKLIST_DB or {}
	BagSyncBLACKLIST_DB[playerRealm] = BagSyncBLACKLIST_DB[playerRealm] or {}
	
	-- Static references into the SavedVariables database for the current realm
	RealmCharDB      = BagSyncDB[playerRealm]
	RealmTokenDB     = BagSyncTOKEN_DB[playerRealm]
	RealmCraftDB     = BagSyncCRAFT_DB[playerRealm]
	RealmGuildDB     = BagSyncGUILD_DB[playerRealm]
	RealmBlacklistDB = BagSyncBLACKLIST_DB[playerRealm]
	
	-- Initialize database for current character
	RealmCharDB[playerName] = RealmCharDB[playerName] or {}
	RealmCraftDB[playerName] = RealmCraftDB[playerName] or {}
	
	-- Static references into the SavedVariables database for the current character
	PlayerDB         = RealmCharDB[playerName]
	PlayerCraftDB    = RealmCraftDB[playerName]
	
end





----------------------------
--         GEAR           --
----------------------------

-- global function for debugging
function GetBagLink(bagID)
	return GetInventoryItemLink( 'player', ContainerIDToInventoryID(bagID) )
end



local function GetEquippedBags(bagIDFirst, bagIDLast)
	assert(atBank  or  (BACKPACK_CONTAINER <= bagIDFirst  and  bagIDLast <= NUM_BAG_SLOTS), "GetEquippedBags("..bagIDFirst..", "..bagIDLast.."): Must be at bank to be able to scan bags in bank")
	
	local bags = {}
	for  bagID = bagIDFirst, bagIDLast  do
		--local invSlotID = ContainerIDToInventoryID(bagID)
		--bags[invSlotID] = GetInventoryItemShortLink(invSlotID)
		bags[bagID] = ToItemData( GetBagLink(bagID) )
	end
	return bags
end

--[[
/dump BagSync.tmoggableSlotIDs
/run for i=1,19 do print(i,":",pcall(GetTransmogrifySlotInfo,i)) end
2,4,11-14,18-19 fails
[03:10:53] true true true 0 false false 8113 Interface\Icons\INV_Chest_Cloth_01
INVSLOT_HEAD 		= 1; INVSLOT_FIRST_EQUIPPED = INVSLOT_HEAD;
[03:11:49] 1 : true true true 0 false false 3345 Interface\Icons\INV_Helmet_15
INVSLOT_NECK = 2
[03:11:49] 2 : false Usage: GetTransmogrifySlotInfo(slot)
[03:11:49] 3 : true false true 0 false false 89883 Interface\Icons\inv_shoulder_raidmage_l_01
INVSLOT_BODY = 4 (shirt)
[03:11:49] 4 : false Usage: GetTransmogrifySlotInfo(slot)
[03:11:49] 5 : true true true 0 false false 8113 Interface\Icons\INV_Chest_Cloth_01
[03:11:49] 6 : true false true 0 false false 95961 Interface\Icons\INV_BELT_CLOTH_RAIDMAGE_M_01
[03:11:49] 7 : true true true 0 false false 8112 Interface\Icons\INV_Pants_14
[03:11:49] 8 : true true true 0 false false 77234 Interface\Icons\inv_boots_robe_raidwarlock_k_01
[03:11:49] 9 : true true true 0 false false 16799 Interface\Icons\INV_Belt_29
[03:11:49] 10 : true true true 0 false false 10019 Interface\Icons\INV_Gauntlets_18
INVSLOT_FINGER1 = 11
INVSLOT_FINGER2 = 12
INVSLOT_TRINKET1 = 13
INVSLOT_TRINKET2 = 14
[03:11:49] 11 : false Usage: GetTransmogrifySlotInfo(slot)
[03:11:49] 12 : false Usage: GetTransmogrifySlotInfo(slot)
[03:11:49] 13 : false Usage: GetTransmogrifySlotInfo(slot)
[03:11:49] 14 : false Usage: GetTransmogrifySlotInfo(slot)

[03:11:49] 15 : true false true 0 false false 90526 Interface\Icons\inv_cape_pandaria_d_03
[03:11:49] 16 : true false false 5 false false 45073 Interface\Icons\inv_misc_roses_01
[03:11:49] 17 : true false false 1
INVSLOT_RANGED = 18
INVSLOT_TABARD = 19
[03:11:49] 18 : false Usage: GetTransmogrifySlotInfo(slot)
[03:11:49] 19 : false Usage: GetTransmogrifySlotInfo(slot)
--]]

do
	local tmoggable = {}
	for  invSlotID = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED  do
		-- Checking if the slot throws an error (meaning its not tmoggable). Not interested in the actual return values.
		tmoggable[invSlotID] = pcall(GetTransmogrifySlotInfo, invSlotID)
	end
	BagSync.tmoggableSlotIDs = tmoggable
end

function BagSync:ScanEquipment()
	--reset our tooltip data since we scanned new items (we want current data not old)
	BagSync:resetTooltip()
	
	local invSlots = {}
	-- First to last = 1 to 19.  0 used to be INVSLOT_AMMO (not needed anymore)
	for  invSlotID = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED  do
		local itemLink = GetInventoryItemLink('player', invSlotID)
		--local isTransmogrified,canTransmogrify,cannotTransmogrifyReason,hasPending,hasUndo,visibleItemID,textureName = GetTransmogrifySlotInfo(invSlotID)
		local ran, err, tmoggedItemID
		if  BagSync.tmoggableSlotIDs[invSlotID]  then
			ran, err,_,_,_,_,tmoggedItemID = pcall(GetTransmogrifySlotInfo, invSlotID)
			if  not ran  then
				BagSync.tmoggableSlotIDs[invSlotID] = ran
				print("GetTransmogrifySlotInfo("..invSlotID..") fucked up: "..(err or "<no error message>"))
				tmoggedItemID = nil
			end
		end
		invSlots[invSlotID] = ToEquipData( itemLink, tmoggedItemID )
	end
	
	PlayerDB['equip'] = {}
	--PlayerDB['equip'] = PlayerDB['equip'] or {}
	PlayerDB['equip'][0] = invSlots
	PlayerDB['equip'].bags = GetEquippedBags(BACKPACK_CONTAINER+1, NUM_BAG_SLOTS)
	
	if  atBank  then
		PlayerDB['bank'].bags = GetEquippedBags(NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS)
	end
end



----------------------------
--       BACKPACK         --
----------------------------

function BagSync:ScanContainer(storageName, bagID)
	assert(atBank  or  (BACKPACK_CONTAINER <= bagID  and  bagID <= NUM_BAG_SLOTS), "BagSync:ScanContainer("..storageName..", "..bagID.."): Must be at bank to be able to scan bags in bank")
	print("BagSync:ScanContainer("..storageName..", "..bagID..")")
	
	--reset our tooltip data since we scanned new items (we want current data not old)
	BagSync:resetTooltip()

	local numBagSlots = GetContainerNumSlots(bagID)
	local bagItems = false
	
	if  0 < numBagSlots  then
		bagItems = {}
		for  slotID = 1, numBagSlots  do
			local _, count, _,_,_,_, link = GetContainerItemInfo(bagID, slotID)
			bagItems[slotID] = ToItemData(link, count)
		end
	end
	
	PlayerDB[storageName] = PlayerDB[storageName] or {}
	PlayerDB[storageName][bagID] = bagItems
end


function BagSync:ScanBackpackAndBags()    -- or ScanCarriedBags()
	--reset our tooltip data since we scanned new items (we want current data not old)
	BagSync:resetTooltip()
	-- Reset bag data
	PlayerDB['bag'] = {}
	
	-- Save carried backpack and bag contents 0 - 4
	for  bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS  do
		self:ScanContainer('bag', bagID)
	end
	
	--[[ Equipped (carried) bags are updated in ScanEquipment() on UNIT_INVENTORY_CHANGED event
	PlayerDB['equip'] = PlayerDB['equip'] or {}
	PlayerDB['equip'].bags = GetEquippedBags(BACKPACK_CONTAINER+1, NUM_BAG_SLOTS)
	--]]
end



----------------------------
--      BANK	            --
----------------------------

function BagSync:ScanEntireBank()
	print("BagSync:ScanEntireBank()")
	
	--reset our tooltip data since we scanned new items (we want current data not old)
	BagSync:resetTooltip()
	-- Reset bank data
	PlayerDB['bank'] = {}
	
	-- Equipped bank bags are updated on BANKFRAME_OPENED event
	PlayerDB['bank'].bags = GetEquippedBags(NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS)
	
	-- Save builtin bank contents
	self:ScanContainer('bank', BANK_CONTAINER)
	
	-- Save bank bag contents 5 - 11
	for  bagID = NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS  do
		self:ScanContainer('bank', bagID)
	end
end



----------------------------
--      VOID BANK	        --
----------------------------

function BagSync:ScanVoidBank()
	if  not VoidStorageFrame  or  not VoidStorageFrame:IsShown()  then  return false  end
	--print("BagSync:ScanVoidBank()")
	
	--reset our tooltip data since we scanned new items (we want current data not old)
	BagSync:resetTooltip()

	local voidItems = {}
	for slotID = 1, 80 do
		itemID, textureName, locked, recentDeposit, isFiltered = GetVoidItemInfo(i)
		voidItems[slotID] =  itemID  and  tostring(itemID)    -- no counts in void storage
	end
	
	--PlayerDB['void'] = {}
	PlayerDB['void'] = PlayerDB['void'] or {}
	PlayerDB['void'][0] = voidItems
end



------------------------------
--      GUILD BANK	        --
------------------------------

function BagSync:ScanGuildTab(tabID)
	local guildName = IsInGuild()  and  GetGuildInfo('player')
	if not guildName then return end
	--print("BagSync:ScanGuildTab("..tabID..")")
	
	--reset our tooltip data since we scanned new items (we want current data not old)
	BagSync:resetTooltip()
	
	local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(tabID)
	local tabItems = nil
		
	--if we don't check for isViewable we get a weirdo permissions error for the player when they attempt it
	if  isViewable  then
		tabItems = {}
		
		for  slotID = 1, MAX_GUILDBANK_SLOTS_PER_TAB  do
			local link = GetGuildBankItemLink(tabID, slotID)
			local _, count, _ =  link  and  GetGuildBankItemInfo(tabID, slotID)
			tabItems[slotID] = ToItemData(link, count)
		end
	end
	
	RealmGuildDB[guildName] = RealmGuildDB[guildName] or {}
	RealmGuildDB[guildName][tabID] = tabItems
end


function BagSync:ScanGuildBank()
	local guildName = IsInGuild()  and  GetGuildInfo('player')
	if not guildName then return end
	print("BagSync:ScanGuildBank()")
	
	for  tabID = 1, GetNumGuildBankTabs()  do
		self:ScanGuildTab(tabID)
	end
end



----------------------------
--      MAILBOX  	        --
----------------------------

function BagSync:ScanMailbox()
	--this is to prevent buffer overflow from the CheckInbox() function calling ScanMailbox too much :)
	if isCheckingMail then return end
	isCheckingMail = true
	print("BagSync:ScanMailbox()")

	--reset our tooltip data since we scanned new items (we want current data not old)
	BagSync:resetTooltip()
	
	--used to initiate mail check from server, for some reason GetInboxNumItems() returns zero sometimes
	--even though the user has mail in the mailbox.  This can be attributed to lag.
	CheckInbox()

	local mailbox = {}

	--scan the inbox
	for  mailIndex = 1, GetInboxNumItems()  do
		local mailItems = nil
		for  slotID = 1, ATTACHMENTS_MAX_RECEIVE  do
			local name, itemTexture, count, quality, canUse = GetInboxItem(mailIndex, slotID)
			local link = GetInboxItemLink(mailIndex, slotID)
			local itemData = ToItemData(link, count)
			if  not itemData  then
			elseif  slotID == 1  then
				-- First item stored directly
				mailItems = itemData
			else
				-- Second item wraps the first into an array
				if  type(mailItems) ~= 'table'  then  mailItems = { mailItems }  end
				-- Second and further items are stored in the array
				mailItems[slotID] = itemData
			end
		end
		
		mailbox[mailIndex] = mailItems
	end
	
	PlayerDB['mailbox'] = mailbox
	isCheckingMail = false
end



------------------------------
--     AUCTION HOUSE        --
------------------------------

function BagSync:ScanAuctionHouse()
	print("BagSync:ScanAuctionHouse()")
	
	--reset our tooltip data since we scanned new items (we want current data not old)
	BagSync:resetTooltip()
	
	local ahItems = {}
	local ahCount = 0
	local numActiveAuctions = GetNumAuctionItems("owner")
	
	--scan the auction house
	for  ahIndex = 1, numActiveAuctions  do
		local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, saleStatus  = GetAuctionItemInfo("owner", ahIndex)
		local link = GetAuctionItemLink("owner", ahIndex)
		--local timeLeft = link  and  GetAuctionItemTimeLeft("owner", ahIndex)
		--ahItems[ahIndex] = ToItemData(link, count, 'A', timeLeft)
		ahItems[ahIndex] = ToItemData(link, count)
	end

	--PlayerDB['auction'] = PlayerDB['auction'] or {}
	PlayerDB['auction'] = { [0] = ahItems }
	--PlayerDB.AH_Count = numActiveAuctions
	PlayerDB.AH_Count = nil
end



--this method is global for all toons, removes expired auctions on login
function BagSync:RemoveExpiredAuctions()
	local timestampChk = { 30*60, 2*60*60, 12*60*60, 48*60*60 }
				
	for realmName, realmData in pairs(BagSyncDB) do
		for charName, charData in pairs(realmData) do
			if  charData.AH_LastScan  and  charData['auction']  then --only proceed if we have an auction house time to work with
				--check to see if we even have something to work with
				local ahItems = charData['auction'][0]
				if  ahItems  then
					--do a loop through all of them and check to see if any expired
					for  ahIndex, itemData  in pairs(ahItems) do
						--check for expired and remove if necessary
						local dblink, dbcount, dbtimeleft = itemData:match('^(.+),(%d+),(%d+)$')
						
						--only proceed if we have everything to work with, otherwise this auction data is corrupt
						if dblink and dbcount and dbtimeleft then
							if tonumber(dbtimeleft) < 1 or tonumber(dbtimeleft) > 4 then dbtimeleft = 4 end --just in case
							--now do the time checks
							local diff = time() - charData.AH_LastScan 
							if diff > timestampChk[tonumber(dbtimeleft)] then
								--technically this isn't very realiable.  but I suppose it's better than nothing
								ahItems[ahIndex] = nil
							end
						else
							--it's corrupt delete it
							--ahItems[ahIndex] = nil
						end
					end
				end
			end
		end
	end
end





---------------------------
-- Database initial scan --
---------------------------

function BagSync:AfterLoginScan()
	local startTime = GetTime()
	-- local version = "[v|cFFDF2B2B"..ver.."|r]"
	Debug("|cFF99CC33BagSync|r   /bgs, /bagsync    starting delayed initial bag scan")
	
	--do DB cleanup check by version number
	local ver = GetAddOnMetadata("BagSync","Version") or 0
	if not BagSyncOpt.dbversion or BagSyncOpt.dbversion ~= ver then	
		self:FixDB_Data()
		BagSyncOpt.dbversion = ver
	end
	
	--save the current user money (before bag update)
	PlayerDB.gold = GetMoney()

	--save the class information
	PlayerDB.class = playerClass

	--save the faction information
	--"Alliance", "Horde" or nil
	PlayerDB.faction = playerFaction
	
	--check for player not in guild
	if IsInGuild() or GetNumGuildMembers(true) > 0 then
		GuildRoster()
	elseif PlayerDB.guild then
		PlayerDB.guild = nil
		self:FixDB_Data(true)
	end
	
	-- Refresh equipment, backpack, bag and token database
	self:Schedule( self.ScanBackpackAndBags )
	self:Schedule( self.ScanEquipment )
	self:Schedule( self.ScanTokens )
	
	self:SetRegisterEvents(true, ns.EventsToScanAfterInitial)
	
	-- Release memory
	self.AfterLoginScan = nil
	
	--clean up old auctions
	--self:RemoveExpiredAuctions()
	
	--BagSync.AfterLoginScanTime = GetTime() - startTime
	--print( format("BagSync:AfterLoginScan() ran for %.3f seconds", BagSync.AfterLoginScanTime) )
	
	--we deleted someone with the Profile Window, display name of user deleted
	if BagSyncOpt.delName then
		print("|cFFFF0000BagSync: "..L["Profiles"].." "..L["Delete"].." ["..BagSyncOpt.delName.."]!|r")
		BagSyncOpt.delName = nil
	end
end



----------------------
-- Database cleanup --
----------------------

function BagSync:FixDB_Data(onlyChkGuild)
	--Removes obsolete character information
	--Removes obsolete guild information
	--Removes obsolete characters from tokens db
	--Removes obsolete profession information
	--Will only check guild related information if the paramater is passed as true

	local storeUsers = {}
	local storeGuilds = {}
	
	for realmName, realmData in pairs(BagSyncDB) do
		storeUsers[realmName] = storeUsers[realmName] or {}
		storeGuilds[realmName] = storeGuilds[realmName] or {}
		for charName, charData in pairs(realmData) do
			storeUsers[realmName][charName] = storeUsers[realmName][charName] or 1
			if  charData.guild  then  storeGuilds[realmName][charData.guild] = true  end
		end
	end

	--guildbank data
	for realmName, realmGuilds in pairs(BagSyncGUILD_DB) do
		for guildName, guildData in pairs(realmGuilds) do
			if not storeGuilds[realmName][guildName] then
				--delete the guild because no one has it
				BagSyncGUILD_DB[realmName][guildName] = nil
			end
		end
	end
	
	--token data and profession data, only do if were not doing a guild check
	--also display fixdb message only if were not doing a guild check
	if not onlyChkGuild then
	
		--fix tokens
		for realmName, realmTokens in pairs(BagSyncTOKEN_DB) do
			if not storeUsers[realmName] then
				--if it's not a realm that ANY users are on then delete it
				BagSyncTOKEN_DB[realmName] = nil
			else
				--delete old db information for tokens if it exists
				realmTokens[1] = nil
				realmTokens[2] = nil
				
				for tokenName, charTokens in pairs(realmTokens) do
					for  charName, count  in pairs(charTokens) do
						if charName ~= "icon" and charName ~= "header" then
							if not storeUsers[realmName][charName] then
								--if the user doesn't exist then delete data
								charTokens[charName] = nil
							end
						end
					end
				end
			end
		end
		
		--fix professions
		for realmName, realmCraft in pairs(BagSyncCRAFT_DB) do
			local existingChars = nil
			--if it's not a realm that ANY users are on then delete it
			if  storeUsers[realmName]  then
				existingChars = {}
				for  charName, charCraft  in pairs(realmCraft) do
					-- If user exists then keep the data
					if  storeUsers[realmName][charName]  then  existingChars[charName] = charCraft  end
				end
			end
			BagSyncCRAFT_DB[realmName] = existingChars
		end

		DEFAULT_CHAT_FRAME:AddMessage("|cFF99CC33BagSync:|r |cFFFF9900"..L["A FixDB has been performed on BagSync!  The database is now optimized!"].."|r")
	end
end





------------------------------
--      Event Handlers      --
------------------------------


----------------------------
--      BAG UPDATES  	    --
----------------------------

function BagSync:PLAYER_MONEY()
	PlayerDB.gold = GetMoney()
end

function BagSync:BAG_UPDATE(event, bagID)
	print("BagSync:BAG_UPDATE("..event..", "..bagID..")")
	self.BagsToScan = self.BagsToScan  or  {}
	self.BagsToScan[bagID] = true
	self:Schedule( self.ScanNextContainer )
end

function BagSync:ScanNextContainer()
	local bagID = next(self.BagsToScan)
	if  not bagID  then  return  end
	self.BagsToScan[bagID] = nil
	
	-- Get the correct storage name based on it's id. Use constants defined in FrameXML\Constants.lua as Blizzard may change these in the future.
	local storageName =  BACKPACK_CONTAINER <= bagID  and  bagID  <= NUM_BAG_SLOTS  and  'bag'
		or  NUM_BAG_SLOTS < bagID  and  bagID <= NUM_BAG_SLOTS + NUM_BANKBAGSLOTS  and  'bank'
	
	if  not storageName  then  
		local backpackIDs = BACKPACK_CONTAINER .." - ".. NUM_BAG_SLOTS
		local bankIDs = BANK_CONTAINER ..", ".. (NUM_BAG_SLOTS+1) .." - ".. (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
		print("BagSync:ScanNextContainer(): unknown bagID="..bagID.." not in backpack ("..backpackIDs..") nor the bank ("..bankIDs..")")
		return true  -- Call again to scan next
	end
	
	if  storageName == 'bank'  and  not atBank  then
		print("BagSync:ScanNextContainer(): bagID="..bagID.."  storageName == 'bank' but not atBank")
		return true  -- Call again to scan next
	end
	
	-- Save the item information in the bag from bagupdate, this could be carried bag or bank bag
	self:ScanContainer(storageName, bagID)
		
	if  atBank  and  bagID ~= BANK_CONTAINER  then
		-- We have to force the -1 default bank container because Blizzard doesn't push updates for it (for some stupid reason)
		--self:ScanContainer('bank', BANK_CONTAINER)
	end
	
	return true  -- Call again to scan next
end

function BagSync:UNIT_INVENTORY_CHANGED(event, unit)
	if unit == 'player' then
		print("BagSync:UNIT_INVENTORY_CHANGED("..unit.."): ScanEquipment()")
		self:Schedule( self.ScanEquipment )
	end
end

----------------------------
--      BANK	            --
----------------------------

function BagSync:BANKFRAME_OPENED()
	atBank = true
	self:Schedule( self.ScanEntireBank )
end

function BagSync:BANKFRAME_CLOSED()
	atBank = false
end

----------------------------
--      VOID BANK	        --
----------------------------

function BagSync:VOID_STORAGE_OPEN()
	atVoidBank = true
	self:Schedule( self.ScanVoidBank )
end

function BagSync:VOID_STORAGE_CLOSE()
	atVoidBank = false
end

function BagSync:VOID_STORAGE_UPDATE()
	self:Schedule( self.ScanVoidBank )
end

function BagSync:VOID_STORAGE_CONTENTS_UPDATE()
	self:Schedule( self.ScanVoidBank )
end

function BagSync:VOID_TRANSFER_DONE()
	self:Schedule( self.ScanVoidBank )
end

------------------------------
--      GUILD BANK	        --
------------------------------

function BagSync:GUILD_ROSTER_UPDATE()
	local newGuild =  IsInGuild()  and  GetGuildInfo('player')
	
	if  PlayerDB.guild ~= newGuild  then
		PlayerDB.guild = newGuild
		-- Delete guild bank data now  or  keep until next login
		if  self.instantForgetGuildData  then  self:FixDB_Data(true)  end
	end
end

function BagSync:GUILDBANKFRAME_OPENED()
	atGuildBank = true
	if not BagSyncOpt.enableGuild then return end
	
	local numTabs = GetNumGuildBankTabs()
	for tabID = 1, numTabs do
		-- add this tab to the queue to refresh; if we do them all at once the server bugs and sends massive amounts of events
		local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(tabID)
		if isViewable then
			guildTabQueryQueue[tabID] = true
		end
	end
end

function BagSync:GUILDBANKFRAME_CLOSED()
	atGuildBank = false
end

function BagSync:GUILDBANKBAGSLOTS_CHANGED()
	if not BagSyncOpt.enableGuild then return end

	if atGuildBank then
		-- check if we need to process the queue
		local tabID = next(guildTabQueryQueue)
		if tabID then
			QueryGuildBankTab(tabID)
			guildTabQueryQueue[tabID] = nil
		else
			-- the bank is ready for reading
			self:Schedule( self.ScanGuildBank )
		end
	end
end

------------------------------
--      MAILBOX  	        --
------------------------------

function BagSync:MAIL_SHOW()
	if isCheckingMail then return end
	if not BagSyncOpt.enableMailbox then return end
	self:Schedule( self.ScanMailbox )
end

function BagSync:MAIL_INBOX_UPDATE()
	if isCheckingMail then return end
	if not BagSyncOpt.enableMailbox then return end
	self:Schedule( self.ScanMailbox )
end

------------------------------
--     AUCTION HOUSE        --
------------------------------

function BagSync:AUCTION_HOUSE_SHOW()
	Debug('BagSync:AUCTION_HOUSE_SHOW()')
	if not BagSyncOpt.enableAuction then return end
	self:Schedule( self.ScanAuctionHouse )
end

function BagSync:AUCTION_OWNED_LIST_UPDATE()
	Debug('BagSync:AUCTION_OWNED_LIST_UPDATE()')
	if not BagSyncOpt.enableAuction then return end
	PlayerDB.AH_LastScan = time()
	self:Schedule( self.ScanAuctionHouse )
end





------------------------
--      TOKENS        --
------------------------

local function IsInBG()
	if (GetNumBattlefieldScores() > 0) then
		return true
	end
	local status, mapName, instanceID, minlevel, maxlevel
	for i=1, GetMaxBattlefieldID() do
		status, mapName, instanceID, minlevel, maxlevel, teamSize = GetBattlefieldStatus(i)
		if status == "active" then
			return true
		end
	end
	return false
end

local function IsInArena()
	local a,b = IsActiveBattlefieldArena()
	if (a == nil) then
		return false
	end
	return true
end

--[[
/run print(tostring(BagSyncTOKEN_DB))
--]]
function BagSync:ScanTokens(event)
	if  not RealmTokenDB  then
			print("[".. date('%H:%M:%S') .."] BagSync:ScanTokens("..tostring(event).."): Saved variables BagSyncTOKEN_DB ("..tostring(BagSyncTOKEN_DB).."), RealmTokenDB ("..tostring(RealmTokenDB)..": not loaded yet.")
		return
	end
	
	print("BagSync:ScanTokens("..tostring(event)..")")
	
	self = self or BagSync
	
	--LETS AVOID TOKEN SPAM AS MUCH AS POSSIBLE
	if doTokenUpdate == 1 then return end
	if IsInBG() or IsInArena() or InCombatLockdown() or UnitAffectingCombat("player") then
		--avoid (Honor point spam), avoid (arena point spam), if it's world PVP...well then it sucks to be you
		doTokenUpdate = 1
		BagSync:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	local lastHeader
	
	for i=1, GetCurrencyListSize() do
		local name, isHeader, isExpanded, _, _, count, icon = GetCurrencyListInfo(i)
		--extraCurrencyType = 1 for arena points, 2 for honor points; 0 otherwise (an item-based currency).
		if  not name  then
			-- What now?
		elseif  isHeader  then
			if  not isExpanded  then  ExpandCurrencyList(i,1)  end
			lastHeader = name
		else
			local tokenDB = RealmTokenDB[name] or {}
			RealmTokenDB[name] = tokenDB
			tokenDB.icon = icon
			tokenDB.header = lastHeader
			tokenDB[playerName] = count
		end
	end
	--we don't want to overwrite tokens, because some characters may have currency that the others dont have
end


-- Called from  MainMenuBar_OnEvent(CURRENCY_DISPLAY_UPDATE)
hooksecurefunc('BackpackTokenFrame_Update', BagSync.ScanTokens)

function BagSync:CURRENCY_DISPLAY_UPDATE(event)
	print('BagSync:CURRENCY_DISPLAY_UPDATE()')
	self:Schedule( self.ScanTokens )
end

function BagSync:PLAYER_REGEN_ENABLED(event)
	if IsInBG() or IsInArena() or InCombatLockdown() or UnitAffectingCombat('player') then return end
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	--were out of an arena or battleground scan the points
	doTokenUpdate = 0
	self:Schedule( self.ScanTokens )
end





------------------------------
--     PROFESSION           --
------------------------------

local function doRegularTradeSkill(numIndex, dbIdx)
	local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, skillModifier = GetProfessionInfo(numIndex)
	if name and skillLevel then
		PlayerCraftDB[dbIdx] = format('%s,%s', name, skillLevel)
	end
end

function BagSync:TRADE_SKILL_SHOW()
	--IsTradeSkillLinked() returns true only if trade window was opened from chat link (meaning another player)
	if (not IsTradeSkillLinked()) then
		
		local tradename = _G.GetTradeSkillLine()
		local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
		
		local iconProf1 = prof1 and select(2, GetProfessionInfo(prof1))
		local iconProf2 = prof2 and select(2, GetProfessionInfo(prof2))
		
		--list of tradeskills with NO skill link but can be used as primaries (ex. a person with two gathering skills)
		local noLinkTS = {
			["Interface\\Icons\\Trade_Herbalism"] = true, --this is Herbalism
			["Interface\\Icons\\INV_Misc_Pelt_Wolf_01"] = true, --this is Skinning
			["Interface\\Icons\\INV_Pick_02"] = true, --this is Mining
		}
		
		--prof1
		if prof1 and (GetProfessionInfo(prof1) == tradename) and GetTradeSkillListLink() then
			local skill = select(3, GetProfessionInfo(prof1))
			PlayerCraftDB[1] = { tradename, GetTradeSkillListLink(), skill }
		elseif prof1 and iconProf1 and noLinkTS[iconProf1] then
			--only store if it's herbalism, skinning, or mining
			doRegularTradeSkill(prof1, 1)
		elseif not prof1 and PlayerCraftDB[1] then
			--they removed a profession
			PlayerCraftDB[1] = nil
		end

		--prof2
		if prof2 and (GetProfessionInfo(prof2) == tradename) and GetTradeSkillListLink() then
			local skill = select(3, GetProfessionInfo(prof2))
			PlayerCraftDB[2] = { tradename, GetTradeSkillListLink(), skill }
		elseif prof2 and iconProf2 and noLinkTS[iconProf2] then
			--only store if it's herbalism, skinning, or mining
			doRegularTradeSkill(prof2, 2)
		elseif not prof2 and PlayerCraftDB[2] then
			--they removed a profession
			PlayerCraftDB[2] = nil
		end
		
		--archaeology
		if archaeology then
			doRegularTradeSkill(archaeology, 3)
		elseif not archaeology and PlayerCraftDB[3] then
			--they removed a profession
			PlayerCraftDB[3] = nil
		end
		
		--fishing
		if fishing then
			doRegularTradeSkill(fishing, 4)
		elseif not fishing and PlayerCraftDB[4] then
			--they removed a profession
			PlayerCraftDB[4] = nil
		end
		
		--cooking
		if cooking and (GetProfessionInfo(cooking) == tradename) and GetTradeSkillListLink() then
			local skill = select(3, GetProfessionInfo(cooking))
			PlayerCraftDB[5] = { tradename, GetTradeSkillListLink(), skill }
		elseif not cooking and PlayerCraftDB[5] then
			--they removed a profession
			PlayerCraftDB[5] = nil
		end
		
		--firstAid
		if firstAid and (GetProfessionInfo(firstAid) == tradename) and GetTradeSkillListLink() then
			local skill = select(3, GetProfessionInfo(firstAid))
			PlayerCraftDB[6] = { tradename, GetTradeSkillListLink(), skill }
		elseif not firstAid and PlayerCraftDB[6] then
			--they removed a profession
			PlayerCraftDB[6] = nil
		end
		
	end
end



