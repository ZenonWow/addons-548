--####################################################################################
--####################################################################################
--Main class
--####################################################################################
--####################################################################################
--Dependencies: LinkWebParsing.lua, Locale.lua, SearchProvider.lua

--LINKSINCHAT_GameVersion		= nil; --UIversion number of the game for quick lookup for other parts of the code for compatibility
	--if (LINKSINCHAT_GameVersion < 50300) then
		--Before patch 5.3.0

--local LINKSINCHAT_addon_version = GetAddOnMetadata("LinksInChat", "Version");	--Version number for the addon

--####################################################################################
--####################################################################################
--Event Handling and Cache
--####################################################################################

LinksInChat			= {};	--Global declaration
LinksInChat.__index	= LinksInChat;

local LinkWebParsing	= LinksInChat_LinkWebParsing;		--Local pointer
local Locale			= LinksInChat_Locale;
local SearchProvider	= LinksInChat_SearchProvider;

LINKSINCHAT_settings	= {};		--Array of Settings	(SAVED TO DISK)
--[[
	Color				:: Number	: Hex formatted color for links (RRGGBB)
	AutoHide			:: Number	: Hide copy frame after N seconds. Positive number in seconds or -1 to disable the feature.
	IgnoreHyperlinks 	:: Boolean	: Ignore any hyperlinks [myitem] etc. and will just work for web links www. and http://
	Simple				:: Boolean	: Always simple-search for providers (only search for item name and dont try to lookup using spellid, factionname etc).
	UseHTTPS			:: Boolean	: Use https:// or http:// (true).
	AlwaysEnglish		:: Boolean  : Always use english search provider.
	Provider			:: String	: Dropdown of several different search providers for itemlinks (Google, Bing, Wowdb, Wowhead, etc).
]]--

--Local variables that cache stuff so we dont have to recreate large objects
local cache_Color_HyperLinks	= "FF0080"; --Pink hyperlink color
local cache_Provider			= nil; --Current selected provider
local hook_ChatFrame_OnHyperlinkShow = nil; --ChatFrame_OnHyperlinkShow; --Original function

