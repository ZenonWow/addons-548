--[[
/dump MerchantFrame:GetSize()    -- 336,444
/dump MerchantFrameInset:GetSize()    -- 326,358
/run MerchantFrameInset:SetShown( false )
/run MerchantBuyBackItem:Hide()
/run GVS.EventFrame:SetScript('OnShow', function() error('OnShow') end)


/run SetModifiedClick('SPLITSTACK',nil)
/run SetModifiedClick('SPLITSTACK','SHIFT')
/run SetModifiedClick('SPLITSTACK','SHIFT-BUTTON2')
/run SetModifiedClick('SPLITSTACK','ALT-BUTTON1')
-- Bindings.xml:  <ModifiedClick action="FULLSTACK" default="ALT"/>
/run SetModifiedClick('FULLSTACK','ALT')
--]]

local myname, ns = ...
ns.IHASCAT = select(4, GetBuildInfo()) >= 40000

local GVS = {}
if  _G.GVS == nil  then  _G.GVS = GVS  end

local ItemSearch = LibStub('LibItemSearch-1.0')

local TAB_TITLE = "Gnomish"
local NUMROWS, ICONSIZE, GAP, SCROLLSTEP = 14, 17, 4, 5
local HONOR_POINTS, ARENA_POINTS = "|cffffffff|Hitem:43308:0:0:0:0:0:0:0:0|h[Honor Points]|h|r", "|cffffffff|Hitem:43307:0:0:0:0:0:0:0:0|h[Arena Points]|h|r"
local ROWHEIGHT = 21

local searchColor = {
	[false] = {1,0,0,1, 1,0,0,0.3}, -- red
	[true] = {1,0.7,0.3,1, 1,0.7,0.3,0.3}, -- yellow
}
	local default_grad = {0,1,0,0.75, 0,1,0,0} -- green
local grads = setmetatable({
	red = {1,0,0,0.75, 1,0,0,0},
	[1] = {1,1,1,0.75, 1,1,1,0}, -- white
	[2] = default_grad, -- green
	[3] = {0.5,0.5,1,1, 0,0,1,0}, -- blue
	[4] = {1,0,1,0.75, 1,0,1,0}, -- purple
	[7] = {1,.75,.5,0.75, 1,.75,.5,0}, -- heirloom
}, {__index = function(t,i)  return default_grad  end})
--}, {__index = function(t,i) t[i] = default_grad return default_grad end})
local RECIPE = select(7, GetAuctionItemClasses())
local quality_colors = setmetatable({}, {__index = function() return "|cffffffff" end})
for i=1,7 do quality_colors[i] = "|c".. select(4, GetItemQualityColor(i)) end


local function print(...)  DEFAULT_CHAT_FRAME:AddMessage(...)  end
local function tindexof(self, value)
	for  i= 1,#self  do  if  self[i] == value  then  return i  end end
end



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
	
	-- Done by ZenTools too? not atm
	MFItems:EnableMouseWheel(true)
	MFItems:SetScript("OnMouseWheel", MerchantFrame_OnMouseWheel)
end


-- GnomishVendor  Tab
local GVSTab = CreateFrame('Frame', 'GnomishVendor', MerchantFrame)
GVS.Tab = GVSTab

-- MerchantFrame: <Size x="336" y="444"/>    <-->    GVSTab:SetWidth(315) ; GVSTab:SetHeight(294)
GVSTab:SetPoint("TOPLEFT", 8, -67)
GVSTab:SetPoint("BOTTOMRIGHT", -13, 83)    --   -(336 - 315 - 8), (444 - 294 - 67)
GVSTab:Hide()

-- Tab selector button
GVSTab.tabIndex = MerchantFrame.numTabs + 1
GVSTab.tabButton = CreateFrame('Button', 'MerchantFrameTab'..GVSTab.tabIndex, MerchantFrame, 'CharacterFrameTabButtonTemplate')
GVSTab.tabButton:SetID(GVSTab.tabIndex)
GVSTab.tabButton:SetText(TAB_TITLE)
GVSTab.tabButton:SetPoint('LEFT', _G['MerchantFrameTab'..(GVSTab.tabIndex-1)], 'RIGHT', -16, 0)
GVSTab.tabButton:SetScript('OnClick', function(self, button) 
	PanelTemplates_SetTab(MerchantFrame, self:GetID())
	--_G.MerchantFrame_Update()
	GVS.MerchantFrame_Update()
end)
--[[
GVSTab.tabButton:SetScript('OnLeave', GameTooltip_Hide)
GVSTab.tabButton:SetScript('OnEnter', function() 
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("", 1.0,1.0,1.0 )
end)
--]]
PanelTemplates_SetNumTabs(MerchantFrame, GVSTab.tabIndex)
PanelTemplates_DeselectTab(GVSTab.tabButton)




