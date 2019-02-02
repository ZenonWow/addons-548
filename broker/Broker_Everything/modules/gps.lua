
--[[
	Little description to this 3 in 1 module.
	it register 4 modules. the first (name0) is only for configuration.
	all config variables in name0 are used in the other modules.
]]


----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I
local _

-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name0 = "Location/Coordinates" -- L["Location/Coordinates"]
local name1 = "Location-Zone"        -- L["Location-Zone"]
local name2 = "Location-Coordinates" -- L["Location-Coordinates"]
local locationTTkey = "Location"
local teleportTTkey = "Teleport"
--[[
local tt5positions = {
	["LEFT"]   = {edgeSelf = "RIGHT",  edgeParent = "LEFT",   x = -2, y =  0},
	["RIGHT"]  = {edgeSelf = "LEFT",   edgeParent = "RIGHT",  x =  2, y =  0},
}--]]

local iStr16 = "|T%s:16:16:0:0|t"
local iStr32 = "|T%s:32:32:0:0|t"
local gpsLoc = {
	zone = " ",
	pvp = "Contested",
	color = "white",
	posColor = "white",
	pos = "",
}
local zoneDisplayValues = {
	["0"] = L["Don't display"],
	["1"] = L["Zone"],
	["2"] = L["Subzone"],
	["3"] = L["Zone"]..": "..L["Subzone"],
	["4"] = ("%s (%s)"):format(L["Zone"],L["Subzone"]),
	["5"] = ("%s (%s)"):format(L["Subzone"],L["Zone"]),
}
local teleports, portals, spells, items_for_menu,item_replacements = {},{},{},{},{}
for _,v in ipairs({18984,18986,21711,30542,30544,32757,35230,37863,40585,40586,43824,44934,44935,45688,45689,45690,45691,46874,48933,48954,48955,48956,48957,50287,51557,51558,51559,51560,52251,58487,63206,63207,63352,63353,63378,63379,64457,65274,65360,87215,95050,95051,95567,95568,110560}) do items_for_menu[v] = true end
for _,v in ipairs({64488,28585,6948,44315,44314,37118}) do item_replacements[v] = true end


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name1] = {iconfile="Interface\\Addons\\"..addon.."\\media\\gps"}
I[name2] = {iconfile="Interface\\Addons\\"..addon.."\\media\\gps"}
-- I[name3] = {iconfile=GetItemIcon(11105),coords={0.05,0.95,0.05,0.95}}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module0 = {
	noBroker = true,
	desc = "",
	--[[
	config_defaults = {
		precision = 0,
		coordsFormat = "%s, %s",
		shortMenu = false
	},
	config_allowed = {
		coordsFormat = {
			["%s, %s"] = true,
			["%s / %s"] = true,
			["%s/%s"] = true,
			["%s | %s"] = true,
			["%s||%s"] = true
		}
	},
	config = {
		height = 62,
		elements = {
			{
				type	= "check",
				name	= "shortMenu",
				label	= L["Iconify transport menu"],
				desc	= L["Display the transport menu with icons only, without spell names."],
			},
			{
				type	= "dropdown",
				name	= "coordsFormat",
				label	= L["Co-ordination format"],
				desc	= L["How would you like to view co-ordinations."],
				values	= {
					["%s, %s"]     = "10.3, 25.4",
					["%s / %s"]    = "10.3 / 25.4",
					["%s/%s"]      = "10.3/25.4",
					["%s | %s"]    = "10.3 | 25.4",
					["%s||%s"]     = "10.3||25.4"
				},
				default = "%s, %s",
			},
			{
				type		= "slider",
				name		= "precision",
				label		= L["Precision"],
				desc		= L["Change how much digits display after the dot."],
				minText		= "0",
				maxText		= "3",
				minValue	= 0,
				maxValue	= 3,
				default		= 0
			}
		}
	}
	--]]
}

local module1 = {
	desc = L["Broker to show the name of the current zone."],
	config_defaults = {
		bothZones = "1",    -- Zone
		shortMenu = false,
	},
	-- config_prepend = name0,
	config = {
		height = 68,
		elements = {
			{
				type = "dropdown",
				name = "bothZones",
				label = L["Display zone names"],
				desc = L["Display in broker zone and subzone if exists or one of it."],
				default = "1",    -- Zone
				values = zoneDisplayValues
			},
			{
				type	= "check",
				name	= "shortMenu",
				label	= L["Iconify transport menu"],
				desc	= L["Display the transport menu with icons only, without spell names."],
			},
		}
	}
}

