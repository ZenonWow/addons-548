
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Clock" -- L["Clock"]
local ldbName = name
local tt
local ttName = name.."TT"
local GetGameTime = GetGameTime
local GetGameTime2
local countries = {}
local played = false
local clock_diff = nil

-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Addons\\"..addon.."\\media\\clock"}


---------------------------------------
-- module variables for registration --
---------------------------------------
ns.modules[name] = {
	desc = L["Broker to show realm or local time"],
	events = {"TIME_PLAYED_MSG"},
	updateinterval = 1,
	timeout = 30,
	timeoutAfterEvent = "PLAYER_ENTERING_WORLD",
	config_defaults = {
		format24 = true,
		timeLocal = true,
		showSeconds = false
	},
	config_allowed = {
	},
	config = {
		height = 52,
		elements = {
			{
				type = "check",
				name = "format24",
				label = L["24 hours mode"], -- TIMEMANAGER_24HOURMODE
				desc = L["Switch between time format 24 hours and 12 hours with AM/PM"],
			},
			{
				type = "check",
				name = "timeLocal",
				label = L["Local or server time"],
				desc = L["Switch between local and server time in broker button"]
			},
			{
				type = "check",
				name = "showSeconds",
				label = L["Show seconds"],
				desc = L["Display the time with seconds in broker button and tooltip"]
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------
local function generateTooltip(tt)
	local h24 = Broker_EverythingDB[name].format24
	local dSec = Broker_EverythingDB[name].showSeconds
	local pT,pL,pS = ns.LT.GetPlayedTime()

	tt:Clear()
	tt:AddHeader(C("dkyellow",L[name]))
	tt:AddSeparator()

	tt:AddLine(C("ltyellow",L["Local Time"]),	C("white",ns.LT.GetTimeString("GetLocalTime",h24,dSec)))
	tt:AddLine(C("ltyellow",L["Server Time"]),	C("white",ns.LT.GetTimeString("GetGameTime",h24,dSec)))
	tt:AddLine(C("ltyellow",L["UTC Time"]),		C("white",ns.LT.GetTimeString("GetUTCTime",h24,dSec)))

	tt:AddSeparator(3,0,0,0,0)

	tt:AddLine(C("ltblue",L["Playtime"]))
	tt:AddSeparator()
	tt:AddLine(C("ltyellow",L["Total"]),C("white",SecondsToTime(pT)))
	tt:AddLine(C("ltyellow",L["Level"]),C("white",SecondsToTime(pL)))
	tt:AddLine(C("ltyellow",L["Session"]),C("white",SecondsToTime(pS)))

	if Broker_EverythingDB.showHints then
		tt:AddSeparator(3,0,0,0,0)
		tt:AddLine(C("copper",L["Left-click"]).." ||"		,C("green",L["Open time manager"]))
		tt:AddLine(C("copper",L["Right-click"]).." ||"		,C("green",L["Local or server time"]))
		tt:AddLine(C("copper",L["Shift+Right-click"]).." ||",C("green",L["Open calendar"]))
		tt:AddLine(C("copper",L["Shift+Left-click"]).." ||"	,C("green",L["12 / 24 hours mode"]))
	end

end


------------------------------------
-- module (BE internal) functions --
------------------------------------
ns.modules[name].init = function(obj)
	ldbName = (Broker_EverythingDB.usePrefix and "BE.." or "")..name
end

ns.modules[name].onevent = function(self,event,...)
	if event=="TIME_PLAYED_MSG" then
		played = true
	end
end

--[[ ns.modules[name].optionspanel = function(panel) end ]]

--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

ns.modules[name].onupdate = function(self)
	if not self then self = {} end
	self.obj = self.obj or ns.LDB:GetDataObjectByName(ldbName)

	local h24 = Broker_EverythingDB[name].format24
	local dSec = Broker_EverythingDB[name].showSeconds

	self.obj.text = Broker_EverythingDB[name].timeLocal and ns.LT.GetTimeString("GetLocalTime",h24,dSec) or ns.LT.GetTimeString("GetGameTime",h24,dSec)

	if tt~=nil and tt.key==name.."TT" and tt:IsShown() then
		generateTooltip(tt)
	end
end

ns.modules[name].ontimeout = function(self)
	if played==false then
		--RequestTimePlayed()
	end
end

ns.modules[name].ontooltip = function(tt)
	if (not tt.key) or tt.key~=ttName then return end -- don't override other LibQTip tooltips...
	ns.tooltipScaling(tt)
	local h24 = Broker_EverythingDB[name].format24
	local dSec = Broker_EverythingDB[name].showSeconds
	tt:ClearLines()

	tt:AddLine(L[name])
	tt:AddLine(" ")

	tt:AddDoubleLine(C("white",L["Local Time"]), C("white",ns.LT.GetTimeString("GetLocalTime",h24,dSec)))
	tt:AddDoubleLine(C("white",L["Server Time"]), C("white",ns.LT.GetTimeString("GetGameTime",h24,dSec)))

	if Broker_EverythingDB.showHints then
		tt:AddLine(" ")
		tt:AddLine(C("copper",L["Left-click"]).." || "..C("green",L["Open time manager"]))
		tt:AddLine(C("copper",L["Right-click"]).." || "..C("green",L["Local or server time"]))
		tt:AddLine(C("copper",L["Shift+Right-click"]).." || "..C("green",L["Open calendar"]))
		tt:AddLine(C("copper",L["Shift+Left-click"]).." || "..C("green",L["12 / 24 hours mode"]))
	end
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
ns.modules[name].onenter = function(self)
	if (ns.tooltipChkOnShowModifier(false)) then return; end

	tt = ns.LQT:Acquire(ttName, 2 , "LEFT", "RIGHT" )
	generateTooltip(tt)
	ns.createTooltip(self,tt)
end

ns.modules[name].onleave = function(self)
	if (tt) then ns.hideTooltip(tt,ttName,true); end
	if (tt2) then ns.hideTooltip(tt2,ttName2,true); end --?
end

ns.modules[name].onclick = function(self,button)
	local shift = IsShiftKeyDown()
	if button == "RightButton" and not shift then
		if Broker_EverythingDB[name].timeLocal == true then
			Broker_EverythingDB[name].timeLocal = false
		else
			Broker_EverythingDB[name].timeLocal = true
		end
		ns.modules[name].onupdate(self)
	elseif button == "RightButton" and shift then
		securecall("ToggleCalendar")
	elseif button == "LeftButton" and shift then 
		if Broker_EverythingDB[name].format24 == true then
			Broker_EverythingDB[name].format24 = false
		else
			Broker_EverythingDB[name].format24 = true
		end
		ns.modules[name].onupdate(self)
	else
		securecall("ToggleTimeManager")
	end
end

--[[ ns.modules[name].ondblclick = function(self,button) end ]]




--[[

Time
-------------------
Server
Local

Playtime
-------------------
playtime total
playtime level
playtime session

Other Countries
-------------------
<5 chooseable>

]]

