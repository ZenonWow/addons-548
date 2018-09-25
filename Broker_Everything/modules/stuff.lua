
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

if  GetCVarBool == nil  then
	function GetCVarBool(cvar)  return GetCVar(cvar) == "1"  end
end

--[[
/run SetCVar("gxMaximize", 1); SetCVar("gxWindow", 1); RestartGx()
--]]
function ToggleFullscreen() 
  local wasMaximized= GetCVarBool("gxMaximize")
  local wasWindowed= GetCVarBool("gxWindow")
  local wasFullscreen= wasMaximized or not wasWindowed
  Broker_EverythingDB.Stuff= Broker_EverythingDB.Stuff or {}
  if  wasFullscreen  then
    -- save windowed state of fullscreen before switching
    Broker_EverythingDB.Stuff.fullscreenWindowed= wasWindowed
    -- go windowed and not maximized
    ns.SetCVar("gxMaximize", 0)
    ns.SetCVar("gxWindow", 1)
  else
    local fullscreenIsWindowed= Broker_EverythingDB.Stuff.fullscreenIsWindowed
    if  fullscreenIsWindowed == nil  then  fullscreenIsWindowed= true  end
		local varValue= fullscreenIsWindowed and 1 or 0
    ns.SetCVar("gxMaximize", varValue)  -- awkward logic: non-windowed fullscreen is not maximized
    --if  fullscreenIsWindowed  then  ns.SetCVar("gxMaximize", 1)  end
    ns.SetCVar("gxWindow", varValue)
  end
  --ns.SetCVar("gxWindow", 1 - tonumber(GetCVar("gxWindow")))
  RestartGx()
end

ns.modules[name].ontooltip = function(tt)
	if (not tt.key) or tt.key~=ttName then return end -- don't override other LibQTip tooltips...

	local line, column
	
	tt:Clear()
	tt:AddHeader(C("dkyellow",L[name])) 
	tt:AddLine (" ")
	
	line, column = tt:AddLine(L["Windowed / Fullscreen (press Alt)"])
	tt:SetLineScript(line, "OnMouseUp", function(self)
		if  not IsControlKeyDown()  and  IsAltKeyDown()  then  ToggleFullscreen()  end
	end )
	tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
	tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
	
	line, column = tt:AddLine(L["Reload UI (press Control)"])
	tt:SetLineScript(line, "OnMouseUp", function(self)
		if  IsControlKeyDown()  and  not IsAltKeyDown()  then  securecall("ReloadUI")  end
		if  not IsControlKeyDown()  and  not IsAltKeyDown()  then  StaticPopup_Show("CONFIRM")  end  -- Use StaticPopup to avoid taint.
	end )
	tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
	tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
	
	line, column = tt:AddLine(L["Logout (Control-RightClick)"])
	tt:SetLineScript(line, "OnMouseUp", function(self,button)
		if  button == "RightButton"  and  IsControlKeyDown()  and  not IsAltKeyDown()  then  securecall("Logout")  end
	end)			
	tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
	tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
	
	line, column = tt:AddLine(L["Quit Game (Control+Alt-RightClick)"])
	tt:SetLineScript(line, "OnMouseUp", function(self,button)
		if  button == "RightButton"  and  IsControlKeyDown()  and  IsAltKeyDown()  then  securecall("Quit")  end
	end)			
	tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
	tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
	
	if Broker_EverythingDB.showHints then
		tt:AddLine(" ")
		line, column = nil, nil
		tt:AddLine(
			C("copper",L["Shift+Alt-LeftClick"]).." || "..C("green",L["Toggle Window/Fullscreen mode"])
			.."|n"..
			C("copper",L["Shift+Ctrl-LeftClick"]).." || "..C("green",L["Reload UI"])
			.."|n"..
			C("copper",L["Shift+Control-RightClick"]).." || "..C("green",L["Logout"])
			.."|n"..
			C("copper",L["Shift+Control+Alt-RightClick"]).." || "..C("green",L["Quit game"])
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
	if  IsShiftKeyDown()  and  button == "LeftButton"  then
		if  not IsControlKeyDown()  and  IsAltKeyDown()  then  ToggleFullscreen()  end
		if  IsControlKeyDown()  and  not IsAltKeyDown()  then  securecall("ReloadUI")  end
	elseif  IsShiftKeyDown()  and  button == "RightButton"  then
		if  IsControlKeyDown()  and  not IsAltKeyDown()  then  securecall("Logout")  end
		if  IsControlKeyDown()  and  IsAltKeyDown()  then  securecall("Quit")  end
	end
end

--[[ ns.modules[name].ondblclick = function(self,button) end ]]

