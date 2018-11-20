
--local Dominos_BuffTimes = Dominos_BuffTimes

--[[ Configuration functions ]]--

Dominos_BuffTimes.ignoreOptions = {
	addspell = {
		name = "Remove Spell",
		desc = "Remove spell from ignored list.",
		type = "execute",
		func = "RemoveSpellFromIgnored",
		order = 200,
	},
}

Dominos_BuffTimes.yourBuffOptions = {
	addspell = {
		name = "Remove Spell",
		desc = "Remove spell from player buffs list.",
		type = "execute",
		func = "RemoveSpellFromYourBuff",
		order = 200,
	},
}

Dominos_BuffTimes.allDebuffOptions = {
	addspell = {
		name = "Remove Spell",
		desc = "Remove spell from any debuff list.",
		type = "execute",
		func = "RemoveSpellFromAnyDebuff",
		order = 200,
	},
}

Dominos_BuffTimes.selfBuffOptions = {
	addspell = {
		name = "Remove Spell",
		desc = "Remove spell from any self-buff list.",
		type = "execute",
		func = "RemoveSpellFromSelfBuff",
		order = 200,
	},
}

Dominos_BuffTimes.translatedOptions = {
	addspell = {
		name = "Remove Spell",
		desc = "Remove spell pair from translated list.",
		type = "execute",
		func = "RemovePairFromTranslated",
		order = 200,
	},
}

Dominos_BuffTimes.overrideOptions = {
	addspell = {
		name = "Remove Spell",
		desc = "Remove spell from override list.",
		type = "execute",
		func = "RemoveSpellFromOverride",
		order = 200,
	},
}

function Dominos_BuffTimes:InitOptions()
	
	local _, playerClass = UnitClass("player")
	self.class = playerClass
	
	self.options = {
		desc = "Dominos_BuffTimes - (de)buff timers on buttons",
		type = "group",
		childGroups = "tab",
		handler = Dominos_BuffTimes,
		
		args = {
			ignored = {
				name = "Ignored",
				desc = "Spells for which timers will not be shown.",
				type = "group",
				
				args = {
					description = {
						type = "description",
						name = "The following spells will not show times on the buttons (borders will still be colored).",
						order = 1,
					},
					spellname = {
						name = "Spell to add",
						type = "input",
						desc = "Name of the spell to add to the ignored list.",
						set = "AddSpellToIgnored",
						order = 100,
					}, 
				},
			},
			yourbuffs = {
				name = "Player only buffs",
				desc = "Buffs for which timers will only be shown if you casted it.",
				type = "group",
				
				args = {
					description = {
						type = "description",
						name = "By default, all buffs will show times for the target regardless of who casted it. The following spells will only show times on the buttons if you casted it.",
						order = 1,
					},
					spellname = {
						name = "Spell to add",
						type = "input",
						desc = "Name of the spell to add to the player only buffs list.",
						set = "AddSpellToYourBuff",
						order = 100,
					}, 
				},
			},
			alldebuffs = {
				name = "Any player debuffs",
				desc = "Debuffs for which timers will only be shown regardless of who casted it.",
				type = "group",
				
				args = {
					description = {
						type = "description",
						name = "By default, debuffs will only show times for the target if you were the one to cast it. The following spells will show times on the buttons regardless of who casted it.",
						order = 1,
					},
					spellname = {
						name = "Spell to add",
						type = "input",
						desc = "Name of the spell to add to the any player debuffs list.",
						set = "AddSpellToAnyDebuff",
						order = 100,
					}, 
				},
			},
			selfbuffs = {
				name = "Self-only buffs",
				desc = "Buffs for which timers will only show for you, and will override the cooldown.",
				type = "group",
				
				args = {
					description = {
						type = "description",
						name = "The following spells will show times on the buttons for buffs on you, regardless of who is targeted. These spells will also override the cooldown.",
						order = 1,
					},
					spellname = {
						name = "Spell to add",
						type = "input",
						desc = "Name of the spell to add to the any player debuffs list.",
						set = "AddSpellToSelfBuff",
						order = 100,
					}, 
				},
			},
			translated = {
				name = "Translated",
				desc = "Spell groups for which the status/time will be shown if it matches any of the spells",
				type = "group",
				
				args = {
					description = {
						type = "description",
						name = "The buttons for the spells on the left will show borders/times if it matches any of the spells on the right. Where multiple spells are found, the longest time is used.",
						order = 1,
					},
					leftspellname = {
						name = "Spell to add",
						type = "input",
						desc = "Name of your spell to add.",
						set = "SetLeftTranslatedSpell",
						get = "GetLeftTranslatedSpell",
						order = 100,
					},
					rightspellname = {
						name = "Translated spell to add.",
						type = "input",
						desc = "Name of other spell to add.",
						set = "SetRightTranslatedSpell",
						get = "GetRightTranslatedSpell",
						order = 200,
					},
					addspell = {
						name = "Add Spell Pair",
						desc = "Add spell pair to the translation list.",
						type = "execute",
						func = "AddPairToTranslated",
						order = 300,
					},
				},
			},
			override = {
				name = "Override",
				desc = "Spells for which timers will override the cooldown.",
				type = "group",
				
				args = {
					description = {
						type = "description",
						name = "The following spells will also override the cooldown.",
						order = 1,
					},
					spellname = {
						name = "Spell to add",
						type = "input",
						desc = "Name of the spell to add to the override list.",
						set = "AddSpellToOverride",
						order = 100,
					}, 
				},
			},
			resetAll = {
				name = "Reset options",
				desc = "Resets all buff/debuff options to thier defaults. Defaults depend on class and race.",
				type = "execute",
				func = "ResetOptions",
			},
		},
	}
	
	local profile = self.db.profile
	self:UpdateSpellOptions(self.options.args.ignored.args, profile.ignored, self.ignoreOptions)
	self:UpdateSpellOptions(self.options.args.yourbuffs.args, profile.yourbuffs, self.yourBuffOptions)
	self:UpdateSpellOptions(self.options.args.alldebuffs.args, profile.alldebuffs, self.allDebuffOptions)
	self:UpdateSpellOptions(self.options.args.selfbuffs.args, profile.selfbuffs, self.selfBuffOptions)
	self:UpdateSpellPairOptions(self.options.args.translated.args, profile.translated, self.translatedOptions)
	self:UpdateSpellOptions(self.options.args.override.args, profile.override, self.overrideOptions)
