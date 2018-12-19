local SpellIdToButton = {}

local p_timestamp 		= 1
local p_event			= 2
local p_hideCaster      = 3
local p_sourceGUID      = 4
local p_sourceName      = 5
local p_sourceFlags     = 6
local p_sourceRaidFlags = 7
local p_destGUID        = 8
local p_destName        = 9
local p_destFlags       = 10
local p_destRaidFlags   = 11

--offset 12-13(enviroinmental)
local p_spell_offset	= 11
local p_spell_id		= 1
local p_spell_name		= 2
local p_spell_school	= 3

local p_effect_offset	= 14
local p_effect_amount	= 1
local p_effect_overkill	= 2
local p_effect_school	= 3

local p_buff_offset		= 15

local AVERAGE_COUNT_MAX = 10

local spell_effects = {}

function TinyExtraBars_AddButtonToSpellIds(btn, id)
	--print("TinyExtraBars_AddButtonToSpellIds", btn.id)
	if not(id) then
		id = btn.id
	end
	if id then
		SpellIdToButton[id] = SpellIdToButton[id] or {}
		SpellIdToButton[id][btn:GetName()] = btn
	end
end

function TinyExtraBars_RemoveButtonFromSpellIds(btn, id)
	if not(id) then
		id = btn.id
	end
	if id and (type(SpellIdToButton[id]) == "table") then
		SpellIdToButton[id][btn:GetName()] = nil
	end
end

local function GetFormattedValue(v)
	if v < 1000 then
		return string.format("%d", v)
	elseif v < 10000 then
		return string.format("%.2fk", v / 1000)
	elseif v < 100000 then
		return string.format("%.1fk", v / 1000)
	elseif v < 1000000 then
		return string.format("%dk", v / 1000)
	else
		return string.format("%.2fm", v / 1000000)
	end
end

local function SetButtonText(spellId, text)
	--get generic spell id because buttons casting generic spells
	local spellName = TinyExtraBars_GetSpellNameById(spellId)
	--print("SetButtonText", spellId, spellName)
	local _, _, genericId = TinyExtraBars_FindSpellSlotGenIdByRealName(spellName)
	local id = genericId or spellId
	--print(spellId, genericId, id)
	if type(SpellIdToButton[id]) == "table" then
		for k, btn in pairs(SpellIdToButton[id]) do
			if btn then
				--print("button found", btn:GetName())
				if TEB_LastEffectMode then
					btn.damagetext:SetText(text)
					btn.damagetext:Show()
				else
					btn.damagetext:Hide()
				end
			end
		end
	end
end

function TEBLE_ResetSpell(id)
	if not(id) then
		return
	end
	
	--reset amounts by spell on next cast
	if spell_effects[id] then
		spell_effects[id].damage.current = 0
		spell_effects[id].heal.current = 0
	end
end

local function ShowEffect(id)
	if spell_effects[id] then
		--calculate accumulated and show
		if spell_effects[id].damage.current > 0 and spell_effects[id].damage.prev > 0 then
			SetButtonText(id, GetFormattedValue(spell_effects[id].damage.prev))
		elseif spell_effects[id].heal.current > 0 and spell_effects[id].heal.prev > 0 then
			SetButtonText(id, GetFormattedValue(spell_effects[id].heal.prev))
		end
	end
end

function TEBLE_InitAndShowSpell(id)
	if not(id) then
		return
	end
	
	--print("TEBLE_InitAndShowSpell", id)
	spell_effects[id] = spell_effects[id] or {}
	spell_effects[id].damage = spell_effects[id].damage or {["current"] = 0, ["prev"] = 0, ["count"] = 0}
	spell_effects[id].heal = spell_effects[id].heal or {["current"] = 0, ["prev"] = 0, ["count"] = 0}
	--update amounts by spell
	if spell_effects[id].damage.current > 0 then
		local t = spell_effects[id].damage
		if TEB_LastEffectAverageMode then
			if t.count < AVERAGE_COUNT_MAX then
				t.count = t.count + 1
			end
			if t.prev == 0 then
				t.prev = t.current
			else
				t.prev = (t.prev * t.count + t.current) / (t.count + 1)
				--print(t.prev, t.current, t.count)
			end
		else
			t.prev = t.current
		end
	end
	if spell_effects[id].heal.current > 0 then
		local t = spell_effects[id].heal
		if TEB_LastEffectAverageMode then
			if t.count < AVERAGE_COUNT_MAX then
				t.count = t.count + 1
			end
			if t.prev == 0 then
				t.prev = t.current
			else
				t.prev = (t.prev * t.count + t.current) / (t.count + 1)
			end
		else
			t.prev = t.current
		end
	end
	ShowEffect(id)
end

function TEBLE_EventCombatLog(self, ...)
	
	local args = {...}
	
	local petguid = UnitGUID("pet")
	local playerGuid = UnitGUID("player")
	if playerGuid ~= args[p_sourceGUID] and petguid ~= args[p_sourceGUID] then
		return
	end
	
	--print all
	--local temp = ""
	--for i = 1, #args do
	--	temp = temp..i.." = "..tostring(args[i])..", "
	--end
	--print(temp)
	
	--print partial
	--local temp = tostring(args[2])..", "..tostring(args[12])..", "..tostring(args[13])
	--if #args >= p_buff_offset then
	--	temp = temp..", "..tostring(args[p_buff_offset])
	--end
	--print(temp)
	
	local events = {strsplit("_", args[p_event])}
	
	if events[1] == "SPELL" then
		local id = args[p_spell_offset + p_spell_id]
		local id2 = TEBLE_SpellPartOf[id] or id
		local name = args[p_spell_offset + p_spell_name]
		
		local e = events[2]
		if e == "CAST" then
			local r = events[3]
			if r == "SUCCESS" or r == "START" then
				--TEBLE_InitAndShowSpell(id2)
				--TEBLE_ResetSpell(id2)
			elseif r == "FAILED" then
				TEBLE_ResetSpell(id2)
			end
		elseif e == "AURA" then
			local r = events[3]
			if r == "APPLIED" or r == "REMOVED" then
				--TEBLE_InitAndShowSpell(id2)
			end
		end
		
		if e == "PERIODIC" then
			e = events[3]
		end
		
		--spell_effects[id] init on click
		if not(spell_effects[id2]) then
			--some proc spell, not exists in buttons or LE_SpellPartOf
			return
		end
		
		if e == "DAMAGE" then
			--inc damage
			spell_effects[id2].damage.current = spell_effects[id2].damage.current + args[p_effect_offset + p_effect_amount]
			--print("damage", spell_effects[id2].damage.current)
		elseif e == "HEAL" then
			--inc heal
			spell_effects[id2].heal.current = spell_effects[id2].heal.current + args[p_effect_offset + p_effect_amount]
			--print("heal", spell_effects[id2].heal.current)
		end
	end
end

