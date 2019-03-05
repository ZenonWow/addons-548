local ADDON_NAME, addon = ...
local _G, L = _G, addon.L
if  not _G.BugGrabber  then  return  end

-- What activeTab is the sack in?
local activeTab = "BugSackTabSession"
local searchResults = nil
local searchThrough = nil

-- Frame activeTab variables
local currentSackContents = nil -- List of all the errors currently navigated in the sack
local currentErrorObject = nil -- Current errorObject shown. Normative.
local currentErrorIndex = nil -- Index of currentErrorObject in the currentSackContents, or nil if window.UpdateErrors() needs to be run.
local currentBeforeSearch = nil -- Restore selected if Esc is pressed in search.

local countLabel, sessionLabel, textArea = nil, nil, nil
local nextButton, prevButton, sendButton = nil, nil, nil
local searchLabel, searchBox = nil, nil

local sessionFormat = "%s - |cffff4411%s|r - |cff44ff44%d|r" -- <date> - <sent by> - <session id>
local countFormat = "%d/%d" -- 1/10
local sourceFormat = L["Sent by %s (%s)"]
local localFormat = L["Local (%s)"]

local function tindexof(arr, item)
	for i = 1,#arr  do  if  arr[i] == item  then  return i  end end
end

-- Updates the total bug count and so forth.
-- local lastState = nil

