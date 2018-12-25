local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if SetTheory then
	local em = {};
	em.name = "SetTheory_EquipmentManager"
	em.desc = L["Equipment Manager"]
	em.wait = 2

	function em.set(opts)
		if not opts.outfit then return end
		if UseEquipmentSet(opts.outfit) then	
			SetTheory:SelectStatus(L["Setting outfit"]..opts.outfit)
			return true
		else return false end
	end

	function em.exists(i, outfit)
		outfit = GetEquipmentSetInfoByName(outfit)
		if not outfit then return L["No Outfit"] else return true end
	end

	function em.outfits()
		local ret = {}
		for i=1,GetNumEquipmentSets() do
			name = GetEquipmentSetInfo(i)
			ret[name] = name
		end
		return ret
	end

	em.opts = {
		type = "group",
		name = L["Equipment Manager"],
		handler = SetTheory,
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which outfit you'd like to wear"],
				order = 0,
			},
			outfit = {
				name = L["Outfit"],
				desc = L["Changes your active outfit"],
				type = "select",
				values = em.outfits,
				validate = em.exists,
				set = "SetActionOption",
				get = "GetActionOption",
			},
		}
	}

	SetTheory:RegisterAction(em)
end
