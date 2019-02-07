--[[
/run BlackMarketFrame_Show()
/run BlackMarketFrame:Show()
/run BlackMarketFrame:SetPoint('TOPLEFT',100,100)
/dump BlackMarketFrame:GetRect()
/run BlackMarketFrame.BidButton:Enable()
/run BMT.Uninstall()
/run BMT:Disable()
/run BMT.Install()
/dump C_BlackMarket.GetNumItems_()
/vdt BlackMarketTrackerAuctionData
/dump BMT.currentItems
/dump BMT.filteredItems
/run BlackMarketTrackerAuctionData.showCompletedForMinutes = 50
/dump HybridScrollFrame_GetOffset(BlackMarketScrollFrame)
/run BlackMarketTrackerAuctionData = {}

/run BlackMarketFrame:SetSize(660,300)  -- -230,-400+56
/run BlackMarketFrame:SetSize(660,700)  -- -230,+56

/run C_BlackMarket.RequestItems()
/dump C_BlackMarket.GetNumItems()
/run BlackMarketScrollFrame_Update()
/dump BlackMarketFrame.selectedMarketID
/dump C_BlackMarket.GetItemInfoByIndex(0)
/run BlackMarketFrame.HotDeal:Hide()
/run C_BlackMarket.ItemPlaceBid(BlackMarketFrame.selectedMarketID, 9523810000)

/run BlackMarketFrameBidButton= BlackMarketFrame.BidButton
/run MoneyInputFrame_SetCopper(BlackMarketBidPrice, 200000)
/click BlackMarketFrameBidButton
/click StaticPopup1Button1

/run BlackMarketFrame:SetSize(660,560);BlackMarketFrame.Inset:SetSize(578,352);BlackMarketScrollFrame:SetSize(345,450)
/dump BlackMarketFrame.Inset:GetSize()  -- 608,408  -282,-96
/dump BlackMarketFrame:GetSize()  -- 890,504
/dump BlackMarketScrollFrame:GetSize()  -- 575,394  -33,-14
/dump BlackMarketFrame.TopLeftCorner:GetSize()  -- 32,32
/run a= BlackMarketFrame.TopLeftCorner:GetPoint('TOPLEFT')  -- 32,32
/dump a:GetCoord()
/run BlackMarketFrame.Inset:SetSize(578,352)
/run BlackMarketFrame.Inset:SetPoint('TOPLEFT',BlackMarketFrame,26,-70)
/run BlackMarketFrame.Inset:SetPoint('BOTTOMRIGHT',BlackMarketFrame,-26,22)
/run BlackMarketFrame.Inset:SetPoint('TOPRIGHT',BlackMarketFrame.ColumnCurrentBid,'BOTTOMRIGHT',26,0)
/run BlackMarketFrame.Inset:SetPoint('BOTTOMRIGHT',BlackMarketFrame.ColumnCurrentBid,'BOTTOMRIGHT',26,0)
/run BlackMarketFrame.Inset:Hide()
/run BlackMarketScrollFrame:SetSize(345,480)
/run BlackMarketScrollFrame:SetAllPoints()
/run BlackMarketScrollFrame:SetPoint("TOPLEFT", 20, -100)
TopLeftCorner.TOPLEFT -6,+1
ColumnName TopLeftCorner.BOTTOMLEFT(26,33) y=-20 y+=19 (6,52)
			<Frame parentKey="Inset" inherits="InsetFrameTemplate2">
					<Anchor point="TOPLEFT" relativeKey="$parent.ColumnName" relativePoint="BOTTOMLEFT" x="0" y="0"/>
					<Anchor point="BOTTOMRIGHT" relativeKey="$parent.ColumnCurrentBid" relativePoint="BOTTOMRIGHT" x="26" y="-408"/>
			<ScrollFrame name="BlackMarketScrollFrame" inherits="MinimalHybridScrollFrameTemplate">
					<Anchor point="TOPLEFT" relativeKey="$parent.Inset" x="6" y="-7"/>
					<Anchor point="BOTTOMRIGHT" relativeKey="$parent.Inset" relativePoint="BOTTOMRIGHT" x="-27" y="7"/>
/dump BlackMarketScrollFrame:GetSize()
/dump BlackMarketScrollFrame:GetParent():GetName()
/run BlackMarketFrame:SetSize(660,560);BlackMarketFrame.Inset:SetSize(578,352);BlackMarketScrollFrame:SetSize(345,450)

/run  BMT.currentItems[1].data.from = BMT.currentItems.updatedTime + 24*60*60 - 15*60
/run  BMT.currentItems[1].data.from = BMT.currentItems[1].data.from +2*60 - 10
--]]



