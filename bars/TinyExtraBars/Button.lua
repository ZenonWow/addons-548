--[[ TEB_Button ]]

local StoredCursor = {}
local ParentAlpha
local QUICK_SLOT = "Interface\\Buttons\\UI-Quickslot"
local QUICK_SLOT_2 = "Interface\\Buttons\\UI-Quickslot2"
local QUESTION_MARK = "Interface\\Icons\\INV_Misc_QuestionMark"
TEB_Button = {}

-- presets

local preset_by_companion = {
	["UpdateText"] 		= "EmptyFunc",
	["UpdateCount"] 	= "EmptyFunc",
	["SetTooltip"] 		= "SetTooltipCompanion",
	["UpdateTooltip"] 	= "UpdateTooltipCompanion",
	["GetNewTexture"] 	= "GetTextureCompanion",
	["UpdateChecked"] 	= "UpdateCheckedCompanion",
	["UpdateEquipped"] 	= "UpdateEquippedNotItem",
	["UpdateCooldown"] 	= "UpdateCooldownNone",
	["GetUsable"] 		= "GetUsableComapnion",
	["InRange"] 		= "InRangeCompanion",
	["GlowShow"]		= "EmptyFunc",
	["GlowHide"]		= "EmptyFunc",
}

local preset_by_spell = {
	["UpdateText"] 		= "EmptyFunc",
	["UpdateCount"] 	= "UpdateCountSpell",
	["SetTooltip"] 		= "SetTooltipSpell",
	["UpdateTooltip"] 	= "UpdateTooltipSpell",
	["GetNewTexture"] 	= "GetTextureSpell",
	["UpdateChecked"] 	= "UpdateCheckedSpell",
	["UpdateEquipped"] 	= "UpdateEquippedNotItem",
	["UpdateCooldown"] 	= "UpdateCooldownSpell",
	["GetUsable"] 		= "GetUsableSpell",
	["InRange"] 		= "InRangeSpell",
	["GlowShow"]		= "SpellGlowShow",
	["GlowHide"]		= "SpellGlowHide",
}

local preset_by_item = {
	["UpdateText"] 		= "EmptyFunc",
	["UpdateCount"] 	= "UpdateCountItem",
	["SetTooltip"] 		= "SetTooltipItem",
	["UpdateTooltip"] 	= "UpdateTooltipItem",
	["GetNewTexture"] 	= "GetTextureItem",
	["UpdateChecked"] 	= "UpdateCheckedItem",
	["UpdateEquipped"] 	= "UpdateEquippedItem",
	["UpdateCooldown"] 	= "UpdateCooldownItem",
	["GetUsable"] 		= "GetUsableItem",
	["InRange"] 		= "InRangeItem",
	["GlowShow"]		= "EmptyFunc",
	["GlowHide"]		= "EmptyFunc",
}

local preset_by_macro = {
	["UpdateText"] 		= "UpdateTextMacro",
	["UpdateCount"] 	= "UpdateCountMacro",
	["SetTooltip"] 		= "SetTooltipMacro",
	["UpdateTooltip"]	= "UpdateTooltipMacro",
	["GetNewTexture"] 	= "GetTextureMacro",
	["UpdateChecked"] 	= "UpdateCheckedMacro",
	["UpdateEquipped"] 	= "UpdateEquippedNotItem",
	["UpdateCooldown"] 	= "UpdateCooldownMacro",
	["GetUsable"] 		= "GetUsableMacro",
	["InRange"] 		= "InRangeMacro",
	["GlowShow"]		= "MacroGlowShow",
	["GlowHide"]		= "MacroGlowHide",
}

local preset_by_macrotext = {
	["UpdateText"] 		= "EmptyFunc",
	["UpdateCount"] 	= "UpdateCountMacroText",
	["SetTooltip"] 		= "SetTooltipMacroText",
	["UpdateTooltip"]	= "UpdateTooltipMacroText",
	["GetNewTexture"] 	= "GetTextureMacroText",
	["UpdateChecked"] 	= "UpdateCheckedMacro",
	["UpdateEquipped"] 	= "UpdateEquippedNotItem",
	["UpdateCooldown"] 	= "UpdateCooldownMacroText",
	["GetUsable"] 		= "GetUsableMacroText",
	["InRange"] 		= "InRangeMacroText",
	["GlowShow"]		= "MacroTextGlowShow",
	["GlowHide"]		= "MacroTextGlowHide",
}

local preset_by_equipmentset = {
	["UpdateText"] 		= "UpdateTextEquipmentset",
	["UpdateCount"] 	= "EmptyFunc",
	["SetTooltip"] 		= "SetTooltipEquipmentset",
	["UpdateTooltip"] 	= "UpdateTooltipEquipmentset",
	["GetNewTexture"] 	= "GetTextureEquipmentset",
	["UpdateChecked"] 	= "UpdateCheckedEquipmentset",
	["UpdateEquipped"] 	= "UpdateEquippedNotItem",
	["UpdateCooldown"] 	= "UpdateCooldownNone",
	["GetUsable"] 		= "GetUsableEquipmentset",
	["InRange"] 		= "InRangeEquipmentset",
	["GlowShow"]		= "EmptyFunc",
	["GlowHide"]		= "EmptyFunc",
}

