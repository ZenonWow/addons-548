--[[
NoLoginMusic makes your login screen silent. It will save your settings if you reenable sound and/or music on the login screen.
How it works: it disables the music/sound when you logout and enables it when you login. Blizzard has no separate settings for it.

You can change your login screen settings ingame too. First load them by copying the following line as a chat message:
/run NoLoginMusic:EditLoginProfile()

Now alter your sound settings, then save it by copying the following line as a chat message:
/run NoLoginMusic:SaveAsLoginProfile()

To disable silencing the login screen (note: just disabling the addon will set the silent settings for the login screen and also ingame):
/run NoLoginMusic:Disable()

To reenable:
/run NoLoginMusic:Enable()
--]]


local ADDON_NAME, private = ...
local _G = _G

-- SavedVariable
local NoLoginMusicDB

-- Profile names
local onLoginScreen = 'onLoginScreen'
local inWorld = 'inWorld'

local defaultSavedCVars = {
	Sound_EnableAllSound = false,
	Sound_EnableSoundWhenGameIsInBG = false,
	
	Sound_EnableMusic = true,				-- in Sound_ToggleMusic()
	Sound_EnableSFX = true,					-- in Sound_ToggleSound()
	Sound_EnableAmbience = true,		-- in Sound_ToggleSound()
	
	Sound_EnableErrorSpeech = false,
	Sound_EnableDSPEffects = false,
	Sound_EnablePetSounds = false,
	
	Sound_MasterVolume = false,
	Sound_MusicVolume = false,
	Sound_SFXVolume = false,
	Sound_AmbienceVolume = false,
}

local defaultSettings = {
	onLoginScreen = {
		Sound_EnableMusic = 0,
		Sound_EnableSFX = 0,
		Sound_EnableAmbience = 0,
	}
}



-- Global reference:  NoLoginMusic

local NoLoginMusic = CreateFrame('Frame', 'NoLoginMusic')

function NoLoginMusic:Disable()
	NoLoginMusicDB.disabled = true
	-- NoLoginMusicDB._loadedProfile = nil
end

function NoLoginMusic:Enable()
	NoLoginMusicDB.disabled = nil
	--NoLoginMusicDB._loadedProfile = inWorld
end

function NoLoginMusic:EditLoginProfile()
	self:LoadProfile(onLoginScreen)
end

function NoLoginMusic:SaveAsLoginProfile()
	self:SaveProfile(onLoginScreen)
	self:LoadProfile(inWorld)
end




-- Event handlers

function NoLoginMusic:OnEvent(event, ...)
	if  self[event]  then  self[event](self, event, ...)  end
end

function NoLoginMusic:ADDON_LOADED(event, addonName)
	if  addonName ~= ADDON_NAME  then  return  end
	
	NoLoginMusicDB =  _G.NoLoginMusicDB  or  defaultSettings
	_G.NoLoginMusicDB = NoLoginMusicDB
	if  NoLoginMusicDB.disabled  then  return  end
	
	-- Check if onLoginScreen profile was loaded before logout.
	if  NoLoginMusicDB._loadedProfile ~= onLoginScreen  then
		print(_G.YELLOW_FONT_COLOR_CODE.."NoLoginMusic:|r failed to load login screen sound settings before last exit. This is expected only if the client crashed.")
	elseif  not IsLoggedIn()  then
		-- IsLoggedIn() check: don't save if delayed-loading addon (tho it makes not much sense to delay-load this).
		self:SaveProfile(onLoginScreen)
  end
	
	-- Load sound settings for play-time.
	self:LoadProfile(inWorld)
end

function NoLoginMusic:PLAYER_LOGOUT(event)
	if  NoLoginMusicDB.disabled  then  return  end
	self:SaveProfile(inWorld)
	self:LoadProfile(onLoginScreen)
end


NoLoginMusic:RegisterEvent('ADDON_LOADED')
NoLoginMusic:RegisterEvent('PLAYER_LOGOUT')
NoLoginMusic:SetScript('OnEvent', NoLoginMusic.OnEvent)
NoLoginMusic:Hide()




-- Profile saving loading
--[[ unused
function NoLoginMusic:SetProfile(profileName, saveProfile)
	if  saveProfile  and  NoLoginMusicDB._loadedProfile ~= profileName  then  self:SaveProfile(saveProfile)  end
	self:LoadProfile(profileName)
end
--]]

function NoLoginMusic:SaveProfile(profileName)
	profileName =  profileName  or  NoLoginMusicDB._loadedProfile
	if  not profileName  then  return false  end
	
	local savedCVars =  NoLoginMusicDB[profileName]  or  defaultSavedCVars
	local profile =  NoLoginMusicDB[profileName]  or  {}
	NoLoginMusicDB[profileName] = profile
	for  cvar, saved  in pairs(savedCVars)  do
		if  saved ~= false  then  profile[cvar] = GetCVar(cvar)  end
	end
	return true
end


function NoLoginMusic:LoadProfile(profileName)
	local profile = NoLoginMusicDB  and  NoLoginMusicDB[profileName]
	if  not profile  then  return false  end
	
	for  cvar, value  in pairs(profile)  do
		SetCVar(cvar, value)
	end
	
	NoLoginMusicDB._loadedProfile = profileName
	return true
end



