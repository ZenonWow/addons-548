--[[ Container ]]

--[[ structure:
	container = {
		FrameList = {
			ButtonList[row][col]
		}
		tabs = {
		}
	}
]]

TEB_Container = {}

local hiContainerId = 0
local currTab = {} -- conatiner, contID, currFrame, tabID
local SubmenuDummyFrame = CreateFrame("Frame", "TinyExtraBars_DropDownMenu_Dummy", UIParent, "Lib_UIDropDownMenuTemplate")

function TinyExtraBarsTabButton_OnClick(self)
	if InCombatLockdown() then
		return
	end

	Lib_CloseDropDownMenus(1)
	local tabID = self:GetID()
	local frame = self:GetParent()
	Lib_PanelTemplates_SetTab(frame, tabID)
	self.container.activeTab = tabID
	
	--now fix font anchors for tabs after PanelTemplates_SetTab
	local tab, name
	for i = 1, frame.numTabs do
		tab = _G[frame:GetName().."Tab"..i]
		if not(tab.isDisabled) then
			if i == frame.selectedTab then
				--do opposite to PanelTemplates_SelectTab(tab)
				name = tab:GetName()
				_G[name.."Text"]:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2))
			else
				--do opposite to PanelTemplates_DeselectTab(tab)
				name = tab:GetName()
				_G[name.."Text"]:SetPoint("CENTER", tab, "CENTER", (tab.selectedTextX or 0), (tab.selectedTextY or -3))
			end
		end
	end 	
	
	for k, v in pairs(self.container.FrameList) do
		if tabID ~= k then
			self.container.FrameList[k]:Hide()
		end
	end
	self.container.FrameList[tabID]:Show()
end

local function SetTabsAnchors(container)
	local relativeto = container
	local point = 'BOTTOMLEFT'
	for k, v in ipairs(container.tabs) do
		v:ClearAllPoints()
		if k == 1 then
			v:SetPoint(point, relativeto, "TOPLEFT", 0, -4)
		else
			v:SetPoint(point, relativeto, "RIGHT", -16, 0)
		end
		point = "LEFT"
		relativeto = v
	end		
end

local function NewTab(id, container)
	local tab = _G[container:GetName()..'Tab'..id]
	if not(tab) then
		tab = CreateFrame('Button', container:GetName()..'Tab'..id, container, 'TinyExtraBarsTabButtonTemplate')
		tab.texLeftDisabled 	= _G[tab:GetName().."LeftDisabled"]
		tab.texMiddleDisabled 	= _G[tab:GetName().."MiddleDisabled"]
		tab.texRightDisabled 	= _G[tab:GetName().."RightDisabled"]
		tab.texLeft 	= _G[tab:GetName().."Left"]
		tab.texMiddle 	= _G[tab:GetName().."Middle"]
		tab.texRight 	= _G[tab:GetName().."Right"]
		tab.texHighlightTexture = _G[tab:GetName().."HighlightTexture"]
		
		local texActiveFName = "Interface\\AddOns\\TinyExtraBars\\textures\\ui-character-activetab-r"
		local texInactiveFName = "Interface\\AddOns\\TinyExtraBars\\textures\\ui-character-inactivetab-r"
		tab.texLeftDisabled:SetTexture(texActiveFName)
		tab.texLeftDisabled:SetTexCoord(0, 0.15625, 0.453125, 1.0)
		tab.texMiddleDisabled:SetTexture(texActiveFName)
		tab.texMiddleDisabled:SetTexCoord(0.15625, 0.84375, 0.453125, 1.0)
		tab.texRightDisabled:SetTexture(texActiveFName)
		tab.texRightDisabled:SetTexCoord(0.84375, 1.0, 0.453125, 1.0)
		tab.texLeft:SetTexture(texInactiveFName)
		tab.texLeft:SetTexCoord(0, 0.15625, 0, 1.0)
		tab.texMiddle:SetTexture(texInactiveFName)
		tab.texMiddle:SetTexCoord(0.15625, 0.84375, 0, 1.0)
		tab.texRight:SetTexture(texInactiveFName)
		tab.texRight:SetTexCoord(0.84375, 1.0, 0, 1.0)
		
		tab.texHighlightTexture:ClearAllPoints()
		tab.texHighlightTexture:SetPoint("TOPLEFT", 3, -5)
		tab.texHighlightTexture:SetPoint("BOTTOMRIGHT", -3, -7)
	end
	tab:SetID(id)
	tab.container = container
	tab:SetText(container.FrameList[id].title)
	
	return tab
