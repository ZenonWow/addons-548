
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I
durabilityDB = {}

-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local _
local name = "Durability" -- L["Durability"]
local tt = nil
local hiddenTooltip = nil
local atMerchant = nil
local debugging = false
local updateinterval = nil
local currentCosts = nil
local byGuild = nil
local currentDurability = nil
local reputation = nil
local last_repairs = {}
local singleItemRepairs = 0
local manualRepairAll = nil
local slots = {
	[1]  = "Head",
	[3]  = "Shoulder",
	[5]  = "Chest",
	[6]  = "Waist",
	[7]  = "Legs",
	[8]  = "Feet",
	[9]  = "Wrist",
	[10] = "Hands",
	[16] = "MainHand",
	[17] = "SecondaryHand"
}
if (select(4,GetBuildInfo())<50000) then
	--[[for pre MoP clients]]
	slots[18] = "Ranged";
end
local date_format = "%Y-%m-%d %H:%M"
local date_formats = {
	["%d.%m. %H:%M"]      = "28.07. 16:23",
	["%d.%m. %I:%M %p"]   = "28.07. 04:23 pm",
	["%Y-%m-%d %H:%M"]    = "2099-07-28 16:23",
	["%Y-%m-%d %I:%M %p"] = "2099-07-28 04:23 pm",
	["%d/%m/%Y %H:%M"]    = "28/07/2099 16:23",
	["%d/%m/%Y %I:%M %p"] = "28/07/2099 04:23 pm"
}
if debugging then updateinterval = false end
local colorSets = setmetatable({values={}},{
	__newindex = function(t,k,v)
		local tb,n = {},0
		for i,col in ns.pairsByKeys(v) do table.insert(tb,C(col,(n<100 and n.."-" or "")..i.."%")) n = i+1 end
		rawset(t.values,k,table.concat(tb,", "))
		rawset(t,k,v)
	end,
	__call = function(t,d)
		local c,n = nil,0
		local set = t[Broker_EverythingDB[name].colorSet]
		for i,v in ns.pairsByKeys(set) do if d>=n and d<=i then c,n = v,i+1 end end
		return c
	end
})

