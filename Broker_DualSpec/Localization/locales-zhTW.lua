-- ********************************************************************************
-- Data Broker Dual Specialization (Broker_DualSpec)
-- A dual specialization switch for Data Broker.
-- By: Shenton
--
-- Locales-zhTW.lua
-- ********************************************************************************

local L = LibStub("AceLocale-3.0"):NewLocale("Broker_DualSpec", "zhTW");

if L then
L["ADDON_NAME"] = "雙天賦"
L["BINDINGS_HEADER"] = "Data Broker 雙天賦"
L["CLOAK"] = "披風"
L["CLOSE"] = "關閉"
L["COMMAND_USAGE_1"] = "指令使用， \"/ds\", \"/bds\", \"/brokerdualspec\""
L["COMMAND_USAGE_2"] = "沒有爭論的它會改變你的天賦"
L["COMMAND_USAGE_3"] = "\"/ds show\", 顯示小地圖按鈕, \"/ds list\", 列出裝備管理套裝"
L["COMMAND_USAGE_4"] = "\"/ds <主天賦|副天賦> <裝備管理套裝>\",會設定天賦綁定裝備。 "
L["CURRENT_SPEC"] = "當前天賦"
L["DISPLAY_SPEC_NAME"] = "顯示天賦名稱"
L["DISPLAY_SPEC_POINTS"] = "顯示天賦點數"
L["GEAR_NOT_EXISTS"] = "此裝備套裝不存在，使用\"/ds list\"以觀看裝備管理列表"
L["GEAR_SETS"] = "裝備套裝"
L["HELM"] = "頭盔"
L["HIDDEN"] = "隱藏"
L["HIDE_MINIMAP"] = "小地圖按鈕是隱藏的，如果你想要顯示請用：\"/ds show\" (或 /bds /brokerdualspec)"
L["HIDE_SPAM"] = "隱藏垃圾訊息"
L["IN_COMBAT"] = "你在戰鬥中，無法切換天賦"
L["LOCAL_NOT_SUPPORTED"] = "本地 %s 並不支援，請取消隱藏垃圾訊息選項。"
L["NO_GEAR_DEFINED"] = "切換天賦同時換裝備是啟用的，但是沒有裝備套裝已綁定"
L["NO_GEAR_SETS"] = "你沒有綁定的裝備套裝"
L["NOT_AVAILABLE"] = "不可使用"
L["OPTIONS"] = "選項"
L["PRIMARY_SPEC"] = "主天賦"
L["PRIMARY_SPEC_BIND"] = "主天賦"
L["SECONDARY_SPEC"] = "副天賦"
L["SECONDARY_SPEC_BIND"] = "副天賦"
L["SHOW_HIDE_MINIMAP"] = "顯示/隱藏小地圖按鈕"
L["SHOWN"] = "顯示"
L["SWITCH_GEAR_TOO"] = "同時切換裝備"
L["SWITCH_SPECIALIZATION"] = "切換天賦"
L["SWITCH_TO"] = "切換到"
L["TOOLTIP_TIPS"] = [=[%s左鍵點擊:%s 同時切換你的天賦與套裝
%s右鍵點擊:%s 顯示配置面板]=]
L["WITH_GEAR_SET"] = "同時切換套裝"

end
