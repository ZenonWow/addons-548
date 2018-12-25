local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if AsheylaLib_Settings and SetTheory then
	local dot = {};
	dot.name = "SetTheory_DoTimer"
	dot.desc = L["DoTimer"]

	function dot.set(opts)
		if not opts.profile then return end
		SetTheory:SelectStatus(L['Setting DoTimer profile to: ']..opts.profile)
		AsheylaLib:SetActiveProfile(opts.profile)
	end
	
	function exists(i, profile)
		for p, name in pairs(profiles()) do
			if name == profile then return true end
		end
		return L["No profile called "]..profile 
	end

	function profiles()
		local ret = {}
		for name, vals in pairs(AsheylaLib_Settings) do
                                if type(vals) == "table" then
                                    ret[name] = name
                                end
                            end
		return ret
	end

	dot.opts = {
		type = "group",
		name = L["DoTimer"],
		handler = SetTheory,
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which profile you'd like to use"],
				order = 0,
			},
			profile = {
				name = L["Profile"],
				desc = L["Changes your active profile"],
				type = "select",
				values = profiles,
				validate = exists,
				set = "SetActionOption",
				get = "GetActionOption",
			},
		}
	}

	SetTheory:RegisterAction(dot)
end
