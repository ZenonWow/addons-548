local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if ActionBarSaver and SetTheory then
	local abs = {};
	abs.name = "SetTheory_ABS"
	abs.desc = L["ABS"]

	function abs.set(opts)
		if not opts.set or opts.set == "" then return end
		local set = opts.set
		ActionBarSaver:RestoreProfile(set);
	end

	function exists(i, set)
		if ActionBarSaver.db.sets[UnitClass('player')][set] then return true end
		return L["No set called "]..set
	end

	function sets()
		local ret = {}
		for name,_ in pairs(ActionBarSaver.db.sets[select(2,UnitClass('player'))]) do
			ret[name] = name;
		end
		return ret
	end

	abs.opts = {
		type = "group",
		name = L["Action Bar Saver"],
		handler = SetTheory,
		set = "SetActionOption",
		get = "GetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which action bar setup you'd like to use."],
				order = 0,
			},
			--[[reload = {
				name = L["Reload"],
				desc = L["Checking this will automatically reload your UI after selecting your addon set. It should only be checked if the ABS action is the last in the action sequence."],
				type = "toggle",
				order = 10,
			},]]
			set = {
				name = L["Setups"],
				desc = L["Changes your action bar setup"],
				type = "select",
				values = sets,
				order = 20,
				--validate = exists,
			},
		}
	}

	SetTheory:RegisterAction(abs)
end
