
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Memory" -- L["Memory"]
local ldbName = name
local tt
local ttName = name.."TT"
local GetNumAddOns,GetAddOnMemoryUsage,GetAddOnInfo = GetNumAddOns,GetAddOnMemoryUsage,GetAddOnInfo
local ttColumns = 3


local addonpanels = {}
if ns.build>=60000000 then
	addonpanels["Blizzard's Addons Panel"] = function() end
end
addonpanels["ACP"] = function() ACP:ToggleUI() end
addonpanels["Ampere"] = function() InterfaceOptionsFrame_OpenToCategory("Ampere") InterfaceOptionsFrame_OpenToCategory("Ampere") end
addonpanels["OptionHouse"] = function() OptionHouse:Open(1) end
addonpanels["stAddonManager"] = function() stAddonManager:LoadWindow() end

local addonpanels_select = {none=L["None (disable right click)"]}
do
	local panelstates = {}
	local name, title, notes, enabled, loadable, reason, security, state
	for i=1, GetNumAddOns() do
		name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		panelstates[name] = nil -- nil = not present, false = present but not loaded yet, true = present and loaded
		if (addonpanels[name]) then
			if name == "Blizzard's Addons Panel" or reason==nil then
				reason = "enabled"
			end
			addonpanels_select[name] = name .. " (" .. L[reason:lower()] .. ")"
		end
	end
end


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Addons\\"..addon.."\\media\\memory"}


