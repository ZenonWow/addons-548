NUM_ICONSEL_ICONS_PER_ROW = 5;
NUM_ICONSEL_ICON_ROWS = 8;
NUM_ICONSEL_ICONS_SHOWN = NUM_ICONSEL_ICONS_PER_ROW * NUM_ICONSEL_ICON_ROWS;
ICONSEL_ICON_ROW_HEIGHT = 36;
local EM_ICON_FILENAMES = {};

--local BL_TEXTURE = [[Interface\MacroFrame\MacroPopup-BotLeft]]
--local BR_TEXTURE = [[Interface\MacroFrame\MacroPopup-BotRight]]
local SCROLL_BAR_FNAME = [[Interface\ClassTrainerFrame\UI-ClassTrainer-ScrollBar]]
local BKG_LEFT_FNAME = [[Interface\MacroFrame\MacroPopup-TopLeft]]
local BKG_RIGHT_FNAME = [[Interface\MacroFrame\MacroPopup-TopRight]]

local ICONSEL_TEXTURE_NAME = "IconSelectionScrollTexture"

local tex_scroll, tex_bkg_left, tex_bkg_right

local function CreateTex(var_tex, parent, tex, layer, width, height, ...)
	if var_tex == nil then
		var_tex = parent:CreateTexture(ICONSEL_TEXTURE_NAME, layer)
	end
	var_tex:SetPoint(...)
	var_tex:SetTexture(tex)
	var_tex:SetWidth(width)
	var_tex:SetHeight(height)
	var_tex:Show()
	return var_tex
end


function IconSelectionDialogPopup_OnLoad (self)
	self.buttons = {};
	
	local rows = 0;
	
	local button = CreateFrame("CheckButton", "IconSelectionDialogPopupButton1", IconSelectionDialogPopup, "IconSelectionPopupButtonTemplate");
	button:SetPoint("TOPLEFT", 24, -85);
	button:SetID(1);
	tinsert(self.buttons, button);
	
	local lastPos;
	for i = 2, NUM_ICONSEL_ICONS_SHOWN do
		button = CreateFrame("CheckButton", "IconSelectionDialogPopupButton" .. i, IconSelectionDialogPopup, "IconSelectionPopupButtonTemplate");
		button:SetID(i);
		
		lastPos = (i - 1) / NUM_ICONSEL_ICONS_PER_ROW;
		if ( lastPos == math.floor(lastPos) ) then
			button:SetPoint("TOPLEFT", self.buttons[i-NUM_ICONSEL_ICONS_PER_ROW], "BOTTOMLEFT", 0, -8);
		else
			button:SetPoint("TOPLEFT", self.buttons[i-1], "TOPRIGHT", 10, 0);
		end
		tinsert(self.buttons, button);
	end

	local width = (ICONSEL_ICON_ROW_HEIGHT + 8) * NUM_ICONSEL_ICONS_PER_ROW + 77
	local height = (ICONSEL_ICON_ROW_HEIGHT + 8) * NUM_ICONSEL_ICON_ROWS + 122
	IconSelectionDialogPopup:SetWidth(width)
	IconSelectionDialogPopup:SetHeight(height)
	local scroll_width = width - 1
	local scroll_height = height - 103
	IconSelectionDialogPopupScrollFrame:SetWidth(scroll_width)
	IconSelectionDialogPopupScrollFrame:SetHeight(scroll_height)

	--[[for i, region in ipairs({IconSelectionDialogPopup:GetRegions()}) do
		if region:IsObjectType("Texture") then
			--print(region:GetTexture())
			if region:GetTexture() == BL_TEXTURE then
				--print("BL_TEXTURE found")
				region:ClearAllPoints()
				region:SetPoint("BOTTOMLEFT", IconSelectionDialogPopup, "BOTTOMLEFT", 0, -22)
			elseif region:GetTexture() == BR_TEXTURE then
				--print("BR_TEXTURE found")
				region:ClearAllPoints()
				region:SetPoint("BOTTOMRIGHT", IconSelectionDialogPopup, "BOTTOMRIGHT", 23, -22)
			end
		end
	end]]
	
	if scroll_height > 151 then
		CreateTex(tex_scroll, IconSelectionDialogPopupScrollFrame, SCROLL_BAR_FNAME, "BACKGROUND", 30, scroll_height - 151, "LEFT", IconSelectionDialogPopupScrollFrame, "RIGHT", -3, 0):SetTexCoord(0, 0.46875, 0.2, 0.9609375)
		CreateTex(tex_bkg_left, IconSelectionDialogPopup, BKG_LEFT_FNAME, "BACKGROUND", 256, scroll_height - 151, "TOPLEFT", IconSelectionDialogPopup, "TOPLEFT", 0, -212):SetTexCoord(0, 1, 0.5, 1)
		CreateTex(tex_bkg_right, IconSelectionDialogPopup, BKG_RIGHT_FNAME, "BACKGROUND", 64, scroll_height - 151, "TOPRIGHT", IconSelectionDialogPopup, "TOPRIGHT", 23, -212):SetTexCoord(0, 1, 0.5, 1)
	else
		if tex_scroll then 
			tex_scroll:Hide()
		end
		if tex_bkg_left then
			tex_bkg_left: Hide()
		end
		if tex_bkg_right then
			tex_bkg_right: Hide()
		end
	end

	self.SetSelection = function(self, fTexture, Value)
		if(fTexture) then
			self.selectedTexture = Value;
			self.selectedIcon = nil;
		else
			self.selectedTexture = nil;
			self.selectedIcon = Value;
		end
	end
