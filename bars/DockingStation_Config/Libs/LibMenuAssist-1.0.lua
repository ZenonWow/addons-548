local LIB, REVISION = "LibMenuAssist-1.0", 4
if not LibStub then error(LIB .. " requires LibStub", 0) end

local lib, oldRevision = LibStub:NewLibrary(LIB, REVISION)
if not lib then return end

local pcall, setmetatable, type = pcall, setmetatable, type

local refreshing

--[[----------------------------------------------------------------------------
Version bridge
------------------------------------------------------------------------------]]
local activeMenu, focusFrames, mt, OnHide, OnShow

if oldRevision then
	activeMenu, focusFrames, mt, OnHide, OnShow = lib.__void()
else
	focusFrames, mt, OnHide, OnShow = { }, { }, { }, { }
	DropDownList1:HookScript('OnHide', function() OnHide.Hook(activeMenu) end)
	DropDownList1:HookScript('OnShow', function() OnShow.Hook(UIDROPDOWNMENU_OPEN_MENU) end)
end

--[[----------------------------------------------------------------------------
Hooks
------------------------------------------------------------------------------]]
function OnHide.Hook(menu)
	activeMenu = nil
	if OnHide[menu] then
		OnHide[menu](menu)
	end
end

function OnShow.Hook(menu)
	activeMenu = menu
	if OnShow[menu] then
		OnShow[menu](menu)
	end
end

--[[----------------------------------------------------------------------------
Support
------------------------------------------------------------------------------]]
local subMenuKeys = { }

local function Close(self)
	if activeMenu == self then
		CloseDropDownMenus()
		return true
	end
end

local function DoNothing()
end

local function IsOpen(self)
	return activeMenu == self
end

local function OpenSubMenu(level, value, ...)
	for index = 1, _G['DropDownList' .. level].numButtons do
		local button = _G['DropDownList' .. level .. 'Button' .. index]
		if button and button.hasArrow and button.value == value then
			level = level + 1
			ToggleDropDownMenu(level, value, nil, nil, nil, nil, button.menuList, button)
			if ... then
				level = OpenSubMenu(level, ...)
			end
			break
		end
	end
	return level
end

