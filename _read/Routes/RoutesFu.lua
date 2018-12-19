local Tablet = AceLibrary("Tablet-2.0")
local L = Rock("LibRockLocale-1.0"):GetTranslationNamespace("FuBar_RoutesFu")

RoutesFu = Rock:NewAddon("RoutesFu", "LibRockConfig-1.0", "LibRockDB-1.0", "LibFuBarPlugin-3.0")

RoutesFu:SetDatabase("RoutesFuDB")

RoutesFu:SetFuBarOption("hasIcon", true)
RoutesFu:SetFuBarOption("iconPath", "Interface\\Addons\\FuBar_RoutesFu\\icon.tga" )
RoutesFu:SetFuBarOption("defaultPosition", "RIGHT")
RoutesFu:SetFuBarOption("tooltipType", "Tablet-2.0")
RoutesFu:SetFuBarOption("clickableTooltip", true )
RoutesFu:SetFuBarOption("tooltipHiddenWhenEmpty", true)

local CR, BZR, CRW, TT
if Routes then
	-- Routes code, has priority over Cartographer_Routes if both addons are active
	CR = Routes
	BZR = nil -- we use BZR to test whether Routes or Cartographer_Routes is active
	CRW = Routes:GetModule("Waypoints")
	TT = Routes:GetModule("TomTom")
elseif Cartographer_Routes then
	-- Cartographer_Routes code
	CR = Cartographer_Routes
	BZR = Rock("LibBabble-Zone-3.0"):GetReverseLookupTable()
	CRW = nil
else
	error("RoutesFu requires either Cartographer_Routes or Routes.")
end
local optionsTable
local tmptable = {}

function RoutesFu:OnInitialize()
	optionsTable = {
		name = "FuBar_RoutesFu",
		desc = self.notes,
		handler = RoutesFu,
		type = "group",
		args = {
		}
	}
	RoutesFu:SetConfigTable(optionsTable)
	RoutesFu.OnMenuRequest = optionsTable

	-- Happens on first-install for LibFuBarPlugin-3.0, the db has a value of nil for both instead of
	-- true/false values and its not possible to register the icon to be shown by default. Dumb? Yes.
	if not self:IsFuBarIconShown() and not self:IsFuBarTextShown() then
		self:ToggleFuBarIconShown() -- show it
		self:ToggleFuBarTextShown() -- show it
		self:ToggleFuBarTextShown() -- hide it (to force the db to save a value of false, rather than nil)
	end
end

function RoutesFu:OnUpdateFuBarTooltip()
	local zone = GetRealZoneText()
	local header = Tablet:AddCategory(
		"columns", 2
	)
	header:AddLine(
		"text", L["Zone:"],
		"text2", zone,
		"text2R", 1,
		"text2G", 1,
		"text2B", 0
	)

	local zone_data
	if BZR then
		-- Cartographer_Routes code
		zone = BZR[zone] or zone -- Get english name
		zone_data = CR.db.account.routes[zone]
	else
		-- Routes code
		if CR.LZName[zone] then
			zone = CR.LZName[zone][1] -- Get mapfile
			zone_data = CR.db.global.routes[zone]
		end
	end

	if type(zone_data) == "table" then
		local toggle = Tablet:AddCategory(
			"columns", 2,
			"child_textR", 1,
			"child_textG", 1,
			"child_textB", 0,
			"child_text2R", 1,
			"child_text2G", 1,
			"child_text2B", 1,
			"hideBlankLine", true
		)

		for i = #tmptable, 1, -1 do
			tmptable[i] = nil
		end
		for route_name in pairs(zone_data) do
			tinsert(tmptable, route_name)
		end
		table.sort(tmptable)

		for i = 1, #tmptable do
			local route_name = tmptable[i]
			local route_data = zone_data[route_name]
			local checked = not route_data.hidden

			if route_data.route and #route_data.route > 0 then
				toggle:AddLine(
					"text", " "..route_name,
					"text2", L["%s nodes"]:format(#route_data.route),
					"hasCheck", true,
					"checked", checked,
					"func", "OnClickItem",
					"arg1", self,
					"arg2", zone,
					"arg3", route_name,
					"arg4", checked
				)
			end
		end
	end

	if TomTom or Cartographer and Cartographer:HasModule("Waypoints") and Cartographer:IsModuleActive("Waypoints") then
		local header = Tablet:AddCategory(
			"columns", 1,
			"child_textR", 1,
			"child_textG", 1,
			"child_textB", 1,
			"child_indentation", 20
		)
		header:AddLine(
			"text", TomTom and "TomTom" or "Cartographer_Waypoints:",
			"noInherit", true
		)
		header:AddLine(
			"text", L["Start using Waypoints"],
			"func", TomTom and TT.QueueFirstNode or BZR and CR.QueueFirstNode or CRW.QueueFirstNode,
			"arg1", TomTom and TT or BZR and CR or CRW
		)	
		header:AddLine(
			"text", L["Change Waypoint direction"],
			"func", TomTom and TT.ChangeWaypointDirection or BZR and CR.ChangeWaypointDirection or CRW.ChangeWaypointDirection,
			"arg1", TomTom and TT or BZR and CR or CRW
		)	
		header:AddLine(
			"text", L["Stop using Waypoints"],
			"func", TomTom and TT.RemoveQueuedNode or BZR and CR.RemoveQueuedNode or CRW.RemoveQueuedNode,
			"arg1", TomTom and TT or BZR and CR or CRW
		)	
	end

	Tablet:SetHint(L["Click route to toggle"])
	Tablet:SetTitle(BZR and "Cartographer_Routes" or "Routes")
end

function RoutesFu:OnClickItem(zone, route_name, hidden)
	if BZR then
		-- Cartographer_Routes code
		CR.db.account.routes[zone][route_name].hidden = hidden
		CR.DrawWorldmapLines()
		CR.DrawMinimapLines(true)
	else
		-- Routes code
		CR.db.global.routes[zone][route_name].hidden = hidden
		CR:DrawWorldmapLines()
		CR:DrawMinimapLines(true)
	end
end

function RoutesFu:OnFuBarClick()
	if BZR then
		-- Cartographer_Routes code
		Cartographer:OpenConfigMenu("Routes")
	else
		-- Routes code
		LibStub("AceConfigDialog-3.0"):Open("Routes")
	end
end
