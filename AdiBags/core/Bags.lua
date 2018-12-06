--[[
AdiBags - Adirelle's bag addon.
Copyright 2010-2012 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local BankFrame = _G.BankFrame
local CloseBankFrame = _G.CloseBankFrame
local ipairs = _G.ipairs
local pairs = _G.pairs
local setmetatable = _G.setmetatable
local tinsert = _G.tinsert
local tsort = _G.table.sort
--GLOBALS>

--local hookedBags = addon.hookedBags

--------------------------------------------------------------------------------
-- Bag prototype
--------------------------------------------------------------------------------

local bagProto = setmetatable({
	isBag = true,
}, { __index = addon.moduleProto })
addon.bagProto = bagProto


function bagProto:OnEnable()
	----[[ No need to replace open bags when enabling. Bags were closed by InterfaceOptionsFrame, the only place where it can be enabled.
	local open = false
	for  id in pairs(self.bagIds)  do
		if  _G.IsBagOpen(id)  then  -- use Blizzard api
			open = true
			_G.CloseBag(id)
		end
		--hookedBags[id] = self
	end
	--]]
	
	if self.PostEnable then  self:PostEnable()  end
	self:Debug('Enabled')
	if open then
		--self.autoOpened = true
		self:Open()
	end
end


function bagProto:OnDisable()
	local open = self:IsOpen()
	self:Close()
	if open then
		for  id in pairs(self.bagIds)  do  _G.OpenBag(id)  end
	end
	
	if self.PostDisable then  self:PostDisable()  end
	self:Debug('Disabled')
	-- Release frame?
end


function bagProto:Open()
	if not self:CanOpen() then return end
	local frame = self:GetFrame()
	if  not frame:IsShown()  then
		self:Debug('Open')
		frame:Show()
		addon:SendMessage('AdiBags_BagOpened', self.bagName, self)
		return true
	end
end

function bagProto:Close()
	if self.frame and self.frame:IsShown() then
		self:Debug('Close')
		self.frame:Hide()
		addon:SendMessage('AdiBags_BagClosed', self.bagName, self)
		if self.PostClose then  self:PostClose()  end
		return true
	end
end

function bagProto:IsOpen()
	return self.frame and self.frame:IsShown() or false
end

function bagProto:CanOpen()
	--return self:IsEnabled()
	return true
end

function bagProto:Toggle()
	if self:IsOpen() then
		return self:Close()
	elseif self:CanOpen() then
		return self:Open()
	end
end

function bagProto:HasFrame()
	return not not self.frame
end

function bagProto:GetFrame()
	if not self.frame then
		self.frame = self:CreateFrame()
		self.frame.CloseButton:SetScript('OnClick', function() self:Close() end)
		addon:SendMessage('AdiBags_BagFrameCreated', self)
	end
	return self.frame
end

function bagProto:CreateFrame()
	return addon:CreateContainerFrame(self.bagName, self.bagIds, self.isBank)
end

--------------------------------------------------------------------------------
-- Bags methods
--------------------------------------------------------------------------------

local bags = {}
addon.bags = bags

--[[ There are 2 bags: backpack and bank
local function CompareBags(a, b)
	return a.order < b.order
end
--]]

function addon:NewBag(name, order, bagIds, isBank, ...)
	self:Debug('NewBag', name, order, bagIds, isBank, ...)
	local bag = addon:NewModule(name, bagProto, 'AceEvent-3.0', ...)
	bag.bagName = name
	bag.bagIds = bagIds
	bag.isBank = isBank
	bag.order = order
	tinsert(bags, bag)
	--tsort(bags, CompareBags)
	-- Export to global namespace
	_G['Adi'..name] = bag
	return bag
end

-- There are 2 bags: backpack and bank
do
	local function iterateOpenBags(numBags, index)
		while index < numBags do
			index = index + 1
			local bag = bags[index]
			if bag:IsEnabled() and bag:IsOpen() then
				return index, bag
			end
		end
	end

	local function iterateBags(numBags, index)
		while index < numBags do
			index = index + 1
			local bag = bags[index]
			if bag:IsEnabled() then
				return index, bag
			end
		end
	end

	function addon:IterateBags(onlyOpen)
		return onlyOpen and iterateOpenBags or iterateBags, #bags, 0
	end
end
--]]

