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



local ActionBarChatLink = CreateFrame('Frame', nil, nil, 'SecureHandlerClickTemplate')

function ActionBarChatLink:SendChatLink(actionButton)
	-- local bindingid = actionButton:GetAttribute('bindingid')
	local action = actionButton:GetAttribute('action')
	local actionType, id, subType = _G.GetActionInfo(action)

	local link
	if  actionType == 'spell'  then  link = _G.GetSpellLink(id)
	elseif  actionType == 'item'  then  link = _G.select(2, _G.GetItemInfo(id))
	elseif  actionType == 'companion' and subType == 'MOUNT'  then  link = _G.GetSpellLink(id)
	end

	local tostring,math = _G.tostring, _G.math
	local msg = link or "type="..tostring(actionType).." id="..tostring(id).." subType="..tostring(subType)
	_G.print("ActionBarChatLink:SendChatLink(action="..math.floor(action/12+1).."."..tostring(action) .."): ".. msg)
	
	-- LootHistoryItemTemplate calls HandleModifiedItemClick() if IsModifiedClick("CHATLINK"), not ChatEdit_InsertLink()
	-- ChatEdit_InsertLink() called directly:  SetItemRef() (clicking a link),
	-- QuestSpellTemplate, QuestInfoRewardSpellTemplate, QuestLogTitleButton_OnClick, RaidInfoInstance_OnClick, SpellButton_OnModifiedClick,
	-- CoreAbilitySpellTemplate, SpellFlyoutButton_OnClick, WatchFrameLinkButtonTemplate_OnClick, ScorePlayer_OnClick
	if link then  _G.HandleModifiedItemClick(link)  end
	-- if link then  ChatEdit_InsertLink(link)  end
end


ActionBarChatLink.PreClickSnippet = [===[
	if not IsModifiedClick('CHATLINK') then  return  end
	local chatBox = owner:GetFrameRef('ActiveChatBox')
	if chatBox and chatBox:IsShown() then
		owner:CallMethod('SendChatLink', self)
		return true    -- Disable normal button action.
	end
]===]


-- _G.ACTIVE_CHAT_EDIT_BOX == _G.ChatEdit_GetActiveWindow()
function ActionBarChatLink.UpdateActiveChatBox(chatBox)
	-- In combat it won't track changing the active chat box, the handler will think it's hidden, and do the original action.
	-- if GetCVar("chatStyle") == "classic" then active chat box never changes.
	-- if InCombatLockdown() then  AceEvent.Once.PLAYER_REGEN_ENABLED = ActionBarChatLink.UpdateActiveChatBox  end
	if InCombatLockdown() then  return  end
	
	local chatBox = _G.ChatEdit_GetActiveWindow() or _G.DEFAULT_CHAT_FRAME.editBox
	if ActionBarChatLink.ActiveChatBox ~= chatBox then
		ActionBarChatLink.ActiveChatBox = chatBox
		ActionBarChatLink:SetFrameRef('ActiveChatBox', chatBox)
	end
end)
hooksecurefunc('ChatEdit_ActivateChat', ActionBarChatLink.UpdateActiveChatBox)



--constructor
function ActionButton:New(id)
	local b = self:Restore(id) or self:Create(id)

	if b then
		-- ActionBarChatLink:WrapScript(WorldFrame, 'OnClick', ActionBarChatLink.PreClickSnippet, nil)
		-- Handle Shift-LeftClick as chatlink.
		-- local key = GetModifiedClick('CHATLINK'):gsub('BUTTON','type'):lower()
		b:SetAttribute("shift-type1", "chatlink")    -- Hardwired for the default GetModifiedClick('CHATLINK') == "SHIFT-BUTTON1"
		b:SetAttribute("_chatlink", function(self)  ActionBarChatLink:SendChatLink(self)  end)
		

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



-- Global
function GetActionButtonNameLinear(id)
	if id <= 12 then  return 'ActionButton' .. id
	elseif id <= 24 then  return 'MultiBarBottomLeftButton' .. (id-12)
	elseif id <= 36 then  return 'MultiBarBottomRightButton' .. (id-24)
	elseif id <= 48 then  return 'MultiBarLeftButton' .. (id-36)
	elseif id <= 60 then  return 'MultiBarRightButton' .. (id-48)
	--elseif id <= 72 then  return 'DominosActionButton' .. (id-60)
	else  return 'DominosActionButton' .. (id-60)
	-- else  return 'DominosActionButton' .. id
	end
end

local function Create(id)
	local name = GetActionButtonNameLinear(id)
	if id <= 60 then
		local b = _G[name]
		if id <= 12 then  b.buttonType = 'ACTIONBUTTON'  end
		return b
	end
	return CreateFrame('CheckButton', name, nil, 'ActionBarButtonTemplate')
end

--[[ original Create() that exchanges bars 2<->6, 3<->5 : DominosActionButton[1]<->MultiBarBottomLeftButton, MultiBarRightButton<->MultiBarBottomRightButton
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
--]]

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