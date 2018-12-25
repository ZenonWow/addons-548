--Contributed by Cybeloras, current maintainer/updater of TellMeWhen.

local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if ((TMW and TMW.db) or TellMeWhen_Settings) and SetTheory then
    local tmw = {};
    tmw.name = "SetTheory_TellMeWhen"
    tmw.desc = L["TellMeWhen"]
	
	local TellMeWhen_Settings = TellMeWhen_Settings
        local TellMeWhen_Group_Update = TellMeWhen_Group_Update
	if TELLMEWHEN_VERSION >= "3.0.0" then
		TellMeWhen_Settings = TMW.db.profile
		TellMeWhen_Group_Update =  TMW.Group_Update
	end
    function tmw.set(opts)
        local on = {}; local off = {}
        for i, v in pairs(opts) do
            TellMeWhen_Settings.Groups[tonumber(i)]["Enabled"] = v
            TellMeWhen_Group_Update(tonumber(i))
            if v then table.insert(on, i) else table.insert(off, i) end
        end
        if #on > 0 then SetTheory:SelectStatus(L['Turned the following TellMeWhen groups on: ']..table.concat(on, ', ')) end
        if #off > 0 then SetTheory:SelectStatus(L['Turned the following TellMeWhen groups off: ']..table.concat(off, ', ')) end
    end
   

    tmw.opts = {
        type = "group",
        name = L["TellMeWhen"],
        handler = SetTheory,
        set = "SetActionOption",
        get = "GetActionOption",
	args = {
            actionInstructions = {
                type = "description",
                name = L["Select which TellMeWhen groups you'd like to enable or disable. Blank = disable, grey = no change, ticked = enable."],
                order = 0,
            }
        }
    }
   
    for i=1,20 do
		tmw.opts.args[tostring(i)] = {
			name = L["Group "] .. i,
			desc = L["Enable or disable this TellMeWhen group."],
			type = "toggle",
			tristate = true,
			order = i+1,
			hidden = function() return TellMeWhen_Settings.Groups[tonumber(i)] == nil or TellMeWhen_Settings.Groups[tonumber(i)].Enabled == false end,
		}
    end

    SetTheory:RegisterAction(tmw)
end

