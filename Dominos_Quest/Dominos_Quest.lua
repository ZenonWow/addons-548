local DQuest = Dominos:NewModule('Quest')
local Quest = Dominos:CreateClass('Frame', Dominos.Frame)

function DQuest:Load()
	self.frame = Quest:New()
	self.frame:SetFrameStrata('LOW')
end

function DQuest:Unload()
	self.frame:Free()
end

function Quest:New()
	local f = self.super.New(self, 'quest')
	f:VerifyDefaults()
	f:TrackerSetup()
	f:Layout()
	return f
end

function Quest:VerifyDefaults()
	for key, value in pairs(self:GetDefaults()) do
		self.sets[key] = self.sets[key] or value
	end
end

function Quest:GetDefaults()
	return {
		scale = 1,
		point = 'RIGHT',
		x = 0,
		y= 0,
		width = 220,
		height = 350,
		padding = 0,
		bgPad = -12,
		bgWidth = 32,
		bgName = 'Silver',
		bgFile = 'Interface/ItemTextFrame/ItemText-Silver-TopLeft',
		edgeName = 'Wood',
		edgeFile = 'Interface/ACHIEVEMENTFRAME/UI-Achievement-WoodBorder',
		edgecolor = {r = 1, g = 1, b = 1, a = .7},
		bgcolor = {r = 1, g = 1, b = 1, a = .5},
		ePad = -9,
--		xItems = 1,
--		yItems = -22,
--		leftItems = true,
--		itemScale = 90,
		speed = 16,
	}
end

local function NewScroller(parent, name)
	if _G[parent:GetName().."ScrollFrame"] then
		return _G[parent:GetName().."ScrollFrame"]
	end
	
	local frame = CreateFrame("ScrollFrame", parent:GetName().."ScrollFrame", parent)
	frame:SetPoint("Center")
	
	frame.bar = CreateFrame("Slider", frame:GetName().."ScrollBar", frame, "OptionsSliderTemplate")
	frame.bar:SetOrientation("VERTICAL")
	frame.bar:SetWidth(16)

	local loading = true
	frame.bar:SetScript("OnShow", function (self)
		if loading then
			loading = nil
			return
		end
		_G[frame.bar:GetName() .. 'High']:SetText("")
		_G[frame.bar:GetName() .. 'Low']:SetText("")
		--parent:UpdateScroll()
	end)
	
	frame.bar:SetScript("OnValueChanged", function (l, value)
		_G[frame.bar:GetName() .. 'High']:SetText("")
		_G[frame.bar:GetName() .. 'Low']:SetText("")
		frame:SetVerticalScroll(value)
		--parent:UpdateMax()
	end)
	frame.bar:SetScript("OnMouseWheel", function(self, delta)
		self:SetValue(self:GetValue() - (delta * self:GetValueStep()))
	end)
	frame:SetScript("OnMouseWheel", function(self, delta)
		self.bar:GetScript("OnMouseWheel")(self.bar, delta)
	end)

	frame.bar:SetMinMaxValues(1, 200) 
	frame.bar:SetValueStep(10) 
	frame.bar.scrollStep = 1 
	frame.bar:SetValue(0) 

	--if hasContent then
 		frame.content = CreateFrame("Frame", frame:GetName().."Content", frame)
		frame.content:SetSize(128, 1000)
		frame:SetScrollChild(frame.content)
		frame.content:SetPoint("TopLeft")
	--end

	return frame, frame.bar, frame.content
end

function Quest:TrackerSetup()
	if self.setup then
		return
	end
