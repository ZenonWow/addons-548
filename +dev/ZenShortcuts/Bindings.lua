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


local ADDON_NAME, _ADDON = ...
local _G = _G
-- setfenv(1, setmetatable(_ADDON, {__index = _G}) )  -- Lookup variable references in global namespace if not found in local-private
local ZenShortcuts = _G.ZenShortcuts or {}
_G.ZenShortcuts = ZenShortcuts




local ClearTargetButton = CreateFrame('Button', 'ClearTargetButton', UIParent, 'SecureActionButtonTemplate')
ClearTargetButton:SetAttribute('type', 'macro')
ClearTargetButton:SetAttribute('macrotext', '/cleartarget')




function  ZenShortcuts.OpenCharacterEquipmentTab()
	-- idea from: Broker_Equipment addon
	if  not PaperDollFrame:IsVisible()  then  return  end

	if  not CharacterFrame.Expanded  then  CharacterFrame_Expand()  end
	--PaperDollSidebarTab3:Click()
	PaperDollFrame_SetSidebar(PaperDollSidebarTab3, 3)
end

hooksecurefunc('ToggleCharacter', ZenShortcuts.OpenCharacterEquipmentTab)



-- Open the game menu without deselecting the target or closing frames like the map.
local  silent= true
function  ToggleGameMenuOnly()
	if  GameMenuFrame:IsShown()  then
		if not silent then  PlaySound("igMainMenuQuit")  end
		print("HideUIPanel(GameMenuFrame)")
		HideUIPanel(GameMenuFrame)
	else
		if not silent then  PlaySound("igMainMenuOpen")  end
		print("ShowUIPanel(GameMenuFrame)")
		ShowUIPanel(GameMenuFrame)
	end
end


function  ToggleMacroFrame()
	--[[ Source:
	SlashCmdList.MACRO()    -- FrameXML/ChatFrame.lua
	ShowMacroFrame()    -- FrameXML/UIParent.lua
	--]]
	if  not MacroFrame  then  MacroFrame_LoadUI()  end
	ToggleFrame(MacroFrame)  -- Uses secure code if necessary.
end



local function printFrames(...)
	for i = 1, select("#", ...) do
		local region = select(i, ...)
		if region:GetObjectType() == "FontString" then
			local text = region:GetText()
			print(text)
		end
	end
end

function  CopyFrameStack()
	local f, name = GetMouseFocus()
	_G.MF = f
	print("MF = GetMouseFocus() ; see it with /dump MF")
	if  f and f.GetName  then
		name = f:GetName()
		print("GetMouseFocus():GetName() == '"..name.."'")
	end
	if  FrameStackTooltip and FrameStackTooltip:IsShown()  then
		printFrames(FrameStackTooltip:GetRegions())
	end
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
hooksecurefunc('Dismount', VehicleExit)


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
		VehicleExit()
	else
		local seatIdx
		for  i = 1, UnitVehicleSeatCount('player')  do
			if  CanEjectPassengerFromSeat(i)  then
				seatIdx = i
				break
			end
		end

		if  seatIdx  then
			local _, name, _, _, _ = UnitVehicleSeatInfo('player', seatIdx)
			print('Eject passenger '.. seatIdx ..': ' .. name)
			EjectPassengerFromSeat(seatIdx)
		else
			print('Nothing to delete/abandon/exit/eject.')
		end

	end
end


