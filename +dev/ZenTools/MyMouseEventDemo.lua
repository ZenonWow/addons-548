--[[
-- /run MyMouseEventDemo()

function MyMouseEventDemo()

	-- source: http://wowprogramming.com/docs/scripts/OnClick
	-- Illustrates the timing of mouse script handlers when clicking a button
	local b = CreateFrame("Button", "TestButton", UIParent, "UIPanelButtonTemplate2")
	b:SetPoint("CENTER")
	b:RegisterForClicks("AnyUp", "AnyDown")
	local upDown = { [false] = "Up", [true] = "Down" }
	local function show(text, color)
		DEFAULT_CHAT_FRAME:AddMessage(text, color, color, color)
	end
	local color
	b:SetScript("OnMouseDown", function(self, button)
		color = .60
		show(format("OnMouseDown: %s", button), color, color, color)
	end)
	b:SetScript("OnMouseUp", function(self, button)
		color = .60
		show(format("OnMouseUp: %s", button), color, color, color)
	end)
	b:SetScript("OnClick", function(self, button, down)
		color = color + 0.1
		show(format("OnClick: %s %s", button, upDown[down]), color, color, color)
	end)
	b:SetScript("PreClick", function(self, button, down)
		color = color + 0.1
		show(format("PreClick: %s %s", button, upDown[down]), color, color, color)
	end)
	b:SetScript("PostClick", function(self, button,down)
		color = color + 0.1
		show(format("PostClick: %s %s", button, upDown[down]),  color, color, color)
	end)

end  -- MyMouseEventDemo()


--]]