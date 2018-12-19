-- functions to manage tab interfaces where only one tab of a group may be selected
function Lib_PanelTemplates_Tab_OnClick(self, frame)
	Lib_PanelTemplates_SetTab(frame, self:GetID())
end

function Lib_PanelTemplates_SetTab(frame, id)
	frame.selectedTab = id;
	Lib_PanelTemplates_UpdateTabs(frame);
end

function Lib_PanelTemplates_GetSelectedTab(frame)
	return frame.selectedTab;
end

function Lib_PanelTemplates_UpdateTabs(frame)
	if ( frame.selectedTab ) then
		local tab;
		for i=1, frame.numTabs, 1 do
			tab = _G[frame:GetName().."Tab"..i];
			if ( tab.isDisabled ) then
				Lib_PanelTemplates_SetDisabledTabState(tab);
			elseif ( i == frame.selectedTab ) then
				Lib_PanelTemplates_SelectTab(tab);
			else
				Lib_PanelTemplates_DeselectTab(tab);
			end
		end
	end
end

function Lib_PanelTemplates_GetTabWidth(tab)
	local tabName = tab:GetName();

	local sideWidths = 2 * _G[tabName.."Left"]:GetWidth();
	return tab:GetTextWidth() + sideWidths;
end

function Lib_PanelTemplates_TabResize(tab, padding, absoluteSize, minWidth, maxWidth, absoluteTextSize)
	local tabName = tab:GetName();
	
	local buttonMiddle = _G[tabName.."Middle"];
	local buttonMiddleDisabled = _G[tabName.."MiddleDisabled"];
	local sideWidths = 2 * _G[tabName.."Left"]:GetWidth();
	local tabText = _G[tab:GetName().."Text"];
	local width, tabWidth;
	local textWidth;
	if ( absoluteTextSize ) then
		textWidth = absoluteTextSize;
	else
		tabText:SetWidth(0);
		textWidth = tabText:GetWidth();
	end
	-- If there's an absolute size specified then use it
	if ( absoluteSize ) then
		if ( absoluteSize < sideWidths) then
			width = 1;
			tabWidth = sideWidths
		else
			width = absoluteSize - sideWidths;
			tabWidth = absoluteSize
		end
		tabText:SetWidth(width);
	else
		-- Otherwise try to use padding
		if ( padding ) then
			width = textWidth + padding;
		else
			width = textWidth + 24;
		end
		-- If greater than the maxWidth then cap it
		if ( maxWidth and width > maxWidth ) then
			if ( padding ) then
				width = maxWidth + padding;
			else
				width = maxWidth + 24;
			end
			tabText:SetWidth(width);
		else
			tabText:SetWidth(0);
		end
		if (minWidth and width < minWidth) then
			width = minWidth;
		end
		tabWidth = width + sideWidths;
	end
	
	if ( buttonMiddle ) then
		buttonMiddle:SetWidth(width);
	end
	if ( buttonMiddleDisabled ) then
		buttonMiddleDisabled:SetWidth(width);
	end
	
	tab:SetWidth(tabWidth);
	local highlightTexture = _G[tabName.."HighlightTexture"];
	if ( highlightTexture ) then
		highlightTexture:SetWidth(tabWidth);
	end
end

function Lib_PanelTemplates_SetNumTabs(frame, numTabs)
	frame.numTabs = numTabs;
end

function Lib_PanelTemplates_DisableTab(frame, index)
	_G[frame:GetName().."Tab"..index].isDisabled = 1;
	Lib_PanelTemplates_UpdateTabs(frame);
end

function Lib_PanelTemplates_EnableTab(frame, index)
	local tab = _G[frame:GetName().."Tab"..index];
	tab.isDisabled = nil;
	-- Reset text color
	tab:SetDisabledFontObject(GameFontHighlightSmall);
	Lib_PanelTemplates_UpdateTabs(frame);
end

function Lib_PanelTemplates_DeselectTab(tab)
	local name = tab:GetName();
	_G[name.."Left"]:Show();
	_G[name.."Middle"]:Show();
	_G[name.."Right"]:Show();
	--tab:UnlockHighlight();
	tab:Enable();
	_G[name.."Text"]:SetPoint("CENTER", tab, "CENTER", (tab.deselectedTextX or 0), (tab.deselectedTextY or 2));
		
	_G[name.."LeftDisabled"]:Hide();
	_G[name.."MiddleDisabled"]:Hide();
	_G[name.."RightDisabled"]:Hide();
end

function Lib_PanelTemplates_SelectTab(tab)
	local name = tab:GetName();
	_G[name.."Left"]:Hide();
	_G[name.."Middle"]:Hide();
	_G[name.."Right"]:Hide();
	--tab:LockHighlight();
	tab:Disable();
	tab:SetDisabledFontObject(GameFontHighlightSmall);
	_G[name.."Text"]:SetPoint("CENTER", tab, "CENTER", (tab.selectedTextX or 0), (tab.selectedTextY or -3));
	
	_G[name.."LeftDisabled"]:Show();
	_G[name.."MiddleDisabled"]:Show();
	_G[name.."RightDisabled"]:Show();
	
	if ( GameTooltip:IsOwned(tab) ) then
		GameTooltip:Hide();
	end
end

function Lib_PanelTemplates_SetDisabledTabState(tab)
	local name = tab:GetName();
	_G[name.."Left"]:Show();
	_G[name.."Middle"]:Show();
	_G[name.."Right"]:Show();
	--tab:UnlockHighlight();
	tab:Disable();
	tab.text = tab:GetText();
	-- Gray out text
	tab:SetDisabledFontObject(GameFontDisableSmall);
	_G[name.."LeftDisabled"]:Hide();
	_G[name.."MiddleDisabled"]:Hide();
	_G[name.."RightDisabled"]:Hide();
end
