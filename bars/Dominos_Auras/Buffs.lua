BuffFrame:Hide()

local BuffModule = Dominos:NewModule('Buff')
local AuraFrame = Dominos:CreateClass('Frame', Dominos.Frame)

function BuffModule:Load()
	self.frame = AuraFrame:New()
end

function BuffModule:Unload()
	self.frame:Free()

end

function AuraFrame:New()
	local f = self.super.New(self, 'buff')
	f:SetFrameStrata('LOW')
	f.headerAura = Dominos:NewAurabar("DominosBuffs", "HELPFUL", f)
	f:LoadButtons()
	f:Layout()
	return f
end

function AuraFrame:GetDefaults()
	return {
		scale = 1,
		point = 'CENTER',
		y = 60,
		x = 0,
		spacing = 0,
		columns = 10,
		rows = 2,
		isRightToLeft = false,
		isBottomToTop = false,
		method = 1, --time, index or name
		direction = true,
		padding = 0,
	}
end

function AuraFrame:NumButtons()
	return self.sets.cols * self.sets.rows
end
local items = {"Time", "Index", "Name",}
function AuraFrame:Layout()
	if not InCombatLockdown() then
		local sets = self.sets
		local w,h = 30, 30
		local newWidth = max((((30 + sets.spacing) * sets.columns) - sets.spacing) +(sets.padding*2), 8)
		local newHeight = max((((30 + sets.spacing) * sets.rows) - sets.spacing) +(sets.padding*2), 8)
		self:SetSize(newWidth, newHeight)

		local hori, vert, padhori, padvert
		
		if not sets.isRightToLeft then	
			hori = "Left"
			padhori = sets.padding
		else
			hori = "Right"
			padhori = -sets.padding
		end
		if not sets.isBottomToTop then
			vert = "Top"
			padvert = -sets.padding
		else
			vert = "Bottom"
			padvert = sets.padding
		end

		self.headerAura:ClearAllPoints()
		self.headerAura:SetPoint(vert..hori, self, vert..hori, padhori, padvert)
		local dir = "+"
		if sets.direction == 1 then
			dir = "-"
		end
		
		local method = items[sets.method]
		self.headerAura:UpdateLayout(sets.spacing, sets.columns, sets.rows, sets.isRightToLeft, sets.isBottomToTop, method, dir)
		self.headerAura.event:GetScript("OnEvent")()
	end
end
local function CreateRowsSlider(p)
	local s = p:NewSlider("Rows", 1, 20, 1)

	s.OnShow = function(self)
		self:SetValue(self:GetParent().owner.sets.rows)
	end

	s.UpdateValue = function(self, value)
		local f = self:GetParent().owner
		f.sets.rows = value
		f:Layout()
	end
end
local function NewColumnsSlider(p)
	local L = LibStub('AceLocale-3.0'):GetLocale('Dominos-Config')

	local s = p:NewSlider(L.Columns, 1, 20, 1)

	s.OnShow = function(self)
		self:SetValue(self:GetParent().owner.sets.columns)
	end

	s.UpdateValue = function(self, value)
		local f = self:GetParent().owner
		f.sets.columns = value
		f:Layout()
	end
end
local function NewPaddingSlider(p)
	local L = LibStub('AceLocale-3.0'):GetLocale('Dominos-Config')

	local s = p:NewSlider(L.Padding, -13, 32, 1)

	s.OnShow = function(self)
		self:SetValue(self:GetParent().owner.sets.padding)
	end

	s.UpdateValue = function(self, value)
		local f = self:GetParent().owner
		f.sets.padding = value
		f:Layout()
	end
end
local function AddLayoutPanel(menu)
	local p = menu:NewPanel(LibStub('AceLocale-3.0'):GetLocale('Dominos-Config').Layout)
	p:NewOpacitySlider()
	p:NewFadeSlider()
	p:NewScaleSlider()
	NewPaddingSlider(p)
	p:NewSpacingSlider()
	CreateRowsSlider(p)
	NewColumnsSlider(p)
end

local function AddAdvancedLayout(self)
	local L = LibStub('AceLocale-3.0'):GetLocale('Dominos-Config')
	local panel = self:NewPanel(L.Advanced)

	panel:NewLeftToRightCheckbox()
	panel:NewTopToBottomCheckbox()
	panel:NewShowInOverrideUICheckbox()
	panel:NewShowInPetBattleUICheckbox()
	
	panel.width = 256
	return panel
end

local function AddSortPanel(self)
	local L = LibStub('AceLocale-3.0'):GetLocale('Dominos-Config')
	local p = self:NewPanel("Sorting")
	
	local A = p:NewCheckButton("Reverse")
	A:SetScript('OnClick', function(self)
		self:GetParent().owner.sets.direction = self:GetChecked()
		self:GetParent().owner:Layout()
	end)
	A:SetScript('OnShow', function(self) self:SetChecked(self:GetParent().owner.sets.direction) end)
	p.height = p.height + 50



	local c =  CreateFrame("Frame", "DropDownMenuTest", p, "UIDropDownMenuTemplate")
	c:ClearAllPoints()
	c:SetPoint("BottomLeft", 5, 5)
	c:Show()
	local title = c:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
	title:SetPoint("BottomLeft", c, "TopLeft", 10, 0)
	title:SetText("Sort Method")
	local function OnClick(s)
		UIDropDownMenu_SetSelectedID(c, s:GetID())
		c:GetParent().owner.sets.method = s:GetID()
		c:GetParent().owner:Layout()
	end

	local function initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for k,v in pairs(items) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = OnClick
			UIDropDownMenu_AddButton(info, level)
		end
	end

	UIDropDownMenu_Initialize(c, initialize)
	UIDropDownMenu_SetWidth(c, 100);
	UIDropDownMenu_SetButtonWidth(c, 124)
	c:SetScript("OnShow", function()
		UIDropDownMenu_Initialize(c, initialize)
		UIDropDownMenu_SetSelectedID(c, c:GetParent().owner.sets.method)
	end)
	UIDropDownMenu_JustifyText(c, "CENTER")

	return p
end

function AuraFrame:CreateMenu()
	local menu = Dominos:NewMenu(self.id)
	AddLayoutPanel(menu)
	AddSortPanel(menu)
	AddAdvancedLayout(menu)
	self.menu = menu
end