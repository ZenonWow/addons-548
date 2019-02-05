--MacroClicks = MacroClicks or {}
local MacroClicks = { hooks = {} }


--[[
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


function MacroClicks.HookMacroUI()
	if  MacroClicks.hooks.MacroButton_OnClick  then  return  end
	
	hooksecurefunc('MacroButton_OnClick', function() print('original MacroButton_OnClick') end)

	MacroClicks.hooks.MacroButton_OnClick = _G.MacroButton_OnClick
	_G.MacroButton_OnClick = MacroClicks.MacroButton_OnClick

	hooksecurefunc('MacroButton_OnClick', function() print('hooked MacroButton_OnClick') end)
end
--]]




----[[
local function CallOriginalOnClick(self, unit, button, actionType)
	MacroButton_OnClick(self, button)
	--self.originalOnClick(self, button)
end

local PreClickUpdate = [===[
	local id = self:GetID()
	self:SetAttribute('macro2', id)
	self:SetAttribute('ctrl-macro*', id)
]===]


local function SetupButton(button, id)
	button:SetID(id)
	button:SetAttribute('type1', 'original')
	button:SetAttribute('_original', CallOriginalOnClick)
	button:SetAttribute('type2', 'macro')
	button:SetAttribute('macro2', id)
	button:SetAttribute('ctrl-type*', 'macro')
	button:SetAttribute('ctrl-macro*', id)
	button:WrapScript(button, "OnClick", PreClickUpdate)
end




function ReplaceMacroButton(origButton)
	--local origButton = _G[name]
	local name = origButton:GetName()
	local parent = origButton:GetParent()
	local id = origButton:GetID()
	_G[name] = nil
	
	--button = CreateFrame("CheckButton", "MacroButton"..id, self, "MacroButtonTemplate");
	local button = CreateFrame('CheckButton', name, parent, 'MacroButtonTemplate,SecureActionButtonTemplate,SecureHandlerClickTemplate')
	_G[name] = button
	SetupButton(button, id)
	--button.originalOnClick = origButton:GetScript('OnClick')
	
	local children = { origButton:GetChildren() }
	for  n, child  in ipairs(children) do  child:SetParent(button)  end
	
	return button
end

--[[
function MacroClicks.MacroButtonContainer_ReLoad(self)
	local buttons = {}
	local NUM_MACROS_PER_ROW = NUM_MACROS_PER_ROW
	local maxMacroButtons = max(MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS);
	for id=1, maxMacroButtons do
		local origButton = _G['MacroButton'..id]
		local button = ReplaceMacroButton(origButton)
		buttons[id] = button
		
		for  n = 1, origButton:GetNumPoints()  do  button:SetPoint(origButton:GetPoint(n))  end
		
		--origButton:SetName(nil)
		origButton:SetParent(nil)
		origButton:SetID(0)
		origButton:Hide()
		button:Show()
	
	end
	return buttons
end
--]]



--[[
function MacroClicks.MacroButtonContainer_ReLoad(self)
	local buttons = {}
	local NUM_MACROS_PER_ROW = NUM_MACROS_PER_ROW
	local maxMacroButtons = max(MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS);
	for id=1, maxMacroButtons do
		local origButton = _G['MacroButton'..id]
		local button = ReplaceMacroButton(origButton)
		buttons[id] = button
		
		if ( id == 1 ) then
			button:SetPoint("TOPLEFT", self, "TOPLEFT", 6, -6);
		elseif ( mod(id, NUM_MACROS_PER_ROW) == 1 ) then
			button:SetPoint("TOP", "MacroButton"..(id-NUM_MACROS_PER_ROW), "BOTTOM", 0, -10);
		else
			button:SetPoint("LEFT", "MacroButton"..(id-1), "RIGHT", 13, 0);
		end
		
		--origButton:SetName(nil)
		origButton:SetParent(nil)
		origButton:SetID(0)
		origButton:Hide()
		button:Show()
	
	end
	return buttons
end
--]]


--[[
function MacroClicks.InitMacroUI()
	if  MacroClicks.buttons  then  return  end
	MacroClicks.buttons = MacroClicks.MacroButtonContainer_ReLoad(MacroButtonContainer)
	ReplaceMacroButton(MacroFrameSelectedMacroButton)
	MacroFrameSelectedMacroButton:SetPoint("TOPLEFT", "MacroFrameSelectedMacroBackground", 14, -14)
	-- <Anchor point="TOPLEFT" relativeTo="MacroFrameSelectedMacroBackground" x="14" y="-14"/>
end
--]]





--[[
local OverlayPreClickUpdate = [===[
	local id = self:GetParent():GetID()
	self:SetID(id)
	self:SetAttribute('macro2', id)
	self:SetAttribute('ctrl-macro*', id)
]===]

local function ReplaceMacroButton(origButton)
	local name = origButton:GetName()
	--local parent = origButton:GetParent()
	local id = origButton:GetID()
	local button = CreateFrame('Button', name..'Run', origButton, 'SecureActionButtonTemplate,SecureHandlerClickTemplate')
	--button:SetAttribute('type1', 'original')
	--button:SetAttribute('_original', CallOriginalOnClick)
	button:SetAttribute('type1', 'click')
	button:SetAttribute('click1', name)
	button:SetAttribute('type2', 'macro')
	button:SetAttribute('macro2', id)
	button:SetAttribute('ctrl-type*', 'macro')
	button:SetAttribute('ctrl-macro*', id)
	button:SetAllPoints(origButton)
	--button:SetFrameRef('parent', origButton)
	button:WrapScript(button, "OnClick", OverlayPreClickUpdate)
	button:Show()
	return button
end

function MacroClicks.MacroButtonContainer_ReLoad(self)
	local buttons = {}
	local NUM_MACROS_PER_ROW = NUM_MACROS_PER_ROW
	local maxMacroButtons = max(MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS);
	for id=1, maxMacroButtons do
		local origButton = _G['MacroButton'..id]
		local button = ReplaceMacroButton(origButton)
		buttons[id] = button
	end
	return buttons
end



function MacroClicks.InitMacroUI()
	if  MacroClicks.buttons  then  return  end
	MacroClicks.buttons = MacroClicks.MacroButtonContainer_ReLoad(MacroButtonContainer)
	ReplaceMacroButton(MacroFrameSelectedMacroButton)
	--MacroFrameSelectedMacroButton:SetPoint("TOPLEFT", "MacroFrameSelectedMacroBackground", 14, -14)
	-- <Anchor point="TOPLEFT" relativeTo="MacroFrameSelectedMacroBackground" x="14" y="-14"/>
end

--]]




--[[
	<CheckButton name="MacroButtonTemplate" inherits="PopupButtonTemplate" virtual="true">
		<Scripts>
			<OnLoad>
				self:RegisterForDrag("LeftButton");
			</OnLoad>
			<OnClick>
				MacroButton_OnClick(self, button, down);
			</OnClick>
			<OnDragStart>
				PickupMacro(MacroFrame.macroBase + self:GetID());
			</OnDragStart>
		</Scripts>
	</CheckButton>
--]]


--[[
http://wowwiki.wikia.com/wiki/API_RunMacro
macroID 
Number - the position of the macro in the macro frame. Starting at the top left macro with 1, counting from left to right and top to bottom. The IDs of the first page (all characters) range from 1-36, the second page 37-54.
--]]


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



--[[
if  IsAddOnLoaded('Blizzard_MacroUI')  then
	MacroClicks.InitMacroUI()
else
	hooksecurefunc('MacroFrame_LoadUI', MacroClicks.InitMacroUI)
end
--]]


