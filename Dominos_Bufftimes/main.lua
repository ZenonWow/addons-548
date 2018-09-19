--[[
	Updater.lua
		Handles ranged updating + buff highlighting updating
--]]

-- Original code by Tuller. Modified by Starslayer.

Dominos_BuffTimes = LibStub("AceAddon-3.0"):NewAddon("Dominos_BuffTimes", 'AceConsole-3.0')

local PLAYER_UNITS = {
	player = true,
	vehicle = true,
	pet = true,
};

--[[ Dominos_BuffTimes functions ]]--

function Dominos_BuffTimes:CheckDB()
	-- populate db with default values if none are present
	local _, playerClass = UnitClass("player")
	local _, playerRace = UnitRace("player")
	
	if not self.db.char.ignored then
		self.db.char.ignored = {}
		
		if playerClass == 'WARRIOR' then
			self.db.char.ignored['mortal strike'] = 1
		elseif playerClass == 'PALADIN' then
			self.db.char.ignored['judgement of light'] = 1
		end
		
		
		self.db.char.yourbuffs = {}
		
		if playerClass == 'PRIEST' then
			self.db.char.yourbuffs['renew'] = 1
		end
		
		self.db.char.alldebuffs = {}
		
		if playerClass == 'WARLOCK' then
			self.db.char.alldebuffs['banish'] = 1
			self.db.char.alldebuffs['fear'] = 1
		end
	end
	
	if not self.db.char.selfbuffs then
		self.db.char.selfbuffs = {}
		
		if playerClass == 'WARRIOR' then
			self.db.char.selfbuffs['bloodrage'] = 1
			self.db.char.selfbuffs['retaliation'] = 1
			self.db.char.selfbuffs['shield wall'] = 1
			self.db.char.selfbuffs['berserker rage'] = 1
			self.db.char.selfbuffs['recklessness'] = 1
			self.db.char.selfbuffs['spell reflection'] = 1
			self.db.char.selfbuffs['enraged regeneration'] = 1
			self.db.char.selfbuffs['death wish'] = 1
			self.db.char.selfbuffs['rampage'] = 1
			self.db.char.selfbuffs['sweeping strikes'] = 1
			self.db.char.selfbuffs['bladestorm'] = 1
			self.db.char.selfbuffs['last stand'] = 1
		elseif playerClass == 'DEATHKNIGHT' then
			self.db.char.selfbuffs['icebound fortitude'] = 1
			self.db.char.selfbuffs['anti-magic shell'] = 1
			self.db.char.selfbuffs['vampiric blood'] = 1
			self.db.char.selfbuffs['dancing rune weapon'] = 1
			self.db.char.selfbuffs['lichborne'] = 1
			self.db.char.selfbuffs['deathchill'] = 1
			self.db.char.selfbuffs['unbreakable armor'] = 1
			self.db.char.selfbuffs['bone shield'] = 1
		elseif playerClass == 'DRUID' then
			self.db.char.selfbuffs['berserk'] = 1
			self.db.char.selfbuffs['survival instincts'] = 1
			self.db.char.selfbuffs['enrage'] = 1
			self.db.char.selfbuffs['frenzied regeneration'] = 1
			self.db.char.selfbuffs['tiger\'s fury'] = 1
			self.db.char.selfbuffs['dash'] = 1
			self.db.char.selfbuffs['barkskin'] = 1
		elseif playerClass == 'HUNTER' then
			self.db.char.selfbuffs['eyes of the beast'] = 1
			self.db.char.selfbuffs['deterrence'] = 1
			self.db.char.selfbuffs['rapid fire'] = 1
		elseif playerClass == 'MAGE' then
			self.db.char.selfbuffs['frost armor'] = 1
			self.db.char.selfbuffs['slow fall'] = 1
			self.db.char.selfbuffs['evocation'] = 1
			self.db.char.selfbuffs['fire ward'] = 1
			self.db.char.selfbuffs['mana shield'] = 1
			self.db.char.selfbuffs['frost ward'] = 1
			self.db.char.selfbuffs['ice armor'] = 1
			self.db.char.selfbuffs['molten armor'] = 1
			self.db.char.selfbuffs['invisibility'] = 1
			self.db.char.selfbuffs['arcane power'] = 1
			self.db.char.selfbuffs['icy veins'] = 1
			self.db.char.selfbuffs['ice barrier'] = 1
		elseif playerClass == 'PALADIN' then
			self.db.char.selfbuffs['seal of righteousness'] = 1
			self.db.char.selfbuffs['divine protection'] = 1
			self.db.char.selfbuffs['righteous fury'] = 1
			self.db.char.selfbuffs['seal of justice'] = 1
			self.db.char.selfbuffs['seal of light'] = 1
			self.db.char.selfbuffs['divine shield'] = 1
			self.db.char.selfbuffs['seal of wisdom'] = 1
			self.db.char.selfbuffs['seal of blood'] = 1
			self.db.char.selfbuffs['seal of vengeance'] = 1
			self.db.char.selfbuffs['seal of the martyr'] = 1
			self.db.char.selfbuffs['avenging wrath'] = 1
			self.db.char.selfbuffs['divine illumination'] = 1
			self.db.char.selfbuffs['seal of command'] = 1
		elseif playerClass == 'PRIEST' then
			self.db.char.selfbuffs['inner fire'] = 1
			self.db.char.selfbuffs['dispersion'] = 1
		elseif playerClass == 'ROGUE' then
			self.db.char.selfbuffs['evasion'] = 1
			self.db.char.selfbuffs['sprint'] = 1
			self.db.char.selfbuffs['slice and dice'] = 1
			self.db.char.selfbuffs['vanish'] = 1
			self.db.char.selfbuffs['cloak of shadows'] = 1
			self.db.char.selfbuffs['hunger for blood'] = 1
			self.db.char.selfbuffs['blade flurry'] = 1
			self.db.char.selfbuffs['adrenaline rush'] = 1
			self.db.char.selfbuffs['shadow dance'] = 1
		elseif playerClass == 'SHAMAN' then
			self.db.char.selfbuffs['rockbiter weapon'] = 1
			self.db.char.selfbuffs['lightning shield'] = 1
			self.db.char.selfbuffs['flametongue weapon'] = 1
			self.db.char.selfbuffs['frostbrand weapon'] = 1
			self.db.char.selfbuffs['water shield'] = 1
			self.db.char.selfbuffs['far sight'] = 1
			self.db.char.selfbuffs['earthliving weapon'] = 1
			self.db.char.selfbuffs['shamanistic rage'] = 1
			self.db.char.selfbuffs['bloodlust'] = 1
			self.db.char.selfbuffs['heroism'] = 1
		elseif playerClass == 'WARLOCK' then
			self.db.char.selfbuffs['demon skin'] = 1
			self.db.char.selfbuffs['demon armor'] = 1
			self.db.char.selfbuffs['eye of kilrogg'] = 1
			self.db.char.selfbuffs['shadow ward'] = 1
			self.db.char.selfbuffs['fel armor'] = 1
			self.db.char.selfbuffs['demonic sacrifice'] = 1
			self.db.char.selfbuffs['soul link'] = 1
			self.db.char.selfbuffs['metamorphosis'] = 1
			self.db.char.selfbuffs['soul swap'] = 1
		elseif playerClass == 'MONK' then
			self.db.char.selfbuffs['tiger power'] = 1
			self.db.char.selfbuffs['energizing brew'] = 1
			self.db.char.selfbuffs['nimble brew'] = 1
		end
		
		if playerRace == 'Troll' then
			self.db.char.selfbuffs['berserking'] = 1
		elseif playerRace == 'Dwarf' then
			self.db.char.selfbuffs['stoneform'] = 1
		elseif playerRace == 'NightElf' then
			self.db.char.selfbuffs['shadowmeld'] = 1
		elseif playerRace == 'Orc' then
			self.db.char.selfbuffs['blood fury'] = 1
		end
	end
	
	if not self.db.char.translated then
		self.db.char.translated = {}
		if playerClass == 'DEATHKNIGHT' then
			self.db.char.translated['plague strike'] = {}
			self.db.char.translated['plague strike']['blood plague'] = 1
			self.db.char.translated['icy touch'] = {}
			self.db.char.translated['icy touch']['frost fever'] = 1
		elseif playerClass == 'WARRIOR' then
			self.db.char.translated['devastate'] = {}
			self.db.char.translated['devastate']['sunder armor'] = 1
		elseif playerClass == 'MAGE' then
			self.db.char.translated['scorch'] = {}
			self.db.char.translated['scorch']['improved scorch'] = 1
		elseif playerClass == 'WARLOCK' then
			self.db.char.translated['soul swap exhale'] = {}
			self.db.char.translated['soul swap exhale']['soul swap'] = 1
		elseif playerClass == 'MONK' then
			self.db.char.translated['tiger palm'] = {}
			self.db.char.translated['tiger palm']['tiger power'] = 1
		end
	else
		-- convert existing spell translations to lower case
		local newTranslatedSpells = {}
		for spell in pairs(self.db.char.translated) do
			local lowerSpell = string.lower(spell)
			newTranslatedSpells[lowerSpell] = {}
			
			for newSpell in pairs(self.db.char.translated[spell]) do
				local newLowerSpell = string.lower(newSpell)
				newTranslatedSpells[lowerSpell][newLowerSpell] = 1
			end
		end
		self.db.char.translated = newTranslatedSpells
	end
	
	-- buffs that will show even if CD is greater
	if not self.db.char.override then
		self.db.char.override = {}
		if playerClass == 'WARLOCK' then
			self.db.char.override['death coil'] = 1
			self.db.char.override['shadowflame'] = 1
		elseif playerClass == 'ROGUE' then
			self.db.char.override['vendetta'] = 1
		elseif playerClass == 'MONK' then
			self.db.char.override['tiger\'s lust'] = 1
			self.db.char.override['energizing brew'] = 1
			self.db.char.override['nimble brew'] = 1
		end
	end
