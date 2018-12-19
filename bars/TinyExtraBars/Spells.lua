--this table used to add effects to main spell
--like "Hand of Gul'Dan" causes direct damage + Shadowflame
--use debug slash command to see events log
TEBLE_SpellPartOf = {
	-- format: [effect_id] = cast_id
	--warlock
	[86040] 	= 105174, 	--Hand of Gul'dan direct <- Hand of Gul'dan
	[47960] 	= 105174, 	--Shadowflame <- Hand of Gul'dan direct
	[129476] 	= 104025, 	--Immolation Aura dot <- Immolation Aura
	--mage
	[42208] 	= 10, 		--Blizzard dot <- Blizzard
	[84721] 	= 84714, 	--Frozen Orb
	[113092] 	= 112948, 	--Frost Bomb
	[44461]		= 44457,	--Living Bomb, aura removed before this damage!!!
	[12654]		= 133,		--Ignite <- Inferno Blast (108853), Scorch (2948), Fireball (133)
	--priest
	[124469] 	= 49821, 	--Mind Sear
	[124468]	= 15407,	--Mind Flay
	[120785]	= 121135, 	--Cascade Holy
	[127628]	= 127632, 	--Cascade Shadow
	[47666] 	= 47540, 	--Penance (damage)
	[47750] 	= 47540, 	--Penance (heal)
	--dk
	[55095]		= 45477,	--Frost Fever <- Icy Touch, Howling Blast???
	[55078]		= 45462,	--Blood Plague <- Plague Strike
	[47632]		= 47541,	--Death Coil
	[52212]		= 43265,	--Death and Decay
	[119980]	= 119975, 	--Conversion
	--hunter
	[118253]	= 1978,		--Serpent Sting DoT
	[83381]		= 34026,	--Kill Command
	--paladin
	[88263]		= 53595,	--Hammer of the Righteous
	[81297]		= 26573, 	--Consecration
	--shaman
	[8349]		= 1535,		--Fire Nova
	[32175] 	= 17364, 	--Stormstrike
	[32176]		= 17364,	--Stormstrike offhand
	[73921]		= 73920,	--Healing Rain
	--monk
	[116995]	= 116694,	--Surging Mist
	[132120]	= 124682,	--Envelpoing Mist
	[119611]	= 115151,	--Renewing Mist
}

--examples of debug logs

--"Shadow Bolt"
--SPELL_CAST_START optional SPELL_CAST_FAILED
--SPELL_DAMAGE [15-17]

--"Hand of Gul'dan", causes Shadowflame 47960 + Hand of Gul'dan 86040
--SPELL_CAST_SUCCESS
--SPELL_AURA_APPLIED [15] DEBUFF
--SPELL_DAMAGE [15-17]
--SPELL_PERIODIC_DAMAGE [15-17]
--SPELL_AURA_REMOVED

--"Fel Flame"
--SPELL_CAST_SUCCESS
--SPELL_DAMAGE [15-17]
--SPELL_HEAL [15-17]

--"Drain Life" 
--SPELL_AURA_APPLIED [15] BUFF [16] amount optional
--SPELL_CAST_SUCCESS
--SPELL_PERIODIC_HEAL [15-17]
--SPELL_PERIODIC_DAMAGE [15-17]

--"Blizzard", channeled
--SPELL_AURA_APPLIED [15] BUFF = 10, self
--SPELL_CAST_SUCCESS = 10
--SPELL_AURA_APPLIED [15] DEBUFF = 10, target
--SPELL_CAST_SUCCESS = 42208 (also [13] = "Blizzard")
--SPELL_DAMAGE [15-17] = 42208 (also [13] = "Blizzard")
--repeat 42208
--SPELL_AURA_REMOVED [15] BUFF = 10
