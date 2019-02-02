
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Stuff" -- L["Stuff"]


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Addons\\"..addon.."\\media\\stuff"}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to allow you to do...Stuff! Switch to windowed mode, reload ui, logout and quit."],
	events = {},
	updateinterval = nil, -- 10
	config_defaults = nil,
	config_allowed = nil,
	config = nil,
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

module.initbroker = function(dataobj)
	dataobj.type = 'launcher'  -- .label, tooltip and click only.  no .text, .value, .suffix
end

if  GetCVarBool == nil  then
	function GetCVarBool(cvar)  return GetCVar(cvar) == "1"  end
end

local isLogging = false
local function Log(...)
	if  isLogging  then  DEFAULT_CHAT_FRAME:AddMessage(...)  end
end

--[[
/run SetCVar("gxMaximize", 1); SetCVar("gxWindow", 1); RestartGx()
/dump GetCVar("gxMaximize") , GetCVar("gxWindow")
--]]
function ToggleFullscreen(goFullscreen, fullscreenIsExlusive) 
  local wasMaximized= GetCVarBool("gxMaximize")
  local wasWindowed= GetCVarBool("gxWindow")
  local wasFullscreen= wasMaximized or not wasWindowed
	if  nil == goFullscreen  then  goFullscreen = not wasFullscreen  end
	--if  nil == fullscreenIsExlusive  then  fullscreenIsExlusive = not Broker_EverythingDB.Stuff.fullscreenWasWindowed  end
  Broker_EverythingDB.Stuff= Broker_EverythingDB.Stuff or {}
	
  if  not goFullscreen  then
    -- save windowed state of fullscreen before switching
    if  wasFullscreen  then  Broker_EverythingDB.Stuff.fullscreenWasWindowed= wasWindowed  end
		-- return if nothing changes
		if  not wasMaximized  and  wasWindowed  then  return  end
    
		--Log('ToggleFullscreen(' .. tostring(goFullscreen) ..', '.. tostring(fullscreenIsExlusive)  ..'): gxMaximize = 0 ; gxWindow = 1')
		-- go windowed and not maximized
    ns.SetCVar("gxMaximize", 0)
    ns.SetCVar("gxWindow", 1)
  else
		local fullscreenIsWindowed = not fullscreenIsExlusive
		local varValue= fullscreenIsWindowed  and  1  or  0
		-- return if nothing changes
		if  wasMaximized == fullscreenIsWindowed  and  wasWindowed == fullscreenIsWindowed  then  return  end
		
		--Log('ToggleFullscreen('.. tostring(goFullscreen) ..', '.. tostring(fullscreenIsExlusive) ..'): gxMaximize = gxWindow = '.. varValue)
		-- awkward logic: non-windowed (exclusive) fullscreen is not maximized
    ns.SetCVar("gxMaximize", varValue)
    --if  not fullscreenIsExlusive  then  ns.SetCVar("gxMaximize", 1)  end
    ns.SetCVar("gxWindow", varValue)
  end
  
	Log('ToggleFullscreen('.. tostring(goFullscreen) ..', '.. tostring(fullscreenIsExlusive) ..'): gxMaximize = '.. GetCVar("gxMaximize") ..' gxWindow = '.. GetCVar("gxWindow"))
	--ns.SetCVar("gxWindow", 1 - tonumber(GetCVar("gxWindow")))
  RestartGx()
	
end


module.onqtip = function(tt)
	tt:Clear()
	tt:SetColumnLayout(1, "LEFT")
	tt:AddHeader(C("dkyellow",L[name])) 
	tt:AddLine (" ")
	
	local line, column

  local wasMaximized= GetCVarBool("gxMaximize")
  local wasWindowed= GetCVarBool("gxWindow")
  local wasFullscreen= wasMaximized or not wasWindowed
	
	line, column = tt:AddLine(C("green",L["Windowed / Fullscreen"]) .."  ||  ".. C("copper",L["Alt-LeftClick"]))
	ns.highlightOnMouseover(tt, line)
	tt:SetLineScript(line, "OnMouseUp", function(self)
		if  not IsControlKeyDown()  and  IsAltKeyDown()  and  not IsShiftKeyDown()  then  ToggleFullscreen(nil, IsShiftKeyDown())  end
	end )
	
	line, column = tt:AddLine(C("green","    ".. L["Exlusive fullscreen"]) .."  ||  ".. C("copper",L["Shift+Alt-LeftClick"]))
	ns.highlightOnMouseover(tt, line)
	tt:SetLineScript(line, "OnMouseUp", function(self)
		if  not IsControlKeyDown()  and  IsAltKeyDown()  and  IsShiftKeyDown()  then  ToggleFullscreen(true, IsShiftKeyDown())  end
	end )
	
	line, column = tt:AddLine(C("green",L["Reload UI"]) .."  ||  ".. C("copper",L["Ctrl-LeftClick"]))
	ns.highlightOnMouseover(tt, line)
	tt:SetLineScript(line, "OnMouseUp", function(self)
		if  IsControlKeyDown()  and  not IsAltKeyDown()  then  ReloadUI()  end
		if  not IsControlKeyDown()  and  not IsAltKeyDown()  then  StaticPopup_Show("CONFIRM")  end  -- Use StaticPopup to avoid taint.
	end )
	
	line, column = tt:AddLine(C("green",L["Logout"]) .."  ||  ".. C("copper",L["Control-RightClick"]))
	ns.highlightOnMouseover(tt, line)
	tt:SetLineScript(line, "OnMouseUp", function(self,button)
		if  button == "RightButton"  and  IsControlKeyDown()  and  not IsAltKeyDown()  then  Logout()  end
	end)			
	
	line, column = tt:AddLine(C("green",L["Quit Game"]) .."  ||  ".. C("copper",L["Control+Alt-RightClick"]))
	ns.highlightOnMouseover(tt, line)
	tt:SetLineScript(line, "OnMouseUp", function(self,button)
		if  button == "RightButton"  and  IsControlKeyDown()  and  IsAltKeyDown()  then  Quit()  end
	end)			
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------

module.mouseOverTooltip = true

module.onclick = function(self,button)
	if  button == "LeftButton"  then
		if  not IsControlKeyDown()  and  IsAltKeyDown()  then  ToggleFullscreen(nil, IsShiftKeyDown())
		elseif  IsControlKeyDown()  and  not IsAltKeyDown()  then  ReloadUI()
		end
	elseif  button == "RightButton"  then
		if  IsControlKeyDown()  and  not IsAltKeyDown()  then  Logout()
		elseif  IsControlKeyDown()  and  IsAltKeyDown()  then  Quit()
		elseif  not IsModifierKeyDown()  then
			ns.commands.options.func()
		end
	end
end


-- final module registration --
-------------------------------
ns.modules[name] = module

