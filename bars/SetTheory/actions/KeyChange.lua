local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if KeyChange and SetTheory then
	local kc = {};
	kc.name = "SetTheory_KeyChange"
	kc.desc = L["KeyChange"]

	function kc.set(opts)
		if not opts.profile then return end
		KeyChange.configMode = true
		local preProfile = KeyChange.db:GetCurrentProfile()
		KeyChange.db:SetProfile(opts.profile)		
		KeyChange:ApplyBinds()
		KeyChange.db:SetProfile(preProfile)
	end
	
	function exists(i, p)
		for _, profile in pairs(KeyChange.db:GetProfiles()) do
			if p == profile then return true end
		end
		return false 
	end

	function profiles()
		local ret = {}
		for p, profile in pairs(KeyChange.db:GetProfiles()) do
			ret[profile] = profile
		end
		return ret
	end

	kc.opts = {
		type = "group",
		name = L["KeyChange"],
		handler = SetTheory,
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which key bind profile you'd like to apply."],
				order = 0,
			},
			profile = {
				name = L["Key bind profile"],
				desc = L["Changes your active key bind profile"],
				type = "select",
				values = profiles,
				validate = exists,
				set = "SetActionOption",
				get = "GetActionOption",
			},
		}
	}

	SetTheory:RegisterAction(kc)
end
