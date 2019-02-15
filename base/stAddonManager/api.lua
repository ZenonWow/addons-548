local M, F, L, D = unpack(stAddonManager) --Import: Modules, Functions/Utilities, Locales, Data

F.dummy = function() end

function GetCustomUI()
	if (AsphyxiaUI or DuffedUI or Tukui) then
		return 'Tukui'
	elseif ElvUI then
		return 'ElvUI'
	elseif SaftUI then
		return 'SaftUI'
	else
		return ''
	end			
end

function F.Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = API.dummy
	object:Hide()
end

function F.StripTextures(object, kill)
	for i=1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region:GetObjectType() == 'Texture' then
			if kill then
				region:Kill()
			else
				region:SetTexture(nil)
			end
		end
	end		
end

function F.SetFontTemplate(text)
	if GetCustomUI() == 'Tukui' then

	elseif GetCustomUI() == 'ElvUI' then

	elseif GetCustomUI() == 'SaftUI' then
		text:SetFontTemplate()
	else			
		text:SetFont(unpack(D.Saved.Font))
		text:SetShadowOffset(0,0)
	end
end

function F.GetBackdrop(inset)
	inset = inset or 2

	return {
		bgFile = D.blankTex, 
		edgeFile = D.blankTex, 
		tile = false, tileSize = 0, edgeSize = 1, 
		insets = { left = inset, right = inset, top = inset, bottom = inset}
	}
end

