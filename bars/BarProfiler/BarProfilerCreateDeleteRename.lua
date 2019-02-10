BPFunc.Profiles = {
-------------------------------------------------------------------------------------------------------------------------------------------
	Create = function(ProfileName, CreatePosition)
		local me, key, value, test2 = BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter]
		if ProfileName == "" then
			test2 = 1
		end
		local test, test1 = string.find(ProfileName, "%s")
		if test == 1 or test1 == 1 or test2 == 1 then
			BarProfiler:Print ("Error - Invalid Profile Name ", ProfileName)
			return 1
		end
		if me.Profiles[ProfileName] ~= nil then
			BarProfiler:Print ("Error - That Profile name is already being used")
			return 1
		end
		if CreatePosition == nil then
			table.insert (me.ProfileList, ProfileName)
			BarProfiler:Print("Profile", ProfileName, "created successfully")
		else
			table.insert (me.ProfileList, CreatePosition, ProfileName)
		end
		me.Profiles[ProfileName] = {}
		for CreateSlotsLoop = 1, 120 do
			me.Profiles[ProfileName][CreateSlotsLoop] = {}
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	Delete = function(PrintCheck)
		local me = BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter]
		local DeleteName = me.ProfileList[BPTemp.Main.SelectedProfile]
		me.Profiles[DeleteName] = nil	
		table.remove(me.ProfileList, BPTemp.Main.SelectedProfile)
		if PrintCheck == nil then
			BarProfiler:Print ("Profile", DeleteName, "deleted successfully")
		end
		BPTemp.Main.SelectedProfile = nil
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	Rename = function(NewProfileName, Silent)
		local me = BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter]
		local CreatePosition = BPTemp.Main.SelectedProfile + 1
		local error = BPFunc.Profiles.Create (NewProfileName, CreatePosition)
		if error == 1 then
			return
		end
		local OldProfileName = me.ProfileList[BPTemp.Main.SelectedProfile]
		me.Profiles[NewProfileName] = me.Profiles[OldProfileName]
		BPFunc.Profiles.Delete(true)
		if Silent == false then
			BarProfiler:Print ("Profile", OldProfileName, "renamed to", NewProfileName)
		end
	end
-------------------------------------------------------------------------------------------------------------------------------------------
}