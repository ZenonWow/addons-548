--[[
/run BlackMarketFrame_Show()
/run BlackMarketTracker.Install()
/run BlackMarketTracker.Restore()
/vdt BlackMarketTrackerAuctionData
/dump BlackMarketTracker.currentItems
/dump BlackMarketTracker.filteredItems
/run BlackMarketTrackerAuctionData.showCompletedForMinutes = 50
/dump HybridScrollFrame_GetOffset(BlackMarketScrollFrame)

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

/dump BlackMarketFrame:GetSize()  -- 890,504
/dump BlackMarketFrame.Inset:GetSize()  -- 608,408  -282,-96
/dump BlackMarketScrollFrame:GetSize()  -- 575,394  -33,-14
/dump BlackMarketFrame.TopLeftCorner:GetSize()  -- 32,32
/run a= BlackMarketFrame.TopLeftCorner:GetPoint('TOPLEFT')  -- 32,32
/dump a:GetCoord()
/run BlackMarketFrame:SetSize(660,700)  -- -230,+56
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
--]]

function BlackMarketFrame_Resize(self)
	BlackMarketFrame:SetSize(660,600)
	BlackMarketFrame.Inset:SetPoint('TOPLEFT',BlackMarketFrame,26,-70)
	BlackMarketFrame.Inset:SetPoint('BOTTOMRIGHT',BlackMarketFrame,-26,22)
	--BlackMarketFrame.Inset:SetSize(578,352)
	--BlackMarketFrame.Inset:SetPoint('BOTTOMRIGHT',nil)
	--BlackMarketFrame.Inset:SetPoint('BOTTOMLEFT',nil)
	--BlackMarketScrollFrame:SetSize(345,450)
end



BINDING_NAME_TOGGLEBLACKMARKET        = "Toggle Black Market"
-- "Open the Black Market without updating auctions"

LOADING_DATA = "<Loading item data>"

local function Log(...)  DEFAULT_CHAT_FRAME:AddMessage(...)  end
--local LogVar= ViragDevTool_AddData
----[[
local function LogVar(obj,name)
  if  ViragDevTool_AddData  then  ViragDevTool_AddData(obj,name)  end
end
--]]


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





_G.BlackMarketTracker = _G.BlackMarketTracker or {}
local BlackMarketTracker = _G.BlackMarketTracker
-- BlackMarketTracker.filteredItems = nil
-- BlackMarketTracker.newestItem
-- BlackMarketTrackerAuctionData
BlackMarketTrackerAuctionData = BlackMarketTrackerAuctionData or {}
BlackMarketTrackerAuctionData.showCompletedForMinutes = BlackMarketTrackerAuctionData.showCompletedForMinutes or 10

--[[
/run  BlackMarketTracker.currentItems[1].data.from = BlackMarketTracker.currentItems.updatedTime + 24*60*60 - 15*60
/run  BlackMarketTracker.currentItems[1].data.from = BlackMarketTracker.currentItems[1].data.from +2*60 - 10
--]]

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

function BlackMarketTracker.getTimeFrameText(data, nowSeconds)
	return  getDayText(data.from, nowSeconds) .. date('%H:%M:%S', data.from) ..'<\n<'.. getDayText(data.to, nowSeconds) .. date('%H:%M:%S', data.to)
end


function BlackMarketTracker.calcTimeFrame(timeLeft)
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
		ChatFrame1:AddMessage('BlackMarketTracker:calcTimeFrame(): unknown timeLeft value = '.. timeLeft)
	end
	return  from, to, short
end


function BlackMarketTracker:UpdateItem(item)
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


