--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local BackupList = AS2.Model.BackupList

local BACKUP_LIMIT_SOFT = 15
local BACKUP_LIMIT_HARD = 20

local SECONDS_PER_DAY = 86400

local PROTECTED_FOR = SECONDS_PER_DAY * 7	-- Protected backups can't be deleted until this much time has passed

BackupList.BACKUP_SLOT_EXPIRATION_OFFSETS = {
	0 * SECONDS_PER_DAY,	-- Expires after today (i.e., this backup was created today)
	1 * SECONDS_PER_DAY,	-- Expires after one day
	2 * SECONDS_PER_DAY,	-- Expires after two days
	3 * SECONDS_PER_DAY,	-- Three days, etc.
	7 * SECONDS_PER_DAY,
	15 * SECONDS_PER_DAY,
	31 * SECONDS_PER_DAY
}

-- Creates a BackupList object around an existing data source.
function BackupList:CreateWithDataSource(dataSource, dataContext)
	assert(dataSource, "NIL_ARGUMENT")
	self = self:Derive()

	-- Validate the data source
	if not dataSource.automatedBackups then dataSource.automatedBackups = { } end
	if not dataSource.manualBackups then dataSource.manualBackups = { } end

	-- Synchronize the object model to the data source
	self.dataSource = dataSource
	self.dataContext = dataContext
	self.qcTableCache = dataContext:GetQCTableCache()

	AS2:RegisterMessage(self, "ContentChanged")
	
	return self
end

-- Removes all backups (automated and manual).
function BackupList:RemoveAll()
	for i = self:GetAutomatedBackupCount(), 1, -1 do
		self:RemoveAutomatedBackupAt(i)
	end
	for i = self:GetManualBackupCount(), 1, -1 do
		self:RemoveManualBackupAt(i)
	end
end

-- Saves all tables with the given name on any entry from garbage collection.
function BackupList:KeepTables(...)
	for i = 1, select('#', ...) do
		local tableName = select(i, ...)
		for _, entry in ipairs(self.dataSource.automatedBackups) do if entry[tableName] then self.qcTableCache:KeepTableAt(entry[tableName]) end end
		for _, entry in ipairs(self.dataSource.manualBackups) do if entry[tableName] then self.qcTableCache:KeepTableAt(entry[tableName]) end end
	end
end

-- Performs the given function on all tables with the given name.
function BackupList:ForEachTable(fn, ...)
	for i = 1, select('#', ...) do
		local tableName = select(i, ...)
		for _, entry in ipairs(self.dataSource.automatedBackups) do if entry[tableName] then fn(self.qcTableCache:GetTableAt(entry[tableName])) end end
		for _, entry in ipairs(self.dataSource.manualBackups) do if entry[tableName] then fn(self.qcTableCache:GetTableAt(entry[tableName])) end end
	end
end

function BackupList:GetDataContext()
	return self.dataContext
end

function BackupList:CreateBackupEntry()
	return { time = AS2.activeGameModel:GetTime() }
end

