local LIB, REVISION = "LibOptionsAssist-1.0", 5
if not LibStub then error(LIB .. " requires LibStub", 0) end

local lib, oldRevision = LibStub:NewLibrary(LIB, REVISION)
if not lib then return end

local ERROR_BASE = "bad argument #%d to %q (%s)"
local ERROR_TYPE = "bad argument #%d to %q (%s expected, got %s)"

local pcall, type = pcall, type

local entries = INTERFACEOPTIONS_ADDONCATEGORIES

--[[----------------------------------------------------------------------------
Version bridge
------------------------------------------------------------------------------]]
local appName, content, desc, frame, info, isValid, lock, mt, path, showing, title, widget, LOD, OnHide, OnShow

if oldRevision then
	if oldRevision < 5 then
		local getmetatable, fsDesc, fsInfo, fsTitle = getmetatable
		if oldRevision < 2 then
			appName, desc, info, path, title = lib._name, { }, lib._info, lib._path, lib._title
			LOD, OnHide, OnShow = lib._LOD, lib._OnHide, lib._OnShow
			content, frame, fsInfo, fsTitle = lib.content, lib.frame, lib.info, lib.title
			mt, showing, widget = wipe(lib.emulate_mt), lib.showing, lib.widget
			fsDesc = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall', 1)
			fsInfo:SetParent(frame)
			fsTitle:SetParent(frame)
			lib.title_bar:Hide()
			wipe(lib)
		else
			content, desc, frame, fsDesc, fsInfo, fsTitle, info, mt, appName, path, showing, title, widget, LOD, OnHide, OnShow = lib.__void()
			fsDesc:SetDrawLayer('ARTWORK', 1)
		end
		fsInfo:SetDrawLayer('ARTWORK', 2)
		fsTitle:SetDrawLayer('ARTWORK', 3)

		desc[0], desc.setMethod = fsDesc[0], "SetDesc"
		setmetatable(desc, getmetatable(fsDesc))

		info[0], info.setMethod = fsInfo[0], "SetInfo"
		setmetatable(info, getmetatable(fsInfo))

		title[0], title.setMethod = fsTitle[0], "SetTitle"
		setmetatable(title, getmetatable(fsTitle))

		lock, isValid = { }, { }
		for index = 1, #entries do
			if getmetatable(entries[index]) == mt then
				lock[entries[index]] = true
			end
		end
	else
		appName, content, desc, frame, info, isValid, lock, mt, path, showing, title, widget, LOD, OnHide, OnShow = lib.__void()
	end
else
	frame = CreateFrame('Frame', nil, UIParent)
	content = CreateFrame('Frame', nil, frame)

	local region = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall', 1)
	desc = setmetatable({ [0] = region[0], setMethod = "SetDesc" }, getmetatable(region))

	region = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall', 2)
	info = setmetatable({ [0] = region[0], setMethod = "SetInfo" }, getmetatable(region))

	region = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge', 3)
	title = setmetatable({ [0] = region[0], setMethod = "SetTitle" }, getmetatable(region))

	appName, isValid, lock, mt, path, LOD, OnHide, OnShow = { }, { }, { }, { }, { }, { }, { }, { }
	frame:Hide()
end

--[[----------------------------------------------------------------------------
Object validation
------------------------------------------------------------------------------]]
setmetatable(isValid, { __index = lock })										-- isValid is a pseudo-alias for lock

if oldRevision and oldRevision < 5 then
	local getmetatable = getmetatable
	for index = 1, #entries do
		if getmetatable(entries[index]) == mt then
			lock[entries[index]] = true
		end
	end
end

--[[----------------------------------------------------------------------------
Initialize frames and font strings
------------------------------------------------------------------------------]]
frame:SetScript('OnHide', function(self)
	if OnHide[showing] then
		local ok, err = pcall(OnHide[showing], showing)
		if not ok then geterrorhandler()(err) end
	end
end)

frame:SetScript('OnShow', function(self)
	if showing then
		if OnShow[showing] then
			local ok, err = pcall(OnShow[showing], showing)
			if not ok then geterrorhandler()(err) end
		end
		showing:Refresh()
	end
end)

content:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -10, 10)

desc:ClearAllPoints()
desc:SetJustifyH('LEFT')
desc:SetJustifyV('TOP')
desc:SetNonSpaceWrap(true)
desc:SetText(" ")
desc:Hide()
desc.shown = false

