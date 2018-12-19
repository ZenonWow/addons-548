--[[ 
	Action Button.lua
		A dominos action button
--]]

local HiddenActionButtonFrame = CreateFrame('Frame');  HiddenActionButtonFrame:Hide() 

local KeyBound = LibStub('LibKeyBound-1.0')

local ActionButton = Dominos:CreateClass('CheckButton', Dominos.BindableButton)
Dominos.ActionButton = ActionButton
ActionButton.unused = {}
ActionButton.active = {}



------------------------
--[[
/run reportActionButtons()
https://wow.gamepedia.com/Action_slot
--]]

function reportActionButtons()
        local lActionSlot = 0;
        for lActionSlot = 1, 120 do
                local lActionText = GetActionText(lActionSlot);
                local lActionTexture = GetActionTexture(lActionSlot);
                if lActionTexture then
                        local lMessage = "Slot " .. lActionSlot .. ": [" .. lActionTexture .. "]";
                        if lActionText then
                                lMessage = lMessage .. " \"" .. lActionText .. "\"";
                        end
                        DEFAULT_CHAT_FRAME:AddMessage(lMessage);
                end
        end
end


------------------------

local function ActionButtonPreClick(self, button)
	print('ActionButtonPreClick(): '.. tostring(link) )
	local actionType, id, subType = GetActionInfo(self.action)

	local link
	if  actionType == 'spell'  then  link = GetSpellLink(id)
	elseif  actionType == 'item'  then  link = select(2, GetItemInfo(id))
	elseif  actionType == "companion" and subType == "MOUNT"  then  link = GetSpellLink(id)
	else  print('ActionButtonChatLink: type='..tostring(actionType)..' id='..tostring(id)..' subType='..tostring(subType) )
	end

	if  link  then  print('ActionButtonChatLink: '.. link)  end
end

local function ActionButtonChatLinkHandlerPre(self, unit, button, actionType)
	print('ActionButtonChatLinkHandlerPre('..(self:GetID() or self:GetName() or '<noIDorName>')..')')
end
local function ActionButtonChatLinkHandlerHook(self, unit, button, actionType)
	print('ActionButtonChatLinkHandlerHook('..(self:GetID() or self:GetName() or '<noIDorName>')..')')
end
local function ActionButtonChatLinkHandler(self, unit, button, actionType)
	self:CallMethod('SendLink')
end
ActionButtonChatLinkHandlerCode = [===[
	self:CallMethod('SendLink')
]===]

function ActionButton_SendLink(self)
	local actionID = self:GetID()
	print('ActionButton_SendLink(actionID='.. tostring(actionID) ..')')
	--local action = ActionButton_CalculateAction(self, button)
	local actionType, id, subType = GetActionInfo(self.action)

	local link
	if  actionType == 'spell'  then  link = GetSpellLink(id)
	elseif  actionType == 'item'  then  link = select(2, GetItemInfo(id))
	elseif  actionType == 'companion' and subType == 'MOUNT'  then  link = GetSpellLink(id)
	end

	if  link  then  print('ActionButton_SendLink(): '.. link)
	else  print('ActionButton_SendLink(): type='..tostring(actionType)..' id='..tostring(id)..' subType='..tostring(subType) )
  end
	
	if  link  then  HandleModifiedItemClick(link)  end
	--if  link  then  ChatEdit_InsertLink(link)  end
end

local SendLinkHandler = CreateFrame('Frame', nil, nil, 'SecureHandlerClickTemplate')

-- Secure wrapper  function  ActionButton_PreOnClick(self, button, down)
local ActionButton_PreOnClick = [===[
	print("ActionButton_PreOnClick(".. self:GetName() ..",".. button ..",".. tostring(down) ..")")
	if  button == 'LeftButton'  and  IsModifiedClick('CHATLINK')  then
		if  not down  then
			self:CallMethod('SendLink')
			return false
		end
	end
]===]



-----------------



--constructor
function ActionButton:New(id)
	local b = self:Restore(id) or self:Create(id)

	if b then
		b:SetAttribute('showgrid', 0)
		b:SetAttribute('action--base', id)
		b:SetAttribute('_childupdate-action', [[
			local state = message
			local overridePage = self:GetParent():GetAttribute('state-overridepage')
			local newActionID
			
			if state == 'override' then
				newActionID = self:GetAttribute('button--index') + (overridePage - 1) * 12
			else
				newActionID = state and self:GetAttribute('action--' .. state) or self:GetAttribute('action--base')
			end
			
			if newActionID ~= self:GetAttribute('action') then
				self:SetAttribute('action', newActionID)
				self:CallMethod('UpdateState')
			end
		]])

		--print('ActionButton:New('..id..'): name='..tostring(b:GetName()) )
		--[[
		self:SetAttribute("shift-type*", "chatlink")
		self:SetAttribute("_chatlink", ActionButtonChatLinkHandlerCode)
		self:SetAttribute("_chatlink-action", ActionButtonChatLinkHandlerCode)
		self:SetAttribute("shift-_chatlink*", ActionButtonChatLinkHandlerCode)
		self:SetAttribute("shift-chatlink*", ActionButtonChatLinkHandlerCode)

		self:SetScript("PreClick", ActionButtonChatLinkHandlerPre)
		self:HookScript("OnClick", ActionButtonChatLinkHandlerHook)
		--]]

		self.SendLink = ActionButton_SendLink
		SendLinkHandler:WrapScript(self, 'OnClick', ActionButton_PreOnClick, nil)


		Dominos.BindingsController:Register(b, b:GetName():match('DominosActionButton%d'))

		--hack #1billion, get rid of range indicator text
		local hotkey = _G[b:GetName() .. 'HotKey']
		if hotkey:GetText() == _G['RANGE_INDICATOR'] then
			hotkey:SetText('')
		end		

		b:UpdateGrid()
		b:UpdateMacro()

		self.active[id] = b
	end

	return b	
