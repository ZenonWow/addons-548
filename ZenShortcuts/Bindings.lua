-- Bindings locales
BINDING_HEADER_ZenShortcuts               = "ZenShortcuts - usability keybindings"

--BINDING_NAME_OPENCHAT_REMEMBER        = "Open Chat with last entered"
-- "Open chatbox preserving the last entered text so you can continue writing your message even if you had to or some background event unexpectedly closed your chatbox"
BINDING_NAME_TOGGLEGAMEMENUONLY       = "Toggle Game Menu ONLY"
-- "Don't Clear Target and close every frame on screen, just open the GameMenu"
BINDING_NAME_TOGGLEMACROS             = "Toggle Macros Frame"
-- "Open macro editor"
BINDING_NAME_TOGGLEFRAMESTACK         = "Toggle Frame Inspector"
-- "Show/hide frame inspector"
BINDING_NAME_TOGGLEEVENTTRACE         = "Toggle Event Trace"
-- "Show/hide event trace"
BINDING_NAME_TOGGLELOOTHISTORY        = "Toggle Loot History (rolls)"
-- "Show/hide loot history frame"
BINDING_NAME_TOGGLECHARACTEREQUIPMENT = "Toggle Equipment Manager"
-- "Go directly to Equipment Manager in Character Frame"
BINDING_NAME_TOGGLESPECIALIZATION     = "Toggle Talent Specializations"
-- "Almost the same as builtin Toggle Talents that actually opens Specializations: it does so even if last time you opened the Talents Tab"
BINDING_NAME_TOGGLETALENTSTAB         = "Toggle Talents Tab"
-- "Open the actual Talents Tab on the Talent Frame"
BINDING_NAME_LOOKBACKWHILEPUSHED      = "Look back while pushed"
-- "See who's following: Look back when pushed, look forward when released"
BINDING_NAME_DELETEOREJECT            = "Delete Cursor Item or Quest or Eject Passengers or Yourself"
-- "Delete item on cursor  or  eject passengers"
_G["BINDING_NAME_CLICK ClearTargetButton:LeftButton"] = "Clear Target (unselect)"
-- "Unselect Target"


local ADDON_NAME, AddonPrivate = ...
local ZenShortcuts = _G[ADDON_NAME] or {}
--local _G = getfenv(0)
_G[ADDON_NAME] = ZenShortcuts
--setmetatable(AddonPrivate, {__index = _G})  -- Lookup variable references in global namespace if not found in local-private
--setfenv(1, AddonPrivate)

local function print(...)  DEFAULT_CHAT_FRAME:AddMessage(...)  end




local ClearTargetButton = CreateFrame('Button', 'ClearTargetButton', UIParent, 'SecureActionButtonTemplate')
ClearTargetButton:SetAttribute('type', 'macro')
ClearTargetButton:SetAttribute('macrotext', '/cleartarget')



--[[
local  ToggleTalentFrame = _G.ToggleTalentFrame	-- infinite recursion safeguard
ToggleTalentFrameOrig    = ToggleTalentFrame

-- Override ToggleTalentFrame(nil)  to open TALENTS_TAB, not SPECIALIZATION_TAB
function  ToggleTalentTab(tab)
	--print('ToggleTalentTab(' .. (tab or 'nil') .. ')')
	if  tab == nil  then  tab= TALENTS_TAB  end
	ToggleTalentFrameOrig(tab)
end

_G.ToggleTalentFrame= ToggleTalentTab
--]]




local function  OpenCharacterEquipmentTab()
	-- copied from: Broker_Equipment addon
	if  not PaperDollFrame:IsVisible()
	then  return  end

	if  not CharacterFrame.Expanded  then
		SetCVar('characterFrameCollapsed', '0')
		CharacterFrame_Expand()
	end

	--PaperDollSidebarTab2:Click()
	if  not _G[PAPERDOLL_SIDEBARS[3].frame]:IsShown()  then
		PaperDollFrame_SetSidebar(nil, 3)
	end
end

--[[
-- Toggle the character frame and open the equipment manager.
function  ToggleCharacterEquipment()
		ToggleCharacter('PaperDollFrame')
		OpenCharacterEquipmentTab()
end
--]]