end

function Dominos_BuffTimes:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("Dominos_BuffTimesDB")
	self:CheckDB()
	self:RegisterSlashCommands()
	
	self.options = {}
	self:InitOptions()
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Dominos_BuffTimes", self.options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Dominos_BuffTimes", "Dominos_BuffTimes")
end

function Dominos_BuffTimes:OnEnable()
    -- Called when the addon is enabled
end

function Dominos_BuffTimes:OnDisable()
    -- Called when the addon is disabled
end

--[[ Local Functions ]]--

--clear a table, returning true if there was stuff to clear
local function ClearTable(t)
	if next(t) then
		wipe(t)
		return true
	end
end

--remove any values from t that are not in toClone
--adds any values from tableToClone that are not in t
--requires that both tables be using the same key value pairs
local function CloneTable(from, to)
	local changed = false

	for i,oldVal in pairs(to) do
		local newVal = from[i]
		if (not newVal and oldVal) or (newVal and not oldVal) or (oldVal and newVal and (oldVal.start ~= newVal.start or oldVal.duration ~= newVal.duration)) then
			to[i] = newVal
			changed = true
		end
	end

	for i,newVal in pairs(from) do
		local oldVal = to[i]
		if (not newVal and oldVal) or (newVal and not oldVal) or (oldVal and newVal and (oldVal.start ~= newVal.start or oldVal.duration ~= newVal.duration)) then
			to[i] = newVal
			changed = true
		end
	end

	return changed
