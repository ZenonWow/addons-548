﻿--[[
	actionBar.lua
		the code for Dominos action bars and buttons
--]]

--[[ globals ]]--

local Dominos = _G['Dominos']
local ActionButton = Dominos.ActionButton

local MAX_BUTTONS = 120

local ceil = math.ceil
local min = math.min
local format = string.format

--[[ Action Bar ]]--

local ActionBar = Dominos:CreateClass('Frame', Dominos.Frame); Dominos.ActionBar = ActionBar

ActionBar.class = select(2, UnitClass('player'))
local active = {}

function ActionBar:New(id)
	local f = self.super.New(self, id)
	local bar = f

	--[[
	f.sets.pages = setmetatable(f.sets.pages, f.id == 1 and self.mainbarOffsets or self.defaultOffsets)
	f.pages = f.sets.pages[f.class]
	--]]
	if  not bar.sets.pagesAllClass  then
		-- 2018-01: migrate  bar.sets.pages[classId]  to  bar.sets.pagesAllClass
		-- preserve paging setting for current (character's) class
		local unitClass = select(2, UnitClass('player'))
		bar.sets.pagesAllClass= bar.sets.pages[unitClass]  or  {}
		-- remove from settings to be merged
		bar.sets.pages[unitClass]= nil
		local merged= bar.sets.pagesAllClass
		local conflicted= nil
		
		for  classId, classPages  in  bar.sets.pages  do
			for  pageId, offset  in  classPages  do
				if  not merged[pageId]  then
					merged[pageId]= offset
				elseif  merged[pageId] ~= offset  then
					DEFAULT_CHAT_FRAME:AddMessage('Losing conflicting paging on bar #' .. id .. ' for class ' .. classId .. ': ' .. pageId .. '->' .. offset+1)
					conflicted= conflicted  or  {}
					conflicted[classId]= conflicted[classId]  or  {}
					conflicted[classId][pageId]= offset
				end
			end
		end
		
		-- save only what was conflicted, removes old setting (is nil) if no conflict
		--bar.sets.pages= conflicted
	end

	bar.pages= bar.sets.pagesAllClass

	f.baseID = f:MaxLength() * (id-1)

	f:LoadButtons()
	f:LoadStateController()
	f:UpdateClickThrough()
	f:UpdateStateDriver()
	f:Layout()
	f:UpdateGrid()
	f:UpdateRightClickUnit()
	f:SetScript('OnSizeChanged', self.OnSizeChanged)
	f:UpdateFlyoutDirection()

	active[id] = f

	return f
end

function ActionBar:OnSizeChanged()
	if not InCombatLockdown() then
		self:UpdateFlyoutDirection()
	end
end


-- Defaults for paging bars (aka. offset) individually for each class. Only the played classes are initialized by AceDB.
-- Bar default paging offset: +1-5, druid forms: +6-9, rogue stealth: +6
-- local mainbarOffsets = {
local mainbarPages = {
	-- defaults for all classes
	page2 = 1,
	page3 = 2,
	page4 = 3,
	page5 = 4,
	page6 = 5,
--[[
	-- DRUID defaults
	cat = 6,
	bear = 8,
	moonkin = 9,
	tree = 7,
	-- ROGUE defaults
	stealth = 6,
	shadowdance = 6,
--]]
}

local classLocalized, class = UnitClass('player')
if class == 'DRUID' then
	mainbarPages.cat = 6
	mainbarPages.bear = 8
	mainbarPages.moonkin = 9
	mainbarPages.tree = 7
elseif class == 'ROGUE' then
	mainbarPages.stealth = 6
	mainbarPages.shadowdance = 6
end


local defaults = {}
defaults.point = 'BOTTOM'
defaults.spacing = 4
defaults.padW = 2
defaults.padH = 2
defaults.pages = { ['*'] = {} }
defaults.pagesAllClass = {}

--TODO: change the position code to be based more on the number of action bars
function ActionBar:GetDefaults()
	-- New instance of defaults for each bar.
	local defaults = _G.LibShared.merge({}, defaults)

	local x = math.floor((self.id-1) / 3)
	if x > 2 then  x = 2  end
	local y = self.id - x*3
	defaults.numButtons = self:MaxLength()
	defaults.x = x * 40 * defaults.numButtons
	defaults.y = y * 40

	if self.id == 1 then
		defaults.pages = { ['*'] = mainbarPages }
		defaults.pagesAllClass = mainbarPages
	end
	return defaults
end


function ActionBar:Free()
	active[self.id] = nil
	self.super.Free(self)
end

--returns the maximum possible size for a given bar
function ActionBar:MaxLength()
	return floor(MAX_BUTTONS / Dominos:NumBars())
end


--[[ button stuff]]--

function ActionBar:LoadButtons()
	for i = 1, self:NumButtons() do
		local b = ActionButton:New(self.baseID + i)
		if b then
			b:SetParent(self.header)
			b:SetFlyoutDirection(self:GetFlyoutDirection())
			self.buttons[i] = b
		else
			break
		end
	end
	self:UpdateActions()
end

function ActionBar:AddButton(i)
	local b = ActionButton:New(self.baseID + i)
	if b then
		self.buttons[i] = b
		b:SetParent(self.header)
		b:SetFlyoutDirection(self:GetFlyoutDirection())
		b:LoadAction()
		self:UpdateAction(i)
		self:UpdateGrid()
	end
end

function ActionBar:RemoveButton(i)
	local b = self.buttons[i]
	self.buttons[i] = nil
	b:Free()
end


--[[ Paging Code ]]--

function ActionBar:SetOffset(stateId, page)
	self.pages[stateId] = page
	self:UpdateStateDriver()
end

function ActionBar:GetOffset(stateId)
	return self.pages[stateId]
end

-- note to self:
-- if you leave a ; on the end of a statebutton string, it causes evaluation issues, 
-- especially if you're doing right click selfcast on the base state
function ActionBar:UpdateStateDriver()
	UnregisterStateDriver(self.header, 'page', 0)

	local header = ''
	for i, state in Dominos.BarStates:getAll() do
		local stateId = state.id
		local condition
		if type(state.value) == 'function' then
			condition = state.value()
		else
			condition = state.value
		end

		if self:GetOffset(stateId) then
			header = header .. condition .. 'S' .. i .. ';'
		end
	end

	if header ~= '' then
		RegisterStateDriver(self.header, 'page', header .. 0)
	end

	self:UpdateActions()
	self:RefreshActions()
end

local function ToValidID(id)
	return (id - 1) % MAX_BUTTONS + 1
end

--updates the actionID of a given button for all states
function ActionBar:UpdateAction(i)
	local b = self.buttons[i]
	local maxSize = self:MaxLength()

	b:SetAttribute('button--index', i)

	for i, state in Dominos.BarStates:getAll() do
		local offset = self:GetOffset(state.id)
		local actionId = nil

		if offset then
			actionId = ToValidID(b:GetAttribute('action--base') + offset * maxSize)
		end

		b:SetAttribute('action--S' .. i, actionId)
	end
end

--updates the actionID of all buttons for all states
function ActionBar:UpdateActions()
	for i = 1, #self.buttons do
		self:UpdateAction(i)
	end
end

local runUpdateSnippet = " self:RunAttribute('updateState') "

function ActionBar:LoadStateController()
	self.header:SetAttribute('_onstate-overridebar', runUpdateSnippet)
	self.header:SetAttribute('_onstate-overridepage', runUpdateSnippet)
	self.header:SetAttribute('_onstate-page', runUpdateSnippet)

	self.header:SetAttribute('updateState', [[
		local state
		if self:GetAttribute('state-overridepage') > 10 and self:GetAttribute('state-overridebar')
		then  state = 'override'
		else  state = self:GetAttribute('state-page')
		end
		
		control:ChildUpdate('action', state)
	]])

	self:UpdateOverrideBar()
end

function ActionBar:RefreshActions()
	self.header:Execute(runUpdateSnippet)
end

function ActionBar:UpdateOverrideBar()
	local isOverrideBar = self:IsOverrideBar()

	self.header:SetAttribute('state-overridebar', isOverrideBar)
end

--returns true if the possess bar, false otherwise
function ActionBar:IsOverrideBar()
	return self == Dominos:GetOverrideBar()
end


--Empty button display
function ActionBar:ShowGrid()
	for _,b in pairs(self.buttons) do
		b:SetAttribute('showgrid', b:GetAttribute('showgrid') + 1)
		b:UpdateGrid()
	end
end

function ActionBar:HideGrid()
	for _,b in pairs(self.buttons) do
		b:SetAttribute('showgrid', max(b:GetAttribute('showgrid') - 1, 0))
		b:UpdateGrid()
	end
end

function ActionBar:UpdateGrid()
	if Dominos:ShowGrid() then
		self:ShowGrid()
	else
		self:HideGrid()
	end
end

---keybound support
function ActionBar:KEYBOUND_ENABLED()
	self:ShowGrid()
	for _, b in pairs(self.buttons) do
		b:RegisterEvent('UPDATE_BINDINGS')
	end
end

function ActionBar:KEYBOUND_DISABLED()
	self:HideGrid()
end

--right click targeting support
function ActionBar:UpdateRightClickUnit()
	self.header:SetAttribute('*unit2', Dominos:GetRightClickUnit())
end

--utility functions
function ActionBar:ForAll(method, ...)
	for _,f in pairs(active) do
		f[method](f, ...)
	end
end

--[[ flyout direction updating ]]--

function ActionBar:GetFlyoutDirection()
	local w, h = self:GetSize()
	local isVertical = w < h
	local anchor = self:GetPoint()

	if isVertical then
		if anchor and anchor:match('LEFT') then
			return 'RIGHT'
		end
		return 'LEFT'
	end

	if anchor and anchor:match('TOP') then
		return 'DOWN'
	end
	return 'UP'
end

function ActionBar:UpdateFlyoutDirection()
	if self.buttons then
		local direction = self:GetFlyoutDirection()

		--dear blizzard, I'd like to be able to use the useparent-* attribute stuff for this
		for _,b in pairs(self.buttons) do
			b:SetFlyoutDirection(direction)
		end
	end
end

function ActionBar:SavePosition()
	Dominos.Frame.SavePosition(self)
	self:UpdateFlyoutDirection()
end


--right click menu code for action bars
--TODO: Probably enable the showstate stuff for other bars, since every bar basically has showstate functionality for 'free'
do
	local L

	--state slider template
	local function ConditionSlider_OnShow(self)
		self:SetMinMaxValues(-1, Dominos:NumBars() - 1)
		self:SetValue(self:GetParent().owner:GetOffset(self.stateId) or -1)
		self:UpdateText(self:GetValue())
	end

	local function ConditionSlider_UpdateValue(self, value)
		self:GetParent().owner:SetOffset(self.stateId, (value > -1 and value) or nil)
	end

	local function ConditionSlider_UpdateText(self, value)
		if value > -1 then
			local page = (self:GetParent().owner.id + value - 1) % Dominos:NumBars() + 1
			self.valText:SetFormattedText(L.Bar, page)
		else
			self.valText:SetText(DISABLE)
		end
	end

	local function ConditionSlider_New(panel, stateId, text)
		local s = panel:NewSlider(stateId, 0, 1, 1)
		s.OnShow = ConditionSlider_OnShow
		s.UpdateValue = ConditionSlider_UpdateValue
		s.UpdateText = ConditionSlider_UpdateText
		s.stateId = stateId
		s:SetWidth(s:GetWidth() + 28)

		local title = _G[s:GetName() .. 'Text']
		title:ClearAllPoints()
		title:SetPoint('BOTTOMLEFT', s, 'TOPLEFT')
		title:SetJustifyH('LEFT')
		title:SetText(text or L['State_' .. stateId:upper()])

		local value = s.valText
		value:ClearAllPoints()
		value:SetPoint('BOTTOMRIGHT', s, 'TOPRIGHT')
		value:SetJustifyH('RIGHT')

		return s
	end

	local function AddLayout(self)
		local p = self:AddLayoutPanel()

		local size = p:NewSlider(L.Size, 1, 1, 1)
		size.OnShow = function(self)
			self:SetMinMaxValues(1, self:GetParent().owner:MaxLength())
			self:SetValue(self:GetParent().owner:NumButtons())
		end

		size.UpdateValue = function(self, value)
			self:GetParent().owner:SetNumButtons(value)
			_G[self:GetParent():GetName() .. L.Columns]:OnShow()
		end
	end

	local function AddAdvancedLayout(self)
		self:AddAdvancedPanel()
	end

	--GetSpellInfo(spellID) is awesome for localization
	local function addStatePanel(self, name, type)
		local states = Dominos.BarStates:map(function(s) return s.type == type end)
		if #states > 0 then
			local p = self:NewPanel(name)

			--HACK: Make the state panel wider for monks
			--		since their stances have long names
			local playerClass = select(2, UnitClass('player'))
			local hasLongStanceNames = playerClass == 'MONK' or playerClass == 'ROGUE' or playerClass == 'DRUID'
			for i = #states, 1, -1 do
				local state = states[i]
				local slider = ConditionSlider_New(p, state.id, state.text)
				if hasLongStanceNames then
					slider:SetWidth(slider:GetWidth() + 48)
				end
			end

			if hasLongStanceNames then
				p.width = 228
			end
		end
	end

	local function AddClass(self)
		addStatePanel(self, UnitClass('player'), 'class')
	end

	local function AddPaging(self)
		addStatePanel(self, L.QuickPaging, 'page')
	end

	local function AddModifier(self)
		addStatePanel(self, L.Modifiers, 'modifier')
	end

	local function AddTargeting(self)
		addStatePanel(self, L.Targeting, 'target')
	end

	local function AddShowState(self)
		local p = self:NewPanel(L.ShowStates)
		p.height = 56

		local editBox = CreateFrame('EditBox', p:GetName() .. 'StateText', p,  'InputBoxTemplate')
		editBox:SetWidth(148) editBox:SetHeight(20)
		editBox:SetPoint('TOPLEFT', 12, -10)
		editBox:SetAutoFocus(false)
		editBox:SetScript('OnShow', function(self)
			self:SetText(self:GetParent().owner:GetShowStates() or '')
		end)
		editBox:SetScript('OnEnterPressed', function(self)
			local text = self:GetText()
			self:GetParent().owner:SetShowStates(text ~= '' and text or nil)
		end)
		editBox:SetScript('OnEditFocusLost', function(self) self:HighlightText(0, 0) end)
		editBox:SetScript('OnEditFocusGained', function(self) self:HighlightText() end)

		local set = CreateFrame('Button', p:GetName() .. 'Set', p, 'UIPanelButtonTemplate')
		set:SetWidth(30) set:SetHeight(20)
		set:SetText(L.Set)
		set:SetScript('OnClick', function(self)
			local text = editBox:GetText()
			self:GetParent().owner:SetShowStates(text ~= '' and text or nil)
			editBox:SetText(self:GetParent().owner:GetShowStates() or '')
		end)
		set:SetPoint('BOTTOMRIGHT', -8, 2)

		return p
	end

	function ActionBar:CreateMenu()
		local menu = Dominos:NewMenu(self.id)

		L = LibStub('AceLocale-3.0'):GetLocale('Dominos-Config')
		AddLayout(menu)
		AddClass(menu)
		AddPaging(menu)
		AddModifier(menu)
		AddTargeting(menu)
		AddShowState(menu)
		AddAdvancedLayout(menu)

		ActionBar.menu = menu
	end
end


--[[ Action Bar Controller ]]--

local ActionBarController = Dominos:NewModule('ActionBars', 'AceEvent-3.0')

function ActionBarController:Load()
	self:RegisterEvent('UPDATE_BONUS_ACTIONBAR', 'UpdateOverrideBar')
	self:RegisterEvent('UPDATE_VEHICLE_ACTIONBAR', 'UpdateOverrideBar')
	self:RegisterEvent('UPDATE_OVERRIDE_ACTIONBAR', 'UpdateOverrideBar')

	for i = 1, Dominos:NumBars() do
		ActionBar:New(i)
	end
end

function ActionBarController:Unload()
	self:UnregisterAllEvents()

	for i = 1, Dominos:NumBars() do
		Dominos.Frame:ForFrame(i, 'Free')
	end	
end

function ActionBarController:UpdateOverrideBar()
	if InCombatLockdown() or (not Dominos.OverrideController:OverrideBarActive()) then
		return
	end

	local overrideBar = Dominos:GetOverrideBar()

	for _, button in pairs(overrideBar.buttons) do
		ActionButton_Update(button)
	end
end