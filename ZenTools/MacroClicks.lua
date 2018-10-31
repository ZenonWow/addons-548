--MacroClicks = MacroClicks or {}
local MacroClicks = { hooks = {} }


function MacroClicks.MacroButton_OnClick(...)
	local self, button = ...
	print( 'MacroClicks.MacroButton_OnClick('..self:GetID()..')' )
	if  button == "RightButton"  or  IsModifiedClick('RUN_MACRO')  then    --  or  IsModifiedClick('USE_ITEM')
	--if  IsModifiedClick('RUN_MACRO_B2')  or  IsModifiedClick('RUN_MACRO')  then    --  or  IsModifiedClick('USE_ITEM') -> CTRL-BUTTON2 is handled by RightButton
		MacroFrame_SelectMacro(MacroFrame.macroBase + self:GetID());
		RunMacro(MacroFrame.macroBase + self:GetID(), button)
	else
		MacroClicks.hooks.MacroButton_OnClick(...)
	end
end


MacroClicks.hooks.MacroButton_OnClick = _G.MacroButton_OnClick
_G.MacroButton_OnClick = MacroClicks.MacroButton_OnClick


--[[
/run SetModifiedClick('RUN_MACRO_B2','CTRL-BUTTON2')

function MacroClicks:RawHook(hookedFuncName)
	-- Already registered?
	self.hooks = self.hooks or {}
	if  self.hooks[hookedFuncName]  then
		--DEFAULT_CHAT_FRAME:AddMessage('MacroClicks:RawHook(): '.. hookedFuncName ..' was already registered.')
	elseif  not self[hookedFuncName]  then
		DEFAULT_CHAT_FRAME:AddMessage('MacroClicks:RawHook(): MacroClicks.'.. hookedFuncName ..'() does not exist.')
	else
		self.hooks[hookedFuncName] = _G[hookedFuncName]
		_G[hookedFuncName] = self[hookedFuncName]
	end
end


MacroClicks:RawHook('MacroButton_OnClick')
--]]

