--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local SetListBase = AS2.Model.SetListBase

-- Creates a SetListBase object around the given data source.  Uses the specified key
-- names to access data on the data source.
function SetListBase:CreateWithDataSource(dataSource, dataContext, setType, setsKey, activeSetKey, isReadOnlyFn)
	assert(dataSource and dataContext and setType and setsKey and activeSetKey and isReadOnlyFn, "NIL_ARGUMENT")
	self = self:Derive()

	-- Validate the data source
	if not dataSource[setsKey] then dataSource[setsKey] = { } end
	if not dataSource[activeSetKey] then dataSource[activeSetKey] = { } end		-- (one for each spec)

	-- Synchronize the object model to the data source
	self.dataSource = dataSource
	self.setType = setType
	self.setsKey = setsKey
	self.activeSetKey = activeSetKey
	self.IsReadOnly = isReadOnlyFn
	self.sets = { }
	for _, setData in ipairs(dataSource[setsKey]) do
		local set = setType:CreateWithDataSource(setData, dataContext)
		AS2:AddCallback(set, "ContentChanged", self.Child_OnContentChanged, self)
		tinsert(self.sets, set)
	end

	AS2:RegisterMessage(self, "ContentChanged")

	return self
end

-- Returns the data source for this set list.
function SetListBase:GetDataSource()
	return self.dataSource
end

-- Returns the number of sets in this set list.
function SetListBase:GetSetCount()
	return #self.sets
end

-- Adds the given set to this list, then returns its index (plus the set as a pass-through value).
function SetListBase:AddSet(set)
	assert(set, "NIL_ARGUMENT")

	-- Observe messages on the added child
	AS2:AddCallback(set, "ContentChanged", self.Child_OnContentChanged, self)

	-- Make the same change in the object model and data source
	tinsert(self.sets, set)
	tinsert(self.dataSource[self.setsKey], set:GetDataSource())

	AS2:SendMessage(self, "ContentChanged", self)

	return #self.sets, set
end

-- Removes the set at the given index.
function SetListBase:RemoveSetAt(index)
	assert(index >= 1 and index <= #self.sets, "INVALID_ID")
	local removedSet = self.sets[index]

	-- Unobserve messages on the the removed child
	AS2:RemoveAllCallbacksWithContext(removedSet, self)

	-- Set the active set to nil if it points to the deleted set,
	-- and decrement it if it's above.
	for spec, set in pairs(self.dataSource[self.activeSetKey]) do
		if set == index then
			self.dataSource[self.activeSetKey][spec] = nil
		elseif set > index then
			self.dataSource[self.activeSetKey][spec] = set - 1
		end
	end

	-- Make the same change in the object model and data source
	tremove(self.sets, index)
	tremove(self.dataSource[self.setsKey], index)

	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the set at the given index, or nil if index is nil or out of range.
function SetListBase:GetSetAt(index)
	if not index or index < 1 or index > #self.sets then return nil end
	return self.sets[index]
end

-- Finds a set in this list via linear search, and returns its index (nil if not found or nil input).
function SetListBase:FindSet(set)
	if not set then return nil end
	for index = 1, #self.sets do
		if self.sets[index] == set then
			return index
		end
	end
end

-- Returns the active set for the given spec (1 or 2).  If not specified, uses the current spec.
function SetListBase:GetActiveSet(spec)
	if not spec then spec = AS2.activeGameModel:GetActiveSpec() end
	assert(spec >= 1 and spec <= AS2.NUM_SPECS, "INVALID_ID")
	return self.dataSource[self.activeSetKey][spec]
end

-- Sets the active set for the given spec (1 or 2).  nil can be specified to use the current spec.
-- This method is marked friend, because it doesn't actually apply anything, and can be therefore
-- be dangerous to call if you don't know what you're doing.
function SetListBase:friend_SetActiveSet(spec, setIndex)
	-- (do not disallow on activation; this function needs to be called)
	if not spec then spec = AS2.activeGameModel:GetActiveSpec() end
	assert(spec >= 1 and spec <= AS2.NUM_SPECS, "INVALID_ID")
	assert(not setIndex or (setIndex >= 1 and setIndex <= #self.sets))
	self.dataSource[self.activeSetKey][spec] = setIndex

	AS2:SendMessage(self, "ContentChanged", self)
end

-- Swaps the sets at the two indices.
function SetListBase:private_Swap(index1, index2)
	assert(index1 >= 1 and index1 <= #self.sets, "INVALID_ID")
	assert(index2 >= 1 and index2 <= #self.sets, "INVALID_ID")
	
	-- Swap the sets in the list (and make the same change to the dataSource)
	local temp = self.sets[index1]
	self.sets[index1] = self.sets[index2]
	self.sets[index2] = temp
	
	temp = self.dataSource[self.setsKey][index1]
	self.dataSource[self.setsKey][index1] = self.dataSource[self.setsKey][index2]
	self.dataSource[self.setsKey][index2] = temp
end

-- Shifts the set at the given index up a slot
function SetListBase:MoveUp(index)
	assert(index, "NIL_ARGUMENT")
	assert(index >= 1 and index <= #self.sets, "INVALID_ID")

	-- Don't do anything if moving the top item up.
	if index == 1 then return end

	-- Swap the sets at index and index - 1
	self:private_Swap(index, index - 1)

	AS2:SendMessage(self, "ContentChanged", self)
end

-- Shifts the set a the given index down a slot
function SetListBase:MoveDown(index)
	assert(index, "NIL_ARGUMENT")
	assert(index >= 1 and index <= #self.sets, "INVALID_ID")

	-- Don't do anything if moving the top item up.
	if index == #self.sets then return end

	-- Swap the sets at index and index + 1
	self:private_Swap(index, index + 1)

	AS2:SendMessage(self, "ContentChanged", self)
end

-- Called when a child fires a ContentChanged message.
function SetListBase:Child_OnContentChanged(child)
	AS2:SendMessage(self, "ContentChanged", self)
end
