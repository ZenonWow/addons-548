--[[ Common ]]

--const
local MIN_VISIBLE_BUTTONS_SETTINGS_MODE = 1
FBC_BUTTON_PLACE_SIZE 	= 36
FBC_BUTTON_PLACE_OFFSET	= 4
FBC_FRAME_OFFSET 		= 5
FBC_ARROW_OFFSET 		= 4

--arrow button directions
FBC_DIR_UP		= 1
FBC_DIR_LEFT	= 2
FBC_DIR_DOWN	= 3
FBC_DIR_RIGHT	= 4

local SpellCacheToSlot = {}

function FlyoutButton_GetFullSpellName(name, rank)
	if not(rank) then
		rank = ""
	end
	if (name) then
		return name.."("..rank..")", name
	end
	return nil, nil
end

function FlyoutButton_GetGenericSpellNameById(id)
	local name, rank = GetSpellInfo(id)
	return FlyoutButton_GetFullSpellName(name, rank)
end

local CompanionTypes = {"MOUNT", "CRITTER"}

local function CacheCompanionSpells(compType, cache2slot)
	for slot = 1, GetNumCompanions(compType) do
		--creatureID, creatureName, creatureSpellID, icon, issummoned
		local _, name, id = GetCompanionInfo(compType, slot)
		local spellName = GetSpellInfo(id)
		--print(spellName)
		cache2slot[spellName] = {slot, compType}
	end
end

function FlyoutButton_CacheSpells()
	SpellCacheToSlot = {}
	for _, v in pairs(CompanionTypes) do
		CacheCompanionSpells(v, SpellCacheToSlot)
	end
end

function FlyoutButton_FindSpellId(spellName)
	local link = GetSpellLink(spellName)
	if link then
		return tonumber(select(3, strfind(link, "spell:(%d+)|")))
	else
		return nil
	end
end

function FlyoutButton_GetCompanionInfoByName(name, compType)
	local packed = SpellCacheToSlot[name]
	if packed then
		local slot = unpack(packed)
		if slot then
			--creatureID, creatureName, creatureSpellID, icon, issummoned
			return GetCompanionInfo(compType, slot)
		end
	end
	return nil
end

function FlyoutButton_SetCursor(command, value, subValue, id)
	--print("SetCursorValues "..tostring(command)..", "..tostring(value)..", "..tostring(subValue)..", "..tostring(id))
	if not(command) then
		return
	end

	ClearCursor()
	if (command == "spell") then
		PickupSpell(id)
	elseif (command == "item") then
		PickupItem(value)	--itemID or "itemString" or "itemName" or "itemLink"
	elseif (command == "macro") then
		PickupMacro(value)
	elseif (command == "equipmentset") then
		PickupEquipmentSetByName(value)
	elseif (command == "battlepet") then
		C_PetJournal.PickupPet(value, PetJournal.isWild)
	end
end

function FlyoutButton_GetCursorValues()
	local command, value, subValue, id = GetCursorInfo()
	--print("GetCursorValues "..tostring(command)..", "..tostring(value)..", "..tostring(subValue)..", "..tostring(id))
	if (command == "spell") then
		value = FlyoutButton_GetGenericSpellNameById(id)
	elseif (command == "item") or (command == "equipmentset") then
		--nothing to do, value is item id
	elseif (command == "macro") then		
		subValue = value -- value is macro index	
		value = GetMacroInfo(value) --name, texture, body
	elseif (command == "companion") then		
		local _
		_, _, id = GetCompanionInfo(subValue, value)
		--without rank, else can't find texture by name
		value = GetSpellInfo(id)
		command = "spell"
	end
	--battlepet, guid, nil, nil
	return command, value, subValue, id
end

function FlyoutButton_GetListButtonsCount(listTable)
	local count = 0
	if listTable then
		for i = 1, #listTable do
			if (listTable[i]) and (listTable[i].value) then
				count = i
			end
		end
	end
	local settingsCount = count
	
	if FbcSettingsMode then
		if count < MIN_VISIBLE_BUTTONS_SETTINGS_MODE then
			settingsCount = MIN_VISIBLE_BUTTONS_SETTINGS_MODE
		else
			settingsCount = count + 1
		end
	end
	return count, settingsCount
end
