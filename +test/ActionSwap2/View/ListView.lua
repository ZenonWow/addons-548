--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- Why re-implement the basic scroll frame?  Because anything placed in a scrollChild is subject to
-- massive pixel precision errors that cause textures to jiggle when the window is moved (which is
-- especially not good if your list items have a background texture that needs to be seamless)
--
-- Note though, that since we're not placing items in a scroll child, we can't do clipping, so
-- 

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local ListView = AS2.View.ListView

function ListView:Create(name, parent)
	assert(parent)
	self = self:MixInto(CreateFrame("Frame", name, parent))

	-- Create the internal scroll frame seperately, so it can be hidden if there's nothing to scroll.
	self.scrollFrame = CreateFrame("ScrollFrame", name .. "_ScrollFrame", self, "FauxScrollFrameTemplate")
	self.scrollFrame:SetAllPoints()
	self.scrollFrame.owner = self

	self.isInvalid = false
	self.buttons = { }
	self.buttonCount = 0
	self.itemCount = 0
	self.itemHeight = 1

	self.scrollFrame:SetScript("OnSizeChanged", self.private_OnUpdateScrollFrameSize)
	self.scrollFrame:SetScript("OnVerticalScroll", function(scrollFrame, offset)
		FauxScrollFrame_OnVerticalScroll(scrollFrame, offset, self.itemHeight, function()
			self:private_UpdateButtons()
		end)
	end)

	return self
end

-- Sets the delegate of this ListView, which yields information about the list's contents.
function ListView:SetDelegate(delegate)
	assert(not self.delegate)	-- (you can only set the delegate once; the class wasn't designed to handle switching delegates)
	self.delegate = delegate
	self.itemHeight = self.delegate:ListView_GetItemHeight()
	assert(self.itemHeight > 0)

	-- Update everything by simulating a size change.
	self.private_OnUpdateScrollFrameSize(self.scrollFrame, self.scrollFrame:GetWidth(), self.scrollFrame:GetHeight())
end

-- Call this when the size of the scroll frame changes.
function ListView.private_OnUpdateScrollFrameSize(scrollFrame, width, height)
	assert(scrollFrame and width and height)
	local self = scrollFrame.owner

	if self.delegate then
		self.buttonCount = floor(self:GetHeight() / self.itemHeight)

		-- Create new buttons as necessary
		for i = #self.buttons + 1, self.buttonCount do
			local newButton = self.delegate:ListView_CreateButton(self)
			newButton.buttonIndex = i
			assert(newButton)	-- (no nil results, please)
			newButton:SetPoint("TOPLEFT", 0, -(i - 1) * self.itemHeight)
			self.buttons[i] = newButton
			newButton:SetScript("OnClick", function(newButton, mouseButton, down)
				if self.delegate and self.delegate.ListView_OnClickButton then
					local offset = FauxScrollFrame_GetOffset(self.scrollFrame)
					self.delegate:ListView_OnClickButton(newButton, offset + newButton.buttonIndex, self.itemCount)
				end
			end)

			newButton:SetScript("OnDoubleClick", function(newButton, mouseButton)
				if self.delegate and self.delegate.ListView_OnDoubleClickButton then
					local offset = FauxScrollFrame_GetOffset(self.scrollFrame)
					self.delegate:ListView_OnDoubleClickButton(newButton, offset + newButton.buttonIndex, self.itemCount)
				end
			end)
		end

		-- Show all buttons now visible
		for i = 1, self.buttonCount do
			if self.buttons[i] then
				self.buttons[i]:Show()
			end
		end

		-- Hide all buttons that aren't visible anymore
		for i = self.buttonCount + 1, #self.buttons do
			if self.buttons[i] then
				self.buttons[i]:Hide()
			end
		end
	end

	-- Call refresh instead of Validate to take advantage of its message-collapsing functionality.
	self:Refresh()
end

-- Call this when the number of items in the list may have changed.
function ListView:Validate()
	if self.isInvalid then
		self.isInvalid = false
		if self.delegate then
			self.itemCount = self.delegate:ListView_GetItemCount()
			assert(self.itemCount >= 0)
		end
		self:private_UpdateButtons()
	end
end

-- Call this when list data changes, but the count remains the same.
function ListView:private_UpdateButtons()
	FauxScrollFrame_Update(self.scrollFrame, self.itemCount, self.buttonCount, self.itemHeight)

	if self.delegate then
		local offset = FauxScrollFrame_GetOffset(self.scrollFrame)
		for i = 1, self.buttonCount do
			self.delegate:ListView_UpdateButton(self.buttons[i], offset + i, self.itemCount)
		end
	end
end

-- Called by the user to refresh the list.
function ListView:Refresh()
	self.isInvalid = true
	AS2:Dispatch(self.Validate, self)
end
