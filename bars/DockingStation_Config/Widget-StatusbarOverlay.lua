if not _G[...] then return end

-- Based on AceGUI-3.0-SharedMediaWidgets StatusbarWidget by Yssaril

local AceGUI, LSM = LibStub('AceGUI-3.0'), LibStub('LibSharedMedia-3.0')

local media = LSM.MediaTable["statusbar_overlay"]
if type(media) ~= 'table' then
	media = { }
	LSM.MediaTable["statusbar_overlay"] = media
end
AceGUIWidgetLSMlists["statusbar_overlay"] = media

local list = LSM:List("statusbar_overlay")

local function SetText(self, text)
	if media[text] and self.texture:SetTexture(media[text]) then
		self.text:SetText(text)
		self.texture:SetAlpha(1)
		self.userdata.value = text
	else
		self.text:SetText("")
		self.texture:SetAlpha(0)
		self.userdata.value = ""
	end
end

local Type, Version = "LSM30_Statusbar_Overlay-Item-Toggle", 1
if (AceGUI:GetWidgetVersion(Type) or 0) < Version then
	local function Constructor()
		local self = AceGUI:Create('Dropdown-Item-Toggle')
		local frame = self.frame

		local bg = frame:CreateTexture(nil, 'BORDER')
		bg:SetPoint('TOPLEFT', frame, 'TOPLEFT', 6, -1)
		bg:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -4, 1)
		bg:SetTexture([[Interface\BUTTONS\WHITE8X8]])
		bg:SetVertexColor(0.5, 0.5, 0.5)

		local texture = frame:CreateTexture(nil, 'ARTWORK')
		texture:SetAllPoints(bg)
		texture:SetTexture([[Interface\BUTTONS\WHITE8X8]])
		texture:SetVertexColor(1, 1, 1)

		self.texture, self.type, self.SetText = texture, Type, SetText
		return self
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end

local Type, Version = "LSM30_Statusbar_Overlay", 3
if (AceGUI:GetWidgetVersion(Type) or 0) < Version then
	local function OnValueChanged(item, _, checked)
		local self = item.userdata.obj
		if checked then
			self:SetValue(item.userdata.value)
			self:Fire('OnValueChanged', item.userdata.value)
		else
			item:SetValue(true)
		end
		if self.open then
			self.pullout:Close()
		end
	end

	local function SetList(self)
		local pullout = self.pullout
		local items, item = pullout.items
		for index = 1, #items do
			items[index]:SetText(list[index])
		end
		for index = #items + 1, #list do
			item = AceGUI:Create("LSM30_Statusbar_Overlay-Item-Toggle")
			item.userdata.obj = self
			item:SetText(list[index])
			item:SetCallback('OnValueChanged', OnValueChanged)
			pullout:AddItem(item)
		end
		self.list = media
	end

	local function SetValue(self, value)
		self.value = value
		self:SetText(value or "")
	end

	local function Constructor()
		local self = AceGUI:Create('Dropdown')
		local dropdown = self.dropdown
		local name = dropdown:GetName()

		_G[name .. 'Left']:SetDrawLayer('BACKGROUND')
		_G[name .. 'Middle']:SetDrawLayer('BACKGROUND')
		_G[name .. 'Right']:SetDrawLayer('BACKGROUND')

		local bg = dropdown:CreateTexture(nil, 'BORDER')
		bg:SetPoint('TOPLEFT', _G[name .. 'Left'], 'TOPLEFT', 24, -24)
		bg:SetPoint('BOTTOMRIGHT', _G[name .. 'Right'], 'BOTTOMRIGHT', -39, 26)
		bg:SetTexture([[Interface\BUTTONS\WHITE8X8]])
		bg:SetVertexColor(0.5, 0.5, 0.5)

		local texture = dropdown:CreateTexture(nil, 'ARTWORK')
		texture:SetAllPoints(bg)
		texture:SetTexture([[Interface\BUTTONS\WHITE8X8]])
		texture:SetVertexColor(1, 1, 1)

		self.text:SetDrawLayer('OVERLAY')

		self.texture, self.type, self.SetList, self.SetText, self.SetValue = texture, Type, SetList, SetText, SetValue
		return self
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end