end

function IconSelectionDialogPopup_OnShow (self)
	PlaySound("igCharacterInfoOpen");
	--self.name = nil;
	self.isEdit = false;
	RecalculateIconSelectionDialogPopup();
end

function IconSelectionDialogPopup_OnHide (self)
	--IconSelectionDialogPopup.name = nil;
	IconSelectionDialogPopup:SetSelection(true, nil);
	--IconSelectionDialogPopupEditBox:SetText("");
	if (not PaperDollEquipmentManagerPane.selectedSetName) then
		PaperDollFrame_ClearIgnoredSlots();
	end
	EM_ICON_FILENAMES = nil;
	collectgarbage();
end

--[[
RefreshIconSelectionIconInfo() counts how many uniquely textured inventory items the player has equipped. 
]]
local function RefreshIconSelectionIconInfo ()
	EM_ICON_FILENAMES = {};
	EM_ICON_FILENAMES[1] = "INV_MISC_QUESTIONMARK";
	local index = 2;

	for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local itemTexture = GetInventoryItemTexture("player", i);
		if ( itemTexture ) then
			EM_ICON_FILENAMES[index] = gsub( strupper(itemTexture), "INTERFACE\\ICONS\\", "" );
			if(EM_ICON_FILENAMES[index]) then
				index = index + 1;
				--[[
				Currently checks all for duplicates, even though only rings, trinkets, and weapons may be duplicated. 
				This version is clean and maintainable.
				]]
				for j=INVSLOT_FIRST_EQUIPPED, (index-1) do
					if(EM_ICON_FILENAMES[index] == EM_ICON_FILENAMES[j]) then
						EM_ICON_FILENAMES[index] = nil;
						index = index - 1;
						break;
					end
				end
			end
		end
	end
	GetMacroItemIcons(EM_ICON_FILENAMES);
	GetMacroIcons(EM_ICON_FILENAMES);
end


--[[ 
GetIconSelectionIconInfo(index) determines the texture and real index of a regular index
	Input: 	index = index into a list of equipped items followed by the macro items. Only tricky part is the equipped items list keeps changing.
	Output: the associated texture for the item, and a index relative to the join point between the lists, i.e. negative for the equipped items
			and positive for the macro items//
]]
local function GetIconSelectionIconInfo(index)
	return EM_ICON_FILENAMES[index];

end

