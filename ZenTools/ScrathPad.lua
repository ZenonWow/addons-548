--[[ Dump code here and enter in chat   /rl  ]]--

local function SpellBookFrame_OnMouseWheel(self, value)
	local direction = 0 < value  and  'Prev'  or  'Next'    -- roll up: PrevPage, roll down: NextPage
	local btnName = 'SpellBook'..direction..'PageButton'
	local btn = _G[btnName]
	-- Turn pages with mouse wheel only on player and pet spells
	if  SpellBookFrame.bookType ~= BOOKTYPE_SPELL  and  SpellBookFrame.bookType ~= BOOKTYPE_PET  then  return
	elseif  value ~= 0  and  btn:IsEnabled()  then  _G[btnName..'_OnClick']( btn )
	end
end

SpellBookFrame:EnableMouseWheel(true)
SpellBookFrame:SetScript("OnMouseWheel", SpellBookFrame_OnMouseWheel)

--[[
/run local s,b=SpellBookFrame,'SpellBook'..(0<v and 'Prev' or 'Next')..'PageButton';s:EnableMouseWheel(true);
s:SetScript("OnMouseWheel",function(_,v)
if(s.bookType=='spell' or s.bookType=='pet')and _G[b]:IsEnabled() then _G[b..'_OnClick']()end
end)

BOOKTYPE_SPELL = "spell";
BOOKTYPE_PROFESSION = "professions";
BOOKTYPE_PET = "pet";
BOOKTYPE_CORE_ABILITIES = "core";
BOOKTYPE_WHAT_HAS_CHANGED = "changed"
--]]

LossOfControlFrame:SetPoint('CENTER', 0, 100)


--[[
InboxMailbagTab_OnClick(MB_Tab)
InboxMailbag_Hide()

function InboxMailbagTab_OnClick(self)
	hooksecurefunc("MailFrameTab_OnClick", InboxMailbag_Hide); -- Adopted from Sent Mail as a more general solution, and plays well with Sent Mail


<Button name="MerchantFrameTab1" inherits="CharacterFrameTabButtonTemplate" id="1" text="MERCHANT">
	<Scripts>
		<OnClick>
			PanelTemplates_SetTab(MerchantFrame, self:GetID());
			MerchantFrame_Update();
		</OnClick>
	</Scripts>
</Button>

			<Button name="MailFrameTab1" inherits="FriendsFrameTabTemplate" id="1" text="INBOX">
					<OnClick>
						MailFrameTab_OnClick(self, 1);
					</OnClick>
			</Button>

function MailFrameTab_OnClick(self, tabID)
	if ( not tabID ) then
		tabID = self:GetID();
	end
	PanelTemplates_SetTab(MailFrame, tabID);
	if ( tabID == 1 ) then
		-- Inbox tab clicked
		ButtonFrameTemplate_HideButtonBar(MailFrame)
		MailFrameInset:SetPoint("TOPLEFT", 4, -58);
		InboxFrame:Show();
		SendMailFrame:Hide();
		SetSendMailShowing(false);
	else
		-- Sendmail tab clicked
		ButtonFrameTemplate_ShowButtonBar(MailFrame)
		MailFrameInset:SetPoint("TOPLEFT", 4, -80);
		InboxFrame:Hide();
		SendMailFrame:Show();
		SendMailFrame_Update();
		SetSendMailShowing(true);

		-- Set the send mode to dictate the flow after a mail is sent
		SendMailFrame.sendMode = "send";
	end
	PlaySound("igSpellBookOpen");
end
--]]

--[[
/run SetModifiedClick('CHATLINK','ALT-BUTTON1')
/run LibStub("AceConfigDialog-3.0"):SetDefaultSize("FasterCamera", 420, 510)

/run MainMenuBarBackpackButton:Disable()
/run MainMenuBarBackpackButton:Hide()
/run MainMenuBarBackpackButton:SetScript('OnEvent',nil)
--]]
MainMenuBarBackpackButton:SetScript('OnLoad',nil)
MainMenuBarBackpackButton:SetScript('OnClick',nil)
MainMenuBarBackpackButton:SetScript('OnReceiveDrag',nil)
MainMenuBarBackpackButton:SetScript('OnEnter',nil)
MainMenuBarBackpackButton:SetScript('OnLeave',nil)
MainMenuBarBackpackButton:SetScript('OnEvent',nil)



--[[
	MailTab:Hook("MailFrameTab_OnClick", OnOtherTabClick, true)
	tab:SetScript("OnClick", OnTabClick)
--]]


--[[
Auctionator -> taints  CompactRaidFrame2:Show()
4x [ADDON_ACTION_BLOCKED] AddOn 'Auctionator' tried to call the protected function 'CompactRaidFrame2:Show()'.
!BugGrabber\BugGrabber.lua:586: in function <!BugGrabber\BugGrabber.lua:586>
[C]: in function `Show'
FrameXML\CompactUnitFrame.lua:285: in function `CompactUnitFrame_UpdateVisible'
FrameXML\CompactUnitFrame.lua:243: in function `CompactUnitFrame_UpdateAll'
FrameXML\CompactUnitFrame.lua:98: in function <FrameXML\CompactUnitFrame.lua:45>
--]]



