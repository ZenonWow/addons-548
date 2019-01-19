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

function ActionButtonPreClick(self, button)
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

function ActionButtonChatLinkHandlerPre(self, unit, button, actionType)
	print('ActionButtonChatLinkHandlerPre('..(self:GetAttribute('bindingid') or self:GetName() or '<noIDorName>')..')')
end
function ActionButtonChatLinkHandlerHook(self, unit, button, actionType)
	print('ActionButtonChatLinkHandlerHook('..(self:GetAttribute('bindingid') or self:GetName() or '<noIDorName>')..')')
end
function ActionButtonChatLinkHandler(self, unit, button, actionType)
	print('ActionButtonChatLinkHandler('..(self:GetAttribute('bindingid') or self:GetName() or '<noIDorName>')..','..tostring(unit)..','..tostring(button)..')')
	ActionButton_SendLink(self)
end
ActionButtonChatLinkHandlerCode = [===[
	self:CallMethod('SendLink')
]===]

function PatchActionButton(b)
		b:SetAttribute("_chatlink", ActionButtonChatLinkHandler)
		-- b:SetAttribute("_chatlink", ActionButtonChatLinkHandlerCode)
		-- _= id == 4 and b:SetAttribute("shift-chatlink*", ActionButtonChatLinkHandlerCode)
		-- b:SetAttribute("_chatlink-action", ActionButtonChatLinkHandlerCode)
    
		b:SetScript("PreClick", ActionButtonChatLinkHandlerPre)
		-- b:HookScript("OnClick", ActionButtonChatLinkHandlerHook)

		b.SendLink = ActionButton_SendLink
		-- self.SendLink = ActionButton_SendLink
		SendLinkHandler:WrapScript(b, 'OnClick', ActionButton_PreOnClick, nil)
end



-----------------

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



-----------------





function GetActionButtonNameLinear(id)
	if id <= 12 then  return 'ActionButton' .. id
	elseif id <= 24 then  return 'MultiBarBottomLeftButton' .. (id-12)
	elseif id <= 36 then  return 'MultiBarBottomRightButton' .. (id-24)
	elseif id <= 48 then  return 'MultiBarLeftButton' .. (id-36)
	elseif id <= 60 then  return 'MultiBarRightButton' .. (id-48)
	--elseif id <= 72 then  return 'DominosActionButton' .. (id-60)
	else  return 'DominosActionButton' .. (id-60)
	end
end

function GetActionButtonNameOrig(id)
	-- 2->6 3->5 4->4 5->3 6->2
	if id <= 12 then  return 'ActionButton' .. id
	elseif id <= 24 then  return 'DominosActionButton' .. (id-12)
	elseif id <= 36 then  return 'MultiBarRightButton' .. (id-24)
	elseif id <= 48 then  return 'MultiBarLeftButton' .. (id-36)
	elseif id <= 60 then  return 'MultiBarBottomRightButton' .. (id-48)
	elseif id <= 72 then  return 'MultiBarBottomLeftButton' .. (id-60)
	else  return 'DominosActionButton' .. (id-60)
	end
end

local GetActionButtonName = GetActionButtonNameLinear

--[[
http://wowwiki.wikia.com/wiki/SecureHandlers
http://wowwiki.wikia.com/wiki/RestrictedEnvironment
SpellIsTargeting()
/run TestActionButtonIDs()
IsModifiedClick("CHATLINK")
--]]
function TestActionButtonIDs()
	for i = 1,120  do
		local n = GetActionButtonName(i)
		local id = _G[n]  and  (_G[n].action or '<noID>')  or  '<noButton>'
		print(i..'. '.. n ..' -> '.. id)
	end
end

--[[
	if id <= 12 then  b = _G['ActionButton' .. id]
	elseif id <= 24 then  return CreateFrame('CheckButton', 'DominosActionButton' .. (id-12), nil, 'ActionBarButtonTemplate')
	elseif id <= 36 then  return _G['MultiBarRightButton' .. (id-24)]
	elseif id <= 48 then  return _G['MultiBarLeftButton' .. (id-36)]
	elseif id <= 60 then  return _G['MultiBarBottomRightButton' .. (id-48)]
	elseif id <= 72 then  return _G['MultiBarBottomLeftButton' .. (id-60)]
	else  return CreateFrame('CheckButton', 'DominosActionButton' .. (id-60), nil, 'ActionBarButtonTemplate')
	end
--]]




--[[

local function ActionButtonChatLinkHandler(self, unit, button, actionType)
	local actionID = self:GetID()
	--local action = ActionButton_CalculateAction(self, button)
	local actionType, id, subType = GetActionInfo(self.action)
	
	local link
	if  actionType == 'spell'  then  link = GetSpellLink(id)
	elseif  actionType == 'item'  then  link = select(2, GetItemInfo(id))
	elseif  actionType == "companion" and subType == "MOUNT"  then  link = GetSpellLink(id)
	end

	if  link  then  print('ActionButtonChatLink: '.. link)  end
	if  link  then  HandleModifiedItemClick(link)  end
	if  link  then  ChatEdit_InsertLink(link)  end
end

self:SetAttribute("shift-type1", "chatlink")
self:SetAttribute("_chatlink", ActionButtonChatLinkHandler)



function ActionButton_OnLoad (self)
	self.flashing = 0;
	self.flashtime = 0;
	self:SetAttribute("showgrid", 0);
	self:SetAttribute("type", "action");
	self:SetAttribute("checkselfcast", true);
	self:SetAttribute("checkfocuscast", true);
	self:SetAttribute("useparent-unit", true);
	self:SetAttribute("useparent-actionpage", true);
	self:RegisterForDrag("LeftButton", "RightButton");
	self:RegisterForClicks("AnyUp");
	ActionBarButtonEventsFrame_RegisterFrame(self);
	ActionButton_UpdateAction(self);
	ActionButton_UpdateHotkeys(self, self.buttonType);
end



local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, 
isCraftingReagent = GetItemInfo(itemID or "itemString" or "itemName" or "itemLink") 



/run local actionType, id =GetActionInfo(ActionButton_CalculateAction(<button name>))
local _,l=GetItemInfo(id) if l then SendChatMessage("WTS "..l,"channel",nil,2) end

--]]