--	WATCHFRAME_ITEM_WIDTH = 0
	WatchFrame:SetMovable(true)
	WatchFrame:SetUserPlaced(true)
	WatchFrameLines:SetMovable(true)
	WatchFrameLines:SetUserPlaced(true)
	self.container = self.container or CreateFrame("Frame", self:GetName().."Container", self)
	self.container:SetPoint("Center")
	self.scroll = self.scroll or NewScroller(self.container, "Scroller", true)
	self.scroll:SetScript("OnSizeChanged", function()
		local w = self.scroll:GetWidth() - self.lines.offset
		WATCHFRAME_EXPANDEDWIDTH = w
		WATCHFRAME_MAXLINEWIDTH = w
		WatchFrame_Update();
		self.scroll.bar:SetHeight(self.scroll:GetHeight())
		self:UpdateScroll()
	end)
	self.lines = self.lines or CreateFrame("Frame", nil, self)
	self.lines.offset = 24
	self.lines:ClearAllPoints()
	self.lines:SetParent(self.scroll.content)
	self.lines:SetAllPoints(self.scroll.content)
	self.lines:SetPoint("TopLeft", self.scroll.content, 0, 0)
	WatchFrameLines:SetParent(self.scroll.content)
	WatchFrameLines:SetPoint("TopLeft", self.lines.offset, 0)
	WatchFrameLines:SetHeight(10000)
	self.container.watch = WatchFrame
	self.container.watch:ClearAllPoints()
	self.container.watch:SetParent(self.scroll.content)
	self.container.watch:SetPoint("TopLeft", self.scroll.content, 0, 0)
	self.container.watch:SetHeight(100000)
	self.container.title = CreateFrame("Frame", self.container:GetName().."Title", self)
	self.container.title:SetHeight(20)
	self.container.title:SetPoint("BottomLeft", self.scroll, "TopLeft")
	self.container.title:SetPoint("BottomRight", self.scroll, "TopRight")
	self.header = _G["WatchFrameHeader"]
	self.collapse = _G["WatchFrameCollapseExpandButton"]	
	self.header:SetParent(self.container.title)
	self.collapse:SetParent(self.container.title)
	self.collapse:HookScript("OnClick", function()
		self:UpdateCollapse()
	end)

	hooksecurefunc("WatchFrame_Update", function()
		self:UpdateScroll(true)
	end)

	self.setup = true
end

function Quest:ToggleScroll()
	self.scroll.bar:SetValue(0)
	self.scroll:ClearAllPoints()
	local ePad = -self.sets.ePad
	 if not self.sets.bgEnable then
	 	ePad = 0
	 end
	
	
	self.scroll:SetPoint("TopLeft", self.container, ePad, -(19 + ePad))
	self.scroll:SetPoint("BottomRight", self.container, -ePad, ePad + 2)
end

function Quest:UpdateScroll(isUpdate)
	local num = #WATCHFRAME_QUESTLINES + #WATCHFRAME_ACHIEVEMENTLINES + #WATCHFRAME_TIMERLINES
	local cont = self.scroll
	local line = _G["WatchFrameLine"..num+1]
	local height = (cont:GetHeight())
	local diff
	if (cont and line) then
		local contBottom = cont:GetBottom()
		local lineBottom  = line:GetBottom()
		if not lineBottom and not isUpdate then
			WatchFrame_Update()
			self:ToggleScroll()
			return --self:UpdateScroll()
		end		
		if (lineBottom and contBottom) and (lineBottom < contBottom) and (not self.sets.noScroll) then
			local ePad = self.sets.ePad
			if not self.sets.bgEnable then
				ePad = 0
			end	
			self.scroll.bar:SetMinMaxValues(0, math.abs(lineBottom - contBottom) - ePad)
		else
			self.scroll.bar:SetValue(0)
			self.scroll.bar:SetMinMaxValues(0, 0)
		end
	end
end

function Quest:UpdateCollapse()
	self.collapse:ClearAllPoints()
	self.header:ClearAllPoints()
	if WatchFrame.userCollapsed then
		self.collapse:SetPoint("Right", self.container.title)
		self.header:SetPoint("Left", self.container.title)
	else
		self.collapse:SetPoint("Right", self.container.title)
		self.header:SetPoint("Left", self.container.title)
	end
end

