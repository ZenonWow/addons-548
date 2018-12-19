-- ********************************************************************************
-- Data Broker Dual Specialization (Broker_DualSpec)
-- A dual specialization switch for Data Broker.
-- By: Shenton
--
-- Locales-zhCN.lua
-- ********************************************************************************

local L = LibStub("AceLocale-3.0"):NewLocale("Broker_DualSpec", "zhCN");

if L then
-- L["ADDON_NAME"] = ""
-- L["BINDINGS_HEADER"] = ""
-- L["CLOAK"] = ""
L["CLOSE"] = "关闭"
L["COMMAND_USAGE_1"] = "命令行, \"/ds\", \"/bds\", \"/brokerdualspec\""
L["COMMAND_USAGE_2"] = "不带参数将改变你的当前天赋"
L["COMMAND_USAGE_3"] = "\"/ds show\", 显示小地图图标, \"/ds list\", 列表你的装备管理列表"
L["COMMAND_USAGE_4"] = "\"/ds <primary|secondary> <gear set>\", 将设置套装于给定的天赋"
L["CURRENT_SPEC"] = "当前天赋"
L["DISPLAY_SPEC_NAME"] = "显示天赋名字"
L["DISPLAY_SPEC_POINTS"] = "显示天赋点数"
L["GEAR_NOT_EXISTS"] = "装备套装不存在,使用 \"/ds list\" 来获取"
L["GEAR_SETS"] = "状态套装"
-- L["HELM"] = ""
-- L["HIDDEN"] = ""
L["HIDE_MINIMAP"] = "小地图图标已被隐藏, 如果你想要重新显示请使用：: \"/ds show\" (或 /bds /brokerdualspec)"
-- L["HIDE_SPAM"] = ""
L["IN_COMBAT"] = "你在战斗中不能切换天赋"
-- L["LOCAL_NOT_SUPPORTED"] = ""
L["NO_GEAR_DEFINED"] = "切换套装已启用但没有定义套装"
L["NO_GEAR_SETS"] = "你没有定义套装"
L["NOT_AVAILABLE"] = "不可用" -- Needs review
L["OPTIONS"] = "选项"
L["PRIMARY_SPEC"] = "主天赋"
-- L["PRIMARY_SPEC_BIND"] = ""
L["SECONDARY_SPEC"] = "副天赋"
-- L["SECONDARY_SPEC_BIND"] = ""
L["SHOW_HIDE_MINIMAP"] = "显示/隐藏小地图按钮"
-- L["SHOWN"] = ""
L["SWITCH_GEAR_TOO"] = "同时切换装备"
-- L["SWITCH_SPECIALIZATION"] = ""
L["SWITCH_TO"] = "切换到"
L["TOOLTIP_TIPS"] = [=[%s左键点击:%s 切换天赋和套装
%s右键点击:%s 显示配置面板]=]
L["WITH_GEAR_SET"] = "同时切换套装"

end