BINDING_NAME_TOGGLEBLACKMARKET        = "Toggle Black Market"
-- "Show/hide the Black Market without updating auctions"

LOADING_DATA = "<Loading item data>"



-- Main object

local BMT = CreateFrame('Frame')
_G.BlackMarketTracker = BMT

BMT.lastRequest = 0
BMT.lastUpdate = 0
-- BMT.filteredItems = nil
-- BMT.newestItem

-- Initialized in BMT:Enable()
local BlackMarketTrackerAuctionData



function  ToggleBlackMarket()
	-- Called by TOGGLEBLACKMARKET binding
	if  not BlackMarketFrame  then  BlackMarket_LoadUI()  end
	if  not BlackMarketFrame  then  return false  end
	BMT:Enable()
	-- If not interacting with the bmah npc (offline) then C_BlackMarket.GetNumItems_() returns nil
	if  not BMT.atNpc  and  C_BlackMarket.GetNumItems_()  then  BMT.atNpc = true  end
	ToggleFrame(BlackMarketFrame)  -- Uses secure code if necessary.
	--BlackMarketFrame_Show()
end





-- Logging and debugging functions
local function Log(...)  DEFAULT_CHAT_FRAME:AddMessage(...)  end
--local LogVar= ViragDevTool_AddData
----[[
local function LogVar(obj,name)
  if  ViragDevTool_AddData  then  ViragDevTool_AddData(obj,name)  end
end
--]]


-- Debug(...) messages
function Debug(...)  if  BMT.logFrame  then  BMT.logFrame:AddMessage( string.join(", ", tostringall(...)) )  end end
BMT.logFrame = tekDebug  and  tekDebug:GetFrame("BlackMarketTracker")
function BMT.Debug(enable)  BMT.logFrame =  enable  and  (tekDebug  and  tekDebug:GetFrame("BagSync")  or  DEFAULT_CHAT_FRAME)  end





-- Serialize a table and tables in it up to provided depth (default: 1)
-- Go to infinite depth: -1
local function  tableToString(values, separator, depth)
	separator= separator or ', '
	depth= depth or 1
	if  depth == 0  or  type(values) ~= 'table'  then  return tostring(values)  end
	local joined= ''
	for  k,v  in  pairs(values)  do
		joined= i ~= 0  and  joined .. separator  or  ''
		joined= joined .. k .. '= ' .. tableToString(v, separator, depth - 1)
	end
	return joined
end

-- Serialize an array and tables in it up to provided depth (default: 1)
-- Go to infinite depth: -1
local function  arrayToString(values, separator, depth)
	separator= separator or ', '
	depth= depth or 1
	if  depth == 0  or  type(values) ~= 'table'  then  return tostring(values)  end
	local joined= ''
	for  i,v  in  ipairs(values)  do
		joined= i ~= 0  and  joined .. separator  or  ''
		joined= joined .. tableToString(v, separator, depth - 1)
	end
	return joined
end





local hourSeconds = 60*60
local daySeconds = 24*hourSeconds
local nowSeconds, nowDays

local function getDayText(t)
	local daysLater =  math.floor( (t - nowSeconds + 12*hourSeconds) / daySeconds )
	-- If more than half day later:
	if  1 == daysLater  then  return  '+d.'
	elseif  1 < daysLater  then  return  '+'.. daysLater ..'d.'
  end
	return  ''
	--[[
	local thatDay = math.floor(t / daySeconds)
	local daysLater = thatDay - nowDays
	if  daysLater == 0  then  return ''  end
	local daysText = tostring(daysLater) ..'d,'
	--return  0 < daysLater  and  '+'..daysText  or  daysText
	return  daysText
	--]]
end

function BMT.getTimeFrameText(data, nowSeconds)
	return  getDayText(data.from, nowSeconds) .. date('%H:%M:%S', data.from) ..'<\n<'.. getDayText(data.to, nowSeconds) .. date('%H:%M:%S', data.to)
end