local preset_by_battlepet = {
	["UpdateText"] 		= "EmptyFunc",
	["UpdateCount"] 	= "EmptyFunc",
	["SetTooltip"] 		= "SetTooltipBattlepet",
	["UpdateTooltip"] 	= "UpdateTooltipBattlepet",
	["GetNewTexture"] 	= "GetTextureBattlepet",
	["UpdateChecked"] 	= "UpdateCheckedBattlepet",
	["UpdateEquipped"] 	= "UpdateEquippedNotItem",
	["UpdateCooldown"] 	= "UpdateCooldownNone",
	["GetUsable"] 		= "GetUsableBattlepet",
	["InRange"] 		= "InRangeBattlepet",
	["GlowShow"]		= "EmptyFunc",
	["GlowHide"]		= "EmptyFunc",
}			

local TEB_ButtonCombatSnippet = [=[
	local v = self:GetAttribute("type")
	if (v == "" or v == nil) then
		self:Hide()
	end
]=]

local TEB_ButtonShowSnippet = [=[
	local key = self:GetAttribute('click_binding_key')
	local binding = self:GetAttribute('click_binding_cmd')
	if (key) and (key ~= "") and (binding) and (binding ~= "") then
		--print('onshow', binding)
		self:SetBinding(false, key, binding)
	end
]=]

local TEB_ButtonHideSnippet = [=[
	self:ClearBindings()
]=]

function TEB_Button_New(parent, row, col)
	parent.ButtonList[row] = parent.ButtonList[row] or {}
	parent.ButtonList[row][col] = CreateFrame("CheckButton", parent:GetName().."Button"..row.."_"..col, parent, "TinyExtraBarsButtonTemplate")
	local btn = parent.ButtonList[row][col]
	btn.row = row
	btn.col = col
	btn.border = _G[btn:GetName().."Border"]
	btn.count = _G[btn:GetName().."Count"]
	btn.name = _G[btn:GetName().."Name"]
	btn.hotkey = _G[btn:GetName().."HotKey"]
	btn.ntexture = _G[btn:GetName().."NormalTexture"]
	btn.flash = _G[btn:GetName().."Flash"]
	btn.buttonframe = parent -- container -> buttonframe -> button
	btn.frameID = parent:GetID()
	btn.contID = parent.container:GetID()
	btn.action = 10000
	btn.flashing = false
	btn.flashtime = 0
	
	-- adding methods to button
	for k, v in pairs(TEB_Button) do
		if type(v) == "function" then
			btn[k] = v
		end
	end
	
	btn:SetSize(TEB_BUTTON_SIZE, TEB_BUTTON_SIZE)
	--btn:SetScale(TEB_BUTTON_SCALE)
	btn:SetMovable(true)
	btn.configure:Hide()
	btn:RegisterForDrag("LeftButton")
	btn:SetNormalTexture(QUICK_SLOT)
	btn:SetAttribute("checkselfcast", true)
	btn:SetAttribute("checkfocuscast", true)
	btn:SetAttribute("unit2", "player") --right-click self cast
	btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	btn:SetAttribute('_childupdate-combat', TEB_ButtonCombatSnippet)
	
	btn:SetAttribute('_onshow', TEB_ButtonShowSnippet)
	btn:SetAttribute('_onhide', TEB_ButtonHideSnippet)
	
	btn.damagetext = btn:CreateFontString(btn:GetName() .. "DamageText", "OVERLAY", GameFontNormalSmall) --GameFontNormal
	local dt = btn.damagetext
	dt:SetPoint("TOPLEFT", btn, "TOPLEFT", -5, -10)
	dt:SetPoint("TOPRIGHT", btn, "TOPRIGHT", 5, -10)
	dt:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
	dt:SetTextColor(1, 1, 0)
	
	btn:HookScript("OnClick", btn.OnHookClick)

	btn:EnableMouse(not(parent.container.clickthrough))
	
	return btn
end

function TEB_Button_AttachToFrame(parent, row, col)
	local btn
	if not(parent.ButtonList[row]) or not(parent.ButtonList[row][col]) then
		btn = TEB_Button_New(parent, row, col)
		if (TEB_LBFMasterGroup) then --ButtonFacade stuff
			TEB_LBFMasterGroup:AddButton(btn)
		end
	else
		btn = parent.ButtonList[row][col]
	end
	btn:SetAnchor(row, col)

	return btn
end

function TEB_Button:ClearHandlers()
	for k, v in pairs(preset_by_spell) do
		self[k] = self.EmptyFunc
	end
end

function TEB_Button:EmptyFunc()
	return nil
end

function TEB_Button:SetRightClickSelfCast(value)
	if value then
		self:SetAttribute("unit2", "player") --right-click self cast enabled
	else
		self:SetAttribute("unit2", "") --right-click self cast disabled
	end
end

function TEB_Button:SetAnchor(row, col)
	local left = col * TEB_BUTTON_SPACING + (col - 1) * TEB_BUTTON_SIZE
	local top = - (row * TEB_BUTTON_SPACING + (row - 1) * TEB_BUTTON_SIZE)
	--local left = col * TEB_BUTTON_SPACING / TEB_BUTTON_SCALE + (col - 1) * TEB_BUTTON_SIZE
	--local top = - (row * TEB_BUTTON_SPACING / TEB_BUTTON_SCALE + (row - 1) * TEB_BUTTON_SIZE)
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", left, top)
end

function TEB_Button:OnCustomize()
	TinyExtraBars_MacroTextCustomizeFrame_Toogle(self)
end

--bindings

function TEB_Button:GetHotkey()
	local key = GetBindingKey("CLICK "..self:GetName()..":LeftButton")
	local displayKey = TEB_LibKeyBound:ToShortKey(key)
	return displayKey
end

