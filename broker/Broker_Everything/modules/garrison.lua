
----------------------------------
-- module independent variables --
----------------------------------
	local addon, ns = ...
	local C, L, I = ns.LC.color, ns.L, ns.I

	if ns.build<60000000 then return end

-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
	local name = "Garrison" -- L["Garrison"]
	local ldbName = name
	local tt -- tooltips
	local ttName = name.."TT"
	local buildings,nBuildings,construct,nConstruct = {},0,{},0
	local updater = false;
	local longer = false;

-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
	--I[name] = {iconfile=("Interface\\Icons\\Achievement_Garrison_Monument_%s_Profession"):format(ns.player.faction), coords={0.1,0.9,0.1,0.9}}
	--I[name] = {iconfile="Interface\\Icons\\ACHIEVEMENT_GUILDPERK_WORKINGOVERTIME", coords={0.1,0.9,0.1,0.9}}
	I[name] = {iconfile="Interface\\Icons\\inv_garrison_resource", coords={0.05,0.95,0.05,0.95}}
	--I[name] = {iconfile="Interface\\Icons\\Achievement_General_WorkingasaTeam", coords={0.1,0.9,0.1,0.9}}


---------------------------------------
-- module variables for registration --
---------------------------------------
	ns.modules[name] = {
		desc = L["Broker to show your different currencies."],
		--icon_suffix = "_Neutral",
		enabled = false,
		events = {
			"GARRISON_LANDINGPAGE_SHIPMENTS",
			"GARRISON_UPDATE",
			--"CURRENCY_DISPLAY_UPDATE",
			"GARRISON_BUILDING_UPDATE",
			"GARRISON_BUILDING_PLACED",
			"GARRISON_BUILDING_REMOVED",
			"GARRISON_BUILDING_LIST_UPDATE",
			"GARRISON_BUILDING_ACTIVATED",
			"GARRISON_UPGRADEABLE_RESULT",
			--"GARRISON_BUILDING_ERROR",
		},
		updateinterval = 30, -- 10
		config_defaults = {},
		config_allowed = {},
		config = nil
	}

--C_Garrison.RequestLandingPageShipmentInfo()

--------------------------
-- some local functions --
--------------------------
	local function makeTooltip(tt)
		local now, timeleft, timeleftAll, shipmentsCurrent = time();
		local none, qualities = true,{"white","ff1eaa00","ff0070dd","ffa335ee"};
--		local building = "|T%s:0|t "..C("ltyellow","%s").." "..C("gray","(%s %d%s)");
		local building = "|T%s:0|t "..C("ltyellow","%s").." "..C("ltgray","(%d%s)");
		local _ = function(n)
			if (IsShiftKeyDown()) then -- TODO: modifier key adjustable...
				return date("%Y-%m-%d %H:%M",time() + n); -- TODO: timestring adjustable...
			end
			return SecondsToTime(n,true);
		end;
		tt:Clear();
		tt:AddHeader(C("dkyellow",L[name]));

		if (nBuildings>0) then
			tt:AddSeparator(4,0,0,0,0);
			tt:AddLine(C("ltblue",L["Name"]),C("ltblue","Follower"),C("ltblue",L["Max."]),C("ltblue",L["Ready"]),C("ltblue",L["In|nprogress"]),C("ltblue",L["Single|nduration"]),C("ltblue",L["Overall|nduration"]));
			tt:AddSeparator();
			for i,v in ipairs(buildings) do
				if (v) then
					timeleft,timeleftAll = nil,nil;
					if (v.creationTime) then
						timeleft = _(now-v.creationTime);
						timeleftAll = _(now-v.creationTime+(v.duration*(v.shipmentsTotal - v.shipmentsReady - 1)));
					end
					tt:AddLine(
--						(building):format(v.texture,v.name,L["Level"],v.rank, (v.canUpgrade) and "|T"..ns.media.."GarrUpgrade:12:12:0:0:32:32:4:24:4:24|t" or ""),
						(building):format(v.texture,v.name,v.rank, (v.canUpgrade) and "|T"..ns.media.."GarrUpgrade:12:12:0:0:32:32:4:24:4:24|t" or ""),
						(v.follower) and C(v.follower.class,v.follower.name) .. C(qualities[v.follower.quality], " ("..v.follower.level..")") or (v.hasFollowerSlot and C("gray",L["Free job"]) or ""),
						(v.shipmentCapacity) and v.shipmentCapacity or "",
						(v.shipmentCapacity and v.shipmentsReady>0) and v.shipmentsReady or "",
						(v.shipmentCapacity and v.shipmentsTotal>0) and (v.shipmentsTotal - v.shipmentsReady) or "",
						(v.shipmentCapacity and timeleft) and timeleft or "",
						(v.shipmentCapacity and timeleftAll) and timeleftAll or ""
					)
				end
			end
			none = false;
		end

		-- cunstruction list
		if (nConstruct>0) then
			local l,c;
			if (not none) then tt:AddSeparator(4,0,0,0,0); end

			tt:AddLine(C("ltblue",L["Under construction"]));
			tt:AddSeparator();
			for i,v in ipairs(construct) do
				tt:AddLine(C("ltyellow",v.name))
			end

			none = false;
		end

		if (none) then
			tt:AddLine(L["No buildings found..."]);
		else
			if (Broker_EverythingDB.showHints) then
				tt:AddSeparator(4,0,0,0,0,0)
				local line, column = tt:AddLine()
				tt:SetCell(line, 1, C("copper", L["Hold shift"]).." || "..C("green", L["to see duration ending times."]) , nil, nil, 5)
			end
		end
	end