function GVS:RawHook(hookedFuncName)
	-- Already registered?
	self.hooks = self.hooks or {}
	if  self.hooks[hookedFuncName]  then
		--print('GVS:RawHook(): '.. hookedFuncName ..' was already registered.')
	elseif  not self[hookedFuncName]  then
		print('GVS:RawHook(): GVS.'.. hookedFuncName ..'() does not exist.')
	else
		self.hooks[hookedFuncName] = _G[hookedFuncName]
		_G[hookedFuncName] = self[hookedFuncName]
	end
end


function GVS:Unhook(hookedFuncName)
	if  not self.hooks  or  not self.hooks[hookedFuncName]  then
		-- Not registered
		print('GVS:Unhook(): '.. hookedFuncName ..' was not registered.')
		
	elseif  _G[hookedFuncName] ~= self[hookedFuncName]  then
		-- Other addon hooked before our hook, don't know how to unhook from the chain
		print('GVS:Unhook(): '.. hookedFuncName ..' was hooked by other addon, failed to unhook.')
		
	else
		-- Replace our function with original
		_G[hookedFuncName] = self.hooks[hookedFuncName]
		self.hooks[hookedFuncName] = nil
	end
end


function GVS:HookScript(hookedFrame, hookedScriptName, callback)
	self.hooks = self.hooks or {}
	self.hooks[hookedFrame] = self.hooks[hookedFrame] or {}
	local frameHooks = self.hooks[hookedFrame]
	if  not frameHooks[hookedScriptName]  then
		frameHooks[hookedScriptName] = hookedFrame:GetScript(hookedScriptName)
		MerchantFrame:SetScript(hookedScriptName, callback)
	end
end

function GVS:UnhookScript(hookedFrame, hookedScriptName)
	local frameHooks = self.hooks  and  not self.hooks[hookedFrame]
	if  not frameHooks  or  not frameHooks[hookedScriptName]  then
		-- Not registered
		local frameName = hookedFrame:GetName()  or  '<unnamed>'
		print('GVS:UnhookScript(): '.. frameName ..':GetScript("'.. hookedScriptName ..'") was not registered.')
		
	elseif  hookedFrame:GetScript(hookedFuncName) ~= frameHooks[hookedFuncName]  then
		-- Other addon hooked before our hook, don't know how to unhook from the chain
		print('GVS:UnhookScript(): '.. frameName ..':GetScript("'.. hookedScriptName ..'") was hooked by other addon, failed to unhook.')
		
	else
		-- Replace our function with original
		hookedFrame:SetScript( hookedScriptName, frameHooks[hookedFuncName] )
		frameHooks[hookedFuncName] = nil
	end
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
	-- Fix the idiotic idea of Blizzard to not let you sell items when the buyback tab is open
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
		ShowContainerSellCursor(self:GetParent():GetID(),self:GetID());
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
function GVS.MerchantFrame_Update()
	local tabChanged =  GVSTab.lastTab ~= MerchantFrame.selectedTab
	
	if  tabChanged  then
		GVSTab.lastTab = MerchantFrame.selectedTab
		MerchantFrameItems:SetShown(MerchantFrame.selectedTab ~= GVSTab.tabIndex)
		MerchantFrameItemsPurchase:SetShown(MerchantFrame.selectedTab == 1)
		MerchantFrameItemsBuyBack:SetShown(MerchantFrame.selectedTab == 2)
		MerchantFrameRepairRow:SetShown(MerchantFrame.selectedTab ~= 2)
		GVSTab:SetShown(MerchantFrame.selectedTab == GVSTab.tabIndex)
	end
	
	MerchantFrame_UpdateFilterString()
	
	if  MerchantFrame.selectedTab == GVSTab.tabIndex  then
		-- GVS.MerchantFrame_UpdateReusedElements()
		MerchantFrame_UpdateMerchantInfo()
		GVSTab:Refresh()
	elseif  MerchantFrame.selectedTab == 1  then
		MerchantFrame_UpdateMerchantInfo();
	elseif  MerchantFrame.selectedTab == 2  then
		--if  not MerchantFrame.closeBags  and  not _G.FRAME_THAT_OPENED_BAGS  then
		if  not MerchantFrame.closeBags  then
			MerchantFrame.closeBags = true
			OpenAllBags(MerchantFrame)
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

function GVS.HandleModifiedItemClick(...)
	--local link = ... ; print('GVS.HandleModifiedItemClick('.. link ..')')
	return IsModifiedClick('CHATLINK') and GVSTab:OnItemLink(...)
		or GVS.hooks.HandleModifiedItemClick(...)
end


function GVS.ChatEdit_InsertLink(...)
	--local link = ... ; print('GVS.ChatEdit_InsertLink('.. link ..')')
	return GVSTab:OnItemLink(...)
		or GVS.hooks.ChatEdit_InsertLink(...)
end


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