function  ZenShortcuts.ToggleCharacter(tab)
	if  tab == 'PaperDollFrame'
	then  OpenCharacterEquipmentTab()  end
end
hooksecurefunc('ToggleCharacter', ZenShortcuts.ToggleCharacter)



-- Open the game menu without deselecting the target or closing frames like the map.
local  silent= true
function  ToggleGameMenuOnly()
	if ( GameMenuFrame:IsShown() ) then
		if not silent then  PlaySound("igMainMenuQuit")  end
		HideUIPanel(GameMenuFrame);
	else
		if not silent then  PlaySound("igMainMenuOpen")  end
		ShowUIPanel(GameMenuFrame);
	end
end


function  ToggleMacroFrame()
	--[[ Source:
	SlashCmdList.MACRO()    -- FrameXML/ChatFrame.lua
	ShowMacroFrame()    -- FrameXML/UIParent.lua
	--]]
	if  not MacroFrame  then  MacroFrame_LoadUI()  end
	ToggleFrame(MacroFrame)  -- Uses secure code if necessary.
	--[[
	if  not MacroFrame:IsShown()  then  ShowUIPanel(MacroFrame)
	else  HideUIPanel(MacroFrame)  end
	--]]
	--[[
	if  not MacroFrame  or  not MacroFrame:IsShown()  then  ShowMacroFrame()
	else  HideUIPanel(MacroFrame)  end
	--]]
end


function  ToggleFrameStack()
	local showHidden = IsAltKeyDown()
	SlashCmdList.FRAMESTACK( showHidden and 'true' or '' )    -- FrameXML/ChatFrame.lua
	--[[
	if  not FrameStackTooltip  then  UIParentLoadAddOn("Blizzard_DebugTools")  end
	FrameStackTooltip_Toggle(showHidden)
	--]]
end


function  ToggleEventTrace()
	SlashCmdList.EVENTTRACE('')    -- FrameXML/ChatFrame.lua
	--[[
	if  not EventTraceFrame  then  UIParentLoadAddOn("Blizzard_DebugTools")  end
	EventTraceFrame_HandleSlashCmd('')
	--]]
end




-- DISMOUNT action also leaves the vehicle in case you're sitting in one
-- Many or all vehicles are perceived by the user as mounts with extras,
-- therefore the user would expect to be able to Dismount them.
-- This hook does that in a securehook, to prevent any creeping tainting that might come up.
function  ZenShortcuts.Dismount()
	--print( 'ZenShortcuts.Dismount():  IsMounted()= ' .. tostring(IsMounted()) .. '  UnitInVehicle()= ' .. tostring(UnitInVehicle('player')) )
	--VehicleExit()
	securecall('VehicleExit')
end
hooksecurefunc('Dismount', ZenShortcuts.Dismount)



----[[
-- Shift-Ctrl-X, Shift-Ctrl-Del:  delete cursor item or eject passengers
-- /run if IsControlKeyDown() then if CursorHasItem() then DeleteCursorItem() else EjectPassengerFromSeat(1);EjectPassengerFromSeat(2) end end
--]]
function  ZenShortcuts.DeleteItemOrEjectPassengers()
	if  CursorHasItem()  then
		local infoType, itemId, itemLink= GetCursorInfo()
		print('Delete ' .. tostring(infoType) .. '=' .. tostring(itemId) .. ' ' .. tostring(itemLink) )
		DeleteCursorItem()
	elseif  QuestLogDetailFrame:IsVisible()  then
		QuestLogFrameAbandonButton:Click()
		if  StaticPopup1:IsVisible()  then  StaticPopup1Button1:Click()  end
	elseif  CanExitVehicle()  then
		print('Exit Vehicle')
		securecall('VehicleExit')
	else
		local _, name1, _, _, _ = UnitVehicleSeatInfo('player', 1)
		local _, name2, _, _, _ = UnitVehicleSeatInfo('player', 2)
		local name, num

		--if  name1  and  name2  then  name1= name1 .. ',' .. name2
		if  name1  then  name,num = name1,1
		elseif  name2  then  name,num = name2,2
		end

		if  name  then
			print('Eject passenger '.. num ..': ' .. name)
			EjectPassengerFromSeat(num)
			--EjectPassengerFromSeat(2)
		else
			print('Nothing to delete/abandon/exit/eject.')
		end

	end
end