end

function Dominos_BuffTimes:UpdateSpellOptions(optionList, spellList, options)
	-- add new spells that aren't in optionList
	for i in pairs(spellList) do
		-- remove space from spell name
		local intName = string.gsub(i, ' ', '')
		intName = "Spell" .. intName
				
		if not optionList[intName] then
			optionList[intName] = {
				name = i,
				type = "group",
				args = options,
			}
		end
	end
	
	-- remove from optionList spells that aren't in spellList
	for i in pairs(optionList) do
		if i ~= "description" and i ~= "spellname" and not spellList[optionList[i].name] then
			optionList[i] = nil
		end
	end
end

function Dominos_BuffTimes:UpdateSpellPairOptions(optionList, spellList, options)
	-- add new spells that aren't in optionList
	for i in pairs(spellList) do
		-- remove space from spell name
		local intName = string.gsub(i, ' ', '')
		intName = "Spell" .. intName
		
		for j in pairs(spellList[i]) do
			-- get second spell
			local intName2 = string.gsub(j, ' ', '')
			intName2 = "Spell" .. intName2
			if not optionList[intName .. " -> " .. intName2] then
				optionList[intName .. " -> " .. intName2] = {
					name = i .. " -> " .. j,
					type = "group",
					args = options,
				}
			end
		end
	end
	
	-- remove from optionList spells that aren't in spellList
	for i in pairs(optionList) do
		if i ~= "description" and i ~= "leftspellname" and i ~= "rightspellname" and i ~= "addspell" then
			-- extract the spell names
			local checkName = string.gsub(optionList[i].name, ' %-> ', '!')
			local name1, name2 = string.split('!', checkName)
			if name1 and name2 then
				if (not spellList[name1] or not spellList[name1][name2]) then
					optionList[i] = nil
				end
			end
		end
	end
