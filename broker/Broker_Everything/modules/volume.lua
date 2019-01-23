
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I
local _G = _G


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Volume" -- L["Volume"]
local tt = nil
local ttName = name.."TT"
local ttColumns = 2
local icon = "Interface\\AddOns\\"..addon.."\\media\\volume_"
local VIDEO_VOLUME_TITLE = L["Video Volume"];
local getSoundHardware,setSoundHardware
local volume = {}
local vol = {
	{inset=0,locale="MASTER_VOLUME",			toggle="Sound_EnableAllSound",								percent="Sound_MasterVolume"},
	{inset=1,locale="ENABLE_SOUNDFX",			toggle="Sound_EnableSFX",					depend={1},		percent="Sound_SFXVolume"},
	{inset=2,locale="ENABLE_ERROR_SPEECH",		toggle="Sound_EnableErrorSpeech",			depend={1,2}	},
	{inset=2,locale="ENABLE_EMOTE_SOUNDS",		toggle="Sound_EnableEmoteSounds",			depend={1,2}	},
	{inset=2,locale="ENABLE_PET_SOUNDS",		toggle="Sound_EnablePetSounds",				depend={1,2}	},
	{inset=1,locale="MUSIC_VOLUME",				toggle="Sound_EnableMusic",					depend={1},		percent="Sound_MusicVolume"},
	{inset=2,locale="ENABLE_MUSIC_LOOPING",		toggle="Sound_ZoneMusicNoDelay",			depend={1,6}	},
	{inset=2,locale="ENABLE_PET_BATTLE_MUSIC",	toggle="Sound_EnablePetBattleMusic",		depend={1,6}	},
	{inset=1,locale="ENABLE_AMBIENCE",			toggle="Sound_EnableAmbience",				depend={1},		percent="Sound_AmbienceVolume"},
	{inset=1,locale="DIALOG_VOLUME",			toggle="no-toggle",							depend={1},		percent="Sound_DialogVolume", hide=(select(4,GetBuildInfo())<60000)},
	{inset=1,locale="ENABLE_BGSOUND",			toggle="Sound_EnableSoundWhenGameIsInBG",	depend={1}		},
	{inset=1,locale="ENABLE_SOUND_AT_CHARACTER",toggle="Sound_ListenerAtCharacter",			depend={1}		},
	{inset=1,locale="ENABLE_REVERB",			toggle="Sound_EnableReverb",				depend={1}		},
	{inset=1,locale="ENABLE_SOFTWARE_HRTF",		toggle="Sound_EnableSoftwareHRTF",			depend={1}		},
	{inset=1,locale="ENABLE_DSP_EFFECTS",		toggle="Sound_EnableDSPEffects",			depend={1}		},
	--{inset=0,locale="VIDEO_VOLUME_TITLE",		toggle=false,								special="video"},
	{inset=0,locale="HARDWARE",					toggle=false,								special="hardware"},
}


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name..'_0']    = {iconfile=icon.."0"}
I[name..'_33']   = {iconfile=icon.."33"}
I[name..'_66']   = {iconfile=icon.."66"}
I[name..'_100']  = {iconfile=icon.."100"}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Change Volumes and toogle some audio options."],
	icon_suffix = "_100",
	events = {
		"ADDON_LOADED"
	},
	updateinterval = 5,
	config_defaults = {
		useWheel = false,
		steps = 10,
		listHardware = true
	},
	config_allowed = nil,
	config = {
		height = 62,
		elements = {
			{
				type = "check",
				name = "useWheel",
				label = L["Use MouseWheel"],
				desc = L["Use the MouseWheel to change the volume"]
			},
			{
				type  = "check",
				name  = "listHardware",
				label = L["List of hardware"],
				desc  = L["Display in tooltip a list of your sound output hardware."]
			},
			{
				type = "slider",
				name = "steps",
				label = L["Steps"],
				desc = L["Change the stepping of volume changes."],
				minText = "1",
				maxText = "100",
				minValue = 1,
				maxValue = 100,
				default = 10
			}
		}
	}
}

