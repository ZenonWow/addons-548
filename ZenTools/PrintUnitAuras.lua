BINDING_NAME_PRINTUNITAURAS = "Print mouseover / target / focus unit's auras to General chat frame"


local function toTimeString(sec)
	local d,h,m,s
	s = math.floor( sec % 60 * 100 ) / 100	-- 2 decimals
	m = math.floor( sec / 60 % 60 )
	h = math.floor( sec / 3600 % 24 )
	d = math.floor( sec / 3600 / 24 )
	--[[
	s = math.floor( mod(sec,60) * 100 ) / 100	-- 2 decimals
	m = math.floor( mod(sec/60,60) )
	h = math.floor( mod(sec/3600,24) )
	d = math.floor( sec/3600/24 )
	--]]
	str = ''
	if  0 < d  then  str = str .. d ..'d '  end
	if  0 < h  or  0 < #str  then  str = str .. h ..'h '  end
	if  0 < m  or  0 < #str  then  str = str .. m ..'m '  end
	str = str .. s ..'s'
	return str
end

function PrintUnitAura(unit, index, filter)
	--local spellName,rank,_,count,debuffType,duration,expirationTime,_,_,_,spellId = UnitAura(unit,i,nil,nil,'HELPFUL|HARMFUL')  -- Legion, maybe wrong?, don't remember seeing debuffs
	local spellName,rank,texture,count,debuffType,duration,expirationTime,_,_,shouldConsolidate,spellId = UnitAura(unit, index, filter)  -- MoP
	if  spellName == nil  then  return  end
	
	local spellLink = GetSpellLink(spellId)
	--spellLink =  spellLink  and  spellLink:gsub('\124r$','#'.. spellId ..'\124r')  or  'Unknown'
	spellLink = spellLink  or  'Unknown'
	local strLeft = 'infinite'
	if  0 < expirationTime  then  strLeft = toTimeString(expirationTime - GetTime()) ..' left'  end
	local strCount = ''
	if  0 < count  then  strCount = ', '.. count ..' stacks'  end
	debuffType =  debuffType  and  ', '.. debuffType  or  ''
	
	local str = index ..'. spell='.. spellId ..' '.. spellLink ..'  '.. strLeft .. strCount .. debuffType
	print(str)

end


local serverIDs = {
	['09'] = 'Evermoon',
	['0B'] = 'WoD',
}

local BUFF_MAX_DISPLAY = 32
local DEBUFF_MAX_DISPLAY = 16

function  PrintUnitAuras(unit)
	unit = unit  or  UnitGUID('mouseover') and 'mouseover'  or  UnitGUID('target') and 'target'  or  UnitGUID('focus') and 'focus'
	if  not unit  then
		print('PrintUnitAuras:  No mouseover, no target, no focus.')
		return false
	end
	
	local name = UnitName(unit)
	local guid = UnitGUID(unit)
	local race = UnitRace(unit)
	local faction = UnitFactionGroup(unit)
	local class, classFileName, classIndex = UnitClass(unit)
	-- class is name of npc (if npc)
	if  class == name  then  class = classFileName:lower()  end
	
	local classification = UnitClassification(unit)
	if  classification == 'normal'  then  classification = nil  end
	
	local extra = faction  and  classification  and  (faction ..','.. classification )
		or  faction  or  classification
	
	local idType = guid:sub(1, 4)
	local type, id = 'unknown', guid
	local link = type ..':'.. guid
	if  idType == '0x01'  then
		-- 0x0109 == Evermoon, 0x010B == WoD
		local idServer = guid:sub(5, 6)
		local server = serverIDs[idServer]
		server = server  and  server ..' '  or  ''
		server = server ..' ('.. idServer ..'h)'
		type, id = 'player', '0x'.. strsub(guid, 13) ..' on '.. server
		link = type ..':'.. name
	elseif  idType == '0xF1'  then  -- 0xF130
		type, id = 'npc', '0x'.. strsub(guid, 7, 10)
		link = type ..':'.. id
	end
	
  local str = unit ..':  \124cff00ff96'.. type ..'='.. id ..' \124H'.. link ..'\124h['.. name ..']\124h\124r  '
  --str = str ..'Level '
  str = str .. UnitLevel(unit)
	if  race  then  str = str ..' '.. race  end
	str = str .. ' '.. class
	if  extra  then  str = str .. ' (' .. extra .. ')'  end
	print(str)
	
	
	if IsAltKeyDown() then  print('GUID ('.. unit ..'):  '.. guid ..'    Name:  '.. name)  end
	
	local filter
	--[[
	filter = 'HELPFUL|HARMFUL'
	print('Auras:')
	for  i = 1,BUFF_MAX_DISPLAY+DEBUFF_MAX_DISPLAY  do PrintUnitAura(unit, i, filter)  end
	--]]
	filter = 'HELPFUL'
	print('Buffs:')
	for  i = 1,BUFF_MAX_DISPLAY  do  PrintUnitAura(unit, i, filter)  end

	filter = 'HARMFUL'
	print('Debuffs:')
	for  i = 1,DEBUFF_MAX_DISPLAY  do  PrintUnitAura(unit, i, filter)  end
end


