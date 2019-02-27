-- Bindings locales
BINDING_HEADER_ZenShortcuts           = "Zen Shortcuts - usability keybindings"

-- "Open chatbox preserving the last entered text so you can continue writing your message even if you had to or some background event unexpectedly closed your chatbox"
-- BINDING_NAME_OPENCHAT_REMEMBER        = "Open Chat with last entered"
-- "Don't Clear Target and close every frame on screen, just open the GameMenu"
BINDING_NAME_TOGGLEGAMEMENUONLY       = "Toggle Game Menu ONLY"
-- "Open macro editor"
BINDING_NAME_TOGGLEMACROS             = "Toggle Macros Frame"
-- "Show/hide frame inspector"
BINDING_NAME_TOGGLEFRAMESTACK         = "Toggle Frame Inspector"
-- "Copy contents of frame inspector"
BINDING_NAME_COPYFRAMESTACK           = "Copy FrameStack"
-- "Show/hide event trace"
BINDING_NAME_TOGGLEEVENTTRACE         = "Toggle Event Trace"
-- "Show/hide loot history frame"
BINDING_NAME_TOGGLELOOTHISTORY        = "Toggle Loot History (rolls)"
-- "Go directly to Equipment Manager in Character Frame"
BINDING_NAME_TOGGLECHARACTEREQUIPMENT = "Toggle Equipment Manager"
-- "Almost the same as builtin Toggle Talents that actually opens Specializations: it does so even if last time you opened the Talents Tab"
BINDING_NAME_TOGGLESPECIALIZATION     = "Toggle Talent Specializations"
-- "Open the actual Talents Tab on the Talent Frame"
BINDING_NAME_TOGGLETALENTSTAB         = "Toggle Talents Tab"

-- See who's following: Look back while pushed, look forward when released.
BINDING_NAME_LookBackWhilePushed  = "Look back *while* pushed"
BINDING_NAME_LookLeft             = "Look left"
BINDING_NAME_LookRight            = "Look right"
-- Eject a passenger. One at a time.
BINDING_NAME_EjectPassenger       = "Eject a passenger"
-- "Delete item on cursor  or  eject passengers"
BINDING_NAME_DELETEOREJECT            = "Delete Cursor Item or Quest or Eject Passengers or Yourself"
-- "Unselect Target"
_G["BINDING_NAME_CLICK ClearTargetButton"] = "Clear Target (unselect)"


local _G, ADDON_NAME, _ADDON = _G, ...
-- setfenv(1, setmetatable(_ADDON, {__index = _G}) )  -- Lookup variable references in global namespace if not found in local-private
local UIShortcuts = _G.UIShortcuts or {}
_G.UIShortcuts = UIShortcuts




local ClearTargetButton = CreateFrame('Button', 'ClearTargetButton', UIParent, 'SecureActionButtonTemplate')
ClearTargetButton:SetAttribute('type', 'macro')
ClearTargetButton:SetAttribute('macrotext', '/cleartarget')




UIShortcuts.OpenCharacterEquipmentTab = UIShortcuts.OpenCharacterEquipmentTab  or  function()
	-- idea from: Broker_Equipment addon
	if  not PaperDollFrame:IsVisible()  then  return  end

	if  not CharacterFrame.Expanded  then  CharacterFrame_Expand()  end
	--PaperDollSidebarTab3:Click()
	PaperDollFrame_SetSidebar(PaperDollSidebarTab3, 3)
end

hooksecurefunc('ToggleCharacter', UIShortcuts.OpenCharacterEquipmentTab)



-- Open the game menu without deselecting the target or closing frames like the map.
local  loud = nil
UIShortcuts.ToggleGameMenuOnly = UIShortcuts.ToggleGameMenuOnly  or  function()
	if  GameMenuFrame:IsShown()  then
		if loud then  PlaySound("igMainMenuQuit")  end
		print("HideUIPanel(GameMenuFrame)")
		HideUIPanel(GameMenuFrame)
	else
		if loud then  PlaySound("igMainMenuOpen")  end
		print("ShowUIPanel(GameMenuFrame)")
		ShowUIPanel(GameMenuFrame)
	end
end


UIShortcuts.ToggleMacroFrame = UIShortcuts.ToggleMacroFrame  or  function()
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

UIShortcuts.CopyFrameStack = UIShortcuts.CopyFrameStack  or  function()
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



UIShortcuts.ToggleFrameStack = UIShortcuts.ToggleFrameStack  or  function()
	local showHidden = IsAltKeyDown()
	SlashCmdList.FRAMESTACK( showHidden and 'true' or '' )    -- FrameXML/ChatFrame.lua
	--[[
	if  not FrameStackTooltip  then  UIParentLoadAddOn("Blizzard_DebugTools")  end
	FrameStackTooltip_Toggle(showHidden)
	--]]
end


UIShortcuts.ToggleEventTrace = UIShortcuts.ToggleEventTrace  or  function()
	SlashCmdList.EVENTTRACE('')    -- FrameXML/ChatFrame.lua
	--[[
	if  not EventTraceFrame  then  UIParentLoadAddOn("Blizzard_DebugTools")  end
	EventTraceFrame_HandleSlashCmd('')
	--]]
end




UIShortcuts.EjectPassenger = UIShortcuts.EjectPassenger  or  function()
	local seatIdx
	for  i = 1, UnitVehicleSeatCount('player')  do
		if  CanEjectPassengerFromSeat(i)  then
			local _, name, _, _, _ = UnitVehicleSeatInfo('player', seatIdx)
			print('Eject passenger '.. seatIdx ..': ' .. name)
			EjectPassengerFromSeat(seatIdx)
			break
		end
	end

	if not seatIdx then  print('No passengers to eject.')  end
end


----[[
-- Shift-Ctrl-X, Shift-Ctrl-Del:  delete cursor item or eject passengers
-- /run if IsControlKeyDown() then if CursorHasItem() then DeleteCursorItem() else EjectPassengerFromSeat(1);EjectPassengerFromSeat(2) end end
--]]
UIShortcuts.DeleteItemOrEjectPassengers = UIShortcuts.DeleteItemOrEjectPassengers  or  function()
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




-- DISMOUNT action also leaves the vehicle in case you're sitting in one
-- Many or all vehicles are perceived by the user as mounts with extras,
-- therefore the user would expect to be able to Dismount them.
-- This hook does that in a securehook, to prevent any creeping tainting that might come up.
hooksecurefunc('Dismount', VehicleExit)



