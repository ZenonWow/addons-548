local EnteringWorldOrVariablesLoaded = 0
local UpdateMacroCount = 0
local EventFrame
local EventHandlersTable = {}
local toolsFrame, overlayFrame, minimapButton
local IsInit
--preset
local presetFrame
local selectedPreset = 0
local customizeFrame, iconSelectionDialogPopupFrame

local EventHandlersTable = {}
local Containers = {}
local createBarMode = false
TEB_LastEffectMode = false
TEB_LastEffectAverageMode = false
TEB_FullRangeArtwork = false
TEB_HideBorders = true

--Button Facade stuff
local LBF
local BF_Table = {}
TEB_LBFMasterGroup = nil
local BF_SETTINGS_GROUP = "Button Facade"

local LIST_ELEMENT_HEIGHT 	= 16
local LIST_ELEMENT_COUNT 	= 5


local function ButtonFacadeCallback(self, SkinID, Gloss, Backdrop, Group, Button, Colors)
	-- If no group is specified, save the data as the root add-on skin.
	-- This will allow the ButtonFacade GUI to display it correctly.
	if not(Group) then
		TinyExtraBarsG:Set({BF_SETTINGS_GROUP, "SkinID"}, SkinID)
		TinyExtraBarsG:Set({BF_SETTINGS_GROUP, "Gloss"}, Gloss)
		TinyExtraBarsG:Set({BF_SETTINGS_GROUP, "Backdrop"}, Backdrop)
		TinyExtraBarsG:Set({BF_SETTINGS_GROUP, "Colors"}, Colors)
	else
		TinyExtraBarsG:Set({BF_SETTINGS_GROUP, Group, "SkinID"}, SkinID)
		TinyExtraBarsG:Set({BF_SETTINGS_GROUP, Group, "Gloss"}, Gloss)
		TinyExtraBarsG:Set({BF_SETTINGS_GROUP, Group, "Backdrop"}, Backdrop)
		TinyExtraBarsG:Set({BF_SETTINGS_GROUP, Group, "Colors"}, Colors)
	end
end

TEB_KeybindMode = nil
TEB_SettingsMode = true

function TinyExtraBars_RemoveContainer(id)
	if InCombatLockdown() then
		return
	end
	
	Containers[id]:Hide()
	local size = #Containers
	for i = id, size - 1 do
		Containers[i] = Containers[i + 1]
		Containers[i]:SetID(i)
		TinyExtraBarsPC:Set({'Containers', i}, TinyExtraBarsPC:Get({'Containers', i + 1}, nil))
	end
	table.remove(Containers, size)
	TinyExtraBarsPC:Remove({'Containers'}, size)
end

function TinyExtraBars_RegisterContainer(id, container)
	Containers[id] = container
end

function TinyExtraBars_SetButtonsMovable(value)
	for k, v in ipairs(Containers) do
		for kf, vf in ipairs(v.FrameList) do
			for r, _ in ipairs(vf.ButtonList) do
				for c, btn in ipairs(vf.ButtonList[r]) do
					btn:SetMovable(value)
				end
			end
		end
	end
end

function TinyExtraBars_SetButtonsConfigure(value)
	for k, v in ipairs(Containers) do
		for kf, vf in ipairs(v.FrameList) do
			for r, _ in ipairs(vf.ButtonList) do
				for c, btn in ipairs(vf.ButtonList[r]) do
					if value then
						btn.configure:Show()
					else
						btn.configure:Hide()
					end
				end
			end
		end
	end
end

function TinyExtraBars_SetButtonsClickable(value)
	for k, cont in ipairs(Containers) do
		for kf, vf in ipairs(cont.FrameList) do
			if value then
				vf:EnableMouse(value)
			else
				vf:EnableMouse(not(cont.clickthrough))
			end
			for r, _ in ipairs(vf.ButtonList) do
				for c, btn in ipairs(vf.ButtonList[r]) do
					if value then
						btn:EnableMouse(value)
					else
						btn:EnableMouse(not(cont.clickthrough))
					end
				end
			end
		end
	end
end

-- Tools Frame