end

local function NewTabFrame(id, container, rows, cols)
	local f = TEB_ButtonFrame_New(id, container)
	f:SetAnchor(container)
	--f:SetFrameLevel(container:GetFrameLevel() + 1)
	f:SetButtons(rows, cols)
	f:SetButtonsCount(rows, cols)
	f:Show()
	
	return f
end

function TEB_Container_New(id, left, top, rows, cols)
	if InCombatLockdown() then
		return
	end

	local isNew
	if not(id) then
		isNew = true
		hiContainerId = hiContainerId + 1
		id = hiContainerId
	else
		hiContainerId = id
	end
	
	local container = _G['TinyExtraBarsContainerFrame'..id]
	if not(container) then
		container = CreateFrame('Frame', 'TinyExtraBarsContainerFrame'..id, UIParent, 'TinyExtraBarsContainerFrameTemplate')
	end
	if isNew then
		TinyExtraBars_RegisterContainer(id, container)
	end
	container.activeTab = 1
	container.maxRows = rows
	container.maxCols = cols
	container.rows = rows
	container.cols = cols
	container:SetID(id)
	container:ClearAllPoints()
	container:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
	-- adding methods to frame
	for k, v in pairs(TEB_Container) do
		if type(v) == "function" then
			container[k] = v
		end
	end
	
	-- settings
	container.showtooltip = TinyExtraBarsPC:Get({'Containers', id, "Show tooltip"}, true)
	container:SetSize(rows, cols)
	if isNew then
		TinyExtraBarsPC:Set({'Containers', id, 'pos', 'left'}, left)
		TinyExtraBarsPC:Set({'Containers', id, 'pos', 'top'}, top)
		TinyExtraBarsPC:Set({'Containers', id, 'tabs', 1}, {["title"] = "Tab1"})
		TinyExtraBarsPC:Set({'Containers', id, 'cols'}, cols)
		TinyExtraBarsPC:Set({'Containers', id, 'rows'}, rows)
		container:Show()
	end
	
	-- strata
	container.strata = TinyExtraBarsPC:Get({'Containers', id, 'strata'}, "LOW")
	container:SetFrameStrata(container.strata)
	
	-- alpha
	container.alpha = TinyExtraBarsPC:Get({'Containers', id, 'alpha'}, 1.0)
	-- clickthrough
	container.clickthrough = TinyExtraBarsPC:Get({'Containers', id, 'Click through'}, false)

	container.tabs = {}
	container.FrameList = {}
	
	local tabs = TinyExtraBarsPC:Get({'Containers', id, 'tabs'}, nil)
	if tabs then
		for k, v in ipairs(tabs) do
			container.FrameList[k] = NewTabFrame(k, container, rows, cols)
			container.FrameList[k]:SetFrameStrata(container.strata)
			container.tabs[k] = NewTab(k, container)
			container.tabs[k]:Show()
		end
		SetTabsAnchors(container)
		Lib_PanelTemplates_SetNumTabs(container, #tabs)	-- frames total
		Lib_PanelTemplates_SetTab(container, container.activeTab)
		TinyExtraBarsTabButton_OnClick(container.tabs[container.activeTab])
	end
	
	container:SetScript("OnSizeChanged", TEB_Container.OnResize)
	
	RegisterStateDriver(container, "visibility", "[combat] hide; [vehicleui] hide")
	
	-- set default keybinds
	container:SetDefaultKeybindText()
	
	-- set stored keybinds
	local keybinds = TinyExtraBarsPC:Get({'Containers', id, 'keibinds'}, nil)
	if keybinds then
		for row, v in pairs(keybinds) do
			if v then
				for col, key in pairs(v) do
					if key then
						container:SetKeybind(key, row, col)
					end
				end
			end
		end
	end
	
	return container
end

function TEB_Container:SetSize(rows, cols)
	local width = TinyExtraBars_GetButtonsTotalSize(cols) + TEB_WIDTH_EXTRA
	local height = TinyExtraBars_GetButtonsTotalSize(rows) + TEB_HEIGHT_EXTRA
	self:SetWidth(width)
	self:SetHeight(height)
	local maxWidth = TinyExtraBars_GetButtonsTotalSize(TEB_MAX_COLS) + TEB_WIDTH_EXTRA + 1
	local maxHeight = TinyExtraBars_GetButtonsTotalSize(TEB_MAX_ROWS) + TEB_HEIGHT_EXTRA + 1
	self:SetMaxResize(maxWidth, maxHeight)
end

function TEB_Container:OnShow()
end

function TEB_Container:OnHide()
end

function TEB_Container:OnMouseDown(button)
	if button == "LeftButton" then
		self:StartMoving()
	end
end

function TEB_Container:OnMouseUp(button)
	if button == "LeftButton" then
		self:StopMovingOrSizing()
		local id = self:GetID()
		TinyExtraBarsPC:Set({'Containers', id, 'pos', 'left'}, self:GetLeft())
		TinyExtraBarsPC:Set({'Containers', id, 'pos', 'top'}, self:GetTop())
	end
end

function TEB_Container:OnResize()
	local width = self:GetWidth()
	local height = self:GetHeight()
	local cols = TinyExtraBars_GetButtonsCountByLen(width)
	local rows = TinyExtraBars_GetButtonsCountByLen(height)
	self.rows = rows
	self.cols = cols
	--print("OnResize", width, height, rows, cols)
	local id = self:GetID()
	local tabs = TinyExtraBarsPC:Get({'Containers', id, 'tabs'}, nil)
	if tabs then
		for k, v in ipairs(tabs) do
			self.FrameList[k]:SetButtons(rows, cols)
			self.FrameList[k]:SetButtonsCount(rows, cols)
		end
	end
	
	if self.maxRows < rows then
		self.maxRows = rows
	end
	if self.maxCols < cols then
		self.maxCols = cols
	end
end

function TEB_Container:SetEmptyButtonsVisible(value)
	for _, fl in pairs(self.FrameList) do
		for r = 1, self.rows do
			for c = 1, self.cols do
				local btn = fl.ButtonList[r][c]
				if btn then
					if not(btn.command) and not(value) then
						btn:Hide()
					else
						btn:Show()
					end
				end
			end
		end
	end
end

function TEB_Container:SetDefaultKeybindText()
	for _, fl in pairs(self.FrameList) do
		for r = 1, self.rows do
			for c = 1, self.cols do
				local btn = fl.ButtonList[r][c]
				if btn then
					btn.hotkey:SetText(RANGE_INDICATOR)
					if not btn.hotkey.__LBF_SetPoint then
						btn.hotkey:ClearAllPoints()
						btn.hotkey:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -2)
					end
					btn.hotkey:Hide()
				end
			end
		end
	end
