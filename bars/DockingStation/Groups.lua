local addonName, addon = ...

--[[----------------------------------------------------------------------------
Helpers
------------------------------------------------------------------------------]]
local recycled = { }

--[[----------------------------------------------------------------------------
Methods
------------------------------------------------------------------------------]]
local methods = {
	["Recycle"] = function(self)
		local name, panel = self.name, self.panel
		self:Hide()
		for index = #self, 1, -1 do
			self[index]:Recycle()
		end
		LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_icon')
		LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_label')
		if pluginType[name] == 'data source' then
			LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_suffix')
			LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_text')
			LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_value')
		end
		if panel and tremove_byVal(panel[self.section], self) then
			panel:AnchorChildren(self.section)
			panel[self] = nil
		end
		PurgeQueue(self)
		plugins[name] = nil
		self[0], self = self[0], wipe(self)
		recycled[#recycled + 1] = self
	end,

	["SetState"] = function(self)
		local id, section, index = GetPluginLocation(self.name)
		SetInheritance(self.name, id)
		local panel = panels[id]
		if panel then
			if self.settings.enable then
				self.panel, self.section, self.index = panel, section, index

				local children = panel[section]
				tremove_byVal(children, self)
				self:SetParent(panel)
				self:SetFrameStrata(panel:GetFrameStrata())
				self:SetFrameLevel(panel:GetFrameLevel() + 1)

				local insertPoint
				for i = 1, #children do
					if index <= children[i].index then
						insertPoint = i
						break
					end
				end
				tinsert(children, insertPoint or #children + 1, self)
				panel:AnchorChildren(section)
				panel[self] = true
				self:Refresh()
				self:Show()
				return
			end
		elseif not id then
			self.settings.enable = false
		end
		self:Recycle()
	end,

	["UpdateChildren"] = function(self)
		UpdateChildren(self)
		self:AnchorChildren()
	end,

	["UpdateWidth"] = function(self)
		self:SetWidth(self[#self]:GetRight() - self[1]:GetLeft() + 1)
		if self.section == "Center" and not self.moving then
			QueueMethod(self.panel, "UpdateCenterWidth")
		end
	end,

	["AnchorChildren"] = DoNothing,
	['AttachFrame'] = DoNothing,
	['DetachFrame'] = DoNothing,
	['EnableMouseWheel'] = DoNothing,
	['GetLeft'] = DoNothing,
	['GetName'] = DoNothing,
	['GetRight'] = DoNothing,
	['GetScript'] = DoNothing,
	["Refresh"] = DoNothing,
	['SetScript'] = DoNothing
}

mt = { __index = setmetatable(methods, mt), __metatable = addonName }
