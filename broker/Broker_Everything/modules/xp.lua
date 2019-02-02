
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I
xpDB = {}

-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "XP" -- L["XP"]
local string = string
local tooltip,tt2
local data = {}
local slots = {  [1]=L["Head"], [3]=L["Shoulder"], [5]=L["Chest"], [7]=L["Legs"], [15]=L["Back"], [11]=L["Ring1"], [12]=L["Ring2"]}
local items = { -- Heirlooms with {<percent>,<maxLevel>}
	-- Head
	[61931] = {10,85}, [61935] = {10,85}, [61936] = {10,85}, [61937] = {10,85}, [61942] = {10,85}, [61958] = {10,85}, [69887] = {10,85},
	-- shoulder
	[42949] = {10,80}, [42951] = {10,80}, [42952] = {10,80}, [42984] = {10,80}, [42985] = {10,80}, [44099] = {10,80}, [44100] = {10,80},
	[44101] = {10,80}, [44102] = {10,80}, [44103] = {10,80}, [44105] = {10,80}, [44107] = {10,80}, [69890] = {10,80}, [93859] = {10,85},
	[93861] = {10,85}, [93862] = {10,85}, [93864] = {10,85}, [93866] = {10,85}, [93876] = {10,85}, [93886] = {10,85}, [93887] = {10,85},
	[93889] = {10,85}, [93890] = {10,85}, [93893] = {10,85}, [93894] = {10,85},
	-- chest
	[48677] = {10,80}, [48683] = {10,80}, [48685] = {10,80}, [48687] = {10,80}, [48689] = {10,80}, [48691] = {10,80}, [69889] = {10,80},
	[93860] = {10,85}, [93863] = {10,85}, [93865] = {10,85}, [93885] = {10,85}, [93888] = {10,85}, [93891] = {10,85}, [93892] = {10,85},
	-- legs
	[62029] = {10,85}, [62026] = {10,85}, [62027] = {10,85}, [62024] = {10,85}, [62025] = {10,85}, [62023] = {10,85}, [69888] = {10,85},
	-- rings
	[50255] = {5,80},
	-- backs
	[62038] = {5,85}, [62039] = {5,85}, [62040] = {5,85}, [69892] = {5,85}
}
local spells = {
	[78631] = 5, -- Fast Track (Guild perk)
	[78632] = 10 -- Fast Track 2 (Guild perk)
}

-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="interface\\icons\\ability_dualwield",coords={0.05,0.95,0.05,0.95}}
--{iconfile="Interface\\Addons\\"..addon.."\\media\\xp"}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show your xp. Can be shown either as a percentage, or as values."],
	events = {
		"PLAYER_XP_UPDATE",
		"PLAYER_LOGIN",
		"DISABLE_XP_GAIN",
		"ENABLE_XP_GAIN",
		"UNIT_INVENTORY_CHANGED"
	},
	updateinterval = nil, -- 10
	config_defaults = {
		display = "1",
		showMyOtherChars = true,
		showNonMaxLevelOnly = false
	},
	config_allowed = {
		display = {["1"]=true,["2"]=true,["3"]=true}
	},
	config = {
		height = 52,
		elements = {
			{
				type = "check",
				name = "showMyOtherChars",
				label = L["Show other chars xp"],
				desc = L["Display a list of my chars on same realm with her level and xp"]
			},
			{
				type = "check",
				name = "showNonMaxLevelOnly",
				label = L["Chars under %d only"]:format(MAX_PLAYER_LEVEL),
				desc = L["Only display my chars under max player level."]
			},
			{
				type = "dropdown",
				name = "display",
				label = L["Display XP in broker"],
				desc = L["Select to show XP as an absolute value; Deselected will show it as a percentage."],
				default = "1",
				event = true,
				values = {
					["1"] = "Percent (77%)",
					["2"] = "Absolute value (1234/4567)",
					["3"] = "Til next level (1242)"
				}
			}
		}
	}
}