info:ClearAllPoints()
info:SetAlpha(0.75)
info:SetJustifyH('RIGHT')
info:SetJustifyV('MIDDLE')
info:SetPoint('TOPLEFT', frame, 'TOPLEFT', 15, -15)
info:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, -15)
info:SetText(" ")
info:Hide()
info.shown = false

title:ClearAllPoints()
title:SetJustifyH('LEFT')
title:SetJustifyV('TOP')
title:SetPoint('TOPLEFT', frame, 'TOPLEFT', 15, -15)
title:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, -15)
title:SetText(" ")
title:SetHeight(title:GetStringHeight())
title:Hide()
title.shown = false

--[[----------------------------------------------------------------------------
Load on Demand support
------------------------------------------------------------------------------]]
local ACD = LibStub('AceConfigDialog-3.0', true)

local function OnContentResize(self, width, height)								-- More efficient than AceGUI
	self.height, self.width = height, width
	widget:PerformLayout()
end

local function OnSizeChanged(self, width, height)								-- Keep the width of desc set correctly
	desc:SetWidth(width - 25)
end

frame:SetScript('OnUpdate', function(self)
	self:SetScript('OnUpdate', nil)
	OnSizeChanged(frame, self:GetSize())
	self:SetScript('OnSizeChanged', OnSizeChanged)
end)

if ACD and widget then
	frame:UnregisterEvent('ADDON_LOADED')
	frame:SetScript('OnEvent', nil)
	content:SetScript('OnSizeChanged', OnContentResize)
else
	frame:RegisterEvent('ADDON_LOADED')
	frame:SetScript('OnEvent', function(self)
		if not ACD then
			ACD = LibStub('AceConfigDialog-3.0', true)
		end
		local AceGUI = LibStub('AceGUI-3.0', true)
		if not (ACD and AceGUI and LibStub('AceConfigRegistry-3.0', true)) then return end
		self:UnregisterEvent('ADDON_LOADED')
		self:SetScript('OnEvent', nil)
		if not widget then
			widget = {
				content = content,
				frame = frame,
				type = LIB
			}
			AceGUI:RegisterAsContainer(widget)
			content:SetScript('OnSizeChanged', OnContentResize)
			if not frame:GetScript('OnUpdate') then
				frame:SetScript('OnSizeChanged', OnSizeChanged)
			end
		end
		if showing then
			showing:Refresh()
		end
	end)
end

--[[----------------------------------------------------------------------------
Support
------------------------------------------------------------------------------]]
local FindEntry, LoadModule														-- Defined later in API support section

local function AnchorContent()
	local anchor = title.shown and title
	if info.shown then
		if anchor then
			info:SetHeight(anchor:GetStringHeight())
		else
			anchor = info
			anchor:SetHeight(anchor:GetStringHeight())
		end
	end
	if desc.shown then
		if anchor then
			desc:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, -11)
		else
			desc:SetPoint('TOPLEFT', title, 'TOPLEFT')
		end
		content:SetPoint('TOPLEFT', desc, 'BOTTOMLEFT', 0, -10)
	elseif anchor then
		content:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, -8)
	else
		content:SetPoint('TOPLEFT', title, 'TOPLEFT')
	end
end

local function DoNothing()
end

local function Release(entry)
	isValid[entry], lock[entry] = nil, nil
	mt.__metatable = nil
	pcall(setmetatable, entry, nil)
	mt.__metatable = LIB
end

local function Remove(index, entry, update, unlock)
	if entry.hasChildren then
		local index, name = index + 1, entry.name
		while entries[index] and entries[index].parent == name do
			Remove(index, entries[index], nil, unlock)
		end
	end

	if isValid[entry] then
		mt.__index.Hide(entry)
		desc[entry], info[entry], title[entry] = nil, nil, nil
		LOD[entry], OnHide[entry], OnShow[entry] = nil, nil, nil
		appName[entry], path[entry] = nil, nil
		if unlock then
			Release(entry)
		else
			isValid[entry] = false
		end
	else
		pcall(frame.Hide, entry)
	end
	tremove(entries, index)

	if InterfaceOptionsFramePanelContainer.displayedPanel == entry then
		InterfaceOptionsFramePanelContainer.displayedPanel = nil				-- Avoiding taint
	end
	if update and InterfaceOptionsFrameAddOns:IsShown() then
		InterfaceAddOnsList_Update()
	end
end

local function Turn(key)
	return key == nil and mt or key == false and isValid or key == true and lock or key