function TinyExtraBarsToolsFrame_OnShow()
	if InCombatLockdown() then
		return
	end
	
	TEB_SettingsMode = true
	TinyExtraBarsPC:Set({'ToolsFrame', 'SettingsMode'}, TEB_SettingsMode)
	for k, v in ipairs(Containers) do
		for kf, vf in ipairs(v.FrameList) do
			vf:SetCustomAlpha()
			vf:DisableVisibilityDriver()
		end
		v:Show()
		v:SetEmptyButtonsVisible(true)
		Lib_PanelTemplates_SetTab(v, v.activeTab)
		TinyExtraBarsTabButton_OnClick(v.tabs[v.activeTab])
	end
	TinyExtraBars_SetButtonsMovable(TEB_SettingsMode)
	TinyExtraBars_SetButtonsConfigure(TEB_SettingsMode)
	TinyExtraBars_SetButtonsClickable(true)
end

function TinyExtraBarsToolsFrame_OnHide()
	Lib_CloseDropDownMenus(1)
	TEB_SettingsMode = false
	TinyExtraBarsPC:Set({'ToolsFrame', 'SettingsMode'}, TEB_SettingsMode)

	TinyExtraBars_SetButtonsConfigure(TEB_SettingsMode)
	
	if InCombatLockdown() then
		return
	end	
	for k, v in ipairs(Containers) do
		v:Hide()
		v:SetEmptyButtonsVisible(false)
		for kf, vf in ipairs(v.FrameList) do
			vf:SetCustomAlpha()
			vf:UpdateVisibilityDriver()
		end
	end
	if presetFrame:IsVisible() then
		presetFrame:Hide()
	end
	TinyExtraBars_SetButtonsMovable(TEB_SettingsMode)
	TinyExtraBars_SetButtonsClickable(false)
end

function TinyExtraBarsToolsFrame_OnMouseDown(self, button)
	if button == "LeftButton" then
		self:StartMoving()
	end
end

function TinyExtraBarsToolsFrame_OnMouseUp(self)
	self:StopMovingOrSizing()
	TinyExtraBarsPC:Set({'ToolsFrame', 'pos', 'left'}, self:GetLeft())
	TinyExtraBarsPC:Set({'ToolsFrame', 'pos', 'top'}, self:GetTop())
end

function TinyExtraBarsToolsFrame_SetButtonSize(self, value)
	if InCombatLockdown() then
		return
	end
	
	-- 5.4 fix
	if not self._onsetting then   -- is single threaded 
		self._onsetting = true
		self:SetValue(self:GetValue())
		value = self:GetValue()     -- cant use original 'value' parameter
		self._onsetting = false
	else return end               -- ignore recursion for actual event handler
	-- end fix
	_G[self:GetName().."Text"]:SetText(value) -- handle the event
	
	TinyExtraBarsG:Set({'ButtonSize'}, value)
	TEB_BUTTON_SIZE = value
	--TEB_BUTTON_SCALE = TEB_BUTTON_SIZE / TEB_DEFAULT_BUTTON_SIZE
	--print("scale", TEB_BUTTON_SCALE)
	for _, v in ipairs(Containers) do
		local rows = v.rows
		local cols = v.cols
		v:SetSize(rows, cols)
		for _, vf in ipairs(v.FrameList) do
			vf:SetSize(rows, cols)
			for r, _ in ipairs(vf.ButtonList) do
				for c, btn in ipairs(vf.ButtonList[r]) do
					btn:SetSize(value, value)
					--btn:SetScale(TEB_BUTTON_SCALE)
					btn:SetAnchor(r, c)
				end
			end
		end
	end
end

function TinyExtraBarsToolsFrame_SetButtonSpace(self, value)
	if InCombatLockdown() then
		return
	end
	
	-- 5.4 fix
	if not self._onsetting then   -- is single threaded 
		self._onsetting = true
		self:SetValue(self:GetValue())
		value = self:GetValue()     -- cant use original 'value' parameter
		self._onsetting = false
	else return end               -- ignore recursion for actual event handler
	-- end fix
	_G[self:GetName().."Text"]:SetText(value) -- handle the event
	
	TinyExtraBarsG:Set({'ButtonSpace'}, value)
	TEB_BUTTON_SPACING = value
	for k, v in ipairs(Containers) do
		local rows = v.rows
		local cols = v.cols
		v:SetSize(rows, cols)
		for _, vf in ipairs(v.FrameList) do
			vf:SetSize(rows, cols)
			for r, _ in ipairs(vf.ButtonList) do
				for c, btn in ipairs(vf.ButtonList[r]) do
					btn:SetAnchor(r, c)
				end
			end
		end
	end
