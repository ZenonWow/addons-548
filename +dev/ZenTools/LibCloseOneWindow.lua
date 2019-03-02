local MAJOR, MINOR = "LibCloseOneWindow", 10 -- 5.4.8 v10 / increase manually on changes
if  LibCloseOneWindow  and  LibCloseOneWindow.minor >= MINOR  then  return  end
LibCloseOneWindow = { minor = MINOR }


-- Close ONE special window, return frame object or nil if none visible
function CloseOneWindow()
	for  index, frameName  in pairs(UISpecialFrames) do
		local frame = _G[frameName]
		-- frame:GetLeft() is a simple on-screen check. Returns nil if the frame was not positioned. If it was, then it's most probably on-screen.
		if  frame  and  frame:IsVisible()  then
			print("ESC -> CloseOneWindow(): UISpecialFrames["..index.."] == "..frameName)
			-- Avoid BUG in  FrameXML/UIParent.lua#CloseWindows():  finding a UIPanel to close after it's been :Hide() -n by CloseSpecialWindows() and making the Game Menu unreachable with ESC key.
			-- Source of the bug:  FramePositionDelegate:HideUIPanel() not being called when :Hide() is called instead of HideUIPanel()
			-- Next source of the bug:  GetUIPanel(f) returning a hidden frame, assuming :Hide() is not called directly.
			-- Usually this bug does not surface as UIPanels are not listed in UISpecialFrames.
			HideUIPanel(frame)
			if  frame:GetLeft()  then  return frame  end
		end
	end
	-- print("ESC -> CloseOneWindow(): nothing to close.")
end

--[[
/dump getmetatable(RaidBrowserFrame).__index.Hide
Demonstrate bug:
/run local r,g=RaidBrowserFrame,GetUIPanel;getmetatable(r).__tostring=function(f) return f:GetName() end; ShowUIPanel(r);r:Hide(); print("Press ESC, Game Menu won't show. GetUIPanel()s:",g('left'),g('center'),g('right'),g('doublewide'),g('fullscreen'))
To Regain Game Menu run this as many times as the previous (max 3 times necessary):
/run RaidBrowserFrame:Show() ; HideUIPanel(RaidBrowserFrame) ; print("Press ESC, Game Menu WILL show.")
Proper fix: hook OnHide on UIPanel frames and call FramePositionDelegate:HideUIPanel(frame) ; FramePositionDelegate is a private local in UIParent.lua, not reachable by addon code.
Patch 1:  hook OnHide, call f:Show() and HideUIPanel(f)
Patch 2:  hook OnHide, set f.IsShown=function() return true end ; call HideUIPanel(f) ; reset f.IsShown
Patch 3:  replace CloseSpecialWindows() with a fixed one using HideUIPanel()
Patch 4:  hook CloseWindows(...)  local f=CloseWindows_orig(...) ; return not f:IsShown() and f  end
Patch 5:  hook GetUIPanel(...)  local f=GetUIPanel_orig(...) ; return f and f:IsShown() and f  end
--]]

-- Reimplementation of FrameXML/ContainerFrame.lua#CloseAllBags() with O(n) instead of O(n^2) operations (n == NUM_CONTAINER_FRAMES == 13).
-- Additionally it returns count of bags closed or nil if none was open.
function CloseAllBagsLinear(requestingFrame)
	if requestingFrame and requestingFrame:GetName() ~= _G.FRAME_THAT_OPENED_BAGS then  return  end
	_G.FRAME_THAT_OPENED_BAGS = nil
	local bagsVisible = nil
	for  i = 1, NUM_CONTAINER_FRAMES  do
		local containerFrame = _G["ContainerFrame"..i]
		if  containerFrame:IsShown()  then
			containerFrame:Hide()
			bagsVisible = (bagsVisible or 0) + 1
		end
	end
	-- print("ESC -> CloseAllBagsLinear(): closed "..(bagsVisible or "ZERO").." container frames")
	return bagsVisible
end

_G._Original = _G._Original or {}
_G._Original.CloseAllBags = _G.CloseAllBags
_G.CloseAllBags = CloseAllBagsLinear

