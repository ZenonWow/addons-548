local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if Dominos and SetTheory then
	local dominos = {};
	dominos.name = "SetTheory_Dominos"
	dominos.desc = L["Dominos"]

	function dominos.set(opts)
		if not opts.profile then return end
		Dominos:Unload();
		Dominos.db:SetProfile(opts.profile);
		Dominos.isNewProfile = nil;
		Dominos:Load();
	end

	function profiles()
		local ret = {}
		for _, name in ipairs(Dominos.db:GetProfiles()) do
			ret[name] = name;
		end
		return ret
	end

	function exists(i, v)
		local found = false
		for _, name in ipairs(Dominos.db:GetProfiles()) do
			if name == v then 
				found = true;
				break;
			end
		end
		return found
	end
	
	dominos.opts = {
		type = "group",
		name = L["Dominos"],
		handler = SetTheory,
		set = "SetActionOption",
		get = "GetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which Dominos profile you'd like to apply"],
				order = 0,
			},
			profile = {
				name = L["Profile"],
				desc = L["The dominos profile you'd like to apply"],
				type = "select",
				values = profiles,
				validate = exists,
			},
		}
	}

	SetTheory:RegisterAction(dominos)
end
