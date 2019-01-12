--[[
/run print( format("BagSync:AfterLoginScan() ran for %.3f seconds", BagSync.AfterLoginScanTime) )
/run slotID = 1; print( GetInventoryItemID('player', slotID), GetInventoryItemLink('player', slotID) )
/dump GetItemInfo(1)
/dump GetInventoryItemID('player', 68)
/dump GetInventoryItemID('player', 1)
/dump GetInventoryItemLink('player', 1)
/run for bagID=1,11 do local invSlotID=ContainerIDToInventoryID(bagID); print(bagID..'. invSlotID='..tostring(invSlotID)..' item='..(GetInventoryItemID('player', invSlotID) or 'nil')..' '..(GetInventoryItemLink('player', invSlotID) or 'nil') ) end
/run for bagID=1,11 do local l=GetBagLink(bagID); if l then print(bagID..'. '..l..'  '..gsub(l,'|','||')) else print(bagID..'. <no bag>') end end
--]]


-- Addon private namespace
local ADDON_NAME, ns = ...
-- Addon global namespace
local _G = _G
local BagSync = _G.BagSync
-- Localization
local L = BAGSYNC_L
-- Imported from BagSync.lua
local Debug = ns.Debug

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
local playerName = _G.UnitName('player')
local playerRealm = _G.GetRealmName()
local playerClass = select(2, _G.UnitClass('player'))
local playerFaction = _G.UnitFactionGroup('player')


-- Blizzard constants from FrameXML\Constants.lua cached in local namespace
local INVSLOT_FIRST_EQUIPPED = INVSLOT_FIRST_EQUIPPED    -- 1
local INVSLOT_LAST_EQUIPPED = INVSLOT_LAST_EQUIPPED    -- 19
local ATTACHMENTS_MAX_RECEIVE = ATTACHMENTS_MAX_RECEIVE    -- 16  MailFrame.lua
local MAX_GUILDBANK_TABS = MAX_GUILDBANK_TABS    -- 8
local MAX_GUILDBANK_SLOTS_PER_TAB = 98    -- not defined in FrameXML
local HEARTHSTONE_ITEM_ID = HEARTHSTONE_ITEM_ID or 6948

--[[ State of scanning
local ns.doTokenUpdate = nil
local ns.guildTabQueryQueue = {}
local ns.atBank = false
local ns.atVoidBank = false
local ns.atGuildBank = false
local ns.isCheckingMail = false
--]]


local ToEquipData = BagSync.ToEquipData
local ToItemData = BagSync.ToItemData
local ToSearchData = BagSync.ToSearchData
local ParseItemData = BagSync.ParseItemData
local MatchItemData = BagSync.MatchItemData





-------------------------
-- SavedVariables init --
-------------------------

