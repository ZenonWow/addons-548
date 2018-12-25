local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if SetTheory and select(4, GetBuildInfo()) >= 40000 then
	local cStats = {};
	cStats.name = "SetTheory_CharacterStats"
	cStats.desc = "Character Stats"

	function cStats.set(opts)
		local i = 1
		local order = {}
		for name, category in pairs(PAPERDOLL_STATCATEGORIES) do
			local pane = opts[i..'pane']
			if not pane then
				SetTheory:SelectStatus(L["Couldn't set Character Stats. A pane is missing."]);
				return
			end
			pane = PAPERDOLL_STATCATEGORIES[PAPERDOLL_STATCATEGORY_DEFAULTORDER[tonumber(pane)]]
			table.insert(order, pane.id);

			if opts[i..'expanded'] ~= nil then SetCVarBitfield('statCategoriesCollapsed', pane.id, not opts[i..'expanded']) end
			i=i+1
		end
		
		SetCVar('statCategoryOrder', table.concat(order, ","));
		PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, 'statCategoryOrder', 'statCategoriesCollapsed', 'player');	
	end

	local function getCategories()
		local ret = {}
		for cName,category in pairs(PAPERDOLL_STATCATEGORIES) do
			ret[category.id] = _G["STAT_CATEGORY_"..cName]
		end
		return ret
	end

	cStats.opts = {
		type = "group",
		name = L["CharacterStats"],
		handler = SetTheory,
		set = "SetActionOption",
		get = "GetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Choose which stat panes would would like to see and their order."],
				order = 0,
			},
		}
	}

	local statFrames = {CharacterStatsPaneScrollChild:GetChildren()}
	for pane,_ in pairs(statFrames) do
		if pane ~= 7 then 
			cStats.opts.args[tostring(pane)..'title'] = {
				type = "header",
				name = "Pane "..pane,
				order = pane*10,
			}
			cStats.opts.args[tostring(pane)..'expanded'] = {
				type = "toggle",
				name = "Expanded",
				tristate = true,
				order = pane*10+1,
			}
			cStats.opts.args[tostring(pane)..'pane'] = {
				type = "select",
				name = "",
				order = pane*10+2,
				values = getCategories,
				style = "dropdown",
			}
		end
	end

	SetTheory:RegisterAction(cStats)
end
