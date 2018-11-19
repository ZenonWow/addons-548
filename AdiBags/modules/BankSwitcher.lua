--[[
AdiBags - Adirelle's bag addon.
Copyright 2010-2012 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local GameTooltip = _G.GameTooltip
local UseContainerItem = _G.UseContainerItem
--GLOBALS>

local mod = addon:NewModule('BankSwitcher', 'AceEvent-3.0')
mod.uiName = L['Bank Switcher']
mod.uiDesc = L['Move items from and to the bank by right-clicking on section headers.']

function mod:OnEnable()
	self:RegisterEvent('BANKFRAME_OPENED')
	self:RegisterEvent('BANKFRAME_CLOSED')
	-- if  addon.bags.bank.atBank  then  self:BANKFRAME_OPENED()  end
end

function mod:OnDisable()
	self:UnregisterEvent('BANKFRAME_OPENED')
	self:UnregisterEvent('BANKFRAME_CLOSED')
	self:BANKFRAME_CLOSED()
end

function mod:BANKFRAME_OPENED()
	if  not self.registered  then
		addon.RegisterSectionHeaderScript(self, 'OnTooltipUpdate', 'OnTooltipUpdateSectionHeader')
		addon.RegisterSectionHeaderScript(self, 'OnClick', 'OnClickSectionHeader')
		self.registered = true
	end
end

function mod:BANKFRAME_CLOSED()
	if  self.registered  then
		addon.UnregisterAllSectionHeaderScripts(self)
		self.registered = false
	end
end

function mod:OnTooltipUpdateSectionHeader(_, _, tooltip)
	tooltip:AddLine(L['Right-click to move these items.'])
end

function mod:OnClickSectionHeader(_, header, button)
	if button == "RightButton" then
		for slotId, bag, slot in header.section:IterateContainerSlots() do
			UseContainerItem(bag, slot)
		end
	end
end