function TEB_Button:SetKey(key) -- binds the given key to the given button, called by lib on new binding
	--print('SetKey', key)
	self.buttonframe.container:SetKeybind(key, self.row, self.col)
	TinyExtraBarsPC:Set({'Containers', self.contID, 'keibinds', self.row, self.col}, key)
end

function TEB_Button:ClearBindings() -- removes all keys bound to the given button, called by lib on escape pressed
	--print('ClearBindings', key)
	local key = self:GetAttribute('click_binding_key')
	self:SetAttribute('click_binding_key', nil);
	self:SetAttribute('click_binding_cmd', nil);
	self.buttonframe.container:SetKeybind(nil, self.row, self.col)
	TinyExtraBarsPC:Set({'Containers', self.contID, 'keibinds', self.row, self.col}, nil)
end

function TEB_Button:FreeKey(key) -- unbinds the given key from all other buttons, called by lib before SetKey
	--print('FreeKey', key)
	TinyExtraBars_UnbindButtons(key)
end
	
--tooltip

function TEB_Button:UpdateTooltipSpell()
	if (self.id) then --tooltipValue
		GameTooltip:SetSpellByID(self.id)
	end
end
function TEB_Button:UpdateTooltipItem()
	if (self.tooltipValue) then
		GameTooltip:SetItemByID(self.tooltipValue)
	end
end
function TEB_Button:UpdateTooltipCompanion()
	if (self.id) then
		GameTooltip:SetSpellByID(self.id)
	elseif (self.tooltipValue) then
		GameTooltip:SetHyperlink(self.tooltipValue)
	end
end
function TEB_Button:UpdateTooltipMacro()
	if (self.tooltipValue) then
		GameTooltip:SetText(self.tooltipValue, 1.0, 1.0, 1.0)
	end
end
function TEB_Button:UpdateTooltipMacroText()
	local t = self.macroValues
	if (self.tooltipValue) and (self.tooltipValue ~= '') then
		local temp = string.gsub(self.tooltipValue, "||", "|")
		GameTooltip:SetText(temp, 1.0, 1.0, 1.0, 1, 1)
	elseif t and type(t) == "table" then
		if self.subValue == "spell" then
			if t.id then
				GameTooltip:SetSpellByID(t.id)
			end
		elseif self.subValue == "item" then
			if t.id then
				GameTooltip:SetItemByID(t.id)
			end
		end
	end
end
function TEB_Button:UpdateTooltipEquipmentset()
	if (self.tooltipValue) then
		GameTooltip:SetEquipmentSet(self.tooltipValue)
	end
end
function TEB_Button:UpdateTooltipBattlepet()
	if (self.value) and (self.tooltipValue) then -- self.tooltipValue is hyperlinklink
		--speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType, creatureID, sourceText, description, isWild, canBattle, tradable, unique
		local speciesID, customName, level = C_PetJournal.GetPetInfoByPetID(self.value)
		local _, _, _, breedQuality, maxHealth, power, speed, _ = strsplit(":", self.tooltipValue)
		BattlePetToolTip_Show(speciesID, level, tonumber(breedQuality), maxHealth, power, speed, customName) 
	end
end
function TEB_Button:OnEnter()
	if (self.GetHotkey) then
		TEB_LibKeyBound:Set(self)
	end
	
	if not(self.buttonframe.container.showtooltip) then
		return
	end
	
	if (GetCVar("UberTooltips") == "1") then
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	
	self:UpdateTooltip()
end

function TEB_Button:OnLeave()
	GameTooltip:Hide()
	BattlePetTooltip:Hide()
	
	-- anti fading stuff
	if ParentAlpha and ParentAlpha.bar then
		ParentAlpha.bar:SetAlpha(ParentAlpha.alpha)
		ParentAlpha = nil
	end
end

function TEB_Button:SetTooltipSpell()
	self.tooltipValue = self.value
end

function TEB_Button:SetTooltipItem()
	self.tooltipValue = self.value --itemId
end
function TEB_Button:SetTooltipMacro()
	self.tooltipValue = self.value
end
function TEB_Button:SetTooltipMacroText()
	self.tooltipValue = self.id --tooltip stored in id
end
function TEB_Button:SetTooltipEquipmentset()
	self.tooltipValue = self.value
end
function TEB_Button:SetTooltipCompanion()
	self.tooltipValue = nil
	if self.id then
		self.tooltipValue = "spell:"..self.id
	end
end
function TEB_Button:SetTooltipBattlepet()
	self.tooltipValue = C_PetJournal.GetBattlePetLink(self.value)
end

--texture

function TEB_Button:GetTextureSpell()
	local texture = nil
	local value, subValue, id = self.value, self.subValue, self.id

	if id then
		texture = GetSpellTexture(id)
	end
	if not(texture) then
		texture = GetSpellTexture(value) 
	end
	return texture
end
function TEB_Button:GetTextureItem()
	return GetItemIcon(self.value)
end
function TEB_Button:GetTextureMacro()
	local _, texture = GetMacroInfo(self.value)
	return texture
end
function TEB_Button:GetTextureMacroText()
	local t = self.macroValues
	local texture
	if t and type(t) == "table" then 
		if t.textureIsCustom then
			texture = t.texture
		else
			if self.subValue == "spell" then
				t.texture = GetSpellTexture(t.value)
				texture = t.texture
			elseif self.subValue == "item" then
				t.texture = GetItemIcon(t.value)
				texture = t.texture
			end
		end
	end
	
	return texture
end
function TEB_Button:GetTextureEquipmentset()
	return 'Interface/Icons/'..(GetEquipmentSetInfoByName(self.value) or '')
