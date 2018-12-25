local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if PowaSet and SetTheory then
	local powa = {};
	powa.name = "SetTheory_PowerAuras3"
	powa.desc = "PowerAuras3"

	function powa.set(opts)
		local on = {}; local off = {}
		for o, opt in pairs(opts) do
			if PowaAuras.Auras[tonumber(o)] then 
				PowaAuras.Auras[tonumber(o)].off = not opt 
				if opt then table.insert(on, getAuraName({[1]=tonumber(o)}))
				else table.insert(off, getAuraName({[1]=tonumber(o)})) end
			end
		end

--[[		for i = 0, PowaAuras.MaxAuras do
			if (PowaSet[i]) then
				Powa_FramesVisibleTime[i] = 0;
			end
		end]]

		PowaAuras:FindAllChildren();
		PowaAuras:CreateEffectLists();	
		PowaAuras.DoCheck.All = true;
		PowaAuras:NewCheckBuffs();
		PowaAuras:MemorizeActions();

		if #on > 0 then SetTheory:SelectStatus(L["Turned the following PowerAuras X: "]('on') .. table.concat(on, ", ")) end
		if #off > 0 then SetTheory:SelectStatus(L["Turned the following PowerAuras X: "]('off').. table.concat(off, ", ")) end
	end

	function getAuraName(k)
		local aura = PowaAuras.Auras[tonumber(k[#k])]
		if not aura then return end

		local tag = ""
		if (aura.bufftype >= 1 and aura.bufftype <= 7) or aura.buffname == 13 then -- buffname
			tag = aura.buffname
		elseif aura.bufftype >= 8 and aura.bufftype <= 10 then --threshold
			tag = tostring(aura.threshold)
		elseif aura.bufftype == 14 then -- stance
			tag = aura.stance
		end

		if tag ~= "" then tag = ": " .. tag end
		return aura.OptionText.typeText .. tag
	end

	function getAuraDescription(k)
		local aura = PowaAuras.Auras[tonumber(k[#k])]
		if not aura then return end

		local desc = ""
		if aura.bufftype == 1 or aura.bufftype == 2 then --stacks
			if aura.stacksOperator ~= '=' or aura.stacks ~= '0' then desc = aura.stacksOperator .. aura.stacks end
		elseif aura.bufftype >= 8 and aura.bufftype <= 10 then --threshold 
			desc = aura.threshold
		end
	end

	function hidePowa(k)
		if not PowaAuras.Auras[tonumber(k[#k])] then return true
		else return false end
	end

	function hidePowaPage(k)
		local page = select(1,k[#k]:gsub('powaPage', ''))
		found = false
		for k=tonumber(page), tonumber(page)+23 do
			if PowaAuras.Auras[k] then found = true end
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
			name = getAuraName,
			desc = getAuraDescription,
			type = "toggle",
			hidden = hidePowa,
			tristate = true,
			order = k*10,
		}
	end

	SetTheory:RegisterAction(powa)
end
