--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local ListControllerBase = AS2.Controller.ListControllerBase

function ListControllerBase:Create(listView)
	assert(listView)
	self = self:Derive()

	-- Tell the list view that we'll be providing it with items.
	self.listView = listView
	listView:SetDelegate(self)

	AS2:RegisterMessage(self, "SelectedItemChanged")

	return self
end

-- Returns the height of each item in the list.
function ListControllerBase:ListView_GetItemHeight()
	return AS2.LIST_ITEM_HEIGHT
end

function ListControllerBase:ListView_UpdateButton(button, index, count, itemObject)
	assert(button and index and count)
	button:UpdateDisplayForPosition(index, count,
		itemObject ~= nil and self.selectedItem == itemObject)	-- (selected state)
end

-- Sets the currently selected item.
function ListControllerBase:SetSelectedItem(item)
	if item ~= self.selectedItem then
		self.selectedItem = item
		AS2:SendMessage(self, "SelectedItemChanged", self, item)
		self.listView:Refresh()
	end
end

-- Returns the currently selected item.
function ListControllerBase:GetSelectedItem()
	return self.selectedItem
end
