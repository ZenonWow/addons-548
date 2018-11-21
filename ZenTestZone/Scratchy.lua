


local prev_InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
function InterfaceOptionsFrame_OpenToCategory(catFrame)
	local nameStr = type(catFrame) == 'string'  and  catFrame  or  catFrame.name  or  tostring(catFrame)
	local thunk = function() prev_InterfaceOptionsFrame_OpenToCategory(catFrame) end
	local errorhandler = geterrorhandler()
	
	for i = 1,5 do  -- max 5 tries
		local ran, result = xpcall(thunk, errorhandler)
		if  not ran  then
			print("InterfaceOptionsFrame_OpenToCategory("..nameStr..") failed:  "..result)
		else
			local displayedPanel = InterfaceOptionsFramePanelContainer.displayedPanel
			print("InterfaceOptionsFrame_OpenToCategory("..nameStr..") displayedPanel:  ".. (displayedPanel  and  displayedPanel.name  or  "nil"))
			if  nameStr == displayedPanel.name  then
				return "Happy"
			end
		end
	end
end



