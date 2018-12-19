-- -------------------------------------------------------------------------- --
-- IQ (ItemLevel Quotient) by kunda                                           --
-- -------------------------------------------------------------------------- --
--                                                                            --
-- Calculation:                                                               --
--   IQ = item ItemLevel Quotient                                             --
--        summary of itemLevel from all items divided through 17 (16 if       --
--        2-Hand Weapon)                                                      --
--                                                                            --
--   gemIQ = gem ItemLevel Quotient                                           --
--           summary of itemLevel from all gems divided through gemcount      --
--                                                                            --
--   IQ+ = rarity-dependent item ItemLevel Quotient                           --
--         summary of (itemLevel multiplied with itemRarityQuotient) from all --
--         items divided through 17 (16 if 2-Hand Weapon)                     --
--                                                                            --
--   gemIQ+ = rarity-dependent gem ItemLevel Quotient                         --
--            summary of (itemLevel multiplied with itemRarityQuotient) from  --
--            all gems divided through gemcount                               --
--                                                                            --
-- Slots that are used for ItemLevel Quotient calculation:                    --
--   HeadSlot, NeckSlot, ShoulderSlot, BackSlot, ChestSlot, WristSlot,        --
--   HandsSlot, WaistSlot, LegsSlot, FeetSlot, Finger0Slot, Finger1Slot,      --
--   Trinket0Slot, Trinket1Slot, MainHandSlot, SecondaryHandSlot, RangedSlot  --
--   = 17 slots (with 2-Hand Weapon 16 slots)                                 --
-- Slots that are not used:                                                   --
--   ShirtSlot, TabardSlot, AmmoSlot                                          --
--                                                                            --
-- -------------------------------------------------------------------------- --
--                                                                            --
-- Note: No Enchants! May be in a future release...                           --
--                                                                            --
-- -------------------------------------------------------------------------- --

-- ---------------------------------------------------------------------------------------------------------------------
local IQ = CreateFrame("Frame") -- container
local L = IQ_Locales            -- localization table

local _G = _G
local select = _G.select
local math_floor = _G.math.floor
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemInfo = _G.GetItemInfo
local GetItemGem = _G.GetItemGem

local inspectTab = true
local mult = 10^(2 or 0)
local slots = {
	[1] = "HeadSlot",
	[2] = "NeckSlot",
	[3] = "ShoulderSlot",
	[4] = "BackSlot",
	[5] = "ChestSlot",
	[6] = "WristSlot",
	[7] = "HandsSlot",
	[8] = "WaistSlot",
	[9] = "LegsSlot",
	[10] = "FeetSlot",
	[11] = "Finger0Slot",
	[12] = "Finger1Slot",
	[13] = "Trinket0Slot",
	[14] = "Trinket1Slot",
	[15] = "MainHandSlot",
	[16] = "SecondaryHandSlot",
	[17] = "RangedSlot"	
}
local slotsNum = #slots
local itemRarityNames = {
	[1] = ITEM_QUALITY0_DESC,-- 0|poor
	[2] = ITEM_QUALITY1_DESC,-- 1|common
	[3] = ITEM_QUALITY2_DESC,-- 2|uncommon
	[4] = ITEM_QUALITY3_DESC,-- 3|rare
	[5] = ITEM_QUALITY4_DESC,-- 4|epic
	[6] = ITEM_QUALITY5_DESC,-- 5|legendary
	[7] = ITEM_QUALITY6_DESC,-- 6|artifact (not in game)
	[8] = ITEM_ACCOUNTBOUND  -- 7|account bound
}
local itemRarityColors = {
	[1] = "|cff9d9d9d", -- 0|poor
	[2] = "|cffffffff", -- 1|common
	[3] = "|cff1eff00", -- 2|uncommon
	[4] = "|cff0070dd", -- 3|rare
	[5] = "|cffa335ee", -- 4|epic
	[6] = "|cffff8000", -- 5|legendary
	[7] = "|cffe6cc80", -- 6|artifact (not in game)
	[8] = "|cffe6cc80"  -- 7|account bound
}
local itemRarityQuotient = {
	[1] = 0.25, --  25% 0|poor
	[2] = 0.5,  --  50% 1|common
	[3] = 0.65, --  65% 2|uncommon
	[4] = 0.8,  --  80% 3|rare
	[5] = 1,    -- 100% 4|epic
	[6] = 1.25, -- 125% 5|legendary
	[7] = 1.50, -- 150% 6|artifact (not in game)
	[8] = 1     -- 100% 7|account bound
}
-- ---------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------
local function IQ_GetItemQuality(unit, who)
	local itemRarityCount = {}
	for i = 1, 8 do
		itemRarityCount[i] = 0
	end
	local quality = ""
	for i = 1, slotsNum do
		local id = GetInventoryItemLink(unit, _G[who..slots[i]]:GetID())
		if id then
			local linkID = select(3, id:find("item:(%d+)"))
			local itemRarity = select(3, GetItemInfo(linkID))
			itemRarityCount[itemRarity+1] = itemRarityCount[itemRarity+1] + 1
		end
	end
	local x = 0
	for i = 1, #itemRarityCount do
		if itemRarityCount[i] > 0 then
			if x == 1 then
				quality = quality..", "
				x = 0
			end
			quality = quality..itemRarityColors[i]..itemRarityCount[i].."x "..itemRarityNames[i].."|r"
			x = 1
		end
	end
	return quality
