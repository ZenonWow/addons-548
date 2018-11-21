------------------------
--      Tooltip!      --
-- (Special thanks to tuller)
------------------------

-- Addon private namespace
local ADDON_NAME, ns = ...
-- Addon global namespace
local BagSync = BagSync
-- Localization
local L = BAGSYNC_L
local Debug =  ns.Debug
-- Cache the Search frame for checking if the tooltip is for this frame
local BagSync_SearchFrame = BagSync_SearchFrame


local BagSyncOpt

-- Static references into the SavedVariables database initialized in AddItemToTooltip()
local RealmCharDB      -- BagSyncDB[playerRealm]
local RealmTokenDB     -- BagSyncTOKEN_DB[playerRealm]
--local RealmCraftDB     -- BagSyncCRAFT_DB[playerRealm]
local RealmGuildDB     -- BagSyncGUILD_DB[playerRealm]
local RealmBlacklistDB -- BagSyncBLACKLIST_DB[playerRealm]
--[[
local PlayerDB         -- RealmCharDB[playerName]
local PlayerCraftDB    -- RealmCraftDB[playerName]
--]]

-- from https://wow.gamepedia.com/Class_colors
local colorRGB = {
	--playerName  = 'FFF569',  -- Rogue	Yellow	255	245	105	1.00	0.96	0.41	#FFF569	
	--playerName  = 'FFFF00',  -- Yellow	255	255	0	1.00	1.00	0.0	#FFFF00	
	playerName  = 'FF7D0A',  -- Druid	Orange	255	125	10	1.00	0.49	0.04	#FF7D0A
	playerCount = 'FF7D0A',  -- Druid	Orange	255	125	10	1.00	0.49	0.04	#FF7D0A
	--playerCount = 'FFFF00',  -- Yellow	255	255	0	1.00	1.00	0.0	#FFFF00	
	charName    = '80FF00',  -- Monk	Spring Green	0	255	150	0.00	1.00	0.59	#00FF96
	count       = 'ABD473',  -- Hunter	Green	171	212	115	0.67	0.83	0.45	#ABD473
	--count       = '80FF00',  -- MOSS
	total       = 'FFF569',  -- Rogue	Yellow	255	245	105	1.00	0.96	0.41	#FFF569	
	--total       = 'FF7D0A',  -- Druid	Orange	255	125	10	1.00	0.49	0.04	#FF7D0A
	guildName   = '40C7EB',  -- Mage	Light Blue	64	199	235	0.25	0.78	0.92	#40C7EB
	guild       = '0070DE',  -- Shaman	Blue	0	112	222	0.00	0.44	0.87	#0070DE
}

--[[
local SILVER = '|cffc7c7cf%s|r'
local MOSS = '|cFF80FF00%s|r'
local TTL_C = '|cFFF4A460%s|r'
local GN_C = '|cFF65B8C0%s|r'
local colorRGB = {
	count = '80FF00',  -- MOSS
	guildName = '65B8C0',  -- GN_C
	guild = 'c7c7cf',  -- SILVER
	total = 'F4A460',  -- TTL_C
}
--]]

local colorWrap = {}
-- Generate methods for static colors
for  color,rgb  in pairs(colorRGB) do  colorWrap[color] = function(text)  return '|cff'.. rgb .. text ..'|r'  end  end
-- Generate methods for dynamic colors
--for  color,_  in pairs(colorRGB) do  colorWrap[color] = function(text)  return '|cff'.. colorRGB[color] .. text ..'|r'  end  end


-- Which storages to query and display
local storageEnabled = {
	bag = true,
	equip = true,
	mailbox = true,    -- BagSyncOpt.enableMailbox,
	mailsent = true,    -- BagSyncOpt.enableMailbox,
	auction = true,    -- BagSyncOpt.enableAuction,
	bank = true,
	void = true,
}