--------------------------
-- some local functions --
--------------------------
local function updateBrokerButton()
	local obj = module.obj
	volume.master = tonumber(GetCVar("Sound_MasterVolume"))
	local suffix = "100"
	if volume.master < .1 then
		suffix = "0"
	elseif volume.master < .3 then
		suffix = "33"
	elseif volume.master < .6 then
		suffix = "66"
	end
	local icon = I(name.."_"..(suffix or "100"))
	obj.iconCoords = icon.coords or {0,1,0,1}
	obj.icon = icon.iconfile
	obj.text = ceil(volume.master*100).."%"
	module.ontooltip(tt)
end

function module.ontooltip(tt)
	if  not tt  or  not tt.key  or  tt.key ~= ttName  then  return  end -- don't override other LibQTip tooltips...
	local l,c
	tt:Clear()
	tt:AddHeader(C("dkyellow",L[name]))
	tt:AddSeparator()

	local function percent(self,cvar,now,direction)
		if (direction==-1 and now==0) or (direction==1 and now==1) then return end
		local new = now + ((direction * Broker_EverythingDB[name].steps) / 100)
		new = (new>1 and 1) or (new<0 and 0) or new
		ns.SetCVar(cvar,new,cvar)
		module.ontooltip(tt)
		updateBrokerButton()
	end

	for i,v in ipairs(vol) do
		local color,disabled

		if (v.hide) then
			-- do nothing
		elseif type(v.toggle)=="string" then
			l,c = tt:AddLine()
			v.now = tonumber(GetCVar(v.toggle)) vol[i].now=v.now
			v.inv = v.now==1 and 0 or 1
			if (v.toggle~="no-toggle") then

				if v.depend~=nil and ( (v.depend[1]~=nil and vol[v.depend[1]].now==0) or (v.depend[2]~=nil and vol[v.depend[2]].now==0) ) then
					color = v.now==1 and "gray" or "dkgray"
					disabled = color
				end

				if color==nil then
					color = v.now==1 and "green" or "red"
					disabled = v.now==1 and "white" or "gray"
				end

				tt:SetLineScript(l,"OnMouseUp",function(self, button) ns.SetCVar(v.toggle,tostring(v.inv),v.toggle) module.ontooltip(tt) end);
			else
				if v.depend~=nil and ( (v.depend[1]~=nil and vol[v.depend[1]].now==0) or (v.depend[2]~=nil and vol[v.depend[2]].now==0) ) then
					color = "gray";
					disabled = color;
				else
					color = "dkyellow"
					disabled = "white";
				end
				tt:SetLineScript(l,"OnMouseUp",function(self, button) module.ontooltip(tt) end);
			end

			tt:SetCell(l,1,strrep(" ",3 * v.inset)..C(color,_G[v.locale]));

			if v.percent~=nil then
				v.pnow = tonumber(GetCVar(v.percent))

				tt.lines[l]:EnableMouseWheel(1)
				tt.lines[l]:SetScript("OnMouseWheel",function(self,direction)
					percent(self,v.percent,v.pnow,direction)
				end)

				tt:SetCell(l,ttColumns,C(disabled,ceil(v.pnow*100).."%"))
				tt:SetCellScript(l,ttColumns,"OnMouseUp",function(self,button) end)
				tt.lines[l].cells[ttColumns]:SetScript("OnMouseUp",function(self,button)
					local direction = button=="RightButton" and -1 or 1
					percent(self,v.percent,v.pnow,direction)
				end)
			else
				tt:SetCell(l,ttColumns,"           ")
			end
		elseif (v.special=="hardware") and (Broker_EverythingDB[name].listHardware) then
			tt:AddSeparator(3,0,0,0,0)
			tt:AddHeader(C("dkyellow",_G[v.locale])..(InCombatLockdown() and C("orange"," (disabled in combat)") or ""))
			tt:AddSeparator()

			local lst,num,sel = getSoundHardware()

			for I,V in ipairs(lst) do
				local color = I==sel and "green" or "ltgray"

				local m = 30
				if strlen(V)>m then
					V = strsub(V,0,m-3).."..."
				end

				l,c = tt:AddLine(strrep(" ",3 * (v.inset+1))..C(color,V).." ")

				if not InCombatLockdown() then
					tt:SetLineScript(l,"OnMouseUp",function(self,button)
						if InCombatLockdown() then
							ns.print("("..L[name]..")",L["Sorry, In combat lockdown."])
						else
							setSoundHardware(I)
							module.ontooltip(tt)
							AudioOptionsFrame_AudioRestart()
						end
					end)
				end
			end
		elseif (v.special=="video") then
			tt:AddSeparator(3,0,0,0,0);
			tt:AddHeader(C("dkyellow",VIDEO_VOLUME_TITLE));
			tt:AddSeparator();


			-- master volumes
			tt:AddLine("   ".._G["MASTER_VOLUME"], "0%");

			--
			--tt:AddLine("x", "0%");

		end
	end

	if Broker_EverythingDB.showHints then
		tt:AddSeparator(5,0,0,0,0)
		tt:AddLine(C("ltblue",L["Click"]).." || "..C("green",L["On/Off"]))
		tt:AddLine(C("ltblue",L["Mousewheel"]).." || "..C("green",L["Louder"].."/"..L["Quieter"]))
	end