-- Reimplementation of FrameXML/UIParent.lua#CloseAllWindows() to close just _one_ window when ESC is pressed.
-- Original CloseAllWindows == CloseAllBagsLinear + CloseWindows
-- Original CloseWindows == Close UI Panels + CloseSpecialWindows
-- Original CloseSpecialWindows == Close frames listed in UISpecialFrames  -- hooked by addons to close their window (usually one at a time).
_G._Original.CloseAllWindows = _G.CloseAllWindows
function _G.CloseAllWindows(ignoreCenter, ...)
	-- if  not called from ToggleGameMenu()  then  return  end			-- do nothing
	-- Don't close windows after PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_CONTROL_LOST.
	if  ignoreCenter  then
		print("  CloseAllWindows("..tostring(ignoreCenter)..") called from:", _G.debugstack(2,3,0) )
		return
  end
	local res =  CloseOneWindow()  or  CloseAllBagsLinear()  or  _G._Original.CloseAllWindows(ignoreCenter, ...)
	print("  CloseOneWindow/_Original.CloseAllWindows() ->", res)
	-- Table returned would be silently dropped by securecall(), returning nil...
	return res and 1
end

-- Make frames nicely print their name for tostring(frame). Basic for debugging, shouldn't be?
-- Any frame will do here, or an unnecessarily allocating CreateFrame(), if we want to be on the safe side.
getmetatable(CharacterFrame).__tostring = function(f)
  local name = f.GetName and f:GetName()  ;  if name then  return name  end
  name = f.GetObjectType and "ObjectType "..f:GetObjectType() or "Some "..type(f)
  if f.GetID then  name = name.." with ID="..tostring(f:GetID())  end
  local parent = f.GetParent and f:GetParent()
  if parent then  name = name.." with Parent: "..tostring(parent)  end
  return name
end

--[[
/run print( GetUIPanel("left"), GetUIPanel("center"), GetUIPanel("right"), GetUIPanel("doublewide"), GetUIPanel("fullscreen") )
/run UIParent:EnableMouse( true )

[09:46:30] ESC -> CloseOneWindow(): nothing to close.
[09:46:30] ESC -> CloseAllBagsLinear(): closed ZERO container frames
[09:46:30] ESC -> call CloseSpecialWindows_orig()
[09:46:30]   CloseSpecialWindows_orig() -> nil
[09:46:30]   CloseAllWindows_orig() -> table: 13EB1CA0

[08:22:05] ESC -> CloseOneWindow(): nothing to close.
[08:22:05] ESC -> CloseAllBagsLinear(): closed ZERO container frames
[08:22:05] ESC -> CloseOneWindow(): nothing to close.
[08:22:05] ESC -> call CloseSpecialWindows_orig()
--]]



--[[ Original:
-- should always be called from secure code using securecall()
function CloseSpecialWindows()
	local found;
	for index, value in pairs(UISpecialFrames) do
		local frame = _G[value];
		if ( frame and frame:IsShown() ) then
			frame:Hide();
			found = 1;
		end
	end
	return found;
end

/run function CloseSpecialWindows(...) local res = _G.CloseSpecialWindows_(...) ; print("    ->", res) ; return res  end
--]]


----[[
-- should always be called from secure code using securecall()
_G.CloseSpecialWindows_ = CloseSpecialWindows
function CloseSpecialWindows(...)
	-- local closedOne = CloseOneWindow()
	-- if  closedOne  then  return closedOne  end
	-- print("ESC -> call CloseSpecialWindows_orig()")
	local res = _G.CloseSpecialWindows_(...)
	-- print("  CloseSpecialWindows_orig() ->", res)
	return res and 1
end
--]]








local function HideGameMenuFrame()
	if  not GameMenuFrame:IsShown()  then  return  end
	GameMenuFrame.Hidden = true
	GameMenuFrame:Hide()
end

local function UnhideGameMenuFrame()
	if  not GameMenuFrame.Hidden  then  return  end
	GameMenuFrame.Hidden = false
	GameMenuFrame:Show()
end

--[[
VideoOptionsFrame
AudioOptionsFrame
--]]
InterfaceOptionsFrame:HookScript('OnShow', HideGameMenuFrame)
InterfaceOptionsFrame:HookScript('OnHide', UnhideGameMenuFrame)
-- KeyBindingFrame:HookScript('OnShow', HideGameMenuFrame)
-- KeyBindingFrame:HookScript('OnHide', UnhideGameMenuFrame)



