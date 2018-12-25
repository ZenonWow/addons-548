local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if PowaSet and PowaText and SetTheory then
	local powa = {};
	powa.name = "SetTheory_PowerAuras"
	powa.desc = L["PowerAuras"]

	function powa.set(opts)
		local on = {}; local off = {}
		for o, opt in pairs(opts) do
			if PowaSet[tonumber(o)] then 
				PowaSet[tonumber(o)].off = not opt 
				if opt then table.insert(on, getPowaSetName({[1]=tonumber(o)}))
				else table.insert(off, getPowaSetName({[1]=tonumber(o)})) end
			end
		end

		for i = 0, MaxAuras do
			if (PowaSet[i]) then
				Powa_FramesVisibleTime[i] = 0;
			end
		end

		Powa_CreateEffectLists()
		DoCheckBuffs = true;
		DoCheckOthers = true;
		DoCheckCombo = true;
		DoCheckTargetBuffs  = true;
		DoCheckPartyBuffs  = true;
		DoCheckRaidBuffs  = true;
		DoCheckUnitBuffs  = true;
		DoCheckFocusBuffs  = true;
		DoCheckHealth = true;
		DoCheckTargetHealth = true;
		DoCheckPartyHealth  = true;
		DoCheckRaidHealth  = true;
		DoCheckFocusHealth  = true;
		DoCheckMana = true;
		DoCheckTargetMana = true;
		DoCheckPartyMana  = true;
		DoCheckRaidMana  = true;
		DoCheckFocusMana = true;
		DoCheckRageEnergy = true;
		DoCheckTargetRageEnergy = true;
		DoCheckPartyRageEnergy  = true;
		DoCheckRaidRageEnergy  = true;
		DoCheckFocusRageEnergy = true;
		DoCheckUnitHealth = true;
		DoCheckUnitMana = true;
		DoCheckUnitRageEnergy = true;
		DoCheckStance = true;
		DoCheckAction = true;
		DoCheckEnchant = true;
		DoCheckMounted = true;
		DoCheckPvP = true;
		DoCheckPartyPvP = true;
		DoCheckRaidPvP = true;
		DoCheckTargetPvP = true;
		DoCheckAggro = true;
		DoCheckPartyAggro = true;
		DoCheckRaidAggro = true;
		DoCheckSpells = true;
		DoCheckTargetSpells = true;
		DoCheckFocusSpells = true;
		Powa_NewCheckBuffs();
		if #on > 0 then SetTheory:SelectStatus(L["Turned the following PowerAuras X: "]('on') .. table.concat(on, ", ")) end
		if #off > 0 then SetTheory:SelectStatus(L["Turned the following PowerAuras X: "]('off').. table.concat(off, ", ")) end
	end

	types = {
		[1] = PowaText.nomCheckBuff,
		[2] = PowaText.nomCheckDebuff,
		[3] = PowaText.nomCheckDebuffType,
		[4] = PowaText.nomCheckAoeDebuff,
		[5] = PowaText.nomEnchant,
		[6] = PowaText.nomCheckCombo,
		[7] = PowaText.nomCheckSkill,
		[8] = PowaText.nomCheckHealth,
		[9] = PowaText.nomCheckMana,
		[10] = PowaText.nomCheckRageEnergy,
		[11] = PowaText.nomCheckAggro,
		[12] = PowaText.nomCheckPvP,
		[13] = PowaText.nomCheckSpells,
		[14] = PowaText.nomCheckStance,
	}

	function getPowaSetName(k)
		local aura = PowaSet[tonumber(k[#k])]
		if not aura then return end

		local tag
		if (aura.bufftype >= 1 and aura.bufftype <= 7) or aura.buffname == 13 then -- buffname
			tag = aura.buffname
		elseif aura.bufftype >= 8 and aura.bufftype <= 10 then --threshold
			tag = tostring(aura.threshold)
		elseif aura.bufftype == 14 then -- stance
			tag = aura.stance
		end
		return types[aura.bufftype] .. ": " .. tag
	end

	function getPowaSetDescription(k)
		local aura = PowaSet[tonumber(k[#k])]
		if not aura then return end

		local desc = ""
		if aura.bufftype == 1 or aura.bufftype == 2 then --stacks
			if aura.stacksOperator ~= '=' or aura.stacks ~= '0' then desc = aura.stacksOperator .. aura.stacks end
		elseif aura.bufftype >= 8 and aura.bufftype <= 10 then --threshold 
			desc = aura.threshold
		end
	end

	function hidePowa(k)
		if not PowaSet[tonumber(k[#k])] then return true
		else return false end
	end

	function hidePowaPage(k)
		local page = select(1,k[#k]:gsub('powaPage', ''))
		found = false
		for k=tonumber(page), tonumber(page)+23 do
			if PowaSet[k] then found = true end
		end
		return not found
	end

	powa.opts = {
		type = "group",
		name = L["PowerAuras"],
		handler = SetTheory,
		set = "SetActionOption",
		get = "GetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which PowerAuras auras you would like to toggle on or off"],
				order = 0,
			},
		}
	}

	-- Make a checkbox for every player aura so that if new ones are created they'll show up, unfortunately this hits memory.
	for k=1, 120 do
		local page = math.floor(((k-1) /24 ) + 1)
		if (k+24) % 24 == 1 then 
			powa.opts.args['powaPage'..tostring(k)] = {
				type = 'header',
				name = PowaPlayerListe[page],
				hidden = hidePowaPage,
				order = (k*10)-5,
			}
		end
		powa.opts.args[tostring(k)] = {
			name = getPowaSetName,
			desc = getPowaSetDescription,
			type = "toggle",
			hidden = hidePowa,
			tristate = true,
			order = k*10,
		}
	end

	SetTheory:RegisterAction(powa)
end