function BMT.calcTimeFrame(timeLeft)
	local hourSeconds = 60*60
	local from, to, short
	if  timeLeft == 0  then
		to = nowSeconds
		short = 'Done'
	elseif  timeLeft == 1  then
		from = nowSeconds
		to = nowSeconds + hourSeconds/2
		short = '<30m'
	elseif  timeLeft == 2  then
		from = nowSeconds + hourSeconds/2
		to = nowSeconds + 2*hourSeconds
		short = '30m-2h'
	elseif  timeLeft == 3  then
		from = nowSeconds + 2*hourSeconds
		to = nowSeconds + 12*hourSeconds
		short = '2h-12h'
	elseif  timeLeft == 4  then
		from = nowSeconds + 12*hourSeconds
		to = nowSeconds + 24*hourSeconds
		short = '12h-24h'
	else
		from = nowSeconds
		to = nowSeconds + 24*hourSeconds
		short = timeLeft
		ChatFrame1:AddMessage('BMT:calcTimeFrame(): unknown timeLeft value = '.. timeLeft)
	end
	return  from, to, short
end


function BMT:UpdateItem(item)
	--[[
	local name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement,
		currBid, youHaveHighBid, numBids, timeLeft, link, marketID = unpack(item)
	--]]
	local items = self.currentItems
	local currBid = item[11]
	local numBids = item[13]
	local timeLeft = item[14]
	local itemLink = item[15]
	local marketID = item[16]
	
	local index
	for  j = 1,#items  do
		if  items[j][16] == marketID  then  index = j ; break  end
	end
	
	local oldItem = index and items[index]
	local data = oldItem and oldItem.data
	
	-- Skip zeroed-out item received when data is not available yet (new auction / first opening blackmarket)
	--if  not itemLink  then  return  end
	if  not itemLink  or  itemLink == ''  then
		if  index  then  items[index].exists = true  end
		self.incompleteQuery = true
		--[[
		Log('Empty auction data: '.. tableToString(item))
		LogVar(item, marketID)
		--]]
		return
	end

	-- If the item is different then make a new auction entry
	-- Won't happen, each marketID seems to sell exactly one item allways
	if  oldItem  and  oldItem[15] ~=  itemLink  then  index = nil ; oldItem = nil ; data = nil  end
	
	-- Detect finished or repeated auction
	if  data  and  not data.completed  then
		if  0 == timeLeft  then
			Log('Completed: '.. tableToString(item))
			LogVar(item, marketID)
			data.completed = nowSeconds
			data.timeFrame = 'Completed at '.. date('%m-%d %H:%M:%S', data.completed)
		elseif  currBid < oldItem[11]  or  numBids < oldItem[13]  then
			Log('Found repeated: '.. tableToString(item))
			LogVar(item, marketID)
			data.completed = nowSeconds
			data.timeFrame = 'Repeated before '.. date('%m-%d %H:%M:%S', data.completed)
		end
	end
	
	if  0 < timeLeft  then
		local from, to, short = self.calcTimeFrame(timeLeft)
		if  data  and  data.completed  then
			-- Found previous completed auction of same item, ignore it
			index = nil ; oldItem = nil ; data = nil
		end

		if  data  then
			if  from  then  data.from = math.max(data.from, from)  end
			if  to  then  data.to = math.min(data.to, to)  end
		else
			if  timeLeft == 4  and  items.updatedTime  then  from = math.max(from, items.updatedTime + 24*hourSeconds)  end
			data = { firstSeen = nowSeconds, from = from, to = to }
		end
		item.data = data
		
		
		
		-- time frame when auction is expected to complete
		data.timeFrame = self.getTimeFrameText(data, nowSeconds)
		--item[14] = data.timeFrame
	end
	
	-- mark still existing auctions
	item.exists = true
	
	-- show marketID in seller column
	--item[8] = 'id: '.. item[16]
	
	-- update only at the end to retain old data in case of error
	if  index  then
		items[index] = item
	else
		self.newestItem = item
		table.insert(items, self.newIndex, item)
		index = self.newIndex
		newIndex = self.newIndex + 1
	end
end