end
function TEB_Button:GetTextureCompanion()
	local _, _, _, texture = TinyExtraBars_GetCompanionInfoByName(self.value, self.subValue)
	return texture
end
function TEB_Button:GetTextureBattlepet()
	local _, _, _, _, _, _, _, _, icon = C_PetJournal.GetPetInfoByPetID(self.value)
	return icon
end
function TEB_Button:UpdateTexture()
	local icon = self.icon
	if not(self.command) then
		icon:Hide()
		self.cooldown:Hide()
		self:SetNormalTexture(QUICK_SLOT)
		return
	end

	local curr_texture = icon:GetTexture()
	local texture = self:GetNewTexture()

	if curr_texture ~= texture then
		--hide damage text on update
		self.damagetext:Hide()
	end
	
	if (texture) then
		icon:SetTexture(texture)
		icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
		icon:Show()
		if TEB_HideBorders then
			self:SetNormalTexture("")
		else
			self:SetNormalTexture(QUICK_SLOT_2)
		end
	else
		icon:SetTexture(QUESTION_MARK)
		icon:SetVertexColor(1.0, 1.0, 1.0, 0.5)
		icon:Show()
		self:SetNormalTexture(QUICK_SLOT_2)		
	end
end

--checked

function TEB_Button:UpdateCheckedSpell()
	local result = false
	local value = self.value --self.id
	if value then
		result = IsCurrentSpell(value) or IsAutoRepeatSpell(value)
	end
	self:SetChecked(result)
end
function TEB_Button:UpdateCheckedItem()
	self:SetChecked(IsCurrentItem(self.value))
end
function TEB_Button:UpdateCheckedMacro()
	self:SetChecked(false)
end
function TEB_Button:UpdateCheckedEquipmentset()
	self:SetChecked(false) --todo get somehow is equipped
end
function TEB_Button:UpdateCheckedCompanion()
	local value, subValue = self.value, self.subValue
	_, _, _, _, result = TinyExtraBars_GetCompanionInfoByName(value, subValue)
	local spellName = UnitCastingInfo("player")
	self:SetChecked(result or spellName == value)
end
function TEB_Button:UpdateCheckedBattlepet()
	self:SetChecked(self.value == C_PetJournal.GetSummonedPetGUID())
end

--equipped

function TEB_Button:UpdateEquippedItem()
	local border = self.border

	if IsEquippedItem(self.value) then
		border:SetVertexColor(0, 1.0, 0, 0.35)
		border:Show()
	else
		border:Hide()
	end
end
function TEB_Button:UpdateEquippedNotItem()
	self.border:Hide()
end
--todo macrotext

--cooldown

function TEB_Button:UpdateCooldownSpell()
	local start, duration, enable = GetSpellCooldown(self.value) --GetSpellCooldown(slot, book) --GetSpellCooldown(id)
	if start then
		local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(self.value)
		--if (charges ~= maxCharges) then
		--	start = chargeStart
		--	duration = chargeDuration
		--end
		CooldownFrame_SetTimer(self.cooldown, start, duration, enable, charges, maxCharges)
	else
		self:UpdateCooldownNone()
	end
end
function TEB_Button:UpdateCooldownItem()
	CooldownFrame_SetTimer(self.cooldown, GetItemCooldown(self.value))
end
function TEB_Button:UpdateCooldownMacro()
	if (self.macroSpellName) then
		local start, duration, enable = GetSpellCooldown(self.macroSpellName)
		if start then
			local charges, maxCharges = GetSpellCharges(self.value)
			CooldownFrame_SetTimer(self.cooldown, start, duration, enable, charges, maxCharges)
		else
			self:UpdateCooldownNone()
		end
	end
end
function TEB_Button:UpdateCooldownMacroText()
	local t = self.macroValues
	if t and type(t) == "table" then 
		if self.subValue == "spell" and t.value then
			local start, duration, enable = GetSpellCooldown(t.value)
			if start then
				local charges, maxCharges = GetSpellCharges(self.value)
				CooldownFrame_SetTimer(self.cooldown, start, duration, enable, charges, maxCharges)
				return
			end			
		elseif self.subValue == "item" and t.id then
			CooldownFrame_SetTimer(self.cooldown, GetItemCooldown(t.id))
			return
		end
	end
	self:UpdateCooldownNone()
end
function TEB_Button:UpdateCooldownNone()
	CooldownFrame_SetTimer(self.cooldown, 0, 0, 0)
	self.cooldown:Hide()
end

--usable

function TEB_Button:GetUsableSpell()
	local usable, nomana = IsUsableSpell(self.value) --self.id
	--print(self.value, usable, nomana)
	return usable --and not(nomana)
end
function TEB_Button:GetUsableItem()
	--print(self.subValue, IsUsableItem(self.value))
	return IsUsableItem(self.value)
end
function TEB_Button:GetUsableMacro()
	if (self.macroSpellName) then
		return IsUsableSpell(self.macroSpellName, "target")
	end
	return true
end
function TEB_Button:GetUsableMacroText()
	local t = self.macroValues
	if t and type(t) == "table" then 
		if self.subValue == "spell" and t.value then
			return IsUsableSpell(t.value, "target")
		elseif self.subValue == "item" and t.id then
			return IsUsableItem(t.id)
		end
	end
	return true
end
function TEB_Button:GetUsableEquipmentset()
	return not(InCombatLockdown())
end
function TEB_Button:GetUsableComapnion()
	return self.subValue == "MOUNT" and IsOutdoors()
end
function TEB_Button:GetUsableBattlepet()
	return true
