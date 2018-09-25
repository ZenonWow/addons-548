local CES = CreateFrame("Frame")
local L = LibStub('AceLocale-3.0'):GetLocale('Combuctor')
local CombuctorSet = Combuctor:GetModule('Sets')
CES_Items = {}	--cache of items saved to sets
local items = CES_Items
local FilterFunction

local function SetFilterFunction()
	if CESDB then
		FilterFunction = function(_,_,name,_,_,_,_,type)
			return not items[name] and type == L.Armor or type == L.Weapon
		end
	else
		FilterFunction = function(_,_,name,_,_,_,_,type)
			return items[name] --and type == L.Armor or type == L.Weapon
		end
	end
end

CES:SetScript("OnEvent", function(self, event)
		local IDs = {}	--table to store IDs from GetEquipmentSetItemIDs()
		local name
		wipe(items)		--clear table to start anew
		for i = 1, GetNumEquipmentSets() do
			setname = GetEquipmentSetInfo(i)
			IDs = GetEquipmentSetItemIDs(setname)
			for k,v in pairs(IDs) do
				name = GetItemInfo(v)
				if name then
					items[name] = true	--save item name for Combuctor to check
				end
			end
		end
		if event == "PLAYER_ENTERING_WORLD" then
			if CESDB == nil then CESDB = true end
			SetFilterFunction()
			CombuctorSet:RegisterSubSet("CES", L.Equipment, nil, FilterFunction)
			SlashCmdList["COMBUCTOR_EQUIPMENTSETS"] = function()
					CESDB = not CESDB
					SetFilterFunction()
					if CESDB then
						print("|caaaa00ffCombuctor Equipment Sets:|r The CES tab is now displaying items NOT currently saved to a set.")
					else
						print("|caaaa00ffCombuctor Equipment Sets:|r The CES tab is now displaying items currently saved to a set.")
					end
					CombuctorSet:RegisterSubSet("CES", L.Equipment, nil, FilterFunction)
				end
			SLASH_COMBUCTOR_EQUIPMENTSETS1 = "/ces"
		end
	end)


CES:RegisterEvent("PLAYER_ENTERING_WORLD")
CES:RegisterEvent("EQUIPMENT_SETS_CHANGED")