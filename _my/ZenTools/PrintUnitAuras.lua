BINDING_NAME_PRINTUNITAURAS = "Print mouseover / target / focus unit's auras to General chat frame"


-- Array of text lines printed
local auraPrintout



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
	auraPrintout[#auraPrintout+1] = str
end




local serverIDs = {
	--['?'] = 'Tau',
	--['?'] = 'Ptr',
	['9'] = 'Eve',
	['B'] = 'WoD',
}


local function  PrintUnitHeader(unit)
	local guid = UnitGUID(unit)
	local name = UnitName(unit)
	local race = UnitRace(unit)
	local faction = UnitFactionGroup(unit)
	-- UnitClass(unit) returns name of npc (if npc), use UnitClassBase(unit) instead
	local class, classFileName, classIndex = UnitClassBase(unit)
	
	local classification = UnitClassification(unit)
	if  classification == 'normal'  then  classification = nil  end
	
	local extra = faction  and  classification  and  (faction ..','.. classification )
		or  faction  or  classification
	
	local prefixID = guid:sub(1, 5)
	local prefixNum = tonumber(prefixID, 16)
	local typeID = guid:sub(5, 5)
	local typeNum =  prefixNum  and  bit.band(prefixNum, 0x00F)
	--local typeNum = bit.band( tonumber(typeID, 16), 0xF)
	
	local type, ID = 'unknown', guid:sub(3)
	local linkref = type..':'..guid
	local nameWithID = name..'#'..ID
	
	--[[
	http://wowprogramming.com/docs/api_types.html#guid
	The type of unit represented by a GUID can be determined by using bit.band() to mask the first three digits with 0x00F
	0x000 - A player
	0x003 - An NPC
	0x004 - A player's pet (i.e. hunter/warlock pets and similar; non-combat pets count as NPCs)
	0x005 - A vehicle
	--]]
	
	-- GetPlayerInfoByGUID(guid)
	if  typeNum == 0  then  -- 0x010
		-- 0x0109 == Evermoon, 0x010B == WoD
		type = 'player'
		-- serverID = 1 hexadecimal number after "0x010"
		local serverID = guid:sub(6, 6)
		
		-- uid = last 8 hexadecimal numbers
		local uid = strsub(guid, 11)
		-- ID = all after serverID without the leading zeroes
		ID = strsub(guid, 7):match('^0*(.*)$')
		
		-- Short name of server
		local realm = serverIDs[serverID]
		realm = realm  and  '-'..realm  or  ''
		
		--  |Hplayer:Name:ChatID|hLinktext|h   for Player links (Click to whisper, CTRL-click to select and shift-click to do a /who Name. ChatID here refers to spam reporting
		--linkref = 'player:'..name..':'..guid
		linkref = 'player:'..name..':'..serverID..'-'..uid
		nameWithID = name..realm..'#'..serverID..'-'..ID
	
	elseif  typeNum == 3  then  -- 0xF13
		--local _ = strsub(guid, 4, 5)
		type, ID = 'npc', strsub(guid, 6, 10)
		--local spawnUID = strsub(guid, 11)
		ID =  tonumber(ID, 16)  or  ID
		linkref = 'unit:'.. guid
		nameWithID = name..'#'..ID
		--[[  |Hunit:GUID|h:Name|h
		for Unit links (Left-click opens the ItemRefTooltip frame, similar as with the Blizzard CombatLog and API_SetItemRef)
		GUID = API_UnitGUID; It accepts both with or without the hex prefix "0x".
		Name = API_UnitName; You can change "Name" to anything you want without breaking the link.
		Right-clicking will return an error, "because it will try to call Blizzard_CombatLog_CreateUnitMenu() and unitName is not given to it, so displayName == nil".
		--]]
	end
	
  local str = unit ..':  \124cff00FF96\124H'.. linkref ..'\124h['.. nameWithID ..']\124h\124r  \124cffFFF569'.. type ..'='.. ID ..'\124r'
  --str = str ..'Level '
  str = str ..'  '.. UnitLevel(unit)
	if  race  then  str = str ..' '.. race  end
	str = str .. ' '.. class
	if  extra  then  str = str .. ' (' .. extra .. ')'  end
	
	
	auraPrintout[#auraPrintout+1] = str
end




local BUFF_MAX_DISPLAY = 32
local DEBUFF_MAX_DISPLAY = 16

function  PrintUnitAuras(unit)
	unit = unit  or  UnitGUID('mouseover') and 'mouseover'  or  UnitGUID('target') and 'target'  or  UnitGUID('focus') and 'focus'
	if  not unit  then
		print('PrintUnitAuras:  No mouseover, no target, no focus.')
		return false
	end
	
	-- Start new report
	auraPrintout = {}
	PrintUnitHeader(unit)
	
	if IsAltKeyDown() then
		local guid = UnitGUID(unit)
		local name = UnitName(unit)
		auraPrintout[#auraPrintout+1] = ('GUID ('.. unit ..'):  '.. guid ..'    Name:  '.. name)
	end
	
	local filter
	--[[ Double filter works in Legion, not in MoP
	filter = 'HELPFUL|HARMFUL'
	print('Auras:')
	for  i = 1,BUFF_MAX_DISPLAY+DEBUFF_MAX_DISPLAY  do PrintUnitAura(unit, i, filter)  end
	--]]
	filter = 'HELPFUL'
	auraPrintout[#auraPrintout+1] = ('Buffs:')
	local buffsStart = #auraPrintout
	for  i = 1,BUFF_MAX_DISPLAY  do  PrintUnitAura(unit, i, filter)  end
	if  buffsStart == #auraPrintout  then  auraPrintout[#auraPrintout] = auraPrintout[#auraPrintout] .. ' \124cff00FF96none\124r'  end

	filter = 'HARMFUL'
	auraPrintout[#auraPrintout+1] = ('Debuffs:')
	buffsStart = #auraPrintout
	for  i = 1,DEBUFF_MAX_DISPLAY  do  PrintUnitAura(unit, i, filter)  end
	if  buffsStart == #auraPrintout  then  auraPrintout[#auraPrintout] = auraPrintout[#auraPrintout] .. ' \124cff00FF96none\124r'  end
	
	
	UnitAurasDB = UnitAurasDB or {}
	UnitAurasDB[#UnitAurasDB+1] = auraPrintout
	for  i, line  in ipairs(auraPrintout) do  print(line)  end
	auraPrintout = nil
end


