local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if TrinketMenu and SetTheory then
	local tm = {};
	tm.name = "SetTheory_TrinketMenu"
	tm.desc = L["TrinketMenu"]
	tm.wait = 2

	function tm.set(opts)
		if not opts.queue or not opts.slot then return end
		SetTheory:SelectStatus(L["Queueing profile X in slot Y"](opts.queue, L[tostring(opts.slot+12)]))
		TrinketMenu.SetQueue(opts.slot -1, "SORT", opts.queue)
		TrinketMenu.SetQueue(opts.slot -1, "ON")
	end

	function tm.alreadySet(opts)
		local enabled = TrinketMenu.GetQueue(opts.slot -1)
		if not enabled then return false end

		local i = 1
		local found = false
		while TrinketMenuQueue.Profiles[i] do
			if TrinketMenuQueue.Profiles[i][1] == opts.queue then 
				found = true
				break
			end
			i = i + 1
		end
		if not found then return false end

		local queue = {} 
		for j=2,#TrinketMenuQueue.Profiles[i] do
			if TrinketMenuQueue.Profiles[i][j] == 0 then break end
			table.insert(queue, TrinketMenuQueue.Profiles[i][j])
		end
		
		local sort = {}
		for j=1,#TrinketMenuQueue.Sort[opts.slot-1] do
			if TrinketMenuQueue.Sort[opts.slot-1][j] == 0 then break end
			table.insert(sort, TrinketMenuQueue.Sort[opts.slot-1][j])
		end
		if #queue ~= #sort then return false end

		for j=1, #queue do
			if queue[j] ~= sort[j] then return false end
		end
		return true		
	end
	
	function tm.exists(i, queue)
		local found = false
		for i=1, #(TrinketMenuQueue.Profiles) do
			if TrinketMenuQueue.Profiles[i][1] == queue then 
				found = true
				break
			end
		end
		return found
	end

	function tm.queues()
		local ret = {}
		for i=1, #(TrinketMenuQueue.Profiles) do
			ret[TrinketMenuQueue.Profiles[i][1]] = TrinketMenuQueue.Profiles[i][1]
		end
		return ret
	end

	tm.opts = {
		type = "group",
		name = L["TrinketMenu"],
		handler = SetTheory,
		set = "SetActionOption",
		get = "GetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which TrinketMenu queue you'd like to activate in which trinket slot"],
				order = 0,
			},
			queue = {
				name = L["Queue"],
				desc = L["Changes the queue"],
				type = "select",
				values = tm.queues,
				validate = tm.exists,
			},
			slot = {
				name = L["Slot"],
				desc = L["The slot you'd like to change"],
				type = "select",
				values = {
					L["Top"],
					L["Bottom"],
				},
			},
		}
	}

	SetTheory:RegisterAction(tm)
end