--------------------------
-- some local functions --
--------------------------
local function getTooltip2(parentTooltip, parentLine,data)
	tt2 = ns.LQT:Acquire(name.."TT2", 2, "LEFT", "RIGHT")

	tt2:Clear()

	tt2:AddLine(C("ltblue",L["XP bonus"]),C("green",data.xpBonusSum.."%"))
	tt2:AddSeparator(1)
	for i,v in ns.pairsByKeys(data.xpBonus) do
		if not (v.percent==false and (i==11 or i==12)) then
			tt2:AddLine(
				C(v.percent==false and "ltgray" or "ltyellow",v.name),
				(v.percent==false and C("ltgray",L["not equipped"])) or (v.outOfLevel and C("red",L["Out of Level"])) or v.percent.."%"
			)
		end
	end

	ns.createTooltip(parentLine, tt2)
	tt2:ClearAllPoints()
	tt2:SetPoint("TOP",parentLine,"TOP",0,0)

	local tt = parentTooltip
	local tL,tR,tT,tB = ns.getBorderPositions(tt)
	local uW = UIParent:GetWidth()
	if tR<(uW/2) then
		tt2:SetPoint("RIGHT",tt,"LEFT",-2,0)
	else
		tt2:SetPoint("LEFT",tt,"RIGHT",2,0)
	end
end

function module.onqtip(tt)
	if not tt then  return  end

	tt:Clear()
	tt:SetColumnLayout(2, "LEFT", "RIGHT")

	local l, c, _, x = nil,nil,function(...) local l,c = tt:AddLine() for i,v in ipairs({...}) do tt:SetCell(l,i,v) end return l,c end,function(str,align) local l,c = tt:AddLine() tt:SetCell(l,1,str,nil,align,2) return l,c end

	local tc,tx = "dkyellow",L[name]
	if IsXPUserDisabled() then tc,tx = "orange",L["XP gain disabled"] end

	l,c = tt:AddLine()
	tt:SetCell(l,1,C(tc,tx),tt:GetHeaderFont(),nil,2)
	tt:AddSeparator(1)

	_(C("ltyellow",L[name]),C("white",("%d/%d (%s)"):format(data.xp,data.xpMax,data.xpPercent)))
	_(C("ltyellow",L["Til Next Level"]),C("white",data.xpNeed))
	_(C("ltyellow",L["Rest"]),C("white",data.xpRest))

	if UnitLevel("player")<MAX_PLAYER_LEVEL and #data.xpBonus>0 then
		tt:AddSeparator(5,0,0,0,0)
		_(C("ltblue",L["XP bonus"]),C("green",data.xpBonusSum.."%"))
		tt:AddSeparator(1)
		for i,v in ns.pairsByKeys(data.xpBonus) do
			if not (v.percent==false and (i==11 or i==12)) then
				_(C(v.percent==false and "ltgray" or "ltyellow",v.name), (v.percent==false and C("ltgray",L["not equipped"])) or (v.outOfLevel and C("red",L["Out of Level"])) or v.percent.."%")
			end
		end
	end

	if Broker_EverythingDB[name].showMyOtherChars then
		tt:AddSeparator(5,0,0,0,0)
		l,c = tt:AddLine()
		tt:SetCell(l,1,C("ltblue",L["Your other chars (%s)"]:format(ns.realm)),nil,nil,2)
		tt:AddSeparator(1)
		local count = 0
		for i,v in pairs(xpDB[ns.realm]) do
			if v~=nil and i~=ns.player.name and not (Broker_EverythingDB[name].showNonMaxLevelOnly and v.level==MAX_PLAYER_LEVEL) then
				l,c = _(("(%d) %s %s"):format(v.level,C(v.class,ns.scm(i)),v.faction and "|TInterface\\PVPFrame\\PVP-Currency-"..v.faction..":16:16:0:-1:16:16:0:16:0:16|t" or ""), ("%d/%d (%s)"):format(v.xp,v.xpMax,v.xpPercent))
				tt:SetLineScript(l,"OnMouseUp",function(self,button) xpDB[ns.realm][i] = nil module.onqtip(tt) end)
				if #v.xpBonus>0 then
					tt:SetLineScript(l,"OnEnter",function(self) getTooltip2(tt,self,v) end)
					tt:SetLineScript(l,"OnLeave",function(self) ns.hideTooltip(tt2, nil, true) end)
				end
				count = count + 1
			end
		end
		if count == 0 then
			l,v = tt:AddLine()
			tt:SetCell(l,1,L["No data found"],nil,nil,2)
		end
	end

	if Broker_EverythingDB.showHints then
		tt:AddSeparator(5,0,0,0,0)
		if Broker_EverythingDB[name].showMyOtherChars then
			l,c = tt:AddLine()
			tt:SetCell(l,1,C("ltblue",L["Click"]).."||"..C("green",L["Delete a character from the list"]),nil,nil,2)
		end
		l,c = tt:AddLine()
		tt:SetCell(l,1,C("copper",L["Right-click"]).."||"..C("green",L["Switch mode"]),nil,nil,2)
	end
