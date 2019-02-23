--------------------------------------------------------
--------------------------------------------------------
----	Project....: LUI NextGenWoWUserInterface    ----
----	Plugin.....: LUI Dynamics					----
----	Description: LUI Dynamic Change Interface   ----
----	Rev Date...: 09/03/2012 (mm/dd/yyyy)        ----
----	Author.....: Kaliad @EU-Pozzo Dell'Eternità ----
--------------------------------------------------------
--------------------------------------------------------


--------------------------------------------------------
--- TO DO : 
--- TO DO : 
--- TO DO : 
--- TO DO : 
--- TO DO :  module:GetProfilesFor(addonName,addon,searchedProfile)  Manca la gestione di VUHDO e HealBOT
--- TO DO : Aggiungere una dropDown in ogni sezione che imposta per tutte le classi lo stesso profilo!!!
--- TO DO : 
--- TO DO : 
--- TO DO : Aggiungere la gestione dell'aggiunta, cancellazione e copia dei profili nella sezione RaidFrames
--- TO DO : Aggiungere la customizzazione per CLIQUE per il ruolo Healer Classe Prete che può essere Holy o Disci e MANCA LA GESTIONE DEL CAMBIO PROFILO DI CLIQUE!!!!
--- TO DO : 
--- TO DO :
--- TO DO : 
--- TO DO : 
--- TO DO : 
--- TO DO : Aggiungere una funzione che cancelli per tutti gli addon gestiti i profili col nome del pg.
--- TO DO : Creare il log della memoria ripulita...
--- TO DO : Gestire OVALE che si disattivi quando sei Healer!!!
--- TO DO : Se riesco a capire qual è il comando per rinominare una finestra di Chat, agggiungere nella gestione Chat il rename delle ChatFrames1-10
--- TO DO : Applica alcuni settaggi di masque con Dynamics..


--------------------------------------------------------
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI")
local module = LUI:Module("Dynamics", "AceEvent-3.0")
local oUF = LUI:Module("Unitframes") 
local Forte = LUI:Module("Forte")

local LSM = LibStub("LibSharedMedia-3.0")

local widgetLists = AceGUIWidgetLSMlists
local version = GetAddOnMetadata("LUI_Dynamics", "Version")
local author = GetAddOnMetadata("LUI_Dynamics", "Author")
local Media = LibStub("LibSharedMedia-3.0")

local DEBUG = true

local db

local fontflags = {"OUTLINE", "THICKOUTLINE", "MONOCHROME", "NONE"}
local LUIunits = {"Player", "Target", "ToT", "ToToT", "Focus", "FocusTarget", "Pet", "PetTarget", "Party", "PartyTarget", "PartyPet", "Boss", "BossTarget", "Maintank", "MaintankTarget", "MaintankToT", "Arena", "ArenaTarget", "ArenaPet", "Raid"}
local units = {"Player", "Target", "ToT", "ToToT", "Focus", "Pet", "PetTarget","Boss"}
local BlizzardScale = 1

local canBeTank = false
local canBeHealer = false
local canBeMelee = false
local canBeRanged = false

--------------------------------------------------
-- / LOCAL VARIABLES / --
--------------------------------------------------

local _,L = ...
local myPlayerName = UnitName("player")
local myPlayerFaction = UnitFactionGroup("player")
local myPlayerRealm = GetRealmName()
local myPlayerClass = UnitClass("player")
local _,class = UnitClass("player")
local myPlayerRole = "" -- TODO : Function to get Role

local DEFAULT_ICON = "Interface\\Icons\\Spell_Shadow_SacrificialShield"
local DIMENSIONE5MENMAX = 5
local DIMENSIONE10MENMAX = 14
local DIMENSIONE25MENMAX = 40

local DUPDATE = false

-- Addons Profile's Management Variables
local profileToDelete= "-"
local addonToDelete= "-"
local currentRoleOptionsSelected = "-"
local addonToCopy = "-"
local profileToCopyFrom = "-"
local profileToCopyTo = "-"
local actualRaidDim = 1
local isBIGWIGSProximityShown = false
local isDXEProximityShown = false
local isDXEAlternateShown = false
local isDXEArrowShown = false

local ClassColorArrayLighter = {
								["WARRIOR"] = {0.87, 0.69, 0.45}, -- Checked
								["PRIEST"] = {0.52, 0.52, 0.52},-- Checked
								["DRUID"] = {1, 0.64, 0.50},-- Checked
								["HUNTER"] = {0.70, 0.91, 0.67},-- Checked
								["MAGE"] = {0.53, 0.79, 0.89},-- Checked
								["PALADIN"] = {0.96, 0.77, 0.91}, -- Checked
								["SHAMAN"] = {0.51, 0.77, 0.98},-- Checked
								["WARLOCK"] = {0.72, 0.61, 0.94}, -- Checked
								["ROGUE"] = {0.88, 0.83, 0.72}, -- Checked
								["DEATH KNIGHT"] = {0.93, 0.46, 0.44},-- Checked
								["DEATHKNIGHT"] = {0.93, 0.46, 0.44},-- Checked
								["MONK"] = {0.44, 0.73, 0.69},
							}	
local ClassColorArrayOfficial = {
								["WARRIOR"] = {1, 0.78, 0.55},
								["PRIEST"] = {0.9, 0.9, 0.9},-- Checked
								["DRUID"] = {1, 0.44, 0.15},-- Checked
								["HUNTER"] = {0.22, 0.91, 0.18},-- Checked
								["MAGE"] = {0.12, 0.58, 0.89},-- Checked
								["PALADIN"] = {0.96, 0.21, 0.73}, -- Checked
								["SHAMAN"] = {0.04, 0.39, 0.98},-- Checked
								["WARLOCK"] = {0.57, 0.22, 1}, -- Checked
								["ROGUE"] = {0.95, 0.86, 0.16}, -- Checked
								["DEATH KNIGHT"] = {0.80, 0.1, 0.1},-- Checked
								["DEATHKNIGHT"] = {0.80, 0.1, 0.1},-- Checked
								["MONK"] = {0.33, 0.54, 0.52},
							}
local ClassColorArrayDarker = {
								["WARRIOR"] = {0.48, 0.38, 0.25},
								["PRIEST"] = {0.50, 0.50, 0.50}, -- Checked
								["DRUID"] = {0.45, 0.30, 0.22}, -- Checked
								["HUNTER"] = {0.38, 0.46, 0.36},-- Checked
								["MAGE"] = {0.33, 0.45, 0.48}, -- Checked
								["PALADIN"] = {0.49, 0.42, 0.47}, -- Checked
								["SHAMAN"] = {0.24, 0.36, 0.47}, -- Checked
								["WARLOCK"] = {0.31, 0.12, 0.54}, -- Checked
								["ROGUE"] = {0.56, 0.51, 0.38}, -- Checked
								["DEATH KNIGHT"] = {0.38, 0.04, 0.04},-- Checked
								["DEATHKNIGHT"] = {0.38, 0.04, 0.04},-- Checked
								["MONK"] = {0.22, 0.36, 0.34},
							}
		
--------------------------------------------------
-- / LOCAL FUNCTIONS / --
--------------------------------------------------
local function CaricaDynamicsMedia(lsm)

-- Textures
lsm:Register("statusbar", "Dynamics_Graphite", [[Interface\AddOns\LUI_Dynamics\Texture\Graphite.tga]])
lsm:Register("statusbar", "Dynamics_Minimalist", [[Interface\AddOns\LUI_Dynamics\Texture\Minimalist.tga]])
lsm:Register("statusbar", "Dynamics_oUFLUI", [[Interface\AddOns\LUI_Dynamics\Texture\oUF_LUI.tga]])
lsm:Register("statusbar", "Dynamics_Ruben", [[Interface\AddOns\LUI_Dynamics\Texture\Ruben.tga]])
lsm:Register("statusbar", "Dynamics_Renaitre", [[Interface\AddOns\LUI_Dynamics\Texture\RenaitreMinion.tga]])
lsm:Register("statusbar", "Dynamics_1", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics1.tga]])
lsm:Register("statusbar", "Dynamics_2", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics2.tga]])
lsm:Register("statusbar", "Dynamics_3", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics3.tga]])
lsm:Register("statusbar", "Dynamics_4", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics4.tga]])
lsm:Register("statusbar", "Dynamics_5", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics5.tga]])
lsm:Register("statusbar", "Dynamics_6", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics6.tga]])
lsm:Register("statusbar", "Dynamics_7", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics7.tga]])
lsm:Register("statusbar", "Dynamics_8", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics8.tga]])
lsm:Register("statusbar", "Dynamics_9", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics9.tga]])
lsm:Register("statusbar", "Dynamics_10", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics10.tga]])
lsm:Register("statusbar", "Dynamics_11", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics11.tga]])
lsm:Register("statusbar", "Dynamics_12", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics12.tga]])
lsm:Register("statusbar", "Dynamics_13", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics13.tga]])
lsm:Register("statusbar", "Dynamics_14", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics14.tga]])
lsm:Register("statusbar", "Dynamics_15", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics15.tga]])
lsm:Register("statusbar", "Dynamics_16", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics16.tga]])
lsm:Register("statusbar", "Dynamics_17", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics17.tga]])
lsm:Register("statusbar", "Dynamics_18", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics18.tga]])
lsm:Register("statusbar", "Dynamics_19", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics19.tga]])
lsm:Register("statusbar", "Dynamics_20", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics20.tga]])
lsm:Register("statusbar", "Dynamics_21", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics21.tga]])
lsm:Register("statusbar", "Dynamics_22", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics22.tga]])
lsm:Register("statusbar", "Dynamics_23", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics23.tga]])
lsm:Register("statusbar", "Dynamics_24", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics24.tga]])
lsm:Register("statusbar", "Dynamics_25", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics25.tga]])
lsm:Register("statusbar", "Dynamics_26", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics26.tga]])
lsm:Register("statusbar", "Dynamics_27", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics27.tga]])
lsm:Register("statusbar", "Dynamics_28", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics28.tga]])
lsm:Register("statusbar", "Dynamics_29", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics29.tga]])
lsm:Register("statusbar", "Dynamics_30", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics30.tga]])
lsm:Register("statusbar", "Dynamics_31", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics31.tga]])
lsm:Register("statusbar", "Dynamics_32", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics32.tga]])
lsm:Register("statusbar", "Dynamics_33", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics33.tga]])
lsm:Register("statusbar", "Dynamics_34", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics34.tga]])
lsm:Register("statusbar", "Dynamics_35", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics35.tga]])
lsm:Register("statusbar", "Dynamics_36", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics36.tga]])
lsm:Register("statusbar", "Dynamics_37", [[Interface\AddOns\LUI_Dynamics\StatusBars\Dynamics37.tga]])

-- Fonts
lsm:Register("font", "Dynamics_AlienFur", [[Interface\AddOns\LUI_Dynamics\Fonts\AlienFur.ttf]])
lsm:Register("font", "Dynamics_Desib", [[Interface\AddOns\LUI_Dynamics\Fonts\DESIB___.ttf]])
lsm:Register("font", "Dynamics_Express", [[Interface\AddOns\LUI_Dynamics\Fonts\expressway rg.ttf]])
lsm:Register("font", "Dynamics_Font1", [[Interface\AddOns\LUI_Dynamics\Fonts\font.ttf]])
lsm:Register("font", "Dynamics_ArmaGeddon", [[Interface\AddOns\LUI_Dynamics\Fonts\fontmageddon.ttf]])
lsm:Register("font", "Dynamics_Font1Old", [[Interface\AddOns\LUI_Dynamics\Fonts\fontold.ttf]])
lsm:Register("font", "Dynamics_Foy", [[Interface\AddOns\LUI_Dynamics\Fonts\FOY1REG.ttf]])
lsm:Register("font", "Dynamics_HemiHead", [[Interface\AddOns\LUI_Dynamics\Fonts\hemi head bd it.ttf]])
lsm:Register("font", "Dynamics_Morpheus", [[Interface\AddOns\LUI_Dynamics\Fonts\MORPHEUS.ttf]])
lsm:Register("font", "Dynamics_Northwood", [[Interface\AddOns\LUI_Dynamics\Fonts\Northwood High.ttf]])
lsm:Register("font", "Dynamics_Robotica", [[Interface\AddOns\LUI_Dynamics\Fonts\Robotica.ttf]])
lsm:Register("font", "Dynamics_Intellivised", [[Interface\AddOns\LUI_Dynamics\Fonts\SF Intellivised Bold.ttf]])
lsm:Register("font", "Dynamics_N_Intellivised", [[Interface\AddOns\LUI_Dynamics\Fonts\Numbers\nasalization rg.ttf]])
lsm:Register("font", "Dynamics_N_Orion", [[Interface\AddOns\LUI_Dynamics\Fonts\Numbers\Orion Pax.ttf]])
lsm:Register("font", "Dynamics_N_ShadowMage", [[Interface\AddOns\LUI_Dynamics\Fonts\Numbers\ShadowMages.ttf]])
lsm:Register("font", "Dynamics_N_SpaceAge", [[Interface\AddOns\LUI_Dynamics\Fonts\Numbers\space age.ttf]])
lsm:Register("font", "Dynamics_N_Ophans", [[Interface\AddOns\LUI_Dynamics\Fonts\Numbers\dream orphans.ttf]])
lsm:Register("font", "Dynamics_N_Libel", [[Interface\AddOns\LUI_Dynamics\Fonts\Numbers\libelsuit.ttf]])

-- Bordi
lsm:Register("border", "Dynamics_Border1", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics1.ttf]])
lsm:Register("border", "Dynamics_Border2", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics2.ttf]])
lsm:Register("border", "Dynamics_Border3", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics3.ttf]])
lsm:Register("border", "Dynamics_Border4", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics4.ttf]])
lsm:Register("border", "Dynamics_Border5", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics5.ttf]])
lsm:Register("border", "Dynamics_Border6", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics6.ttf]])
lsm:Register("border", "Dynamics_Border7", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics7.ttf]])
lsm:Register("border", "Dynamics_Border8", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics8.ttf]])
lsm:Register("border", "Dynamics_Border9", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics9.ttf]])
lsm:Register("border", "Dynamics_Border10", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics10.ttf]])
lsm:Register("border", "Dynamics_Border11", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics11.ttf]])
lsm:Register("border", "Dynamics_Border12", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics12.ttf]])
lsm:Register("border", "Dynamics_Border13", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics13.ttf]])
lsm:Register("border", "Dynamics_Border14", [[Interface\AddOns\LUI_Dynamics\Borders\Dynamics14.ttf]])

end

local function TestCastbar(parent_Frame)
		if parent_Frame:IsShown() then
				if parent_Frame and parent_Frame.Castbar then
					parent_Frame.Castbar.max = 30
					parent_Frame.Castbar.duration = 0
					parent_Frame.Castbar.delay = 0
					parent_Frame.Castbar:SetMinMaxValues(0, 30)
					parent_Frame.Castbar.casting = true
					parent_Frame.Castbar.Text:SetText("Dynamics Dummy Castbar")
					parent_Frame.Castbar:PostCastStart(parent_Frame.__unit, "Dummy Castbar")
					parent_Frame.Castbar:Show()
				end
			
		else
			LUI:Print("The "..parent_Frame.." Frame must be shown for the dummy castbar to work.")
		end
	end
	
local function applyDBMDefaults()
	-- Insert Here all the GENERAL not ROLE Settings for DBM
	DBM.Options.UseMasterVolume = true
	DBM.Options.StatusEnabled = true
	DBM.Options.EnableModels = true
	DBM.Options.ModelSoundValue = "Short"
	DBM.Options.AutoRespond = true
	--DBM.Options.AlwaysShowHealthFrame = true
	DBM.Options.InfoFramePoint = "TOPRIGHT"
	DBM.Bars.options.TimerPoint = "TOPLEFT"
	DBM.Bars.options.HugeTimerPoint = "CENTER"
	DBM.Options.RaidWarningPosition.Point = "TOP"
	DBM.Options.RangeFramePoint = "LEFT"
	DBM.Bars.options.Texture = "Interface\\AddOns\\LUI_Dynamics\\Texture\\RenaitreMinion.tga"
	DBM.Bars.options.Texture = "Interface\\AddOns\\SharedMedia_MyMedia\\statusbar\\Dynamics33.tga"
	
	-- "SharedMedia_MyMedia\\statusbar\\Dynamics33.tga"
end
local function applyBIGWIGSDefaults()
	-- Insert Here all the GENERAL not ROLE Settings for DBM
	BigWigs.db.profile.sound = true
	BigWigs.db.profile.shake = true
	BigWigs.db.profile.raidicon = true
	BigWigs.db.profile.flash = true
	if (BigWigs.modules.Plugins.modules.Bars) then
		BigWigs.modules.Plugins.modules.Bars.db.profile.emphasize = true
		BigWigs.modules.Plugins.modules.Bars.db.profile.emphasizeMove = true
		BigWigs.modules.Plugins.modules.Bars.db.profile.emphasizeFlash = true
		BigWigs.modules.Plugins.modules.Bars.db.profile.emphasizeRestart = true
		BigWigs.modules.Plugins.modules.Bars.db.profile.icon = true
		--BigWigs.modules.Plugins.modules.Bars.db.profile.texture = "Dynamics_oUFLUI"
		--BigWigs.modules.Plugins.modules.Bars.db.profile.barStyle = "BeautyCase"      --- BigWigs.modules.Plugins.modules.Bars:SetBarStyle("BeautyCase")
		BigWigs.modules.Plugins.modules.Bars.db.profile.align = "LEFT"
		BigWigs.modules.Plugins.modules.Bars.db.profile.time = true
	end
	if (BigWigs.modules.Plugins.modules.Messages) then
		BigWigs.modules.Plugins.modules.Messages.db.profile.usecolors = true
		BigWigs.modules.Plugins.modules.Messages.db.profile.classcolor = true
		BigWigs.modules.Plugins.modules.Messages.db.profile.chat = false
	end
	if (BigWigs.modules.Plugins.modules.Proximity) then
		BigWigs.modules.Plugins.modules.Proximity.db.profile.fontSize = 20
		BigWigs.modules.Plugins.modules.Proximity.db.profile.soundDelay = 1
		BigWigs.modules.Plugins.modules.Proximity.db.profile.proximity = true
		BigWigs.modules.Plugins.modules.Proximity.db.profile.lock = false
		BigWigs.modules.Plugins.modules.Proximity.db.profile.graphical = true
		BigWigs.modules.Plugins.modules.Proximity.db.profile.sound = true
		BigWigs.modules.Plugins.modules.Proximity.db.profile.objects.title = true
		BigWigs.modules.Plugins.modules.Proximity.db.profile.objects.close = true
		BigWigs.modules.Plugins.modules.Proximity.db.profile.objects.tooltip = true
		BigWigs.modules.Plugins.modules.Proximity.db.profile.objects.sound = true
		BigWigs.modules.Plugins.modules.Proximity.db.profile.objects.background = true
		BigWigs.modules.Plugins.modules.Proximity.db.profile.objects.ability = true
	end	
end
local function applyFORTEDefaults()
	if FW then
		if FW.Settings then
			local _, class = UnitClass("player")
			local classcolor = ClassColorArrayOfficial[class]
			local classcolorDarker = ClassColorArrayDarker[class]
			FW.Settings.Cooldown.Instances[1].Texture = "Interface\\AddOns\\LUI_Dynamics\\Texture\\RenaitreMinion.tga"
			FW.Settings.Cooldown.Instances[1].IconTime = true
			FW.Settings.Cooldown.Instances[1].BgColor = {classcolor[1],classcolor[2],classcolor[3], 1}
			FW.Settings.Cooldown.Instances[1].TextColor = {1,1,1,0.8}
			FW.Settings.Cooldown.Instances[1].BarColor = {classcolorDarker[1],classcolorDarker[2],classcolorDarker[3], 1}
			-- FW.Settings.Cooldown.Instances[1].
			-- FW.Settings.Cooldown.Instances[1].
		else 
			
			--print("|CFF99FF00Dynamics |r: Error applying Forte Cooldown Settings for |CFF9999FF".. db.profile.ActualRole .."|r Role. (1858)")
		end
	end
end
local function applyDXEDefaults()
	-- SEZIONE GLOBALS:	

	DXE.db.profile.Globals.BarTexture = "Dynamics_Renaitre"
	DXE.db.profile.Globals.BackgroundTexture = "Blizzard Parchment 2"
	DXE.db.profile.Globals.BorderEdgeSize = 12
	DXE.db.profile.Globals.BackgroundInset = 1
					
	-- SEZIONE PANE   :	  
						
	DXE.Alerts.db.profile.ShowRightIcon = false
	DXE.Alerts.db.profile.ShowLeftIcon = true
	DXE.Alerts.db.profile.ShowIconBorder = true
	DXE.Alerts.db.profile.SetIconToBarHeight = true
	DXE.Alerts.db.profile.BarSpacing = 0
	DXE.Alerts.db.profile.WarningMessage = true
	DXE.Alerts.db.profile.WarningBars = true
	DXE.Alerts.db.profile.WarningAlpha = 1

	  DXE.Alerts.db.profile.ShowBarBorder = true
	  DXE.Alerts.db.profile.DisableDropdowns = false
	  DXE.Alerts.db.profile.BarFillDirection = "FILL"
	  DXE.Alerts.db.profile.TopScale = 1
	  DXE.Alerts.db.profile.TopAlpha = 0.75
	  DXE.Alerts.db.profile.CenterScale = 1.15
	  DXE.Alerts.db.profile.CenterAlpha = 1
	  DXE.Alerts.db.profile.WarningAlpha = 1
	  DXE.Alerts.db.profile.ClrWarningText = true
	  DXE.Alerts.db.profile.SinkIcon = true
	  DXE.Alerts.db.profile.FlashTexture = "Interface\Addons\DXE\Textures\LowHealthGray"
	  DXE.Alerts.db.profile.FlashAlpha = 0.8
	  DXE.Alerts.db.profile.FlashDuration = 1.2
	  DXE.Alerts.db.profile.EnableOscillations = true
	  DXE.Alerts.db.profile.FlashOscillations = 5
	  DXE.db.profile.Proximity.AutoPopup = true
	  DXE.db.profile.Proximity.AutoHide = true
	  DXE.db.profile.Proximity.Rows = 9
	  DXE.db.profile.Proximity.IconPosition = "LEFT" --   o RIGHT
	  DXE.db.profile.Proximity.NameAlignment = "CENTER"
	  DXE.db.profile.Proximity.NameFontSize = 12
	  DXE.db.profile.Proximity.TimeFontSize = 12
	  DXE.db.profile.AlternatePower.AutoPopup = true
	  DXE.db.profile.AlternatePower.AutoHide = true
	  DXE.db.profile.AlternatePower.Rows = 10
	  DXE.db.profile.AlternatePower.IconPosition = "LEFT"
	  DXE.db.profile.AlternatePower.NameAlignment = "CENTER"
	  DXE.db.profile.AlternatePower.NameFontSize = 10
	  DXE.db.profile.AlternatePower.TimeFontSize = 10
	  DXE.Alerts.db.profile.BarHeight = 28
	  
end

local function updateBIGWIGSProximityProfile()
	local anchor = BigWigsProximityAnchor
	if not anchor then return end

	BigWigsProximityAnchor:SetWidth(BigWigs.modules.Plugins.modules.Proximity.db.profile.width)
	BigWigsProximityAnchor:SetHeight(BigWigs.modules.Plugins.modules.Proximity.db.profile.height)

	local x = BigWigs.modules.Plugins.modules.Proximity.db.profile.posx
	local y = BigWigs.modules.Plugins.modules.Proximity.db.profile.posy
	if x and y then
		local s = anchor:GetEffectiveScale()
		anchor:ClearAllPoints()
		anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / s, y / s)
	else
		anchor:ClearAllPoints()
		anchor:SetPoint("CENTER", UIParent, "CENTER", 400, 0)
	end

end
local function formatMem(kb)
			if kb > 1024 then
				return format("%.1fmb", kb / 1024)
			else
				return format("%.1fkb", kb)
			end
end

function module:getSpec(group) --ritorna 
	local maxPoints, finalIcon, text, MaxPointTreeID,id, name, desc,iconTexture,_,role
	text="No Assigned Talents"
	if (GetSpecialization()) then
		id, name, desc,iconTexture,_,role = GetSpecializationInfo(GetSpecialization())
		else
		id = ""
		name = "Nessuna Spec"
		iconTexture = "Interface\\Icons\\Spell_Shadow_SacrificialShield"
		role = "DAMAGER"
	end
	return name, iconTexture, role
end  
function module:getInfoPG(id,talentGroup)
	local actualRole="NoRole"
	local actualSpec="No Assigned Talents"
	
	if (db.profile.ActualSpec) then actualSpec = db.profile.ActualSpec end
	if (db.profile.ActualRole) then actualRole = db.profile.ActualRole end
	
	local actualIcon= "Interface\\Icons\\Achievement_BG_trueAVshutout.blp"
	
	local spec,actualIcon, role = module:getSpec(talentGroup)
	local _,class=UnitClass(id)
	
	if role == "TANK" then
		actualRole ="Tank"
	elseif role == "HEALER" then
		actualRole = "Healer"
	elseif role == "DAMAGER" then
		actualRole = "Ranged" 
		if (class=="PALADIN" or class=="DEATHKNIGHT" or class=="ROGUE" or class=="WARRIOR") then 	actualRole = "Melee"	end
		if (class=="SHAMAN" or class=="DRUID") and  (GetSpecialization() == 2) then actualRole = "Melee" end
		if (class=="MONK") and  (GetSpecialization() == 3) then actualRole = "Melee" end
	end

	if actualSpec == "No Assigned Talents" then 
		if class == "MAGE" or class == "WARLOCK" or class == "HUNTER" or class == "PRIEST" or class == "DRUID" or class == "SHAMAN" then
			actualRole = "Ranged" 
		else
			actualRole = "Melee"
		end
	end
	return spec,actualRole,actualIcon
end 
function module:checkClassRoles(playerClass)
	if not playerClass then 
		local _
		_,playerClass = UnitClass("player") 
	end
	if playerClass=="PALADIN" then 
		canBeTank = true
		canBeHealer = true
		canBeMelee = true
		canBeRanged = false
	end
	if playerClass=="PRIEST" then 
		canBeTank = false
		canBeHealer = true
		canBeMelee = false
		canBeRanged = true
	end
	if playerClass=="DEATHKNIGHT" then 
		canBeTank = true
		canBeHealer = false
		canBeMelee = true
		canBeRanged = false
	end
	if playerClass=="ROGUE" then 
		canBeTank = false
		canBeHealer = false
		canBeMelee = true
		canBeRanged = false
	end
	if playerClass=="HUNTER" then 
		canBeTank = false
		canBeHealer = false
		canBeMelee = false
		canBeRanged = true
	end
	if playerClass=="WARRIOR" then 
		canBeTank = true
		canBeHealer = false
		canBeMelee = true
		canBeRanged = false
	end
	if playerClass=="WARLOCK" then 
		canBeTank = false
		canBeHealer = false
		canBeMelee = false
		canBeRanged = true
	end
	if playerClass=="SHAMAN" then 
		canBeTank = false
		canBeHealer = true
		canBeMelee = true
		canBeRanged = true
	end
	if playerClass=="DRUID" then 
		canBeTank = true
		canBeHealer = true
		canBeMelee = true
		canBeRanged = true
	end
	if playerClass=="MAGE" then 
		canBeTank = false
		canBeHealer = false
		canBeMelee = false
		canBeRanged = true
	end
	if playerClass=="MONK" then 
		canBeTank = true
		canBeHealer = true
		canBeMelee = true
		canBeRanged = false
	end
end  -- Called to populate the local canBe flags
function module:updateSpecsRoles()
	local previousRole = db.profile.ActualRole
	local previousSpec = db.profile.ActualSpec
	local RoleChanged = false
	--GetActiveTalentGroup(false,false)
	db.profile.MainSpec, db.profile.MainSpecRole = module:getInfoPG("player",1)
	db.profile.OffSpec, db.profile.OffSpecRole = module:getInfoPG("player",2)
	if ( GetActiveSpecGroup() == 1) then
		if not ((db.profile.MainSpec == "No Assigned Talents" and not (previousSpec == "No Assigned Talents"))) then
			db.profile.ActualRole = db.profile.MainSpecRole
			db.profile.ActualSpec = db.profile.MainSpec
		end
	else
		if not ((db.profile.OffSpec == "No Assigned Talents" and not (previousSpec == "No Assigned Talents"))) then
			db.profile.ActualRole = db.profile.OffSpecRole
			db.profile.ActualSpec = db.profile.OffSpec
		end
	end		
	if not (db.profile.ActualRole == previousRole) then
		RoleChanged = true
	end
	--print("updateSpecsRoles : Ruolo prec = "..previousRole.. " --- Ruolo Attuale = "..db.profile.ActualRole)
	return RoleChanged
end
function module:getRaidDimension()
	local dim = GetNumGroupMembers()
	if dim == 0 then dim =1 end
	return dim
end

--------------------------------------------------
-- / ADDONS MANAGEMENT FUNCTIONS / --
--------------------------------------------------
function resetRealmDB(info)
		print("ALL Realm Dynamics Settings Resetted!")
		db.realm.Dynamics = nil
	end
function startUPRealmDB()
		db.realm.Dynamics = {}
		module:InitializeRealmDB("Tank")
		module:InitializeRealmDB("Healer")
		module:InitializeRealmDB("Melee")
		module:InitializeRealmDB("Ranged")
end
function printRealmDB()
		
	print("------- REALM DB ------- ")
	if db.realm.Dynamics == nil then print("Vuoto") return end
		if db.realm.Dynamics then
			for k,v in pairs(db.realm.Dynamics) do
				print ("- "..k)
				for x,y in pairs (v) do
					print("-- "..x)
					-- for a,b in pairs (y) do
					--	print("--- "..a)
						-- for i,o in pairs (b) do
							-- --if type(o)=="boolean" then if o then o="true" else o="false" end end
							-- print("---- "..i.. " = ".. tostring(o))
						-- end
					--end
				end
			end
		end
		
end
	
function module:InitializeRealmDB(role)
	
	local newRole = {
				LUI = {
					Player = {
							X = oUF.db.profile.Player.X,
							Y = oUF.db.profile.Player.Y,
							Width = oUF.db.profile.Player.Width,
							Height = oUF.db.profile.Player.Height,	
							Castbar = {
								X = oUF.db.profile.Player.Castbar.X,
								Y = oUF.db.profile.Player.Castbar.Y,
								Width = oUF.db.profile.Player.Castbar.Width,
								Height = oUF.db.profile.Player.Castbar.Height,	
								Enable = oUF.db.profile.Player.Castbar.Enable,	
							},
					},
					Target = {
							X = oUF.db.profile.Target.X,
							Y = oUF.db.profile.Target.Y,
							Width = oUF.db.profile.Target.Width,
							Height = oUF.db.profile.Target.Height,	
							Castbar = {
								X = oUF.db.profile.Target.Castbar.X,
								Y = oUF.db.profile.Target.Castbar.Y,
								Width = oUF.db.profile.Target.Castbar.Width,
								Height = oUF.db.profile.Target.Castbar.Height,	
								Enable = oUF.db.profile.Target.Castbar.Enable,	
							},	
					},
					ToT = {
							X = oUF.db.profile.ToT.X,
							Y = oUF.db.profile.ToT.Y,
							Width = oUF.db.profile.ToT.Width,
							Height = oUF.db.profile.ToT.Height,		
							Enable = oUF.db.profile.ToT.Enable,
					},
					Focus = {
							X = oUF.db.profile.Focus.X,
							Y = oUF.db.profile.Focus.Y,
							Width = oUF.db.profile.Focus.Width,
							Height = oUF.db.profile.Focus.Height,
							Enable = oUF.db.profile.Focus.Enable,
							Castbar = {
								X = oUF.db.profile.Focus.Castbar.X,
								Y = oUF.db.profile.Focus.Castbar.Y,
								Width = oUF.db.profile.Focus.Castbar.Width,
								Height = oUF.db.profile.Focus.Castbar.Height,	
								Enable = oUF.db.profile.Focus.Castbar.Enable,	
							},			
					},
					Pet = {
							X = oUF.db.profile.Pet.X,
							Y = oUF.db.profile.Pet.Y,
							Width = oUF.db.profile.Pet.Width,
							Height = oUF.db.profile.Pet.Height,
							Enable = oUF.db.profile.Pet.Enable,	
							Castbar = {
								X = oUF.db.profile.Pet.Castbar.X,
								Y = oUF.db.profile.Pet.Castbar.Y,
								Width = oUF.db.profile.Pet.Castbar.Width,
								Height = oUF.db.profile.Pet.Castbar.Height,	
								Enable = oUF.db.profile.Pet.Castbar.Enable,	
							},		
					},
					PetTarget = {
							X = oUF.db.profile.PetTarget.X,
							Y = oUF.db.profile.PetTarget.Y,
							Width = oUF.db.profile.PetTarget.Width,
							Height = oUF.db.profile.PetTarget.Height,	
							Enable = oUF.db.profile.PetTarget.Enable,		
					},
				},
				BT4 = {
					DEATHKNIGHT = "-",
					DRUID = "-",
					HUNTER = "-",
					MAGE = "-",
					MONK = "-",
					PALADIN = "-",
					PRIEST = "-",
					ROGUE = "-",
					SHAMAN = "-",
					WARLOCK = "-",
					WARRIOR = "-",	
				},
				MSBT = {
					DEATHKNIGHT = "-",
					DRUID = "-",
					HUNTER = "-",
					MAGE = "-",
					MONK = "-",
					PALADIN = "-",
					PRIEST = "-",
					ROGUE = "-",
					SHAMAN = "-",
					WARLOCK = "-",
					WARRIOR = "-",	
				},
				RAIDFRAMES = {
					MEN1 = {
						DEATHKNIGHT = {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
							DXE = "-",
							BIGWIGS = "-",
							DBM = "-",
						},
						DRUID =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
							DXE = "-",
							BIGWIGS = "-",
							DBM = "-",
						},
						HUNTER =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						MAGE =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						PALADIN =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						MONK =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						PRIEST =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						ROGUE =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						SHAMAN =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						WARLOCK =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						WARRIOR =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},	
					},
					MEN5 = {
						DEATHKNIGHT = {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
							DXE = "-",
							BIGWIGS = "-",
							DBM = "-",
						},
						DRUID =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
							DXE = "-",
							BIGWIGS = "-",
							DBM = "-",
						},
						HUNTER =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						MAGE =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						MONK =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						PALADIN =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						PRIEST =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						ROGUE =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						SHAMAN =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						WARLOCK =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						WARRIOR =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},	
					},
					MEN10 = {
						DEATHKNIGHT = {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						DRUID =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						HUNTER =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						MAGE =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						MONK =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						PALADIN =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						PRIEST =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						ROGUE =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						SHAMAN =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						WARLOCK =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						WARRIOR =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},	
					},
					MEN25 = {
						DEATHKNIGHT = {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						DRUID =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						HUNTER =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						MAGE =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						MONK =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						PALADIN =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						PRIEST =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						ROGUE =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						SHAMAN =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						WARLOCK =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						WARRIOR =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},	
					},
					MEN40 = {
						DEATHKNIGHT = {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						DRUID =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						HUNTER =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						MAGE =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						MONK =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						PALADIN =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						PRIEST =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						ROGUE =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						SHAMAN =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						WARLOCK =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},
						WARRIOR =  {
							GRID = "-",
							CLIQUE = "-",
							VUHDO = "-",
							HEALBOT = "-",
						},	
					},
				},
				FORTE = {
					COOLDOWN =  {
							X = "0",
							Y = "120",
							WIDTH = "780",
							HEIGHT = "40",
					},
					COOLDOWNSPLAH =  {
							X = "-180",
							Y = "350",
							Anchor = "Bottom",
							SCALE = 3,
					},
					TOPTEXTURE = {
							X = "0",
							Y = "90",
							EnableAnimation = true,
							AnimationHeight = "30",
							Alpha = 0.95,
					},
					BOTTOMTEXTURE = {
							X = "0",
							Y = "-25",
							Alpha = 1,
					},
					PLAYER =  {
							Enable = false,
							X = "0",
							Y = "0",
							WIDTH = "208",
							HEIGHT = "14",
					},
					TARGET =  {
							Enable = false,
							X = "0",
							Y = "0",
							WIDTH = "208",
							HEIGHT = "14",
					},
					FOCUS =  {
							Enable = false,
							X = "0",
							Y = "0",
							WIDTH = "208",
							HEIGHT = "14",
					},
					COMPACT =  {
							Enable = false,
							X = "0",
							Y = "0",
							Anchor = "LEFT",
							WIDTH = "50",
							HEIGHT = "18",
					},
				},
				CHAT = {
					LEFTCHAT = {
						X = "28",
						Y = "46",
						WIDTH = "404",
						HEIGHT = "175",
						WINDOWS = {},
						ENABLED = true,
					},
					RIGHTCHAT = {
						X = "1552",
						Y = "40",
						WIDTH = "390",
						HEIGHT = "160",
						WINDOWS = {},
						ENABLED = true,
					},
					CHANNELS = {
						SAY = {},
						EMOTE = {},
						YELL = {},
						GUILDCHAT = {},
						OFFICERCHAT = {},
						PARTY = {},
						PARTYLEADER = {},
						RAID = {},
						RAIDLEADER = {},
						RAIDAWARNING = {},
						BATTLEGROUNDLEADER = {},
						BATTLEGROUND = {},
						GLOBAL1 = {},
						GLOBAL2 = {},
						GLOBAL3 = {},
						GLOBAL4 = {},
						GLOBAL5 = {},
						CREATURESAY = {},
						CREATUREEMOTE = {},
						CREATUREYELL = {},
						CREATUREWISPER = {},
						BOSSEMOTE = {},
						BOSSWHISPER = {},
						EXPERIENCE = {},
						GUILDEXPERIENCE = {},
						HONOR = {},
						REPUTATION = {},
						SKILLUPS = {},
						ITEMLOOT = {},
						CURRENCY = {},
						MONEYLOOT = {},
						TRADESKILLS = {},
						OPENING = {},
						PETINFO = {},
						MISCINFO = {},
					},
				},
				BOSSMODS = {
					DBM = {
					    defaults = true,
					    BARS = {
					        NORMALX = "300",
					        NORMALY = "-240",
					        NORMALWIDTH = "312",
					        NORMALSCALE = "1",
					        HUGEX = "0",
					        HUGEY = "130",
					        HUGEWIDTH = "187",
					        HUGESCALE = "1.2",
					        EXPANDUPWARDS = false,
					        CLASSCOLORBARS = true,    
					    },
					    SPECIALWARNINGS = {
					        X = "0",
					        Y = "-270",
					    },
					    RAIDWARNINGS = {
					        X = "0",
					        Y = "-200",
					    },
					    RANGECHECK = {
					        X = "10",
					        Y = "-200",
					    },
					    RANGECHECKRADAR = {
					        X = "-80",
					        Y = "-235",
					    },
					    BOSSHPFRAME = {
					        X = "-57",
					        Y = "-48",
					        GROWUPWARDS = false,
					        WIDTH = "160",
					    },
					    INFOFRAME = {
					        X = "-380",
					        Y = "-30",
					    },
					    
					},
					BIGWIGS = {
					      defaults = true,
					     NORMALBAR = {
					        X = "458"  ,
					        Y = "264"  ,
					        WIDTH = "244",
					        SCALE = "1",
					        GROWUP = true,
					    },
					     EMPHASIZEDBAR = {
					        X = "552"  ,
					        Y = "742"  ,
					        WIDTH = "375",
					        SCALE = "1.7",
					        GROWUP = false,
					        FONTSIZE = "18",
					    },
					     NORMALMESSAGES = {
					        X = "620"  ,
					        Y = "441"  ,
					    },
					     EMPHASIZEDMESSAGES = {
					        X = "620"  ,
					        Y = "598"  ,
					     },
					     PROXIMITY = {
					        X = "1"  ,
					        Y = "262"  ,
					        WIDTH = "192",
					        HEIGHT = "120",
					    },
					    
					},
					DXE = {
					      defaults = true,
					    PANE = {
					        X = "-22"  ,
					        Y = "-60"  ,
					        SCALE = "0.8",
					        WIDTH = "183",
					        TITLEFONTSIZE = "13",
					        HEALTHFONTSIZE = "12",
                            BARGROWTH = "DOWN",					        
					    },
					     TOPBAR = {
					        X = "-385"  ,
					        Y = "-175"  ,
					        WIDTH = "228",
					       TEXTWIDTH = "160",
					       GROWTH = "UP",					        
					    },
					     CENTERBAR = {
					        X = "-15"  ,
					        Y = "-58"  ,
					        WIDTH = "305",
					        TEXTWIDTH = "240",
					        GROWTH = "DOWN",					        
					    },
					     WARNINGBAR = {
					        X = "-30"  ,
					        Y = "-180"  ,
					        SCALE = "1.2",
					        WIDTH = "310",
					        TEXTWIDTH = "300",
					        GROWTH = "UP",					        
					    },
					     FLASHSCREEN = {
					        ALPHA = "0.8",
					     },
					     PROXIMITY = {
					        X = "4"  ,
					        Y = "-235"  ,				        
					    },
					     ALTERNATEPOWER = {
					        X = "-167"  ,
					        Y = "67"  ,				        
					    },
					    ARROW1 = {
					        X = "-453"  ,
					        Y = "-135"  ,				        
					    },
					    ARROW2 = {
					        X = "--361"  ,
					        Y = "-135"  ,				        
					    },
					   ARROW3 = {
					        X = "-271"  ,
					        Y = "-135"  ,				        
					    },
					},
				},
				UIENANCHEMENTS = {
					SKULLME = false,
					SETSRTI = false,
					MAXCAMERA = false,
					GARBAGE = false,
					AUTORESS = false,
					BAGNONCOLORS = false,
					Minimap = false,
				},
				
	} -- end NewRole
	--Inizializing role DB
	--db.realm.Dynamics[role]= newRole
	--db.realm.Dynamics["RAIDDIM"] = {
									-- MEN1 = "1",
									-- MEN5 = "2",
									-- MEN10 = "7",
									-- MEN25 = "12",
									-- MEN40 = "27",
									-- },
	print("Dynamics Realm ".. role.." DB Inizializated!")