end
function TEB_Button:UpdateUsable()
	local isUsable, notEnoughMana = self:GetUsable()

	local icon = self.icon
	local ntexture = self.ntexture
	if (isUsable) then
		icon:SetVertexColor(1.0, 1.0, 1.0)
		ntexture:SetVertexColor(1.0, 1.0, 1.0)
	elseif (notEnoughMana and not(self.subValue == "MOUNT")) then
		icon:SetVertexColor(0.5, 0.5, 1.0)
		ntexture:SetVertexColor(0.5, 0.5, 1.0)
	else
		icon:SetVertexColor(0.4, 0.4, 0.4)
		ntexture:SetVertexColor(1.0, 1.0, 1.0)
	end	
end

--update text

function TEB_Button:UpdateTextMacro()
	-- name, iconTexture, body, isLocal = GetMacroInfo("name" or macroSlot)
	local name = GetMacroInfo(self.subValue) --by slot
	self.name:SetText(name)
end
function TEB_Button:UpdateTextEquipmentset()
	self.name:SetText(self.value)
end

--range

function TEB_Button:InRangeSpell()
	return IsSpellInRange(self.value, "target")
end
function TEB_Button:InRangeItem()
	return IsItemInRange(self.value, "target")
end
function TEB_Button:InRangeMacro()
	if (self.macroSpellName) then
		return IsSpellInRange(self.macroSpellName, "target")
	end
	return nil
end
function TEB_Button:InRangeMacroText()
	local t = self.macroValues
	if t and type(t) == "table" then 
		if self.subValue == "spell" and t.value then
			return IsSpellInRange(t.value, "target")
		elseif self.subValue == "item" and t.id then
			return IsItemInRange(t.id, "target")
		end
	end
	return nil
end
function TEB_Button:InRangeEquipmentset()
	return nil
end
function TEB_Button:InRangeCompanion()
	return nil
end
function TEB_Button:InRangeBattlepet()
	return nil
end
function TEB_Button:UpdateRange()
	local hotkey = self.hotkey
	local valid = self:InRange()
	if ( hotkey:GetText() == RANGE_INDICATOR ) then
		--print(self:GetName(), valid)
		if ( valid == 0 ) then
			hotkey:Show()
			hotkey:SetVertexColor(1.0, 0.1, 0.1)
		elseif ( valid == 1 ) then
			hotkey:Show()
			hotkey:SetVertexColor(0.6, 0.6, 0.6)
		else
			hotkey:Hide()
		end
	else
		if ( valid == 0 ) then
			hotkey:SetVertexColor(1.0, 0.1, 0.1)
		else
			hotkey:SetVertexColor(0.6, 0.6, 0.6)
		end
	end
	
	--full button color
	local aw = self.ArtworkRange
	if aw then
		if TEB_FullRangeArtwork then
			if ( valid == 0 ) then
				aw:Show()
				--out of range color, format is "r, g, b, alpha" between 0 and 1
				aw:SetVertexColor(0.5, 0, 0, 0.7)
			elseif ( valid == 1 ) then
				aw:Show()
				aw:SetVertexColor(0, 0, 0, 0)
			else
				aw:Hide()
			end
		else
			aw:Hide()
		end
	end
end

-- count

local function GetCountText(count)
	if (count > 999) then
		return "*"
	else
		return count
	end
end
function TEB_Button:UpdateCountSpell()
	local text = ""
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(self.value) --self.id
	if (maxCharges) and (charges) and (maxCharges > 1) then
		text = GetCountText(charges)
	end
	self.count:SetText(text)
	if (text) and (text ~= "") then
		self.count:Show()
	end
end
function TEB_Button:UpdateCountItem()
	local charges = GetItemCount(self.value, false, true)
	if charges > 1 then
		charges = GetCountText(charges)
	else
		charges = ""
	end
	self.count:SetText(charges)
	if (charges) and (charges ~= "") then
		self.count:Show()
	end
end
function TEB_Button:UpdateCountMacro()
	local text = ""
	if self.macroSpellName then
		local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(self.macroSpellName)
		if (maxCharges) and (charges) and (maxCharges > 1) then
			text = GetCountText(charges)
		end
	end
	
	self.count:SetText(text)
	if (text) and (text ~= "") then
		self.count:Show()
	end
end
function TEB_Button:UpdateCountMacroText()
	local text = ""
	local t = self.macroValues
	if t and type(t) == "table" then 
		if self.subValue == "spell" and t.value then
			local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(t.value)
			if (maxCharges) and (charges) and (maxCharges > 1) then
				text = GetCountText(charges)
			end
		elseif self.subValue == "item" and t.id then
			local charges = GetItemCount(t.id, false, true)
			if charges > 1 then
				text = GetCountText(charges)
			else
				text = ""
			end
		end
	end
	self.count:SetText(text)
	if (text) and (text ~= "") then
		self.count:Show()
	end
end

-- glow

function TEB_Button:SpellGlowShow(...)
	local arg1 = ...
	if self.id and self.id == arg1 and IsSpellOverlayed(self.id) then
		Lib_ActionButton_ShowOverlayGlow(self) --Lib_
	end
end
function TEB_Button:MacroGlowShow(...)
	local arg1 = ...
	if self.subValue  then
		local _, _, spellId = GetMacroSpell(self.subValue) --index
		if spellId and spellId == arg1 and IsSpellOverlayed(spellId) then
			Lib_ActionButton_ShowOverlayGlow(self)
		end
	end
