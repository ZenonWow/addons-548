
-- TODO: auto sell trash on vendor as option

----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Bags" -- L["Bags"]
local ttName = name.."TT"
local tt = nil
local ContainerIDToInventoryID,GetInventoryItemLink = ContainerIDToInventoryID,GetInventoryItemLink
local GetItemInfo,GetContainerNumSlots,GetContainerNumFreeSlots = GetItemInfo,GetContainerNumSlots,GetContainerNumFreeSlots
local qualityModeValues = {
	["1"]=L["All qualities"],
	["2"]=L["All qualities (+ vendor price)"],
	["3"]=L["Non empty qualities"],
	["4"]=L["Non empty qualities (+ vendor price)"],
	["5"]=L["poor only"],
	["6"]=L["poor only (+ vendor price)"],
	["7"]=L["poor and common"],
	["8"]=L["poor and common (+ vendor price)"]
}
local qualityModes = {
	["1"] = {empty=true,  vendor=false, max=7},
	["2"] = {empty=true,  vendor=true,  max=7},
	["3"] = {empty=false, vendor=false, max=7},
	["4"] = {empty=false, vendor=true,  max=7},
	["5"] = {empty=true,  vendor=false, max=0},
	["6"] = {empty=true,  vendor=true,  max=0},
	["7"] = {empty=true,  vendor=false, max=1},
	["8"] = {empty=true,  vendor=true,  max=1}
}

local G = {}
for i=0, 7 do
	G["ITEM_QUALITY"..i.."_DESC"] = _G["ITEM_QUALITY"..i.."_DESC"]
end
G.ITEM_QUALITY99_DESC = L["Unknown"]