end

function TinyExtraBarsToolsFrame_SetLastEffect(checked)
	TEB_LastEffectMode = checked
	TinyExtraBarsG:Set({'ToolsFrame', 'LastEffectMode'}, checked)
end

function TinyExtraBarsToolsFrame_SetLastEffectAverage(checked)
	TEB_LastEffectAverageMode = checked
	TinyExtraBarsG:Set({'ToolsFrame', 'LastEffectAverageMode'}, checked)
end

function TinyExtraBarsToolsFrame_SetFullRangeArtwork(checked)
	TEB_FullRangeArtwork = checked
	TinyExtraBarsG:Set({'ToolsFrame', 'FullRangeArtwork'}, checked)
end

function TinyExtraBarsToolsFrame_SetHideBorders(checked)
	TEB_HideBorders = checked
	TinyExtraBarsG:Set({'ToolsFrame', 'HideBorders'}, checked)
	for k, v in ipairs(Containers) do
		for kf, vf in ipairs(v.FrameList) do
			for r, _ in ipairs(vf.ButtonList) do
				for c, btn in ipairs(vf.ButtonList[r]) do
					btn:UpdateTexture()
				end
			end
		end
	end
end

function TinyExtraBarsToolsFrame_SetUseShift(checked)
	TEB_UseShift = checked
	TinyExtraBarsG:Set({'ToolsFrame', 'UseShift'}, checked)
end

function TinyExtraBars_UnbindButtons(key)
	for k, v in ipairs(Containers) do
		local rows = v.maxRows
		local cols = v.maxCols
		for _, vf in ipairs(v.FrameList) do
			for r, _ in ipairs(vf.ButtonList) do
				for c, btn in ipairs(vf.ButtonList[r]) do
					if btn:GetAttribute('click_binding_key') == key then
						SetOverrideBinding(btn, false, key, nil)
						btn:SetKey(nil)
					end
				end
			end
		end
	end
end

-- MacroText

local customizableButton

local function TinyExtraBars_MacroTextCustomizeFrame_OkClick(self)
	local frame = self:GetParent()
	local macroText = frame.ScrollMacro.EditBoxMacro:GetText()
	local iconSpellName = frame.EditBoxIcon:GetText()
	local tooltip = frame.ScrollTooltip.EditBoxTooltip:GetText()
	--set button
	if customizableButton then
		if macroText and macroText ~= "" then
			local command, value, id = "macrotext", macroText, tooltip
			local t = {}
			t.texture = customizeFrame.spellIcon.icon:GetTexture()
			t.textureIsCustom = customizeFrame.macroTextTextureIsCustom
			t.value = iconSpellName -- spell name or item hint
			
			subValue = customizeFrame.macroTextCommandType
			if customizeFrame.macroTextCommandType == "spell" then
				t.id = customizeFrame.macroTextSpellID
			elseif customizeFrame.macroTextCommandType == "item" then
				t.id = customizeFrame.macroTextItemID
			else
				t.id = nil
			end
			
			customizableButton:Set(command, value, subValue, id, t)
			customizableButton:SaveCommand(command, value, subValue, id, t)
		else
			customizableButton:Set(nil, nil, nil, nil)
			customizableButton:SaveCommand(nil, nil, nil, nil)
		end
	end
	frame:Hide()
end