function addon:IterateDefinedBags()
	return pairs(bags)
end

function addon:CloseAll()
	-- Close all AdiBags
	local closed = false
	for  i, bag  in  pairs(bags)  do  closed = bag:Close()  or  closed  end
	return closed
end

--------------------------------------------------------------------------------
-- Backpack
--------------------------------------------------------------------------------

do
	-- L["Backpack"]
	local backpack = addon:NewBag("Backpack", 10, addon.BAG_IDS.BAGS, false, 'AceHook-3.0')
	bags.backpack = backpack

	function backpack:PostEnable()
		self:CheckAutoOpen(nil)
	end

	function backpack:CheckAutoOpen(requesterFrame, opened)
		local toggled
		if  next(addon.InteractingWindows)  then
			-- Opening
			if  self:IsEnabled()  and  not self:IsOpen()  and  addon.db.profile.autoOpen  then
				--print("backpack:CheckAutoOpen("..(requesterFrame:GetName() or "?")..", "..tostring(opened)..")")
				self.autoOpened = true
				toggled = self:Open()
			end
		elseif  self.autoOpened  then
			-- Closing
			toggled = self:Close()
			self.autoOpened = nil
		end
		return toggled
	end

end

--------------------------------------------------------------------------------
-- Bank
--------------------------------------------------------------------------------

do
	-- L["Bank"]
	local bank = addon:NewBag("Bank", 20, addon.BAG_IDS.BANK, true, 'AceHook-3.0')
	bags.bank = bank

	local function NOOP() end

	function bank:PostEnable()
		-- Check if bank was opened
		local open = BankFrame:IsShown()
		if  open  then
			-- BankFrame_OnHide() calls CloseBankFrame(), stopping interaction with the banker.
			-- To avoid this disable CloseBankFrame() momentarily.
			local CloseBankFrame = _G.CloseBankFrame
			_G.CloseBankFrame = NOOP
			BankFrame:Hide()
			_G.CloseBankFrame = CloseBankFrame
		end
		
		-- Take over the events from builtin BankFrame.
		self:RegisterEvent('BANKFRAME_OPENED')
		self:RegisterEvent('BANKFRAME_CLOSED')
		BankFrame:UnregisterEvent('BANKFRAME_OPENED')
		--BankFrame:UnregisterEvent('BANKFRAME_CLOSED')
		
		--[[ This is enough to disable the BankFrame, while retaining its functionality.
		-- It can be optionally opened with:
/run BankFrame:Show()
/run TogglePanel(BankFrame)
		--]]
		
		-- Fake a bank opening event if already open
		if  open  or  self.atBank  then  self:BANKFRAME_OPENED()  end
		
	end

	function bank:PostDisable()
		-- Keep listening to bank events to update self.atBank
		--self:UnregisterEvent('BANKFRAME_OPENED')
		--self:UnregisterEvent('BANKFRAME_CLOSED')
		-- Re-enable opening builtin BankFrame
		BankFrame:RegisterEvent('BANKFRAME_OPENED')
		--BankFrame:RegisterEvent('BANKFRAME_CLOSED')
		
		if  self.atBank  then
			-- Fake a bank opening event if already open
			BankFrame_OnEvent(BankFrame, 'BANKFRAME_OPENED')
			--BankFrame:GetScript('OnEvent')('BANKFRAME_OPENED')
			--BankFrame:Show()
		end
	end

	function bank:PostClose()
		-- Stop interaction with banker
		if  self.autoOpened  then
			CloseBankFrame()
			_G.CloseAllBags(self)
		end
	end

	function bank:CanOpen()
		--return addon.InteractingWindows.BANKFRAME
		return self.atBank
		--return self:IsEnabled()
	end

	function bank:BANKFRAME_OPENED()
		self.atBank = true
		if  not self:IsOpen()  then
			self.autoOpened = true
			self:Open()
			_G.OpenAllBags(self)
		end
	end
	
	function bank:BANKFRAME_CLOSED()
		self.atBank = false
		if  self.autoOpened  then
			_G.CloseAllBags(self)
			self:Close()
		end
		self.autoOpened = nil
	end
	
end

--------------------------------------------------------------------------------
-- Helper for modules
--------------------------------------------------------------------------------

