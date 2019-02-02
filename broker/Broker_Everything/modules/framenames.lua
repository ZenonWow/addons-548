
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Framenames" -- L["Framenames"]
local string = string


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Addons\\"..addon.."\\media\\equip"}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show names of frames under the mouse."],
	enabled = false,
	events = {},
	updateinterval = 0.05,
	config_defaults = nil,
	config_allowed = nil,
	config = nil
}


--------------------------
-- some local functions --
--------------------------
local lastFrame

function module.onqtip(tt)
	if not tt then  return  end

	tt:Clear()
	tt:SetColumnLayout(2, "LEFT", "RIGHT")

	local frame = lastFrame
	if frame:IsForbidden() or ( frame:IsProtected() and InCombatLockdown() ) then
		tt:AddLine(L["Name"], (frame:IsForbidden() and "[Forbidden Frame]") or (frame:IsProtected() and "[Protected Frame]") or "[Unknown]")
	else
		tt:AddHeader(frame:GetName() or "<anonym>")
		tt:AddSeparator()
		local tmp
		for i,v in pairs(frame) do
			if i~=0 and ( type(v)=="string" or type(v)=="number" ) then
				if strlen(v)>26 then v = strsub(v,0,23).."..." end
				tt:AddLine(i, v);
			end
		end
		tmp = frame:GetParent()
		tt:AddLine("GetParent", (tmp~=nil and tmp:GetName()) or "nil <anonym?>")
	end
end

local lastUnit = nil
local function UnitInfoTooltip(tt)
	local tmp
	local guid = UnitGUID("mouseover")
	local name = UnitName("mouseover")
	if lastUnit==name then return end

	tt:Clear()

	tt:AddLine("UnitName",name)
	tt:AddLine("UnitGUID",guid or "Unknown")

	if lastUnit~=guid then
		lastUnit = name
	end
end


------------------------------------
-- module (BE internal) functions --
------------------------------------

module.initbroker = function(dataobj)
	dataobj.text = L[name]
end

module.onupdate = function(self)
	if  IsShiftKeyDown()  then  return  end
	
	local f = GetMouseFocus()
	if  lastFrame == f  then  return  end
	lastFrame = f
	
	local dataobj = self.obj
	if  not f  then
		dataobj.text = L["No GetMouseFocus()"]
	else
		local frameName
		frameName = (f:IsForbidden() and "[Forbidden Frame]") or (f:IsProtected() and InCombatLockdown() and "[Protected Frame]") or f:GetName()
		if frameName == nil and type(f.key)=="string" then -- LibQTip tooltips returns nil on GetName but f.key contains the current name
			frameName = "LibQTip('"..f.key.."')"
		end
		dataobj.text = frameName  or  tostring(f)
	end

	module.onqtip(module.tooltip)

	--[[
	if ( f ) and  IsControlKeyDown() and IsAltKeyDown() then
		if tt==nil then
			tt = ns.LQT:Acquire(ttName, 2, "LEFT", "RIGHT")
		elseif tt.key~=ttName then
			return;
		end

		if UnitName("mouseover") then
			UnitInfoTooltip(tt)
		else
			FrameInfoTooltip(tt,GetMouseFocus())
		end

		local s = UIParent:GetEffectiveScale()
		local x,y = GetCursorPosition()
		local w,h = tt:GetWidth()/s, tt:GetHeight()/s
		tt:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",(x/s)+12,(y/s)-h)
		tt:SetClampedToScreen(true)

		if not tt:IsShown() then tt:Show() end
	elseif tt~=nil and tt.key==ttName then
		tt:ClearAllPoints()
		tt:Hide()
		lastFrame = nil
		lastUnit = nil
	end
	]]
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------

module.ontooltip = function(tt)  tt:Hide()  end
module.onenter = function(display) end -- prevent displaying tooltip
module.onleave = function(display) end -- prevent hiding tooltip

module.onclick = function(display, button)
	if  module.tooltip  then
		ns.defaultOnLeave(module, display)
	else
		ns.defaultOnEnter(module, display)
		ns.setStayOpen(module.tooltip, true, nil)
	end
end

module.mouseOverTooltip = nil


-- final module registration --
-------------------------------
ns.modules[name] = module

