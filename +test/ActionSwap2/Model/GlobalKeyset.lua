--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local GlobalKeyset = AS2.Model.GlobalKeyset

-- Creates a new GlobalKeyset object (and data source) with the given name.
function GlobalKeyset:Create(name, dataContext)
	return GlobalKeyset:CreateWithDataSource({ name = name	}, dataContext)
end

-- Creates a new GlobalKeyset object around an existing data source.
function GlobalKeyset:CreateWithDataSource(dataSource, dataContext)
	assert(dataSource and dataContext, "NIL_ARGUMENT")
	self = self:Derive()
	local qcTableCache = dataContext:GetQCTableCache()

	-- Validate the data source
	if not dataSource.name then dataSource.name = "New Keyset" end
	if not dataSource.backups then dataSource.backups = { } end

	self.keybindingsTable = qcTableCache:GetTableAt(dataSource.keybindingsTable)
	if not self.keybindingsTable then
		self.keybindingsTable = qcTableCache:CreateTable()
		dataSource.keybindingsTable = self.keybindingsTable:GetIndex()
	end
	self.keybindingsTable:Keep()

	-- Synchronize the object model to the data source
	self.dataSource = dataSource
	self.qcTableCache = qcTableCache
	self.backupList = AS2.Model.BackupList:CreateWithDataSource(dataSource.backups, dataContext)
	self.backupList:KeepTables("keybindingsTable")	-- (save these tables from garbage collection)

	AS2:RegisterMessage(self, "ContentChanged")

	return self
end

-- Returns the data source for this global keyset.
function GlobalKeyset:GetDataSource()
	return self.dataSource
end

-- Returns the name of this global keyset.
function GlobalKeyset:GetName()
	return self.dataSource.name
end

-- Sets the name of this global keyset.
function GlobalKeyset:SetName(name)
	self.dataSource.name = name
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the icon for this global keyset.
function GlobalKeyset:GetIcon()
	return self.dataSource.icon
end

-- Sets the icon for this global keyset.
function GlobalKeyset:SetIcon(filename)
	self.dataSource.icon = filename
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the keybindings table associated with this global keyset.
function GlobalKeyset:GetKeybindingsTable()
	return self.keybindingsTable
end

-- Returns the global keyset's list of backups.
function GlobalKeyset:GetBackupList()
	return self.backupList
end

-- Fills a backup object with data.
function GlobalKeyset:private_FillBackup(backupEntry)
	-- (if you add more tables, remember to Keep() them up top!)
	backupEntry.keybindingsTable = self.qcTableCache:CloneTable(self.keybindingsTable):GetIndex()
end

-- Creates a new backup entry and returns it
function GlobalKeyset:CreateBackup()
	local backupEntry = self.backupList:CreateBackupEntry()
	if backupEntry then self:private_FillBackup(backupEntry) end
	return backupEntry
end

function GlobalKeyset:CreateManualBackup()
	local backup = self:CreateBackup()
	self.backupList:AddManualBackup(backup)
	return backup
end

function GlobalKeyset:CreateAutomatedBackup()
	local backup = self:CreateBackup()
	self.backupList:AddAutomatedBackup(backup)
	return backup
end

-- Restores this global keyset's data from a backup entry.
function GlobalKeyset:RestoreFromBackup(backupEntry)
	-- Clone the backup's tables, and also validate the backup by creating any tables that don't exist.
	local keybindingsTable = self.qcTableCache:GetTableAt(backupEntry.keybindingsTable)
	if not keybindingsTable then
		keybindingsTable = self.qcTableCache:CreateTable()
	else
		keybindingsTable = self.qcTableCache:CloneTable(keybindingsTable) 
	end

	-- Put the new tables into our data source to restore the backup.
	self.keybindingsTable = keybindingsTable
	self.dataSource.keybindingsTable = keybindingsTable:GetIndex()
end
