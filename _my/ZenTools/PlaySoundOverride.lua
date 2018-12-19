--[[
/dump SoundHistory.last
/dump SoundHistory
/run PlaySound= PlaySoundOverride
--]]
--[[
/run PlaySoundReplace.
/run PlaySoundReplace.igQuestLogOpen  =nil
/run PlaySoundReplace.igQuestLogClose =nil
--]]

local ADDON_NAME, AddonPrivate = ...


local function  tremovebyval(tab, item)
	for  i,v  in  ipairs(tab)  do
		if  v == item  then  table.remove(tab, i)  return v  end
	end
	return nil
end


SoundHistory= {
	Last= nil,
	MaxCount= 10,
}


local function  PlaySoundHook(sound)
	local lastSound= SoundHistory.Last
	if  sound ~= lastSound  then
		--DEFAULT_CHAT_FRAME:AddMessage('PlaySoundHook("' .. tostring(sound) .. "')")
	  SoundHistory.Last= sound
	  local msg=  sound
		--[[
	  -- The message is  the name of the sound  or  ... silenced  or  the replacement.
	  local msg=  not replace  and  sound
				or  replace == ''  and  colors.red .. tostring(sound) .. colors.restore .. ' silenced'
				or  sound .. ' -> ' .. replace
		--]]
		if   tremovebyval(SoundHistory, msg)  then
			-- Removed same sound from a previous position, table size <= MaxCount
		elseif  #SoundHistory > SoundHistory.MaxCount  then
			-- Remove oldest entry at the end of the list  if history limit is reached.
			table.remove(SoundHistory)
		end

	  table.insert(SoundHistory, 1, msg)
  end
end


-- Check for original PlaySound being called without calling the override.
-- TODO: Does this cache the current PlaySound?  Is it different to hook _after_ replacing PlaySound?
hooksecurefunc('PlaySound', PlaySoundHook)




--[[ Taints...

PlaySoundReplace= {
	igMainMenuOpen	='',
	igMainMenuQuit	='',
	--igQuestLogOpen  ='',
	--igQuestLogClose ='',
}

--  source: ViragDevTool.lua/.../default_settings.colors
local colors = {
		white = "|cFFFFFFFF",
		gray = "|cFFBEB9B5",
		lightblue = "|cFF96C0CE",
		lightgreen = "|cFF98FB98",
		red = "|cFFFF0000",
		green = "|cFF00FF00",
		darkred = "|cFFC25B56",
		parent = "|cFFBEB9B5",
		error = "|cFFFF0000",
		ok = "|cFF00FF00",
		table = { 0.41, 0.80, 0.94, 1 },
		string = { 0.67, 0.83, 0.45, 1 },
		number = { 1, 0.96, 0.41, 1 },
		default = { 1, 1, 1, 1 },
		restore = "|r",
}


local PlaySound = _G.PlaySound  -- infinite recursion safeguard
PlaySoundOrig   = _G.PlaySound

function  PlaySoundOverride(sound)
  local replace= PlaySoundReplace[sound]
	if  replace  and replace == ''  then
		--DEFAULT_CHAT_FRAME:AddMessage('PlaySoundOverride:  '.. colors.red .. tostring(sound) .. colors.restore .. ' silenced')
	  return    -- without calling original function
	end
	--DEFAULT_CHAT_FRAME:AddMessage('PlaySoundOverride:  '.. colors.green .. tostring(sound))

	PlaySoundOrig(replace or sound)
end

--  Override original PlaySound function with modified one.
--_G.PlaySound = PlaySoundOverride

--]]


