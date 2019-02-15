--[[--------------------------------------------------------------------
	Bugger
	Basic GUI front-end for !BugGrabber.
	Copyright (c) 2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info23144-Bugger.html
	http://www.curse.com/addons/wow/bugger
----------------------------------------------------------------------]]

local BUGGER, Bugger = ...
local L = Bugger.L

if not BugGrabber then
	function Bugger:OnLogin()
		DEFAULT_CHAT_FRAME:AddMessage(L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."])
	end
	return
end

_G[BUGGER] = Bugger

------------------------------------------------------------------------

Bugger.db = "BuggerDB"
Bugger.dbDefaults = {
	autoshow = false,
	chat  = true,  -- show a message in the chat frame when an error is captured
	sound = false, -- play a sound when an error is captured
	soundMedia = "Baby Murloc",
	minimap = {},
}

local MIN_INTERVAL = 60

------------------------------------------------------------------------

local LSM = _G.LibStub("LibSharedMedia-3.0")
LSM:Register("sound", "Baby Murloc",        [[Sound\creature\BabyMurloc\BabyMurlocC.ogg]])
LSM:Register("sound", "Cat Miao",           [[Sound\creature\Cat\CatStepA.ogg]])
LSM:Register("sound", "Flying Reindeer",    [[Sound\creature\FlyingReindeer\FyingReindeerJump.ogg]])
LSM:Register("sound", "Wolpertinger 2",     [[Sound\creature\Wolpertinger\WolpertingerClickable2.ogg]])
LSM:Register("sound", "Wolpertinger 3",     [[Sound\creature\Wolpertinger\WolpertingerClickable3.ogg]])
LSM:Register("sound", "Wolpertinger 4",     [[Sound\creature\Wolpertinger\WolpertingerClickable4.ogg]])
LSM:Register("sound", "Water Medium",       [[Sound\Effects\DeathImpacts\InWater\mDeathImpactMediumWaterA.ogg]])
LSM:Register("sound", "Water Small",        [[Sound\Effects\DeathImpacts\InWater\mDeathImpactSmallWaterA.ogg]])
LSM:Register("sound", "Map Ping",           [[Sound\INTERFACE\MapPing.ogg]])
LSM:Register("sound", "Magic Click",        [[Sound\INTERFACE\MagicClick.ogg]])
LSM:Register("sound", "Wisp",               [[Sound\Event Sounds\Wisp\WispYes2.ogg]])
LSM:Register("sound", "TMW - Ding 1",       [[Interface\Addons\BugSack\Media\Ding1.ogg]])

------------------------------------------------------------------------

local ICON_GRAY  = "Interface\\AddOns\\Bugger\\Icons\\Bug-Gray"
local ICON_GREEN = "Interface\\AddOns\\Bugger\\Icons\\Bug-Green"
local ICON_RED   = "Interface\\AddOns\\Bugger\\Icons\\Bug-Red"

local c = {
	BLUE   = BATTLENET_FONT_COLOR_CODE,
	GOLD   = NORMAL_FONT_COLOR_CODE,
	GRAY   = "|cff9f9f9f",
	GREEN  = "|cff7fff7f",
	ORANGE = "|cffff9f7f",
	PURPLE = "|cff9f7fff",
}

------------------------------------------------------------------------

Bugger.dataObject = {
	type = "data source",
	icon = ICON_GREEN,
	text = 0,
	label = L["Errors"],
	OnClick = function(self, button)
		if button == "RightButton" then
			-- level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay
			ToggleDropDownMenu(nil, nil, Bugger.menu, self, 0, 0, nil, nil, 10)
		elseif IsShiftKeyDown() then
			ReloadUI()
		elseif IsAltKeyDown() then
			BugGrabber:Reset()
		else
			Bugger:ToggleFrame()
		end
	end,
	OnTooltipShow = function(tt)
		local total = Bugger:GetNumErrors()
		local errorsInTooltip = 8
		Bugger.lastTooltip = tt
		Bugger.lastTooltipOwner = tt:GetOwner()

		tt:AddDoubleLine(BUGGER, total > 0 and total or "", nil, nil, nil, 1, 1, 1)

		if total > 0 then
			tt:AddLine(" ")
			local errors = BugGrabber.GetSessionErrors  and  BugGrabber:GetSessionErrors()  or  BugGrabber:GetDB()
			local from = max(#errors-errorsInTooltip+1, 1)
			for i = #errors, from, -1 do
				tt:AddLine(format("%s%d.|r %s", c.GRAY, total + 1 - i, Bugger:FormatError(errors[i], true)), 1, 1, 1)
			end
			tt:AddLine(" ")
		end

		tt:AddLine(L["Click to open the error window."])
		tt:AddLine(L["Alt-click to clear all saved errors."])
		tt:AddLine(L["Shift-click to reload the UI."])
		tt:AddLine(L["Right-click for options."])
	end,
}

------------------------------------------------------------------------

function Bugger:OnLoad()
	BugGrabber.RegisterCallback(self, "BugGrabber_BugGrabbed")
	-- Register :DisplayError() and :FormatError() callbacks
	if  BugGrabber.DisplayAddons  then  table.insert(BugGrabber.DisplayAddons, self)  end

	LibStub("LibDataBroker-1.1"):NewDataObject(BUGGER, self.dataObject)

	-- Only create a minimap icon if the user doesn't have another Broker display
	local displays = { "Barrel", "Bazooka", "ButtonBin", "ChocolateBar", "DockingStation", "HotCorners", "NinjaPanel", "StatBlockCore", "TitanPanel" }
	local character = UnitName("player")

	local defaultHide = false
	-- MOP
	local GetAddOnEnableState = GetAddOnEnableState  or  function(character, addonName)  local _,_,_,enabled = GetAddOnInfo(addonName) ; return enabled  end
	for i = 1, #displays do
		-- WOD
		if GetAddOnEnableState(character, displays[i]) then  defaultHide = true ; break  end
	end
	
	local LibDBIcon = LibStub("LibDBIcon-1.0")
	LibDBIcon:Register(BUGGER, self.dataObject, self.db.minimap)
	if  self.db.minimap.hide == nil  then
		-- LibDBIcon:Toggle(BUGGER, not defaultHide)
		if  defaultHide  then  LibDBIcon:Show(BUGGER)  else  LibDBIcon:Hide(BUGGER)  end
	end
end

function Bugger:OnLogin()
	if self:GetNumErrors() > 0 then
		return self:BugGrabber_BugGrabbed()
	end
end

------------------------------------------------------------------------

hooksecurefunc(BugGrabber, "Reset", function()
	Bugger:Print(L["All saved errors have been deleted."])

	Bugger.dataObject.icon = ICON_GREEN
	Bugger.dataObject.text = 0
end)

------------------------------------------------------------------------

local function tindexof(arr, item)
	for i = 1,#arr  do  if  arr[i] == item  then  return i  end end
end

function Bugger:GetErrors(session)
	local newApi, errors = true
	if  (not session  or session == 'current') and BugGrabber.GetSessionErrors  then
		errors = BugGrabber:GetSessionErrors()
	elseif  session == 'previous'  and  BugGrabber.GetPreviousErrors  then
		errors = BugGrabber:GetPreviousErrors()
	else
		newApi, errors = session == 'all', BugGrabber:GetDB()
	end
	
	local total = #errors

	if  newApi  then  return errors, 1, total  end
	if  total == 0  then  return errors, 1, 0  end
	-- if  session == "all"  then  return errors, 1, total  end    -- newApi == true

	local sessionId = BugGrabber:GetSessionId()
	local previousCount = total

	for  i = 1,total  do
		if  errors[i].session == sessionId  then  previousCount = i-1 ; break  end
	end

	local currentCount = total - previousCount
	if  session == "previous"  then
		return errors, 1, previousCount
	else
		return errors, previousCount+1, total
	end
end

function Bugger:GetNumErrors(session)
	local errors, first, last = Bugger:GetErrors(session)
	return last - first + 1
end

------------------------------------------------------------------------

--[[
	errorObject = {
		message = sanitizedMessage,
		stack = table.concat(tmp, "\n"),
		locals = debuglocals(4),
		session = BugGrabber:GetSessionId(),
		time = date("%Y/%m/%d %H:%M:%S"),
		counter = 1,
	}
]]

function Bugger:BugGrabber_BugGrabbed(event, errorObject, newErrors)
	self.dataObject.text = self:GetNumErrors()
	self.dataObject.icon = ICON_RED
	
	local tt = Bugger.lastTooltip
	if  tt and tt:GetOwner() == Bugger.lastTooltipOwner and tt:IsShown()  then
		-- Update tooltip if visible.
		tt:Hide()
		self.dataObject.OnTooltipShow(tt)
	else
		Bugger.lastTooltip = nil
	end
	
	local open = self.frame and self.frame:IsShown()
	if  not errorObject  then
		if open then  self:ShowError()  end
		return
	end
	
	local now = time()
	if  MIN_INTERVAL < now - (self.lastError or 0)  then
		self.lastError = now
		if self.db.chat then
			self:Print(L["An error has been captured!"].."  "..BugGrabber:GetChatLink(errorObject))
		end
		if self.db.sound then
			local sound = LibStub("LibSharedMedia-3.0"):Fetch("sound", self.db.soundMedia)
			PlaySoundFile(sound, "Master")
		end
		-- Do not disturb the user if already open.
		if  self.db.autoshow  and  not open  then
			self:DisplayError(errorObject)
		end
	end
end

------------------------------------------------------------------------

do
	local FILE_TEMPLATE   = c.GRAY .. "%1%2\\|r%3:" .. c.GREEN .. "%4|r" .. c.GRAY .. "%5|r%6"
	local STRING_TEMPLATE = c.GRAY .. "%1[loadstring(|r?,\"" .. c.BLUE .. "%2\"|r" .. c.GRAY .. ")]|r:" .. c.GREEN .. "%3|r" .. c.GRAY .. "%4|r%5"
	local NAME_TEMPLATE   = c.BLUE .. "'%1'|r"
	local IN_C = c.GOLD .. "[game engine]|r" .. c.GRAY .. ":|r"

	function Bugger:FormatStack(message, stack)
		message = message and tostring(message)
		if not message then return "" end
		stack = stack and tostring(stack)
		if stack then
			message = message .. "\n" .. stack
		end
		message = gsub(message, "Interface\\", "")
		message = gsub(message, "AddOns\\", "")
		message = gsub(message, "%[C%]", IN_C)
		message = gsub(message, "(<?)(%a+)\\(.-%.[lx][um][al]):(%d+)(>?)(:?)", FILE_TEMPLATE)
		message = gsub(message, "(<?)%[string \"(.-)\"]:(%d+)(>?)(:?)", STRING_TEMPLATE)
		message = gsub(message, "['`]([^`']+)'", NAME_TEMPLATE)
		return message
	end
end

do
	local LOCALS_TEMPLATE = "\n\n" .. c.GOLD .. "Locals:|r%s"
	local FILE_TEMPLATE   = c.GRAY .. "%1\\|r%2:" .. c.GREEN .. "%3|r"
	local GRAY    = c.GRAY .. "%1|r"
	local EQUALS  = c.GRAY .. " = |r"
	local BOOLEAN = EQUALS .. c.PURPLE .. "%1|r"
	local NUMBER  = EQUALS .. c.ORANGE .. "%1|r"
	local STRING  = EQUALS .. c.BLUE .. "\"%1\"|r"
	-- TODO: color other types

	function Bugger:FormatLocals(locals)
		locals = locals and tostring(locals)
		if not locals then return "" end
		locals = "\n" .. locals
		locals = gsub(locals, "> {\n}", ">")
		locals = gsub(locals, "%(%*temporary%)", GRAY)
		locals = gsub(locals, "(<[a-z]+>)", GRAY)
		locals = gsub(locals, " = ([ftn][ari][lu]s?e?)", BOOLEAN)
		locals = gsub(locals, " = ([0-9%.%-]+)", NUMBER)
		locals = gsub(locals, " = \"([^\"]+)\"", STRING)
		locals = gsub(locals, "Interface\\A?d?d?[Oo]?n?s?\\?(%a+)\\(.-%.[lx][um][al]):([0-9]+)", FILE_TEMPLATE)
		return format(LOCALS_TEMPLATE, locals)
	end
end

do
	local FULL_TEMPLATE = "%d" .. c.GRAY .. "x|r %s%s"
	local SHORT_TEMPLATE = "%s " .. c.GRAY .. "(x%d)|r"

	function Bugger:FormatError(err, short)
		if short then
			return format(SHORT_TEMPLATE, self:FormatStack(err.message), err.counter or 1)
		end
		return format(FULL_TEMPLATE, err.counter or 1, self:FormatStack(err.message, err.stack), self:FormatLocals(err.locals))
	end
end

------------------------------------------------------------------------

function Bugger:DisplayError(errorObject)
	local current =  errorObject.session == BugGrabber:GetSessionId()
	local session =  current  and  'current'  or  'previous'
	local errors = self:GetErrors(session)
	local index = tindexof(errors, errorObject)
	self:ShowSession(session, index)
end

------------------------------------------------------------------------

function Bugger:ShowError(index)
	if not self.frame then
		self:SetupFrame()
	end

	-- self.frame:Show()
	ShowUIPanel(self.frame)

	local errors, first, last = self:GetErrors(self.session)
	local total = last - first + 1

	if total == 0 then
		self.error = 0
		self.editBox:SetText(c.GRAY .. L["There are no errors to display."])
		self.editBox:SetCursorPosition(0)
		self.editBox:ClearFocus()
		self.scrollFrame:SetVerticalScroll(0)
		self.title:SetText(LUA_ERROR)
		self.indexLabel:SetText("")
		self.previous:Disable()
		self.next:Disable()
		--[[
		local otherErrors = 0 < #errors
			or  BugGrabber.GetSessionErrors and 0 < #BugGrabber:GetSessionErrors()
			or  BugGrabber.GetPreviousErrors and 0 < #BugGrabber:GetPreviousErrors()
		--]]
		self.clear:SetEnabled(false)
		return
	end

	-- local last = first + total - 1
	-- Show last shown error.
	index = index  or self.error
	local err = index and index >= first and index <= last and errors[index]
	if not err then
		index = last
		err = errors[index]
	end

	self.first, self.last, self.error = first, last, index

	local sdiff = BugGrabber:GetSessionId() - err.session
	if self.session == "all" and sdiff > 0 then
		self.title:SetFormattedText("%s %s(%d)|r", err.time, c.GRAY, sdiff)
	else
		self.title:SetText(err.time)
	end

	self.indexLabel:SetFormattedText("%d / %d", index + 1 - first, total)

	self.editBox:SetText(self:FormatError(err))
	self.editBox:SetCursorPosition(strlen(err.message))
	self.editBox:ClearFocus()

	self.scrollFrame:SetVerticalScroll(0)

	self.previous:SetEnabled(index > first)
	self.next:SetEnabled(index < last)
	self.clear:Enable()
end

------------------------------------------------------------------------

function Bugger:ShowSession(session, index)
	if session ~= "all" and session ~= "previous" then
		session = "current"
	end

	if not self.frame then
		self:SetupFrame()
	end

	for i = 1, #self.tabs do
		local tab = self.tabs[i]
		if tab.session == session then
			PanelTemplates_SelectTab(tab)
		else
			PanelTemplates_DeselectTab(tab)
		end
	end

	-- Show last if changing session.
	if self.session ~= session then  index = index or -1  end
	self.session = session
	self:ShowError(index)
end

------------------------------------------------------------------------

function Bugger:ToggleFrame()
	if self.frame and self.frame:IsShown() then
		-- self.frame:Hide()
		HideUIPanel(self.frame)
	else
		self:ShowSession()
	end
end

------------------------------------------------------------------------

function Bugger:SetupFrame()
	if not IsAddOnLoaded("Blizzard_DebugTools") then
		LoadAddOn("Blizzard_DebugTools")
	end

	ScriptErrorsFrame_OnError = function() end
	ScriptErrorsFrame_Update  = function() end
	UIPanelWindows.ScriptErrorsFrame = { area = "right", pushable = 1, whileDead = 1, allowOtherPanels = 1 }
	-- Note: builtin CloseSpecialWindows()  :Hide()s frames in UISpecialFrames.
	-- CloseAllWindows() bugs if a UIPanelWindow is not hidden with HideUIPanel().
	-- Result: Game Menu is not showing when you press ESC.
	-- UISpecialFrames[#UISpecialFrames+1] = "ScriptErrorsFrame"    -- Later loaded from Blizzard_DebugTools

	self.frame       = ScriptErrorsFrame
	self.scrollFrame = ScriptErrorsFrameScrollFrame
	self.editBox     = ScriptErrorsFrameScrollFrameText
	self.title       = self.frame.title
	self.options     = CreateFrame("Button", nil, self.frame)
	self.indexLabel  = self.frame.indexLabel
	self.previous    = self.frame.previous
	self.next        = self.frame.next
	self.clear       = self.frame.close

	self.frame:SetParent(UIParent)
	self.frame:SetScript("OnShow", nil)
	self.frame:EnableMouse(true)

	self.editBox:SetFontObject(GameFontHighlight)
	self.editBox:SetTextColor(0.9, 0.9, 0.9)

	local addWidth = 200
	self.frame:SetWidth(self.frame:GetWidth() + addWidth)
	self.scrollFrame:SetWidth(self.scrollFrame:GetWidth() + addWidth - 4)
	self.editBox:SetWidth(self.editBox:GetWidth() + addWidth)
	-- self.editBox:SetAllPoints()

	local addHeight = 150
	self.frame:SetHeight(self.frame:GetHeight() + addHeight)
	self.scrollFrame:SetHeight(self.scrollFrame:GetHeight() + addHeight - 4)

	self.scrollFrame:SetPoint("TOPLEFT", 16, -32)
	self.scrollFrame.ScrollBar:SetPoint("TOPLEFT", self.scrollFrame, "TOPRIGHT", 6, -13)

	self.options:SetPoint("TOPRIGHT", -32, -8)
	self.options:SetText("X")
	self.options:SetSize(16, 16)
	self.options:SetScript("OnClick", function()
		-- level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay
		ToggleDropDownMenu(nil, nil, Bugger.menu, self, 0, 0, nil, nil, 10)
	end)
--[[
/dump Bugger.frame:GetRect()
/dump Bugger.editBox:GetRect()
/dump Bugger.scrollFrame:GetRect()
/run Bugger.editBox:SetAllPoints()
/run Bugger.scrollFrame:SetAllPoints()
/run Bugger.scrollFrame:SetPoint("BOTTOMRIGHT", -8, -8)
[08:57:24] Dump: value=Bugger.frame:GetRect()
[08:57:24] [1]=664.79998082526,
[08:57:24] [2]=172.00000196808,
[08:57:24] [3]=384.00002699084,
[08:57:24] [4]=260.00000590425
[08:57:40] Dump: value=Bugger.editBox:GetRect()
[08:57:40] [1]=676.79996255022,
[08:57:40] [2]=258.64002764874,
[08:57:40] [3]=343.00004744483,
[08:57:40] [4]=143.35999892037
[08:57:43] Dump: value=Bugger.scrollFrame:GetRect()
[08:57:43] [1]=676.79996255022,
[08:57:43] [2]=208.00001911851,
[08:57:43] [3]=343.00004744483,
[08:57:43] [4]=193.99998045976
--]]
	self.clear:ClearAllPoints()
	self.clear:SetPoint("BOTTOMLEFT", 12, 12)
	self.clear:SetText(CLEAR_ALL)
	self.clear:SetWidth(self.clear:GetFontString():GetStringWidth() + 20)
	self.clear:SetScript("OnClick", function()
		BugGrabber:Reset(Bugger.session)
		self:ShowError()
	end)

	self.next:ClearAllPoints()
	self.next:SetPoint("BOTTOMRIGHT", -10, 12)

	self.previous:ClearAllPoints()
	self.previous:SetPoint("RIGHT", self.next, "LEFT", -4, 0)

	self.indexLabel:ClearAllPoints()
	self.indexLabel:SetPoint("LEFT", self.clear, "RIGHT", 4, 0)
	self.indexLabel:SetPoint("RIGHT", self.previous, "LEFT", -4, 0)
	self.indexLabel:SetJustifyH("CENTER")

	self.error = 0
	self.session = "current"

	self.previous:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			self:ShowError(self.first)
		else
			self:ShowError(self.error - 1)
		end
	end)

	self.next:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			self:ShowError(self.last)
		else
			self:ShowError(self.error + 1)
		end
	end)

	local tabLevel = self.frame:GetFrameLevel()
	local tabWidth = (self.frame:GetWidth() - 16) / 3
	local function clickTab(tab)
		Bugger:ShowSession(tab.session)
	end
	self.tabs = {}
	self.frame:SetFrameLevel(tabLevel + 1)
	for i = 1, 3 do
		local tab = CreateFrame("Button", "$parentTab"..i, self.frame, "CharacterFrameTabButtonTemplate")
		tab:UnregisterAllEvents()
		tab:SetScript("OnEvent", nil)
		tab:SetScript("OnClick", clickTab)
		tab:SetScript("OnShow",  nil)
		tab:SetScript("OnEnter", nil)
		tab:SetScript("OnLeave", nil)
		tab:SetFrameLevel(tabLevel)
		PanelTemplates_TabResize(tab, 0, tabWidth) --, tabWidth, tabWidth)
		self.tabs[i] = tab
	end

	self.tabs[1].session = "current"
	self.tabs[1]:SetText(L["Current Session"])
	self.tabs[1]:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT", 8, 7)

	self.tabs[2].session = "previous"
	self.tabs[2]:SetText(L["Previous Sessions"])
	self.tabs[2]:SetPoint("TOPLEFT", self.tabs[1], "TOPRIGHT")

	self.tabs[3].session = "all"
	self.tabs[3]:SetText(L["All Errors"])
	self.tabs[3]:SetPoint("TOPLEFT", self.tabs[2], "TOPRIGHT")

	-- TODO: add button for opening options
	-- maybe a little gear by the close button at the top