colorSets.set1 = {[20]="red",[40]="orange",[99]="yellow",[100]="green"}
colorSets.set2 = {[15]="red",[40]="orange",[70]="yellow",[100]="white"}
colorSets.set3 = {[20]="red",[40]="orange",[60]="yellow",[99]="green",[100]="ltblue"}
colorSets.set4 = {[15]="red",[40]="orange",[60]="yellow",[80]="green",[100]="white"}


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Minimap\\TRACKING\\Repair",coords={0.05,0.95,0.05,0.95}}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show durability of your gear and estimated repair costs."],
	events = {
		"PLAYER_LOGIN",
		"PLAYER_DEAD",
		"PLAYER_REGEN_ENABLED",
		"PLAYER_ENTERING_WORLD",
		"MERCHANT_CLOSED",
		"MERCHANT_SHOW",
		"PLAYER_MONEY",
		"CHAT_MSG_MONEY"
	},
	updateinterval = nil,
	config_defaults = {
		goldColor = false,
		inBroker = "percent",
		colorSet = "set1",
		autorepair = false,
		autorepairbyguild = false,
		listCosts = true,
		saveCosts = true,
		maxCosts = 5,
		dateFormat = "%Y-%m-%d %H:%M",
		showDiscount = true,
		lowestItem = true
	},
	config_allowed = {
		inBroker = {["percent"]=true,["costs"]=true,["costs/percent"]=true,["percent/costs"]=true},
		colorSet = {},
		dateFormat = {["%d.%m. %H:%M"] = true,["%d.%m. %I:%M %p"] = true,["%Y-%m-%d %H:%M"] = true,["%Y-%m-%d %I:%M %p"] = true,["%d/%m/%Y %H:%M"] = true,["%d/%m/%Y %I:%M %p"] = true}
	},
	config = {
		height = 160,
		elements = {
			{
				type = "check",
				name = "goldColor",
				label = L["Gold coloring"],
				desc = L["Use colors instead of icons for gold, silver and copper"],
				event = true
			},
			{
				type = "check",
				name = "autorepairbyguild",
				label = L["Use guild money"],
				desc = L["Use guild money on auto repair if you can"],
				event = true
			},
			{
				type = "check",
				name = "listCosts",
				label = L["List of repair costs"],
				desc = L["Display a list of the last repair costs in tooltip"]
			},
			{ type = "next_row" },
			{
				type = "check",
				name = "saveCosts",
				label = L["Save repair costs"],
				desc = L["Save the list of repair costs over the session"]
			},
			{
				type = "check",
				name = "showDiscount",
				label = L["Show discount"],
				desc = L["Show list of reputation discounts in tooltip"]
			},
			{
				type = "check",
				name = "autorepair",
				label = L["Auto repair"],
				desc = L["Automaticly repair your equipment on opening a merchant with repair option."],
				event = true
			},
			{ type = "next_row" },
			{
				type = "dropdown",
				name = "inBroker",
				label = L["Broker format"],
				desc = L["Choose your favorite display format for the broker button."],
				default = "percent",
				event = true,
				values = {
					["percent"] = "54%",
					["costs"] = "34.23.01",
					["costs/percent"] = "32.27.16, 54%",
					["percent/costs"] = "54%, 32.27.16"
				}
			},
			{
				type = "dropdown",
				name = "colorSet",
				label = L["Percent color set"],
				desc = L["Choose your favorite color set in which the percent text in broker should be displayed."],
				event = true,
				default = "set1",
				values = colorSets.values
			},
			{
				type = "dropdown",
				name = "dateFormat",
				label = L["Date format"],
				desc = L["Choose the date format if used in the list of repair costs"],
				default = "%Y-%m-%d %H:%M",
				values = date_formats,
				event = true
			},
			{ type = "next_row" },
			{
				type="slider",
				name = "maxCosts",
				label = L["Max. list entries"],
				desc = L["Choose how much entries the list of repair costs can have."],
				minValue = 1,
				maxValue = 50,
				minText = "1",
				maxText = "50",
				default = 5
			},
			{
				type  = "check",
				name  = "lowestItem",
				label = L["Lowest durability"],
				desc  = L["Display the lowest item durability in broker."],
				event = true
			}
		}
	}
}


for i,v in pairs(colorSets) do
	module.config_allowed.colorSet[i] = true
end

--------------------------
-- some local functions --
--------------------------
local function getRepairCosts()
	local total,equipped,bags,diff = 0,0,0,0
	for _, slot in ipairs(slots) do
		local id = GetInventorySlotInfo(slot .. "Slot")
		local hasItem, _ ,cost = hiddenTooltip:SetInventoryItem("player", id)
		equipped = equipped + (cost or 0)
	end
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			local _, cost = hiddenTooltip:SetBagItem(bag, slot);
			bags = bags + tonumber(cost or 0)
		end
	end
	total = (equipped + bags)
	if currentCosts~=nil then
		diff = currentCosts - total
	end
	return total,equipped,bags,diff
end

-- Function to remove/add the reputation discounts if at a vendor.
local function repDiscounts(total,direction)
	if not atMerchant then return total end
	local discount = {[5]=0.95,[6]=0.9,[7]=0.85,[8]=0.8}
	local reputation = UnitReaction("npc", "player")
	if discount[reputation]~=nil then total = direction=="remove" and (total / discount[reputation]) or (total * discount[reputation]) end
	return total
end

local function durabilityPercent() -- lowest durability value of equipped item
	local d,X,Y,i = 1,0,0,nil
	for slotId = 1, 18 do
		if GetInventoryItemLink("player", slotId) then
			local x, y = GetInventoryItemDurability(slotId)
			if x and y > 0 then
				X,Y = X+x,Y+y
				if x / y < d then
					d = x / y
					i = slotId
				end
			end
		end
	end
	local xy = Y>0 and X/Y or 0
	return floor(d * 100), xy, i
