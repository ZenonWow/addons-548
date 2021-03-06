
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I
local MAX_CURRENCIES_IN_TITLE = 4


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Currency"; -- L["Currency"]
local tt2 -- tooltip
local GetCurrencyInfo = GetCurrencyInfo
local currencies = {}
local currencies_num = 0
local currenciesName2Id = {}
local UPDATE_LOCK = false;
local tt2positions = {
	["BOTTOM"] = {edgeSelf = "TOP",    edgeParent = "BOTTOM", x =  0, y = -2},
	["LEFT"]   = {edgeSelf = "RIGHT",  edgeParent = "LEFT",   x = -2, y =  0},
	["RIGHT"]  = {edgeSelf = "LEFT",   edgeParent = "RIGHT",  x =  2, y =  0},
	["TOP"]    = {edgeSelf = "BOTTOM", edgeParent = "TOP",    x =  0, y =  2}
}
local currency_params = {blacklist={[141]=true,[483]=true,[484]=true,[692]=true}, cut={[395]=true,[396]=true,[392]=true}, start=42, stop=799}
local currency = nil


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
--I[name..'_Neutral']  = {iconfile="Interface\\Addons\\"..addon.."\\media\\icon-Neutral"}
I[name..'_Neutral']  = {iconfile="Interface\\minimap\\tracking\\BattleMaster", coords={0.1,0.9,0.1,0.9}}
I[name..'_Horde']    = {iconfile="Interface\\PVPFrame\\PVP-Currency-Horde", coords={0.1,0.9,0.1,0.9}}
I[name..'_Alliance'] = {iconfile="Interface\\PVPFrame\\PVP-Currency-Alliance", coords={0.1,0.9,0.1,0.9}}