-- Show storages in the order:
local storageOrder = {
	'bag',
	'equip',
	'mailbox',
	'mailsent',
	'auction',
	'bank',
	'void',
	-- showTotal, showGuild done by specific code
	--'showTotal',
	--'showGuild',
}

-- Storage name localization and optional coloring
local storageL = {
	bag = L["Bags: %d"],
	equip = L["Equipped: %d"],
	mailbox = L["Mailbox: %d"],
	mailsent = L["Sent to: %d"],
	auction = L["AH: %d"],
	bank = L["Bank: %d"],
	void = L["Void: %d"],
	showTotal = colorWrap.total( "("..L["All: %d"]..")" ),
	--showTotal = colorWrap.total( "(%d)" ),
	--showTotal = colorWrap.total( L["(∑: %d)"] ),
	--showTotal = colorWrap.total( L["Total:"].." %d" ),
	showGuild = colorWrap.guild( L["Guild: %d"] ),
}


-- Last item's searchData (stringified itemID if item  or  shortened link if battlepet or full link)
local lastQuery
-- Last displayed tooltip lines
local itemLines = {}
-- Temporary guild info cache
local guildsItemInfo = nil


-- Addon functions imported
local ToEquipData = BagSync.ToEquipData
local ToItemData = BagSync.ToItemData
local ToSearchData = BagSync.ToSearchData
local ParseItemData = BagSync.ParseItemData
local MatchItemData = BagSync.MatchItemData





-- Show characters in decreasing order of total count
local function charInfoSortFunc(a, b)  return  (a.total > b.total)  or  (a.total == b.total and a.charName < b.charName)  end


--sort by key element rather then value
local function pairsByKeys (t, f)
	local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a, f)
		local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
	return iter
end


local function rgbhex(r, g, b)
  if type(r) == "table" then
	if r.r then
	  r, g, b = r.r, r.g, r.b
	else
	  r, g, b = unpack(r)
	end
  end
  return string.format("|cff%02x%02x%02x", (r or 1) * 255, (g or 1) * 255, (b or 1) * 255)
end


--[[
local function getNameColor(sName, sClass)
	if not BagSyncOpt.enableUnitClass then
		return colorWrap.charName(sName)
	else
		if sName ~= "Unknown" and sClass and RAID_CLASS_COLORS[sClass] then
			return rgbhex(RAID_CLASS_COLORS[sClass])..sName.."|r"
		end
	end
	return colorWrap.charName(sName)
end

local function getCharNameColored(sName)
	local playerData = BagSyncDB[playerRealm][sName]
	if  playerData  then
		return getNameColor(sName, playerData.class)
	end
	return colorWrap.charName(sName)
end
--]]


local function getCharNameColored(charName, charClass)
	if   BagSyncOpt.enableUnitClass  then
		local charDB =  not charClass  and  RealmCharDB[charName]
		if  charDB  then  charClass = charDB.class  end
		
		local classColor = RAID_CLASS_COLORS[charClass]
		if  classColor  then  return rgbhex(classColor) .. charName .."|r"  end
	end
	local wrap =  charName == playerName  and  colorWrap.playerName  or  colorWrap.charName
	return wrap(charName)
	--return  wrap  and  wrap(charInfo.charName)  or  charInfo.charName
end


local function getCharInfoNameColored(charInfo)
	return getCharNameColored(charInfo.charName, charInfo.charDB.class)
end





local function CountBagItems(bagItems, searchData)
	if  type(bagItems) ~= 'table'  then  return 0  end
	local itemCount = 0
	
	--slotID = slot index in bag, itemData = "itemID,count" or "itemID" of item stored in slot
	for slotID, itemData in pairs(bagItems) do
		if  type(itemData) == 'string'  then
			local dbcount = MatchItemData(itemData, searchData)
			itemCount = itemCount + (dbcount or 0)
		end
	end
	return itemCount
end