end

local function lastRepairs_add(cost,fund)
	local t = {}
	if fund==nil then fund = byGuild end
	table.insert(t,{time(),cost,fund})
	for i,v in ipairs(last_repairs) do
		if #t<50 then table.insert(t,v) end
	end
	last_repairs = t
	if Broker_EverythingDB[name].saveCosts then
		durabilityDB = t
	end
end

local function byGuildBank()
	if (not Broker_EverythingDB[name].autorepairbyguild) or (not IsInGuild()) then return 0 end
	if (not CanGuildBankRepair()) or GetGuildInfoText():match("%[noautorepair%]") then return 0 end
	return 1
end

local function lastRepairs_reset()
	last_repairs = {}
	durabilityDB = {}
	module.onqtip(module.tooltip)
end

local function toggleAutoRepair()
	Broker_EverythingDB[name].autorepair = not Broker_EverythingDB[name].autorepair
	module.onqtip(module.tooltip)
end

local function toggleByGuild(tt)
	Broker_EverythingDB[name].autorepairbyguild = not Broker_EverythingDB[name].autorepairbyguild
	module.onqtip(module.tooltip)
end

function module.onqtip(tt)
	if  not tt  or  tt.key ~= module.name  then  return  end

	tt:Clear()
	tt:SetColumnLayout(2, "LEFT", "RIGHT")

	local repairCost, equipCost, bagCost, _ = getRepairCosts()
	local repairCost2 = repDiscounts(repairCost,"remove")
	local durabilityL, durabilityA, durabilityLslot = durabilityPercent()
	durabilityA = floor(durabilityA*100)
	local a,g,d = Broker_EverythingDB[name].autorepair, Broker_EverythingDB[name].autorepairbyguild
	local lst = setmetatable({},{__call = function(t,a) rawset(t,#t+1,a) end})

	lst({sep={3,0,0,0,0}})
	lst({c1=C("ltblue",L["Repair cost"]),c2=ns.GetCoinColorOrTextureString(name,repairCost)})
	lst({sep={1}})
	lst({c1=L["Character"],c2=ns.GetCoinColorOrTextureString(name,equipCost)})
	lst({c1=L["Bags"],c2=ns.GetCoinColorOrTextureString(name,bagCost)})

	if Broker_EverythingDB[name].showDiscount then
		lst({sep={3,0,0,0,0}})
		lst({c0=C("ltblue",L["Reputation discounts"])})
		lst({sep={1}})
		lst({c1=C("white",L["Neutral"]),  c2=ns.GetCoinColorOrTextureString(name,repairCost2)})
		lst({c1=C("white",L["Friendly"]), c2=ns.GetCoinColorOrTextureString(name,floor(repairCost2 * 0.95))})
		lst({c1=C("white",L["Honoured"]), c2=ns.GetCoinColorOrTextureString(name,floor(repairCost2 * 0.89))})
		lst({c1=C("white",L["Revered"]),  c2=ns.GetCoinColorOrTextureString(name,floor(repairCost2 * 0.85))})
		lst({c1=C("white",L["Exalted"]),  c2=ns.GetCoinColorOrTextureString(name,floor(repairCost2 * 0.80))})
	end

	if Broker_EverythingDB[name].listCosts then
		lst({sep={3,0,0,0,0}})
		if Broker_EverythingDB[name].saveCosts then
			lst({c0=C("ltblue",L["Last %d repair costs"]:format(Broker_EverythingDB[name].maxCosts))})
		else
			lst({c1=C("ltblue",L["Last %d repair costs"]:format(Broker_EverythingDB[name].maxCosts)),c2=C("ltblue",L["(session only)"])})
		end
		lst({sep={1}})
		if #last_repairs>0 then
			for i,v in ipairs(last_repairs) do
				if i<=tonumber(Broker_EverythingDB[name].maxCosts) then
					
					lst({c1=date(date_format,v[1])..((v[3]==1 and " G") or (v[3]==0 and " P") or ""),c2=ns.GetCoinColorOrTextureString(name,ceil(v[2]))})
				end
			end
		else
			lst({c0=L["No data found"]})
		end
	end

	if Broker_EverythingDB.showHints then
		lst({sep={3,0,0,0,0}})
		lst({c0=C("copper",L["Left-click"]).." || "..C("green",L["Open character info"])});
		lst({c0=C("copper",L["Right-click"]).." || "..C("green",L["Open auto repair menu"])});
	end

	tt:AddHeader(C("dkyellow",L[name]));
	tt:AddSeparator();
	local slotName = "";
	if (durabilityLslot) then
		if (slots[durabilityLslot]) then
			slotName = (" (%s)"):format(L[slots[durabilityLslot]]);
		else
			slotName = " (?)";
			ns.print("Error: unknown slot", durabilityLslot);
		end
	end
	tt:AddLine(L["Lowest item"]..slotName,	C(colorSets(durabilityL) or "blue", durabilityL.."%"))
	tt:AddLine(L["Average"],				C(colorSets(durabilityA) or "blue", durabilityA.."%"))

	for i,v in ipairs(lst) do
		if v.sep~=nil then
			tt:AddSeparator(unpack(v.sep))
		elseif v.c0~=nil then
			local l,c = tt:AddLine()
			tt:SetCell(l,1,v.c0,nil,nil,2)
			if v.f0~=nil then tt:SetCellScript(l,1,"OnMouseUp",v.f0) end
		else
			local l,c = tt:AddLine()
			tt:SetCell(l,1,v.c1)
			tt:SetCell(l,2,v.c2)
		end
	end

	if true then return end
end



local function createMenu(self)
	ns.EasyMenu.InitializeMenu();

	ns.EasyMenu.addEntry({ label = L["Options"], title = true });

	ns.EasyMenu.addEntry({ separator = true });

	ns.EasyMenu.addEntry({
		label = L["Auto repair"],
		checked = function() return Broker_EverythingDB[name].autorepair; end,
		func  = function() Broker_EverythingDB[name].autorepair = not Broker_EverythingDB[name].autorepair; end,
		disabled = (false)
	});
	ns.EasyMenu.addEntry({
		label = L["Repair by Guild"],
		checked = function() return Broker_EverythingDB[name].autorepairbyguild; end,
		func  = function() Broker_EverythingDB[name].autorepairbyguild = not Broker_EverythingDB[name].autorepairbyguild; end,
		disabled = (false)
	});

	ns.EasyMenu.addEntry({ separator = true });

	ns.EasyMenu.addEntry({
		label = L["Reset last repairs"],
		colorName = "yellow",
		func  = function() lastRepairs_reset() end,
		disabled = (false)
	});

	--ns.EasyMenu.addChancel();
	ns.EasyMenu.ShowMenu(self);
end

------------------------------------
-- module (BE internal) functions --
------------------------------------

module.preinit = function()
	hiddenTooltip = CreateFrame("GameTooltip", "BasicBrokerScanTip", nil, "GameTooltipTemplate")
	hiddenTooltip:SetOwner(UIParent, "ANCHOR_NONE")

	date_format = Broker_EverythingDB[name].dateFormat
	if durabilityDB[ns.realm]==nil then
		durabilityDB[ns.realm] = {}
	end
	if Broker_EverythingDB[name].saveCosts then
		last_repairs = durabilityDB or {}
	else
		durabilityDB = {} 
	end
end

module.onevent = function(module,event,msg)
	local dataobj = module.obj 
	local discount = {[5]=0.95,[6]=0.9,[7]=0.85,[8]=0.8}
	local repairCosts, equipment, bag, diff = getRepairCosts()

	local dL,dA,d = durabilityPercent()
	if not (Broker_EverythingDB[name].lowestItem) then
		d = floor(dA*100) -- average durability
	else
		d = dL -- lowest item durability
	end

	if event == "MERCHANT_SHOW" then
		local costs, canRepair = GetRepairAllCost()
		if canRepair then
			atMerchant = true
			reputation = UnitReaction("npc", "player")
			currentCosts = costs
			_, currentDurability = durabilityPercent()
			if Broker_EverythingDB[name].autorepair then
				byGuild = byGuildBank()
				if byGuild == 0 and costs > GetMoney() then byGuild = false end
				if byGuild~=false then
					RepairAllItems(byGuild)

					-- add repair costs from auto repair
					local _, _, _, diff = getRepairCosts()
					if diff>0 then lastRepairs_add(diff,byGuild) end

					module:onevent("BE_DUMMY_EVENT")
				end
				currentCosts = nil
				byGuild = nil
			end
		end
	end

	if atMerchant==true then
		if event == "CHAT_MSG_MONEY" or event == "PLAYER_MONEY" then
			if manualRepairAll==true and diff>0 then 
				-- if byGuild == 0 then RepairAll with own money
				-- if byGuild == 1 then RepairAll with guild money
				lastRepairs_add(diff,byGuild)
				byGuild, manualRepairAll, currentCosts = nil,nil,nil
			end
			if InRepairMode() and diff>0 then -- single item repair mode, step 1
				singleItemRepairs = singleItemRepairs + diff
			end
		end

		if event == "MERCHANT_CLOSED" then
			if singleItemRepairs>0 then -- single item repair mode, step 2
				lastRepairs_add(singleItemRepairs,0)
				currentCosts = currentCosts - singleItemRepairs
			end
			if currentCosts~=nil then
				local now = currentCosts - repairCosts
				if now>0 and byGuild~=nil then -- last point to track repair cost changes
					lastRepairs_add(now,byGuild)
				end
			end
			reputation, atMerchant, manualRepairAll, singleItemRepairs = nil,nil,nil,0
		end
	end

	if Broker_EverythingDB[name].inBroker == "costs" then
		dataobj.text = ns.GetCoinColorOrTextureString(name,repairCosts)
	else
		if Broker_EverythingDB[name].inBroker == "percent" then
			dataobj.text = C(colorSets(d)or "blue",d.."%")
		elseif Broker_EverythingDB[name].inBroker == "percent/costs" then
			dataobj.text = C(colorSets(d)or "blue",d.."%")..", "..ns.GetCoinColorOrTextureString(name,repairCosts)
		elseif Broker_EverythingDB[name].inBroker == "costs/percent" then
			dataobj.text = ns.GetCoinColorOrTextureString(name,repairCosts)..", "..C(colorSets(d) or "blue",d.."%")
		end
	end

	date_format = Broker_EverythingDB[name].dateFormat
end

module.onclick = function(display, button)
	if  button == "LeftButton"  then
		ToggleCharacter("PaperDollFrame")
		if  ns.OpenCharacterTab  then  ns.OpenCharacterTab(3)  end
	elseif  button == "RightButton"  then
		if ns.EasyMenu.HideMenu() then
			ns.defaultOnEnter(module, display)
		else
			ns.hideTooltip(module.tooltip, nil, true)
			createMenu(display)
		end
	end
end

do
	local percent = 0
	module.onupdate = function(module)
		if debugging then
			module.onevent(module,"DEBUGGING",percent)
			percent = percent==100 and 0 or percent+1
		end
	end
end

module.mouseOverTooltip = nil

--[[

some mercant are friendly but without reputation discount.
Gizmo GUID 0xF1307F7F003AE87A

]]

-- -------------------------------------------- --
-- Hooks of Blizzards ui elements and functions --
-- -------------------------------------------- --
_G['MerchantRepairAllButton']:HookScript("OnClick",function(self,button)
	manualRepairAll = true
	byGuild = 0
end)
_G['MerchantGuildBankRepairButton']:HookScript("OnClick",function(self,button)
	manualRepairAll = true
	byGuild = 1
end)


-- final module registration --
-------------------------------
ns.modules[name] = module

