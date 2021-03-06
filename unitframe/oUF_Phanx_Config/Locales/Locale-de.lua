--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	German localization
	Contributors: Phanx, Grafotz
----------------------------------------------------------------------]]

if GetLocale() ~= "deDE" then return end
local _, private = ...
local L = private.L

L.AddAura = "Aura hinzufügen"
L.AddAura_Desc = "Um eine neue Aura hinzuzufügen, gib seine Zauber-ID ein, und drücke die Eingabetaste."
L.AddAura_Invalid = "Das ist keine gültige Zauber-ID!"
L.AddAura_Note = "Um die ID für einen Zauber zu finden, suche sie auf Wowhead.com, und kopiere die Nummer aus der URL."
L.AuraFilter0 = "Zeigen nie"
L.AuraFilter1 = "Zeigen immer"
L.AuraFilter2 = "Zeigen nur meine"
L.AuraFilter3 = "Zeigen nur auf Freunde"
L.AuraFilter4 = "Zeigen nur auf mich selbst"
L.Auras = "Auren"
L.Auras_Desc = "Neue Stärkungs- oder Schwächungszauber hinzufügen, oder ändern, wie die vordefinierten Auren werden gefiltert."
L.BorderColor = "Randfarbe"
L.BorderColor_Desc = "Standartrandfarbe ändern."
L.BorderSize = "Randbreite"
L.Castbar = "Zauberbalken"
L.Castbar_Desc = "Eine Zauberbalken auf diesem Einheitfenster anzeigen."
L.ClassFeatures = "%s-Klassenfunktionen"
L.ColorClass = "Nach Klasse"
L.ColorCustom = "Benutzerdefinierte"
L.ColorHealth = "Nach Gesundheit"
L.ColorPower = "Nach Energieart"
L.Colors = "Farbe"
L.Colors_Desc = "Diese Optionen ändern die Farben, die für verschiedene Teile der Einheitfenster verwendet werden."
L.CombatText = "Kampfrückmeldungstext"
L.CombatText_Desc = "Schadens-, Heilungs- und anderen Kampftext auf den Fenster dieser Einheit anzeigen."
L.DeleteAura = "Aura löschen"
L.DeleteAura_Desc = "Den benutzerdefinierten Filter für diese Aura löschen."
L.DruidManaBar = "Druidmanabalken"
L.DruidManaBar_Desc = "Eine zusätzliche Manabalken anzeigen, während Sie in Katzengestalt oder Bärengestalt sind."
L.EclipseBar = "Finsternisbalken"
L.EclipseBar_Desc = "Ein Finsternisbalken über dem Spielerfenster anzeigen."
L.EclipseBarIcons = "Finsternisbalkensymbole"
L.EclipseBarIcons_Desc = "Animierte Symbole von Mond und Sonne an beiden Enden der Finsternisbalken anzeigen."
L.EnableUnit = "Aktivieren"
L.EnableUnit_Desc = "Das Fenster von oUF Phanx dieser Einheit könnt Ihr deaktivieren, falls Ihr vorzieht, das Fenster des Standard-UI oder eines anderen Addon verzuwenden."
L.FilterDebuffHighlight = "Schwächungszauber filtern"
L.FilterDebuffHighlight_Desc = "Hervorhebungen der Schwächungszauber nur anzeigen, die auch entfernt werden können."
L.Font = "Schriftart"
L.FrameHeight = "Basishöhe"
L.FrameHeight_Desc = "Die Basishöhe der Fenster festlegen."
L.FrameWidth = "Basisbreite"
L.FrameWidth_Desc = "Die Basisbreite der Fenster festlegen. Einige Fenster sind proportional breiter oder schmaler."
L.HealthBG = "Gesundheitsbalkenhintergrund"
L.HealthBG_Desc = "Die Helligkeit der Hintergrund des Gesundheitsbalkens festlegen, relativ zu seiner Vordergrund."
L.HealthColor = "Gesundheitsbalkenfarbe"
L.HealthColor_Desc = "Legt fest, wie die Gesundheitsbalken eingefärbt werden."
L.HealthColorCustom = "Benutzerdefinierte Farbe"
L.Height = "Relative Höhe"
L.Height_Desc = "Die Höhe diesem Einheitfenster relativ zur Layoutsbasisbreite einstellen."
L.IgnoreOwnHeals = "Ignoriere eigene Heals"
L.IgnoreOwnHeals_Desc = "Zeige nur eingehende Heilungen anderer Spieler."
L.MoreSettings = "Weitere Einstellungen"
L.MoreSettings_Desc = "Um die Änderungen dieser Einstellungen anzuwenden, muss das UI erneut geladen werden."
L.None = "Nichts"
L.Options_Desc = "oUF_Phanx ist ein Layout für Haste's oUF Framework. Nutze diese Oberfläche um Grundeinstellungen zu konfigurieren."
L.Outline = "Schriftumriss"
L.Power = "Ressourcenbalken"
L.Power_Desc = "Eine Ressourcenbalken auf diesem Einheitfenster anzeigen."
L.PowerBG = "Ressourcenbalkenhintergrund"
L.PowerBG_Desc = "Die Helligkeit der Hintergrund des Ressourcenbalkens festlegen, relativ zu seiner Vordergrund."
L.PowerColor = "Ressourcenbalkenfarbe"
L.PowerColor_Desc = "Legt fest, wie die Ressourcenbalken eingefärbt werden."
L.PowerColorCustom = "Benutzerdefinierte Farbe"
L.PowerHeight = "Ressourcenbalkenhöhe"
L.PowerHeight_Desc = "Die Höhe des Ressourcenbalkens in Prozent der Gesamthöhe des Fensters festlegen."
L.ReloadUI = "UI neuladen"
L.RuneBars = "Runenleisten anzeigen"
L.RuneBars_Desc = "Abklingzeitleisten für Ihre Runen über dem Spielerfenster anzeigen."
L.Shadow = "Schriftschatten"
L.StaggerBar = "Staffelungsbalken"
L.StaggerBar_Desc = "Gestaffelte Schaden als Balken über dem Spielerfenster anzeigen."
L.Texture = "Textur"
L.Thick = "Dick"
L.Thin = "Dünn"
L.ThreatLevels = "Bedrohungstufen anzeigen"
L.ThreatLevels_Desc = "Detaillierte Bedrohungstufen anzeigen, statt einer einfachen Aggro-Status."
L.TotemBars = "Totemleisten anzeigen"
L.TotemBars_Desc = "Zeitleisten für Ihre Totems über dem Spielerfenster anzeigen."
L.Unit_Arena = "Arenagegner"
L.Unit_ArenaPet = "Arenabegleiter"
L.Unit_Boss = "Bosse"
L.Unit_Focus = "Fokus"
L.Unit_FocusTarget = "Ziel des Fokus"
L.Unit_Global = "Alle Einheiten"
L.Unit_Party = "Gruppe"
L.Unit_PartyPet = "Gruppenhaustiere"
L.Unit_Pet = "Begleiter"
L.Unit_Player = "Spieler"
L.Unit_Target = "Ziel"
L.Unit_TargetTarget = "Ziel des Ziels"
L.UnitSettings = "Einheiten"
L.UnitSettings_Desc = "Einstellungen der einzelnen Einheitfenster ändern."
L.Width = "Relative Breite"
L.Width_Desc = "Die Briete diesem Einheitfenster relativ zur Layoutsbasisbreite einstellen."