function GVS:OnEnable()
	--GVS:RawHook('MerchantFrame_OnShow')
	self:RawHook('MerchantFrame_Update')
	--self:RawHook('ContainerFrameItemButton_OnClick')
	--self:RawHook('ContainerFrameItemButton_OnEnter')
	self:HookScript(MerchantFrame, 'OnShow', self.MerchantFrame_OnShow)
	self:HookScript(MerchantFrame, 'OnHide', self.MerchantFrame_OnHide)
	
	MerchantFrame.selectedTab = GVSTab.tabIndex
	PanelTemplates_EnableTab(MerchantFrame, GVSTab.tabIndex)
	--[[ Alternative:
	GVSTab.tabButton.isDisabled = nil
	PanelTemplates_SetTab(MerchantFrame, GVSTab.tabIndex)
	--]]
	
	if  MerchantFrame:IsVisible()  then  _G.MerchantFrame_Update()  end
end

function GVS:OnDisable()
	--self:Unhook('MerchantFrame_OnShow')
	self:Unhook('MerchantFrame_Update')
	--self:Unhook('ContainerFrameItemButton_OnClick')
	--self:Unhook('ContainerFrameItemButton_OnEnter')
	self:UnhookScript(MerchantFrame, 'OnShow')
	self:UnhookScript(MerchantFrame, 'OnHide')
	
	if  MerchantFrame.selectedTab == GVSTab.tabIndex  then
		MerchantFrame.selectedTab = 1
		if  MerchantFrame:IsVisible()  then  _G.MerchantFrame_Update()  end
	end
	PanelTemplates_DisableTab(MerchantFrame, GVSTab.tabIndex)
	--[[ Alternative:
	GVSTab.tabButton.isDisabled = 1
	PanelTemplates_SetDisabledTabState(GVSTab.tabButton)
	--]]
	
	GVSTab:DeleteRows()
end




function GVSTab:OnShow()
	--print('GVSTab:OnShow()')
	
	--GVS:RawHook('HandleModifiedItemClick')
	GVS:RawHook('ChatEdit_InsertLink')
	
	local npcName = UnitName('npc')
	-- Scroll up if opening different vendor
	if  self.npcName ~= npcName  then
		self.scrollbar:SetValue(0)
	end
	self.npcName = npcName
	
	self:CreateRows()
	--self:Refresh()
end

function GVSTab:OnHide()
	--print('GVSTab:OnHide()')
	--GVS:Unhook('HandleModifiedItemClick')
	GVS:Unhook('ChatEdit_InsertLink')
	if StackSplitFrame:IsVisible() then StackSplitFrame:Hide() end
end


GVSTab:SetScript('OnShow', GVSTab.OnShow)
GVSTab:SetScript('OnHide', GVSTab.OnHide)


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







function GVS.Purchase(id, quantity)
	local _, _, _, vendorStackSize, numAvailable = GetMerchantItemInfo(id)
	local maxPurchase = GetMerchantItemMaxStack(id)
	
	--print('GVS.Purchase('.. id ..','.. quantity ..'): maxPurchase = '.. maxPurchase)
	-- fix bug of buying only 5 when vendorStackSize == 5
	if  vendorStackSize == 5  then  maxPurchase = vendorStackSize  end

	if numAvailable > 0 and numAvailable < quantity then quantity = numAvailable end
	local purchased = 0
	while purchased < quantity do
		local buyamount = math.min(maxPurchase, quantity - purchased)
		purchased = purchased + buyamount
		BuyMerchantItem(id, buyamount)
	end
end



-- Create scrollbar
do
	local scrollbar = LibStub("tekKonfig-Scroll").new(GVSTab, 0, SCROLLSTEP)
	GVSTab.scrollbar = scrollbar
	GVSTab.offset = 0

	local hookedOnValueChanged = scrollbar:GetScript("OnValueChanged")
	scrollbar:SetScript("OnValueChanged", function(self, value, ...)
		--GVSTab.offset = math.floor(value)
		GVSTab:RefreshVisibleItems( math.floor(value) )
		return hookedOnValueChanged(self, value, ...)
	end)

	GVSTab:EnableMouseWheel(true)
	GVSTab:SetScript("OnMouseWheel", function(self, value) scrollbar:SetValue(scrollbar:GetValue() - value * SCROLLSTEP) end)
end

