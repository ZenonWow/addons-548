
--[[
local function SpellBookFrame_OnMouseWheel(self, offset)
	-- Turn pages with mouse wheel only on player and pet spells
	if  SpellBookFrame.bookType ~= BOOKTYPE_SPELL  and  SpellBookFrame.bookType ~= BOOKTYPE_PET  then  return  end
	
	local direction = 0 < offset  and  'Prev'  or  'Next'    -- roll up: PrevPage, roll down: NextPage
	local btnName = 'SpellBook'..direction..'PageButton'
	local btn = _G[btnName]
	if  offset ~= 0  and  btn:IsEnabled()  then  securecall(btnName..'_OnClick')  end
end

SpellBookFrame:EnableMouseWheel(true)
SpellBookFrame:SetScript("OnMouseWheel", SpellBookFrame_OnMouseWheel)

/run local s,b=SpellBookFrame,'SpellBook'..(0<v and 'Prev' or 'Next')..'PageButton';s:EnableMouseWheel(true);
s:SetScript("OnMouseWheel",function(_,v)
if(s.bookType=='spell' or s.bookType=='pet')and _G[b]:IsEnabled() then securecall(b..'_OnClick')end
end)

BOOKTYPE_SPELL = "spell";
BOOKTYPE_PROFESSION = "professions";
BOOKTYPE_PET = "pet";
BOOKTYPE_CORE_ABILITIES = "core";
BOOKTYPE_WHAT_HAS_CHANGED = "changed"
--]]

--[[
-- Secure wrapper  function  SpellBookFrame_PreOnMouseWheel(self, button, down)
--local function SpellBookFrame_PreOnMouseWheel(self, offset)
	-- Turn pages with mouse wheel only on player and pet spells
	--if  SpellBookFrame.bookType ~= BOOKTYPE_SPELL  and  SpellBookFrame.bookType ~= BOOKTYPE_PET  then  return  end
	
	--local funcName = direction..'PageButton_OnClick'
	--if  offset ~= 0  then  self:CallMethod(funcName)  end

--end
local SpellBookFrame_PostOnMouseWheel = nil


<Frame name="SecureHandlerMouseWheelTemplate"
	 inherits="SecureHandlerBaseTemplate" virtual="true">
    <Scripts>
      <OnLoad>
	SecureHandler_OnLoad(self);
	self:EnableMouseWheel();
      </OnLoad>
      <OnMouseWheel>
	SecureHandler_OnMouseWheel(self, "_onmousewheel", delta);
      </OnMouseWheel>
    </Scripts>
</Frame>


/run SpellBookFrame_Update()
/run SpellBook_UpdatePlayerTab()
/run SpellBookFrame_UpdateSpells()
/run ToggleSpellBook(bookType)
/run SpellBookPrevPageButton_OnClick()
/run SpellBookNextPageButton_OnClick()
--]]




--[[
-- Secure wrapper  function  SpellBookFrame_PreOnMouseWheel(self, button, down)
local SpellBookFrame_PreOnMouseWheel = [===[
	print("SpellBookFrame_PreOnMouseWheel(".. self:GetName() ..",".. button ..",".. tostring(down) ..")")
	if  0 < offset  then  self:CallMethod('ClickPrev')  else  self:CallMethod('ClickNext')  end
	local direction = 0 < offset  and  'Prev'  or  'Next'    -- roll up: PrevPage, roll down: NextPage
	local btnHandle = self:GetFrameRef(direction..'PageButton')
	self:SetFrameRef('toclick', btnHandle)
	self:SetAttribute('click', btnHandle:GetName())
	--btnHandle:Click()
]===]

local frame = CreateFrame("Frame", "SpellBookFrameWheelie", SpellBookFrame, "SecureHandlerMouseWheelTemplate")
frame:SetFrameRef('PrevPageButton', SpellBookPrevPageButton)
frame:SetFrameRef('NextPageButton', SpellBookNextPageButton)
frame.ClickPrev = SpellBookPrevPageButton_OnClick
frame.ClickNext = SpellBookNextPageButton_OnClick
--frame:SetAttribute('_onmousewheel', SpellBookFrame_PreOnMouseWheel)
--frame:SetAllPoints()
frame:WrapScript(SpellBookFrame, 'OnMouseWheel', SpellBookFrame_PreOnMouseWheel, nil)
--]]