local hooks = {}

function addon:HookBagFrameCreation(target, callback)
	local hook = hooks[target]
	if not hook then
		local target, callback, seen = target, callback, {}
		hook = function(event, bag)
			if seen[bag] then return end
			seen[bag] = true
			local res, msg
			if type(callback) == "string" then
				res, msg = pcall(target[callback], target, bag)
			else
				res, msg = pcall(callback, bag)
			end
			if not res then
				geterrorhandler()(msg)
			end
		end
		hooks[target] = hook
	end
	local listen = false
	for index, bag in pairs(bags) do
		if bag:HasFrame() then
			hook("HookBagFrameCreation", bag)
		else
			listen = true
		end
	end
	if listen then
		target:RegisterMessage("AdiBags_BagFrameCreated", hook)
	end
end



--[[  Bag IDs:
https://wow.gamepedia.com/BagId
--
BACKPACK_CONTAINER	0	The backpack - your intial 16 slots container that you can't change or delete.	ContainerFrame.lua
BACKPACK_CONTAINER + 1
to NUM_BAG_SLOTS	1 to 4	The bags on the character (numbered right to left).	ContainerFrame.lua
BANK_CONTAINER	-1	Bank container. Your intial 28 slots container in the bank that you can't change or delete.	BankFrame.lua
NUM_BAG_SLOTS + 1
to NUM_BAG_SLOTS + NUM_BANKBAGSLOTS	5 to 11	Bank bags.	BankFrame.lua
REAGENTBANK_CONTAINER	-3	Reagent Bank. A reagent-only bank introduced in WoD.	BankFrame.lua
KEYRING_CONTAINER	-2	Keyring. Removed and obsolete since 4.2.0, but remains in code and constants.
Trying to use it seems to return equipped items instead.	ContainerFrame.lua
-4	A 7 slots "container" that holds your bank bags themselves.	BankFrame.lua


http://wowprogramming.com/docs/api_types.html#containerID
--
Type: containerID
Identifies one of the player's bags or other containers. Possible values:

REAGENTBANK_CONTAINER: Reagent bank (-3)
KEYRING_CONTAINER: Keyring and currency bag (-2)
BANK_CONTAINER Main storage area in the bank (-1)
BACKPACK_CONTAINER: Backpack (0)
1 through NUM_BAG_SLOTS: Bag slots (as presented in the default UI, numbered right to left)
NUM_BAG_SLOTS + 1 through NUM_BAG_SLOTS + NUM_BANKBAGSLOTS: Bank bag slots (as presented in the default UI, numbered left to right)
--]]


--[[
/run invID=1 ; itemID=GetInventoryItemID('player',invID) ; print(invID ..'. item='.. itemID, GetItemInfo(itemID), 'link='.. GetInventoryItemLink('player',invID) )
GetInventoryItemID - Returns the item ID of an equipped item
GetInventoryItemLink - Returns an item link for an item in the unit's inventory

 0-19 -> gear
20-23 -> bags 1-4
24-39 -> 16 backpack contents
40-67 -> 28 base bank contents
68-74 -> bankbags 5-11
-> bags: 1-4 -> 20-23  bankbags: 5-11 -> 68-74

INVSLOT_AMMO       = 0;
INVSLOT_HEAD       = 1; INVSLOT_FIRST_EQUIPPED = INVSLOT_HEAD;
INVSLOT_NECK       = 2;
INVSLOT_SHOULDER   = 3;
INVSLOT_BODY       = 4;
INVSLOT_CHEST      = 5;
INVSLOT_WAIST      = 6;
INVSLOT_LEGS       = 7;
INVSLOT_FEET       = 8;
INVSLOT_WRIST      = 9;
INVSLOT_HAND       = 10;
INVSLOT_FINGER1        = 11;
INVSLOT_FINGER2        = 12;
INVSLOT_TRINKET1   = 13;
INVSLOT_TRINKET2   = 14;
INVSLOT_BACK       = 15;
INVSLOT_MAINHAND   = 16;
INVSLOT_OFFHAND        = 17;
INVSLOT_RANGED     = 18;
INVSLOT_TABARD     = 19;
INVSLOT_LAST_EQUIPPED = INVSLOT_TABARD;
--]]


