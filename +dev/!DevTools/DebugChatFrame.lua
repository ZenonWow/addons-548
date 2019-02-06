--CHAT_TIMESTAMP_FORMAT
--FCF_GetCurrentChatFrame()
--FCF_GetCurrentChatFrameID()

do
	local  DebugFrameNames = {
		Debug =1,
		Dbg =1,
		Log =1,
		Addons =1,
		Add =1,
	}
	-- Make enough space for the login message spam of addons and a potential ADDON_LOADED log.
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local chatFrame = _G["ChatFrame" .. i]
		
		if  chatFrame:GetMaxLines() < 1000  then  chatFrame:SetMaxLines(1000)  end
		if  chatFrame:IsShown()  and  DebugFrameNames[chatFrame.name]  then  DEFAULT_CHAT_FRAME = chatFrame  end
		
		-- Save the original AddMessage as AddMessageRaw. Addons knowing this can use it for custom timestamp formating in case Prat Timestamps is enabled.
		if  not chatFrame.AddMessageRaw  then  chatFrame.AddMessageRaw = chatFrame.AddMessage  end
	end
end




