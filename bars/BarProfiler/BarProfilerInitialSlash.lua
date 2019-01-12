BarProfiler = LibStub("AceAddon-3.0"):NewAddon("BarProfiler", "AceConsole-3.0")
BarProfilerIcon = LibStub("LibDBIcon-1.0")
BarProfilerGui = LibStub("AceGUI-3.0")
BarProfiler:RegisterChatCommand("barprofiler", "BarProfilerSlash")
BarProfiler:RegisterChatCommand("bp", "BarProfilerSlash")
-------------------------------------------------------------------------------------------------------------------------------------------
function BarProfiler:OnInitialize()
	BPFunc.Initial.Initialise()
end
-------------------------------------------------------------------------------------------------------------------------------------------
local BarProfilerFrame = CreateFrame("Frame")
	BarProfilerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	local function eventHandler()
		BPFunc.Initial.EnterWorld()
	end
-------------------------------------------------------------------------------------------------------------------------------------------
function BarProfiler:BarProfilerSlash(input)
	BPFunc.Initial.Slash(input)
end
-------------------------------------------------------------------------------------------------------------------------------------------
BarProfilerFrame:SetScript("OnEvent", eventHandler)
-------------------------------------------------------------------------------------------------------------------------------------------
BPFunc = {}
BPFunc.Initial = {
-------------------------------------------------------------------------------------------------------------------------------------------
	Initialise = function ()
		local Key, Value
		BarProfilerDebug = 0	--needs moving into Db
		local Slot = 1
		
		BPTemp = {
			Adv = {},
			Main = {}
		}
		
		if BarProfilerDb == nil then
			BarProfilerDb = {
				Version = 0.1,
				Realms = {},
				RealmList = {},
			}
			BarProfiler:Print ("Creating and initialising database to 0.1")
		end
		if BarProfilerDb.Version == 0.1 then
			BarProfilerDb.Version = 0.2
			BarProfilerDb.Minimap = {
				minimapPos = 243.5,
				Hide = false,
				Info = {}
			}
			BarProfiler:Print ("Upgrading database to 0.2")
		end
		if BarProfilerDb.Version == 0.2 then
			BarProfilerDb.Version = "0.2.1"
			BarProfilerDb.GUI = {
				Main = {
					point = "CENTER",
					relativeTo = nil,
					relativePoint = "CENTER",
					xOfs = 0,
					yOfs = 0
				},
				ConfirmationWindow = {
					point = "CENTER",
					relativeTo = nil,
					relativePoint = "CENTER",
					xOfs = 0,
					yOfs = 0
				}
			}
			BarProfiler:Print ("Upgrading database to 0.2.1")
		end
		if BarProfilerDb.Version == "0.2.1" then
			BarProfilerDb.Version = "0.2.3"
			BarProfilerDb.Adv = {
				Viewer = {}
			}
			BarProfilerDb.GUI.HideWarnings = false
			BarProfiler:Print ("Upgrading database to 0.2.3")
		end
		if BarProfilerDb.Version == "0.2.3" then
			BarProfilerDb.Adv = nil
			BarProfilerDb.SelectedProfile = nil
			BarProfilerDb.CurrentRealm = nil
			BarProfilerDb.CurrentCharacter = nil
			BarProfilerDb.Version = "0.2.3"
			BarProfiler:Print ("Upgrading database to 0.2.4")
		end
		
		BPTemp.CurrentRealm = GetRealmName()
		BPTemp.CurrentCharacter = GetUnitName("player", True)
		
		if BarProfilerDb.Realms[BPTemp.CurrentRealm] == nil then
			BPFunc.Initial.NewRealm()
			BPFunc.Initial.NewCharacter()
		else
			if BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter] == nil then
				BPFunc.Initial.NewCharacter()
			end
		end
		BarProfilerSlashCount = 0	--needs moving into Db
		tinsert(UISpecialFrames,"BPGUIEsc")
		tinsert(UISpecialFrames,"BarProfilerMessageFrame")
		BarProfilerDb.Minimap.Info = LibStub("LibDataBroker-1.1"):NewDataObject("BarProfiler", {	--only needs doing once?
			type = "launcher",
			label = "BarProfiler",
			icon = "Interface\\Icons\\Achievement_guildperk_workingovertime",
			OnClick = function() BarProfiler:BarProfilerSlash(nil) end,
			OnTooltipShow = function(tooltip)
			tooltip:AddLine("Bar Profiler")
			end,
		})
		BarProfilerIcon:Register("BarProfiler", BarProfilerDb.Minimap.Info, BarProfilerDb.Minimap)

		BarProfilerDb.GUI.Inhibit = nil
		BarProfiler:Print ("Loaded")
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	EnterWorld = function ()
		BPFunc.GUI.SettingsTab.MiniMapCheckHandler (BarProfilerDb.Minimap.Hide)
		local temp = BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Version
		if temp == nil or temp == "0.1" or temp == "0.1.1" or temp == "0.1.2" then
			BPFunc.Initial.CharacterUpdate()
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	CharacterUpdate = function ()
		BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Backups = {
			Update1 = {}
		}
		for CreateSlotsLoop = 1, 120 do
			BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Backups.Update1[CreateSlotsLoop] = {}
		end
		BPFunc.Bars.Save("Backups", "Update1")
		for Key,Value in pairs(BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].ProfileList) do
			BPFunc.Bars.Load("Profiles", Value, true)
			BPFunc.Bars.Save("Profiles", Value, true)
			BPFunc.Initial.NameCheck(Key, Value)
		end
		BPFunc.Bars.Load("Backups", "Update1", true)
		BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Version = "0.1.3"
		BarProfiler:Print ("Character Database updated to v0.1.3")
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	Slash = function (input)
		local Command, Argument
		if input ~= nil then
			Command, Argument = input:match("^(%S*)%s*(.-)$")
		end
		if Command == "resetgui" then
			BarProfilerDb.GUI = {
				Main = {
					point = "CENTER",
					relativeTo = nil,
					relativePoint = "CENTER",
					xOfs = 0,
					yOfs = 0
				},
				ConfirmationWindow = {
					point = "CENTER",
					relativeTo = nil,
					relativePoint = "CENTER",
					xOfs = 0,
					yOfs = 0
				}
			}
			BarProfiler:Print ("Position of GUI reset to center")
		elseif Command == "load" then
			print ("load")
			if BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Profiles[Argument] == nil then
				BarProfiler:Print("Error - Profile " .. Argument .. " not found")
			else
				BPFunc.Bars.Load("Profiles", Argument)
			end
		elseif Command == "forcecharupdate" then
			BPFunc.Initial.CharacterUpdate()
		elseif BarProfilerDb.GUI.Inhibit == nil then
			if BarProfilerSlashCount == 0 then
				BarProfilerSlashCount = 1
				BPFunc.GUI.Main.Frame()
			else
				BarProfilerSlashCount = 0
				BPFunc.GUI.Main.Close()
			end
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	NewRealm = function ()
		BarProfilerDb.Realms[BPTemp.CurrentRealm] =	{
			CharacterList = {},
			Characters = {}
		}
		table.insert (BarProfilerDb.RealmList, BPTemp.CurrentRealm)
	end,
-------------------------------------------------------------------------------------------------------------------------------------------	
	NewCharacter = function()
		BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter] = 	{
			ProfileList = {},
			Profiles = {},
			Version = "0.1.2"
		}
		BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Class = UnitClass("player")
		table.insert (BarProfilerDb.Realms[BPTemp.CurrentRealm].CharacterList, BPTemp.CurrentCharacter)
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	NameCheck = function (Key, ProfileName)	
	local test2
		if ProfileName == "" then
			test2 = 1
		end
		local test, test1 = string.find(ProfileName, "%s")
		if test == 1 or test1 == 1 or test2 == 1 then
			NewName = "[Error]:" .. ProfileName
			BarProfiler:Print ("Invalid Profile name found! Renaming it to:")
			print (NewName)
			BPTemp.Main.SelectedProfile = Key
			BPFunc.Profiles.Rename(NewName, true)
		end
	end
-------------------------------------------------------------------------------------------------------------------------------------------
}
BPFunc.General = {
	FindKey = function(Table, Value)
		for Key, ValueCheck in pairs(Table) do
			if ValueCheck == Value then
				return Key
			end
		end
	end
}