end

local function IQ_GetGemQuality(unit, who)
	local itemRarityCount = {}
	for i = 1, 8 do
		itemRarityCount[i] = 0
	end
	local quality = ""
	for i = 1, slotsNum do
		local id = GetInventoryItemLink(unit, _G[who..slots[i]]:GetID())
		if id then
			for i = 1, 4 do
				local itemName, itemLink = GetItemGem(id, i)
				if itemLink then
					local itemRarity = select(3, GetItemInfo(itemLink))
					itemRarityCount[itemRarity+1] = itemRarityCount[itemRarity+1] + 1
				end
			end
		end
	end
	local x = 0
	for i = 1, #itemRarityCount do
		if itemRarityCount[i] > 0 then
			if x == 1 then
				quality = quality..", "
				x = 0
			end
			quality = quality..itemRarityColors[i]..itemRarityCount[i].."x "..itemRarityNames[i].."|r"
			x = 1
		end
	end
	return quality
end

local function IQ_GetItemLevel(unit, slot)
	local id = GetInventoryItemLink(unit, slot:GetID())
	if id then
		local linkID = select(3, id:find("item:(%d+)"))
		local itemRarity = select(3, GetItemInfo(linkID))
		local iLevel = select(4, GetItemInfo(linkID))
		local IRarLevel = iLevel * itemRarityQuotient[(itemRarity+1)]
		return iLevel or 0, IRarLevel or 0
	else
		return -1, -1
	end
end

local function IQ_GetGemLevel(unit, slot)
	local id = GetInventoryItemLink(unit, slot:GetID())
	if id then
		local GemLevelSum = 0
		local GRarLevel = 0
		local count = 0
		for i = 1, 3 do
			local itemName, itemLink = GetItemGem(id, i)
			if itemLink then
				local gLevel = select(4, GetItemInfo(itemLink))
				local itemRarity = select(3, GetItemInfo(itemLink))
				GemLevelSum = GemLevelSum + gLevel
				GRarLevel = GRarLevel + (gLevel * itemRarityQuotient[(itemRarity+1)])
				count = count + 1
			end
		end
		if count > 0  then
			return GemLevelSum or 0, count or 0, GRarLevel or 0
		else
			return -1, -1, -1
		end
	else
		return -1, -1, -1
	end
end

local function IQ_2HWeaponCheck(unit, slot1, slot2)
	local id = GetInventoryItemLink(unit, slot1:GetID())
	local twohandweapon = false
	if id then
		local linkID = select(3, id:find("item:(%d+)"))
		local itemEquipLoc = select(9, GetItemInfo(linkID))
		if itemEquipLoc == "INVTYPE_2HWEAPON" then
			local id2 = GetInventoryItemLink(unit, slot2:GetID())
			if not id2 then
				twohandweapon = true
			end
		end
	end
	return twohandweapon