local OptionDefaults = {
	-- enableMinimap = true,
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
	Debug("[".. date('%H:%M:%S') .."] BagSync.InitSavedDB()")

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

BagSync.tmoggableSlotIDs = {
	[INVSLOT_AMMO]       = false,		-- quiver, removed, ammo is infinite now
	[INVSLOT_HEAD]       = 1,
	[INVSLOT_NECK]       = false,		-- necklace cannot be tmogged
	[INVSLOT_SHOULDER]   = 1,
	[INVSLOT_BODY]       = false,		-- shirt, cannot be tmogged
	[INVSLOT_CHEST]      = 1,
	[INVSLOT_WAIST]      = 1,
	[INVSLOT_LEGS]       = 1,
	[INVSLOT_FEET]       = 1,
	[INVSLOT_WRIST]      = 1,
	[INVSLOT_HAND]       = 1,
	[INVSLOT_FINGER1]    = false,		-- rings and trinkets cannot be tmogged
	[INVSLOT_FINGER2]    = false,
	[INVSLOT_TRINKET1]   = false,
	[INVSLOT_TRINKET2]   = false,
	[INVSLOT_BACK]       = 1,
	[INVSLOT_MAINHAND]   = 1,
	[INVSLOT_OFFHAND]    = 1,
	[INVSLOT_RANGED]     = false,		-- bow/gun, removed, ranged weapons are in INVSLOT_MAINHAND now
	[INVSLOT_TABARD]     = false,		-- tabard cannot be tmogged
}

function BagSync:CheckTmoggableSlotIDs()
	local tmoggable = {}
	for  invSlotID = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED  do
		-- Checking if the slot throws an error (meaning its not tmoggable). Not interested in the actual return values.
		tmoggable[invSlotID] = pcall(GetTransmogrifySlotInfo, invSlotID)
		Debug("GetTransmogrifySlotInfo("..invSlotID..") runs to success: "..tostring(tmoggable[invSlotID]))
	end
	self.tmoggableSlotIDs = tmoggable
end

do
	BagSync:CheckTmoggableSlotIDs()
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
				Debug("GetTransmogrifySlotInfo("..invSlotID..") fucked up: "..(err or "<no error message>"))
				tmoggedItemID = nil
			end
		end
		invSlots[invSlotID] = ToEquipData( itemLink, tmoggedItemID )
	end
	
	PlayerDB['equip'] = PlayerDB['equip'] or {}
	PlayerDB['equip'][0] = invSlots
	-- BagSync:ScanBackpackBags()
	-- BagSync:ScanBankBags()
end



----------------------------
--     EQUIPPED BAGS      --
----------------------------

local function GetBagLink(bagID)
	return GetInventoryItemLink( 'player', ContainerIDToInventoryID(bagID) )
end
-- Export as global function for debugging
_G.GetBagLink = GetBagLink


local function GetEquippedBags(bagIDFirst, bagIDLast)
	assert(ns.atBank  or  (BACKPACK_CONTAINER <= bagIDFirst  and  bagIDLast <= NUM_BAG_SLOTS), "GetEquippedBags("..bagIDFirst..", "..bagIDLast.."): Must be at bank to be able to scan bags in bank")
	
	local bags = {}
	for  bagID = bagIDFirst, bagIDLast  do
		--local invSlotID = ContainerIDToInventoryID(bagID)
		--bags[invSlotID] = GetInventoryItemShortLink(invSlotID)
		bags[bagID] = ToItemData( GetBagLink(bagID) )
	end
	return bags
end

function BagSync:ScanBackpackBags()
	PlayerDB['equip'] = PlayerDB['equip'] or {}
	PlayerDB['equip'].bags = GetEquippedBags(BACKPACK_CONTAINER+1, NUM_BAG_SLOTS)
end

function BagSync:ScanBankBags(bagID)
	if  not ns.atBank  then  return false  end
	
	if  bagID  and  PlayerDB['equip']  and  PlayerDB['equip'].bankBags  then
		PlayerDB['equip'].bankBags[bagID] = ToItemData( GetBagLink(bagID) )
	else
		if  PlayerDB.bank  and  PlayerDB.bank.bags  then  PlayerDB.bank.bags = nil  end
		PlayerDB['equip'] = PlayerDB['equip'] or {}
		PlayerDB['equip'].bankBags = GetEquippedBags(NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS)
	end
end



----------------------------
--       BACKPACK         --
----------------------------

function BagSync:ScanContainer(storageName, bagID)
	assert(ns.atBank  or  (BACKPACK_CONTAINER <= bagID  and  bagID <= NUM_BAG_SLOTS), "BagSync:ScanContainer("..storageName..", "..bagID.."): Must be at bank to be able to scan bags in bank")
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


function BagSync:ScanBackpack()    -- or ScanCarriedBags()
	--reset our tooltip data since we scanned new items (we want current data not old)
	BagSync:resetTooltip()
	-- Reset bag data
	PlayerDB['bag'] = {}
	
	-- Save carried backpack and bag contents 0 - 4
	for  bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS  do
		self:ScanContainer('bag', bagID)
	end
	
	self:ScanBackpackBags()
end



----------------------------
--      BANK	            --
----------------------------

function BagSync:ScanEntireBank()
	print("BagSync:ScanEntireBank()")
	-- Delayed scan was scheduled when bank was opened, maybe it has been closed in the meantime.
	if  not ns.atBank  then  return  end
	
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
	
	self:ScanBankBags()
end



----------------------------
--      VOID BANK	        --
----------------------------

function BagSync:ScanVoidBank()
	--if  not VoidStorageFrame  or  not VoidStorageFrame:IsShown()  then  return false  end
	if  not ns.atVoidBank  then  return  end
	Debug("BagSync:ScanVoidBank()")
	
	--reset our tooltip data since we scanned new items (we want current data not old)
	BagSync:resetTooltip()

	local voidItems = {}
	for slotID = 1, 80 do
		itemID, textureName, locked, recentDeposit, isFiltered = GetVoidItemInfo(slotID)
		voidItems[slotID] =  itemID  and  tostring(itemID)    -- no counts in void storage
	end
	
	--PlayerDB['void'] = {}
	PlayerDB['void'] = PlayerDB['void'] or {}
	PlayerDB['void'][0] = voidItems
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

function BagSync:ScanGuildTab(tabID)
	local guildName = IsInGuild()  and  GetGuildInfo('player')
	if not guildName then return end
	Debug("BagSync:ScanGuildTab("..tabID..")")
	
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
	Debug("BagSync:ScanGuildBank()")
	
	for  tabID = 1, GetNumGuildBankTabs()  do
		self:ScanGuildTab(tabID)
	end
end



----------------------------
--      MAILBOX  	        --
----------------------------

function BagSync:ScanMailbox()
	--this is to prevent buffer overflow from the CheckInbox() function calling ScanMailbox too much :)
	if ns.isCheckingMail then return end
	ns.isCheckingMail = true
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
	ns.isCheckingMail = false
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
	PlayerDB.AH_LastScan = time()
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
	self:Schedule( self.ScanBackpack )
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