----[[
-- MOUSEWHEELUP, MOUSEWHEELDOWN
-- HANDLE:SetBinding(priority, key, action)
-- Secure wrapper  function  SpellBookFrameMouseOver_OnEnter(self, button, down)
local SpellBookFrame_OnEnter = [===[
	print("SpellBookFrame_OnEnter()")
	self:SetBinding(true, 'MOUSEWHEELUP',   'CLICK SpellBookPrevPageButton')
	self:SetBinding(true, 'MOUSEWHEELDOWN', 'CLICK SpellBookNextPageButton')
	-- Let the OnMouseWheel event through to UIParent to trigger MOUSEWHEELUP/MOUSEWHEELDOWN binding.
	-- SpellBookFrame:EnableMouse(false)
]===]
-- return nil, true

local SpellBookFrame_OnLeave = [===[
	print("SpellBookFrame_OnLeave()")
	self:ClearBinding('MOUSEWHEELUP')
	self:ClearBinding('MOUSEWHEELDOWN')
	-- SpellBookFrame:EnableMouse(true)
]===]

-- local handler = CreateFrame('Frame', 'SpellBookFrameWheelie', SpellBookFrame, 'SecureHandlerMouseWheelTemplate')
local handler = CreateFrame('Frame', 'SpellBookFrameWheelie', SpellBookFrame, 'SecureHandlerEnterLeaveTemplate')
handler:SetFrameRef('SpellBookFrame', SpellBookFrame)
handler:WrapScript(SpellBookFrame, 'OnEnter', SpellBookFrame_OnEnter)
handler:WrapScript(SpellBookFrame, 'OnLeave', SpellBookFrame_OnLeave)
handler:Execute(" SpellBookFrame = self:GetFrameRef('SpellBookFrame') ")
SpellBookFrame:EnableMouseWheel(false)
-- SpellBookFrame:EnableMouse(false)

--[[
/run SetOverrideBinding( SpellBookFrameWheelie , false, 'MOUSEWHEELUP'  , 'CLICK SpellBookPrevPageButton')
/run SetOverrideBinding( SpellBookFrameWheelie , false, 'MOUSEWHEELDOWN', 'CLICK SpellBookNextPageButton')
/run SetOverrideBindingMacro( SpellBookFrameWheelie , false, 'MOUSEWHEELUP'  , '/click SpellBookPrevPageButton')
/run SetOverrideBindingMacro( SpellBookFrameWheelie , false, 'MOUSEWHEELDOWN', '/click SpellBookNextPageButton')
/run SetOverrideBinding( SpellBookFrameWheelie , false, 'MOUSEWHEELUP'  , nil)
/run SetOverrideBinding( SpellBookFrameWheelie , false, 'MOUSEWHEELDOWN', nil)
/run ChatFrame1:Clear()
/click SpellBookNextPageButton

/run SetBinding( 'MOUSEWHEELDOWN', 'CLICK SpellBookNextPageButton')
/run SetBinding( 'MOUSEWHEELDOWN', 'CAMERAZOOMOUT')
/dump GetBindingByKey('MOUSEWHEELUP'), GetBindingByKey('MOUSEWHEELDOWN'), GetBindingByKey('MOVEANDSTEER'), GetBindingByKey('MOVEFORWARD')


local frame = CreateFrame("Frame", "SpellBookFrameMouseOver", SpellBookFrame, "SecureHandlerEnterLeaveTemplate")
frame:SetAttribute('_onenter', SpellBookFrameMouseOver_OnEnter)
frame:SetAttribute('_onleave', SpellBookFrameMouseOver_OnLeave)
frame:SetAllPoints()
--]]






--[[

--handler:WrapScript(WorldMapFrame, 'OnClick', preBody, postBody)

local function MerchantFrame_OnMouseWheel(self, offset)
	-- Turn pages with mouse wheel only on buy tab
	if  MerchantFrame.selectedTab ~= 1  then   return  end
	
	local direction = 0 < offset  and  'Prev'  or  'Next'    -- roll up: PrevPage, roll down: NextPage
	local btnName = 'Merchant'..direction..'PageButton'
	local btn = _G[btnName]
	if  offset ~= 0  and  btn:IsEnabled()  then  _G[btnName..'_OnClick']( btn )  end
end

-- Done by GnomishVendorShrinker too
if  not MerchantFrame:GetScript("OnMouseWheel")  then
	MerchantFrame:EnableMouseWheel(true)
	MerchantFrame:SetScript("OnMouseWheel", MerchantFrame_OnMouseWheel)
end
--]]



