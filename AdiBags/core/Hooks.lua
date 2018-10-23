--[[
AdiBags - Adirelle's bag addon.
Copyright 2010-2012 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local BACKPACK_CONTAINER = _G.BACKPACK_CONTAINER
local ContainerFrame_GenerateFrame = _G.ContainerFrame_GenerateFrame
local ContainerFrame_GetOpenFrame = _G.ContainerFrame_GetOpenFrame
local GetContainerNumSlots = _G.GetContainerNumSlots
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS
local NUM_BANKBAGSLOTS = _G.NUM_BANKBAGSLOTS
local NUM_CONTAINER_FRAMES = _G.NUM_CONTAINER_FRAMES
local pairs = _G.pairs
--GLOBALS>

--------------------------------------------------------------------------------
-- Bag-related function hooks
--------------------------------------------------------------------------------

local hookedBags = {}
addon.hookedBags = hookedBags
local ContainerFrames = {}
do
	for  i = 1,NUM_CONTAINER_FRAMES  do
		ContainerFrames[i] = _G["ContainerFrame"..i]
	end
end

local function GetNumBags()
	if addon:GetInteractingWindow() == "BANKFRAME" then
		return NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
	else
		return NUM_BAG_SLOTS
	end
end

local IterateBuiltInContainers
do
	local function iter(maxContainer, id)
		while id < maxContainer do
			id = id + 1
			if not hookedBags[id] and GetContainerNumSlots(id) > 0 then
				return id
			end
		end
	end

	function IterateBuiltInContainers()
		return iter, GetNumBags(), -1
	end
end

--[[
/run for i=1,NUM_CONTAINER_FRAMES do local f=_G['ContainerFrame'..i]; local id=f:GetID(); print(i ..'.: id='.. id ..' slots='.. GetContainerNumSlots(i)) end
--]]

function addon:GetContainerFrame(id, spawn)
	for i, frame in pairs(ContainerFrames) do
		if frame:IsShown() and frame:GetID() == id then
			return frame
		end
	end
	if spawn then
		local size = GetContainerNumSlots(id)
		if size > 0 then
			local frame = ContainerFrame_GetOpenFrame()
			ContainerFrame_GenerateFrame(frame, size, id)
		end
	end
end

function addon:ToggleAllBags()
	if  IsShiftKeyDown()  then  return self.hooks.ToggleAllBags()  end
	
	for i, bag in self:IterateBags() do
		if  bag:CanOpen() and  not bag:IsOpen() then
			return self:OpenAllBags()
		end
	end
	
	--[[
	local numBags = GetNumBags()
	local found = {}
	for  i = 1,NUM_CONTAINER_FRAMES  do
		local frame = ContainerFrames[i]
		local id = frame:GetID()
		if  0 <= id  and  id <= numBags  and  frame:IsShown()  then
			found[id] = frame
		end
	end
	
	for  id = 0,numBags  do
		if  not found[id]  then
			return self:OpenAllBags()
		end
	end
	--]]
	----[[
	for id in IterateBuiltInContainers() do
		if not self:GetContainerFrame(id) then
			return self:OpenAllBags()
		end
	end
	--]]
	
	-- All bags open so close them
	return self:CloseAllBags()
end

function addon:OpenAllBags(requesterFrame)
	if  IsShiftKeyDown()  then  return self.hooks.OpenAllBags(requesterFrame)  end
	
	if requesterFrame then return end -- UpdateInteractingWindow takes care of these cases
	for _, bag in self:IterateBags() do
		bag:Open()
	end
	for id in IterateBuiltInContainers() do
		self:GetContainerFrame(id, true)
	end
end

function addon:CloseAllBags(requesterFrame)
	if  IsShiftKeyDown()  then  return self.hooks.CloseAllBags(requesterFrame)  end
	
	if requesterFrame then return end -- UpdateInteractingWindow takes care of these cases
	local found = false
	for i, bag in self:IterateBags() do
		if bag:Close() then
			found = true
		end
	end
	
	--[[
	local numBags = GetNumBags()
	local found = {}
	for  i = 1,NUM_CONTAINER_FRAMES  do
		local frame = ContainerFrames[i]
		local id = frame:GetID()
		if  0 <= id  and  id <= numBags  and  frame:IsShown()  then
			frame:Hide()
			found = 1
		end
	end
	--]]
	
	----[[
	for id in IterateBuiltInContainers() do
		local frame = self:GetContainerFrame(id)
		if frame then
			frame:Hide()
			found = 1
		end
	end
	--]]
	return found
end
--[[
function addon:ToggleBag(id)
	print('ToggleBag('..id..')')
	if  IsShiftKeyDown()  then  return self.hooks.ToggleBag(id)  end
	
	local ourBag = hookedBags[id]
	if ourBag then
		return ourBag:Toggle()
	else
		local frame = self:GetContainerFrame(id, true)
		if frame then
			frame:Hide()
		end
	end
end
--]]
function addon:OpenBackpack()
	print('OpenBackpack()')
	if  IsShiftKeyDown()  then  return self.hooks.OpenBackpack()  end
	
	local ourBackpack = hookedBags[BACKPACK_CONTAINER]
	if ourBackpack then
		self.backpackWasOpen = ourBackpack:IsOpen()
		ourBackpack:Open()
	else
		local frame = self:GetContainerFrame(BACKPACK_CONTAINER, true)
		self.backpackWasOpen = not not frame
	end
	return self.backpackWasOpen
end

function addon:CloseBackpack()
	print('CloseBackpack()')
	if  IsShiftKeyDown()  then  return self.hooks.CloseBackpack()  end
	
	if self.backpackWasOpen then
		return
	end
	local ourBackpack = hookedBags[BACKPACK_CONTAINER]
	if ourBackpack then
		return ourBackpack:Close()
	else
		local frame = self:GetContainerFrame(BACKPACK_CONTAINER)
		if frame then
			frame:Hide()
		end
	end
end

function addon:ToggleBackpack()
	print('ToggleBackpack()')
	if  IsShiftKeyDown()  then  return self.hooks.ToggleBackpack()  end
	
	local frame = self:GetContainerFrame(BACKPACK_CONTAINER)
	if frame then  return self.hooks.ToggleBackpack()  end
	
	local ourBackpack = hookedBags[BACKPACK_CONTAINER]
	if ourBackpack then
		return ourBackpack:Toggle()
	else
		return self.hooks.ToggleBackpack()
		--self:OpenBackpack()
	end
end

function addon:CloseSpecialWindows()
	print('CloseSpecialWindows()')
	local found = self.hooks.CloseSpecialWindows()
	if  IsShiftKeyDown()  then  return  found  end
	return self:CloseAllBags() or found
end