end

--[[
	The Code
--]]

local Updater = CreateFrame('Frame')

Updater.targetBuffs = {}
Updater.targetBuffs['target'] = {}
Updater.targetBuffs['focus'] = {}
Updater.playerBuffs = {}
Updater.buttons = {}

--buff and debuff caches
local newVals = {} --store new info in here

function Dominos_BuffTimes:DebugOutputTable()
	self:Print('Self:')
	self:OutputTable(Updater.playerBuffs)
	
	self:Print('Buff:')
	self:OutputTable(Updater.targetBuffs['target'])
	
	self:Print('newvals:')
	self:OutputTable(newVals)
	
end

function Dominos_BuffTimes:OutputTable(table)
	for i,val in pairs(table) do
		self:Print(i .. ': ' ..  table[i].start .. ' ' .. table[i].duration)
	end
end



--on update script, handles throttled buff and debuff updating as well as range updating
Updater:SetScript('OnUpdate', function(self, elapsed)
	if self.shouldUpdateBuffs then
		self.shouldUpdateBuffs = nil

		for _,b in pairs(self.buttons) do
		
			if b:IsVisible() and b.action and HasAction(b.action) then
				--ActionButton_UpdateState(b)
				if b.DBT_Update then
					b.DBT_Update(b)
				end
			end
		end
	end
end)
Updater.nextUpdate = 1
Updater.delay = 0.025