end -- to inizialize all the Addons Packs DB.

function module:CheckDeletable(addonName,profile)
	local deletable = true
	local reason = "Unknown Reason"
	if (addonName == "Bartender4") then
		reason= "Profile Deletion LOCKED ATM!"
		
		if db.realm.Dynamics then
			for k,v in pairs(db.realm.Dynamics) do
				if v.BT4 then
					for x,y in pairs(v.BT4) do
						if y == profile then 
							deletable=false 
							reason = "|CFFFF3333is used as Current profile for role ".. k .." in the ".. x.. " Class!|r"
						end
					end
				end
			end
		end
	elseif (addonName == "MikScrollingBattleText") then
		reason= "MSBT Profile Deletion LOCKED ATM!"
		if db.realm.Dynamics then
			for k,v in pairs(db.realm.Dynamics) do
				if v.MSBT then
					for x,y in pairs(v.MSBT) do
						if y == profile then 
							deletable=false 
							reason = "|CFFFF3333is used as Current profile for role ".. k .." in the ".. x.. " Class!|r"
						end
					end
				end
			end
		end
	
	end
	return deletable,reason
end
function module:GetProfilesFor(addonName,addon,searchedProfile)
	local array = {}
	local ret = false -- Definisco un booleano per dire se il profilo messo in 3° parametro è presente
	local leggiProfili = true -- Definisco un booleano per scegliere in base all'addon quale lettura va fatta.
	
	-- DEfinisco se l'addon è caricato 
	local AddonAttivo = false
	if IsAddOnLoaded(addonName) then AddonAttivo = true end
	if addonName == "MikScrollingBattleText" and not AddonAttivo then 
		--if (MikSBT) then AddonAttivo= true else print("ANCHE MikSBT vale NIL!!!! PD") end
	end
	
	if AddonAttivo then -- Controllo se l'addon è attivato
		table.insert(array, "-") -- Creo il vettore di nomi profili
		local t -- Definisco un vettore di supporto
		
		-- Nel caso addon non sia stato passato come parametro, mi assicuro che venga associato:
		if addonName == "Grid" then addon = Grid
		elseif addonName =="Vuhdo" then leggiProfili = false -- Per la futura gestione di Vuhdo
		elseif addonName =="Healbot" then leggiProfili = false -- Per la futura gestione di Healbot
		end
		
		if addonName == "MikScrollingBattleText" then
			t= addon.Profiles.savedVariables.profiles
			for k,v in pairs(t) do
				table.insert(array,k)
				if (searchedProfile) then
					if k == searchedProfile then ret=true end
				end
			end
		else
			if leggiProfili then
			t = addon.db:GetProfiles()
			for i=1,#t do 
				table.insert(array,t[i])
				if (searchedProfile) then
					if t[i] == searchedProfile then ret=true end
				end
			end -- Fine For
			end -- Fine If LeggiProfili
		end -- Fine If 
	else -- Se l'addon non è attivato
		--print (addonName .. " NON e' LOADED!!!!!!")
		table.insert(array, addonName .." Non Attivo")
	end
	table.sort(array) -- Ordino il Vettore prima di restituirlo al chiamante
	return array,ret
end
function module:DeleteProfileFor(addonName,profileName)
	local addon
	if IsAddOnLoaded(addonName) then
		local deletable,reason = module:CheckDeletable(addonName,profileName)
		
		if (deletable) then
			if addonName == "Bartender4" then
				addon = Bartender4
				
				addon.db:DeleteProfile(profileName, true) 
				print("|CFF99CCFFDynamics|r: ".. profileName .. " " ..addonName .." Profile DELETED!")
				module:UpdateOptions("BT4MOD")
				currentRoleOptionsSelected = "-"
			elseif addonName =="MikScrollingBattleText" then
				addon = MikSBT
				MikSBT.Profiles.DeleteProfile(profileName) 
				print("|CFF99CCFFDynamics|r: ".. profileName .. " " ..addonName .." Profile DELETED!")
				module:UpdateOptions("MSBTMOD")
				currentRoleOptionsSelected = "-"
			elseif addonName == "Clique" then
				addon = Clique
				
				addon.db:DeleteProfile(profileName, true) 
				print("|CFF99CCFFDynamics|r: ".. profileName .. " " ..addonName .." Profile DELETED!")
				module:UpdateOptions("CLIQUEMOD")
				currentRoleOptionsSelected = "-"
			end
			
		else
			print("|CFF99CCFFDynamics|r: ".. profileName .. " " ..addonName .." Profile can't be deleted because " .. reason)
		end
	else 
		print("Addon "..addonName.." NOT LOADED")
	end 
	profileToDelete = "-"
	addonToDelete = "-"
end
function module:CopyProfileFor(addonName,FromProfileName,ToProfileName)
	local addon
	if IsAddOnLoaded(addonName) then
			if addonName == "Bartender4" then
				addon = Bartender4
				local current = addon.db:GetCurrentProfile()
				addon.db:SetProfile(ToProfileName)
				addon.db:CopyProfile(FromProfileName, true) 
				print("|CFF99CCFFDynamics|r: |CFF99CCFF".. FromProfileName .."|r |CFF9999FF"..addonName .."|r Profile COPIED to profile |CFF99CCFF".. ToProfileName .."|r !")
				addon.db:SetProfile(current)
				module:UpdateOptions("BT4")
				currentRoleOptionsSelected = "-"
			elseif addonName =="MikScrollingBattleText" then
				local current = db.profile.currentMSBTProfile
				MikSBT.Profiles.CopyProfile(ToProfileName,current) 
				print("|CFF99CCFFDynamics|r: |CFF99CCFF".. FromProfileName .."|r |CFF9999FF"..addonName .."|r Profile COPIED to profile |CFF99CCFF".. ToProfileName .."|r !")
				MikSBT.Profiles.SelectProfile(db.profile.currentMSBTProfile)
				module:UpdateOptions("MSBT")
				currentRoleOptionsSelected = "-"
			elseif addonName =="Clique" then
				addon = Clique
				local current = addon.db:GetCurrentProfile()
				addon.db:SetProfile(ToProfileName)
				addon.db:CopyProfile(FromProfileName, true) 
				print("|CFF99CCFFDynamics|r: |CFF99CCFF".. FromProfileName .."|r |CFF9999FF"..addonName .."|r Profile COPIED to profile |CFF99CCFF".. ToProfileName .."|r !")
				addon.db:SetProfile(current)
				module:UpdateOptions("CLIQUE")
				currentRoleOptionsSelected = "-"
			end
			
	end 
	profileToCopyFrom = "-"
	profileToCopyTo = "-"
	addonToCopy = "-"
end

function module:TimeToUpdate()
	local ok = true
	local now = GetTime()
	if db.profile.updateTime then
		if (now - db.profile.updateTime) <= 2 then
			ok = false
			--print("|CFF99FF00Dynamics |r: Nothing Changed for |CFF9999FF".. db.profile.ActualRole .."|r Role. (TIMEtoUPDATE Work)")
		
		end
	end
	db.profile.updateTime = GetTime()
	return ok
end
function module:readRaidManager()
	local raidManager = "-"
	local GRIDLOADED = false
	local VUHDOLOADED = false
	local HEALBOTLOADED = false
	
	if IsAddOnLoaded("Grid") then GRIDLOADED = true	end
	if IsAddOnLoaded("Vuhdo") then VUHDOLOADED = true end
	if IsAddOnLoaded("Healbot") then HEALBOTLOADED = true end
	
	if HEALBOTLOADED then raidManager = "Healbot" end
	if VUHDOLOADED then raidManager = "Vuhdo" end
	if GRIDLOADED then raidManager = "Grid" end
	
	return raidManager
end
function module:getRaidKey(dim)
	local key = "MEN5"
	local dim10,dim25,dim40
	
	if db.realm.Dynamics["RAIDDIM"]["MEN10"] then dim10 = tonumber(db.realm.Dynamics["RAIDDIM"]["MEN10"])  else dim10 = 6 end
	if db.realm.Dynamics["RAIDDIM"]["MEN25"] then dim25 = tonumber(db.realm.Dynamics["RAIDDIM"]["MEN25"])  else dim25 = 12 end
	if db.realm.Dynamics["RAIDDIM"]["MEN40"] then dim40 = tonumber(db.realm.Dynamics["RAIDDIM"]["MEN40"])  else dim40 = 27 end
	
	if dim == 1 then key ="MEN1" end
	if dim >= dim10 then key ="MEN10" end
	if dim >= dim25 then key ="MEN25" end
	if dim >= dim40 then key ="MEN40" end
	
	return key
end
function OpenChatWindow(id)
        local name = 'ChatFrame' .. id
        _G[name]:Show()
        _G[name .. 'Tab']:Show()
        SetChatWindowShown(id, 1)
    
end

function module:GetBossMods()
 if db.profile.ManageBossMod then
	local d_dbm = IsAddOnLoaded("DBM-Core")
	local d_bigwigs = IsAddOnLoaded("BigWigs")
	local d_dxe = IsAddOnLoaded("DXE_Loader")
	
	--if not d_bigwigs then d_bigwigs = IsAddOnLoadOnDemand("BigWigs") end
	
	if d_dbm then db.profile.BossMods.DBM = true else db.profile.BossMods.DBM = false end
	if d_bigwigs then db.profile.BossMods.BIGWIGS = true else db.profile.BossMods.BIGWIGS = false end
	if d_dxe then db.profile.BossMods.DXE = true else db.profile.BossMods.DXE = false end
	-- print("DBM = ".. tostring(db.profile.BossMods.DBM))
	-- print("BIGWIGS = ".. tostring(db.profile.BossMods.BIGWIGS))
	-- print("DXE = ".. tostring(db.profile.BossMods.DXE))
	-- 
	-- print("BIGWIGS è on demand : " .. tostring(IsAddOnLoadOnDemand("BigWigs")))
	if d_dbm then 
		if not DBM then 
				print("|CFF99FF00Dynamics |r: DBM is not Loaded. DMB AutoConfig Failed.")
		end
	if d_bigwigs then 
		if not BigWigs then	
				LoadAddOn("BigWigs_Core") 
				LoadAddOn("BigWigs")
				-- if not BigWigs then return end
				--BigWigs:Enable()
				-- for name, module in BigWigs:IterateBossModules() do
					-- if module:IsEnabled() then module:Reboot() end
				-- end
		end
	end
	
	if d_dxe then 
		if not select(4,GetAddOnInfo("DXE")) then EnableAddOn("DXE") end 
		if not DXE then	LoadAddOn("DXE") end
	end
	end
 end
end
--------------------------------------------------
-- / ADDON POPUPS/ --
--------------------------------------------------

StaticPopupDialogs["DELETEPROFILE"] = {
			text = "Can you confirm to |CFFFF3333DELETE|r the |CFF9999FF".. addonToDelete .."|r Profile : |CFF99CCFF"..profileToDelete .."|r" ,
			button1 = ACCEPT,
			button2 = CANCEL,
			hasEditBox = false	,
			OnAccept = function(self)
						module:DeleteProfileFor(addonToDelete,profileToDelete)
						end,
			--OnShow = function(self) end,
			--OnHide = function(self) end,
			--EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
			timeout = 0,
			exclusive = 1,
			whileDead = 1,
			hideOnEscape = 0
		}
StaticPopupDialogs["COPYPROFILE"] = {
			text = "Can you confirm to |\CFFFFFF00COPY|r the |CFF9999FF".. 
					addonToCopy .."|r Profile : |CFF99CCFF"..profileToCopyFrom ..
					"|r\nTo the Profile : |CFF99CCFF" .. profileToCopyTo .." |r?" ,
			button1 = ACCEPT,
			button2 = CANCEL,
			hasEditBox = false	,
			OnAccept = function(self)
						module:CopyProfileFor(addonToCopy,profileToCopyFrom,profileToCopyTo)
						end,
			--OnShow = function(self) end,
			--OnHide = function(self) end,
			--EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
			timeout = 0,
			exclusive = 1,
			whileDead = 1,
			hideOnEscape = 0
		}


--------------------------------------------------
-- / PROFILE MANAGEMENT ARRAYS / --
--------------------------------------------------
local bt4profiles = module:GetProfilesFor("Bartender4",Bartender4)
local msbtprofiles = module:GetProfilesFor("MikScrollingBattleText",MikSBT)
local raidprofiles = module:GetProfilesFor(module:readRaidManager())
local cliqueprofiles = module:GetProfilesFor("Clique",Clique) 
--------------------------------------------------
-- / DYNAMICS ROLE SETTINGS FUCNTIONS / --
--------------------------------------------------

function module:dynamicsUpdateLUI() --Fired from Events
	--print("dynamicsUpdateLUI : imposta ruolo "..db.profile.ActualRole)
	if db.profile.ManageLUI then --LUI Positions
		if db.realm.Dynamics[db.profile.ActualRole] then
			local r = db.realm.Dynamics[db.profile.ActualRole]
			if r.LUI then 
				if r.LUI.Player and oUF_LUI_player then
					oUF.db.profile.Player.X = r.LUI.Player.X
					oUF.db.profile.Player.Y = r.LUI.Player.Y
					oUF_LUI_player:SetPoint("CENTER", UIParent, "CENTER", r.LUI.Player.X ,r.LUI.Player.Y)
					
				end
				if r.LUI.Target and oUF_LUI_target then
					oUF.db.profile.Target.X = r.LUI.Target.X
					oUF.db.profile.Target.Y = r.LUI.Target.Y
					oUF_LUI_target:SetPoint("CENTER", UIParent, "CENTER", r.LUI.Target.X ,r.LUI.Target.Y)
					
				end
				if r.LUI.ToT and oUF_LUI_targettarget then
					oUF.db.profile.ToT.X = r.LUI.ToT.X
					oUF.db.profile.ToT.Y = r.LUI.ToT.Y
					oUF_LUI_targettarget:SetPoint("CENTER", UIParent, "CENTER", r.LUI.ToT.X ,r.LUI.ToT.Y)
					
				end
				if r.LUI.Focus and oUF_LUI_focus then
					oUF.db.profile.Focus.X = r.LUI.Focus.X
					oUF.db.profile.Focus.Y = r.LUI.Focus.Y
					oUF_LUI_focus:SetPoint("CENTER", UIParent, "CENTER", r.LUI.Focus.X ,r.LUI.Focus.Y)
					
				end
				if r.LUI.Pet and oUF_LUI_pet then
					oUF.db.profile.Pet.X = r.LUI.Pet.X
					oUF.db.profile.Pet.Y = r.LUI.Pet.Y
					oUF_LUI_pet:SetPoint("CENTER", UIParent, "CENTER", r.LUI.Pet.X ,r.LUI.Pet.Y)
					
				end
				if r.LUI.PetTarget and oUF_LUI_pettarget then
					oUF.db.profile.PetTarget.X = r.LUI.PetTarget.X
					oUF.db.profile.PetTarget.Y = r.LUI.PetTarget.Y
					oUF_LUI_pettarget:SetPoint("CENTER", UIParent, "CENTER", r.LUI.PetTarget.X ,r.LUI.PetTarget.Y)
					
				end
				if r.LUI.Player and r.LUI.Player.Castbar and oUF_LUI_player_Castbar then
					oUF.db.profile.Player.Castbar.General.X = r.LUI.Player.Castbar.X
					oUF.db.profile.Player.Castbar.General.Y = r.LUI.Player.Castbar.Y
					oUF.db.profile.Player.Castbar.General.Width = r.LUI.Player.Castbar.Width
					oUF.db.profile.Player.Castbar.General.Height = r.LUI.Player.Castbar.Height
					
					if oUF_LUI_player_Castbar then 
					oUF_LUI_player.Castbar:SetPoint(oUF.db.profile.Player.Castbar.General.Point, UIParent, oUF.db.profile.Player.Castbar.General.Point, r.LUI.Player.Castbar.X, r.LUI.Player.Castbar.Y) end
					oUF_LUI_player.Castbar:SetWidth(r.LUI.Player.Castbar.Width)
					oUF_LUI_player.Castbar:SetHeight(r.LUI.Player.Castbar.Height)
					
				end
				if r.LUI.Target and r.LUI.Target.Castbar and oUF_LUI_target and oUF_LUI_target.Castbar then
					oUF.db.profile.Target.Castbar.General.X = r.LUI.Target.Castbar.X
					oUF.db.profile.Target.Castbar.General.Y = r.LUI.Target.Castbar.Y
					oUF.db.profile.Target.Castbar.General.Width = r.LUI.Target.Castbar.Width
					oUF.db.profile.Target.Castbar.General.Height = r.LUI.Target.Castbar.Height
					if oUF_LUI_target_Castbar then
					oUF_LUI_target.Castbar:SetPoint("BOTTOM", UIParent, "BOTTOM", r.LUI.Target.Castbar.X, r.LUI.Target.Castbar.Y)
					oUF_LUI_target.Castbar:SetWidth(r.LUI.Target.Castbar.Width)
					oUF_LUI_target.Castbar:SetHeight(r.LUI.Target.Castbar.Height)
					
					end
					
				end
				if r.LUI.Focus and r.LUI.Focus.Castbar and oUF_LUI_focus and oUF_LUI_focus_Castbar then
					oUF.db.profile.Focus.Castbar.General.X = r.LUI.Focus.Castbar.X
					oUF.db.profile.Focus.Castbar.General.Y = r.LUI.Focus.Castbar.Y
					if oUF_LUI_focus_Castbar then
					oUF_LUI_focus_Castbar:SetPoint("TOP", oUF_LUI_focus, "BOTTOM", r.LUI.Focus.Castbar.X, r.LUI.Focus.Castbar.Y) end
					
				end
				if r.LUI.Pet and r.LUI.Pet.Castbar and oUF_LUI_pet and oUF_LUI_pet_Castbar then
					oUF.db.profile.Pet.Castbar.General.X = r.LUI.Pet.Castbar.X
					oUF.db.profile.Pet.Castbar.General.Y = r.LUI.Pet.Castbar.Y
					if oUF_LUI_pet_Castbar then
					oUF_LUI_pet_Castbar:SetPoint("TOP", oUF_LUI_pet, "BOTTOM", r.LUI.Pet.Castbar.X, r.LUI.Pet.Castbar.Y) end
					
				end
				
			end
			
			
		end
		--print("Dynamics : LUI Positions applyed for ".. db.profile.ActualRole) 
	end
	if db.profile.ManageLUI then  -- LUI Dimensions
		if db.realm.Dynamics[db.profile.ActualRole] then
			local r = db.realm.Dynamics[db.profile.ActualRole]
			if r.LUI then 
				if r.LUI.Player then
					-- oUF.db.profile.Player.X = r.LUI.Player.X
					-- oUF.db.profile.Player.Y = r.LUI.Player.Y
					-- oUF_LUI_player:SetPoint("CENTER", UIParent, "CENTER", r.LUI.Player.X ,r.LUI.Player.Y)
					
				end
			end
			
		end	
		--print("Dynamics : LUI Dimensions applyed for ".. db.profile.ActualRole)		
	end
	if db.profile.ManageLUI then  -- LUI Dimensions
	
		--print("Dynamics : LUI Details applyed for ".. db.profile.ActualRole)		
	end
		
end -- Done
function module:dynamicsUpdateBossMods() --Fired from Events
	if db.profile.ManageBossMod then  -- BossMods Settings
	

		local _, class = UnitClass("player")
		local startClasscolor = ClassColorArrayLighter[class]
		local endClasscolor = ClassColorArrayOfficial[class]
		

		module:GetBossMods() -- Get the Used BossMods
		
		------------------------------------------- DBM Loaded ------------------------------------------
		if (db.profile.BossMods.DBM) then
			if not DBM then 
				print("|CFF99FF00Dynamics |r: DBM is not Loaded. DMB AutoConfig Failed.") 
			else
			
				local role = db.profile.ActualRole
				
				-- APPLY the "AllROLES" DBM Settings
				if db.realm.Dynamics[role].BOSSMODS.DBM.defaults then 
					applyDBMDefaults()	
				end
				
				if not (role == "") then
					DBM.Bars.options.ExpandUpwards = db.realm.Dynamics[role].BOSSMODS.DBM.BARS.EXPANDUPWARDS
					if db.realm.Dynamics[role].BOSSMODS.DBM.BARS.CLASSCOLORBARS then 
						DBM.Bars.options.StartColorR = startClasscolor[1]	
						DBM.Bars.options.StartColorG = startClasscolor[2]
						DBM.Bars.options.StartColorB = startClasscolor[3]
						DBM.Bars.options.EndColorR = endClasscolor[1]	
						DBM.Bars.options.EndColorG = endClasscolor[2]
						DBM.Bars.options.EndColorB = endClasscolor[3]
					else
						DBM.Bars.options.StartColorR = 1	
						DBM.Bars.options.StartColorG = 1
						DBM.Bars.options.StartColorB = 0
						DBM.Bars.options.EndColorR = 1	
						DBM.Bars.options.EndColorG = 0
						DBM.Bars.options.EndColorB = 0
					end
					
					-- DBM Bars Settings
					DBM.Bars.options.TimerX = db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALX 
					DBM.Bars.options.TimerY = db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALY 
					DBM.Bars.options.Scale = db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALSCALE 
					DBM.Bars.options.Width = db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALWIDTH 
					DBM.Bars.options.HugeTimerX = db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGEX 
					DBM.Bars.options.HugeTimerY = db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGEY 
					DBM.Bars.options.HugeWidth = db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGEWIDTH 
					DBM.Bars.options.HugeScale = db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGESCALE 
					
					-- Refresh DBM Bars 
					if DBM.Bars then
						if DBM.Bars.mainAnchor and DBM.Bars.secAnchor then
							DBM.Bars:ApplyStyle()
							DBM.Bars.mainAnchor:ClearAllPoints()
							DBM.Bars.secAnchor:ClearAllPoints()
							DBM.Bars.mainAnchor:SetPoint(DBM.Bars.options.TimerPoint, UIParent, DBM.Bars.options.TimerPoint, DBM.Bars.options.TimerX, DBM.Bars.options.TimerY)
							DBM.Bars.secAnchor:SetPoint(DBM.Bars.options.HugeTimerPoint, UIParent, DBM.Bars.options.HugeTimerPoint, DBM.Bars.options.HugeTimerX, DBM.Bars.options.HugeTimerY)
						end
					end
					
					-- DBM Text Settings
					DBM.Options.SpecialWarningX = db.realm.Dynamics[role].BOSSMODS.DBM.SPECIALWARNINGS.X
					DBM.Options.SpecialWarningY = db.realm.Dynamics[role].BOSSMODS.DBM.SPECIALWARNINGS.Y
					DBM.Options.RaidWarningPosition.X = db.realm.Dynamics[role].BOSSMODS.DBM.RAIDWARNINGS.X
					DBM.Options.RaidWarningPosition.Y = db.realm.Dynamics[role].BOSSMODS.DBM.RAIDWARNINGS.Y			
					-- Refresh Texts
					DBM:UpdateSpecialWarningOptions()
					RaidWarningFrame:SetPoint(DBM.Options.RaidWarningPosition.Point, UIParent, DBM.Options.RaidWarningPosition.Point, 
												DBM.Options.RaidWarningPosition.X, 
												DBM.Options.RaidWarningPosition.Y)
					
					-- DBM Windows Settings
					DBM.Options.RangeFrameX = db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECK.X
					DBM.Options.RangeFrameY = db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECK.Y
					DBM.Options.RangeFrameRadarX = db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECKRADAR.X
					DBM.Options.RangeFrameRadarY = db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECKRADAR.Y
					DBM.Options.HPFrameX = db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.X
					DBM.Options.HPFrameY = db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.Y
					DBM.Options.HealthFrameGrowUp = db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.GROWUPWARDS
					DBM.Options.HealthFrameWidth = tonumber(db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.WIDTH)
					DBM.Options.InfoFrameX = db.realm.Dynamics[role].BOSSMODS.DBM.INFOFRAME.X
					DBM.Options.InfoFrameY = db.realm.Dynamics[role].BOSSMODS.DBM.INFOFRAME.Y
					
					-- Refresh Windows
					if DBMRangeCheck then 
						DBMRangeCheck:SetPoint(DBM.Options.RangeFramePoint, UIParent, DBM.Options.RangeFramePoint, 
											DBM.Options.RangeFrameX, 
											DBM.Options.RangeFrameY)
					end						
					if DBMRangeCheckRadar then
						DBMRangeCheckRadar:SetPoint(DBM.Options.RangeFrameRadarPoint, UIParent, DBM.Options.RangeFrameRadarPoint, 
											DBM.Options.RangeFrameRadarX, 
											DBM.Options.RangeFrameRadarY)
					end
					if DBM.BossHealth then DBM.BossHealth:UpdateSettings() end
					if DBMInfoFrame then
						DBMInfoFrame:SetPoint(DBM.Options.InfoFramePoint, UIParent, DBM.Options.InfoFramePoint, 
									DBM.Options.InfoFrameX, 
									DBM.Options.InfoFrameY)
					end
					DBM.BossHealth:UpdateSettings()
				end
				--print("Dynamics : DBM Settings applyed for ".. db.profile.ActualRole)
			end
		end
		
		
		------------------------------------------- BigWigs Loaded ------------------------------------------
		if (db.profile.BossMods.BIGWIGS) then
			-- If Only BigWigs Loader is Up, Load BigWigs Core
			if not BigWigs then	
				LoadAddOn("BigWigs_Core") 
				-- if not BigWigs then return end
				-- BigWigs:Enable()
				-- for name, module in BigWigs:IterateBossModules() do
					-- if module:IsEnabled() then module:Reboot() end
				-- end
			end
			
			
			local role = db.profile.ActualRole
				
				-- APPLY the "AllROLES" BIGWIGS Settings
				if db.realm.Dynamics[role].BOSSMODS.BIGWIGS.defaults then 
					applyBIGWIGSDefaults()	
				end
				if not (role == "") then
					if BigWigs.modules.Plugins.modules.Colors then
						if db.realm.Dynamics[role].BOSSMODS.BIGWIGS.CLASSCOLOREDBARS then
							BigWigs.modules.Plugins.modules.Colors.db.profile.barEmphasized.BigWigs_Plugins_Colors.default = { endClasscolor[1], endClasscolor[2], endClasscolor[3], 1 } -- RGB + trasparenza (METTERE CLASS COLOR REALI
							BigWigs.modules.Plugins.modules.Colors.db.profile.barColor.BigWigs_Plugins_Colors.default = { startClasscolor[1], startClasscolor[2], startClasscolor[3], 1 } -- RGB + trasparenza (METTERE CLASS COLOR REALI ma + CHIARI!!!!)
							BigWigs.modules.Plugins.modules.Colors.db.profile.barText.BigWigs_Plugins_Colors.default = { 1, 1, 1 } --Bianco
							BigWigs.modules.Plugins.modules.Colors.db.profile.barBackground.BigWigs_Plugins_Colors.default = { 0.5, 0.5, 0.5, 0.3 } -- Grigio
						else
							BigWigs.modules.Plugins.modules.Colors.db.profile.barEmphasized.BigWigs_Plugins_Colors.default = { 1,0,0, 1 } -- RGB + trasparenza (METTERE CLASS COLOR REALI
							BigWigs.modules.Plugins.modules.Colors.db.profile.barColor.BigWigs_Plugins_Colors.default = { 0, 0, 1, 1 } -- RGB + trasparenza (METTERE CLASS COLOR REALI ma + CHIARI!!!!)
							BigWigs.modules.Plugins.modules.Colors.db.profile.barText.BigWigs_Plugins_Colors.default = { 1, 1, 1 } --Bianco
							BigWigs.modules.Plugins.modules.Colors.db.profile.barBackground.BigWigs_Plugins_Colors.default = { 0.5, 0.5, 0.5, 0.3 } -- Grigio
						end
					end
					-- BIGWIGS Bars Settings
					if BigWigs.modules.Plugins.modules.Bars then
						BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsAnchor_x = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.X 
						BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsAnchor_y = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.Y 
						BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsAnchor_width = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.WIDTH
						BigWigs.modules.Plugins.modules.Bars.db.profile.scale = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.SCALE
						BigWigs.modules.Plugins.modules.Bars.db.profile.growup = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.GROWUP
						
						BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsEmphasizeAnchor_x = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.X 
						BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsEmphasizeAnchor_y = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.Y 
						BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsEmphasizeAnchor_width = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.WIDTH
						BigWigs.modules.Plugins.modules.Bars.db.profile.emphasizeScale = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.SCALE
						BigWigs.modules.Plugins.modules.Bars.db.profile.emphasizeGrowup = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.GROWUP
					end
					-- Refresh BIGWIGS Bars 
					if BigWigsAnchor then BigWigsAnchor:RefixPosition() end
					if BigWigsEmphasizeAnchor then BigWigsEmphasizeAnchor:RefixPosition() end
					
					-- BIGWIGS Text Settings
					if BigWigs.modules.Plugins.modules.Messages then
						BigWigs.modules.Plugins.modules.Messages.db.profile.BWMessageAnchor_x = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALMESSAGES.X 
						BigWigs.modules.Plugins.modules.Messages.db.profile.BWMessageAnchor_y = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALMESSAGES.Y 
						BigWigs.modules.Plugins.modules.Messages.db.profile.BWEmphasizeMessageAnchor_x = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.X 
						BigWigs.modules.Plugins.modules.Messages.db.profile.BWEmphasizeMessageAnchor_y = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.Y 
					end
					-- Refresh BIGWIGS Texts
					if BWMessageAnchor then BWMessageAnchor:RefixPosition() end
					if BWEmphasizeMessageAnchor then BWEmphasizeMessageAnchor:RefixPosition() end
					
					-- BIGWIGS Windows Settings
					if BigWigs.modules.Plugins.modules.Proximity then
						BigWigs.modules.Plugins.modules.Proximity.db.profile.posx = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.X 
						BigWigs.modules.Plugins.modules.Proximity.db.profile.posy = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.Y 
						BigWigs.modules.Plugins.modules.Proximity.db.profile.width = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.WIDTH 
						BigWigs.modules.Plugins.modules.Proximity.db.profile.height = db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.HEIGHT 
					end
					-- Refresh BIGWIGS Windows
					if BigWigs.modules.Plugins.modules.Proximity then updateBIGWIGSProximityProfile() end--BigWigs.modules.Plugins.modules.Proximity:updateProfile() end						
					
				
				end -- End ROLE Empty Test
													
		end
			
		------------------------------------------- DXE Loaded ------------------------------------------
		if (db.profile.BossMods.DXE) then
			-- If Only DXE Loader is Up, Load DXE Core
			if not select(4,GetAddOnInfo("DXE")) then EnableAddOn("DXE") end 
			if not DXE then	LoadAddOn("DXE") end
			
			local role = db.profile.ActualRole
				
				-- APPLY the "AllROLES" BIGWIGS Settings
				if db.realm.Dynamics[role].BOSSMODS.DXE.defaults then 
					applyDXEDefaults()	
				end
				if not (role == "") then
					
					if db.realm.Dynamics[role].BOSSMODS.DXE.CLASSCOLOREDBARS then 
						DXE.db.profile.Globals.BorderColor = { endClasscolor[1], endClasscolor[2], endClasscolor[3], 1 } --  <<--- CLASS COLORED   (DXE.db.profile.Globals.BorderColor[1] -2-3-4 )
						DXE.db.profile.Globals.BackgroundColor = { startClasscolor[1], startClasscolor[2], startClasscolor[3], 0.7 }  --<<--- CLASS COLORED + chiaro
						DXE.db.profile.Pane.FontColor  = {1, 1, 1, 1}
						DXE.db.profile.Pane.NeutralColor = { endClasscolor[1], endClasscolor[2], endClasscolor[3], 1 }
					else
						DXE.db.profile.Globals.BorderColor = { 0,0,0,0.5 } --  <<--- CLASS COLORED   (DXE.db.profile.Globals.BorderColor[1] -2-3-4 )
						DXE.db.profile.Globals.BackgroundColor = { 0.65, 0.65, 0.65, 0.8 }  --<<--- CLASS COLORED + chiaro
						DXE.db.profile.Pane.FontColor  = {1, 1, 1, 1}
						DXE.db.profile.Pane.NeutralColor = { 0, 0, 1, 1 }
					end
					-- DXE Bars Settings
					DXE.Alerts.db.profile.TopBarWidth = db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.WIDTH 
					DXE.Alerts.db.profile.TopGrowth = db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.GROWTH     
					DXE.Alerts.db.profile.TopTextWidth = db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.TEXTWIDTH
					DXE.db.profile.Positions.DXEAlertsTopStackAnchor.xOfs =  db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.X
					DXE.db.profile.Positions.DXEAlertsTopStackAnchor.yOfs =  db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.Y
					
					DXE.Alerts.db.profile.CenterBarWidth =  db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.WIDTH
					DXE.Alerts.db.profile.CenterGrowth =   db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.GROWTH 
					DXE.Alerts.db.profile.CenterTextWidth = db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.TEXTWIDTH 
					DXE.db.profile.Positions.DXEAlertsCenterStackAnchor.xOfs = db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.X 
					DXE.db.profile.Positions.DXEAlertsCenterStackAnchor.yOfs = db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.Y 
	
					DXE.Alerts.db.profile.WarningGrowth =  db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.GROWTH       
					DXE.Alerts.db.profile.WarningScale = db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.SCALE 
					DXE.Alerts.db.profile.WarningBarWidth = db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.WIDTH 
					DXE.Alerts.db.profile.WarningTextWidth = db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.TEXTWIDTH 
					DXE.db.profile.Positions.DXEAlertsWarningStackAnchor.xOfs = db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.X 
					DXE.db.profile.Positions.DXEAlertsWarningStackAnchor.yOfs = db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.Y  
					
					-- DXE Bars Update
					DXE.Alerts:RefreshBars()
					DXE:LoadPosition("DXEAlertsTopStackAnchor")
					DXE:LoadPosition("DXEAlertsCenterStackAnchor")
					DXE:LoadPosition("DXEAlertsWarningStackAnchor")
					
					-- DXE Windows Settings
					if DXE.db.profile.Positions.DXEWindowProximity then
						DXE.db.profile.Positions.DXEWindowProximity.xOfs = db.realm.Dynamics[role].BOSSMODS.DXE.PROXIMITY.X
						DXE.db.profile.Positions.DXEWindowProximity.yOfs = db.realm.Dynamics[role].BOSSMODS.DXE.PROXIMITY.Y
						DXE.db.profile.Positions.DXEWindowAlternatePower.xOfs = db.realm.Dynamics[role].BOSSMODS.DXE.ALTERNATEPOWER.X
						DXE.db.profile.Positions.DXEWindowAlternatePower.yOfs = db.realm.Dynamics[role].BOSSMODS.DXE.ALTERNATEPOWER.Y
						DXE.db.profile.Positions.DXEArrowsAnchor1.xOfs = db.realm.Dynamics[role].BOSSMODS.DXE.ARROW1.X
						DXE.db.profile.Positions.DXEArrowsAnchor1.yOfs = db.realm.Dynamics[role].BOSSMODS.DXE.ARROW1.Y
						DXE.db.profile.Positions.DXEArrowsAnchor2.xOfs = db.realm.Dynamics[role].BOSSMODS.DXE.ARROW2.X
						DXE.db.profile.Positions.DXEArrowsAnchor2.yOfs = db.realm.Dynamics[role].BOSSMODS.DXE.ARROW2.Y
						DXE.db.profile.Positions.DXEArrowsAnchor3.xOfs = db.realm.Dynamics[role].BOSSMODS.DXE.ARROW3.X
						DXE.db.profile.Positions.DXEArrowsAnchor3.yOfs = db.realm.Dynamics[role].BOSSMODS.DXE.ARROW3.Y
					end
					-- DXE Windows Update
					DXE:LoadPosition("DXEWindowProximity")
					DXE:LoadPosition("DXEWindowAlternatePower")
					DXE:LoadPosition("DXEArrowsAnchor1")
					DXE:LoadPosition("DXEArrowsAnchor2")
					DXE:LoadPosition("DXEArrowsAnchor3")
					
					DXE:UpdateProximitySettings()
					DXE:UpdateAlternatePowerSettings()
					DXE:SkinPane()
					
					-- INSERT and IF to change profile only when Pane need to be reloaded!!!! and not always!
					local current = DXE.db:GetCurrentProfile()
					local foundDynamicsProfile = false
					local temp =""
					for k,v in pairs(DXE.db.profiles) do 
						if (not k == current) and (not k == "Dynamics Default") then
							temp = k
						end
						if k== "Dynamics Default" then current = k end
					end
					DXE.db:SetProfile(temp)
					DXE.db:SetProfile(current)
					
				end -- ROLE NOT EMPTY IF 									
		end
 
	--print("Dynamics : Bossmods Settings applyed for ".. db.profile.ActualRole)		
	end
	
end -- 0%
function module:dynamicsUpdateBartender() --Fired from Events
	if db.profile.ManageBartender then  -- BarTender Setting
		local _,class = UnitClass("player")
		if db.realm.Dynamics[db.profile.ActualRole] then
			local r = db.realm.Dynamics[db.profile.ActualRole]
			if r.BT4 then 
				if r.BT4[class] then
					if not (r.BT4[class] == "-") then
						Bartender4.db:SetProfile(r.BT4[class])
						--print("Dynamics : " ..r.BT4[class] .." Profile applyed for ".. class .." ".. db.profile.ActualRole .." Role.")
					else
						print("No BT profile selected for ".. class.. " "..db.profile.ActualRole .." Role.")
					end
				end
			end
			
		end	
		--print("Dynamics : Buttons Settings applyed for ".. db.profile.ActualRole)		
	else --print("Non Gestisco BarTender")
	end
		
end -- Done
function module:dynamicsUpdateRaidFrames() --Fired from Events
		if db.profile.ManageRaidFrames then  -- RaidFrames Setting
		local _,class = UnitClass("player")
		
		local raidKey =  module:getRaidKey(module:getRaidDimension())
		local rm = module:readRaidManager()
		if db.realm.Dynamics[db.profile.ActualRole] then
			local r = db.realm.Dynamics[db.profile.ActualRole]
			if r["RAIDFRAMES"][raidKey] then 
				if r["RAIDFRAMES"][raidKey][class][string.upper(module:readRaidManager())] then
					local newProfile = r["RAIDFRAMES"][raidKey][class][string.upper(rm)]
					if not (newProfile == "-") then
						if string.upper(rm) == "GRID" then
							local current = Grid.db:GetCurrentProfile()
							local gl = Grid:GetModule("GridLayout")
							local gf = Grid:GetModule("GridFrame")
							if not (current == newProfile) then
								Grid.db:SetProfile(newProfile)
								local actualLayout = Grid.modules.GridLayout.db.profile.layout
								local test = ""
								for k,v in pairs(Grid.modules.GridLayout.options.args.sololayout.values) do
									if not (k == actualLayout) and test == "" then test = k end
								end
								Grid.modules.GridLayout:LoadLayout(test)
								Grid.modules.GridLayout:LoadLayout(actualLayout)
								gf:ResizeAllFrames()
								gl:ReloadLayout()
							end
						else
						--	print("|CFF99FF00Dynamics |r: Not Grid UnitFrame Managers is not yet implemented.")
						
						end
						
					else
						if string.upper(rm) == "VUHDO" then
							LUI:Module("Frames"):SetNaviAlpha("Raid", 1)
							LUI:Module("Panels").db.Raid.IsShown = true
							--print ("Test Dynamics Message: Rilevato VuhDO")
						end
						
						--print("|CFF99FF00Dynamics |r: No "..rm.." profile selected for ".. class.. " "..db.profile.ActualRole .." Role in "..raidKey.." Setup.")
					end
				end
			end
			
		end	
		--print("Dynamics : Buttons Settings applyed for ".. db.profile.ActualRole)		
	else 
	end
end -- 33%
function module:dynamicsUpdateForte() --Fired from Events
		
	if db.profile.ManageForte then  -- Forte Cooldown Settings
		if FW then
		if db.realm.Dynamics[db.profile.ActualRole] then
			local r = db.realm.Dynamics[db.profile.ActualRole]
			if r["FORTE"]["COOLDOWN"] then 
				-- Cooldown Bar Settings
				if (Forte.db.profile.Cooldown.Enable) then
					local x = r["FORTE"]["COOLDOWN"].X
					local y = r["FORTE"]["COOLDOWN"].Y
					local err = false
					Forte.db.profile.Cooldown.PaddingX = x
					Forte.db.profile.Cooldown.PaddingY = y
					if FW.Settings then
						FW.Settings.Cooldown.Instances[1].Width = r["FORTE"]["COOLDOWN"].WIDTH
						FW.Settings.Cooldown.Instances[1].Height = r["FORTE"]["COOLDOWN"].HEIGHT
						applyFORTEDefaults()
						LUI.modules.Forte.SetPosForteCooldown()
					
					else 
						err = true
						print("|CFF99FF00Dynamics |r: Error applying Forte Cooldown Settings for |CFF9999FF".. db.profile.ActualRole .."|r Role. (1858)")
					end
					if err then 
						if FW.Settings then
							FW.Settings.Cooldown.Instances[1].Width = r["FORTE"]["COOLDOWN"].WIDTH
							FW.Settings.Cooldown.Instances[1].Height = r["FORTE"]["COOLDOWN"].HEIGHT
							LUI.modules.Forte.SetPosForteCooldown()
						end
					end
				end
				-- LUI Top Texture Settings
				if (LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].TopTexture.Enable) then
					local x = r["FORTE"]["TOPTEXTURE"].X
					local y = r["FORTE"]["TOPTEXTURE"].Y
					local h = r["FORTE"]["TOPTEXTURE"].AnimationHeight
					local alpha = r["FORTE"]["TOPTEXTURE"].Alpha
					LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].TopTexture.X = x
					LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].TopTexture.Y = y
					LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].TopTexture.AnimationHeight = h
					LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].TopTexture.Alpha = alpha
					if (LUIBarsTopBG) then
						LUI.modules.Bars:Refresh()
					end
				end
				-- LUI Bottom Texture Settings
				if (LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].BottomTexture.Enable) then
					local x = r["FORTE"]["BOTTOMTEXTURE"].X
					local y = r["FORTE"]["BOTTOMTEXTURE"].Y
					local alpha = r["FORTE"]["BOTTOMTEXTURE"].Alpha
					LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].BottomTexture.X = x
					LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].BottomTexture.Y = y
					LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].BottomTexture.Alpha = alpha
					if (LUIBarsTopBG) then
						LUI.modules.Bars:Refresh()
					end
				end
				-- Forte Cooldown Splash Settings
				if (LUI.modules.Forte.db.profile.Splash.Enable) and FW and FW.Settings then
				    if FW then
						if FW.Settings then
							-- Code to manage Splash positioning.
							LUI.modules.Forte.db.profile.Splash.PaddingX =  r.FORTE.COOLDOWNSPLASH.X
							LUI.modules.Forte.db.profile.Splash.PaddingY = r.FORTE.COOLDOWNSPLASH.Y
							FW.Settings.Splash.Instances[1].Scale = r.FORTE.COOLDOWNSPLASH.SCALE
							LUI.modules.Forte:SetPosForteSplash()
							FW:RefreshFrames()
						end
				    end
				end
				-- Forte Cooldown Player Timer
				if ( r.FORTE.PLAYER.Enable) then
					if FW then
						if FW.Settings then
							-- Code to manage Player Timers positioning.
							LUI.modules.Forte.db.profile.Player.Enable =  r.FORTE.PLAYER.Enable
							LUI.modules.Forte.db.profile.Player.Lock =  r.FORTE.PLAYER.Enable
							LUI.modules.Forte.db.profile.Player.PaddingX =  r.FORTE.PLAYER.X
							LUI.modules.Forte.db.profile.Player.PaddingY = r.FORTE.PLAYER.Y
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Player",FW.Settings.Timer,1)].alpha = tonumber(r.FORTE.PLAYER.ALPHA)
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Player",FW.Settings.Timer,1)].Font[1] = "Interface\\AddOns\\LUI\\media\\fonts\Prototype.ttf"
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Player",FW.Settings.Timer,1)].Expand = r.FORTE.PLAYER.EXPANDUP
						end
				   end
				 else
				   if FW.Settings then
						LUI.modules.Forte.db.profile.Player.Enable =   r.FORTE.PLAYER.Enable
						LUI.modules.Forte.db.profile.Player.Lock =   r.FORTE.PLAYER.Enable
				    end
				end
				-- Forte Cooldown Target Timer
				if ( r.FORTE.TARGET.Enable) then
					if FW then
						if FW.Settings then
							-- Code to manage Player Timers positioning.
							LUI.modules.Forte.db.profile.Target.Enable =  r.FORTE.TARGET.Enable
							LUI.modules.Forte.db.profile.Target.Lock =  r.FORTE.TARGET.Enable
							LUI.modules.Forte.db.profile.Target.PaddingX =  r.FORTE.TARGET.X
							LUI.modules.Forte.db.profile.Target.PaddingY = r.FORTE.TARGET.Y
							
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Target",FW.Settings.Timer,1)].alpha = tonumber(r.FORTE.TARGET.ALPHA) 
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Target",FW.Settings.Timer,1)].Font[1] = "Interface\\AddOns\\LUI\\media\\fonts\Prototype.ttf"
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Target",FW.Settings.Timer,1)].Expand = r.FORTE.TARGET.EXPANDUP
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Target",FW.Settings.Timer,1)].Width = tonumber(r.FORTE.TARGET.WIDTH) 
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Target",FW.Settings.Timer,1)].Height = tonumber(r.FORTE.TARGET.HEIGHT) 
							
							if (r.FORTE.TARGET.RAIDDEBUFFS == true) then
								FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Target",FW.Settings.Timer,1)].RaidDebuffs =  false
							else 
								FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Target",FW.Settings.Timer,1)].RaidDebuffs =  true
							end
						end
				   end
				 else
				   if FW.Settings then
						LUI.modules.Forte.db.profile.Target.Enable =   r.FORTE.TARGET.Enable
						LUI.modules.Forte.db.profile.Target.Lock =   r.FORTE.TARGET.Enable
				    end
				end
				-- Forte Cooldown Focus Timer
				if ( r.FORTE.FOCUS.Enable) then
					if FW then
						if FW.Settings then
							-- Code to manage Player Timers positioning.
							LUI.modules.Forte.db.profile.Focus.Enable =  r.FORTE.FOCUS.Enable
							LUI.modules.Forte.db.profile.Focus.Lock =  r.FORTE.FOCUS.Enable
							LUI.modules.Forte.db.profile.Focus.PaddingX =  r.FORTE.FOCUS.X
							LUI.modules.Forte.db.profile.Focus.PaddingY = r.FORTE.FOCUS.Y
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Focus",FW.Settings.Timer,1)].alpha = tonumber(r.FORTE.FOCUS.ALPHA)
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Focus",FW.Settings.Timer,1)].Font[1] = "Interface\\AddOns\\LUI\\media\\fonts\Prototype.ttf"
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Focus",FW.Settings.Timer,1)].Expand = r.FORTE.FOCUS.EXPANDUP
							if (r.FORTE.FOCUS.RAIDDEBUFFS == true) then
								FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Focus",FW.Settings.Timer,1)].RaidDebuffs =  false
							else 
								FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Focus",FW.Settings.Timer,1)].RaidDebuffs =  true
							end
						end
				   end
				 else
				   if FW.Settings then
						LUI.modules.Forte.db.profile.Focus.Enable =   r.FORTE.FOCUS.Enable
						LUI.modules.Forte.db.profile.Focus.Lock =   r.FORTE.FOCUS.Enable
				    end
				end
				-- Forte Cooldown Compact Timer
				if ( r.FORTE.COMPACT.Enable) then
					if FW then
						if FW.Settings then
							-- Code to manage Player Timers positioning.
							LUI.modules.Forte.db.profile.Compact.Enable =  r.FORTE.COMPACT.Enable
							LUI.modules.Forte.db.profile.Compact.Lock =  r.FORTE.COMPACT.Enable
							LUI.modules.Forte.db.profile.Compact.PaddingX =  r.FORTE.COMPACT.X
							LUI.modules.Forte.db.profile.Compact.PaddingY = r.FORTE.COMPACT.Y
							LUI.modules.Forte.db.profile.Compact.Location = r.FORTE.COMPACT.Anchor ---or "LEFT"
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Compact",FW.Settings.Timer,1)].alpha = tonumber(r.FORTE.COMPACT.ALPHA)
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Compact",FW.Settings.Timer,1)].Font[1] = "Interface\\AddOns\\LUI\\media\\fonts\Prototype.ttf"
							FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Compact",FW.Settings.Timer,1)].Expand = r.FORTE.COMPACT.EXPANDUP
							if (r.FORTE.COMPACT.RAIDDEBUFFS == true) then
								FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Compact",FW.Settings.Timer,1)].RaidDebuffs =  false
							else 
								FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Compact",FW.Settings.Timer,1)].RaidDebuffs =  true
							end
						end
				   end
				 else
				   if FW.Settings then
						LUI.modules.Forte.db.profile.Compact.Enable =   r.FORTE.COMPACT.Enable
						LUI.modules.Forte.db.profile.Compact.Lock =   r.FORTE.COMPACT.Enable
				    end
				end
			end
			if FW.Settings then
				LUI.modules.Forte:SetForte()
				FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Target",FW.Settings.Timer,1)].Width = tonumber(r.FORTE.TARGET.WIDTH) 
				FW.Frames["FX_Timer2"]:Update();			
				LUI.modules.Forte.SetPosForteCooldown() 
				LUI.modules.Bars:Refresh()
			end
		end						
		end
		
			
	end
	
