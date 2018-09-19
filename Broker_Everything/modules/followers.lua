
----------------------------------
-- module independent variables --
----------------------------------
	local addon, ns = ...
	local C, L, I = ns.LC.color, ns.L, ns.I

	if ns.build<60000000 then return end

-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
	local name = "Follower" -- L["Follower"]
	local ldbName = name
	local tt -- tooltips
	local ttName = name.."TT"
	local followers = {available={}, onmission={}, onwork={}, onresting={}, unknown={},num=0};
	local delay=false;

-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
	I[name]  = {iconfile="Interface\\Icons\\Achievement_GarrisonFolLower_Rare", coords={0.1,0.9,0.1,0.9} }


---------------------------------------
-- module variables for registration --
---------------------------------------
	ns.modules[name] = {
		desc = L["Broker to show your different currencies."],
		--icon_suffix = "_Neutral",
		enabled = false,
		events = {
			"PLAYER_ENTERING_WORLD",
			"GARRISON_FOLLOWER_LIST_UPDATE",
			"GARRISON_FOLLOWER_XP_CHANGED",
			"GARRISON_FOLLOWER_REMOVED"
		},
		updateinterval = 30,
		config_defaults = {},
		config_allowed = {},
		config = nil
	}


--------------------------
-- some local functions --
--------------------------
	local function getFollowers()
		local _ = function(count,level,xp,quality)
			local num = ("%04d"):format(count);
			num = ("%03d"):format(100-ceil(xp))  .. num
			num = ("%02d"):format(10-quality)    .. num
			num = ("%02d"):format(100-level)     .. num
			return num
		end
		local xp = 0
		local tmp = C_Garrison.GetFollowers();
		followers = {available={},available_num=0,onmission={},onwork_num=0,onwork={},onmission_num=0,onresting={},onresting_num=0,unknown={},unknown_num=0,num=0};
		for i,v in ipairs(tmp)do
			if v.isCollected==true then
				v.AbilitiesAndTraits = C_Garrison.GetFollowerAbilities(v.followerID);
				if v.status==nil then
					followers.available_num = followers.available_num + 1
					xp = (v.levelXP>0) and (v.xp/v.levelXP*100) or 100
					followers.available[_(followers.available_num,v.level,xp,v.quality)] = v
				elseif v.status==GARRISON_FOLLOWER_ON_MISSION then
					followers.onmission_num = followers.onmission_num + 1
					xp = (v.levelXP>0) and (v.xp/v.levelXP*100) or 100
					followers.onmission[_(followers.onmission_num,v.level,xp,v.quality)] = v
				elseif v.status==GARRISON_FOLLOWER_EXHAUSTED then
					followers.onresting_num = followers.onresting_num + 1
					xp = (v.levelXP>0) and (v.xp/v.levelXP*100) or 100
					followers.onresting[_(followers.onresting_num,v.level,xp,v.quality)] = v
				elseif v.status==GARRISON_FOLLOWER_WORKING then
					followers.onwork_num = followers.onwork_num + 1
					xp = (v.levelXP>0) and (v.xp/v.levelXP*100) or 100
					followers.onwork[_(followers.onwork_num,v.level,xp,v.quality)] = v
				else
					followers.unknown_num = followers.unknown_num + 1
					xp = (v.levelXP>0) and (v.xp/v.levelXP*100) or 100
					followers.unknown[_(followers.unknown_num,v.level,xp,v.quality)] = v
				end
				followers.num = followers.num + 1
			end
		end
		--XYDB.followers = followers
		--XYDB.followers_all = C_Garrison.GetFollowers();
	end

	local function makeTooltip(tt)
		local labels, colors, qualities,count = {GARRISON_FOLLOWER_EXHAUSTED,GARRISON_FOLLOWER_ON_MISSION,GARRISON_FOLLOWER_WORKING,L["Available"],L["Unknown"]},{"ltblue","yellow","yellow","green","red"},{"white","ff1eaa00","ff0070dd","ffa335ee"},0
		tt:AddHeader(C("dkyellow",L["Follower"]))

		for i,v in ipairs({"onresting","onmission","onwork","available","unknown"}) do
			local fD = followers[v];
			if (followers[v.."_num"]>0) then
				tt:AddSeparator(4,0,0,0,0)
				tt:AddLine(
					C(colors[i],labels[i]),
					C("ltblue",L["Level"]),
					C("ltblue",L["XP"]),
					C("ltblue",L["iLevel"]),
					C("ltblue",L["Abilities|n& Traits"]),
					C("ltblue",L["Professions"])
				)
				tt:AddSeparator()
				for i,v in ns.pairsByKeys(followers[v]) do
					local class = "red"
					if type(v["classAtlas"])=="string" then
						class = strsub(v["classAtlas"],23)
					end
					if strlen(v["name"])==0 then
						v["name"] = "["..L["Unknown"].."]"
					end
					local a,t = "",""
					for _,at in ipairs(v.AbilitiesAndTraits) do
						if not (at.icon:find("Trade_") or at.icon:find("INV_Misc_Gem_01")) then
							a = a .. " |T"..at.icon..":0|t";
						else
							t = t .. " |T"..at.icon..":0|t";
						end
					end
					if v["levelXP"]~=0 then
						l,c = tt:AddLine(
							C(class,v["name"]),
							v["level"].." ",
							("%1.1f"):format(v.xp / v.levelXP * 100).."%",
							v.iLevel,
							a,
							t
						)
					else
						l,c = tt:AddLine(
							C(class,v.name),
							v.level.." ",
							C("gray","100.0%"),
							v.iLevel,
							a,
							t
						)
					end
					local col = C(qualities[v.quality],"colortable");
					tt.lines[l].cells[2]:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", tile = false, insets = { left = 0, right = 0, top = 1, bottom = 0 }})
					tt.lines[l].cells[2]:SetBackdropColor(col[1],col[2],col[3],.4);
				end
			end
		end

		if (followers.num==0) then
			tt:AddLine(L["No followers found..."]);
		end
	end