function TinyExtraBars_MacroTextCustomizeFrame_Toogle(btn)
	if InCombatLockdown() then
		return
	end
	
	if customizeFrame:IsVisible() then
		customizeFrame:Hide()
	else
		--[[customizeFrame.macroTextCommandType = nil
		customizeFrame.macroTextItemID = nil
		customizeFrame.macroTextSpellID = nil
		customizeFrame.macroTextTextureIsCustom = nil]]
		
		customizeFrame:Show()

		--SetText
		local command, value, subValue, id = btn.command, btn.value, btn.subValue, btn.id
		
		customizeFrame.CommandType:SetText("")
		
		if command == "macrotext" and value then
			customizeFrame.ScrollMacro.EditBoxMacro:SetText(value)
		else
			customizeFrame.ScrollMacro.EditBoxMacro:SetText("")
		end
		if command == "macrotext" then
			local t = btn.macroValues
			local texture
			if t and type(t) == "table" then 
				customizeFrame.macroTextTextureIsCustom = t.textureIsCustom
				if customizeFrame.macroTextTextureIsCustom then
					texture = t.texture
				else
					if subValue == "spell" then
						texture = GetSpellTexture(t.value)
					elseif subValue == "item" then
						texture = GetItemIcon(t.value)
					end
				end
			end
			--set spell/item text
			if subValue == "spell" then
				customizeFrame.CommandType:SetText("spell")
			elseif subValue == "item" then
				customizeFrame.CommandType:SetText("item")
			else
				customizeFrame.CommandType:SetText("")
			end
			if t.value then
				customizeFrame.EditBoxIcon:SetText(t.value)
			else
				customizeFrame.EditBoxIcon:SetText("")
			end
			customizeFrame.spellIcon.icon:SetTexture(texture)
		else
			customizeFrame.EditBoxIcon:SetText("")
			customizeFrame.spellIcon.icon:SetTexture(nil)
		end
		if command == "macrotext" and id then
			customizeFrame.ScrollTooltip.EditBoxTooltip:SetText(id)
		else
			customizeFrame.ScrollTooltip.EditBoxTooltip:SetText("")
		end
		customizableButton = btn
		
		-- handler
		customizeFrame.OK:SetScript("OnClick", TinyExtraBars_MacroTextCustomizeFrame_OkClick)
	end
end

--presets

local function IndexOf(t, val)
    for k, v in ipairs(t) do 
        if v == val then 
			return k 
		end
    end
end

function TinyExtraBarsPresetsToogle()
	if not(InCombatLockdown()) then
		if presetFrame:IsVisible() then
			presetFrame:Hide()
		else
			presetFrame:Show()
			TinyExtraBarsPresetsUpdate()
		end
	end
end

function TinyExtraBarsPresetsUpdate()
	table.sort(presetFrame.Presets)
	local listCount = #presetFrame.Presets
	if listCount < 1 then
		selectedPreset = 0
		presetFrame.Apply:Disable()
		presetFrame.Delete:Disable()
	else
		if selectedPreset == 0 or listCount > selectedPreset then
			selectedPreset = 1
		end
		presetFrame.Apply:Enable()
		presetFrame.Delete:Enable()
	end
	
	if #Containers > 0 then
		presetFrame.SaveAsPreset:Enable()
	else
		presetFrame.SaveAsPreset:Disable()
	end
	TinyExtraBarsScrollBar_Update(presetFrame.ScrollFrame)
end

local function deepcopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

function TinyExtraBarsPresetSaveAs()
	local charName = UnitName("player")
	local idx = IndexOf(presetFrame.Presets, charName)
	if idx and idx > 0 then
		table.remove(presetFrame.Presets, idx)
	end
	local temp = deepcopy(TinyExtraBarsPC:Get({'Containers'}, {}))
	TinyExtraBarsG:Set({'Presets', charName}, temp)
	table.insert(presetFrame.Presets, charName)
	TinyExtraBarsPresetsUpdate()
end

function TinyExtraBarsPresetApply()
	local charName = presetFrame.Presets[selectedPreset]
	local temp = deepcopy(TinyExtraBarsG:Get({'Presets', charName}, {}))
	TinyExtraBarsPC:Set({'Containers'}, temp)
	TinyExtraBars_LoadContainers()
end

function TinyExtraBarsPresetDelete()
	local charName = table.remove(presetFrame.Presets, selectedPreset)
	TinyExtraBarsG:Set({'Presets', charName}, nil)
	selectedPreset = selectedPreset - 1
	if selectedPreset < 0 then
		selectedPreset = 0
	end
	TinyExtraBarsPresetsUpdate()
end

local function ListButton_OnClick(self)
	selectedPreset = self.tag + FauxScrollFrame_GetOffset(presetFrame.ScrollFrame)
	TinyExtraBarsScrollBar_Update(presetFrame.ScrollFrame)
end

local function CreateListButton(idx, parent, scrollFrame)
	local b = CreateFrame("Button", parent:GetName().."ListButton"..idx, parent)
	b:SetWidth(scrollFrame:GetWidth() - 15)
	b:SetHeight(LIST_ELEMENT_HEIGHT - 2)
	b.tag = idx
	b:SetScript("OnClick", ListButton_OnClick)
	b:SetNormalFontObject("GameFontHighlightLeft")
	--b:SetText(idx)
	b:SetNormalTexture("Interface\\TargetingFrame\\UI-StatusBar")
	b:SetHighlightTexture("Interface\\TargetingFrame\\UI-StatusBar")
	b.texture = b:GetNormalTexture()
	return b
