--[[ Dump code here and enter in chat   /rl  ]]--

--[[ TODO:
- TipTop skin MogIt tooltips
- LiteMount About config gyökérbe került
- AddonLoader config ures
- Elephant memory optim	
- TomTom opt ures. XLoot delay load mukodik. Bazooka is?
- delay: Auct, Handy, Examiner, TomTom, iCPU, Ellipsis, IQ, LiteMount, Mapster, MogIt, Routes, ShowItemLevel, SilverDragon, Skada, XLoot, 
- ?  FasterCamera, idTip, TipTop, ZenTools,
- why? AdvancIvcon, AuctionUI

/dump debug.getinfo(1)
/dump debug.getinfo(2)
/dump GetMouseFocus():GetID()

/run a=LibStub('LibDataBroker-1.1'):GetDataObjectByName('FasterCamera') ; print(a.label, a.text, a.value, a.type)
/run a=LibStub('LibDataBroker-1.1'):GetDataObjectByName('BagSync') ; print(a.label, a.text, a.value, a.type)
/dump a.label, a.text
--]]


--		BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
hooksecurefunc('BattlePetToolTip_Show', function(...)
	print( "BattlePetToolTip_Show("..strjoin(", ", tostringall(...)..")") )
end)


--[[ TODO: 
find BattlePetTooltip:SetScript
/run _G.ChatFrame_OpenChat("/cast Inner Fire")  ;  _G.ChatEdit_SendText(editbox, 1)
/dump debuglocals()
/dump GetPlayerInfoByGUID('0x010B0000002ADF67')  -- Tessa
/run FriendsFrame_ShowDropdown('Dallaryen', 1, 1, 'WHISPER', ChatFrame1)   -- taints?
HandleModifiedItemClick táskából vendornak??
-+ AceDB: purge profileKeys
-- AuctionMaster: delayed fix
-- X-LoadOn-Frames
-- AutoBar scale: a nagyobbik dimenzio hasson csak
-- TODO: securemousewheelhandler
-- TODO: color fill, yield
-- LibRelativeFrames
## X-LoadOn-Events: UNIT_SPELLCAST_SENT, UNIT_SPELLCAST_START
## X-LoadOn-UNIT_SPELLCAST_SENT: LoadAddOn('Quartz')
## X-LoadOn-UNIT_SPELLCAST_START: LoadAddOn('Quartz')
--]]

--[[ TODO: 
if  self.tmogLink  and  self.tmogLink ~= link  then  SetTmogToLink(self.tmogLink)
elseif  self.itemLink  and  self.itemLink ~= link  then  SetTmogFromLink(self.tmogLink)
end
check SV/Bazooka, dom_buff
SV/MountQ - profiles
CLASS profileKeys clean
--]]

--[[
/run DisableAddOn('Dominos')
/run EnableAddOn('Dominos')
/dump SetModifiedClick('ATTACHSIMILAR','ALT')
/dump IsAddOnLoaded('TradeSkillMaster_Mailing')
/run LoadAddOn('TradeSkillMaster_Mailing')
/run LoadAddOn('TradeSkillMaster_Auctioning')
/run LoadAddOn('TradeSkillMaster_Shopping')
/run LoadAddOn('GnomishVendorShrinker')
/run LoadAddOn('Examiner')
/run LoadAddOn('ViragDevTool')
/run LoadAddOn('BankStack')
/run LoadAddOn('LuaBrowser')
/run LoadAddOn('MogIt')
/run LoadAddOn('Postal')  LoadAddOn('InboxMailBag')

/run EventTracker.PrintLog()
/run reportActionButtons()
--]]




--[[
/dump GetCVar('autoLootDefault')
/run SetAutoLootDefault(0)

/run SetModifiedClick('CHATLINK','ALT-BUTTON1')
/run LibStub("AceConfigDialog-3.0"):SetDefaultSize("FasterCamera", 420, 510)

/run MainMenuBarBackpackButton:Disable()
/run MainMenuBarBackpackButton:Hide()
/run MainMenuBarBackpackButton:SetScript('OnEvent',nil)
--]]
--[[ This definitely disabled the button.
MainMenuBarBackpackButton:SetScript('OnLoad',nil)
MainMenuBarBackpackButton:SetScript('OnClick',nil)
MainMenuBarBackpackButton:SetScript('OnReceiveDrag',nil)
MainMenuBarBackpackButton:SetScript('OnEnter',nil)
MainMenuBarBackpackButton:SetScript('OnLeave',nil)
MainMenuBarBackpackButton:SetScript('OnEvent',nil)

/dump tkeys(LibStub.short)
--]]