end -- 70%
function module:dynamicsUpdateChat() --Fired from Events
	if db.profile.ManageChat then  -- Chat Windows Settings
	local role = db.profile.ActualRole
	-- SET THE LEFT SIDE FRAME :
	LUI.modules.Chat.db.profile.x = db.realm.Dynamics[role].CHAT.LEFTCHAT.X
	LUI.modules.Chat.db.profile.y = db.realm.Dynamics[role].CHAT.LEFTCHAT.Y
	LUI.modules.Chat.db.profile.width = db.realm.Dynamics[role].CHAT.LEFTCHAT.WIDTH
	LUI.modules.Chat.db.profile.height = db.realm.Dynamics[role].CHAT.LEFTCHAT.HEIGHT
	LUI.modules.Chat:Refresh()
	
	-- LEFT Chat Settings
	for i=1, 10 do 
		local f = _G["ChatFrame"..i]
		local t = _G["ChatFrame"..i.."Tab"]
				
		if (db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS["FRAME"..i]) then
			local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
			
			FCF_SetLocked( f, nil );
			FCF_UnDockFrame( f );
			
			f:SetHeight(db.realm.Dynamics[role].CHAT.LEFTCHAT.HEIGHT)
			f:SetWidth(db.realm.Dynamics[role].CHAT.LEFTCHAT.WIDTH)
			f:ClearAllPoints()
			f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.realm.Dynamics[role].CHAT.LEFTCHAT.X, db.realm.Dynamics[role].CHAT.LEFTCHAT.Y)
			f:SetUserPlaced( true );
			FCF_SetLocked( f, 1 );
			FCF_DockFrame( f, #FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)+1, true )
			
			if not f:IsShown() then
				f:Show();
				t:Show();
				SetChatWindowShown(f:GetID(), 1);
			end
		else
			FCF_SetLocked( f, nil );
			FCF_UnDockFrame( f );
			if  f:IsShown() then
				f:Hide();
				t:Hide();
				SetChatWindowShown(f:GetID(), nil);
			end
		end
	end
	-- RIGHT CHat Settings
	-- LUI.modules.Chat.db.profile.Chat.SecondChatFrame = db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.ENABLED
	-- if LUI.modules.Chat.db.profile.Chat.SecondChatFrame then 
		-- for i=1, 10 do 
			-- local f = _G["ChatFrame"..i]
			-- local t = _G["ChatFrame"..i.."Tab"]
			-- if (db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS["FRAME"..i]) then
				-- FCF_SetLocked( f, nil );
				-- FCF_UnDockFrame( f );
				-- 
				-- f:SetHeight(db.realm.Dynamics[role].CHAT.RIGHTCHAT.HEIGHT)
				-- f:SetWidth(db.realm.Dynamics[role].CHAT.RIGHTCHAT.WIDTH)
				-- f:ClearAllPoints()
				-- f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.realm.Dynamics[role].CHAT.RIGHTCHAT.X, db.realm.Dynamics[role].CHAT.RIGHTCHAT.Y)
				-- 
				-- f:SetUserPlaced( true );
				-- FCF_SetLocked( f, 1 );
				-- FCF_UnDockFrame( f );
				-- 
				-- if not f:IsShown() then
					-- f:Show();
					-- t:Hide(); 
					-- SetChatWindowShown(f:GetID(), 1);
				-- end
			-- end		
		-- end
		-- LUI.modules.Panels:AlphaIn("Chat")
	-- else
		-- LUI.modules.Panels:AlphaIn("Chat")
	-- end
	
	-- LUI Chat Backgrounds Repositioning
	local repositionLuiBackGrounds = false
	-- 2.0
	if not (LUI.modules.Panels.db.Chat.OffsetX == db.realm.Dynamics[role].CHAT.LEFTCHAT.LUITEXTURE.X) then repositionLuiBackGrounds = true end
	if not (LUI.modules.Panels.db.Chat.OffsetY == db.realm.Dynamics[role].CHAT.LEFTCHAT.LUITEXTURE.Y) then repositionLuiBackGrounds = true end
	--if not (LUI.modules.Panels.db.Chat2.OffsetX == db.realm.Dynamics[role].CHAT.RIGHTCHAT.LUITEXTURE.X) then repositionLuiBackGrounds = true end
	--if not (LUI.modules.Panels.db.Chat2.OffsetY == db.realm.Dynamics[role].CHAT.RIGHTCHAT.LUITEXTURE.Y) then repositionLuiBackGrounds = true end
	if repositionLuiBackGrounds then 
		LUI.modules.Panels.db.Chat.OffsetX = db.realm.Dynamics[role].CHAT.LEFTCHAT.LUITEXTURE.X
		LUI.modules.Panels.db.Chat.OffsetY = db.realm.Dynamics[role].CHAT.LEFTCHAT.LUITEXTURE.Y
		--LUI.modules.Panels.db.Chat2.OffsetX = db.realm.Dynamics[role].CHAT.RIGHTCHAT.LUITEXTURE.X
		--LUI.modules.Panels.db.Chat2.OffsetY = db.realm.Dynamics[role].CHAT.RIGHTCHAT.LUITEXTURE.Y
		LUI.modules.Panels:Refresh()
	end
	
	
	-- General Chat Settings
	--if (LUI.db.profile.Chat.Size == db.realm.Dynamics[role].CHAT.fontSize) then
		LUI.modules.Chat.db.profile.General.Font.Size = db.realm.Dynamics[role].CHAT.fontSize
		LUI.modules.Chat.db.profile.General.Font.Flag = "OUTLINE"
		for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i]:SetFont(Media:Fetch("font",LUI.modules.Chat.db.profile.General.Font.Font), LUI.modules.Chat.db.profile.General.Font.Size, LUI.modules.Chat.db.profile.General.Font.Flag)
		_G["ChatFrame"..i.."EditBox"]:SetFont(Media:Fetch("font",LUI.modules.Chat.db.profile.General.Font.Font), LUI.modules.Chat.db.profile.General.Font.Size, LUI.modules.Chat.db.profile.General.Font.Flag)
		_G["ChatFrame"..i.."EditBox"].header:SetFont(Media:Fetch("font",LUI.modules.Chat.db.profile.General.Font.Font), LUI.modules.Chat.db.profile.General.Font.Size, LUI.modules.Chat.db.profile.General.Font.Flag)
		end
	--end
	
	-- Fix per l'errore sul ClickTab
	for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G['ChatFrame'..i]
        cf.oldAlpha = cf.oldAlpha or 0 -- Fix 'max-bug' in FCF.lua
        local cfname, _, _, _, _, _, shown, _, _, _ = GetChatWindowInfo(i)
        if(cfname == iname) then
            ifound = true
            break
        end
    end
    
	if ChatFrame1Tab then
		ChatFrame1Tab:Click()
	end
	
	-- ChatFrames Names
	--if not (ChatFrame1.name == db.realm.Dynamics[role].CHAT.CHATNAMES.FRAME1) then ChatFrame1.name = db.realm.Dynamics[role].CHAT.CHATNAMES.FRAME1 end
	
	-- PARAMETRI LUI : 
	-- LUI.modules.Chat.db.profile.Chat.SecondChatFrame = true
	-- LUI.modules.Chat.db.profile.Chat.SecondChatAmchor = "ChatFrame2"
	-- LUI.modules.Chat.db.profile.Chat.PreventDrag = true
	-- LUI.modules.Chat.db.profile.Chat.Enable = true
	
		--print("Dynamics : Chat Settings applyed for ".. role)		
	end	
end -- 0%             <------------------
function module:dynamicsUpdateMSBT() --Fired from Events
	if db.profile.ManageMSBT then  -- MikBarScrollingText Setting
		local _,class = UnitClass("player")
		if db.realm.Dynamics[db.profile.ActualRole] and MikSBT then
			local r = db.realm.Dynamics[db.profile.ActualRole]
			if r.MSBT then 
				if r.MSBT[class] then
					if not (r.MSBT[class] == "-") then
						MikSBT.Profiles.SelectProfile(r.MSBT[class])
						db.profile.currentMSBTProfile= r.MSBT[class] 
					else
						print("No MSBT profile selected for ".. class.. " "..db.profile.ActualRole .." Role.")
					end
				end
			end
			
		end	
		--print("Dynamics : Buttons Settings applyed for ".. db.profile.ActualRole)		
	else 
	end
end -- Done
function module:dynamicsUpdateSkullMe() --Fired from Events
	if db.profile.ManageSkullMe then  -- SkullMe Settings
		if IsAddOnLoaded("Skull Me") then 
			if SkullMe.db then
				if db.profile.ActualRole == "Tank" then
	 				SkullMe.db.char["enabled"]=true	 
	 			else
	 				SkullMe.db.char["enabled"]=false	 
	 			end
	 		else
	 			--print("Dynamics : Error Setting SkullMe")
	 		end
	--		print("Dynamics : SkullMe Settings applyed for ".. db.profile.ActualRole)		
		end
	end	
end -- 100%
function module:dynamicsUpdateSRTI() --Fired from Events
	if db.profile.ManageSRTI then  -- SRTI Settings
		if IsAddOnLoaded("SimpleRaidTargetIcons") then
			SRTISaved.singlehover = true
			SRTISaved.doublehover = true
		end
		--print("Dynamics : SRTI Settings applyed for ".. db.profile.ActualRole)		
	end	
end -- 100%
function module:dynamicsUpdateMaxCameraDistance() --Fired from Events
	if db.profile.ManageMaxCameraDistance then  -- MaxCameraDistance Settings
		SetCVar("cameradistancemaxfactor","5")
		SetCVar("cameradistancemax","12.5")
		--print("Dynamics : MaxCameraDistance Settings applyed for ".. db.profile.ActualRole)		
	end	
end -- 100%
function module:dynamicsUpdateGarbageCollection(message) --Fired from Events
	if db.profile.ManageGarbageCollection then  -- GarbageCollection Settings
		local collected, deltamem = 0, 0
		collected = collectgarbage('count')
		collectgarbage("collect")
		deltamem = collected - collectgarbage('count')
		if message == nil then	
			print(format("|CFF99FF00Dynamics |r: |cffC3771AMemory|r Collected: |cff06ddfa%s|r", formatMem(deltamem, true)))
		end
		--print("Dynamics : MaxCameraDistance Settings applyed for ".. db.profile.ActualRole)		
	end	
end -- 100%
function module:dynamicsUpdateAutoRess() --Fired from Events
	if db.profile.ManageAutoRess then  -- AutoRess Settings
	
		--print("Dynamics : AutoRess Settings applyed for ".. db.profile.ActualRole)		
	end	
end ---- 80%
function module:dynamicsUpdateMinimap() --Fired from Events
	if db.profile.ManageMinimap then  -- Minimap Settings
		if(MinimapAlphaOut) then
			MinimapAlphaOut:Show()
			--LUI.db.profile.Frames.IsMinimapShown = false  2.0
		end
		--print("Dynamics : Minimap Settings applyed for ".. db.profile.ActualRole)		
	end	
end -- 100%
function module:dynamicsUpdateBagnon() --Fired from Events
	if db.profile.ManageBagnon then  -- Bagnon Settings
		if IsAddOnLoaded("Bagnon") then
			local _, class = UnitClass("player")
			local classColorArray = {
									["WARRIOR"] = {1, 0.78, 0.55},
									["PRIEST"] = {0.9, 0.9, 0.9},
									["DRUID"] = {1, 0.44, 0.15},
									["HUNTER"] = {0.22, 0.91, 0.18},
									["MAGE"] = {0.12, 0.58, 0.89},
									["PALADIN"] = {0.96, 0.21, 0.73},
									["SHAMAN"] = {0.04, 0.39, 0.98},
									["WARLOCK"] = {0.57, 0.22, 1},
									["ROGUE"] = {0.95, 0.86, 0.16},
									["DEATH KNIGHT"] = {0.80, 0.1, 0.1},
									["DEATHKNIGHT"] = {0.80, 0.1, 0.1},
									["MONK"] = {0.33, 0.54, 0.52},
			}
			local classcolor = classColorArray[class]

			Bagnon.FrameSettings:Get('inventory'):SetColor(classcolor[1], classcolor[2],classcolor[3], 0.5)
			Bagnon.FrameSettings:Get('bank'):SetColor(classcolor[1], classcolor[2],classcolor[3], 0.5)
		end
		--print("Dynamics : Bagnon Settings applyed for ".. db.profile.ActualRole)		
	end
		
end -- 100%
function module:dynamicsUpdateAutoLUIProfile() --Fired from Events
	if db.profile.ManageLUIProfile then  -- AutoLUI Profile Settings
	
		--print("Dynamics : AutoLUI Profile Settings applyed for ".. db.profile.ActualRole)		
	end
		
end --0%
function module:dynamicsUpdateSkada() --Fired from Events
	--print("Ingresso UpdateSkada") -- COMMENTO DEBUG
	if db.profile.ManageSkada then  --
		local w1 = ""
		local w2 = ""
		local w3 = ""
		
		if Skada then
			local windows = Skada:GetWindows()
			if windows then
				if windows[1] then w1 = windows[1].db.name end
				if windows[2] then w2 = windows[2].db.name end
				if windows[3] then w3 = windows[3].db.name end
			end
		end
		--print (w1 .. " - " .. w2 .. " - " .. w3 .. " - " ) -- COMMENTO DEBUG
		if not (w1 == "" or w1 == nil) then
			local f = _G["SkadaBarWindow"..w1]
			if f  then
				--f:Hide()
				local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
				local x = db.realm.Dynamics[db.profile.ActualRole].UIENANCHEMENTS.SKADA.WINDOWS1.X
				local y = db.realm.Dynamics[db.profile.ActualRole].UIENANCHEMENTS.SKADA.WINDOWS1.Y
				f:ClearAllPoints()
				--f:Show()
				f:SetPoint(point,relativeTo,relativePoint,x,y)
				Skada.db.profile.windows[1].x = x
				Skada.db.profile.windows[1].y = y
				LUI.modules.Panels.db.Dps.OffsetX = db.realm.Dynamics[db.profile.ActualRole].UIENANCHEMENTS.SKADA.WINDOWS1.BACKX
				LUI.modules.Panels.db.Dps.OffsetY = db.realm.Dynamics[db.profile.ActualRole].UIENANCHEMENTS.SKADA.WINDOWS1.BACKY
				--LUI.modules.Panels:SetDpsBackground()
				-- /run for k,v in pairs (LUI.modules.Panels.db.Tps) do print (k.. " - " .. tostring(v)) end
				-- LUI.modules.Panels:Refresh()
				f:Show()
				
			end	
		end
		if not (w2 == "" or w2 == nil) then
			local f = _G["SkadaBarWindow"..w2]
			if  f  then
				local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
				local x = db.realm.Dynamics[db.profile.ActualRole].UIENANCHEMENTS.SKADA.WINDOWS2.X
				local y = db.realm.Dynamics[db.profile.ActualRole].UIENANCHEMENTS.SKADA.WINDOWS2.Y
				f:ClearAllPoints()
				f:SetPoint(point,relativeTo,relativePoint,x,y)
				Skada.db.profile.windows[2].x = x
				Skada.db.profile.windows[2].y = y
				LUI.modules.Panels.db.Tps.OffsetX = db.realm.Dynamics[db.profile.ActualRole].UIENANCHEMENTS.SKADA.WINDOWS2.BACKX
				LUI.modules.Panels.db.Tps.OffsetY = db.realm.Dynamics[db.profile.ActualRole].UIENANCHEMENTS.SKADA.WINDOWS2.BACKY
				--LUI.modules.Panels:Refresh()
				f:Show()
				
			end	
		end
		if not (w3 == "" or w3 == nil) then
		local f = _G["SkadaBarWindow"..w3]
			if  f  then
				local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
				f:Show()
				--LUI.modules.Panels:Refresh()
			end	
		
		end
		local Panels = LUI:Module("Panels") 
		--Panels:AlphaIn("Tps")
		--Panels:AlphaIn("Dps")
		
		
		
	end
		
end --80%
function module:dynamicsUpdateHermes()
		local _,class = UnitClass("player")
		if (db.realm.Dynamics[db.profile.ActualRole] and Hermes ) then
			--print(db.profile.ActualRole)
			
			if (db.profile.ActualRole == "Healer") then
				if (Hermes and Hermes.db) then
					local profiloObscureEsiste = false
					for k,v in pairs(Hermes.db.profiles) do if k=="Obscure Healer" then profiloObscureEsiste = true end end
					if profiloObscureEsiste then
						Hermes.db:SetProfile("Obscure Healer")
						-- print("Profilo Hermes : Obscure Healer")
					end
				end
			end
			if (db.profile.ActualRole == "Tank") then
				if (Hermes and Hermes.db) then
					local profiloObscureEsiste = false
					for k,v in pairs(Hermes.db.profiles) do if k=="Obscure Tank" then profiloObscureEsiste = true end end
					if profiloObscureEsiste then
						Hermes.db:SetProfile("Obscure Tank")
						-- print("Profilo Hermes : Obscure Healer")
					end
				end
			end
			if (db.profile.ActualRole == "Melee" or db.profile.ActualRole == "Ranged") then
				if (Hermes and Hermes.db) then
					local profiloObscureEsiste = false
					for k,v in pairs(Hermes.db.profiles) do if k=="Obscure DPS" then profiloObscureEsiste = true end end
					if profiloObscureEsiste then
						Hermes.db:SetProfile("Obscure DPS")
						-- print("Profilo Hermes : Obscure Healer")
					end
				end
			end
		end	
		--print("Dynamics : Buttons Settings applyed for ".. db.profile.ActualRole)		
end 


function module:dynamicsApply(silent)
		
		if not silent then
			print("|CFF99FF00Dynamics |r: Applyed settings for |CFF9999FF".. db.profile.ActualRole .."|r Role.")
		end
		module:dynamicsUpdateLUI()
		module:dynamicsUpdateBossMods()
		module:dynamicsUpdateBartender()
		module:dynamicsUpdateRaidFrames()
		module:dynamicsUpdateForte()
		module:dynamicsUpdateChat() 
		module:dynamicsUpdateMSBT()
		module:dynamicsUpdateSkullMe()
		module:dynamicsUpdateSRTI()
		module:dynamicsUpdateMaxCameraDistance()
		module:dynamicsUpdateGarbageCollection()
		module:dynamicsUpdateAutoRess()
		module:dynamicsUpdateMinimap()
		module:dynamicsUpdateBagnon()
		module:dynamicsUpdateAutoLUIProfile()
		module:dynamicsUpdateSkada()
		module:dynamicsUpdateHermes()
end

--------------------------------------------------
-- / EVENTS HANDLING / --
--------------------------------------------------

function module:PARTY_CONVERTED_TO_RAID()
	if not (UnitAffectingCombat("player")) then
		if (DUPDATE and module:TimeToUpdate()) then
			-- module:dynamicsUpdateLUI()
			-- module:dynamicsUpdateBossMods()
			-- module:dynamicsUpdateBartender()
			module:dynamicsUpdateRaidFrames()
			-- module:dynamicsUpdateForte()
			-- module:dynamicsUpdateChat()
			-- module:dynamicsUpdateMSBT()
			-- module:dynamicsUpdateSkullMe()
			-- module:dynamicsUpdateSRTI()
			module:dynamicsUpdateGarbageCollection()
			-- module:dynamicsUpdateAutoRess()
			-- module:dynamicsUpdateMinimap()
			-- module:dynamicsUpdateBagnon()
			-- module:dynamicsUpdateAutoLUIProfile()
			print("|CFF99FF00Dynamics |r: Applyed settings for |CFF9999FF".. db.profile.ActualRole .."|r Role. (PARTY_CONVERTED_TO_RAID)")
		else
			--print("|CFF99FF00Dynamics |r: Nothing changed for |CFF9999FF".. db.profile.ActualRole .."|r Role.(PARTY_CONVERTED_TO_RAID)")
		
		end
	    module:dynamicsUpdateMaxCameraDistance()
			
	end
end
function module:PARTY_MEMBERS_CHANGED()
	if not (UnitAffectingCombat("player")) then
		if (DUPDATE and module:TimeToUpdate()) then
			-- module:dynamicsUpdateLUI()
			-- module:dynamicsUpdateBossMods()
			-- module:dynamicsUpdateBartender()
			module:dynamicsUpdateRaidFrames()
			-- module:dynamicsUpdateForte()
			-- module:dynamicsUpdateChat()
			-- module:dynamicsUpdateMSBT()
			-- module:dynamicsUpdateSkullMe()
			-- module:dynamicsUpdateSRTI()
			module:dynamicsUpdateGarbageCollection()
			module:dynamicsUpdateSkada()
			-- module:dynamicsUpdateAutoRess()
			-- module:dynamicsUpdateBagnon()
			-- module:dynamicsUpdateAutoLUIProfile()
			print("|CFF99FF00Dynamics |r: Applyed settings for |CFF9999FF".. db.profile.ActualRole .."|r Role. (PARTY_MEMBERS_CHANGED)")
		else
			--print("|CFF99FF00Dynamics |r: Nothing changed for |CFF9999FF".. db.profile.ActualRole .."|r Role.(PARTY_MEMBERS_CHANGED)")
			
		end
		module:dynamicsUpdateMaxCameraDistance()
		module:dynamicsUpdateMinimap()		
	else
		--print("DYNAMICS : You're in combat... no settings modified!")
	end
end
function module:RAID_ROSTER_UPDATE()
   if not (UnitAffectingCombat("player")) then
		if (DUPDATE and module:TimeToUpdate()) then
			-- module:dynamicsUpdateLUI()
			-- module:dynamicsUpdateBossMods()
			-- module:dynamicsUpdateBartender()
			module:dynamicsUpdateRaidFrames()
			-- module:dynamicsUpdateForte()
			-- module:dynamicsUpdateChat()
			-- module:dynamicsUpdateMSBT()
			-- module:dynamicsUpdateSkullMe()
			-- module:dynamicsUpdateSRTI()
			module:dynamicsUpdateMaxCameraDistance()
			module:dynamicsUpdateGarbageCollection()
			-- module:dynamicsUpdateAutoRess()
			-- module:dynamicsUpdateMinimap()
			-- module:dynamicsUpdateBagnon()
			-- module:dynamicsUpdateAutoLUIProfile()
			print("|CFF99FF00Dynamics |r: Applyed settings for |CFF9999FF".. db.profile.ActualRole .."|r Role.")
		else
			--print("|CFF99FF00Dynamics |r: Nothing changed for |CFF9999FF".. db.profile.ActualRole .."|r Role.(RAID_ROSTER_UPDATE)")
			
		end
	end
end	-- Fires when the raid roster changes. This occurs when a raid is formed or disbanded, 
									-- if members join or leave or are moved between raid subgroups, 
									--  if the loot policy or loot master is changed, or if raid leader, assistant, 
									--	main tank or main assist attributes are changed.
function module:LFG_PROPOSAL_SUCCEEDED()
	if not (UnitAffectingCombat("player")) then
		if (DUPDATE and module:TimeToUpdate()) then
			-- module:dynamicsUpdateLUI()
			-- module:dynamicsUpdateBossMods()
			-- module:dynamicsUpdateBartender()
			module:dynamicsUpdateRaidFrames()
			-- module:dynamicsUpdateForte()
			-- module:dynamicsUpdateChat()
			-- module:dynamicsUpdateMSBT()
			-- module:dynamicsUpdateSkullMe()
			-- module:dynamicsUpdateSRTI()
			module:dynamicsUpdateMaxCameraDistance()
			module:dynamicsUpdateGarbageCollection()
			-- module:dynamicsUpdateAutoRess()
			-- module:dynamicsUpdateMinimap()
			-- module:dynamicsUpdateBagnon()
			-- module:dynamicsUpdateAutoLUIProfile()
			print("|CFF99FF00Dynamics |r: Applyed settings for |CFF9999FF".. db.profile.ActualRole .."|r Role. (LFG_PROPOSAL_SUCCEEDED)")
		else
			--print("|CFF99FF00Dynamics |r: Nothing changed for |CFF9999FF".. db.profile.ActualRole .."|r Role.(LFG_PROPOSAL_SUCCEEDED)")
		end
	end
end
function module:PLAYER_ENTERING_WORLD()
	if not (UnitAffectingCombat("player")) then
		if module:updateSpecsRoles() then DUPDATE = true end
		if (DUPDATE and module:TimeToUpdate()) then
			module:dynamicsUpdateLUI()
			module:dynamicsUpdateBossMods()
			module:dynamicsUpdateBartender()
			module:dynamicsUpdateRaidFrames()
			module:dynamicsUpdateForte()
			module:dynamicsUpdateChat()
			module:dynamicsUpdateMSBT()
			module:dynamicsUpdateSkullMe()
			module:dynamicsUpdateSRTI()
			module:dynamicsUpdateGarbageCollection()
			--module:dynamicsUpdateAutoRess()
			module:dynamicsUpdateBagnon()
			module:dynamicsUpdateAutoLUIProfile()
			module:dynamicsUpdateSkada()
			module:dynamicsUpdateHermes()
			print("|CFF99FF00Dynamics |r: Applyed settings for |CFF9999FF".. db.profile.ActualRole .."|r Role. (PLAYER_ENTERING_WORLD)")	
		else
			--print("|CFF99FF00Dynamics |r: Nothing changed for |CFF9999FF".. db.profile.ActualRole .."|r Role.(PLAYER_ENTERING_WORLD)")
		end
		module:dynamicsUpdateMaxCameraDistance()
		module:dynamicsUpdateMinimap()
	end
