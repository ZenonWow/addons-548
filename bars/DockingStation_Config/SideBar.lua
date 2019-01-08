if not _G[...] then return end
local addon = _G[...]
local addonName = addon.addonName

local panelConfig, pluginConfig = addon.ConfigFrames[1], addon.ConfigFrames[2]
local PanelList, PluginList = addon.PanelList, addon.PluginList
local currentList, LUT = PanelList, { }

local L = addon.L

addon.UpdateConfigVariables = addon.DoNothing

--[[----------------------------------------------------------------------------
Constants
------------------------------------------------------------------------------]]
local ENTRY_HEIGHT, ENTRY_WIDTH, INSET_HEIGHT, INSET_WIDTH, NUM_ENTRIES = 18, 175, 21, 12, 23

--[[----------------------------------------------------------------------------
Main frame
------------------------------------------------------------------------------]]
local sideBar, slider = CreateFrame('Frame', nil, InterfaceOptionsFrame)
sideBar:SetSize(ENTRY_WIDTH + INSET_WIDTH, ENTRY_HEIGHT * NUM_ENTRIES + INSET_HEIGHT)
sideBar:SetBackdrop({ bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]], edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]], edgeSize = 32, tile = true, tileSize = 32, insets = { left = 11, right = 11, top = 11, bottom = 10 } })
sideBar:SetPoint('LEFT', InterfaceOptionsFrame, 'RIGHT', -13, 0)
sideBar:EnableMouse(true)
sideBar:Hide()

local displayed = { }
function sideBar:Refresh(offset)
	local numDisplayed, data, entry = 0
	wipe(displayed)
	for index = 1, #currentList do
		if not currentList[index].hidden then
			numDisplayed = numDisplayed + 1
			displayed[numDisplayed] = currentList[index]
		end
	end
	offset = slider:Refresh(numDisplayed - NUM_ENTRIES, offset)
	for index = 1, NUM_ENTRIES do
		entry = sideBar[index]													-- Don't use 'self' here due to slider:OnValueChanged calls
		data = displayed[index + offset]
		if data then
			entry.data = data
			if not data.hasChildren then
				entry.toggle:Hide()
			else
				if data.collapsed then
					entry.toggle:SetNormalTexture([[Interface\Buttons\UI-PlusButton-Up]])
					entry.toggle:SetPushedTexture([[Interface\Buttons\UI-PlusButton-Down]])
				else
					entry.toggle:SetNormalTexture([[Interface\Buttons\UI-MinusButton-Up]])
					entry.toggle:SetPushedTexture([[Interface\Buttons\UI-MinusButton-Down]])		
				end
				entry.toggle:Show()
			end
			if not data.parent then
				entry:SetNormalFontObject(GameFontNormal)
				entry:SetHighlightFontObject(GameFontHighlight)
				entry.text:SetPoint('LEFT', entry, 'LEFT', 8, 2)
			else
				entry:SetNormalFontObject(GameFontHighlightSmall)
				entry:SetHighlightFontObject(GameFontHighlightSmall)
				entry.text:SetPoint('LEFT', entry, 'LEFT', 16, 2)
			end
			if not data.selected then
				entry:UnlockHighlight()
			else
				entry:LockHighlight()
			end
			entry:SetText(data.label)
			entry:Show()
		else
			entry:Hide()
		end
	end
end

--[[----------------------------------------------------------------------------
Scroll bar frames
------------------------------------------------------------------------------]]
slider = CreateFrame('Slider', nil, sideBar)									-- Declared local earlier
slider:SetOrientation('VERTICAL')

slider:SetThumbTexture([[Interface\Buttons\UI-ScrollBar-Knob]])
local sliderThumb = slider:GetRegions()
sliderThumb:SetSize(16, 24)
sliderThumb:SetTexCoord(0.25, 0.75, 0.125, 0.875)

local sliderDown = CreateFrame('Button', nil, slider, 'UIPanelScrollDownButtonTemplate')
sliderDown:SetPoint('BOTTOMRIGHT', sideBar, 'BOTTOMRIGHT', -11, 9)

local sliderUp = CreateFrame('Button', nil, slider, 'UIPanelScrollUpButtonTemplate')
sliderUp:SetPoint('TOPRIGHT', sideBar, 'TOPRIGHT', -11, -11)

slider:SetPoint('TOPLEFT', sliderUp, 'BOTTOMLEFT', 0, 5)
slider:SetPoint('BOTTOMRIGHT', sliderDown, 'TOPRIGHT', 0, -4)
slider:SetBackdrop({ bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]], edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 12, tile = true, tileSize = 16, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
slider:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.6)
slider:EnableMouseWheel(true)
slider:SetMinMaxValues(0, 0)
slider:SetValue(0)
slider:SetValueStep(1)

slider:SetScript('OnHide', function(self)
	sideBar:EnableMouseWheel(false)
	sideBar:SetWidth(ENTRY_WIDTH + INSET_WIDTH)
end)
slider:SetScript('OnShow', function(self)
	sideBar:EnableMouseWheel(true)
	sideBar:SetWidth(ENTRY_WIDTH + INSET_WIDTH + self:GetWidth())
end)
slider:SetScript('OnValueChanged', sideBar.Refresh)