end

------------------------------------
-- module (BE internal) functions --
------------------------------------

module.onevent = function(self,event,msg)

	if event == "UNIT_INVENTORY_CHANGED" and msg~="player" then return end

	local dataobj = self.obj

	local xpBonus = 0
	data.xpBonus = {}
	for slotId,slotName in pairs(slots) do
		local itemId = GetInventoryItemID("player",slotId)
		if itemId and items[itemId] then
			xpBonus = xpBonus + items[itemId][1]
			data.xpBonus[slotId] = {name=slotName, percent=items[itemId][1], outOfLevel=UnitLevel("player")>items[itemId][2]}
		else
			data.xpBonus[slotId] = {name=slotName, percent=false}
		end
	end

	local count = 1
	for spellId, boost in pairs(spells) do
		if IsSpellKnown(spellId) then
			xpBonus = xpBonus + boost
			data.xpBonus[800+count] = {name=L["Guild"],percent=boost}
			count = count + 1
		end
	end

	if IsInGroup() or IsInRaid() then
		local raf_boost = false
		for i=1, GetNumGroupMembers() or 0 do
			local m = (IsInRaid() and "raid" or "party")..i
			if UnitIsVisible(m) and IsReferAFriendLinked(m) then
				raf_boost = true
				data.xpBonus[999] = {name=L["Recruite a Friend"],percent=300}
			end
		end
		if raf_boost then
			xpBonus = xpBonus + 300
		end
	end

	data.level       = UnitLevel("player")
	data.class       = ns.player.class
	data.faction     = ns.player.faction
	data.xp          = UnitXP("player")
	data.xpMax       = UnitXPMax("player")
	data.xpPercent   = math.floor((data.xp / data.xpMax) * 100).."%"
	data.xpNeed      = data.xpMax - data.xp
	data.xpRest      = GetXPExhaustion()
	data.xpRest      = data.xpRest and floor(data.xpRest / data.xpMax).."%" or "0%"
	data.xpBonusSum  = xpBonus

	if xpDB[ns.realm]==nil then xpDB[ns.realm] = {} end
	xpDB[ns.realm][ns.player.name] = data

	if IsXPUserDisabled() then
		dataobj.text = C("orange",L["XP gain disabled"])
	elseif Broker_EverythingDB[name].display == "1" then
		dataobj.text = data.xpPercent
	elseif Broker_EverythingDB[name].display == "2" then
		dataobj.text = data.xp.."/"..data.xpMax
	elseif Broker_EverythingDB[name].display == "3" then
		dataobj.text = data.xpNeed
	end

	-- TODO: Update the tooltip?
	module.onqtip(module.tooltip)
end

--[[ Replaced by .onqtip()
module.ontooltip = function(tooltip)
	ns.tooltipScaling(tooltip)

	if IsXPUserDisabled() then
		tooltip:AddLine(C("orange",L["XP gain disabled"]))
	else
		tooltip:AddLine(L[name])
	end

	tooltip:AddLine(" ")
	tooltip:AddDoubleLine(C("ltyellow",("%s:"):format(L[name])), C("white",("%d/%d (%s)"):format(data.xp,data.xpMax,data.xpPercent)))
	tooltip:AddDoubleLine(C("ltyellow",("%s:"):format(L["Til Next Level"])), C("white",data.xpNeed))
	tooltip:AddDoubleLine(C("ltyellow",("%s:"):format(L["Rest"])), C("white",data.xpRest))

	if Broker_EverythingDB.showHints then
		tooltip:AddLine(" ")
		tooltip:AddLine(C("copper",L["Right-click"]).." || "..C("green",L["Switch mode"]))
	end
end
--]]

-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------

module.mouseOverTooltip = true

module.onclick = function(self,button)
	if button == "LeftButton" then
		ToggleCharacter("PaperDollFrame")
		if  ns.OpenCharacterTab  then  ns.OpenCharacterTab(1)  end
	end
	if button == "RightButton" then
		if type(Broker_EverythingDB[name].display)=="boolean" then
			Broker_EverythingDB[name].display = "1"
		end
		if Broker_EverythingDB[name].display == "1"  then
			Broker_EverythingDB[name].display = "2"
		elseif Broker_EverythingDB[name].display == "2" then
			Broker_EverythingDB[name].display = "3"
		elseif Broker_EverythingDB[name].display == "3" then
			Broker_EverythingDB[name].display = "1"
		end
		module.onevent(self)
	end
end


-- final module registration --
-------------------------------
ns.modules[name] = module