local module2 = {
	desc = L["Broker to show the name of the current Zone and the co-ordinates."],
	updateinterval = 0.2,
	config_defaults = {
		bothZones = "0",
		precision = 0,
		coordsFormat = "%s, %s",
	},
	config_allowed = {
		coordsFormat = {
			["%s, %s"] = true,
			["%s / %s"] = true,
			["%s/%s"] = true,
			["%s | %s"] = true,
			["%s||%s"] = true,
		}
	},
	-- config_prepend = name0,
	config = {
		height = 68,
		elements = {
			{
				type = "dropdown",
				name = "bothZones",
				label = L["Display zone names"],
				desc = L["Display in broker zone and subzone if exists or one of it."],
				default = "0",
				values = zoneDisplayValues
			},
			{
				type	= "dropdown",
				name	= "coordsFormat",
				label	= L["Co-ordination format"],
				desc	= L["How would you like to view co-ordinations."],
				values	= {
					["%s, %s"]     = "10.3, 25.4",
					["%s / %s"]    = "10.3 / 25.4",
					["%s/%s"]      = "10.3/25.4",
					["%s | %s"]    = "10.3 | 25.4",
					["%s||%s"]     = "10.3||25.4"
				},
				default = "%s, %s",
			},
			{
				type		= "slider",
				name		= "precision",
				label		= L["Precision"],
				desc		= L["Change how much digits display after the dot."],
				minText		= "0",
				maxText		= "3",
				minValue	= 0,
				maxValue	= 3,
				default		= 0
			},
		}
	}
}


--[[
ns.modules[name3] = {
	desc = L["Broker to show your current co-ordinates within the zone."],
	enabled = false,
	events = {},
	updateinterval = nil,
	config_defaults = nil,
	config_prepend = name0,
	config = nil
}
--]]


--------------------------
-- some local functions --
--------------------------
local function setSpell(tb,id)
	if IsSpellKnown(id) then
		local sName, _, icon, _, _, _, _, _, _ = GetSpellInfo(id)
		table.insert(tb,{id=id,icon32=iStr32:format(icon),icon16=iStr16:format(icon),name=sName,name2=sName})
	end
end
local function setItem(tb,id,nameReplacement)
	local itemName, _, _, _, _, _, _, _, _, icon, _ = GetItemInfo(id)
	table.insert(tb,{id=id,icon32=iStr32:format(icon),icon16=iStr16:format(icon),name=itemName,name2=(nameReplacement or itemName)})
end

local function chkInventory(ifExists)
	local found, count = {},0
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			local item_id = GetContainerItemID(bag,slot)
			if item_id then
				local itemName, _, _, _, _, _, _, _, _, icon, _ = GetItemInfo(item_id)
				if type(ifExists)=="table" and ifExists[item_id] then
					return itemName
				elseif type(ifExists)=="number" and ifExists == item_id then
					return itemName
				elseif items_for_menu[item_id]==true then
					setItem(found,item_id)
					count = count + 1
				elseif item_replacements[item_id]==true then
					setItem(found,item_id,GetBindLocation())
					count = count + 1
				end
			end
		end
	end
	return found, count
end

local function position()
	local p,f = Broker_EverythingDB[name2].precision, Broker_EverythingDB[name2].coordsFormat
	if not p then p = 0 end
	local precision_format = "%."..p.."f"
	if not f then f = "%s, %s" end

	local x, y = GetPlayerMapPosition("player")

	if x ~= 0 and y ~= 0 then
		return string.format(
			f,
			string.format(precision_format, (x * 100)),
			string.format(precision_format, (y * 100))
		)
	else
		local pX = strrep("?",p)
		return string.format(f, (pX~="" and "?."..pX or "?"), (pX~="" and "?."..pX or "?") )
	end
end

local function zone(byName)
	local subZone = GetSubZoneText() or ""
	local zone = GetRealZoneText() or ""
	local types = {"%s: %s","%s (%s)"}
	local bothZones = Broker_EverythingDB[byName].bothZones

	if bothZones == "0" then
		return nil
	elseif bothZones == "2" and subZone ~= "" then
		return subZone
	elseif bothZones == "3" and subZone ~= "" then
		return subZone and types[1]:format(zone,subZone or "")
	elseif bothZones == "4" and subZone ~= "" then
		return subZone and types[2]:format(zone,subZone)
	elseif bothZones == "5" and subZone ~= "" then
		return subZone and types[2]:format(subZone,zone)
	end

	return zone