local function OnClick(self)
	PlaySound('UChatScrollButton')
	slider:SetValue(slider:GetValue() - (self == sliderUp and 1 or -1))
end
sliderDown:SetScript('OnClick', OnClick)
sliderUp:SetScript('OnClick', OnClick)

sideBar:SetScript('OnMouseWheel', function(_, direction)						-- up = 1, down = -1
	slider:SetValue(slider:GetValue() - direction)
end)

function slider:Refresh(max, offset)
	if max > 0 then
		self:SetMinMaxValues(0, max)
		offset = offset or self:GetValue()
		if offset ~= 0 then
			sliderUp:Enable()
		else
			sliderUp:Disable()
		end
		if offset ~= max  then
			sliderDown:Enable()
		else
			sliderDown:Disable()
		end
		self:Show()
	else
		offset = 0
		self:Hide()
	end
	return offset
end

--[[----------------------------------------------------------------------------
Selectable entries
------------------------------------------------------------------------------]]
local function OnToggle(self)
	PlaySound('igMainMenuOptionCheckBoxOn')
	local data = self:GetParent().data
	data.collapsed = not data.collapsed
	local collapsed, key = data.collapsed, data.key
	for index = 1, #currentList do
		if currentList[index].parent == key then
			currentList[index].hidden = collapsed
		end
	end
	sideBar:Refresh()
end

local function OnClick(self, button)
	if button == 'RightButton' then
		local SideBarMenu = addon.SideBarMenu
		SideBarMenu.entry, SideBarMenu.isPanel = self, currentList == PanelList
		return SideBarMenu:Open()
	end
	PlaySound('igMainMenuOptionCheckBoxOn')
	currentList:Select(self.data.key)
end

for index = 1, NUM_ENTRIES do
	local entry = CreateFrame('Button', nil, sideBar)
	entry:SetSize(ENTRY_WIDTH, ENTRY_HEIGHT)
	if index ~= 1 then
		entry:SetPoint('TOPLEFT', sideBar[index - 1], 'BOTTOMLEFT')
	else
		entry:SetPoint('TOPLEFT', sideBar, 'TOPLEFT', 6, -12)
	end
	entry:RegisterForClicks('AnyUp')
	entry:SetScript('OnClick', OnClick)
	entry:SetHighlightTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
	entry:SetText(index)

	local toggle = CreateFrame('Button', nil, entry)
	toggle:SetSize(14, 14)
	toggle:SetPoint('TOPRIGHT', entry, 'TOPRIGHT', -6, -1)
	toggle:RegisterForClicks('AnyUp')
	toggle:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
	toggle:SetScript('OnClick', OnToggle)

	local highlight, text = entry:GetRegions()
	highlight:SetPoint('TOPLEFT', entry, 'TOPLEFT', 0, 1)
	highlight:SetPoint('BOTTOMRIGHT', entry, 'BOTTOMRIGHT', 0, 1)	
	highlight:SetVertexColor(0.196, 0.388, 0.8)

	text:SetPoint('RIGHT', toggle, 'LEFT', -2, -1)
	text:SetJustifyH('LEFT')

	entry.text, entry.toggle = text, toggle
	sideBar[index] = entry
end

--[[----------------------------------------------------------------------------
Shared panel/plugin list support
------------------------------------------------------------------------------]]
local heap, refresh_list = setmetatable({ }, { __mode = 'kv' })

