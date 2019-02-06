local addonName, addon = ...

LibStub('AceEvent-3.0'):Embed(addon)

local gsub, pairs_iter, pcall, tostring, type = gsub, pairs(addon), pcall, tostring, type

local GetObjectType = UIParent.GetObjectType

local LDB, LSM = LibStub('LibDataBroker-1.1'), LibStub('LibSharedMedia-3.0')

--[[----------------------------------------------------------------------------
Helper functions
------------------------------------------------------------------------------]]
local function UpdateProfile()
	addon:AllPanels("Recycle")
	addon.settings = addon.GetSettings()
	for id, settings in pairs_iter, addon.settings.panels, nil do
		if settings.enable then
			addon.CreatePanel(id)
		end
	end
	addon.PanelList:Refresh()
	addon.PluginList:Refresh()
end

local function UpdateSharedMedia(event, type)
	if type == 'border' or type == 'font' or type == 'statusbar' or type == 'statusbar_overlay' then
		addon:QueueMethod("AllPanels", "Refresh")
		if addon.CONFIG_IS_OPEN then
			addon.QueueMethod(addon.CONFIG_IS_OPEN, "Refresh")
		end
	end
end

--[[----------------------------------------------------------------------------
Global to addon
------------------------------------------------------------------------------]]
addon.LDB_RegisterCallback, addon.LDB_UnregisterCallback = LDB.RegisterCallback, LDB.UnregisterCallback
addon.hideConditions = { hide = 0, Hide = 0, HIDE = 0, ["0"] = 0 }
addon.sectionTypes = { Center = "Center", Left = "Left", Right = "Right" }
addon.dataObj, addon.panels, addon.plugins = { }, { }, { }

addon.L = setmetatable({ }, { __index = function(self, key)
	self[key] = key
	return key
end })

addon.mt_subtables = {
	__index = function(self, key)
		self[key] = { }
		return self[key]
	end
}

function addon.safecall(...)
	local showErrors = not addon.settings.hideErrors
	local safecall =  showErrors  and  _G.safecall  or  pcall
	local ok, result = safecall(...)
	if ok then
		return ok, result
	elseif  showErrors  and  safecall == pcall  then
		_G.geterrorhandler()(result)
	end
end

-- Just use global safecall, don't hide errors.
-- if  _G.safecall  then  addon.safecall = _G.safecall  end

function addon.tremove_byVal(table, value)
	for index = 1, #table do
		if table[index] == value then
			tremove(table, index)
			return true
		end
	end
end

function addon:AllPanels(method, ...)
	for index = #self, 1, -1 do													-- Reversed order so that panel:Recycle() will work properly
		self[index][method](self[index], ...)
	end
end

function addon.ConnectTooltip(frame, tooltip, scale)
	if not tooltip:IsClampedToScreen() then
		tooltip:SetClampedToScreen(true)
	end
	tooltip:ClearAllPoints()
	tooltip:SetPoint(addon.GetAnchorInfo(frame))
	local oldScale = tooltip:GetScale()
	if oldScale then
		tooltip:SetScale(scale or frame.settings.tooltipScale)
	end
	return oldScale
end

function addon.DoNothing()
end

function addon.GetAnchorInfo(frame)
	local _, frameCenter = frame:GetCenter()
	local _, uiCenter = UIParent:GetCenter()
	if frameCenter >= uiCenter then
		return 'TOP', frame, 'BOTTOM', 0, 0
	end
	return 'BOTTOM', frame, 'TOP', 0, 0
end

function addon.GetSubTable(table, key, ...)
	local tableKey = table[key]
	if type(tableKey) ~= 'table' then
		tableKey = { }
		local field, value
		for index = 1, select('#', ...), 2 do
			field, value = select(index, ...)
			tableKey[field] = value
		end
		table[key] = tableKey
	end
	return tableKey
end

function addon.IsFrame(object)
	return pcall(GetObjectType, object)
end

function addon.RemoveColorCodes(string)
	local type = type(string)
	if type == 'string' then
		return gsub(gsub(string, "\|[Rr]", ""), "\|[Cc]%x%x%x%x%x%x%x%x", "")
	elseif type == 'number' then
		return tostring(string)
	end
	return ""
end

--[[----------------------------------------------------------------------------
Key Generator
------------------------------------------------------------------------------]]
do
	local digit, base, chrono = {
		'#', '$', '%', '&', '*', '+', '-', '.', '0', '1', '2', '3', '4', '5', '6',
		'7', '8', '9', ':', '=', '?', '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
		'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
		'X', 'Y', 'Z', '^', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
		'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
	}
	base, chrono, digit[0] = #digit + 1, 0, '!'

	function addon.GenerateUniqueKey()
		local key, time = "", time() - 1262325600								-- Epoch: 2010 Jan 01 00:00:00
		if chrono >= time then
			time = chrono + 1
		end
		chrono = time
		while time >= base do
			time, key = floor(time / base), digit[time % base] .. key
		end
		if time > 0 or key == "" then
			key = digit[time] .. key
		end
		return key
	end
