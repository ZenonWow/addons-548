local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if  SetTheory then --and GetBuildInfo() < "4.0.0" then
	local cb = {};
	cb.name = "SetTheory_CancelBuff"
	cb.desc = L["Cancel Buff"]

	function cb.set(opts)
		if not opts.buff then return end
		if opts.buff then CancelUnitBuff("player", opts.buff) end
	end
	
	function buffs()
		local buffs = {}
		for i=1,40 do
			local buff = UnitBuff("player", i)
			if not buff then break end
			buffs[buff] = buff
		end
		return buffs
	end

	cb.opts = {
		type = "group",
		name = L["Cancel Buff"],
		handler = SetTheory,
		get = "GetActionOption",
		set = "SetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select a current buff or type the name of a currently inactive buff you'd like to cancel"],
				order = 0,
			},
			currentBuff = {
				type = "select",
				name = L["Current buffs"],
				desc = L["Select a currently active buff"],
				values = buffs,
				order = 10,
				set = function(i, v) SetTheory:SetActionOptionByName(i[#i-3], i[#i-1], 'buff', v) end
			},
			buff = {
				name = L["Buff Name"],
				desc = L["Type the name of the buff name."],
				type = "input",
				order = 20,
			},
		}
	}

	SetTheory:RegisterAction(cb)
--[[elseif SetTheory then
	local cb = {};
	cb.name = "SetTheory_CancelBuff"
	cb.desc = L["Cancel Buff"]

	function cb.set(opts)
		if not opts.buff then return end
		local buff,icon
		for i=1,40 do
			buff,_,icon = UnitBuff('player', i)
			if not buff then break end
			if buff == opts.buff then break
			else buff,icon = nil,nil end
		end
		if buff then 
			local f = SetTheory:CreateSecureButton(cb.name, icon, {['type']='cancelaura', ['unit']='player', ['spell']=buff})
			f:RegisterEvent("UNIT_AURA")
			f:SetScript("OnEvent", function(self, event, ...)
				for i=1,40 do
					local buff = UnitBuff('player', i)
					if not buff then break end
					if buff == opts.buff then return end
				end
				f:Hide()
			end)
			SetTheory:SelectStatus(L["Click the central button to remove "]..buff)
		end
		
	end
	
	function buffs()
		local buffs = {}
		for i=1,40 do
			local buff = UnitBuff("player", i)
			if not buff then break end
			buffs[buff] = buff
		end
		return buffs
	end

	cb.opts = {
		type = "group",
		name = L["Cancel Buff"],
		handler = SetTheory,
		get = "GetActionOption",
		set = "SetActionOption",
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select a current buff or type the name of a currently inactive buff you'd like to cancel"],
				order = 0,
			},
			currentBuff = {
				type = "select",
				name = L["Current buffs"],
				desc = L["Select a currently active buff"],
				values = buffs,
				order = 10,
				set = function(i, v) SetTheory:SetActionOptionByName(i[#i-3], i[#i-1], 'buff', v) end
			},
			buff = {
				name = L["Buff Name"],
				desc = L["Type the name of the buff name."],
				type = "input",
				order = 20,
			},
		}
	}

	SetTheory:RegisterAction(cb)]]
end