--[[ Update Functions ]]--

function Updater:UpdatePlayerBuffs()
	local changed = false
	
	local name, duration, expirationTime, caster
	local i = 1
	repeat
		name, _, _, _, _, duration, expirationTime, caster = UnitBuff('player', i, 1)
		local isMine = PLAYER_UNITS[caster]
		
		if name then
			name = string.lower(name)
			if isMine or (not Dominos_BuffTimes:IsYourBuff(name) and not newVals[name]) then
				newVals[name] = {}
				newVals[name].start = expirationTime - duration
				newVals[name].duration = duration
				newVals[name].isMine = isMine
			end
		end
		i = i + 1
	until not name

	if CloneTable(newVals, self.playerBuffs) then
		changed = true
	end
	
	ClearTable(newVals)

	--something changed, trigger update buffs
	if changed then
		self.shouldUpdateBuffs = true
	end
end

function Updater:UpdateTargetBuffs(unit, forceRefresh)
	local changed = false
	
	if(forceRefresh) then
		ClearTable(self.targetBuffs[unit])
	end
	
	if UnitExists(unit) then
		if UnitIsFriend('player', unit) then
			changed = self:UpdateFriendlyTargetBuffs(unit)
		else
			changed = self:UpdateEnemyTargetDebuffs(unit)
		end
	else
		changed = self:ClearTargetBuffsAndDebuffs(unit)
	end

	--if change, mark for updating
	if changed or forceRefresh then
		self.shouldUpdateBuffs = true
	end
end


function Updater:UpdateFriendlyTargetBuffs(unit)
	--friendly target, clear target debuffs
	local changed = false
	
	--add all target buffs into newVals
	local i = 1
	local name, duration, expirationTime, caster
	repeat
		name, _, _, _, _, duration, expirationTime, caster = UnitBuff(unit, i, 1)
		local isMine = PLAYER_UNITS[caster]
		
		if name then
			name = string.lower(name)
			-- prioritise our buffs over others
			if isMine or (not Dominos_BuffTimes:IsYourBuff(name) and not newVals[name]) then
				newVals[name] = {}
				newVals[name].start = expirationTime - duration
				newVals[name].duration = duration
				newVals[name].isMine = isMine
			end
		end
		i = i + 1
	until not name

	--set changed to true if the target buffs table has changed
	if CloneTable(newVals, self.targetBuffs[unit]) then
		changed = true
	end
	
	ClearTable(newVals)

	return changed
end

function Updater:UpdateEnemyTargetDebuffs(unit)
	--friendly target, clear target debuffs
	local changed = false

	--update debuffs on enemy targets
	local i = 1
	local name, duration, expirationTime, caster
	repeat
		name, _, _, _, _, duration, expirationTime, caster = UnitDebuff(unit, i)
		local isMine = PLAYER_UNITS[caster]
				
		if name then
			name = string.lower(name)
			-- prioritise our buffs over others
			if isMine or (not newVals[name] and Dominos_BuffTimes:IsAllDebuff(name)) then
				newVals[name] = {}
				newVals[name].start = expirationTime - duration
				newVals[name].duration = duration
				newVals[name].isMine = isMine
			end
		end
		i = i + 1
	until not name

	--set changed to true if the target debuffs table has changed
	if CloneTable(newVals, self.targetBuffs[unit]) then
		changed = true
	end
	
	ClearTable(newVals)

	return changed
