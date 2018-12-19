---------------------
-- SEE LICENSE.TXT --
---------------------

--------------
-- DEFAULTS --
--------------
if not Watcher then
    return;
end

local L = LibStub("AceLocale-3.0"):GetLocale("Watcher");
local C = Watcher.constants;


--[[ TODO: rewrite for new default system
function Watcher:AddIcon(spellName, spellID)
	local spellinfo = GetSpellInfo(spellID)
	if not spellinfo then return end
	C[spellName], _, C[spellName.." Icon"] = GetSpellInfo(spellID)
	C[spellName.." SID"] = spellID
end

function Watcher:Debuff(name, casttime, stack) -- basically, dots
	if not C[name] then return end
	local def = self.db.char.spell
	k = C[name]
	def.spellName[k] = C[name]
	def.name[k] = k
	def.icon[k] = C[name.." Icon"]
	def.auraName[k] = C[name]
	def.trackAura[k] =  true -- true if looking for an aura (on caster or target)
	def.refreshThreshold[k] = casttime or 0
	def.countReq[k] = stack or 0
	def.playerIsCaster[k] = true -- ignore other player's debuffs
	def.spellID[k] = C[name.. " SID"]
end

function Watcher:Buff(buff, name, spellisbuff,stack, comboReq, comboCost, comboType) -- buff that can be maintained 100% up
	if not C[name] then return end
	local def = self.db.char.spell
	if spellisbuff then k = C[name] else k = C[name].." for "..C[buff] end
	def.spellName[k] = C[name]
	def.name[k] = k
	def.icon[k] = C[name.." Icon"]
	def.auraName[k] = C[buff]
	def.trackAura[k] =  true -- true if looking for an aura (on caster or target)
	def.isBuff[k] =  true -- true if %auraName is an aura on the caster
	def.countReq[k] = stack or 0
	def.comboReq[k] = comboReq or "Greater Than"
	def.comboCost[k] = comboCost or 0
	def.comboType[k] = comboType or "Combo Points"
	def.spellID[k] = C[name.. " SID"]
end

function Watcher:BuffPerm(name, buff, spellisbuff,stack, comboReq, comboCost, comboType) -- buff that doesn't fade
	if not C[name] then return end
	local def = self.db.char.spell
	if spellisbuff then k = C[name] else k = C[name].." for "..C[buff] end
	def.spellName[k] = C[name]
	def.name[k] = k
	def.icon[k] = C[name.." Icon"]
	if buff then def.auraName[k] = C[buff] else def.auraName[k] = C[name] end
	def.trackAura[k] =  true -- true if looking for an aura (on caster or target)
	def.isBuff[k] =  true -- true if %auraName is an aura on the caster
	def.countReq[k] = stack or 0
	def.comboReq[k] = comboReq or "Greater Than"
	def.comboCost[k] = comboCost or 0
	def.comboType[k] = comboType or "Combo Points"
	def.spellID[k] = C[name.. " SID"]
end

function Watcher:Proc(buff, name, stack, comboReq, comboCost, comboType) -- when %buff is triggered on self, cast %name
	if not C[name] then return end
	local def = self.db.char.spell
	k = C[name].." w/ "..buff
	def.spellName[k] = C[name]
	def.name[k] = k -- sets definition names
	def.icon[k] =  C[name.." Icon"]
	def.auraName[k] = buff -- which spell to look for
	def.trackAura[k] =  true -- true if looking for an aura (on caster or target)
	def.invertAura[k] =  true -- true if %auraName is something that should be shown only when it's there
	def.isBuff[k] =  true -- true if %auraName is an aura on the caster
	def.countReq[k] = stack or 0
	def.comboReq[k] = comboReq or "Greater Than"
	def.comboCost[k] = comboCost or 0
	def.comboType[k] = comboType or "Combo Points"
	def.spellID[k] = C[name.. " SID"]
end

function Watcher:Direct(name,comboReq, comboCost, comboType) -- direct damage and the sort
	if not C[name] then return end
	local def = self.db.char.spell
	k = C[name]
	def.spellName[k] = C[name]
	def.name[k] = k
	def.icon[k] =  C[name.." Icon"]
	def.spellID[k] = C[name.. " SID"]
	def.comboReq[k] = comboReq or "Greater Than"
	def.comboCost[k] = comboCost or 0
	def.comboType[k] = comboType or "Combo Points"
end

function Watcher:Capitalize(debuff, name) -- while %debuff is applied, cast %name
	if not C[name] then return end
	local def = self.db.char.spell
	k = C[name].." w/ "..debuff
	def.spellName[k] = C[name]
	def.name[k] = k
	def.icon[k] = C[name.." Icon"]
	def.trackAura[k] =  true -- true if looking for an aura (on caster or target)
	def.auraName[k] = C[debuff]
	def.invertAura[k] =  true -- true if %auraName is something that should be shown only when it's there
	def.playerIsCaster[k] = true -- ignore other player's debuffs
	def.spellID[k] = C[name.. " SID"]
end

function Watcher:Apply(debuff, name, casttime, stack, playercast, displayname) -- when %debuff is desired, cast %name
	if not C[name] then return end
	local def = self.db.char.spell
	if (name and displayname) then k = name.." for ".. debuff else k = debuff end
	def.spellName[k] = C[name]
	if (name and displayname) then def.name[k] = name.." for ".. debuff def.icon[k] = C[name.." Icon"] else def.name[k] = k def.icon[k] = C[debuff.." Icon"] end
	def.trackAura[k] =  true -- true if looking for an aura (on caster or target)
	def.auraName[k] = debuff -- which spell to look for
	--def.invertAura[k] =  true -- true if %auraName is something that should be shown only when it's there
	def.refreshThreshold[k] = casttime or 0
	def.countReq[k] = stack or 0
	def.playerIsCaster[k] = playercast or true -- false, if you want to count other players' debuffs; true to require player's casts
	def.spellID[k] = C[name.. " SID"]
end

function Watcher:powerThreshold(power, reverse, name)
	if not C[name] then return end
	local def =	self.db.char.spell
	k = C[name]
	def.powerThresh[k] = power
	def.invertPowerThreshhold[k] = reverse
	def.spellID[k] = C[name.. " SID"]
end

function Watcher:HealthThreshold(health, reverse, name)
	if not C[name] then return end
	-- reverse (true) means greater then
	local def = self.db.char.spell
	if reverse then
		k = C[name].." w/ Health more then "..health
	else
		k = C[name].." w/ Health less then "..health
	end
	def.spellName[k] = C[name]
	def.name[k] = k
	def.icon[k] =  C[name.." Icon"]
	def.healthThreshold[k] = health
	def.invertHealthThreshhold[k] = reverse
	def.spellID[k] = C[name.. " SID"]
end

function Watcher:powerThreshold(power, reverse, name)
	if not C[name] then return end
	-- reverse (true) means less then
	local def = self.db.char.spell
	if reverse then
		k = C[name].." w/ Power less then "..power
	else
		k = C[name].." w/ Power more then "..power
	end
	def.spellName[k] = C[name]
	def.name[k] = k
	def.icon[k] =  C[name.." Icon"]
	def.powerThresh[k] = power
	def.invertPowerThreshhold[k] = reverse
	def.spellID[k] = C[name.. " SID"]
end
--]]