local AddonName, Addon = ...
local AddonLastUpdated = "02/14/2018"

--[[ Global Variables
removed:
/run  Binder_Settings = nil
--]]
-- minimap button savedVar: BinderSettingsDB.minimap
--BinderSettingsDB = {}
--BinderProfilesDB = nil

--[[
local BinderMinimapSettings = {
	ShowMinimapButton = true;
	MinimapRadioOption = 2;
	xposition = 300;
	yposition = 0; -- default position of the minimap icon
	degree = -12;
}
--]]

local Binder_Profiles_Idx= nil
local SelectedProfile_Name = nil



--This appears in your chat frame
local function out_frame(text)
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

--This appears on the top of your screen
local function out(text)
	UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0, 1, 10)
end

--This appears both in chat and on the top of your screen
local function out_both(text)
	out_frame(text) ; out(text)
end


function GetProfileName(profile)  return  profile.Name  or  profile[1] and profile[1].Name  end


function Binder_OnLoad(self)
	--out_frame("Binder is Loaded. Use /binder for help");
	self:RegisterEvent( "ADDON_LOADED" );

	SLASH_BINDER1 = "/binder";
	SlashCmdList["BINDER"] = function (cmd, editbox)
		local command, rest = cmd:match("^(%S*)%s*(.-)$");
		if  not command  or  command == ""  or  command == "toggle"  then
			Binder_Toggle()
		elseif command == "load" and rest ~= "" then
			LoadProfile(rest);
		elseif command == "info" then
			out_frame("Created by: Tensai");
			local version= GetAddOnMetadata(AddonName, "Version")  or  ""
			out_frame("Version: ".. version .."  Last updated: ".. AddonLastUpdated)
			out_frame("Stores profiles of keybindings, supports easy switching and transferring to different characters.")
		else
			out_frame("Syntax for Binder slash commands:");
			out_frame("  - /binder - Toggles main Binder window");
			out_frame("  - /binder load name - Loads profile 'name', case sensitive");
			out_frame("  - /binder info - Credits, version info");
		end
	end
	--[[ create only when needed
	if LibStub then
		if LibStub:GetLibrary("LibKeyBound-1.0") then
			LibKeyBound = LibStub:GetLibrary("LibKeyBound-1.0")
		else
			out_frame("Binder Missing Dependecy: LibKeyBound-1.0")
		end
	else
		out_frame("Binder Missing Dependecy: LibStub")
	end
	--]]

	--Binder_Frame.MiniButton:Init()		-- MiniButton.lua not loaded yet
end

function Binder_OnEvent(self, event, addonName)
	if  event == "ADDON_LOADED"  and  addonName == AddonName  then
		-- migrate after 6.2.2:  Binder_Settings.Profiles -> BinderProfilesDB
		if  not BinderProfilesDB  then
			BinderProfilesDB=  Binder_Settings  and  Binder_Settings.Profiles
		end
		Binder_Settings = nil
		
		Binder_Profiles_Idx= {}
		for  i,profile  in  ipairs(BinderProfilesDB)  do
			Binder_Profiles_Idx[GetProfileName(profile)]= profile
		end
		
		--Binder_MinimapButton_OnLoad();
		--Minimap_Options_WhenLoaded();
		Binder_Frame.MiniButton:OnAddonLoad()
	end		