-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\icons\\inv_misc_bag_08",coords={0.05,0.95,0.05,0.95}}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show filled, total and free count of blag slots"],
	events = {
		"PLAYER_LOGIN",
		"BAG_UPDATE",
		"UNIT_INVENTORY_CHANGED"
	},
	updateinterval = nil, -- 10
	config_defaults = {
		freespace = true,
		critLowFree = 5,
		warnLowFree = 15,
		showQuality = true,
		goldColor = false,
		qualityMode = "1"
	},
	config_allowed = {
		qualityMode = {["1"]=true,["2"]=true,["3"]=true,["4"]=true,["5"]=true,["6"]=true,["7"]=true,["8"]=true}
	},
	config = {
		height = 93,
		elements = {
			{
				type = "check",
				name = "showQuality",
				label = L["Show quality"],
				desc = L["Display a list of item qualities"],
				event = true
			},
			{
				type = "check",
				name = "goldColor",
				label = L["Gold coloring"],
				desc = L["Use colors instead of icons for gold, silver and copper"],
				event = true
			},
			{
				type = "dropdown",
				name = "qualityMode",
				label = L["Quality list"],
				desc = L["Choose your favorite"],
				default = "1",
				values = qualityModeValues
			},
			{ type = "next_row" },
			{
				type = "slider",
				name = "critLowFree",
				label = L["Critical low free slots"],
				desc = L["Select the maximum free slot count to coloring in red."],
				minText = "1",
				maxText = "50",
				minValue = 1,
				maxValue = 50,
				default = 5,
				event = true
			},
			{
				type = "slider",
				name = "warnLowFree",
				label = L["Warn low free slots"],
				desc = L["Select the maximum free slot count to coloring in yellow."],
				minText = "2",
				maxText = "100",
				minValue = 2,
				maxValue = 100,
				default = 15,
				event = true
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------

-- Function to determine the total number of bag slots and the number of free bag slots.
local function BagsFreeUsed()
	local t = GetContainerNumSlots(0)
	local f = GetContainerNumFreeSlots(0)

	for i=1,NUM_BAG_SLOTS do
		local idtoinv = ContainerIDToInventoryID(i)
		local il = GetInventoryItemLink("player", idtoinv)
		if il then
			local st = select(7, GetItemInfo(il))
			if st ~= "Soul Bag"
					and st ~= "Ammo Pouch"
					and st ~= "Quiver" then
				t = t + GetContainerNumSlots(i)
				f = f + GetContainerNumFreeSlots(i)
			end
		end
	end
	return f, t
end

local function itemQuality()
	local _, item_id, xm, itemRarity, itemSellPrice, itemCount
	local price, sum = {["0"]=0,["1"]=0,["2"]=0,["3"]=0,["4"]=0,["5"]=0,["6"]=0,["7"]=0,["99"]=0},{["0"]=0,["1"]=0,["2"]=0,["3"]=0,["4"]=0,["5"]=0,["6"]=0,["7"]=0,["99"]=0}
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			item_id = GetContainerItemID(bag,slot)
			if item_id then
				xm, _, itemRarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(item_id)
				_, itemCount = GetContainerItemInfo(bag, slot)
				if itemRarity==nil then itemRarity=99 end
				itemRarity = tostring(itemRarity)
				price[itemRarity] = (price[itemRarity] or 0) + (itemSellPrice or 0)
				sum[itemRarity] = (sum[itemRarity] or 0) + (itemCount or 0)
			end
		end
	end
	return price, sum
end


------------------------------------
-- module (BE internal) functions --
------------------------------------
--[[
module.preinit = function()
	if Broker_EverythingDB[name].freespace == nil then
		Broker_EverythingDB[name].freespace = true
	end
end
--]]

module.onevent = function(self,event,msg)
	local f, t = BagsFreeUsed()
	local u = t - f
	local p = u / t
	local txt = u .. "/" .. t
	local c = "white"
	local min1 = tonumber(Broker_EverythingDB[name].critLowFree)
	local min2 = tonumber(Broker_EverythingDB[name].warnLowFree)

	if Broker_EverythingDB[name].freespace == false then
		txt = u .. "/" .. t
	else
		txt = (t - u) .. " ".. L["free"]
	end

	if f<=min1 then
		c = "red"
	elseif f<=min2 then
		c = "dkyellow"
	end

	self.obj.text = C(c,txt)
end

module.ontooltip = function(tt)
	if (not tt.key) or tt.key~=ttName then return end -- don't override other LibQTip tooltips...
	local f, total = BagsFreeUsed()
	local l, c, n

	tt:AddHeader(C("dkyellow",L[name]))
	tt:AddSeparator(1)

	l,c = tt:AddLine()
	tt:SetCell(l,1,C("ltyellow",L["Free slots"] .. " :"))
	tt:SetCell(l,3,C("white",f).." ")

	l,c = tt:AddLine()
	tt:SetCell(l,1,C("ltyellow",L["Total slots"] .. " :"))
	tt:SetCell(l,3,C("white",total).." ")

	if Broker_EverythingDB[name].showQuality then
		local mode = qualityModes[Broker_EverythingDB[name].qualityMode]
		local price, sum = itemQuality()
		tt:AddSeparator(3,0,0,0,0)

		l,c = tt:AddLine()
		tt:SetCell(l,1,C("ltblue",L["Quality"]))
		if mode.vendor then
			tt:SetCell(l,2,C("ltblue",L["Vendor price"]))
		end
		tt:SetCell(l,3,C("ltblue",L["Count"]))
		tt:AddSeparator(1)

		for i,v in ns.pairsByKeys(sum) do
			if (tonumber(i) <= mode.max or (i=="99" and v~=0)) and ((mode.empty==true and v>=0) or (mode.empty==false and v>0)) then
				n = G["ITEM_QUALITY"..i.."_DESC"]
				l,c = tt:AddLine()
				tt:SetCell(l,1,C("quality"..i,n))
				if price[i]>0 and mode.vendor then
					tt:SetCell(l,2, ns.GetCoinColorOrTextureString(name,price[i]))
				end
				tt:SetCell(l,3,v.." ")
			end
		end
	end

	if Broker_EverythingDB.showHints then
		tt:AddSeparator(3,0,0,0,0)
		l,c = tt:AddLine()
		tt:SetCell(l,1,C("copper",L["Left-click"]).." || "..C("green",L["Open bags"]) .. "|n" .. C("copper",L["Right-click"]).." || "..C("green",L["Switch display"]),3)
	end
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
module.onenter = function(self)
	if (ns.tooltipChkOnShowModifier(false)) then return; end

	tt = ns.LQT:Acquire(ttName, 3, "LEFT", "RIGHT", "RIGHT")
	module.ontooltip(tt)
	ns.createTooltip(self,tt)
end

module.onleave = function(self)
	ns.hideTooltip(tt,ttName,true)
end

module.onclick = function(self,button)
	if button == "RightButton" then
		if Broker_EverythingDB[name].freespace == false then
			Broker_EverythingDB[name].freespace = nil
		else
			Broker_EverythingDB[name].freespace = false
		end
		module.onevent(self)
	else
		securecall("ToggleBackpack")
	end
end


-- final module registration --
-------------------------------
ns.modules[name] = module