end
-- ---------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------
function IQ_InvChange_OnEvent(self, event, arg1)
	if event == "UNIT_INVENTORY_CHANGED" then
		if arg1 == "player" then
			if PaperDollFrame:IsVisible() then
				IQ_Calc("Character")
			end
		elseif arg1 == "target" then
			if InspectPaperDollFrame then
				if InspectPaperDollFrame:IsVisible() then
					IQ_Calc("Inspect")
				end
			end
		end
	end
end

function IQ_Hook_PaperDollFrame_OnShow()
	IQ_Calc("Character")
end

function IQ_Hook_PaperDollFrame_OnHide()
	IQ_BoxCharacter:Hide()
end

function IQ_Hook_InspectPaperDollFrame_OnShow()
	if inspectTab == true then
		IQ_Calc("Inspect")
	end
end

function IQ_Hook_InspectBoxHide()
	IQ_BoxInspect:Hide()
end

function IQ_Hook_ToggleInspect(newID)
	local newFrame = _G[INSPECTFRAME_SUBFRAMES[newID]]:GetName()
	if newFrame == "InspectPaperDollFrame" then
		inspectTab = true
		IQ_Calc("Inspect")
	else
		inspectTab = false
		IQ_BoxInspect:Hide()
	end
end
-- ---------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------
function IQ_Calc(who)
	local unit
	local SlotCount = 17
	local ItemLevel = 0
	local ItemRarLevel = 0
	local ItemCount = 0
	local GemLevel = 0
	local GemRarLevel = 0
	local GemCount = 0

	if who == "Character" then
		unit = "player"
	elseif who == "Inspect" then
		unit = InspectFrame.unit
	else
		unit = who
	end

	for i = 1, slotsNum do
		local i1, i2 = IQ_GetItemLevel(unit, _G[who..slots[i]])
		if i1 >= 0 then
			ItemLevel = ItemLevel + i1
			ItemCount = ItemCount + 1
		end
		if i2 >= 0 then
			ItemRarLevel = ItemRarLevel + i2
		end
		local g1, g2, g3 = IQ_GetGemLevel(unit, _G[who..slots[i]])
		if g1 >= 0 then
			GemLevel = GemLevel + g1
			GemCount = GemCount + g2
			GemRarLevel = GemRarLevel + g3
		end
	end

	if IQ_2HWeaponCheck(unit, _G[who.."MainHandSlot"], _G[who.."SecondaryHandSlot"]) then SlotCount = 16 end
	local ItemIQ = math_floor((ItemLevel/SlotCount) * mult + 0.5) / mult
	local ItemRarIQ = math_floor((ItemRarLevel/SlotCount) * mult + 0.5) / mult
	local ItemQuality = IQ_GetItemQuality(unit, who)
	local GemIQ = math_floor((GemLevel/GemCount) * mult + 0.5) / mult
	local GemRarIQ = math_floor((GemRarLevel/GemCount) * mult + 0.5) / mult
	local GemQuality = IQ_GetGemQuality(unit, who)

	local ItemIQtxt = "IQ: -"
	if type(ItemIQ) == "number" and ItemIQ > 0 then
		ItemIQtxt = "IQ: "..ItemIQ
	end
	local GemIQtxt = "gemIQ: -"
	if type(GemIQ) == "number" and GemIQ > 0 then
		GemIQtxt = "gemIQ: "..GemIQ
	end
	local ItemIQcount = SlotCount-ItemCount
	local ItemIQtxtcount = ""
	if ItemIQcount > 0 then
		ItemIQtxtcount = " ("..ItemIQcount.." "..L["not used"]..")"
	end
	local SlotIQtxtcount = L["Slots"]..": "..SlotCount
	local GemIQtxtcount = L["Gems"]..": "..GemCount

	local ItemRarIQtxt = "IQ+: -"
	if type(ItemRarIQ) == "number" and ItemRarIQ > 0 then
		ItemRarIQtxt = "IQ+: "..ItemRarIQ.." ("..ItemQuality..")"
	end
	local GemRarIQtxt = "gemIQ+: -"
	if type(GemRarIQ) == "number" and GemRarIQ > 0 then
		GemRarIQtxt = "gemIQ+: "..GemRarIQ.." ("..GemQuality..")"
	end

	_G["IQ_Box"..who]:SetParent(_G[who.."WristSlot"])
	_G["IQ_Box"..who]:SetFrameLevel(_G[who.."WristSlot"]:GetFrameLevel())

	_G["IQ_Text"..who]:SetText(ItemIQtxt.."\n"..GemIQtxt)
	_G["IQ_Box"..who]:ClearAllPoints()
	_G["IQ_Box"..who]:SetPoint("TOPLEFT", _G[who.."WristSlot"], "BOTTOMLEFT", 0, -2)
	_G["IQ_Box"..who]:Show()

	_G["IQ_SubText"..who]:SetText(SlotIQtxtcount..ItemIQtxtcount.."\n"..ItemRarIQtxt.."\n"..GemIQtxtcount.."\n"..GemRarIQtxt)
	_G["IQ_SubBox"..who]:SetWidth(ceil(_G["IQ_SubText"..who]:GetWidth())+20)
	_G["IQ_SubBox"..who]:ClearAllPoints()
	_G["IQ_SubBox"..who]:SetPoint("TOPLEFT", _G["IQ_Box"..who], "BOTTOMLEFT", 0, 0)