end

	
function Binder_Toggle()
	--Selection = false;
	-- if (frame) then
		if (  Binder_Frame:IsVisible()  ) then
			--When the Frame Goes away
			Binder_Frame:Hide();
			--[[
			Binder_Frame_Title:Hide();
			Binder_Description_InputBox:Hide();
			Binder_Name_Input_Frame:Hide();
			Apply_Frame:Hide();
			Description_Frame:Hide();
			Selection_Frame:Hide();
			Loading_Frame:Hide();
			Binder_Options_Frame:Hide();
			Creation_Frame:Hide();
			Binder_Description_Input_Frame:Hide();
			Binder_Divider_Frame1:Hide();
			Binder_Divider_Frame2:Hide();
			Binder_Name_InputBox:SetText("");
			Binder_Description_InputBox:SetText("");
			--]]
		else
			--When the Frame is Shown again
			BindingSetButtons_Update()
			ProfileButtons_Update()
			
			Binder_Frame:Show();
			Binder_Frame_Title:Show();

			Binder_Load_Frame:Show();
			Binder_Profiles_Frame:Show();
			Binder_Description_Frame:Show();
			Binder_LoadButtons_Frame:Show();
			
			Binder_Save_Frame:Show();
			Binder_Name_Input_Frame:Show();
			Binder_Description_Input_Frame:Show();
			Binder_Description_InputBox:Show();
			
			Binder_Options_Frame:Show();
			Binder_Divider_Frame1:Show();
			Binder_Divider_Frame2:Show();

			--[[
			Binder_Name_InputBox:SetText("");
			Binder_Description_InputBox:SetText("");
			BinderEntry1:UnlockHighlight();
			BinderEntry2:UnlockHighlight();
			BinderEntry3:UnlockHighlight();
			BinderEntry4:UnlockHighlight();
			BinderEntry5:UnlockHighlight();
			--]]
		end
	-- end
end




