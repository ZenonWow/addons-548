
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Calendar" -- L["Calendar"]
local ldbName = name
local tt = nil


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Addons\\"..addon.."\\media\\calendar"}
I[name.."_pending"] = {iconfile="Interface\\Addons\\"..addon.."\\media\\calendar_pending"}


---------------------------------------
-- module variables for registration --
---------------------------------------
ns.modules[name] = {
	desc = L["Broker to show invitations"],
	events = {
		"CALENDAR_UPDATE_PENDING_INVITES",
		"PLAYER_LOGIN",
		"PLAYER_ENTERING_WORLD"
	},
	updateinterval = nil, -- 10
	config_defaults = {
		hideMinimapCalendar = false,
		shortBroker = false
	},
	config_allowed = {
	},
	config = {
		height = 52,
		elements = {
			{
				type  = "check",
				name  = "hideMinimapCalendar",
				label = L["Hide calendar button"],
				desc  = L["Hide Blizzard's minimap calendar button"]
			},
			{
				type  = "check",
				name  = "shortBroker",
				label = L["Shorter Broker"],
				desc  = L["Reduce the broker text to a number without text"],
				event = true
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------



------------------------------------
-- module (BE internal) functions --
------------------------------------
ns.modules[name].init = function(obj)
	ldbName = (Broker_EverythingDB.usePrefix and "BE.." or "")..name
	if not obj then
		if Broker_EverythingDB[name].hideMinimapCalendar == true then
			GameTimeFrame:Hide()
			GameTimeFrame.Show = dummyFunc
		end
	end
end

ns.modules[name].onevent = function(self,event,msg)
	self.obj = self.obj or ns.LDB:GetDataObjectByName(ldbName)
	local num = CalendarGetNumPendingInvites()

	local icon = I(name..(num~=0 and "_pending" or ""))
	self.obj.iconCoords = icon.coords
	self.obj.icon = icon.iconfile

	local suffix = " "..L[ num==1 and "Invite" or "Invites" ]
	if Broker_EverythingDB[name].shortBroker then
		suffix = ""
	end

	if num==0 then
		self.obj.text = num..suffix
	else
		self.obj.text = C("green",num..suffix)
	end
end

--[[ ns.modules[name].onupdate = function(self) end ]]

--[[ ns.modules[name].optionspanel = function(panel) end ]]

--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

ns.modules[name].ontooltip = function(tt)
	if (ns.tooltipChkOnShowModifier(false)) then tt:Hide(); return; end

	local x = CalendarGetNumPendingInvites()
	ns.tooltipScaling(tt)
	tt:AddLine(L[name])
	tt:AddLine(" ")
	if x == 0 then
		tt:AddLine(C("white",L["No invitations found"].."."))
	else
		tt:AddLine(C("white",x.." "..(x==1 and L["Invitation"] or L["Invitations"]).."."))
	end
	if Broker_EverythingDB.showHints then
		tt:AddLine(" ")
		tt:AddLine(C("copper",L["Click"]).." || "..C("green",L["Open calendar"]))
	end
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
--[[ ns.modules[name].onenter = function(self) end ]]

--[[ ns.modules[name].onleave = function(self) end ]]

ns.modules[name].onclick = function() securecall("ToggleCalendar") end

--[[ ns.modules[name].ondblclick = function(self,button) end ]]

--[=[
note:
	broker text can extend with accepted entries today

	tt can be extend with accepted today. (time, title) description are zoo much for tt.
	can be display in second tt on mouseover
]=]