function RecalculateIconSelectionDialogPopup(setName, iconTexture)
	local popup = IconSelectionDialogPopup;
	--[[if ( setName and setName ~= "") then
		IconSelectionDialogPopupEditBox:SetText(setName);
		IconSelectionDialogPopupEditBox:HighlightText(0);
	else
		IconSelectionDialogPopupEditBox:SetText("");
	end]]
	
	if (iconTexture) then
		popup:SetSelection(true, iconTexture);
	else
		popup:SetSelection(false, 1);
	end
	
	--[[ 
	Scroll and ensure that any selected equipment shows up in the list.
	When we first press "save", we want to make sure any selected equipment set shows up in the list, so that
	the user can just make his changes and press Okay to overwrite.
	To do this, we need to find the current set (by icon) and move the offset of the IconSelectionDialogPopup
	to display it. Issue ID: 171220
	]]
	RefreshIconSelectionIconInfo();
	local totalItems = #EM_ICON_FILENAMES;
	local texture, _;
	if (popup.selectedTexture) then
		local foundIndex = nil;
		for index = 1, totalItems do
			texture = GetIconSelectionIconInfo(index);
			if ( texture == popup.selectedTexture ) then
				foundIndex = index;
				break;
			end
		end
		if (foundIndex == nil) then
			foundIndex = 1;
		end
		-- now make it so we always display at least NUM_ICONSEL_ICON_ROWS of data
		local offsetnumIcons = floor((totalItems - 1) / NUM_ICONSEL_ICONS_PER_ROW);
		local offset = floor((foundIndex - 1) / NUM_ICONSEL_ICONS_PER_ROW);
		offset = offset + min((NUM_ICONSEL_ICON_ROWS - 1), offsetnumIcons - offset) - (NUM_ICONSEL_ICON_ROWS - 1);
		if (foundIndex <= NUM_ICONSEL_ICONS_SHOWN) then
			offset = 0;			--Equipment all shows at the same place.
		end
		FauxScrollFrame_OnVerticalScroll(IconSelectionDialogPopupScrollFrame, offset * ICONSEL_ICON_ROW_HEIGHT, ICONSEL_ICON_ROW_HEIGHT, nil);
	else
		FauxScrollFrame_OnVerticalScroll(IconSelectionDialogPopupScrollFrame, 0, ICONSEL_ICON_ROW_HEIGHT, nil);
	end
	IconSelectionDialogPopup_Update();
end

function IconSelectionDialogPopup_Update ()
	RefreshEquipmentSetIconInfo();

	local popup = IconSelectionDialogPopup;
	local buttons = popup.buttons;
	local offset = FauxScrollFrame_GetOffset(IconSelectionDialogPopupScrollFrame) or 0;
	local button;	
	-- Icon list
	local texture, index, button, realIndex, _;
	for i=1, NUM_ICONSEL_ICONS_SHOWN do
		local button = buttons[i];
		index = (offset * NUM_ICONSEL_ICONS_PER_ROW) + i;
		if ( index <= #EM_ICON_FILENAMES ) then
			texture = GetEquipmentSetIconInfo(index);
			-- button.name:SetText(index); --dcw
			button.icon:SetTexture("INTERFACE\\ICONS\\"..texture);
			button:Show();
			if ( index == popup.selectedIcon ) then
				button:SetChecked(1);
			elseif ( texture == popup.selectedTexture ) then
				button:SetChecked(1);
				popup:SetSelection(false, index);
			else
				button:SetChecked(nil);
			end
		else
			button.icon:SetTexture("");
			button:Hide();
		end
		
	end
	
	-- Scrollbar stuff
	FauxScrollFrame_Update(IconSelectionDialogPopupScrollFrame, ceil(#EM_ICON_FILENAMES / NUM_ICONSEL_ICONS_PER_ROW) , NUM_ICONSEL_ICON_ROWS, GEARSET_ICON_ROW_HEIGHT );
end

function IconSelectionDialogPopupOkay_Update ()
	local popup = IconSelectionDialogPopup;
	local button = IconSelectionDialogPopupOkay;
	
	if ( popup.selectedIcon ) then --and popup.name
		button:Enable();
	else
		button:Disable();
	end
end

local SetIconCallback

function IconSelectionDialogPopup_SetCallback(callback)
	SetIconCallback = callback
end

function IconSelectionDialogPopupOkay_OnClick (self, button, pushed)
	local popup = IconSelectionDialogPopup;
	local iconTexture = GetEquipmentSetIconInfo(popup.selectedIcon);
	--print(iconTexture, popup.selectedIcon)
	
	if SetIconCallback then
		SetIconCallback(self, iconTexture)
	end
	popup:Hide();
end

function IconSelectionDialogPopupCancel_OnClick ()
	IconSelectionDialogPopup:Hide();
end

function IconSelectionPopupButton_OnClick (self, button)
	local popup = IconSelectionDialogPopup;
	local offset = FauxScrollFrame_GetOffset(IconSelectionDialogPopupScrollFrame) or 0;
	popup.selectedIcon = (offset * NUM_ICONSEL_ICONS_PER_ROW) + self:GetID();
 	popup.selectedTexture = nil;
	IconSelectionDialogPopup_Update();
	IconSelectionDialogPopupOkay_Update();
end
