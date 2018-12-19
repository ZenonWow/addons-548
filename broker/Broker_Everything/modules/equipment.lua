
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Equipment" -- L["Equipment"]
local ldbName = name
local ttName = name.."TT"
local tt = nil
local equipPending = nil


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Addons\\"..addon.."\\media\\equip"}


---------------------------------------
-- module variables for registration --
---------------------------------------
ns.modules[name] = {
	desc = L["Broker to show, equip, delete, update and save equipment sets"],
	events = {
		"UNIT_INVENTORY_CHANGED",
		"EQUIPMENT_SETS_CHANGED",
		"PLAYER_ENTERING_WORLD",
		"PLAYER_REGEN_ENABLED",
		"UNIT_INVENTORY_CHANGED",
		"EQUIPMENT_SETS_CHANGED"
	},
	updateinterval = nil, -- 10
	config_defaults = nil,
	config_allowed = nil,
	config = nil -- {}
}


--------------------------
-- some local functions --
--------------------------
ns.toggleEquipment = function(eName)
	if InCombatLockdown() then 
		equipPending = eName
		ns.modules[name].onevent("BE_DUMMY_EVENT")
	else
		securecall("UseEquipmentSet",eName);
	end
	ns.hideTooltip(tt,ttName,true);
end


------------------------------------
-- module (BE internal) functions --
------------------------------------
ns.modules[name].init = function(obj)
	ldbName = (Broker_EverythingDB.usePrefix and "BE.." or "")..name
end

ns.modules[name].onevent = function(self,event,...)
	if event == "PLAYER_REGEN_ENABLED" then
		if equipPending ~= nil then
			UseEquipmentSet(equipPending)
			equipPending = nil
		end
	end

	if event == "UNIT_INVENTORY_CHANGED" then
		local unit = ...
		if unit ~= "player" then return end
	end

	local dataobj = self.obj or ns.LDB:GetDataObjectByName(ldbName)

	local numEquipSets = GetNumEquipmentSets()

	if numEquipSets >= 1 then 
		for i = 1, GetNumEquipmentSets() do 
			local equipName, iconFile, _, isEquipped, _, _, _, numMissing = GetEquipmentSetInfo(i)
			local pending = (equipPending~=nil and C("orange",equipPending)) or false
			if isEquipped then 
				dataobj.iconCoords = {0.05,0.95,0.05,0.95}
				dataobj.icon = iconFile
				dataobj.text = pending~=false and pending or equipName
				return
			else 
				dataobj.icon = I(name).iconfile
				dataobj.text = pending~=false and pending or C("red",L["Unknown Set"])
			end
		end
	else
		dataobj.text = L["No sets found"]
	end
end

--[[ ns.modules[name].onupdate = function(self) end ]]

--[[ ns.modules[name].optionspanel = function(panel) end ]]

--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

ns.modules[name].ontooltip = function(tt)
	if (not tt.key) or tt.key~=ttName then return end -- don't override other LibQTip tooltips...

	local line, column
	tt:Clear()
	tt:AddHeader(C("dkyellow",L[name]))
	tt:AddSeparator()
	if not CanUseEquipmentSets() then
		tt:AddLine(L["Equipment manager is not enabled"])
		tt:AddLine(L["Enable it from the character pane"])
		return
	end

	local numEquipSets = GetNumEquipmentSets()

	if numEquipSets < 1 then
		tt:AddLine(L["No equipment sets found"])
		line, column = tt:AddLine(C("copper",L["Click"]).." || "..C("green",L["Open equipment manager"]))
		tt:SetLineScript(line, "OnMouseUp", function(self) securecall("ToggleCharacter","PaperDollFrame") end)
		tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
		tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)

		line, column = nil, nil
		return
	end

	for i = 1, numEquipSets do 
		local eName, icon, _, isEquipped, _, _, _, numMissing = GetEquipmentSetInfo(i)
		local color = (equipPending==eName and "orange") or (numMissing>0 and "red") or (isEquipped and "ltyellow") or false
		local formatName = color~=false and C(color,eName) or eName

		line, column = tt:AddLine()
		tt:SetCell(line, 1, formatName, nil, nil, 1, ns.LQT.LabelProvidor, 0, 5)
		tt:SetCell(line, 2, " |T"..icon..":16|t", nil, nil, 1)
		tt:SetLineScript(line, "OnMouseUp", function(self) 
			if IsShiftKeyDown() then 
				local dialog = StaticPopup_Show('CONFIRM_SAVE_EQUIPMENT_SET', eName)
				dialog.data = eName 
			elseif IsControlKeyDown() then
				local dialog = StaticPopup_Show('CONFIRM_DELETE_EQUIPMENT_SET', eName)
				dialog.data = eName				
			else
				ns.toggleEquipment(eName)
			end 
		end)
		tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
		tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
	end

	if Broker_EverythingDB.showHints then
		tt:AddLine(" ")
		line, column = tt:AddLine()
		tt:SetCell(line, 1,
			C("ltblue",L["Click"]).." || "..C("green",L["Equip a set"])
			.."|n"..
			C("ltblue",L["Shift+Click"]).." || "..C("green",L["Update/save a set"])
			.."|n"..
			C("ltblue",L["Ctrl+Click"]).." || "..C("green",L["Delete a set"])
			, nil, nil, 2)
	end

	line, column = nil, nil
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
ns.modules[name].onenter = function(self)
	if (ns.tooltipChkOnShowModifier(false)) then return; end

	tt = ns.LQT:Acquire(ttName, 2, "LEFT", "RIGHT")
	ns.modules[name].ontooltip(tt)
	ns.createTooltip(self,tt)
end

ns.modules[name].onleave = function(self)
	if (tt) then ns.hideTooltip(tt,ttName,false,true); end
end

--[[ ns.modules[name].onclick = function(self,button) end ]]

--[[ ns.modules[name].ondblclick = function(self,button) end ]]


