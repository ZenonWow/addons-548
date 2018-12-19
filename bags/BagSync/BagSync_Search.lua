-- Addon private namespace
local ADDON_NAME, ns = ...
-- Addon global namespace
local BagSync = BagSync
-- Localization
local L = BAGSYNC_L
-- Imported from BagSync.lua
local Debug =  ns.Debug

local rows, anchor = {}
local currentRealm = GetRealmName()
local GetItemInfo = _G['GetItemInfo']
local playerName = UnitName('player')

local ItemSearch = LibStub('LibItemSearch-1.0')
local bgSearch = CreateFrame("Frame","BagSync_SearchFrame", UIParent)

--add class search
local tooltipScanner = _G['LibItemSearchTooltipScanner'] or CreateFrame('GameTooltip', 'LibItemSearchTooltipScanner', UIParent, 'GameTooltipTemplate')
local tooltipCache = setmetatable({}, {__index = function(t, k) local v = {} t[k] = v return v end})

ItemSearch:RegisterTypedSearch{
	id = 'classRestriction',
	tags = {'c', 'class'},
	
	canSearch = function(self, _, search)
		return search
	end,
	
	findItem = function(self, link, _, search)
		--if link:find("battlepet") then return false end
		--local itemID = link:match('item:(%d+)')
		
		-- Also handle battlepet: links
		local itemID = BagSync.ToItemData(link)
		if  not itemID  then  return  end
		
		local cachedResult = tooltipCache[search][itemID]
		if cachedResult ~= nil then
			return cachedResult
		end
		
		tooltipScanner:SetOwner(UIParent, 'ANCHOR_NONE')
		tooltipScanner:SetHyperlink(link)

		local result = false
		
		local pattern = string.gsub(ITEM_CLASSES_ALLOWED:lower(), "%%s", "(.+)")
		
		for i = 1, tooltipScanner:NumLines() do
			local text =  _G[tooltipScanner:GetName() .. 'TextLeft' .. i]:GetText():lower()
			textChk = string.find(text, pattern)

			if textChk and tostring(text):find(search) then
				result = true
			end
		end
		
		tooltipCache[search][itemID] = result
		return result
	end,
}



local searchTable = {}
local searchStr
local searchStorageName
local tempList = {}
local previousGuilds = {}
--local count = 0



