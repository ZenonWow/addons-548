local MAJOR, MINOR = "LibCloseOneWindow-1.0", 5040801 -- 5.4.8 v1 / increase manually on changes
if  LibCloseOneWindow  and  LibCloseOneWindow.minor >= MINOR  then  return  end
LibCloseOneWindow = { minor = MINOR }


-- Close ONE special window, return frame object or nil if none visible
function CloseOneWindow()
	for  index, frameName  in pairs(UISpecialFrames) do
		local frame = _G[frameName]
		-- frame:GetLeft() is a simple on-screen check. Returns nil if the frame was not positioned. If it was, then it's most probably on-screen.
		if  frame  and  frame:IsVisible()  then
			print("ESC -> CloseOneWindow(): UISpecialFrames["..index.."] == "..frameName)
			HideUIPanel(frame)
			if  frame:GetLeft()  then  return frame  end
		end
	end
	-- print("ESC -> CloseOneWindow(): nothing to close.")
end

-- Return count of bags closed or nil if none opened
function CloseAllBags2()
	local bagsVisible = nil
	for  i = 1, NUM_CONTAINER_FRAMES  do
		local containerFrame = _G["ContainerFrame"..i]
		if  containerFrame:IsShown()  then
			containerFrame:Hide()
			bagsVisible = (bagsVisible or 0) + 1
		end
	end
	-- print("ESC -> CloseAllBags2(): closed "..(bagsVisible or "ZERO").." container frames")
	return bagsVisible
end

_G.CloseAllBags_ = _G.CloseAllBags
_G.CloseAllBags = CloseAllBags2

_G.CloseAllWindows_ = _G.CloseAllWindows
function _G.CloseAllWindows(ignoreCenter, ...)
	-- if  not called from ToggleGameMenu()  through securecall("CloseAllWindows")  then  return  end			-- do nothing
	if  ignoreCenter  then  return  end			-- don't close windows after PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_CONTROL_LOST
	local res =  CloseOneWindow()  or  CloseAllBags2()  or  _G.CloseAllWindows_(ignoreCenter, ...)
	print("  CloseOneWindow/CloseAllWindows_orig() ->", res, res and LibCommon.istable(res) and res.GetName and res:GetName() )
	-- Table returned would be silently dropped by securecall(), returning nil...
	return res and 1
end


--[[
/run print( GetUIPanel("left"), GetUIPanel("center"), GetUIPanel("right"), GetUIPanel("doublewide"), GetUIPanel("fullscreen") )

[09:46:30] ESC -> CloseOneWindow(): nothing to close.
[09:46:30] ESC -> CloseAllBags2(): closed ZERO container frames
[09:46:30] ESC -> call CloseSpecialWindows_orig()
[09:46:30]   CloseSpecialWindows_orig() -> nil
[09:46:30]   CloseAllWindows_orig() -> table: 13EB1CA0

[08:22:05] ESC -> CloseOneWindow(): nothing to close.
[08:22:05] ESC -> CloseAllBags2(): closed ZERO container frames
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



