--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local ButtonSet = AS2.Model.ButtonSet
local SetListBase = AS2.Model.SetListBase

-- Creates a new ButtonSet object (and data source) with the given name.
function ButtonSet:Create(name, dataContext)
	return ButtonSet:CreateWithDataSource({ name = name	}, dataContext)
end

-- Creates a new ButtonSet object around an existing data source.
function ButtonSet:CreateWithDataSource(dataSource, dataContext)
	assert(dataSource and dataContext, "NIL_ARGUMENT")
	self = AS2.Model.SetListBase.CreateWithDataSource(self, dataSource, dataContext, AS2.Model.ActionSet, "actionSets", "activeActionSet",
		function() return AS2.activeModel:IsActivatingActionSet() end)

	-- Validate the data source
	if not dataSource.name then dataSource.name = "New Button Set" end
	if dataSource.includeKeybindings == nil then dataSource.includeKeybindings = false end

	-- Synchronize the object model to the data source

	-- (our context is set by our owner immediately after creation, thus on the child action sets too)

	-- (ContentChanged already registered in SetListBase)

	return self
end

-- Returns the name of this button set.
function ButtonSet:GetName()
	return self.dataSource.name
end

-- Sets the name of this button set.
function ButtonSet:SetName(name)
	self.dataSource.name = name
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns the icon for this button set.
function ButtonSet:GetIcon()
	return self.dataSource.icon
end

-- Sets the icon for this button set.
function ButtonSet:SetIcon(filename)
	self.dataSource.icon = filename
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Enables or disables the inclusion of keybindings for this button set.  Doesn't record data.
function ButtonSet:friend_SetIncludeKeybindings(value)
	self.dataSource.includeKeybindings = value
	AS2:SendMessage(self, "ContentChanged", self)
end

-- Returns whether or not this button set includes keybinding data.
function ButtonSet:AreKeybindingsIncluded()
	return self.dataSource.includeKeybindings
end

-- Sets the context of this button set, used mainly for backup purposes.
function ButtonSet:SetContext(bsList)
	self.bsListContext = bsList
	for i = 1, self:GetActionSetCount() do	-- (update the context of all our existing action sets too)
		self:GetActionSetAt(i):SetContext(bsList, self)
	end
end

-- Rename the base class functions, as set operations can be confusing if you don't specify the kind of set.
function ButtonSet:GetActionSetCount(...) return self:GetSetCount(...) end
function ButtonSet:AddActionSet(...) return self:AddSet(...) end
function ButtonSet:RemoveActionSetAt(...) return self:RemoveSetAt(...) end
function ButtonSet:GetActionSetAt(...) return self:GetSetAt(...) end
function ButtonSet:FindActionSet(...) return self:FindSet(...) end
function ButtonSet:GetActiveActionSet(...) return self:GetActiveSet(...) end
function ButtonSet:friend_SetActiveActionSet(...) return self:friend_SetActiveSet(...) end

-- Override the AddSet method to notify the added action set of its context.
function ButtonSet:AddSet(actionSet)
	assert(actionSet, "NIL_ARGUMENT")
	actionSet:SetContext(self.bsListContext, self)
	return SetListBase.AddSet(self, actionSet)
end