-- Create editbox
do
	local editbox = CreateFrame('EditBox', nil, MerchantFrame)
	GVS.editbox = editbox
	editbox:SetAutoFocus(false)
	editbox:SetPoint("BOTTOMLEFT", GVSTab, "TOPLEFT", 55, 9)
	editbox:SetWidth(105)
	editbox:SetHeight(32)
	editbox:SetFontObject('GameFontHighlightSmall')

	local backdrop = editbox:CreateTexture(nil, "BACKGROUND")
	--backdrop:SetAllPoints()
	backdrop:SetPoint("TOPLEFT", -3, -9)
	backdrop:SetPoint("BOTTOMRIGHT", -2, 8)
	backdrop:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	backdrop:SetGradientAlpha("HORIZONTAL", unpack(grads[2]))  -- or grads[7]
	editbox.backdrop = backdrop
	editbox:SetBackdrop(backdrop)

	local left = editbox:CreateTexture(nil, "BACKGROUND")
	left:SetWidth(8) left:SetHeight(20)
	left:SetPoint("LEFT", -5, 0)
	left:SetTexture("Interface\\Common\\Common-Input-Border")
	left:SetTexCoord(0, 0.0625, 0, 0.625)

	local right = editbox:CreateTexture(nil, "BACKGROUND")
	right:SetWidth(8) right:SetHeight(20)
	right:SetPoint("RIGHT", 0, 0)
	right:SetTexture("Interface\\Common\\Common-Input-Border")
	right:SetTexCoord(0.9375, 1, 0, 0.625)

	local center = editbox:CreateTexture(nil, "BACKGROUND")
	center:SetHeight(20)
	center:SetPoint("RIGHT", right, "LEFT", 0, 0)
	center:SetPoint("LEFT", left, "RIGHT", 0, 0)
	center:SetTexture("Interface\\Common\\Common-Input-Border")
	center:SetTexCoord(0.0625, 0.9375, 0, 0.625)

	editbox.placeholder = "Search..."
	GVS.searchstring = ""

	function editbox:ShowPlaceholder(show)
		if  show  then
			self.placeholderShown = true
			if  self:GetText() ~= self.placeholder  then  self:SetText(self.placeholder)  end
			self:SetTextColor(0.75, 0.75, 0.75, 1)
		elseif  self.placeholderShown  then
			self.placeholderShown = false
			if  self:GetText() == self.placeholder  then  self:SetText(GVS.searchstring)  end
			self:SetTextColor(1,1,1,1)
		end
	end

	editbox:SetScript('OnEscapePressed', editbox.ClearFocus)
	editbox:SetScript('OnEnterPressed', editbox.ClearFocus)
	editbox:SetScript('OnEditFocusGained', function(self)
		self:ShowPlaceholder(false)
		self:HighlightText()
	end)
	editbox:SetScript('OnEditFocusLost', function(self)
		if  GVS.searchstring == ""  then  self:ShowPlaceholder(true)  end
	end)
	
	editbox:SetScript('OnTextChanged', function(self)
		local t = self:GetText()
		--print('GVS.editbox.OnTextChanged(): "'..GVS.searchstring..'" -> "'..t..'"')
		if  self.placeholderShown  and  t == self.placeholder  then  t = ""  end
		GVS.searchstring = t
		--[[
		if  t ~= ''  then  self:SetBackdropColor(0.5,0.75,0.75,0.5)
		else  self:SetBackdropColor(0,0,0,0)  end
		--]]
		self.backdrop:SetShown(t ~= '')
		
		if  not self.searchChanged  then
			self:SetScript('OnUpdate', self.OnUpdate)
		end
		self.searchChanged = GetTime()
	end)
	
	local SEARCH_REFRESH_DELAY = 0.2    -- seconds
	
	function editbox:OnUpdate(elapsed)
		if  self.searchChanged  and  SEARCH_REFRESH_DELAY <= GetTime() - self.searchChanged  then
			self.searchChanged = nil
			self:SetScript('OnUpdate', nil)
			GVSTab:Refresh()
			local backColor = searchColor[ GVS.FilteredItems  and  #GVS.FilteredItems > 0  or  false ]
			GVS.editbox.backdrop:SetGradientAlpha("HORIZONTAL", unpack(backColor))
		end
	end
	--[[
/run GVS.Tab.editbox.backdrop:SetGradientAlpha("HORIZONTAL", 1,1,1,1, 1,1,1,1 )
/run GVS.Tab.editbox.backdrop:SetGradientAlpha("HORIZONTAL", 1,0.7,0.3,1, 1,0.7,0.3,0.3 )
/run GVS.Tab.editbox.backdrop:SetGradientAlpha("HORIZONTAL", 1,0,0,1, 1,0,0,0.3 )
/run GVS.Tab.editbox:SetBackdropColor(1,1,1,1)
/run GVS.Tab.editbox:SetBackdrop(nil)
/run GVS.Tab.editbox.backdrop:SetPoint("TOPLEFT", -3, -9) ; GVS.Tab.editbox.backdrop:SetPoint("BOTTOMRIGHT", -2, 8)
/run GVS.Tab.editbox.backdrop:SetGradientAlpha()
/run GVS.Tab.editbox:SetPoint("BOTTOMLEFT", GVSTab, "TOPLEFT", 55, 9) ; GVS.Tab.editbox:SetWidth(105) ; GVS.Tab.editbox:SetHeight(32)
	--]]
	
	editbox:SetScript('OnShow', function(self)
		self:ShowPlaceholder(GVS.searchstring == "")
	end)
	editbox:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
		GameTooltip:AddLine("Enter an item name to search")
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("Type search:", "bop   boe   bou", nil,nil,nil, 255,255,255)
		GameTooltip:AddDoubleLine(" ", "boa   quest", 255,255,255, 255,255,255)
		GameTooltip:AddDoubleLine(" ", "ilvl>=378  ilvl=359", 255,255,255, 255,255,255)
		GameTooltip:AddDoubleLine(" ", "q=rare   q<4", 255,255,255, 255,255,255)
		GameTooltip:AddDoubleLine(" ", "t:leather   t:shield", 255,255,255, 255,255,255)
		GameTooltip:AddDoubleLine("Modifiers:", "&   Match both", nil,nil,nil, 255,255,255)
		GameTooltip:AddDoubleLine(" ", "|   Match either", 255,255,255, 255,255,255)
		GameTooltip:AddDoubleLine(" ", "!   Do not match", 255,255,255, 255,255,255)
		GameTooltip:Show()
	end)
	editbox:SetScript('OnLeave', function(self)
		GameTooltip:Hide()
	end)
