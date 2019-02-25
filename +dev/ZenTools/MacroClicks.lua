local _G, MacroClicks = _G, assert(LibStub, "Include LibStub.lua before"):NewLibrary('MacroClicks', 1)
if not MacroClicks then  return  end

local CreateFrame

NUM_MACROS_PER_ROW, MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS

--[[
http://wowwiki.wikia.com/wiki/API_RunMacro
macroID - Number - the position of the macro in the macro frame. Starting at the top left macro with 1, counting from left to right and top to bottom. The IDs of the first page (all characters) range from 1-36, the second page 37-54.
--]]


-- Update macro id with potentially changed macroBase.
local UpdateMacroIDSnippet = [===[
	local id = self:GetID()
	local macroID =  id~=0  and  macroBase+id  or  selectedMacro
	-- if id~=0 then  selectedMacro = macroID  end
	self:SetAttribute('macro', id)
]===]

local SelectMacroSnippet = [===[
	local id = self:GetID()
	if id~=0 then  selectedMacro = macroBase+id  end
]===]

-- Capture click of MacroFrameTab1,MacroFrameTab2 (id=1,2) to save `macroBase` in handler's protected environment.
local SelectTabSnippet = [===[
	macroBase =  self:GetID()==2  and  MAX_ACCOUNT_MACROS  else  0  end
]===]


local function OverlayMacroButton(name, commonHandler)
	-- local name = origButton:GetName()
	local origButton = _G[name]
	local id = origButton:GetID()
	local button = CreateFrame('Button', name..'Run', origButton, 'SecureActionButtonTemplate')
	button:SetID(id)

	-- Pass on normal clicks to original macro button.
	button:SetAttribute('*type*', 'click')
	button:SetAttribute('clickbutton', origName)
	-- button:SetAttribute('macro', id)    -- Disabled to test whether UpdateMacroIDSnippet actually sets it.

	-- Catch RightButton clicks to run macro.
	button:SetAttribute('type2', 'macro')
	-- Catch Ctrl-*Button clicks to run macro.
	button:SetAttribute('ctrl-type*', 'macro')

	-- Get commonHandler to update the macroID based on the MacroFrame.macroBase:
	-- macroBase == 0 after MacroFrame_SetAccountMacros(), macroBase == MAX_ACCOUNT_MACROS (36) after MacroFrame_SetCharacterMacros()
	commonHandler:WrapScript(button, 'OnClick', UpdateMacroIDSnippet)
	commonHandler:WrapScript(origButton, 'OnClick', SelectMacroSnippet)
	-- button:SetFrameRef('parent', origButton)

	-- Position overlay above original.
	button:SetAllPoints(origButton)
	-- button:Show()
	return button
end


function MacroClicks.MacroButtonContainer_Upgrade(self, commonHandler)
	local buttons = {}
	local NUM_MACROS_PER_ROW = _G.NUM_MACROS_PER_ROW
	local maxMacroButtons = max(_G.MAX_ACCOUNT_MACROS, _G.MAX_CHARACTER_MACROS)
	for id=1, maxMacroButtons do
		local button = OverlayMacroButton('MacroButton'..id, commonHandler)
		buttons[id] = button
	end
	return buttons
end



function MacroClicks.InitMacroUI()
	if  MacroClicks.buttons  then  return  end
	local commonHandler = CreateFrame('Frame', nil, nil, 'SecureHandlerClickTemplate')
	MacroClicks.commonHandler = commonHandler
	-- commonHandler:Hide()
	commonHandler:Execute(" macroBase,selectedMacro,MAX_ACCOUNT_MACROS = ... ", 0,1,MAX_ACCOUNT_MACROS )
	commonHandler:WrapScript(MacroFrameTab1, 'OnClick', SelectTabSnippet)  -- id==1, macroBase=0
	commonHandler:WrapScript(MacroFrameTab2, 'OnClick', SelectTabSnippet)  -- id==2, macroBase=MAX_ACCOUNT_MACROS

	MacroClicks.buttons = MacroClicks.MacroButtonContainer_Upgrade(MacroButtonContainer, commonHandler)
	OverlayMacroButton('MacroFrameSelectedMacroButton', commonHandler)
	--MacroFrameSelectedMacroButton:SetPoint("TOPLEFT", "MacroFrameSelectedMacroBackground", 14, -14)
	-- <Anchor point="TOPLEFT" relativeTo="MacroFrameSelectedMacroBackground" x="14" y="-14"/>
end





if  IsAddOnLoaded('Blizzard_MacroUI')  then
	MacroClicks.InitMacroUI()
else
	hooksecurefunc('MacroFrame_LoadUI', MacroClicks.InitMacroUI)
end


--[[
AceEvent.Once.AddonLoaded.Blizzard_MacroUI = MacroClicks.InitMacroUI
AceEvent.Once.AddonLoaded.Blizzard_MacroUI = MacroClicks    -- Call MacroClicks:Blizzard_MacroUI(addonName)?  or  MacroClicks:AddonLoaded(addonName)
AceEvent.Once.AddonLoaded.Blizzard_MacroUI[MacroClicks] = function(MacroClicks, addonName) .. end
AceEvent.Once.AddonLoaded.Blizzard_MacroUI[MacroClicks] = 'InitMacroUI'

AceEvent.Once.AddonLoaded.Blizzard_MacroUI[MacroClicks.InitMacroUI] = nil    -- Unregister.
AceEvent.Once.AddonLoaded.Blizzard_MacroUI.Unregister(MacroClicks.InitMacroUI)    -- Unregister.
AceEvent.Unregister.Once.AddonLoaded.Blizzard_MacroUI(MacroClicks.InitMacroUI)    -- Unregister.
AceEvent.Once:Unregister('AddonLoaded', 'Blizzard_MacroUI', MacroClicks.InitMacroUI)    -- Unregister.

function  AceEvent.Once.AddonLoaded.Blizzard_MacroUI(addonName) .. end
function  AceEvent[MacroClicks].Once.AddonLoaded.Blizzard_MacroUI(MacroClicks, addonName) .. end
--]]