end



do
	local cvar = "Sound_OutputDriverIndex"
	local hardware = {
		selected = tonumber(GetCVar(cvar))+1,
		list = {}
	}
	local hardware_selected = nil

	getSoundHardware = function()
		if #hardware.list==0 then
			local num = Sound_GameSystem_GetNumOutputDrivers()
			for index=1, num do
				hardware.list[index] = Sound_GameSystem_GetOutputDriverNameByIndex(index-1)
			end
		end
		return hardware.list, hardware.num, hardware.selected
	end

	setSoundHardware = function(value)
		hardware.selected = value
		SetCVar(cvar,tostring(value-1) or 0)
	end
end


------------------------------------
-- module (BE internal) functions --
------------------------------------
module.initbroker = updateBrokerButton

module.onevent = updateBrokerButton

module.onmousewheel = function(self,direction)
	if not Broker_EverythingDB[name].useWheel then return end
	if (direction==-1 and volume.master == 0) or (direction==1 and volume.master == 1) then return end

	volume.master = volume.master + (direction * Broker_EverythingDB[name].steps / 100)
	if volume.master > 1 then
		volume.master = 1
	elseif volume.master < 0 then
		volume.master = 0
	end
	local cvar = "Sound_MasterVolume"
	ns.SetCVar(cvar,volume.master,cvar)
	--BlizzardOptionsPanel_SetCVarSafe("Sound_MasterVolume",volume.master)
	updateBrokerButton()
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
module.onenter = function(self)
	ns.RegisterMouseWheel(self, module.onmousewheel)
	if (ns.tooltipChkOnShowModifier(false)) then return; end

	tt = ns.LQT:Acquire(ttName, 2, "LEFT", "RIGHT")
	module.ontooltip(tt)
	ns.createTooltip(self,tt)
end

module.onleave = function(self)
	ns.hideTooltip(tt,ttName,false,true)
end

module.onclick = function(self,button)
	if button == "LeftButton" then
		if volume.master == 1 then return end
		volume.master = volume.master + (Broker_EverythingDB[name].steps / 100)
		if volume.master > 1 then volume.master = 1 elseif volume.master < 0 then volume.master = 0 end
		BlizzardOptionsPanel_SetCVarSafe("Sound_MasterVolume",volume.master)
		updateBrokerButton()
	elseif button == "RightButton" then
		if volume.master == 0 then return end
		volume.master = volume.master - (Broker_EverythingDB[name].steps / 100)
		if volume.master > 1 then volume.master = 1 elseif volume.master < 0 then volume.master = 0 end
		BlizzardOptionsPanel_SetCVarSafe("Sound_MasterVolume",volume.master)
		updateBrokerButton()
	end
end

--[[

do
	local stored = {};
	MovieFrame:HookScript("OnShow", function(self)
		stored.mastervolume = GetCVar("Sound_MasterVolume");
		stored.masterenabled = GetCVar("Sound_EnableAllSound");
		SetCVar("Sound_MasterVolume",Broker_EverythingDB[name].override_MasterVolume);
		SetCVar("Sound_EnableAllSound",Broker_EverythingDB[name].override_MasterEnabled);
	end);

	MovieFrame:HookScript("OnHide", function(self)
		SetCVar("Sound_MasterVolume",stored.mastervolume);
		SetCVar("Sound_EnableAllSound",stored.masterenabled);
	end);
end

--]]


-- final module registration --
-------------------------------
ns.modules[name] = module