-- Creates a new entry for an automated backup, removing old automated backups as necessary.  Returns
-- the entry, or nil if it was rejected due to existing backups.
function BackupList:AddAutomatedBackup(backupEntry)
	local dataSource = self.dataSource
	local backupTime = backupEntry.time
	local baseTime = BackupList.friend_GetDayBaseTime(backupTime)	-- (should return something constant, but prior, like 3 AM)
	local isProtected = backupEntry.isProtected and baseTime - backupEntry.time <= PROTECTED_FOR
	assert(backupTime >= baseTime)	-- (if this isn't true, something's wrong with the base time calculation...)

	-- Reject the backup if it would've been immediately tossed due to a more mature one filling the slot.
	if not isProtected and dataSource.automatedBackups[1] and baseTime - dataSource.automatedBackups[1].time <= self.BACKUP_SLOT_EXPIRATION_OFFSETS[1] and dataSource.automatedBackups[1].time <= backupTime then
		return nil
	end

	-- Add the backup entry at the front of the list (since it's the newest).
	tinsert(dataSource.automatedBackups, 1, backupEntry)

	-- Try to keep the oldest backup entry that's not expired for each time slot, but keep at least one entry in each slot.
	local i = 1
	local j = 1
	while i <= #dataSource.automatedBackups and j <= #self.BACKUP_SLOT_EXPIRATION_OFFSETS do
		local nextEntry = dataSource.automatedBackups[i + 1]
		if not nextEntry or baseTime - nextEntry.time > self.BACKUP_SLOT_EXPIRATION_OFFSETS[j] or nextEntry.time > backupTime then
			-- Keep this entry; it's either the first one we checked, or the last one that didn't expire.
			-- (also, "future" backups are always considered to be expired, so they get replaced quickly)
			dataSource.automatedBackups[i].toss = nil
			j = j + 1	-- (go to the next time slot)
		else
			dataSource.automatedBackups[i].toss = true
		end
		i = i + 1
	end

	-- Mark the remaining entries as tossable
	while i <= #dataSource.automatedBackups do
		dataSource.automatedBackups[i].toss = true
		i = i + 1
	end

	-- Go through the backup list in reverse, tossing the marked entries
	assert(not backupEntry.toss or isProtected)	-- (removal of the added entry should have been prevented at the top of this function)
	for i = #dataSource.automatedBackups, 1, -1 do
		local e = dataSource.automatedBackups[i]
		if e.toss and (not e.isProtected or baseTime - e.time > PROTECTED_FOR) then
			tremove(dataSource.automatedBackups, i)
		end
	end

	AS2:SendMessage(self, "ContentChanged", self)

	return backupEntry
end

-- Returns the number of automated backups in this backup list.
function BackupList:GetAutomatedBackupCount()
	return #self.dataSource.automatedBackups
end

-- Returns the automated backup entry at the given index, or nil if none is at that index.
function BackupList:GetAutomatedBackupAt(index)
	return self.dataSource.automatedBackups[index]
end

-- Removes the automated backup entry at the given index.
function BackupList:RemoveAutomatedBackupAt(index)
	assert(index >= 1 and index <= #self.dataSource.automatedBackups, "INVALID_ID")
	tremove(self.dataSource.automatedBackups, index)
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Creates a new manual backup entry and returns (backup, index)
function BackupList:AddManualBackup(backupEntry)
	local backupCount = #self.dataSource.manualBackups
	if backupCount >= BACKUP_LIMIT_HARD then
		-- Warn AND prevent backup creation.
		AS2:ShowDialog(AS2.Popups.BACKUP_LIMIT_HARD)
		return
	elseif backupCount >= BACKUP_LIMIT_SOFT then
		-- Warn, but don't prevent backup creation.
		AS2:ShowDialog(AS2.Popups.BACKUP_LIMIT_SOFT)
	end

	tinsert(self.dataSource.manualBackups, 1, backupEntry)
	
	AS2:SendMessage(self, "ContentChanged", self)

	return backupEntry, 1
end

-- Returns the number of manual backups in this backup list.
function BackupList:GetManualBackupCount()
	return #self.dataSource.manualBackups
end

-- Returns the manual backup entry at the given index, or nil if none is at that index.
function BackupList:GetManualBackupAt(index)
	return self.dataSource.manualBackups[index]
end

-- Removes the manual backup entry at the given index.
function BackupList:RemoveManualBackupAt(index)
	assert(index >= 1 and index <= #self.dataSource.manualBackups, "INVALID_ID")
	tremove(self.dataSource.manualBackups, index)
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Sets the name of the manual backup at the given index.
function BackupList:SetManualBackupName(index, name)
	assert(index >= 1 and index <= #self.dataSource.manualBackups, "INVALID_ID")
	if name == "" then name = nil end
	self.dataSource.manualBackups[index].name = name
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the time() value at which a day officially starts, as far as backups are concerned.
function BackupList.friend_GetDayBaseTime(timeValue)
	local t = date("*t", timeValue)

	-- Return the previous 3 AM
	if t.hour < 3 then
		t = date("*t", timeValue - 3 * 3600 - 1)
	end
	t.hour = 3
	t.min = 0
	t.sec = 0
	return time(t)
end