local function CreateShadow(f, t)
	if f.shadow then return end
			
	local shadow = CreateFrame('Frame', nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint('TOPLEFT', -3, 3)
	shadow:SetPoint('BOTTOMLEFT', -3, -3)
	shadow:SetPoint('TOPRIGHT', 3, 3)
	shadow:SetPoint('BOTTOMRIGHT', 3, -3)
	shadow:SetBackdrop( { 
		edgeFile = C['media'].glowTex, edgeSize = 3,
		insets = {left = 5, right = 5, top = 5, bottom = 5},
	})
	shadow:SetBackdropColor(0, 0, 0, 0)
	shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
	f.shadow = shadow
end

local function HideBorder(self)
	if self.insets then
		for _,inset in pairs(self.insets) do
			inset:Hide()
		end
	end
end

--Cleaner way to toggle borders
local function ShowBorder(self) self.innerborder:Show(); self.outerborder:Show(); end
local function HideBorder(self) self.innerborder:Hide(); self.outerborder:Hide(); end

local function CreateThickBorder(self)
	if self.outerborder then return end

	local backdrop = F.GetBackdrop(0)
	backdrop.bgFile = nil
	
	self.outerborder = CreateFrame("Frame", nil, self)
	F.SetInside(self.outerborder, self, -1)
	self.outerborder:SetBackdrop(backdrop)
	self.outerborder:SetBackdropBorderColor(0, 0, 0, 1)
	self.outerborder:SetFrameLevel(max(0, self:GetFrameLevel()-1))

	self.innerborder = CreateFrame("Frame", nil, self)
	F.SetInside(self.innerborder, self, 1)
	self.innerborder:SetBackdrop(backdrop)
	self.innerborder:SetBackdropBorderColor(0, 0, 0, 1)
	self.innerborder:SetFrameLevel(max(0, self:GetFrameLevel()-1))

	self.ShowBorder = ShowBorder
	self.HideBorder = HideBorder
end

local function ClearTemplate(self)
	self:SetBackdrop(nil)
	if self.HideBorder then self:HideBorder() end
	if self.shadow then self.shadow:Hide() end
end

local function SetTemplate(f, mods)
	mods = mods or ''

	--Start with a clean slate
	ClearTemplate(f)

	--If a clear template is desired, don't continue
	if strfind(mods, 'N') then return end

	local blankTex = D.blankTex
	f:SetBackdrop(F.GetBackdrop())

	if not f.ShowBorder then CreateThickBorder(f) else f:ShowBorder() end

	local r, g, b = unpack(D.Saved.Colors.backdrop)
	local a = strfind(mods, 'T') and 0.8 or 1
	f:SetBackdropColor(r, g, b, a)
	
	r, g, b = unpack(D.Saved.Colors.border)
	f:SetBackdropBorderColor(r, g, b)
end

function F.SetTemplate(self, temp, tex)
	if self.SetTemplate then
		self:SetTemplate(temp)
	else			
		SetTemplate(self, temp)
	end
end

function F.SetInside(obj, anchor, xOffset, yOffset)
	local off = 2
	if GetCustomUI() == 'SaftUI' then
		off = SaftUI[1].GetBorderInset()
	end 
	xOffset = xOffset or off
	yOffset = yOffset or xOffset or off
	anchor = anchor or obj:GetParent()

	if obj:GetPoint() then obj:ClearAllPoints() end
	
	obj:SetPoint('TOPLEFT', anchor, 'TOPLEFT', xOffset, -yOffset)
	obj:SetPoint('BOTTOMRIGHT', anchor, 'BOTTOMRIGHT', -xOffset, yOffset)
end

function F.CreateBackdrop(f, t, tex)
	--Use custom UI's function if available	
	if f.CreateBackdrop then f:CreateBackdrop(f, t, tex) return end

	if f.backdrop then return end
	if not t then t = 'Default' end

	local b = CreateFrame('Frame', nil, f)
	b:SetPoint('TOPLEFT', -2 + inset, 2 - inset)
	b:SetPoint('BOTTOMRIGHT', 2 - inset, -2 + inset)
	F.SetTemplate(b, t, tex)

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end
	
	f.backdrop = b
end

function F.CreateButton(name, parent, width, height, point, text, onclick)
	local button = CreateFrame('Button', name or nil, parent or UIParent)
	F.SetTemplate(button)
	button:SetSize(width or 50, height or 20) -- Just random numbers to have a basic form and 
	button:SetScript('OnEnter', function(self) self:SetBackdropBorderColor(unpack(D.Saved.Colors.hover)) end)
	button:SetScript('OnLeave', function(self) F.SetTemplate(self) end)
	
	if point then button:SetPoint(unpack(point)) end
	if onclick then button:SetScript('OnClick', onclick) end

	button.text = F.CreateFontString(button)
	button.text:SetText(text or '')
	button.text:SetPoint('CENTER')
	return button
end

function F.CreateCheckBox(name, parent, width, height, point, onclick)
	local checkbox = CreateFrame('CheckButton', name or nil, parent or UIParent)
	F.SetTemplate(checkbox)
	checkbox:SetSize(width or 10, height or 10)

	if point then checkbox:SetPoint(unpack(point)) end
	if onclick then checkbox:SetScript('OnClick', onclick) end	

	--Time to sexify these textures
	local checked = checkbox:CreateTexture(nil, 'OVERLAY')
	checked:SetTexture(unpack(D.Saved.Colors.hover))
	F.SetInside(checked, checkbox)
	checkbox:SetCheckedTexture(checked)

	local hover = checkbox:CreateTexture(nil, 'OVERLAY')
	hover:SetTexture(1, 1, 1, 0.3)
	F.SetInside(hover, checkbox)
	checkbox:SetHighlightTexture(hover)

	checkbox.text = F.CreateFontString(checkbox)
	return checkbox
end

function F.CreateEditBox(name, parent, width, height, point)
	local search = CreateFrame('EditBox', name or nil, parent or UIParent)
	search:SetSize(width or 150, height or 20)
	if point then search:SetPoint(unpack(point)) end
	F.SetTemplate(search)
	search:SetAutoFocus(false)
	search:SetTextInsets(5, 5, 0, 0)

	F.SetFontTemplate(search)
	search:SetTextColor(1, 1, 1)

	--Just some basic scripts to make sure your cursor doesn't get stuck in the edit box
	search:HookScript('OnEnterPressed', function(self) self:ClearFocus() end)
	search:HookScript('OnEscapePressed', function(self) self:ClearFocus() end)
	search:HookScript('OnEditFocusGained', function(self) self:SetBackdropBorderColor(unpack(D.Saved.Colors.hover)); self:HighlightText() end)
	search:HookScript('OnEditFocusLost', function(self)  F.SetTemplate(self); self:HighlightText(0,0) end)

	return search
end

function F.SetFont(self)
		self:SetFont(unpack(D.Saved.Font))
		self:SetShadowOffset(0, 0)
end

function F.CreateFontString(self)
	local fs = self:CreateFontString(nil, 'OVERLAY')
	F.SetFont(fs)
	return fs
end

function F.AddTooltip(self, func)
	assert(func, 'You need to add a function to execute line additions to tooltip')
	self:HookScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT', 5, -self:GetHeight())
		GameTooltip:ClearLines()
		
		func()
		
		GameTooltip:Show()
	end)
	self:HookScript('OnLeave', function() GameTooltip:Hide() end)
end

---------------------------
-- TABLE FUNCTIONS --------
---------------------------
--Make a copy of a table
function F.CopyTable(t, deep, seen)
	seen = seen or {}
	if t == nil then return nil end
	if seen[t] then return seen[t] end

	local nt = {}
	for k, v in pairs(t) do
		if deep and type(v) == 'table' then
			nt[k] = F.CopyTable(v, deep, seen)
		else
			nt[k] = v
		end
	end
	setmetatable(nt, F.CopyTable(getmetatable(t), deep, seen))
	seen[t] = nt
	return nt
end

--Merge two tables, with variables from t2 overwriting t1 when a duplicate is found
function F.MergeTable(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
		   F.MergeTables(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end

--Purge any variable of t1 who's value is set to the same as t2
function F.PurgeTable(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			F.PurgeTable(t1[k], t2[k])
		else
			if t1[k] == v then
				t1[k] = nil
			end
		end
	end
	return t1
end