--The Scrolling Frame
function BinderScrollBar_Update()
	local line; 
	local lineplusoffset;
	FauxScrollFrame_Update(BinderScrollBar,#BinderProfilesDB,5,19);
	for  line = 1,5  do 
		lineplusoffset = line + FauxScrollFrame_GetOffset(BinderScrollBar);
		local BinderEntry= _G["BinderEntry"..line]
		if ( lineplusoffset <= #BinderProfilesDB ) then
			local profile= BinderProfilesDB[lineplusoffset]
			local Name = GetProfileName(profile)
			BinderEntry:SetText(Name)
			--if  lineplusoffset == Currently_Selected_Profile_Num
			if  Name == SelectedProfile_Name
			then  BinderEntry:LockHighlight()
			else  BinderEntry:UnlockHighlight()
			end
			BinderEntry:Show()
		else
			BinderEntry:Hide()
		end
	end
end




local function tableEqualsShallow(a, b)
	if  #a ~= #b  then  return false  end
	for  i= 1,#a  do
		if  a[i] ~= b[i]  then  return false  end
	end
	return true
end

function strBeginsWith(str, prefix)
	return prefix == strsub(str, 1, string.len(prefix))
end

function strRemovePrefix(str, prefix)
	local len= string.len(prefix)
	return  prefix == strsub(str, 1, len)  and  strsub(str, len+1)
end

local function subStrSplit(str, sepStr)
	local splits, from= {}, 0
	while  from  do
		local sepIdx= strfind(str, sepStr, from)
		splits[#splits+1]= strsub(str, from, sepIdx and sepIdx-1 or nil)  -- sepIdx == nil will add the part after the last separator
		from= sepIdx  and  sepIdx + strlen(sepStr)
	end
	-- str == ""  will always result in one split: { "" }
	return unpack(splits)
end

local function SetBindingsForKeys(keys, command)
	for  i= 1,#keys  do  SetBinding(keys[i], command)  end
end

local function SetBindingsForCommand(command, ...)
	-- accept keys as  multiple arguments
	local newKeys= {...}
	--[[
	-- or  a list
	if  #newKeys == 1  and  type(newKeys[1]) == 'table'  then  newKeys= newKeys[1]
	-- or a list starting with command
	elseif  #newKeys == 0  and  type(command) == 'table'  then
		newKeys= command
		command= table.remove(newKeys, 1)
	end
	--]]
	
	local  oldKeys= { GetBindingKey(command) }
	if  not tableEqualsShallow(oldKeys, newKeys)  then
		local wasStr= #oldKeys == 0  and  ''  or  '    was->  '.. table.concat(oldKeys, '|')
		out_frame( '  '.. command .. wasStr ..'    changed->  '.. table.concat(newKeys, '|') )
		SetBindingsForKeys(oldKeys, nil)
		SetBindingsForKeys(newKeys, command)
	end
end

local function LoadKeyBindingsSerialized(list, SavedSeparator)
	for  _,bindingStr  in  ipairs(list)  do
		if  type(bindingStr) == 'string'  and  bindingStr:match("^%a")  then
			SetBindingsForCommand( subStrSplit(bindingStr, SavedSeparator) )
		end
	end
end

local function LoadKeyBindingsTwoLevel(categList, SavedSeparator)
	for  _,categ  in  ipairs(categList)  do
		LoadKeyBindingsSerialized(categ, SavedSeparator)
	end
end

--[[
-- "ELEPHANT_TOGGLE || CTRL-E || CTRL-L", -- [3]
local function 	SerializeBindingStrSimple(command, keys)
	return  bindingStr= command .." || ".. table.concat(keys, " || ")
end

-- "ELEPHANT_TOGGLE >> CTRL-E || CTRL-L", -- [2]
local function 	SerializeBindingStrNice(command, keys)
	return  bindingStr= command .." >> ".. table.concat(keys, " || ")
end

-- "ELEPHANT_TOGGLE = {'CTRL-E','CTRL-L',}", -- [2]
local function 	SerializeBindingStrLua(command, keys)
	local bindingStr= command .." = {"
	for i=1,#keys  do  bindingStr= bindingStr .."'".. keys[i] .."',"
	return  bindingStr ..'}'
end

local SerializeBindingStr= SerializeBindingStrLua

--]]


-- GetBinding(i) builtin return format before Warlords: binding= { command, key1, key2, ... keyN }
-- GetBinding(i) builtin since Warlords returns an extra 2nd value:  binding= { command, category, key1, key2, ... keyN }
local GetBinding_Category_Prefix= 'BINDING_HEADER_'		-- confusingly binding categories were called headers b
local GetBinding_Header_Prefix= 'HEADER_'


function 	LoadKeyBindingsOriginal(binds)
	-- added backward-compatibility for Binder 2.5.1 (Warlords expa) and Binder 2.6.1 (Legion expa)
	for  _,keys  in  ipairs(binds)  do
		local cmd = keys.TheAction
		local  oldKeys= { GetBindingKey(cmd) }
		SetBindingsForKeys(oldKeys, nil)
		
		-- GetBinding(i) builtin return format since Warlords?: keys= { command, category, key1, key2, ... keyN }
		-- GetBinding(i) builtin return format before Warlords?: keys= { command, key1, key2, ... keyN }
		local key1= keys.BindingOne  or  keys.Binding1
		if  key1  and  not strBeginsWith(key1, GetBinding_Category_Prefix)  then  SetBinding(key1, cmd)  end
		
		local key2= keys.BindingTwo
		if  key2  then  SetBinding(key2, cmd)  end
		
		local  n= 2
		while  keys['Binding'..n]  do
			SetBinding(keys['Binding'..n], cmd)
			n= n+1
		end
	end
end




local KeySeparator= " || "

local function AddToCategory(list, binding)
	-- category was removed: binding= { command, keys... }
	list[#list+1]= table.concat(binding, KeySeparator)
end

local function 	SaveKeyBindingsSerialized()
	-- Check if GetBinding(1) returns category as 2nd value
	local GetBinding_1_2 = select(2, GetBinding(1))
	local GetBinding_Returns_Category = GetBinding_1_2  and  strBeginsWith( GetBinding_1_2, GetBinding_Category_Prefix )
	--local GetBinding_Returns_Category = ( 60000 <= select(4, GetBuildInfo()) )		-- returns category since Warlords?
	
	local lastCategory = ''
	local list = { { Separator= KeySeparator } }
	
	-- Add hidden bindings
	AddToCategory( list, { 'CAMERAORSELECTORMOVE', GetBindingKey('CAMERAORSELECTORMOVE') } )
	AddToCategory( list, { 'TURNORACTION', GetBindingKey('TURNORACTION') } )

	local num= GetNumBindings()
	for  i= 1,num  do
		local binding= { GetBinding(i) }
		-- GetBinding(i) builtin since Warlords returns an extra 2nd value:  binding= { command, category, key1, key2, ... keyN }
		local category= GetBinding_Returns_Category  and  table.remove(binding, 2)  or  ''
		if  lastCategory ~= category  then
			--local catName= strRemovePrefix(category, GetBinding_Category_Prefix)  or  category
			AddToCategory( list, { '-- '.. category } )
			lastCategory = category
		end
		
		if  #binding == 1  and  strBeginsWith( binding[1], GetBinding_Header_Prefix )  then
			-- Header lines in keybinding ui
			AddToCategory( list, { '-- '.. binding[1] } )
		else
			--local action= table.remove(binding, 1)  or  ''
			--local keys= { GetBindingKey(cmd) }
			-- category was removed: binding= { command, keys... }
			AddToCategory( list, binding )
			--list[#list+1]= SerializeBindingStr(command, keys)
		end
	end
	return list
end



--When you click on a profile
function SelectProfile(profileName)
	SelectedProfile_Name= profileName
	local profile= Binder_Profiles_Idx[SelectedProfile_Name]
	if  profile  then
		local meta = profile[1]  and  profile[1].Name  and  profile[1]  or  profile
		Binder_Name_InputBox:SetText(meta.Name)
		Binder_Description_InputBox:SetText(meta.Description)
		Binder_Description_Frame_Text2:SetText(meta.Description)
	else
		Binder_Description_Frame_Text2:SetText("")
	end
	BinderScrollBar_Update()
	ProfileButtons_Update()
end




function ProfileEntry_OnClick(self)
	local profileName= self:GetText()
	
	-- clicking the selected will deselect it
	if  SelectedProfile_Name == profileName  then  profileName= nil  end
	SelectProfile(profileName)
end

function LoadProfile_OnClick()
	SaveBackup()
	LoadProfile(SelectedProfile_Name)
	BindingSetButtons_Update()
end


function LoadProfile(profileName)
	SelectedProfile_Name= profileName
	local profile= Binder_Profiles_Idx[profileName]
	if  not profile  then
		local msg= "Binding profile '".. profileName .."' not found"
		out_both(msg)
		return
	end
	
	SaveBindings(2)		-- save to character-specific so it can be loaded (with modifications) in case of an error
	--SaveBackup()
	local result, err= xpcall(LoadProfileProtected, geterrorhandler())
	
	if  not result  then
		LoadBindings(2)		-- restore previously saved
		local msg= "Binder error: ".. tostring(err)
		out_both(msg)
		return
	end
	
	SaveBindings(2)		-- set to character-specific
end

function LoadProfileProtected()
	local profileName= SelectedProfile_Name
	local profile= Binder_Profiles_Idx[profileName]
	out_both("Loading binding profile '".. profileName .."', changes:")
	
	local bindings = profile[2]
	if  bindings  and  bindings[1]  and  bindings[1].Separator  then
		-- using serialized format: bindings listed in declaration order, Bindings[bindingIndex]= "name || binding1 || binding2[ || binding3...]"
		LoadKeyBindingsSerialized(bindings, bindings[1].Separator)
	elseif  profile.Bindings  and  profile.Bindings[1]  and  profile.Bindings[1].Separator  then
		-- using serialized format: bindings listed in categories in order, Bindings[categoryIndex][bindingIndex]= "name || binding1 || binding2[ || binding3...]"
		LoadKeyBindingsTwoLevel(profile.Bindings, profile.Bindings[1].Separator)
	elseif  profile.The_Binds  then
		-- using original format: The_Binds[category][name]= { binding1, binding2, ... }
		LoadKeyBindingsOriginal(profile.The_Binds)
	else
		out_both("Binding profile '".. profileName .."' has incompatible bindings format")
		return
	end
	
	local msg= "Loaded binding profile '".. profileName .."'"
	out_frame(msg)
end




function SaveProfile_OnClick()
	local profileName= Binder_Name_InputBox:GetText()
	if  profileName == ''  then
		out('Enter profile name to save')
		return
	end
	if  Binder_Profiles_Idx[profileName]  then
		-- profile exists with this name, show update confirm popup
		UpdateConfirm_No:Show()
		UpdateConfirm_New:Hide()
		Update_Confirm_Frame:Show()
	elseif  SelectedProfile_Name  then
		-- profile is selected, offer to update (rename) or create a new
		-- show NEW button instead of Cancel
		UpdateConfirm_No:Hide()
		UpdateConfirm_New:Show()
		Update_Confirm_Frame:Show()
	else
		SaveProfile()
	end
end
	
function SaveProfile()
	local profileName= Binder_Name_InputBox:GetText()
	local profile= Binder_Profiles_Idx[profileName]  or  Binder_Profiles_Idx[SelectedProfile_Name]
	local action= profile  and  'updated'  or  'created'
	
	if  not profile  then
		-- new profile: add to end of BinderProfilesDB
		profile= {}
		BinderProfilesDB[#BinderProfilesDB+1]= profile
	else
		Binder_Profiles_Idx[GetProfileName(profile)]= nil
		-- delete data with old format
		profile.Name = nil
		profile.Description = nil
		profile.Bindings = nil
	end
	Binder_Profiles_Idx[profileName]= profile
	
	local clientVersion, build, buildDate, interfaceVersion, memUpdateLocked = GetBuildInfo()
	profile[1] = {
		Name = profileName,
		Date = date('%Y-%m-%d', time()),
		Description = Binder_Description_InputBox:GetText(),
		ClientVersion = clientVersion,
		--ClientVersion = clientVersion .. "-" .. interfaceVersion,
	}
	profile[2] = SaveKeyBindingsSerialized()
	
	SelectProfile(profileName)
	
	local msg= "Binding profile '".. profileName .."' ".. action
	out_both(msg)
end



local function  tremoveByVal(tab, item)
	for  i,v  in  ipairs(tab)  do
		if  v == item  then  table.remove(tab, i)  return v  end
	end
	return nil
end

function DeleteProfile()
	if  not SelectedProfile_Name  then  return  end
	local profile= Binder_Profiles_Idx[SelectedProfile_Name]
	tremoveByVal(BinderProfilesDB, profile)
	Binder_Profiles_Idx[SelectedProfile_Name]= nil
	
	local msg= "Binding profile '".. SelectedProfile_Name .."' deleted"
	out_both(msg)
	
	SelectProfile(nil)	
end


function LoadProfile_Button_Update()
	if  SelectedProfile_Name
  then LoadProfile_Button:Enable()
	else LoadProfile_Button:Disable()
	end
end

function SaveProfile_Button_Update()	
	if  Binder_Name_InputBox:GetText() == ''
  then SaveProfile_Button:Disable()
	else SaveProfile_Button:Enable()
	end
end

function DeleteProfile_Button_Update()
	if  SelectedProfile_Name
  then DeleteProfile_Button:Enable()
	else DeleteProfile_Button:Disable()
	end
end


function ProfileButtons_Update()
	LoadProfile_Button_Update()
	--SaveProfile_Button_Update()	
	DeleteProfile_Button_Update()
end




local FirstBackup= nil

function SaveBackup()
	if  not FirstBackup  then
		-- backup current keybindings
		FirstBackup= SaveKeyBindingsSerialized()
		out_frame('Previous keybindings can be restored')
	end
end

function LoadBackup()
	--set= set  or  GetCurrentBindingSet()
	if  FirstBackup  then
		out_both('Restoring previous keybindings')
		LoadKeyBindingsSerialized(FirstBackup)
		SaveBindings(2)		-- set to character-specific
		FirstBackup= nil
		out_frame('Previous keybindings restored')
	end
end


function RestoreBackup_OnClick(arg1)
	LoadBackup()
	BindingSetButtons_Update()
end

function ResetToDefaults_OnClick(arg1)
	SaveBackup()
	LoadBindings(0)		-- load defaults
	SaveBindings(2)
	BindingSetButtons_Update()
	local msg= 'Current character-specific keybindings are reset to factory defaults'
	out_both(msg)
end

function ResetToAccount_OnClick(arg1)
	SaveBackup()
	LoadBindings(1)			-- load account-wide
	SaveBindings(1)			-- set to account-wide
	local msg= 'Loading account-wide keybindings'
	out(msg)
	out_frame(msg .. '\nCurrent character-specific keybindings are removed')
	BindingSetButtons_Update()
end

function SaveToAccount_OnClick(arg1)
	--LoadBindings(1);SaveBackup();LoadBindings(2)			-- backup account-wide keybindings
	SaveBindings(1)		-- set to account-wide
	BindingSetButtons_Update()
	local msg= 'Current keybindings are now set account-wide'
	out(msg)
	out_frame(msg ..'\nOther characters keep their character-specific keybindings, if they have.\nTo use the account-wide settings, Reset to account-wide individually on each character, after logging on with them.')
end



function ToggleBindingSet_Name(set)
	return  set == 1  and  'account-wide'  or  'character'
end

local ToggleBindingSet_Other= 1

function ToggleBindingSet_OnClick(arg1)
	local set= GetCurrentBindingSet()
	local msg
	--SaveBindings(set)		-- don't save: SaveBindings(1) deletes character-specific bindings
	if  set == 1  then
		SaveBindings(2)
		msg= 'Saving '.. ToggleBindingSet_Name(2) ..' keybindings'
	else
		LoadBindings(ToggleBindingSet_Other)		-- load the other set
		msg= 'Loading '.. ToggleBindingSet_Name(ToggleBindingSet_Other) ..' keybindings'
		ToggleBindingSet_Other= ToggleBindingSet_Other == 1  and  2  or  1
	end
	
	BindingSetButtons_Update()
	out_both(msg)
end


function BindingSetButtons_Update()
	local set= GetCurrentBindingSet()
	--[[
	local newSet= set == 1  and  2  or  1
	LoadProfile_Button:SetText('Load profile '.. ToggleBindingSet_Name(set))
	]]--
	if  set == 1  then
		-- using account-wide keybindings
		ToggleBindingSet_Other= 1
		ToggleBindingSet_Button:SetText('Copy to character')
		SaveToAccount_Button:Disable()
		ResetToAccount_Button:Disable()
	else
		-- using character-specific keybindings
		ToggleBindingSet_Button:SetText('Load from '.. ToggleBindingSet_Name(ToggleBindingSet_Other))
		SaveToAccount_Button:Enable()
		ResetToAccount_Button:Enable()
	end
	if  FirstBackup
  then  RestoreBackup_Button:Enable()
	else  RestoreBackup_Button:Disable()
	end
end


function Binder_TooltipOnButton(button, tooltipText)
	if  not tooltipText  then  GameTooltip:Hide() ; return  end
	if  button.dragging  then  return  end
	
	GameTooltip:SetOwner(button or UIParent, "ANCHOR_RIGHT")
	GameTooltip:SetText(tooltipText)
end




function Binder_KeyBound_OnClick()
	if  LibKeyBound  and  LibKeyBound:IsShown()  then
		LibKeyBound:Deactivate()
		BindingSetButtons_Update()		-- todo: hook OnHide script
	else
		if  KeyBindingFrame  and  KeyBindingFrame:IsShown()  then  KeyBindingFrame:Hide()  end
		
		LibKeyBound= LibKeyBound  or  LibStub:GetLibrary("LibKeyBound-1.0")
		if LibKeyBound then  LibKeyBound:Activate()
		else
			local msg = "Optionally you can install Dominos/Bartender4/LibKeyBound to configure keybindings directly on the actionbar buttons"
			out_frame(msg)
		end
	end
end


local KeyBindingFrame_OnHide_Orig
local function KeyBindingFrame_OnHide()
	-- KeyBindingFrame_OnHide_Orig not called now, but next time when opened from the game menu
	KeyBindingFrame:SetScript('OnHide', KeyBindingFrame_OnHide_Orig)
	HideUIPanel(GameMenuFrame)
	BindingSetButtons_Update()
	--Binder_Frame:Show()
end

function Binder_KeyBindingFrame_OnClick()
	-- Open/close blizzard keybindings frame from game menu
	if  KeyBindingFrame  and  KeyBindingFrame:IsShown()  then
		KeyBindingFrame:Hide()
	else
		if  LibKeyBound  and  LibKeyBound:IsShown()  then  LibKeyBound:Deactivate()  end
		
		if  not KeyBindingFrame  then
			UIParentLoadAddOn("Blizzard_BindingUI")
		end
		
		KeyBindingFrame_OnHide_Orig= KeyBindingFrame:GetScript('OnHide')
		-- Override OnHide to NOT open GameMenuFrame
		KeyBindingFrame:SetScript('OnHide', KeyBindingFrame_OnHide)
		KeyBindingFrame:Show()
	end
end




----------------------------------------------------------------------
--[[ original

function SaveCurrentBindsToProfile(profile_number)
	for i = 1, GetNumBindings() do		
		Binder_Settings.Profiles[profile_number].The_Binds[i] = {["TheAction"] = select(1, GetBinding(i))}
		-- At some point blizzard modified how they display Keybinds to players to modify them. They added KeyBindingHeaders so that the keybind list would be more manageable. They apparently modified how GetBinding() works, it now returns TheAction(1) TheHeader(2) and all the keybinds(3 to n). This broke the system I was using which required TheAction(1), Bind1(2), Bind2(3). This caused errors for many players who seemingly had their keybinds just disappear. I know intelligently loop over all keybinds and store them, instead of just the first 2.
		-- We start from (j=2) here so we skip the action for the binds. We could start from (j=3) and skip the "KeyBindingHeader", but some keybinds don't have a header, and starting at 3 would skip the first bind. So we will just let it silently fail when we try to later set a keybind to a keybind header.
		for j = 2, select("#", GetBinding(i)) do
			Binder_Settings.Profiles[profile_number].The_Binds[i]["Binding"..j-1] = select(j, GetBinding(i))
		end
	end
end

--]]



--[[
-- Minimap coding

function Binder_MinimapButton_OnLoad()
	if  Binder_Settings.Minimap  then
		-- account-wide savedVar
		BinderMinimapSettings= Binder_Settings.Minimap
	elseif  _G.BinderMinimapSettings  then 
		-- character-specific savedVar
		BinderMinimapSettings= _G.BinderMinimapSettings
		Binder_Settings.Minimap= BinderMinimapSettings
		_G.BinderMinimapSettings= nil
	else
		Binder_Settings.Minimap= BinderMinimapSettings
  end
	
	if not BinderMinimapSettings.degree then
		out_frame("degree is broken :(")
		BinderMinimapSettings.degree = -12
	end

	if (BinderMinimapSettings.MinimapRadioOption == 1) then
		Binder_MinimapButton:SetPoint("CENTER", "UIParent", "CENTER",BinderMinimapSettings.xposition,BinderMinimapSettings.yposition)
	elseif (BinderMinimapSettings.MinimapRadioOption == 2) then
		Binder_MinimapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52-(80*cos(BinderMinimapSettings.degree)), (80*sin(BinderMinimapSettings.degree))-52 )
	end
end

function Binder_MinimapButton_Reposition()
	if (BinderMinimapSettings.MinimapRadioOption == 1) then
		local xlim = (GetScreenWidth()/2)
		local ylim = (GetScreenHeight()/2)
		
		if ( BinderMinimapSettings.xposition > xlim) then
			BinderMinimapSettings.xposition = xlim
			end
		if ( BinderMinimapSettings.xposition < (-1) * xlim) then
			BinderMinimapSettings.xposition = (-1) * xlim
			end
		if ( BinderMinimapSettings.yposition > ylim) then
			BinderMinimapSettings.yposition = ylim
			end
		if ( BinderMinimapSettings.yposition < (-1) * ylim) then
			BinderMinimapSettings.yposition = (-1) * ylim
			end
		
		Binder_MinimapButton:SetPoint("CENTER", "UIParent", "CENTER", BinderMinimapSettings.xposition, BinderMinimapSettings.yposition)
	else
		Binder_MinimapButton:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52-(80*cos(BinderMinimapSettings.degree)),(80*sin(BinderMinimapSettings.degree))-52)
	end
end

function Binder_MinimapButton_DraggingFrame_OnUpdate()
	if (BinderMinimapSettings.MinimapRadioOption == 1) then
		local xcursor, ycursor = GetCursorPosition()

		local xpos = (xcursor/UIParent:GetEffectiveScale()) - (GetScreenWidth()/2);
		local ypos = (ycursor/UIParent:GetEffectiveScale()) - (GetScreenHeight()/2);
		
		BinderMinimapSettings.xposition = xpos
		BinderMinimapSettings.yposition = ypos
		Binder_MinimapButton_Reposition() 
	else
		local xpos,ypos = GetCursorPosition()
		local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

		xpos = xmin-xpos/UIParent:GetScale()+70
		ypos = ypos/UIParent:GetScale()-ymin-70

		BinderMinimapSettings.degree = math.deg(math.atan2(ypos,xpos))
		Binder_MinimapButton_Reposition() 
	end	
end

function Binder_MinimapButton_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_LEFT")
	Binder_MinimapButton_Details(GameTooltip)
end

function Binder_MinimapButton_Details(tt, ldb)
	tt:SetText("Binder|n|nLeft Click: Open Frame|nRight Click: Drag")
end

function Minimap_Reset(arg1)
	BinderMinimapSettings.xposition = 0
	BinderMinimapSettings.yposition = 0
	BinderMinimapSettings.degree = 30
	Binder_MinimapButton_Reposition()
end

function Minimap_Reset_Details(tt, ldb)
	tt:SetText("Will reset the position of the|nminimap button to center screen")
end

function Minimap_Reset_OnEnter(self)
	if (self.dragging) then
		return
	end
	GameTooltip:SetOwner(self or UIParent, "ANCHOR_RIGHT")
	Minimap_Reset_Details(GameTooltip)
end


function Minimap_Options_WhenLoaded()
	if (BinderMinimapSettings.ShowMinimapButton == true) then
		Binder_Minimap_CheckButton1:SetChecked(true)
	else
		Binder_Minimap_CheckButton1:SetChecked(false)
	end
	if (BinderMinimapSettings.MinimapRadioOption == 1) then
		Binder_Options_Frame_RadioButton1:SetChecked(true)
	else
		Binder_Options_Frame_RadioButton2:SetChecked(true)
	end

	Minimap_Options_OnUpdate()
end

function Minimap_Options_OnUpdate()
	-- Show Minimap Button
	if (Binder_Minimap_CheckButton1:GetChecked() == true) then
		BinderMinimapSettings.ShowMinimapButton = true
		Binder_MinimapButton:Show()
		Binder_Options_Frame_RadioButton1:Enable()
		Binder_Options_Frame_RadioButton1:SetAlpha(1)
		Binder_Options_Frame_RadioButton2:Enable()
		Binder_Options_Frame_RadioButton2:SetAlpha(1)
	else
	-- Hide Minimap Button
		BinderMinimapSettings.ShowMinimapButton = false
		Binder_MinimapButton:Hide()
		Binder_Options_Frame_RadioButton1:Disable()
		Binder_Options_Frame_RadioButton1:SetAlpha(.4)
		Binder_Options_Frame_RadioButton2:Disable()
		Binder_Options_Frame_RadioButton2:SetAlpha(.4)
	end

	-- 
	if (Binder_Options_Frame_RadioButton1:GetChecked() == true) then
		BinderMinimapSettings.MinimapRadioOption = 1
	else
		BinderMinimapSettings.MinimapRadioOption = 2
	end
end

--]]