end    -- Create editbox




local function RowBuyItem(self, fullstack)
	local id = self:GetID()
	local link = GetMerchantItemLink(id)
	if not link then return end

	local _, _, _, vendorStackSize = GetMerchantItemInfo(id)
	local _, _, _, _, _, _, _, itemStackSize = GetItemInfo(link)
	GVS.Purchase(id, fullstack and itemStackSize or vendorStackSize or 1)
end

local function RowOnClick(self, button)
	-- Finished editing search text, regain "WASD controls (or QWES :-)"
	GVS.editbox:ClearFocus()
	
	--if IsAltKeyDown() and not self.altcurrency then self:BuyItem(true)
	if IsModifiedClick('FULLSTACK') and not self.altcurrency then
		RowBuyItem(self, true)
		
	elseif IsModifiedClick() then
		-- This would spoil the call chain if it was hooked after GVSTab, which is pretty likely as many addons hook it:
		--local HandleModifiedItemClick = GVSTab.hooks.HandleModifiedItemClick  or  _G.HandleModifiedItemClick
		
		-- Don't search for the item if clicking in the vendor frame
		GVSTab.onClickInGVS = true
		HandleModifiedItemClick( GetMerchantItemLink(self:GetID()) )
		GVSTab.onClickInGVS = false
		
	elseif self.altcurrency then
		local id = self:GetID()
		local link = GetMerchantItemLink(id)
		self.link, self.texture = GetMerchantItemLink(id), self.icon:GetTexture()
		MerchantFrame_ConfirmExtendedItemCost(self)
		
	else
		RowBuyItem(self)
	end
end

local function RowOnDragStart(self, button)
	MerchantFrame.extendedCost = nil
	PickupMerchantItem(self:GetID())
	if self.extendedCost then MerchantFrame.extendedCost = self end
end

local function RowOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetMerchantItem(self:GetID())
	GameTooltip_ShowCompareItem()
	MerchantFrame.itemHover = self:GetID()
	if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
end

local function RowOnLeave(self)
	GameTooltip:Hide()
	ResetCursor()
	MerchantFrame.itemHover = nil
end


local function PopoutOnClick(self, button)
	local id = self:GetParent():GetID()
	local link = GetMerchantItemLink(id)
	if not link then return end

	local _, _, _, vendorStackSize, numAvailable = GetMerchantItemInfo(id)
	local maxPurchase = GetMerchantItemMaxStack(id)
	local _, _, _, _, _, _, _, itemStackSize = GetItemInfo(link)

	local size = numAvailable > 0 and numAvailable or 20*itemStackSize+1
	OpenStackSplitFrame(size, self, "LEFT", "RIGHT")
	-- OpenStackSplitFrame(250, self, "LEFT", "RIGHT")
end

local function PopoutSplitStack(self, qty)
	GVS.Purchase(self:GetParent():GetID(), qty)
end


local function AltCurrencyOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if self.link then GameTooltip:SetHyperlink(self.link) else GameTooltip:SetMerchantCostItem(self.index, self.itemIndex) end
end

local function AltCurrencyOnLeave()
	GameTooltip:Hide()
	ResetCursor()
end

local function GetCurrencyCount(item)
	if  not GVS.AltCurrencyCount  then  print('GVS.GetCurrencyCount('..item..'): SetValue() out of RefreshVisibleItems() - no AltCurrencyCount cache')
	elseif  GVS.AltCurrencyCount[item]  then  return GVS.AltCurrencyCount[item]  end
	
	for i=1,GetCurrencyListSize() do
		local name, _, _, _, _, count = GetCurrencyListInfo(i)
		if item == name then
			if  GVS.AltCurrencyCount  then  GVS.AltCurrencyCount[item] = count  end
			return count
		end
	end
end

local function AltCurrencySetValue(self, text, icon, link)
	local color = ""
	local itemID = link and link:match("item:(%d+)")
	self.link, self.index, self.itemIndex = nil
	if  itemID  then  self.link = link  end
	
	if  itemID and (GetItemCount(itemID) or 0) < text
		or  link and not itemID and (GetCurrencyCount(link) or 0) < text
	then
		color = "|cffff9999"
	end
	self.text:SetText(color..text)
	self.icon:SetTexture(icon)
	self:Show()