end

------------------------------------------------------------------------

SLASH_BUGGER1 = "/bugger"
SLASH_BUGGER2 = L["/bugger"]

SlashCmdList["BUGGER"] = function(cmd)
	cmd = strlower(strtrim(cmd or ""))
	if cmd == "reset" then
		BugGrabber:Reset()
	else
		Bugger:ToggleFrame()
	end
end

------------------------------------------------------------------------

local menu = CreateFrame("Frame", "BuggerMenu", UIParent, "UIDropDownMenuTemplate")
menu.displayMode = "MENU"

menu.chatFunc = function(self, arg1, arg2, checked)
	Bugger.db.chat = checked
end

menu.soundFunc = function(self, arg1, arg2, checked)
	Bugger.db.sound = checked
end

menu.autoshowFunc = function(self, arg1, arg2, checked)
	Bugger.db.autoshow = checked
end

menu.iconFunc = function(self, arg1, arg2, checked)
	Bugger.db.minimap.hide = not checked
	LibStub("LibDBIcon-1.0"):Refresh(BUGGER, Bugger.db.minimap)
end

menu.closeFunc = function()
	CloseDropDownMenus()
end

menu.initialize = function(_, level)
	if not level then return end

	local info = UIDropDownMenu_CreateInfo()
	info.text = BUGGER
	info.isTitle = 1
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info, level)

	info = UIDropDownMenu_CreateInfo()
	info.text = L["Auto-popup frame"]
	info.func = menu.autoshowFunc
	info.checked = Bugger.db.autoshow
	info.keepShownOnClick = 1
	UIDropDownMenu_AddButton(info, level)

	info = UIDropDownMenu_CreateInfo()
	info.text = L["Chat frame alerts"]
	info.func = menu.chatFunc
	info.checked = Bugger.db.chat
	info.keepShownOnClick = 1
	UIDropDownMenu_AddButton(info, level)

	info = UIDropDownMenu_CreateInfo()
	info.text = L["Sound alerts"]
	info.func = menu.soundFunc
	info.checked = Bugger.db.sound
	info.keepShownOnClick = 1
	UIDropDownMenu_AddButton(info, level)

	if LibStub("LibDBIcon-1.0"):IsRegistered(BUGGER) then
		info = UIDropDownMenu_CreateInfo()
		info.text = L["Minimap icon"]
		info.func = menu.iconFunc
		info.checked = not Bugger.db.minimap.hide
		info.keepShownOnClick = 1
		UIDropDownMenu_AddButton(info, level)
	end

	info = UIDropDownMenu_CreateInfo()
	info.text = CLOSE
	info.func = menu.closeFunc
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info, level)
end

Bugger.menu = menu