local window = CreateFrame("Frame", "BugSackFrame", UIParent)
BugSack.window = window
window:Hide()
-- area = "center" closes UIGameMenu on auto-popup. A problem, if you want to get to interace options to disable auto-popup.
-- UIPanelWindows.BugSackFrame = { area = "center", pushable = 1, whileDead = 1, allowOtherPanels = 1 }
UIPanelWindows.BugSackFrame = { area = "right", pushable = 1, whileDead = 1, allowOtherPanels = 1 }
-- Fix that bliz buzz too.
UIPanelWindows.ScriptErrorsFrame = { area = "right", pushable = 1, whileDead = 1, allowOtherPanels = 1 }
-- Or disable auto-layout altogether, but still close when pressing Esc.
-- UISpecialFrames[#UISpecialFrames+1] = 'ScriptErrorsFrame'    -- Builtin annoyance is persistent even after Esc
-- UISpecialFrames[#UISpecialFrames+1] = window:GetName()


function window:UpdateErrors(selectExistingError)
	-- Delay update until next ShowUIPanel(window)
	if  not self:IsShown()  then  return false  end

	-- if activeTab ~= lastState then selectLast = true end
	-- lastState = activeTab

	local sId = BugGrabber:GetSessionId()
	if  searchResults  then
		currentSackContents = searchResults
	elseif activeTab == "BugSackTabAll" then
		currentSackContents = addon:GetAllErrors()
	elseif activeTab == "BugSackTabSession" then
		currentSackContents = addon:GetSessionErrors()
	elseif activeTab == "BugSackTabLast" then
		currentSackContents = addon:GetPreviousErrors()
	end
	
	self:UpdateSelected(selectExistingError)
end

function window:UpdateSelected(selectExistingError)
	-- currentSackContents is nil when window is hidden
	if  not currentSackContents  then  return false  end

	-- Find the currentErrorIndex index in the new error list.
	local size = #currentSackContents
	local eo = currentErrorObject
	currentErrorIndex = currentErrorObject  and  tindexof(currentSackContents, currentErrorObject)
	if  not currentErrorIndex  then
		currentErrorIndex = size
		if  selectExistingError  then
			currentErrorObject = currentSackContents[currentErrorIndex]
			eo = currentErrorObject
		end
	end

	if  eo  then
		currentErrorObject = eo
		local source = nil
		if eo.source then source = sourceFormat:format(eo.source, "error")
		else source = localFormat:format("error") end

		if eo.session == BugGrabber:GetSessionId() then
			sessionLabel:SetText(sessionFormat:format(L["Today"], source, eo.session))
		else
			sessionLabel:SetText(sessionFormat:format(eo.time, source, eo.session))
		end

		countLabel:SetText(countFormat:format(currentErrorIndex, size))
		textArea:SetText(addon:FormatError(eo))

		if currentErrorIndex >= size then
			nextButton:Disable()
		else
			nextButton:Enable()
		end
		if currentErrorIndex <= 1 then
			prevButton:Disable()
		else
			prevButton:Enable()
		end
		if sendButton then sendButton:Enable() end
	else
		countLabel:SetText()
		if  searchResults  then
			sessionLabel:SetText("")
			textArea:SetText(L["No bugs match your search."])
		elseif  activeTab == "BugSackTabSession"  then
			sessionLabel:SetText(("%s (%d)"):format(L["Today"], BugGrabber:GetSessionId()))
			textArea:SetText(L["You have no bugs, yay!"])
		elseif  activeTab == "BugSackTabLast"  then
			sessionLabel:SetText("Previous sessions")
			textArea:SetText(L["No bugs from previous sessions."])
		elseif  activeTab == "BugSackTabAll"  then
			sessionLabel:SetText("All bugs")
			textArea:SetText(L["You have no bugs, yay!"])
		end
		nextButton:Disable()
		prevButton:Disable()
		if sendButton then sendButton:Disable() end
	end

end     -- window:UpdateSelected()


-- Only invoked when actually clicking a tab
local function SetActiveTab(tab)
	searchLabel:Hide()
	searchBox:Hide()
	sessionLabel:Show()

	searchResults = nil
	searchThrough = nil

	activeTab =  type(tab) == "table"  and  tab:GetName()  or  tab

	for  i,t  in ipairs(window.tabs) do
		if activeTab == t:GetName() then  PanelTemplates_SelectTab(t)
		else  PanelTemplates_DeselectTab(t)
		end
	end

	window:UpdateErrors(true)
	-- window:UpdateErrors()
end



local function ClearSearch(restoreCurrent)
	if  restoreCurrent  then  currentErrorObject = currentBeforeSearch  end
	searchResults = nil
	searchThrough = nil
	currentBeforeSearch = nil
	
	-- SetActiveTab("BugSackTabSession")
	window:UpdateErrors()
end

local function FilterSack(editbox)
	local text = editbox:GetText()
	-- If there's no text in the box, we reset to all bugs so the search can start over
	if not searchThrough or not text or text:trim():len() == 0 then
		-- activeTab = "BugSackTabAll"
		searchResults = nil
	else
		if  not currentBeforeSearch  then  currentBeforeSearch = currentErrorObject  end
		local res = {}
		for  i,err  in ipairs(searchThrough) do
			if err.message and err.message:find(text) then
				res[#res+1] = err
			elseif err.stack and err.stack:find(text) then
				res[#res+1] = err
			elseif err.locals and err.locals:find(text) then
				res[#res+1] = err
			end
		end
		searchResults = res
	end
	
	-- activeTab = "BugSackSearch"
	window:UpdateErrors(true)
	-- window:UpdateErrors()
end



function window:Init()
	local window = self
	-- Run only once
	window.Init = nil
	window:SetScript('OnShow', window.OnShow)
	window:SetScript('OnHide', window.OnHide)

	-- HideUIPanel(window)
	window:SetFrameStrata("HIGH")
	-- window:SetFrameStrata("FULLSCREEN_DIALOG")
	-- window:SetWidth(500)
	-- window:SetHeight(500 / 1.618)
	window:SetWidth(600)
	window:SetHeight(400)
	window:SetPoint("CENTER")
	window:SetMovable(true)
	window:EnableMouse(true)
	window:RegisterForDrag("LeftButton")
	window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", window.StopMovingOrSizing)

	local titlebg = window:CreateTexture(nil, "BORDER")
	titlebg:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Title-Background")
	titlebg:SetPoint("TOPLEFT", 9, -6)
	titlebg:SetPoint("BOTTOMRIGHT", window, "TOPRIGHT", -28, -24)

	local dialogbg = window:CreateTexture(nil, "BACKGROUND")
	dialogbg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-CharacterTab-L1")
	dialogbg:SetPoint("TOPLEFT", 8, -12)
	dialogbg:SetPoint("BOTTOMRIGHT", -6, 8)
	dialogbg:SetTexCoord(0.255, 1, 0.29, 1)

----[[
	local topleft = window:CreateTexture(nil, "BORDER")
	topleft:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	topleft:SetWidth(64)
	topleft:SetHeight(64)
	topleft:SetPoint("TOPLEFT")
	topleft:SetTexCoord(0.501953125, 0.625, 0, 1)

	local topright = window:CreateTexture(nil, "BORDER")
	topright:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	topright:SetWidth(64)
	topright:SetHeight(64)
	topright:SetPoint("TOPRIGHT")
	topright:SetTexCoord(0.625, 0.75, 0, 1)

	local top = window:CreateTexture(nil, "BORDER")
	top:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	top:SetHeight(64)
	top:SetPoint("TOPLEFT", topleft, "TOPRIGHT")
	top:SetPoint("TOPRIGHT", topright, "TOPLEFT")
	top:SetTexCoord(0.25, 0.369140625, 0, 1)

	local bottomleft = window:CreateTexture(nil, "BORDER")
	bottomleft:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	bottomleft:SetWidth(64)
	bottomleft:SetHeight(64)
	bottomleft:SetPoint("BOTTOMLEFT")
	bottomleft:SetTexCoord(0.751953125, 0.875, 0, 1)

	local bottomright = window:CreateTexture(nil, "BORDER")
	bottomright:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	bottomright:SetWidth(64)
	bottomright:SetHeight(64)
	bottomright:SetPoint("BOTTOMRIGHT")
	bottomright:SetTexCoord(0.875, 1, 0, 1)

	local bottom = window:CreateTexture(nil, "BORDER")
	bottom:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	bottom:SetHeight(64)
	bottom:SetPoint("BOTTOMLEFT", bottomleft, "BOTTOMRIGHT")
	bottom:SetPoint("BOTTOMRIGHT", bottomright, "BOTTOMLEFT")
	bottom:SetTexCoord(0.376953125, 0.498046875, 0, 1)

	local left = window:CreateTexture(nil, "BORDER")
	left:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	left:SetWidth(64)
	left:SetPoint("TOPLEFT", topleft, "BOTTOMLEFT")
	left:SetPoint("BOTTOMLEFT", bottomleft, "TOPLEFT")
	left:SetTexCoord(0.001953125, 0.125, 0, 1)

	local right = window:CreateTexture(nil, "BORDER")
	right:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Border")
	right:SetWidth(64)
	right:SetPoint("TOPRIGHT", topright, "BOTTOMRIGHT")
	right:SetPoint("BOTTOMRIGHT", bottomright, "TOPRIGHT")
	right:SetTexCoord(0.1171875, 0.2421875, 0, 1)
--]]

	local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 2, 1)
	close:SetScript("OnClick", function()  HideUIPanel(window)  end)

	countLabel = window:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	countLabel:SetPoint("TOPRIGHT", titlebg, -6, -3)
	countLabel:SetJustifyH("RIGHT")
	countLabel:SetTextColor(1, 1, 1, 1)

	sessionLabel = CreateFrame("Button", nil, window)
	sessionLabel:SetNormalFontObject("GameFontNormalLeft")
	sessionLabel:SetHighlightFontObject("GameFontHighlightLeft")
	sessionLabel:SetPoint("TOPLEFT", titlebg, 6, -4)
	sessionLabel:SetPoint("BOTTOMRIGHT", countLabel, "BOTTOMLEFT", -4, 1)
	sessionLabel:SetScript("OnHide", function()
		window:StopMovingOrSizing()
	end)
	sessionLabel:SetScript("OnMouseUp", function(self, mouseButton)
		window:StopMovingOrSizing()
		if  mouseButton == "RightButton"  then
			if  IsAltKeyDown()  then  addon:Reset()
			else
				InterfaceOptionsFrame_OpenToCategory(ADDON_NAME)
				InterfaceOptionsFrame_OpenToCategory(ADDON_NAME)
			end
		end
	end)
	sessionLabel:SetScript("OnMouseDown", function()
		window:StartMoving()
	end)
	sessionLabel:SetScript("OnDoubleClick", function()
		sessionLabel:Hide()
		searchLabel:Show()
		searchBox:Show()
		searchThrough = currentSackContents
	end)
	local quickTips = 
[[|cff44ff44Double-click|r to filter bug reports. After you are done with the search results, return to the full sack by selecting a tab at the bottom.
|cff44ff44Left-click|r and drag to move the window.
|cff44ff44Right-click|r to open the interface options for BugSack.
|cff44ff44Alt+Right-click|r to delete all bugs.]]
	sessionLabel:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", -8, 8)
		GameTooltip:AddLine("Quick tips")
		GameTooltip:AddLine(quickTips, 1, 1, 1, 1)
		GameTooltip:Show()
	end)
	sessionLabel:SetScript("OnLeave", function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end)

	searchLabel = window:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	searchLabel:SetText("Filter:")
	searchLabel:SetJustifyH("LEFT")
	searchLabel:SetPoint("TOPLEFT", titlebg, 6, -3)
	searchLabel:SetTextColor(1, 1, 1, 1)
	searchLabel:Hide()

	searchBox = CreateFrame("EditBox", nil, window)
	searchBox:SetTextInsets(4, 4, 0, 0)
	searchBox:SetMaxLetters(50)
	searchBox:SetFontObject("ChatFontNormal")
	searchBox:SetBackdrop({
		edgeFile = nil,
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		insets = { left = 0, right = 0, top = 0, bottom = 0 },
		tile = true,
		tileSize = 16,
		edgeSize = 0,
	})
	searchBox:SetBackdropColor(0, 0, 0, 0.5)
	searchBox:SetScript("OnShow", function(self)
		self:SetFocus()
	end)
	searchBox:SetScript("OnHide", function(self)
		self:ClearFocus()
		self:SetText("")
	end)
	searchBox:SetScript("OnEscapePressed", function()  ClearSearch(true)  end)
	searchBox:SetScript("OnEnterPressed", ClearSearch)
	searchBox:SetScript("OnTextChanged", FilterSack)
	searchBox:SetAutoFocus(false)
	searchBox:SetPoint("TOPLEFT", searchLabel, "TOPRIGHT", 6, 1)
	searchBox:SetPoint("BOTTOMRIGHT", countLabel, "BOTTOMLEFT", -3, -1)
	searchBox:Hide()

	nextButton = CreateFrame("Button", "BugSackNextButton", window, "UIPanelButtonTemplate")
	nextButton:SetPoint("BOTTOMRIGHT", window, -11, 16)
	nextButton:SetWidth(130)
	nextButton:SetText(L["Next >"])
	nextButton:SetScript("OnClick", function()
		if  IsShiftKeyDown()  then  currentErrorIndex = #currentSackContents
		elseif  not currentErrorIndex  then  currentErrorIndex = 1
		elseif  currentErrorIndex < #currentSackContents  then  currentErrorIndex = currentErrorIndex + 1
		end
		window:SelectError(currentSackContents[currentErrorIndex])
	end)

	prevButton = CreateFrame("Button", "BugSackPrevButton", window, "UIPanelButtonTemplate")
	prevButton:SetPoint("BOTTOMLEFT", window, 14, 16)
	prevButton:SetWidth(130)
	prevButton:SetText(L["< Previous"])
	prevButton:SetScript("OnClick", function()
		if  IsShiftKeyDown()  then  currentErrorIndex = 1
		elseif  not currentErrorIndex  then  currentErrorIndex = #currentSackContents
		elseif  1 < currentErrorIndex  then  currentErrorIndex = currentErrorIndex - 1
		end
		window:SelectError(currentSackContents[currentErrorIndex])
	end)

	if addon.Serialize then
		sendButton = CreateFrame("Button", "BugSackSendButton", window, "UIPanelButtonTemplate")
		sendButton:SetPoint("LEFT", prevButton, "RIGHT")
		sendButton:SetPoint("RIGHT", nextButton, "LEFT")
		sendButton:SetText(L["Send bugs"])
		sendButton:SetScript("OnClick", function()
			local eo = currentSackContents[currentErrorIndex]
			local popup = StaticPopup_Show("BugSackSendBugs", eo.session)
			popup.data = eo.session
			HideUIPanel(window)
		end)
	end

	local scroll = CreateFrame("ScrollFrame", "BugSackScroll", window, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", window, "TOPLEFT", 16, -36)
	scroll:SetPoint("BOTTOMRIGHT", nextButton, "TOPRIGHT", -24, 8)

	textArea = CreateFrame("EditBox", "BugSackScrollText", scroll)
	textArea:SetTextColor(.5, .5, .5, 1)
	textArea:SetAutoFocus(false)
	textArea:SetMultiLine(true)
	textArea:SetFontObject(_G[addon.db.fontSize] or GameFontHighlightSmall)
	--textArea:SetMaxLetters(99999)
	textArea:EnableMouse(true)
	textArea:SetScript("OnEscapePressed", textArea.ClearFocus)
	-- XXX why the fuck doesn't SetPoint work on the editbox?
	--textArea:SetWidth(450)
	--textArea:SetWidth(550)
	textArea:SetWidth(scroll:GetWidth())
	textArea:SetAllPoints()
	scroll:SetScrollChild(textArea)

	local tabs = {}
	window.tabs = tabs
	local session = CreateFrame("Button", "BugSackTabSession", window, "CharacterFrameTabButtonTemplate")
	-- session:SetFrameStrata("FULLSCREEN")
	session:SetPoint("TOPLEFT", window, "BOTTOMLEFT", 0, 8)
	session:SetText(L["Current session"])
	session:SetScript("OnLoad", nil)
	session:SetScript("OnShow", nil)
	session:SetScript("OnClick", SetActiveTab)
	session.bugs = "currentSession"
	tabs[#tabs+1] = session

	local last = CreateFrame("Button", "BugSackTabLast", window, "CharacterFrameTabButtonTemplate")
	-- last:SetFrameStrata("FULLSCREEN")
	last:SetPoint("LEFT", tabs[#tabs], "RIGHT")
	last:SetText(L["Previous sessions"])
	last:SetScript("OnLoad", nil)
	last:SetScript("OnShow", nil)
	last:SetScript("OnClick", SetActiveTab)
	last.bugs = "previousSession"
	tabs[#tabs+1] = last

	local all = CreateFrame("Button", "BugSackTabAll", window, "CharacterFrameTabButtonTemplate")
	-- all:SetFrameStrata("FULLSCREEN")
	all:SetPoint("LEFT", tabs[#tabs], "RIGHT")
	all:SetText(L["All bugs"])
	all:SetScript("OnLoad", nil)
	all:SetScript("OnShow", nil)
	all:SetScript("OnClick", SetActiveTab)
	all.bugs = "all"
	tabs[#tabs+1] = all

	local size = window:GetWidth() / 3
	for  i, t  in ipairs(tabs) do  PanelTemplates_TabResize(t, nil, size, size)  end
	SetActiveTab(activeTab)

	-- Call real OnShow handler.
	window:OnShow()
end
-- END window:Init()



function window:OnShow()
	-- PlaySound("igQuestLogOpen")
	self:UpdateErrors()
end

function window:OnHide()
	--PlaySound("igQuestLogClose")
	ClearSearch()
	currentSackContents = nil
	currentErrorObject  = nil
	currentErrorIndex   = nil
	currentBeforeSearch = nil
end

-- Init() runs once when BugSackFrame is first opened. Replaces itself with window:OnShow().
window:SetScript('OnShow', window.Init)



window.Toggle = _G.ToggleFrame


function window:SelectError(errorObject)
	if  not errorObject  then  return false  end
	currentErrorObject = errorObject
	
	local sId, sessionId = errorObject.session, BugGrabber:GetSessionId()
	local errorOnTab =  sId == sessionId  and  "BugSackTabSession"
		or  sId == sessionId - 1  and  "BugSackTabLast"
		or  "BugSackTabAll"
	if  activeTab ~= errorOnTab  and  activeTab ~= "BugSackTabAll"  then
		SetActiveTab(errorOnTab)
	elseif  searchResults  and  not tindexof(searchResults, errorObject)  then
		ClearSearch()
	else
		self:UpdateSelected()
	end
end