end


local function GetAltCurrencyFrame(frame)
	for i,v in ipairs(frame.altframes) do if not v:IsShown() then return v end end

	local anchor = #frame.altframes > 0 and frame.altframes[#frame.altframes].text
	local f = CreateFrame('Frame', nil, frame)
	f:SetWidth(ICONSIZE) f:SetHeight(ICONSIZE)
	f:SetPoint("RIGHT", anchor or frame.ItemPrice, "LEFT")

	f.icon = f:CreateTexture()
	f.icon:SetWidth(ICONSIZE) f.icon:SetHeight(ICONSIZE)
	f.icon:SetPoint("RIGHT")

	f.text = f:CreateFontString(nil, nil, "NumberFontNormalSmall")
	f.text:SetPoint("RIGHT", f.icon, "LEFT", -GAP/2, 0)

	f.SetValue = AltCurrencySetValue

	f:EnableMouse(true)
	f:SetScript("OnEnter", AltCurrencyOnEnter)
	f:SetScript("OnLeave", AltCurrencyOnLeave)

	table.insert(frame.altframes, f)
	return f
end


local function AddAltCurrency(frame, i)
	local lastframe = frame.ItemPrice
	local honorPoints, arenaPoints, itemCount = GetMerchantItemCostInfo(i)
	if ns.IHASCAT then itemCount, honorPoints, arenaPoints = honorPoints, 0, 0 end
	for j=itemCount,1,-1 do
		local f = frame:GetAltCurrencyFrame()
		local texture, price, link, name = GetMerchantItemCostItem(i, j)
		f:SetValue(price, texture, link or name)
		f.index, f.itemIndex, f.link = i, j
		lastframe = f.text
	end
	if arenaPoints > 0 then
		local f = frame:GetAltCurrencyFrame()
		f:SetValue(arenaPoints, "Interface\\PVPFrame\\PVP-ArenaPoints-Icon", ARENA_POINTS)
		lastframe = f.text
	end
	if honorPoints > 0 then
		local f = frame:GetAltCurrencyFrame()
		f:SetValue(honorPoints, "Interface\\PVPFrame\\PVP-Currency-".. UnitFactionGroup("player"), HONOR_POINTS)
		lastframe = f.text
	end
	frame.ItemName:SetPoint("RIGHT", lastframe, "LEFT", -GAP, 0)
end



local function RowSetItem(row, vendorIdx)
	-- vendorIdx == id
	if  not vendorIdx  or  vendorIdx > GetMerchantNumItems()  then
		row:Hide()
		row:SetID(0)
		return
	end

	row:SetID(vendorIdx)
	local name, itemTexture, itemPrice, itemStackCount, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(vendorIdx)
	local link = GetMerchantItemLink(vendorIdx)
	local color = quality_colors.default
	row.backdrop:Hide()
	if link then
		local name, link2, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(link)
		color = quality_colors[quality]

		if class == RECIPE and not ns.knowns[link] then
			row.backdrop:SetGradientAlpha("HORIZONTAL", unpack(grads[quality]))
			row.backdrop:Show()
		end
		
	elseif  not name  then
		-- Data not ready, update later
		row:Hide()
		return
	end

	if not isUsable then
		row.backdrop:SetGradientAlpha("HORIZONTAL", unpack(grads.red))
		row.backdrop:Show()
	end

	row.icon:SetTexture(itemTexture)
	row.ItemName:SetText((numAvailable > -1 and ("["..numAvailable.."] ") or "").. color.. (name or "<Loading item data>").. (itemStackCount > 1 and ("|r x"..itemStackCount) or ""))
	
	if  link  and  link == GVS.highlightedLink  then
		row:LockHighlight()
	else
		row:UnlockHighlight()
	end

	for  _,v  in  pairs(row.altframes)  do  v:Hide()  end
	row.altcurrency = extendedCost
	if extendedCost then
		row:AddAltCurrency(vendorIdx)
		row.link, row.texture, row.extendedCost = link, itemTexture, true
	end
	if itemPrice > 0 then
		row.ItemPrice:SetText(ns.GSC(itemPrice))
		row.Price = itemPrice
	end
	if extendedCost and (itemPrice <= 0) then
		row.ItemPrice:SetText()
		row.Price = 0
	elseif extendedCost and (itemPrice > 0) then
		row.ItemPrice:SetText(ns.GSC(itemPrice))
	else
		row.ItemName:SetPoint("RIGHT", row.ItemPrice, "LEFT", -GAP, 0)
		row.extendedCost = nil
	end

	if isUsable then row.icon:SetVertexColor(1, 1, 1) else row.icon:SetVertexColor(.9, 0, 0) end
	row:Show()
end