end

function Updater:ClearTargetBuffsAndDebuffs(unit)
	local changed = false

	if ClearTable(self.targetBuffs[unit]) then
		changed = true
	end
	
	return changed
end


--[[ Access Functions ]]--

function Updater:GetTargetBuff(unit, buff)
	return self.targetBuffs[unit][buff]
end

function Updater:GetTargetDebuff(unit, debuff)
	return self.targetBuffs[unit][debuff]
end

function Updater:PlayerHasBuff(buff)
	return self.playerBuffs[buff]
end


--[[ Action Button Updating ]]--

local function ShouldShowTimer(spell, buff, spellBuff, cdstart, cdduration)
	if Dominos_BuffTimes:IsIgnored(spell) then return nil end
	
	if Dominos_BuffTimes:IsSelfBuff(spell) then return 1 end
	
	if buff == 1 and Dominos_BuffTimes:IsYourBuff(spell) and not spellBuff.isMine then return nil end
	
	if buff == 0 and not Dominos_BuffTimes:IsAllDebuff(spell) and not spellBuff.isMine then return nil end
	
	if cdstart == nil or cdduration == 0 or Dominos_BuffTimes:IsOverride(spell) or spellBuff.start + spellBuff.duration > cdstart + cdduration then return 1 end
		
	return nil
end

local function ActionButton_UpdateBorder(self, spell)
	local buff = 1
	local showBorder = nil
	
	if spell then
	    local unit = self.unit
		local spellBuff = nil
		
		-- translate spells
		spell = string.lower(spell)
		local spellsToCheck = Dominos_BuffTimes:GetSpellTranslations(spell)
		
		if Dominos_BuffTimes:IsSelfBuff(spell) then
			for i in pairs(spellsToCheck) do
				local thisSpellBuff = Updater:PlayerHasBuff(i)
				
				if thisSpellBuff then
					local start, duration, enabled
					
					if not spellBuff or thisSpellBuff.start + thisSpellBuff.duration > spellBuff.start + spellBuff.duration then
						spellBuff = thisSpellBuff
					end
				end
			end
						
			if spellBuff and spellBuff.duration == 0 then
				if self.DBTCooldown and self.DBTCooldown:IsShown() then
					CooldownFrame_SetTimer(self.DBTCooldown, 0, 0, nil)
					self.DBTOrigcooldown:Show()
				end
				return false
			end
			
			if spellBuff then
				self:GetCheckedTexture():SetVertexColor(0, 1, 0)
				showBorder = 1
			end
		else
			if UnitExists(unit) then
				if UnitIsFriend('player', unit) then
					for i in pairs(spellsToCheck) do
						local thisSpellBuff = Updater:GetTargetBuff(unit, i)
						
						if thisSpellBuff then
							local start, duration, enabled
							
							if not spellBuff or thisSpellBuff.start + thisSpellBuff.duration > spellBuff.start + spellBuff.duration then
								spellBuff = thisSpellBuff
							end
						end
					end
					
					if spellBuff then
						self:GetCheckedTexture():SetVertexColor(0, 1, 0)
						showBorder = 1
					end
				else
					buff = 0
					
					for i in pairs(spellsToCheck) do
						local thisSpellBuff = Updater:GetTargetDebuff(unit, i)
						
						if thisSpellBuff then
							local start, duration, enabled
							
							if not spellBuff or thisSpellBuff.start + thisSpellBuff.duration > spellBuff.start + spellBuff.duration then
								spellBuff = thisSpellBuff
							end
						end
					end
					
					if spellBuff and spellBuff.duration == 0 then 
						return false
					end
					
					if spellBuff and spellBuff.isMine and spellBuff.duration ~= 0 then
						self:GetCheckedTexture():SetVertexColor(1, 0, 1)
						showBorder = 1
					end
				end
			end
		end
			
		if spellBuff and spellBuff.start ~= nil then
			local start, duration, enabled
			start, duration, enabled = GetSpellCooldown(spell)
			
			if ShouldShowTimer(spell, buff, spellBuff, start, duration) then
				if self.DBTCooldown == nil then
					local _G = getfenv(0)
					local name = self.name
					self.DBTOrigcooldown = _G[name .. 'Cooldown']
					self.DBTCooldown = CreateFrame('Cooldown', nil, self, 'CooldownFrameTemplate')
					self.DBTCooldown:SetAllPoints(self)
				end
				self.DBTOrigcooldown:Hide()
				CooldownFrame_SetTimer(self.DBTCooldown, spellBuff.start, spellBuff.duration, 1)
			elseif self.DBTCooldown and self.DBTCooldown:IsShown() then
				CooldownFrame_SetTimer(self.DBTCooldown, 0, 0, nil)
				self.DBTOrigcooldown:Show()
			end
			
			return showBorder
		end
		
		local playerBuff = Updater:PlayerHasBuff(spell)
		if playerBuff and not UnitIsFriend('player', unit) and playerBuff.duration ~= 0 then
			self:GetCheckedTexture():SetVertexColor(0, 1, 0)

			if self.DBTCooldown ~= nil and self.DBTCooldown:IsShown() then
				CooldownFrame_SetTimer(self.DBTCooldown, 0, 0, nil)
				self.DBTOrigcooldown:Show()
			end

			return true
		end
	end
	
	if self.DBTCooldown and self.DBTCooldown:IsShown() then
		-- need to distinguish between buff dropping off and change targets
		CooldownFrame_SetTimer(self.DBTCooldown, 0, 0, nil)
		self.DBTOrigcooldown:Show()
	end
	
	return showBorder
