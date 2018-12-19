--[[
/dump MerchantFrame:GetSize()    -- 336,444
/dump MerchantFrameInset:GetSize()    -- 326,358
/run MerchantFrameInset:SetShown( false )
/run MerchantBuyBackItem:Hide()
/run GVS.EventFrame:SetScript('OnShow', function() error('OnShow') end)
--]]

local GVS = _G.GVS
local GVSTab = GVS.Tab
local MerchantFrame = _G.MerchantFrame



local function MerchantFrame_OnMouseWheel(self, offset)
	-- Turn pages with mouse wheel only on buy tab
	if  MerchantFrame.selectedTab ~= 1  then   return  end
	
	local direction = 0 < offset  and  'Prev'  or  'Next'    -- roll up: PrevPage, roll down: NextPage
	local btnName = 'Merchant'..direction..'PageButton'
	local btn = _G[btnName]
	if  offset ~= 0  and  btn:IsEnabled()  then  _G[btnName..'_OnClick']( btn )  end
end

-- Contents of MerchantFrame Tab1 are grouped together in MerchantFrameItems to be hidden when GVSTab is visible
do
	local MFItems = CreateFrame('Frame', 'MerchantFrameItems', MerchantFrame)
	MFItems:SetAllPoints() ; MFItems:Show()
	for  i = 1,10  do  _G["MerchantItem"..i]:SetParent(MFItems)  end

	local MFIBack = CreateFrame('Frame', 'MerchantFrameItemsBuyBack', MerchantFrame)
	MFIBack:SetAllPoints() ; MFIBack:Show()
	for  i = 11,12  do  _G["MerchantItem"..i]:SetParent(MFIBack) ; _G["MerchantItem"..i]:Show()  end

	local MFIPurr = CreateFrame('Frame', 'MerchantFrameItemsPurchase', MerchantFrame)
	MFIPurr:SetAllPoints() ; MFIPurr:Show()
	MerchantPrevPageButton:SetParent(MFIPurr) ; MerchantNextPageButton:SetParent(MFIPurr) ; MerchantPageText:SetParent(MFIPurr)

	local MFRepr = CreateFrame('Frame', 'MerchantFrameRepairRow', MerchantFrame)
	MFRepr:SetAllPoints() ; MFRepr:Show()
	MerchantRepairText:SetParent(MFRepr) ; MerchantRepairAllButton:SetParent(MFRepr) ; MerchantRepairItemButton:SetParent(MFRepr) ; MerchantGuildBankRepairButton:SetParent(MFRepr)
	MerchantBuyBackItem:SetParent(MFRepr) ; MerchantFrameBottomLeftBorder:SetParent(MFRepr) ; MerchantFrameBottomRightBorder:SetParent(MFRepr)
	
--[[
	-- Reanchor the buyback button, it acts weird when switching tabs otherwise...
	MerchantBuyBackItem:ClearAllPoints()
	MerchantBuyBackItem:SetPoint("BOTTOMRIGHT", -7, 33)
--]]
	
	MFItems:EnableMouseWheel(true)
	MFItems:SetScript("OnMouseWheel", MerchantFrame_OnMouseWheel)
end




-- Overriden function of FrameXML\MerchantFrame.lua
function GVS.MerchantFrame_OnShow(self)
	-- Only open bag on buyback tab
	--OpenAllBags(self);
	-- Update repair all button status
	MerchantFrame_UpdateCanRepairAll();
	MerchantFrame_UpdateGuildBankRepair();
	--PanelTemplates_SetTab(MerchantFrame, GVSTab.tabIndex);
	
	local npcName = UnitName('npc')
	-- Reset filter if opening different vendor
	if  MerchantFrame.npcName ~= npcName  then
		ResetSetMerchantFilter()
	end
	MerchantFrame.npcName = npcName
	
	local showTab = IsShiftKeyDown()  and  1  or  GVSTab.tabIndex
	PanelTemplates_SetTab(MerchantFrame, showTab)
	
	_G.MerchantFrame_Update();
	--PlaySound("igCharacterInfoOpen");
end

