--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local Action = AS2.Model.Action
local ActionSet = AS2.Model.ActionSet
local Utilities = AS2.Model.Utilities

-- Creates a new ActionSet object (and data source) with the given name.
function ActionSet:Create(name, dataContext)
	return ActionSet:CreateWithDataSource({ name = name, revision = 11 }, dataContext)
end

-- Creates an ActionSet object around an existing data source.
function ActionSet:CreateWithDataSource(dataSource, dataContext)
	assert(dataSource and dataContext, "NIL_ARGUMENT")
	self = self:Derive()
	local qcTableCache = dataContext:GetQCTableCache()

	-- Validate the data source
	if not dataSource.name then dataSource.name = "New Action Set" end
	if not dataSource.backups then dataSource.backups = { } end
	
	self.actionsTable = qcTableCache:GetTableAt(dataSource.actionsTable)
	if not self.actionsTable then
		self.actionsTable = qcTableCache:CreateTable()
		dataSource.actionsTable = self.actionsTable:GetIndex()
	end
	self.actionsTable:SetComparator(Action.Comparator)
	self.actionsTable:Keep()

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
	self.backupList:KeepTables("actionsTable", "keybindingsTable", "slotAssignmentsTable")	-- (save these tables from garbage collection)

	-- Set the comparator of each backup's actions table.
	for i = 1, self.backupList:GetAutomatedBackupCount() do
		local entry = self.backupList:GetAutomatedBackupAt(i)
		local actionsTable = qcTableCache:GetTableAt(entry.actionsTable)
		if actionsTable then actionsTable:SetComparator(Action.Comparator) end
	end
	for i = 1, self.backupList:GetManualBackupCount() do
		local entry = self.backupList:GetManualBackupAt(i)
		local actionsTable = qcTableCache:GetTableAt(entry.actionsTable)
		if actionsTable then actionsTable:SetComparator(Action.Comparator) end
	end
	
	AS2:RegisterMessage(self, "ContentChanged")

	return self
end

-- Returns the data source for this action set.
function ActionSet:GetDataSource()
	return self.dataSource
end

-- Returns the name of this action set.
function ActionSet:GetName()
	return self.dataSource.name
end

-- Sets the name of this action set.
function ActionSet:SetName(name)
	self.dataSource.name = name
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the icon for this action set.
function ActionSet:GetIcon()
	return self.dataSource.icon
end

-- Sets the icon for this action set.
function ActionSet:SetIcon(filename)
	self.dataSource.icon = filename
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the actions table associated with this ActionSet.
function ActionSet:GetActionsTable()
	return self.actionsTable
end

-- Returns the keybindings table associated with this ActionSet.
function ActionSet:GetKeybindingsTable()
	return self.keybindingsTable
end

-- Returns the action set's list of backups.
function ActionSet:GetBackupList()
	return self.backupList
end