end

local function Update(entry, data)
	if data[entry] then
		data:SetText(data[entry])
		if not data.shown then
			data.shown = true
			data:Show()
			AnchorContent()
		end
	elseif data.shown then
		data.shown = false
		data:Hide()
		AnchorContent()
	end
end

local function Set(entry, data, text)
	if text and type(text) ~= 'string' then
		error(ERROR_TYPE:format(1, data.setMethod, "string or nil", type(text)), 3)
	end
	if text then
		text = strtrim(text)
		if text == "" then
			text = nil
		end
	end
	data[entry] = text or nil
	if showing == entry then
		Update(entry, data)
	end
end

--[[----------------------------------------------------------------------------
Instead of creating a new set of frames and font strings for each Blizzard
options panel entry, one set will be shared between them all.  To facilitate
this, a metatable will be used to emulate the needed methods.
------------------------------------------------------------------------------]]
mt.__call = function(self)
	InterfaceOptionsFrame_OpenToCategory(self)
	if not self:IsVisible() then												-- Temp fix for Blizzard bug
		InterfaceOptionsFrame_OpenToCategory(self)
	end
end

mt.__index = {
	cancel = DoNothing,
	defaults = DoNothing,
	okay = DoNothing,
	refresh = DoNothing,

	["AssignOptions"] = function(self, name, ...)
		if isValid[self] then
			if name ~= nil then													-- Can be false
				appName[self] = name
				if select('#', ...) == 0 then
					path[self] = nil
				else
					path[self] = { ... }
				end
			else
				appName[self], path[self] = nil, nil
			end
			self:Refresh()
		end
	end,

	['ClearAllPoints'] = function(self)											-- Required
		if isValid[self] and (showing or self) == self then
			frame:ClearAllPoints()
		end
	end,

	["FlagAsLoaded"] = function(self)
		LOD[self] = nil
	end,

	["GetDesc"] = function(self)
		return isValid[self] and desc[self]
	end,

	["GetInfo"] = function(self)
		return isValid[self] and info[self]
	end,

	['GetScript'] = function(self, script)
		if script == 'OnHide' then
			return OnHide[self]
		elseif script == 'OnShow' then
			return OnShow[self]
		elseif type(script) == 'string' then
			if isValid[self] then
				error(ERROR_BASE:format(1, "GetScript", ("object doesn't have a %q script"):format(script)), 2)
			end
		else
			error(ERROR_TYPE:format(1, "GetScript", 'string', type(script)), 2)
		end
	end,

	["GetTitle"] = function(self)
		return isValid[self] and title[self]
	end,

	['HasScript'] = function(self, script)
		return isValid[self] and (script == 'OnHide' or script == 'OnShow')
	end,

	['Hide'] = function(self)													-- Required
		if showing == self then
			content:Hide()
			if widget then
				widget:PauseLayout()
				widget:ReleaseChildren()
				wipe(widget.userdata)
				wipe(widget.events)
				widget.relHeight, widget.relWidth = nil, nil
				widget.noAutoHeight = nil
			end
			frame:Hide()
			showing = nil
		end
	end,

	['IsShown'] = function(self)
		return showing == self
	end,

	['IsVisible'] = function(self)
		return showing == self and frame:IsVisible()
	end,

	["Recycle"] = function(self, key)
		if lock[self] == Turn(key) then
			if isValid[self] then
				for index = 1, #entries do
					if entries[index] == self then
						return Remove(index, self, true, true)
					end
				end
			else
				if self.hasChildren then
					local name = self.name
					for entry in pairs(isValid) do
						if entry.parent == name then
							Release(entry)
						end
					end
				end
				Release(self)
			end
		end
	end,

	["Refresh"] = function(self)
		if showing == self then
			Update(self, desc)
			Update(self, info)
			Update(self, title)
			if widget then
				local appName, show = appName[self]
				if appName ~= nil then											-- Can be false
					widget:ResumeLayout()
					if not path[self] then
						show = pcall(ACD.Open, ACD, appName, widget)
					else
						show = pcall(ACD.Open, ACD, appName, widget, unpack(path[self]))
					end
				end
				content:SetShown(show)
			end
		end
	end,

	['SetAllPoints'] = function(self, ...)
		if isValid[self] and (showing or self) == self then
			frame:SetAllPoints(...)
		end
	end,

	["SetDesc"] = function(self, text)
		if isValid[self] then
			Set(self, desc, text)
		end
	end,

	["SetInfo"] = function(self, text)
		if isValid[self] then
			Set(self, info, text)
		end
	end,

	["SetKey"] = function(self, newKey, oldKey)
		if lock[self] == Turn(oldKey) then
			lock[self] = Turn(newKey)
			return true
		end
	end,

	['SetParent'] = function(self, ...)											-- Required
		if isValid[self] and (showing or self) == self then
			frame:SetParent(...)
		end
	end,

	['SetPoint'] = function(self, ...)											-- Required
		if isValid[self] and (showing or self) == self then
			frame:SetPoint(...)
		end
	end,

	['SetScript'] = function(self, script, func)
		if func and type(func) ~= 'function' then
			error(ERROR_TYPE:format(2, "SetScript", "function or nil", type(func)), 2)
		elseif not isValid[self] then
			return
		elseif script == 'OnHide' then
			OnHide[self] = func or nil
		elseif script == 'OnShow' then
			OnShow[self] = func or nil
		elseif type(script) == 'string' then
			error(ERROR_BASE:format(1, "SetScript", ("object doesn't have a %q script"):format(script)), 2)
		else
			error(ERROR_TYPE:format(1, "SetScript", 'string', type(script)), 2)
		end
	end,

	['SetShown'] = function(self, show)
		mt.__index[show and 'Show' or 'Hide'](self)
	end,

	["SetTitle"] = function(self, text)
		if isValid[self] then
			Set(self, title, text)
		end
	end,

	['Show'] = function(self)													-- Required
		if isValid[self] then
			if showing then
				if showing == self then
					return self:Refresh()
				end
				showing:Hide()
			end
			if LOD[self] then													-- Do here to avoid potential LoD issues
				local lod = LOD[self]
				LOD[self] = nil
				if lod == "parent" then
					local _, entry = FindEntry(self.parent)
					lod, LOD[entry or false] = LOD[entry], nil
				end
				if type(lod) == 'function' then
					local ok, ret = pcall(lod, self)
					lod = ok and (ret or true) or (geterrorhandler()(ret) and nil)
				end
				if type(lod) == 'string' then
					local loaded, reason = LoadModule(lod)
					if not loaded then
						reason = _G['ADDON_' .. (reason or 'UNKNOWN_ERROR')]
						if type(reason) ~= 'string' then
							reason = ADDON_UNKNOWN_ERROR
						end
						geterrorhandler()(ADDON_LOAD_FAILED:format(lod, reason))
					end
				end
			end
			showing = self
			frame:Show()
		end
	end
}

