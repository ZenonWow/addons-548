local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if SetTheory then
	local ace = {};
	ace.name = "SetTheory_AceToggle"
	ace.desc = L["Ace Toggle"]

	function ace.set(opts)
		local on = {}; local off = {}
		for o, opt in pairs(opts) do
			addon = LibStub('AceAddon-3.0'):GetAddon(o, true)
			if addon then 
				SetTheory:Print('Calling SetEnabledState('..tostring(opt)..') on '..addon:GetName())
				if opt then addon:Enable() else addon:Disable() end
				if opt then table.insert(on, o) 
				else table.insert(off, o) end
			end
		end
		if #on > 0 then SetTheory:SelectStatus(L["Turned the following Ace addons X"]('on')..' '..table.concat(on, ', ')) end
		if #off > 0 then SetTheory:SelectStatus(L["Turned the following Ace addons X"]('off')..' '..table.concat(off, ', ')) end
	end

	ace.opts = {
		type = "group",
		name = L["AceToggle"],
		handler = SetTheory,
		set = "SetActionOption",
		get = "GetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which Ace addons you'd like to enable or disable"],
				order = 0,
			},
		}
	}

	for name, addon in LibStub('AceAddon-3.0'):IterateAddons() do
		if addon.SetEnabledState and addon.OnEnable and addon.OnDisable then
			ace.opts.args[name] = {
				name = name,
				type = "toggle",
				tristate = true,
			}
		end
	end

	SetTheory:RegisterAction(ace)
end