function BMT:FilterItem(item)
	local data = item.data
	
	if  self.incompleteQuery  or  not data  then
		if  item[1] == 'Blood-Soaked Invitation'  then
			-- Skip invitations
		else
			table.insert(self.filteredItems, item)
		end
		return
	end
	
	if  not item.exists  and  not data.completed  then
		-- Save time of completion
		item[14] = 0  -- time left column: Completed
		data.completed = nowSeconds
		data.timeFrame = 'Unseen at '.. date('%m-%d %H:%M:%S', data.completed)
	else
		-- Remove flag
		item.exists = nil
	end
	
	if  item[1] == 'Blood-Soaked Invitation'  then
		-- Skip invitations
		if  data.completed  then
			-- Forget if completed
			return  true
		end
	elseif  data.completed  and  (nowSeconds - data.completed > BlackMarketTrackerAuctionData.showCompletedForMinutes * 60)  then
		-- Archive if completed more than 10 minutes ago
		BlackMarketTrackerArchive = BlackMarketTrackerArchive or {}
		table.insert(BlackMarketTrackerArchive, item)
		return  true
	else
		table.insert(self.filteredItems, item)
	end
end


--[[
93227 [Blood-Soaked Invitation]  (Horde)
93194 [Blood-Soaked Invitation]  (Alliance)
/run BlackMarketTrackerAuctionData={}
/run local d=BlackMarketTrackerAuctionData; for i=1,#d do d[i].data=nil end
--]]
function BMT:UpdateItems()
	--ChatFrame1:AddMessage('BMT:UpdateItems()')
	-- nowSeconds, nowDays declared local at top of file
	nowSeconds = time()
	nowDays = math.floor(nowSeconds / daySeconds)
	
	self.newIndex = 1
	
	local realmName = GetRealmName()
	local items = BlackMarketTrackerAuctionData[realmName]
	if  not items  then
		items = {}
		BlackMarketTrackerAuctionData[realmName] = items
	end
	self.currentItems = items
	
	local num = C_BlackMarket.GetNumItems_()
	if  not num  then
		self.incompleteQuery = 'closed'
	else
		self.incompleteQuery = nil
		for  i = 1,num  do
			local item = { C_BlackMarket.GetItemInfoByIndex_(i) }
			self:UpdateItem(item)
			--[[
			local name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement,
				currBid, youHaveHighBid, numBids, timeLeft, link, marketID = C_BlackMarket.GetHotItem();
			--]]
		end
	end
	
	self.filteredItems = {}
	local i = 0
	while i < #items  do
		i = i + 1
		if  self:FilterItem(items[i])  then
			table.remove(self.currentItems, i)
			i = i - 1
		end
	end
	
	if  not self.incompleteQuery  then
		items.updatedTime = nowSeconds
		items.updated = date('%Y-%m-%d %H:%M:%S', nowSeconds)
	end
	
	-- Drop soon-to-become-outdated timestamp
	nowSeconds = nil
	nowDays = nil
end




-- Patched update function
function BMT.ScrollFrame_Update_0()
	local offset, offsetReal = HybridScrollFrame_GetOffset(BlackMarketScrollFrame)
	if  0 < offset  then  return  end
	
	BlackMarketScrollFrame.update_()
	--ChatFrame1:AddMessage('BMT.ScrollFrame_Update() offset='.. offset)
	local buttons = BlackMarketScrollFrame.buttons
	local items = BMT.filteredItems
	for  i = 1,#buttons  do
		local item = items[i + offset]
		local button = buttons[i];
		if  item  then
			-- Show end time frame in time left column
			button.TimeLeft.Text:SetText(button.TimeLeft.Text:GetText() ..' \n '.. item.data.timeFrame)
			-- Show marketID in seller column
			button.Seller:SetText(button.Seller:GetText() ..' \n Id='.. item[16])
		end
	end
	HybridScrollFrame_SetOffset(BlackMarketScrollFrame, offsetReal)
end


BMT.colors = {
	timeLeft = { [0]='|cffbeb9b5', '|cffff0000', '|cffc0ff00', '|cff00ff00', '|cff2020ff' },
	marketID  = '|cff00ff00',
	itemID    = '|cffffff80',
	itemLevel = '|cffffff80',
	gray = '|cffbeb9b5',
}




function BMT:BLACK_MARKET_OPEN()
	-- Called when interacting with BM npc
	if  IsAltKeyDown()  then  self:Disable()  else  self:Enable()  end
	
	-- Save BM npc name for InteractUnit() hook
	self.atNpc = UnitName('npc') or true
	self.lastUpdate = self.lastUpdate  or  0
	self.RequestItems()
	--BlackMarketFrame:SetScript('OnUpdate', self.OnUpdate)
	self:Show()    -- enable BMT:OnUpdate()
	ShowUIPanel(BlackMarketFrame)
	--if  not BlackMarketFrame:IsShown()  then  C_BlackMarket.Close()  end
	--PlaySound("AuctionWindowOpen")
