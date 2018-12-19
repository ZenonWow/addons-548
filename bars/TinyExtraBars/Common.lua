--[[ Common ]]

--const
TEB_DEFAULT_BUTTON_SIZE = 36
TEB_BUTTON_SIZE 		= 36
TEB_BUTTON_SPACING		= 4
TEB_HEIGHT_EXTRA 		= 35
TEB_WIDTH_EXTRA 		= 20
TEB_MAX_ROWS 			= 12
TEB_MAX_COLS 			= 12
TEB_BUTTON_SCALE 		= TEB_BUTTON_SIZE / TEB_DEFAULT_BUTTON_SIZE

TEB_ACCEPTABLE_COMMANDS = {
	["spell"] = true,
	["item"] = true,
	["macro"] = true,
	["macrotext"] = true,
	["companion"] = true,
	["equipmentset"] = true,
	["battlepet"] = true,
}

local SpellCacheToSlot = {}

function TinyExtraBars_GetFullSpellName(name, rank)
	if not(rank) then
		rank = ""
	end
	if (name) then
		return name.."("..rank..")", name
	end
	return nil, nil
end

function TinyExtraBars_GetSpellNameById(id)
	local name, rank = GetSpellInfo(id)
	return TinyExtraBars_GetFullSpellName(name, rank)
end

local CompanionTypes = {"MOUNT", "CRITTER"}

local function CacheCompanionSpells(compType, cache2slot)
	for slot = 1, GetNumCompanions(compType) do
		--creatureID, creatureName, creatureSpellID, icon, issummoned
		local _, name, id = GetCompanionInfo(compType, slot)
		local spellName = GetSpellInfo(id)
		if spellName then
			cache2slot[spellName] = {slot, compType}
		end
	end
end

local SpellRealNameToGeneric = {}

function TinyExtraBars_FindSpellSlotGenIdByRealName(name)
	local packed = SpellRealNameToGeneric[name]
	if packed then
		return unpack(packed)
	end
	
	--name, texture, offset, numSpells
	local bookType = BOOKTYPE_SPELL
	local _, _, offset, numSpells = GetSpellTabInfo(2)
	local total = numSpells

	for slot = offset, offset + total do
		local id = TinyExtraBars_FindSpellIdBySlot(slot, bookType)
		local _, genId = GetSpellBookItemInfo(slot, bookType)
		local spellName = TinyExtraBars_GetSpellNameById(id)

		if name == spellName then
			SpellRealNameToGeneric[name] = {slot, bookType, genId}
			return slot, bookType, genId
		end
	end
end

function TinyExtraBars_CacheSpells()
	SpellCacheToSlot = {}
	for _, v in pairs(CompanionTypes) do
		CacheCompanionSpells(v, SpellCacheToSlot)
	end
end

-- returns spellId according to stance/spec
function TinyExtraBars_FindSpellId(spellName)
	local link = GetSpellLink(spellName)
	if link then
		return tonumber(select(3, strfind(link, "spell:(%d+)|")))
	end
	return nil
end

function TinyExtraBars_FindSpellIdBySlot(slot, bookType)
	local link = GetSpellLink(slot, bookType)
	if link then
		return tonumber(select(3, strfind(link, "spell:(%d+)|")))
	end
	return nil
end

function TinyExtraBars_GetCompanionInfoByName(name, compType)
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

function TinyExtraBars_SetCursor(command, value, subValue, id)
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

function TinyExtraBars_GetCursorValues()
	local command, value, subValue, id = GetCursorInfo()
	--print("GetCursorValues "..tostring(command)..", "..tostring(value)..", "..tostring(subValue)..", "..tostring(id))
	if (command == "spell") then
		value = TinyExtraBars_GetSpellNameById(id)
	elseif (command == "item") or (command == "equipmentset") then
		--nothing to do
	elseif (command == "macro") then		
		subValue = value -- value is macro index	
		value = GetMacroInfo(value) --name, texture, body
	elseif (command == "companion") then
		_, _, id = GetCompanionInfo(subValue, value)
		--without rank, else can't find texture by name
		value = GetSpellInfo(id)
		command = "spell"
	end
	--battlepet, guid, nil, nil
	return command, value, subValue, id, realId
end

function TinyExtraBars_GetButtonsTotalSize(count)
	--local size = math.ceil(count * TEB_BUTTON_SIZE + (count + 1) * TEB_BUTTON_SPACING / TEB_BUTTON_SCALE)
	--return size
	return count * TEB_BUTTON_SIZE + (count + 1) * TEB_BUTTON_SPACING
end

function TinyExtraBars_GetButtonsCountByLen(len)
	local count = math.floor((len - TEB_WIDTH_EXTRA)/(TEB_BUTTON_SIZE + TEB_BUTTON_SPACING))
	if count <= 0 then
		count = 1
	elseif count > TEB_MAX_COLS then
		count = TEB_MAX_COLS
	end
	return count
end
