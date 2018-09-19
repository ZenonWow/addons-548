
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Stuff" -- L["Stuff"]
local ldbName = name
local ttName = name.."TT"
local tt = nil
local last_click = 0


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Addons\\"..addon.."\\media\\stuff"}


---------------------------------------
-- module variables for registration --
---------------------------------------
ns.modules[name] = {
	desc = L["Broker to allow you to do...Stuff! Switch to windowed mode, reload ui, logout and quit."],
	events = {},
	updateinterval = nil, -- 10
	config_defaults = nil, -- {}
	config_allowed = nil,
	config = nil -- {}
}


--------------------------
-- some local functions --
--------------------------
StaticPopupDialogs["CONFIRM"] = {
	text = L["Are you sure you want to Reload the UI?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		ReloadUI()
	end,
	timeout = 20,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 5,
}


------------------------------------
-- module (BE internal) functions --
------------------------------------

ns.modules[name].init = function(obj)
	ldbName = (Broker_EverythingDB.usePrefix and "BE.." or "")..name
	if not obj then return end
	obj = obj.obj or ns.LDB:GetDataObjectByName(ldbName) 
end

--[[ ns.modules[name].onevent = function(self,event,msg) end ]]

--[[ ns.modules[name].onupdate = function(self) end ]]

--[[ ns.modules[name].optionspanel = function(panel) end ]]

--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

ns.modules[name].ontooltip = function(tt)
	if (not tt.key) or tt.key~=ttName then return end -- don't override other LibQTip tooltips...

	local line, column
	
	tt:Clear()
	tt:AddHeader(C("dkyellow",L[name])) 
	tt:AddLine (" ")
	
	line, column = tt:AddLine(L["Windowed / Fullscreen"])
	tt:SetLineScript(line, "OnMouseUp", function(self) 
		ns.SetCVar("gxWindow", 1 - tonumber(GetCVar("gxWindow")))
		RestartGx()
	end)			
	tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
	tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
	
	line, column = tt:AddLine(L["Reload UI"])
	tt:SetLineScript(line, "OnMouseUp", function(self)	StaticPopup_Show("CONFIRM")	end) -- Use static Popup to avoid taint.
	tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
	tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
	
	line, column = tt:AddLine(L["Logout"])
	tt:SetLineScript(line, "OnMouseUp", function(self) Logout() end)			
	tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
	tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
	
	line, column = tt:AddLine(L["Quit Game"])
	tt:SetLineScript(line, "OnMouseUp", function(self) Quit() end)			
	tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
	tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
	
	if Broker_EverythingDB.showHints then
		tt:AddLine(" ")
		line, column = nil, nil
		tt:AddLine(
			C("copper",L["Left-click"]).." || "..C("green",L["Logout"])
			.."|n"..
			C("copper",L["Right-click"]).." || "..C("green",L["Quit game"])
--			.."|n"..
--			C("copper",L["Shift+Left-click"]).." || "..C("green",L["Switch window/fullscreen mode"])
			.."|n"..
			C("copper",L["Shift+Left-click"]).." || "..C("green",L["Reload UI"])
		)
	end
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
ns.modules[name].onenter = function(self)
	if (ns.tooltipChkOnShowModifier(false)) then return; end

	tt = ns.LQT:Acquire(ttName, 1, "LEFT") 
	ns.modules[name].ontooltip(tt)
	ns.createTooltip(self,tt)
end

ns.modules[name].onleave = function(self)
	if (tt) then ns.hideTooltip(tt,ttName,false,true); end
end

ns.modules[name].onclick = function(self,button)
	local shift = IsShiftKeyDown() or -1
	local cv = 0

	if button == "RightButton" then
		cv = 1 * shift
	elseif button == "LeftButton" then
		cv = 2 * shift
	end

	if last_click ~= cv then
		last_click = cv
		return
	end

	-- only for windowed mode switching...
	last_click = 0

	if shift > 0 then
		if button == "LeftButton" then
			securecall("ReloadUI")
		elseif button == "RightButton" then
			--SetCVar("gxWindow", 1 - GetCVar("gxWindow"))
			--RestartGx()
		end
	else
		if button == "LeftButton" then
			securecall("Logout")
		elseif button == "RightButton" then
			securecall("Quit")
		end
	end
end

--[[ ns.modules[name].ondblclick = function(self,button) end ]]

