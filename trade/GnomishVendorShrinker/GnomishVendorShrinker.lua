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

local ADDON_NAME, ns = ...
local _G = _G
ns.IHASCAT = select(4, GetBuildInfo()) >= 40000

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

local function tindexof(arr, item)
	for i = 1,#arr  do  if  arr[i] == item  then  return i  end end
end




-- GnomishVendorShrinker main addon object
local GVS = {}
if  _G.GVS == nil  then  _G.GVS = GVS  end


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



function GVS:OnEnable()
	GVS:HookMerchantFrameOn()
	
	MerchantFrame.selectedTab = GVSTab.tabIndex
	PanelTemplates_EnableTab(MerchantFrame, GVSTab.tabIndex)
	--[[ Alternative:
	GVSTab.tabButton.isDisabled = nil
	PanelTemplates_SetTab(MerchantFrame, GVSTab.tabIndex)
	--]]
	
	if  MerchantFrame:IsVisible()  then  _G.MerchantFrame_Update()  end
end

function GVS:OnDisable()
	GVS:HookMerchantFrameOff()
	
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
	if StackSplitFrame:IsShown() then StackSplitFrame:Hide() end
end

function GVSTab:OnEvent(event, addonName)
	if  event == 'ADDON_LOADED'  and  addonName == ADDON_NAME  then
		GVSTab:SetScript('OnEvent', nil)
		GVSTab:UnregisterEvent('ADDON_LOADED')
		return GVS:OnEnable()
	end
end


GVSTab:SetScript('OnShow', GVSTab.OnShow)
GVSTab:SetScript('OnHide', GVSTab.OnHide)
GVSTab:SetScript('OnEvent', GVSTab.OnEvent)
GVSTab:RegisterEvent('ADDON_LOADED')






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






function GVS.Purchase(id, quantity)
	local _, _, _, vendorStackSize, numAvailable = GetMerchantItemInfo(id)
	local maxPurchase = GetMerchantItemMaxStack(id)
	
	--print('GVS.Purchase('.. id ..','.. quantity ..'): maxPurchase = '.. maxPurchase)
	-- fix bug of buying only 5 when vendorStackSize == 5
	if  vendorStackSize == 5  then  maxPurchase = vendorStackSize  end

	quantity =  quantity  or  1
	if  numAvailable > 0  and  numAvailable < quantity  then  quantity = numAvailable  end
	local purchased = 0
	while  purchased < quantity  do
		local buyamount = math.min(maxPurchase, quantity - purchased)
		purchased = purchased + buyamount
		BuyMerchantItem(id, buyamount)
	end
end



local function RowBuyItem(self, fullstack)
	local id = self:GetID()
	local link = GetMerchantItemLink(id)
	if  not link  then  return  end

	local _, _, _, vendorStackSize = GetMerchantItemInfo(id)
	local _, _, _, _, _, _, _, itemStackSize = GetItemInfo(link)
	local quantity = fullstack and itemStackSize  or  vendorStackSize or 1

	if  self.altcurrency  then
		self.link, self.texture = GetMerchantItemLink(id), self.icon:GetTexture()
		MerchantFrame_ConfirmExtendedItemCost(self, quantity)
	else
		GVS.Purchase(id, quantity)
	end
end

local function RowOnClick(self, button)
	-- Finished editing search text, regain "WASD" controls (or QWES :-)
	GVS.editbox:ClearFocus()
	
	--if IsAltKeyDown() and not self.altcurrency then self:BuyItem(true)
	if  IsModifiedClick('FULLSTACK')  then
		RowBuyItem(self, true)
		
	elseif IsModifiedClick() then
		-- This would spoil the call chain if it was hooked after GVSTab, which is pretty likely as many addons hook it:
		--local HandleModifiedItemClick = GVSTab.hooks.HandleModifiedItemClick  or  _G.HandleModifiedItemClick
		
		-- Don't search for the item if clicking in the vendor frame
		GVSTab.onClickInGVS = true
		HandleModifiedItemClick( GetMerchantItemLink(self:GetID()) )
		GVSTab.onClickInGVS = false
		
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

local function PopoutSplitStack(self, quantity)
	GVS.Purchase(self:GetParent():GetID(), quantity)
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
	GVS.AltCurrencyCount = {}
	
	GVS:RefreshFiltered()
	self:RefreshVisibleItems()
	
	-- Reset currency cache
	GVS.AltCurrencyCount = nil
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

