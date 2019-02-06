local addonName, addon = ...

local strtrim = strtrim

local mt = getmetatable(InterfaceOptionsFrameHeaderText)

local SetText = mt.__index.SetText

local LDB_RegisterCallback, LDB_UnregisterCallback = addon.LDB_RegisterCallback, addon.LDB_UnregisterCallback

local LSM = LibStub('LibSharedMedia-3.0')

local plugins, safecall = addon.plugins, addon.safecall

local PurgeQueue, QueueMethod = addon.PurgeQueue, addon.QueueMethod

--[[----------------------------------------------------------------------------
Helpers
------------------------------------------------------------------------------]]
local recycled = { }

local function CleanString(value)
	if value then
		local ok, result = safecall(strtrim, value)
		if ok and result ~= "" then
			return result
		end
	end
end

local function DetectString(_, name, field, value, data)
	if CleanString(value) then
		PurgeQueue(plugins[name], "UpdateWidth")
		QueueMethod(plugins[name], "UpdateChildren")
	end
end

local function UpdateString(_, name, field, value, data)
	value = CleanString(value)
	if value then
		plugins[name][field]:SetText(value)
	else
		PurgeQueue(plugins[name], "UpdateWidth")
		QueueMethod(plugins[name], "UpdateChildren")
	end
end

local Update = {
	['label'] = function(_, name, field, value, data)
		local plugin = plugins[name]
		if not plugin.settings[field .. "UseName"] then
			value = CleanString(value)
		else
			LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field)
			value = nil
		end
		if not value then
			value = addon.pluginAlias[name] or strtrim(name)
		end
		if plugin.text or plugin.value then
			value = value .. ": "
		end
		plugin[field]:SetText(value)
	end,

	['suffix'] = function(_, name, field, value, data)
		value = CleanString(value)
		if value then
			plugins[name][field]:SetText(" " .. value)
		else
			PurgeQueue(plugins[name], "UpdateWidth")
			QueueMethod(plugins[name], "UpdateChildren")
		end
	end,

	['text'] = UpdateString,
	['value'] = UpdateString
}

--[[----------------------------------------------------------------------------
Methods
------------------------------------------------------------------------------]]
local methods = {
	["Recycle"] = function(self)
		self:Hide()
		LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. self.plugin.name .. '_' .. self.field)
		self.plugin[self.field] = nil
		PurgeQueue(self)
		self[0], self = self[0], wipe(self)
		recycled[#recycled + 1] = self
	end,

	["Refresh"] = function(self)
		local field, settings, _ = self._field, self.settings
		local shadow, outline = settings[field .. "Effect"] or 0
		if shadow > 2 then
			shadow = shadow - 2
		elseif shadow == 1 then
			outline, shadow = 'OUTLINE', 0
		elseif shadow == 2 then
			outline, shadow = 'THICKOUTLINE', 0
		end
		self:SetFont(LSM:Fetch('font', settings[field .. "Font"]), settings[field .. "Size"] * self.plugin.size, outline)
		self:SetTextColor(settings[field .. "ColorR"], settings[field .. "ColorG"], settings[field .. "ColorB"], settings[field .. "ColorA"])
		self:SetShadowOffset(shadow, -shadow)

		_, self.size = self:GetFont()
		self:SetSize(0, self.size)
		if settings[field .. "Fixed"] then
			local value = self:GetText()
			SetText(self, "...")
			local minWidth = self:GetStringWidth()
			SetText(self, settings[field .. "Fixed"])
			self:SetWidth(max(minWidth, self:GetStringWidth()))
			SetText(self, value)
		end
	end,

	['SetText'] = function(self, text)
		if self.settings[self._field .. "Override"] then
			text = addon.RemoveColorCodes(text)
		end
		SetText(self, text)
		QueueMethod(self.plugin, "UpdateWidth")
	end,

	['GetLeft'] = mt.__index.GetLeft,
	['GetRight'] = mt.__index.GetRight
}

mt = { __index = setmetatable(methods, mt), __metatable = addonName }

--[[----------------------------------------------------------------------------
Global to addon
------------------------------------------------------------------------------]]
function addon.CreateFontString(field, plugin, alias)
	local name = plugin.name
	local data = addon.dataObj[name]

	if field ~= 'label' and not CleanString(data[field]) then
		LDB_RegisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field, DetectString)
		return
	end

	local self = recycled[#recycled]
	if self then
		recycled[#recycled] = nil
		self:SetParent(plugin)
		self:ClearAllPoints()
		self:Show()
	else
		self = plugin:CreateFontString(nil, 'ARTWORK')
		self:SetFont([[Fonts\FRIZQT__.TTF]], 12)
		self:SetJustifyH('LEFT')
		self:SetJustifyV('MIDDLE')
		self:SetNonSpaceWrap(false)
		self:SetShadowColor(0, 0, 0, 0.5)
		self:SetText(" ")
		setmetatable(self, mt)
	end
	plugin[field], self.field, self.plugin, self.settings = self, field, plugin, plugin.settings
	self._field = alias or field

	self:SetSize(1, 1)
	self.size = 1
	
	LDB_RegisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field, Update[field])
	Update[field](nil, name, field, data[field], data)
	self:Refresh()
	return self
end