function GVS.MerchantFrame_OnHide(self)
	CloseMerchant();
	
	--[[
	Blizzard has overwritten CloseAllBags(frame) with CloseAllBags()
	as if this was C, not Lua (well, the ; on lineends is a telltale sign)
	basicly disabling handling of FRAME_THAT_OPENED_BAGS
	therefore it must be done here.
	Update: leave Blizz internals alone, flip a flag instead: MerchantFrame.closeBags
	--]]
	--if  _G.FRAME_THAT_OPENED_BAGS == self:GetName()  then
	if  MerchantFrame.closeBags  then
		CloseAllBags(MerchantFrame)
		--_G.FRAME_THAT_OPENED_BAGS = nil
		MerchantFrame.closeBags = nil
	end
	
	ResetCursor();
	
	StaticPopup_Hide("CONFIRM_PURCHASE_TOKEN_ITEM");
	StaticPopup_Hide("CONFIRM_REFUND_TOKEN_ITEM");
	StaticPopup_Hide("CONFIRM_REFUND_MAX_HONOR");
	StaticPopup_Hide("CONFIRM_REFUND_MAX_ARENA_POINTS");
	--PlaySound("igCharacterInfoClose");
end


function GVS.ContainerFrameItemButton_OnClick(self, button)
	-- Fix the idea of Blizzard to not let you sell items when the buyback tab is open
	--GVS.hooks.ContainerFrameItemButton_OnClick(self, button)
	
	if ( button ~= "LeftButton" ) then
		if ( MerchantFrame:IsShown() ) then
			if ( MerchantFrame.selectedTab ~= 2 ) then
				-- Already sold by the original function
				return;
			end
			if ( ContainerFrame_GetExtendedPriceString(self)) then
				-- a confirmation dialog has been shown
				return;
			end
			UseContainerItem(self:GetParent():GetID(), self:GetID());
			StackSplitFrame:Hide();
		end
	end
end

function GVS.ContainerFrameItemButton_OnEnter(self, motion)
	-- Fix to show the sell cursor in bags when the selectedTab ~= 1
	--GVS.hooks.ContainerFrameItemButton_OnEnter(self, button)
	
	if ( InRepairMode() and (repairCost and repairCost > 0) ) then
	elseif  MerchantFrame:IsShown()  then
		ShowContainerSellCursor(self:GetParent():GetID(), self:GetID());
	end
end


--[[
-- Secure hook variant:
function GVS.MerchantFrame_Update_Secure(self, ...)
	local onGvsTab =  ( MerchantFrame.selectedTab == GVSTab.tabIndex )
	if  not GVSTab:IsShown() == onGvsTab  then
		MerchantFrameItems:SetShown(not onGvsTab)
		GVSTab:SetShown(onGvsTab)
		
		-- Show and update reused elements of buy tab
		if  onGvsTab  then  MerchantFrame_UpdateMerchantInfo()  end
		
	elseif  GVSTab:IsVisible()  then
		-- _G.MerchantFrame_Update() made visible the buyback elements (2nd tab) now it has to be reverted
		MerchantFrame_UpdateMerchantInfo()
		GVSTab:Refresh()
		
	end
end
--]]

-- RawHook variant:
function GVS.MerchantFrame_Update(self, ...)
	local selectedTab = MerchantFrame.selectedTab
	local tabChanged =  GVSTab.lastTab ~= selectedTab
	print("GVS.MerchantFrame_Update(): selectedTab="..tostring(selectedTab).." tabChanged="..tostring(tabChanged) )
	
	if  tabChanged  then
		GVSTab.lastTab = selectedTab
		MerchantFrameItems:SetShown(selectedTab ~= GVSTab.tabIndex)
		MerchantFrameItemsPurchase:SetShown(selectedTab == 1)
		MerchantFrameItemsBuyBack:SetShown(selectedTab == 2)
		MerchantFrameRepairRow:SetShown(selectedTab ~= 2)
		GVSTab:SetShown(selectedTab == GVSTab.tabIndex)
	end
	
	_G.MerchantFrame_UpdateFilterString()
	
	if  selectedTab == GVSTab.tabIndex  then
		-- GVS.MerchantFrame_UpdateReusedElements()
		_G.MerchantFrame_UpdateMerchantInfo()
		GVSTab:Refresh()
	elseif  selectedTab == 1  then
		_G.MerchantFrame_UpdateMerchantInfo()
	elseif  selectedTab == 2  then
		if  not MerchantFrame.closeBags  and  not _G.FRAME_THAT_OPENED_BAGS  then
			MerchantFrame.closeBags = true
			OpenAllBags(self)
		end
		GVS.MerchantFrame_UpdateBuybackInfo()
	end