end

function TinyExtraBarsScrollBar_VerticalScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, LIST_ELEMENT_HEIGHT, TinyExtraBarsScrollBar_Update)
end

function TinyExtraBarsScrollBar_Update(self)
	local line -- 1 through TextureElementCount of our window to scroll
	local lineplusoffset -- an index into our data calculated from the scroll offset
	local listCount = #presetFrame.Presets
	--print("listCount", listCount)
	local sf = self:GetParent()
	for line = 1, LIST_ELEMENT_COUNT do
		lineplusoffset = line + FauxScrollFrame_GetOffset(self)
		local button = presetFrame.Bars[line]
		if lineplusoffset <= listCount then
			if button.texture then
				if selectedPreset == lineplusoffset then
					button.texture:SetVertexColor(0.75, 0, 0, 1)
				else
					button.texture:SetVertexColor(0, 0, 0, 1)
				end
			end
			--print(presetFrame.Presets[lineplusoffset])
			button:SetText(presetFrame.Presets[lineplusoffset])
			button:Show()
		else
			button:Hide()
		end
	end
	-- frame, numItems, numToDisplay, valueStep, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth, alwaysShowScrollBar
	FauxScrollFrame_Update(self, listCount, LIST_ELEMENT_COUNT, LIST_ELEMENT_HEIGHT, nil, nil, nil, nil, nil, nil, true)
end

--event handlers, for mounts only right now

local function EventTalentGroupChanged(self, ...)
	TinyExtraBars_CacheSpells()
end

local function EventSpellsChanged(self, ...)
	TinyExtraBars_CacheSpells()
end

local function ModifierStateChanged(self, key, state)
	--print(key, state)
	if InCombatLockdown() or not(TEB_UseShift) then
		return
	end
	
	if ((key == "LSHIFT") or (key == "RSHIFT")) and (state ~= 0) then
		for k, v in ipairs(Containers) do
			--print('SetEmptyButtonsVisible', k, 'true')
			v:SetEmptyButtonsVisible(true)
		end
		TinyExtraBars_SetButtonsMovable(true)
	elseif not(TEB_SettingsMode) then
		for k, v in ipairs(Containers) do
			--print('SetEmptyButtonsVisible', k, 'false')
			v:SetEmptyButtonsVisible(false)
		end
		TinyExtraBars_SetButtonsMovable(false)
	end
end

local function RegisterEvents()
	EventHandlersTable = {
		["PLAYER_SPECIALIZATION_CHANGED"]	= EventTalentGroupChanged,
		["SPELLS_CHANGED"] 					= EventSpellsChanged,
		["COMBAT_LOG_EVENT_UNFILTERED"]		= TEBLE_EventCombatLog,
		["MODIFIER_STATE_CHANGED"] 			= ModifierStateChanged,
	}
	
	for k, _ in pairs(EventHandlersTable) do
		EventFrame:RegisterEvent(k)
	end
end

local function ClearTable(t)
	for k, v in pairs(t) do
		t[k] = nil
	end
end

function TinyExtraBars_LoadContainers()
	ClearTable(Containers)
	local cont = TinyExtraBarsPC:Get({'Containers'}, {})
	for k, v in ipairs(cont) do
		--print(k, v)
		if v and v.tabs then
			local left = TinyExtraBarsPC:Get({'Containers', k, 'pos', 'left'})
			local top = TinyExtraBarsPC:Get({'Containers', k, 'pos', 'top'})
			local cols = TinyExtraBarsPC:Get({'Containers', k, 'cols'}, 6)
			local rows = TinyExtraBarsPC:Get({'Containers', k, 'rows'}, 2)
			local cf = TEB_Container_New(k, left, top, rows, cols)
			Containers[k] = cf		
		
			if toolsFrame:IsShown() then
				cf:Show()
			end
		else
			TinyExtraBarsPC:Set({'Containers', k}, nil)
		end
	end
end

