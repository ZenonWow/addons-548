--[[
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


-- BFBindingMode is UISpecialFrames[8], it's Shown but not visible (offscreen)
if  BFBindingMode  then  BFBindingMode:Hide()  end
--BFBindingMode:SetPoint('TOPLEFT',10,-20)
--tDeleteItem(UISpecialFrames, BFBindingMode)

--[[
LossOfControlFrame:SetPoint('CENTER', 0, 100)
--]]



