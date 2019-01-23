
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Surprise" -- L["Surprise"]
local ttName = name.."TT"
local tt = nil
local ITEM_DURATION,ITEM_COOLDOWN,ITEM_LOOTABLE=1,2,3
local founds,counter,items = {},{},{
	-- 1 items with duration time
	[39878] = {ITEM_DURATION, "tooltipLine4"}, -- Mysterious Egg (Geen <Oracles Quartermaster>, Sholaar Basin)
	[44717] = {ITEM_DURATION, "tooltipLine4"}, -- Disgusting Jar
	[94295] = {ITEM_DURATION, "tooltipLine4"}, -- Primal Egg
	[118705] = {ITEM_DURATION, "tooltipLine4"}, -- Warm Goren Egg
	-- 2 items with cooldown time
	[19462] = {ITEM_COOLDOWN, "duration"}, -- Unhatched Jubling Egg
	-- 3 lootable items
	[19450] = {ITEM_LOOTABLE}, -- A Jubling's Tiny Home (prev.: Unhatched Jubling Egg)
	[39883] = {ITEM_LOOTABLE}, -- Cracked Egg (prev.: Mysterious Egg)
	[44718] = {ITEM_LOOTABLE}, -- Ripe Disgusting Jar (prev.: Disgusting Jar)
	[94296] = {ITEM_LOOTABLE},  -- Cracked Primal Egg (prev.: Primal Egg)
	[118206] = {ITEM_LOOTABLE} -- Cracked Goren Egg
}


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Icons\\INV_misc_gift_01",coords={0.05,0.95,0.05,0.95}}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show, equip, delete, update and save equipment sets"],
	events = {
		"PLAYER_ENTERING_WORLD",
		"BAG_UPDATE",
	},
	updateinterval = 10,
	config_defaults = nil,
	config_allowed = nil,
	config = nil -- {}
}


--------------------------
-- some local functions --
--------------------------
local function foundFunc(item_id,bag,slot)
	founds[item_id] = ns.GetItemData(item_id,bag,slot)
	counter[items[item_id][1]] = (counter[items[item_id][1]] or 0) + 1
	counter['sum'] = (counter['sum'] or 0) + 1
end

local function resetFunc() -- clear founds table
	founds = {}
	counter = {}
end

local function updateFunc() -- update broker
	local obj = module.obj
	if counter.sum==nil then counter.sum = 0 end
	if counter.sum>0 then
		obj.text = ((counter[ITEM_LOOTABLE] and C("green",counter[ITEM_LOOTABLE])) or 0) .. "/" .. counter.sum
	else
		obj.text = "0/0"
	end
end

local function getTooltip(tt)
	if (not tt.key) or tt.key~=ttName then return end -- don't override other LibQTip tooltips...

	local e,l,c = 0,nil,nil
	tt:AddHeader(C("dkyellow",L[name]))
	tt:AddSeparator()

	for i,v in pairs(founds) do
		l,c = tt:AddLine()
		tt:SetCell(l,1,v.itemName)
		tt:SetCell(l,2,C("dkyellow","||"))
		tt:SetCell(l,3, (type(items[i][2])=="function" and items[i][2]()) or (type(items[i][2])=="string" and founds[i][items[i][2]]) or (items[i][1]==ITEM_LOOTABLE and L["(finished)"]) or L["(Unknown)"] )
		e = e+1
	end
	if e==0 then
		tt:AddLine(L["No item found."])
	end
end

------------------------------------
-- module (BE internal) functions --
------------------------------------

module.onevent = function(self,event,...)
	for i,v in pairs(items) do ns.bagScan.RegisterId(name,i,foundFunc,resetFunc,updateFunc) end
	ns.bagScan.Update(true)
end

module.onupdate = function(self)
	
end

-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
module.onenter = function(self)
	if (ns.tooltipChkOnShowModifier(false)) then return; end

	tt = ns.LQT:Acquire(ttName, 3, "LEFT", "LEFT", "RIGHT")
	getTooltip(tt)
	ns.createTooltip(self,tt)
end

module.onleave = function(self)
	ns.hideTooltip(tt,ttName,true)
end


-- final module registration --
-------------------------------
ns.modules[name] = module

