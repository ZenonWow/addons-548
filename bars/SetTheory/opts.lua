local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)
local constantSetSelect = {
	name = L["Select Set"],
	type = "execute",
	desc = L["Selects this set"],
	order = 100,
	func = "SetSet",
	disabled = function() if SetTheory.working then return true else return false end end
}
local constantSetRemove = {
	type = "execute",
	name = L["Remove Set"],
	confirm = true,
	confirmText = L["Confirm remove set"],
	func = "RemoveSet",
	disabled = function() if SetTheory.working then return true else return false end end,
	order = 110,
}
local constantSetBind = {
	name = L["Keybind"],
	desc = L["Binds this set to a key"],
	type = 'keybinding',
	set = 'SetSetKeybind',
	get = 'GetSetKeybind',
	order = 120,
}
local constantSetPublish = {
	type = "execute",
	name = L["Publish set"],
	desc = L["This will make the set globally accessible. This is useful if you want to share a set with other characters on your account or if you intend to publish your interface for others to use."],
	order = 130,
	func = function(i, v) SetTheory.db.global.sets[i[#i-1]] = SetTheory.db.char.sets[i[#i-1]] end
}
local constantPossibleActions = {
	name = L["Possible actions"],
	desc = L["Available actions"],
	type = "select",
	values = "GetAvailableActions",
	order = 0,
}
local constantAddAction = {
	name = L["Add Action"],
	desc = L["Adds and action"],
	type = "execute",
	order = 10,
	func = "AddActionToSet",
	disabled = function(i, v) if SetTheory.tmp.possibleActions then return false else return true end end
}
local constantPossibleTriggers = {
	name = L["Possible triggers"],
	desc = L["Available triggers"],
	type = "select",
	values = "GetAvailableTriggers",
	order = 0,
}
local constantAddTrigger = {
	name = L["Add Trigger"],
	desc = L["Adds and trigger"],
	type = "execute",
	order = 10,
	func = "AddTriggerToSet",
	disabled = function(i, v) if SetTheory.tmp.possibleTriggers then return false else return true end end
}

local constantActionRemoveNL = {
	name = "",
	type = "description",
	order = 9999
}
local constantActionRemoveAction = {
	name = L["Remove action"],
	desc = L["Removes this action from this set"],
	type = "execute",
	func = "RemoveActionFromSet",
	order = 10000,
}
local constantActionChangePriority = {
	name = L["Change action priority:"],
	type = "description",
	order = 10001,
}
local constantActionOrderUp = {
	name = L["+"],
	desc = L["Move this action up in priority"],
	width = "half",
	type = "execute",
	func = "MoveActionOrder",
	order = -1,
	disabled = function(i, v) if SetTheory.db.char.sets[i[#i-3]].actions[1].id == i[#i-1] then return true else return false end end
}
local constantActionOrderDown = {
	name = L["-"],
	desc = L["Move this action down in priority"],
	width = "half",
	type = "execute",
	func = "MoveActionOrder",
	order = -1,
	disabled = function(i, v) if SetTheory.db.char.sets[i[#i-3]].actions[#SetTheory.db.char.sets[i[#i-3]].actions].id == i[#i-1] then return true else return false end end
}

function SetTheory:RegisterOptions()
	self.options = {
		name = L["SetTheory Options"],
		icon = "Interface\\GossipFrame\\HealerGossipIcon",
		type = "group",
		handler = SetTheory,
		args = {
			sets = {
				name = L["Sets"],
				type = "group",
				get = "GetTmp",
				set = "SetTmp",
				args = {
					addHeader = {
						type = 'header',
						name = L["Add a New Set"],
						order = 80,
					},
					txt = {
						type = "description",
						name = L["SetTheoryDesc"],
						order = 90,
					},
					setName = {
						name = L["Set Name"],	
						type = "input",
						desc = L["The name of the set"],
						validate = "CheckSetName",
						order = 100,
					},
					setDesc = {
						name = L["Set Description"],
						type = "input",
						width = "full",
						multiline = true,
						order = 110,
					},
					addSet = {
						name = L["Add Set"],
						type = "execute",
						func = "AddSet",
						order = 120,
						disabled = function(i, v) if type(self:CheckSetNameByString(self.tmp.setName)) == "string" then return true else return false end end
					},
					globalSetNL = {
						type = 'header',
						name = L["Global Sets"],
						order = 125,
						hidden = function() return select(2, self:GetGlobalSets()) == 0 end
					},
					globalSetDesc = {
						type = "description",
						name = L["You can also copy in a set from an external source (your other characters or from interface compilations)"],
						order = 130,
						hidden = function() return select(2, self:GetGlobalSets()) == 0 end
					},
					globalSet = {
						name = L["Global Set"],
						desc = L["Select a set you'd like to copy into your current character's set collection."],
						type = "select",
						values = "GetGlobalSets",
						order = 140,
						hidden = function() return select(2, self:GetGlobalSets()) == 0 end
					},
					globalSelectSet = {
						name = L["Select Set"],
						type = "execute",
						desc = L["Selects this set"],
						order = 142,
						func = function(i,v)
							i[#i] = 'globalSet'
							local set = self:GetTmp(i)
							self:SetSetByName({['set']=set, global=true})
						end,
						hidden = function(i,v) return select(2, self:GetGlobalSets()) == 0 end,
						disabled = function(i,v)
							if SetTheory.working then return true end

							i[#i] = 'globalSet'
							local set = self:GetTmp(i)
							return set == nil
						end
					},
					globalSetName = {
						name = L["New name"],
						desc = L["Choose a new name for this set"],
						type = "input",
						order = 145,
						validate = "CheckSetName",
						hidden = function(i) 
							if select(2, self:GetGlobalSets()) == 0 then return true end
							i[#i] = 'globalSet'
							local set = self:GetTmp(i)
							if set == nil then return true end
							if type(self:CheckSetNameByString(set)) == 'string' then return false else return true 
							end 
						end
					},
					copySet = {
						name = L["Copy Set"],
						desc = L["Copies the selected set into your current character's set collection."],
						type = "execute",
						order = 150,
						func = "CopySet",
						hidden = function() return select(2, self:GetGlobalSets()) == 0 end,
						disabled = function(i, v) 
							i[#i] = 'globalSet'
							local set = self:GetTmp(i)
							i[#i] = 'globalSetName'
							if type(self:CheckSetNameByString(set)) == 'string' then
								if type(self:CheckSetNameByString(self:GetTmp(i))) == 'string' then return true 
								else return false end
							else return false end
						end
					}
				}
			},
			opts = {
				name = L["Options"],
				type = "group",
				get = "GetOption",
				set = "SetOpt",
				get = "GetOpt",
				order = -1,
				args = {
					print = {
						name = L["Print messages"],
						desc = L["Print out status messages when selecting a set."],
						type = "toggle",
					},
					hideSpellChanges = {
						name = L["Hide spell changes"],
						desc = L["Hide chat messages about lost or gained spells while processing a SetTheory set."],
						type = "toggle",
					},
					progress = {
						name = L["Show progress bar"],
						desc = L["Displays a progress bar when you switch to a new set."],
						type = "toggle",
					},
					respec = {
						name = L["Respec prompt"],
						desc = L["Prompt to select a new set when you respec"],
						type = "toggle"
					},
					resetDB = {
						name = L["Reset Database"],
						desc = L["Removes all of your defined sets and returns the options back to their default states."],
						type = "execute",
						confirm = true,
						confirmText = L["Are you sure you wish to reset your database?"],
						func = function() 
							for s in pairs(self.db.char.sets) do
								self:RemoveSetByName(s)
							end
							self.db:ResetDB()
							LibStub('AceConfigRegistry-3.0'):NotifyChange('SetTheory')
						end,
						order = -1,
					}
				}
			}
		}
	}
	if self.db.char.sets then
		for n, set in pairs(self.db.char.sets) do 
			self:UpdateOptionsTableSet(n, set.desc) 
			if not set.actions then break end
			for a, act in pairs(set.actions) do
				self:UpdateOptionsTableAction(n, act.id, act.name)
			end
		end
	end

	--[[if self.db.global.sets then
		for n, set in pairs(self.db.global.sets) do 
			self:UpdateOptionsTableSet(n, set.desc, self.db.global) 
			if not set.actions then break end
			for a, act in pairs(set.actions) do
				self:UpdateOptionsTableAction(n, act.id, act.name, self.db.global)
			end
		end
	end]]
end

function SetTheory:UpdateOptionsTableSet(n, d)--, tbl)
	if not d and self.db.char.sets[n].desc then d = self.db.char.sets[n].desc or "" end

	self.options.args.sets.args[n] = {
		type ='group', 
		name = n,
		desc = d or "",
		childGroups = "tab",
		args={
			setDesc = {
				type = "description",
				name = d or "",
				order = 0,
			},	
			actions = {
				name = L["Actions"],
				type = "group",
				order = 10,
				get = "GetTmp",
				set = "SetTmp",
				args = {
					possibleActions = constantPossibleActions,
					addAction = constantAddAction, 
				},
			},
			--[[triggers = {
				name = L["Triggers"],
				type = "group",
				order = 20,
				get = "GetTmp",
				set = "SetTmp",
				args = {
					possibleTriggers = constantPossibleTriggers,
					addTrigger = constantAddTrigger,
				}
			},]]--
			select = constantSetSelect,
			remove = constantSetRemove,
			bind = constantSetBind,
			publish = constantSetPublish,
		}
	}
	self.options.args.sets.args[n].args.macro = {
		type = 'description',
		name = L["Select macro"] .. "\n/settheory sets ".. self:SanitiseSetName(n).. " select",
		order = 130,
	}
end

function SetTheory:UpdateOptionsTableAction(n, a, name)
	if not self.actions[name] then return false end
	self.options.args.sets.args[n].args.actions.args[a] = self.actions[name].opts or {}
	self.options.args.sets.args[n].args.actions.args[a].order = 'GetActionOrder'
	self.options.args.sets.args[n].args.actions.args[a].args.removeNL = constantActionRemoveNL 
	self.options.args.sets.args[n].args.actions.args[a].args.removeAction = constantActionRemoveAction
	self.options.args.sets.args[n].args.actions.args[a].args.orderDesc = constantActionChangePriority
	self.options.args.sets.args[n].args.actions.args[a].args.orderUp = constantActionOrderUp
	self.options.args.sets.args[n].args.actions.args[a].args.orderDown = constantActionOrderDown
end

function SetTheory:SetOpt(i, v)
	self.db.char[i[#i]] = v
end

function SetTheory:GetOpt(i)
	return self.db.char[i[#i]]
end

function SetTheory:GetSetKeybind(i)
	local set = 1
	for name in pairs(self.db.char.sets) do
		if name == i[#i-1] then break end
		set=set+1
	end
	LoadBindings(GetCurrentBindingSet())
	return GetBindingKey("CLICK "..'SetTheorySelect'..tostring(set)..':LeftButton')
end

function SetTheory:SetSetKeybind(i, v)
	local set = 1
	for name in pairs(self.db.char.sets) do
		if name == i[#i-1] then break end
		set=set+1
	end

	--clear previous
	local bindings = {self:GetSetKeybind(i)}
	for i=1,#bindings do
		SetBinding(bindings[i], nil)
	end
	
	if v ~= "" then
		SetBindingClick(v, 'SetTheorySelect'..tostring(set))
	end
	SaveBindings(GetCurrentBindingSet())
end

function SetTheory:SetTmp(i,v)
	self.tmp[i[#i]] = v
end

function SetTheory:GetTmp(i)
	return self.tmp[i[#i]] 
end

function SetTheory:CheckSetName(i, v)
	if not v or not i then return "" end
	return self:CheckSetNameByString(v)
end

function SetTheory:AddSet(i, v)
	self:AddSetByNameAndDesc(self.tmp.setName, self.tmp.setDesc)
	self.tmp = {}
end

function SetTheory:RemoveSet(i, v)
	self:RemoveSetByName(i[#i-1])
end

function SetTheory:CopySet(i, v)
	i[#i] = 'globalSet'
	local globalName = self:GetTmp(i)
	i[#i] = 'globalSetName'
	local localName = self:GetTmp(i) or globalName
	self:CopySetByName(globalName, localName) 
	self:SetTmp(i, nil)
end

function SetTheory:SetSet(i,v)
	tbl = {
		set = i[#i-1],
	}
	self:SetSetByName(tbl)
end

function SetTheory:AddActionToSet(i, v)
	self:AddActionToSetByName(i[#i-2], self.tmp.possibleActions)
end

function SetTheory:AddTriggerToSet(i, v)
	self:AddTriggerToSetByName(i[#i-2], self.tmp.possibleTriggers)
end

function SetTheory:RemoveActionFromSet(i, v)
	self:RemoveActionFromSetByName(i[#i-3], i[#i-1])
end

function SetTheory:GetActionOrder(i, v)
	local order = 1
	for k, action in pairs(self.db.char.sets[i[#i-2]].actions) do
		if action.id == i[#i] then 
			order = k
			break
		end
	end
	return order
end

function SetTheory:MoveActionOrder(i, v)
	for k, action in pairs(self.db.char.sets[i[#i-3]].actions) do
		if action.id == i[#i-1] then
			if i[#i] == 'orderUp' then destination = k-1
			elseif i[#i] == 'orderDown' then destination = k+1 end
			if self.db.char.sets[i[#i-3]].actions[destination] then
				self.db.char.sets[i[#i-3]].actions[destination], self.db.char.sets[i[#i-3]].actions[k] = self.db.char.sets[i[#i-3]].actions[k], self.db.char.sets[i[#i-3]].actions[destination]
				break
			end
		end
	end
end

function SetTheory:SetActionOption(i, v)
	self:SetActionOptionByName(i[#i-3], i[#i-1], i[#i], v)
end

function SetTheory:GetActionOption(i)
	return self:GetActionOptionByName(i[#i-3], i[#i-1], i[#i])
end