---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show your different currencies."],
	icon_suffix = "_Neutral",
	events = {
		"PLAYER_ENTERING_WORLD",
		"KNOWN_CURRENCY_TYPES_UPDATE",
		"CURRENCY_DISPLAY_UPDATE"
	},
	updateinterval = nil, -- 10
	config_defaults = {
		shortTT = false,
		subTTposition = "AUTO",
		currenciesInTitle = {},
		favCurrencies = {},
		favMode=false
	},
	config_allowed = {
		subTTposition = {["AUTO"]=true,["TOP"]=true,["LEFT"]=true,["RIGHT"]=true,["BOTTOM"]=true}
	},
	config = {
		height = 52,
		elements = {
			{
				type = "check",
				name = "shortTT",
				label = L["short Tooltip"],
				desc = L["display the content of the tooltip shorter"]
			},
			{
				type	= "dropdown",
				name	= "subTTposition",
				label	= L["Second tooltip"],
				desc	= L["Where does the second tooltip for a single currency are displayed from the first tooltip"],
				values	= {
					["AUTO"]    = L["Auto"],
					["TOP"]     = L["Over"],
					["LEFT"]    = L["Left"],
					["RIGHT"]   = L["Right"],
					["BOTTOM"]  = L["Under"]
				},
				default = "BOTTOM"
			},
			{
				type	= "check",
				name	= "favMode",
				label	= L["Favorite mode"],
				desc	= L["Display as favorite selected currencies only."],
				disabled= true
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------
local function collectData() -- collect currency data
	UPDATE_LOCK = true;
	local GetCurrencyListInfo = GetCurrencyListInfo;
	local itemname, isHeader, isExpanded, isUnused, isWatched, count, icon, currencyId
	currencies_num = 0
	wipe(currencies);

	local collapsed = {};
	local indexes = {};
	local num = GetCurrencyListSize();
	local invertI = num;
	--for i=1, GetCurrencyListSize() do
	--for invertI=num, 1 do
	while (0 < invertI) do
		itemname, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(invertI)
		if (isHeader) then
			collapsed[itemname]=(not isExpanded);
			indexes[itemname]=invertI;
			if (not isExpanded) then
				ExpandCurrencyList(invertI,1);
			end
		end
		invertI = invertI-1;
	end

	local expanded;
	for i=1, num do
		itemname, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(i)
		currencyId = currency.id[itemname]

		if (isHeader) then
			expanded = (collapsed[itemname]~=true);
		end

		currencies[i] = {
			name = itemname,
			id = currencyId,
			isHeader = isHeader,
			isUnused = isUnused,
			isExpanded = expanded,
			count = count,
			maxCount = currencyId~=nil and currency.total[currencyId] or false,
			maxWeekly = currencyId~=nil and currency.weekly[currencyId] or false,
			icon = icon
		}

		if (itemname) then
			currenciesName2Id[itemname] = i
		end
		if (not isHeader) then
			currencies_num=currencies_num+1
		else
			currencies[i].index = indexes[itemname]
		end
	end

	invertI = num;
	while (0 < invertI) do
		itemname, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(invertI)
		if (isHeader) and (collapsed[itemname]==true) then
			ExpandCurrencyList(invertI,0);
		end
		invertI = invertI-1;
	end
	UPDATE_LOCK = false;
end

local function updateTitle(obj)
	local title = {}
	for i = 1,MAX_CURRENCIES_IN_TITLE do
		local v = Broker_EverythingDB[name].currenciesInTitle[i]
		if v and (currenciesName2Id[v]~=nil) and (currencies[currenciesName2Id[v]]~=nil) then
			local d = currencies[currenciesName2Id[v]]
			if (not d.isUnused) and (d.icon) then
				table.insert(title, d.count .. "|T" .. d.icon .. ":0|t")
			end
		end
	end
	if #title==0 then
		obj.text = L[name]
	else
		obj.text = table.concat(title," ")
	end
end

local function setInTitle(titlePlace, currencyName, parent)
	if Broker_EverythingDB[name].currenciesInTitle[titlePlace] ~= currencyName then
		for i = 1,MAX_CURRENCIES_IN_TITLE do
			if titlePlace~=i and Broker_EverythingDB[name].currenciesInTitle[i]==currencyName then return end
		end
		Broker_EverythingDB[name].currenciesInTitle[titlePlace] = currencyName
	else
		Broker_EverythingDB[name].currenciesInTitle[titlePlace] = nil
	end
	updateTitle(module.obj)
end


local function makeMenu(parent)
	local inTitle = setmetatable({},{__index=function() return false end})
	collectData()
	for place=1, 4 do
		if Broker_EverythingDB[name].currenciesInTitle[place] then
			inTitle[Broker_EverythingDB[name].currenciesInTitle[place] ] = true
		end
	end

	ns.EasyMenu.InitializeMenu();

	ns.EasyMenu.addEntry({ label=L["Currency in title - menu"], title=true});
	ns.EasyMenu.addEntry({separator=true});

	for place=1, (currencies_num>=4) and 4 or currencies_num do
		local pList,d;
		local missingCurrency = true;
		local currencyName = Broker_EverythingDB[name].currenciesInTitle[place]
		if  currencyName  then
			local id = currenciesName2Id[currencyName]
			d = currencies[id];
			if (d~=nil) then
				pList = ns.EasyMenu.addEntry({
					label = (C("dkyellow","%s%d:").."  |T%s:20:20:0:0|t %s"):format(L["Place"],place,d.icon,C("ltblue",d.name)) .. ((d.isUnused) and C("orange"," ("..UNUSED..")") or ""),
					arg1 = place,
					arg2 = d.name,
					arrow = true;
					func = function()
						setInTitle(place,d.name);
					end
				});
				missingCurrency = false;
			end
		end
		if (missingCurrency) then
			pList = ns.EasyMenu.addEntry({
				label = (C("dkyellow","%s%d:").."  %s"):format(L["Place"],place,L["Add a currency"]),
				arrow = true
			});
		end
		if (d) then
			ns.EasyMenu.addEntry({ label = C("ltred",L["Remove the currency"]), func=function() setInTitle(place,d.name); end }, pList);
			ns.EasyMenu.addEntry({separator=true}, pList);
		end
		local I = 1;
		for k,v in pairs(currencies) do
			if (v.name) and (v.name~=UNUSED) and (not v.isUnused) then
				if (I>1) and (v.isHeader) then
					ns.EasyMenu.addEntry({separator=true},pList);
				end
				local name = v.name;
				if (not inTitle[v.name]) then
					name = C( v.isHeader and "ltblue" or "ltyellow", name)
				end
				ns.EasyMenu.addEntry({
					label = name,
					icon = v.icon,
					title = (v.isHeader),
					disabled = (inTitle[v.name]),
					func = function() setInTitle(place,v.name); end
				}, pList);
				I = I + 1;
			end
		end
	end

	ns.EasyMenu.ShowMenu(parent);
end


------------------------------------
-- module (BE internal) functions --
------------------------------------
module.initbroker = updateTitle

module.onevent = function(module,event,msg)
	if currency==nil then
		-- collect localized names and currencyID's
		currency = {id={},name={},weekly={}, total={}}
		local currencyName, currentAmount, texture, earnedThisWeek, weeklyMax, totalMax, isDiscovered
		local _=function(id,num) if currency_params.cut[id]==true then num=floor(num/100) end return num end
		for i=currency_params.start, currency_params.stop do
			if currency_params.blacklist[i]~=true then
				currencyName, currentAmount, texture, earnedThisWeek, weeklyMax, totalMax, isDiscovered = GetCurrencyInfo(i)
				if currencyName~=nil and currencyName~="" then
					currency.id[currencyName] = i
					currency.name[i] = currencyName
					if type(weeklyMax)=="number" and weeklyMax>0 then
						currency.weekly[i] = _(i,weeklyMax)
					end
					if type(totalMax)=="number" and totalMax>0 then
						currency.total[i] = _(i,totalMax)
					end
				end
			end
		end
		--[[
		-- convert old currencyInTitle entries to newer version
		if type(Broker_EverythingDB[name].currenciesInTitle[1])=="string" then
			for i = 1,MAX_CURRENCIES_IN_TITLE do
				local currencyName = Broker_EverythingDB[name].currenciesInTitle[i]
				Broker_EverythingDB[name].currenciesInTitle[i] = currency.id[currencyName]
			end
		end
		--]]
	end

	local obj = module.obj
	if UnitFactionGroup("player") ~= "Neutral" then
		local i = I(name.."_"..UnitFactionGroup("player"))
		obj.iconCoords = i.coords or {0,1,0,1}
		obj.icon = i.iconfile
	end
	collectData()
	updateTitle(obj)

	module.onqtip(module.tooltip)
end

module.onqtip = function(tt)
	if not tt then  return  end

	tt:Clear()
	tt:SetColumnLayout(2, "LEFT", "RIGHT")

	tt:AddHeader(C("dkyellow",L[name]))
	if Broker_EverythingDB[name].shortTT == true then
		tt:AddSeparator()
	end

	local l,c;
	for i,v in ipairs(currencies) do
		if (not v.isUnused) then
			if (v.isHeader) then
				if Broker_EverythingDB[name].shortTT == false then
					tt:AddSeparator(3,0,0,0,0)
					l,c = tt:AddLine(C("ltblue",v.name))
					tt:SetLineScript(l,"OnMouseUp",function()
						ExpandCurrencyList(v.index, (v.isExpanded) and 0 or 1 );
					end);
					if (v.isExpanded) then
						tt:AddSeparator()
					end
				end
			elseif (v.isExpanded) then
				local line, column = tt:AddLine(C("ltyellow",v.name),v.count.."  |T"..v.icon..":0|t")
				local lineObj = tt.lines[line]
				lineObj.currencyIndex = i

				tt:SetLineScript(line, "OnEnter",function(self)
					local pos = {}
					if (not tt2) then tt2=GameTooltip; end
					tt2:SetOwner(tt,"ANCHOR_NONE")

					if Broker_EverythingDB[name].subTTposition == "AUTO" then
						local tL,tR,tT,tB = ns.getBorderPositions(tt)
						local uW = UIParent:GetWidth()
						if tB<200 then
							pos = tt2positions["TOP"]
						elseif tL<200 then
							pos = tt2positions["RIGHT"]
						elseif tR<200 then
							pos = tt2positions["LEFT"]
						else
							pos = tt2positions["BOTTOM"]
						end
					else
						pos = tt2positions[Broker_EverythingDB[name].subTTposition]
					end

					tt2:SetPoint(pos.edgeSelf,tt,pos.edgeParent, pos.x , pos.y)
					-- changes for user choosen direction
					tt2:ClearLines()
					tt2:SetCurrencyToken(self.currencyIndex) -- tokenId / the same index number if needed by GetCurrencyListInfo
					tt2:Show()
				end)

				tt:SetLineScript(line, "OnLeave", function(self)
					if (tt2) then tt2:Hide(); end
				end)
			end
		end
	end

	if Broker_EverythingDB.showHints then
		tt:AddSeparator(3,0,0,0,0)
		local l,c = tt:AddLine()
		tt:SetCell(l,1,
			C("copper",L["Left-click"]).." || "..C("green",L["Open currency pane"])
			.."|n"..
			C("copper",L["Right-click"]).." || "..C("green",L["Currency in title - menu"]),
			nil,
			nil,
			2)
	end
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------

module.mouseOverTooltip = true

module.onclick = function(display, button)
	if button == "LeftButton" then
		ToggleCharacter("TokenFrame")
	elseif button == "RightButton" then
		if ns.EasyMenu.HideMenu() then
			ns.defaultOnEnter(module, display)
		else
			ns.hideTooltip(module.tooltip, nil, true)
			makeMenu(display)
		end
	end
end

do
	local dummyEventFunc = function()
		if (UPDATE_LOCK) then return; end
		module:onevent("BE_DUMMY_EVENT")
	end;
	_G["TokenFramePopupInactiveCheckBox"]:HookScript("OnClick",dummyEventFunc);
	hooksecurefunc("ExpandCurrencyList",dummyEventFunc);
end



--[[
IDEAS:
* get max count and weekly max count of a currency for displaying caped counts in red.

]]


-- final module registration --
-------------------------------
ns.modules[name] = module

