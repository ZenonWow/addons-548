local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if SetTheory then
	local wait = {};
	wait.name = "SetTheory_Wait"
	wait.desc = L["Wait"]

	function wait.set(opts)
		SetTheory:Pause(opts.wait, wait.desc)
	end
	
	function wait.exists(i, outfit)
	end

	wait.opts = {
		type = "group",
		name = "--Wait--",
		desc = L["Use this action to create pauses in the action sequence. This is useful if your set's actions share multiple equipping items or you're equipping items and using the Dual Spec action."],
		handler = SetTheory,
		args = {
			actionInstructions = {
				type = "description",
				name = L["Choose how long you'd like to wait for."],
				order = 0,
			},
			wait = {
				name = L["Wait"],
				desc = L["Pauses the action sequence for some seconds"],
				type = "range",
				min = 1,
				max = 10,
				bigStep = 1,
				set = "SetActionOption",
				get = "GetActionOption",
			},
		}
	}

	SetTheory:RegisterAction(wait)
end
