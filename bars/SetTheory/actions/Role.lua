local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if SetTheory and GetBuildInfo() > "4.0.0" then 
	local role = {};
	role.name = "SetTheory_Role"
	role.desc = L["Role"]

	function role.set(opts)
		if opts.role then
			UnitSetRole('player', opts.role);
		end
	end

	function role.alreadySet(opts)
		return UnitGroupRolesAssigned('player') == opts.role
	end

	function getPossibleRoles()
		local ret = {};
		local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles('player');
		
		if(canBeTank) 	 then ret['TANK'] = TANK; end
		if(canBeHealer)  then ret['HEALER'] = HEALER; end
		if(canBeDamager) then ret['DAMAGER'] = DAMAGER; end

		return ret;
	end
	
	role.opts = {
		type = "group",
		name = L["Role"],
		handler = SetTheory,
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which role you'd like to fulfil."],
				order = 0,
			},
			role = {
				name = L["Spec"],
				desc = L["Changes your marked role in raids and groups."],
				type = "select",
				values = getPossibleRoles,
				set = "SetActionOption",
				get = "GetActionOption",
			},
		}
	}

	SetTheory:RegisterAction(role)
end
