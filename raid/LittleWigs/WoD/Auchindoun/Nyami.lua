
--------------------------------------------------------------------------------
-- Module Declaration
--

if not BigWigs.isWOD then return end -- XXX compat
local mod, CL = BigWigs:NewBoss("Soulbinder Nyami", 984, 1186)
if not mod then return end
mod:RegisterEnableMob(76177)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		155327, 153994, {154477, "DISPEL"}, "bosskill",
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Log("SPELL_CAST_START", "SoulVessel", 155327)
	self:Log("SPELL_CAST_START", "TornSpirits", 153994)
	self:Log("SPELL_AURA_APPLIED", "ShadowWordPain", 154477)

	self:Death("Win", 76177)
end

function mod:OnEngage()
	self:CDBar(155327, 6) -- Soul Vessel
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:SoulVessel(args)
	self:Message(args.spellId, "Urgent", "Warning")
	self:CDBar(args.spellId, 27.7)
	self:Bar(args.spellId, 7, CL.cast:format(args.spellName))
end

function mod:TornSpirits(args)
	self:Message(args.spellId, "Attention", "Alert", CL.incoming:format(CL.adds))
	self:CDBar(args.spellId, 27.7)
	self:Bar(args.spellId, 3, CL.adds)
end

function mod:ShadowWordPain(args)
	if self:Dispeller("magic", nil, args.spellId) then
		self:TargetMessage(args.spellId, args.destName, "Important", "Alarm", nil, nil, true)
	end
end