end

function GVS.MerchantFrame_UpdateBuybackInfo()
	MerchantNameText:SetText(MERCHANT_BUYBACK);
	MerchantFramePortrait:SetTexture("Interface\\MerchantFrame\\UI-BuyBack-Icon");

	-- Show Buyback specific items
	MerchantItem11:Show();
	MerchantItem12:Show();
	--BuybackBG:Show();    -- Don't need that smudge

	--[[
	-- Position buyback items
	MerchantItem3:SetPoint("TOPLEFT", "MerchantItem1", "BOTTOMLEFT", 0, -15);
	MerchantItem5:SetPoint("TOPLEFT", "MerchantItem3", "BOTTOMLEFT", 0, -15);
	MerchantItem7:SetPoint("TOPLEFT", "MerchantItem5", "BOTTOMLEFT", 0, -15);
	MerchantItem9:SetPoint("TOPLEFT", "MerchantItem7", "BOTTOMLEFT", 0, -15);
	--]]
	
	local numBuybackItems = GetNumBuybackItems();
	local itemButton, buybackButton;
	local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable;
	for i=1, BUYBACK_ITEMS_PER_PAGE do
		itemButton = _G["MerchantItem"..i.."ItemButton"];
		buybackButton = _G["MerchantItem"..i];
		_G["MerchantItem"..i.."AltCurrencyFrame"]:Hide();
		if ( i <= numBuybackItems ) then
			buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable = GetBuybackItemInfo(i);
			_G["MerchantItem"..i.."Name"]:SetText(buybackName);
			SetItemButtonCount(itemButton, buybackQuantity);
			SetItemButtonStock(itemButton, buybackNumAvailable);
			SetItemButtonTexture(itemButton, buybackTexture);
			_G["MerchantItem"..i.."MoneyFrame"]:Show();
			MoneyFrame_Update("MerchantItem"..i.."MoneyFrame", buybackPrice);
			itemButton:SetID(i);
			itemButton:Show();
			if ( not buybackIsUsable ) then
				SetItemButtonNameFrameVertexColor(buybackButton, 1.0, 0, 0);
				SetItemButtonSlotVertexColor(buybackButton, 1.0, 0, 0);
				SetItemButtonTextureVertexColor(itemButton, 0.9, 0, 0);
				SetItemButtonNormalTextureVertexColor(itemButton, 0.9, 0, 0);
			else
				SetItemButtonNameFrameVertexColor(buybackButton, 0.5, 0.5, 0.5);
				SetItemButtonSlotVertexColor(buybackButton, 1.0, 1.0, 1.0);
				SetItemButtonTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
				SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
			end
		else
			SetItemButtonNameFrameVertexColor(buybackButton, 0.5, 0.5, 0.5);
			SetItemButtonSlotVertexColor(buybackButton,0.4, 0.4, 0.4);
			_G["MerchantItem"..i.."Name"]:SetText("");
			_G["MerchantItem"..i.."MoneyFrame"]:Hide();
			itemButton:Hide();
		end
	end

	--[[
	-- Hide all merchant related items
	MerchantRepairAllButton:Hide();
	MerchantRepairItemButton:Hide();
	MerchantBuyBackItem:Hide();
	MerchantPrevPageButton:Hide();
	MerchantNextPageButton:Hide();
	MerchantFrameBottomLeftBorder:Hide();
	MerchantFrameBottomRightBorder:Hide();
	MerchantRepairText:Hide();
	MerchantPageText:Hide();
	MerchantGuildBankRepairButton:Hide();
	--]]
end