end
function TEB_Button:MacroTextGlowShow(...)
	local arg1 = ...
	local t = self.macroValues
	if t and type(t) == "table" then 
		if self.subValue == "spell" then
			local spellId = t.id
			if spellId and spellId == arg1 and IsSpellOverlayed(spellId) then
				Lib_ActionButton_ShowOverlayGlow(self)
			end
		end
	end
end
function TEB_Button:SpellGlowHide(...)
	local arg1 = ...
	if self.id and self.id == arg1 then
		Lib_ActionButton_HideOverlayGlow(self)
	end
end
function TEB_Button:MacroGlowHide(...)
	local arg1 = ...
	if self.subValue then
		local _, _, spellId = GetMacroSpell(self.subValue) --index
		if spellId and spellId == arg1 then
			Lib_ActionButton_HideOverlayGlow(self)
		end
	end
end
function TEB_Button:MacroTextGlowHide(...)
	local arg1 = ...
	local t = self.macroValues
	if t and type(t) == "table" then 
		if self.subValue == "spell" then
			local spellId = t.id
			if spellId and spellId == arg1 then
				Lib_ActionButton_HideOverlayGlow(self)
			end
		end
	end
end

-- flash

function TEB_Button:StartFlash()
	self.flashing = true
	self.flashtime = 0
end

function TEB_Button:StopFlash()
	self.flashing = false
	self.flash:Hide()
end

-- click

function TEB_Button:Click(button)
	if (self.command == "battlepet") and self.value then
		C_PetJournal.SummonPetByGUID(self.value)
	end
end

-- common

local function deepcopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

function TEB_Button:Set(command, value, subValue, id, macroValues)
	if self.id then
		TinyExtraBars_RemoveButtonFromSpellIds(self, self.id)
	end
	self.command, self.value, self.subValue, self.id = command, value, subValue, id
	self.macroValues = deepcopy(macroValues)
	
	self.macroSpellName = nil
	self.name:SetText("")
	self.count:SetText("")
	self:SetAttribute("type", "")
	self:SetAttribute("spell", "")
	self:SetAttribute("item", "")
	self:SetAttribute("macro", "")
	self:SetAttribute("macrotext", "")
	self:SetAttribute("clickbutton", "")
	self:SetAttribute("_onclick", "")

	if command then
		if command == "spell" then
			self:SetAttribute("type", command)
			if (subValue == "MOUNT") then --everything on their own, mount spell by id not works
				for k, v in pairs(preset_by_companion) do
					self[k] = self[v]
				end

				self:SetAttribute(command, value)
			else
				for k, v in pairs(preset_by_spell) do
					self[k] = self[v]
				end

				if self.id then
					--print(self.value, self.id)
					TinyExtraBars_AddButtonToSpellIds(self, self.id)
				end
				self:SetAttribute(command, value) --id
			end
		elseif command == "item" then
			for k, v in pairs(preset_by_item) do
				self[k] = self[v]
			end
			
			--local itemname = GetItemInfo(value)
			self:SetAttribute("type", command)
			self:SetAttribute(command, command..":"..value) --itemname
		elseif command == "macro" then
			for k, v in pairs(preset_by_macro) do
				self[k] = self[v]
			end

			if self.subValue then
				local name, rank, spellId = GetMacroSpell(self.subValue) --subValue is index, GetMacroIndexByName(value)
				self.macroSpellName = TinyExtraBars_GetFullSpellName(name, rank)
				if spellId then
					TinyExtraBars_AddButtonToSpellIds(self, spellId)
				end
			end			
			self:SetAttribute("type", command)
			self:SetAttribute("macrotext", nil)
			self:SetAttribute(command, value)
		elseif command == "equipmentset" then
			for k, v in pairs(preset_by_equipmentset) do
				self[k] = self[v]
			end

			self:SetAttribute("type", "macro")
			self:SetAttribute("macrotext", "/equipset "..value)
		elseif command == "battlepet" then
			for k, v in pairs(preset_by_battlepet) do
				self[k] = self[v]
			end

			self:SetAttribute("type", "click")
			self:SetAttribute("clickbutton", self)
			--local speciesID, customName, level, xp, maxXp, displayID, petName, petIcon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(value)
		elseif command == "macrotext" then
			-- value is macro text, subValue is spell name, id is tooltip
			for k, v in pairs(preset_by_macrotext) do
				self[k] = self[v]
			end
			
			local t = self.macroValues
			if t and type(t) == "table" then 
				if self.subValue == "spell" and t.id then
					TinyExtraBars_AddButtonToSpellIds(self, t.id)
				end
			end
			self:SetAttribute("type", "macro")
			self:SetAttribute("macro", nil)
			self:SetAttribute(command, value)
		else
			self:ClearHandlers()
		end
	else
		self:ClearHandlers()
	end
	
	self:UpdateButton()
	self:Show()
	if command then
		self:RegisterEvents()
	else
		self:UnregisterEvents()
	end
end

function TEB_Button:PreClick(button)
	if InCombatLockdown() then
		ClearCursor()
		return
	end
	
	StoredCursor = {}
	local command, value, subValue, id = TinyExtraBars_GetCursorValues()
	if button == "LeftButton" then
		if command then
			StoredCursor.command, StoredCursor.value, StoredCursor.subValue, StoredCursor.id = command, value, subValue, id
			self:SetAttribute("type", nil) --to avoid click event (spell cast)
		end
	end
end

function TEB_Button:PostClick(button)
	if InCombatLockdown() then
		return
	end
	
	if button == "LeftButton" and StoredCursor.command then
		TinyExtraBars_SetCursor(StoredCursor.command, StoredCursor.value, StoredCursor.subValue, StoredCursor.id)
		StoredCursor = {}
		self:OnReceiveDrag()
	end
