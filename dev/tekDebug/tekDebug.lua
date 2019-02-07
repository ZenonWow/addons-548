

--[[
How do you use this bugger? simple!

local f = tekDebug:GetFrame("MyAddon")
This gets you a ScrollingMessageFrame to output debuggery into.  You can call f:AddMessage() directly if you like, pass it off to your Debug lib, whatever.

In my addons this is what I do...
Force tD to load before your addon if present
## OptionalDeps: tekDebug

Then make a Debug function (note, this version is NOT nil-safe)

local debugf = tekDebug and tekDebug:GetFrame("MyAddon")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", ...)) end end

Or, if you use Dongle:

MyAddon = DongleStub("Dongle-1.0"):New("MyAddon")
if tekDebug then MyAddon:EnableDebug(1, tekDebug:GetFrame("MyAddon")) end
]]


local tekDebug = {}
_G.tekDebug = tekDebug

local DebugPanel = LibStub('SlimPanel').new('DebugPanel', 'tekDebug', true)
local navBar = CreateFrame('Frame', 'DebugPanelNav', DebugPanel)
DebugPanel.navBar = navBar
--navBar:SetPoint('TOPLEFT', 23, -105)
navBar:SetPoint('TOPLEFT', DebugPanel.TitleRegion, 'BOTTOMLEFT')
navBar:SetPoint('BOTTOMLEFT')
navBar:SetWidth(158)
--[[
/run DebugPanel.logBar:SetPoint('TOPLEFT')
/run DebugPanel.frames.AddonLoader:SetAllPoints()
--]]
local logBar = CreateFrame('Frame', 'DebugPanelLogs', DebugPanel)
DebugPanel.logBar = logBar
logBar:SetPoint('TOPLEFT', navBar, 'TOPRIGHT')
--logBar:SetPoint('TOPRIGHT', self.TitleRegion, 'BOTTOMRIGHT')
logBar:SetPoint('BOTTOMRIGHT')

local frames, names = {}, {}
DebugPanel.frames = frames
local buttons, offset = {}, 0

local function refresh()
	for  i = 1, #buttons  do
		local button, logName = buttons[i], names[i+offset]
		if  logName  then
			button.logName = logName
			button.text:SetText(logName)
			if frames[logName]:IsVisible() then button:LockHighlight() else button:UnlockHighlight() end
			button:Show()
		else
			button:Hide()
		end
	end
end

local function Nav_OnClick(self)
	if not self.scrollframe then return end

	local frame = frames[self.logName]
	if frame:IsVisible() then
		frame:Hide()
		self:UnlockHighlight()
	else
		print("Nav_OnClick("..self.logName..")")
		for _,f in pairs(frames) do f:Hide() end
		for _,f in pairs(buttons) do f:UnlockHighlight() end

		--[[
		frame:SetParent(DebugPanel)
		frame:ClearAllPoints()
		frame:SetPoint("TOPLEFT", 190, -103)
		frame:SetWidth(630) frame:SetHeight(305)
		frame:SetFrameStrata("DIALOG")
		--]]
		frame:Show()
		self:LockHighlight()
		logBar.messageFrame = frame
	end
end