local function LoadSlider()

	local function OnEnter(self)
		if self.link then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:SetHyperlink(self.link)
			GameTooltip:Show()
		end
	end
	local function OnLeave() GameTooltip:Hide() end

	local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 20, 2, 4
	local FRAME_HEIGHT = bgSearch:GetHeight() - 60
	local SCROLL_TOP_POSITION = -90
	local totalRows = math.floor((FRAME_HEIGHT-22)/(ROWHEIGHT + ROWGAP))
	
	for i=1, totalRows do
		if not rows[i] then
			local row = CreateFrame("Button", "BagSyncSearchRow"..i, bgSearch)
			if not anchor then row:SetPoint("BOTTOMLEFT", bgSearch, "TOPLEFT", 0, SCROLL_TOP_POSITION)
			else row:SetPoint("TOP", anchor, "BOTTOM", 0, -ROWGAP) end
			row:SetPoint("LEFT", EDGEGAP, 0)
			row:SetPoint("RIGHT", -EDGEGAP*2-8, 0)
			row:SetHeight(ROWHEIGHT)
			row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			anchor = row
			rows[i] = row

			local title = row:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
			title:SetPoint("LEFT")
			title:SetJustifyH("LEFT") 
			title:SetWidth(row:GetWidth())
			title:SetHeight(ROWHEIGHT)
			row.title = title

			row:SetScript("OnEnter", OnEnter)
			row:SetScript("OnLeave", OnLeave)
			row:SetScript("OnClick", function(self)
				if self.link then
					if HandleModifiedItemClick(self.link) then
						return
					end
					if IsModifiedClick("CHATLINK") then
						local editBox = ChatEdit_ChooseBoxForSend()
						if editBox then
							editBox:Insert(self.link)
							ChatFrame_OpenChat(editBox:GetText())
						end
					end
				end
			end)
		end
	end

	local offset = 0
	local RefreshSearch = function()
		if not BagSync_SearchFrame:IsVisible() then return end
		for i,row in ipairs(rows) do
			if (i + offset) <= #searchTable then
				if searchTable[i + offset] then
					if searchTable[i + offset].rarity then
						--local hex = (select(4, GetItemQualityColor(searchTable[i + offset].rarity)))
						local hex = (select(4, GetItemQualityColor(searchTable[i + offset].rarity)))
						row.title:SetText(format('|c%s%s|r', hex, searchTable[i + offset].name) or searchTable[i + offset].name)
					else
						row.title:SetText(searchTable[i + offset].name)
					end
					row.link = searchTable[i + offset].link
					row:Show()
				end
			else
				row.title:SetText(nil)
				row:Hide()
			end
		end
	end

	RefreshSearch()

	if not bgSearch.scrollbar then
		bgSearch.scrollbar = LibStub("tekKonfig-Scroll").new(bgSearch, nil, #rows/2)
		bgSearch.scrollbar:ClearAllPoints()
		bgSearch.scrollbar:SetPoint("TOP", rows[1], 0, -16)
		bgSearch.scrollbar:SetPoint("BOTTOM", rows[#rows], 0, 16)
		bgSearch.scrollbar:SetPoint("RIGHT", -16, 0)
	end
	
	if #searchTable > 0 then
		bgSearch.scrollbar:SetMinMaxValues(0, math.max(0, #searchTable - #rows))
		bgSearch.scrollbar:SetValue(0)
		bgSearch.scrollbar:Show()
	else
		bgSearch.scrollbar:Hide()
	end
	
	local f = bgSearch.scrollbar:GetScript("OnValueChanged")
		bgSearch.scrollbar:SetScript("OnValueChanged", function(self, value, ...)
		offset = math.floor(value)
		RefreshSearch()
		return f(self, value, ...)
	end)

	bgSearch:EnableMouseWheel()
	bgSearch:SetScript("OnMouseWheel", function(self, val)
		bgSearch.scrollbar:SetValue(bgSearch.scrollbar:GetValue() - val*#rows/2)
	end)
end



local function SearchBag(bagItems)
	-- q = storageName, r = storageDB
	for slotID, itemData in pairs(bagItems) do
		local linkType, ID, dbcount, dblink = ParseItemData(itemData)
		if  dblink  and  not tempList[dblink]  then
			local dName, dItemLink, dRarity = GetItemInfo(dblink)
			if  not dItemLink  then
			elseif  searchStorageName  or  ItemSearch:Find(dItemLink, searchStr)  then
				table.insert(searchTable, { name=dName, link=dItemLink, rarity=dRarity } )
				tempList[dblink] = dName
				--count = count + 1
			end
		end
	end
end

local function SearchStorage(storageDB)
	--if  type(storageDB[0]) ~= 'table'  then  return SearchBag(storageDB)  end

	--bagID = bag name bagID, bagItems = data of specific bag with bagID
	for  bagID, bagItems  in pairs(storageDB) do
		--slotID = slotid for specific bagid, itemValue = data of specific slotid
		if  type(bagItems) == "table"  then
			SearchBag(bagItems)
		end
	end
end

local function DoSearch()
	if not BagSync or not BagSyncDB then return end
	
	-- Search query
	searchStr = bgSearch.SEARCHBTN:GetText()
	searchStr = searchStr:lower()
	-- Don't search on empty stomach
	if  0 == searchStr:len()  then  return  end
	
	
	-- Empty result table
	searchTable = {}
	
	-- Reset search state
	tempList = {}
	previousGuilds = {}
	--count = 0
	
	local allowList = {
		["bag"] = 0,
		["bank"] = 0,
		["equip"] = 0,
		["mailbox"] = 0,
		["void"] = 0,
		["auction"] = 0,
		["guild"] = 0,
	}
	
	-- Static references into the SavedVariables database for the current realm
	RealmCharDB      = BagSyncDB[playerRealm]
	--RealmTokenDB     = BagSyncTOKEN_DB[playerRealm]
	--RealmCraftDB     = BagSyncCRAFT_DB[playerRealm]
	RealmGuildDB     = BagSyncGUILD_DB[playerRealm]
	RealmBlacklistDB = BagSyncBLACKLIST_DB[playerRealm]
	
	
	searchStorageName =  searchStr[1] == "@"  and  searchStr:sub(2)
	if  not allowList[searchStorageName]  then  searchStorageName = nil  end
	
	if  searchStorageName  then
		-- List a specific storage
		SearchStorage(RealmCharDB[playerName][searchStorageName])
	else
		
		local playerFaction = UnitFactionGroup('player')
		
		--loop through our characters
		--k = player, v = stored data for player
		for  charName, charDB  in  pairs(RealmCharDB)  do
			if  charDB.faction  and  charDB.faction ~= playerFaction  and  not BagSyncOpt.enableFaction  then
				-- Do not show other factions if not enabled
				-- If we dont know the faction yet display it anyways
			else
				--now count the stuff for the user
				-- q = storageName, r = storageDB
				for storageName, storageDB in pairs(charDB) do
					--only loop through table items we want
					if allowList[storageName] and type(storageDB) == 'table' then
						SearchStorage(storageDB)
					end
				end
			end
		end
				
		if  true  or  BagSyncOpt.enableGuild  and  RealmGuildDB  then
			for  guildName, guildDB  in  pairs(RealmGuildDB)  do
				if  type(guildDB[0]) == 'table'  then
					SearchStorage(guildDB)
				else
					SearchBag(guildDB)
				end
				previousGuilds[guildName] = true
			end
		end
		
		table.sort(searchTable, function(a,b) return (a.name < b.name) end)
	end
	
	bgSearch.totalC:SetText("|cFFFFFFFF"..L["Total:"].." "..#searchTable.."|r")
	
	LoadSlider()
end

local function escapeEditBox(self)
  self:SetAutoFocus(false)
end

local function enterEditBox(self)
	self:ClearFocus()
	--self:GetParent():DoSearch()
	DoSearch()
end

local function createEditBox(name, labeltext, obj, x, y)
  local editbox = CreateFrame("EditBox", name, obj, "InputBoxTemplate")
  editbox:SetAutoFocus(false)
  editbox:SetWidth(180)
  editbox:SetHeight(16)
  editbox:SetPoint("TOPLEFT", obj, "TOPLEFT", x or 0, y or 0)
  local label = editbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  label:SetPoint("BOTTOMLEFT", editbox, "TOPLEFT", -6, 4)
  label:SetText(labeltext)
  editbox:SetScript("OnEnterPressed", enterEditBox)
  editbox:HookScript("OnEscapePressed", escapeEditBox)
  return editbox
end

bgSearch:SetFrameStrata("HIGH")
bgSearch:SetToplevel(true)
bgSearch:EnableMouse(true)
bgSearch:SetMovable(true)
bgSearch:SetClampedToScreen(true)
bgSearch:SetWidth(380)
bgSearch:SetHeight(500)

bgSearch:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 32,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

bgSearch:SetBackdropColor(0,0,0,1)
bgSearch:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

bgSearch.SEARCHBTN = createEditBox("$parentEdit1", (L["Search"]..":"), bgSearch, 60, -50)

local addonTitle = bgSearch:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
addonTitle:SetPoint("CENTER", bgSearch, "TOP", 0, -20)
addonTitle:SetText("|cFF99CC33BagSync|r |cFFFFFFFF("..L["Search"]..")|r")

local totalC = bgSearch:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
totalC:SetPoint("RIGHT", bgSearch.SEARCHBTN, 70, 0)
totalC:SetText("|cFFFFFFFF"..L["Total:"].." 0|r")
bgSearch.totalC = totalC
		
local closeButton = CreateFrame("Button", nil, bgSearch, "UIPanelCloseButton");
closeButton:SetPoint("TOPRIGHT", bgSearch, -15, -8);

bgSearch:SetScript("OnShow", function(self)
	LoadSlider()
	self.SEARCHBTN:SetFocus()
end)
bgSearch:SetScript("OnHide", function(self)
	searchTable = {}
	self.SEARCHBTN:SetText("")
	self.totalC:SetText("|cFFFFFFFF"..L["Total:"].." 0|r")
end)

bgSearch:SetScript("OnMouseDown", function(frame, button)
	if frame:IsMovable() then
		frame.isMoving = true
		frame:StartMoving()
	end
end)

bgSearch:SetScript("OnMouseUp", function(frame, button) 
	if( frame.isMoving ) then
		frame.isMoving = nil
		frame:StopMovingOrSizing()
	end
end)

function bgSearch:initSearch()
	DoSearch()
end

bgSearch:Hide()