end

function TEB_Button:OnHookClick()
	local t = self.macroValues
	if self.command == "spell" and self.value then
		local id = TinyExtraBars_FindSpellId(self.value)
		TEBLE_InitAndShowSpell(id)
		TEBLE_ResetSpell(id)
	elseif self.command == "macro" and self.macroSpellName then
		local id = TinyExtraBars_FindSpellId(self.macroSpellName)
		TEBLE_InitAndShowSpell(id)
		TEBLE_ResetSpell(id)
	elseif self.command == "macrotext" then 
		if t and type(t) == "table" then 
			if self.subValue == "spell" and t.value then
				local id = TinyExtraBars_FindSpellId(t.value)
				TEBLE_InitAndShowSpell(id)
				TEBLE_ResetSpell(id)
			end
		end
	end
end

function TEB_Button:SaveCommand(command, value, subValue, id, macroValues)
	if command then
		TinyExtraBarsPC:Set({'Containers', self.contID, 'tabs', self.frameID, self.row, self.col, "command"}, command)
		TinyExtraBarsPC:Set({'Containers', self.contID, 'tabs', self.frameID, self.row, self.col, "value"}, value)
		TinyExtraBarsPC:Set({'Containers', self.contID, 'tabs', self.frameID, self.row, self.col, "subValue"}, subValue)
		TinyExtraBarsPC:Set({'Containers', self.contID, 'tabs', self.frameID, self.row, self.col, "id"}, id)
		TinyExtraBarsPC:Set({'Containers', self.contID, 'tabs', self.frameID, self.row, self.col, "macroValues"}, macroValues)
	else
		TinyExtraBarsPC:Set({'Containers', self.contID, 'tabs', self.frameID, self.row, self.col}, nil)
	end
end

function TEB_Button:OnReceiveDrag()
	if InCombatLockdown() or (TEB_UseShift and not(TEB_SettingsMode) and not(IsShiftKeyDown())) then
		ClearCursor()
		return
	end

	local command, value, subValue, id = TinyExtraBars_GetCursorValues()

	ClearCursor()
	if self.command then
		TinyExtraBars_SetCursor(self.command, self.value, self.subValue, self.id)
	end

	self:Set(command, value, subValue, id)
	self:SaveCommand(command, value, subValue, id)
end

function TEB_Button:OnDragStart()
	if InCombatLockdown() or (not(TEB_SettingsMode) and not(IsShiftKeyDown())) then
		return
	end
	
	if self.command then
		TinyExtraBars_SetCursor(self.command, self.value, self.subValue, self.id)
	end
	
	TinyExtraBarsPC:Set({'Containers', self.contID, 'tabs', self.frameID, self.row, self.col}, nil)
	
	self:Set(nil, nil, nil, nil)
	self:SaveCommand(nil, nil, nil, nil)
end

function TEB_Button:HideButton()
	self.tooltipValue = nil
	self:SetAttribute("type", "none")
	self.icon:Hide()
	self.cooldown:Hide()
	self.border:Hide()
	self.count:Hide()
	self.name:SetText("")
	self.hotkey:Hide()
	self:SetNormalTexture(QUICK_SLOT)
	self:SetChecked(0)
	self:Hide()
end

function TEB_Button:UpdateButton()
	self:SetTooltip()
	self:UpdateTexture()
	self:UpdateCooldown()
	self:UpdateChecked()
	self:UpdateEquipped()
	self:UpdateUsable()
	self:UpdateText()
	self:UpdateCount()
	if self.command then
		self.rangeTimer = -1
	else
		self.rangeTimer = nil
	end
end

local function EventCooldownUpdate(self, ...)
	self:UpdateCooldown()
end

local function EventLossOfControlUpdate(self, ...)
	--local args = {...}
	--local temp = ""
	--for _, v in pairs(args) do
	--	temp = temp..tostring(v)..", "
	--end
	--print("EventLossOfControlUpdate", temp)
	--if self.command and self.command == "spell" then
	--	local start, duration = GetSpellLossOfControlCooldown(self.value)
	--	self.cooldown:SetLossOfControlCooldown(start, duration)
	--end
end

local function EventCheckedUpdate(self, ...)
	self:UpdateChecked()
end

local function EventEquippedUpdate(self, ...)
	self:UpdateEquipped()
	self:UpdateText()
	self:UpdateCount()
	self:UpdateCooldown()
	self:UpdateChecked()
end

local function EventUsableUpdate(self, ...)
	self:UpdateUsable()
	self:UpdateText()
	self:UpdateCooldown()
end

local function EventMacroUpdate(self, ...)
	if InCombatLockdown() then
		return
	end

	if self.command == "macro" then
		--command = "macro", value = macro name, subValue = macro index
		local command, subValue = self.command, self.subValue
		local value = GetMacroInfo(subValue)
		self:Set(command, value, subValue, nil)
		self:SaveCommand(command, value, subValue, nil)
	end
end

local function EventRangeUpdate(self, ...)
	self:UpdateRange()
	self.rangeTimer = TOOLTIP_UPDATE_TIME
end

local function EventChargesUpdate(self, ...)
	self:UpdateCount()
end

local function EventSpellsChanged(self, ...)
	self:UpdateButton()
end

local function EventGlowShow(self, ...)
	self:GlowShow(...)
end

local function EventGlowHide(self, ...)
	self:GlowHide(...)
end

