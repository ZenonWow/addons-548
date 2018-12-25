local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

function SetTheory:GetMenuFrame(frame)
	local dropdown = CreateFrame("Frame", "SetTheoryDropDown", nil, "UIDropDownMenuTemplate")
	dropdown.point = "TOPLEFT"
	dropdown.relativePoint = "BOTTOMLEFT"
	dropdown.displayMode = "MENU"
	dropdown.xOffset = 2
	dropdown.yOffset = 2
	dropdown.relativeTo = frame
	self.dropdown = dropdown
	self.GetDropdownFrame = function (self, frame)
		local dropdown = self.dropdown
		dropdown.relativeTo = frame
		return dropdown
	end
	return dropdown
end

function SetTheory:GetMenuList()
	menu = {{text = L["Select a set"], isTitle = true}}
	for s, set in pairs(self.db.char.sets) do
		if #set.actions > 0 and set.actions[1].name == "SetTheory_DualSpec" then asterisk = " *" else asterisk = "" end
		table.insert(menu, {text = set.name .. asterisk, func = function() self:SetSetByName({['set']=set.name, checked=self.db.char.active_set == s}) end}) 
	end
	table.insert(menu, {text=L["Global Sets"], isTitle=true})
	for s, set in pairs(self.db.global.sets) do
		table.insert(menu, {text = set.name, func = function() self:SetSetByName({['set']=set.name, ['global']=true, checked=self.db.char.active_set == s}) end})
	end
	return menu
end

function SetTheory:PromptSetMenu_OnLoad(sets)
	for s, set in pairs(sets) do
		f = function()
			SetTheory.promptFrame.cancel:SetText(L['Cancel'])
			SetTheory:CancelTimer(SetTheory.cancelPromptTimer); 
			UIDropDownMenu_SetSelectedValue(SetTheory.promptFrame.setMenu, set.name); 
		end
		UIDropDownMenu_AddButton({text=set.name, value=set.name, func= f})
	end
end

function SetTheory:PromptSetMenu_OnClick()
	ToggleDropDownMenu(1, nil, SetTheory.promptFrame.setMenu, SetTheory.promptFrame, 20, 20)
end