function BlackMarketTracker:FilterItem(item)
	local data = item.data
	
	if  not self.incompleteQuery  then
		if  not item.exists  and  not data.completed  then
			-- Save time of completion
			item[14] = 0  -- time left column: Completed
			data.completed = nowSeconds
			data.timeFrame = 'Unseen at '.. date('%m-%d %H:%M:%S', data.completed)
		else
			-- Remove flag
			item.exists = nil
		end
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
function BlackMarketTracker:UpdateItems()
	--ChatFrame1:AddMessage('BlackMarketTracker:UpdateItems()')
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
		self.incompleteQuery = true
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
function BlackMarketTracker.ScrollFrame_Update_0()
	local offset, offsetReal = HybridScrollFrame_GetOffset(BlackMarketScrollFrame)
	if  0 < offset  then  return  end
	
	BlackMarketScrollFrame.update_()
	--ChatFrame1:AddMessage('BlackMarketTracker.ScrollFrame_Update() offset='.. offset)
	local buttons = BlackMarketScrollFrame.buttons
	local items = BlackMarketTracker.filteredItems
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


BlackMarketTracker.colors = {
	timeLeft = { [0]='|cffbeb9b5', '|cffff0000', '|cffc0ff00', '|cff00ff00', '|cff2020ff' },
	marketID  = '|cff00ff00',
	itemID    = '|cffffff80',
	itemLevel = '|cffffff80',
	gray = '|cffbeb9b5',
}


-- Patched update function
local lastNumItems = 0
function BlackMarketTracker.ScrollFrame_Update()
	if  not BlackMarketTracker.filteredItems  then  BlackMarketTracker:UpdateItems()  end
	local items = BlackMarketTracker.filteredItems
	if  not items  then  return false  end
	
	local numItems = #items
	--local numItems = C_BlackMarket.GetNumItems();
	
	--local offset, offsetReal = HybridScrollFrame_GetOffset(BlackMarketScrollFrame)
	local offsetReal = BlackMarketScrollFrame.offsetReal  or  select(2, HybridScrollFrame_GetOffset(BlackMarketScrollFrame) )
	local offset = math.floor(offsetReal)
	--local scrollHeight = BlackMarketScrollFrame:GetVerticalScroll()
	local buttons = BlackMarketScrollFrame.buttons;
	local numButtons = #buttons;
	local colors = BlackMarketTracker.colors

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
				itemType = itemType  and  itemType..'\n'  or  ''
				itemID = itemID  or  '?'
				button.Type:SetText(itemType..'item='.. colors.itemID .. itemID ..'|r');
				
				sellerName = sellerName or ''
				-- Show marketID, itemID in seller column
				--button.Seller:SetText(sellerName ..' #'.. colors.marketID .. marketID ..'|r \n item='.. colors.itemID .. itemID .. '|r')
				--button.Seller:SetText(sellerName ..' \n item='.. colors.itemID .. itemID .. '|r')
				marketID = marketID  or  '?'
				button.Seller:SetText(sellerName ..' #'.. colors.marketID .. marketID .. '|r')
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
				button.TimeLeft.Text:SetText(colors.timeLeft[timeLeft] .. _G["AUCTION_TIME_LEFT"..timeLeft] ..'|r \n '.. item.data.timeFrame)
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
	
	--BlackMarketScrollFrame:SetVerticalScroll(BlackMarketScrollFrame.scrollHeight)
	HybridScrollFrame_SetOffset(BlackMarketScrollFrame, offsetReal)
	--BlackMarketScrollFrame.offsetReal = nil
	--[[
/run BlackMarketScrollFrame:SetVerticalScroll(25)
/run HybridScrollFrame_SetOffset(BlackMarketScrollFrame, BlackMarketScrollFrame.offsetReal)
/run HybridScrollFrame_SetOffset(BlackMarketScrollFrame, 10)
/dump BlackMarketScrollFrame:GetVerticalScroll()
/dump HybridScrollFrame_GetOffset(BlackMarketScrollFrame)
/dump BlackMarketScrollFrame.offsetReal
/dump BlackMarketScrollFrame.scrollHeight
	if  lastNumItems ~= numItems  then
		lastNumItems = numItems
		local scrollFrame = BlackMarketScrollFrame;
		local totalHeight = numItems * scrollFrame.buttonHeight;
		local displayedHeight = numButtons * scrollFrame.buttonHeight;
		HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
		HybridScrollFrame_SetOffset(BlackMarketScrollFrame, offsetReal)
	end
	--]]
