

local LogLastTime= 0
local LogCount= 0
local LogCount2= 0
local function DEFAULT_CHAT_FRAME_AddMessage_Mod(self, ...)
	-- add some separator between AddMessages: 1 line after 5 lines and 0.1 sec delay, 2 lines after 20 lines and 20 sec delay
	if not DEFAULT_CHAT_FRAME then return end
	local elapsed= GetTime() - LogLastTime
	LogLastTime= GetTime()
	LogCount= LogCount + 1
	LogCount2= LogCount2 + 1
	if  elapsed > 2  and  LogCount2 > 20  then  DEFAULT_CHAT_FRAME:AddMessage('') LogCount2=0  end
	if  elapsed > 0.1  and  LogCount > 5  then  DEFAULT_CHAT_FRAME:AddMessage('') LogCount=0  end
	self:AddMessage_Orig(...)
end


function  GetChatFrame(name)
	for  i= 1,10  do
		local  frame= _G['ChatFrame'..i]
		if  frame and frame.name == name and frame:IsVisible()
		then  return frame  end
	end
	return nil
end

function  InitDebugChatFrame()
	local Debug_Chat_Frame= GetChatFrame('Debug')
	if  Debug_Chat_Frame  then
		-- taken from Mappy/MCDebugLib.lua
		if  Debug_Chat_Frame:GetMaxLines() < 1000
		then  Debug_Chat_Frame:SetMaxLines(1000)  end
		
		--Debug_Chat_Frame:SetFading(false)
		Debug_Chat_Frame:SetMaxResize(1200, 1000)
		
		-- DEFAULT_CHAT_FRAME is now the Debug frame -> mention this in the original frame "General"
		DEFAULT_CHAT_FRAME:AddMessage('')
		DEFAULT_CHAT_FRAME:AddMessage('')
		DEFAULT_CHAT_FRAME:AddMessage('Changeing DEFAULT_CHAT_FRAME:  ' .. colors.lightblue .. 'Debug output goes to frame: ' .. colors.white .. tostring(Debug_Chat_Frame.name) )
		DEFAULT_CHAT_FRAME:AddMessage('')
		_G.DEFAULT_CHAT_FRAME= Debug_Chat_Frame
	end
	
	-- silent fail - nowhere to report
	if  DEFAULT_CHAT_FRAME == nil  then  return  end
	
	DEFAULT_CHAT_FRAME:AddMessage('')
	DEFAULT_CHAT_FRAME:AddMessage('')
	DEFAULT_CHAT_FRAME:AddMessage(colors.green .. 'Debug output appears in this chat frame: ' .. colors.white .. tostring(DEFAULT_CHAT_FRAME.name))
	DEFAULT_CHAT_FRAME:AddMessage('')
end

function  ReplaceChatAddMessage()
	-- store original
	if  not DEFAULT_CHAT_FRAME.AddMessage_Orig
	then  DEFAULT_CHAT_FRAME.AddMessage_Orig= DEFAULT_CHAT_FRAME.AddMessage  end
	-- replace with mod
	DEFAULT_CHAT_FRAME.AddMessage= DEFAULT_CHAT_FRAME_AddMessage_Mod
end

local  addonFrame= CreateFrame("Frame")
addonFrame:RegisterEvent("ADDON_LOADED")
addonFrame:SetScript("OnEvent", function (this, event, addon)
	if  event == "ADDON_LOADED" and addon == ADDON_NAME  then
		InitDebugChatFrame()
		--ReplaceChatAddMessage()
	end
end)


