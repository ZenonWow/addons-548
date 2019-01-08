if not _G[...] then return end
local addon = _G[...]
local addonName = addon.addonName

local L = addon.L

--[[----------------------------------------------------------------------------
Core
------------------------------------------------------------------------------]]
local function DeletePanel(id)
	local settings = addon.settings
	local cacheSettings, pluginSettings = settings.panels[id], settings.plugins
	settings.panels[id] = nil
	if settings.defaultPanel == id then
		settings.defaultPanel = next(settings.panels)
	end
	for section in pairs(addon.sectionTypes) do
		local children = cacheSettings[section]
		for index = 1, #children do
			local name = children[index]
			if pluginSettings[name] then
				pluginSettings[name].enable = false
				addon.SetInheritance(name, nil)
			end
		end
	end
	if addon.panels[id] then
		addon.panels[id]:Recycle()
	end
	addon.PanelList:Delete(id)
	addon.UpdatePanelList()
end

local function DeletePlugin(name)
	local id, section, index = addon.GetPluginLocation(name)
	if id then
		tremove(addon.settings.panels[id][section], index)
	end
	addon.settings.plugins[name] = nil
	addon.PluginList:Delete(name)
end

local function RenamePanel(id, value)
	if value == "" or value == L["<unnamed>"] then
		value = nil
	end
	if addon.settings.panels[id].alias ~= value then
		addon.settings.panels[id].alias = value
		addon.PanelList:Add(id)
		addon.UpdatePanelList()
	end
end

local function RenamePlugin(name, value)
	if value == "" or value == name then
		value = nil
	end
	if addon.pluginAlias[name] ~= value then
		addon.pluginAlias[name] = value
		if addon.plugins[name] then
			addon.plugins[name]:Refresh()
		end
		addon.PluginList:Add(name)
	end
end

--[[----------------------------------------------------------------------------
Edit box
------------------------------------------------------------------------------]]
local editBox = CreateFrame('EditBox', nil, addon.SideBar)
editBox:SetFrameLevel(editBox:GetFrameLevel() + 1)
editBox:SetCountInvisibleLetters(false)
editBox:Hide()

editBox:SetScript('OnEditFocusLost', function(self)
	if self:IsShown() then
		if self.ignore then
			self.ignore = nil
		else
			(addon.SideBarMenu.isPanel and RenamePanel or RenamePlugin)(self.entry.data.key, self:GetText():trim())
		end
		self:Hide()
	end
end)

editBox:SetScript('OnEnterPressed', editBox.ClearFocus)

editBox:SetScript('OnEscapePressed', function(self)
	self.ignore = true
	self:ClearFocus()
end)

editBox:SetScript('OnHide', function(self)
	self.entry.text:Show()
end)

editBox:SetScript('OnShow', function(self)
	local entry = addon.SideBarMenu.entry
	self.entry = entry
	entry.text:Hide()
	self:SetAllPoints(entry.text)
	self:SetFontObject(entry:GetNormalFontObject())
	self:SetText(entry.data.label)
	self:HighlightText()
	self:SetCursorPosition(self:GetNumLetters())
	self:SetFocus()
end)

--[[----------------------------------------------------------------------------
Drop down menu
------------------------------------------------------------------------------]]
local function OnClick(self, delete, key)
	editBox:ClearFocus()
	if delete then
		delete(key)
	else
		editBox:Show()
	end
end

local SideBarMenu = LibStub('LibMenuAssist-1.0'):New()
SideBarMenu.point = 'cursor'
SideBarMenu.xOffset = 0
SideBarMenu.yOffset = 0

SideBarMenu.initialize = function(self, level)
	local data, info = self.entry.data, UIDropDownMenu_CreateInfo()
	info.notCheckable = true

	info.isTitle = true
	info.text = addon.RemoveColorCodes(data.label)
	UIDropDownMenu_AddButton(info, level)
	info.isTitle = nil

	info.func, info.arg2 = OnClick, data.key
	info.text = L["Delete"]
	if self.isPanel then
		info.disabled, info.arg1 = #addon.PanelList <= 1, DeletePanel
	else
		info.disabled, info.arg1 = addon.dataObj[data.key], DeletePlugin
	end
	UIDropDownMenu_AddButton(info, level)
	info.disabled, info.arg1 = nil, nil

	info.text = L["Rename"]
	UIDropDownMenu_AddButton(info, level)
end

addon.SideBarMenu = SideBarMenu
