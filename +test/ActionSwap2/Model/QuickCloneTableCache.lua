--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- QuickCloneTableCache
--
-- For a description of this mechanism, see QuickCloneTable.

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local QuickCloneTable = AS2.Model.QuickCloneTable
local QuickCloneTableCache = AS2.Model.QuickCloneTableCache

local EXPLICIT_NIL = "@nil"		-- This string is put into a table to indicate nil as opposed to an inherited value.

local function DefaultComparator(a, b)
	return a == b
end

-- Creates a QuickCloneTableCache object around an existing data source.
function QuickCloneTableCache:CreateWithDataSource(dataSource)
	assert(dataSource, "NIL_ARGUMENT")
	self = self:Derive()

	-- Synchronize the object model to the data source, and do validation
	if not dataSource.tables then dataSource.tables = { } end

	self.dataSource = dataSource
	self.cachedTableObjects = { }
	self.forwardsTo = { }
	self.keepTables = { }
	self.comparators = { }
	
	for tableIndex, table in pairs(dataSource.tables) do
		if not table.data then table.data = { } end
		self.forwardsTo[tableIndex] = { }
	end

	-- Calculate forwardsTo values and repair any broken links.
	for tableIndex, table in pairs(dataSource.tables) do
		if table.inheritsFrom then
			if not dataSource.tables[table.inheritsFrom] then
				-- Repair the broken link
				table.inheritsFrom = nil
			else
				-- Create a forward link to the inheritor
				tinsert(self.forwardsTo[table.inheritsFrom], tableIndex)
			end
		end
	end

	return self
end

-- Creates a new, empty, QuickCloneTable and returns it.
function QuickCloneTableCache:CreateTable()
	local newTableIndex = self:private_FindEmptyIndex()
	self.dataSource.tables[newTableIndex] = { data = { } }
	self.forwardsTo[newTableIndex] = { }
	return self:GetTableAt(newTableIndex) -- (creates a table object)
end