-- Fills a backup object with data.
function ActionSet:private_FillBackup(backupEntry)

	-- (if you add more tables, remember to Keep() them up top!)
	backupEntry.actionsTable = self.qcTableCache:CloneTable(self.actionsTable):GetIndex()
	backupEntry.keybindingsTable = self.qcTableCache:CloneTable(self.keybindingsTable):GetIndex()
	
	assert(self.bsListContext and self.bsContext)	-- (shouldn't be creating backups outside of a context)
	local bsIndex = self.bsListContext:FindButtonSet(self.bsContext)
	assert(bsIndex)	-- (shouldn't be part of a button set that doesn't exist)
		
	-- Implicitly clip the backup, by saving the slot assignments table along with our current button set's index
	backupEntry.slotAssignmentsTable = self.qcTableCache:CloneTable(self.bsListContext:GetSlotAssignmentsTable()):GetIndex()
	backupEntry.buttonSetAtBackup = bsIndex
end

-- Creates a new backup entry and returns it
function ActionSet:CreateBackup()
	local backupEntry = self.backupList:CreateBackupEntry()
	if backupEntry then self:private_FillBackup(backupEntry) end
	return backupEntry
end

function ActionSet:CreateManualBackup()
	local backup = self:CreateBackup()
	self.backupList:AddManualBackup(backup)
	return backup
end

function ActionSet:CreateAutomatedBackup()
	local backup = self:CreateBackup()
	self.backupList:AddAutomatedBackup(backup)
	return backup
end

function ActionSet:CreateProtectedAutomatedBackup()
	local backup = self:CreateBackup()
	backup.isProtected = true
	self.backupList:AddAutomatedBackup(backup)
	return backup
end

-- Restores this action set's data from a backup entry.
function ActionSet:RestoreFromBackup(backupEntry)
	-- Clone the backup's tables, and also validate the backup by creating any tables that don't exist.
	local actionsTable = self.qcTableCache:GetTableAt(backupEntry.actionsTable)
	if not actionsTable then
		actionsTable = self.qcTableCache:CreateTable()
		actionsTable:SetComparator(Action.Comparator)
	else
		actionsTable = self.qcTableCache:CloneTable(actionsTable)
	end

	local keybindingsTable = self.qcTableCache:GetTableAt(backupEntry.keybindingsTable)
	if not keybindingsTable then
		keybindingsTable = self.qcTableCache:CreateTable()
	else
		keybindingsTable = self.qcTableCache:CloneTable(keybindingsTable) 
	end

	local slotAssignmentsTable = self.qcTableCache:GetTableAt(backupEntry.slotAssignmentsTable)
	local buttonSetAtBackup = backupEntry.buttonSetAtBackup

	-- Clip the actions / keybindings table by the slot assignments table.
	if slotAssignmentsTable and buttonSetAtBackup then
		for slot, action in actionsTable:Pairs() do
			if slotAssignmentsTable:GetValue(slot) ~= buttonSetAtBackup then
				actionsTable:SetValue(slot, nil)
			end
		end
	end

	for key, command in keybindingsTable:Pairs() do
		local slot = Utilities:QuickParseSlotFromCommand(command)
		if not slot or slotAssignmentsTable:GetValue(slot) ~= buttonSetAtBackup then
			keybindingsTable:SetValue(key, nil)
		end
	end

	-- Put the new tables into our data source to restore the backup.
	self.actionsTable = actionsTable
	self.keybindingsTable = keybindingsTable
	self.dataSource.actionsTable = actionsTable:GetIndex()
	self.dataSource.keybindingsTable = keybindingsTable:GetIndex()
end

-- Sets the context of this action set, used mainly for backup purposes.
-- (and, as a tradeoff, action sets can exist in only one context at a time)
function ActionSet:SetContext(bsList, buttonSet)
	self.bsListContext = bsList
	self.bsContext = buttonSet
end

-- De-morphs all spells in this action set and all of its backups based on the
-- currently known morphing rules (what's currently in the spellbook).
function ActionSet:DemorphAllSpells()
	self:private_DemorphActionsInTable(self.actionsTable)
	self.backupList:ForEachTable(function(table) self:private_DemorphActionsInTable(table) end, "actionsTable")
end

-- Helper function for UpgradeToRevision11(); demorphs all spells in the specified table.
function ActionSet:private_DemorphActionsInTable(table)
	-- (note: okay to remove / change current key during iteration)
	if table then
		for slot, action in table:Pairs() do
			local type, originalID = Action:GetTypeAndID(action)	-- (will reutrn nil if Action.NIL)
			if type == "spell" then
				local demorphedID = AS2.activeGameModel:GetUnmorphedSpellID(originalID)
				if demorphedID and demorphedID ~= originalID then
					-- (call SetValue; don't simply change the old action or the table will no longer be optimal)
					table:SetValue(slot, Action:Create("spell", demorphedID))
				end
			end
		end
	end
end

-- Upgrades this action set to revision 11 if not already done.
-- At revision 11, the IDs of all spells are de-morphed (including backups).
function ActionSet:UpgradeToRevision11()
	if not self.dataSource.revision or self.dataSource.revision < 11 then
		self:DemorphAllSpells()

		-- Mark this glyph set list as upgraded so we don't ever upgrade it again.
		self.dataSource.revision = 11
	end
end