end

function Dominos_BuffTimes:AddSpellToIgnored(info, value)
	self:AddIgnored(value)
	self:UpdateSpellOptions(self.options.args.ignored.args, self.db.profile.ignored, self.ignoreOptions)
end

function Dominos_BuffTimes:AddSpellToYourBuff(info, value)
	self:AddYourBuff(value)
	self:UpdateSpellOptions(self.options.args.yourbuffs.args, self.db.profile.yourbuffs, self.yourBuffOptions)	
end

function Dominos_BuffTimes:AddSpellToAnyDebuff(info, value)
	self:AddAllDebuff(value)
	self:UpdateSpellOptions(self.options.args.alldebuffs.args, self.db.profile.alldebuffs, self.allDebuffOptions)
end

function Dominos_BuffTimes:AddSpellToSelfBuff(info, value)
	self:AddSelfBuff(value)
	self:UpdateSpellOptions(self.options.args.selfbuffs.args, self.db.profile.selfbuffs, self.selfBuffOptions)
end

function Dominos_BuffTimes:AddSpellToOverride(info, value)
	self:AddOverride(value)
	self:UpdateSpellOptions(self.options.args.override.args, self.db.profile.override, self.overrideOptions)
end

function Dominos_BuffTimes:RemoveSpellFromIgnored(info)
	self:RemoveIgnored(self.options.args.ignored.args[info[#info - 1]].name)
	self:UpdateSpellOptions(self.options.args.ignored.args, self.db.profile.ignored, ignoreOptions)
end

function Dominos_BuffTimes:RemoveSpellFromYourBuff(info)
	self:RemoveYourBuff(self.options.args.yourbuffs.args[info[#info - 1]].name)
	self:UpdateSpellOptions(self.options.args.yourbuffs.args, self.db.profile.yourbuffs, yourBuffOptions)
end

function Dominos_BuffTimes:RemoveSpellFromAnyDebuff(info)
	self:RemoveAllDebuff(self.options.args.alldebuffs.args[info[#info - 1]].name)
	self:UpdateSpellOptions(self.options.args.alldebuffs.args, self.db.profile.alldebuffs, allDebuffOptions)
end

function Dominos_BuffTimes:RemoveSpellFromSelfBuff(info)
	self:RemoveSelfBuff(self.options.args.selfbuffs.args[info[#info - 1]].name)
	self:UpdateSpellOptions(self.options.args.selfbuffs.args, self.db.profile.selfbuffs, selfBuffOptions)
end

function Dominos_BuffTimes:RemoveSpellFromOverride(info, value)
	self:RemoveOverride(self.options.args.override.args[info[#info - 1]].name)
	self:UpdateSpellOptions(self.options.args.override.args, self.db.profile.override, self.overrideOptions)
end

function Dominos_BuffTimes:SetLeftTranslatedSpell(info, value)
	self.leftTranslatedSpell = value
end

function Dominos_BuffTimes:GetLeftTranslatedSpell(info, value)
	return self.leftTranslatedSpell
end

function Dominos_BuffTimes:SetRightTranslatedSpell(info, value)
	self.rightTranslatedSpell = value
end

function Dominos_BuffTimes:GetRightTranslatedSpell(info, value)
	return self.rightTranslatedSpell
end

function Dominos_BuffTimes:AddPairToTranslated(info)
	self:AddTranslatedSpellPair(self.leftTranslatedSpell, self.rightTranslatedSpell)
	self:UpdateSpellPairOptions(self.options.args.translated.args, self.db.profile.translated, self.translatedOptions)
end

function Dominos_BuffTimes:RemovePairFromTranslated(info)
	-- extract the spell names
	local checkName = string.gsub(self.options.args.translated.args[info[#info - 1]].name, ' %-> ', '!')
	local name1, name2 = string.split('!', checkName)
	self:RemoveTranslatedSpellPair(name1, name2)
	self:UpdateSpellPairOptions(self.options.args.translated.args, self.db.profile.translated, self.translatedOptions)
end

function Dominos_BuffTimes:ResetOptions()
	local profile = self.db.profile
	profile.ignored = nil
	profile.yourbuffs = nil
	profile.alldebuffs = nil
	profile.selfbuffs = nil
	profile.translated = nil
	profile.override = nil
	
	self:CheckDB()
	
	self:Print('Options reset to their default values.')
	
	self:UpdateSpellOptions(self.options.args.yourbuffs.args, profile.yourbuffs, yourBuffOptions)
	self:UpdateSpellOptions(self.options.args.selfbuffs.args, profile.selfbuffs, selfBuffOptions)
	self:UpdateSpellOptions(self.options.args.alldebuffs.args, profile.alldebuffs, allDebuffOptions)
	self:UpdateSpellOptions(self.options.args.ignored.args, profile.ignored, ignoreOptions)
	self:UpdateSpellOptions(self.options.args.translated.args, profile.translated, self.translatedOptions)
	self:UpdateSpellOptions(self.options.args.override.args, profile.override, overrideOptions)
end

--[[ Slash Commands ]]--

function Dominos_BuffTimes:RegisterSlashCommands()
	self:RegisterChatCommand('bufftimes', 'OnCmd')
end

function Dominos_BuffTimes:OnCmd(args)
	local cmd = string.split(' ', args):lower() or args:lower()
	local restOfString = string.gsub(args, cmd .. ' ', '')

	--frame functions
	if cmd == 'ignored' then
		self:ShowIgnored()
	elseif cmd == 'yourbuffs' then
		self:ShowYourBuffs()
	elseif cmd == 'alldebuffs' then
		self:ShowAllDebuffs()
	elseif cmd == 'selfbuffs' then
		self:ShowSelfBuffs()
	elseif cmd == 'override' then
		self:ShowOverride()
	elseif cmd == 'addignored' then
		self:AddIgnored(restOfString)
	elseif cmd == 'removeignored' then
		self:RemoveIgnored(restOfString)
	elseif cmd == 'addyourbuff' then
		self:AddYourBuff(restOfString)
	elseif cmd == 'removeyourbuff' then
		self:RemoveYourBuff(restOfString)
	elseif cmd == 'addalldebuff' then
		self:AddAllDebuff(restOfString)
	elseif cmd == 'removealldebuff' then
		self:RemoveAllDebuff(restOfString)
	elseif cmd == 'addselfbuff' then
		self:AddSelfBuff(restOfString)
	elseif cmd == 'removeselfbuff' then
		self:RemoveSelfBuff(restOfString)
	elseif cmd == 'addoverride' then
		self:AddOverride(restOfString)
	elseif cmd == 'removeoverride' then
		self:RemoveOverride(restOfString)
	elseif cmd == 'translated' then
		self:ShowTranslated()
	elseif cmd == 'addtranslated' then
		restOfString = restOfString:lower()
		local firstSpell, secondSpell = string.split(' ', restOfString)
		self:AddTranslatedSpellPair(firstSpell, secondSpell)
	elseif cmd == 'removetranslated' then
		restOfString = restOfString:lower()
		local firstSpell, secondSpell = string.split(' ', restOfString)
		self:RemoveTranslatedSpellPair(firstSpell, secondSpell)
	elseif cmd == 'resetoptions' then
		self:ResetOptions()
	elseif cmd == 'debugtable' then
		self:DebugOutputTable()
	elseif cmd == 'help' or cmd == '?' then
		self:PrintHelp()
	else
		self:PrintHelp()
	end
end

function Dominos_BuffTimes:PrintHelp(cmd)
	local function PrintCmd(cmd, desc)
		DEFAULT_CHAT_FRAME:AddMessage(format(' - |cFF33FF99%s|r: %s', cmd, desc))
	end
	
	self:Print('Commands (/bufftimes)')
	PrintCmd('ignored', 'Show spells that will not show times on the buttons')
	PrintCmd('addignored <spell name>', 'Add spell that will not show times on the buttons')
	PrintCmd('removeignored <spell name>', 'Remove spell that will not show times on the buttons')
	PrintCmd('yourbuffs', 'Show buffs that will only show times on your casted spells')
	PrintCmd('addyourbuff <spell name>', 'Add buff that will only show times on your casted spells')
	PrintCmd('removeyourbuff <spell name>', 'Remove buff that will only show times on your casted spells')
	PrintCmd('alldebuffs', 'Show debuffs that will show times regardless of the caster')
	PrintCmd('addalldebuff <spell name>', 'Add debuff that will show times regardless of the caster')
	PrintCmd('removealldebuff <spell name>', 'Remove debuff that will show times regardless of the caster')
	PrintCmd('selfbuffs', 'Show buffs that will show times only for you and override the cooldown')
	PrintCmd('addselfbuff <spell name>', 'Add buffs that will show times only for you and override the cooldown')
	PrintCmd('removeselfbuff <spell name>', 'Remove buffs that will show times only for you and override the cooldown')
	PrintCmd('translated', 'Show spells where buttons with the first spell will show status/cooldown for other spell')
	PrintCmd('addtranslated <your spell> <other spell>', 'Add spell where buttons with the first spell will show status/cooldown for other spell')
	PrintCmd('removetranslated <your spell> <other spell>', 'Remove spell where buttons with the first spell will show status/cooldown for other spell')
	PrintCmd('override', 'Show spells that will override the cooldown')
	PrintCmd('addoverride <spell name>', 'Add spell that will override the cooldown')
	PrintCmd('removeoverride <spell name>', 'Remove spell that will override the cooldown')
	PrintCmd('resetoptions', 'Resets all buff/debuff options to thier defaults. Defaults depend on class and race.')
end

function Dominos_BuffTimes.ShowSpells(spells)
	for spellName in pairs(spells) do
		self:Print(spellName)
	end
end

function Dominos_BuffTimes:ShowIgnored()
	self:Print('Spells that will not show times on the buttons')
	self.ShowSpells(self.db.profile.ignored)
end

function Dominos_BuffTimes:ShowYourBuffs()
	self:Print('Buffs that will only show times for your casted spells')
	self.ShowSpells(self.db.profile.yourbuffs)
end

function Dominos_BuffTimes:ShowAllDebuffs()
	self:Print('Spells that will not show times on the buttons')
	self.ShowSpells(self.db.profile.alldebuffs)
end

function Dominos_BuffTimes:ShowSelfBuffs()
	self:Print('Spells that will show times for you only and will override the cooldown')
	self.ShowSpells(self.db.profile.selfbuffs)
end

function Dominos_BuffTimes:ShowOverride()
	self:Print('Spells that will override the cooldown')
	self.ShowSpells(self.db.profile.override)
end

local function tableKeysSorted(t)
	local n, keys = 0, {}
	for k,v in pairs(tab) do  n = n+1 ; keys[n] = k  end
	if  2 <= n  then  table.sort(keys)  end
	return keys
end

function Dominos_BuffTimes:ShowTranslated()
	self:Print('Spells translation list')
	local translated = self.db.profile.translated
	for  fromSpell, toSpells  in pairs(translated) do
		self:Print(fromSpell .. ' -> ' .. strjoin(', ', tableKeysSorted(toSpells)) )
	end
end

function Dominos_BuffTimes:AddIgnored(spell)
	local lowerSpell = string.lower(spell)
	self.db.profile.ignored[lowerSpell] = 1
	self:Print(lowerSpell .. ' will no longer show buff/debuffs times on buttons')
end

function Dominos_BuffTimes:RemoveIgnored(spell)
	local lowerSpell = string.lower(spell)
	self.db.profile.ignored[lowerSpell] = nil
	self:Print(lowerSpell .. ' will now show buff/debuffs times on buttons')
end
		
function Dominos_BuffTimes:AddYourBuff(spell)
	local lowerSpell = string.lower(spell)
	self.db.profile.yourbuffs[lowerSpell] = 1
	self:Print(lowerSpell .. ' will now only show buff times on buttons when casted by you')
end

function Dominos_BuffTimes:RemoveYourBuff(spell)
	local lowerSpell = string.lower(spell)
	self.db.profile.yourbuffs[lowerSpell] = nil
	self:Print(lowerSpell .. ' will now show buff times on buttons regardless of the caster')
end

function Dominos_BuffTimes:AddAllDebuff(spell)
	local lowerSpell = string.lower(spell)
	self.db.profile.alldebuffs[lowerSpell] = 1
	self:Print(lowerSpell .. ' will now show debuff times on buttons regardless of the caster')
end

function Dominos_BuffTimes:RemoveAllDebuff(spell)
	local lowerSpell = string.lower(spell)
	self.db.profile.alldebuffs[lowerSpell] = nil
	self:Print(lowerSpell .. ' will now only show debuff times on buttons when casted by you')
end

function Dominos_BuffTimes:AddSelfBuff(spell)
	local lowerSpell = string.lower(spell)
	self.db.profile.selfbuffs[lowerSpell] = 1
	self:Print(lowerSpell .. ' will now show for you only, and will override the cooldown')
end

function Dominos_BuffTimes:RemoveSelfBuff(spell)
	local lowerSpell = string.lower(spell)
	self.db.profile.selfbuffs[lowerSpell] = nil
	self:Print(lowerSpell .. ' will now show for anyone, and will not override the cooldown')
end

function Dominos_BuffTimes:AddOverride(spell)
	local lowerSpell = string.lower(spell)
	self.db.profile.override[lowerSpell] = 1
	self:Print(lowerSpell .. ' will now override the cooldown')
end

function Dominos_BuffTimes:RemoveOverride(spell)
	local lowerSpell = string.lower(spell)
	self.db.profile.override[lowerSpell] = nil
	self:Print(lowerSpell .. ' will no longer override the cooldown')
end

function Dominos_BuffTimes:AddTranslatedSpellPair(firstSpell, secondSpell)
	local lowerSpell = string.lower(firstSpell)
	local lowerOtherSpell = string.lower(secondSpell)
	local translated = self.db.profile.translated
	if not translated[lowerSpell] then
		translated[lowerSpell] = {}
	end 
		
	translated[lowerSpell][lowerOtherSpell] = 1
	self:Print(lowerSpell .. ' will now show a cooldown if ' .. lowerOtherSpell .. ' is detected')
end

function Dominos_BuffTimes:RemoveTranslatedSpellPair(firstSpell, secondSpell)
	local lowerSpell = string.lower(firstSpell)
	local lowerOtherSpell = string.lower(secondSpell)
	local translated = self.db.profile.translated
	if translated[lowerSpell] then
		translated[lowerSpell][lowerOtherSpell] = nil
	end
	
	self:Print(lowerSpell .. ' will no longer show a cooldown if ' .. lowerOtherSpell .. ' is detected')
end

function Dominos_BuffTimes:IsIgnored(spell)
	return self.db.profile.ignored[spell]
end

function Dominos_BuffTimes:IsYourBuff(spell)
	return self.db.profile.yourbuffs[spell]
end

function Dominos_BuffTimes:IsAllDebuff(spell)
	return self.db.profile.alldebuffs[spell]
end

function Dominos_BuffTimes:IsSelfBuff(spell)
	return self.db.profile.selfbuffs[spell]
end

function Dominos_BuffTimes:IsOverride(spell)
	return self.db.profile.override[spell]
end

-- Returns only the translated spells _without_ the main spell in an array (values are the lowered spellnames)
function Dominos_BuffTimes:GetSpellTranslationsArray(spell)
	return self.db.profile.translated[spell]
end

--[[
-- Returns the translated spells _and_ the main spell in a map (keys are the lowered spellnames)
-- Recreates the map on each call
function Dominos_BuffTimes:GetSpellTranslations(fromSpell)
	local ret = {}
	ret[fromSpell] = 1
	
	local toSpells = self.db.profile.translated[spell]
	if  toSpells  then
		for toSpell in pairs(toSpells) do
			ret[toSpell] = 1
		end
	end
	
	return ret
end
--]]