end

function BMT:BLACK_MARKET_CLOSE()
	-- Called when BM npc is left
	self.atNpc = false
	-- Sound the bell if it was scanning in the background
	if  not BlackMarketFrame:IsShown()  then  PlaySound("AuctionWindowClose")  end
	HideUIPanel(BlackMarketFrame)
	--BlackMarketFrame:SetScript('OnUpdate', nil)
	self:Hide()    -- disable BMT:OnUpdate()
end

function BMT:OnEvent(event, ...)
	if  self[event]  then  return self[event](self, event, ...)  end
end
	
function BMT:OnUpdate(elapsed)
	local nowSecondsFloat = GetTime()
	if  2 <= nowSecondsFloat - (BMT.lastRequest or 0)  then
		if  not BMT.atNpc  then
			-- Should have hidden the frame. No update if not interacting with npc.
			print('BMT.OnUpdate() when not at npc')
			self:Hide()
		end
		BMT.RequestItems()
	elseif  BMT.incompleteQuery == true  and  0.5 <= nowSecondsFloat - (BMT.lastUpdate or 0)  then
		-- BMT.incompleteQuery == 'closed' <-> if C_BlackMarket.GetNumItems_() == nil <-> not BMT.atNpc
		BMT.lastUpdate = nowSecondsFloat
		-- Let's see if some unloaded data has arrived
		BMT.ScrollFrame_Update()
	end
end




-- Patched update function
local lastNumItems = 0

