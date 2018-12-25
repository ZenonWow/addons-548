local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if XPerlConfigNew and SetTheory then
	local xperl = {};
	xperl.name = "SetTheory_XPerl"
	xperl.desc = L["XPerl"]

	function xperl.set(opts)
		--XPerl_Options_LoadFrameLayout(opts.layout)
		layout = getLayout(opts.layout)
		if (layout) then
			local name = UnitName("player")
			local realm = GetRealmName()
			if (not XPerlConfigNew.savedPositions) then
				if (not create) then
					return
				end
				XPerlConfigNew.savedPositions = {}
			end
			local c = XPerlConfigNew.savedPositions
			if (not c[realm]) then
				if (not create) then
					return
				end
				c[realm] = {}
			end
			if (not c[realm][name]) then
				if (not create) then
					return
				end
				c[realm][name] = {}
			end

			c[realm][name] = XPerl_CopyTable(layout)
			XPerl_RestoreAllPositions()
			SetTheory:SelectStatus(L['Loading XPerl layout: ']..opts.layout)
		end
	end
	
	function exists(i, layout)
		local found = false
		for i, l in pairs(layouts()) do
			if l == layout then return true end
		end
		if not found then return L["There is no layout called "]..layout end
	end

	function layouts()
		local list = {}
		if (XPerlConfigNew.savedPositions) then
			for realmName,realmList in pairs(XPerlConfigNew.savedPositions) do
				for playerName,frames in pairs(realmList) do
					if (realmName == "saved") then
						--tinsert(list, playerName)
						list[playerName] = playerName
					else
						--tinsert(list, format("%s(%s)", realmName, playerName))
						list[format("%s(%s)", realmName, playerName)] = format("%s(%s)", realmName, playerName)
					end
				end
			end
			sort(list)
		end
		return list
	end

	function getLayout(name)
		if (XPerlConfigNew.savedPositions) then
			for realmName,realmList in pairs(XPerlConfigNew.savedPositions) do
				for playerName,frames in pairs(realmList) do
					local find
					if (realmName == "saved") then
						find = playerName
					else
						find = format("%s(%s)", realmName, playerName)
					end

					if (name == find) then
						return frames
					end
				end
			end
		end
	end

	xperl.opts = {
		type = "group",
		name = L["XPerl"],
		handler = SetTheory,
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which layout you'd like to use"],
				order = 0,
			},
			layout = {
				name = L["Layout"],
				desc = L["Changes your active layout"],
				type = "select",
				values = layouts,
				validate = exists,
				set = "SetActionOption",
				get = "GetActionOption",
			},
		}
	}

	SetTheory:RegisterAction(xperl)
end
