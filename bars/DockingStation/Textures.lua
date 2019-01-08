local addonName, addon = ...

local tonumber, type = tonumber, type

local mt = getmetatable(InterfaceOptionsFrameHeader)

local LDB_RegisterCallback, LDB_UnregisterCallback = addon.LDB_RegisterCallback, addon.LDB_UnregisterCallback

local dataObj, plugins = addon.dataObj, addon.plugins
local PurgeQueue, QueueMethod = addon.PurgeQueue, addon.QueueMethod

--[[----------------------------------------------------------------------------
Helpers
------------------------------------------------------------------------------]]
local fields, recycled = { }, { }

local proxy = UIParent:CreateTexture(nil, 'ARTWORK')
proxy:Hide()

local function topercent(value, default)
	value = tonumber(value) or default
	if value >= 1 then
		return 1
	elseif value <= 0 then
		return 0
	end
	return value
end

local function DetectTexture(_, name, field, value, data)
	if type(value) == 'string' then
		PurgeQueue(plugins[name], "UpdateWidth")
		QueueMethod(plugins[name], "UpdateChildren")
	end
end

local function UpdateColors(_, name, field, value, data)
	QueueMethod(plugins[name][fields[field]], "RefreshColors")
end

local function UpdateCoords(_, name, field, value, data)
	field = fields[field]
	local self = plugins[name][field]
	local zoom = self.settings[field .. "Zoom"]
	if type(value) == 'table' then
		if #value == 4 then
			local L, R, T, B = topercent(value[1], 0), topercent(value[2], 1), topercent(value[3], 0), topercent(value[4], 1)
			local zX, zY = (R - L) * zoom, (B - T) * zoom
			self:SetTexCoord(L + zX, R - zX, T + zY, B - zY)
		else
			local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = topercent(value[1], 0), topercent(value[2], 0), topercent(value[3], 0), topercent(value[4], 1), topercent(value[5], 1), topercent(value[6], 0), topercent(value[7], 1), topercent(value[8], 1)
			local zXT, zXB, zYL, zYR = (URx - ULx) * zoom, (LRx - LLx) * zoom, (LLy - ULy) * zoom, (LRy - URy) * zoom
			self:SetTexCoord(ULx + zXT, ULy + zYL, LLx + zXB, LLy - zYL, URx - zXT, URy + zYR, LRx - zXB, LRy - zYR)
		end
	elseif self.blizIcon and self.settings[field .. "Trim"] then
		zoom = zoom * 0.86
		self:SetTexCoord(0.07 + zoom, 0.93 - zoom, 0.07 + zoom, 0.93 - zoom)
	else
		self:SetTexCoord(zoom, 1 - zoom, zoom, 1 - zoom)
	end
end

local function UpdateRatio(_, name, field, value, data)
	field = fields[field]
	local plugin = plugins[name]
	local self = plugin[field]
	self.size = self.settings[field .. "Size"] * plugin.size
	value = tonumber(value) or 1
	if value >= 1 then
		self:SetSize(self.size, self.size)
	elseif value <= 0.2 then
		self:SetSize(self.size * 0.2, self.size)
	else
		self:SetSize(self.size * value, self.size)
	end
	QueueMethod(plugin, "UpdateWidth")
end

local function UpdateTexture(_, name, field, value, data)
	local self = plugins[name][field]
	if type(value) == 'string' and self:SetTexture(value) then
		self.blizIcon = value:find([[^[Ii][Nn][Tt][Ee][Rr][Ff][Aa][Cc][Ee]\[Ii][Cc][Oo][Nn][Ss]\.+$]])
		UpdateCoords(nil, name, field, data[field .. 'Coords'], data)
	else
		PurgeQueue(self.plugin, "UpdateWidth")
		QueueMethod(self.plugin, "UpdateChildren")
	end
end

--[[----------------------------------------------------------------------------
Methods
------------------------------------------------------------------------------]]
local methods = {
	["Recycle"] = function(self)
		local field, name = self.field, self.plugin.name
		self:Hide()
		LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field)
		LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field .. 'B')
		LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field .. 'Coords')
		LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field .. 'G')
		LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field .. 'R')
		LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field .. 'Ratio')
		plugins[name][field] = nil
		PurgeQueue(self)
		self[0], self = self[0], wipe(self)
		recycled[#recycled + 1] = self
	end,

	["Refresh"] = function(self)
		local field, name = self.field, self.plugin.name
		local data = dataObj[name]
		UpdateRatio(nil, name, field, data[field .. 'Ratio'], data)
		UpdateTexture(nil, name, field, data[field], data)						-- Also updates coords
		self:RefreshColors()
	end,

	["RefreshColors"] = function(self)
		local data, field = dataObj[self.plugin.name], self.field
		local blue, green, red = data[field .. 'B'], data[field .. 'G'], data[field .. 'R']
		if blue or green or red then
			self:SetVertexColor(topercent(red, 0), topercent(green, 0), topercent(blue, 0))
		else
			self:SetVertexColor(1, 1, 1)
		end
	end,

	['GetLeft'] = mt.__index.GetLeft,
	['GetRight'] = mt.__index.GetRight,
--	['SetHeight'] = mt.__index.SetHeight,
	['SetSize'] = mt.__index.SetSize,
	['SetTexCoord'] = mt.__index.SetTexCoord,
	['SetTexture'] = mt.__index.SetTexture,
	['SetVertexColor'] = mt.__index.SetVertexColor,
--	['SetWidth'] = mt.__index.SetWidth
}

mt = { __index = setmetatable(methods, mt), __metatable = addonName }

--[[----------------------------------------------------------------------------
Global to addon
------------------------------------------------------------------------------]]
function addon.CreateTexture(field, plugin)
	local name = plugin.name

	local value = dataObj[name][field]
	if type(value) ~= 'string' or not proxy:SetTexture(value) then
		LDB_RegisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field, DetectTexture)
		return
	end

	local self = recycled[#recycled]
	if self then
		recycled[#recycled] = nil
		self:SetParent(plugin)
		self:ClearAllPoints()
		self:Show()
	else
		self = plugin:CreateTexture(nil, 'ARTWORK')
		setmetatable(self, mt)
	end
	plugin[field], self.field, self.plugin, self.settings = self, field, plugin, plugin.settings
	self._field = field

	self:SetSize(1, 1)
	self.size = 1

	if not fields[field] then
		fields[field] = field
		fields[field .. 'B'] = field
		fields[field .. 'Coords'] = field
		fields[field .. 'G'] = field
		fields[field .. 'R'] = field
		fields[field .. 'Ratio'] = field
	end

	LDB_RegisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field, UpdateTexture)
	LDB_RegisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field .. 'B', UpdateColors)
	LDB_RegisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field .. 'Coords', UpdateCoords)
	LDB_RegisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field .. 'G', UpdateColors)
	LDB_RegisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field .. 'R', UpdateColors)
	LDB_RegisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_' .. field .. 'Ratio', UpdateRatio)
	self:Refresh()
	return self
end