end

local pvpColor = {
	combat    = "red",
	arena     = "red",
	hostile   = "red",
	contested = "dkyellow",
	friendly  = "ltgreen",
	sanctuary = "ltblue",
}

local function zoneColor()
	local p, _, f = GetZonePVPInfo()
	p = p or "contested"
	local color = pvpColor[p]  or  "white"
	local pvp = gsub(p,"^%l", string.upper)
	--[[
		L["Contested"]
		L["Sanctuary"]
		L["Friendly"]
		L["Combat"]
		L["Arena"]
		L["Hostile"]
	]]
	return pvp, color
end




--------------------------------
-- tooltip content generators --
--------------------------------

-- shared tooltip for modules Location, GPS and ZoneText
function locationTooltip(tt, module)
	tt:Clear()
	tt:SetColumnLayout(3, "LEFT", "RIGHT", "RIGHT")
	tt:AddHeader( C("dkyellow", module.label) )
	tt:AddSeparator()

	if buttonFrame then buttonFrame:ClearAllPoints() buttonFrame:Hide() end
	-- gpsLoc:refresh()

	local lst = {
		{C("ltyellow",L["Zone"] .. ":"),GetRealZoneText()},
		{C("ltyellow",L["Subzone"] .. ":"),GetSubZoneText()},
		{C("ltyellow",L["Zone status"] .. ":"),C(gpsLoc.color,L[gpsLoc.pvp])},
		{C("ltyellow",L["Co-ordinates"] .. ":"),position() or C(gpsLoc.posColor,gpsLoc.pos)}
	}

	local line, column
	for _, d in pairs(lst) do
		line, column = tt:AddLine()
		tt:SetCell(line,1,d[1],nil,nil,2)
		tt:SetCell(line,3,d[2],nil,nil,1)
	end

	if gpsLoc.posColor then
		line,column = tt:AddLine()
		tt:SetCell(line,1,C(gpsLoc.posColor,gpsLoc.posInfo),nil,"CENTER",3)
	end

	tt:AddSeparator()

	line, column = tt:AddLine()
	tt:SetCell(line,1,C("ltyellow",L["Inn"]..":"),nil,nil,1)
	tt:SetCell(line,2,GetBindLocation(),nil,nil,2)

	--[=[
	local item = chkInventory(item_replacements)
	if type(item)=="string" then
		tt:SetLineScript(line,"OnEnter",function(self)
			--buttonHandler(self,"item",item)
			ns.secureButton(self,{ {typeName="type", typeValue="item", attrName="item", attrValue=item} }, name.."_Inn")
			tinsert(tt.secureButtons, name.."_Inn")
		end)
	end
	--]=]

	if Broker_EverythingDB.showHints then
		tt:AddSeparator(3,0,0,0,0)
		line, column = tt:AddLine()
		tt:SetCell(line, 1, C("copper",L["Left-click"]).." || "..C("green",L["Open transport menu"]), nil, nil, 3)
		line, column = tt:AddLine()
		tt:SetCell(line, 1, C("copper",L["Right-click"]).." || "..C("green",L["Open World map"]), nil, nil, 3)
	end
end