end
function module:PLAYER_TALENT_UPDATE() -- Fired when the player changes between dual talent specs, and possibly when learning or unlearning talents
   	if module:updateSpecsRoles() then DUPDATE = true end
		if (DUPDATE) then
			module:dynamicsUpdateLUI()
			module:dynamicsUpdateBossMods()
			module:dynamicsUpdateBartender()
			module:dynamicsUpdateRaidFrames()
			module:dynamicsUpdateForte()
			module:dynamicsUpdateChat() 
			module:dynamicsUpdateMSBT()
			module:dynamicsUpdateSkullMe()
			module:dynamicsUpdateSRTI()
			module:dynamicsUpdateMaxCameraDistance()
			module:dynamicsUpdateGarbageCollection()
			--module:dynamicsUpdateAutoRess()
			module:dynamicsUpdateMinimap()
			module:dynamicsUpdateSkada()
			module:dynamicsUpdateHermes()
			--module:dynamicsUpdateBagnon()
			--module:dynamicsUpdateAutoLUIProfile()
			print("|CFF99FF00Dynamics |r: Applyed settings for |CFF9999FF".. db.profile.ActualRole .."|r Role. (PLAYER_TALENT_UPDATE)")
		else
			--print("|CFF99FF00Dynamics |r: Nothing changed for |CFF9999FF".. db.profile.ActualRole .."|r Role.(PLAYER_TALENT_UPDATE)")
		end

end
function module:RESURRECT_REQUEST()--self,event,...)
	--if not (UnitAffectingCombat("player")) then
	
		if db.profile.ManageAutoRess then
			-- local res = ...
			-- 
			-- if (UnitAffectingCombat(res) == nil and GetCorpseRecoveryDelay() == 0) then -- Excludes Rebirth
				AcceptResurrect()
				--DoEmote("thank", res)
			-- else
				-- local s = "Thanks! "..GetCorpseRecoveryDelay().." seconds and I can Accept."
				-- SendChatMessage(s, "WHISPER", nil, res);
				-- return
			-- end	
		end
	--end
end
--------------------------------------------------
-- / MODULE HANDLING / --
--------------------------------------------------
local realmROLEdefault = {
	LUI = {
				Player = {
						X = -150,--oUF.db.profile.Player.X,
						Y = -150,--oUF.db.profile.Player.Y,
						Width = oUF.defaults.profile.Player.Width, --oUF.db.profile.Player.Width,
						Height = oUF.defaults.profile.Player.Height,	
						Castbar = {
							X = 0,--oUF.db.profile.Player.Castbar.X,
							Y = 100,--oUF.db.profile.Player.Castbar.Y,
							Width = oUF.defaults.profile.Player.Castbar.General.Width,
							Height = oUF.defaults.profile.Player.Castbar.General.Height,	
							Enable = oUF.defaults.profile.Player.Castbar.General.Enable,	
						},
				},
				Target = {
						X = 150,--oUF.db.profile.Target.X,
						Y = -150,--oUF.db.profile.Target.Y,
						Width = oUF.defaults.profile.Target.Width,
						Height = oUF.defaults.profile.Target.Height,	
						Castbar = {
							X = 0,--oUF.db.profile.Target.Castbar.X,
							Y = 130,--oUF.db.profile.Target.Castbar.Y,
							Width = oUF.defaults.profile.Target.Castbar.General.Width,
							Height = oUF.defaults.profile.Target.Castbar.General.Height,	
							Enable = true,--oUF.db.profile.Target.Castbar.Enable,	
						},	
				},
				ToT = {
						X = 250,--oUF.db.profile.ToT.X,
						Y = 200,--oUF.db.profile.ToT.Y,
						Width = oUF.defaults.profile.ToT.Width,
						Height = oUF.defaults.profile.ToT.Height,		
						Enable = true, --oUF.db.profile.ToT.Enable,
				},
				Focus = {
						X = -250,--oUF.db.profile.Focus.X,
						Y = 200,--oUF.db.profile.Focus.Y,
						Width = oUF.defaults.profile.Focus.Width,
						Height = oUF.defaults.profile.Focus.Height,
						Enable = true, --oUF.defaults.profile.Focus.Enable,
						Castbar = {
							X = 0,--oUF.db.profile.Focus.Castbar.X,
							Y = 100,--oUF.db.profile.Focus.Castbar.Y,
							Width = oUF.defaults.profile.Focus.Castbar.General.Width,
							Height = oUF.defaults.profile.Focus.Castbar.General.Height,	
							Enable = true, --oUF.db.profile.Focus.Castbar.Enable,	
						},			
				},
				Pet = {
						X = 0,--oUF.db.profile.Pet.X,
						Y = 100,--oUF.db.profile.Pet.Y,
						Width = oUF.defaults.profile.Pet.Width,
						Height = oUF.defaults.profile.Pet.Height,
						Enable = true, --oUF.db.profile.Pet.Enable,	
						Castbar = {
							X = 0,--oUF.db.profile.Pet.Castbar.X,
							Y = 180,--oUF.db.profile.Pet.Castbar.Y,
							Width = oUF.defaults.profile.Pet.Castbar.General.Width,
							Height = oUF.defaults.profile.Pet.Castbar.General.Height,	
							Enable = true, --oUF.db.profile.Pet.Castbar.Enable,	
						},		
				},
				PetTarget = {
						X = 0,--oUF.db.profile.PetTarget.X,
						Y = 140,--oUF.db.profile.PetTarget.Y,
						Width = oUF.defaults.profile.PetTarget.Width,
						Height = oUF.defaults.profile.PetTarget.Height,	
						Enable = true,-- oUF.defaults.profile.PetTarget.Enable,		
				},
			},
	BT4 = {
		DEATHKNIGHT = "-",
		DRUID = "-",
		HUNTER = "-",
		MAGE = "-",
		MONK = "-",
		PALADIN = "-",
		PRIEST = "-",
		ROGUE = "-",
		SHAMAN = "-",
		WARLOCK = "-",
		WARRIOR = "-",	
	},
	MSBT = {
		DEATHKNIGHT = "-",
		DRUID = "-",
		HUNTER = "-",
		MAGE = "-",
		MONK = "-",
		PALADIN = "-",
		PRIEST = "-",
		ROGUE = "-",
		SHAMAN = "-",
		WARLOCK = "-",
		WARRIOR = "-",	
	},
	RAIDFRAMES = {
		MEN1 = {
			DEATHKNIGHT = {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
				DXE = "-",
				BIGWIGS = "-",
				DBM = "-",
			},
			DRUID =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
				DXE = "-",
				BIGWIGS = "-",
				DBM = "-",
			},
			HUNTER =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			MAGE =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			MONK =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			PALADIN =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			PRIEST =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			ROGUE =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			SHAMAN =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			WARLOCK =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			WARRIOR =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},	
		},
		MEN5 = {
			DEATHKNIGHT = {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
				DXE = "-",
				BIGWIGS = "-",
				DBM = "-",
			},
			DRUID =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
				DXE = "-",
				BIGWIGS = "-",
				DBM = "-",
			},
			HUNTER =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			MAGE =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			MONK =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			PALADIN =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			PRIEST =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			ROGUE =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			SHAMAN =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			WARLOCK =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			WARRIOR =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},	
		},
		MEN10 = {
			DEATHKNIGHT = {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			DRUID =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			HUNTER =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			MAGE =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			MONK =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			PALADIN =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			PRIEST =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			ROGUE =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			SHAMAN =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			WARLOCK =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			WARRIOR =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},	
		},
		MEN25 = {
			DEATHKNIGHT = {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			DRUID =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			HUNTER =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			MAGE =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			MONK =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			PALADIN =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			PRIEST =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			ROGUE =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			SHAMAN =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			WARLOCK =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			WARRIOR =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},	
		},
		MEN40 = {
			DEATHKNIGHT = {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			DRUID =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			HUNTER =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			MAGE =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			MONK =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			PALADIN =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			PRIEST =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			ROGUE =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			SHAMAN =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			WARLOCK =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},
			WARRIOR =  {
				GRID = "-",
				CLIQUE = "-",
				VUHDO = "-",
				HEALBOT = "-",
			},	
		},
	},
	FORTE = {
		COOLDOWN =  {
				X = "0",
				Y = "120",
				WIDTH = "780",
				HEIGHT = "40",
		},
		COOLDOWNSPLASH =  {
				X = "-180",
				Y = "350",
				Anchor = "Bottom",
				SCALE = 3,
		},
		TOPTEXTURE = {
				X = "0",
				Y = "90",
				EnableAnimation = true,
				AnimationHeight = "30",
				Alpha = 0.95,
		},
		BOTTOMTEXTURE = {
				X = "0",
				Y = "-25",
				Alpha = 1,
		},
		PLAYER =  {
				Enable = false,
				X = "0",
				Y = "0",
				WIDTH = "208",
				HEIGHT = "14",
				ALPHA = 1,
				EXPANDUP = true,
		},
		TARGET =  {
				Enable = false,
				X = "0",
				Y = "0",
				WIDTH = "208",
				HEIGHT = "14",
				ALPHA = 1,
				EXPANDUP = true,
				RAIDDEBUFFS = true,
		},
		FOCUS =  {
				Enable = false,
				X = "0",
				Y = "0",
				WIDTH = "208",
				HEIGHT = "14",
				ALPHA = 1,
				EXPANDUP = true,
				RAIDDEBUFFS = true,
		},
		COMPACT =  {
				Enable = false,
				X = "0",
				Y = "0",
				Anchor = "LEFT",
				WIDTH = "50",
				HEIGHT = "18",
				ALPHA = 1,
				EXPANDUP = true,
				RAIDDEBUFFS = true,
		},
	},
	CHAT = {
	    fontSize = 11,
		LEFTCHAT = {
			X = "28",
			Y = "46",
			WIDTH = "404",
			HEIGHT = "175",
			WINDOWS = {
			    FRAME1 = true,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10 = false,
			},
			LUITEXTURE = {
			    X = "",
			    Y = "",
			},
			ENABLED = true,
		},
		RIGHTCHAT = {
			X = "1552",
			Y = "40",
			WIDTH = "390",
			HEIGHT = "160",
			WINDOWS = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10 = false,
			},
			LUITEXTURE = {
			    X = "",
			    Y = "",
			},
			ENABLED = true,
		},
		CHANNELS = {
			SAY = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			EMOTE = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			YELL = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			GUILDCHAT = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			OFFICERCHAT = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			PARTY = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			PARTYLEADER = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			RAID = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			RAIDLEADER = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			RAIDAWARNING = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			BATTLEGROUNDLEADER = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			BATTLEGROUND = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			GLOBAL1 = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			GLOBAL2 = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			GLOBAL3 = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			GLOBAL4 = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			GLOBAL5 = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			CREATURESAY = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			CREATUREEMOTE = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			CREATUREYELL = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			CREATUREWISPER = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			BOSSEMOTE = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			BOSSWHISPER = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			EXPERIENCE = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			GUILDEXPERIENCE = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			HONOR = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			REPUTATION = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			SKILLUPS = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			ITEMLOOT = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			CURRENCY = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			MONEYLOOT = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			TRADESKILLS = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			OPENING = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			PETINFO = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
			MISCINFO = {
			    FRAME1 = false,
			    FRAME2 = false,
			    FRAME3 = false,
			    FRAME4 = false,
			    FRAME5 = false,
			    FRAME6 = false,
			    FRAME7 = false,
			    FRAME8 = false,
			    FRAME9 = false,
			    FRAME10= false,
			    },
		},
		CHATNAMES = {
		    FRAME1 = "Chat",
		    FRAME2 = "Chat 2",
		    FRAME3 = "Chat 3",
		    FRAME4 = "Chat 4",
		    FRAME5 = "Chat 5",
		    FRAME6 = "Chat 6",
		    FRAME7 = "Chat 7",
		    FRAME8 = "Chat 8",
		    FRAME9 = "Chat 9",
		    FRAME10 = "Chat 10",
		    
		},
	},
	BOSSMODS = {
		DBM = {
		    defaults = true,
		    BARS = {
		        NORMALX = "300",
		        NORMALY = "-240",
		        NORMALWIDTH = "312",
		        NORMALSCALE = "1",
		        HUGEX = "0",
		        HUGEY = "130",
		        HUGEWIDTH = "187",
		        HUGESCALE = "1.2",
		        EXPANDUPWARDS = false,
		        CLASSCOLORBARS = true,    
		    },
		    SPECIALWARNINGS = {
		        X = "0",
		        Y = "-270",
		    },
		    RAIDWARNINGS = {
		        X = "0",
		        Y = "-200",
		    },
		    RANGECHECK = {
		        X = "10",
		        Y = "-200",
		    },
		    RANGECHECKRADAR = {
		        X = "-80",
		        Y = "-235",
		    },
		    BOSSHPFRAME = {
		        X = "-57",
		        Y = "-48",
		        GROWUPWARDS = false,
		        WIDTH = "160",
		    },
		    INFOFRAME = {
		        X = "-380",
		        Y = "-30",
		    },
		    
		},
		BIGWIGS = {
		     defaults = true,
		     CLASSCOLOREDBARS = true,
		     NORMALBAR = {
		        X = "458"  ,
		        Y = "264"  ,
		        WIDTH = "244",
		        SCALE = "1",
		        GROWUP = true,
		    },
		     EMPHASIZEDBAR = {
		        X = "552"  ,
		        Y = "742"  ,
		        WIDTH = "375",
		        SCALE = "1.7",
		        GROWUP = false,
		        FONTSIZE = "18",
		    },
		     NORMALMESSAGES = {
		        X = "620"  ,
		        Y = "441"  ,
		    },
		     EMPHASIZEDMESSAGES = {
		        X = "620"  ,
		        Y = "598"  ,
		     },
		     PROXIMITY = {
		        X = "1"  ,
		        Y = "262"  ,
		        WIDTH = "192",
		        HEIGHT = "120",
		    },
		    
		},
		DXE = {
		    defaults = true,
		    CLASSCOLOREDBARS = true,
		    PANE = {
		        X = "-22"  ,
		        Y = "-60"  ,
		        SCALE = "0.8",
		        WIDTH = "183",
		        TITLEFONTSIZE = "13",
		        HEALTHFONTSIZE = "12",
                BARGROWTH = "DOWN",					        
		    },
		     TOPBAR = {
		        X = "-385"  ,
		        Y = "-175"  ,
		        WIDTH = "228",
		       TEXTWIDTH = "160",
		       GROWTH = "UP",					        
		    },
		     CENTERBAR = {
		        X = "-15"  ,
		        Y = "-58"  ,
		        WIDTH = "305",
		        TEXTWIDTH = "240",
		        GROWTH = "DOWN",					        
		    },
		     WARNINGBAR = {
		        X = "-30"  ,
		        Y = "-180"  ,
		        SCALE = "1.2",
		        WIDTH = "310",
		        TEXTWIDTH = "300",
		        GROWTH = "UP",					        
		    },
		     FLASHSCREEN = {
		        ALPHA = "0.8",
		     },
		     PROXIMITY = {
		        X = "4"  ,
		        Y = "-235"  ,				        
		    },
		     ALTERNATEPOWER = {
		        X = "-167"  ,
		        Y = "67"  ,				        
		    },
		    ARROW1 = {
		        X = "-453"  ,
		        Y = "-135"  ,				        
		    },
		    ARROW2 = {
		        X = "--361"  ,
		        Y = "-135"  ,				        
		    },
		   ARROW3 = {
		        X = "-271"  ,
		        Y = "-135"  ,				        
		    },
		},
	},
	UIENANCHEMENTS = {
		SKULLME = false,
		SETSRTI = false,
		MAXCAMERA = false,
		GARBAGE = false,
		AUTORESS = false,
		BAGNONCOLORS = false,
		Minimap = false,
		SKADA ={
			WINDOWS1 = {
				X = "0",
				Y = "0",
				BACKX = "0",
				BACKY = "0",
			},
			WINDOWS2 = {
				X = "0",
				Y = "0",
				BACKX = "0",
				BACKY = "0",
			},
		},
	},
}

module.order = 2.5
module.optionsName = "Dynamic Interface"
module.childGroups = "select"
module.defaults = {
	profile = {
		Enabled = true,
		DynamicsInfoText = {
			Enable = true,
			X = -320,
			Y = 0,
			InfoPanel = {
				Horizontal = "Right",
				Vertical = "Bottom",
			},
			Font = "vibroceb",
			FontSize = 12,
			Outline = "NONE",
			Color = {
				r = 1,
				g = 1,
				b = 1,
				a = 1,
			},
		},
		MainSpec = "",
		OffSpec = "",
		MainSpecRole = "",
		OffSpecRole = "",
		ActualRole = "",
		ActualSpec = "",
		ManageLUI = false,	
		ManageBossMod = false,
		ManageBartender = false,
		ManageRaidFrames = false,
		ManageMSBT = false,
		ManageForte = false,
		ManageChat = false,
		ManageSkada = false,
		ManageSkullMe = false,
		ManageSRTI = false,
		ManageMaxCameraDistance = false,
		ManageGarbageCollection = false,
		ManageAutoRess = false,
		ManageMinimap = false,
		ManageBagnon = false,
		ManageLUIProfile = false,
		currentMSBTProfile = "-",
		updateTime = 0,
		BossMods = {
			DBM = false,
			BIGWIGS = false,
			DXE = false,
		},
		Version = "1",
	},
	realm = {
		Dynamics = {
			RAIDDIM = {
				MEN1 = "1",
				MEN5 = "2",
				MEN10 = "7",
				MEN25 = "12",
				MEN40 = "27",
			},
			Tank = realmROLEdefault,
			Healer = realmROLEdefault,
			Melee = realmROLEdefault,
			Ranged = realmROLEdefault,
		},
		
	}
} 