local function Nav_OnMouseWheel(self, v)
	if v > 0 then -- up
		offset = math.max(offset - 1, 0)
		refresh()
	else -- down
		offset = math.max(math.min(offset + 1, #names - #buttons), 0)
		refresh()
	end
end


DebugPanel:SetScript('OnShow', function(self)
	for  i = 1,15  do
		local button = CreateFrame('Button', "DebugPanelNav"..i, navBar)
		button:SetHeight(20)
		if i == 1 then  button:SetPoint('TOPLEFT') ; button:SetPoint('TOPRIGHT')
		else
			button:SetPoint('TOPLEFT', buttons[i-1], 'BOTTOMLEFT')
			button:SetPoint('TOPRIGHT', buttons[i-1], 'BOTTOMRIGHT')
		end

		button:SetHighlightFontObject(GameFontHighlightSmall)
		button:SetNormalFontObject(GameFontNormalSmall)

		button:SetNormalTexture([[Interface\AuctionFrame\UI-AuctionFrame-FilterBG]])
		button:GetNormalTexture():SetTexCoord(0, 0.53125, 0, 0.625)

		button:SetHighlightTexture([[Interface\PaperDollInfoFrame\UI-Character-Tab-Highlight]])
		button:GetHighlightTexture():SetBlendMode('ADD')

		button.text = button:CreateFontString(nil, 'OVERLAY', 'GameFontWhite')
		button.text:SetText("Test")
		button.text:SetPoint('LEFT', button, 10, 0)
		button.text:SetPoint('RIGHT', button, -10, 0)
		button.text:SetJustifyH('LEFT')

		button:EnableMouseWheel()
		button:SetScript('OnMouseWheel', Nav_OnMouseWheel)
		button:SetScript('OnClick', Nav_OnClick)

		buttons[i] = button
	end

	refresh()
	self:SetScript('OnShow', nil)
end)


local function Log_OnMouseWheel(frame, delta)
	if delta > 0 then
		if IsControlKeyDown() and IsShiftKeyDown() then frame:ScrollToTop()
		elseif IsControlKeyDown() then frame:ScrollUp(60)
		elseif IsShiftKeyDown() then frame:ScrollUp(15)
		else frame:ScrollUp(3) end
	elseif delta < 0 then
		if IsControlKeyDown() and IsShiftKeyDown() then frame:ScrollToBottom()
		elseif IsControlKeyDown() then frame:ScrollDown(60)
		elseif IsShiftKeyDown() then frame:ScrollDown(15)
		else frame:ScrollDown(3) end
	end
end

local function Log_OnHyperlinkClick(sourceFrame, linkRef, fullLink, mouseButton)
	SetItemRef(linkRef, fullLink, mouseButton, sourceFrame)
end

local function SMF_AddMessageRaw(self, ...)
	local edittext = self:GetText()
	edittext = edittext .."\n".. string.join( " ", tostringall(...) )
	self:SetText(edittext)
end
local function Editbox_AddMessageRaw(self, ...)
	local edittext = self:GetText()
	edittext = edittext .."\n".. string.join( " ", tostringall(...) )
	self:SetText(edittext)
end
local function Log_AddMessage(self, txt, ...)
	--txt = txt:gsub(self.logName.."|r:", date("%X").."|r", 1)
	local timestamp = date("%H:%M:%S")
	return self:AddMessageRaw(timestamp, txt, ...)
end

--[[
/vdt DebugPanelLogs_EventTracker
--]]
--local MAXLINES = 1000
function tekDebug:GetFrame(logName)
	if frames[logName] then return frames[logName] end

	local frame = CreateFrame('ScrollingMessageFrame', "DebugPanelLogs_"..logName, logBar)
	frame:SetMaxLines(5000)
	frame:SetFontObject(ChatFontSmall)
	frame:SetJustifyH('LEFT')
	frame:SetFading(false)

	frame:SetPoint("TOPLEFT")
	frame:SetWidth(logBar:GetWidth()) frame:SetHeight(logBar:GetHeight())
	-- frame:SetAllPoints()
	
	frame:EnableMouse(true)
	frame:EnableMouseWheel(true)
	frame:SetHyperlinksEnabled(true)
	frame:SetScript('OnMouseWheel', Log_OnMouseWheel)
	frame:SetScript('OnHide', frame.ScrollToBottom)
	frame:SetScript('OnHyperlinkClick', Log_OnHyperlinkClick)
	frame:Hide()
	
	-- Public API
	frame.logName = logName
	frame.AddMessageRaw = frame.AddMessage
	frame.AddMessage = Log_AddMessage
	
	frames[logName] = frame
	table.insert(names, logName)
	table.sort(names)
	refresh()

	return frame
end


function tekDebug:GetFrame2(logName)
	if frames[logName] then return frames[logName] end

	local editbox = CreateFrame('EditBox', "DebugPanelLogs_"..logName, logBar)
	--f:SetFontObject(ChatFontSmall)
	--f:SetJustifyH('LEFT')
	-- No limit
	editbox:SetMaxLetters(0)
	editbox:SetMaxBytes(0)
	editbox:SetMultiLine(true)
	--editbox:SetHistoryLines(0)
	
	editbox:SetAllPoints()
	editbox:SetWidth(logBar:GetWidth())
	editbox:SetHeight(logBar:GetHeight())
	
	editbox:EnableMouse(true)
	editbox:SetHyperlinksEnabled(true)
	--editbox:SetScript('OnMouseWheel', Log_OnMouseWheel)
	--editbox:SetScript('OnHide', editbox.ScrollToBottom)
	--editbox:SetScript('OnHyperlinkEnter', f:GetScript('OnHyperlinkEnter'))
	--editbox:SetScript('OnHyperlinkLeave', f:GetScript('OnHyperlinkLeave'))
	editbox:SetScript('OnHyperlinkClick', Log_OnHyperlinkClick)
	editbox:SetScript('OnEscapePressed', editbox.ClearFocus)
	editbox:Hide()
	
	-- Public API
	editbox.logName = logName
	editbox.AddMessageRaw = Editbox_AddMessageRaw
	editbox.AddMessage = Log_AddMessage
	
	frames[logName] = editbox
	table.insert(names, logName)
	table.sort(names)
	refresh()

	return editbox
end


-----------------------------
--      Slash Handler      --
-----------------------------

SLASH_TEKDEBUG1 = "/d"
SLASH_TEKDEBUG2 = "/td"
SLASH_TEKDEBUG3 = "/tek"
SLASH_TEKDEBUG4 = "/tekdebug"
function SlashCmdList.TEKDEBUG(arg)
	if  arg == "" then  return  ToggleFrame(DebugPanel)  end
	if  arg:find("|")  then  arg = arg.."  ->  "..arg:gsub("|","||")  end
	print("/d: "..arg)
end


----------------------------------------
--      Quicklaunch registration      --
----------------------------------------

local ldb = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)
if ldb then
	ldb:NewDataObject("tekDebug", {
		type = "launcher",
		icon = [[Interface\Icons\Spell_Shadow_CarrionSwarm]],
		OnClick = function()  ToggleFrame(DebugPanel)  end,
	})
end