--[[----------------------------------------------------------------------------
Methods
------------------------------------------------------------------------------]]
mt.__index = {
	displayMode = 'MENU',

	initialize = function(self, level)
		level = tonumber(level) or 1
		if type(self[0]) == 'function' then
			local ok, err = pcall(self[0], self, level)
			if not ok then
				geterrorhandler()(err)
			end
		end
		local initType = type(self[level])
		if initType == 'function' then
			local ok, err = pcall(self[level], self, level)
			if not ok then
				geterrorhandler()(err)
			end
		elseif initType == 'table' then
			EasyMenu_Initialize(self, level, self[level])
		end
	end,

	["AddFocusFrame"] = function(self, frame)
		local type = type(frame)
		if type == 'string' or type == 'table' then
			if not focusFrames[self] then
				focusFrames[self] = { }
			end
			focusFrames[self][frame] = true
			if activeMenu == self then
				self:UpdateAutoHide()
			end
		end
	end,

	['GetScript'] = function(self, script)
		if script == 'OnHide' then
			return OnHide[self]
		elseif script == 'OnShow' then
			return OnShow[self]
		else
			error(LIB .. ": <menu>:GetScript(script) - '" .. tostring(script) .. "' is not a valid script for this object", 2)
		end
	end,

	["HasMouseFocus"] = function(self)
		local focus, focusFrames = GetMouseFocus(), focusFrames[self]
		if focus then
			local name = focus:GetName()
			if (focusFrames and (focusFrames[focus] or focusFrames[name])) or (activeMenu == self and name and name:match("^DropDownList%d+")) then
				return true
			end
		end
	end,

	['HasScript'] = function(self, script)
		return script == 'OnHide' or script == 'OnShow'
	end,

	['IsVisible'] = function(self)
		return activeMenu == self and DropDownList1:IsVisible()
	end,

	["Open"] = function(self, ...)
		local level, onHide, onShow, wasOpen = 1, OnHide[self], OnShow[self], activeMenu == self
		OnHide[self], OnShow[self] = nil, nil
		CloseDropDownMenus()
		if self.point ~= 'cursor' then
			ToggleDropDownMenu(1, nil, self, self.relativeTo or 'UIParent', nil, nil, self.menuList)
		elseif refreshing == self then
			local point, relativeTo, relativePoint, xOffset, yOffset = self.point, self.relativeTo, self.relativePoint, self.xOffset, self.yOffset
			self.point, self.relativeTo, self.relativePoint, self.xOffset, self.yOffset = DropDownList1:GetPoint()
			ToggleDropDownMenu(1, nil, self, self.relativeTo or 'UIParent', nil, nil, self.menuList)
			self.point, self.relativeTo, self.relativePoint, self.xOffset, self.yOffset = point, relativeTo, relativePoint, xOffset, yOffset
		else
			ToggleDropDownMenu(1, nil, self, 'cursor', self.xOffset, self.yOffset, self.menuList)
		end
		OnHide[self], OnShow[self] = onHide, onShow

		if ... then
			level = OpenSubMenu(level, ...)
		end

		if self:UpdateAutoHide() then
			if not wasOpen and onShow then
				onShow(self)
			end
			return level
		elseif wasOpen and onHide then
			onHide(self)
		end
	end,

	["Recycle"] = function(self)
		self:Close()
		focusFrames[self], OnHide[self], OnShow[self] = nil, nil, nil
		mt.__metatable = nil
		pcall(setmetatable, self, nil)
		mt.__metatable = LIB
	end,

	["Refresh"] = function(self)
		if activeMenu == self then
			wipe(subMenuKeys)
			for level = 2, UIDROPDOWNMENU_MENU_LEVEL do
				local list = _G['DropDownList' .. level]
				if list and list:IsShown() then
					local _, button = list:GetPoint(1)
					if button and button.hasArrow and button.value then
						subMenuKeys[level - 1] = button.value
					else
						break
					end
				else
					break
				end
			end
			refreshing = self
			local level = self:Open(unpack(subMenuKeys))
			refreshing = nil
			return level
		end
	end,

	["RemoveAllFocusFrames"] = function(self)
		if focusFrames[self] then
			focusFrames[self] = nil
			if activeMenu == self then
				self:UpdateAutoHide()
			end
		end
	end,

	["RemoveFocusFrame"] = function(self, frame)
		if focusFrames[self] and focusFrames[self][frame] then
			focusFrames[self][frame] = nil
			if not next(focusFrames[self]) then
				focusFrames[self] = nil
			end
			if activeMenu == self then
				self:UpdateAutoHide()
			end
		end
	end,

	["SetAnchor"] = function(self, xOffset, yOffset, point, relativeTo, relativePoint)
		if point == 'cursor' then
			relativeTo, relativePoint = nil, nil
		end
		if xOffset ~= self.xOffset or yOffset ~= self.yOffset or point ~= self.point or relativeTo ~= self.relativeTo or relativePoint ~= self.relativePoint then
			self.xOffset, self.yOffset, self.point, self.relativeTo, self.relativePoint = xOffset, yOffset, point, relativeTo, relativePoint
			return self:Refresh()
		end
	end,

	['SetScript'] = function(self, script, func)
		if type(func) ~= 'function' and func ~= nil then
			error(LIB .. ": <menu>:SetScript(script, func) - 'func' expected function or nil, got " .. type(func), 2)
		elseif script == 'OnHide' then
			OnHide[self] = func
		elseif script == 'OnShow' then
			OnShow[self] = func
		else
			error(LIB .. ": <menu>:SetScript(script, func) - '" .. tostring(script) .. "' is not a valid script for this object", 2)
		end
	end,

	['Show'] = function(self)
		if activeMenu == self then
			self:Refresh()
		else
			self:Open()
		end
	end,

	["Toggle"] = function(self)
		if activeMenu == self then
			CloseDropDownMenus()
		else
			return self:Open()
		end
	end,

	["UpdateAutoHide"] = function(self)
		if activeMenu == self then
			if self:HasMouseFocus() then
				UIDropDownMenu_StopCounting(DropDownList1)
			else
				UIDropDownMenu_StartCounting(DropDownList1)
			end
			return true
		end
	end,

	["Close"] = Close,
	['Hide'] = Close,
	["IsOpen"] = IsOpen,
	['IsShown'] = IsOpen,
	['SetHeight'] = DoNothing													-- Required to work with Blizzard's UIDropDownMenu code
}

mt.__metatable = LIB

--[[----------------------------------------------------------------------------
Tweaks
------------------------------------------------------------------------------]]
DropDownList1:SetClampedToScreen(true)

for level = 2, UIDROPDOWNMENU_MAXLEVELS do
	_G['DropDownList' .. level]:SetScript('OnUpdate', nil)
end

--[[----------------------------------------------------------------------------
Private API
------------------------------------------------------------------------------]]
function lib.__void()
	wipe(lib)
	wipe(mt)
	return activeMenu, focusFrames, mt, OnHide, OnShow
end

--[[----------------------------------------------------------------------------
Public API
------------------------------------------------------------------------------]]
function lib.New()
	return setmetatable({ }, mt)
end
