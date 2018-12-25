local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if ACP and SetTheory then
	local acp = {};
	acp.name = "SetTheory_ACP"
	acp.desc = L["ACP"]

	function acp.set(opts,_, pastWaits)
		if not opts.set or opts.set == "" then return end
		local loadType = opts.loadType or 'load'
		local set = opts.set
		if set == -1 then set = UnitClass("player") end

		if loadType == 1 then ACP:ClearSelectionAndLoadSet(set)
		elseif loadType == 2 then ACP:LoadSet(set)
		elseif loadType == 3 then ACP:UnloadSet(set) end

		if opts.reload then 
			if pastWaits == 0 then ReloadUI() 
			else
				local f = SetTheory:CreateSecureButton(acp.name, "Interface\\PaperDollInfoFrame\\UI-GearManager-Undo", {['type']='reload'})
				f:RegisterForClicks(    'LeftButtonUp' , 'RightButtonUp')
				f:HookScript('OnClick', function(self, button) if button == 'RightButton' then self:Hide() else ReloadUI() end end)
				SetTheory:Print('Left click the central button to reload your UI, right click to cancel the reload.')
			end
		end

		--SetTheory:SelectStatus(L['Setting ACP set to: ']..opts.set)
	end

	function exists(i, set)
		if ACP_Data.AddonSet[set] then return true end
		return L["No set called "]..set
	end

	function sets()
		local ret = {}
		for i=0,10 do
			name = ACP:GetSetName(i)
			if i == 0 then ret[i] = name
			elseif ACP_Data.AddonSet and ACP_Data.AddonSet[i] then ret[i] = name end
		end
		local class = UnitClass("player")
		ret[-1] = class
		return ret
	end

	acp.opts = {
		type = "group",
		name = L["ACP"],
		handler = SetTheory,
		set = "SetActionOption",
		get = "GetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which set of addons you'd like to use."],
				order = 0,
			},
			reload = {
				name = L["Reload"],
				desc = L["Checking this will automatically reload your UI after selecting your addon set. It should only be checked if the ACP action is the last in the action sequence."],
				type = "toggle",
				order = 10,
			},
			set = {
				name = L["Set"],
				desc = L["Changes your addon set"],
				type = "select",
				values = sets,
				order = 20,
				--validate = exists,
			},
			loadType = {
				name = L["Load Type"],
				desc = L["Changes how your addon set is loaded"],
				type = "select",
				values = {
					[1] = L["Replace current selection"],
					[2] = L["Add to current selection"],
					[3] = L["Remove from current selection"],
				},
				order = 30,
			},
		}
	}
	
	acp.defaults = {
		loadType = 1
	}

	SetTheory:RegisterAction(acp)
end