local function CountStorageItems(storageDB, searchData)
	if  type(storageDB) ~= 'table'  then  return 0  end
	local itemCount = 0

	-- bagID = containerID (-1 .. 11) for bag and bank, bagItems = contents of specific bag with bagID
	for  bagID, bagItems  in pairs(storageDB) do
		if  type(bagItems) == 'table'  then
			itemCount = itemCount + CountBagItems(bagItems, searchData)
		elseif  type(bagItems) == 'string'  then
			-- Only an item
			local dbcount = MatchItemData(bagItems, searchData)
			itemCount = itemCount + (dbcount or 0)
		end
	end
	return itemCount
end



local function CountTabbedStorageItems(storageDB, searchData, tabCounts)
	if  type(storageDB) ~= 'table'  then  return 0  end
	local itemCount = 0
	local tabCounts = tabCounts or {}

	-- bagID = containerID (-1 .. 11) for bag and bank, bagItems = contents of specific bag with bagID
	for  tabID, tabItems  in pairs(storageDB) do
		if  type(tabItems) == 'table'  then
			-- A tab (bag)
			local tabCnt = CountBagItems(tabItems, searchData)
			tabCounts[tabID] = tabCnt
			itemCount = itemCount + tabCnt
		elseif  type(bagItems) == 'string'  then
			-- Only an item
			local dbcount = MatchItemData(bagItems, searchData)
			itemCount = itemCount + (dbcount or 0)
		end
	end
	return itemCount, tabCounts
end




local function QueryCharacterItemInfo(charName, charDB, searchData)
	local charInfo = { charName = charName, charDB = charDB }
	local total, storageCnt = 0, 0
	
	for  storageName, enabled  in pairs(storageEnabled) do  if  enabled  then
		local count = CountStorageItems(charDB[storageName], searchData)
		if  0 < count  then
			charInfo[storageName] = count
			total = total + count
			storageCnt = storageCnt + 1
		end
	end end
	
	charInfo.total = total
	if  1 < storageCnt  and  BagSyncOpt.showTotal  then  charInfo.showTotal = total  end
	return charInfo
end



