local CombuctorSet = Combuctor:GetModule("Sets")
local L = LibStub('AceLocale-3.0'):GetLocale('Combuctor')
L.BindToAccount = "Bind to Account"

local tooltipCache = setmetatable({}, {__index = function(t, k) local v = {} t[k] = v return v end})
local tooltipScanner = _G['LibItemSearchTooltipScanner'] or CreateFrame('GameTooltip', 'LibItemSearchTooltipScanner', UIParent, 'GameTooltipTemplate')

--
-- Copied pretty much wholesale from LibItemSearch 1.2
-- 
local function link_FindSearchInTooltip(itemLink, search)
        local itemID = itemLink:match('item:(%d+)')
        if not itemID then
                return
        end

        local cachedResult = tooltipCache[search][itemID]
        if cachedResult ~= nil then
                return cachedResult
        end

        tooltipScanner:SetOwner(UIParent, 'ANCHOR_NONE')
        tooltipScanner:SetHyperlink(itemLink)

        local result = false
        if tooltipScanner:NumLines() > 1 and _G[tooltipScanner:GetName() .. 'TextLeft2']:GetText() == search then
                result = true
        elseif tooltipScanner:NumLines() > 2 and _G[tooltipScanner:GetName() .. 'TextLeft3']:GetText() == search then
                result = true
        elseif tooltipScanner:NumLines() > 3 and _G[tooltipScanner:GetName() .. 'TextLeft4']:GetText() == search then
                result = true
        end

        tooltipCache[search][itemID] = result
        return result
end


local function isBindToAccount(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc)
    if not link then
        return false
    end
    return link_FindSearchInTooltip(link, ITEM_BIND_TO_BNETACCOUNT)
end
CombuctorSet:Register(L.BindToAccount, "Interface/Icons/Achievement_Reputation_ArgentChampion", isBindToAccount);
CombuctorSet:RegisterSubSet(L.All, L.BindToAccount);

local function isArmor(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc)
	return type == L.Armor and equipLoc ~= 'INVTYPE_TRINKET'
end
CombuctorSet:RegisterSubSet(L.Armor, L.BindToAccount, nil, isArmor);

local function isWeapon(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc)
	return type == L.Weapon
end
CombuctorSet:RegisterSubSet(L.Weapon, L.BindToAccount, nil, isWeapon);

local function isTrinket(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc)
	return equipLoc == 'INVTYPE_TRINKET'
end
CombuctorSet:RegisterSubSet(L.Trinket, L.BindToAccount, nil, isTrinket);

local function isOther(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc)
	return not isArmor(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc)
	    and not isWeapon(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc)
		and not isTrinket(player, bagType, name, link, quality, level, ilvl, type, subType, stackCount, equipLoc)
end
CombuctorSet:RegisterSubSet("Other", L.BindToAccount, nil, isOther);