function tkeys(t)	local ks = {}	for k in next,t do ks[#ks+1] = k end	return ks end

function tkeys(t)
	local ks = {}
	for k in pairs(t) do ks[#ks+1] = k end
	return ks
 end

function tvalues(t)
	local ks = {}
	for k,v in pairs(t) do ks[#ks+1] = v end
	return ks
end




-- Secure wrapper  function  WorldMapFrame_PreClick(self, button, down)
local preBody = [===[
if  button == 'LeftButton'  then
	if  down  then
		self:SetBinding(true, 'BUTTON2', 'AUTORUN')
	else
		self:ClearBinding('BUTTON2')
	end
end
]===]
local postBody = nil

--WorldMapFrame:WrapScript(frame, 'OnClick', preBody, postBody)
--SecureHandlerWrapScript(WorldMapFrame, 'OnClick', preBody, postBody)





--[[
Auctionator -> creeping taints  CompactRaidFrame2:Show()
4x [ADDON_ACTION_BLOCKED] AddOn 'Auctionator' tried to call the protected function 'CompactRaidFrame2:Show()'.
!BugGrabber\BugGrabber.lua:586: in function <!BugGrabber\BugGrabber.lua:586>
[C]: in function `Show'
FrameXML\CompactUnitFrame.lua:285: in function `CompactUnitFrame_UpdateVisible'
FrameXML\CompactUnitFrame.lua:243: in function `CompactUnitFrame_UpdateAll'
FrameXML\CompactUnitFrame.lua:98: in function <FrameXML\CompactUnitFrame.lua:45>
--]]



--[[
------------------------------------
-- Duplicate in Examiner/core.lua --
------------------------------------

-- IsModifiedKey(modifiedClickAction) is similar to IsModifiedClick(modifiedClickAction),
-- checking only for the modifier key state set in Bindings.xml/<ModifiedClick action="modifiedClickAction">, regardless of mouse input.
-- Whereas IsModifiedClick() returns nil if there is no mousebutton pressed. 
-- Also fixes the behaviour with multiple modifiers. CTRL-SHIFT-BUTTON1 checks for Control and Shift _both_ to be pressed,
-- while IsModifiedClick() checks if _any_ of the modifiers is pressed. Opposite of how keybindings work.
local IsModifierDownFunc = {
	ALT = IsAltKeyDown,
	CTRL = IsControlKeyDown,
	SHIFT = IsShiftKeyDown,
	[0] = function() return true end,
}

local IsModifiedKeyCache = {}

function IsModifiedKey(action)
	local checkerFuncs = IsModifiedKeyCache[action]
	if  checkerFunc  then  return checkerFunc()  end
	
	-- 8 modifier key variations: ACS, AC, AS, CS, A, C, S, none
	local key1, key2, key3, btn = ('-'):split( GetModifiedClick(action) or '' )
	-- f1,f2,f3 will check for one modifier key or return true if not needed. f1 is needed minimum.
	local f1,f2,f3 = IsModifierDownFunc[key1], IsModifierDownFunc[key2] or IsModifierDownFunc[0], IsModifierDownFunc[key3] or IsModifierDownFunc[0]
	-- checkerFunc checks for all modifiers needed
	-- If f1 is null then there is no modifier key in the ModifiedClick. IsModifiedClick is called to check for a potential mouseclick.
	checkerFunc =  not f1  and  IsModifiedClick
		or  function()  return f1() and f2() and f3()  end
	
	IsModifiedKeyCache[action] = checkerFunc
	return checkerFunc(action)  -- only IsModifiedClick cares about the parameter
end
--]]



--[[
local IsModClickFunc = setmetatable({}, {
	__index = function(self, id)
		-- Parse the mouse button number once and store in the closure
		local buttonNum = tonumber(id:sub(7))  or  id
		self[id] = IsModifierDownFunc[id]  or  function()  return IsMouseButtonDown(buttonNum)  end
		return self[id]
	end,
})
local function IsModClick(id)
	__index = function(self, id)
		local isMod = IsModifierDownFunc[id]
		if  isMod  then  return isMod()  end
		-- Parse the mouse button number
		local buttonNum = tonumber(id:sub(7))  or  id
		return IsMouseButtonDown(buttonNum)
	end,
})
--]]





