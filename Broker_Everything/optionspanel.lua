
local addon, ns = ...
local C, L = ns.LC.color, ns.L

ns.OP = CreateFrame("frame") -- OP / optionspanel

local function setPoints(element, sibling, points, fir)
	local parent = sibling.elem
	if not points then
		if fir==sibling.dot then
			if element.type=="dropdown" or element.type=="slider" or element.type=="editbox" then
				points = {edgeSelf="TOPLEFT", edgeSibling="TOPLEFT", x=0, y=-14}
			else
				points = {edgeSelf="TOPLEFT", edgeSibling="TOPLEFT", x=0, y=0}
			end
		else
			points = {edgeSelf="TOPLEFT", edgeSibling="TOPLEFT", x=200, y=0}
		end
	end
	if points.sibling then
		if points.sibling=="dot" then
			parent = sibling.dot
		else
			parent = points.sibling
		end
	end
	element:SetPoint(points.edgeSelf,parent or sibling.elem,points.edgeSibling,points.x,points.y)
end

local function getIconSets()
	local t = {NONE=L["None"]}
	local l = ns.LSM:List((addon.."_Iconsets"):lower())
	if type(l)=="table" then
		for i,v in pairs(l) do
			t[v] = v
		end
	end
	return t
end


-- ----------------------------------------------------- --
-- Option panel 1 - brokerPanel - enable/disable modules --
-- ----------------------------------------------------- --

ns.OP.createBrokerPanel = function(panel)
	local controls = {}	

	local function makeToggle(varname, name, desc)
		return panel:MakeToggle(
			"name", name, 
			"description", desc, 
			"default", Broker_EverythingDB[varname].enabled,
			"getFunc", function() return Broker_EverythingDB[varname].enabled end, 
			"setFunc", function(value)
				Broker_EverythingDB[varname].enabled = value
				if value==true and ns.LDB:GetDataObjectByName(varname)==nil then
					ns.moduleInit(varname)
					if ns.modules[varname].onevent then ns.modules[varname].onevent({},"ADDON_LOADED") end
				end
			end
		)
	end

	panel.title, panel.subText = panel:MakeTitleTextAndSubText(
		"Broker_Everything - Broker", L["Select the listed broker to enable/disable. You must Reload UI for any changes to apply."])

	local mods2Locale = {}
	for k, v in pairs(ns.modules) do mods2Locale[L[k]] = k end

	-- for k, v in ns.pairsByKeys(ns.modules) do
	for K, V in ns.pairsByKeys(mods2Locale) do
		local k, v = V, ns.modules[V]
		if not v.noBroker then
			panel[k] = makeToggle(k, L[k], {L[k],ns.modules[k].desc})
			table.insert(controls, panel[k])
		end
	end

	panel.reload = panel:MakeButton(
		'name', L["Reload UI"],
		'description', L["Reloads the UI. You must do this to apply any changes in module activation."],
		'func', function() ReloadUI() end
	)

	panel.selectnone = panel:MakeButton(
		'name', L["Select none"],
		'description', L["Remove all selections from modules"],
		'func', function()
			for i,v in pairs(ns.modules) do
				Broker_EverythingDB[i].enabled = false
			end
			InterfaceOptionsFrame_OpenToCategory(ns.OP.brokerPanel);
		end
	)

	panel.selectall = panel:MakeButton(
		'name', L["Select all"],
		'description', L["Select all modules"],
		'func', function()
			for i,v in pairs(ns.modules) do
				Broker_EverythingDB[i].enabled = true
			end
			InterfaceOptionsFrame_OpenToCategory(ns.OP.brokerPanel);
		end
	)

	local c,fromTop,pos,last = 1,-10,{0,200,400},0
	
	for i, frame in ipairs(controls) do
		frame:SetPoint("TOPLEFT",panel.subText,"BOTTOMLEFT",pos[c],fromTop)
		c, last = c+1, fromTop
		if c==4 then c, fromTop = 1, fromTop - 25 end
	end

	last = last - 40
	panel.reload:SetPoint(    "TOPLEFT",panel.subText,"BOTTOMLEFT",0,last)
	panel.selectall:SetPoint( "TOPLEFT",panel.subText,"BOTTOMLEFT",200,last)
	panel.selectnone:SetPoint("TOPLEFT",panel.subText,"BOTTOMLEFT",400,last)

