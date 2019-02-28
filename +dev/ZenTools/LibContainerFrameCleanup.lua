local LIB_NAME, LIB_REVISION = "LibContainerFrameCleanup-1.0", 5040801 -- 5.4.8 v1 / increase manually on changes
if  LibContainerFrameCleanup  and  LibContainerFrameCleanup.revision >= LIB_REVISION  then  return  end
LibContainerFrameCleanup = { revision = LIB_REVISION }


--[[
/run a={};a[#a+1]=1;a[#a+1]=2;a[#a+1]=nil;a[#a+1]=4;print(unpack(a))
/dump (ContainerIDToInventoryID(-1))
/run for id=1,11 do print(id..' -> '..ContainerIDToInventoryID(id)) end
-> bags: 1-4 -> 20-23  bankbags: 5-11 -> 68-74
/run local a={}; for n=1,13 do local f=_G['ContainerFrame'..n]; a[#a+1]=f:GetID(); end print(unpack(a))
/run DumpBags()
/run DumpBagsShort()
--]]

function DumpBags()
	for n=1,NUM_CONTAINER_FRAMES do
		local f=_G['ContainerFrame'..n];
		local id=f:GetID();
		print( n ..'.: bagID='.. id ..' bagName='.. GetBagName(id) .. ' slots='.. GetContainerNumSlots(id) ..' inventoryID='.. ContainerIDToInventoryID(id) )
	end
end

function DumpBagsShort()
	local a={}
	for n=1,NUM_CONTAINER_FRAMES do
		local f=_G['ContainerFrame'..n];
		a[#a+1]=f:GetID();
	end
	print(unpack(a))
end


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



--[[
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
NUM_CONTAINER_FRAMES = 13;
NUM_BAG_FRAMES = NUM_BAG_SLOTS;
MAX_CONTAINER_ITEMS = 36;

-- Container constants
ITEM_INVENTORY_BANK_BAG_OFFSET	= 4; -- Number of bags before the first bank bag
CONTAINER_BAG_OFFSET = 19; -- Used for PutItemInBag

BACKPACK_CONTAINER = 0;
BANK_CONTAINER = -1;
BANK_CONTAINER_INVENTORY_OFFSET = 39; -- Used for PickupInventoryItem
KEYRING_CONTAINER = -2;

NUM_BAG_SLOTS = 4;
NUM_BANKGENERIC_SLOTS = 28;
NUM_BANKBAGSLOTS = 7;

--
-- Equipment Set
--
MAX_EQUIPMENT_SETS_PER_PLAYER = 10;
EQUIPMENT_SET_EMPTY_SLOT = 0;
EQUIPMENT_SET_IGNORED_SLOT = 1;
EQUIPMENT_SET_ITEM_MISSING = -1;
--]]


-- 1-4 -> BACKPACK_CONTAINER+1 .. NUM_BAG_SLOTS
-- 5-11 -> NUM_BAG_SLOTS+1 .. NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
local NUM_BAG_AND_BANK_SLOTS = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS    -- 4+7 = 11
local ADDITIONAL_CONTAINER = NUM_CONTAINER_FRAMES + 1

local ContainerFrames = {}
_G.ContainerFrames = ContainerFrames

do
	--for  id = 1, NUM_CONTAINER_FRAMES  do    -- 1 to 13
	for  id = 1, NUM_BAG_AND_BANK_SLOTS  do    -- 1 to 11
		ContainerFrames[id] = _G["ContainerFrame"..id]
	end
	
	-- Special container frames -1, 0, -2
	-- BANK_CONTAINER = -1  ->  _G["ContainerFrame-1"]
	-- BACKPACK_CONTAINER = 0  ->  _G.ContainerFrame0
	-- KEYRING_CONTAINER = -2  ->  _G["ContainerFrame-2"]    -- Removed and obsolete since 4.2.0
	
	-- Map special container frames -1, 0  ->  12, 13
	ContainerFrames[BANK_CONTAINER] = _G["ContainerFrame"..(NUM_CONTAINER_FRAMES + BANK_CONTAINER)]            -- BANK_CONTAINER = -1  ->  12
	ContainerFrames[BACKPACK_CONTAINER] = _G["ContainerFrame"..(NUM_CONTAINER_FRAMES + BACKPACK_CONTAINER)]    -- BACKPACK_CONTAINER = 0  ->  13
	--ContainerFrames[KEYRING_CONTAINER] = _G["ContainerFrame"..(NUM_CONTAINER_FRAMES + KEYRING_CONTAINER)]    -- KEYRING_CONTAINER = -2  ->  14
	
	-- Map global frame names
	_G["ContainerFrame"..BANK_CONTAINER] = ContainerFrames[BANK_CONTAINER]           -- _G["ContainerFrame-1"] -> ContainerFrame12
	_G["ContainerFrame"..BACKPACK_CONTAINER]  = ContainerFrames[BACKPACK_CONTAINER]  -- _G.ContainerFrame0     -> ContainerFrame13
	
	-- Use the last bank bag frame if some rogue code calls ContainerFrame_GetOpenFrame()
	ContainerFrames[ADDITIONAL_CONTAINER] = ContainerFrames[NUM_BAG_AND_BANK_SLOTS]
	-- Use the last bank bag frame if some rogue code tinkers with the removed KeyRing
	ContainerFrames[KEYRING_CONTAINER] = ContainerFrames[ADDITIONAL_CONTAINER]

	--[[
	No need for more container frames: 13 is the max used.
	Only -1 and 0 needed to be mapped to the actual ContainerFrame12 and ContainerFrame13.
	Now all the overcomplicated dynamic mapping code can be removed.
	
	function CreateContainerFrame(id)
		-- from ContainerFrame.xml:  <Frame name="ContainerFrame13" inherits="ContainerFrameTemplate" parent="UIParent" id="100" hidden="true"/>
		local frame = CreateFrame('Frame', "ContainerFrame"..id, UIParent, 'ContainerFrameTemplate')
		frame:SetID(100)
		frame:Hide()
		return frame
	end

	-- Create missing container frames
	--for  id = KEYRING_CONTAINER, BACKPACK_CONTAINER  do  ContainerFrames[id] = CreateContainerFrame(id)  end
	
	-- Increase number of container frames
	--NUM_CONTAINER_FRAMES = NUM_BAG_AND_BANK_SLOTS + 3    -- 11+3 = 14
	--for  id = #ContainerFrames + 1, NUM_CONTAINER_FRAMES  do  ContainerFrames[id] = CreateContainerFrame(id)  end
	--]]
end





function GetOpenContainer(id)
	local frame = ContainerFrames[id]
	if  not frame  then  print('GetOpenContainer('..tostring(id)..'): missing container frame')  end
	return  frame  and  frame:IsShown() and  frame:GetID() == id  and  frame
end

function GetContainerNumSlotsWithKeyring(id)
	return  id == KEYRING_CONTAINER  and  GetKeyRingSize()  or  GetContainerNumSlots(id)
end


-- Deprecated, used only by ContainerFrame.lua functions that are overwritten here to not use it.
function ContainerFrame_GetOpenFrame()
	local frame = ContainerFrames[ADDITIONAL_CONTAINER]
	frame:Hide()
	return frame
end

local function CheckCanOpen()
	--[[ If the user wants the user shall open bags on option frame or while dead
	if  not CanOpenPanels()  then
		if  UnitIsDead("player")  then  NotWhileDeadError()  end
		return false
	end
	--]]
	return true
end



--[[ This variant is too long, sticking to separate OpenContainer and CloseContainer
function SetContainerOpened(id, openit)
	local frame = ContainerFrames[id]
	
	-- Is there a frame allocated for this container?
	if  not frame  then  return nil  end
	-- Initialized for this container?
	local sameID =  frame:GetID() == id
	
	-- Want to close it?
	if  not openit  then
		-- Do nothing if closed
		if  not sameID  or  not frame:IsShown()  then  return false  end
		
		-- Original calls UpdateNewItemList(frame) only from CloseBag() and CloseBackpack(), not keyring
		UpdateNewItemList(frame)
		frame:Hide()
		
			-- Hide the token bar if closing the backpack
		if  id == BACKPACK_CONTAINER  and  BackpackTokenFrame  then  BackpackTokenFrame:Hide()  end
		return true
		
	elseif  GetContainerNumSlots(id) <= 0  and  id ~= KEYRING_CONTAINER  then
		-- Do not open empty bag slots. KeyRing might be an excecption.
		return false
		
	elseif  not sameID  then
		-- Different container was using this frame
		frame:Hide()
		ContainerFrame_GenerateFrame(frame, GetContainerNumSlotsWithKeyring(id), id)
		
	elseif  not frame:IsShown()  then
		-- Add the bag to the baglist
		frame:Show()
		-- Re-layout bags
		UpdateContainerFrameAnchors()
		-- Raise on top of other frames in same strata
		frame:Raise()
		
	else  -- is already open
		return false
	end
	
	if  id == BACKPACK_CONTAINER  and  ManageBackpackTokenFrame  then
		-- If there are tokens watched then show the bar
		BackpackTokenFrame_Update()
		ManageBackpackTokenFrame()
	end
	
	return true
end
--]]


function OpenContainer(id)
	-- Do not open empty bag slots. KeyRing might be an excecption.
	if  GetContainerNumSlots(id) <= 0  and  id ~= KEYRING_CONTAINER  then  return false  end
	
	local frame = ContainerFrames[id]
	
	-- Is there a frame allocated for this container?
	if  not frame  then  return nil  end
	
	if  frame:GetID() ~= id  then
		-- Different container was using this frame
		frame:Hide()
		ContainerFrame_GenerateFrame(frame, GetContainerNumSlotsWithKeyring(id), id)
		
	elseif  not frame:IsShown()  then
		-- Add the bag to the baglist
		frame:Show()
		-- Re-layout bags
		UpdateContainerFrameAnchors()
		-- Raise on top of other frames in same strata
		frame:Raise()
		
	else  -- is already open
		return false
	end
	
	if  id == BACKPACK_CONTAINER  and  ManageBackpackTokenFrame  then
		-- If there are tokens watched then show the bar
		BackpackTokenFrame_Update()
		ManageBackpackTokenFrame()
	end
	
	return true
end


function CloseContainer(id)
	local frame = GetOpenContainer(id)
	if  not frame  then  return false  end
	
	-- Original calls UpdateNewItemList(frame) only from CloseBag() and CloseBackpack(), not keyring and bank?
	UpdateNewItemList(frame)
	frame:Hide()
	
		-- Hide the token bar if closing the backpack
	if  id == BACKPACK_CONTAINER  and  BackpackTokenFrame  then  BackpackTokenFrame:Hide()  end
	
	return true
end



function ToggleContainer(id)  return  CloseContainer(id)  or  OpenContainer(id)  end
-- Called by clicks on bagbar  and  keybindings TOGGLEBAG*, TOGGLEBACKPACK -> ToggleBackpack() -> ToggleBag(0) if opening it
_G.ToggleBag = ToggleContainer
-- Called by ToggleAllBags, OpenAllBags
_G.OpenBag = OpenContainer
-- Called by CloseBankBagFrames, ToggleAllBags, CloseAllBags
_G.CloseBag = CloseContainer
-- Called by ToggleBackpack, ToggleAllBags, OpenAllBags, ToggleKeyRing, GetBackpackFrame
function IsBagOpen(id)  return  GetOpenContainer(id) and id  end

--[[ Alternative with non-dead check:
function ToggleBag(id)
	--if  not CheckCanOpen()  then  return false  end
	return ToggleContainer(id)
end
--]]



function ToggleBackpack()
	-- Called by BackpackButton_OnClick(), OpenBackpack(), TOGGLEBACKPACK binding
	--if  not CheckCanOpen()  then  return false  end
	
	if  CloseContainer(BACKPACK_CONTAINER)  then
		-- Close inventory bags (1-4)
		-- NOT closing the bank, compared to original
		--for  id = 1, NUM_BAG_SLOTS  do  CloseContainer(id)  end
		CloseManyContainers(BACKPACK_CONTAINER+1, NUM_BAG_SLOTS)
		
	else
		return OpenContainer(BACKPACK_CONTAINER)
	end
	
	return true
end

--[[
The original implementation of OpenBackpack() calls ToggleBackpack(), this dependency is inverted here.
Also sets  ContainerFrame1.backpackWasOpen = 1  if the frame was already open,
which is dead code, Blizzard luckily does not call it in such case
as it would cause a locked backpack that cannot be closed:
CloseBackpack() does not reset it.
--]]
-- Called by ToggleAllBags(), OpenAllBags()
function OpenBackpack()  return OpenContainer(BACKPACK_CONTAINER)  end
-- Called by ToggleAllBags(), CloseAllBags()
function CloseBackpack()  return CloseContainer(BACKPACK_CONTAINER)  end
-- Used by AddOns\...\Blizzard_TokenUI.lua # ManageBackpackTokenFrame(backpack)
function GetBackpackFrame()  return GetOpenContainer(BACKPACK_CONTAINER)  end
-- Should be used by TOGGLEKEYRING binding, but it is missing from Bindings.xml
-- Is this a relic from WotLK?
function ToggleKeyRing()  return ToggleContainer(KEYRING_CONTAINER)  end




--[[
function SetManyContainersOpened(first, last, opened)
	local changed
	for  id = first, last  do  changed = SetContainerOpened(id, opened) or changed  end
	return changed
end
--]]

function OpenManyContainers(first, last)
	local changed
	for  id = first, last  do  changed = OpenContainer(id) or changed  end
	return changed
end

function CloseManyContainers(first, last)
	local changed
	for  id = first, last  do  changed = CloseContainer(id) or changed  end
	return changed
end



function ToggleAllBags()
	-- Called by keybinding OPENALLBAGS  and  clicks on bagbar if IsModifiedClick("OPENALLBAGS")
	--if  not CheckCanOpen()  then  return false  end
	if  not UIParent:IsShown()  then  return  end
	
	-- First: open all inventory bags, return if opened any inventory bags
	if  OpenManyContainers(BACKPACK_CONTAINER, NUM_BAG_SLOTS)  then  return true  end

	-- 2nd: open all bank bags if BankFrame is open, return if opened any bank bags
	if  BankFrame:IsShown()  then
		if  OpenManyContainers(NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS)  then  return true  end
	end

	-- 3rd: if every inventory bag and bank bag (if at bank) was open then close all
	return CloseManyContainers(BACKPACK_CONTAINER, NUM_BANKBAGSLOTS)
end


--FRAME_THAT_OPENED_BAGS = nil;
local  OpenAllRequesterFrames = {}

function OpenAllBags(requesterFrame)
	-- Called by BankFrame_OnShow, MailFrame_OnEvent(MAIL_SHOW), MerchantFrame_OnShow -- only interacting windows
	if  not UIParent:IsShown()  then  return  end
	
	-- Do nothing if any bag is open
	for  id = BACKPACK_CONTAINER, NUM_BAG_SLOTS  do  if  IsBagOpen(id)  then  return false  end end

	if  requesterFrame  then
		local key = requesterFrame:GetName()  or  requesterFrame
		OpenAllRequesterFrames[key] = requesterFrame
		FRAME_THAT_OPENED_BAGS = FRAME_THAT_OPENED_BAGS  or  key
	end
	
	return OpenManyContainers(BACKPACK_CONTAINER, NUM_BAG_SLOTS)
end


function CloseAllBags(requesterFrame)
	-- Called by BankFrame_OnHide, MailFrame_OnEvent(MAIL_CLOSED), MerchantFrame_OnHide -- interacting windows
	-- and  BarberShop_OnShow  and...  FramePositionDelegate:ShowUIPanel(frame, force)  if not GetUIPanelWindowInfo(frame, "allowOtherPanels")
	
	if  requesterFrame  then
		local key = requesterFrame:GetName()  or  requesterFrame
		if  FRAME_THAT_OPENED_BAGS == key  then  FRAME_THAT_OPENED_BAGS = nil  end
		
		-- If the request was removed by CloseAllBags(nil) or duplicate CloseAllBags(requesterFrame) call
		-- then do nothing, the bags were already closed
		if  not OpenAllRequesterFrames[key]  then  return false  end
		OpenAllRequesterFrames[key] = nil
		
		-- Filter out hidden requesterFrames
		local visibleRequesters = {}
		for  key, frame  in  pairs(OpenAllRequesterFrames)  do
			if  frame:IsVisible()  then  visibleRequesters[key] = frame
			else  print('Frame '.. tostring(key) ..' did not call CloseAllBags() before being hidden, dropping stale reference.')
			end
		end
		OpenAllRequesterFrames = visibleRequesters
		
		-- If any other frame is still requesting open bags then leave them open
		if  next(visibleRequesters)  then  return false  end
	end
	
	FRAME_THAT_OPENED_BAGS = nil
	OpenAllRequesterFrames = {}
	
	return CloseManyContainers(BACKPACK_CONTAINER, NUM_BAG_SLOTS)
end






--[[ WrapSecure necessary: UseContainerItem() is protected
local hooked_OnModifiedClick = ContainerFrameItemButton_OnModifiedClick
function ContainerFrameItemButton_OnModifiedClick(self, button)
	if ( IsModifiedClick("USEITEM") ) then
		UseContainerItem(self:GetParent():GetID(), self:GetID())
	else
		hooked_OnModifiedClick(self, button)
	end
end
--]]