------------------------------------
-- module (BE internal) functions --
------------------------------------
	--[[ ns.modules[name].init = function(self) end ]]

	ns.modules[name].onevent = function(self,event,msg)
		getFollowers();
		local obj = ns.LDB:GetDataObjectByName(ldbName)
		obj.text = ("%s/%s/%s/%s"):format(C("ltblue",followers.onresting_num),C("yellow",followers.onmission_num+followers.onwork_num),C("green",followers.available_num),followers.num);
		if delay == false then
			C_Timer.After(10,ns.modules[name].onevent)
			delay = true
		end
	end

	ns.modules[name].onupdate = function(self)
		if UnitLevel("player")>=90 and followers.num==0 then
			-- stupid blizzard forgot to trigger this event after all types of long distance ports (teleport/portals/homestones)...
			ns.modules[name].onevent(self,"GARRISON_FOLLOWER_LIST_UPDATE")
		end
	end

	--[[ ns.modules[name].optionspanel = function(panel) end ]]

	--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

	--[[ ns.modules[name].ontooltip = function(self) end ]]


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
	ns.modules[name].onenter = function(self)
		if (ns.tooltipChkOnShowModifier(false)) then return; end

		tt = ns.LQT:Acquire(name.."TT", 6, "LEFT", "RIGHT", "RIGHT", "CENTER", "CENTER", "CENTER")
		makeTooltip(tt)
		ns.createTooltip(self, tt)
	end

	ns.modules[name].onleave = function(self)
		if (tt) then ns.hideTooltip(tt,ttName,true); end
	end

	--[[ ns.modules[name].onclick = function(self,button) end ]]

	--[[ ns.modules[name].ondblclick = function(self,button) end ]]



--[[
	empty table on some reloads?
	- 1 time


	wo is das event, wenn eine completed mission erfolgreich abgegeben wurde??
]]