end

local function Create(id)
	if id <= 12 then
		local b = _G['ActionButton' .. id]
		b.buttonType = 'ACTIONBUTTON'
		return b
	elseif id <= 24 then
		return CreateFrame('CheckButton', 'DominosActionButton' .. (id-12), nil, 'ActionBarButtonTemplate')
	elseif id <= 36 then
		return _G['MultiBarRightButton' .. (id-24)]
	elseif id <= 48 then
		return _G['MultiBarLeftButton' .. (id-36)]
	elseif id <= 60 then
		return _G['MultiBarBottomRightButton' .. (id-48)]
	elseif id <= 72 then
		return _G['MultiBarBottomLeftButton' .. (id-60)]
	end
	return CreateFrame('CheckButton', 'DominosActionButton' .. (id-60), nil, 'ActionBarButtonTemplate')
end

function ActionButton:Create(id)
	local b = Create(id)
	if b then
		self:Bind(b)

		--this is used to preserve the button's old id
		--we cannot simply keep a button's id at > 0 or blizzard code will take control of paging
		--but we need the button's id for the old bindings system
		b:SetAttribute('bindingid', b:GetID())
		b:SetID(0)

		b:ClearAllPoints()
		b:SetAttribute('useparent-actionpage', nil)
		b:SetAttribute('useparent-unit', true)
		b:EnableMouseWheel(true)
		b:SetScript('OnEnter', self.OnEnter)
		b:Skin()
	end
	return b
end

function ActionButton:Restore(id)
	local b = self.unused[id]
	if b then
		self.unused[id] = nil
		b:LoadEvents()
		ActionButton_UpdateAction(b)
		b:Show()
		self.active[id] = b
		return b
	end
end

--destructor
function ActionButton:Free()
	local id = self:GetAttribute('action--base')

	self.active[id] = nil
	
	ActionBarActionEventsFrame_UnregisterFrame(self)
	Dominos.BindingsController:Unregister(self)
	
	self:SetParent(HiddenActionButtonFrame)
	self:Hide()
	self.action = nil

	self.unused[id] = self
end

--these are all events that are registered OnLoad for action buttons
function ActionButton:LoadEvents()
	ActionBarActionEventsFrame_RegisterFrame(self)
end

--keybound support
function ActionButton:OnEnter()
	if Dominos:ShouldShowTooltips() then
		ActionButton_SetTooltip(self)
		ActionBarButtonEventsFrame.tooltipOwner = self
		ActionBarActionEventsFrame.tooltipOwner = self
		ActionButton_UpdateFlyout(self)
	end
	KeyBound:Set(self)
end

--override the old update hotkeys function
hooksecurefunc('ActionButton_UpdateHotkeys', ActionButton.UpdateHotkey)

--button visibility
function ActionButton:UpdateGrid()
	if InCombatLockdown() then return end
	
	if self:GetAttribute('showgrid') > 0 then
		ActionButton_ShowGrid(self)
	else
		ActionButton_HideGrid(self)
	end
end

--macro text
function ActionButton:UpdateMacro()
	if Dominos:ShowMacroText() then
		_G[self:GetName() .. 'Name']:Show()
	else
		_G[self:GetName() .. 'Name']:Hide()
	end
end

function ActionButton:SetFlyoutDirection(direction)
	if InCombatLockdown() then return end
	
	self:SetAttribute('flyoutDirection', direction)
	ActionButton_UpdateFlyout(self)
end

function ActionButton:UpdateState()
	ActionButton_UpdateState(self)
end

--utility function, resyncs the button's current action, modified by state
function ActionButton:LoadAction()
	local state = self:GetParent():GetAttribute('state-page')
	local id = state and self:GetAttribute('action--' .. state) or self:GetAttribute('action--base')
	
	self:SetAttribute('action', id)
end

function ActionButton:Skin()
	if not Dominos:Masque('Action Bar', self) then
		_G[self:GetName() .. 'Icon']:SetTexCoord(0.06, 0.94, 0.06, 0.94)
		self:GetNormalTexture():SetVertexColor(1, 1, 1, 0.5)
		
		if _G[self:GetName() .. 'FloatingBG'] then
			_G[self:GetName() .. 'FloatingBG']:Hide()
		end
	end
end