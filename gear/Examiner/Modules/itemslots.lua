local ex = Examiner;
local cfg;
local gtt = GameTooltip;

-- Module
local mod = ex:CreateModule("ItemSlots");
mod.slotBtns = {};

-- Variables
local statTipStats1, statTipStats2 = {}, {};

-- Options
ex.options[#ex.options + 1] = { var = "alwaysShowItemLevel", default = true, label = "Always Show Item Levels", tip = "With this enabled, the items will always show their item levels, instead of having to hold down the ALT key." };

--------------------------------------------------------------------------------------------------------
--                                           Module Scripts                                           --
--------------------------------------------------------------------------------------------------------

-- OnInitialize
function mod:OnInitialize()
	cfg = ex.cfg;
end

-- OnInspectReady
function mod:OnInspectReady(unit,guid)
	self:UpdateItemSlots();
	self:ShowItemSlotButtons();
end
mod.OnInspect = mod.OnInspectReady;

-- OnCacheLoaded
function mod:OnCacheLoaded(entry,unit)
	self:UpdateItemSlots();
	self:ShowItemSlotButtons();
end

-- OnPageChanged
function mod:OnPageChanged(module,shown)
	self:ShowItemSlotButtons();
end

-- OnConfigChanged
function mod:OnConfigChanged(var,value)
	if (var == "alwaysShowItemLevel") then
		for index, button in ipairs(self.slotBtns) do
			if (value) and (button.link) then
				button.level:Show();
			else
				button.level:Hide();
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------
--                                          Helper Functions                                          --
--------------------------------------------------------------------------------------------------------

-- Show the Item Slot Buttons
function mod:ShowItemSlotButtons()
	local shownMod = (cfg.activePage and ex.modules[cfg.activePage]);
	local visible = (ex.itemsLoaded) and (not shownMod or shownMod.showItems or not shownMod.page:IsShown());
	for _, button in ipairs(self.slotBtns) do
		if (visible) then
			button:Show();
		else
			button:Hide();
		end
	end
end

-- UpdateSlot: Updates slot from "button.link"
function mod:UpdateItemSlots()
	for index, button in ipairs(self.slotBtns) do
		if (cfg.alwaysShowItemLevel) then
			button.level:Show();
		end
		button.itemLink = ex.info.Items[button.slotName]
		button.tmogLink = ex.info.Tmogs[button.slotName]
		button.link = button.itemLink
		button.realLink = nil
		button:UpdateTexture()
	end
end

--------------------------------------------------------------------------------------------------------
--                                          Item Slot Scripts                                         --
--------------------------------------------------------------------------------------------------------

-- Import from core.lua
local IsModifiedKey = ex.IsModifiedKey

-- OnEvent -- MODIFIER_STATE_CHANGED
local function OnEvent(self,event,key,state)
	if  event ~= 'MODIFIER_STATE_CHANGED'  then  return  end
	-- Toggle showing icon of the actual item or the tmog appearance
	-- Must do before UpdateTip() to update button.link
	self:UpdateTexture()
	
	-- Toggle ItemLevel
	--if (self.link) and (IsAltKeyDown()) then
	self.level:SetShown( cfg.alwaysShowItemLevel  or  self.link  and  IsModifiedKey('SHOW_ITEMLEVEL') )
	
	-- Update Tip
	if  gtt:IsOwned(self)  and  gtt:IsShown() then
		self:UpdateTip()
	end
end

-- OnDrag
local function OnDrag(self)
	if (ex:ValidateUnit() and UnitIsUnit(ex.unit,"player")) then
		PickupInventoryItem(self.id);
	end
end

-- OnClick
local function OnClick(self,button)
	if (CursorHasItem()) then
		OnDrag(self);
	elseif  ex.ItemButton_OnClick(self,button)  then
		-- All done
	elseif (self.realLink) then
		-- Az: this needs to be changed, look at shared onenter func for more info
		-- Az: should not be like this anymore, a single call to GetItemInfo() would make the client cache the item, so just make some kind of postcacheload thingie, or just redo the OnCacheLoaded event?
		-- self:UpdateTexture() should be enough in OnEnter
		local entryName = ex:GetEntryName();
		ex:ClearInspect();
		ex:LoadPlayerFromCache(entryName);
		self:GetScript("OnEnter")(self);
	end
end

-- OnShow
local function OnShow(self)
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
end

-- OnHide
local function OnHide(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	if (not cfg.alwaysShowItemLevel) then
		self.level:Hide();
	end
end

--------------------------------------------------------------------------------------------------------
--                                           Widget Creation                                          --
--------------------------------------------------------------------------------------------------------

for index, slot in ipairs(LibGearExam.Slots) do
	local btn = CreateFrame("Button","ExaminerItemButton"..slot,ex.model); -- Some other mods bug if you create this nameless
	btn:SetWidth(37);
	btn:SetHeight(37);
	btn:RegisterForClicks("LeftButtonUp","RightButtonUp");
	btn:RegisterForDrag("LeftButton");
	btn:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress");
	btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");

	btn:SetScript("OnShow",OnShow);
	btn:SetScript("OnHide",OnHide);
	btn:SetScript("OnClick",OnClick);
	btn:SetScript("OnEnter",ex.ItemButton_OnEnter);
	btn:SetScript("OnLeave",ex.ItemButton_OnLeave);
	btn:SetScript("OnEvent",OnEvent);
	btn:SetScript("OnDragStart",OnDrag);
	btn:SetScript("OnReceiveDrag",OnDrag);

	btn.id, btn.bgTexture = GetInventorySlotInfo(slot);
	btn.slotName = slot;
	btn.UpdateTexture = ex.ItemButton_UpdateTexture
	btn.UpdateTip = ex.ItemButton_UpdateTip

	btn.texture = btn:CreateTexture(nil,"BACKGROUND");
	btn.texture:SetAllPoints();

	btn.border = btn:CreateTexture(nil,"OVERLAY");
	btn.border:SetTexture("Interface\\Addons\\Examiner\\Textures\\Border");
	btn.border:SetWidth(41);
	btn.border:SetHeight(41);
	btn.border:SetPoint("CENTER");

	btn.level = btn:CreateFontString(nil,"ARTWORK","GameFontHighlight");
	btn.level:SetFont(GameFontHighlight:GetFont(),12,"OUTLINE");
	btn.level:SetPoint("BOTTOM",0,4);
	btn.level:Hide();

	if (index == 1) then
		btn:SetPoint("TOPLEFT",4,-3);
	elseif (index == 9) then
		btn:SetPoint("TOPRIGHT",-4,-3);
	elseif (index == 17) then
		btn:SetPoint("BOTTOM",-20,27);
	elseif (index <= 16) then
		btn:SetPoint("TOP",mod.slotBtns[index - 1],"BOTTOM",0,-4);
	else
		btn:SetPoint("LEFT",mod.slotBtns[index - 1],"RIGHT",5,0);
	end

	mod.slotBtns[index] = btn;
end