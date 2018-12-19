local MAJOR, MINOR = "LibCloseOneWindow-1.0", 5040801 -- 5.4.8 v1 / increase manually on changes
if  LibCloseOneWindow  and  LibCloseOneWindow.minor >= MINOR  then  return  end
LibCloseOneWindow = { minor = MINOR }


-- Close ONE special window, return frame object or nil if none visible
function CloseOneWindow()
	for  index, frameName  in pairs(UISpecialFrames) do
		local frame = _G[frameName]
		-- frame:GetLeft() is a simple on-screen check. Returns nil if the frame was not positioned. If it was, then it's most probably on-screen.
		if  frame  and  frame:IsVisible()  and  frame:GetLeft()  then
			print("ESC -> CloseOneWindow(): UISpecialFrames["..index.."] == "..frameName)
			frame:Hide()
			return frame
		end
	end
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
	if  bagsVisible  then  print("ESC -> CloseAllBags2(): closed "..bagsVisible.." container frames")  end
	return bagsVisible
end


local CloseAllWindows_orig = _G.CloseAllWindows
function CloseAllWindows(ignoreCenter)
	-- if  not called from ToggleGameMenu()  through securecall("CloseAllWindows")  then  return  end			-- do nothing
	if  ignoreCenter  then  return  end			-- don't close windows after PLAYER_DEAD, PLAYER_ENTERING_WORLD, PLAYER_CONTROL_LOST
	return  CloseOneWindow()  or  CloseAllBags2()  or  CloseAllWindows_orig(ignoreCenter)
end






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
--]]

--[[
-- should always be called from secure code using securecall()
local CloseSpecialWindows_orig = CloseSpecialWindows
function CloseSpecialWindows(...)
	local closedOne = CloseOneWindow()
	if  closedOne  then  return closedOne  end
	print("ESC -> call CloseSpecialWindows_orig()")
	return CloseSpecialWindows_orig(...)
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