function module:LoadOptions()
	
	
	-- INFOTEXT Functions
	local fontflags = {"NONE", "OUTLINE", "THICKOUTLINE", "MONOCHROME"}
	local function NameLabel(info, statName) -- (info [, statName])
		statName = statName or info[#info]
		return (db.profile[statName].Enable and statName.. " InfoText" or ("|cff888888"..statName.." InfoText|r"))
	end
	local function PositionOptions(order, statName) -- (order [, statName])
		local horizontal = {"Left", "Right"}
		local vertical = {"Top", "Bottom"}
		
		local option = {
			name = "Info Panel and Position",
			type = "group",
			order = order,
			disabled = StatDisabled,
			guiInline = true,
			args = {
				X = {
					name = "X Offset",
					desc = function(info)
							return ("X offset for the " .. (statName or info[#info-2]) .. " info text.\n\n" ..
								"Note:\nPositive values = right\nNegative values = left\n" ..
								"Default: " .. db.defaults.profile[statName].X
							)
						end,
					type = "input",
					order = 1,
					disabled = function(info) return not db.profile[statName].Enable end,
					get = function(info) return tostring(db.profile[statName].X) end,
					set = function(info, value)
						if value == nil or value == "" then value = "0" end
						db.profile[statName].X = tonumber(value)
						module:SetInfoPanel(statName)
					end,
				},
				Y = {
					name = "Y Offset",
					desc = function(info)
							return ("Y offset for the " .. (statName or info[#info-2]) .. " info text.\n\n" ..
								"Note:\nPositive values = up\nNegative values = down\n" ..
								"Default: " .. db.defaults.profile[statName].Y
							)
						end,
					type = "input",
					order = 2,
					disabled = function(info) return not db.profile[statName].Enable end,
					get = function(info) return tostring(db.profile[statName].Y) end,
					set = function(info, value)
						if value == nil or value == "" then value = "0" end
						db.profile[statName].Y = tonumber(value)
						module:SetInfoPanel(statName)
					end,
				},
				Horizontal = {
					name = "Horizontal",
					desc = function(info)
							return ("Select the horizontal panel that the " .. (statName or info[#info-2]) .. " info text will be anchored to.\n\n" ..
								"Default: " .. db.defaults.profile[statName].InfoPanel.Horizontal
							)
						end,
					type = "select",
					disabled = function(info) return not db.profile[statName].Enable end,
					order = 3,
					values = horizontal,
					get = function(info)
						for k, v in pairs(horizontal) do
							if db.profile[statName].InfoPanel.Horizontal == v then return k end
						end
					end,
					set = function(info, value)
						db.profile[statName].InfoPanel.Horizontal = horizontal[value]
						db.profile[statName].X = 0
						module:SetInfoPanel(statName)
					end,
				},
				Vertical = {
					name = "Vertical",
					desc = function(info)
							return ("Select the vertical panel that the " .. (statName or info[#info-2]) .. " info text will be anchored to.\n\n" ..
								"Default: " .. db.defaults.profile[statName].InfoPanel.Vertical
							)
						end,
					type = "select",
					disabled = function(info) return not db.profile[statName].Enable end,
					order = 3,
					values = vertical,
					get = function(info)
						for k, v in pairs(vertical) do
							if db.profile[statName].InfoPanel.Vertical == v then return k end
						end
					end,
					set = function(info, value)
						db.profile[statName].InfoPanel.Vertical = vertical[value]
						db.profile[statName].Y = 0
						module:SetInfoPanel(statName)
					end,
				},
			}
		}
		
		return option
	end
	local function FontOptions(order, statName) -- (order [, statName])
	
	local option = {
			name = "Font Settings",
			type = "group",
			disabled = StatDisabled,
			order = order,
			guiInline = true,
			args = {
				FontSize = {
					name = "Size",
					desc = function(info)
							return ("Choose your " .. (statName or info[#info-2]) .. " info text's fontsize.\n\n" ..
								"Default: " .. db.defaults.profile[statName].FontSize
							)
						end,
					type = "range",
					disabled = function(info) return not db.profile[statName].Enable end,
					order = 1,
					min = 1,
					max = 40,
					step = 1,
					get = function(info) return db.profile[statName].FontSize end,
					set = function(info, value)
						db.profile[statName].FontSize = value
						module:SetFontSettings(statName)
					end,
				},
				Color = {
					name = "Color",
					desc = function(info)
							local defaults = db.defaults.profile[statName].Color
							return ("Choose your " .. statName .. " info text's colour.\n\n" ..
								"Defaults:\nr = " .. defaults.r .. "\ng = " .. defaults.g .. "\nb = " .. defaults.b .. "\na = " .. defaults.a
							)
						end,
					type = "color",
					hasAlpha = true,
					get = function(info)
							local color = db.profile[statName].Color
							return color.r, color.g, color.b, color.a
						end,
					set = function(info, r, g, b, a)
						local color = db.profile[statName].Color
						color.r = r
						color.g = g
						color.b = b
						color.a = a
						
						module:SetFontSettings(statName)
					end,
					disabled = function(info) return not db.profile[statName].Enable end,
					order = 2,
				},
				Font = {
					name = "Font",
					desc = function(info)
							return ("Choose your " .. (statName or info[#info-2]) .. " info text's font.\n\n" ..
								"Default: " .. db.defaults.profile[statName].Font
							)
						end,
					type = "select",
					dialogControl = "LSM30_Font",
					values = widgetLists.font,
					get = function(info) return db.profile[statName].Font end,
					set = function(info, value)
						db.profile[statName].Font = value
						module:SetFontSettings(statName)
					end,
					disabled = function(info) return not db.profile[statName].Enable end,
					order = 3,
				},
				Outline = {
					name = "Font Flag",
					desc = function(info)
							return ("Choose your " .. (statName or info[#info-2]) .. " info text's font flag.\n\n" ..
								"Default: " .. db.defaults.profile[statName].Outline
							)
						end,
					type = "select",
					values = fontflags,
					get = function(info)
						for k, v in pairs(fontflags) do
							if db.profile[statName].Outline == v then
								return k
							end
						end
					end,
					set = function(info, value)
						db.profile[statName].Outline = fontflags[value]
						module:SetFontSettings(statName)
					end,
					disabled = function(info) return not db.profile[statName].Enable end,
					order = 4,
				},
			},
		}

	return option
	end
	local function ResetOption(order)
		local option = {
			name = "Reset Settings",
			type = "execute",
			disabled = not db.profile["AddonSwitcher"].Enable,
			order = order,
			func = function(info)
				local statDB = "AddonSwitcher"
				
				for k, v in pairs(db.profile[statDB]) do
					db.profile[statDB][k] = nil
				end
				module:copyDefaults(db.profile[statDB], db.defaults.profile[statDB])
				db.profile[statDB].Enable = true
				
				module:ResetStat(statDB)
				module:DisableStat(statDB)
				module:EnableStat(statDB)
			end
		}
		
		return option
	end
	local function createDummyFunc(i) return function() return i end end
	
	local function createRaidFramesOptions(name,order,players,role)
		local _,class = UnitClass("player")
		local raidKey = ""
		
		if players== 1 then
			raidKey = "MEN1"
		elseif players ==5 then
			raidKey = "MEN5"
		elseif players == 10 then
			raidKey = "MEN10"
		elseif players == 25 then
			raidKey = "MEN25"
		elseif players == 40 then
			raidKey = "MEN40"
		end
		-- Let's understand which RAIDFrame Manager you're using...
		local rm = module:readRaidManager()
		local raidframe = 
			{
			name = name ,
			type = "group",
			disabled = false,
			order = order,
			guiInline = false,
			args = {
				Description1 = {
							name = "Use the following DropDownMenus to select the profile you want to be applyed when you play as |CFF9999FF" ..role ..
									"|r in a |CFF9999FF".. players .." Men Raid ",
							type = "description",
							order = 1,
							},
				Description2 = {
							name = "\n",
							type = "description",
							order = 2,
							},
				RaidProfiles = {
											name = "Manage "..rm.." Profiles",
											type = "group",
											disabled = false,
											order = 3,
											guiInline = true,
											args = {
														DeathKnight = {
																	name = function() 
																				if class == "DEATHKNIGHT" then 
																					return "|CFF99FF66Death Knight Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Death Knight Profile|r" 
																				end
																			end,
																	desc = "Select the |CFFCC66FF".. rm.."|r Profile you want to use when you're playing a DeathKnight as |CFFCC66FF".. role .. "|r in ".. players.." Men Raids.",
																	type = "select",
																	width = "double",
																	values = raidprofiles,
																	get = function() 
																				for i=1, #raidprofiles do
																					if (raidprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["DEATHKNIGHT"][string.upper(rm)]) then
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["DEATHKNIGHT"][string.upper(rm)] = raidprofiles[val]
																		if (class == "DEATHKNIGHT") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("RAIDFRAMES")
																	end,
																	order = 1,
														},
														Druid = {
																	name = function() 
																				if class == "DRUID" then 
																					return "|CFF99FF66Druid Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Druid Profile|r" 
																				end
																			end,
																	desc = "Select the |CFFCC66FF".. rm.."|r Profile you want to use when you're playing a Druid as |CFFCC66FF".. role .. "|r in ".. players.." Men Raids.",
																	type = "select",
																	width = "double",
																	values = raidprofiles,
																	get = function() 
																				for i=1, #raidprofiles do
																					if (raidprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["DRUID"][string.upper(rm)]) then
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["DRUID"][string.upper(rm)] = raidprofiles[val]
																		if (class == "DRUID") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("RAIDFRAMES")
																	end,
																	order = 2,
														},
														Hunter = {
																	name = function() 
																				if class == "HUNTER" then 
																					return "|CFF99FF66Hunter Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Hunter Profile|r" 
																				end
																			end,
																	desc = "Select the |CFFCC66FF".. rm.."|r Profile you want to use when you're playing a Hunter as |CFFCC66FF".. role .. "|r in ".. players.." Men Raids.",
																	type = "select",
																	width = "double",
																	values = raidprofiles,
																	get = function() 
																				for i=1, #raidprofiles do
																					if (raidprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["HUNTER"][string.upper(rm)]) then
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["HUNTER"][string.upper(rm)] = raidprofiles[val]
																		if (class == "HUNTER") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("RAIDFRAMES")
																	end,
																	order = 3,
														},
														Mage = {
																	name = function() 
																				if class == "MAGE" then 
																					return "|CFF99FF66Mage Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Mage Profile|r" 
																				end
																			end,
																	desc = "Select the |CFFCC66FF".. rm.."|r Profile you want to use when you're playing a Mage as |CFFCC66FF".. role .. "|r in ".. players.." Men Raids.",
																	type = "select",
																	width = "double",
																	values = raidprofiles,
																	get = function() 
																				for i=1, #raidprofiles do
																					if (raidprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["MAGE"][string.upper(rm)]) then
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["MAGE"][string.upper(rm)] = raidprofiles[val]
																		if (class == "MAGE") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("RAIDFRAMES")
																	end,
																	order = 4,
														},
														Paladin = {
																	name = function() 
																				if class == "PALADIN" then 
																					return "|CFF99FF66Paladin Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Paladin Profile|r" 
																				end
																			end,
																	desc = "Select the |CFFCC66FF".. rm.."|r Profile you want to use when you're playing a Paladin as |CFFCC66FF".. role .. "|r in ".. players.." Men Raids.",
																	type = "select",
																	width = "double",
																	values = raidprofiles,
																	get = function() 
																				for i=1, #raidprofiles do
																					if (raidprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["PALADIN"][string.upper(rm)]) then
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["PALADIN"][string.upper(rm)] = raidprofiles[val]
																		if (class == "PALADIN") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("RAIDFRAMES")
																	end,
																	order = 5,
														},
														Priest = {
																	name = function() 
																				if class == "PRIEST" then 
																					return "|CFF99FF66Priest Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Priest Profile|r" 
																				end
																			end,
																	desc = "Select the |CFFCC66FF".. rm.."|r Profile you want to use when you're playing a Priest as |CFFCC66FF".. role .. "|r in ".. players.." Men Raids.",
																	type = "select",
																	width = "double",
																	values = raidprofiles,
																	get = function() 
																				for i=1, #raidprofiles do
																					if (raidprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["PRIEST"][string.upper(rm)]) then
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["PRIEST"][string.upper(rm)] = raidprofiles[val]
																		if (class == "PRIEST") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("RAIDFRAMES")
																	end,
																	order = 6,
														},
														Rogue = {
																	name = function() 
																				if class == "ROGUE" then 
																					return "|CFF99FF66Rogue Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Rogue Profile|r" 
																				end
																			end,
																	desc = "Select the |CFFCC66FF".. rm.."|r Profile you want to use when you're playing a Rogue as |CFFCC66FF".. role .. "|r in ".. players.." Men Raids.",
																	type = "select",
																	width = "double",
																	values = raidprofiles,
																	get = function() 
																				for i=1, #raidprofiles do
																					if (raidprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["ROGUE"][string.upper(rm)]) then
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["ROGUE"][string.upper(rm)] = raidprofiles[val]
																		if (class == "ROGUE") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("RAIDFRAMES")
																	end,
																	order = 7,
														},
														Shaman = {
																	name = function() 
																				if class == "SHAMAN" then 
																					return "|CFF99FF66Shaman Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Shaman Profile|r" 
																				end
																			end,
																	desc = "Select the |CFFCC66FF".. rm.."|r Profile you want to use when you're playing a Shaman as |CFFCC66FF".. role .. "|r in ".. players.." Men Raids.",
																	type = "select",
																	width = "double",
																	values = raidprofiles,
																	get = function() 
																				for i=1, #raidprofiles do
																					if (raidprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["SHAMAN"][string.upper(rm)]) then
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["SHAMAN"][string.upper(rm)] = raidprofiles[val]
																		if (class == "SHAMAN") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("RAIDFRAMES")
																	end,
																	order = 8,
														},
														Warlock = {
																	name = function() 
																				if class == "WARLOCK" then 
																					return "|CFF99FF66Warlock Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Warlock Profile|r" 
																				end
																			end,
																	desc = "Select the |CFFCC66FF".. rm.."|r Profile you want to use when you're playing a Warlock as |CFFCC66FF".. role .. "|r in ".. players.." Men Raids.",
																	type = "select",
																	width = "double",
																	values = raidprofiles,
																	get = function() 
																				for i=1, #raidprofiles do
																					if (raidprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["WARLOCK"][string.upper(rm)]) then
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["WARLOCK"][string.upper(rm)] = raidprofiles[val]
																		if (class == "WARLOCK") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("RAIDFRAMES")
																	end,
																	order = 9,
														},
														Warrior = {
																	name = function() 
																				if class == "WARRIOR" then 
																					return "|CFF99FF66Warrior Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Warrior Profile|r" 
																				end
																			end,
																	desc = "Select the |CFFCC66FF".. rm.."|r Profile you want to use when you're playing a Warrior as |CFFCC66FF".. role .. "|r in ".. players.." Men Raids.",
																	type = "select",
																	width = "double",
																	values = raidprofiles,
																	get = function() 
																				for i=1, #raidprofiles do
																					if (raidprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["WARRIOR"][string.upper(rm)]) then
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["WARRIOR"][string.upper(rm)] = raidprofiles[val]
																		if (class == "WARRIOR") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("RAIDFRAMES")
																	end,
																	order = 10,
														},
														Monk = {
																	name = function() 
																				if class == "MONK" then 
																					return "|CFF99FF66Monk Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Monk Profile|r" 
																				end
																			end,
																	desc = "Select the |CFFCC66FF".. rm.."|r Profile you want to use when you're playing a Monk as |CFFCC66FF".. role .. "|r in ".. players.." Men Raids.",
																	type = "select",
																	width = "double",
																	values = raidprofiles,
																	get = function() 
																				for i=1, #raidprofiles do
																					if (raidprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["WARRIOR"][string.upper(rm)]) then
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role]["RAIDFRAMES"][raidKey]["MONK"][string.upper(rm)] = raidprofiles[val]
																		if (class == "MONK") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("RAIDFRAMES")
																	end,
																	order = 11,
														},
											},
								}, -- MSBTProfiles END			
			}, -- ARGS END
		}
		
		
		return raidframe
	
	end
	
	local function toggleDynamicsRolesOptions(option,value)
		for k,v in pairs (LUI.options.args[self:GetName()].args) do 
			if not (k == "Dynamics") then
				if v.args[option] then
					v.args[option].disabled = not value
				end
			end
		end
		LUI.options.args[self:GetName()].args["Dynamics"].args["RaidSwitch"].args["MEN10"].disabled = not value
		LUI.options.args[self:GetName()].args["Dynamics"].args["RaidSwitch"].args["MEN25"].disabled = not value
		LUI.options.args[self:GetName()].args["Dynamics"].args["RaidSwitch"].args["MEN40"].disabled = not value
	end
	local function createDynamicsOptions(name,order,canBe)
		local role = name
		local _,class = UnitClass("player")
		local option = canBe and 
		{
			name = name ,
			type = "group",
			disabled = false,
			order = order,
			guiInline = false,
			args = {
				LUIPositions = {
							name = "oUF Positions",
							type = "group",
							disabled = not db.profile.ManageLUI,
							order = 1,
							guiInline = false,
							args = {
								Player = {
									name = "LUI Player",
									type = "group",
									disabled = not db.profile.ManageLUI,
									order = 1,
									guiInline = true,
									args ={
										PlayerX = {
											name = "Player X Offset",
											desc = function(info)
													return ("X offset for the " .. "player" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Player.X .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Player.X .."|r\n"
														-- 
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Player.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												--print("CAMBIO LA X DEL LUI PLAYER!!!!!!! per il ruolo ".. role)
												db.realm.Dynamics[role].LUI.Player.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										PlayerY = {
											name = "Player Y Offset",
											desc = function(info)
														return ("Y offset for the " .. "player" .. " info text.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"Default: " ..  oUF.defaults.profile.Player.Y .."\n"..
															"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Player.Y .."|r\n" 
															-- 
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Player.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].LUI.Player.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("LUIPositions")
												end,
										},
									},
								},
								Target = {
									name = "LUI Target",
									type = "group",
									disabled = not db.profile.ManageLUI,
									order = 2,
									guiInline = true,
									args ={
										TargetX = {
											name = "Target X Offset",
											desc = function(info)
													return ("X offset for the " .. "Target" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Target.X .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Target.X .."|r\n"
														-- 
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Target.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.Target.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										TargetY = {
											name = "Target Y Offset",
											desc = function(info)
														return ("Y offset for the " .. "Target" .. " info text.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"Default: " ..  oUF.defaults.profile.Target.Y .."\n"..
															"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Target.Y .."|r\n"
															-- 
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Target.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].LUI.Target.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("LUIPositions")
												end,
										},
									},
								},
								ToT = {
									name = "LUI Target Of Target",
									type = "group",
									disabled = not db.profile.ManageLUI,
									order = 3,
									guiInline = true,
									args ={
										ToTX = {
											name = "ToT X Offset",
											desc = function(info)
													return ("X offset for the " .. "ToT" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.ToT.X .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.ToT.X .."|r\n"
														-- 
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.ToT.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.ToT.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										ToTY = {
											name = "ToT Y Offset",
											desc = function(info)
														return ("Y offset for the " .. "ToT" .. " info text.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"Default: " ..  oUF.defaults.profile.ToT.Y .."\n"..
															"|CFFCCFF66Actual LUI: " .. oUF.db.profile.ToT.Y .."|r\n"
															-- 
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.ToT.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].LUI.ToT.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("LUIPositions")
												end,
										},
									},
								},
								Focus = {
									name = "LUI Focus",
									type = "group",
									disabled = not db.profile.ManageLUI,
									order = 4,
									guiInline = true,
									args ={
										FocusX = {
											name = "Focus X Offset",
											desc = function(info)
													return ("X offset for the " .. "Focus" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Focus.X .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Focus.X .."|r\n"
														-- 
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Focus.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.Focus.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										FocusY = {
											name = "Focus Y Offset",
											desc = function(info)
														return ("Y offset for the " .. "Focus" .. " info text.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"Default: " ..  oUF.defaults.profile.Focus.Y .."\n"..
															"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Focus.Y .."|r\n"
															-- 
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Focus.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].LUI.Focus.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("LUIPositions")
												end,
										},
									},
								},
								Pet = {
									name = "LUI Pet",
									type = "group",
									disabled = not db.profile.ManageLUI,
									order = 5,
									guiInline = true,
									args ={
										PetX = {
											name = "Pet X Offset",
											desc = function(info)
													return ("X offset for the " .. "Pet" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Pet.X .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Pet.X .."|r\n"
														-- 
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Pet.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.Pet.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										PetY = {
											name = "Pet Y Offset",
											desc = function(info)
														return ("Y offset for the " .. "Pet" .. " info text.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"Default: " ..  oUF.defaults.profile.Pet.Y .."\n"..
															"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Pet.Y .."|r\n"
															-- 
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Pet.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].LUI.Pet.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("LUIPositions")
												end,
										},
									},
								},
								PetTarget = {
									name = "LUI Pet Target",
									type = "group",
									disabled = not db.profile.ManageLUI,
									order = 6,
									guiInline = true,
									args ={
										PetTargetX = {
											name = "Pet Target X Offset",
											desc = function(info)
													return ("X offset for the " .. "Pet Target" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.PetTarget.X .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.PetTarget.X .."|r\n"
														-- 
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.PetTarget.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.PetTarget.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										PetTargetY = {
											name = "Pet Target Y Offset",
											desc = function(info)
														return ("Y offset for the " .. "Pet Target" .. " info text.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"Default: " ..  oUF.defaults.profile.PetTarget.Y .."\n"..
															"|CFFCCFF66Actual LUI: " .. oUF.db.profile.PetTarget.Y .."|r\n"
															-- 
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.PetTarget.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].LUI.PetTarget.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("LUIPositions")
												end,
										},
									},
								},
								CastbarPlayer = {
									name = "LUI Player Castbar",
									type = "group",
									disabled = not db.profile.ManageLUI,
									order = 7,
									guiInline = true,
									args ={
										CastbarPlayerX = {
											name = "Castbar Player X Offset",
											desc = function(info)
													return ("X offset for the " .. "Castbar player" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Player.Castbar.General.X .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Player.Castbar.General.X .."|r\n"
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Player.Castbar.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.Player.Castbar.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										CastbarPlayerY = {
											name = "Castbar Player Y Offset",
											desc = function(info)
														return ("Y offset for the " .. "Castbar player" .. " info text.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"Default: " ..  oUF.defaults.profile.Player.Castbar.General.Y .."\n"..
															"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Player.Castbar.General.Y .."|r\n"
															-- 
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Player.Castbar.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].LUI.Player.Castbar.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("LUIPositions")
												end,
										},
										CastbarPlayerWidth = {
											name = "Castbar Player Width",
											desc = function(info)
													return ("Width for the " .. "Castbar player" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Player.Castbar.General.Width .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Player.Castbar.General.Width .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Player.Castbar.Width or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.Player.Castbar.Width = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										CastbarPlayerHeight = {
											name = "Castbar Player Height",
											desc = function(info)
													return ("Height for the " .. "Castbar player" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Player.Castbar.General.Height .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Player.Castbar.General.Height .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Player.Castbar.Height or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.Player.Castbar.Height = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										--ShowDummy = LUI:NewExecute("Show Dummy Castbar", "Show a Dummy Castbar for testing and positioning", 3, TestCastbar(oUF_LUI_player)),
									},
								},
								CastbarTarget = {
									name = "LUI Target Castbar",
									type = "group",
									disabled = not db.profile.ManageLUI,
									order = 8,
									guiInline = true,
									args ={
										CastbarTargetX = {
											name = "Target Castbar X Offset",
											desc = function(info)
													return ("X offset for the " .. "Target Castbar" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Target.Castbar.General.X .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Target.Castbar.General.X .."|r\n"
														-- 
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Target.Castbar.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.Target.Castbar.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										CastbarTargetY = {
											name = "Target Castbar Y Offset",
											desc = function(info)
														return ("Y offset for the " .. "Target Castbar" .. " info text.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"Default: " ..  oUF.defaults.profile.Target.Castbar.General.Y .."\n"..
															"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Target.Castbar.General.Y .."|r\n"
															-- 
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Target.Castbar.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].LUI.Target.Castbar.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("LUIPositions")
												end,
										},
										CastbarTargetWidth = {
											name = "Castbar Target Width",
											desc = function(info)
													return ("Width for the " .. "Castbar Target" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Target.Castbar.General.Width .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Target.Castbar.General.Width .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Target.Castbar.Width or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.Target.Castbar.Width = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										CastbarTargetHeight = {
											name = "Castbar Target Height",
											desc = function(info)
													return ("Height for the " .. "Castbar Target" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Target.Castbar.General.Height .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Target.Castbar.General.Height .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Target.Castbar.Height or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.Target.Castbar.Height = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
									},
								},
								CastbarFocus = {
									name = "LUI Focus Castbar",
									type = "group",
									disabled = not db.profile.ManageLUI,
									order =9,
									guiInline = true,
									args ={
										CastbarFocusX = {
											name = "Focus Castbar X Offset",
											desc = function(info)
													return ("X offset for the " .. "Focus Castbar" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Focus.Castbar.General.X .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Focus.Castbar.General.X .."|r\n"
														-- 
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Focus.Castbar.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.Focus.Castbar.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										CastbarFocusY = {
											name = "Focus Y Castbar Offset",
											desc = function(info)
														return ("Y offset for the " .. "Focus Castbar" .. " info text.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"Default: " ..  oUF.defaults.profile.Focus.Castbar.General.Y .."\n"..
															"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Focus.Castbar.General.Y .."|r\n"
															-- 
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Focus.Castbar.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].LUI.Focus.Castbar.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("LUIPositions")
												end,
										},
									},
								},
								CastbarPet = {
									name = "LUI Pet Castbar",
									type = "group",
									disabled = not db.profile.ManageLUI,
									order = 10,
									guiInline = true,
									args ={
										CastbarPetX = {
											name = "Pet Castbar X Offset",
											desc = function(info)
													return ("X offset for the " .. "Pet Castbar" .. " info text.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: " ..  oUF.defaults.profile.Pet.Castbar.General.X .."\n"..
														"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Pet.Castbar.General.X .."|r\n"
														-- 
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Pet.Castbar.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].LUI.Pet.Castbar.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("LUIPositions")
											end,
										},
										CastbarPetY = {
											name = "Pet Castbar Y Offset",
											desc = function(info)
														return ("Y offset for the " .. "Pet Castbar" .. " info text.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"Default: " ..  oUF.defaults.profile.Pet.Castbar.General.Y .."\n"..
															"|CFFCCFF66Actual LUI: " .. oUF.db.profile.Pet.Castbar.General.Y .."|r\n"
															-- 
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].LUI.Pet.Castbar.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].LUI.Pet.Castbar.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("LUIPositions")
												end,
										},
									},
								},
								
								
							} -- LUI Options Args End
						}, -- LUI Positions End
				LUIDimensions = {
							name = "LUI oUF Dimensions",
							type = "group",
							disabled = not db.profile.ManageLUI,
							order = 2,
							guiInline = false,
							args = {
									Description = {
									name = "To be developed...",
									type = "description",
									order = 1,
									},
							} -- LUI Dimensions Args End
						}, -- LUI Dimensions End
				LUIDetails = {
							name = "LUI oUF Details",
							type = "group",
							disabled = not db.profile.ManageLUI,
							order = 3,
							guiInline = false,
							args = {
									Description = {
									name = "To be developed...",
									type = "description",
									order = 1,
									},
							} -- LUI Details Args End
						}, -- LUI Details End
				BossModsProfiles = {
							name = "BossMods Settings",
							type = "group",
							disabled = not db.profile.ManageBossMod,
							order = 4,
							guiInline = false,
							args = {
									Description = {
									name = "In this Section you can customize how Dynamics will manage your actual Boss Mod.\n"..
											"Actually DBM, Bigwigs and DXE are Supported.\n"..
											"\n\n First of all you can choose to let Dynamics manage some importante BossMod parameters."..
											"The default Dynamics configuration for every Boss Mod is Raid Oriented to give the best raiding Xperience.\n\n",
									type = "description",
									order = 1,
									},
									DBMDefaults = {
												name = "Apply Dynamics' DBM Defaults",
												desc = "If Checked, Dynamics will always apply the RAID defaults for DBM.",
												type = "toggle",
												width = "full",
												get = function() return db.realm.Dynamics[role].BOSSMODS.DBM.defaults or false end,
												set = function(info, value)
													db.realm.Dynamics[role].BOSSMODS.DBM.defaults = value
													--toggleDynamicsRolesOptions("BossModsProfiles",value)
													module:UpdateOptions("BOSSMODS")
												end,
												order = 2,
									},
									DMBTest = {
												name = "DBM Test",
												desc = "Launch a DBM Test.",
												type = "execute",
												width = "full",
												disabled = (not db.profile.BossMods.DBM) or (not (db.profile.ActualRole==role)),
												func = function(info,value)  
													module:dynamicsUpdateBossMods()
													DBM:DemoMode()		
													DBM:ShowTestSpecialWarning()		
												end,
												order = 3,
											},
									BIGWIGSDefaults = {
												name = "Apply Dynamics' BIGWIGS Defaults",
												desc = "If Checked, Dynamics will always apply the RAID defaults for BIGWIGS.",
												type = "toggle",
												width = "full",
												get = function() return db.realm.Dynamics[role].BOSSMODS.BIGWIGS.defaults or false end,
												set = function(info, value)
													db.realm.Dynamics[role].BOSSMODS.BIGWIGS.defaults = value
													--toggleDynamicsRolesOptions("BossModsProfiles",value)
													module:UpdateOptions("BOSSMODS")
												end,
												order = 4,
									},
									BIGWIGSTest = {
												name = "BIGWIGS Test",
												desc = "Launch a BIGWIGS Test.",
												type = "execute",
												width = "full",
												disabled = (not db.profile.BossMods.BIGWIGS) or (not (db.profile.ActualRole==role)),
												func = function(info,value)  
													if not select(4,GetAddOnInfo("BigWigs_Core")) then EnableAddOn("BigWigs_Core") end 
													if not BigWigs then	
														LoadAddOn("BigWigs_Core") 
														if not BigWigs then return end
														BigWigs:Enable()
														for name, module in BigWigs:IterateBossModules() do
															if module:IsEnabled() then module:Reboot() end
														end
													end
													if BigWigs then
														module:UpdateOptions("BOSSMODS")
														BigWigs:Test()		
													end		
												end,
												order = 5,
											},
									DXEDefaults = {
												name = "Apply Dynamics' DXE Defaults",
												desc = "If Checked, Dynamics will always apply the RAID defaults for DXE.",
												type = "toggle",
												width = "full",
												get = function() return db.realm.Dynamics[role].BOSSMODS.DXE.defaults or false end,
												set = function(info, value)
													db.realm.Dynamics[role].BOSSMODS.DXE.defaults = value
													--toggleDynamicsRolesOptions("BossModsProfiles",value)
													module:UpdateOptions("BOSSMODS")
												end,
												order = 6,
									},
									DXETest = {
												name = "DXE Test",
												desc = "Launch a DXE Test.",
												type = "execute",
												width = "full",
												disabled = (not db.profile.BossMods.DXE) or (not (db.profile.ActualRole==role)),
												func = function(info,value)  
													module:dynamicsUpdateBossMods()
													if not select(4,GetAddOnInfo("DXE")) then EnableAddOn("DXE") end 
													if not DXE then	LoadAddOn("DXE") end
													if DXE then
														DXE.Alerts:BarTest()
														DXE.Alerts:BarTest()
														DXE.Alerts:FlashTest()		
													end
												end,
												order = 7,
											},
									DBM = {
											name = "DBM Settings" ,
											type = "group",
											disabled = not db.profile.BossMods.DBM,
											order = 8,
											guiInline = false,
											args = {
												DMBTestBars = {
														name = "DBM Test",
														desc = "Launch a DBM Test.",
														type = "execute",
														width = "full",
														disabled = (not db.profile.BossMods.DBM) or (not (db.profile.ActualRole==role)),
														func = function(info,value)  
															module:dynamicsUpdateBossMods()
															DBM:DemoMode()		
															DBM:ShowTestSpecialWarning()		
														end,
														order = 1,
												},
												BARS = {
														name = "Bars Settings" ,
														type = "group",
														disabled = false,
														order = 2,
														guiInline = true,
														args = {
																UPWARDS = {
																			name = "Expand Upwards",
																			desc = "If Checked, DBM Bars will Expand upward. If not checked Bars will expand downwards",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].BOSSMODS.DBM.BARS.EXPANDUPWARDS or false end,
																			set = function(info, value)
																				db.realm.Dynamics[role].BOSSMODS.DBM.BARS.EXPANDUPWARDS = value
																				--toggleDynamicsRolesOptions("BossModsProfiles",value)
																				module:UpdateOptions("BOSSMODS")
																			end,
																			order = 1,
																},
																CLASSCOLORED = {
																			name = "Class-Colored Bars",
																			desc = "If Checked, DBM Bars will appears in class color.",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].BOSSMODS.DBM.BARS.CLASSCOLORBARS or false end,
																			set = function(info, value)
																				db.realm.Dynamics[role].BOSSMODS.DBM.BARS.CLASSCOLORBARS = value
																				--toggleDynamicsRolesOptions("BossModsProfiles",value)
																				module:UpdateOptions("BOSSMODS")
																			end,
																			order = 1,
																},
																NORMALBARS = {
																			name = "Normal Bars" ,
																			type = "group",
																			disabled = false,
																			order = 3,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "DBM Normal Bars shows the 30seconds incoming abilities.",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for normal Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Bars.options.TimerX .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.BARS.NORMALX .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.BARS.NORMALX .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.BARS.NORMALX .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.BARS.NORMALX .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALX or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALX = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for normal Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Bars.options.TimerY .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.BARS.NORMALY .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.BARS.NORMALY .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.BARS.NORMALY .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.BARS.NORMALY .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALY or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALY = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					WIDTH = {
																							name = "Width",
																							desc = function(info)
																									return ("Width for normal Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Bars.options.Width .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.BARS.NORMALWIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.BARS.NORMALWIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.BARS.NORMALWIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.BARS.NORMALWIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 4,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALWIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALWIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					SCALE = {
																						name = "Scale",
																							desc = function(info)
																									return ("Scale for normal Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Bars.options.Scale .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.BARS.NORMALSCALE .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.BARS.NORMALSCALE .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.BARS.NORMALSCALE .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.BARS.NORMALSCALE .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 5,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALSCALE or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.BARS.NORMALSCALE = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					
																			},
																},
																HUGEBARS = {
																			name = "Huge Bars" ,
																			type = "group",
																			disabled = false,
																			order = 4,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "DBM Huge Bars shows the 5 seconds incoming abilities.",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Huge Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Bars.options.HugeTimerX .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.BARS.HUGEX .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.BARS.HUGEX .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.BARS.HUGEX .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.BARS.HUGEX .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGEX or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGEX = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Huge Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Bars.options.HugeTimerY .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.BARS.HUGEY .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.BARS.HUGEY .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.BARS.HUGEY .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.BARS.HUGEY .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGEY or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGEY = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					WIDTH = {
																							name = "Width",
																							desc = function(info)
																									return ("Width for Huge Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Bars.options.HugeWidth .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.BARS.HUGEWIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.BARS.HUGEWIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.BARS.HUGEWIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.BARS.HUGEWIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 4,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGEWIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGEWIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					SCALE = {
																						name = "Scale",
																							desc = function(info)
																									return ("Scale for Huge Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Bars.options.HugeScale .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.BARS.HUGESCALE .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.BARS.HUGESCALE .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.BARS.HUGESCALE .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.BARS.HUGESCALE .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 5,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGESCALE or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.BARS.HUGESCALE = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																			},
																},
												
														},
											
												},
												WARNINGS = {
														name = "Text Warnings Settings" ,
														type = "group",
														disabled = false,
														order = 3,
														guiInline = true,
														args = {
															RAIDWARNINGS = {
																			name = "Raid Warnings" ,
																			type = "group",
																			disabled = false,
																			order = 1,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "|CFF33FF66DBM Raid Warnings shows alerts on casted spells.|r",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Raid Warnings.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.RaidWarningPosition.X .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.RAIDWARNINGS.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.RAIDWARNINGS.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.RAIDWARNINGS.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.RAIDWARNINGS.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.RAIDWARNINGS.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.RAIDWARNINGS.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Raid Warnings.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.RaidWarningPosition.Y .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.RAIDWARNINGS.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.RAIDWARNINGS.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.RAIDWARNINGS.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.RAIDWARNINGS.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.RAIDWARNINGS.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.RAIDWARNINGS.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																			},
																},	
															SPECIALWARNINGS = {
																			name = "Special Warnings" ,
																			type = "group",
																			disabled = false,
																			order = 2,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "|CFF33FF66DBM Special Warnings shows alerts on Special Encounters Events.|r",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Special Warnings.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.SpecialWarningX .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.SPECIALWARNINGS.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.SPECIALWARNINGS.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.SPECIALWARNINGS.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.SPECIALWARNINGS.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.SPECIALWARNINGS.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.SPECIALWARNINGS.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Raid Warnings.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.SpecialWarningY .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.SPECIALWARNINGS.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.SPECIALWARNINGS.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.SPECIALWARNINGS.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.SPECIALWARNINGS.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.SPECIALWARNINGS.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.SPECIALWARNINGS.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					DMBRTest = {
																							name = "Warnings Test",
																							desc = "Launch a Special Warning Test.",
																							type = "execute",
																							width = "full",
																							disabled = (not db.profile.BossMods.DBM) or (not (db.profile.ActualRole==role)),
																							func = function(info,value)  
																								module:dynamicsUpdateBossMods()
																								DBM:ShowTestSpecialWarning()		
																							end,
																							order = 4,
																						},
									
																			},
																},	
														},
											
												},
												OTHERWINDOWS = {
														name = "Other Windows Settings" ,
														type = "group",
														disabled = false,
														order = 4,
														guiInline = true,
														args = {
															PROXIMITY = {
																			name = "Range Check Window" ,
																			type = "group",
																			disabled = false,
																			order = 1,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "|CFF33FF66DBM Range Check Window Shows up who is in x Yards Range with you.|r",
																								type = "description",
																								order = 1,
																					},
																					rangeX = {
																							name = "Range X Offset",
																							desc = function(info)
																									return ("X offset for Range Check Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.RangeFrameX .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.RANGECHECK.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.RANGECHECK.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.RANGECHECK.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.RANGECHECK.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECK.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECK.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					rangeY = {
																						name = "Range Y Offset",
																							desc = function(info)
																									return ("Y offset for Range Check Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.RangeFrameY .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.RANGECHECK.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.RANGECHECK.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.RANGECHECK.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.RANGECHECK.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECK.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECK.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					RadarDesc = {
																								name = "|CFF33FF66DBM Radar Check Window Shows up who is in x Yards Range with you in a graphic Radar.|r",
																								type = "description",
																								order = 4,
																					},
																					radarX = {
																							name = "Radar X Offset",
																							desc = function(info)
																									return ("X offset for Radar Check Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.RangeFrameRadarX .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.RANGECHECKRADAR.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.RANGECHECKRADAR.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.RANGECHECKRADAR.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.RANGECHECKRADAR.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 5,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECKRADAR.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECKRADAR.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					radarY = {
																						name = "Radar Y Offset",
																							desc = function(info)
																									return ("Y offset for Radar Check Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.RangeFrameRadarY .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.RANGECHECKRADAR.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.RANGECHECKRADAR.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.RANGECHECKRADAR.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.RANGECHECKRADAR.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 6,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECKRADAR.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.RANGECHECKRADAR.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					rangeTest = {
																							name = "Range Test",
																							desc = "Open or Close Range Window.",
																							type = "execute",
																							width = "full",
																							disabled = (not db.profile.BossMods.DBM) or (not (db.profile.ActualRole==role)),
																							func = function(info,value)  
																								if DBM.RangeCheck:IsShown() then
																									DBM.RangeCheck:Hide()		
																									DBMRangeCheckRadar:Hide()																						
																								else
																									DBM.RangeCheck:Show(28)	
																									DBMRangeCheckRadar:Show(28)
																								end
																								module:dynamicsUpdateBossMods()
																								
																							end,
																							order = 4,
																						},
																			},
																},	
															BOSSHEALTH = {
																			name = "Boss Health Window" ,
																			type = "group",
																			disabled = false,
																			order = 2,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "|CFF33FF66DBM Boss Health Window Shows up the %hp of bosses.|r",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Boss Health Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.HPFrameX .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.BOSSHPFRAME.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.BOSSHPFRAME.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.BOSSHPFRAME.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.BOSSHPFRAME.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Boss Health Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.HPFrameY .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.BOSSHPFRAME.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.BOSSHPFRAME.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.BOSSHPFRAME.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.BOSSHPFRAME.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					WIDTH = {
																						name = "Width",
																							desc = function(info)
																									return ("Width for Boss Health Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.HealthFrameWidth .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.BOSSHPFRAME.WIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.BOSSHPFRAME.WIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.BOSSHPFRAME.WIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.BOSSHPFRAME.WIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 4,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.WIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.WIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					UPWARDS = {
																								name = "Expand Upwards",
																								desc = "If Checked, DBM Boss Health Bars will Expand upward. If not checked Bars will expand downwards",
																								type = "toggle",
																								width = "full",
																								get = function() return db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.GROWUPWARDS or false end,
																								set = function(info, value)
																									db.realm.Dynamics[role].BOSSMODS.DBM.BOSSHPFRAME.GROWUPWARDS = value
																									module:UpdateOptions("BOSSMODS")
																								end,
																								order = 5,
																					},
																					HPTest = {
																							name = "Boss Health Test",
																							desc = "Open Boss Health Window.",
																							type = "execute",
																							width = "full",
																							disabled = (not db.profile.BossMods.DBM) or (not (db.profile.ActualRole==role)),
																							func = function(info,value)  
																								--if DBM.BossHealth and createDummyFunc(25) then
																									DBM.BossHealth:Show("Health Frame")
																									DBM.BossHealth:AddBoss("TestBoss 1")
																									DBM.BossHealth:AddBoss("TestBoss 2")
																									DBM.BossHealth:AddBoss("TestBoss 3")
																									DBM.BossHealth:AddBoss("TestBoss 4")	
																								--end
																										
																							end,
																							order = 6,
																						},
																			},
																},
															INFOFRAME = {
																			name = "Info Frame Window" ,
																			type = "group",
																			disabled = false,
																			order = 3,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "|CFF33FF66DBM Info Frame Window Shows some Encounters details (ex. : Baleroc Healer's Stacks, Atramedes Sound, Cho'Ghall Corruption).|r",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Info Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.InfoFrameX .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.INFOFRAME.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.INFOFRAME.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.INFOFRAME.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.INFOFRAME.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.INFOFRAME.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.INFOFRAME.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Info Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DBM.Options.InfoFrameY .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DBM.INFOFRAME.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DBM.INFOFRAME.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DBM.INFOFRAME.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DBM.INFOFRAME.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DBM.INFOFRAME.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DBM.INFOFRAME.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					InfoTest = {
																							name = "InfoFrame Test",
																							desc = "Open InfoFrame Window.",
																							type = "execute",
																							width = "full",
																							disabled = (not db.profile.BossMods.DBM) or (not (db.profile.ActualRole==role)),
																							func = function(info,value)  
																								module:dynamicsUpdateBossMods()
																								if DBM.InfoFrame:IsShown() then
																									DBM.InfoFrame:Hide()
																								else
																									DBM.InfoFrame:Hide()
																									DBM.InfoFrame:Show(5,"test")
																								end
																										
																							end,
																							order = 4,
																						},
																			},
																},
															
														},
											
												},
											},
									},
									BIGWIGS = {
											name = "BIGWIGS Settings" ,
											type = "group",
											disabled = not db.profile.BossMods.BIGWIGS,
											order = 9,
											guiInline = false,
											args = {
												BIGWIGSTestBars = {
														name = "BIGWIGS Test",
														desc = "Launch a BigWigs Test.",
														type = "execute",
														width = "full",
														disabled = (not db.profile.BossMods.BIGWIGS) or (not (db.profile.ActualRole==role)),
														func = function(info,value)  
															module:UpdateOptions("BOSSMODS")
															BigWigs:Test()				
														end,
														order = 1,
												},
												BARS = {
														name = "Bars Settings" ,
														type = "group",
														disabled = false,
														order = 2,
														guiInline = true,
														args = {
																CLASSCOLORED = {
																			name = "Class-Colored Bars",
																			desc = "If Checked, BigWigs Bars will appears in class color.",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].BOSSMODS.BIGWIGS.CLASSCOLOREDBARS or false end,
																			set = function(info, value)
																				db.realm.Dynamics[role].BOSSMODS.BIGWIGS.CLASSCOLOREDBARS = value
																				module:UpdateOptions("BOSSMODS")
																			end,
																			order = 1,
																},
																NORMALBARS = {
																			name = "Normal Bars" ,
																			type = "group",
																			disabled = false,
																			order = 3,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "Bigwigs Normal Bars shows the 30seconds incoming abilities.",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for normal Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsAnchor_x .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.NORMALBAR.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.NORMALBAR.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.NORMALBAR.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.NORMALBAR.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for normal Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsAnchor_y .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.NORMALBAR.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.NORMALBAR.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.NORMALBAR.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.NORMALBAR.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					WIDTH = {
																							name = "Width",
																							desc = function(info)
																									return ("Width for normal Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsAnchor_width .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.NORMALBAR.WIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.NORMALBAR.WIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.NORMALBAR.WIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.NORMALBAR.WIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 4,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.WIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.WIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					SCALE = {
																						name = "Scale",
																							desc = function(info)
																									return ("Scale for normal Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Bars.db.profile.scale .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.NORMALBAR.SCALE .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.NORMALBAR.SCALE .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.NORMALBAR.SCALE .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.NORMALBAR.SCALE .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 5,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.SCALE or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.SCALE = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					GROWUP = {
																							name = "Grow Upwards",
																							desc = "If Checked, BigWigs Bars will Expand upward. If not checked Bars will expand downwards",
																							type = "toggle",
																							width = "full",
																							get = function() return db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.GROWUP or false end,
																							set = function(info, value)
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALBAR.GROWUP = value
																								--toggleDynamicsRolesOptions("BossModsProfiles",value)
																								module:UpdateOptions("BOSSMODS")
																							end,
																							order = 6,
																					},
																
																			},
																},
																EMPHASIZEDBARS = {
																			name = "Emphasized Bars" ,
																			type = "group",
																			disabled = false,
																			order = 4,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "Bigwigs Emphasized Bars shows the 10seconds incoming abilities.",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for normal Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsEmphasizeAnchor_x .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Emphasized Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsEmphasizeAnchor_y .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					WIDTH = {
																							name = "Width",
																							desc = function(info)
																									return ("Width for Emphasized Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Bars.db.profile.BigWigsEmphasizeAnchor_width .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.WIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.WIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.WIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.WIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 4,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.WIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.WIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					SCALE = {
																						name = "Scale",
																							desc = function(info)
																									return ("Scale for normal Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Bars.db.profile.emphasizeScale .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.SCALE .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.SCALE .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.SCALE .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.SCALE .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 5,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.SCALE or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.SCALE = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					GROWUP = {
																							name = "Grow Upwards",
																							desc = "If Checked, BigWigs Emphasized Bars will Expand upward. If not checked Bars will expand downwards",
																							type = "toggle",
																							width = "full",
																							get = function() return db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.GROWUP or false end,
																							set = function(info, value)
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDBAR.GROWUP = value
																								--toggleDynamicsRolesOptions("BossModsProfiles",value)
																								module:UpdateOptions("BOSSMODS")
																							end,
																							order = 6,
																					},
																
																			},
																},
														},
											
												},
												MESSAGES = {
														name = "Text Messages Settings" ,
														type = "group",
														disabled = false,
														order = 3,
														guiInline = true,
														args = {
															NORMALMESSAGES = {
																			name = "Normal Messages" ,
																			type = "group",
																			disabled = false,
																			order = 1,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "|CFF33FF66DBM Normal Messages shows alerts on casted spells and ended timers.|r",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Normal Messages.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Messages.db.profile.BWMessageAnchor_x .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.NORMALMESSAGES.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.NORMALMESSAGES.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.NORMALMESSAGES.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.NORMALMESSAGES.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALMESSAGES.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALMESSAGES.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Normal Messages.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Messages.db.profile.BWMessageAnchor_y .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.NORMALMESSAGES.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.NORMALMESSAGES.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.NORMALMESSAGES.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.NORMALMESSAGES.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALMESSAGES.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.NORMALMESSAGES.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																			},
																},	
															EMPHASIZEDMESSAGES = {
																			name = "Emphasized Messages" ,
																			type = "group",
																			disabled = false,
																			order = 2,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "|CFF33FF66DBM Emphasized Messages shows countdown and alerts on Special Encounters Events.|r",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Emphasized Messages.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Messages.db.profile.BWEmphasizeMessageAnchor_x .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Emphasized Messages.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Messages.db.profile.BWEmphasizeMessageAnchor_y .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.EMPHASIZEDMESSAGES.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																			},
																},	
														},
											
												},
												OTHERWINDOWS = {
														name = "Other Windows Settings" ,
														type = "group",
														disabled = false,
														order = 4,
														guiInline = true,
														args = {
															PROXIMITY = {
																			name = "Proximity Window" ,
																			type = "group",
																			disabled = false,
																			order = 1,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "|CFF33FF66DBM Proximity Window Shows up who is in x Yards Range with you.|r",
																								type = "description",
																								order = 1,
																					},
																					proximityX = {
																							name = "Proximity X Offset",
																							desc = function(info)
																									return ("X offset for Proximity Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Proximity.db.profile.posx .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.PROXIMITY.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.PROXIMITY.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.PROXIMITY.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.PROXIMITY.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					proximityY = {
																						name = "Proximity Y Offset",
																							desc = function(info)
																									return ("Y offset for Proximity Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Proximity.db.profile.posy .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.PROXIMITY.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.PROXIMITY.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.PROXIMITY.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.PROXIMITY.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					proximityWIDTH = {
																							name = "Width",
																							desc = function(info)
																									return ("Width for Proximity Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Proximity.db.profile.width .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.PROXIMITY.WIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.PROXIMITY.WIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.PROXIMITY.WIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.PROXIMITY.WIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 4,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.WIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.WIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					proximityHEIGHT = {
																							name = "Height",
																							desc = function(info)
																									return ("Height for Proximity Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. BigWigs.modules.Plugins.modules.Proximity.db.profile.height .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.BIGWIGS.PROXIMITY.HEIGHT .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.BIGWIGS.PROXIMITY.HEIGHT .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.BIGWIGS.PROXIMITY.HEIGHT .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.BIGWIGS.PROXIMITY.HEIGHT .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 5,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.HEIGHT or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.BIGWIGS.PROXIMITY.HEIGHT = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					proximityTest = {
																							name = "Proximity Test",
																							desc = "Open or Close Proximity Window.",
																							type = "execute",
																							width = "full",
																							disabled = (not db.profile.BossMods.BIGWIGS) or (not (db.profile.ActualRole==role)),
																							func = function(info,value)  
																								module:dynamicsUpdateBossMods()
																								if not isBIGWIGSProximityShown then
																									BigWigs.modules.Plugins.modules.Proximity:Test() --BigWigs.modules.Plugins.modules.Proximity:BigWigs_StartConfigureMode()	
																									isBIGWIGSProximityShown = true
																								else
																									BigWigs.modules.Plugins.modules.Proximity:BigWigs_StopConfigureMode()
																									isBIGWIGSProximityShown = false
																								end
																							end,
																							order = 6,
																						},
																			},
																},	
														},
											
												},
											}
									},
									DXE = {
											name = "DXE Settings" ,
											type = "group",
											disabled = not db.profile.BossMods.DXE,
											order = 10,
											guiInline = false,
											args = {
												DXETestBars = {
														name = "DXE Test",
														desc = "Launch a DXE Test.",
														type = "execute",
														width = "full",
														disabled = (not db.profile.BossMods.DXE) or (not (db.profile.ActualRole==role)),
														func = function(info,value)  
															module:dynamicsUpdateBossMods()
															DXE.Alerts:BarTest()
															DXE.Alerts:BarTest()
															DXE.Alerts:FlashTest()	
														end,
														order = 1,
												},
												BARS = {
														name = "Bars Settings" ,
														type = "group",
														disabled = false,
														order = 2,
														guiInline = true,
														args = {
																CLASSCOLORED = {
																			name = "Class-Colored Bars",
																			desc = "If Checked, DXE Bars will appears in class color.",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].BOSSMODS.DXE.CLASSCOLOREDBARS or false end,
																			set = function(info, value)
																				db.realm.Dynamics[role].BOSSMODS.DXE.CLASSCOLOREDBARS = value
																				module:UpdateOptions("BOSSMODS")
																			end,
																			order = 1,
																},
																TOPBARS = {
																			name = "Top Bars" ,
																			type = "group",
																			disabled = false,
																			order = 3,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "DXE Top Bars shows the 30seconds incoming abilities.",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Top Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEAlertsTopStackAnchor.xOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.TOPBAR.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.TOPBAR.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.TOPBAR.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.TOPBAR.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Top Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEAlertsTopStackAnchor.yOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.TOPBAR.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.TOPBAR.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.TOPBAR.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.TOPBAR.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					WIDTH = {
																							name = "Width",
																							desc = function(info)
																									return ("Width for Top Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.Alerts.db.profile.TopBarWidth .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.TOPBAR.WIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.TOPBAR.WIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.TOPBAR.WIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.TOPBAR.WIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 4,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.WIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.WIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					TEXTWIDTH = {
																							name = "Text Width",
																							desc = function(info)
																									return ("Text Width for Top Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.Alerts.db.profile.TopTextWidth .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.TOPBAR.TEXTWIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.TOPBAR.TEXTWIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.TOPBAR.TEXTWIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.TOPBAR.TEXTWIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 5,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.TEXTWIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.TEXTWIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					UPWARDS = {
																							name = "Expand Upwards",
																							desc = "If Checked, DXE Bars will Expand upward. If not checked Bars will expand downwards",
																							type = "toggle",
																							width = "full",
																							get = function() 
																									if db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.GROWTH == "UP" then
																										return true
																									else
																										return false
																									end
																									end,
																							set = function(info, value)
																								if value then
																									db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.GROWTH = "UP"
																								else
																									db.realm.Dynamics[role].BOSSMODS.DXE.TOPBAR.GROWTH = "DOWN"
																								end
																								module:UpdateOptions("BOSSMODS")
																							end,
																							order = 6,
																					},
																
																			},
																},
																CENTEREDBARS = {
																			name = "Centered Bars" ,
																			type = "group",
																			disabled = false,
																			order = 4,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "DXE Centered Bars shows the 10seconds incoming abilities.",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Centered Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEAlertsCenterStackAnchor.xOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.CENTERBAR.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.CENTERBAR.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.CENTERBAR.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.CENTERBAR.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Centered Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEAlertsCenterStackAnchor.yOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.CENTERBAR.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.CENTERBAR.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.CENTERBAR.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.CENTERBAR.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					WIDTH = {
																							name = "Width",
																							desc = function(info)
																									return ("Width for Centered Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.Alerts.db.profile.CenterBarWidth .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.CENTERBAR.WIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.CENTERBAR.WIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.CENTERBAR.WIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.CENTERBAR.WIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 4,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.WIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.WIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					TEXTWIDTH = {
																							name = "Text Width",
																							desc = function(info)
																									return ("Text Width for Centered Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.Alerts.db.profile.CenterTextWidth .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.CENTERBAR.TEXTWIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.CENTERBAR.TEXTWIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.CENTERBAR.TEXTWIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.CENTERBAR.TEXTWIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 5,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.TEXTWIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.TEXTWIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					UPWARDS = {
																							name = "Expand Upwards",
																							desc = "If Checked, DXE Centered Bars will Expand upward. If not checked Bars will expand downwards",
																							type = "toggle",
																							width = "full",
																							get = function() 
																									if db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.GROWTH == "UP" then
																										return true
																									else
																										return false
																									end
																									end,
																							set = function(info, value)
																								if value then
																									db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.GROWTH = "UP"
																								else
																									db.realm.Dynamics[role].BOSSMODS.DXE.CENTERBAR.GROWTH = "DOWN"
																								end
																								module:UpdateOptions("BOSSMODS")
																							end,
																							order = 6,
																					},
																					BARTEST = {
																							name = "Bars Test",
																							desc = "Launch a DXE Test.",
																							type = "execute",
																							width = "full",
																							disabled = (not db.profile.BossMods.DXE) or (not (db.profile.ActualRole==role)),
																							func = function(info,value)  
																								module:dynamicsUpdateBossMods()
																								DXE.Alerts:BarTest()
																								DXE.Alerts:BarTest()
																							end,
																							order = 7,
																					},
																			},
																},
																WARININGBARS = {
																			name = "Warning Bars" ,
																			type = "group",
																			disabled = false,
																			order = 5,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "DXE Warning Bars shows the Encounter's Events.",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Warning Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEAlertsWarningStackAnchor.xOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.WARNINGBAR.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.WARNINGBAR.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.WARNINGBAR.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.WARNINGBAR.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Warning Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEAlertsWarningStackAnchor.yOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.WARNINGBAR.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.WARNINGBAR.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.WARNINGBAR.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.WARNINGBAR.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					WIDTH = {
																							name = "Width",
																							desc = function(info)
																									return ("Width for Warning Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.Alerts.db.profile.WarningBarWidth .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.WARNINGBAR.WIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.WARNINGBAR.WIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.WARNINGBAR.WIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.WARNINGBAR.WIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 4,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.WIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.WIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					TEXTWIDTH = {
																							name = "Text Width",
																							desc = function(info)
																									return ("Text Width for Warning Bars.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.Alerts.db.profile.WarningTextWidth .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.WARNINGBAR.TEXTWIDTH .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.WARNINGBAR.TEXTWIDTH .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.WARNINGBAR.TEXTWIDTH .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.WARNINGBAR.TEXTWIDTH .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 5,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.TEXTWIDTH or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.TEXTWIDTH = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					SCALE = {
																							name = "Scale",
																							desc = function(info)
																									return ("Scale for Warning Bars.\n\n" ..
																										"Note:\nFrom 0.5 up to 1.5 are accepted Values\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.Alerts.db.profile.WarningScale .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.WARNINGBAR.SCALE .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.WARNINGBAR.SCALE .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.WARNINGBAR.SCALE .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.WARNINGBAR.SCALE .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 6,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.SCALE or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.SCALE = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					UPWARDS = {
																							name = "Expand Upwards",
																							desc = "If Checked, DXE Warning Bars will Expand upward. If not checked Bars will expand downwards",
																							type = "toggle",
																							width = "full",
																							get = function() 
																									if db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.GROWTH == "UP" then
																										return true
																									else
																										return false
																									end
																									end,
																							set = function(info, value)
																								if value then
																									db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.GROWTH = "UP"
																								else
																									db.realm.Dynamics[role].BOSSMODS.DXE.WARNINGBAR.GROWTH = "DOWN"
																								end
																								module:UpdateOptions("BOSSMODS")
																							end,
																							order = 7,
																					},
																					BARTEST = {
																							name = "Bars Test",
																							desc = "Launch a DXE Test.",
																							type = "execute",
																							width = "full",
																							disabled = (not db.profile.BossMods.DXE) or (not (db.profile.ActualRole==role)),
																							func = function(info,value)  
																								module:dynamicsUpdateBossMods()
																								DXE.Alerts:BarTest()
																								DXE.Alerts:BarTest()
																							end,
																							order = 7,
																					},
												
																			},
																},	
														},
												},
												OTHERWINDOWS = {
														name = "Other Windows Settings" ,
														type = "group",
														disabled = false,
														order = 3,
														guiInline = true,
														args = {
															PROXIMITY = {
																			name = "Proximity Window" ,
																			type = "group",
																			disabled = false,
																			order = 1,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "|CFF33FF66DBM Proximity Window Shows up who is in x Yards Range with you.|r",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Proximity Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEWindowProximity.xOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.PROXIMITY.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.PROXIMITY.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.PROXIMITY.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.PROXIMITY.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.PROXIMITY.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.PROXIMITY.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Proximity Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEWindowProximity.yOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.PROXIMITY.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.PROXIMITY.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.PROXIMITY.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.PROXIMITY.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.PROXIMITY.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.PROXIMITY.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					Test = {
																							name = "Proximity Test",
																							desc = "Open or Close Proximity Window.",
																							type = "execute",
																							width = "full",
																							disabled = (not db.profile.BossMods.DXE) or (not (db.profile.ActualRole==role)),
																							func = function(info,value)  
																								module:dynamicsUpdateBossMods()
																								if not isDXEProximityShown then
																									DXE:Proximity(true,12)
																									isDXEProximityShown = true
																								else
																									DXE:HideProximity()
																									isDXEProximityShown = false
																								end
																							end,
																							order = 4,
																						},
																			},
																},	
															ALTERNATE = {
																			name = "Alternate Power Window" ,
																			type = "group",
																			disabled = false,
																			order = 2,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "|CFF33FF66DBM Alternate Power Window Shows up some Encounters Important DEBUFFs.|r",
																								type = "description",
																								order = 1,
																					},
																					X = {
																							name = "X Offset",
																							desc = function(info)
																									return ("X offset for Alternate Power Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEWindowProximity.xOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.ALTERNATEPOWER.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.ALTERNATEPOWER.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.ALTERNATEPOWER.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.ALTERNATEPOWER.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.ALTERNATEPOWER.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.ALTERNATEPOWER.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y = {
																						name = "Y Offset",
																							desc = function(info)
																									return ("Y offset for Alternate Power Window.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEWindowProximity.yOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.ALTERNATEPOWER.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.ALTERNATEPOWER.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.ALTERNATEPOWER.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.ALTERNATEPOWER.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.ALTERNATEPOWER.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.ALTERNATEPOWER.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					Test = {
																							name = "Alternate Power Test",
																							desc = "Open or Close Alternate Power Window.",
																							type = "execute",
																							width = "full",
																							disabled = (not db.profile.BossMods.DXE) or (not (db.profile.ActualRole==role)),
																							func = function(info,value)  
																								module:dynamicsUpdateBossMods()
																								if not isDXEAlternateShown then
																									DXE:AlternatePower(true)
																									isDXEAlternateShown = true
																								else
																									DXE:HideAlternatePower()
																									isDXEAlternateShown = false
																								end
																							end,
																							order = 4,
																						},
																			},
																},	
															ARROWS = {
																			name = "Arrows Windows" ,
																			type = "group",
																			disabled = false,
																			order = 3,
																			guiInline = true,
																			args = {
																					Desc = {
																								name = "|CFF33FF66DBM Arrows Windows Shows where you need to run on some Encounters events.|r",
																								type = "description",
																								order = 1,
																					},
																					X1 = {
																							name = "Arrow1 X Offset",
																							desc = function(info)
																									return ("X offset for Arrow1.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEArrowsAnchor1.xOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.ARROW1.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.ARROW1.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.ARROW1.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.ARROW1.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 2,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.ARROW1.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.ARROW1.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y1 = {
																						name = "Arrow1 Y Offset",
																							desc = function(info)
																									return ("Y offset for Arrow1.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEArrowsAnchor1.yOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.ARROW1.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.ARROW1.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.ARROW1.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.ARROW1.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 3,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.ARROW1.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.ARROW1.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					X2 = {
																							name = "Arrow2 X Offset",
																							desc = function(info)
																									return ("X offset for Arrow2.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEArrowsAnchor2.xOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.ARROW2.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.ARROW2.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.ARROW2.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.ARROW2.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 4,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.ARROW2.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.ARROW2.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y2 = {
																						name = "Arrow2 Y Offset",
																							desc = function(info)
																									return ("Y offset for Arrow2.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEArrowsAnchor2.yOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.ARROW2.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.ARROW2.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.ARROW2.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.ARROW2.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 5,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.ARROW2.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.ARROW2.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					X3 = {
																							name = "Arrow3 X Offset",
																							desc = function(info)
																									return ("X offset for Arrow3.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEArrowsAnchor3.xOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.ARROW3.X .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.ARROW3.X .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.ARROW3.X .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.ARROW3.X .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 6,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.ARROW3.X or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.ARROW3.X = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																								end,
																						},
																					Y3 = {
																						name = "Arrow3 Y Offset",
																							desc = function(info)
																									return ("Y offset for Arrow3.\n\n" ..
																										"Note:\nPositive values = right\nNegative values = left\n\n" ..
																										"|CFFCCFF66Actual LUI: " .. DXE.db.profile.Positions.DXEArrowsAnchor3.yOfs .."|r\n\n\n"..
																										"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].BOSSMODS.DXE.ARROW3.Y .."|r\n"..
																										"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].BOSSMODS.DXE.ARROW3.Y .."|r\n"..
																										"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].BOSSMODS.DXE.ARROW3.Y .."|r\n"..
																										"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].BOSSMODS.DXE.ARROW3.Y .."|r\n"
																									)
																								end,
																							type = "input",
																							order = 7,
																							width = "half",
																							disabled = false,
																							get = function(info) return tostring(db.realm.Dynamics[role].BOSSMODS.DXE.ARROW3.Y or 0) end,
																							set = function(info, value)
																								if value == nil or value == "" then value = "0" end
																								db.realm.Dynamics[role].BOSSMODS.DXE.ARROW3.Y = tonumber(value) -- Store in the Realm Role DB
																								if (role == db.profile.ActualRole) then	DUPDATE = true end
																								module:UpdateOptions("BOSSMODS")
																							end,
																			},
																					Test = {
																							name = "Arrows Test",
																							desc = "Open or Close Direction Arrows.",
																							type = "execute",
																							width = "full",
																							disabled = (not db.profile.BossMods.DXE) or (not (db.profile.ActualRole==role)),
																							func = function(info,value)  
																								module:dynamicsUpdateBossMods()
																								if not isDXEArrowShown then
																									 for k,arrow in ipairs(DXE.Arrows.frames) do arrow:Test() end
																									isDXEArrowShown = true
																								else
																									 for k,arrow in ipairs(DXE.Arrows.frames) do arrow:Hide() end
																									isDXEArrowShown = false
																								end
																							end,
																							order = 8,
																						},
																			},
																},	
															
														},
											
												},
											}
									},
						
							} -- LUI Details Args End
						}, -- BossModsProfiles End
				ButtonsProfiles = {
							name = "BarTender 4",
							type = "group",
							disabled = not db.profile.ManageBartender,
							order = 5,
							guiInline = false,
							args = {
									Description = {
									name = "Choose the BarTender profile that Dynamics will automatically apply when you're Playing as |CFF9999FF".. role .."|r",
									type = "description",
									order = 1,
									},
									BT4Profiles = {
													name = "Manage BarTender Profiles",
													type = "group",
													disabled = false,
													order = 2,
													guiInline = true,
													args = {
																DeathKnight = {
																			name = function() 
																						if class == "DEATHKNIGHT" then 
																							return "|CFF99FF66Death Knight Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Death Knight Profile|r" 
																						end
																					end,
																			desc = "Select the BarTender Profile you want to use when you're playing a DeathKnight as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() 
																						for i=1, #bt4profiles do
																							if (bt4profiles[i] == db.realm.Dynamics[role].BT4.DEATHKNIGHT) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role].BT4.DEATHKNIGHT = bt4profiles[val]
																				if (class == "DEATHKNIGHT") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("BT4")
																			end,
																			order = 1,
																},
																Druid = {
																			name = function() 
																						if class == "DRUID" then 
																							return "|CFF99FF66Druid Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Druid Profile|r" 
																						end
																					end,
																			desc = "Select the BarTender Profile you want to use when you're playing a Druid as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() 
																						for i=1, #bt4profiles do
																							if (bt4profiles[i] == db.realm.Dynamics[role].BT4.DRUID) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role].BT4.DRUID = bt4profiles[val]
																				if ((class == "DRUID") and (role == db.profile.ActualRole)) then	DUPDATE = true end
																				module:UpdateOptions("BT4")
																			end,
																			order = 2,
																},
																Hunter = {
																			name = function() 
																						if class == "HUNTER" then 
																							return "|CFF99FF66Hunter Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Hunter Profile|r" 
																						end
																					end,
																			desc = "Select the BarTender Profile you want to use when you're playing a Hunter as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() 
																						for i=1, #bt4profiles do
																							if (bt4profiles[i] == db.realm.Dynamics[role].BT4.HUNTER) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role].BT4.HUNTER = bt4profiles[val]
																				if (class == "HUNTER") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("BT4")
																			end,
																			order = 3,
																},
																Mage = {
																			name = function() 
																						if class == "MAGE" then 
																							return "|CFF99FF66Mage Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Mage Profile|r" 
																						end
																					end,
																			desc = "Select the BarTender Profile you want to use when you're playing a Mage as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() 
																						for i=1, #bt4profiles do
																							if (bt4profiles[i] == db.realm.Dynamics[role].BT4.MAGE) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role].BT4.MAGE = bt4profiles[val]
																				if (class == "MAGE") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("BT4")
																			end,
																			order = 4,
																},
																Paladin = {
																			name = function() 
																						if class == "PALADIN" then 
																							return "|CFF99FF66Paladin Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Paladin Profile|r" 
																						end
																					end,
																			desc = "Select the BarTender Profile you want to use when you're playing a Paladin as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() 
																						for i=1, #bt4profiles do
																							if (bt4profiles[i] == db.realm.Dynamics[role].BT4.PALADIN) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role].BT4.PALADIN = bt4profiles[val]
																				if (class == "PALADIN") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("BT4")
																			end,
																			order = 5,
																},
																Priest = {
																			name = function() 
																						if class == "PRIEST" then 
																							return "|CFF99FF66Priest Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Priest Profile|r" 
																						end
																					end,
																			desc = "Select the BarTender Profile you want to use when you're playing a Priest as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() 
																						for i=1, #bt4profiles do
																							if (bt4profiles[i] == db.realm.Dynamics[role].BT4.PRIEST) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role].BT4.PRIEST = bt4profiles[val]
																				if (class == "PRIEST") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("BT4")
																			end,
																			order = 6,
																},
																Rogue = {
																			name = function() 
																						if class == "ROGUE" then 
																							return "|CFF99FF66Rogue Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Rogue Profile|r" 
																						end
																					end,
																			desc = "Select the BarTender Profile you want to use when you're playing a Rogue as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() 
																						for i=1, #bt4profiles do
																							if (bt4profiles[i] == db.realm.Dynamics[role].BT4.ROGUE) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role].BT4.ROGUE = bt4profiles[val]
																				if (class == "ROGUE") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("BT4")
																			end,
																			order = 7,
																},
																Shaman = {
																			name = function() 
																						if class == "SHAMAN" then 
																							return "|CFF99FF66Shaman Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Shaman Profile|r" 
																						end
																					end,
																			desc = "Select the BarTender Profile you want to use when you're playing a Shaman as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() 
																						for i=1, #bt4profiles do
																							if (bt4profiles[i] == db.realm.Dynamics[role].BT4.SHAMAN) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role].BT4.SHAMAN = bt4profiles[val]
																				if (class == "SHAMAN") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("BT4")
																			end,
																			order = 8,
																},
																Warlock = {
																			name = function() 
																						if class == "WARLOCK" then 
																							return "|CFF99FF66Warlock Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Warlock Profile|r" 
																						end
																					end,
																			desc = "Select the BarTender Profile you want to use when you're playing a Warlock as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() 
																						for i=1, #bt4profiles do
																							if (bt4profiles[i] == db.realm.Dynamics[role].BT4.WARLOCK) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role].BT4.WARLOCK = bt4profiles[val]
																				if (class == "WARLOCK") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("BT4")
																			end,
																			order = 9,
																},
																Warrior = {
																			name = function() 
																						if class == "WARRIOR" then 
																							return "|CFF99FF66Warrior Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Warrior Profile|r" 
																						end
																					end,
																			desc = "Select the BarTender Profile you want to use when you're playing a Warrior as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() 
																						for i=1, #bt4profiles do
																							if (bt4profiles[i] == db.realm.Dynamics[role].BT4.WARRIOR) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role].BT4.WARRIOR = bt4profiles[val]
																				if (class == "WARRIOR") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("BT4")
																			end,
																			order = 10,
																},
																Monk = {
																			name = function() 
																						if class == "MONK" then 
																							return "|CFF99FF66Monk Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Monk Profile|r" 
																						end
																					end,
																			desc = "Select the BarTender Profile you want to use when you're playing a Monk as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() 
																						for i=1, #bt4profiles do
																							if (bt4profiles[i] == db.realm.Dynamics[role].BT4.MONK) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role].BT4.MONK = bt4profiles[val]
																				if (class == "MONK") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("BT4")
																			end,
																			order = 11,
																},
													},
										}, -- BT4Profiles END
									ManageProfiles = {
													name = "Manage BarTender Profiles",
													type = "group",
													disabled = false,
													order = 3,
													guiInline = true,
													args = {
															Description = {
																name = function () 
																		local s ="From Here You can directly manage BarTender Profiles; You can Create, Delete and Copy from another profile.\n"
																		if Bartender4 then 
																			s= s.. "|CFF99CC99Actual Bartender Profile is : ".. Bartender4.db:GetCurrentProfile() .. "|r"
																		end
																		return s
																		end,
																type = "description",
																order = 1,
															},
															NewProfile = {
																name = "New",
																desc = function(info)
																		return ("Create a new Empty Profile")
																	end,
																type = "input",
																order = 2,
																disabled = false,
																get = function(info) return "" end,
																set = function(info, value)
																	if value == nil or value == "" then 
																		print("|CFF99CCFFDynamics|r : |CFFFF3399You need to specify a Name for the New Profile|r") 
																	else
																		local _,exist = module:GetProfilesFor("Bartender4",Bartender4,value)
																		local previousBT4Profile = Bartender4.db:GetCurrentProfile()
																		if not exist then 
																			Bartender4.db:SetProfile(value)
																			Bartender4.db:CopyProfile(previousBT4Profile,true) 
																			print ("|CFF99CCFFDynamics|r : " ..value .." BT4 Profile Created (copied from ".. previousBT4Profile ..").") 
																			Bartender4.db:SetProfile(previousBT4Profile)
																			db.realm.Dynamics[role].BT4[class] = value
																			if (role == db.profile.ActualRole) then	DUPDATE = true end
																			bt4profiles = module:GetProfilesFor("Bartender4",Bartender4)
																		else
																			print("|CFF99CCFFDynamics|r : " ..value .." BT4 Profile Already Exists!") 
																		end
																		module:UpdateOptions("BT4MOD")
																	end
																end,
															},
															CopyProfile = {
																			name = "Copy BarTender Profile to the Actual Role BT Profile.",
																			desc = "Select the BarTender Profile you want to COPY inside your current Role BT Profile.",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() return 1 end,
																			set = function(info, val) 
																				addonToCopy = "Bartender4"
																				profileToCopyFrom = bt4profiles[val]
																				profileToCopyTo = db.realm.Dynamics[role].BT4[class]
																				StaticPopupDialogs["COPYPROFILE"].text = "Can you confirm to |\CFFFFFF00COPY|r the |CFF9999FF".. 
																															addonToCopy .."|r Profile : |CFF99CCFF"..profileToCopyFrom ..
																															"|r\nTo the Profile : |CFF99CCFF" .. profileToCopyTo .." |r?"
																				StaticPopup_Show("COPYPROFILE")
																				currentRoleOptionsSelected = role
																			end,
																			order = 3,
																		},
															DeleteProfile = {
																			name = "Delete BarTender Profile",
																			desc = "Select the BarTender Profile you want to DELETE",
																			type = "select",
																			width = "double",
																			values = bt4profiles,
																			get = function() return 1 end,
																			set = function(info, val) 
																				--module:DeleteProfileFor("Bartender4",bt4profiles[val])
																				addonToDelete = "Bartender4"
																				profileToDelete = bt4profiles[val]
																				StaticPopupDialogs["DELETEPROFILE"].text = "Can you confirm to |CFFFF3333DELETE|r the |CFF9999FF".. 
																															addonToDelete .."|r Profile : |CFF99CCFF"..profileToDelete .."|r"
																				StaticPopup_Show("DELETEPROFILE")
																				currentRoleOptionsSelected = role
																			end,
																			order = 4,
																		},
									
													},
									},
							} -- LUI Details Args End
						}, -- Buttons End
				RaidFrames = {
					name = "Raid Frames Profiles",
					type = "group",
					disabled = not db.profile.ManageRaidFrames,
					order = 6,
					guiInline = false,
					args = {
							Description1 = {
									name = "This Section allows you to manage your current RAID Frame Addon.\n\n"..
											"At the moment, Dynamics manages GRID and Clique. In the next versions VuhDo and Healbot will be managed too.\n"..
											"\n\nExpanding the left RaidFrames menu you will setup the profile you want to use "..
											"to play in solo configurations, 5men istances, 10men,25men and 40men raids.",
									type = "description",
									order = 1,
									},
							Description2 = {
									name = "\n\n You can choose the Grid and Clique Profile for each role (upperRight DropDown Menu), for each party dimension (Left Menu) and for each Class (Right DropDownMenu)"
											.. "",
									type = "description",
									order =2,
							},
							Description3 = {
									name = "\n",
									type = "description",
									order =3,
							},
							Description4 = {
									name = "\n",
									type = "description",
									order =4,
							},
							MEN1 = createRaidFramesOptions("Solo Profiles",1,1,role),
							MEN5 = createRaidFramesOptions("5 Men Profiles",2,5,role),
							MEN10 = createRaidFramesOptions("10 Men Profiles",3,10,role),		
							MEN25 = createRaidFramesOptions("25 Men Profiles",4,25,role),		
							MEN40 = createRaidFramesOptions("40 Men Profiles",5,40,role),	
							CliqueOpt = {
									name = "Clique Profiles",
									type = "group",
									disabled = not IsAddOnLoaded("Clique"),
									order = 10,
									guiInline = false,
									args ={
											Description = {
														name = "Choose the Clique profile that Dynamics will automatically apply when you're Playing as |CFF9999FF".. role .."|r",
														type = "description",
														order = 1,
														},
											CliqueProfiles = {
														name = "Manage Clique Profiles",
														type = "group",
														disabled = false,
														order = 2,
														guiInline = true,
														args = {
																DeathKnight = {
																			name = function() 
																						if class == "DEATHKNIGHT" then 
																							return "|CFF99FF66Death Knight Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Death Knight Profile|r" 
																						end
																					end,
																			desc = "Select the Clique Profile you want to use when you're playing a DeathKnight as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = cliqueprofiles,
																			get = function() 
																						for i=1, #cliqueprofiles do
																							if (cliqueprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["DEATHKNIGHT"]["CLIQUE"]) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["DEATHKNIGHT"]["CLIQUE"] = cliqueprofiles[val]
																				if (class == "DEATHKNIGHT") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("CLIQUE")
																			end,
																			order = 1,
																},
																Druid = {
																			name = function() 
																						if class == "DRUID" then 
																							return "|CFF99FF66Druid Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Druid Profile|r" 
																						end
																					end,
																			desc = "Select the Clique Profile you want to use when you're playing a Druid as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = cliqueprofiles,
																			get = function() 
																						for i=1, #cliqueprofiles do
																							if (cliqueprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["DRUID"]["CLIQUE"]) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["DRUID"]["CLIQUE"] = cliqueprofiles[val]
																				if ((class == "DRUID") and (role == db.profile.ActualRole)) then	DUPDATE = true end
																				module:UpdateOptions("CLIQUE")
																			end,
																			order = 2,
																},
																Hunter = {
																			name = function() 
																						if class == "HUNTER" then 
																							return "|CFF99FF66Hunter Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Hunter Profile|r" 
																						end
																					end,
																			desc = "Select The Clique Profile you want to use when you're playing a Hunter as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = cliqueprofiles,
																			get = function() 
																						for i=1, #cliqueprofiles do
																							if (cliqueprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["HUNTER"]["CLIQUE"]) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["HUNTER"]["CLIQUE"] = cliqueprofiles[val]
																				if (class == "HUNTER") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("CLIQUE")
																			end,
																			order = 3,
																},
																Mage = {
																			name = function() 
																						if class == "MAGE" then 
																							return "|CFF99FF66Mage Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Mage Profile|r" 
																						end
																					end,
																			desc = "Select The Clique Profile you want to use when you're playing a Mage as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = cliqueprofiles,
																			get = function() 
																						for i=1, #cliqueprofiles do
																							if (cliqueprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["MAGE"]["CLIQUE"]) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["MAGE"]["CLIQUE"] = cliqueprofiles[val]
																				if (class == "MAGE") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("CLIQUE")
																			end,
																			order = 4,
																},
																Paladin = {
																			name = function() 
																						if class == "PALADIN" then 
																							return "|CFF99FF66Paladin Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Paladin Profile|r" 
																						end
																					end,
																			desc = "Select The Clique Profile you want to use when you're playing a Paladin as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = cliqueprofiles,
																			get = function() 
																						for i=1, #cliqueprofiles do
																							if (cliqueprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["PALADIN"]["CLIQUE"]) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["PALADIN"]["CLIQUE"] = cliqueprofiles[val]
																				if (class == "PALADIN") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("CLIQUE")
																			end,
																			order = 5,
																},
																Priest = {
																			name = function() 
																						if class == "PRIEST" then 
																							return "|CFF99FF66Priest Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Priest Profile|r" 
																						end
																					end,
																			desc = "Select The Clique Profile you want to use when you're playing a Priest as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = cliqueprofiles,
																			get = function() 
																						for i=1, #cliqueprofiles do
																							if (cliqueprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["PRIEST"]["CLIQUE"]) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["PRIEST"]["CLIQUE"] = cliqueprofiles[val]
																				if (class == "PRIEST") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("CLIQUE")
																			end,
																			order = 6,
																},
																Rogue = {
																			name = function() 
																						if class == "ROGUE" then 
																							return "|CFF99FF66Rogue Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Rogue Profile|r" 
																						end
																					end,
																			desc = "Select The Clique Profile you want to use when you're playing a Rogue as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = cliqueprofiles,
																			get = function() 
																						for i=1, #cliqueprofiles do
																							if (cliqueprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["ROGUE"]["CLIQUE"]) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["ROGUE"]["CLIQUE"] = cliqueprofiles[val]
																				if (class == "ROGUE") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("CLIQUE")
																			end,
																			order = 7,
																},
																Shaman = {
																			name = function() 
																						if class == "SHAMAN" then 
																							return "|CFF99FF66Shaman Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Shaman Profile|r" 
																						end
																					end,
																			desc = "Select The Clique Profile you want to use when you're playing a Shaman as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = cliqueprofiles,
																			get = function() 
																						for i=1, #cliqueprofiles do
																							if (cliqueprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["SHAMAN"]["CLIQUE"]) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["SHAMAN"]["CLIQUE"] = cliqueprofiles[val]
																				if (class == "SHAMAN") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("CLIQUE")
																			end,
																			order = 8,
																},
																Warlock = {
																			name = function() 
																						if class == "WARLOCK" then 
																							return "|CFF99FF66Warlock Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Warlock Profile|r" 
																						end
																					end,
																			desc = "Select The Clique Profile you want to use when you're playing a Warlock as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = cliqueprofiles,
																			get = function() 
																						for i=1, #cliqueprofiles do
																							if (cliqueprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["WARLOCK"]["CLIQUE"]) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["WARLOCK"]["CLIQUE"] = cliqueprofiles[val]
																				if (class == "WARLOCK") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("CLIQUE")
																			end,
																			order = 9,
																},
																Warrior = {
																			name = function() 
																						if class == "WARRIOR" then 
																							return "|CFF99FF66Warrior Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Warrior Profile|r" 
																						end
																					end,
																			desc = "Select The Clique Profile you want to use when you're playing a Warrior as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = cliqueprofiles,
																			get = function() 
																						for i=1, #cliqueprofiles do
																							if (cliqueprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["WARRIOR"]["CLIQUE"]) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["WARRIOR"]["CLIQUE"] = cliqueprofiles[val]
																				if (class == "WARRIOR") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("CLIQUE")
																			end,
																			order = 10,
																},
																Monk = {
																			name = function() 
																						if class == "MONK" then 
																							return "|CFF99FF66Monk Profile (Current CLASS)|r" 
																						else 
																							return "|CFFFFCC33Monk Profile|r" 
																						end
																					end,
																			desc = "Select The Clique Profile you want to use when you're playing a Monk as |CFFCC66FF".. role .. "|r.",
																			type = "select",
																			width = "double",
																			values = cliqueprofiles,
																			get = function() 
																						for i=1, #cliqueprofiles do
																							if (cliqueprofiles[i] == db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["MONK"]["CLIQUE"]) then 
																								return i
																							end
																						end
																						return 1
																						end,
																			set = function(info, val) 
																				db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"]["MONK"]["CLIQUE"] = cliqueprofiles[val]
																				if (class == "MONK") and (role == db.profile.ActualRole) then	DUPDATE = true end
																				module:UpdateOptions("CLIQUE")
																			end,
																			order = 11,
																},
															},
											}, -- cliqueprofiles END
											ManageProfiles = {
															name = "Manage Clique Profiles",
															type = "group",
															disabled = false,
															order = 3,
															guiInline = true,
															args = {
																	Description = {
																		name = function()
																				local s = "From Here You can directly manage Clique Profiles; You can Create, Delete and Copy from another profile.\n"
																				if Clique then
																					s = s .. "|CFF99CC99Actual CLIQUE Profile is : ".. Clique.db:GetCurrentProfile() .. "|r"
																				end
																				return s
																				end,
																		type = "description",
																		order = 1,
																	},
																	NewProfile = {
																			name = "New",
																			desc = function(info)
																					return ("Create a new Empty Profile")
																				end,
																			type = "input",
																			order = 2,
																			disabled = false,
																			get = function(info) return "" end,
																			set = function(info, value)
																				if value == nil or value == "" then 
																					print("|CFF99CCFFDynamics|r : |CFFFF3399You need to specify a Name for the New Profile|r") 
																				else
																					local _,exist = module:GetProfilesFor("Clique",Clique,value)
																					local previousCliqueProfile = Clique.db:GetCurrentProfile()
																					if not exist then 
																						Clique.db:SetProfile(value)
																						Clique.db:CopyProfile(previousCliqueProfile,true) 
																						print ("|CFF99CCFFDynamics|r : " ..value .." BT4 Profile Created (copied from ".. previousCliqueProfile ..").") 
																						Clique.db:SetProfile(previousCliqueProfile)
																						db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"][class]["CLIQUE"] = value
																						if (role == db.profile.ActualRole) then	DUPDATE = true end
																						cliqueprofiles = module:GetProfilesFor("Clique",Clique)
																					else
																						print("|CFF99CCFFDynamics|r : " ..value .." CLIQUE Profile Already Exists!") 
																					end
																					module:UpdateOptions("CLIQUEMOD")
																				end
																			end,
																		},
																	CopyProfile = {
																					name = "Copy Clique Profile to the Actual Role BT Profile.",
																					desc = "Select the Clique Profile you want to COPY inside your current Role CLique Profile.",
																					type = "select",
																					width = "double",
																					values = cliqueprofiles,
																					get = function() return 1 end,
																					set = function(info, val) 
																						addonToCopy = "Clique"
																						profileToCopyFrom = cliqueprofiles[val]
																						profileToCopyTo = db.realm.Dynamics[role]["RAIDFRAMES"]["MEN1"][class]["CLIQUE"]
																						StaticPopupDialogs["COPYPROFILE"].text = "Can you confirm to |\CFFFFFF00COPY|r the |CFF9999FF".. 
																																	addonToCopy .."|r Profile : |CFF99CCFF"..profileToCopyFrom ..
																																	"|r\nTo the Profile : |CFF99CCFF" .. profileToCopyTo .." |r?"
																						StaticPopup_Show("COPYPROFILE")
																						currentRoleOptionsSelected = role
																					end,
																					order = 3,
																				},
																	DeleteProfile = {
																					name = "Delete Clique Profile",
																					desc = "Select the Clique Profile you want to DELETE",
																					type = "select",
																					width = "double",
																					values = cliqueprofiles,
																					get = function() return 1 end,
																					set = function(info, val) 
																						addonToDelete = "Clique"
																						profileToDelete = cliqueprofiles[val]
																						StaticPopupDialogs["DELETEPROFILE"].text = "Can you confirm to |CFFFF3333DELETE|r the |CFF9999FF".. 
																																	addonToDelete .."|r Profile : |CFF99CCFF"..profileToDelete .."|r"
																						StaticPopup_Show("DELETEPROFILE")
																						currentRoleOptionsSelected = role
																					end,
																					order = 4,
																				},
																	},
											},
									
									},	
								
							},
						},
				}, -- RaidFrames End
				ForteCooldown = {
					name = "Forte Cooldowns",
					type = "group",
					disabled = not db.profile.ManageForte,
					order = 7,
					guiInline = false,
					args = {
							Description = {
									name = "Here you can Setup for every role the positioning of Forte Cooldown, LUI Top and Bottom texture:",
									type = "description",
									order = 1,
									},
							Cooldown = {
									name = "Forte Cooldown Bar",
									type = "group",
									disabled = false,
									order = 2,
									guiInline = true,
									args ={
										X = {
											name = "X Offset",
											desc = function(info)
													return ("X offset for the Forte Cooldown Bar.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 0\n"..
														"|CFFCCFF66Actual LUI: " .. Forte.db.profile.Cooldown.PaddingX or "" .."|r\n"
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.COOLDOWN.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.COOLDOWN.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Y = {
											name = "Y Offset",
											desc = function(info)
													return ("Y offset for the Forte Cooldown Bar.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 120\n"..
														"|CFFCCFF66Actual LUI: " .. Forte.db.profile.Cooldown.PaddingY .."|r\n"
													)
												end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.COOLDOWN.Y or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.COOLDOWN.Y = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										WIDTH = {
											name = "Width",
											desc = function(info)
													return ("Width for the Forte Cooldown Bar.\n\n" ..
														"Default: 780\n"..
														"|CFFCCFF66Actual LUI: " .. FW.Settings.Cooldown.Instances[1].Width .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "full",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.COOLDOWN.WIDTH or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.COOLDOWN.WIDTH = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										HEIGHT = {
											name = "Height",
											desc = function(info)
													return ("Height for the Forte Cooldown Bar.\n\n" ..
														"Default: 780\n"..
														"|CFFCCFF66Actual LUI: " .. FW.Settings.Cooldown.Instances[1].Height .."|r\n"
													)
												end,
											type = "input",
											order = 4,
											width = "full",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.COOLDOWN.HEIGHT or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.COOLDOWN.HEIGHT = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
									},
								},
							TopTexture = {
									name = "LUI Forte TopTexture",
									type = "group",
									disabled = false,
									order = 3,
									guiInline = true,
									args ={
										X = {
											name = "X Offset",
											desc = function(info)
													return ("X offset for the LUI Forte TopTexture.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 0\n"..
														"|CFFCCFF66Actual LUI: " .. LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].TopTexture.X .."|r\n"
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.TOPTEXTURE.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.TOPTEXTURE.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Y = {
											name = "Y Offset",
											desc = function(info)
													return ("Y offset for the LUI Forte TopTexture..\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 140\n"..
														"|CFFCCFF66Actual LUI: " .. LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].TopTexture.Y .."|r\n"
													)
												end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.TOPTEXTURE.Y or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.TOPTEXTURE.Y = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										ANIMHEIGHT = {
											name = "Animation Height",
											desc = function(info)
													return ("Height for the LUI TopTexture Animation.\n\n" ..
														"Default: 35\n"..
														"|CFFCCFF66Actual LUI: " .. LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].TopTexture.AnimationHeight .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.TOPTEXTURE.AnimationHeight or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.TOPTEXTURE.AnimationHeight = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Alpha = {
												name = "Alpha",
												desc = function(info)
														return ("Transparency for the LUI Forte TopTexture.\n\n|CFFCCCCFFDefault |r: 0.75")
													end,
												type = "range",
												disabled = false,
												order = 4,
												min = 0,
												max = 1,
												step = 0.05,
												get = function(info) return db.realm.Dynamics[role].FORTE.TOPTEXTURE.Alpha or 1 end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].FORTE.TOPTEXTURE.Alpha = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("FORTE")
												end,
										},
										
										
										
									},
								},
							BottomTexture = {
									name = "LUI Forte BottomTexture",
									type = "group",
									disabled = false,
									order = 4,
									guiInline = true,
									args ={
										X = {
											name = "X Offset",
											desc = function(info)
													return ("X offset for the LUI Forte BottomTexture.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 0\n"..
														"|CFFCCFF66Actual LUI: " .. LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].BottomTexture.X .."|r\n"
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.BOTTOMTEXTURE.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.BOTTOMTEXTURE.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Y = {
											name = "Y Offset",
											desc = function(info)
													return ("Y offset for the LUI Forte BottomTexture..\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: -25\n"..
														"|CFFCCFF66Actual LUI: " .. LUIDB.namespaces.Bars.profiles[LUI.db:GetCurrentProfile()].BottomTexture.Y .."|r\n"
													)
												end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.BOTTOMTEXTURE.Y or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.BOTTOMTEXTURE.Y = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Alpha = {
												name = "Alpha",
												desc = function(info)
														return ("Transparency for the LUI Forte BottomTexture.\n\n|CFFCCCCFFDefault |r: 0.75")
													end,
												type = "range",
												disabled = false,
												order = 4,
												min = 0,
												max = 1,
												step = 0.05,
												get = function(info) return db.realm.Dynamics[role].FORTE.BOTTOMTEXTURE.Alpha or 1 end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].FORTE.BOTTOMTEXTURE.Alpha = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("FORTE")
												end,
										},
									},
								},
					} -- LUI Details Args End
				}, -- ForteCooldown End
				ForteTimers = {
					name = "Forte Timers",
					type = "group",
					disabled = not db.profile.ManageForte,
					order = 8,
					guiInline = false,
					args = {
							Description = {
									name = "In this Section you can setup the Forte's Timers Positioning for every single role.\n\n"..
											"To make this section to work correctly you need to have timers and Splash enabled in LUI Forte Module.",
									type = "description",
									order = 1,
									},
							CooldownSplash = {
									name = "Forte Cooldown Splash",
									type = "group",
									disabled = false,
									order = 2,
									guiInline = true,
									args ={
										X = {
											name = "X Offset",
											desc = function(info)
													return ("X offset for the Forte Cooldown Splash.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 0\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Forte.db.profile.Splash.PaddingX .."|r\n"
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.COOLDOWNSPLASH.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.COOLDOWNSPLASH.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Y = {
											name = "Y Offset",
											desc = function(info)
													return ("Y offset for the Forte Cooldown Splash.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 250\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Forte.db.profile.Splash.PaddingY .."|r\n"
													)
												end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.COOLDOWNSPLASH.Y or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.COOLDOWNSPLASH.Y = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										SCALE = {
											name = "Scale",
											desc = function(info)
													return ("Width for the Forte Cooldown Bar.\n\n" ..
														"Default: 780\n"..
														"|CFFCCFF66Actual Forte: " .. FW.Settings.Splash.Instances[1].Scale .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "full",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.COOLDOWNSPLASH.SCALE or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.COOLDOWNSPLASH.SCALE = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
									},
								},
							TimersPlayer = {
									name = "Forte Player Timers",
									type = "group",
									disabled = false,
									order = 3,
									guiInline = true,
									args ={
										ENABLE= {
																			name = "Enable",
																			desc = "If Checked, Forte Player Timers will be displayed",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].FORTE.PLAYER.Enable or false end,
																			set = function(info, value)
																				 db.realm.Dynamics[role].FORTE.PLAYER.Enable = value
																				module:UpdateOptions("FORTE")
																			end,
																			order = 1,
										},
										X = {
											name = "X Offset",
											desc = function(info)
													return ("X offset for the Forte Player Timer.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 0\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Forte.db.profile.Player.PaddingX .."|r\n"
													)
												end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.PLAYER.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.PLAYER.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Y = {
											name = "Y Offset",
											desc = function(info)
													return ("Y offset for the Forte Player Timer.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 250\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Forte.db.profile.Player.PaddingY .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.PLAYER.Y or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.PLAYER.Y = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Alpha = {
												name = "Alpha",
												desc = function(info)
														return ("Transparency for the Forte Player Timer.\n\n|CFFCCCCFFDefault |r: 1")
													end,
												type = "range",
												disabled = false,
												order = 4,
												min = 0,
												max = 1,
												step = 0.05,
												get = function(info) return db.realm.Dynamics[role].FORTE.PLAYER.ALPHA or 1 end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].FORTE.PLAYER.ALPHA = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("FORTE")
												end,
										},
										ExpandUp= {
																			name = "Grow Up",
																			desc = "If Checked, Forte Player Timers will grow upwards. Otherwise it will grow downwards.",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].FORTE.PLAYER.EXPANDUP or false end,
																			set = function(info, value)
																				 db.realm.Dynamics[role].FORTE.PLAYER.EXPANDUP = value
																				module:UpdateOptions("FORTE")
																			end,
																			order = 5,
										},
										
									},
								},
							TimersTarget = {
									name = "Forte Target Timers",
									type = "group",
									disabled = false,
									order = 4,
									guiInline = true,
									args ={
										ENABLE= {
																			name = "Enable",
																			desc = "If Checked, Forte Target Timers will be displayed",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].FORTE.TARGET.Enable or false end,
																			set = function(info, value)
																				 db.realm.Dynamics[role].FORTE.TARGET.Enable = value
																				module:UpdateOptions("FORTE")
																			end,
																			order = 1,
										},
										X = {
											name = "X Offset",
											desc = function(info)
													return ("X offset for the Forte Target Timer.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 0\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Forte.db.profile.Target.PaddingX .."|r\n"
													)
												end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.TARGET.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.TARGET.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Y = {
											name = "Y Offset",
											desc = function(info)
													return ("Y offset for the Forte Target Timer.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 250\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Forte.db.profile.Target.PaddingY .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.TARGET.Y or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.TARGET.Y = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										WIDTH = {
											name = "Width",
											desc = function(info)
													return ("Width for the Forte Target Timer.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 250\n"..
														"|CFFCCFF66Actual LUI: " .. FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Target",FW.Settings.Timer,1)].Width .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.TARGET.WIDTH or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.TARGET.WIDTH = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										HEIGHT = {
											name = "Height",
											desc = function(info)
													return ("Height for the Forte Target Timer.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 250\n"..
														"|CFFCCFF66Actual LUI: " .. FW.Settings.Timer.Instances[FW:InstanceNameToIndex("Target",FW.Settings.Timer,1)].Height .."|r\n"
													)
												end,
											type = "input",
											order = 4,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.TARGET.HEIGHT or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.TARGET.HEIGHT = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Alpha = {
												name = "Alpha",
												desc = function(info)
														return ("Transparency for the Forte Target Timer.\n\n|CFFCCCCFFDefault |r: 1")
													end,
												type = "range",
												disabled = false,
												order = 5,
												min = 0,
												max = 1,
												step = 0.05,
												get = function(info) return db.realm.Dynamics[role].FORTE.TARGET.ALPHA or 1 end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].FORTE.TARGET.ALPHA = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("FORTE")
												end,
										},
										ExpandUp= {
																			name = "Grow Up",
																			desc = "If Checked, Forte Target Timers will grow upwards. Otherwise it will grow downwards.",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].FORTE.TARGET.EXPANDUP or false end,
																			set = function(info, value)
																				 db.realm.Dynamics[role].FORTE.TARGET.EXPANDUP = value
																				module:UpdateOptions("FORTE")
																			end,
																			order = 6,
										},
										OnlyMine= {
												name = "Only My Debuffs",
												desc = "If Checked, Forte Target Timers will show only your debuffs on this Timer. Otherwise it will show all raid debuffs.",
												type = "toggle",
												width = "full",
												get = function() return db.realm.Dynamics[role].FORTE.TARGET.RAIDDEBUFFS or false end,
												set = function(info, value)
													 db.realm.Dynamics[role].FORTE.TARGET.RAIDDEBUFFS = value
													module:UpdateOptions("FORTE")
												end,
												order = 7,
										},
									},
								},
							TimersFocus = {
									name = "Forte Focus Timers",
									type = "group",
									disabled = false,
									order = 5,
									guiInline = true,
									args ={
										ENABLE= {
																			name = "Enable",
																			desc = "If Checked, Forte Focus Timers will be displayed",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].FORTE.FOCUS.Enable or false end,
																			set = function(info, value)
																				 db.realm.Dynamics[role].FORTE.FOCUS.Enable = value
																				module:UpdateOptions("FORTE")
																			end,
																			order = 1,
										},
										X = {
											name = "X Offset",
											desc = function(info)
													return ("X offset for the Forte Focus Timer.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 0\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Forte.db.profile.Focus.PaddingX .."|r\n"
													)
												end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.FOCUS.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.FOCUS.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Y = {
											name = "Y Offset",
											desc = function(info)
													return ("Y offset for the Forte Focus Timer.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 250\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Forte.db.profile.Focus.PaddingY .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.FOCUS.Y or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.FOCUS.Y = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Alpha = {
												name = "Alpha",
												desc = function(info)
														return ("Transparency for the Forte Focus Timer.\n\n|CFFCCCCFFDefault |r: 1")
													end,
												type = "range",
												disabled = false,
												order = 4,
												min = 0,
												max = 1,
												step = 0.05,
												get = function(info) return db.realm.Dynamics[role].FORTE.FOCUS.ALPHA or 1 end,
												set = function(info, value)
													if value == nil or value == "" then value = "1" end
													db.realm.Dynamics[role].FORTE.FOCUS.ALPHA = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("FORTE")
												end,
										},
										ExpandUp= {
																			name = "Grow Up",
																			desc = "If Checked, Forte Focus Timers will grow upwards. Otherwise it will grow downwards.",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].FORTE.FOCUS.EXPANDUP or false end,
																			set = function(info, value)
																				 db.realm.Dynamics[role].FORTE.FOCUS.EXPANDUP = value
																				module:UpdateOptions("FORTE")
																			end,
																			order = 5,
										},
										OnlyMine= {
												name = "Only My Debuffs",
												desc = "If Checked, Forte Focus Timers will show only your debuffs on this Timer. Otherwise it will show all raid debuffs.",
												type = "toggle",
												width = "full",
												get = function() return db.realm.Dynamics[role].FORTE.FOCUS.RAIDDEBUFFS end,
												set = function(info, value)
													 db.realm.Dynamics[role].FORTE.FOCUS.RAIDDEBUFFS = value
													module:UpdateOptions("FORTE")
												end,
												order = 6,
										},
										
									},
								},
							TimersCompact = {
									name = "Forte Compact Timers",
									type = "group",
									disabled = false,
									order = 6,
									guiInline = true,
									args ={
										ENABLE= {
																			name = "Enable",
																			desc = "If Checked, Forte Compact Timers will be displayed",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].FORTE.COMPACT.Enable or false end,
																			set = function(info, value)
																				 db.realm.Dynamics[role].FORTE.COMPACT.Enable = value
																				module:UpdateOptions("FORTE")
																			end,
																			order = 1,
										},
										X = {
											name = "X Offset",
											desc = function(info)
													return ("X offset for the Forte Compact Timer.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 0\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Forte.db.profile.Compact.PaddingX .."|r\n"
													)
												end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.COMPACT.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.COMPACT.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Y = {
											name = "Y Offset",
											desc = function(info)
													return ("Y offset for the Forte Compact Timer.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n" ..
														"Default: 250\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Forte.db.profile.Compact.PaddingY .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,
											get = function(info) return tostring(db.realm.Dynamics[role].FORTE.COMPACT.Y or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].FORTE.COMPACT.Y = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("FORTE")
											end,
										},
										Alpha = {
												name = "Alpha",
												desc = function(info)
														return ("Transparency for the Forte COmpact Timer.\n\n|CFFCCCCFFDefault |r: 1")
													end,
												type = "range",
												disabled = false,
												order = 4,
												min = 0,
												max = 1,
												step = 0.05,
												get = function(info) return db.realm.Dynamics[role].FORTE.COMPACT.ALPHA or 1 end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].FORTE.COMPACT.ALPHA = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("FORTE")
												end,
										},
										ExpandUp= {
																			name = "Grow Up",
																			desc = "If Checked, Forte Compact Timers will grow upwards. Otherwise it will grow downwards.",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].FORTE.COMPACT.EXPANDUP or false end,
																			set = function(info, value)
																				 db.realm.Dynamics[role].FORTE.COMPACT.EXPANDUP = value
																				module:UpdateOptions("FORTE")
																			end,
																			order = 5,
										},
										OnlyMine= {
																			name = "Only My Debuffs",
																			desc = "If Checked, Forte Compact Timers will show only your debuffs on this Timer. Otherwise it will show all raid debuffs.",
																			type = "toggle",
																			width = "full",
																			get = function() return db.realm.Dynamics[role].FORTE.COMPACT.RAIDDEBUFFS or false end,
																			set = function(info, value)
																				 db.realm.Dynamics[role].FORTE.COMPACT.RAIDDEBUFFS = not value
																				module:UpdateOptions("FORTE")
																			end,
																			order = 6,
										},
										Anchor = {
											name = "Anchor",
											desc = "Choose if you want the Forte Compact Timers Anchored to Left or Right Side of the Screen.",
											type = "select",
											width = "half",
											values = {"LEFT", "RIGHT"},
											get = function(info) if db.realm.Dynamics[role].FORTE.COMPACT.Anchor =="LEFT" then return 1 else return 2 end end,
											set = function(info, val) 
												if val == 1 then db.realm.Dynamics[role].FORTE.COMPACT.Anchor = "LEFT"
												else db.realm.Dynamics[role].FORTE.COMPACT.Anchor = "RIGHT"
												end
												if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("FORTE")
												end,
											order = 7,
										},						
									},
								},
					} -- LUI Details Args End
				}, -- ForteTimers End
				DynamicChat = {
					name = "Dynamic Chat",
					type = "group",
					disabled = not db.profile.ManageChat,
					order = 9,
					guiInline = false,
					args = {
							Description = {
									name = "In this Section You can choose how the Chat Windows should appear on the base of your role (Healer,Tank,Melee or Ranged).\n\n"
											.. "You need to ENABLE LUI Chat module to use this section" ,
									type = "description",
									order = 1,
									},
							LEFTCHAT = {
								name = "LEFT Chat Windows Settings" ,
								type = "group",
								disabled =LUI.modules.Chat and true, -- and (not LUI.modules.Chat.db.profile.Chat.Enable),
								order = 2,
								guiInline = true,
								args = {
										Desc = {
												name = "Set the position and dimension of the LEFT Chat and how many Windows you want on Left Side.",
												type = "description",
												order = 1,
										},
										X = {
												name = "X Offset",
												desc = function(info)
														return ("X offset for left Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFFCCFF66Actual LUI: " .. LUI.modules.Chat.db.profile.Chat.X or 28 .."|r\n\n\n"..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.LEFTCHAT.X .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.LEFTCHAT.X .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.LEFTCHAT.X .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.LEFTCHAT.X .."|r\n"
														)
													end,
												type = "input",
												order = 2,
												width = "half",
												disabled = false,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.LEFTCHAT.X or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.LEFTCHAT.X = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("CHAT")
													end,
											},
										Y = {
											name = "Y Offset",
												desc = function(info)
														return ("Y offset for left Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFFCCFF66Actual LUI: " .. LUI.modules.Chat.db.profile.Chat.Y or 46 .."|r\n\n\n"..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.LEFTCHAT.Y .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.LEFTCHAT.Y .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.LEFTCHAT.Y .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.LEFTCHAT.Y .."|r\n"
														)
													end,
												type = "input",
												order = 3,
												width = "half",
												disabled = false,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.LEFTCHAT.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.LEFTCHAT.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("CHAT")
												end,
								},
										WIDTH = {
												name = "Width",
												desc = function(info)
														return ("Width for Left Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFFCCFF66Actual LUI: " .. LUI.modules.Chat.db.profile.Chat.Width or 404 .."|r\n\n\n"..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.LEFTCHAT.WIDTH .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.LEFTCHAT.WIDTH .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.LEFTCHAT.WIDTH .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.LEFTCHAT.WIDTH .."|r\n"
														)
													end,
												type = "input",
												order = 4,
												width = "half",
												disabled = false,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.LEFTCHAT.WIDTH or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.LEFTCHAT.WIDTH = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("CHAT")
													end,
											},
										HEIGHT = {
												name = "Height",
												desc = function(info)
														return ("Height for Left Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFFCCFF66Actual LUI: " .. LUI.modules.Chat.db.profile.Chat.Height or 175 .."|r\n\n\n"..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.LEFTCHAT.HEIGHT .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.LEFTCHAT.HEIGHT .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.LEFTCHAT.HEIGHT .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.LEFTCHAT.HEIGHT .."|r\n"
														)
													end,
												type = "input",
												order = 5,
												width = "half",
												disabled = false,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.LEFTCHAT.HEIGHT or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.LEFTCHAT.HEIGHT = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("CHAT")
													end,
											},
										LEFTCHATFRAMES = {
													name = "Chat Windows on Left Side" ,
													type = "group",
													disabled = false,
													order = 6,
													guiInline = true,
													args = {
															-- FRAME1 = {
																	-- name = ChatFrame1.name or "Chat 1",
																	-- desc = "If Checked, the ".. ChatFrame1.name .. " Window will be positioned on LEFT Chat.Otherwise Hided.",
																	-- type = "toggle",
																	-- width = "half",
																	-- get = function() return db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME1 end,
																	-- set = function(info, value)
																		-- db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME1 = value
																		-- --toggleDynamicsRolesOptions("BossModsProfiles",value)
																		-- module:UpdateOptions("CHAT")
																	-- end,
																	-- order = 1,
															-- },
															FRAME2 = {
																	name = ChatFrame2.name or "Chat 2",
																	desc = "If Checked, the ".. ChatFrame2.name  .. " Window will be positioned on LEFT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME2 end,
																	set = function(info, value)
																		db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME2 = value
																		--toggleDynamicsRolesOptions("BossModsProfiles",value)
																		module:UpdateOptions("CHAT")
																	end,
																	order = 2,
															},
															FRAME3 = {
																	name = ChatFrame3.name or "Chat 3",
																	desc = "If Checked, the ".. ChatFrame3.name.. " Window will be positioned on LEFT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME3  end,
																	set = function(info, value)
																		db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME3 = value
																		--toggleDynamicsRolesOptions("BossModsProfiles",value)
																		module:UpdateOptions("CHAT")
																	end,
																	order = 3,
															},
															FRAME4 = {
																	name = ChatFrame4.name or "Chat 1",
																	desc = "If Checked, the ".. ChatFrame4.name .. " Window will be positioned on LEFT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME4  end,
																	set = function(info, value)
																		db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME4 = value
																		--toggleDynamicsRolesOptions("BossModsProfiles",value)
																		module:UpdateOptions("CHAT")
																	end,
																	order = 4,
															},
															FRAME5 = {
																	name = ChatFrame5.name or "Chat 5",
																	desc = "If Checked, the ".. ChatFrame5.name.. " Window will be positioned on LEFT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME5   end,
																	set = function(info, value)
																		db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME5 = value
																		--toggleDynamicsRolesOptions("BossModsProfiles",value)
																		module:UpdateOptions("CHAT")
																	end,
																	order = 5,
															},
															FRAME6 = {
																	name = ChatFrame6.name or "Chat 6",
																	desc = "If Checked, the ".. ChatFrame6.name .. " Window will be positioned on LEFT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME6   end,
																	set = function(info, value)
																		db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME6 = value
																		--toggleDynamicsRolesOptions("BossModsProfiles",value)
																		module:UpdateOptions("CHAT")
																	end,
																	order = 6,
															},
															FRAME7 = {
																	name = ChatFrame7.name or "Chat 7",
																	desc = "If Checked, the ".. ChatFrame7.name .. " Window will be positioned on LEFT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME7   end,
																	set = function(info, value)
																		db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME7 = value
																		--toggleDynamicsRolesOptions("BossModsProfiles",value)
																		module:UpdateOptions("CHAT")
																	end,
																	order = 7,
															},
															FRAME8 = {
																	name = ChatFrame8.name or "Chat 8",
																	desc = "If Checked, the ".. ChatFrame8.name .. " Window will be positioned on LEFT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME8   end,
																	set = function(info, value)
																		db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME8 = value
																		--toggleDynamicsRolesOptions("BossModsProfiles",value)
																		module:UpdateOptions("CHAT")
																	end,
																	order = 8,
															},
															FRAME9 = {
																	name = ChatFrame9.name or "Chat 9",
																	desc = "If Checked, the ".. ChatFrame9.name .. " Window will be positioned on LEFT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME9   end,
																	set = function(info, value)
																		db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME9 = value
																		--toggleDynamicsRolesOptions("BossModsProfiles",value)
																		module:UpdateOptions("CHAT")
																	end,
																	order = 9,
															},
															FRAME10= {
																	name = ChatFrame10.name or "Chat 10",
																	desc = "If Checked, the ".. ChatFrame10.name .. " Window will be positioned on LEFT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME10   end,
																	set = function(info, value)
																		db.realm.Dynamics[role].CHAT.LEFTCHAT.WINDOWS.FRAME10 = value
																		--toggleDynamicsRolesOptions("BossModsProfiles",value)
																		module:UpdateOptions("CHAT")
																	end,
																	order = 10,
															},
													},
										},
										LUIX = {
												name = "LUI BackGround X Offset",
												desc = function(info)
														return ("LUI BackGround X offset for left Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFFCCFF66Actual LUI: " .. LUI.modules.Panels.db.Chat.OffsetX or 28 .."|r\n\n\n"..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.LEFTCHAT.LUITEXTURE.X .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.LEFTCHAT.LUITEXTURE.X .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.LEFTCHAT.LUITEXTURE.X .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.LEFTCHAT.LUITEXTURE.X .."|r\n"
														)
													end,
												type = "input",
												order = 7,
												width = "half",
												disabled = false,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.LEFTCHAT.LUITEXTURE.X or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.LEFTCHAT.LUITEXTURE.X = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("CHAT")
													end,
											},
										LUIY = {
											name = "LUI BackGround Y Offset",
												desc = function(info)
														return ("LUI BackGround Y offset for left Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFFCCFF66Actual LUI: " .. LUI.modules.Panels.db.Chat.OffsetY or 46 .."|r\n\n\n"..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.LEFTCHAT.LUITEXTURE.Y .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.LEFTCHAT.LUITEXTURE.Y .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.LEFTCHAT.LUITEXTURE.Y .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.LEFTCHAT.LUITEXTURE.Y .."|r\n"
														)
													end,
												type = "input",
												order = 8,
												width = "half",
												disabled = false,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.LEFTCHAT.LUITEXTURE.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.LEFTCHAT.LUITEXTURE.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("CHAT")
												end,
								},
										
										
								},
					
						},
							RIGHTCHAT = {
								name = "RIGHT Chat Windows Settings" ,
								type = "group",
								disabled = LUI.modules.Chat and true,--(not LUI.modules.Chat.db.profile.Chat.Enable) ,
								order = 2,
								guiInline = true,
								args = {
										Desc = {
												name = "Set the position and dimension of the RIGHT Chat and how many Windows you want on Right Side.",
												type = "description",
												order = 1,
										},
										ENABLED = {
											name = "Enabled",
											desc = "If Checked, RIGHT Chat Window will be Enabled.",
											type = "toggle",
											width = "half",
											get = function() return db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.ENABLED end,
											set = function(info, value)
												LUI.modules.Panels.db.Chat.SecondChatFrame = value
												db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.ENABLED = value
												--toggleDynamicsRolesOptions("BossModsProfiles",value)
												module:UpdateOptions("CHAT")
											end,
											order = 2,
									},
										X = {
												name = "X Offset",
												desc = function(info)
														return ("X offset for Right Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.RIGHTCHAT.X .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.RIGHTCHAT.X .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.RIGHTCHAT.X .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.RIGHTCHAT.X .."|r\n"
														)
													end,
												type = "input",
												order = 3,
												width = "half",
												disabled = not db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.ENABLED,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.RIGHTCHAT.X or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.RIGHTCHAT.X = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("CHAT")
													end,
											},
										Y = {
											name = "Y Offset",
												desc = function(info)
														return ("Y offset for Right Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.RIGHTCHAT.Y .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.RIGHTCHAT.Y .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.RIGHTCHAT.Y .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.RIGHTCHAT.Y .."|r\n"
														)
													end,
												type = "input",
												order = 4,
												width = "half",
												disabled = not db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.ENABLED,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.RIGHTCHAT.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.RIGHTCHAT.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("CHAT")
												end,
								},
										WIDTH = {
												name = "Width",
												desc = function(info)
														return ("Width for Right Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.RIGHTCHAT.WIDTH .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.RIGHTCHAT.WIDTH .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.RIGHTCHAT.WIDTH .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.RIGHTCHAT.WIDTH .."|r\n"
														)
													end,
												type = "input",
												order = 5,
												width = "half",
												disabled = not db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.ENABLED,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.RIGHTCHAT.WIDTH or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.RIGHTCHAT.WIDTH = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("BOSSMODS")
													end,
											},
										HEIGHT = {
												name = "Height",
												desc = function(info)
														return ("Height for Right Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.RIGHTCHAT.HEIGHT .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.RIGHTCHAT.HEIGHT .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.RIGHTCHAT.HEIGHT .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.RIGHTCHAT.HEIGHT .."|r\n"
														)
													end,
												type = "input",
												order = 6,
												width = "half",
												disabled = not db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.ENABLED,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.RIGHTCHAT.HEIGHT or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.RIGHTCHAT.HEIGHT = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("BOSSMODS")
													end,
											},
										RIGHTCHATFRAMES = {
													name = "Chat Windows on Right Side" ,
													type = "group",
													disabled = not db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.ENABLED,
													order = 7,
													guiInline = true,
													args = {
															FRAME2 = {
																	name = ChatFrame2.name or "Chat 2",
																	desc = "If Checked, the ".. ChatFrame2.name  .. " Window will be positioned on RIGHT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME2 end,
																	set = function(info, value)
																		if value then 
																			for i=1,10 do 
																				db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS["FRAME"..i] = false	
																			end
																			db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME2 = true
																		else db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME2 = false
																		end
																		module:UpdateOptions("CHAT")
																	end,
																	order = 2,
															},
															FRAME3 = {
																	name = ChatFrame3.name or "Chat 3",
																	desc = "If Checked, the ".. ChatFrame3.name.. " Window will be positioned on RIGHT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME3  end,
																	set = function(info, value)
																		if value then 
																			for i=1,10 do 
																				db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS["FRAME"..i] = false	
																			end
																			db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME3 = true
																		else db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME3 = false
																		end
																		module:UpdateOptions("CHAT")
																	end,order = 3,
															},
															FRAME4 = {
																	name = ChatFrame4.name or "Chat 1",
																	desc = "If Checked, the ".. ChatFrame4.name .. " Window will be positioned on RIGHT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME4  end,
																	set = function(info, value)
																		if value then 
																			for i=1,10 do 
																				db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS["FRAME"..i] = false	
																			end
																			db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME4 = true
																		else db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME4 = false
																		end
																		module:UpdateOptions("CHAT")
																	end,order = 4,
															},
															FRAME5 = {
																	name = ChatFrame5.name or "Chat 5",
																	desc = "If Checked, the ".. ChatFrame5.name.. " Window will be positioned on RIGHT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME5   end,
																	set = function(info, value)
																		if value then 
																			for i=1,10 do 
																				db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS["FRAME"..i] = false	
																			end
																			db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME5 = true
																		else db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME5 = false
																		end
																		module:UpdateOptions("CHAT")
																	end,order = 5,
															},
															FRAME6 = {
																	name = ChatFrame6.name or "Chat 6",
																	desc = "If Checked, the ".. ChatFrame6.name .. " Window will be positioned on RIGHT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME6   end,
																	set = function(info, value)
																		if value then 
																			for i=1,10 do 
																				db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS["FRAME"..i] = false	
																			end
																			db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME6 = true
																		else db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME6 = false
																		end
																		module:UpdateOptions("CHAT")
																	end,order = 6,
															},
															FRAME7 = {
																	name = ChatFrame7.name or "Chat 7",
																	desc = "If Checked, the ".. ChatFrame7.name .. " Window will be positioned on RIGHT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME7   end,
																	set = function(info, value)
																		if value then 
																			for i=1,10 do 
																				db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS["FRAME"..i] = false	
																			end
																			db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME7 = true
																		else db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME7 = false
																		end
																		module:UpdateOptions("CHAT")
																	end,order = 7,
															},
															FRAME8 = {
																	name = ChatFrame8.name or "Chat 8",
																	desc = "If Checked, the ".. ChatFrame8.name .. " Window will be positioned on RIGHT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME8   end,
																	set = function(info, value)
																		if value then 
																			for i=1,10 do 
																				db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS["FRAME"..i] = false	
																			end
																			db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME8 = true
																		else db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME8 = false
																		end
																		module:UpdateOptions("CHAT")
																	end,order = 8,
															},
															FRAME9 = {
																	name = ChatFrame9.name or "Chat 9",
																	desc = "If Checked, the ".. ChatFrame9.name .. " Window will be positioned on RIGHT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME9   end,
																	set = function(info, value)
																		if value then 
																			for i=1,10 do 
																				db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS["FRAME"..i] = false	
																			end
																			db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME9 = true
																		else db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME9 = false
																		end
																		module:UpdateOptions("CHAT")
																	end,order = 9,
															},
															FRAME10= {
																	name = ChatFrame10.name or "Chat 10",
																	desc = "If Checked, the ".. ChatFrame10.name .. " Window will be positioned on RIGHT Chat.Otherwise Hided.",
																	type = "toggle",
																	width = "half",
																	get = function() return db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME10   end,
																	set = function(info, value)
																		if value then 
																			for i=1,10 do 
																				db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS["FRAME"..i] = false	
																			end
																			db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME10 = true
																		else db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.FRAME10 = false
																		end
																		module:UpdateOptions("CHAT")
																	end,order = 10,
															},
													},
										},
										LUIX = {
												name = "LUI BackGround X Offset",
												desc = function(info)
														return ("LUI BackGround X offset for Right Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFFCCFF66Actual LUI: " .. LUI.modules.Panels.db.Chat2.OffsetX or 28 .."|r\n\n\n"..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.RIGHTCHAT.LUITEXTURE.X .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.RIGHTCHAT.LUITEXTURE.X .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.RIGHTCHAT.LUITEXTURE.X .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.RIGHTCHAT.LUITEXTURE.X .."|r\n"
														)
													end,
												type = "input",
												order = 8,
												width = "half",
												disabled = not db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.ENABLED,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.RIGHTCHAT.LUITEXTURE.X or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.RIGHTCHAT.LUITEXTURE.X = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("CHAT")
													end,
											},
										LUIY = {
											name = "LUI BackGround Y Offset",
												desc = function(info)
														return ("Y offset for Right Chat.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n" ..
															"|CFFCCFF66Actual LUI: " .. LUI.modules.Panels.db.Chat2.OffsetY or 46 .."|r\n\n\n"..
															"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.RIGHTCHAT.LUITEXTURE.Y .."|r\n"..
															"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.RIGHTCHAT.LUITEXTURE.Y .."|r\n"..
															"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.RIGHTCHAT.LUITEXTURE.Y .."|r\n"..
															"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.RIGHTCHAT.LUITEXTURE.Y .."|r\n"
														)
													end,
												type = "input",
												order = 9,
												width = "half",
												disabled = not db.realm.Dynamics[role].CHAT.RIGHTCHAT.WINDOWS.ENABLED,
												get = function(info) return tostring(db.realm.Dynamics[role].CHAT.RIGHTCHAT.LUITEXTURE.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].CHAT.RIGHTCHAT.LUITEXTURE.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("CHAT")
												end,
								},
										
										
								},
					
						},
							WINDOWS = {
								name = "Chat Windows" ,
								type = "group",
								disabled = false,
								order = 3,
								guiInline = false,
								args = {
									Desc = {
												name = "Here you can change some general Chat Settings and some ChatFrames Parameters.",
												type = "description",
												order = 1,
										},
									GENERAL = {
										name = "All Windows Frames Settings" ,
										type = "group",
										disabled = false,
										order = 2,
										guiInline = true,
										args = {
												FONTSIZE = {
													name = "Font Size",
													desc = function(info)
															return ("Font Size for ALL ChatFrames.\n\n" ..
																"|CFFCCFF66Actual LUI: " .. LUI.db.profile.Chat.Size or 11 .."|r\n\n\n"..
																"|CFF99FF99Actual Healer Role: " .. db.realm.Dynamics["Healer"].CHAT.fontSize .."|r\n"..
																"|CFF996633Actual Tank Role: " .. db.realm.Dynamics["Tank"].CHAT.fontSize .."|r\n"..
																"|CFFFF3366Actual Melee Role: " .. db.realm.Dynamics["Melee"].CHAT.fontSize .."|r\n"..
																"|CFF99CCFFActual Ranged Role: " .. db.realm.Dynamics["Ranged"].CHAT.fontSize .."|r\n"
															)
														end,
													type = "input",
													order = 1,
													width = "half",
													disabled = false,
													get = function(info) return tostring(db.realm.Dynamics[role].CHAT.fontSize or 0) end,
													set = function(info, value)
														if value == nil or value == "" then value = "0" end
														db.realm.Dynamics[role].CHAT.fontSize = tonumber(value) -- Store in the Realm Role DB
														if (role == db.profile.ActualRole) then	DUPDATE = true end
														module:UpdateOptions("CHAT")
														end,
												},
										
										},
									},
									CHATFRAMES = {
										name = "Chat Frames Names" ,
										type = "group",
										disabled = false,
										order = 3,
										guiInline = true,
										args = {
												Desc = {
												name = "To be developed...",
												type = "description",
												order = 1,
												},
												-- FR1 = {
													-- name = "Frame1 Name",
													-- desc = function(info)
															-- return ("Frame1 Name.\n\n" ..
																-- "|CFFCCFF66Actual LUI: " .. ChatFrame1.name .."|r\n\n\n"..
																-- "|CFF99FF99Actual Healer Role: " .. tostring(db.realm.Dynamics["Healer"].CHAT.CHATNAMES.FRAME1) .."|r\n"..
																-- "|CFF996633Actual Tank Role: " .. tostring(db.realm.Dynamics["Tank"].CHAT.CHATNAMES.FRAME1) .."|r\n"..
																-- "|CFFFF3366Actual Melee Role: " .. tostring(db.realm.Dynamics["Melee"].CHAT.CHATNAMES.FRAME1).."|r\n"..
																-- "|CFF99CCFFActual Ranged Role: " .. tostring(db.realm.Dynamics["Ranged"].CHAT.CHATNAMES.FRAME1) .."|r\n"
															-- )
														-- end,
													-- type = "input",
													-- order = 1,
													-- width = "half",
													-- disabled = false,
													-- get = function(info) return tostring(db.realm.Dynamics[role].CHAT.CHATNAMES.FRAME1 or 0) end,
													-- set = function(info, value)
														-- if value == nil or value == "" then value = "0" end
														-- db.realm.Dynamics[role].CHAT.CHATNAMES.FRAME1 = value -- Store in the Realm Role DB
														-- if (role == db.profile.ActualRole) then	DUPDATE = true end
														-- module:UpdateOptions("CHAT")
														-- end,
												-- },
										
										},
									},
								},
							},
					} -- DynamicChat Args End
				}, -- DynamicChat End
				MSBTOptions = {
					name = "MikBarScrollingTexts",
					type = "group",
					disabled = not db.profile.ManageMSBT,
					order = 10,
					guiInline = false,
					args = {
							Description = {
									name = "Choose the MikBarScrollingText profile that Dynamics will automatically apply when you're Playing as |CFF9999FF".. role .."|r",
									type = "description",
									order = 1,
									},
							MSBTProfiles = {
											name = "Manage MSBT Profiles",
											type = "group",
											disabled = false,
											order = 2,
											guiInline = true,
											args = {
														DeathKnight = {
																	name = function() 
																				if class == "DEATHKNIGHT" then 
																					return "|CFF99FF66Death Knight Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Death Knight Profile|r" 
																				end
																			end,
																	desc = "Select the MSBT Profile you want to use when you're playing a DeathKnight as |CFFCC66FF".. role .. "|r.",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() 
																				for i=1, #msbtprofiles do
																					if (msbtprofiles[i] == db.realm.Dynamics[role].MSBT.DEATHKNIGHT) then 
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role].MSBT.DEATHKNIGHT = msbtprofiles[val]
																		if (class == "DEATHKNIGHT") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("MSBT")
																	end,
																	order = 1,
														},
														Druid = {
																	name = function() 
																				if class == "DRUID" then 
																					return "|CFF99FF66Druid Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Druid Profile|r" 
																				end
																			end,
																	desc = "Select the MSBT Profile you want to use when you're playing a Druid as |CFFCC66FF".. role .. "|r.",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() 
																				for i=1, #msbtprofiles do
																					if (msbtprofiles[i] == db.realm.Dynamics[role].MSBT.DRUID) then 
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role].MSBT.DRUID = msbtprofiles[val]
																		if ((class == "DRUID") and (role == db.profile.ActualRole)) then	DUPDATE = true end
																		module:UpdateOptions("MSBT")
																	end,
																	order = 2,
														},
														Hunter = {
																	name = function() 
																				if class == "HUNTER" then 
																					return "|CFF99FF66Hunter Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Hunter Profile|r" 
																				end
																			end,
																	desc = "Select the MSBT Profile you want to use when you're playing a Hunter as |CFFCC66FF".. role .. "|r.",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() 
																				for i=1, #msbtprofiles do
																					if (msbtprofiles[i] == db.realm.Dynamics[role].MSBT.HUNTER) then 
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role].MSBT.HUNTER = msbtprofiles[val]
																		if (class == "HUNTER") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("MSBT")
																	end,
																	order = 3,
														},
														Mage = {
																	name = function() 
																				if class == "MAGE" then 
																					return "|CFF99FF66Mage Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Mage Profile|r" 
																				end
																			end,
																	desc = "Select the MSBT Profile you want to use when you're playing a Mage as |CFFCC66FF".. role .. "|r.",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() 
																				for i=1, #msbtprofiles do
																					if (msbtprofiles[i] == db.realm.Dynamics[role].MSBT.MAGE) then 
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role].MSBT.MAGE = msbtprofiles[val]
																		if (class == "MAGE") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("MSBT")
																	end,
																	order = 4,
														},
														Paladin = {
																	name = function() 
																				if class == "PALADIN" then 
																					return "|CFF99FF66Paladin Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Paladin Profile|r" 
																				end
																			end,
																	desc = "Select the MSBT Profile you want to use when you're playing a Paladin as |CFFCC66FF".. role .. "|r.",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() 
																				for i=1, #msbtprofiles do
																					if (msbtprofiles[i] == db.realm.Dynamics[role].MSBT.PALADIN) then 
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role].MSBT.PALADIN = msbtprofiles[val]
																		if (class == "PALADIN") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("MSBT")
																	end,
																	order = 5,
														},
														Priest = {
																	name = function() 
																				if class == "PRIEST" then 
																					return "|CFF99FF66Priest Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Priest Profile|r" 
																				end
																			end,
																	desc = "Select the MSBT Profile you want to use when you're playing a Priest as |CFFCC66FF".. role .. "|r.",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() 
																				for i=1, #msbtprofiles do
																					if (msbtprofiles[i] == db.realm.Dynamics[role].MSBT.PRIEST) then 
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role].MSBT.PRIEST = msbtprofiles[val]
																		if (class == "PRIEST") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("MSBT")
																	end,
																	order = 6,
														},
														Rogue = {
																	name = function() 
																				if class == "ROGUE" then 
																					return "|CFF99FF66Rogue Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Rogue Profile|r" 
																				end
																			end,
																	desc = "Select the MSBT Profile you want to use when you're playing a Rogue as |CFFCC66FF".. role .. "|r.",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() 
																				for i=1, #msbtprofiles do
																					if (msbtprofiles[i] == db.realm.Dynamics[role].MSBT.ROGUE) then 
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role].MSBT.ROGUE = msbtprofiles[val]
																		if (class == "ROGUE") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("MSBT")
																	end,
																	order = 7,
														},
														Shaman = {
																	name = function() 
																				if class == "SHAMAN" then 
																					return "|CFF99FF66Shaman Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Shaman Profile|r" 
																				end
																			end,
																	desc = "Select the MSBT Profile you want to use when you're playing a Shaman as |CFFCC66FF".. role .. "|r.",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() 
																				for i=1, #msbtprofiles do
																					if (msbtprofiles[i] == db.realm.Dynamics[role].MSBT.SHAMAN) then 
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role].MSBT.SHAMAN = msbtprofiles[val]
																		if (class == "SHAMAN") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("MSBT")
																	end,
																	order = 8,
														},
														Warlock = {
																	name = function() 
																				if class == "WARLOCK" then 
																					return "|CFF99FF66Warlock Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Warlock Profile|r" 
																				end
																			end,
																	desc = "Select the MSBT Profile you want to use when you're playing a Warlock as |CFFCC66FF".. role .. "|r.",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() 
																				for i=1, #msbtprofiles do
																					if (msbtprofiles[i] == db.realm.Dynamics[role].MSBT.WARLOCK) then 
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role].MSBT.WARLOCK = msbtprofiles[val]
																		if (class == "WARLOCK") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("MSBT")
																	end,
																	order = 9,
														},
														Warrior = {
																	name = function() 
																				if class == "WARRIOR" then 
																					return "|CFF99FF66Warrior Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Warrior Profile|r" 
																				end
																			end,
																	desc = "Select the MSBT Profile you want to use when you're playing a Warrior as |CFFCC66FF".. role .. "|r.",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() 
																				for i=1, #msbtprofiles do
																					if (msbtprofiles[i] == db.realm.Dynamics[role].MSBT.WARRIOR) then 
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role].MSBT.WARRIOR = msbtprofiles[val]
																		if (class == "WARRIOR") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("MSBT")
																	end,
																	order = 10,
														},
														Monk = {
																	name = function() 
																				if class == "MONK" then 
																					return "|CFF99FF66Monk Profile (Current CLASS)|r" 
																				else 
																					return "|CFFFFCC33Monk Profile|r" 
																				end
																			end,
																	desc = "Select the MSBT Profile you want to use when you're playing a Monk as |CFFCC66FF".. role .. "|r.",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() 
																				for i=1, #msbtprofiles do
																					if (msbtprofiles[i] == db.realm.Dynamics[role].MSBT.MONK) then 
																						return i
																					end
																				end
																				return 1
																				end,
																	set = function(info, val) 
																		db.realm.Dynamics[role].MSBT.MONK = msbtprofiles[val]
																		if (class == "MONK") and (role == db.profile.ActualRole) then	DUPDATE = true end
																		module:UpdateOptions("MSBT")
																	end,
																	order = 11,
														}, 
											},
								}, -- MSBTProfiles END
							ManageProfiles = {
											name = "Manage MSBT Profiles",
											type = "group",
											disabled = false,
											order = 3,
											guiInline = true,
											args = {
													Description = {
														name = "From Here You can directly manage MSBT Profiles; You can Create, Delete and Copy from another profile.\n"
																.. "|CFF99CC99Actual MSBT Profile is : ".. db.profile.currentMSBTProfile .. "|r",
														type = "description",
														order = 1,
													},
													NewProfile = {
														name = "New",
														desc = function(info)
																return ("Create a new Empty Profile")
															end,
														type = "input",
														order = 2,
														disabled = false,
														get = function(info) return "" end,
														set = function(info, value)
															if value == nil or value == "" then 
																print("|CFF99CCFFDynamics|r : |CFFFF3399You need to specify a Name for the New Profile|r") 
															else
																local _,exist = module:GetProfilesFor("MikScrollingBattleText",MikSBT,value)
																local previousMSBTProfile = db.profile.currentMSBTProfile
																if not exist then 
																	MikSBT.Profiles.CopyProfile(previousMSBTProfile,value) 
																	print ("|CFF99CCFFDynamics|r : " ..value .." MSBT Profile Created (copied from ".. previousMSBTProfile ..").") 
																	MikSBT.Profiles.SelectProfile(previousMSBTProfile)
																	db.realm.Dynamics[role].MSBT[class] = value
																	if (role == db.profile.ActualRole) then	DUPDATE = true end
																	msbtprofiles = module:GetProfilesFor("MikScrollingBattleText",MikSBT)
																else
																	print("|CFF99CCFFDynamics|r : " ..value .." MSBT Profile Already Exists!") 
																end
																module:UpdateOptions("MSBT")
															end
														end,
													},
													-- CopyProfile = {
																	-- name = "Copy MSBT Profile to the Actual Role MSBT Profile.",
																	-- desc = "Select the MSBT Profile you want to COPY inside your current Role MSBT Profile.",
																	-- type = "select",
																	-- width = "double",
																	-- values = msbtprofiles,
																	-- get = function() return 1 end,
																	-- set = function(info, val) 
																		-- addonToCopy = "MikScrollingBattleText"
																		-- profileToCopyFrom = msbtprofiles[val]
																		-- profileToCopyTo = db.realm.Dynamics[role].MSBT[class]
																		-- StaticPopupDialogs["COPYPROFILE"].text = "Can you confirm to |\CFFFFFF00COPY|r the |CFF9999FF".. 
																													-- addonToCopy .."|r Profile : |CFF99CCFF"..profileToCopyFrom ..
																													-- "|r\nTo the Profile : |CFF99CCFF" .. profileToCopyTo .." |r?"
																		-- StaticPopup_Show("COPYPROFILE")
																		-- currentRoleOptionsSelected = role
																	-- end,
																	-- order = 3,
																-- },
													DeleteProfile = {
																	name = "Delete MSBT Profile",
																	desc = "Select the MSBT Profile you want to DELETE",
																	type = "select",
																	width = "double",
																	values = msbtprofiles,
																	get = function() return 1 end,
																	set = function(info, val) 
																		addonToDelete = "MikScrollingBattleText"
																		profileToDelete = msbtprofiles[val]
																		StaticPopupDialogs["DELETEPROFILE"].text = "Can you confirm to |CFFFF3333DELETE|r the |CFF9999FF".. 
																													addonToDelete .."|r Profile : |CFF99CCFF"..profileToDelete .."|r"
																		StaticPopup_Show("DELETEPROFILE")
																		currentRoleOptionsSelected = role
																	end,
																	order = 4,
																},
							
											},
							},
					} -- MSBT Details Args End
				}, -- MSBTOptions End
				MoreOptions = { -- AutoRess, SkullMe, MaxCameraDistance, GarbageCollect,Srti
					name = "UI Enanchements",
					type = "group",
					disabled = false,
					order = 11,
					guiInline = false,
					args = {
							Description = {
									name = "To be developed...",
									type = "description",
									order = 1,
									},
							SkadaDPS = {
									name = "Skada Windows 1 (RIGHT)",
									type = "group",
									disabled = IsAddOnLoaded("Skada") == nil,
									order = 2,
									guiInline = true,
									args ={
										SKADA1X = {
											name = "X Offset",
											desc = function(info)
													return ("X offset for the Skada Windows 1.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n"..
														"|CFFCCFF66Actual LUI: " .. Skada.db.profile.windows[1].x .."|r\n"
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS1.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS1.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("SKADA")
											end,
										},
										SKADA1Y = {
											name = "Y Offset",
											desc = function(info)
														return ("Y offset for the Skada Windows 1.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n"..
															"|CFFCCFF66Actual LUI: " .. Skada.db.profile.windows[1].y .."|r\n"
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS1.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS1.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("SKADA")
												end,
										},
										SKADAB1X = {
											name = "BackGround X Offset",
											desc = function(info)
													return ("X offset for the Skada Windows 1 BackGround.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Panels.db.Dps.OffsetX .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS1.BACKX or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS1.BACKX = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("SKADA")
											end,
										},
										SKADAB1Y = {
											name = "BackGround Y Offset",
											desc = function(info)
														return ("Y offset for the Skada Windows 1 Background.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n"..
															"|CFFCCFF66Actual LUI: " .. LUI.modules.Panels.db.Dps.OffsetY .."|r\n"
														)
													end,
											type = "input",
											order = 4,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS1.BACKY or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS1.BACKY = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("SKADA")
												end,
										},
									},
								},
							SkadaHeal = {
									name = "Skada Windows 2 (LEFT)",
									type = "group",
									disabled = IsAddOnLoaded("Skada") == nil,
									order = 3,
									guiInline = true,
									args ={
										SKADA2X = {
											name = "X Offset",
											desc = function(info)
													return ("X offset for the Skada Windows 1.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n"..
														"|CFFCCFF66Actual LUI: " .. Skada.db.profile.windows[2].x .."|r\n"
															
													)
												end,
											type = "input",
											order = 1,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS2.X or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS2.X = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("SKADA")
											end,
										},
										SKADA2Y = {
											name = "Y Offset",
											desc = function(info)
														return ("Y offset for the " .. "player" .. " info text.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n"..
															"|CFFCCFF66Actual LUI: " .. Skada.db.profile.windows[2].y .."|r\n"
														)
													end,
											type = "input",
											order = 2,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS2.Y or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS2.Y = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("SKADA")
												end,
										},
										SKADAB2X = {
											name = "BackGround X Offset",
											desc = function(info)
													return ("X offset for the Skada Windows 2 BackGround.\n\n" ..
														"Note:\nPositive values = right\nNegative values = left\n\n"..
														"|CFFCCFF66Actual LUI: " .. LUI.modules.Panels.db.Tps.OffsetX .."|r\n"
													)
												end,
											type = "input",
											order = 3,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS2.BACKX or 0) end,
											set = function(info, value)
												if value == nil or value == "" then value = "0" end
												db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS2.BACKX = tonumber(value) -- Store in the Realm Role DB
												if (role == db.profile.ActualRole) then	DUPDATE = true end
												module:UpdateOptions("SKADA")
											end,
										},
										SKADAB2Y = {
											name = "BackGround Y Offset",
											desc = function(info)
														return ("Y offset for the Skada Windows 2 Background.\n\n" ..
															"Note:\nPositive values = right\nNegative values = left\n\n"..
															"|CFFCCFF66Actual LUI: " .. LUI.modules.Panels.db.Tps.OffsetY .."|r\n"
														)
													end,
											type = "input",
											order = 4,
											width = "half",
											disabled = false,--function(info) return not db.profile[statName].Enable end,
											get = function(info) return tostring(db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS2.BACKY or 0) end,
												set = function(info, value)
													if value == nil or value == "" then value = "0" end
													db.realm.Dynamics[role].UIENANCHEMENTS.SKADA.WINDOWS2.BACKY = tonumber(value) -- Store in the Realm Role DB
													if (role == db.profile.ActualRole) then	DUPDATE = true end
													module:UpdateOptions("SKADA")
												end,
										},
									},
								},	
								
					} -- LUI Details Args End
				}, -- MoreOptions End (AutoRess, SkullMe, MaxCameraDistance, GarbageCollect,Srti)
				AutoLUIProfile = {
					name = "LUI AutoProfile (DeV)",
					type = "group",
					disabled = not db.profile.ManageLUIProfile,
					order = 12,
					guiInline = false,
					args = {
							Description = {
									name = "To be developed...",
									type = "description",
									order = 1,
									},
					} -- AutoLUIProfile Args End
				}, -- AutoLUIProfile End
						
			}, -- Args Name End
		}
		 or nil
		
	return option
	
	end
	
	
	self:checkClassRoles(class) --Update CanBeTank,CanBeHealer ... ...
	self:GetBossMods()
	
	local options  = {
		Dynamics = {
			type = "group",
			order = 1,
			name = "Dynamic Interface",
			guiInline = false,
			args = {
				Title = {
					type = "header",
					order = 1,
					name = module:GetName() .. " - ".. version.. " by ".. author,
				},
				Info = {
					name = "",
					type = "group",
					guiInline = true,
					order = 2,
					args = {
						Description = {
							name = "LUI Dynamics totally change on the fly your LUI Interface giving to you the best performance for your WoW role.",
							type = "description",
							order = 1,
						},
						PackExplanation = {
							name = "\n|cff3399ffNotice:|r When you play wow, the interface information should be in the best place in any moment. For example when you're DPS you need to check your DoTs, your Procs having a look to the raid health or debuffs." ..
								"When you're Healer instead, the main information is the Healing Interface even if you need to check Target's Casting and what's happening around you.",
							type = "description",
							order = 2,
						},
						NewAddonPackInfos = {
							name = "\n|cff3399ffNotice:|r LUI Dynamics let you |CFF99CC00Change the way your interface appears on the base of your current role (Tank, Healer, Melee, Caster)|r.\nThis module wants to help players with different roles specs or with many different characters.\nUsing LUI Dynamics, the most important "..
									"Addons will switch profile when you change spec.\n"..
									"You will have different LUI positions.",
							type = "description",
							order = 3,
						},
					},
				},
				DevUTils = {
					name = "Dynamics Settings",
					type = "group",
					guiInline = true,
					order = 3,
					args = {
						ApplyNow = {
							name = function() local s="Apply Dynamics Now!"
									if db.profile.ActualRole then s= "Apply Dynamics Settings for " .. db.profile.ActualRole .." Role" end 
									return s 
									end,
							desc = "Apply the current Dynamics Setup.",
							type = "execute",
							width = "full",
							func = function(info,value)  
										print("|CFF99FF00Dynamics |r: Applyed settings for |CFF9999FF".. db.profile.ActualRole .."|r Role.")
										module:dynamicsUpdateLUI()
										module:dynamicsUpdateBossMods()
										module:dynamicsUpdateBartender()
										module:dynamicsUpdateRaidFrames()
										module:dynamicsUpdateForte()
										module:dynamicsUpdateChat()
										module:dynamicsUpdateMSBT()
										module:dynamicsUpdateSkullMe()
										module:dynamicsUpdateSRTI()
										module:dynamicsUpdateMaxCameraDistance()
										module:dynamicsUpdateGarbageCollection()
										module:dynamicsUpdateAutoRess()
										module:dynamicsUpdateMinimap()
										module:dynamicsUpdateBagnon()
										module:dynamicsUpdateAutoLUIProfile()
										module:dynamicsUpdateSkada()
		
							end,
							order = 1,
						},
					},
				},
				WhatToManage = {
					name = "Dynamics will manage the following Checked Components:",
					type = "group",
					guiInline = true,
					order = 4,
					args = {
						ManageLUI = {
							name = "LUI UnitFrames Positions",
							desc = "If checked, Dynamics will manage the LUI oUF Positions changing it when you change Role.",
							type = "toggle",
							width = "full",
							get = function() return db.profile.ManageLUI or false end,
							set = function(info, value)
								db.profile.ManageLUI = value
								toggleDynamicsRolesOptions("LUIPositions",value)
								toggleDynamicsRolesOptions("LUIDimensions",value)
								toggleDynamicsRolesOptions("LUIDetails",value)
								module:UpdateOptions()
								-- TODO : Eseguire la funzione che applica i settaggi Dinamici  in modo che comprenda o ripristini la parte in oggetto
							end,
							order = 1,
						},
						ManageBossMod = {
							name = "BossMods Layout (DBM,BigWigs,DXE)",
							desc = "If Checked, Dynamics will manage your BigWigs profile switching it when you change Role.",
							type = "toggle",
							width = "full",
							get = function() return db.profile.ManageBossMod or false end,
							set = function(info, value)
								db.profile.ManageBossMod = value
								toggleDynamicsRolesOptions("BossModsProfiles",value)
								module:UpdateOptions()
							end,
							order = 2,
						},
						ManageBartender = {
							name = "BarTender Layout",
							desc = "If Checked, Dynamics will manage your Bartender profile allowing you to have different bar's setup for every Role.",
							type = "toggle",
							width = "full",
							disabled = not IsAddOnLoaded("BarTender4"),
							get = function() return db.profile.ManageBartender or false end,
							set = function(info, value)
								db.profile.ManageBartender = value
								toggleDynamicsRolesOptions("ButtonsProfiles",value)
								module:UpdateOptions()
							end,
							order = 3,
						},
						ManageRaidFrames = {
							name = "RaidFrames Layout (Vuhdo and Healbot to be developed)",
							desc = "If Checked, Dynamics will manage your Raid Frames Addon's profile allowing you to have different Grid, Vuhdo or Healbot setups for every Role.",
							type = "toggle",
							width = "full",
							disabled = false, --not ( IsAddOnLoaded("BigWigs_Core") or IsAddOnLoaded("DBM-Core") or IsAddOnLoaded("DXE") ),
							get = function() return db.profile.ManageRaidFrames or false end,
							set = function(info, value)
								db.profile.ManageRaidFrames = value
								toggleDynamicsRolesOptions("RaidFrames",value)
								module:UpdateOptions()
							end,
							order = 4,
						}, --TODO : disabled conditions
						ManageMSBT = {
							name = "MikBarScrollingText Layout",
							desc = "If Checked, Dynamics will manage your MSBT's profile allowing you to have different incoming, outgoing, static setups for every Role.",
							type = "toggle",
							width = "full",
							disabled = not IsAddOnLoaded("MikScrollingBattleText"),
							get = function() return db.profile.ManageMSBT or false end,
							set = function(info, value)
								db.profile.ManageMSBT = value
								toggleDynamicsRolesOptions("MSBTOptions",value)
								module:UpdateOptions()
							end,
							order = 5,
						},
						ManageForte = {
							name = "Forte Cooldowns and Timers Layout",
							desc = "If Checked, Dynamics will manage your Forte's profile allowing you to have different Cooldowns and Timers Positioning for every Role.",
							type = "toggle",
							width = "full",
							disabled = not IsAddOnLoaded("Forte_Core"),
							get = function() return db.profile.ManageForte or false end,
							set = function(info, value)
								db.profile.ManageForte = value
								toggleDynamicsRolesOptions("ForteCooldown",value)
								toggleDynamicsRolesOptions("ForteTimers",value)
								if db.profile.ManageForte then module:dynamicsUpdateForte() end
								module:UpdateOptions()
							end,
							order = 6,
						},
						ManageChat = {
							name = "Left and Right Chat's Layout",
							desc = "If Checked, Dynamics will manage your Chat Windows positions allowing you to have different setups for every Role.",
							type = "toggle",
							width = "full",
							disabled = false,
							get = function() return db.profile.ManageChat or false end,
							set = function(info, value)
								db.profile.ManageChat = value
								toggleDynamicsRolesOptions("DynamicChat",value)
								module:UpdateOptions()
							end,
							order = 6,
						},
						
					},
				
				},
				GeneralEnanchements = {
					name = "General Enanchements",
					type = "group",
					guiInline = true,
					order = 5,
					args = {
						ManageMaxCameraDistance = {
							name = "Max Camera Distance",
							desc = "Force the Camera Distance always to MAX range.\n\n Actual Value is ".. GetCVar("cameradistancemaxfactor"),
							type = "toggle",
							width = "15",--"full",
							disabled = false,
							get = function() return db.profile.ManageMaxCameraDistance or false end,
							set = function(info, value)
								db.profile.ManageMaxCameraDistance = value
								if db.profile.ManageMaxCameraDistance then module:dynamicsUpdateMaxCameraDistance() end
								module:UpdateOptions()
							end,
							order = 1,
						},
						ManageGarbageCollection = {
							name = "Keep Garbage Collection",
							desc = "Force the addon to Collect Addons Garbage entering world",
							type = "toggle",
							width = "15",--"full",
							disabled = false,
							get = function() return db.profile.ManageGarbageCollection or false end,
							set = function(info, value)
								db.profile.ManageGarbageCollection = value
								module:dynamicsUpdateGarbageCollection()
								module:UpdateOptions()
							end,
							order = 2,
						},
						ManageAutoRess = {
							name = "AutoRezz Function",
							desc = "Enable the Auto Accept Resurrection Mode.",
							type = "toggle",
							width = "15",--"full",
							disabled = false,
							get = function() return db.profile.ManageAutoRess or false end,
							set = function(info, value)
								db.profile.ManageAutoRess = value
								module:UpdateOptions()
							end,
							order = 3,
						},
						ManageMinimap = {
							name = "Always Hide Minimap",
							desc = "Keep Minimap Hidden.",
							type = "toggle",
							width = "15",--"full",
							disabled = false,
							get = function() return db.profile.ManageMinimap or false end,
							set = function(info, value)
								db.profile.ManageMinimap = value
								MinimapAlphaOut:Show()
								LUI.db.profile.Frames.IsMinimapShown = false
								module:UpdateOptions("MINIMAP")
							end,
							order = 4,
						},
						ManageBagnon = {
							name = "Bagnon Background ClassColor",
							desc = "Auto Apply Class Colors to the Bagnon windows.",
							type = "toggle",
							width = "15",--"full",
							disabled = not IsAddOnLoaded("Bagnon"),
							get = function() return db.profile.ManageBagnon or false end,
							set = function(info, value)
								db.profile.ManageBagnon = value
								module:dynamicsUpdateBagnon()
								module:UpdateOptions("BAGNON")
							end,
							order = 5,
						},
						ManageLUIProfile = {
							name = "AutoSet LUI profile (to be developed)",
							desc = "On Entering WoW, AutoSet LUI CLASSNAMED profile (Ex. Priest, Hunnter, Paladin...)",
							type = "toggle",
							width = "15",--"full",
							disabled = false,
							get = function() return db.profile.ManageLUIProfile or false end,
							set = function(info, value)
								db.profile.ManageLUIProfile = value
								toggleDynamicsRolesOptions("AutoLUIProfile",value)
								module:UpdateOptions()
							end,
							order = 6,
						},
						ManageSkada = {
							name = "AutoSet Skada Windows Positioning",
							desc = "On Entering WoW, AutoSet Skada Windows Positions",
							type = "toggle",
							width = "15",--"full",
							disabled = false,
							get = function() return db.profile.ManageSkada or false end,
							set = function(info, value)
								db.profile.ManageSkada = value
								toggleDynamicsRolesOptions("ManageSkada",value)
								module:UpdateOptions("SKADA")
							end,
							order = 7,
						},
						ManageSkullMe = {
							name = "SkullMe Activation",
							desc = "If Checked, Dynamics will manage the SkullMe Activation for Tank Role. If You're playing in a different Role, Skull me will be disabled.",
							type = "toggle",
							width = "15",
							disabled = not IsAddOnLoaded("Skull Me"),
							get = function() return db.profile.ManageSkullMe or false end,
							set = function(info, value)
								db.profile.ManageSkullMe = value
								module:UpdateOptions("SKULLME")
							end,
							order = 8,
						},
						ManageSRTI = {
							name = "SRTI Layout",
							desc = "If Checked, Dynamics will change some SRTI Parameters like single OnHover and DoubleClick on Hover selection.",
							type = "toggle",
							width = "15",
							disabled = not IsAddOnLoaded("SimpleRaidTargetIcons"),
							get = function() return db.profile.ManageSRTI or false end,
							set = function(info, value)
								db.profile.ManageSRTI = value
								module:dynamicsUpdateSRTI()
								module:UpdateOptions("SRTI")
							end,
							order = 9,
						},
					},
				
				},
				RaidSwitch = {
					name = "Define Raid Dimensions to Swich Profiles",
					type = "group",
					guiInline = true,
					order = 6,
					args = {
						Description = {
							name = "Here you can change the raid players number that will push Dynamics to switch from 5Men to 10Men to 25Men to 40Men Profiles.\n"..
									"For Example is 10Men Dimension is 7, when your raid will have 7 or more players, Dynamics will automatically switch to 10men Mode.\n"..
									"Only Enabled if RaidFrames Management is Enabled.",
							type = "description",
							order = 1,
						},
						MEN10 = {
							name = "10 Men Dimension",
							desc = function(info)
									return ("When this players number will be reached, Dynamics will automatically switch to 10Men Mode.\n\n|CFFCCCCFFDefault |r: 7")
								end,
							type = "range",
							disabled = not db.profile.ManageRaidFrames,
							order = 2,
							min = 2,
							max = 10,
							step = 1,
							get = function(info) local v = 2
												if (db.realm.Dynamics["RAIDDIM"]["MEN10"]) then v=db.realm.Dynamics["RAIDDIM"]["MEN10"] end
												return v
												 end,
							set = function(info, value)
								db.realm.Dynamics["RAIDDIM"]["MEN10"] = value
							end,
							},
						MEN25 = {
							name = "25 Men Dimension",
							desc = function(info)
									return ("When this players number will be reached, Dynamics will automatically switch to 25Men Mode.\n\n|CFFCCCCFFDefault |r: 12")
								end,
							type = "range",
							disabled = not db.profile.ManageRaidFrames,
							order = 3,
							min = 11,
							max = 25,
							step = 1,
							get = function(info) local v = 12
												if (db.realm.Dynamics["RAIDDIM"]["MEN25"]) then v=db.realm.Dynamics["RAIDDIM"]["MEN25"] end
												return v
												 end,
							set = function(info, value)
								db.realm.Dynamics["RAIDDIM"]["MEN25"] = value
							end,
							},
						MEN40 = {
							name = "40 Men Dimension",
							desc = function(info)
									return ("When this players number will be reached, Dynamics will automatically switch to 40Men Mode.\n\n|CFFCCCCFFDefault |r: 27")
								end,
							type = "range",
							disabled = not db.profile.ManageRaidFrames,
							order = 4,
							min = 26,
							max = 40,
							step = 1,
							get = function(info) local v = 30
												if (db.realm.Dynamics["RAIDDIM"]["MEN40"]) then v=db.realm.Dynamics["RAIDDIM"]["MEN40"] end
												return v
												 end,
							set = function(info, value)
								db.realm.Dynamics["RAIDDIM"]["MEN40"] = value
							end,
						},
					},
				},
			},
		},
		Tank = createDynamicsOptions("Tank",2,canBeTank),
		Healer = createDynamicsOptions("Healer",3,canBeHealer),
		Melee = createDynamicsOptions("Melee",4,canBeMelee),
		Ranged = createDynamicsOptions("Ranged",5,canBeRanged),
		
		
	}
	return options
end

function module:UpdateOptions(caller)
	if (DUPDATE and module:TimeToUpdate()) then
		db.profile.updateTime = GetTime()
		module:dynamicsUpdateLUI()
		module:dynamicsUpdateBossMods()
		module:dynamicsUpdateBartender()
		module:dynamicsUpdateRaidFrames()
		module:dynamicsUpdateForte()
		module:dynamicsUpdateChat()
		module:dynamicsUpdateMSBT()
		module:dynamicsUpdateSkullMe()
		module:dynamicsUpdateSRTI()
		module:dynamicsUpdateGarbageCollection(false)
		module:dynamicsUpdateAutoRess()
		module:dynamicsUpdateMinimap()
		module:dynamicsUpdateBagnon()
		module:dynamicsUpdateAutoLUIProfile()
		module:dynamicsUpdateHermes()
		DUPDATE = false
		--print("|CFF99FF00Dynamics |r: Applyed settings for |CFF9999FF".. db.profile.ActualRole .."|r Role. (UPDATE_OPTIONS)")
	else
		--print("|CFF99FF00Dynamics |r: Nothing changed for |CFF9999FF".. db.profile.ActualRole .."|r Role.(LFG_PROPOSAL_SUCCEEDED)")
	
	end
	module:dynamicsUpdateMaxCameraDistance()
									
								
	for k,v in pairs (LUI.options.args[self:GetName()].args) do
		if not (k == "Dynamics") then
			if db.profile.ManageBartender and (not LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].disabled ) and caller=="BT4MOD" then 
			
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["BT4Profiles"].args["DeathKnight"].values = module:GetProfilesFor("Bartender4",Bartender4) 
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["BT4Profiles"].args["Druid"].values = module:GetProfilesFor("Bartender4",Bartender4)
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["BT4Profiles"].args["Hunter"].values = module:GetProfilesFor("Bartender4",Bartender4)
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["BT4Profiles"].args["Mage"].values = module:GetProfilesFor("Bartender4",Bartender4)
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["BT4Profiles"].args["Paladin"].values = module:GetProfilesFor("Bartender4",Bartender4)
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["BT4Profiles"].args["Priest"].values = module:GetProfilesFor("Bartender4",Bartender4)
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["BT4Profiles"].args["Rogue"].values = module:GetProfilesFor("Bartender4",Bartender4)
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["BT4Profiles"].args["Shaman"].values = module:GetProfilesFor("Bartender4",Bartender4)
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["BT4Profiles"].args["Warlock"].values = module:GetProfilesFor("Bartender4",Bartender4)
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["BT4Profiles"].args["Warrior"].values = module:GetProfilesFor("Bartender4",Bartender4)
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["BT4Profiles"].args["Monk"].values = module:GetProfilesFor("Bartender4",Bartender4)
				
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["ManageProfiles"].args["DeleteProfile"].values = module:GetProfilesFor("Bartender4",Bartender4) 
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["ManageProfiles"].args["CopyProfile"].values = module:GetProfilesFor("Bartender4",Bartender4) 
				LUI.options.args[self:GetName()].args[k].args["ButtonsProfiles"].args["ManageProfiles"].args["Description"].name = 
											"From Here You can directly manage BarTender Profiles; You can Create, Delete and Copy from another profile.\n"
											.. "|CFF99CC99Actual Bartender Profile is : ".. Bartender4.db:GetCurrentProfile() .. "|r"
				 bt4profiles = module:GetProfilesFor("Bartender4",Bartender4)
			end
			if db.profile.ManageMSBT and (not LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].disabled ) and caller=="MSBTMOD"  then 
				msbtprofiles = module:GetProfilesFor("MikScrollingBattleText",MikSBT)
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["MSBTProfiles"].args["DeathKnight"].values =msbtprofiles
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["MSBTProfiles"].args["Druid"].values =msbtprofiles
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["MSBTProfiles"].args["Hunter"].values = msbtprofiles
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["MSBTProfiles"].args["Mage"].values = msbtprofiles
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["MSBTProfiles"].args["Paladin"].values = msbtprofiles
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["MSBTProfiles"].args["Priest"].values = msbtprofiles
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["MSBTProfiles"].args["Rogue"].values = msbtprofiles
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["MSBTProfiles"].args["Shaman"].values = msbtprofiles
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["MSBTProfiles"].args["Warlock"].values = msbtprofiles
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["MSBTProfiles"].args["Warrior"].values = msbtprofiles
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["MSBTProfiles"].args["Monk"].values = msbtprofiles
				
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["ManageProfiles"].args["DeleteProfile"].values = msbtprofiles
				--LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["ManageProfiles"].args["CopyProfile"].values = module:GetProfilesFor("MikScrollingBattleText",MikSBT) 
				LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["ManageProfiles"].args["Description"].name = 
											"From Here You can directly manage MSBT Profiles; You can Create, Delete and Copy from another profile.\n"
											.. "|CFF99CC99Actual MSBT Profile is : ".. db.profile.currentMSBTProfile .. "|r"
				 msbtprofiles = module:GetProfilesFor("MikScrollingBattleText",MikSBT)
			end
			if db.profile.ManageRaidFrames and (not LUI.options.args[self:GetName()].args[k].args["RaidFrames"].disabled ) and caller=="RAIDFRAMESMOD" then 
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN1"].args["RaidProfiles"].args["DeathKnight"].values =module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN1"].args["RaidProfiles"].args["Druid"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN1"].args["RaidProfiles"].args["Hunter"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN1"].args["RaidProfiles"].args["Mage"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN1"].args["RaidProfiles"].args["Paladin"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN1"].args["RaidProfiles"].args["Priest"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN1"].args["RaidProfiles"].args["Rogue"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN1"].args["RaidProfiles"].args["Shaman"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN1"].args["RaidProfiles"].args["Warlock"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN1"].args["RaidProfiles"].args["Warrior"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN1"].args["RaidProfiles"].args["Monk"].values = module:GetProfilesFor(module:readRaidManager())
				
				-- 5 Men
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN5"].args["RaidProfiles"].args["DeathKnight"].values =module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN5"].args["RaidProfiles"].args["Druid"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN5"].args["RaidProfiles"].args["Hunter"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN5"].args["RaidProfiles"].args["Mage"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN5"].args["RaidProfiles"].args["Paladin"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN5"].args["RaidProfiles"].args["Priest"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN5"].args["RaidProfiles"].args["Rogue"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN5"].args["RaidProfiles"].args["Shaman"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN5"].args["RaidProfiles"].args["Warlock"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN5"].args["RaidProfiles"].args["Warrior"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN5"].args["RaidProfiles"].args["Monk"].values = module:GetProfilesFor(module:readRaidManager())
				--10 MEN
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN10"].args["RaidProfiles"].args["DeathKnight"].values =module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN10"].args["RaidProfiles"].args["Druid"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN10"].args["RaidProfiles"].args["Hunter"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN10"].args["RaidProfiles"].args["Mage"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN10"].args["RaidProfiles"].args["Paladin"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN10"].args["RaidProfiles"].args["Priest"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN10"].args["RaidProfiles"].args["Rogue"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN10"].args["RaidProfiles"].args["Shaman"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN10"].args["RaidProfiles"].args["Warlock"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN10"].args["RaidProfiles"].args["Warrior"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN10"].args["RaidProfiles"].args["Monk"].values = module:GetProfilesFor(module:readRaidManager())
				
				-- 25Men 
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN25"].args["RaidProfiles"].args["DeathKnight"].values =module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN25"].args["RaidProfiles"].args["Druid"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN25"].args["RaidProfiles"].args["Hunter"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN25"].args["RaidProfiles"].args["Mage"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN25"].args["RaidProfiles"].args["Paladin"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN25"].args["RaidProfiles"].args["Priest"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN25"].args["RaidProfiles"].args["Rogue"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN25"].args["RaidProfiles"].args["Shaman"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN25"].args["RaidProfiles"].args["Warlock"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN25"].args["RaidProfiles"].args["Warrior"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN25"].args["RaidProfiles"].args["Monk"].values = module:GetProfilesFor(module:readRaidManager())
				
				-- 40MEn
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN40"].args["RaidProfiles"].args["DeathKnight"].values =module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN40"].args["RaidProfiles"].args["Druid"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN40"].args["RaidProfiles"].args["Hunter"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN40"].args["RaidProfiles"].args["Mage"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN40"].args["RaidProfiles"].args["Paladin"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN40"].args["RaidProfiles"].args["Priest"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN40"].args["RaidProfiles"].args["Rogue"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN40"].args["RaidProfiles"].args["Shaman"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN40"].args["RaidProfiles"].args["Warlock"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN40"].args["RaidProfiles"].args["Warrior"].values = module:GetProfilesFor(module:readRaidManager())
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["MEN40"].args["RaidProfiles"].args["Monk"].values = module:GetProfilesFor(module:readRaidManager())
				
				
				--LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["ManageProfiles"].args["DeleteProfile"].values = module:GetProfilesFor("MikScrollingBattleText",MikSBT)
				--LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["ManageProfiles"].args["CopyProfile"].values = module:GetProfilesFor("MikScrollingBattleText",MikSBT) 
				--LUI.options.args[self:GetName()].args[k].args["MSBTOptions"].args["ManageProfiles"].args["Description"].name = 
				--							"From Here You can directly manage MSBT Profiles; You can Create, Delete and Copy from another profile.\n"
				--							.. "|CFF99CC99Actual MSBT Profile is : ".. db.profile.currentMSBTProfile .. "|r"
				 raidprofiles = module:GetProfilesFor(module:readRaidManager())
			end
			if db.profile.ManageRaidFrames and (not LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].disabled ) and caller=="CLIQUEMOD" then 
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["CliqueProfiles"].args["DeathKnight"].values = module:GetProfilesFor("Clique",Clique) 
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["CliqueProfiles"].args["Druid"].values = module:GetProfilesFor("Clique",Clique)
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["CliqueProfiles"].args["Hunter"].values = module:GetProfilesFor("Clique",Clique)
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["CliqueProfiles"].args["Mage"].values = module:GetProfilesFor("Clique",Clique)
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["CliqueProfiles"].args["Paladin"].values = module:GetProfilesFor("Clique",Clique)
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["CliqueProfiles"].args["Priest"].values = module:GetProfilesFor("Clique",Clique)
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["CliqueProfiles"].args["Rogue"].values = module:GetProfilesFor("Clique",Clique)
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["CliqueProfiles"].args["Shaman"].values = module:GetProfilesFor("Clique",Clique)
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["CliqueProfiles"].args["Warlock"].values = module:GetProfilesFor("Clique",Clique)
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["CliqueProfiles"].args["Warrior"].values = module:GetProfilesFor("Clique",Clique)
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["CliqueProfiles"].args["Monk"].values = module:GetProfilesFor("Clique",Clique)
				
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["ManageProfiles"].args["DeleteProfile"].values = module:GetProfilesFor("Clique",Clique) 
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["ManageProfiles"].args["CopyProfile"].values = module:GetProfilesFor("Clique",Clique) 
				LUI.options.args[self:GetName()].args[k].args["RaidFrames"].args["CliqueOpt"].args["ManageProfiles"].args["Description"].name = 
											"From Here You can directly manage Clique Profiles; You can Create, Delete and Copy from another profile.\n"
											.. "|CFF99CC99Actual Clique Profile is : ".. Clique.db:GetCurrentProfile() .. "|r"
				 cliqueprofiles = module:GetProfilesFor("Clique",Clique)
			end
			if db.profile.ManageBossMod and (not LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].disabled ) and caller=="BOSSMODS" then 
				local enableDBM = (not db.profile.BossMods.DBM) or (not (db.profile.ActualRole==k)) 
				local enableBIGWIGS = (not db.profile.BossMods.BIGWIGS) or (not (db.profile.ActualRole==k))
				local enableDXE = (not db.profile.BossMods.DXE) or (not (db.profile.ActualRole==k))
				LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DMBTest"].disabled = enableDBM
				LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["BIGWIGSTest"].disabled = enableBIGWIGS
				LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DXETest"].disabled = enableDXE
				if (not LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DBM"].disabled ) then
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DBM"].args["DMBTestBars"].disabled = enableDBM
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DBM"].args["WARNINGS"].args["SPECIALWARNINGS"].args["DMBRTest"].disabled = enableDBM
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DBM"].args["OTHERWINDOWS"].args["PROXIMITY"].args["rangeTest"].disabled = enableDBM
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DBM"].args["OTHERWINDOWS"].args["BOSSHEALTH"].args["HPTest"].disabled = enableDBM
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DBM"].args["OTHERWINDOWS"].args["INFOFRAME"].args["InfoTest"].disabled = enableDBM
					
				end
				if (not LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["BIGWIGS"].disabled ) then
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["BIGWIGS"].args["BIGWIGSTestBars"].disabled = enableBIGWIGS
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["BIGWIGS"].args["OTHERWINDOWS"].args["PROXIMITY"].args["proximityTest"].disabled = enableBIGWIGS
				end
				if (not LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DXE"].disabled ) then
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DXE"].args["DXETestBars"].disabled = enableDXE
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DXE"].args["BARS"].args["CENTEREDBARS"].args["BARTEST"].disabled = enableDXE
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DXE"].args["BARS"].args["WARININGBARS"].args["BARTEST"].disabled = enableDXE
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DXE"].args["OTHERWINDOWS"].args["PROXIMITY"].args["Test"].disabled = enableDXE
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DXE"].args["OTHERWINDOWS"].args["ALTERNATE"].args["Test"].disabled = enableDXE
					LUI.options.args[self:GetName()].args[k].args["BossModsProfiles"].args["DXE"].args["OTHERWINDOWS"].args["ARROWS"].args["Test"].disabled = enableDXE
				end
				
			end
			if db.profile.ManageChat and (not LUI.options.args[self:GetName()].args[k].args["DynamicChat"].disabled ) and caller=="CHAT" then 
				LUI.options.args[self:GetName()].args[k].args["DynamicChat"].args["RIGHTCHAT"].args["X"].disabled = not db.realm.Dynamics[k].CHAT.RIGHTCHAT.WINDOWS.ENABLED 
				LUI.options.args[self:GetName()].args[k].args["DynamicChat"].args["RIGHTCHAT"].args["Y"].disabled = not db.realm.Dynamics[k].CHAT.RIGHTCHAT.WINDOWS.ENABLED 
				LUI.options.args[self:GetName()].args[k].args["DynamicChat"].args["RIGHTCHAT"].args["WIDTH"].disabled = not db.realm.Dynamics[k].CHAT.RIGHTCHAT.WINDOWS.ENABLED
				LUI.options.args[self:GetName()].args[k].args["DynamicChat"].args["RIGHTCHAT"].args["HEIGHT"].disabled = not db.realm.Dynamics[k].CHAT.RIGHTCHAT.WINDOWS.ENABLED
				LUI.options.args[self:GetName()].args[k].args["DynamicChat"].args["RIGHTCHAT"].args["RIGHTCHATFRAMES"].disabled = not db.realm.Dynamics[k].CHAT.RIGHTCHAT.WINDOWS.ENABLED
			end
		end
	end
	-- LUI.options.args[self:GetName()].args.ConfigureAddonsPacks.args["AddonsList"].args = createAddonListOptions(currentPack)
	-- LUI.options.args[self:GetName()].args.AddAddonPack.args["Copy"].args["Packs"].values = module:LUIPacks(profileToCopy)
	-- collectgarbage("collect")
	
	if caller == "FORTE" then 
		module:dynamicsUpdateForte()
	end
	if caller == "BOSSMODS" then
		module:dynamicsUpdateBossMods()
	end
	if caller == "CHAT" then
		module:dynamicsUpdateChat()
	end
	if caller == "SKADA" then
		module:dynamicsUpdateSkada()
	end
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("LUI", LUI.options)
	LibStub("AceConfigRegistry-3.0"):NotifyChange("LUI")
end

function module:OnInitialize()
	--print("INIZIALIZE")
	db = LUI:NewNamespace(self, true)
	db.profile = db.profile or module.defaults.profile
	db.realm = db.realm or module.defaults.realm -- {}
	db.realm.Dynamics = db.realm.Dynamics or module.defaults.realm.Dynamics
	db.realm.Dynamics.Tank = db.realm.Dynamics.Tank or module.defaults.realm.Dynamics.Tank
	db.realm.Dynamics.Healer = db.realm.Dynamics.Healer or module.defaults.realm.Dynamics.Healer
	db.realm.Dynamics.Melee = db.realm.Dynamics.Melee or module.defaults.realm.Dynamics.Melee
	db.realm.Dynamics.Ranged = db.realm.Dynamics.Ranged or module.defaults.realm.Dynamics.Ranged
	local REALMRESET = false
	local PROFILERESET = false
	if REALMRESET then
		db.realm = module.defaults.realm
	end
	if PROFILERESET then
		db.profile = module.defaults.profile
	end
	
	db.profile.version = db.profile.version or 0
	if floor(db.profile.version) ~= floor(version) then db.profile.version = version	end
	
	BlizzardScale = GetCVar("uiScale")
	
	local _,class = UnitClass("player")
	self:checkClassRoles(class)
	
	if (db.realm.Dynamics) then
		if db.realm.Dynamics[db.profile.ActualRole] then
			if db.realm.Dynamics[db.profile.ActualRole].MSBT[class] then
				db.profile.currentMSBTProfile = db.realm.Dynamics[db.profile.ActualRole].MSBT[class]
			end
		end
	end
	
	
	
	-- for k,v in pairs (db.profile) do print(k) end
	-- print ("Realm:")
	--for k,v in pairs (db.realm.Dynamics) do print(k) end
														
end

function module:OnEnable()
	module:RegisterEvent("PARTY_CONVERTED_TO_RAID",module:PARTY_CONVERTED_TO_RAID())
	module:RegisterEvent("PARTY_MEMBERS_CHANGED",module:PARTY_MEMBERS_CHANGED())
	module:RegisterEvent("RAID_ROSTER_UPDATE",module:RAID_ROSTER_UPDATE())
	module:RegisterEvent("LFG_PROPOSAL_SUCCEEDED",module:LFG_PROPOSAL_SUCCEEDED())
	module:RegisterEvent("PLAYER_ENTERING_WORLD",module:PLAYER_ENTERING_WORLD())
	module:RegisterEvent("PLAYER_TALENT_UPDATE",module:PLAYER_TALENT_UPDATE())
	module:RegisterEvent("RESURRECT_REQUEST",module:RESURRECT_REQUEST()) 
	--CaricaDynamicsMedia(LSM) -- Funzione che carica in Shared Media le Texture, I fonts e le barre

	db.profile = db.profile or module.defaults.profile
	db.realm = db.realm or module.defaults.realm -- {}
	db.realm.Dynamics = db.realm.Dynamics or module.defaults.realm.Dynamics
	db.realm.Dynamics.Tank = db.realm.Dynamics.Tank or module.defaults.realm.Dynamics.Tank
	db.realm.Dynamics.Healer = db.realm.Dynamics.Healer or module.defaults.realm.Dynamics.Healer
	db.realm.Dynamics.Melee = db.realm.Dynamics.Melee or module.defaults.realm.Dynamics.Melee
	db.realm.Dynamics.Ranged = db.realm.Dynamics.Ranged or module.defaults.realm.Dynamics.Ranged
	
	oUF = LUI:Module("Unitframes")
	Forte = LUI:Module("Forte")
	if FW then
		FW:RegisterVariablesEvent()
	end
	
	if (module:updateSpecsRoles()) then	DUPDATE = true end
	
	--if (module:TimeToUpdate()) then
		print("|CFF99FF00Dynamics |r: Enabled settings for |CFF9999FF".. db.profile.ActualRole .."|r Role.")
		module:dynamicsUpdateLUI()
		module:dynamicsUpdateBossMods()
		module:dynamicsUpdateBartender()
		module:dynamicsUpdateRaidFrames()
		module:dynamicsUpdateForte()
		module:dynamicsUpdateChat() 
		module:dynamicsUpdateMSBT()
		module:dynamicsUpdateSkullMe()
		module:dynamicsUpdateSRTI()
		module:dynamicsUpdateMaxCameraDistance()
		module:dynamicsUpdateGarbageCollection()
		module:dynamicsUpdateAutoRess()
		module:dynamicsUpdateMinimap()
		module:dynamicsUpdateBagnon()
		module:dynamicsUpdateAutoLUIProfile()
		module:dynamicsUpdateSkada()
		module:dynamicsUpdateHermes()
		DUPDATE = false
	--end	
end

function module:OnDisable()
	
	module:UnregisterEvent"PARTY_CONVERTED_TO_RAID"
	module:UnregisterEvent"PARTY_MEMBERS_CHANGED"
	module:UnregisterEvent"RAID_ROSTER_UPDATE"
	module:UnregisterEvent"LFG_PROPOSAL_SUCCEEDED"
	module:UnregisterEvent"PLAYER_ENTERING_WORLD"
	module:UnregisterEvent"PLAYER_TALENT_UPDATE"
	module:UnregisterEvent"RESURRECT_REQUEST"
	
end