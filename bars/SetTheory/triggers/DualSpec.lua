local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if SetTheory then
	local ds = {}
	ds.name = L["Dual Spec"]
	ds.events = {
		"PLAYER_TALENT_UPDATE"
	}

	local talentNames = {
		[1] = L["Primary"],
		[2] = L["Secondary"]
	}

	function getPossibleSpecs()
		local values = {}
		for i=1,GetNumTalentGroups() do
			values[i] = talentNames[i] 
		end
		values[0] = "Both"
		return values
	end

	ds.defaults = {
		spec = 0
	}

	ds.opts = {
		get = "GetTriggerOption",
		set = "SetTriggerOption",
		spec = {
			name = L["Spec"],
			desc = L["The spec to trigger on"],
			type = select,
			values = getPossibleSpecs,
		}
	}
	
	ds.satisfied = function(opts)
		return opts.spec == 0 or opts.spec == GetActiveTalentGroup()
	end

	SetTheory:RegisterTrigger(ds)
end