end

function TEB_Container:SetKeybind(key, row, col)
	for _, fl in pairs(self.FrameList) do
		local btn = fl.ButtonList[row][col]
		if btn then
			local binding = "CLICK "..btn:GetName()..":LeftButton"
			if (key) and (key ~= "") then
				btn:SetAttribute('click_binding_key', key)
				btn:SetAttribute('click_binding_cmd', binding)
				local text = GetBindingText(key, "KEY_", 1)
				--print(text)
				text = string.gsub(text,"Num Pad (.)","N-%1")
				btn.hotkey:SetText(text)
				if not btn.hotkey.__LBF_SetPoint then
					btn.hotkey:ClearAllPoints()
					btn.hotkey:SetPoint("TOPLEFT", btn, "TOPLEFT", -2, -2)
				end
				btn.hotkey:SetVertexColor(0.6, 0.6, 0.6)
				btn.hotkey:Show()
				if btn:IsVisible() then
					SetOverrideBinding(btn, false, key, binding)
				end
			else
				--print(btn:GetName(), 'set to ', RANGE_INDICATOR)
				btn.hotkey:SetText(RANGE_INDICATOR)
				if not btn.hotkey.__LBF_SetPoint then
					btn.hotkey:ClearAllPoints()
					btn.hotkey:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -2)
				end
				btn.hotkey:Hide()
				ClearOverrideBindings(btn)
			end
		end
	end