function Quest:Layout()
	self.scroll.bar:SetValueStep(self.sets.speed)
	local height = self.sets.height
	local width = self.sets.width
	local scale = self.sets.scale
	local pad = self.sets.padding
	self:SetSize(width+pad, height+pad)
	self.container:SetSize(width, height)
	self:ToggleScroll()
	self:UpdateCollapse()
	self:UpdateScroll()
	self:UpdateBackground()
	--self:UpdateItems()
end

function Quest:UpdateItems()
	for j = 1, WATCHFRAME_NUM_ITEMS do
		local item = _G["WatchFrameItem" .. j]
		if item then
			item:SetFrameLevel(9)
			local a, p = item:GetPoint()
			item:ClearAllPoints()
			if self.sets.leftItems then
				item:SetPoint("TopRight", p, "TopLeft", self.sets.xItems , self.sets.yItems)
			else
				item:SetPoint("TopLeft", p, "TopRight", self.sets.xItems , self.sets.yItems)
			end
			item:SetScale(self.sets.itemScale/100)
		end
	end
end

function Quest:ScrollBar(enable, value)
	self.sets[value] = enable or nil
	self:Layout()
end

function Quest:UpdateBackground()
	if self.sets.bgEnable then
		self.container:SetBackdrop({
			bgFile=self.sets.bgFile,
			edgeFile=self.sets.edgeFile,
			insets = {left = -self.sets.bgPad, right = -self.sets.bgPad, top = -self.sets.bgPad, bottom = -(self.sets.bgPad+1)},
			edgeSize = self.sets.bgWidth,
		})
		
	self.container:SetBackdropBorderColor(self.sets.edgecolor.r, self.sets.edgecolor.g, self.sets.edgecolor.b, self.sets.edgecolor.a)
	self.container:SetBackdropColor(self.sets.bgcolor.r, self.sets.bgcolor.g, self.sets.bgcolor.b, self.sets.bgcolor.a)
	else
		self.container:SetBackdrop({})
	end
end

local function NewSizingSlider(p, name, min, max, arg)
	local s = p:NewSlider(name, min, max, 1, OnShow)
	s.OnShow = function(self)
		self:SetValue(self:GetParent().owner.sets[arg or string.lower(name)])
	end
	s.UpdateValue = function(self, value)
		local f = self:GetParent().owner
		f.sets[arg or string.lower(name)] = value
		f:Layout()
	end
end

local function NewCheckButton(p, name, value)
	local check = p:NewCheckButton(name)
	check:SetScript('OnClick', function(self) p.owner:ScrollBar(self:GetChecked(), value) end)
	check:SetScript('OnShow', function(self) self:SetChecked(p.owner.sets[value]) end)
end

local function AddLayoutPanel(menu)
	local p = menu:NewPanel(LibStub('AceLocale-3.0'):GetLocale('Dominos-Config').Layout)
	p:NewOpacitySlider()
	p:NewFadeSlider()
	NewSizingSlider(p, "Width", 100, 300)
	NewSizingSlider(p, "Height", 120, GetScreenHeight())
	NewSizingSlider(p, "Padding", -16, 32)
	p:NewScaleSlider()
end

local function AddScrollPanel(menu)
	local p = menu:NewPanel("Scroll")
	NewSizingSlider(p, "Speed", 1, 100)
	NewCheckButton(p, "Disable Scrolling", "noScroll")
end

