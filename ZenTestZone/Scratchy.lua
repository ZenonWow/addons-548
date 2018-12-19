


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


--[[
do
	local prev_CloseSpecialWindows, frameToClose = _G.CloseSpecialWindows, ex
	--function _G.CloseSpecialWindows()  return  frameToClose:IsShown()  and  (frameToClose:Hide() or true)  or  prev_CloseSpecialWindows()  end
	function _G.CloseSpecialWindows()  return  not frameToClose:IsShown()  and  prev_CloseSpecialWindows()  or  frameToClose:Hide()  end
	-- Inverse close order - first everything else then me:
	--function _G.CloseSpecialWindows()  return  prev_CloseSpecialWindows()  or  frameToClose:Hide()  end
end
--]]

--[[
[13:36:14] Dump: value=GameTooltipTextLeft1:GetText()
[13:36:14] [1]="Corpse of 闪光大奶男友"
[13:36:17] [1]="Corpse of 薇薇安之父"
[13:36:20] [1]="Corpse of 源泉的好父亲"
[13:36:23] [1]="Corpse of 薇薇安男朋友"
[13:36:26] [1]="Corpse of 薇薇安的干爹"
[13:36:29] [1]="Corpse of 薇薇安的妈妈"
[13:36:33] [1]="Corpse of 闪光的女朋友"

"闪光大奶男友"
"薇薇安之父"
"源泉的好父亲"
"薇薇安男朋友"
"薇薇安的干爹"
"薇薇安的妈妈"
"闪光的女朋友"
--]]



