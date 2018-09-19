
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I
local be_ids_db = {}

-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "IDs"
local ldbName = name
local scanTooltip = CreateFrame("GameTooltip",addon.."_"..name.."_ScanTooltip",UIParent,"GameTooltipTemplate")
scanTooltip:SetScale(0.0001)
scanTooltip:Hide()
local player, tt, tt2, tt3, counter
local numDungeons, numRaids, numLFR, numFlex, numChallenges, numBosses, numUnknown = 0,0,0,0,0,0
local dungeons,    raids,    lfr,    flex,    challenges,    bosses,    unknown    = {},{},{},{},{},{},{}
local instances = {}


---------------------------------------
-- module variables for registration --
---------------------------------------
I[name] = {iconfile=[[interface\icons\inv_misc_pocketwatch_02]],coords={0.05,0.95,0.05,0.95}}

ns.modules[name] = {
	desc = L["-"],
	events = {
		--"CALENDAR_ACTION_PENDING",
		--"CALENDAR_CLOSE_EVENT",
		"CALENDAR_EVENT_ALARM",
		"CALENDAR_NEW_EVENT",
		"CALENDAR_OPEN_EVENT",
		"CALENDAR_UPDATE_EVENT",
		"CALENDAR_UPDATE_EVENT_LIST",
		"CALENDAR_UPDATE_GUILD_EVENTS",
		"CALENDAR_UPDATE_INVITE_LIST",
		"CALENDAR_UPDATE_PENDING_INVITES",
		"PLAYER_ENTERING_WORLD"
	},
	updateinterval = 10,
	timeout = 20,
	timeout_used = false,
	timeout_args = nil,
	config_defaults = {},
	config_allowed = {},
	config = nil
}


--------------------------
-- some local functions --
--------------------------
local function preScan()
	if be_ids_db[ns.realm]==nil then be_ids_db[ns.realm]={} end
	if be_ids_db[ns.realm][ns.player.name]==nil then be_ids_db[ns.realm][ns.player.name]={} end
	for i,v in ipairs({"bosses","dungeons","challenges","raids","lfr","flex"}) do
		
	end
end


local function addInstance(instanceDifficulty,data)
	if instanceDifficulty<=2 then
		dungeons[data.instanceName] = data
		numDungeons = numDungeons+1
	elseif instanceDifficulty==8 then
		challenges[data.instanceName] = data
		numChallenges = numChallenges+1
	elseif instanceDifficulty<=9 then
		raids[data.instanceName] = data
		numRaids = numRaids+1
	else
		numUnknown = numUnknown+1
		unknown[data.instanceName] = data
	end
end

local function scanInstances()
	numDungeons, numRaids, numChallenges, numUnknown = 0,0,0,0
	local data
	for i=1, GetNumSavedInstances() do
		local instanceName, instanceID, instanceReset, instanceDifficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)

		if instanceDifficulty~=nil and instanceReset>0 then
			scanTooltip:Show()
			scanTooltip:SetOwner(UIParent,"LEFT",0,0)
			scanTooltip:SetInstanceLockEncountersComplete(i)
			local reg,data,line = {scanTooltip:GetRegions()},{},1
			local n,nc
			for k,v in pairs(reg) do
				if v~=nil and v:GetObjectType()=="FontString" and v:GetText()~=nil then
					if line>1 then
						if line/2==floor(line/2) then
							n = v:GetText()
						else
							tinsert(data,{n,({v:GetTextColor()})[0]~=0})
						end
					end
					line = line + 1
				end
			end
			scanTooltip:ClearLines()
			scanTooltip:Hide()

			if instances[instanceDifficulty]==nil then instances[instanceDifficulty]={} end

			data = {
				instanceName		= instanceName,
				instanceReset		= instanceReset,
				extended			= extended,
				maxPlayers			= maxPlayers,
				difficultyName		= difficultyName,
				numEncounters		= numEncounters~=0 and numEncounters or "a",
				encounterProgress	= numEncounters~=0 and encounterProgress or "n",
				encounters			= data
			}
			addInstance(instanceDifficulty,data)
			instances[instanceDifficulty][instanceID] = data
		end
	end
	if numUnknown>0 then
		ns.print("(Module:",name,")", numUnknown, "unknown Instances found")
	end