local function TinyExtraBars_SlashHandler(msg, editbox)
	--local command, rest = msg:match("^(%S*)%s*(.-)$")
	-- Any leading non-whitespace is captured into command
	-- the rest (minus leading whitespace) is captured into rest.
	--command = string.lower(command)
	
	if toolsFrame:IsShown() then
		toolsFrame:Hide()
	elseif not(InCombatLockdown()) then
		toolsFrame:Show()
	end
end

local TEB_ToggleSnippet = [=[
	--print("TEB_ToggleSnippet")
	local count = self:GetAttribute("FramesCount")
	--print("FramesCount", count)
	
	local toggle_enabled = self:GetAttribute("toggle_enabled")
	toggle_enabled = not(toggle_enabled)
	self:SetAttribute("toggle_enabled", toggle_enabled)
	
	if count then
		for i = 1, count do
			local bf = self:GetFrameRef("TEB_ButtonFrame"..i)
			--print("bf", bf)
			if bf then
				--print(bf:GetName())
				if toggle_enabled then
					--print("Hide")
					UnregisterStateDriver(bf, "visibility")
					bf:Hide()
				else
					--print("Show")
					bf:Show()
					local DriverString = bf:GetAttribute("StateDriverString")
					if DriverString then
						RegisterStateDriver(bf, "visibility", DriverString)
					end
				end
			end
		end
	end
]=]