mt.__metatable = LIB

--[[----------------------------------------------------------------------------
Private API
------------------------------------------------------------------------------]]
function lib.__void()
	wipe(lib)
	wipe(mt)
	return appName, content, desc, frame, info, isValid, lock, mt, path, showing, title, widget, LOD, OnHide, OnShow
end

--[[----------------------------------------------------------------------------
API support
------------------------------------------------------------------------------]]
local function iterate_children(parent, index)
	index = index + 1
	local entry = entries[index]
	if entry and entry.parent == parent then
		return index, entry
	end
end

local function iterate_main(_, index)
	for index = index + 1, #entries do
		if not entries[index].parent then
			return index, entries[index]
		end
	end
end

local function iterator(parent, index)
	if type(index) ~= 'number' then
		error(ERROR_TYPE:format(2, "iterator", 'number', type(index)), 2)
	end
	return (parent and iterate_children or iterate_main)(parent, index)
end

function FindEntry(name, parent)
	if not parent then
		for index = 1, #entries do
			local entry = entries[index]
			if entry.name == name and not entry.parent then						-- Shouldn't be a child
				return index, entry
			end
		end
	else
		local index, entry = FindEntry(parent)
		if entry and entry.hasChildren then
			for index = index + 1, #entries do
				local entry = entries[index]
				if entry.parent == parent then
					if entry.name == name then
						return index, entry
					end
				else
					return
				end
			end
		end
	end
end

