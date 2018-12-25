local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if ItemRack and SetTheory then
	local ir = {};
	ir.name = "SetTheory_ItemRack"
	ir.desc = L["ItemRack"]
	ir.wait = 2

	function ir.set(opts)
		if not opts.rack then return end
		ItemRack.EquipSet(opts.rack)	
		SetTheory:SelectStatus(L["Setting ItemRack rack to: "]..opts.rack)
	end

	function ir.alreadySet(opts)
		return ItemRack.IsSetEquipped(opts.rack)
	end

	function exists(i, rack)
		for r, name in pairs(racks()) do
			if name == rack then return true end
		end
		return L["No Rack"]
	end

	function racks()
		local ret = {}
		local sets = ItemRackUser.Sets;
		if not sets then return ret end;
		for name, set in pairs(sets) do
			if name:sub(1, 1) ~= "~" then
				ret[name] = name
			end
		end
		return ret
	end

	ir.opts = {
		type = "group",
		name = L["ItemRack"],
		handler = SetTheory,
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which rack you'd like to wear"],
				order = 0,
			},
			rack = {
				name = L["Rack"],
				desc = L["Changes your active rack"],
				type = "select",
				values = racks,
				validate = exists,
				set = "SetActionOption",
				get = "GetActionOption",
			},
		}
	}

	SetTheory:RegisterAction(ir)
end