local function Init()
	if InCombatLockdown() then
		print("TinyExtraBars will be loaded on leaving combat")
		EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	assert(LibStub, "LibStub not found")

	-- EasyStorage
	local storage = LibStub("EasyStorage-1.4", false)
	
	TinyExtraBars_Global = TinyExtraBars_Global or {}
	TinyExtraBarsG = storage:New(TinyExtraBars_Global)
	TinyExtraBars_PerChar = TinyExtraBars_PerChar or {}
	TinyExtraBarsPC = storage:New(TinyExtraBars_PerChar)

	TinyExtraBars_CacheSpells()
	
	TEB_BUTTON_SIZE = TinyExtraBarsG:Get({'ButtonSize'}, TEB_DEFAULT_BUTTON_SIZE)	
	TEB_BUTTON_SPACING = TinyExtraBarsG:Get({'ButtonSpace'}, 4)
	--TEB_BUTTON_SCALE = TEB_BUTTON_SIZE / TEB_DEFAULT_BUTTON_SIZE

	--Button Facade
	LBF = LibStub("LibButtonFacade", true)
	if (LBF) then
		TEB_LBFMasterGroup = LBF:Group("TinyExtraBars")
		LBF:RegisterSkinCallback("TinyExtraBars", ButtonFacadeCallback, BF_Table)
		TEB_LBFMasterGroup:Skin(
			TinyExtraBarsG:Get({BF_SETTINGS_GROUP, "SkinID"}, nil),
			TinyExtraBarsG:Get({BF_SETTINGS_GROUP, "Gloss"}, nil),
			TinyExtraBarsG:Get({BF_SETTINGS_GROUP, "Backdrop"}, nil),
			TinyExtraBarsG:Get({BF_SETTINGS_GROUP, "Colors"}, nil))
	end

	-- LibKeyBound
	TEB_LibKeyBound = LibStub("LibKeyBound-1.0", false)
	if (TEB_LibKeyBound) then
		TEB_LibKeyBound.RegisterCallback(EventFrame, "LIBKEYBOUND_ENABLED")
		TEB_LibKeyBound.RegisterCallback(EventFrame, "LIBKEYBOUND_DISABLED")
		TEB_LibKeyBound.RegisterCallback(EventFrame, "LIBKEYBOUND_MODE_COLOR_CHANGED")
	end

	-- toolsFrame
	toolsFrame = CreateFrame('Frame', 'TinyExtraBarsToolsFrame', UIParent, 'TinyExtraBarsToolsFrameTemplate')
	toolsFrame:ClearAllPoints()
	local left = TinyExtraBarsPC:Get({'ToolsFrame', 'pos', 'left'}, 935)
	local top = TinyExtraBarsPC:Get({'ToolsFrame', 'pos', 'top'}, 600)
	toolsFrame:ClearAllPoints()
	toolsFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
	TEB_SettingsMode = TinyExtraBarsPC:Get({'ToolsFrame', 'SettingsMode'}, true)
	toolsFrame.sliderButtonSize:SetValue(TEB_BUTTON_SIZE)
	_G[toolsFrame.sliderButtonSize:GetName().."Text"]:SetText(TEB_BUTTON_SIZE)
	toolsFrame.sliderButtonSpace:SetValue(TEB_BUTTON_SPACING)
	_G[toolsFrame.sliderButtonSpace:GetName().."Text"]:SetText(TEB_BUTTON_SPACING)

	TEB_LastEffectMode = TinyExtraBarsG:Get({'ToolsFrame', 'LastEffectMode'}, false)
	toolsFrame.checkBoxLastEffect:SetChecked(TEB_LastEffectMode)
	TEB_LastEffectAverageMode = TinyExtraBarsG:Get({'ToolsFrame', 'LastEffectAverageMode'}, false)
	toolsFrame.checkBoxLastEffectAverage:SetChecked(TEB_LastEffectAverageMode)

	TEB_HideBorders = TinyExtraBarsG:Get({'ToolsFrame', 'HideBorders'}, false)
	toolsFrame.checkBoxHideBorders:SetChecked(TEB_HideBorders)
	TEB_FullRangeArtwork = TinyExtraBarsG:Get({'ToolsFrame', 'FullRangeArtwork'}, false)
	toolsFrame.checkBoxFullRangeArtwork:SetChecked(TEB_FullRangeArtwork)
	TEB_UseShift = TinyExtraBarsG:Get({'ToolsFrame', 'UseShift'}, false)
	toolsFrame.checkBoxUseShift:SetChecked(TEB_UseShift)
	
	presetFrame = CreateFrame('Frame', 'TinyExtraBarsPresetsFrame', UIParent, 'TinyExtraBarsPresetsFrameTemplate')
	presetFrame.Bars = {}
	local prevBtn = nil
	for i = 1, LIST_ELEMENT_COUNT do
		presetFrame.Bars[i] = CreateListButton(i, presetFrame, presetFrame.ScrollFrame)
		local btn = presetFrame.Bars[i]
		btn:ClearAllPoints()
		if not(prevBtn) then
			btn:SetPoint("TOPLEFT", presetFrame.ScrollFrame, "TOPLEFT", 8, -8)
		else 
			btn:SetPoint("TOPLEFT", prevBtn, "BOTTOMLEFT", 0, -2)
		end
		prevBtn = btn
	end
	local height = (LIST_ELEMENT_HEIGHT + 2) * LIST_ELEMENT_COUNT + 2
	presetFrame.ScrollFrame:SetHeight(height)
	--fill presetFrame.Presets from global saves
	presetFrame.Presets = {}
	local temp = TinyExtraBarsG:Get({'Presets'}, {})
	for k, v in pairs(temp) do
		table.insert(presetFrame.Presets, k)
	end
	TinyExtraBarsPresetsUpdate()
	
	customizeFrame = _G["MacroText_CustomizeFrame"]
	if not(customizeFrame) then
		customizeFrame = CreateFrame('Frame', 'MacroText_CustomizeFrame', UIParent, 'MacroTextCustomizeFrame_Template')
		RegisterStateDriver(customizeFrame, "visibility", "[combat] hide; [vehicleui] hide")
		tinsert(UISpecialFrames, customizeFrame:GetName())
	end
	iconSelectionDialogPopupFrame = _G["IconSelectionDialogPopup"]
	if not(iconSelectionDialogPopupFrame) then
		iconSelectionDialogPopupFrame = CreateFrame('Frame', 'IconSelectionDialogPopup', customizeFrame, 'IconSelectionDialogPopupTemplate')
		tinsert(UISpecialFrames, iconSelectionDialogPopupFrame:GetName())
	end
	
	RegisterStateDriver(toolsFrame, "visibility", "[combat] hide; [vehicleui] hide")
	RegisterStateDriver(presetFrame, "visibility", "[combat] hide; [vehicleui] hide")

	-- overlayFrame
	overlayFrame = CreateFrame('Frame', 'TinyExtraBarsCreateBarOverlay', UIParent, 'TinyExtraBarsCreateBarOverlayTemplate')

	tinsert(UISpecialFrames, presetFrame:GetName())
	tinsert(UISpecialFrames, overlayFrame:GetName())

	-- minimap button
	minimapButton = CreateFrame('Button', 'TinyExtraBarsMinimapButton', Minimap, 'TinyExtraBarsMinimapButtonTemplate')

	CreateFrame("BUTTON", "TEB_Toggler", UIParent, "SecureHandlerClickTemplate")
	TEB_Toggler:SetAttribute("_onclick", TEB_ToggleSnippet)
	TEB_Toggler:SetAttribute("toggle_enabled", false)
	SetBinding("CTRL-BUTTON3", "CLICK TEB_Toggler:LeftButton")

	-- create containers
	TinyExtraBars_LoadContainers()
	
	RegisterEvents()
	
	IsInit = true
	
	if TEB_SettingsMode then
		toolsFrame:Show()
	end
	
	SLASH_TINYEXTRABARS1, SLASH_TINYEXTRABARS2 = "/teb", "/tinyextrabars"
	SlashCmdList["TINYEXTRABARS"] = TinyExtraBars_SlashHandler
