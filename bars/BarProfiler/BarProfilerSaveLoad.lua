BPFunc.Bars = {
-------------------------------------------------------------------------------------------------------------------------------------------
	Save = function(Location, ProfileName, Silent)
		local SlotLoop
		for SlotLoop = 1, 120 do 
			me = BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter][Location][ProfileName][SlotLoop]
			me.Type, me.GlobalID, me.SubType, me.Texture, me.Name, me.Body = BPFunc.Bars.GetAction(SlotLoop)
		end
		BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter][Location][ProfileName].DataCheck = 1
		if Silent == false then
			BarProfiler:Print ("Current action bars saved to profile", ProfileName)
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	Load = function(Location, ProfileName, Silent)
		local SlotLoop
		for SlotLoop = 1, 120 do
			me = BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter][Location][ProfileName][SlotLoop]
			if me.Ignore == nil then
				BPFunc.Bars.PickUpAction(SlotLoop, me.Type, me.GlobalID, me.SubType, me.Name, me.Body)
				BPFunc.Bars.PlaceAction(SlotLoop)
			end
		end
		if Silent == false then
			BarProfiler:Print("Loaded action bars from profile", ProfileName)
		end
		BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].LoadedProfile = ProfileName
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	GetAction = function(SlotLoop)
		local Type, GlobalID, SubType, Texture, Name, Body
		Type, GlobalID, SubType = GetActionInfo(SlotLoop)
		Texture = GetActionTexture(SlotLoop)
		if Type == 'macro' then
			Name = GetMacroInfo(GlobalID) --macroslot
			Body = GetMacroBody(GlobalID)
		elseif Type == 'companion' then
			for CompanionLoop = 1, GetNumCompanions(SubType) do  
				local creatureID, creatureName, creatureSpellID = GetCompanionInfo(SubType, CompanionLoop)	--unnescarscary variables here
				if creatureSpellID == GlobalID then
					Name = creatureName
				end
			end
		end
		if Texture == nil then
			Texture = "Interface\\BUTTONS\\UI-EmptySlot-Disabled"
		end
		return Type, GlobalID, SubType, Texture, Name, Body
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	PickUpAction = function(SlotLoop, Type, GlobalID, SubType, Name, Body)
		if Type == 'spell' then
			PickupSpell(GlobalID)
		elseif Type == 'item' then
			PickupItem(GlobalID)
		elseif Type == 'macro' then	
			if Body == nil then
				PickupMacro(Name)
			else
				for MacroLoop = 1, 54 do
					local Body2 = GetMacroBody(MacroLoop)
					local Name2 = GetMacroInfo(MacroLoop)
					if Body == Body2 and Name2 == Name then
						PickupMacro(MacroLoop)
					end
				end
			end
		elseif Type == 'equipmentset' then
			PickupEquipmentSetByName (GlobalID)
		elseif Type == "flyout" then
			BPFunc.Bars.PickupFlyout(GlobalID)
		elseif Type == 'companion' then
			if SubType == 'MOUNT' then	--Need to save the mount ID found in mountloop
				for MountLoop = 1, GetNumCompanions("MOUNT") do  
					local creatureID, creatureName, creatureSpellID, icon, issummoned, mountType = GetCompanionInfo("MOUNT", MountLoop)	--unnescarscary variables here
					if creatureSpellID == GlobalID then
						PickupCompanion("MOUNT", MountLoop)
					end
				end
			elseif SubType == 'CRITTER' then	--Need to save the Critter ID found in mountloop
				for CritterLoop = 1, GetNumCompanions("CRITTER") do
					local creatureID, creatureName, creatureSpellID, icon, issummoned, mountType = GetCompanionInfo("CRITTER", CritterLoop)
					if creatureSpellID == GlobalID then
						PickupCompanion("CRITTER", CritterLoop)
					end
				end
			end
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	PickupFlyout = function(id)
		local iii=1
		while true do
			local sbtype, sbid = GetSpellBookItemInfo(iii, "spell")
			if sbtype=="FLYOUT" and sbid==id then
				PickupSpellBookItem(iii, "spell")
				return true
			elseif sbtype==nil and sbid==nil then
				return false
			end
			iii = iii+1
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	PlaceAction = function(SlotLoop)
		if GetCursorInfo() == nil then
			PickupAction(SlotLoop)
		else
			PlaceAction(SlotLoop)
		end
		ClearCursor()
	end
-------------------------------------------------------------------------------------------------------------------------------------------
}