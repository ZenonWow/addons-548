--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- A ButtonSetList is a list of button sets, for which each action bar slot is assigned to at most
-- one of those sets.  In fact, button sets do not know their assignments; it is the list which
-- keeps track of this information.

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local ButtonSetList = AS2.Model.ButtonSetList

-- Creates a ButtonSetList object around an existing data source.
function ButtonSetList:CreateWithDataSource(dataSource, dataContext)
	assert(dataSource and dataContext, "NIL_ARGUMENT")
	self = self:Derive()
	local qcTableCache = dataContext:GetQCTableCache()

	-- Validate the data source
	if not dataSource.buttonSets then dataSource.buttonSets = { } end

	self.slotAssignmentsTable = qcTableCache:GetTableAt(dataSource.slotAssignmentsTable)
	if not self.slotAssignmentsTable then
		self.slotAssignmentsTable = qcTableCache:CreateTable()
		dataSource.slotAssignmentsTable = self.slotAssignmentsTable:GetIndex()
	end
	self.slotAssignmentsTable:Keep()

	-- Synchronize the object model to the data source
	self.dataSource = dataSource
	self.buttonSets = { }
	for _, buttonSetData in ipairs(dataSource.buttonSets) do
		local buttonSet = AS2.Model.ButtonSet:CreateWithDataSource(buttonSetData, dataContext)
		AS2:AddCallback(buttonSet, "ContentChanged", self.Child_OnContentChanged, self)
		buttonSet:SetContext(self)
		tinsert(self.buttonSets, buttonSet)
	end

	AS2:RegisterMessage(self, "SlotAssignedToButtonSet")
	AS2:RegisterMessage(self, "ContentChanged")

	return self
end

-- Returns the total number of button sets in this list.
function ButtonSetList:GetButtonSetCount()
	return #self.buttonSets
end

-- Adds a new button set to the end of the list, then returns its index (plus buttonSet as a pass-through value).
function ButtonSetList:AddButtonSet(buttonSet)
	assert(buttonSet, "NIL_ARGUMENT")

	-- Observe messages on the added child
	AS2:AddCallback(buttonSet, "ContentChanged", self.Child_OnContentChanged, self)

	-- Make the same change in the object model and data source
	tinsert(self.buttonSets, buttonSet)
	tinsert(self.dataSource.buttonSets, buttonSet:GetDataSource())

	buttonSet:SetContext(self)

	AS2:SendMessage(self, "ContentChanged", self)

	return #self.buttonSets, buttonSet
end

-- Removes the button set at the specified index.
function ButtonSetList:RemoveButtonSetAt(index)
	assert(index >= 1 and index <= #self.buttonSets, "INVALID_ID")
	local removedSet = self.buttonSets[index]

	-- Unobserve messages on the the removed child
	AS2:RemoveAllCallbacksWithContext(removedSet, self)

	-- Make the same change in the object model and data source
	tremove(self.buttonSets, index)
	tremove(self.dataSource.buttonSets, index)

	removedSet:SetContext(nil)

	-- Update slot assignments; remove those where equal to index, decrement those that are above
	for k,v in self.slotAssignmentsTable:Pairs() do
		if v == index then self.slotAssignmentsTable:SetValue(k, nil)
		elseif v > index then self.slotAssignmentsTable:SetValue(k, v - 1) end
	end

	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the button set at the specified index, or nil if the index is nil or out of range.
function ButtonSetList:GetButtonSetAt(index)
	if not index or index < 1 or index > #self.buttonSets then return nil end
	return self.buttonSets[index]
end

-- Finds a button set in this list via linear search, and returns its index (nil if not found or nil input).
function ButtonSetList:FindButtonSet(buttonSet)
	if not buttonSet then return nil end
	for index = 1, #self.buttonSets do
		if self.buttonSets[index] == buttonSet then
			return index
		end
	end
end

-- Swaps the button sets at the two indices.
function ButtonSetList:private_Swap(index1, index2)
	assert(index1 >= 1 and index1 <= #self.buttonSets, "INVALID_ID")
	assert(index2 >= 1 and index2 <= #self.buttonSets, "INVALID_ID")
	
	-- Swap the button sets in the list (and make the same change to the dataSource)
	local temp = self.buttonSets[index1]
	self.buttonSets[index1] = self.buttonSets[index2]
	self.buttonSets[index2] = temp
	
	temp = self.dataSource.buttonSets[index1]
	self.dataSource.buttonSets[index1] = self.dataSource.buttonSets[index2]
	self.dataSource.buttonSets[index2] = temp

	-- Update slot assignments
	for k,v in self.slotAssignmentsTable:Pairs() do
		if v == index1 then self.slotAssignmentsTable:SetValue(k, index2)
		elseif v == index2 then self.slotAssignmentsTable:SetValue(k, index1) end
	end
end

-- Shifts the button set at the given index up a slot
function ButtonSetList:MoveUp(index)
	assert(index, "NIL_ARGUMENT")
	assert(index >= 1 and index <= #self.buttonSets, "INVALID_ID")

	-- Don't do anything if moving the top item up.
	if index == 1 then return end

	-- Swap the sets at index and index - 1
	self:private_Swap(index, index - 1)

	AS2:SendMessage(self, "ContentChanged", self)
end

-- Shifts the button set a the given index down a slot
function ButtonSetList:MoveDown(index)
	assert(index, "NIL_ARGUMENT")
	assert(index >= 1 and index <= #self.buttonSets, "INVALID_ID")

	-- Don't do anything if moving the top item up.
	if index == #self.buttonSets then return end

	-- Swap the sets at index and index + 1
	self:private_Swap(index, index + 1)

	AS2:SendMessage(self, "ContentChanged", self)
end

-- Assigns the specified action bar slot to the given button set.
function ButtonSetList:AssignSlotToButtonSet(slotIndex, buttonSetIndex)
	assert(slotIndex >= 1 and slotIndex <= AS2.NUM_ACTION_SLOTS, "INVALID_ID")
	assert(not buttonSetIndex or (buttonSetIndex >= 1 and buttonSetIndex <= #self.buttonSets), "INVALID_ID")
	self.slotAssignmentsTable:SetValue(slotIndex, buttonSetIndex)

	AS2:SendMessage(self, "SlotAssignedToButtonSet", slotIndex, buttonSetIndex)
end

-- Returns the index of the button set the given slot is assigned to, or nil if it's unassigned.
function ButtonSetList:GetAssignedButtonSetForSlot(slotIndex)
	if not slotIndex then return nil end
	assert(slotIndex >= 1 and slotIndex <= AS2.NUM_ACTION_SLOTS, "INVALID_ID")
	return self.slotAssignmentsTable:GetValue(slotIndex)
end

-- Called when a child fires a ContentChanged message.
function ButtonSetList:Child_OnContentChanged(child)
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the raw slot assignments table (for backup purposes).  Don't alter it.
function ButtonSetList:GetSlotAssignmentsTable()
	return self.slotAssignmentsTable
end

-- Provide compatibility with SetListBase (except activation functions)
function ButtonSetList:GetSetCount(...) return self:GetButtonSetCount(...) end
function ButtonSetList:AddSet(...) return self:AddButtonSet(...) end
function ButtonSetList:RemoveSetAt(...) return self:RemoveButtonSetAt(...) end
function ButtonSetList:GetSetAt(...) return self:GetButtonSetAt(...) end
function ButtonSetList:FindSet(...) return self:FindButtonSet(...) end