end

function TinyExtraBarsMinimapButton_OnClick(self, button)
	if IsInit then
		if (button == "LeftButton") then
			if toolsFrame:IsShown() then
				toolsFrame:Hide()
			elseif not(InCombatLockdown()) then
				toolsFrame:Show()
			end
		end
	end
end

function TinyExtraBarsMinimapButton_OnLoad(self)
	local x = TinyExtraBarsG:Get({'minimap_button', 'x'}, 62 - (80 * cos(5)))
	local y = TinyExtraBarsG:Get({'minimap_button', 'y'}, (80 * sin(5)) - 62)
	self:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", x, y)
end

function TinyExtraBarsMinimapButton_OnMouseUp(self, button)
	if (button == "RightButton") then
		local minimap = _G["Minimap"]
		if minimap then
			local xf = self:GetLeft()
			local yf = self:GetTop()
			local xm = minimap:GetLeft()
			local ym = minimap:GetTop()
			--local s = frame:GetEffectiveScale()
			--x, y = x/s, y/s
			local x = xf - xm
			local y = yf - ym
			TinyExtraBarsG:Set({'minimap_button', 'x'}, x)
			TinyExtraBarsG:Set({'minimap_button', 'y'}, y)
		end
	end
end

function TinyExtraBarsToggleCreateBar(forcedOff)
	if forcedOff then
		createBarMode = false
	else
		createBarMode = not(createBarMode)
	end
	
	if InCombatLockdown() then
		createBarMode = false
		return
	end
	
	if createBarMode then
		SetCursor("REPAIRNPC_CURSOR")
		overlayFrame:Show()
	else
		SetCursor(nil)
		overlayFrame:Hide()
	end
end

local function OnEvent(self, event, ...)
	if EventHandlersTable[event] then
		EventHandlersTable[event](self, ...)
	elseif event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" or event == "UPDATE_MACROS" or event == "PET_JOURNAL_LIST_UPDATE" then
		EnteringWorldOrVariablesLoaded = EnteringWorldOrVariablesLoaded + 1
		if event == "PLAYER_ENTERING_WORLD" then EventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD") end
		if event == "VARIABLES_LOADED" then EventFrame:UnregisterEvent("VARIABLES_LOADED") end
		if event == "PET_JOURNAL_LIST_UPDATE" then EventFrame:UnregisterEvent("PET_JOURNAL_LIST_UPDATE") end
		if event == "UPDATE_MACROS" then
			--local numglobal, numperchar = GetNumMacros()
			--print('UpdateMacroCount = '..UpdateMacroCount..', numglobal = '..numglobal..', numperchar = '..numperchar)
			UpdateMacroCount = UpdateMacroCount + 1
			if UpdateMacroCount > 1 then
				EventFrame:UnregisterEvent("UPDATE_MACROS")
			end
		end
		if EnteringWorldOrVariablesLoaded > 4 then
			Init()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		EventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		Init()
	elseif event == "PLAYER_REGEN_DISABLED" then
		TEB_SettingsMode = false
		TinyExtraBars_SetButtonsMovable(TEB_SettingsMode)
	end
end

EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("VARIABLES_LOADED")
EventFrame:RegisterEvent("UPDATE_MACROS")
EventFrame:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
EventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

EventFrame:SetScript("OnEvent", OnEvent)

function EventFrame:LIBKEYBOUND_ENABLED()
	TEB_KeybindMode = true
end

function EventFrame:LIBKEYBOUND_DISABLED()
	TEB_KeybindMode = nil
end

function EventFrame:LIBKEYBOUND_MODE_COLOR_CHANGED()
	--print("color changed")
end