function BMT.ScrollFrame_Update()
	-- Update the items database even in the background (if hidden)
	if  not BMT.filteredItems  then  BMT:UpdateItems()  end
	-- Tho no need to update the frame until it's visible
	if  not BlackMarketScrollFrame:IsVisible()  then  return false  end
	
	local items = BMT.filteredItems
	if  not items  then  return false  end
	
	local numItems = #items
	--local numItems = C_BlackMarket.GetNumItems();
	
	local offset, offsetReal = HybridScrollFrame_GetOffset(BlackMarketScrollFrame)
	local buttons = BlackMarketScrollFrame.buttons;
	local numButtons = #buttons;
	local colors = BMT.colors

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index

		if ( index <= numItems ) then
			local item = items[index]
			--local name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement,
				currBid, youHaveHighBid, numBids, timeLeft, link, marketID = C_BlackMarket.GetItemInfoByIndex(index);
			local name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement,
				currBid, youHaveHighBid, numBids, timeLeft, link, marketID = unpack(item)
			
			if ( marketID ) then
				button.Name:SetText(name or LOADING_DATA);
				
				button.Item.IconTexture:SetTexture(texture)
				if ( not usable ) then
					button.Item.IconTexture:SetVertexColor(1.0, 0.1, 0.1);
				else
					button.Item.IconTexture:SetVertexColor(1.0, 1.0, 1.0);
				end

				button.Item.Count:SetText(quantity or "");
				button.Item.Count:SetShown(quantity and quantity > 1);
			end
			
			if  link  then
				-- |cffa335ee|Hitem:87144:0:0:0:0:0:0:0:90:0:445|h[Regail's Band of the Endless]|h|r
				local itemID = link:match('|Hitem:(%d*):%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*')
				local _,_,_,itemLevel,reqLevel,armorType,armorClass,_,armorSlot,iconPath,maybe_useSpellId = GetItemInfo(link)
				--itemType = itemType  and  itemType..'\n'  or  ''
				itemID = itemID  or  '?'
				button.Type:SetText('item='.. colors.itemID .. itemID ..'|r\n'..itemType);
				
				sellerName = sellerName or ''
				-- Show marketID, itemID in seller column
				--button.Seller:SetText(sellerName ..' #'.. colors.marketID .. marketID ..'|r \n item='.. colors.itemID .. itemID .. '|r')
				--button.Seller:SetText(sellerName ..' \n item='.. colors.itemID .. itemID .. '|r')
				marketID = marketID  or  '?'
				button.Seller:SetText('#'.. colors.marketID .. marketID ..'|r '.. sellerName)
				--button.Seller.tooltip = 'item='.. itemID ..' \n marketID='.. marketID
				
				level = level  or  '?'
				if  itemLevel  then  level = level ..'\n'.. colors.itemLevel .. itemLevel ..'|r'  end
				--level = level ..'\n item='.. colors.itemID .. itemID ..'|r'
				button.Level:SetText(level);
			end

			if  currBid  and  minIncrement  then
				local bidAmount = currBid;
				local minNextBid = currBid + minIncrement;
				if ( currBid == 0 ) then
					bidAmount = minBid;
					minNextBid = minBid;
				end
				MoneyFrame_Update(button.CurrentBid, bidAmount);
				
				button.minNextBid = minNextBid;
				button.youHaveHighBid = youHaveHighBid;
				button.YourBid:SetShown(youHaveHighBid);
			end
			
			if  timeLeft  then
				button.auctionCompleate = (timeLeft == 0);
				-- Show end time frame in time left column
				button.TimeLeft.Text:SetText(colors.timeLeft[timeLeft] .. _G["AUCTION_TIME_LEFT"..timeLeft] .."|r \n ".. (item.data and item.data.timeFrame or "") )
				button.TimeLeft.tooltip = _G["AUCTION_TIME_LEFT"..timeLeft.."_DETAIL"];
			end
			
			if  marketID  then
				button.itemLink = link;
				button.marketID = marketID;
				if ( marketID == BlackMarketFrame.selectedMarketID ) then
					button.Selection:Show();
				else
					button.Selection:Hide();
				end

				button:Show();
			else
				button:Hide()
			end
		else
			button:Hide();
		end
	end
	
	local totalHeight = numItems * BlackMarketScrollFrame.buttonHeight;
	local displayedHeight = numButtons * BlackMarketScrollFrame.buttonHeight;
	HybridScrollFrame_Update(BlackMarketScrollFrame, totalHeight, displayedHeight);
	--HybridScrollFrame_SetOffset(BlackMarketScrollFrame, offsetReal)
end




function BMT.BlackMarketFrame_Resize()
	BlackMarketFrame:SetSize(660,600)
	BlackMarketFrame.Inset:SetPoint('TOPLEFT',BlackMarketFrame,26,-70)
	BlackMarketFrame.Inset:SetPoint('BOTTOMRIGHT',BlackMarketFrame,-26,22)
	--BlackMarketFrame.Inset:SetSize(578,352)
	--BlackMarketFrame.Inset:SetPoint('BOTTOMRIGHT',nil)
	--BlackMarketFrame.Inset:SetPoint('BOTTOMLEFT',nil)
	--BlackMarketScrollFrame:SetSize(345,450)
	--[[
	BlackMarketItemTemplate:SetHeight(44)
	BlackMarketItemTemplate.TimeLeft:SetSize(150,42)
	BlackMarketItemTemplate.TimeLeft:SetWidth(150)
	--]]
	HybridScrollFrame_CreateButtons(BlackMarketScrollFrame, "BlackMarketItemTemplate2", 0, 0)
end


function BMT.BlackMarketFrame_OnShow(BlackMarketFrame)
	HybridScrollFrame_CreateButtons(BlackMarketScrollFrame, "BlackMarketItemTemplate", 5, -5)
	BlackMarketFrame.HotDeal:Hide()
	MoneyInputFrame_SetCopper(BlackMarketBidPrice, 0)
	BlackMarketFrame.BidButton:Disable()
	--PlaySound("AuctionWindowOpen")
	
	if  not BMT.atNpc  then
		-- When offline the list is only updated this once.
		BMT.ScrollFrame_Update()
	else
		BMT.RequestItems()
		-- Not necessary to SetScript, it was done in BlackMarketFrame_Show(). This is just for enforcing it.
		--BlackMarketFrame:SetScript('OnUpdate', BMT.OnUpdate)
	end
end

function BMT.BlackMarketFrame_OnHide(BlackMarketFrame)
	-- OnUpdate unregistered by BlackMarketFrame_Hide. This is just an extra in case the state gets corrupted.
	--if  not BMT.atNpc  then  BlackMarketFrame:SetScript('OnUpdate', nil)  end
	-- Don't close BlackMarket. Continue scanning.
	--C_BlackMarket.Close();
	--PlaySound("AuctionWindowClose");
end


function BMT.BlackMarketFrame_OnEvent(BlackMarketFrame, event, ...)
	if ( event == "BLACK_MARKET_ITEM_UPDATE" ) then
		-- This function scrolls up (resets the scrollframe), very annoying every 2 seconds
		--HybridScrollFrame_CreateButtons(BlackMarketScrollFrame, "BlackMarketItemTemplate", 5, -5);
		BMT.ScrollFrame_Update()
	elseif ( event == "BLACK_MARKET_BID_RESULT" or event == "BLACK_MARKET_OUTBID" ) then
		if (BlackMarketFrame:IsShown()) then
			BMT.RequestItems()
		end
	end
	
	-- do this on any event
	local numItems = C_BlackMarket.GetNumItems()
	BlackMarketFrame.Inset.NoItems:SetShown(numItems  and  numItems <= 0)
	if  BlackMarketFrame.HotDeal:IsVisible()  then   BlackMarketFrame_UpdateHotItem(self)  end
end






function BMT.InteractUnit(unit)
	if  UnitName(unit) == BMT.atNpc  then
		-- Show the BlackMarketFrame when interacting _again_ with the BM npc
		ShowUIPanel(BlackMarketFrame)
	end
end

function BMT.RequestItems()
	--print("BMT.RequestItems() start")
	BMT.filteredItems = nil
	BMT.lastRequest = GetTime()
	C_BlackMarket.RequestItems_()
	print("BMT.RequestItems() end")
	-- UpdateItems event is received later (async)
end

function BMT.GetNumItems()
	if  not BMT.filteredItems  then  BMT:UpdateItems()  end
	return #BMT.filteredItems
end

function BMT.GetItemInfoByIndex(index)
	-- if  not BMT.filteredItems  then  return  end
	return unpack(BMT.filteredItems[index])
end

function BMT.GetHotItem()
	return nil  -- don't show in small frame
end
--[[
function BMT.GetHotItem()
	if  BMT.newestItem  then  return unpack(BMT.newestItem)
  elseif  BMT.filteredItems[1]  then  return unpack(BMT.filteredItems[1])
  end
end
--]]





function BMT.Save()
	local hooks = BMT.hooks or {}  ;  BMT.hooks = hooks
	--[[
	if  not hooks.BlackMarketFrame_Show        then  hooks.BlackMarketFrame_Show       = _G.BlackMarketFrame_Show          end
	if  not hooks.BlackMarketFrame_Hide        then  hooks.BlackMarketFrame_Hide       = _G.BlackMarketFrame_Hide          end
	--]]
	if  not C_BlackMarket.RequestItems_        then  C_BlackMarket.RequestItems_       = C_BlackMarket.RequestItems        end
	if  not C_BlackMarket.GetNumItems_         then  C_BlackMarket.GetNumItems_        = C_BlackMarket.GetNumItems         end
	if  not C_BlackMarket.GetItemInfoByIndex_  then  C_BlackMarket.GetItemInfoByIndex_ = C_BlackMarket.GetItemInfoByIndex  end
	if  not C_BlackMarket.GetHotItem_          then  C_BlackMarket.GetHotItem_         = C_BlackMarket.GetHotItem          end
end

function BMT.Install()
	if  BMT.isInstalled  then  return  end
	
	if  BMT.isInstalled == nil  then
		-- hook only once, BMT.isInstalled == false after BMT.Uninstall()
		-- BMT.isInteractUnitHooked = true
		hooksecurefunc('InteractUnit', BMT.InteractUnit)
	end
	
	BMT.isInstalled = true
	Debug('BMT.Install()')
	BMT.Save()
	BMT:SetScript('OnUpdate', BMT.OnUpdate)
	-- Enable tracking if online (interacting with npc, but atNpc is not initialized yet)
	BMT:SetShown(nil ~= C_BlackMarket.GetNumItems_())
	
	--[[ Registering for the BLACK_MARKET_OPEN and BLACK_MARKET_CLOSE events directly
	_G.BlackMarketFrame_Show = BMT.BlackMarketFrame_Show
	_G.BlackMarketFrame_Hide = BMT.BlackMarketFrame_Hide
	--]]
	
	-- Do not auto-position or auto-close this frame
	UIPanelWindows.BlackMarketFrame = nil
	UISpecialFrames[#UISpecialFrames+1] = "BlackMarketFrame"
	BlackMarketFrame:SetPoint('TOPLEFT',50,-50)
end

--[[
Can only be called explicitly:
/run BMT.Uninstall()
--]]
function BMT.Uninstall()
	print('BMT.Uninstall()')
	BMT:SetScript('OnUpdate', nil)
	BMT:Hide()
	
	--[[ Registering for the BLACK_MARKET_OPEN and BLACK_MARKET_CLOSE events directly
	local hooks = BMT.hooks or {}
	if  hooks.BlackMarketFrame_Show        then  _G.BlackMarketFrame_Show            = hooks.BlackMarketFrame_Show        end
	if  hooks.BlackMarketFrame_Hide        then  _G.BlackMarketFrame_Hide            = hooks.BlackMarketFrame_Hide        end
	--]]
	
	BMT.isInstalled = false
end



function BMT:Enable()
	BlackMarketTrackerAuctionData = _G.BlackMarketTrackerAuctionData or {}
	_G.BlackMarketTrackerAuctionData = BlackMarketTrackerAuctionData
	BlackMarketTrackerAuctionData.showCompletedForMinutes = BlackMarketTrackerAuctionData.showCompletedForMinutes or 10

	if  C_BlackMarket.RequestItems_        then  C_BlackMarket.RequestItems = self.RequestItems  end
	if  C_BlackMarket.GetNumItems_         then  C_BlackMarket.GetNumItems = self.GetNumItems  end
	if  C_BlackMarket.GetItemInfoByIndex_  then  C_BlackMarket.GetItemInfoByIndex = self.GetItemInfoByIndex  end
	if  C_BlackMarket.GetHotItem_          then  C_BlackMarket.GetHotItem = self.GetHotItem  end

	if  not BlackMarketScrollFrame  then  return  end
	if  not BlackMarketScrollFrame.update_     then  BlackMarketScrollFrame.update_    = BlackMarketScrollFrame.update     end
	if  BlackMarketScrollFrame.update_  then
		BlackMarketScrollFrame_Update = self.ScrollFrame_Update
		BlackMarketScrollFrame.update = self.ScrollFrame_Update
	end

	if  not BlackMarketFrame  then  return  end
	--if  not self.eventsRegistered  then
	do
		BlackMarketFrame:SetScript('OnShow', BMT.BlackMarketFrame_OnShow)
		BlackMarketFrame:SetScript('OnHide', BMT.BlackMarketFrame_OnHide)
		BlackMarketFrame:SetScript('OnEvent', BMT.BlackMarketFrame_OnEvent)
		UIParent:UnregisterEvent('BLACK_MARKET_OPEN')
		UIParent:UnregisterEvent('BLACK_MARKET_CLOSE')
		self:SetScript('OnEvent', self.OnEvent)
		self:RegisterEvent('BLACK_MARKET_OPEN')
		self:RegisterEvent('BLACK_MARKET_CLOSE')
		self.eventsRegistered = true
	end
	
	self.BlackMarketFrame_Resize()
end

function BMT:Disable()
	if  C_BlackMarket.RequestItems_        then  C_BlackMarket.RequestItems       = C_BlackMarket.RequestItems_        end
	if  C_BlackMarket.GetNumItems_         then  C_BlackMarket.GetNumItems        = C_BlackMarket.GetNumItems_         end
	if  C_BlackMarket.GetItemInfoByIndex_  then  C_BlackMarket.GetItemInfoByIndex = C_BlackMarket.GetItemInfoByIndex_  end
	if  C_BlackMarket.GetHotItem_          then  C_BlackMarket.GetHotItem         = C_BlackMarket.GetHotItem_          end

	if  not BlackMarketScrollFrame  then  return  end
	if  BlackMarketScrollFrame.update_     then
		BlackMarketScrollFrame_Update = BlackMarketScrollFrame.update_
		BlackMarketScrollFrame.update = BlackMarketScrollFrame.update_
	end

	if  not BlackMarketFrame  then  return  end
	if  self.eventsRegistered  then
		BlackMarketFrame:SetScript('OnShow', _G.BlackMarketFrame_OnShow)
		BlackMarketFrame:SetScript('OnHide', _G.BlackMarketFrame_OnHide)
		BlackMarketFrame:SetScript('OnEvent', _G.BlackMarketFrame_OnEvent)
		UIParent:RegisterEvent('BLACK_MARKET_OPEN')
		UIParent:RegisterEvent('BLACK_MARKET_CLOSE')
		self:SetScript('OnEvent', nil)
		self:UnregisterEvent('BLACK_MARKET_OPEN')
		self:UnregisterEvent('BLACK_MARKET_CLOSE')
		self.eventsRegistered = false
	end
end





if  IsAddOnLoaded('Blizzard_BlackMarketUI')  then
	BMT.Install()
else
	hooksecurefunc('BlackMarket_LoadUI', BMT.Install)
end