local function newButton(menu, name, isColor)
	local b = CreateFrame("Button", menu:GetName()..name, menu, "UIMenuButtonStretchTemplate")
	b:SetSize(140, 25)
	b:SetText(name)
	b.text = b:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	b.text:SetDrawLayer(BACKGROUND)
	if isColor then
		b.texture = b:CreateTexture(nil, "BACKGROUND")
		b.texture:SetDrawLayer("BACKGROUND", -8)
	else
		b.texture = CreateFrame("Frame", b:GetName().."texture", b)
		b.texture:SetFrameLevel(1)
	end
	
	b.text:SetDrawLayer("ARTWORK", 7)

	
	
	b.texture:SetPoint("TopLeft", b, "BottomLeft")
	b.texture:SetPoint("TopRight", b, "BottomRight")
	b.texture:SetHeight(25)
	b.text:SetAllPoints(b.texture)
	local prev = menu.checkbutton
	if prev then
		b:SetPoint('TopLeft', prev.texture or prev, 'BottomLeft', 0, -2)
	else
		b:SetPoint('TOPLEFT', 2, 0)
	end
	menu.checkbutton = b
	menu.height = menu.height + 52
	return b
end

local function AddTexturePickerButton(menu, name, keyName, keyPath)
	local b = newButton(menu, name)
	
	b:SetScript("OnShow", function(self)
			b.texture:SetBackdrop({})
			b.text:SetText(menu.owner.sets[keyName])
			if name == "Border" then
				b.texture:SetBackdrop({
					edgeFile= menu.owner.sets[keyPath],
					edgeSize = 16,

				})
			else
				b.texture:SetBackdrop({
					bgFile= menu.owner.sets[keyPath] ,
				})
			end
	end)
	b:SetScript("OnClick", function(self)
		ShowTexturePicker(string.lower(name), function(textureName, texturePath)
			menu.owner.sets[keyName] = textureName
			menu.owner.sets[keyPath] = texturePath
			self:GetScript("OnShow")(self)
			menu.owner:Layout()
		end)
	end)
	return b
end

local function AddColorPickerButton(menu, name, key)
	local b = newButton(menu, name, 1)



	local function ShowColorPicker(r, g, b, a, changedCallback)
			ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = nil, nil;
			ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = nil, nil, nil;
			ColorPickerFrame:SetColorRGB(r,g,b);
			ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
			ColorPickerFrame.previousValues = {r,g,b,a};
			ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback;
			ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
			ColorPickerFrame:Show();
		end


	
	b:SetScript("OnShow", function(self)
		local saved = menu.owner.sets[key]
		b.texture:SetTexture(saved.r, saved.g, saved.b, saved.a)
	end)
	b:SetScript("OnClick", function(self)
		local saved = menu.owner.sets[key]
		local r, g, b, a = saved.r, saved.g, saved.b, saved.a
		ShowColorPicker(r, g, b, a, function(restore)
			local newR, newG, newB, newA;
			if restore then
				newR, newG, newB, newA = unpack(restore);
			else
				newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
			end
			saved.r, saved.g, saved.b, saved.a = newR, newG, newB, newA
			self:GetScript("OnShow")(self)
			menu.owner:Layout()
		end)
	end)
	
	return b
end

local function AddBackdropPanel(menu)
	local p = menu:NewPanel("Background")
	NewSizingSlider(p, "Border Width", 0, 60, "bgWidth")
	NewSizingSlider(p, "Background Pad", -32, 32, "bgPad")
	NewSizingSlider(p, "Content Pad", -32, 32, "ePad")
	NewCheckButton(p, "Enable", "bgEnable")
	AddTexturePickerButton(p, "Background", "bgName", "bgFile")
	AddColorPickerButton(p, "BG Color", "bgcolor")
	AddTexturePickerButton(p, "Border", "edgeName", "edgeFile")
	AddColorPickerButton(p, "Border Color", "edgecolor")
end

local function AddItemsPanel(menu)
	local p = menu:NewPanel("Items")


	NewSizingSlider(p, "X", -100, 100, "xItems")
	NewSizingSlider(p, "Y", -100, 100, "yItems")
	NewSizingSlider(p, "Scale", 50, 150, "itemScale")

	NewCheckButton(p, "Left", "leftItems")
end

function Quest:CreateMenu()
	local menu = Dominos:NewMenu(self.id)
	AddLayoutPanel(menu)
	AddScrollPanel(menu)
--	AddItemsPanel(menu)
	AddBackdropPanel(menu)
	self.menu = menu
end