----------------------------
--      BAG UPDATES  	    --
----------------------------

function BagSync:PLAYER_MONEY()
	PlayerDB.gold = GetMoney()
end

function BagSync:ScheduleScanContainer(bagID)
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
		or  BANK_CONTAINER == bagID  and  'bank'
	
	if  not storageName  then  
		local backpackIDs = BACKPACK_CONTAINER .." - ".. NUM_BAG_SLOTS
		local bankIDs = BANK_CONTAINER ..", ".. (NUM_BAG_SLOTS+1) .." - ".. (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
		print("BagSync:ScanNextContainer(): unknown bagID="..bagID.." not in backpack ("..backpackIDs..") nor the bank ("..bankIDs..")")
		return true  -- Call again to scan next
	end
	
	if  storageName == 'bank'  and  not ns.atBank  then
		print("BagSync:ScanNextContainer(): bagID="..bagID.."  storageName == 'bank' but not atBank")
		return true  -- Call again to scan next
	end
	
	-- Save the item information in the bag from bagupdate, this could be carried bag or bank bag
	self:ScanContainer(storageName, bagID)
	
	--[[
	-- 2018-12-04: PLAYERBANKSLOTS_CHANGED event is sent for changes in default bank container
	if  ns.atBank  and  bagID ~= BANK_CONTAINER  then
		-- We have to force the -1 default bank container because Blizzard doesn't push updates for it (for some stupid reason)
		self:ScanContainer('bank', BANK_CONTAINER)
	end
	--]]
	
	return true  -- Call again to scan next
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
	return  a ~= nil
end

function BagSync.DelayTokenScan()
	return IsInBG() or IsInArena() or InCombatLockdown() or UnitAffectingCombat('player')
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
	if  ns.doTokenUpdate == 1  then  return  end
	if  self.DelayTokenScan()  then
		--avoid (Honor point spam), avoid (arena point spam), if it's world PVP...well then it sucks to be you
		ns.doTokenUpdate = 1
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


function BagSync:PLAYER_REGEN_ENABLED(event)
	if  self.DelayTokenScan()  then  return  end
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	-- we're out of an arena or battleground scan the points
	ns.doTokenUpdate = nil
	self:Schedule( self.ScanTokens )
end