end

--[[----------------------------------------------------------------------------
Queue - delays a method until the next OnUpdate, used to throttle stuff
------------------------------------------------------------------------------]]
do
	local caller, shown = CreateFrame('Frame')
	caller:Hide()

	local process, queue = setmetatable({ }, addon.mt_subtables), setmetatable({ }, addon.mt_subtables)

	caller:SetScript('OnUpdate', function(self)
		self:Hide()
		process, queue, shown = queue, process, nil								-- Fix for a queued method triggering a call to QueueMethod
		for object, methods in pairs_iter, process, nil do
			for method, arg in pairs_iter, methods, nil do
				object[method](object, arg)
				methods[method] = nil
			end
		end
	end)

	function addon.PurgeQueue(object, method)
		if method then
			queue[object][method] = nil
			if not pairs_iter(queue[object]) then
				process[object], queue[object] = nil, nil
			end
		else
			process[object], queue[object] = nil, nil
		end
	end

	function addon.QueueMethod(object, method, arg)
		queue[object][method] = arg or false
		if not shown then
			shown = true
			caller:Show()
		end
	end
end

--[[----------------------------------------------------------------------------
Data Objects
------------------------------------------------------------------------------]]
local ValidateDataObject

do
	local function DetectType(_, name, _, _, data)
		ValidateDataObject(_, name, data)
		addon.LDB_UnregisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_type')
	end

	function ValidateDataObject(_, name, data)
		local type = data.type
		if type == nil then														-- Just in case type == false
			addon.LDB_RegisterCallback(addon, 'LibDataBroker_AttributeChanged_' .. name .. '_type', DetectType)
		elseif (type == 'data source' or type == 'launcher') and not addon.dataObj[name] then
			addon.dataObj[name], addon.pluginType[name] = data, type
			if addon.GetPluginSettings(name).enable then
				addon.CreatePlugin(name)
			else
				addon.PluginList:Add(name)
			end
		end
	end
end

--[[----------------------------------------------------------------------------
Initialize display/media
------------------------------------------------------------------------------]]
LibStub('LibDisplayAssist-1.3').Register(addon, function(...)					-- Runs on first frame update to ensure proper sizing
	LibStub('LibDisplayAssist-1.3').Unregister(addon)
	addon.UpdateScreenSize(...)
	UpdateProfile()
	for name, data in LDB:DataObjectIterator() do								-- Check for plugins
		ValidateDataObject(nil, name, data)
	end
	local RegisterCallback = addon.db.RegisterCallback
	RegisterCallback(addon, 'OnProfileChanged', UpdateProfile)
	RegisterCallback(addon, 'OnProfileCopied', UpdateProfile)
	RegisterCallback(addon, 'OnProfileReset', UpdateProfile)
	addon.LDB_RegisterCallback(addon, 'LibDataBroker_DataObjectCreated', ValidateDataObject)
	LSM.RegisterCallback(addon, 'LibSharedMedia_Registered', UpdateSharedMedia)
	LSM.RegisterCallback(addon, 'LibSharedMedia_SetGlobal', UpdateSharedMedia)
	LibStub('LibDisplayAssist-1.3').Register(addon, addon.UpdateScreenSize)
end)

LSM:Register('statusbar', "Blizzard Gradient", [[Interface\WorldStateFrame\WORLDSTATEFINALSCORE-HIGHLIGHT]])
LSM:Register('statusbar', "Empty", [[Interface\AddOns\]] .. addonName .. [[\Media\None]])
LSM:Register('statusbar', "Solid", [[Interface\BUTTONS\WHITE8X8]])

LSM:Register('statusbar_overlay', "Line, Gradient", [[Interface\AddOns\]] .. addonName .. [[\Media\Line, Gradient]])
LSM:Register('statusbar_overlay', "Line, Gradient (Center)", [[Interface\AddOns\]] .. addonName .. [[\Media\Line, Gradient (Center)]])
LSM:Register('statusbar_overlay', "Line, Solid", [[Interface\AddOns\]] .. addonName .. [[\Media\Line, Solid]])
LSM:Register('statusbar_overlay', "Gloss", [[Interface\AddOns\]] .. addonName .. [[\Media\Gloss]])
LSM:Register('statusbar_overlay', "None", [[Interface\AddOns\]] .. addonName .. [[\Media\None]])

LSM:SetDefault('statusbar_overlay', "None")
