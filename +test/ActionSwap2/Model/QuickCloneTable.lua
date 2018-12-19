--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- QuickCloneTable
--
-- Quick-clone tables are the mechanism used by ActionSwap 2 to make its backups.  Cloned tables inherit values from
-- their parents, making clones very small and fast to create.
--
-- If we were to employ a table-freezing approach, we get very small tables, but end up with several problems:
--   1) We'd quickly build up very long inheritance chains, making lookups on the mutable version of the table very inefficient.
--   2) Removing old, frozen, tables causes LOTS of values to have to be forwarded.
--
-- Instead, we leave the original table mutable, and forward values to inheritors as they are altered.  As long
-- as we don't build a long chain of clones, we get very good read performance on both clones and original, at the cost
-- of a storage space increase due to the loss of chaining, and write performance due to value forwarding.  Deleting
-- clones becomes significantly simpler, however, as values rarely have to be forwarded at all.
--
-- Using this approach effectively results in each backup storing all changes from the currently active settings
-- since the backup was created, not the changes since the previous backup was made.

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local QuickCloneTable = AS2.Model.QuickCloneTable

-- Internal create function - use QuickCloneTableCache:CreateTable() or CloneTable() instead.
function QuickCloneTable:InternalCreateWithDataSource(tableCache, index)
	assert(tableCache and index, "NIL_ARGUMENT")
	self = self:Derive()
	
	self.tableCache = tableCache
	self.index = index
	return self
end

-- Returns the index of this table in its associated cache.
function QuickCloneTable:GetIndex()
	assert(not self.invalid, "DISALLOWED")
	return self.index
end

-- Returns the QuickCloneTableCache this object is associated with.
function QuickCloneTable:GetTableCache()
	assert(not self.invalid, "DISALLOWED")
	return self.tableCache
end

-- Returns the value for the given key.  Returns nil if no value has been set.
function QuickCloneTable:GetValue(key)
	assert(not self.invalid, "DISALLOWED")
	return self.tableCache:internal_GetValue(self.index, key)
end

-- Sets the value for the given key.
function QuickCloneTable:SetValue(key, value)
	assert(not self.invalid, "DISALLOWED")
	return self.tableCache:internal_SetValue(self.index, key, value)
end

-- Returns true if the given value is inherited (used by test code).  Returns false is no value is set.
function QuickCloneTable:IsInherited(key)
	assert(not self.invalid, "DISALLOWED")
	return self.tableCache:internal_IsInherited(self.index, key)
end

-- Makes this object invalid to use for table access.
function QuickCloneTable:internal_MakeInvalid()
	self.invalid = true
end

-- Saves this table from the next garbage collection pass.
function QuickCloneTable:Keep()
	assert(not self.invalid, "DISALLOWED")
	self.tableCache:KeepTableAt(self.index)
end

-- Returns an iterator over the key/value pairs of this table.
function QuickCloneTable:Pairs()
	assert(not self.invalid, "DISALLOWED")
	return self.tableCache:internal_Pairs(self.index)
end

-- Sets the comparator for this table (and any clones derived from it).
function QuickCloneTable:SetComparator(comparator)
	assert(not self.invalid, "DISALLOWED")
	return self.tableCache:SetComparator(self.index, comparator)
end