--Handles the events for the addon
function LinksInChat:OnEvent(s, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		--Startup

		--Register for chat channels (rest is done in LinkWebParsing)
		LinkWebParsing:RegisterMessageEventFilters(true);
		---------------------------------------------------------------------------

		--Apply default settings.
		cache_Color_HyperLinks	= self:GetCurrentSetting("Color") or "FF0080"; --Pink color
		local s_AutoHide		= self:GetCurrentSetting("AutoHide") or -1;
		local s_Ignore			= self:GetCurrentSetting("IgnoreHyperlinks") or false;
		local s_Simple			= self:GetCurrentSetting("Simple") or false;
		local s_HTTPS			= self:GetCurrentSetting("UseHTTPS") or true;
		local s_English			= self:GetCurrentSetting("AlwaysEnglish") or false;
		local s_Provider		= self:GetCurrentSetting("Provider") or "wowhead";

		--Validate Provider
		SearchProvider:InitializeProvider(s_English);
		if (SearchProvider:ProviderExists(s_Provider) ~= true) then s_Provider = "wowhead"; end
		cache_Provider = SearchProvider:GetProvider(s_Provider);

		self:SetCurrentSetting("Color", cache_Color_HyperLinks);
		self:SetCurrentSetting("AutoHide", s_AutoHide);
		self:SetCurrentSetting("IgnoreHyperlinks", s_Ignore);
		self:SetCurrentSetting("Simple", s_Simple);
		self:SetCurrentSetting("UseHTTPS", s_HTTPS);
		self:SetCurrentSetting("AlwaysEnglish", s_English);
		self:SetCurrentSetting("Provider", s_Provider);
		---------------------------------------------------------------------------

		--Hook into chat
		hook_ChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow; --Save pointer to Original function
		ChatFrame_OnHyperlinkShow = LinksInChat_ChatFrame_OnHyperlinkShow; --Override with our own function.
		---------------------------------------------------------------------------

		--After the first call to RegisterMessageEventFilters we dont need this anymore
		s:UnregisterEvent("PLAYER_ENTERING_WORLD");

		--[[
		local h = "\124cffffff00\124Hachievement:8304:"..UnitGUID("player")..":0:0:0:0:0:0:0:0\124h[Mount Parade]\124h\124r";
		local h1 = "\124cffe5cc80\124Hitem:104406:0:0:0:0:0:0:0:0:0:0\124h[Hellscream's War Staff]\124h\124r";
		local h2 = "\124cffffd000\124Hspell:108978\124h[Alter Time]\124h\124r";
		local h3 = "\124cffffffff\124Hitem:89112:0:0:0:0:0:0:0:0:0:0\124h[Mote of Harmony]\124h\124r";
		local h4 = "\124cffffd000\124Hspell:44457\124h[Living Bomb]\124h\124r";
		print("  ");
		print("        "..h);
		print("        "..h1);
		print("        "..h2);
		print("        "..h3);
		print("        "..h4);
		print("  ");
		--]]--
	end
	return nil;
end


local TimeSinceLastUpdate		= 0;
local booTimeSinceLastUpdate	= false;
--Handles OnUpdate for the Copy frame
function LinksInChat:Copy_Frame_OnUpdate(s, elapsed)
	TimeSinceLastUpdate	= TimeSinceLastUpdate + elapsed;

	if (booTimeSinceLastUpdate) then return nil end --flag to prevent multiple runs of the same code while another is already running
	booTimeSinceLastUpdate = true;

	local sec = tonumber(self:GetCurrentSetting("AutoHide")); --Positive number or -1 if the feature is disabled.
	if (sec ~= nil and sec > 0) then
		local diff = floor( (sec - TimeSinceLastUpdate) );
		if (diff > -1) then LinksInChat_Copy_Frame_Countdown:SetText(diff); end --Update countdown timer

		if (TimeSinceLastUpdate >= sec) then --We only execute this code once to hide the frame
			s:Hide(); --This will stop the event from beign triggered anymore.
			TimeSinceLastUpdate = 0;
			LinksInChat_Copy_Frame_Countdown:SetText("");
		end	--if
	end--if sec

	booTimeSinceLastUpdate = false; --Reset flag and free the method up for the next execution
	return nil;
end


--Returns the current value for a setting.
function LinksInChat:GetCurrentSetting(strSetting)
	if (strSetting == nil) then return nil end
	strSetting = strupper(strSetting);
	return LINKSINCHAT_settings[strSetting];
end


--Sets the current value for a setting.
function LinksInChat:SetCurrentSetting(strSetting, objValue)
	if (strSetting == nil) then return nil end
	strSetting = strupper(strSetting);
	LINKSINCHAT_settings[strSetting] = objValue;
	return objValue;
end


--####################################################################################
--####################################################################################
--Settings frame
--####################################################################################


function LinksInChat:SettingsFrame_OnLoad(panel)
	-- Set the name of the Panel
	panel.name = Locale["CopyFrame Title"];--"LinksInChat";
	panel.default	= function (self) end; --So few settings that we simply ignore the reset button

	--Add the panel to the Interface Options
	InterfaceOptions_AddCategory(panel);
end


--Called after settings related to search provider has been changed
function LinksInChat:UpdateProvider()
	--Get current settings
	local s_English			= self:GetCurrentSetting("AlwaysEnglish") or false;
	local s_Provider		= self:GetCurrentSetting("Provider") or "wowhead";

	--Validate search provider
	SearchProvider:InitializeProvider(s_English);
	if (SearchProvider:ProviderExists(s_Provider) ~= true) then s_Provider = "wowhead"; end
	cache_Provider = SearchProvider:GetProvider(s_Provider);

	return nil;
end


--####################################################################################
--####################################################################################
--Settings frame - Color picker
--####################################################################################


function LinksInChat:ShowColorPicker(objTexture)
	local strColor	= self:GetCurrentSetting("Color");
	local r,g,b		= self:HexColorToRGBPercent(strColor);

	local cf = ColorPickerFrame;
	cf:SetColorRGB(r,g,b);
	cf.hasOpacity = false; --We dont have Alpha for link colors.
	cf.opacity = 1;

	local f = function() end;
	local o = function() LinksInChat:ColorPicker_Callback("ok", objTexture) end;
	local c = function() LinksInChat:ColorPicker_Callback("cancel", objTexture) end;
	cf.func, cf.opacityFunc, cf.cancelFunc = f, o, c;
	cf:Hide(); -- Need to run the OnShow handler.
	cf:Show();
	return nil;
end


function LinksInChat:ColorPicker_Callback(restore, objTexture)
	local cf = ColorPickerFrame;

	if (restore == "ok") then --'ok' or 'cancel'
		local r,g,b = cf:GetColorRGB();
		--local a = OpacitySliderFrame:GetValue();
		objTexture:SetTexture(r,g,b,1);

		cache_Color_HyperLinks = self:RGBPercentToHex(r,g,b); --HEX formatted string
		self:SetCurrentSetting("Color", cache_Color_HyperLinks);
	end--if restore

	--Cleanup
	local f = function() end;
	cf.func, cf.opacityFunc, cf.cancelFunc = f,f,f;
	return nil;
end


--Takes a RGB percent set (0.0-1.0) and converts it to a hex string.
function LinksInChat:RGBPercentToHex(r,g,b)
	--Source: http://www.wowwiki.com/RGBPercToHex
	r = r <= 1 and r >= 0 and r or 0;
	g = g <= 1 and g >= 0 and g or 0;
	b = b <= 1 and b >= 0 and b or 0;
	return strupper(format("%02x%02x%02x", r*255, g*255, b*255));
end


--Returns r, g, b for a given hex colorstring
function LinksInChat:HexColorToRGBPercent(strHexColor)
	--Expects: RRGGBB  --Red, Green, Blue
	if (strlen(strHexColor) ~= 6) then return nil end
	local tonumber	= tonumber; --local fpointer
	local strsub	= strsub;

	local r, g, b = (tonumber( strsub(strHexColor,1,2), 16) /255), (tonumber( strsub(strHexColor,3,4), 16) /255), (tonumber( strsub(strHexColor,5,6), 16) /255);
	if (r==nil or g==nil or b==nil) then return nil end
	return r, g, b;
end


--####################################################################################
--####################################################################################
--Settings frame - Dropdown menus
--####################################################################################
--Source: InterfaceOptionsPanel.lua, InterfaceOptionsPanel.xml ($parentAutoLootKeyDropDown)


function LinksInChat:Settings_Frame_DropDown_AutoHide_OnEvent(objSelf, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		objSelf.defaultValue = -1;
		objSelf.oldValue = self:GetCurrentSetting("AutoHide");
		objSelf.value = objSelf.oldValue or objSelf.defaultValue;

		local init = function(...) return self.Settings_Frame_DropDown__AutoHide_Initialize(self,...) end; --This function is called each time the Dropdown menu is clicked

		UIDropDownMenu_SetWidth(objSelf, 150);
		UIDropDownMenu_Initialize(objSelf, init);
		UIDropDownMenu_SetSelectedValue(objSelf, objSelf.value);

		objSelf.SetValue		=	function(objSelf, value)
										objSelf.value = value
										UIDropDownMenu_SetSelectedValue(objSelf, value)
										self:SetCurrentSetting("AutoHide", value)
									end;
		objSelf.GetValue		=	function(objSelf)
										return UIDropDownMenu_GetSelectedValue(objSelf)
									end;
		objSelf.RefreshValue	=	function (objSelf)
										UIDropDownMenu_Initialize(objSelf, init)
										UIDropDownMenu_SetSelectedValue(objSelf, objSelf.value)
									end;
		objSelf:UnregisterEvent(event);
	end--if event
end

function LinksInChat_Settings_Frame_DropDown_AutoHide_OnClick(self)
	--We declare this one here. If we declared it inline in :Settings_Frame_DropDown__AutoHide_Initialize(), it would mean that every time that the user clicked the dropdown it would generate a new and wasted function pointer
	LinksInChatXML_Settings_Frame_DropDown_AutoHide:SetValue(self.value);
end

function LinksInChat:Settings_Frame_DropDown__AutoHide_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(LinksInChatXML_Settings_Frame_DropDown_Provider);
	local info = UIDropDownMenu_CreateInfo();

	local Lsub = Locale["Dropdown Options Autohide"];
	info.text = Lsub["none"]; --"Don't hide";
	info.func = LinksInChat_Settings_Frame_DropDown_AutoHide_OnClick;
	info.value = -1;
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.text = Lsub["3sec"]; --"3 seconds";
	info.func = LinksInChat_Settings_Frame_DropDown_AutoHide_OnClick;
	info.value = 3;
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.text = Lsub["5sec"]; --"5 seconds";
	info.func = LinksInChat_Settings_Frame_DropDown_AutoHide_OnClick;
	info.value = 5;
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.text = Lsub["7sec"]; --"7 seconds";
	info.func = LinksInChat_Settings_Frame_DropDown_AutoHide_OnClick;
	info.value = 7;
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.text = Lsub["10sec"]; --"10 seconds";
	info.func = LinksInChat_Settings_Frame_DropDown_AutoHide_OnClick;
	info.value = 10;
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);
end


function LinksInChat:Settings_Frame_DropDown_Provider_OnEvent(objSelf, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		objSelf.defaultValue = "wowhead";
		objSelf.oldValue = self:GetCurrentSetting("Provider");
		objSelf.value = objSelf.oldValue or objSelf.defaultValue;

		local init = function(...) return self.Settings_Frame_DropDown__Provider_Initialize(self,...) end; --This function is called each time the Dropdown menu is clicked

		UIDropDownMenu_SetWidth(objSelf, 220);
		UIDropDownMenu_Initialize(objSelf, init);
		UIDropDownMenu_SetSelectedValue(objSelf, objSelf.value);

		objSelf.SetValue		=	function(objSelf, value)
										objSelf.value = value
										UIDropDownMenu_SetSelectedValue(objSelf, value)
										self:SetCurrentSetting("Provider", value)
										self:UpdateProvider()
									end;
		objSelf.GetValue		=	function(objSelf)
										return UIDropDownMenu_GetSelectedValue(objSelf)
									end;
		objSelf.RefreshValue	=	function (objSelf)
										UIDropDownMenu_Initialize(objSelf, init)
										UIDropDownMenu_SetSelectedValue(objSelf, objSelf.value)
									end;
		objSelf:UnregisterEvent(event);
	end--if event
end

function LinksInChat_Settings_Frame_DropDown_Provider_OnClick(self)
	--We declare this one here. If we declared it inline in :Settings_Frame_DropDown__Provider_Initialize(), it would mean that every time that the user clicked the dropdown it would generate a new and wasted function pointer
	LinksInChatXML_Settings_Frame_DropDown_Provider:SetValue(self.value);
end

function LinksInChat:Settings_Frame_DropDown__Provider_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(LinksInChatXML_Settings_Frame_DropDown_Provider);
	local info = UIDropDownMenu_CreateInfo();

	local tblProviders, tblSorted = SearchProvider:GetProvider("all");

	for i = 1, #tblSorted do --tblSorted gives us a sorted list of the key's
		local providerKey	= strlower(tostring(tblSorted[i])); --key = "provider uniqe name", data = table with localized provider data
		local title			=  tblProviders[providerKey]["Title"];
		info.text = title;
		info.func = LinksInChat_Settings_Frame_DropDown_Provider_OnClick;
		info.value = providerKey;
		if ( info.value == selectedValue ) then
			info.checked = 1;
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end--for i
	return nil;
end


--####################################################################################
--####################################################################################
--Copy link frame
--####################################################################################


function LinksInChat:ShowCopyFrame(linkType, text, link)
	--linkType: either 'wcl' or 'other'. If it's wcl then its a www or http:// link and we use text. Otherwise its a hyperlink and we must use that
	--returns: true if the linktype is unknown and the link should be propagated further. otherwise false.
	local message, res = "", true;

	if (linkType == "wcl") then
		message = self:WebLink_Strip(text);
		res = false;
	else
		if (self:GetCurrentSetting("IgnoreHyperlinks") == true) then return true; end --Return immediatly if we are to ignore hyperlinks all together
		message = LinkWebParsing:getHyperLinkURI(link, text, cache_Provider, self:GetCurrentSetting("Simple"), self:GetCurrentSetting("UseHTTPS") ); --Returns an string or nil.
		if (message == nil) then return true; end --Will be nil if we do not support the hyperlink.
		res = false;
	end--if linkType

	--Display frame with pre-selected uri ready to be copied to the clipboard
	LinksInChat_Copy_Frame:Hide();
	LinksInChat_Copy_Frame_EditBox:SetText(message);
	LinksInChat_Copy_Frame:Show();

	return res;
end


--####################################################################################
--####################################################################################
--Custom hyperlink handling
--####################################################################################


--Returns a wcl: hyperlink in the correct format
function LinksInChat:HyperLink_Create(title)
	--Format: |cFF000000|Hwcl:|h[title]|h|r
	local res = "|cFF@COLOR@|Hwcl:|h@TITLE@|h|r";
	res = LinkWebParsing:replace(res, "@COLOR@", cache_Color_HyperLinks);
	res = LinkWebParsing:replace(res, "@TITLE@", tostring(title) ); --Manually add [ ] if you want that as part of the title
	return res;
end


--Removes any weblink data from the string
function LinksInChat:WebLink_Strip(link)
	--[[
		Weblinks can be inside Weblinks (www. inside http://)
		Hyperlinks can not be inside weblinks
		"Hello|cFF000000http://www.link.com|h|r|cff000000[item]|h|rWorld"
	]]--
	local link2 = LinkWebParsing:replace(link, "|cFF"..tostring(cache_Color_HyperLinks).."|Hwcl:|h", ""); --plain replace of the whole beginning of the string
	local link2 = LinkWebParsing:replace(link, "|cFF"..tostring(cache_Color_HyperLinks).."|Hwcl:|h", ""); --plain replace of the whole beginning of the string
	if (link2 ~= link) then
		link2 = LinkWebParsing:replace(link2, "|h|r", ""); --plain replace at the end of the string
		return link2;
	end
	return link;
end


--Returns the plain text title of a web-link (http:// etc)
function LinksInChat:HyperLink_Strip(link)
	local p = "%|h(.-)%|h%|r"; --Just the text inside the hyperlink (note we dont use the [ ] in web-links
	local startPos, endPos, firstWord, restOfString = strfind(link, p);
	if (firstWord ~= nil) then return firstWord; end
	return nil;
end


--####################################################################################
--####################################################################################
--Hooks
--####################################################################################


--This hook makes us able to create and handle customized hyperlinks for the addon
function LinksInChat_ChatFrame_OnHyperlinkShow(chatframe, link, text, button) --function ChatFrame_OnHyperlinkShow(chatframe, link, text, button)
	--Hook is done in LinksInChat:OnEvent()
	local start = strfind(link, "wcl:", 1, true); --plain find starting at pos 1 in the string
	if (start == 1) then --This is a web-link (not a hyperlink)
		if (IsShiftKeyDown()==1) then
			--Shift was held while clicking the web-link, we pass it along like a normal string (if the editbox is visible at the moment)...
			local t = strtrim(LinksInChat:HyperLink_Strip(text));
			if (t ~= nil) then
				local n = chatframe:GetName().."EditBox";
				local f = _G[n];
				--If the user presses Shift, we insert the web-link in plaintext into the chatframe's editbox.
				if (f ~= nil) then
					if (f:IsVisible() == 1) then
						f:Insert(" "..t.." "); --Editbox already open
					else
						f:Show();
						f:Insert(t.." ");
						f:SetFocus();
					end--if f:isVisible()
				end---if f
			end--if t

		else
			--Shift was not held down
			LinksInChat:ShowCopyFrame("wcl", text, nil); --Show the text of the link
		end--if IsShiftKeyDown

		return nil; --Stop propagation of all wcl: web-links
	else --This is a Hyperlink
		if (IsAltKeyDown()==1) then
			--If Alt was held while clicking the hyperlink we will show the copy window too (maybe; depending on the link)
			local propagate = LinksInChat:ShowCopyFrame("other", text, link); --Show the text of the link
			if (propagate == false) then return nil; end --Stop further propagation of this hyperlink (we have shown the copy frame for it)

			--If the Hyperlink-type is of some unknown type (maybe some custom addon hyperlink??), we will just leave it alone...
			return hook_ChatFrame_OnHyperlinkShow(chatframe, link, text, button);
		end--if IsAltKeyDown

		--Regular hyperlink without ALT beign held. Pass it along.
		return hook_ChatFrame_OnHyperlinkShow(chatframe, link, text, button);
	end--if start
end


--####################################################################################
--####################################################################################
