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
--]]


--		BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
hooksecurefunc('BattlePetToolTip_Show', function(...)
	print( "BattlePetToolTip_Show("..strjoin(", ", tostringall(...)..")") )
end)


--[[ TODO: 
find BattlePetTooltip:SetScript
/run _G.ChatFrame_OpenChat("/cast Inner Fire")  ;  _G.ChatEdit_SendText(editbox, 1)
/run reportActionButtons()
/dump debuglocals()
/dump GetPlayerInfoByGUID('0x010B0000002ADF67')  -- Tessa
/dump LibStub("AceDB-3.0").minors    -- 29, last was 25
/run FriendsFrame_ShowDropdown('Dallaryen', 1, 1, 'WHISPER', ChatFrame1)   -- taints?
HandleModifiedItemClick táskából vendornak??
-- geterrorhandler(), xpcall(f, errhandler) <-> pcall(f, args...)
-+ AceDB: purge profileKeys
-- AuctionMaster: delayed fix
-- X-LoadOn-Frames
-- AutoBar scale: a nagyobbik dimenzio hasson csak
-- TODO: securemousewheelhandler
-- TODO: color fill, yield
-- /dump combatlog-name-link, leatrix/addonloader reloadui-link
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
--tDeleteItem()
-- investigate UISpecialFrames -- UIPanelWindows
/run UIPanelWindows.GameMenuFrame    = nil
/dump BlackMarketFrame:GetRect()
/dump MailFrame:GetRect()
/run f= MailFrame ; for i=1,f:GetNumPoints() do print(strjoin(',', tostringall(f:GetPoint(i)) )) end
/run f= BlackMarketFrame ; for i=1,f:GetNumPoints() do print(strjoin(',', tostringall(f:GetPoint(i)) )) end
/run BlackMarketFrame:SetPoint('TOPLEFT',10,-20)
/run MailFrame:SetPoint('TOPLEFT',10,-20)
/run TradeFrame:SetPoint('TOPLEFT',10,-20)
/run MerchantFrame:SetPoint('TOPLEFT',10,-20)
/run MailFrame:ClearAllPoints() ; MailFrame:SetHeight(400) ; MailFrame:SetWidth(300) ; MailFrame:SetPoint('TOPLEFT',10,-20)
/run ToggleFrame(MailFrame)
/dump MailFrame:IsShown()
/run DisableAddOn('Dominos')
/run EnableAddOn('Dominos')
/dump SetModifiedClick('ATTACHSIMILAR','ALT')
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

/run Examiner:ClearAllPoints() Examiner:SetPoint('TOPLEFT', 20, -20)
--]]

UIPanelWindows.InterfaceOptionsFrame = nil
UIPanelWindows.CharacterFrame        = nil
UIPanelWindows.SpellBookFrame        = nil
UIPanelWindows.TaxiFrame             = nil
UIPanelWindows.TradeFrame            = nil
UIPanelWindows.LootFrame             = nil
UIPanelWindows.MerchantFrame         = nil
UIPanelWindows.MailFrame             = nil
UIPanelWindows.DressUpFrame          = nil
UIPanelWindows.FriendsFrame          = nil
UIPanelWindows.WorldMapFrame         = nil
UIPanelWindows.ChatConfigFrame       = nil
UIPanelWindows.GameMenuFrame         = nil
UISpecialFrames[#UISpecialFrames+1] = "CharacterFrame"
UISpecialFrames[#UISpecialFrames+1] = "SpellBookFrame"
-- UISpecialFrames[#UISpecialFrames+1] = "TaxiFrame"
UISpecialFrames[#UISpecialFrames+1] = "TradeFrame"
-- UISpecialFrames[#UISpecialFrames+1] = "LootFrame"
UISpecialFrames[#UISpecialFrames+1] = "MerchantFrame"
UISpecialFrames[#UISpecialFrames+1] = "MailFrame"
UISpecialFrames[#UISpecialFrames+1] = "DressUpFrame"
UISpecialFrames[#UISpecialFrames+1] = "FriendsFrame"
UISpecialFrames[#UISpecialFrames+1] = "WorldMapFrame"
UISpecialFrames[#UISpecialFrames+1] = "ChatConfigFrame"
UISpecialFrames[#UISpecialFrames+1] = "GameMenuFrame"
UISpecialFrames[#UISpecialFrames+1] = "ScriptErrorsFrame"    -- Later loaded from Blizzard_DebugTools
CharacterFrame:SetPoint('TOPLEFT',10,-20)
SpellBookFrame:SetPoint('TOPLEFT',10,-20)
-- TaxiFrame:SetPoint('TOPLEFT',10,-20)
-- TradeFrame:SetPoint('TOPLEFT',10,-20)
MerchantFrame:SetPoint('TOPLEFT',10,-20)
MailFrame:SetPoint('TOPLEFT',10,-20)
--DressUpFrame:SetPoint('TOPRIGHT',-10,-20)
FriendsFrame:SetPoint('TOPRIGHT',-10,-20)


LossOfControlFrame:SetPoint('CENTER', 0, 100)


-- BFBindingMode is UISpecialFrames[8], it's Shown but not visible (offscreen)
if  BFBindingMode  then  BFBindingMode:Hide()  end
--BFBindingMode:SetPoint('TOPLEFT',10,-20)
--tDeleteItem(UISpecialFrames, BFBindingMode)







function GetActionButtonNameMy(id)
	-- 6->2 5->3 4->4 3->5 2->6
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
	if id <= 12 then  return 'ActionButton' .. id
	elseif id <= 24 then  return 'DominosActionButton' .. (id-12)
	elseif id <= 36 then  return 'MultiBarRightButton' .. (id-24)
	elseif id <= 48 then  return 'MultiBarLeftButton' .. (id-36)
	elseif id <= 60 then  return 'MultiBarBottomRightButton' .. (id-48)
	elseif id <= 72 then  return 'MultiBarBottomLeftButton' .. (id-60)
	else  return 'DominosActionButton' .. (id-60)
	end
end

local GetActionButtonName = GetActionButtonNameOrig

--[[
http://wowwiki.wikia.com/wiki/SecureHandlers
http://wowwiki.wikia.com/wiki/RestrictedEnvironment
SpellIsTargeting()
/run TestActionButtonIDs()
--]]
function TestActionButtonIDs()
	for i = 1,120  do
		local n = GetActionButtonName(i)
		local id = _G[n]  and  (_G[n]:GetID() or '<noID>')  or  '<noButton>'
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
--]]



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