function GVSTab:CreateRows()
	NUMROWS = math.floor( self:GetHeight() / ROWHEIGHT + 0.5 )
	self.rows = self.rows  or  {}
	-- Create new rows
	for  i = #self.rows + 1, NUMROWS  do
		self:CreateRow(i)
	end
	-- Delete unneccessary rows
	for  i = #self.rows, NUMROWS + 1, -1  do
		local row = self.rows[i]
		row:SetParent(nil)
		self.rows[i] = nil
	end
end

function GVSTab:DeleteRows()
	if  not self.rows  then  return  end
	for  i,row  in  ipairs(self.rows)  do
		row:SetParent(nil)
	end
	self.rows = nil
end

function GVSTab:CreateRow(i)
	local row = CreateFrame('Button', nil, self) -- base frame
	row:SetHeight(ROWHEIGHT)
	if  i == 1  then  row:SetPoint("TOP", self)
	else  row:SetPoint("TOP", self.rows[i-1], "BOTTOM")
	end
	row:SetPoint("LEFT")
	row:SetPoint("RIGHT", -19, 0)

	row:SetHighlightTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
	row:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.578125)

	row.BuyItem = RowBuyItem
	row:RegisterForClicks('AnyUp')
	row:SetScript('OnClick', RowOnClick)
	row:RegisterForDrag('LeftButton')
	row:SetScript('OnDragStart', RowOnDragStart)

	local backdrop = row:CreateTexture(nil, "BACKGROUND")
	backdrop:SetAllPoints()
	backdrop:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	row.backdrop = backdrop

	local icon = CreateFrame('Frame', nil, row)
	icon:SetHeight(ICONSIZE)
	icon:SetWidth(ICONSIZE)
	icon:SetPoint('LEFT', 2, 0)

	row.icon = icon:CreateTexture(nil, "BORDER")
	row.icon:SetAllPoints()

	local ItemName = row:CreateFontString(nil, nil, "GameFontNormalSmall")
	ItemName:SetPoint('LEFT', icon, "RIGHT", GAP, 0)
	ItemName:SetJustifyH('LEFT')
	row.ItemName = ItemName

	local popout = CreateFrame("Button", nil, row)
	popout:SetPoint("RIGHT")
	popout:SetWidth(ROWHEIGHT/2) popout:SetHeight(ROWHEIGHT)
	popout:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton")
	popout:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton")
	popout:GetNormalTexture():SetTexCoord(0.15625, 0.5, 0.84375, 0.5, 0.15625, 0, 0.84375, 0)
	popout:GetHighlightTexture():SetTexCoord(0.15625, 1, 0.84375, 1, 0.15625, 0.5, 0.84375, 0.5)
	popout:SetScript("OnClick", PopoutOnClick)
	popout.SplitStack = PopoutSplitStack
	row.popout = popout

	local ItemPrice = row:CreateFontString(nil, nil, "NumberFontNormal")
	ItemPrice:SetPoint('RIGHT', popout, "LEFT", -2, 0)
	row.ItemPrice = ItemPrice

	row.altframes = {}
	row.AddAltCurrency, row.GetAltCurrencyFrame = AddAltCurrency, GetAltCurrencyFrame

	row:SetScript('OnEnter', RowOnEnter)
	row:SetScript('OnLeave', RowOnLeave)
	
	self.rows[i] = row
end




function GVSTab:Refresh()
	--print('GVSTab:Refresh()')
	if  not self:IsVisible()  then  return  end
	
	-- Reset currency cache
	self.AltCurrencyCount = {}
	
	GVS:RefreshFiltered()
	self:RefreshVisibleItems()
	
	-- Reset currency cache
	self.AltCurrencyCount = nil
end


function GVS:RefreshFiltered()
	if  "" == self.searchstring  then
		self.FilteredItems = nil
		return
	end
	
	--FilteredItems = {}
	-- Reuse array from previous search
	local FilteredItems = self.FilteredItems  or  {}
	local lastFiltered = #FilteredItems
	local numFilteredItems = 0
	local searchLowCase = self.searchstring:lower()
	
	-- Iterate vendor items
	for  id = 1,GetMerchantNumItems()  do
		local link = GetMerchantItemLink(id)
		if  link == self.highlightedLink  or  ItemSearch:Find(link, searchLowCase)  then
			numFilteredItems = numFilteredItems + 1
			FilteredItems[numFilteredItems] = id
		end
	end
	-- Clear the leftover items from previous search
	for  i = lastFiltered,numFilteredItems+1, -1  do
		FilteredItems[i] = nil
	end
	
	self.FilteredItems = FilteredItems
end


function GVSTab:RefreshScrollBar()
	-- Adjust scrollbar to new item count
	local numFilteredItems = GVS.FilteredItems  and  #GVS.FilteredItems  or  GetMerchantNumItems()
	local maxScroll = math.max(0, numFilteredItems - NUMROWS)
	local scrollbar = self.scrollbar
	scrollbar:SetMinMaxValues(0, maxScroll)
	scrollbar:SetValue( math.min(scrollbar:GetValue(), maxScroll) )
end


