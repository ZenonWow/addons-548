--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local GlyphSet = AS2.Model.GlyphSet

-- Creates a new GlyphSet object (and data source) with the given name.
function GlyphSet:Create(name, dataContext)
	return GlyphSet:CreateWithDataSource({ name = name }, dataContext)
end

-- Creates a new GlyphSet object around an existing data source.
function GlyphSet:CreateWithDataSource(dataSource, dataContext)
	assert(dataSource and dataContext, "NIL_ARGUMENT")
	self = self:Derive()
	local qcTableCache = dataContext:GetQCTableCache()

	-- Validate the data source
	if not dataSource.name then dataSource.name = "New Glyph Set" end
	if not dataSource.backups then dataSource.backups = { } end
	
	self.glyphsTable = qcTableCache:GetTableAt(dataSource.glyphsTable)
	if not self.glyphsTable then
		self.glyphsTable = qcTableCache:CreateTable()
		dataSource.glyphsTable = self.glyphsTable:GetIndex()
	end
	self.glyphsTable:Keep()

	-- Synchronize the object model to the data source
	self.dataSource = dataSource
	self.qcTableCache = qcTableCache
	self.backupList = AS2.Model.BackupList:CreateWithDataSource(dataSource.backups, dataContext)
	self.backupList:KeepTables("glyphsTable")	-- (save these tables from garbage collection)

	-- UPGRADE: Upgrade the glyph set from revision 7- (Cataclysm) to revision 8 (Mists of Pandaria), if not already done
	self:UpgradeToRevision8()

	AS2:RegisterMessage(self, "ContentChanged")

	return self
end

-- Returns the data source for this glyph set.
function GlyphSet:GetDataSource()
	return self.dataSource
end

-- Returns the name of this glyph set.
function GlyphSet:GetName()
	return self.dataSource.name
end

-- Sets the name of this glyph set.
function GlyphSet:SetName(name)
	self.dataSource.name = name
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the icon for this global keyset.
function GlyphSet:GetIcon()
	return self.dataSource.icon
end

-- Sets the icon for this global keyset.
function GlyphSet:SetIcon(filename)
	self.dataSource.icon = filename
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the glyphs table associated with this glyph set.
function GlyphSet:GetGlyphsTable()
	return self.glyphsTable
end

-- Returns the glyph set's list of backups.
function GlyphSet:GetBackupList()
	return self.backupList
end

-- Returns the glyph in the given slot, or nil if none is in the slot.
function GlyphSet:GetGlyph(slot)
	assert(slot >= 1 and slot <= AS2.NUM_GLYPH_SLOTS)
	return self.glyphsTable:GetValue(slot)
end

-- Sets the glyph in the given slot (nil represents no data).
function GlyphSet:SetGlyph(slot, glyphID)
	assert(slot >= 1 and slot <= AS2.NUM_GLYPH_SLOTS)
	self.glyphsTable:SetValue(slot, glyphID)
end

-- Fills a backup object with data.
function GlyphSet:private_FillBackup(backupEntry)
	-- (if you add more tables, remember to Keep() them up top!)
	backupEntry.glyphsTable = self.qcTableCache:CloneTable(self.glyphsTable):GetIndex()
end

-- Creates a new backup entry and returns it
function GlyphSet:CreateBackup()
	local backupEntry = self.backupList:CreateBackupEntry()
	if backupEntry then self:private_FillBackup(backupEntry) end
	return backupEntry
end

function GlyphSet:CreateManualBackup()
	local backup = self:CreateBackup()
	self.backupList:AddManualBackup(backup)
	return backup
end

function GlyphSet:CreateAutomatedBackup()
	local backup = self:CreateBackup()
	self.backupList:AddAutomatedBackup(backup)
	return backup
end

-- Restores this glyph set's data from a backup entry.
function GlyphSet:RestoreFromBackup(backupEntry)
	-- Clone the backup's tables, and also validate the backup by creating any tables that don't exist.
	local glyphsTable = self.qcTableCache:GetTableAt(backupEntry.glyphsTable)
	if not glyphsTable then
		glyphsTable = self.qcTableCache:CreateTable()
	else
		glyphsTable = self.qcTableCache:CloneTable(glyphsTable)
	end

	-- Put the new tables into our data source to restore the backup.
	self.glyphsTable = glyphsTable
	self.dataSource.glyphsTable = glyphsTable:GetIndex()
end

-- Upgrades this glyph set to revision 8 if not already done.
-- At glyph set revision 8 (Mists of Pandaria), the glyph sets have to be cleared due to extensive recycling of glyph IDs.
function GlyphSet:UpgradeToRevision8()
	if not self.dataSource.revision or self.dataSource.revision < 8 then
		
		-- Clear all glyphs (do not simply wipe the table... remember - it can inherit values!)
		for i = 1, 9 do		-- (do not replace with AS2.NUM_GLYPH_SLOTS; there used to be 9, but now there are only 6)
			self.glyphsTable:SetValue(i, nil)
		end

		-- Remove all backups
		self.backupList:RemoveAll()

		-- Mark this glyph set as upgraded so we don't ever upgrade it again.
		self.dataSource.revision = 8
	end
end
