local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if SetTheory then
	local lua = {};
	lua.name = "SetTheory_Lua"
	lua.desc = L["Lua"]

	function lua.set(opts)
		local func, err = loadstring(opts.lua)
		if not func then
			SetTheory:SelectStatus(L["Your Lua string didn't evaluate. Error: "]..err)	
			return false
		end
		local success, err = pcall(func)
		if not success then
			SetTheory:SelectStatus(L["Encountered an error running your Lua string. Error: "]..err)
			return false
		else 
			SetTheory:SelectStatus(L["Your Lua string executed sucessfully."])
			return true
		end
	end
	
	lua.opts = {
		type = "group",
		name = L["Lua"],
		handler = SetTheory,
		args = {
			actionInstructions = {
				type = "description",
				name = L["Enter Lua code to be executed by this action."],
				order = 0,
			},
			lua = {
				name = L["Lua"],
				desc = L["Any Lua code entered here will be executed by this action"],
				type = "input",
				width = "full",
				multiline = true,
				set = "SetActionOption",
				get = "GetActionOption",
			},
		}
	}

	SetTheory:RegisterAction(lua)
end