function GVSTab:RefreshVisibleItems(newOffset)
	if  newOffset  then  self.offset = newOffset  end
	
	if  GVS.FilteredItems  then
		for  i = 1, NUMROWS  do  RowSetItem(self.rows[i], GVS.FilteredItems[self.offset + i])  end
	else
		for  i = 1, NUMROWS  do  RowSetItem(self.rows[i], self.offset + i)  end
	end
	
	self:RefreshScrollBar()
end


function GVSTab:RefreshHighlighted()
	for  i,row  in  ipairs(self.rows)  do
		local link = GetMerchantItemLink(row:GetID())
		if  link  and  link == GVS.highlightedLink  then
			row:LockHighlight()
		else
			row:UnlockHighlight()
		end
	end
end




function GVSTab:OnItemLink(searchLink)
	-- Do nothing if GVS is hidden but the hook is still in place (failed to Unhook)
	if  not searchLink  or  not self:IsVisible()  then  return  end
	-- Leave it for the chat editbox if it's open
	if  ChatEdit_GetActiveWindow()  then  return  end
	-- Don't react if Shift-Clicking in vendor frame || Actually, highlight it, cause why not
	--if  self.onClickInGVS  then  return  end
	
	--local itemID, itemName = searchLink:match('%|Hitem:(%d*):%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*%|h%[(.-)%]')
	--local itemID, itemName = searchLink:match('\124Hitem:(%d*):%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*\124h%[(.-)%]')
	local itemID, itemName = searchLink:match('\124Hitem:(%d-):.-\124h%[(.-)%]\124h')
	--print('GVS:OnItemLink('.. searchLink ..'): item='.. tostring(itemID))
	if  not itemName  then  return false  end
	
	--[[
	GVS.editbox:SetText(itemName)
	GVS.searchstring = itemName
	self:Refresh()
	return true
	--]]
	
	local linkMatch,idMatch,nameMatch
	for  vendorIdx = 1,GetMerchantNumItems()  do
		local link = GetMerchantItemLink(vendorIdx)
		if  link == searchLink  then
			linkMatch = vendorIdx
			break
		elseif  not idMatch  and  link:match('\124Hitem:'..itemID..':')  then
			idMatch = vendorIdx
			print('GVS:OnItemLink('.. searchLink ..'): item='.. tostring(itemID) ..'  ID matched: '.. link)
		elseif  not nameMatch  and  link:match('\124Hitem:%d-:.-\124h%['..itemName..'%]\124h')  then
			nameMatch = vendorIdx
			print('GVS:OnItemLink('.. searchLink ..'): item='.. tostring(itemID) ..'  Name matched: '.. link)
		end
	end
	
	local vendorIdx = linkMatch  or  idMatch  or  nameMatch
	
	if  not vendorIdx  then
		-- Consume Shift-Click event, although not found anything
		GVS.highlightedLink = nil
		-- Undo previously highlighted row
		self:RefreshHighlighted()
		return true
	end
	
	GVS.highlightedLink = GetMerchantItemLink(vendorIdx)
	local FilteredItems = GVS.FilteredItems
	local filteredIdx, refreshVisible
	
	if  not FilteredItems  then
		filteredIdx = vendorIdx
	else
		filteredIdx = tindexof(FilteredItems, vendorIdx)
		-- If not in filtered items then filter again, including highlightedLink
		if  not filteredIdx  then
			GVS:RefreshFiltered()
			refreshVisible = true
		end
		
		-- FilteredItems now should include vendorIdx with the item: highlightedLink
		filteredIdx = tindexof(FilteredItems, vendorIdx)
		--[[
		-- If not in filtered items then drop FilteredItems and show all items
		if  not filteredIdx  then
			self.offset = FilteredItems[self.offset]  or  0
			GVS.FilteredItems = nil
			FilteredItems = nil
			filteredIdx = vendorIdx
		end
		--]]
	end
	
	-- Safety check, this should not happen
	if  not filteredIdx  then  return  end
	
	local newOffset = self.offset
	if  newOffset + NUMROWS < filteredIdx  then
		-- Have to scroll down: scroll found item into bottom half
		local numItems = FilteredItems  and  #FilteredItems  or  GetMerchantNumItems()
		local maxOffset = math.min(0, numItems - NUMROWS)
		newOffset = math.max(maxOffset, filteredIdx-1 - NUMROWS*3/4)
	elseif  filteredIdx < newOffset  then
		-- Have to scroll up: scroll found item into top half
		newOffset = math.min(0, filteredIdx-1 - NUMROWS/4)
	end
	
	if  newOffset ~= self.offset  or  refreshVisible  then
		-- Refreshing items necessary due to offset change or RefreshFiltered()
		self:RefreshVisibleItems(newOffset)
	else
		-- Visible items did not change, only highlight this item
		self:RefreshHighlighted()
	end
	
	-- Consume Shift-Click event
	return true
end




LibStub("tekKonfig-AboutPanel").new(nil, "GVS")
GVS:OnEnable()

