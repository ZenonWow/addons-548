--[[
AdiBags - Adirelle's bag addon.
Copyright 2010-2012 Adirelle (adirelle@gmail.com)
All rights reserved.
--]]
local addonName, addon = ...
local L = addon.L




function addon:RegisterHooks()
	self:RawHook('ToggleAllBags', true)
	-- Called by keybinding OPENALLBAGS  and  clicks on bagbar if IsModifiedClick('OPENALLBAGS')
	self:RawHook('ToggleBag', true)
	-- Called by clicks on bagbar  and  keybindings TOGGLEBAG*, TOGGLEBACKPACK -> ToggleBackpack() -> ToggleBag(0) if opening it
	self:RawHook('OpenAllBags', true)
	-- Called by BankFrame_OnShow, MailFrame_OnEvent(MAIL_SHOW), MerchantFrame_OnShow -- only interacting windows
	self:RawHook('CloseAllBags', true)
	-- Called by BankFrame_OnHide, MailFrame_OnEvent(MAIL_CLOSED), MerchantFrame_OnHide -- interacting windows
	-- and  BarberShop_OnShow  and...  FramePositionDelegate:ShowUIPanel(frame, force)  if not GetUIPanelWindowInfo(frame, 'allowOtherPanels')
	self:RawHook('CloseSpecialWindows', true)
	
	--[[ Leave the original functionality in place. User can choose to bind keys to opening backpack with default ui.
	self:RawHook('ToggleBackpack', true)
	self:RawHook('OpenBackpack', true)
	self:RawHook('CloseBackpack', true)
	--]]
end




function addon:ToggleBag(id)
	-- Called by clicks on bagbar  and  key bindings TOGGLEBAG*, TOGGLEBACKPACK -> ToggleBackpack() -> ToggleBag(0) if opening it
	print('ToggleBag('..id..')')
	
	-- Only hook clicking backpack on bagbar. Alt-Click and TOGGLEBACKPACK keybind opens Blizzard backpack frame.
	-- User can choose to bind keys to opening individual bags with default ui.
	local toggleAdiBag =  id == 0  and  GetMouseButtonClicked()  and  not IsModifiedClick('OPENBUILTINBAGS')
	-- Toggle adibag if conditions are met
	local toggled = toggleAdiBag  and  addon.bags.backpack:IsEnabled()  and  addon.bags.backpack:Toggle()
	-- Do original function otherwise
	return  toggled  or  self.hooks.ToggleBag(id)
end



function addon:ToggleAllBags()
	-- Called by keybinding OPENALLBAGS  and  clicks on bagbar if IsModifiedClick("OPENALLBAGS")
	--print('ToggleAllBags()')
	
	-- Only want to handle keybinding OPENALLBAGS but _not_ clicks on bagbar if IsModifiedClick('OPENALLBAGS')
	local toggleAdiBag =  not GetMouseButtonClicked()
	-- Toggle adibag if conditions are met
	local toggled = toggleAdiBag  and  addon.bags.backpack:IsEnabled()  and  addon.bags.backpack:Toggle()
	-- Do original function otherwise
	return  toggled  or  self.hooks.ToggleAllBags(id)
end




function addon:OpenAllBags(requesterFrame)
	-- Called by BankFrame_OnShow, MailFrame_OnEvent(MAIL_SHOW), MerchantFrame_OnShow -- only interacting windows
	print('OpenAllBags('.. (requesterFrame and (requesterFrame:GetName() or '<unnamed>') or 'nil') ..')')
	
	local backpack = self.bags.backpack
	if  not backpack:IsEnabled()  then  return self.hooks.OpenAllBags(requesterFrame)  end
	
	if  requesterFrame  then
		local key = requesterFrame:GetName()  or  requesterFrame
		self.InteractingWindows[key] = requesterFrame
	end
	
	-- Notify backpack of the request. Will open if autoOpen is set.
	local toggled = self.bags.backpack:CheckAutoOpen(requesterFrame)
	self:SendMessage('AdiBags_InteractingWindowChanged', requesterFrame)
	return backpack:IsOpen()
end


function addon:CloseAllBags(requesterFrame)
	-- Called with requesterFrame ~= nil by BankFrame_OnHide, MailFrame_OnEvent(MAIL_CLOSED), MerchantFrame_OnHide
	-- and  BarberShop_OnShow  and...  FramePositionDelegate:ShowUIPanel(frame, force)  if not GetUIPanelWindowInfo(frame, 'allowOtherPanels')
	print('CloseAllBags('.. (requesterFrame and (requesterFrame:GetName() or '<unnamed>') or 'nil') ..')')
	
	local wasRequester
	if  requesterFrame  then
		local key = requesterFrame:GetName()  or  requesterFrame
		wasRequester = self.InteractingWindows[key]
		self.InteractingWindows[key] = nil
	end
	
	-- Without requesterFrame it is called by FramePositionDelegate:ShowUIPanel() showing main menu and other central frames.
	-- Don't want to close in this case, just dispatching event to Blizzard bags.
	if  not wasRequester  then  return self.hooks.OpenAllBags(requesterFrame)  end
	
	local toggled = self.bags.backpack:Close()
	self:SendMessage('AdiBags_InteractingWindowChanged', requesterFrame)
	return true
end




function addon:CloseSpecialWindows()
	print('CloseSpecialWindows()')
	-- Close all AdiBags  or  dispatch event to original handler
	--return  self:CloseAll()  or  self.hooks.CloseSpecialWindows()
	--[[
	return  self.bags.bank:Close()
		or  self.bags.backpack:Close()
		or  self.hooks.CloseSpecialWindows()
	--]]
	return  self.hooks.CloseSpecialWindows()
		or  self.bags.bank:Close()
		or  self.bags.backpack:Close()
end



