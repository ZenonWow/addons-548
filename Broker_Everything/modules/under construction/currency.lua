
----------------------------------
-- module independent variables --
----------------------------------
	local addon, ns = ...
	local C, L, I = ns.LC.color, ns.L, ns.I
	XX = {}


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
	local name = "Currency" -- L["Currency"]
	local ldbName = name
	local tt, tt2, tt3, tt4 -- tooltips
	local ttName, tt3Name, tt4Name = name.."TT", name.."TT3", name.."TT4"
	local GetCurrencyInfo, GetCurrencyListInfo = GetCurrencyInfo, GetCurrencyListInfo
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
	ns.modules[name] = {
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
			currenciesInTitle = {false,false,false,false},
			--favCurrencies = {},
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
					default = "AUTO"
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
	local function updateCurrencyAmount() -- collect currency data
		local _, itemname, isHeader, count
		for i=1, GetCurrencyListSize() do
			itemname, isHeader, _, _, _, count = GetCurrencyListInfo(i)
			currencyId = currency.id[itemname]
			if not isHeader then
				if currencyId~=nil then
					currency.data[currencyId].count = count
				end
			end
		end
	end

	local function updateTitle()
		local title = {}
		for i, id in ipairs(Broker_EverythingDB[name].currenciesInTitle) do
			if id~=false then
				if type(id)=="string" and currency.id[id]~=nil then
					id = currency.id[id]
				end
				if type(id)=="number" then
					local count = "--"
					if currency.data[id].count~=nil then
						count = currency.data[id].count
					end
					table.insert(title,count.." |T".. currency.data[id].icon ..":0|t")
				end
			end
		end
		local obj = ns.LDB:GetDataObjectByName(ldbName)
		if #title==0 then
			obj.text = L[name]
		else
			obj.text = table.concat(title," ")
		end
	end

	local function setTitleCurrency(place,id)
		Broker_EverythingDB[name].currenciesInTitle[place] = id
		updateTitle()
	end

	local function unsetTitleCurrency(place)
		Broker_EverythingDB[name].currenciesInTitle[place] = false
		updateTitle()
	end

	local function makeTT4(parent, place, currentId)
		local l
		tt4 = ns.LQT:Acquire(tt4Name,1,"LEFT")
		tt4:Clear()
		--
		tt4:AddLine(C("ltblue",L["Place %d"]:format(place)..currentId))
		if currentId==false then
			tt4:AddSeparator(3,0,0,0,0)
			tt4:AddLine(C("ltblue",L["Set"]))
		else
			tt4:AddSeparator()
			l = tt4:AddLine(C("ltred",L["Clear place"]))
			tt4:SetLineScript(l,"OnMouseUp",function(self) unsetTitleCurrency(place) end)
			--
			tt4:AddSeparator(3,0,0,0,0)
			tt4:AddLine(C("ltblue",L["Replace with"]))
		end
		tt4:AddSeparator()
		local _, itemname, isHeader, icon, currencyId
		for i=1, GetCurrencyListSize() do
			itemname, isHeader, _, _, _, _, icon = GetCurrencyListInfo(i)
			if isHeader then
				tt4:AddLine(C("ltgray",itemname))
			else
				currencyId = currency.id[itemname]
				if currentId~=currencyId then
					l = tt4:AddLine(C("ltyellow",("|T%s:0|t %s"):format(currency.data[currencyId].icon,currency.name[currencyId])))
					tt4:SetLineScript(l,"OnMouseUp",function(self)
						setTitleCurrency(place, currentId)
					end)
				end
			end
		end
		--
		ns.createTooltip(parent,tt4)
		tt4:SetFrameLevel(tt3:GetFrameLevel()+2)
		tt4:ClearAllPoints()
		tt4:SetPoint("TOP",parent,"TOP",0,0)
		local tL,tR,tT,tB = ns.getBorderPositions(tt3)
		local uW = UIParent:GetWidth()
		if tR<(uW/2) then
			tt4:SetPoint("RIGHT",tt3,"LEFT",10,0)
		else
			tt4:SetPoint("LEFT",tt3,"RIGHT",-10,0)
		end
		tt4:SetScript('OnLeave', function(self)
			ns.hideTooltip(self,self.key)
		end)
	end

	local function makeTT3(parent, button)
		tt3 = ns.LQT:Acquire(tt3Name, 4, "RIGHT", "LEFT")
		tt3:Clear()
		--
		local l,c,c2,c3,c4
		l = tt3:AddLine()
		tt3:SetCell(1,1,C("dkyellow",L["Currency in Title"]),tt3:GetHeaderFont(),"LEFT",4)
		tt3:AddSeparator(3,0,0,0,0)
		tt3:AddLine(C("ltblue",L["Place"]),C("ltblue",L["Current"]))
		tt3:AddSeparator()
		for i=1, 4 do
			id = Broker_EverythingDB[name].currenciesInTitle[i]

			l = tt3:AddLine(i..". ", (id==false and C("ltgray",L["Nothing"])) or C("ltyellow",currency.name[id]))

			tt3:SetLineScript(l,"OnEnter", function(self)
				makeTT4(self, i, id)
			end)

			tt3:SetLineScript(l,"OnLeave", function(self)
				ns.hideTooltip(tt4,tt4Name)
			end)
		end
		--
		ns.createTooltip(parent,tt3)
		tt3:ClearAllPoints()
		tt3:SetPoint(ns.GetTipAnchor(parent,true))
		tt3:SetScript('OnLeave', function(self) ns.hideTooltip(self,self.key) end)
	end

	local function makeTT2(self)
		local pos = {}
		if not tt2 then
			tt2 = GameTooltip
		end
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
	end

	local function hideTT2(self)
		tt2:ClearLines()
		tt2:ClearAllPoints()
		tt2:Hide()
		tt2=nil

		if tt3~=nil and tt3:IsShown() and tt3.key==tt3Name then
			ns.hideTooltip(tt3,tt3Name)
		end
	end

	local function makeTT(tt)
		tt:Clear()
		tt:AddHeader(C("dkyellow",L[name]))
		if Broker_EverythingDB[name].shortTT == true then
			tt:AddSeparator()
		end

		local itemname, isHeader, isExpanded, isUnused, isWatched, count, icon, currencyId
		for i=1, GetCurrencyListSize() do
			itemname, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(i)

			if not isUnused then
				currencyId = currency.id[itemname]
				if isHeader then
					if Broker_EverythingDB[name].shortTT == false then
						tt:AddSeparator(3,0,0,0,0)
						tt:AddLine(C("ltblue",itemname))
						tt:AddSeparator()
					end
				else
					local line, column = tt:AddLine(C("ltyellow",itemname),count.."  |T"..icon..":0|t")
					local lineObj = tt.lines[line]
					lineObj.currencyIndex = i
					lineObj.currencyId = currencyId

					tt:SetLineScript(line, "OnEnter", makeTT2)
					tt:SetLineScript(line, "OnLeave", hideTT2)
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


------------------------------------
-- module (BE internal) functions --
------------------------------------
	ns.modules[name].init = function(self)
		ldbName = (Broker_EverythingDB.usePrefix and "BE.." or "")..name

		if currency==nil then
			-- collect localized names and currencyID's
			currency = {id={},name={},data={},weekly={}, total={},icon={},count={}}
			local currencyName, currentAmount, texture, earnedThisWeek, weeklyMax, totalMax
			local _=function(id,num) if currency_params.cut[id]==true then num=floor(num/100) end return num end
			for i=currency_params.start, currency_params.stop do
				if currency_params.blacklist[i]~=true then
					currencyName, currentAmount, texture, earnedThisWeek, weeklyMax, totalMax = GetCurrencyInfo(i)
					if currencyName~=nil and currencyName~="" then
						currency.id[currencyName] = i
						currency.name[i] = currencyName
						currency.data[i] = {
							icon = texture,
							count = currentAmount,
							weeklyMax = 0,
							totalMax = 0,
						}
						if type(weeklyMax)=="number" and weeklyMax>0 then
							currency.data[i].weeklyMax = _(i,weeklyMax)
						end
						if type(totalMax)=="number" and totalMax>0 then
							currency.data[i].totalMax = _(i,totalMax)
						end
					end
				end
			end
			-- convert old currencyInTitle entries to newer version
			local tmp = {}
			if type(Broker_EverythingDB[name].currenciesInTitle[1])=="string" then
				for i,v in ipairs(Broker_EverythingDB[name].currenciesInTitle) do
					if currency.id[v]~=nil then
						tmp[i] = currency.id[v]
					else
						tmp[i] = false
					end
				end
				Broker_EverythingDB[name].currenciesInTitle = tmp
			end
		end

		if self then
			updateCurrencyAmount()
			updateTitle()
		end
	end

	ns.modules[name].onevent = function(self,event,msg)
		local obj = ns.LDB:GetDataObjectByName(ldbName)
		if UnitFactionGroup("player") ~= "Neutral" then
			local i = I(name.."_"..UnitFactionGroup("player"))
			obj.iconCoords = i.coords or {0,1,0,1}
			obj.icon = i.iconfile
		end
		if currency~=nil then
			updateCurrencyAmount()
			updateTitle()
		end
	end

	--[[ ns.modules[name].onupdate = function(self) end ]]

	--[[ ns.modules[name].optionspanel = function(panel) end ]]

	--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

	--[[ ns.modules[name].ontooltip = function(self) end ]]


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
	ns.modules[name].onenter = function(self)
		tt = ns.LQT:Acquire(ttName, 2, "LEFT", "RIGHT")
		makeTT(tt)
		ns.createTooltip(self,tt)
	end

	ns.modules[name].onleave = function(self)
		if tt then
			ns.hideTooltip(tt,name)
		end
	end

	ns.modules[name].onclick = function(self,button)
		if button == "LeftButton" then
			securecall("ToggleCharacter","TokenFrame")
		elseif button == "RightButton" then
			ns.hideTooltip(tt,ttName)
			makeTT3(self)
		end
	end

	--[[ ns.modules[name].ondblclick = function(self,button) end ]]




--[[
IDEAS:
* get max count and weekly max count of a currency for displaying caped counts in red.

]]

--[[

brainstorming: (sry, german ^^)
	* eine manuelle list mit den currencyId's führen
	* nicht in der list befindliche currencies bekommen eine temporäre id in einer extra table
	* 

todo:
	[ ] existierende currency in title von name auf ID umstellen
	[ ] broker button anzeige auf nutzung von id's umstellen
	[ ] 

]]