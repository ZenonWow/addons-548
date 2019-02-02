
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Latency" -- L["Latency"]
local tt = nil
local GetNetStats = GetNetStats
local suffix = "ms"
local latency = { Home = 0, World = 0 }
-- http://wowpedia.org/Latency
-- the copy of a bluepost from Brianl are interesting.


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Addons\\"..addon.."\\media\\latency"}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show your current latency. Can be configured to show both Home and/or World latency."],
	events = {
		"PLAYER_ENTERING_WORLD"
	},
	updateinterval = 10,
	config_defaults = {
		showHome = true,
		showWorld = true
	},
	config_allowed = nil,
	config = {
		height = 52,
		elements = {
			{
				type = "check",
				name = "showHome",
				label = L["show home"],
				desc = L["Enable/Disable the display of the latency to the home realm"],
			},
			{
				type = "check",
				name = "showWorld",
				label = L["show world"],
				desc = L["Enable/Disable the display of the latency to the world realms"]
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

module.onevent = function(self,event,msg)
	module.onupdate(self)
end

module.onupdate = function(self)
	local _, _, lHome, lWorld = GetNetStats()
	local text = ""
	local dataobj = self.obj
	local suffix = C("suffix",suffix)

	latency.Home = lHome
	latency.World = lWorld
	
	 -- Colour the latencies
	for k, v in pairs(latency) do
		if v <= 250 then 
			latency[k] = C("green",v)
		elseif v > 250 and v <= 400 then
			latency[k] = C("dkyellow",v)
		elseif v > 400 then
			latency[k] = C("red",v)
		end		
	end

	local showHome, showWorld  = Broker_EverythingDB[name].showHome ~= false, Broker_EverythingDB[name].showWorld ~= false
	if (showWorld and not showHome) or not (showWorld and showHome) then
		text = string.format("%s%s", latency.World, suffix)
	elseif showHome and not showWorld then
		text = string.format("%s%s", latency.Home, suffix)
	elseif showHome and showWorld then
		text = string.format("%s%s%s %s%s%s", C("white","H:"), latency.Home, suffix, C("white","W:"), latency.World, suffix)
	end

	dataobj.text = text
end

module.ontooltip = function(tt)
	ns.tooltipScaling(tt)
	tt:AddLine(L[name])
	tt:AddLine(" ")
	tt:AddDoubleLine(C("white",L["Home"] .. " :"), latency.Home .. suffix)
	tt:AddDoubleLine(C("white",L["World"] .. " :"), latency.World .. suffix)

	if Broker_EverythingDB.showHints then
		tt:AddLine(" ")
		tt:AddLine(C("copper",L["Right-click"]).." || "..C("green",L["Suffix coloring on/off"]))
		tt:AddLine(C("copper",L["Alt+Right-click"]).." || "..C("green",L["Home latency on/off"]))
		tt:AddLine(C("copper",L["Ctrl+Right-click"]).." || "..C("green",L["World latency on/off"]))
	end
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------

module.onclick = function(self,button)
	if button == "RightButton" then
		if IsControlKeyDown() then
			if Broker_EverythingDB[name].showWorld ~= false then
				Broker_EverythingDB[name].showWorld = false
			else
				Broker_EverythingDB[name].showWorld = nil
			end
		elseif IsAltKeyDown() then
			if Broker_EverythingDB[name].showHome ~= false then
				Broker_EverythingDB[name].showHome = false
			else
				Broker_EverythingDB[name].showHome = nil
			end		
		else
			Broker_EverythingDB.suffixColour = not Broker_EverythingDB.suffixColour  or nil
		end
		module.onupdate(self)
	end
end


-- final module registration --
-------------------------------
ns.modules[name] = module

