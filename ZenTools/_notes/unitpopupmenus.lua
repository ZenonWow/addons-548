-- source:  addon Prat-3.0/services/unitpopupmenus.lua
---------------------------------------------------------------------------------
--
-- Prat - A framework for World of Warcraft chat mods
--
-- Copyright (C) 2006-2011  Prat Development Team
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to:
--
-- Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor,
-- Boston, MA  02110-1301, USA.
--
--
-------------------------------------------------------------------------------


local registry = {}

function Prat:RegisterDropdownButton(name, callback)
  registry[name] = callback or true
end




local function showMenu(dropdownMenu, which, unit, name, userData, ...)
  for i=1,UIDROPDOWNMENU_MAXBUTTONS do
    local button = _G["DropDownList" .. UIDROPDOWNMENU_MENU_LEVEL .. "Button" .. i];

    local f = registry[button.value]
    -- Patch our handler function back in
    if f then
      button.func = UnitPopupButtons[button.value].func
      if type(f) == "function" then
        f(dropdownMenu, button)
      end
    end
  end
end

hooksecurefunc("UnitPopup_ShowMenu", showMenu)