end

-- menu stuff

local function SetMenuItemChecked(self)
	local name = self.text or self.value
	TinyExtraBarsPC:Set({'Containers', currTab.contID, name}, self.checked)
end
local function GetMenuItemChecked(v, default)
	local name = v.text or v.value
	return TinyExtraBarsPC:Get({'Containers', currTab.contID, name}, default)
end

-- tabs

local function AddNewTab()
	Lib_CloseDropDownMenus(1)
	local container = currTab.container
	local tabCount = #container.FrameList
	local newTabId = tabCount + 1
	--print(newTabId)
	container.FrameList[newTabId] = NewTabFrame(newTabId, container, container.maxRows, container.maxCols)
	container.tabs[newTabId] = NewTab(newTabId, container, container.tabs[tabCount], 'LEFT')
	TinyExtraBarsPC:Set({'Containers', currTab.contID, 'tabs', newTabId}, {["title"] = "Tab"..newTabId})
	container:OnResize()
	container.tabs[newTabId]:Show()
		
	container.activeTab = newTabId
	SetTabsAnchors(container)
	Lib_PanelTemplates_SetNumTabs(container, newTabId)	-- frames total
	Lib_PanelTemplates_SetTab(container, container.activeTab)
	TinyExtraBarsTabButton_OnClick(container.tabs[newTabId])
end

local function RemoveCurrentTab()
	local container = currTab.container
	local currTabId = currTab.tabID
	-- saves
	local tabCount = #container.FrameList
	-- move
	for i = currTabId, tabCount - 1 do
		TinyExtraBarsPC:Set({'Containers', currTab.contID, 'tabs', i}, TinyExtraBarsPC:Get({'Containers', currTab.contID, 'tabs', i + 1}, nil))
	end
	TinyExtraBarsPC:Set({'Containers', currTab.contID, 'tabs', tabCount}, nil)
	-- hide frames
	for r = 1, container.maxRows do
		for c = 1, container.maxCols do
			local btn = container.FrameList[currTabId].ButtonList[r][c]
			if btn then
				--print("hiding", currTabId, r, c)
				btn:Set(nil, nil, nil, nil)
				btn:HideButton()
			end
		end
	end
	container.FrameList[currTabId]:Hide()
	table.remove(container.FrameList, currTabId)
	-- hide tabs
	container.tabs[currTabId]:Hide()
	table.remove(container.tabs, currTabId)

	local tabCount = #container.FrameList
	--print("new tabCount "..tabCount)
	for i = 1, tabCount do
		container.FrameList[i]:SetID(i)
		container.tabs[i]:SetID(i)
	end
	-- apply
	if tabCount > 0 then
		SetTabsAnchors(container)
		Lib_PanelTemplates_SetNumTabs(container, tabCount)
		container.activeTab = currTabId
		if container.activeTab > tabCount then
			container.activeTab = container.activeTab - 1
		end
		Lib_PanelTemplates_SetTab(container, container.activeTab)
		TinyExtraBarsTabButton_OnClick(container.tabs[container.activeTab])
	else
		TinyExtraBars_RemoveContainer(container:GetID())
	end
end