end

local function scanBosses()
	bosses = {}
	local i,n,id,r = 0,nil,nil,nil
	repeat
		i=i+1
		n,id,r = GetSavedWorldBossInfo(i)
		if n~=nil and type(r)=="number" and r>0 then
			bosses[n] = {name=n,id=id,reset=r,bonus=false}
			numBosses = numBosses + 1
		end
	until n==nil
end

local function scanFlex()
	numFlex = 0
	-- ?
end

local function GetEntries(self, objType, obj)
	local l,c,_,setup
	local count, cells = 0,4

	tt:AddSeparator(3,0,0,0,0)

	if objType=="b" then

	elseif objType=="i" then
		tt:AddLine(
			C("dkyellow",
				(obj=="wb" and "World bosses")        or
				(obj=="ra" and "Raids")               or
				(obj=="rb" and "Raids (LFR)")         or
				(obj=="rf" and "Raids (Flex)")        or
				(obj=="du" and "Dungeons")            or
				(obj=="cm" and "Challenge mode")      or
				"Unknown"
			),
			C("ltblue",L["Type"]),
			C("ltblue",L["Bosses"]),
			C("ltblue",L["Reset in"])
		)
		tt:AddSeparator()

		local selection = ( (obj=="ra" and {3,4,5,6,7,9}) or
							(obj=="du" and {1,2}) or
							(obj=="cm" and {8}) or
							{} )

		for _,I in ipairs(selection) do
			if type(instances[I])=="table" then
				for i,v in pairs(instances[I]) do
					tt:AddLine(C("ltyellow",v.instanceName),v.difficultyName,("%s/%s"):format(v.encounterProgress,v.numEncounters),SecondsToTime(v.instanceReset))
					count=count+1
				end
			end
		end
		if count==0 then
			tt:AddLine(L["Nothing found..."])
		end
	end
end