--[[
function GVS.MerchantFrame_UpdateReusedElements()
	--MerchantNameText:SetText(UnitName("NPC"));
	SetPortraitTexture(MerchantFramePortrait, "NPC");

	-- Handle repair items
	MerchantFrame_UpdateRepairButtons();
	
	-- Handle vendor buy back item
	GVS.MerchantFrame_UpdateBuyBackItem()

	-- Show all merchant related items
	MerchantBuyBackItem:Show();
	MerchantFrameBottomLeftBorder:Show();
	MerchantFrameBottomRightBorder:Show();

	-- Hide buyback related items
	--MerchantItem11:Hide();
	--MerchantItem12:Hide();
	--BuybackBG:Hide();
end

function GVS.MerchantFrame_UpdateBuyBackItem()
	-- Handle vendor buy back item
	local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable = GetBuybackItemInfo(GetNumBuybackItems());
	if ( buybackName ) then
		MerchantBuyBackItemName:SetText(buybackName);
		SetItemButtonCount(MerchantBuyBackItemItemButton, buybackQuantity);
		SetItemButtonStock(MerchantBuyBackItemItemButton, buybackNumAvailable);
		SetItemButtonTexture(MerchantBuyBackItemItemButton, buybackTexture);
		MerchantBuyBackItemMoneyFrame:Show();
		MoneyFrame_Update("MerchantBuyBackItemMoneyFrame", buybackPrice);
		MerchantBuyBackItem:Show();
		
	else
		MerchantBuyBackItemName:SetText("");
		MerchantBuyBackItemMoneyFrame:Hide();
		SetItemButtonTexture(MerchantBuyBackItemItemButton, "");
		SetItemButtonCount(MerchantBuyBackItemItemButton, 0);
		-- Hide the tooltip upon sale
		if ( GameTooltip:IsOwned(MerchantBuyBackItemItemButton) ) then
			GameTooltip:Hide();
		end
	end
end
--]]



--[[
GVS.hooks = GVS.hooks or {}
GVS.hooks.MerchantFrame_OnShow = MerchantFrame_OnShow
MerchantFrame_OnShow = GVS.MerchantFrame_OnShow
GVS.hooks.MerchantFrame_Update = MerchantFrame_Update
MerchantFrame_Update = GVS.MerchantFrame_Update
--]]
--hooksecurefunc('MerchantFrame_Update', GVS.MerchantFrame_Update_Secure)
hooksecurefunc('ContainerFrameItemButton_OnClick', GVS.ContainerFrameItemButton_OnClick)
hooksecurefunc('ContainerFrameItemButton_OnEnter', GVS.ContainerFrameItemButton_OnEnter)



function GVS:HookMerchantFrameOn()
	--GVS:RawHook('MerchantFrame_OnShow')
	self:RawHook('MerchantFrame_Update')
	--self:RawHook('ContainerFrameItemButton_OnClick')
	--self:RawHook('ContainerFrameItemButton_OnEnter')
	self:HookScript(MerchantFrame, 'OnShow', self.MerchantFrame_OnShow)
	self:HookScript(MerchantFrame, 'OnHide', self.MerchantFrame_OnHide)
end

function GVS:HookMerchantFrameOff()
	--self:Unhook('MerchantFrame_OnShow')
	self:Unhook('MerchantFrame_Update')
	--self:Unhook('ContainerFrameItemButton_OnClick')
	--self:Unhook('ContainerFrameItemButton_OnEnter')
	self:UnhookScript(MerchantFrame, 'OnShow')
	self:UnhookScript(MerchantFrame, 'OnHide')
end





--[[
GVS.EventFrame = CreateFrame('Frame', nil, MerchantFrame)
function GVS.EventFrame:OnShow()
	print('GVS.EventFrame:OnShow()')
end
function GVS.EventFrame:OnHide()
	print('GVS.EventFrame:OnHide()')
end
function GVS.EventFrame:OnLoad()
	print('GVS.EventFrame:OnLoad()')
	self:RegisterEvent("MERCHANT_UPDATE");
	self:RegisterEvent("MERCHANT_CLOSED");
	self:RegisterEvent("MERCHANT_SHOW");
end
function GVS.EventFrame:OnEvent(event, ...) 
	print('GVS.EventFrame:OnEvent('..event..')')
	if  self[event]  then  return self[event](self, event, ...)  end
end
function GVS.EventFrame:MERCHANT_UPDATE(event, ...) 
end
function GVS.EventFrame:MERCHANT_SHOW(event, ...) 
end
function GVS.EventFrame:MERCHANT_CLOSED(event, ...) 
end

GVS.EventFrame:SetScript('OnShow', GVS.EventFrame.OnShow)
GVS.EventFrame:SetScript('OnHide', GVS.EventFrame.OnHide)
GVS.EventFrame:SetScript('OnEvent', GVS.EventFrame.OnEvent)
GVS.EventFrame:OnLoad()
GVS.EventFrame:Hide()
--]]