function TEB_Button:OnUpdate(elapsed)
	if self.flashing then
		local flashtime = self.flashtime
		flashtime = flashtime - elapsed
		
		if ( flashtime <= 0 ) then
			local overtime = -flashtime
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0
			end
			flashtime = ATTACK_BUTTON_FLASH_TIME - overtime

			local flashTexture = self.flash
			if flashTexture:IsShown() then
				flashTexture:Hide()
			else
				flashTexture:Show()
			end
		end
		
		self.flashtime = flashtime
	end

	local rangeTimer = self.rangeTimer
	if ( rangeTimer ) then
		rangeTimer = rangeTimer - elapsed

		if ( rangeTimer <= 0 ) then
			self:UpdateRange()
			rangeTimer = TOOLTIP_UPDATE_TIME
		end
		
		self.rangeTimer = rangeTimer
	end
end

function TEB_Button:OnEvent(event, ...)
	if event == "START_AUTOREPEAT_SPELL" then
		if self.command == "spell" and IsAutoRepeatSpell(self.value) then
			self:StartFlash()
		end
	elseif event == "STOP_AUTOREPEAT_SPELL" then
		if self.flashing and (self.command == "spell" and not(IsAttackSpell(self.value))) then
			self:StopFlash()
		end
	end
	if self.EventHandlersTable[event] then
		--print(event)
		self.EventHandlersTable[event](self, ...)
	end
end

function TEB_Button:RegisterEvents()
	--event table
	self.EventHandlersTable = {
		--cooldown
		["SPELL_UPDATE_COOLDOWN"] 			= EventCooldownUpdate,
		["BAG_UPDATE_COOLDOWN"] 			= EventCooldownUpdate,
		["ACTIONBAR_UPDATE_COOLDOWN"] 		= EventCooldownUpdate,
		["UPDATE_SHAPESHIFT_COOLDOWN"] 		= EventCooldownUpdate,
		["LOSS_OF_CONTROL_UPDATE"]			= EventLossOfControlUpdate,
		--checked
		["TRADE_SKILL_SHOW"] 				= EventCheckedUpdate,
		["TRADE_SKILL_CLOSE"] 				= EventCheckedUpdate,
		["ARCHAEOLOGY_TOGGLE"] 				= EventCheckedUpdate,
		["ARCHAEOLOGY_CLOSED"] 				= EventCheckedUpdate,
		["COMPANION_UPDATE"] 				= EventCheckedUpdate,
		["CURRENT_SPELL_CAST_CHANGED"] 		= EventCheckedUpdate,
		["ACTIONBAR_UPDATE_STATE"] 			= EventCheckedUpdate,
		["PLAYER_ENTER_COMBAT"] 			= EventCheckedUpdate,
		["PLAYER_LEAVE_COMBAT"] 			= EventCheckedUpdate,
		["START_AUTOREPEAT_SPELL"] 			= EventCheckedUpdate,
		["STOP_AUTOREPEAT_SPELL"] 			= EventCheckedUpdate,
		--["UPDATE_BONUS_ACTIONBAR"] 			= EventCheckedUpdate,
		--["ACTIONBAR_PAGE_CHANGED"] 			= EventCheckedUpdate,
		--equipment
		["PLAYER_EQUIPMENT_CHANGED"] 		= EventEquippedUpdate,
		["BAG_UPDATE"] 						= EventEquippedUpdate,
		--usable
		--["UNIT_INVENTORY_CHANGED"] 		= EventUsableUpdate,
		["SPELL_UPDATE_USABLE"] 			= EventUsableUpdate,
		["PLAYER_CONTROL_LOST"] 			= EventUsableUpdate,
		["PLAYER_CONTROL_GAINED"] 			= EventUsableUpdate,
		--["UPDATE_BONUS_ACTIONBAR"] 			= EventUsableUpdate,
		["ACTIONBAR_UPDATE_USABLE"] 		= EventUsableUpdate,
		["VEHICLE_UPDATE"] 					= EventUsableUpdate,
		["UPDATE_WORLD_STATES"] 			= EventUsableUpdate,
		--macro
		["UPDATE_MACROS"]					= EventMacroUpdate,
		--range
		["PLAYER_TARGET_CHANGED"]			= EventRangeUpdate,
		--charges
		["SPELL_UPDATE_CHARGES"]			= EventChargesUpdate,
		--spells
		["ACTIVE_TALENT_GROUP_CHANGED"]		= EventSpellsChanged,
		["SPELLS_CHANGED"]					= EventSpellsChanged,
		["LEARNED_SPELL_IN_TAB"] 			= EventSpellsChanged,
		["PLAYER_GUILD_UPDATE"] 			= EventSpellsChanged,
		["PLAYER_SPECIALIZATION_CHANGED"] 	= EventSpellsChanged,
		["COMPANION_LEARNED"] 				= EventSpellsChanged,
		["UPDATE_SHAPESHIFT_FORM"] 			= EventSpellsChanged,
		--glow
		["SPELL_ACTIVATION_OVERLAY_GLOW_SHOW"] = EventGlowShow,
		["SPELL_ACTIVATION_OVERLAY_GLOW_HIDE"] = EventGlowHide,
	}
	
	for k, _ in pairs(self.EventHandlersTable) do
		self:RegisterEvent(k)
	end

	self:SetScript("OnEvent", TEB_Button.OnEvent)
	self:SetScript("OnUpdate", TEB_Button.OnUpdate)
end

function TEB_Button:UnregisterEvents()
	if self.EventHandlersTable then
		for k, _ in pairs(self.EventHandlersTable) do
			self:UnregisterEvent(k)
		end
	end
	self.EventHandlersTable = {}
	self.rangeTimer = nil
	self.hotkey:Hide()
end

