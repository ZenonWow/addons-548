local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if SetTheory then 
	local spec = {};
	spec.name = "SetTheory_DualSpec"
	spec.desc = L["Dual Spec"]
	spec.wait = 6

	local talentNames = {
		[1] = L["Primary"],
		[2] = L["Secondary"]
	}

	function spec.set(opts)
		if opts.spec then
			SetTheory:SelectStatus(L['Setting X as your current talent group'](talentNames[opts.spec]))
			SetActiveSpecGroup(opts.spec)
		end
	end

	function spec.alreadySet(opts)
		return GetActiveSpecGroup() == opts.spec
	end

	function getPossibleSpecs()
		local values = {}
		for i=1,GetNumSpecGroups() do
			values[i] = talentNames[i] 
		end
		return values
	end
	
	spec.opts = {
		type = "group",
		name = L["Dual Spec"],
		handler = SetTheory,
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which spec you'd like to use"],
				order = 0,
			},
			spec = {
				name = L["Spec"],
				desc = L["Changes your active specialisation"],
				type = "select",
				values = getPossibleSpecs,
				set = "SetActionOption",
				get = "GetActionOption",
			},
		}
	}

	SetTheory:RegisterAction(spec)
end