end


-- ----------------------------------------------------- --
-- Option panel 2 - general settings and module settings --
-- ----------------------------------------------------- --

ns.OP.createConfigPanel = function(panel)
	local controls = {}	
	local backdrop = { edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, tileSize = 0, edgeSize = 16, insets = { left = 0, right = 0, top = 0, bottom = 0 } };

    local function makeCheck(name, desc, module, option)
        return panel:MakeToggle(
            "name", name, 
            "description", desc,
            "default", false, 
            "getFunc", function() 
				if module == "nil" or module == nil then
					return Broker_EverythingDB[option]
				else
					return Broker_EverythingDB[module][option]
				end
			end, 
            "setFunc", function(value)
				if module == "nil" or module == nil then
					Broker_EverythingDB[option] = value
				else
					Broker_EverythingDB[module][option] = value
				end
			end
        )
    end

	local function getTitle(text, tType)
		local title
		if tType == "group" then
			title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalMed3")
		else
			title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		end
		title:SetText(text)
		title:SetJustifyH("LEFT")
		title:SetJustifyV("CENTER")
		title:SetHeight(20)
		return title
	end

	local function getDivider(parent,width)
		if not parent then parent = panel end
		local div = CreateFrame("Frame", nil, parent)
		div:SetSize(panel:GetParent():GetWidth() - 30, 2)
		div.tex = div:CreateTexture(nil, "BACKGROUND")
		div.tex:SetHeight(8)
		div.tex:SetPoint("LEFT",-3, 0)
		if ( width ) then
			div.tex:SetWidth(width)
		else
			div.tex:SetPoint("RIGHT",0, 0)
		end
		div.tex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		div.tex:SetTexCoord(0.81, 0.94, 0.5, 1)
		return div
	end

	local function getDivider2(parent)
		if not parent then parent = panel end
		local div = CreateFrame("Frame", nil, parent)
		div:SetSize(panel:GetParent():GetWidth(), 2)
		div.tex = div:CreateTexture(nil, "BACKGROUND")
		div.tex:SetHeight(3)
		div.tex:SetPoint("LEFT",0, 0)
		div.tex:SetPoint("RIGHT",0, 0)
		div.tex:SetTexture(0,0,0,1)
		-- div.tex:SetTexCoord(0.81, 0.94, 0.5, 1)
		return div
	end

	local function getDividerVertical(parent,height)
		--if not parent then parent = panel end
		--local div = CreateFrame("Frame",nil,parent)
		--div:SetSize(2, height)
		--div.tex = div:CreateTexture(nil,"BACKGROUND")
		--div.tex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border
	end

	-- ------------------------------- --
	-- general settings in configPanel --
	-- ------------------------------- --

	-- title & subtitle
	panel.title, panel.subText = panel:MakeTitleTextAndSubText("Broker_Everything - "..L["Options"], L["Allows you to adjust the display options."])
	panel.title:ClearAllPoints()
	panel.title:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -7)
	panel.subText:ClearAllPoints()
	panel.subText:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT",0,-3)

	-- reset button over the panel
	panel.reset = panel:MakeButton(
		'name', L["Reset"],
		'description', L["Resets the Broker_Everything Defaults and Reloads the UI."],
		'func', function() Broker_EverythingDB.reset = true ReloadUI() end
	)
	panel.reset:SetPoint(			"BOTTOMRIGHT", panel, "TOPRIGHT", 0, 3)

	-- reload button over the panel
	panel.reload = panel:MakeButton(
		'name', L["Reload UI"],
		'description', L["Reloads the UI. You must do this to apply any changes in module activation."],
		'func', function() ReloadUI() end
	)
	panel.reload:SetPoint(			"BOTTOMRIGHT", panel.reset, "BOTTOMLEFT", -5, 0)

	-- general options title
	panel.generalTitle = getTitle(L["General Options"], "group")
	panel.generalTitle:SetPoint("TOPRIGHT",panel,"TOPRIGHT",-7,-25)

	panel.generalDivide = getDivider()
	panel.generalDivide:SetPoint("TOPRIGHT",panel.generalTitle,"BOTTOMRIGHT",3,0);
	panel.generalDivide:SetSize(panel:GetParent():GetWidth() - 12, 2);

	-- general options box
	panel.generalBox = CreateFrame("Frame",nil,panel)
	panel.generalBox:SetSize(400,125)
	panel.generalBox:SetPoint("TOPRIGHT",panel.generalTitle,"BOTTOMRIGHT",4,4)

	-- tooltip options box
	panel.tooltipBox = CreateFrame("Frame",nil,panel);
	panel.tooltipBox:SetSize(160,95);
	panel.tooltipBox:SetPoint("TOPRIGHT",panel.generalBox,"TOPLEFT",-8,0);

	panel.global = panel:MakeToggle(
			"name", L["Use global profile"], 
			"description", L["Enable/Disable use of global Broker_Everything profile across all of your characters."],
			"default", false, 
			"getFunc", function() return Broker_EverythingDB.global end, 
			"setFunc", function(value) 
				if value == true and Broker_EverythingGlobalDB["Clock"] == nil then
					Broker_EverythingGlobalDB = Broker_EverythingDB
				end
				Broker_EverythingGlobalDB.global = value
			end
		)

	local sets = getIconSets()
	if sets[Broker_EverythingDB.iconset]==nil then
		Broker_EverythingDB.iconset = nil
	end
	panel.iconset = panel:MakeDropDown(
		'name',			"", --L["Iconsets"],
		'description',	L["Choose an custom iconset"],
		'values',		sets,
		'default',		"NONE",
		'current',		Broker_EverythingDB.iconset or "NONE",
		'setFunc',		function(value) Broker_EverythingDB.iconset = value end
	)
	panel.iconcolor = panel:MakeColorPicker(
		'name',			"", --L["Icon color"],
		'description',	L["Change the color of the icons"],
		'hasAlpha',		false,
		'defaultR',		1,
		'defaultG',		1,
		'defaultB',		1,
		'defaultA',		1,
		'getFunc',		function() return unpack(Broker_EverythingDB.iconcolor or C("white","colortable")) end,
		'setFunc',		function(...)
			Broker_EverythingDB.iconcolor = {...}
			ns.updateIconColor(true)
		end
	)
	panel.maxttheight = panel:MakeSlider(
		'name',			"Max. Tooltip height",
		'description',	"Adjust the maximum of tooltip height in percent of your screen height.",
		'minText',		"10%",
		'maxText',		"90%",
		'minValue',		10,
		'maxValue',		90,
		'step', 		10,
		'default',		60,
		'setFunc',		function(value)
			Broker_EverythingDB.maxTooltipHeight = ceil(value/10)/10
			--if objData.event then
			--	if objData.event==true then objData.event = "BE_DUMMY_EVENT" end
			--	ns.modules[modName].onevent({},objData.event,nil)
			--end
		end,
		'getFunc',			function()
			if (Broker_EverythingDB.maxTooltipHeight) then
				return Broker_EverythingDB.maxTooltipHeight * 100
			else
				return 60
			end
		end,
		'currentTextFunc',	function(value) return (ceil(value/10)*10).."%" --[[("%.0f"):format(value~=nil and tonumber(value) or 0)]] end
	)
	panel.suffixColoring = makeCheck(L["Suffix coloring"],           L["Enable/Disable class coloring of the information display suffixes. (eg, ms, fps etc)"], nil, "suffixColour")
	panel.tooltipScale   = makeCheck(L["Tooltip Scaling"],           L["Scale the tooltips with your UIScale. Default is off"], "nil", "tooltipScale")
	panel.showhints      = makeCheck(L["Show hints"],                L["Show hints in tooltips."], "nil", "showHints")
	panel.libdbicon      = makeCheck(L["Broker as Minimap Buttons"], L["Use LibDBIcon to add Broker to Minimap"],"nil","libdbicon")
	panel.goldcolor      = makeCheck(L["Gold coloring"],             L["Use colors instead of icons for gold, silver and copper"],"nil","goldColor")
	panel.usePrefix      = makeCheck(L["Use prefix"],                L["Use prefix 'BE..' on module registration at LibDataBroker. This fix problems with other addons with same broker names but effect your current settings in panel addons like Bazooka or Titan Panel."],"nil","usePrefix")
	panel.scm            = makeCheck(L["Screen capture mode"],       L["The screen capture mode replaces all characters of a name with wildcards (*) without the first. Your chars in XP, your friends battleTags/RealID and there character names and the character names in your guild and there notes."],"nil","scm")


	-- tooltip options elements
	local values = {NONE = L["Default (no modifier)"]};
	for i,v in pairs(ns.tooltipModifiers) do values[i] = v.l; end
	panel.ttModifierKey1 = panel:MakeDropDown(
		'name',			"Show tooltip", --L["Show tooltip"],
		'description',	L["Hold modifier key to display tooltip"],
		'values',		values,
		'default',		"NONE",
		'current',		Broker_EverythingDB.ttModifierKey1 or "NONE",
		'setFunc',		function(value) Broker_EverythingDB.ttModifierKey1 = value end
	);
	panel.ttModifierKey2 = panel:MakeDropDown(
		'name',			"Allow mouseover", --L["Allow mouseover"],
		'description',	L["Hold modifier key to use mouseover in tooltip"],
		'values',		values,
		'default',		"NONE",
		'current',		Broker_EverythingDB.ttModifierKey2 or "NONE",
		'setFunc',		function(value) Broker_EverythingDB.ttModifierKey2 = value end
	);


	-- general box content right
	panel.global:SetPoint(         "TOPRIGHT", panel.generalBox,   "TOPRIGHT",   -190, -3);
	panel.libdbicon:SetPoint(      "TOPLEFT",  panel.global,       "BOTTOMLEFT",    0,  7);
	panel.scm:SetPoint(            "TOPLEFT",  panel.libdbicon,    "BOTTOMLEFT",    0,  7);
	panel.tooltipScale:SetPoint(   "TOPLEFT",  panel.scm,          "BOTTOMLEFT",    0,  7);
	panel.maxttheight:SetPoint(    "TOPLEFT",  panel.tooltipScale, "BOTTOMLEFT",   15, -7);

	-- general box content left
	panel.suffixColoring:SetPoint( "TOPLEFT", panel.generalBox,     "TOPLEFT",      6, -3);
	panel.goldcolor:SetPoint(      "TOPLEFT", panel.suffixColoring, "BOTTOMLEFT",   0,  6);
	panel.showhints:SetPoint(      "TOPLEFT", panel.goldcolor,      "BOTTOMLEFT",   0,  6);
	panel.usePrefix:SetPoint(      "TOPLEFT", panel.showhints,      "BOTTOMLEFT",   0,  6);
	panel.iconset:SetPoint(        "TOPLEFT", panel.usePrefix,      "BOTTOMLEFT", -15,  2);
	panel.iconcolor:SetPoint(      "TOPLEFT", panel.iconset,        "TOPRIGHT",   -10, -1);

	-- tooltip options positions
	panel.ttModifierKey1:SetPoint("TOPLEFT", panel.tooltipBox,      "TOPLEFT",      0, -21);
	panel.ttModifierKey2:SetPoint("TOPLEFT", panel.ttModifierKey1,  "BOTTOMLEFT",   0, -11);


	-- ------------------------------ --
	-- module settings in configPanel --
	-- ------------------------------ --
	panel.moduleOptionsTitle = getTitle(L["Module Options"], "group");
	panel.moduleOptionsTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -146);

	panel.moduleDivide = getDivider()
	panel.moduleDivide:SetPoint("TOPLEFT",panel.moduleOptionsTitle,"BOTTOMLEFT",0,0);
	panel.moduleDivide:SetSize(panel:GetParent():GetWidth() - 12, 2);

	-- scrollframe & scrollchild
	local scrollFrame = CreateFrame("ScrollFrame",addon.."ns.modulesScrollFrame",panel,"UIPanelScrollFrameTemplate");
	scrollFrame:SetPoint("TOPLEFT",panel.moduleDivide,"BOTTOMLEFT", -3, -1);
	scrollFrame:SetWidth(panel:GetParent():GetWidth() - 31);
	scrollFrame:SetFrameLevel(scrollFrame:GetFrameLevel() + 1);
	scrollFrame:SetHeight(394);
	scrollFrame:SetBackdrop({ bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], insets = { left = 0, right = -22, top = 0, bottom = 0 } });
	scrollFrame:SetBackdropColor(.2,.2,.2,1)

	scrollFrame.child = CreateFrame("Frame", scrollFrame:GetName().."_Child", scrollFrame)
	scrollFrame.child:SetWidth(scrollFrame:GetWidth())
	scrollFrame.child:SetHeight(1)

	scrollFrame:SetScrollChild(scrollFrame.child)
	scrollFrame:SetHitRectInsets( 0, 0, 0, 1)

	local height = 0
	local width = scrollFrame.child:GetWidth()
	local prev = scrollFrame.child
	local rowBackdrop = { bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], insets = { left = 0, right = 0, top = 0, bottom = 0 } }
	local row = nil
	local even = false
	local mods2Locale = {}
	local default_points = { edgeSelf = "TOPLEFT", edgeSibling = "TOPLEFT", x = 200, y = 0 }
	local function makeDot(sibling,first_in_row)
		local dot = CreateFrame("frame") dot:SetWidth(1) dot:SetHeight(1)
		dot:SetPoint("TOPLEFT",first_in_row,"BOTTOMLEFT",0,0)
		sibling.elem, sibling.dot = dot, dot
		return dot, sibling, dot
	end

	for k, v in pairs(ns.modules) do mods2Locale[L[k]] = k end

	for K, V in ns.pairsByKeys(mods2Locale) do
		local modName, modData = V, ns.modules[V]

		-- for modName, modData in ns.pairsByKeys(ns.modules) do

		if modData.config then
			local name = "mod_"..modName.."Title"

			if row~=nil then
				row = getDivider2()
				row:SetParent(scrollFrame.child)
				row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 1, -2)
				row:SetWidth(width)
				height = height + row:GetHeight()
				prev = row
			end

			-- create frame for module options
			row = CreateFrame("Frame",name,scrollFrame.child)
			row:SetWidth(width)
			row:SetHeight(modData.config.height)

			if prev ~= scrollFrame.child then
				row:SetPoint("TOPLEFT",prev,"BOTTOMLEFT",-1, -2)
			else
				row:SetPoint("TOPLEFT",prev,"TOPLEFT",0,0)
			end

			-- module name as title
			local title = getTitle(C("green",L[modName]))
			title:SetParent(row)
			title:SetPoint("TOPLEFT",row,"TOPLEFT",5,0)

			if type(modData.config.elements) == "table" then
				-- walk through option table and create all elements
				local dot, sibling, first_in_row = nil,{elem = title, realWidth = 0},title
				dot, sibling, first_in_row = makeDot(sibling,first_in_row)
				for num, objData in pairs(modData.config.elements) do
					if not objData or type(objData)~="table" or type(objData.type)~="string" or objData.disabled==true then
						-- do nothing
					elseif objData.type == "next_row" then
						dot, sibling, first_in_row = makeDot(sibling,first_in_row)
					elseif objData.type == "check" then
						local obj = panel:MakeToggle(
							'name',			objData.label,
							'description',	objData.desc,
							'default',		false,
							'getFunc',		function() return Broker_EverythingDB[modName][objData.name] end,
							'setFunc',		function(value)
								Broker_EverythingDB[modName][objData.name] = value
								if objData.event then
									if objData.event==true then objData.event = "BE_DUMMY_EVENT" end
									ns.modules[modName].onevent({},objData.event,nil)
								end
							end
						)
						obj:SetParent(row)
						obj.type = objData.type
						setPoints(obj,sibling,objData.points or nil,first_in_row)
						sibling.elem = obj
						sibling.realWidth = obj.realWidth
					elseif objData.type == "slider" then
						--[[
						--	objData = {
						--		type         string     
						--		name         string     
						--		label        string     
						--		desc         string     
						--		minText      string     
						--		maxText      string     
						--		minValue     integer    
						--		maxValue     integer    
						--		step         integer    
						--		default      string     
						--	}
						--]]
						local obj = panel:MakeSlider(
							'name',				objData.label,
							'description',		objData.desc,
							'minText',			objData.minText,
							'maxText',			objData.maxText,
							'minValue',			objData.minValue,
							'maxValue',			objData.maxValue,
							'step', 			objData.step or 1,
							'default',			objData.default,
							'setFunc',			function(value)
								Broker_EverythingDB[modName][objData.name] = ("%.0f"):format(value)
								if objData.event then
									if objData.event==true then objData.event = "BE_DUMMY_EVENT" end
									ns.modules[modName].onevent({},objData.event,nil)
								end
							end,
							'getFunc',			function() return Broker_EverythingDB[modName][objData.name] or 0 end,
							'currentTextFunc',	function(value) return ("%.0f"):format(value~=nil and tonumber(value) or 0) end
						)
						obj:SetParent(row)
						obj.type = objData.type
						setPoints(obj,sibling,objData.points or nil,first_in_row)
						sibling.elem = obj
						sibling.realWith = obj:GetWidth()
					elseif objData.type == "dropdown" then
						--[[
						--	objData = {
						--		type         string     
						--		name         string     
						--		label        string     
						--		desc         string     
						--		values       table      
						--		default      string     
						--		setFunc      function   [optional]
						--	}
						--]]
						if not objData.setFunc then
							objData.setFunc = function(value)
								Broker_EverythingDB[modName][objData.name] = value
								if objData.event then
									if objData.event==true then objData.event = "BE_DUMMY_EVENT" end
									ns.modules[modName].onevent({},objData.event,nil)
								end
							end
						end
						local obj = panel:MakeDropDown(
							'name',			objData.label,
							'description',	objData.desc,
							'values',		objData.values,
							'default',		objData.default,
							'current',		Broker_EverythingDB[modName][objData.name] or objData.default,
							'setFunc',		objData.setFunc
						)
						obj:SetParent(row)
						obj.type = objData.type
						setPoints(obj,sibling,objData.points or nil,first_in_row)
						sibling.elem = obj
						sibling.realWith = obj:GetWidth()
					elseif objData.type == "_button" then
						--[[
						--	objData = {
						--		type      string      
						--		label     string      
						--		desc      string      
						--		func      function    [optional]
						--	}
						--]]
						if not objData.func then
							objData.func = function() Broker_EverythingDB[modName][objData.name] = Broker_EverythingDB[modName][objData.name]==1 and 0 or 1 end
						end
						local obj = panel:MakeButton(
							'name',			objData.label,
							'description',	objData.desc,
							'func',			objData.func
						)
						obj:SetParent(row)
						obj.type = objData.type
						setPoints(obj,sibling,objData.points or nil,first_in_row)
						sibling.elem = obj
						sibling.realWith = obj:GetWidth()
					elseif objData.type == "editbox" then
						--[[
						--	objData = {
						--		type       string
						--		name       string
						--		label      string
						--		desc       string
						--		[width]    number
						--		[numberic] boolean
						--		[passwd]   boolean
						--		[getFunc]  function
						--		[setFunc]  function
						--	}
						]]

						local obj = panel:MakeEditBox({
							name = objData.label,
							description = objData.desc,
							default = objData.default or (objData.numeric and 0) or "",
							width = objData.width or nil,
							numeric = objData.numeric or nil,
							passwd = objData.passwd or nil,
							getFunc = objData.getFunc or function()
								local data = Broker_EverythingDB[modName][objData.name]
								if objData.numeric==true then data = tonumber(data) else data = tostring(data) end
								return data end,
							setFunc = objData.setFunc or function(value)
								if objData.numeric==true then value = tonumber(value or 0) else value = tostring(value or "") end
								Broker_EverythingDB[modName][objData.name] = value
								if objData.event==true then
									ns.modules[modName].onevent({},"BE_DUMMY_EVENT")
								end
							end,
						})
						obj:SetParent(row)
						obj.type = objData.type
						setPoints(obj,sibling,objData.points or nil,first_in_row)
						sibling.elem = obj
						sibling.realWidth = obj:GetWidth()
					end

					if first_in_row==dot then
						first_in_row = sibling.elem
					end
					title = nil
				end
			end
			prev = row
		end
	end

	-- empty last row for a better look
	if prev ~= scrollFrame.child then
		local row = CreateFrame("Frame",nil,prev)
		row:SetWidth(1)
		row:SetHeight(14)
		row:SetPoint("TOPLEFT",prev,"BOTTOMLEFT",0,0)
		height = height + row:GetHeight()
	end

end
