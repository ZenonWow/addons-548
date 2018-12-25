local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

local st = {};
st.name = 'SetTheory_SetTheorySet'
st.desc = L["SetTheory Set"]

st.wait = function(act)
	local set = st.findSet(act.set)
	if set then return SetTheory:CalculateWait(set)
	else print('no set: '.. act.name); return 0 end
end

st.set = function(opts)
	local set, isGlobal = st.findSet(opts.set)
	if set then SetTheory:SetSetByName({['set']=set.name, global=isGlobal})
	else print('no set: '.. opts.set) end
end

st.findSet = function(name)
	--find set, prefering local
	local sets = SetTheory.db.char.sets
	for s,set in pairs(sets) do
		if s == name then return set end
	end
	
	sets = SetTheory.db.global.sets
	for s,set in pairs(sets) do
		if s == name then return set, true end
	end
end

st.values = function()
	local menu = {}
	local sets = SetTheory:GetSets()
	local globalSets = SetTheory:GetGlobalSets()
	
	for s,set in pairs(globalSets) do
		menu[s] = s
	end

	for s,set in pairs(sets) do --Prefer local sets when same-name sets collide...
		menu[s] = s
	end
	return menu
end

st.opts = {
	type='group',
	name = L['SetTheory Set'],
	handler = SetTheory,
	args = {
		set = {
			name = L['Set Name'],
			order = 0,
			type = 'select',
			values = st.values,
			set = "SetActionOption",
			get = "GetActionOption",
		}
	}
}

SetTheory:RegisterAction(st)
 