end






function BlackMarketTracker.OnUpdate(self)
	if  not BlackMarketFrame:IsShown()  then  ChatFrame1:AddMessage('BlackMarketTracker.OnUpdate() when frame not shown') ; return  end
	if  not BlackMarketTracker.lastUpdate  then
		ChatFrame1:AddMessage('BlackMarketTracker.OnUpdate(): BlackMarketTracker.lastUpdate == nil')
		return
	end
	
	local nowSeconds = time()
	if  2 <= nowSeconds - BlackMarketTracker.lastUpdate  then
		BlackMarketTracker.RequestItems()
	elseif BlackMarketTracker.incompleteQuery  then
		BlackMarketTracker.RequestItems()
		BlackMarketTracker.ScrollFrame_Update()
	end
end

--[[
function BlackMarketTracker.OnEvent(self, event, ...)
	if (event == "BLACK_MARKET_ITEM_UPDATE") then  UpdateItems() end
end

function BlackMarketTracker.OnShow(...)
	BlackMarketFrame_OnShow(...)
end
--]]


function BlackMarketFrame_Show()
	ShowUIPanel(BlackMarketFrame);
	if ( not BlackMarketFrame:IsShown() ) then
		C_BlackMarket.Close();
	end
	--PlaySound("AuctionWindowOpen")
end

function BlackMarketFrame_OnShow(self)
	self.HotDeal:Hide();
	C_BlackMarket.RequestItems();
	MoneyInputFrame_SetCopper(BlackMarketBidPrice, 0);
	BlackMarketFrame.BidButton:Disable();
	--PlaySound("AuctionWindowOpen");
end


--[[
function BlackMarketFrame_Hide()
	HideUIPanel(BlackMarketFrame);
	--PlaySound("AuctionWindowClose");
end

function BlackMarketFrame_OnHide(self)
	C_BlackMarket.Close();
	--PlaySound("AuctionWindowClose");
end
--]]




function BlackMarketTracker.RequestItems()
	BlackMarketScrollFrame.offsetReal = select(2, HybridScrollFrame_GetOffset(BlackMarketScrollFrame) )
	BlackMarketScrollFrame.scrollHeight = BlackMarketScrollFrame:GetVerticalScroll()
	BlackMarketTracker.filteredItems = nil
	local nowSeconds = time()
	if  1 <= BlackMarketScrollFrame.offsetReal  and  nowSeconds - BlackMarketTracker.lastUpdate < 30  then
		-- Skip update to keep VerticalScroll
		return
	end
	
	BlackMarketTracker.lastUpdate = nowSeconds
	C_BlackMarket.RequestItems_()
	local newScrollHeight = BlackMarketScrollFrame:GetVerticalScroll()
	if  1 <= BlackMarketScrollFrame.scrollHeight  and  newScrollHeight < 1  then
		-- VerticalScroll reset
		Log('GetVerticalScroll() reset from '.. BlackMarketScrollFrame.scrollHeight ..' to '.. newScrollHeight)
	end
	BlackMarketScrollFrame.offsetReal = nil
end

function BlackMarketTracker.GetNumItems()
	if  not BlackMarketTracker.filteredItems  then  BlackMarketTracker:UpdateItems()  end
	return #BlackMarketTracker.filteredItems
end

function BlackMarketTracker.GetItemInfoByIndex(index)
	-- if  not BlackMarketTracker.filteredItems  then  return  end
	return unpack(BlackMarketTracker.filteredItems[index])
end

function BlackMarketTracker.GetHotItem()
	return nil  -- don't show in small frame
end
--[[
function BlackMarketTracker.GetHotItem()
	if  BlackMarketTracker.newestItem  then  return unpack(BlackMarketTracker.newestItem)
  elseif  BlackMarketTracker.filteredItems[1]  then  return unpack(BlackMarketTracker.filteredItems[1])
  end
end
--]]