------------------------------------
-- module (BE internal) functions --
------------------------------------
	--[[ ns.modules[name].init = function(self) end ]]
	EXPOSE = {};
	ns.modules[name].onevent = function(self,event,msg)
		updater = true;
		longer = false;
		nBuildings = 0;
		local obj = ns.LDB:GetDataObjectByName(ldbName)
		local bName, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, shipmentsCurrent
		local tmp = C_Garrison.GetBuildings() or {};


		buildings = C_Garrison.GetBuildings() or {};
		local names,ready,progress,_ = {},0,0;
		for i=1, #buildings do
			if (buildings[i].buildingID) then
				_, buildings[i].name, _, buildings[i].texture, buildings[i].rank, buildings[i].isBuilding, buildings[i].timeStart, buildings[i].buildTime, buildings[i].canActivate, buildings[i].canUpgrade, buildings[i].isPrebuilt = C_Garrison.GetOwnedBuildingInfoAbbrev(buildings[i].plotID);
				_, _, _, _, _, _, _, _, _, _, _, _, _, buildings[i].upgrades, _, _, buildings[i].hasFollowerSlot = C_Garrison.GetBuildingInfo(buildings[i].plotID);
				_, _, buildings[i].shipmentCapacity, buildings[i].shipmentsReady, buildings[i].shipmentsTotal, buildings[i].creationTime, buildings[i].duration = C_Garrison.GetLandingPageShipmentInfo(buildings[i].buildingID);

				-- catch double posted buildings while under construction
				if (buildings[i].name) then
					if (names[buildings[i].name]) then
						if (names[buildings[i].name][2]>buildings[i].rank) then
							buildings[names[buildings[i].name][1]] = nil;
						else
							buildings[i] = nil;
						end
					else
						names[buildings[i].name] = {i,buildings[i].rank};
					end
				end
			end
		end

		for i=1, #buildings do
			if (buildings[i]) then

				local fID = select(5,C_Garrison.GetFollowerInfoForBuilding(buildings[i].plotID));

				if (fID) then
					buildings[i].follower = C_Garrison.GetFollowerInfo(fID);
					buildings[i].follower.class = strsub(buildings[i].follower.classAtlas,23);
					--(isBuilding or canActivate or not owned);
				end

				buildings[i].shipmentsReady = buildings[i].shipmentsReady or 0;
				buildings[i].shipmentsTotal = buildings[i].shipmentsTotal or 0;

				if (buildings[i].shipmentCapacity==0) then
					buildings[i].shipmentCapacity = nil;
				end

				if (buildings[i].shipmentsReady) then
					ready = ready + buildings[i].shipmentsReady;
				end

				if (buildings[i].shipmentsTotal) then
					progress = progress + buildings[i].shipmentsTotal;
				end

				if (not buildings[i].texture) then
					buildings[i].texture = "interface\\icons\\inv_misc_questionmark";
				end

				nBuildings = nBuildings + 1;
			end
		end

		EXPOSE = buildings;

		local plots = C_Garrison.GetPlots();
		wipe(construct);
		nConstruct=0;
		for i, plot in ipairs(plots) do
			local id, name, texPrefix, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade, isPrebuilt = C_Garrison.GetOwnedBuildingInfoAbbrev(plot.id);
			if (id) then
				local timeEnd = timeStart + buildTime;
				local duration = timeEnd - time();
				if (isBuilding) or (duration>0) then
					tinsert(construct, {
						id			= id,
						icon		= icon,
						name		= name,
						texPrefix	= texPrefix,
						rank		= rank,
						isBuilding	= isBuilding,
						isPrebuilt	= isPrebuilt,
						timeStart	= timeStart,
						timeStartStr= date("%Y-%m-%d %H:%M",timeStart),
						timeEnd		= timeEnd,
						timeEndStr	= date("%Y-%m-%d %H:%M",timeEnd),
						duration	= duration,
						durationStr	= duration --SecondsToTime(duration)
					});
					nConstruct = nConstruct + 1;
				end
			end
		end

		progress = progress - ready
		if (not Broker_EverythingGlobalDB[name.."_cache"]) then Broker_EverythingGlobalDB[name.."_cache"] = {}; end
		Broker_EverythingGlobalDB[name.."_cache"][C(ns.player.class,ns.player.name).." - "..ns.realm] = buildings;
		obj.text = ("%s/%s"):format(C("ltblue",ready),C("orange",progress))
	end

	ns.modules[name].onupdate = function(self)
		if not updater then return end
		C_Garrison.RequestLandingPageShipmentInfo() -- stupid event triggering to get new data
	end

	--[[ ns.modules[name].optionspanel = function(panel) end ]]

	--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

	--[[ ns.modules[name].ontooltip = function(self) end ]]


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
	ns.modules[name].onenter = function(self)
		if (ns.tooltipChkOnShowModifier(false)) then return; end

		tt = ns.LQT:Acquire(name.."TT", 7, "LEFT","LEFT", "CENTER", "CENTER", "CENTER", "RIGHT","RIGHT")
		makeTooltip(tt)
		ns.createTooltip(self, tt)
	end

	ns.modules[name].onleave = function(self)
		if (tt) then ns.hideTooltip(tt,ttName,true); end
	end

	--[[ ns.modules[name].onclick = function(self,button) end ]]

	--[[ ns.modules[name].ondblclick = function(self,button) end ]]