end

local function ActionButton_CheckCooldown (self)
	if self.DBTCooldown then
		if self.DBTCooldown:IsShown() then
			self.DBTOrigcooldown:Hide()
		end
	end
end



local function ActionButton_IsSpellInUse(self)
	local spellID = self.spellID
	if spellID then
		if self.type == 'macro' then
			return ActionButton_UpdateBorder(self, GetMacroSpell(spellID))
		end
		return ActionButton_UpdateBorder(self, spellID)
	end
end

function ActionButton_GetPagedID (self)
    return self.action;
end

local BT4ButtonPrefix = 'BT4Button'

local function IsBT4Button(name)
	return name and string.sub(name, 1, string.len(BT4ButtonPrefix)) == BT4ButtonPrefix 
end

local function ActionButton_UpdateSpell(self)
    if not self.name then
    	-- must be a Blizzard button
    	self.name = self:GetName()
    end
    
    if IsBT4Button(self.name) then
    	local type, id = self:GetAction()
    	if type == 'action' then
    	    self.action = id
    	else
    	    self.action = nil
    	end
    end
    		
    if self.action then
		local type, id, _, globalID = GetActionInfo(self.action)
		self.unit = 'target'
		self.type = type
		
		if type == 'spell' then
			if id and id > 0 then
			    self.spellID = GetSpellInfo(id)
			elseif globalID then
				self.spellID = GetSpellInfo(globalID)
			else
				self.spellID = nil
			end
		elseif type == 'item' then
			self.spellID = GetItemSpell(id)
		else
			self.spellID = id
			local macroSpell = GetMacroSpell(self.spellID)
		end
		
		if type == 'macro' then
			local macroName, macroIcon, macroBody, macroLocal = GetMacroInfo(id)
			
			if macroName ~= nil then
				-- check if we have ' Focus' in the macro name, if so, target is 'focus' for this button
				local startPos, endPos = string.find(macroName, '%sFocus')
			
				if startPos ~= nil then
					self.unit = 'focus'
				end
			end
		end
	end
end

