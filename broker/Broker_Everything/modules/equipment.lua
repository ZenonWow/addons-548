
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Equipment" -- L["Equipment"]
local equipPending = nil


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Addons\\"..addon.."\\media\\equip"}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
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
function ns.toggleEquipment(eName)
	if InCombatLockdown() then 
		equipPending = eName
		module.onevent("BE_DUMMY_EVENT")
	else
		UseEquipmentSet(eName);
	end
end


------------------------------------
-- module (BE internal) functions --
------------------------------------

module.onevent = function(self,event,...)
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

	local equipSet
	local dataobj = self.obj

	local numEquipSets = GetNumEquipmentSets()
	for i = 1, numEquipSets do 
		local equipName, iconFile, _, isEquipped, _, _, _, numMissing = GetEquipmentSetInfo(i)
		if isEquipped then
			equipSet = { equipName, iconFile }
			module.modDB.lastEquipSet = equipSet
			break
		end
	end

	local lastEquipSet = module.modDB.lastEquipSet

	if equipPending then
		dataobj.text =  equipPending  and  L["Pending:"].." "..C("orange",equipPending)
	elseif equipSet then
		dataobj.text = equipSet[1]
	elseif lastEquipSet then
		dataobj.text = L["Was:"].." "..C("red",lastEquipSet[1])
		dataobj.text = L["Changed:"].." "..C("red",lastEquipSet[1])
		dataobj.text = C("red",lastEquipSet[1]).." "..L["(changed)"]

	elseif 0 == numEquipSets then
		dataobj.text = L["No sets found"]
	else
		dataobj.text = C("red",L["Unknown Set"])
	end
	
	if lastEquipSet then
		dataobj.iconCoords = {0.05,0.95,0.05,0.95}
		dataobj.icon = lastEquipSet[2]
	else
		local icon = I(name)
		dataobj.iconCoords = icon.coords or {0,1,0,1}
		dataobj.icon = icon.iconfile
	end
end

--[[ To test: before changing some gear
/run Broker_EverythingDB.equipment.lastEquipSet = nil
--]]

module.onqtip = function(tt)
	tt:Clear()
	tt:SetColumnLayout(2, "LEFT", "RIGHT")
	tt:AddHeader(C("dkyellow",L[name]))
	tt:AddSeparator()

	if not CanUseEquipmentSets() then
		tt:AddLine(L["Equipment manager is not enabled"])
		tt:AddLine(L["Enable it from the character pane"])
		return
	end

	local numEquipSets = GetNumEquipmentSets()

	local line, column
	if numEquipSets < 1 then
		tt:AddLine(L["No equipment sets found"])
		line, column = tt:AddLine(C("copper",L["Click"]).." || "..C("green",L["Open equipment manager"]))
		tt:SetLineScript(line, "OnMouseUp", function(self) ToggleCharacter("PaperDollFrame") end)
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
				ns.hideTooltip(tt, nil, true)
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

module.mouseOverTooltip = true


function ns.OpenCharacterTab(tabNum)
	-- idea from: Broker_Equipment addon
	if  not PaperDollFrame:IsVisible()  then  return  end

	if  not CharacterFrame.Expanded  then  CharacterFrame_Expand()  end
	--_G['PaperDollSidebarTab'..tabNum]:Click()
	PaperDollFrame_SetSidebar(_G['PaperDollSidebarTab'..tabNum], tabNum)
end

module.onclick = function(self,button)
	if button=="LeftButton" then
		ToggleCharacter("PaperDollFrame")
		ns.OpenCharacterTab(3)
	end
end


-- final module registration --
-------------------------------
ns.modules[name] = module