local function makeTooltip()
	if not (tt~=nil and tt.key~=nil and tt.key==name.."TT") then return end
	local l,c
	local nothing = true

	scanInstances()
	scanBosses()
	--scanFlex()

	tt:Clear()

	tt:AddHeader(C("dkyellow",L[name]))

	if numBosses>0 then
		tt:AddSeparator(3,0,0,0,0)
		tt:AddLine(C("dkyellow",L["World bosses"]),"","",C("ltblue",L["Reset in"]))
		tt:AddSeparator()

		for i,v in pairs(bosses) do
			tt:AddLine(C("ltyellow",v.name),"","",SecondsToTime(v.reset))
		end
		nothing = false
	end

	if numDungeons>0 then
		tt:AddSeparator(3,0,0,0,0)
		tt:AddLine(C("dkyellow",L["Dungeons"]),C("ltblue",L["Type"]),C("ltblue",L["Bosses"]),C("ltblue",L["Reset in"]))
		tt:AddSeparator()
		for i,v in pairs(dungeons) do
			tt:AddLine(C("ltyellow",v.instanceName),v.difficultyName,("%s/%s"):format(v.encounterProgress,v.numEncounters),SecondsToTime(v.instanceReset))
		end
		nothing = false
	end

	if numChallenges>0 then
		tt:AddSeparator(3,0,0,0,0)
		tt:AddLine(C("dkyellow",L["Challenge mode"]),C("ltblue",L["Type"]),C("ltblue",L["Bosses"]),C("ltblue",L["Reset in"]))
		tt:AddSeparator()
		for i,v in pairs(challenges) do
			tt:AddLine(C("ltyellow",v.instanceName),v.difficultyName,("%s/%s"):format(v.encounterProgress,v.numEncounters),SecondsToTime(v.instanceReset))
		end
		nothing = false
	end

	if numRaids>0 then
		tt:AddSeparator(3,0,0,0,0)
		tt:AddLine(C("dkyellow",L["Raids"]),C("ltblue",L["Type"]),C("ltblue",L["Bosses"]),C("ltblue",L["Reset in"]))
		tt:AddSeparator()
		for i,v in pairs(raids) do
			tt:AddLine(C("ltyellow",v.instanceName),v.difficultyName,("%s/%s"):format(v.encounterProgress,v.numEncounters),SecondsToTime(v.instanceReset))
		end
		nothing = false
	end

	if numLFR>0 then
		tt:AddSeparator(3,0,0,0,0)
		tt:AddLine(C("dkyellow",L["Raids (LFR)"]),C("ltblue",L["Type"]),C("ltblue",L["Bosses"]),C("ltblue",L["Reset in"]))
		tt:AddSeparator()
		for i,v in pairs(lfr) do
			tt:AddLine(C("ltyellow",v.instanceName),v.difficultyName,("%s/%s"):format(v.encounterProgress,v.numEncounters),SecondsToTime(v.instanceReset))
		end
		nothing = false
	end

	if numFlex>0 then
		tt:AddSeparator(3,0,0,0,0)
		tt:AddLine(C("dkyellow",L["Raids (Flex)"]),C("ltblue",L["Type"]),C("ltblue",L["Bosses"]),C("ltblue",L["Reset in"]))
		tt:AddSeparator()
		for i,v in pairs(flex) do
			tt:AddLine(C("ltyellow",v.instanceName),v.difficultyName,("%s/%s"):format(v.encounterProgress,v.numEncounters),SecondsToTime(v.instanceReset))
		end
		nothing = false
	end

	if nothing==true then
		tt:AddLine("No IDs found...")
	end
end


------------------------------------
-- module (BE internal) functions --
------------------------------------
ns.modules[name].init = function(obj)
	ldbName = (Broker_EverythingDB.usePrefix and "BE.." or "")..name
end

ns.modules[name].onevent = function(self,event,...)
end

ns.modules[name].onupdate = function(self)
	if tt~=nil and tt.key==name.."TT" then
		makeTooltip(tt)
	end
end

--[[ ns.modules[name].optionspanel = function(panel) end ]]

--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

--[[ ns.modules[name].ontooltip = function(tooltip) end ]]


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
ns.modules[name].onenter = function(self)
	tt = ns.LQT:Acquire(name.."TT", 4, "LEFT", "LEFT", "LEFT", "RIGHT")
	makeTooltip(tt)
	ns.createTooltip(self, tt)
end

ns.modules[name].onleave = function(self)
	if tt then 
		ns.hideTooltip(tt,name)
	end
end

--[[ ns.modules[name].onclick = function(self,button) end ]]

--[[ ns.modules[name].ondblclick = function(self,button) end ]]




--[=[

be_ids_db [table]
	<realm [table]>
		<char [table]>
			nBosses [number]
			bosses [table]
				<name [table]>
					<id [number]>
					<reset [number]>
					<extended [bool]> ?
					<bonusloot [bool]>

			nDungeons [number]
			dungeons
				<name [table]>
					<id [number]>
					<reset [number]>
					<extended [bool]>
					<difficultyName [string]>
					<numEncounters [number]>
					<maxEncounters [number]>
					<encounters [table]>
						<name [table]>
							<bonusloot [boolean]>

			nChallenges [number]
			challenges
				{see dungeons}

			nRaids [number]
			raids/myths
				{see dungeons}

			nLFR [number]
			lfr
				{see dungeons}

			nFlex [number]
			flex
				{see dungeons}


all tables (bosses, dungeons etc...) crawled and add set [reset] to false befor start a new scan
after the scan a second run through the table remove all entries with reset==false

]=]