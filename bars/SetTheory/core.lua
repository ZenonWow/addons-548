SetTheory = LibStub("AceAddon-3.0"):NewAddon("SetTheory", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
SetTheory:RegisterChatCommand("settheory", 'ChatCommand')
local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

SetTheory.actions = {}
SetTheory.triggers = {}
SetTheory.tmp = {}

SetTheory.revision = "154"
SetTheory.version = "v0.6-release-MoPupdate"

local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

function SetTheory:OnInitialize()
	local defaults = {
		char = {
			print = true,
			respec = true,
			versionCheck = true,
			progress = true,
			hideSpellChanges = true,

			sets = {},
			firstRun = true,
			auto_action_id = 0,
		},
		global = {
			sets = {},
			higherRevision = false,
		}
	}

	self.db = LibStub("AceDB-3.0"):New("SetTheoryDB", defaults)

	if self.db.char.actionOrder then -- remove actionOrder and give actions ids.
		for s, set in pairs(self.db.char.actionOrder.sets) do
			local acts = {}
			for a, act in pairs(set) do
				local tbl = {
					id = act
				}
				for k, v in pairs(self.db.char.sets[s].actions[act]) do
					tbl[k] = v	
				end
				table.insert(acts, tbl)
			end
			self.db.char.sets[s].actions = acts
		end
		self.db.char.actionOrder = nil
		SetTheory:Print(L['Your sets have been upgraded to a new database format. However, you should check your sets for errors, especially in Ace Profile actions. You can use "/settheory opts resetDB" to reset the database.'])
	end

	if self.LoadTalentedAction then self:LoadTalentedAction() end -- Hack for Talented action, for some reason doing it the same as the other modules meant that SetTheoryDB disappeared (when LoadAddOn was called).
	self:RegisterOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SetTheory", self.options)
	self.blizOptions = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SetTheory")
end

function SetTheory:OnEnable()
	for s, _ in pairs(self.db.char.sets) do
		if not getglobal('SetTheorySelect'..self:SanitiseSetName(s)) then self:AddSetButton(s) end
	end
	stldb:Update()
end

function SetTheory:EnterWorld(evt)
	if self.db.char.firstRun then
		self.db.char.firstRun = false
		if next(self.db.global.sets) then 
			UIParent:Hide()
			self:PromptToActivateSet(L['First Run'], L['SetTheory has been run for the first time. Would you like to activate a global set now?'], self.db.global.sets, 0)
		end
	end
end
SetTheory:RegisterEvent("PLAYER_ENTERING_WORLD", "EnterWorld")

function SetTheory:ChatCommand(input)
	if not input or input:trim() == "" then LibStub("AceConfigDialog-3.0"):Open("SetTheory")
	else LibStub("AceConfigCmd-3.0"):HandleCommand('settheory', 'SetTheory', input) end
end

function SetTheory:OnTalentUpdate(event, ...)
	
	if GetNumUnspentTalents() == GetNumTalents() then
		if self.db.char.respec and next(self.db.char.sets) then self:PromptToActivateSet(L['Respec'], L["SetTheory has detected a respec. Would you like to apply a SetTheory set?"], self.db.char.sets, 10, true) end
	end
end
SetTheory:RegisterEvent("PLAYER_TALENT_UPDATE", "OnTalentUpdate")

function SetTheory:RegisterAction(action)
	self.actions[action.name] = action
end

function SetTheory:RegisterTrigger(trigger)
	self.triggers[trigger.name] = trigger
end

function SetTheory:CheckSetNameByString(name)
	if name == "" or name == nil then return L["Please choose a name for this set."] end
	for n,set in pairs(self.db.char.sets) do
		if name == n then return L["Please choose a unique name for this set"] end
	end
	return true
end

function SetTheory:SanitiseSetName(s)
	return s:gsub(' ', '_')
end
function SetTheory:AddSetByNameAndDesc(name, desc, actions, triggers)
	if type(self:CheckSetNameByString(name)) == "string" then return false end
	self.db.char.sets[name] = {
		name = name,
		desc = desc,
		actions = actions or {},
		triggers = triggers or {},
	}
	self:AddSetButton(name)
	self:UpdateOptionsTableSet(name, desc)
end

function SetTheory:RemoveSetByName(name)
	self.db.char.sets[name] = nil
	if name == self.db.char.active_set then self.db.char.active_set = nil end

	stldb:Update()
	self.options.args.sets.args[name] = nil
end

function SetTheory:CopySetByName(globalName, localName)
	local set = self.db.global.sets[globalName]
	local actions = self:CopyActionsTable(set.actions)
	local triggers = self:CopyActionsTable(set.triggers)
	self:AddSetByNameAndDesc(localName, set.desc, actions, triggers)
	for a, act in pairs(actions) do
		self:UpdateOptionsTableAction(localName, act.id, act.name)
	end
	self.db.char.sets[localName] = self:CopyDeepTable(self.db.global.sets[globalName])
end

function SetTheory:CopyActionsTable(t)
	local ret = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			ret[k] = self:CopyActionsTable(v)
		elseif k == 'id' then
			ret[k] = t['name'].."_"..self.db.char.auto_action_id
			self.db.char.auto_action_id = self.db.char.auto_action_id + 1
		else
			ret[k] = v
		end
	end
	return ret
end

function SetTheory:SetSetByName(tbl)
	local start = tbl.start or nil
	local set = tbl.set
	local profile = self.db.char
	local global = false
	if tbl.global then 
		profile = self.db.global
		global = true;
	end
	if not set then return false end

	self.working = true
	LibStub('AceConfigRegistry-3.0'):NotifyChange('SetTheory')
	stldb:Update()
	local waits, pastWait = tbl.waits or 0, tbl.pastWait or 0 
	if waits == 0 then waits = self:CalculateWait(profile.sets[set]) end

	if profile.hideSpellChanges then ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.FilterSpellChanges) end

	for a, act in pairs(profile.sets[set].actions) do
		if not start or start == a then 
			start = nil
			if self.actions[act.name] then
				if self.paused then 
					self:SelectStatus(L["Pausing the action sequence for X seconds"](self.paused))
					self:ScheduleTimer('SetSetByName', self.paused, {['set']=set,['start']=a, ['pastWait']=pastWait, ['waits']=waits, ['global']=global})
					self.paused = nil
					return
				end

				if self.db.char.progress then self:Progress((a + pastWait)*10, (#profile.sets[set].actions + waits)*10, self.actions[act.name].desc) end

				if self.actions[act.name].alreadySet and self.actions[act.name].alreadySet(act) then 
					if self.db.char.print then self:Print(L['Nothing to be done for action: ']..self.actions[act.name].desc..'('..a..')') end
					pastWait = pastWait + (self.actions[act.name].wait or 0)
				else
					local success, err = pcall(function() self.actions[act.name].set(act, waits, pastWait) end)
					if not success and debug then error(err) end

					if type(self.actions[act.name].wait) == 'number' then 
						self:Pause(self.actions[act.name].wait, self.actions[act.name].desc) 
						pastWait = pastWait + self.actions[act.name].wait
					elseif act.name == 'SetTheory_Wait' then
						pastWait = pastWait + act.wait
					end
				end
			end
		end
	end
	self.db.char.active_set = set 
	self.working = false
	LibStub('AceConfigRegistry-3.0'):NotifyChange('SetTheory')
	self.paused = false
	stldb:Update()
	if self.db.char.hideSpellChanges then ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.FilterSpellChanges) end
end

function SetTheory:CalculateWait(set)
	local waits = 0
	if set.actions == nil then return waits end

	for a, act in pairs(set.actions) do
		if self.actions[act.name] then
			if self.actions[act.name].wait and not (self.actions[act.name].alreadySet and self.actions[act.name].alreadySet(act)) then
				if type(self.actions[act.name].wait) == 'number' then waits = waits + self.actions[act.name].wait
				elseif type(self.actions[act.name].wait) == 'function' then waits = waits + self.actions[act.name].wait(act) end
			end
		end
	end

	return waits
end

function SetTheory:CreateSecureButton(name, texture, opts)
	local f = _G[name] or CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate, ActionButtonTemplate")
	
	f.icon = _G[name ..'Icon']
	f.icon:SetTexture(texture)

	for key,val in pairs(opts) do f:SetAttribute(key,val) end


	f:SetPoint('CENTER', 0,0)
	f:Show()
	return f
end

function SetTheory:AssociateSpec(name)
	if GetNumTalentGroups() > 1 then
		for s, set in pairs(self.db.char.sets) do
			for a, act in pairs(set.actions) do
				if act.name == 'SetTheory_DualSpec' then
					if self.db.char.sets[s].actions[a].spec == GetActiveTalentGroup() then
						self:RemoveActionFromSetByName(s, act.id)
					end
				end
			end
		end

		self:AddActionToSetByName(name, 'SetTheory_DualSpec', 1)
		self.db.char.sets[name].actions[1].spec = GetActiveTalentGroup()
		LibStub('AceConfigRegistry-3.0'):NotifyChange('SetTheory')
	end
end

function SetTheory:AddSetButton(s)
	local i = 1
	for name, set in pairs(self.db.char.sets) do
		if name == s then break end
		i=i+1
	end

	s = self:SanitiseSetName(s)
	local btn = CreateFrame('Button', 'SetTheorySelect'..tostring(i), UIParent, "SecureActionButtonTemplate")
	if not btn then 
		SetTheory:Print('No button: SetTheorySelect'..tostring(i))
	else
		btn:SetAttribute('type', 'macro')
		btn:SetAttribute('macrotext', '/settheory sets '..s..' select')
	end
end

function SetTheory:Pause(time, act)
	self.paused = time
	if self.db.char.progress then self:UpdateProgressTime({action=act, secs=time}) end
end

function SetTheory:GetAvailableActions()
	local actions = {}
	for a, act in pairs(self.actions) do
		actions[a] = act.desc
	end
	return actions;
end

function SetTheory:GetAvailableTriggers()
	local triggers = {}
	for t, trig in pairs(self.triggers) do
		triggers[t] = trig.name
	end
	return triggers
end

function SetTheory:AddActionToSetByName(set, action, index)
	if index then table.insert(self.db.char.sets[set].actions, index, {name=action, id=action.."_"..self.db.char.auto_action_id})
	else table.insert(self.db.char.sets[set].actions, {name=action, id=action.."_"..self.db.char.auto_action_id}) end
	if self.actions[action].defaults then
		for k,v in pairs(self.actions[action].defaults) do
			local index = index or #self.db.char.sets[set].actions
			self.db.char.sets[set].actions[index][k] = v
		end
	end
	self:UpdateOptionsTableAction(set, action..'_'..self.db.char.auto_action_id, action)
	self.db.char.auto_action_id = self.db.char.auto_action_id + 1
end

function SetTheory:AddTriggerToSetByName(set, trigger, index)
	if index then table.insert(self.db.char.sets[set].triggers, index, {name=trigger})
	else table.insert(self.db.char.sets[set].triggers, {name=trigger}) end
	
	if self.triggers[trigger].defaults then
		for k,v in pairs(self.triggers[trigger].defaults) do
			local index = index or #self.db.char.sets[set].triggers
			self.db.char.sets[set].triggers[index][k] = v
		end
	end
end

function SetTheory:RemoveActionFromSetByName(set, id)
	table.remove(self.db.char.sets[set].actions, self:GetActionIndexById(set, id))
	self.options.args.sets.args[set].args.actions.args[id] = nil
end
	
function SetTheory:SetActionOptionByName(set, id, element, value)
	self.db.char.sets[set].actions[self:GetActionIndexById(set, id)][element] = value
end

function SetTheory:GetActionOptionByName(set, id, element)
	return self.db.char.sets[set].actions[self:GetActionIndexById(set, id)][element]
end

function SetTheory:GetActionIndexById(set, id)
	for a, act in pairs(self.db.char.sets[set].actions) do
		if act.id == id then return a end
	end
end

function SetTheory:GetSets()
	local sets = {}
	local count = 0
	for set  in pairs(self.db.char.sets) do
		sets[set] = set	
		count = count + 1
	end
	return sets, count
end

function SetTheory:GetGlobalSets()
	local sets = {}
	local count = 0
	for set in pairs(self.db.global.sets) do
		sets[set] = set
		count = count + 1
	end

	return sets, count 
end

function SetTheory:SelectStatus(msg)
	if msg and self.db.char.print then SetTheory:Print(msg) end
end

function SetTheory:FilterSpellChanges(evt, msg)
	if msg:match(ERR_LEARN_ABILITY_S:gsub('%%s', '.*')) or
		msg:match(ERR_LEARN_SPELL_S:gsub('%%s', '.*')) or
		msg:match(ERR_PET_LEARN_ABILITY_S:gsub('%%s', '.*')) or
		msg:match(ERR_PET_LEARN_SPELL_S:gsub('%%s', '.*')) or
		msg:match(ERR_SPELL_UNLEARNED_S:gsub('%%s', '.*')) or
		msg:match(ERR_PET_SPELL_UNLEARNED_S:gsub('%%s', '.*')) then
			return true;
	end
end

function SetTheory:dump(...)
	if not debug then return end
	local vars = {...}
	local loaded = IsAddOnLoaded('Blizzard_DebugTools')

	for i=1,#vars do
		if not loaded then
			if IsAddOnLoadOnDemand('Blizzard_DebugTools') then LoadAddOn('Blizzard_DebugTools') end
			loaded = true
		end
		DevTools_Dump(vars[i])
	end	
end