---------------------------------------
-- module variables for registration --
---------------------------------------
ns.modules[name] = {
	desc = L["Broker to show how much memory are consumed through your addons."],
	events = {
		"PLAYER_ENTERING_WORLD"
	},
	updateinterval = 10,
	config_defaults = {
		mem_max_addons = -1,
		addonpanel = "none"
	},
	config_allowed = {
	},
	config = {
		height = 68,
		elements = {
			{
				type = "slider",
				name = "mem_max_addons",
				label = "",
				desc = L["Select the maximum number of addons to display, otherwise drag to 'All'."],
				minText = L["All"],
				maxText = '100',
				minValue = -1,
				maxValue = 100,
				default = -1
			},
			{
				type = "dropdown",
				name = "addonpanel",
				label = L["Addon panel"],
				desc = L["Choose your addon panel that opens if you rightclick on memory broker or disable the right click option."],
				default = "none",
				values = addonpanels_select
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------
local function updateMemoryData(sumOnly)
	local total, all = 0, {}
	UpdateAddOnMemoryUsage()
	for i = 1, GetNumAddOns() do
		local u = GetAddOnMemoryUsage(i)
		total = total + u
		if not sumOnly then
			local n = select (1, GetAddOnInfo(i))
			all[i] = {name = n, mem = floor(u * 100) / 100}
		end
	end
	return total, all
end


------------------------------------
-- module (BE internal) functions --
------------------------------------
ns.modules[name].init = function(self)
	ldbName = (Broker_EverythingDB.usePrefix and "BE.." or "")..name
end

--[[ ns.modules[name].onevent = function(self,event,msg) end ]]

ns.modules[name].onupdate = function(self)
	local obj = self.obj or ns.LDB:GetDataObjectByName(ldbName)
	local total, all = updateMemoryData(true)

	local unit = "kb"
	if total > 1000 then
		total = total / 1000
		unit = "mb"
	end

	obj.text = string.format ("%.2f", total) .. C("suffix",unit)
end

--[[ ns.modules[name].optionspanel = function(panel) end ]]

--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

ns.modules[name].ontooltip = function(tt)
	if (not tt.key) or tt.key~=ttName then return end -- don't override other LibQTip tooltips...

	local unit
	local total, all = updateMemoryData(false)
	local cnt = tonumber(Broker_EverythingDB[name].mem_max_addons)

	tt:Clear()

	if cnt > 0 then
		tt:AddHeader(string.format("%s ( %s %d )", C("dkyellow",L[name]), "Top", Broker_EverythingDB[name].mem_max_addons))
	else
		tt:AddHeader(C("dkyellow",L[name]))
		cnt = 1000
	end

	table.sort(all, function (x, y) return x.mem > y.mem end)

	line, column = tt:AddLine()
	tt:SetCell(line,1,C("ltgreen",L["Addon"]),nil,nil,1)
	tt:SetCell(line,2,C("ltgreen",L["Memory Usage"]),nil,nil,2)
	tt:AddSeparator()
	for _, v in pairs (all) do
		if v.mem > 0 then
			unit = "kb"
			if v.mem > 1000 then
				v.mem = v.mem / 1000
				unit = "mb"
			end

			line, column = tt:AddLine()
			tt:SetCell(line,1,v.name,nil,nil,2)
			tt:SetCell(line,3,("%.2f %s"):format(v.mem,C("suffix",unit)),nil,nil,1)
			cnt = cnt - 1

			if cnt == 0 then
				break
			end
		end
	end
	tt:AddSeparator()

	unit = "kb"
	if total > 1000 then
		total = total / 1000
		unit = "mb"
	end
	unit = C("suffix",unit)

	line, column = tt:AddLine()
	tt:SetCell(line,1,L["Total Memory usage"]..":",nil,nil,2)
	tt:SetCell(line,3,("%.2f %s"):format(total, unit),nil,nil,1)

	if Broker_EverythingDB.showHints then
		tt:AddSeparator(2,0,0,0)

		line, column = tt:AddLine()
		tt:SetCell(line, 1, C("copper",L["Left-click"]).." || "..C("green",L["Open interface options"]),nil, nil, ttColumns)

		if IsAddOnLoaded("OptionHouse") then
			line, column = tt:AddLine()
			tt:SetCell(line, 1, C("copper",L["Right-click"]).." || "..C("green",L["Open OptionHouse"]), nil, nil, ttColumns)
		elseif IsAddOnLoaded("ACP") then
			line, column = tt:AddLine()
			tt:SetCell(line, 1, C("copper",L["Right-click"]).." || "..C("green",L["Open Addon Control Panel"]), nil, nil, ttColumns)
		elseif IsAddOnLoaded("stAddonManager") then
			line, column = tt:AddLine()
			tt:SetCell(line, 1, C("copper",L["Right-click"]).." || "..C("green",L["Open stAddonManager"]), nil, nil, ttColumns)
		end

		line, column = tt:AddLine()
		tt:SetCell(line, 1, C("copper",L["Shift+Right-click"]).." || "..C("green",L["Collect garbage"]), nil, nil, ttColumns)
	end	
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
ns.modules[name].onenter = function(self)
	if (ns.tooltipChkOnShowModifier(false)) then return; end

	tt = ns.LQT:Acquire(ttName, 3, "LEFT","RIGHT", "RIGHT")
	ns.modules[name].ontooltip(tt)
	ns.createTooltip(self,tt)
end

ns.modules[name].onleave = function(self)
	if (tt) then ns.hideTooltip(tt,ttName,false,true); end
end

ns.modules[name].onclick = function(self,button)
	local shift = IsShiftKeyDown()
	
	if button == "RightButton" and shift then
		print(L["Collecting Garbage..."])
		collectgarbage("collect")
	elseif button == "LeftButton" then
		InterfaceOptionsFrame_OpenToCategory(ns.OP.brokerPanel)
		if not shift then
			InterfaceOptionsFrame_OpenToCategory(ns.OP.configPanel)
		else
			InterfaceOptionsFrame_OpenToCategory(ns.OP.brokerPanel)
		end
	elseif button == "RightButton" and not shift then
		--[[
		if IsAddOnLoaded("OptionHouse") then
			OptionHouse:Open(1)
		elseif IsAddOnLoaded("ACP") then
			ACP:ToggleUI()
		elseif IsAddOnLoaded("Ampere") then
			InterfaceOptionsFrame_OpenToCategory("Ampere")
		elseif IsAddOnLoaded("stAddonManager") then
			stAddonManager:LoadWindow()
		else
			print(L["No addon manager found. Tried OptionHouse, ACP, stAddonManager and Ampere."])
		end
		]]
		if Broker_EverythingDB[name].addonpanel~="none" then
			local ap = Broker_EverythingDB[name].addonpanel
			if ap=="Blizzard's Addons Panel" then

			else
				if not IsAddOnLoaded(ap) then LoadAddOn(ap) end
				addonpanels[ap]();
			end
		end
	end
end

--[[ ns.modules[name].ondblclick = function(self,button) end ]]