local function ActionButton_UpdateStateHook(self)
	local isChecked = self:GetChecked()
    local shouldBeChecked = ActionButton_IsSpellInUse(self) or isChecked
    
    if isChecked ~= shouldBeChecked then
    	self:SetChecked(shouldBeChecked)
    end
end

hooksecurefunc('ActionButton_UpdateState', ActionButton_UpdateStateHook)
hooksecurefunc('ActionButton_Update', ActionButton_UpdateSpell)
hooksecurefunc('ActionButton_UpdateCooldown', ActionButton_CheckCooldown)

--[[ Events ]]--

--buff and debuff updating stuff
Updater:SetScript('OnEvent', function(self, event, unit)
	if event == 'PLAYER_TARGET_CHANGED' then
		self:UpdateTargetBuffs('target', true)
	elseif event == 'PLAYER_FOCUS_CHANGED' then
		self:UpdateTargetBuffs('focus', true)
	elseif event == 'UNIT_AURA' then
		if unit == 'target' or unit == 'focus' then
			self:UpdateTargetBuffs(unit)
		elseif unit == 'player' then
			self:UpdatePlayerBuffs()
		end
	elseif event == 'PLAYER_ENTERING_WORLD' then
		self:UpdateTargetBuffs('target')
		self:UpdateTargetBuffs('focus')
		self:UpdatePlayerBuffs()
	elseif event == 'ACTIONBAR_UPDATE_COOLDOWN' or event == 'ACTIONBAR_UPDATE_STATE' then
		self.shouldUpdateBuffs = true
	end
end)

Updater:RegisterEvent('UNIT_AURA')
Updater:RegisterEvent('PLAYER_TARGET_CHANGED')
Updater:RegisterEvent('PLAYER_FOCUS_CHANGED')
Updater:RegisterEvent('PLAYER_ENTERING_WORLD')

Updater:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
Updater:RegisterEvent('ACTIONBAR_UPDATE_STATE')

--[[ Loading ]]--

--register buttons
local function RegisterButton(button, updateHook)
	if button then
		table.insert(Updater.buttons, button)
		button.DBT_Update = updateHook
	end
end

for id = 1, NUM_ACTIONBAR_BUTTONS do
	RegisterButton(_G['ActionButton' .. id], ActionButton_UpdateState)
	RegisterButton(_G['BonusActionButton' .. id], ActionButton_UpdateState)
	RegisterButton(_G['MultiBarRightButton' .. id], ActionButton_UpdateState)
	RegisterButton(_G['MultiBarLeftButton' .. id], ActionButton_UpdateState)
	RegisterButton(_G['MultiBarBottomRightButton' .. id], ActionButton_UpdateState)
	RegisterButton(_G['MultiBarBottomLeftButton' .. id], ActionButton_UpdateState)
end

local function LAB_Update(self)
	self:UpdateAction(true)
end

local DominosButtonPrefix = 'DominosActionButton'

if Dominos then
	for id = 1, 120 do
		if _G[DominosButtonPrefix .. id] then
			RegisterButton(_G[DominosButtonPrefix .. id], ActionButton_UpdateState)
		end
	end
end

if Bartender4 then
	for id = 1, 120 do
		if _G[BT4ButtonPrefix .. id] then
			RegisterButton(_G[BT4ButtonPrefix .. id], LAB_Update)
		end
	end
end

--register any stock action buttons created after this addon is loaded
hooksecurefunc('ActionButton_OnLoad', function(self)
	table.insert(Updater.buttons, self)
	RegisterButton(self, ActionButton_UpdateState)
end)

-- register LibActionButton hooks
local LAB = LibStub("LibActionButton-1.0", true)

if LAB then
	LAB.RegisterCallback(Dominos_BuffTimes, "OnButtonCreated", function(_, button)
		RegisterButton(button, LAB_Update)
	end)
	LAB.RegisterCallback(Dominos_BuffTimes, "OnButtonUpdate", function(_, button) ActionButton_UpdateSpell(button) end)
	LAB.RegisterCallback(Dominos_BuffTimes, "OnButtonState", function(_, button) ActionButton_UpdateStateHook(button) end)
end

