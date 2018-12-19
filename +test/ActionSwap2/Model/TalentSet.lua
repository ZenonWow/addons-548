--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local TalentSet = AS2.Model.TalentSet

-- Creates a new TalentSet object (and data source) with the given name.
function TalentSet:Create(name, dataContext)
	return TalentSet:CreateWithDataSource({ name = name	}, dataContext)
end

-- Creates a new TalentSet object around an existing data source.
function TalentSet:CreateWithDataSource(dataSource, dataContext)
	assert(dataSource and dataContext, "NIL_ARGUMENT")
	self = self:Derive()
	local qcTableCache = dataContext:GetQCTableCache()

	-- Validate the data source
	if not dataSource.name then dataSource.name = "New Talent Set" end
	if not dataSource.backups then dataSource.backups = { } end
	
	self.talentsTable = qcTableCache:GetTableAt(dataSource.talentsTable)
	if not self.talentsTable then
		self.talentsTable = qcTableCache:CreateTable()
		dataSource.talentsTable = self.talentsTable:GetIndex()
	end
	self.talentsTable:Keep()

	-- Synchronize the object model to the data source
	self.dataSource = dataSource
	self.qcTableCache = qcTableCache
	self.backupList = AS2.Model.BackupList:CreateWithDataSource(dataSource.backups, dataContext)
	self.backupList:KeepTables("talentsTable")	-- (save these tables from garbage collection)

	AS2:RegisterMessage(self, "ContentChanged")

	return self
end

-- MAINTENANCE: Almost all of this functionality seems like it could be provided in the base class instead.

-- Returns the data source for this talent set.
function TalentSet:GetDataSource()
	return self.dataSource
end

-- Returns the name of this talent set.
function TalentSet:GetName()
	return self.dataSource.name
end

-- Sets the name of this talent set.
function TalentSet:SetName(name)
	self.dataSource.name = name
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the icon for this global keyset.
function TalentSet:GetIcon()
	return self.dataSource.icon
end

-- Sets the icon for this global keyset.
function TalentSet:SetIcon(filename)
	self.dataSource.icon = filename
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the talents table associated with this talent set.
function TalentSet:GetTalentsTable()
	return self.talentsTable
end

-- Returns the talent set's list of backups.
function TalentSet:GetBackupList()
	return self.backupList
end

-- Returns the talent in the given slot, or nil if none is in the slot.
function TalentSet:GetTalent(slot)
	assert(slot >= 1 and slot <= AS2.NUM_TALENT_SLOTS)
	return self.talentsTable:GetValue(slot)
end

-- Sets the talent in the given slot (nil represents no data).
function TalentSet:SetTalent(slot, talentID)
	assert(slot >= 1 and slot <= AS2.NUM_TALENT_SLOTS)
	self.talentsTable:SetValue(slot, talentID)
end

-- Fills a backup object with data.
function TalentSet:private_FillBackup(backupEntry)
	-- (if you add more tables, remember to Keep() them up top!)
	backupEntry.talentsTable = self.qcTableCache:CloneTable(self.talentsTable):GetIndex()
end

-- Creates a new backup entry and returns it
function TalentSet:CreateBackup()
	local backupEntry = self.backupList:CreateBackupEntry()
	if backupEntry then self:private_FillBackup(backupEntry) end
	return backupEntry
end

function TalentSet:CreateManualBackup()
	local backup = self:CreateBackup()
	self.backupList:AddManualBackup(backup)
	return backup
end

function TalentSet:CreateAutomatedBackup()
	local backup = self:CreateBackup()
	self.backupList:AddAutomatedBackup(backup)
	return backup
end

-- Restores this talent set's data from a backup entry.
function TalentSet:RestoreFromBackup(backupEntry)
	-- Clone the backup's tables, and also validate the backup by creating any tables that don't exist.
	local talentsTable = self.qcTableCache:GetTableAt(backupEntry.talentsTable)
	if not talentsTable then
		talentsTable = self.qcTableCache:CreateTable()
	else
		talentsTable = self.qcTableCache:CloneTable(talentsTable)
	end

	-- Put the new tables into our data source to restore the backup.
	self.talentsTable = talentsTable
	self.dataSource.talentsTable = talentsTable:GetIndex()
end