do
	local undo = { }

	local function EnableModule(name, dependency)
		local _, _, _, _, _, reason = GetAddOnInfo(name)
		if reason == 'DISABLED' then
			undo[name] = true
			EnableAddOn(name)
			_, _, _, _, _, reason = GetAddOnInfo(name)
		end
		if reason == 'DEP_DISABLED' then
			local dependencies = { GetAddOnDependencies(name) }
			for index = 1, #dependencies do
				reason = EnableModule(dependencies[index], true)
				if reason then
					return reason, true
				end
			end
			_, _, _, _, _, reason = GetAddOnInfo(name)
		end
		return reason, dependency
	end

	function LoadModule(name)
		local loaded, reason, dependency = nil, EnableModule(name)
		if not reason then
			loaded = IsAddOnLoaded(name)
			if not loaded then
				loaded, reason = LoadAddOn(name)
			end
		elseif dependency then
			reason = _G['ADDON_DEP_' .. reason] and ('DEP_' .. reason) or 'DEP_DISABLED'
		end
		for name in pairs(undo) do
			DisableAddOn(name)
		end
		wipe(undo)
		return loaded, reason
	end
end

--[[----------------------------------------------------------------------------
Basically the same thing as the default InterfaceOptions_AddCategory but won't
place a non-child entry wrongly in with the children of another entry.
------------------------------------------------------------------------------]]
local function InterfaceOptions_AddCategory(entry)
	local index
	if entry.parent then
		local parent
		index, parent = FindEntry(entry.parent)
		index = index + 1
		if parent.hasChildren then
			local name = parent.name
			while entries[index] and entries[index].parent == name do
				index = index + 1
			end
		else
			parent.collapsed, parent.hasChildren = true, true
		end
		entry.hidden = parent.collapsed
	else
		local name = entry.name:lower()
		for ndx, entry in iterate_main, nil, 0 do
			if name < entry.name:lower() then
				index = ndx
				break
			end
		end
	end
	tinsert(entries, index or #entries + 1, entry)
	if InterfaceOptionsFrameAddOns:IsShown() then
		InterfaceAddOnsList_Update()
	end
end

--[[----------------------------------------------------------------------------
Public API (use lib.function vice lib:method on next major version change)
------------------------------------------------------------------------------]]
function lib:AddEntry(name, parent, loadOnDemand, key)
	if type(name) ~= 'string' then
		error(ERROR_TYPE:format(1, "AddEntry", 'string', type(name)), 2)
	elseif loadOnDemand and type(loadOnDemand) ~= 'string' and type(loadOnDemand) ~= 'function' then
		error(ERROR_TYPE:format(3, "AddEntry", "function or string or nil", type(loadOnDemand)), 2)
	elseif parent then
		if type(parent) ~= 'string' then
			error(ERROR_TYPE:format(2, "AddEntry", "string or nil", type(parent)), 2)
		elseif not FindEntry(parent) then
			error(ERROR_BASE:format(2, "AddEntry", ("parent %q doesn't exist"):format(parent)), 2)
		end
	end
	local entry = setmetatable({
		name = name,
		parent = parent or nil
	}, mt)
	lock[entry], title[entry], LOD[entry] = Turn(key), name, loadOnDemand or nil
	InterfaceOptions_AddCategory(entry)
	return entry
end

function lib:HasEntry(name, parent)
	if type(name) ~= 'string' then
		error(ERROR_TYPE:format(1, "HasEntry", 'string', type(name)), 2)
	elseif parent and type(parent) ~= 'string' then
		error(ERROR_TYPE:format(2, "HasEntry", "string or nil", type(parent)), 2)
	end
	return FindEntry(name, parent)
end

function lib:IterateEntries(parent)
	local index
	if parent then
		if type(parent) ~= 'string' then
			error(ERROR_TYPE:format(1, "IterateEntries", "string or nil", type(parent)), 2)
		end
		index = FindEntry(parent) or #entries
	end
	return iterator, parent, index or 0
end

function lib:LoadModule(name)
	if type(name) ~= 'string' then
		error(ERROR_TYPE:format(1, "LoadModule", 'string', type(name)), 2)
	end
	return LoadModule(name)
end

function lib:RemoveEntry(name, parent)
	if type(name) ~= 'string' then
		error(ERROR_TYPE:format(1, "RemoveEntry", 'string', type(name)), 2)
	elseif parent and type(parent) ~= 'string' then
		error(ERROR_TYPE:format(2, "RemoveEntry", "string or nil", type(parent)), 2)
	end
	local index, entry = FindEntry(name, parent)
	if entry then
		Remove(index, entry, true)
	end
end

--[[----------------------------------------------------------------------------
Apply any changes
------------------------------------------------------------------------------]]
AnchorContent()
if showing then
	mt.__index[isValid[showing] and "Refresh" or 'Hide'](showing)				-- Hide will set showing to nil
end
