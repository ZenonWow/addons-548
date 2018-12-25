local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if ZOMGBuffs and SetTheory then
	local z = {}
	z.name = "SetTheory_ZOMGBuffs"
	z.desc = L["ZOMGBuffs"]

	function z.set(opts)
		for o, opt in pairs(opts) do
			zmod = getZOMGBuffModule(o)
			if zmod then zmod:SelectTemplate(opt) end
		end
	end
	
	function z.exists(i, template)
		zmod = getZOMGBuffModule(i[#i])
		found = false
		for b, buff in pairs(zmod.db.char.templates2) do
			if b == template then 
				found = true 
				break
			end
		end
		return found

	end

	function z.templates(i)
		zmod = getZOMGBuffModule(i[#i])
		if not zmod then return {} end
		local ret = {}
		for b, buff in pairs(zmod.db.char.templates2) do
			if b ~= 'last' and b ~= 'Autosave' and b ~= 'current' then ret[b] = b end
		end
		return ret
	end

	function z.disabled(i)
		if getZOMGBuffModule(i[#i]) then 
			return false 
		else return true end
	end

	function getZOMGBuffModule(name)
		if name == 'self' then return ZOMGSelfBuffs
		elseif name == 'raid' then return ZOMGBuffTehRaid
		elseif name == 'blessings' then return ZOMGBlessings
		else return false end
	end

	z.opts = {
		type = "group",
		name = L["ZOMGBuffs"],
		handler = SetTheory,
		set = "SetActionOption",
		get = "GetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select templates for different ZOMGBuffs modules"],
				order = 0,
			},
			self = {
				name = L["ZOMGSelfBuffs"],
				desc = L["Self buffs template"],
				type = "select",
				values = z.templates,
				validate = z.exists,
				disabled = z.disabled,
			},
			raid = {
				name = L["ZOMGBuffTehRaid"],
				desc = L["Raid buffs template"],
				type = "select",
				values = z.templates,
				validate = z.exists,
				disabled = z.disabled,
			},
			blessings = {
				name = L["ZOMGBlessings"],
				desc = L["Blessings template"],
				type = "select",
				values = z.templates,
				validate = z.exists,
				disabled = z.disabled,
			}
		}
	}

	SetTheory:RegisterAction(z)
end
