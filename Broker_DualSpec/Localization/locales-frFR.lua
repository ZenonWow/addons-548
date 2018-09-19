-- ********************************************************************************
-- Data Broker Dual Specialization (Broker_DualSpec)
-- A dual specialization switch for Data Broker.
-- By: Shenton
--
-- Locales-frFR.lua
-- ********************************************************************************

local L = LibStub("AceLocale-3.0"):NewLocale("Broker_DualSpec", "frFR");

if L then
L["ADDON_NAME"] = "DualSpec"
L["BINDINGS_HEADER"] = "Data Broker Dual Specialization"
L["CLOAK"] = "Cape"
L["CLOSE"] = "Fermer"
L["COMMAND_USAGE_1"] = "Utilisation de la commande, \"/ds\", \"/bds\", \"/brokerdualspec\""
L["COMMAND_USAGE_2"] = "Sans aucun argument ça changera de spécialisation"
L["COMMAND_USAGE_3"] = "\"/ds show\", affiche l'icone de la minimap, \"/ds list\", fait une liste de vos jeux d'équipement"
L["COMMAND_USAGE_4"] = "\"/ds <primary|secondary> <jeu d'équipement>\", assigne le jeu d'équipement à la spécialisation"
L["CURRENT_SPEC"] = "Spé actuelle"
L["DISPLAY_SPEC_NAME"] = "Afficher le nom"
L["DISPLAY_SPEC_POINTS"] = "Afficher les points"
L["GEAR_NOT_EXISTS"] = "Ce jeu d'équipement n'existe pas, utilisez \"/ds list\" pour une liste"
L["GEAR_SETS"] = "Sets d'équipement"
L["HELM"] = "Casque"
L["HIDDEN"] = "Masquer"
L["HIDE_MINIMAP"] = "Icone de la minimap caché, pour l'afficher utilisez: \"/ds show\" (ou /bds /brokerdualspec)"
L["HIDE_SPAM"] = "Masquer le spam"
L["IN_COMBAT"] = "Vous êtes en combat, impossible de changer de spécialisation"
L["LOCAL_NOT_SUPPORTED"] = "La locale %s n'est pas supportée, l'option Masquer le spam à été désactivée."
L["NO_GEAR_DEFINED"] = "Le changement d'équipement est activé, mais aucun jeu d'équipement n'est défini"
L["NO_GEAR_SETS"] = "Vous n'avez aucun jeu d'équipement de défini"
L["NOT_AVAILABLE"] = "Indisponible"
L["OPTIONS"] = "Options"
L["PRIMARY_SPEC"] = "Spé pincipale"
L["PRIMARY_SPEC_BIND"] = "Spécialisation principale"
L["SECONDARY_SPEC"] = "Spé secondaire"
L["SECONDARY_SPEC_BIND"] = "Spécialisation secondaire"
L["SHOW_HIDE_MINIMAP"] = "Afficher/Masquer l'icone de la minimap"
L["SHOWN"] = "Afficher"
L["SWITCH_GEAR_TOO"] = "Changer aussi l'équipement"
L["SWITCH_SPECIALIZATION"] = "Changer de spécialisation"
L["SWITCH_TO"] = "Changer pour"
L["TOOLTIP_TIPS"] = [=[%sClique-Gauche:%s Change votre spécialisation et votre jeu d'équipement si activé
%sClique-Droit:%s Affiche le menu de configuration]=]
L["WITH_GEAR_SET"] = "Avec le jeu"

end