local function delete_entry(list, key, noRefresh)
	local data = LUT[key]
	for index = 1, #list do
		if list[index] == data then
			tremove(list, index)
			break
		end
	end
	if noRefresh then
		return data
	end
	heap[#heap + 1], LUT[key] = wipe(data), nil
	if list.selection == key then
		list.selection = nil
		list:Select(list[1].key)
	elseif currentList == list then
		sideBar:Refresh()
	end
end

local function get_data()
	local data
	data, heap[#heap] = heap[#heap], nil
	return data or { }
end

local function select_entry(list, key, noContainerRefresh)
	if list.selection == key then return end
	if LUT[list.selection] then
		LUT[list.selection].selected = false
	end
	list.selection, LUT[key].selected = key, true
	if list.container:IsVisible() and not noContainerRefresh then
		addon.UpdateConfigVariables()
		list.container:Refresh()
	end
	if currentList == list then
		sideBar:Refresh()
	end
end

function refresh_list(list)														-- Declared local earlier
	local Add = list.Add
	for index = 1, #list do
		heap[#heap + 1] = wipe(list[index])
	end
	wipe(list)
	list.max, list.min, list.value = 0, 0, 0
	list.Add, list.Delete, list.Refresh, list.Select = Add, delete_entry, refresh_list, select_entry
	if list == PanelList then
		list.container, list.source = panelConfig, addon.settings.panels
		wipe(LUT)																-- Assumes PanelList is always refreshed just before PluginList
	else
		list.container, list.source = pluginConfig, addon.settings.plugins
	end
	for key in pairs(list.source) do
		Add(list, key, true)
	end
	if list[1] then
		list:Select(list[1].key)
	end
end

--[[----------------------------------------------------------------------------
Panel list
------------------------------------------------------------------------------]]
function PanelList:Add(id, noRefresh)
	local data
	if LUT[id] then
		data = self:Delete(id, true)
		data.selected, data = data.selected, wipe(data)
	else
		data = get_data()
		LUT[id] = data
	end
	local sortKey, insertPoint = addon.settings.panels[id].alias or L["<unnamed>"]
	data.key, data.label, data.sortKey = id, sortKey, sortKey
	for index = 1, #self do
		if sortKey < self[index].sortKey then
			insertPoint = index
			break
		end
	end
	tinsert(self, insertPoint or #self + 1, data)
	if currentList == self and not noRefresh then
		sideBar:Refresh()
	end
end

--[[----------------------------------------------------------------------------
Plugin list
------------------------------------------------------------------------------]]
local function plugin_list_iterator(parent, index)
	for index = index + 1, #PluginList do
		if PluginList[index].parent == parent then
			return index, PluginList[index]
		end
	end
end

local function get_insert_point(data, start)
	local insertPoint, sortKey = start + 1, data.sortKey
	for index, element in plugin_list_iterator, data.parent, start do
		if sortKey < element.sortKey then
			insertPoint = index
			break
		else
			insertPoint = index + 1
		end
	end
	return insertPoint
end

local children = { }
function PluginList:Add(name, noRefresh)
	local data
	if LUT[name] then
		data = self:Delete(name, true)
		data.selected, data = data.selected, wipe(data)
	else
		data = get_data()
		LUT[name] = data
	end
	local numChildren, pluginSettings, insertPoint = 0, addon.settings.plugins[name]
	local label = addon.pluginAlias[name] or strtrim(name)
	local parent, sortKey = pluginSettings.group, strlower(addon.RemoveColorCodes(label))
	data.key, data.parent, data.sortKey = name, parent, sortKey
	data.label = addon.dataObj[name] and label or '|cff808080' .. addon.RemoveColorCodes(label)
	if addon.pluginType[name] == 'group' then
		for _, element in plugin_list_iterator, name, 0 do
			numChildren = numChildren + 1
			children[numChildren] = element
		end
		for index = 1, numChildren do
			self:Delete(children[index].key, true)
		end
		data.parent = nil														-- Groups of groups not supported
	elseif parent then
		for index, element in plugin_list_iterator, nil, 0 do
			if element.key == parent then
				if not element.hasChildren then
					element.collapsed, element.hasChildren = true, true
				end
				data.hidden, insertPoint = element.collapsed, index
				break
			end
		end
		insertPoint = insertPoint and get_insert_point(data, insertPoint)
	end
	if not insertPoint then
		insertPoint = #self + 1
		for index, element in plugin_list_iterator, nil, 0 do
			if sortKey < element.sortKey then
				insertPoint = index
				break
			end
		end
	end
	tinsert(self, insertPoint, data)
	if numChildren > 0 then
		data.collapsed, data.hasChildren = true, true
		local child
		for index = 1, numChildren do
			child = children[index]
			tinsert(self, get_insert_point(child, insertPoint), child)
			child.hidden, LUT[child.key] = true, child
		end
		wipe(children)
	end
	if currentList == self and not noRefresh then
		sideBar:Refresh()
	end
end

--[[----------------------------------------------------------------------------
Auto-hide
------------------------------------------------------------------------------]]
local timer = 0

local function update_timer(self, elapsed)
	timer = timer + elapsed
	if timer < 2 then return end
	self:SetScript('OnUpdate', nil)
	timer = nil
	if not (panelConfig:IsShown() or pluginConfig:IsShown()) then
		self:Hide()
	end
end

sideBar:SetScript('OnHide', function(self)
	addon.SideBarMenu:Close()
	if timer then
		self:SetScript('OnUpdate', nil)
		timer = nil
	end
end)

sideBar:SetScale(addon.settings.scaleSideBar)
function sideBar:ShowScale(value)
	self:SetScale(value)
	if not timer then
		self:SetScript('OnUpdate', update_timer)
		self:Show()
	end
	timer = 0
end

--[[----------------------------------------------------------------------------
Global to config
------------------------------------------------------------------------------]]
sideBar:SetScript('OnShow', function(self)
	local list = pluginConfig:IsShown() and PluginList or PanelList
	if currentList ~= list then
		currentList.value, currentList.min, currentList.max = slider:GetValue(), slider:GetMinMaxValues()
		currentList = list
		slider:SetMinMaxValues(list.min, list.max)
		slider:SetValue(list.value)
		sideBar:Refresh()
	end
	self:SetFrameStrata(InterfaceOptionsFrame:GetFrameStrata())
	self:SetFrameLevel(InterfaceOptionsFrame:GetFrameLevel() - 1)
end)

refresh_list(PanelList)
refresh_list(PluginList)

addon.SideBar = sideBar