-- Clones the table with the given index, and returns the new table.
function QuickCloneTableCache:CloneTable(originalTable)
	assert(originalTable:GetTableCache() == self)	-- (make sure this table is from the same cache)
	local originalTableIndex = originalTable:GetIndex()
	local originalTableDataSource = self.dataSource.tables[originalTableIndex]
	assert(originalTableDataSource, "INVALID_ID")	-- (disallow cloning of tables that don't exist)

	local newTableIndex = self:private_FindEmptyIndex()
	local newTableDataSource = { data = { } }
	self.dataSource.tables[newTableIndex] = newTableDataSource
	self.forwardsTo[newTableIndex] = { }
	self.comparators[newTableIndex] = self.comparators[originalTableIndex]
	
	newTableDataSource.inheritsFrom = originalTableIndex
	tinsert(self.forwardsTo[originalTableIndex], newTableIndex)

	return self:GetTableAt(newTableIndex) -- (creates table object)
end

-- Returns the QuickCloneTable at the specified index, or nil if none is at that index.
function QuickCloneTableCache:GetTableAt(index)
	if self.cachedTableObjects[index] then return self.cachedTableObjects[index] end

	-- No cached table object; create a new one if the table really exists
	local table = self.dataSource.tables[index]
	if table then
		local newObject = QuickCloneTable:InternalCreateWithDataSource(self, index)
		self.cachedTableObjects[index] = newObject
		return newObject
	end
end

-- Saves the specified table from the next CollectGarbage() call.
function QuickCloneTableCache:KeepTableAt(index)
	self.keepTables[index] = true
end

-- Removes the table at the specified index.
function QuickCloneTableCache:RemoveTableAt(index)
	local thisTable = self.dataSource.tables[index]
	assert(thisTable, "INVALID_ID")
	local parent = thisTable.inheritsFrom

	-- Invalidate any object references to the deleted table.
	if self.cachedTableObjects[index] then
		self.cachedTableObjects[index]:internal_MakeInvalid()
		self.cachedTableObjects[index] = nil
	end
	
	-- Choose a "favorite child" based on which child most closely matches its parent
	local favoriteChild
	local favoriteChildScore
	for _, fwdIndex in ipairs(self.forwardsTo[index]) do
		local fwdTable = self.dataSource.tables[fwdIndex]
		local score = self:private_ComputeScore(fwdIndex, index)
		if not favoriteChildScore or score < favoriteChildScore then
			favoriteChild = fwdIndex
			favoriteChildScore = score
		end
	end
	local favoriteChildTable = self.dataSource.tables[favoriteChild]
		
	if favoriteChildTable then	-- (there may have been no children at all)
		
		-- Re-parent the favorite child to the deleted table's parent.
		for key, value in pairs(thisTable.data) do
			if value == EXPLICIT_NIL then value = nil end	-- (don't ever forward explicit nil)
			local newParentValue = nil
			if parent then newParentValue = self:internal_GetValue(parent, key) end
			self:private_OnParentValueChanged(favoriteChild, key, value, newParentValue)
		end
		favoriteChildTable.inheritsFrom = parent
		if parent then tinsert(self.forwardsTo[parent], favoriteChild) end
		
		-- For all other children, re-parent to the favorite child.
		for _, fwdIndex in ipairs(self.forwardsTo[index]) do
			if fwdIndex ~= favoriteChild then
				-- All values on the old parent change to the favorite child
				for key, value in pairs(thisTable.data) do
					if value == EXPLICIT_NIL then value = nil end	-- (don't ever forward explicit nil)
					local newParentValue = self:internal_GetValue(favoriteChild, key)
					self:private_OnParentValueChanged(fwdIndex, key, value, newParentValue)
				end
				-- Some values on the favorite child that weren't on the parent may be re-inherited
				for key, value in pairs(favoriteChildTable.data) do
					if thisTable.data[key] == nil then
						if value == EXPLICIT_NIL then value = nil end	-- (don't ever forward explicit nil)
						local oldParentValue = nil
						if parent then oldParentValue = self:internal_GetValue(parent, key) end
						self:private_OnParentValueChanged(fwdIndex, key, oldParentValue, value)
					end
				end
				self.dataSource.tables[fwdIndex].inheritsFrom = favoriteChild
				tinsert(self.forwardsTo[favoriteChild], fwdIndex)
			end
		end
	end
	
	-- Remove ourselves from our parent's forwardsTo table.
	if parent then
		local forwardsTo = self.forwardsTo[parent]
		for i = #forwardsTo, 1, -1 do
			if forwardsTo[i] == index then
				tremove(forwardsTo, i)	-- (remove all instances, just in case there are erreneously more than one)
			end
		end
	end

	-- Remove the table.
	self.forwardsTo[index] = nil
	self.keepTables[index] = nil
	self.dataSource.tables[index] = nil
	self.comparators[index] = nil
end

-- Computes how closely a child table matches its parent.
-- (a.k.a. "how many values differ from the parent")
function QuickCloneTableCache:private_ComputeScore(childIndex, parentIndex)
	local childTable = self.dataSource.tables[childIndex]
	local parentTable = self.dataSource.tables[parentIndex]
	local childData = childTable.data
	local parentData = parentTable.data
	local score = 0
	for k, v in pairs(parentData) do
		score = score + (childData[k] ~= nil and 1 or 0)	-- ("any of the parent's values that aren't inherited by the child")
	end
	for k, v in pairs(childData) do
		score = score + (parentData[k] == nil and 1 or 0)	-- ("any child values that weren't iterated over the first time")
	end
	return score
end
	
-- Returns a value for the given key on the given table.
function QuickCloneTableCache:internal_GetValue(tableIndex, key)
	local table = self.dataSource.tables[tableIndex]
	assert(table, "INVALID_ID")
	if key == nil then return nil end	-- (get at index nil is nil)
	while table do
		local value = table.data[key]
		if value ~= nil then
			if value == EXPLICIT_NIL then return nil end
			return value
		end

		tableIndex = table.inheritsFrom
		table = self.dataSource.tables[tableIndex]
	end
end

-- Call this to preserve a child's value after a parent value has changed (also, re-inherits the new value if possible).
function QuickCloneTableCache:private_OnParentValueChanged(childTableIndex, key, oldValue, newValue, forceReinherit)
	local childTable = self.dataSource.tables[childTableIndex]
	assert(childTable, "INVALID_ID")
	if AS2.DEBUG then assert(key and oldValue ~= EXPLICIT_NIL and newValue ~= EXPLICIT_NIL) end
	local areEqual = self.comparators[childTableIndex] or DefaultComparator
	
	if not areEqual(oldValue, newValue) or forceReinherit then
		local value = childTable.data[key]
		
		if value == EXPLICIT_NIL then
			value = nil
		elseif value == nil then
			value = oldValue
		end

		if areEqual(value, newValue) then	-- (re-inherit from the parent)
			childTable.data[key] = nil
		else
			if value == nil then	-- (thus, the parent is not nil)
				childTable.data[key] = EXPLICIT_NIL
			else
				childTable.data[key] = value
			end
		end
	end
end

-- Sets a value for the given key on the given table.
function QuickCloneTableCache:internal_SetValue(tableIndex, key, value, forceReinherit)
	
	local thisTable = self.dataSource.tables[tableIndex]
	assert(thisTable, "INVALID_ID")
	if AS2.DEBUG then assert(value ~= EXPLICIT_NIL) end
	local areEqual = self.comparators[tableIndex] or DefaultComparator

	-- Get our parent's value, and then our old value.
	local parentValue = nil
	local oldValue = thisTable.data[key]
	if thisTable.inheritsFrom then parentValue = self:internal_GetValue(thisTable.inheritsFrom, key) end
	
	if oldValue == EXPLICIT_NIL then
		oldValue = nil
	elseif oldValue == nil then
		oldValue = parentValue
	end

	if not areEqual(value, oldValue) or forceReinherit then
		-- Forward the old value to all inheritors (if there are any).
		for _, fwdIndex in ipairs(self.forwardsTo[tableIndex]) do
			self:private_OnParentValueChanged(fwdIndex, key, oldValue, value)	-- (don't need to pass forceReinherit)
		end

		-- Set the new value, re-inheriting from the parent if possible.
		if areEqual(value, parentValue) then	-- (re-inherit from parent)
			thisTable.data[key] = nil
		else
			if value == nil then		-- (thus, the parent is not nil)
				thisTable.data[key] = EXPLICIT_NIL
			else
				thisTable.data[key] = value
			end
		end
	end
end

-- Returns a value for the given key on the given table.  Returns nil if key is nil.
function QuickCloneTableCache:internal_IsInherited(tableIndex, key)
	local table = self.dataSource.tables[tableIndex]
	assert(table, "INVALID_ID")
	return table.data[key] == nil
end

-- Returns table data for the given index, or nil if it doesn't exist.
function QuickCloneTableCache:internal_GetTableData(tableIndex)
	return self.dataSource.tables[tableIndex]
end

-- Removes any tables that haven't been explicitly saved with KeepTableAt.
function QuickCloneTableCache:CollectGarbage()
	local tablesRemoved = 0
	for tableIndex, _ in pairs(self.dataSource.tables) do	-- (don't need reverse order - tables are stored as a map, not a list)
		if not self.keepTables[tableIndex] then
			self:RemoveTableAt(tableIndex)
			tablesRemoved = tablesRemoved + 1
		end
	end
	wipe(self.keepTables)
	if tablesRemoved > 0 then
		AS2:Dispatch(function() AS2:Debug(AS2.NOTE, "Garbage collected", tablesRemoved, "tables") end)
	end
end

-- Returns an iterator over the key/value pairs of the table at tableIndex.
function QuickCloneTableCache:internal_Pairs(tableIndex)
	local table = self.dataSource.tables[tableIndex]
	assert(table, "INVALID_ID")
	local f1, s1, k1
	local f2, s2, k2
	f1, s1, k1 = pairs(table.data)
	if table.inheritsFrom then f2, s2, k2 = self:internal_Pairs(table.inheritsFrom) end
	return function()
		local v
		if f1 then
			repeat
				k1, v = f1(s1, k1)
			until k1 == nil or v ~= EXPLICIT_NIL	-- "stop on any value that's not nil"
			if k1 then return k1, v end
			f1 = nil
		end
		if f2 then
			repeat
				k2, v = f2(s2, k2)
				-- (don't need to test for EXPLICIT_NIL this time, since the base case does)
			until k2 == nil or table.data[k2] == nil	-- "stop on any value that my parent has that I inherit"
		end
		return k2, v
	end
end

-- Finds an empty slot and returns its index.  We don't use the # operator, as it likes to leave huge holes
-- that never get filled in.  This version will leave some holes, but these holes will eventually be filled
-- in if enough tables are created.
function QuickCloneTableCache:private_FindEmptyIndex()
	local base = 1
	local size = 8
	local index
	repeat
		index = random(base, base + size - 1)
		base = base + size
		size = size * 2
	until not self.dataSource.tables[index]
	return index
end

-- Sets the comparator of the specified table.
function QuickCloneTableCache:SetComparator(tableIndex, comparator)
	local table = self.dataSource.tables[tableIndex]
	assert(table, "INVALID_ID")	-- (just verify the table actually exists)
	self.comparators[tableIndex] = comparator
end

-- Verifies that the table is still optimal (values are inherited whenever possible)
function QuickCloneTableCache:CheckIsOptimal()
	for tableIndex, table in pairs(self.dataSource.tables) do
		local areEqual = self.comparators[tableIndex] or DefaultComparator
		if table.inheritsFrom then
			for k,v in pairs(table.data) do
				local parentValue = self:internal_GetValue(table.inheritsFrom, k)
				if areEqual(parentValue, v) then	-- (any non-nil value equal to parent's value means non-optimal)
					return false
				end
			end
		end
	end
	return true
end

-- Forces re-optimization of all tables
function QuickCloneTableCache:Optimize()
	for tableIndex, table in pairs(self.dataSource.tables) do
		local areEqual = self.comparators[tableIndex] or DefaultComparator
		if table.inheritsFrom then
			for k,v in pairs(table.data) do
				local parentValue = self:internal_GetValue(table.inheritsFrom, k)
				if areEqual(parentValue, v) then	-- (any non-nil value equal to parent's value means non-optimal)
					self:internal_SetValue(tableIndex, k, parentValue, true) -- (force reinherit flag is set)
				end
			end
		end
	end
	return true
end
