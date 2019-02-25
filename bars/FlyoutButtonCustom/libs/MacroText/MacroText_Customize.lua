
local function SpellIconSelectionButton_Callback(btn, texture)
	local customizeFrame = btn:GetParent():GetParent()
	--print('SpellIconSelectionButton_Callback', customizeFrame:GetName(), texture)
	customizeFrame.spellIcon.icon:SetTexture("INTERFACE\\ICONS\\"..texture)
	customizeFrame.macroTextTextureIsCustom = true
end

function MacroTextButton_ReceiveDrag(self)
	local command, value, subValue, id = GetCursorInfo()
	ClearCursor()
	if not(command) then
		return
	end
	
	local texture
	local customizeFrame = self:GetParent()
	--print('MacroTextButton_ReceiveDrag', customizeFrame:GetName())
	customizeFrame.macroTextSpellID = id
	customizeFrame.macroTextTextureIsCustom = false

	local icon = customizeFrame.spellIcon.icon
	
	customizeFrame.macroTextCommandType = command
	
	if command == "spell" and (subValue ~= "MOUNT") then
		local name, rank = GetSpellInfo(id)
		
		if id then
			texture = GetSpellTexture(id)
		end
		if not(texture) then
			texture = GetSpellTexture(name) 
		end
		customizeFrame.EditBoxIcon:SetText(name)
		customizeFrame.CommandType:SetText("spell")
	elseif command == "item" and value then
		customizeFrame.macroTextItemID = value
		texture = GetItemIcon(value)
		local name = GetItemInfo(value)
		customizeFrame.EditBoxIcon:SetText(name)
		customizeFrame.CommandType:SetText("item")
	end
	
	if (texture) then
		icon:SetTexture(texture)
		icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
		icon:Show()
	else
		icon:SetTexture(nil)
		icon:SetVertexColor(1.0, 1.0, 1.0, 0.5)
		icon:Show()
	end
end

function MacroTextButton_OnClick(self, button, down)
	local iconSelectionDialogPopupFrame = _G["IconSelectionDialogPopup"]
	if not(iconSelectionDialogPopupFrame) then
		return
	end

	if iconSelectionDialogPopupFrame:IsVisible() then
		iconSelectionDialogPopupFrame:Hide()
	else
		iconSelectionDialogPopupFrame:ClearAllPoints()
		iconSelectionDialogPopupFrame:SetPoint("TOPLEFT", customizeFrame, "TOPRIGHT", 20, 0)
		IconSelectionDialogPopup_SetCallback(SpellIconSelectionButton_Callback)
		iconSelectionDialogPopupFrame:Show()
		--todo set icon selection
	end
	self:SetChecked(false)
end