local function teleportTooltip(teleTT)
	local shortMenu = Broker_EverythingDB[name1].shortMenu
	local ttColumns = shortMenu  and 4  or 1
	teleTT:Clear()
	teleTT:SetColumnLayout(ttColumns, "LEFT","LEFT","LEFT","LEFT")

	-- title
	if not shortMenu then
		teleTT:AddHeader(C("dkyellow","Choose your transport"))
	end

	local pts,ipts,tls,itls = {},{},{},{}
	local line, column,cellcount = nil,nil,5
	local inv, inv_c = chkInventory()
	teleTT.secureButtons = {}

	local function add_title(title)
		teleTT:AddSeparator(4,0,0,0,0)
		teleTT:AddLine(C("ltyellow",title))
		teleTT:AddSeparator()
	end

	local function add_cell(v,t)
		teleTT:SetCell(line, cellcount, v.icon32, nil, nil, 1)
		teleTT:SetCellScript(line,cellcount,"OnEnter",function(self) ns.secureButton(self,{ {typeName="type", typeValue=t, attrName=t, attrValue=v.name} }) end)
	end

	local function add_line(v,t)
		line, column = teleTT:AddLine(v.icon16..(v.name2 or v.name))
		teleTT:SetLineScript(line,"OnEnter",function(self) ns.secureButton(self,{ {typeName="type", typeValue=t, attrName=t, attrValue=v.name} }) end)
	end

	local function add_obj(v,t)
		if shortMenu then
			if cellcount<4 then
				cellcount = cellcount + 1
			else
				cellcount = 1
				line, column = teleTT:AddLine()
			end
			add_cell(v,t)
		else
			add_line(v,t)
		end
	end

	local counter = 0

	if #teleports>0 or #portals>0 or #spells>0 then
		-- class title
		if not shortMenu then
			add_title(ns.player.classLocale)
		end
		-- class spells
		if ns.player.class=="MAGE" then
			for i,v in ns.pairsByKeys(teleports) do
				add_obj(v,"spell")
			end
			if not shortMenu then
				teleTT:AddSeparator()
			end
			for i,v in ns.pairsByKeys(portals) do
				add_obj(v,"spell")
			end
		else
			for i,v in ns.pairsByKeys(spells) do
				add_obj(v,"spell")
			end
		end
	end

	if inv_c>0 then
		-- item title
		if not shortMenu then
			add_title(L["Items"])
		end
		-- items
		for i,v in ns.pairsByKeys(inv) do
			add_obj(v,"item")
			counter = counter + 1
		end
	end
	
	if counter==0 then
		teleTT:AddSeparator(4,0,0,0,0)
		teleTT:AddHeader(C("ltred",L["Sorry"].."!"))
		teleTT:AddSeparator(1,1,.4,.4,1)
		teleTT:AddLine(C("ltred",L["No spells or items found"].."."))
	end
end



-----------------------
-- tooltip show/hide --
-----------------------

local locationTT
local teleportTT

-- module1.mouseOverTooltip = nil
-- module2.mouseOverTooltip = nil

local function locationShow(module, display)
	module:refresh()
	if  module.tooltip == teleportTT  then  return  end
	-- ns.defaultOnEnter(module, display)
	if  ns.tooltipChkOnShowModifier()  then  return  end
	local tooltip, reused = ns.LQT:Acquire(locationTTkey)
	ns.attachTooltip(module, tooltip)
	locationTooltip(tooltip, module)
	ns.createTooltip(display, tooltip, module.mouseOverTooltip)
	locationTT = tooltip
end
local function locationHide(module)
	if  module.tooltip ~= locationTT  then  return  end

	locationTT = nil
	return ns.hideTooltip(module.tooltip, locationTTkey, true)
end
--[[
local function locationShow(module, display)
	if (ns.tooltipChkOnShowModifier()) then return; end
	locationTT = ns.LQT:Acquire(locationTTkey, 3, "LEFT", "RIGHT", "RIGHT")
	locationTooltip(locationTT, module)
	ns.createTooltip(display, locationTT, true)
end
local function locationHide()
	if  ns.hideTooltip(teleportTTns.LQT.activeTooltips[locationTTkey],nil,true)  then
		locationTT = nil
		return true
	end
end
--]]


local function teleportShow(module, display)
	-- if InCombatLockdown() then  return  end
	local tooltip, reused = ns.LQT:Acquire(teleportTTkey)
	ns.attachTooltip(module, tooltip)
	teleportTooltip(tooltip)
	ns.createTooltip(display, tooltip, true)
	ns.setStayOpen(tooltip, true, 3)
	teleportTT = tooltip
end

--[[
local function teleportHide(module)
	if  module.tooltip ~= teleportTT  then  return  end
	teleportTT = nil
	return ns.hideTooltip(module.tooltip, teleportTTkey, true)
end
--]]

local function brokerOnClick(display, button, module)
	module:refresh()
	if button == "LeftButton" then
		local ttKey = module.tooltip  and  module.tooltip.key
		-- ns.attachTooltip() now hides the previous tooltip.
		-- ns.hideTooltip(module.tooltip, nil, true)
		if  ttKey ~= teleportTTkey  then
			teleportShow(module, display)
		else
			locationShow(module, display)
		end

	elseif button == "RightButton" then
		-- ToggleFrame(WorldMapFrame)
		-- Open settings.
		ns.commands.options.func()
	end
