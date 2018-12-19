


--[[
	FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
	FriendsFrame:RegisterEvent("WHO_LIST_UPDATE")
	FriendsFrame:UnregisterEvent("IGNORELIST_UPDATE")
	FriendsFrame:RegisterEvent("IGNORELIST_UPDATE")
	FriendsFrame:UnregisterEvent("FRIENDLIST_UPDATE")
	FriendsFrame:RegisterEvent("FRIENDLIST_UPDATE")
	FriendsFrame:UnregisterEvent("FRIENDLIST_SHOW")
	FriendsFrame:RegisterEvent("FRIENDLIST_SHOW")
--]]

local WhoMonitor = {
	lastEnteredWho = "",
	lastWhoUpdate = 0,
}
_G.WhoMonitor = WhoMonitor

function WhoFrameEditBox_OnEnterPressed(self)
	WhoMonitor.lastEnteredWho = self:GetText()
	SendWho(self:GetText());
end

function WhoMonitor.OnUpdate(whoFrame)
	if  WhoMonitor.lastEnteredWho == ""  then  return  end
	local now = time()
	if  WhoFrame:IsVisible()  and  2 <= now - WhoMonitor.lastWhoUpdate then
		print("WhoMonitor.OnUpdate(): "..WhoMonitor.lastEnteredWho)
		WhoMonitor.lastWhoUpdate = now
		SendWho(WhoMonitor.lastEnteredWho)
	end
end

WhoFrameEditBox:SetScript('OnEnterPressed', WhoFrameEditBox_OnEnterPressed)
WhoFrame:SetScript('OnUpdate', WhoMonitor.OnUpdate)


