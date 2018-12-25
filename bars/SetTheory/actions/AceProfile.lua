local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if SetTheory then
	local ace = {};
	ace.name = "SetTheory_AceProfiles"
	ace.desc = L["Ace Profiles"]

	local findGlobal = _G.setmetatable({}, {__index=function(self, object)
		for k,v in pairs(_G) do
			if v == object then
				k = tostring(k)
				self[v] = k
				return k
			end
		end
		self[object] = false
		return false
	end})

	function ace.set(opts)
		if not opts.addon and not opts.profile then return end
		db = getAceDBFromSV(opts.addon)
		if not db then return false end
		db:SetProfile(opts.profile) 
		SetTheory:SelectStatus(L['Setting Ace profile for X to Y'](opts.addon or opts.dbobject, opts.profile))
	end

	function aceAddons()
		local ret = {}
		for db in pairs(LibStub('AceDB-3.0').db_registry) do
			if not db.parent then
				local g = findGlobal[db.sv]
				if g then ret[g] = g end
			end
		end

		Ace2 = LibStub:GetLibrary('AceDB-2.0', true)
		if Ace2 then
			for db in pairs(LibStub('AceDB-2.0').registry) do
				ret[db.db.name] = db.db.name
			end
		end

		if Rock and Rock:HasLibrary('LibRockDB-1.0') then
			local RockDB = Rock:GetLibrary("LibRockDB-1.0", false, false)
			if RockDB and RockDB.data then
				for db in pairs(RockDB.data) do
					local g = findGlobal[db.db.raw]
					if g then ret[g] = g end
				end
			end
		end
		return ret
	end

	function getAceDBFromSV(s)
		for db in pairs(LibStub('AceDB-3.0').db_registry) do
			if not db.parent then
				local g = findGlobal[db.sv]
				if g == s then return db, 'ace3' end
			end
		end

		Ace2 = LibStub:GetLibrary('AceDB-2.0', true)
		if Ace2 then
			for db in pairs(LibStub('AceDB-2.0').registry) do
				if s == db.db.name then return db, 'ace2' end
			end
		end

		if Rock and Rock:HasLibrary('LibRockDB-1.0') then
			local RockDB = Rock:GetLibrary("LibRockDB-1.0", false, false)
			if RockDB and RockDB.data then
				for db in pairs(RockDB.data) do
					local g = findGlobal[db.db.raw]
					if g == s then return db, 'rock' end
				end
			end
		end	
		return false
	end

	function aceProfiles(i, v)
		i[#i] = 'addon'
		db, framework = getAceDBFromSV(SetTheory:GetActionOption(i))
		if not db then return {} end

		local profiles = {}
		if framework == 'ace3' and db.GetProfiles then profiles = db:GetProfiles() 
		elseif framework == 'ace2' or framework == 'rock' then
			if db.db.raw.profiles then
				for p in pairs(db.db.raw.profiles) do
					table.insert(profiles, detectSpecialProfiles(p))
				end
			end
			if db.db.raw.namespaces then 
				for _,n in pairs(db.db.raw.namespaces) do
					if n.profiles then 
						for p in pairs(n.profiles) do
							table.insert(profiles, detectSpecialProfiles(p))
						end
					end
				end
			end
			local curProfile = db:GetProfile()
			table.insert(profiles, curProfile) 
		end

		local ret = {}
		for k=1,#profiles do
			ret[profiles[k]] = profiles[k]
		end
		return ret 
	end

	function detectSpecialProfiles(s)
		slow = s:lower()
		local patterns = {'char', 'class', 'realm'}

		for i=1,#patterns do
			if slow:match('^'..patterns[i]..'/') then slow = patterns[i] end
		end
		if s:lower() ~= slow then return slow else return s end
	end

	function aceDBExists(i, v)
		if getAceDBFromSV(v) then return true else return L["No Ace database here"] end
	end

	ace.opts = {
		type = "group",
		name = L["Ace Profiles"],
		handler = SetTheory,
		set = "SetActionOption",
		get = "GetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which addon's profile you'd like to use"],
				order = 0,
			},
			addon = {
				name = L["Ace Addon"],
				desc = L["Auto-detected Ace addon databases"],
				type = "select",
				values = aceAddons,
				validate = aceDBExists,
			},
			profile = {
				name = L["Profile"],
				desc = L["The profile you'd like to select"],
				type = "select",
				values = aceProfiles,
			},
		}
	}

	SetTheory:RegisterAction(ace)
end