local function QueryGuildItemInfo(guildName, searchData)
	if  not guildName  then  return nil  end
	--Debug("QueryGuildItemInfo(".. tostring(guildName) ..", ".. searchData ..")")
	
	-- See if guild was queried already by other character
	assert(guildsItemInfo, "Should not be called if  BagSyncOpt.enableGuild  is falsy")
	local guildInfo = guildsItemInfo[guildName]
	if  guildInfo  then  return guildInfo  end
	
	local guildDB =  RealmGuildDB  and  RealmGuildDB[guildName]
	if  not guildDB  then  return nil  end
	
	guildInfo = {
		-- Name of characters in guild
		charNames = {},
	}
	
	-- Guild order follows the order of the respective characters
	guildsItemInfo[#guildsItemInfo] = guildInfo
	guildsItemInfo[guildName] = guildInfo
	
	-- Do the counting
	guildInfo.total = CountTabbedStorageItems(guildDB, searchData, guildInfo)
	return guildInfo
end




local function GetCharacterInfoLine(charInfo)
	local str = {}
	-- Print list of storage counts
	for  i, storageName  in ipairs(storageOrder) do
		local count = charInfo[storageName]
		if  count  and  0 < count  then
			str[#str+1] = storageL[storageName]:format(count)
		end
	end
	local colorFunc =  charInfo.charName == playerName  and  colorWrap.playerCount  or  colorWrap.count
	local infoString = colorFunc( strjoin(', ', unpack(str)) )
	
	-- Print optional total and guild counts with custom color and without separating comma
	if  charInfo.showTotal  then  infoString = infoString.." "..storageL.showTotal:format(charInfo.showTotal)  end
	if  charInfo.showGuild  then  infoString = infoString.." "..storageL.showGuild:format(charInfo.showGuild)  end
	
	if  not infoString  or  infoString == ''  then  return nil  end

	local nameStr = getCharInfoNameColored(charInfo)
	--local nameStr = getCharNameColored(charInfo.charName, charInfo.charDB.class)
	return { nameStr, infoString }
end

--[[
local function CountsToInfoString(countTable)
	local total = 0
	local str = {}
	
	if countTable['bag'] > 0 then
		str[#str+1] = L["Bags: %d"]:format(countTable['bag'])
		total = total + countTable['bag']
	end

	if countTable['equip'] > 0 then
		str[#str+1] = L["Equipped: %d"]:format(countTable['equip'])
		total = total + countTable['equip']
	end

	if countTable['mailbox'] > 0 and BagSyncOpt.enableMailbox then
		str[#str+1] = L["Mailbox: %d"]:format(countTable['mailbox'])
		total = total + countTable['mailbox']
	end
	
	if countTable['auction'] > 0 and BagSyncOpt.enableAuction then
		str[#str+1] = L["AH: %d"]:format(countTable['auction'])
		total = total + countTable['auction']
	end
	
	if countTable['bank'] > 0 then
		str[#str+1] = L["Bank: %d"]:format(countTable['bank'])
		total = total + countTable['bank']
	end

	if countTable['void'] > 0 then
		str[#str+1] = L["Void: %d"]:format(countTable['void'])
		total = total + countTable['void']
	end
	
	-- Check to see if we show multiple items
	if  2 <= #str  then
		-- Show total count with different color
		str[#str+1] = colorWrap.total( L["All: %d"]:format(total) )
	end
	
	-- Add the guild count only if we don't have showGuildNames on, otherwise it's counted twice
	if countTable['guild'] > 0 and BagSyncOpt.enableGuild and not BagSyncOpt.showGuildNames then
		-- Show guild count separately with color of total count
		str[#str+1] = colorWrap.guild( L["Guild: %d"]:format(countTable['guild']) )
	end
	
	if  0 < #str  then
		return colorWrap.count( strjoin(', ', unpack(str)) )
	end
end
--]]





local function AddLinesToTooltip(tooltip, lineList)
	for  i, line  in ipairs(lineList) do
		tooltip:AddDoubleLine( unpack(line) )
	end
	tooltip:Show()
	return  0 < #lineList
end



--a function call to reset these local variables outside the scope ;)
function BagSync.resetTooltip()
	itemLines = {}
	lastQuery = nil
end


function BagSync.AddItemToTooltip(tooltip, link)
	BagSyncOpt = _G.BagSyncOpt
	if  not BagSyncOpt.enableTooltips  then  return false  end
	
	--if we can't convert the item link then lets just ignore it altogether
	local searchData = ToSearchData(link)
	if not searchData then  return  end
	
	--only show tooltips in search frame if the option is enabled
	if  BagSyncOpt.tooltipOnlySearch  then
		local ownerParent = tooltip:GetOwner()  and  tooltip:GetOwner():GetParent()
		if  ownerParent ~= BagSync_SearchFrame  then  return  end
	end
	
	-- Static references into the SavedVariables database for the current realm
	RealmCharDB      = BagSyncDB[playerRealm]
	--RealmTokenDB     = BagSyncTOKEN_DB[playerRealm]
	--RealmCraftDB     = BagSyncCRAFT_DB[playerRealm]
	RealmGuildDB     = BagSyncGUILD_DB[playerRealm]
	RealmBlacklistDB = BagSyncBLACKLIST_DB[playerRealm]


	-- Convert to itemID: searchData of items is stringified itemID
	local itemID =  tonumber(searchData)  or  searchData
	
	-- Do not ignore the hearthstone.
	--if  itemID == HEARTHSTONE_ITEM_ID  then  return BagSync.resetTooltip()  end
	-- Ignore blacklisted items
	if  RealmBlacklistDB[itemID]  then  return BagSync.resetTooltip()  end

	--lag check (check for previously displayed data) if so then display it
	if  lastQuery == searchData  then
		return AddLinesToTooltip(tooltip, itemLines)
	end

	-- Update enable flags
	storageEnabled.mailbox = BagSyncOpt.enableMailbox
	storageEnabled.auction = BagSyncOpt.enableAuction
	
	--reset our last displayed
	lastQuery = searchData
	itemLines = {}
	
	--check for seperator
	if BagSyncOpt.enableTooltipSeperator then
		itemLines[#itemLines+1] = { " ", " "}
	end
	
	------------------------------
	-- Count item on characters --
	------------------------------
	
	local charInfos = {}
	-- Query item count for other characters
	for  charName, charDB  in  pairs(RealmCharDB)  do
		if  charName == currentPlayer  and  BagSyncOpt.playerFirstLast  then
			-- Excluding currentPlayer now, adding later to top/bottom
		elseif  charDB.faction  and  charDB.faction ~= playerFaction  and  not BagSyncOpt.enableFaction  then
			-- Do not show other factions if not enabled
		else
			-- QueryCharacterItemInfo() might return nil if total == 0 and the character has no guild
			local charInfo = QueryCharacterItemInfo(charName, charDB, searchData)
			charInfos[#charInfos+1] = charInfo
		end
	end
 
	-- Sort other characters by total count, in decreasing order
	table.sort(charInfos, charInfoSortFunc)
	
	if  BagSyncOpt.playerFirstLast  then
		-- Add player character first or last
		local playerInfo = QueryCharacterItemInfo(currentPlayer, RealmCharDB[currentPlayer], searchData)
		
		if  BagSyncOpt.playerFirstLast == 'last'
		then  charInfos[#charInfos+1] = playerInfo
		else  table.insert(charInfos, 1, playerInfo)
		end
	end


	--------------------------
	-- Count item in guilds --
	--------------------------
	
	-- Reset guild info cache
	guildsItemInfo = BagSyncOpt.enableGuild  and  {}
	local guildTotal, guildNameCount, guildCount = 0, 0, 0
	
	-- Query count in guild banks, keep guilds in the same order as characters
	if  guildsItemInfo  then
		for  i, charInfo  in ipairs(charInfos) do
			-- Character is in a guild?
			local guildName = charInfo.charDB.guild
			local guildInfo = QueryGuildItemInfo(guildName, searchData)
			charInfo.guildInfo = guildInfo
			
			-- Add to name of characters in guild
			if  guildInfo  then
				table.insert(guildInfo.charNames, charInfo.charName)
				-- Guild count is shown on its own line if showGuildNames is on or more characters are in the same guild
				guildInfo.showOnChar =  not BagSyncOpt.showGuildNames  and  guildInfo.showOnChar == nil  and  charInfo  or  false
				-- showOnChar == false disables this option for later characters in this guild
			end
		end

		for  i, guildInfo  in ipairs(guildsItemInfo) do
			if  guildInfo.showOnChar  then
				guildInfo.showOnChar.showGuild = guildInfo.total
			else
				guildNameCount = guildNameCount + 1
			end
			guildTotal = guildTotal + guildInfo.total
			guildCount = guildCount + 1
		end
	end

	------------------------------
	-- Print the collected info --
	------------------------------
	
	-- Show characters
	local charTotal, charCount = 0, 0
	for  i, charInfo  in ipairs(charInfos) do  if  0 < charInfo.total  then
		itemLines[#itemLines+1] = GetCharacterInfoLine(charInfo)
		charTotal = charTotal + charInfo.total
		charCount = charCount + 1
	end end

	-- Show grand total if there are more than 1 characters displayed
	if  BagSyncOpt.showTotal  and  1 < charCount  then
		local charTotalStr = colorWrap.total(L["Total:"] .." ".. charTotal)
		if  1 < guildCount  and  0 == guildNameCount  then
			-- Show guildTotal on the same line ["Guild: %d"]
			local guildTotalStr = colorWrap.guild(format(L["Guild: %d"], guildTotal))
			itemLines[#itemLines+1] = { " ", charTotalStr .." ".. guildTotalStr }
		else
			itemLines[#itemLines+1] = { " ", charTotalStr }
			--itemLines[#itemLines+1] = { colorWrap.total(L["Total:"]) , colorWrap.total(charTotal) }
		end
	end
	
	-- Show guildnames last
	if  guildsItemInfo  then
		for  i, guildInfo  in ipairs(guildsItemInfo) do  if  0 < guildInfo.total  and  not guildInfo.showOnChar  then
			itemLines[#itemLines+1] = { colorWrap.guildName(guildName) , colorWrap.guild(guildInfo.total) }
		end end
	end
	
	----[[ Showing guild grand total is hardly useful: how often do you take all of a specific item from all the guilds you know?
	-- Show guild grand total if there are more than 1 guilds displayed
	if  BagSyncOpt.showTotal  and  1 < guildCount  and  0 < guildNameCount  then
		--local guildTotalStr = colorWrap.total( L["Guild total:"] .." ".. guildTotal ))
		local guildTotalStr = colorWrap.total( L["Guild total:"] .." ".. colorWrap.guild(guildTotal) )
		itemLines[#itemLines+1] = { " ", guildTotalStr }
	end
	--]]
	
	-- Release caches
	guildsItemInfo = nil

	--------------------------
	-- Print on the tooltip --
	--------------------------
	return AddLinesToTooltip(tooltip, itemLines)
end





function BagSync.AddCurrencyToTooltip(tooltip, currencyName)
	BagSyncOpt = _G.BagSyncOpt
	if  not BagSyncOpt.enableTooltips  then  return false  end
	
	RealmTokenDB     = BagSyncTOKEN_DB[playerRealm]
	local currencyDB = currencyName  and  RealmTokenDB  and  RealmTokenDB[currencyName]
	if  currencyDB  then
		if BagSyncOpt.enableTooltipSeperator then
			tooltip:AddLine(" ")
		end
		for charName, count in pairsByKeys(currencyDB) do
			if charName ~= "icon" and charName ~= "header" and count > 0 then
				tooltip:AddDoubleLine(getCharNameColored(charName), count)
			end
		end
	end
	tooltip:Show()
	return true
end





--simplified tooltip function, similar to the past HookTip that was used before Jan 06, 2011 (commit:a89046f844e24585ab8db60d10f2f168498b9af4)
--Honestly we aren't going to care about throttleing or anything like that anymore.  The lastdisplay array token should take care of that
--Special thanks to Tuller for tooltip hook function
local function hookTip(tooltip)
	local modified = false
	tooltip:HookScript('OnTooltipCleared', function(self)
		modified = false
	end)
	tooltip:HookScript('OnTooltipSetItem', function(self)
		local name, link = self:GetItem()
		modified = BagSync.AddItemToTooltip(self, link)
	end)
	hooksecurefunc(tooltip, 'SetCurrencyToken', function(self, index)
		modified = BagSync.AddCurrencyToTooltip( self, GetCurrencyListInfo(index) )
	end)
	hooksecurefunc(tooltip, 'SetCurrencyByID', function(self, id)
		modified = BagSync.AddCurrencyToTooltip( self, GetCurrencyInfo(id) )
  end)
	hooksecurefunc(tooltip, 'SetBackpackToken', function(self, index)
		modified = BagSync.AddCurrencyToTooltip( self, GetBackpackCurrencyInfo(index) )
	end)
end

local function hookPetTip()
	local modified = false
	-- BattlePetTooltipTemplate_SetBattlePet(BattlePetTooltip, BATTLE_PET_TOOLTIP);
	hooksecurefunc('BattlePetToolTip_Show', function (speciesID, level, breedQuality, maxHealth, power, speed, customName)
		modified = BagSync.AddItemToTooltip( BattlePetTooltip, "battlepet:"..speciesID )
	end)
end

hookTip(GameTooltip)
hookTip(ItemRefTooltip)
hookPetTip()