StaticPopupDialogs["TEB_CONFIRM_REMOVE_TAB"] = {
	text = "Remove active tab?",
	button1 = YES,
	button2 = NO,
	OnAccept = RemoveCurrentTab,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

local function ConfirmRemoveTab()
	Lib_CloseDropDownMenus(1)
	local popup = StaticPopupDialogs["TEB_CONFIRM_REMOVE_TAB"]
	local title = currTab.tabFrame:GetText()
	popup.text = "Remove active tab '"..title.."'?"
	StaticPopup_Show("TEB_CONFIRM_REMOVE_TAB")
end

-- tab title

local function SetCurrentTabTitle(self, data)
    local text = self.editBox:GetText()
	currTab.currFrame.title = text
	currTab.tabFrame:SetText(text)
	TinyExtraBarsPC:Set({'Containers', currTab.contID, 'tabs', currTab.tabID, "title"}, text)
end

StaticPopupDialogs["TEB_ENTER_TAB_TITILE"] = {
	text = "Set tab title",
	button1 = YES,
	button2 = NO,
	OnAccept = SetCurrentTabTitle,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
	OnShow = function (self, data)
		self.editBox:SetText(currTab.tabFrame:GetText())
	end,
}

local function SetTabTitleDialog()
	--Lib_CloseDropDownMenus(1)
	StaticPopup_Show("TEB_ENTER_TAB_TITILE")
end

-- custom visibility

local function SetCurrentTabCustomVisibility(self, data)
    local text = self.editBox:GetText()
	currTab.currFrame.visibility["Custom"] = text
	currTab.currFrame:SaveVisibilityDriver()
end

StaticPopupDialogs["TEB_ENTER_TAB_CUSTOM_VISIBILITY"] = {
	text = "Edit tab custom visibility",
	button1 = YES,
	button2 = NO,
	OnAccept = SetCurrentTabCustomVisibility,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	hasEditBox = true,
	editBoxWidth = 350,
	OnShow = function (self, data)
		local visibility = currTab.currFrame.visibility["Custom"] or ""
		self.editBox:SetText(visibility)
	end,
}

local function SetTabCustomVisibilityDialog()
	--Lib_CloseDropDownMenus(1)
	StaticPopup_Show("TEB_ENTER_TAB_CUSTOM_VISIBILITY")
end


-- handlers

local function SetShowTooltip(self)
	SetMenuItemChecked(self)
	currTab.container.showtooltip = self.checked
end

local function SetClickThrough(self)
	SetMenuItemChecked(self)
	currTab.container.clickthrough = self.checked
end

local tabsSubmenu = {
	{ text = "Add new tab", func = AddNewTab, notCheckable = true, keepShownOnClick = false },
	{ text = "-----------", notCheckable = true, notClickable = true },
	{ text = "Remove active tab", func = ConfirmRemoveTab, notCheckable = true, keepShownOnClick = false },
}

local function UpdateDropdownChecked(dropdownLevel, i, checked)
	local button = _G["Lib_DropDownList"..dropdownLevel.."Button"..i]
	local checkImage = _G["Lib_DropDownList"..dropdownLevel.."Button"..i.."Check"]
	local uncheckImage = _G["Lib_DropDownList"..dropdownLevel.."Button"..i.."UnCheck"]
	button.checked = checked
	if checked then
		button:LockHighlight()
		checkImage:Show()
		uncheckImage:Hide()
	else
		button:UnlockHighlight()
		checkImage:Hide()
		uncheckImage:Show()
	end
end

local function StanceChecked(self)
	local visibility = currTab.currFrame.visibility[self.arg1]
	local dropdownLevel = 3
	visibility[self.arg2] = self.checked
	if self.arg2 == 1 and self.checked then
		for k, v in ipairs(visibility) do
			if k ~= self.arg2 then
				visibility[k] = false
				UpdateDropdownChecked(dropdownLevel, k, false)
			end
		end
	elseif self.checked then
		visibility[1] = false
		UpdateDropdownChecked(dropdownLevel, 1, false)
	end
	currTab.container:SetTabSubmenu()
	UpdateDropdownChecked(dropdownLevel, self.arg2, self.checked)
	currTab.currFrame:SaveVisibilityDriver()
end

local function ShowHideChecked(self)
	local visibility = currTab.currFrame.visibility[self.arg1]
	local dropdownLevel = 3
	if (self.checked) then
		visibility[self.arg2] = self.checked
		for k, v in ipairs(visibility) do
			if k ~= self.arg2 then
				visibility[k] = false
				UpdateDropdownChecked(dropdownLevel, k, false)
			end
		end
		currTab.container:SetTabSubmenu()
		currTab.currFrame:SaveVisibilityDriver()
	end
	UpdateDropdownChecked(dropdownLevel, self.arg2, visibility[self.arg2])
end

local function TalentsChecked(self)
	local visibility = currTab.currFrame.visibility[self.arg1]
	local dropdownLevel = 3
	visibility[self.arg2] = self.checked
	currTab.container:SetTabSubmenu()
	currTab.currFrame:SaveVisibilityDriver()
	UpdateDropdownChecked(dropdownLevel, self.arg2, self.checked)
end

local function StrataChecked(self)
	local text = self.text or self.value
	currTab.container.strata = text
	TinyExtraBarsPC:Set({'Containers', currTab.contID, 'strata'}, text)
	local dropdownLevel = 2
	for i = 1, 8 do
		UpdateDropdownChecked(dropdownLevel, i, i == self.arg2)
	end
	currTab.container:SetContainerSubmenu()
	currTab.container:SetFrameStrata(text)
	for k, v in pairs(currTab.container.FrameList) do
		v:SetFrameStrata(text)
	end
end

local function AlphaChecked(self)
	local text = self.text or self.value
	currTab.container.alpha = tonumber(text)
	TinyExtraBarsPC:Set({'Containers', currTab.contID, 'alpha'}, currTab.container.alpha)
	local dropdownLevel = 2
	for i = 1, 11 do
		UpdateDropdownChecked(dropdownLevel, i, i == self.arg2)
	end
	currTab.container:SetContainerSubmenu()
end

local visibilityOptionsStance = {
	{ text = "any", arg1 = "Stance", arg2 = 1, func = StanceChecked, checked = true, keepShownOnClick = true },
	{ text = "0", arg1 = "Stance", arg2 = 2, func = StanceChecked, checked = false, keepShownOnClick = true, isNotRadio = true },
	{ text = "1", arg1 = "Stance", arg2 = 3, func = StanceChecked, checked = false, keepShownOnClick = true, isNotRadio = true },
	{ text = "2", arg1 = "Stance", arg2 = 4, func = StanceChecked, checked = false, keepShownOnClick = true, isNotRadio = true },
	{ text = "3", arg1 = "Stance", arg2 = 5, func = StanceChecked, checked = false, keepShownOnClick = true, isNotRadio = true },
	{ text = "4", arg1 = "Stance", arg2 = 6, func = StanceChecked, checked = false, keepShownOnClick = true, isNotRadio = true },
	{ text = "5", arg1 = "Stance", arg2 = 7, func = StanceChecked, checked = false, keepShownOnClick = true, isNotRadio = true },
	{ text = "6", arg1 = "Stance", arg2 = 8, func = StanceChecked, checked = false, keepShownOnClick = true, isNotRadio = true },
	{ text = "7", arg1 = "Stance", arg2 = 9, func = StanceChecked, checked = false, keepShownOnClick = true, isNotRadio = true },
}

local visibilityOptionsVehicle = {
	{ text = "show", arg1 = "Vehicle", arg2 = 1, func = ShowHideChecked, checked = false, keepShownOnClick = true },
	{ text = "hide", arg1 = "Vehicle", arg2 = 2, func = ShowHideChecked, checked = true, keepShownOnClick = true },
}

local visibilityOptionsBonusBar = {
	{ text = "show", arg1 = "BonusBar", arg2 = 1, func = ShowHideChecked, checked = false, keepShownOnClick = true },
	{ text = "hide", arg1 = "BonusBar", arg2 = 2, func = ShowHideChecked, checked = true, keepShownOnClick = true },
}

local visibilityOptionsPetBattle = {
	{ text = "show", arg1 = "PetBattle", arg2 = 1, func = ShowHideChecked, checked = false, keepShownOnClick = true },
	{ text = "hide", arg1 = "PetBattle", arg2 = 2, func = ShowHideChecked, checked = true, keepShownOnClick = true },
}

local talentSubmenu = {
	{ text = "1", arg1 = "Talents", arg2 = 1, func = TalentsChecked, checked = true, keepShownOnClick = true, isNotRadio = true },
	{ text = "2", arg1 = "Talents", arg2 = 2, func = TalentsChecked, checked = true, keepShownOnClick = true, isNotRadio = true },
}

local visibilitySubmenu = {
	{ text = "Talents", menuList = talentSubmenu, hasArrow = true, notCheckable = true, keepShownOnClick = true },
	{ text = "Stance", menuList = visibilityOptionsStance, hasArrow = true, notCheckable = true, keepShownOnClick = true },
	{ text = "Vehicle", menuList = visibilityOptionsVehicle, hasArrow = true, notCheckable = true, keepShownOnClick = true },
	{ text = "PetBattle", menuList = visibilityOptionsPetBattle, hasArrow = true, notCheckable = true, keepShownOnClick = true },
	{ text = "BonusBar", menuList = visibilityOptionsBonusBar, hasArrow = true, notCheckable = true, keepShownOnClick = true },
	{ text = "Custom", arg1 = "Custom", func = SetTabCustomVisibilityDialog,  notCheckable = true, keepShownOnClick = false },
}

local strataSubmenu = {
	{ text = "BACKGROUND", 	arg1 = "Strata", arg2 = 1, func = StrataChecked, checked = false, keepShownOnClick = true },
	{ text = "LOW", 		arg1 = "Strata", arg2 = 2, func = StrataChecked, checked = true, keepShownOnClick = true },
	{ text = "MEDIUM", 		arg1 = "Strata", arg2 = 3, func = StrataChecked, checked = false, keepShownOnClick = true },
	{ text = "HIGH", 		arg1 = "Strata", arg2 = 4, func = StrataChecked, checked = false, keepShownOnClick = true },
	{ text = "DIALOG", 		arg1 = "Strata", arg2 = 5, func = StrataChecked, checked = false, keepShownOnClick = true },
	{ text = "FULLSCREEN", 	arg1 = "Strata", arg2 = 6, func = StrataChecked, checked = false, keepShownOnClick = true },
	{ text = "FULLSCREEN_DIALOG", arg1 = "Strata", arg2 = 7, func = StrataChecked, checked = false, keepShownOnClick = true },
	{ text = "TOOLTIP", 	arg1 = "Strata", arg2 = 8, func = StrataChecked, checked = false, keepShownOnClick = true },
}

local alphaSubmenu = {
	{ text = "0", 	arg1 = "Alpha", arg2 = 1, func = AlphaChecked, checked = false, keepShownOnClick = true },
	{ text = "0.1", arg1 = "Alpha", arg2 = 2, func = AlphaChecked, checked = false, keepShownOnClick = true },
	{ text = "0.2", arg1 = "Alpha", arg2 = 3, func = AlphaChecked, checked = false, keepShownOnClick = true },
	{ text = "0.3", arg1 = "Alpha", arg2 = 4, func = AlphaChecked, checked = false, keepShownOnClick = true },
	{ text = "0.4", arg1 = "Alpha", arg2 = 5, func = AlphaChecked, checked = false, keepShownOnClick = true },
	{ text = "0.5", arg1 = "Alpha", arg2 = 6, func = AlphaChecked, checked = false, keepShownOnClick = true },
	{ text = "0.6", arg1 = "Alpha", arg2 = 7, func = AlphaChecked, checked = false, keepShownOnClick = true },
	{ text = "0.7", arg1 = "Alpha", arg2 = 8, func = AlphaChecked, checked = false, keepShownOnClick = true },
	{ text = "0.8", arg1 = "Alpha", arg2 = 9, func = AlphaChecked, checked = false, keepShownOnClick = true },
	{ text = "0.9", arg1 = "Alpha", arg2 = 10, func = AlphaChecked, checked = false, keepShownOnClick = true },
	{ text = "1.0", arg1 = "Alpha", arg2 = 11, func = AlphaChecked, checked = true, keepShownOnClick = true },
}

local containerMenu = {
	-- arg1 = default for checkable
	{ text = "Container", isTitle = true, notCheckable = true, justifyH = "CENTER"},
	{ text = "Tabs", menuList = tabsSubmenu, hasArrow = true, notCheckable = true, keepShownOnClick = true },
	{ text = "Show tooltip", arg1 = true, func = SetShowTooltip, checked = true, keepShownOnClick = true, isNotRadio = true},
	{ text = "Strata", menuList = strataSubmenu, hasArrow = true, notCheckable = true, keepShownOnClick = true },
	{ text = "Alpha", menuList = alphaSubmenu, hasArrow = true, notCheckable = true, keepShownOnClick = true },
	{ text = "Click through", arg1 = false, func = SetClickThrough, checked = false, keepShownOnClick = true, isNotRadio = true},
	{ text = "Close", notCheckable = true, keepShownOnClick = false },
}

local tabMenu = {
	-- arg1 = default for checkable
	{ text = "Tab", isTitle = true, notCheckable = true, justifyH = "CENTER"},
	{ text = "Title", func = SetTabTitleDialog, notCheckable = true, keepShownOnClick = false },
	{ text = "Visibility", menuList = visibilitySubmenu, hasArrow = true, notCheckable = true, keepShownOnClick = true },
	{ text = "Close", notCheckable = true, keepShownOnClick = false },
}

function TEB_Container:SetContainerSubmenu()
	for _, v in pairs(containerMenu) do
		if not(v.notCheckable) then
			v.checked = GetMenuItemChecked(v, v.arg1)
		end
	end
	for k, v in ipairs(strataSubmenu) do
		v.checked = v.text == currTab.container.strata
	end
	for k, v in ipairs(alphaSubmenu) do
		v.checked = tonumber(v.text) == currTab.container.alpha
	end
end

function TEB_Container:SetTabSubmenu()
	--[[for _, v in pairs(tabMenu) do
		if not(v.notCheckable) then
			v.checked = GetMenuItemChecked(v, v.arg1)
		end
	end]]
	for k, v in pairs(talentSubmenu) do
		v.checked = currTab.currFrame.visibility["Talents"][k]
	end
	for k, v in pairs(visibilityOptionsStance) do
		v.checked = currTab.currFrame.visibility["Stance"][k]
	end
	for k, v in pairs(visibilityOptionsVehicle) do
		v.checked = currTab.currFrame.visibility["Vehicle"][k]
	end
	for k, v in pairs(visibilityOptionsBonusBar) do
		v.checked = currTab.currFrame.visibility["BonusBar"][k]
	end
end

function TEB_Container:OnContainerSubmenu()
	currTab = {}
	currTab.container = self
	currTab.contID = self:GetID()
	currTab.currFrame = self.FrameList[self.activeTab]
	currTab.tabID = self.activeTab
	currTab.tabFrame = self.tabs[self.activeTab]
	self:SetContainerSubmenu()
	--menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay
	Lib_EasyMenu(containerMenu, SubmenuDummyFrame, "cursor", 0, 0, "MENU")
end

function TEB_Container:OnTabSubmenu()
	currTab = {}
	currTab.container = self
	currTab.contID = self:GetID()
	currTab.currFrame = self.FrameList[self.activeTab]
	currTab.tabID = self.activeTab
	currTab.tabFrame = self.tabs[self.activeTab]
	self:SetTabSubmenu()
	--menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay
	Lib_EasyMenu(tabMenu, SubmenuDummyFrame, "cursor", 0, 0, "MENU")
end

-- resize

local leftPos, topPos

function TinyExtraBarsFrame_OnResizeGripMouseDown(self, button)
	local container = self:GetParent()
	if (button == "LeftButton") then
		leftPos = container:GetLeft()
		topPos = container:GetTop()
		container:SetResizable(true)
		container:StartSizing("BOTTOMRIGHT")
	end 
end

function TinyExtraBarsFrame_OnResizeGripMouseUp(self, button)
	local container = self:GetParent()
	if (button == "LeftButton") then
		container:StopMovingOrSizing()
		container:SetResizable(false)
		container:ClearAllPoints()
		container:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", leftPos, topPos)
		local id = container:GetID()
		local width = container:GetWidth()
		local height = container:GetHeight()
		local cols = TinyExtraBars_GetButtonsCountByLen(width)
		local rows = TinyExtraBars_GetButtonsCountByLen(height)
		--print("OnResizeGripMouseUp", width, height, rows, cols)
		TinyExtraBarsPC:Set({'Containers', id, 'cols'}, cols)
		TinyExtraBarsPC:Set({'Containers', id, 'rows'}, rows)
		
		width = TinyExtraBars_GetButtonsTotalSize(cols) + TEB_WIDTH_EXTRA + 1
		height = TinyExtraBars_GetButtonsTotalSize(rows) + TEB_HEIGHT_EXTRA + 1
		container:SetWidth(width)
		container:SetHeight(height)
	end
end
