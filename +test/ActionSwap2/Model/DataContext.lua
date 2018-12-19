--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- DataContext is an object which stores data that is shared between a group of many
-- different objects, such as the quick-clone table cache.  There is currently a
-- single DataContext for the model, but I plan to make use of a different DataContext
-- instance for exported data. (this way, it allows for split & merge of addon data,
-- which can be useful, say, when transferring settings to / from PTR)

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local DataContext = AS2.Model.DataContext

-- Creates a new DataContext object around an existing data source.
function DataContext:CreateWithDataSource(dataSource)
	assert(dataSource, "NIL_ARGUMENT")
	self = self:Derive()

	-- Validate the data source
	if not dataSource.tableCache then dataSource.tableCache = { } end

	-- Synchronize the object model to the data source
	self.dataSource = dataSource
	self.qcTableCache = AS2.Model.QuickCloneTableCache:CreateWithDataSource(dataSource.tableCache)

	return self
end

-- Returns the data source for this DataContext.
function DataContext:GetDataSource()
	return self.dataSource
end

-- Returns the quick-clone table cache for this DataContext.
function DataContext:GetQCTableCache()
	return self.qcTableCache
end
