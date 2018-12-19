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