end

--[[
local function brokerOnClick(display, button, module)
	module:refresh()
	if button == "LeftButton" then
		if  teleportHide(module)  then
			-- Click 2 -> locationShow 
			locationShow(module, display)
		else
			-- Enter -> locationShow
			locationHide(module)
			-- Click 1 -> teleportShow
			teleportShow(module, display)
		end

	elseif button == "RightButton" then
		-- ToggleFrame(WorldMapFrame)
		-- Open settings.
		ns.commands.options.func()
	end
end

local function brokerOnClick(display, button, module)
	module:refresh()
	if button == "LeftButton" then
		-- Enter -> locationShow
		if  locationHide(module)  then
			-- Click 1 -> teleportShow
			teleportShow(module, display)
		elseif  teleportHide(module)  then
			-- Click 2 -> locationShow 
			locationShow(module, display)
		end

	elseif button == "RightButton" then
		-- ToggleFrame(WorldMapFrame)
		-- Open settings.
		ns.commands.options.func()
	end
end
--]]

-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------

module1.onenter = function(display)  gpsLoc:refresh() ; return locationShow(module1, display)  end  
module2.onenter = function(display)  return locationShow(module2, display)  end

module1.onleave = function(display)  locationHide(module1)  end
module2.onleave = function(display)  locationHide(module2)  end

module1.onclick = function(display, button)  gpsLoc:refresh() ; brokerOnClick(display, button, module1)  end
module2.onclick = function(display, button)  brokerOnClick(display, button, module2)  end



------------------------------------
-- module (BE internal) functions --
------------------------------------

module0.events = {
	--"PLAYER_LOGIN",
	--"PLAYER_ENTERING_WORLD",
	"ADDON_LOADED",
	--"ZONE_CHANGED",
	--"ZONE_CHANGED_INDOORS",
	--"ZONE_CHANGED_NEW_AREA",
	"LEARNED_SPELL_IN_TAB"
}

module0.onevent = function(module,event,msg)
	teleports, portals, spells = {},{},{}
	if ns.player.class=="MAGE" then
		for _,v in ipairs({3561,3562,3563,3565,3566,3567,32271,32272,33690,35715,49358,49359,53140,88342,88344,120145,132621,132627,176248}) do setSpell(teleports,v) end
		for _,v in ipairs({10059,11416,11417,11418,11419,11420,32266,32267,33691,35717,49360,49361,53142,88345,88346,120146,132620,132626,176246}) do setSpell(portals,v) end
	end
	for _,v in ipairs({50977,18960,556,126892}) do setSpell(spells,v) end
end


module1.events = {
	--"PLAYER_LOGIN",
	--"PLAYER_ENTERING_WORLD",
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
}

module1.refresh = function()
	gpsLoc.pvp, gpsLoc.color = zoneColor()
	-- Location: Zone
	local zoneText = zone(name1)
	module1.obj.text = zoneText and C(gpsLoc.color, zoneText)
end

module1.onevent = module1.refresh
module1.initbroker = module1.refresh


function gpsLoc:refresh()
	gpsLoc.pvp, gpsLoc.color = zoneColor()
	local pos = position()
	if pos then
		gpsLoc.pos = pos
		gpsLoc.posColor = gpsLoc.color
		gpsLoc.posInfo = nil
	else
		if gpsLoc.posLast==nil then
			gpsLoc.posLast=time()
		elseif time()-gpsLoc.posLast>5 then
			gpsLoc.posColor = "orange"
			gpsLoc.posInfo = L["Co-ordinates indeterminable"]
		end
	end
	gpsLoc.posText = C(gpsLoc.posColor, gpsLoc.pos)
end


module2.refresh = function()
	gpsLoc:refresh()
	local zoneText = zone(name2)
	if  zoneText  then
		-- Location: Zone (Coordinates)
		module2.obj.text = C(gpsLoc.color, zoneText.." ("..gpsLoc.posText..")")
	else
		-- Location: Coordinates
		module2.obj.text = gpsLoc.posText
	end
end

module2.events = module1.events    -- Taken from module1 intentionally.
module2.onevent = module2.refresh
module2.onupdate = module2.refresh
module2.initbroker = module2.refresh


-- final module registration --
-------------------------------
ns.modules[name0] = module0
ns.modules[name1] = module1
ns.modules[name2] = module2

