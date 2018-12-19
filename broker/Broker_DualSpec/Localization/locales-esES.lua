-- ********************************************************************************
-- Data Broker Dual Specialization (Broker_DualSpec)
-- A dual specialization switch for Data Broker.
-- By: Shenton
--
-- Locales-esES.lua
-- ********************************************************************************

local L = LibStub("AceLocale-3.0"):NewLocale("Broker_DualSpec", "esES");

if L then
L["ADDON_NAME"] = "DualSpec"
-- L["BINDINGS_HEADER"] = ""
-- L["CLOAK"] = ""
L["CLOSE"] = "Cerrar"
L["COMMAND_USAGE_1"] = "Comandos, \"/ds\", \"/bds\", \"/brokerdualspec\""
L["COMMAND_USAGE_2"] = "Sin comandos adicionales, solo cambiará tu especialización"
L["COMMAND_USAGE_3"] = "\"/ds show\", mostrar icono en el minimapa, \"/ds list\", listado de tus equipaciones"
L["COMMAND_USAGE_4"] = "\"/ds <primary|secondary> <gear set>\", asignará la especialización a la equipación seleccionada"
L["CURRENT_SPEC"] = "Especialización actual"
L["DISPLAY_SPEC_NAME"] = "Mostrar nombre de especialización"
L["DISPLAY_SPEC_POINTS"] = "Mostrar los puntos de talentos"
L["GEAR_NOT_EXISTS"] = "Esa equipación no existe, usa \"/ds list\" para verlas"
L["GEAR_SETS"] = "Equipaciones"
-- L["HELM"] = ""
-- L["HIDDEN"] = ""
L["HIDE_MINIMAP"] = "El icono del minimapa está oculto. Si quieres mostrarlo utilizar: \"/ds show\" (o /bds /brokerdualspec)"
-- L["HIDE_SPAM"] = ""
L["IN_COMBAT"] = "Mientras estás en combate no puedes cambiar de especialización"
-- L["LOCAL_NOT_SUPPORTED"] = ""
L["NO_GEAR_DEFINED"] = "No has elegido la equipación de esa especialización"
L["NO_GEAR_SETS"] = "No tienes una equipación establecida"
L["NOT_AVAILABLE"] = "No disponible"
L["OPTIONS"] = "Opciones"
L["PRIMARY_SPEC"] = "Primaria"
-- L["PRIMARY_SPEC_BIND"] = ""
L["SECONDARY_SPEC"] = "Secundaria"
-- L["SECONDARY_SPEC_BIND"] = ""
L["SHOW_HIDE_MINIMAP"] = "Mostrar/ocultar icono en el minimapa"
-- L["SHOWN"] = ""
L["SWITCH_GEAR_TOO"] = "Cambiar de equipación también"
-- L["SWITCH_SPECIALIZATION"] = ""
L["SWITCH_TO"] = "Cambiar a"
L["TOOLTIP_TIPS"] = [=[%sClick izquierdo:%s Cambiar de especialización y equipo si está permitido
%sClick derecho:%s Muestra el menú de configuración]=]
L["WITH_GEAR_SET"] = "Con equipación"

end
