
----------------------------------
-- module independent variables --
----------------------------------
	local addon, ns = ...
	local C, L, I = ns.LC.color, ns.L, ns.I

	if ns.build<60000000 then return end

-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
	local name = "Missions" -- L["Missions"]
	local tt -- tooltips
	local ttName = name.."TT"
	local missions = {inprogress={},available={},completed={}}
	local started = {}

-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
	I[name]  = {iconfile="Interface\\Icons\\Achievement_RareGarrisonQuests_X", coords={0.1,0.9,0.1,0.9} }


---------------------------------------
-- module variables for registration --
---------------------------------------
	local module = {
		desc = L["Broker to show your different currencies."],
		--icon_suffix = "_Neutral",
		enabled = false,
		events = {
			"PLAYER_ENTERING_WORLD",
			"GARRISON_MISSION_LIST_UPDATE",
			"GARRISON_MISSION_STARTED",
			"GARRISON_MISSION_FINISHED"
		},
		updateinterval = 30,
		config_defaults = {
			-- chars_progress = {}
		},
		config_allowed = nil,
		config = nil,
	}


--------------------------
-- some local functions --
--------------------------
	--[[
	do
		local lst = GarrisonMissionFrame.MissionList
		local function hookStart(self)
			local p = self:GetParent().missonInfo; -- GarrisonMissionFrame.MissionTab.MissionPage

			

		end
		GarrisonMissionFrame.MissionTab.MissionPage.StartMissionButton:HookScript("OnClick", hookStart);
	end
	]]

	local function stripTime(str,tag)
		-- ["HOURS_ABBR"] = "%d |4Std.:Std.;",
		-- ["MINUTES_ABBR"] = "%d |4Min.:Min.;",
		-- ["SECONDS_ABBR"] = "%d |4Sek.:Sek.;",
		local h, m, s = str:match("(%d+)");
	end

	local function makeTooltip(tt)
		tt:Clear()
		local labels,colors,count,l,c = {"Missions completed","Missions in progress","Missions available"},{"ltblue","yellow","green"},0
		tt:AddHeader(C("dkyellow",L[name]))

		for mI,mD in ipairs({missions.completed,missions.inprogress,missions.available}) do
			if #mD>0 then
				local duration_title = L["duration"]
				tt:AddSeparator(4,0,0,0,0)
				if (missions.inprogress == mD) then
					duration_title = L["time left"]
				end
				tt:AddLine(
					C(colors[mI],L[labels[mI]]),
					C("ltblue",L["Level"]),
					C("ltblue",L["Type"]),
					C("ltblue",L["iLevel"]),
					C("ltblue",L["Follower"]),
					C("ltblue",duration_title)
				)
				tt:AddSeparator()
				for mi, md in ipairs(mD) do
					local duration_str = md["duration"]
					if duration_title == L["time left"] then
						duration_str = md["timeLeft"]
					end

					local color,color_lvl,lvl = "white","white",md["level"];
					if (md["isElite"]) then
						lvl = "++"..lvl
						color_lvl="violet"
					elseif (md["isRare"]) then
						lvl = "+"..lvl
						color_lvl = "ff00eeff"
					end
						
					if (md["isExhausting"]) then
						color = "orange"
						if (color_lvl=="white") then
							color_lvl = color
						end
					end

					l,c = tt:AddLine(
						C(color,md["name"]),
						C(color_lvl,lvl),
						C(color,md["type"]),
						C(color,(md["iLevel"]>0 and md["iLevel"] or "-")),
						C(color,md["numFollowers"]),
						C(color,duration_str)
					)
					--stripTime(duration_str);
				end
				count = count + 1;
			end
		end

		if (count==0) then
			tt:AddLine(L["No missions found..."]);
		end

		if (Broker_EverythingDB[name].chars_progress) then
			
		end
	end --LoadAddOn("Blizzard_GarrisonUI")

	local function update()
		local location, xp, environment, environmentDesc, environmentTexture, locPrefix, isExhausting, enemies
		local obj = module.obj
		missions.inprogress = C_Garrison.GetInProgressMissions() or {};
		missions.available  = C_Garrison.GetAvailableMissions() or {};
		missions.completed  = C_Garrison.GetCompleteMissions() or {};

		--Broker_EverythingDB[name].chars_progress[C(ns.player.class, ns.player.name.." - "..ns.realm)] = {
		--	inprogress = #missions.inprogress,
		--	completed = #missions.completed
		--}

		local cIds = {}
		for i,v in ipairs(missions.completed) do
			cIds[v["missionID"]..v["name"]] = true;
			missions.completed[i].isExhausting = select(7,C_Garrison.GetMissionInfo(v.missionID))
		end
		local tmp = {}
		for i,v in pairs(missions.inprogress) do
			if (not cIds[v["missionID"]..v["name"]]) then
				tinsert(tmp,v)
			end
			missions.inprogress[i].isExhausting = select(7,C_Garrison.GetMissionInfo(v.missionID))
		end
		for i,v in pairs(missions.available) do
			missions.available[i].isExhausting = select(7,C_Garrison.GetMissionInfo(v.missionID))
		end

		missions.inprogress = tmp
		obj.text = ("%s/%s/%s"):format(C("ltblue",#missions.completed),C("yellow",#missions.inprogress),C("green",#missions.available));

		--XYDB.missions = missions
	end

------------------------------------
-- module (BE internal) functions --
------------------------------------

	module.onevent = function(self,event,msg)
		update()
	end

	module.onupdate = function(self)
		update()
	end

-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
	module.onenter = function(self)
		if (ns.tooltipChkOnShowModifier(false)) then return; end

		tt = ns.LQT:Acquire(name.."TT", 6, "LEFT", "RIGHT", "LEFT", "CENTER", "CENTER","RIGHT")
		makeTooltip(tt)
		ns.createTooltip(self, tt)
	end

	module.onleave = function(self)
		ns.hideTooltip(tt,ttName,true)
	end


-- final module registration --
-------------------------------
ns.modules[name] = module