function BlackMarketTracker.Save()
	if  not C_BlackMarket.RequestItems_  then  C_BlackMarket.RequestItems_ = C_BlackMarket.RequestItems  end
	if  not C_BlackMarket.GetNumItems_  then  C_BlackMarket.GetNumItems_ = C_BlackMarket.GetNumItems  end
	if  not C_BlackMarket.GetItemInfoByIndex_  then  C_BlackMarket.GetItemInfoByIndex_ = C_BlackMarket.GetItemInfoByIndex  end
	if  not C_BlackMarket.GetHotItem_  then  C_BlackMarket.GetHotItem_ = C_BlackMarket.GetHotItem  end
	if  not BlackMarketScrollFrame.update_  then  BlackMarketScrollFrame.update_ = BlackMarketScrollFrame.update  end
end

function BlackMarketTracker.Install()
	if  IsShiftKeyDown()  then
		BlackMarketTracker.Restore()
		return
	end
	
	BlackMarketTracker.Save()
	ChatFrame1:AddMessage('BlackMarketTracker.Install()')
	if  C_BlackMarket.RequestItems_  then  C_BlackMarket.RequestItems = BlackMarketTracker.RequestItems  end
	if  C_BlackMarket.GetNumItems_  then  C_BlackMarket.GetNumItems = BlackMarketTracker.GetNumItems  end
	if  C_BlackMarket.GetItemInfoByIndex_  then  C_BlackMarket.GetItemInfoByIndex = BlackMarketTracker.GetItemInfoByIndex  end
	if  C_BlackMarket.GetHotItem_  then  C_BlackMarket.GetHotItem = BlackMarketTracker.GetHotItem  end
	if  BlackMarketScrollFrame.update_  then
		BlackMarketScrollFrame_Update = BlackMarketTracker.ScrollFrame_Update
		BlackMarketScrollFrame.update = BlackMarketTracker.ScrollFrame_Update
	end
	--hooksecurefunc('BlackMarketScrollFrame_Update', BlackMarketTracker.ScrollFrame_Update)
	if  not BlackMarketTracker.eventsRegistered  then
		--BlackMarketFrame:SetScript('OnEvent', BlackMarketTracker.OnEvent)
		--BlackMarketFrame:SetScript('OnShow', BlackMarketTracker.OnShow)
		BlackMarketFrame:SetScript('OnUpdate', BlackMarketTracker.OnUpdate)
		BlackMarketTracker.eventsRegistered = true
	end
	
	BlackMarketFrame_Resize(self)
end

function BlackMarketTracker.Restore()
	if  C_BlackMarket.RequestItems_  then  C_BlackMarket.RequestItems = C_BlackMarket.RequestItems_  end
	if  C_BlackMarket.GetNumItems_  then  C_BlackMarket.GetNumItems = C_BlackMarket.GetNumItems_  end
	if  C_BlackMarket.GetItemInfoByIndex_  then  C_BlackMarket.GetItemInfoByIndex = C_BlackMarket.GetItemInfoByIndex_  end
	if  C_BlackMarket.GetHotItem_  then  C_BlackMarket.GetHotItem = C_BlackMarket.GetHotItem_  end
	if  BlackMarketScrollFrame.update_  then
		BlackMarketScrollFrame_Update = BlackMarketScrollFrame.update_
		BlackMarketScrollFrame.update = BlackMarketScrollFrame.update_
	end
	if  BlackMarketTracker.eventsRegistered  then
		--BlackMarketFrame:SetScript('OnEvent', BlackMarketFrame_OnEvent)
		--BlackMarketFrame:SetScript('OnShow', BlackMarketFrame_OnShow)
		BlackMarketFrame:SetScript('OnUpdate', nil)
		BlackMarketTracker.eventsRegistered = false
	end
end


--BlackMarketTracker.Save()
hooksecurefunc('BlackMarket_LoadUI', BlackMarketTracker.Install)