end
-- ---------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------
function IQ_CreateFrames(who)
	local backdrop = {
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 12,
		edgeSize = 12,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	}

	local box = CreateFrame("Button", "IQ_Box"..who)
	box:SetWidth(95)
	box:SetHeight(30)
	box:SetBackdrop(backdrop)
	box:RegisterEvent("UNIT_INVENTORY_CHANGED")
	box:SetScript("OnEvent", IQ_InvChange_OnEvent)
	box:SetScript("OnEnter", function() _G["IQ_SubBox"..who]:Show() end)
	box:SetScript("OnLeave", function() _G["IQ_SubBox"..who]:Hide() end)
	local boxtxt = box:CreateFontString("IQ_Text"..who, "OVERLAY", "GameFontHighlightSmall")
	boxtxt:SetPoint("CENTER", box)
	local texture = box:CreateTexture(nil, "BACKGROUND")
	texture:SetAllPoints(box)
	texture:SetTexture(0, 0, 0, 1)

	local box2 = CreateFrame("Button", "IQ_SubBox"..who, box)
	box2:SetFrameLevel(_G["IQ_Box"..who]:GetFrameLevel()+10)
	box2:SetHeight(58)
	box2:SetBackdrop(backdrop)
	box2:Hide()
	local boxtxt2 = box2:CreateFontString("IQ_SubText"..who, "OVERLAY", "GameFontHighlightSmall")
	boxtxt2:SetPoint("CENTER", box2)
	boxtxt2:SetJustifyH("LEFT")
	local texture2 = box2:CreateTexture(nil, "BACKGROUND")
	texture2:SetAllPoints(box2)
	texture2:SetTexture(0, 0, 0, 1)
end
-- ---------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------
local function OnEvent(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == "IQ" then
			IQ_CreateFrames("Character")
			IQ_CreateFrames("Inspect")
			PaperDollFrame:HookScript("OnShow", function() IQ_Hook_PaperDollFrame_OnShow() end)
			PaperDollFrame:HookScript("OnHide", function() IQ_Hook_PaperDollFrame_OnHide() end)
		elseif arg1 == "Blizzard_InspectUI" then
			InspectPaperDollFrame:HookScript("OnShow", function() IQ_Hook_InspectPaperDollFrame_OnShow() end)
			InspectFrame:HookScript("OnHide", function() IQ_Hook_InspectBoxHide() end)
			InspectPVPFrame:HookScript("OnShow", function() IQ_Hook_InspectBoxHide() end)
			hooksecurefunc("InspectSwitchTabs", IQ_Hook_ToggleInspect)
			hooksecurefunc("InspectFrame_UnitChanged", IQ_Hook_InspectPaperDollFrame_OnShow)
		end
	end
end
-- ---------------------------------------------------------------------------------------------------------------------

IQ:RegisterEvent("ADDON_LOADED")
IQ:SetScript("OnEvent", OnEvent)