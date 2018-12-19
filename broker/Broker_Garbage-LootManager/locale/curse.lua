--[[
	This file imports localization data from curse.com
	If you wish to get your language and/or translations used, submit them at http://wow.curseforge.com/addons/broker_garbage/localization and inform me via private message or an addon issue ticket
--]]
local _, BGLM = ...
local L = BGLM.locale

local current = GetLocale()
if current == "zhTW" then
	L["couldNotLootBlacklist"] = "沒有拾取%sx%d，因為它在你的垃圾列表。"
L["couldNotLootCompareValue"] = "沒有拾取%sx%d。它比我們已經有的還要便宜。背包滿了!"
L["couldNotLootLM"] = "你是拾取管理員，請手動分配%s。"
L["couldNotLootLocked"] = "無法拾取%sx%d，因為它被鎖定。請手動拾取。"
L["couldNotLootSpace"] = "無法拾取%sx%d，因為你沒有任何空間。"
L["couldNotLootValue"] = "沒有拾取%sx%d，因為太便宜。"
L["CreatureTypeBeast"] = "野獸"
L["disableBlizzAutoLoot"] = "|cffff0000警告:|r 請取消暴雪的自動拾取。"
L["errorInventoryFull"] = "有東西沒有被拾取，因為你的背包滿了。請手動拾取!"
L["GlobalSetting"] = "|cffffff9a這設定是全局。"
L["GroupInventory"] = "背包"
L["GroupLooting"] = "拾取"
L["GroupNotices"] = "注意"
L["GroupThreshold"] = "門檻"
L["LMAutoAcceptLootTitle"] = "自動確認拾取綁定"
L["LMAutoAcceptLootTooltip"] = "勾選自動確認拾取綁定。"
L["LMAutoDestroy_ErrorNoItems"] = "錯誤！我嘗試騰出空間，但沒有東西可以讓我刪除！"
L["LMAutoDestroyInstantTitle"] = "強制"
L["LMAutoDestroyInstantTooltip"] = "勾選時，Broker_Garbage可能在拾取那時刻刪除物品。換句話說，刪除僅發生在你有更好的拾取或是需要空間。"
L["LMAutoDestroyTitle"] = "自動摧毀"
L["LMAutoDestroyTooltip"] = "勾選時，Broker_Garbage將會採取行動當你背包空間(幾乎)滿。"
L["LMAutoLootFishingTitle"] = "釣魚"
L["LMAutoLootFishingTooltip"] = "勾選來拾取如果是釣魚拾取。"
L["LMAutoLootPickpocketTitle"] = "偷竊"
L["LMAutoLootPickpocketTooltip"] = "勾選來拾取如果你是盜賊並且潛行。"
L["LMAutoLootSkinningTitle"] = "剝皮"
L["LMAutoLootSkinningTooltip"] = "勾選來拾取如果你可以對生物剝皮。"
L["LMAutoLootTitle"] = "自動拾取"
L["LMAutoLootTooltip"] = "使用這設定或是組合以下設定讓Broker_Garbage來決定如何/如果處理拾取。"
L["LMCloseLootTitle"] = "關閉視窗"
L["LMCloseLootTooltip"] = [=[勾選自動關閉拾取視窗同時沒有興趣的物品會被遺留在裡面。
|cffff0000警告|r: 這可能會干擾其它插件。]=]
L["LMEnableInCombatTitle"] = "戰鬥中啟用"
L["LMEnableInCombatTooltip"] = "如果勾選，Broker_Garbage會嘗試拾取即使你在戰鬥中。"
L["LMForceClearTitle"] = "強制清除Mobs"
L["LMForceClearTooltip"] = "勾選清除Mobs(即使你不是skinner)。用這設定你可能失去金錢!"
L["LMFreeSlotsTitle"] = "最小空間槽"
L["LMFreeSlotsTooltip"] = "設定最小空間槽數量來讓自動摧毀行動。"
L["LMItemMinValue"] = "最小物品價值拾取"
L["LMKeepPLOpenTitle"] = "當個人時保持開啟"
L["LMKeepPLOpenTooltip"] = "勾選此以保持拾取視窗開啟當你無法拾取相關物品時，如果您正在處理個人的戰利品(如 背包的內容物，礦脈)"
L["LMSubTitle"] = "拾取管理員控制你的拾取和背包空間。"
L["LMTitle"] = "拾取管理員"
L["LMWarnInventoryFullTitle"] = "背包已滿"
L["LMWarnInventoryFullTooltip"] = "勾選讓Broker_Garbage顯示聊天訊息當'背包滿了。'錯誤觸發。"
L["LMWarnLMTitle"] = "拾取管理員"
L["LMWarnLMTooltip"] = "勾選時，Broker_Garbage將會列出通知提醒你分配拾取。"
L["lootJunkTitle"] = "拾取 '垃圾'"
L["lootJunkTooltip"] = "勾選拾取在你'垃圾'清單的物品像是正常物品。"
L["lootKeepTitle"] = "拾取 '保留'"
L["lootKeepTooltip"] = "勾選總是拾取在你'保留'清單的物品。"
L["minLootQualityTitle"] = "最低物品品質"
L["minLootQualityTooltip"] = "拾取經理將不會拾取任何低於此品質的物品。"
L["printCompareValueText"] = "勾選收到聊天訊息當Broker_Garbage不捨取物品，因為它比你所有已獲得的價值還少。"
L["printCompareValueTitle"] = "太便宜"
L["printDebugTitle"] = "列出除錯輸出"
L["printDebugTooltip"] = "勾選顯示LootManager的除錯資訊。往往對你而言是垃圾，你必須注意。"
L["printJunkText"] = "勾選收到聊天訊息當Broker_Garbage不拾取物品，因為在你的垃圾列表。"
L["printJunkTitle"] = "在垃圾列表"
L["printLockedText"] = "勾選收到聊天訊息當Broker_Garbage不拾取物品，因為已經鎖定(舉例：已經有人拾取)。"
L["printLockedTitle"] = "已鎖定"
L["printSpaceText"] = "勾選收到聊天訊息當Broker_Garbage不拾取物品，因為你的背包已經滿了且自動摧毀已禁用。"
L["printSpaceTitle"] = "缺少空間"
L["printValueText"] = "勾選獲得聊天訊息當Broker_Garbage不拾取物品，因為物品價值少於最小拾取價值(看下面)。"
L["printValueTitle"] = "低於門檻"
L["TOC_Notes"] = "Broker_Garbage的掛件，選擇性拾取與更多功能！"

elseif current == "zhCN" then
	
elseif current == "ruRU" then
	L["CreatureTypeBeast"] = "Животное" -- Needs review
L["LMAutoDestroyInstantTitle"] = "мгновенно" -- Needs review
L["LMAutoDestroyTitle"] = "Автоуничтожение" -- Needs review
L["LMAutoLootFishingTitle"] = "Рыбалка" -- Needs review
L["LMAutoLootTitle"] = "Автолут" -- Needs review
L["LMTitle"] = "Loot Manager" -- Needs review

elseif current == "frFR" then
	L["couldNotLootBlacklist"] = "%s n'a pas été ramassé car c'est dans notre liste Inclure / liste-noire." -- Needs review
L["couldNotLootLM"] = "%s n'a pas été ramassé. Vous êtes le Maître du Butin, distribuez l'objet manuellement." -- Needs review
L["couldNotLootLocked"] = "Impossible de ramasser %s car c'est verrouillé. Ramassez cela manuellement." -- Needs review
L["couldNotLootSpace"] = "Impossible de ramasser %s car votre inventaire est plein." -- Needs review
L["couldNotLootValue"] = "%s n'a pas été ramassé car cela ne vaut pas assez." -- Needs review
L["CreatureTypeBeast"] = "Bête" -- Needs review
L["LMAutoDestroyInstantTitle"] = "instantanément" -- Needs review
L["LMAutoDestroyInstantTooltip"] = "Si coché, Broker_Garbage supprimera les objets hors-limites au moment où il ramasse quelque chose. Sinon, la suppression aura lieu quand vous n'avez plus de place." -- Needs review
L["LMAutoDestroyTitle"] = "Destruction-auto" -- Needs review
L["LMAutoDestroyTooltip"] = "Si coché, Broker_Garbage agira quand votre inventaire est (presque) plein." -- Needs review
L["LMAutoLootFishingTitle"] = "Pêche" -- Needs review
L["LMAutoLootFishingTooltip"] = "Si coché, Broker_Garbage ramassera si vous êtes en train de pêcher." -- Needs review
L["LMAutoLootPickpocketTitle"] = "Vol à la tire" -- Needs review
L["LMAutoLootPickpocketTooltip"] = "Si coché, Broker_Garbage ramassera si vous êtes un Voleur et camouflé." -- Needs review
L["LMAutoLootSkinningTitle"] = "Dépeçage" -- Needs review
L["LMAutoLootSkinningTooltip"] = "Si coché, Broker_Garbage ramassera si la créature est dépeçable pour vous." -- Needs review
L["LMAutoLootTitle"] = "Ramassage auto" -- Needs review
L["LMAutoLootTooltip"] = "Si décoché, Broker_Garbage ne ramassera qu'en certaines occasion." -- Needs review
L["LMFreeSlotsTitle"] = "Emplacements libres minimum" -- Needs review
L["LMFreeSlotsTooltip"] = "Définissez le nombre minimum d'emplacements libres gardés par l'auto-destruction." -- Needs review
L["LMItemMinValue"] = "Valeur d'objet minimum" -- Needs review
L["LMSubTitle"] = [=[Le Loot Manager prend contrôle du ramassage si vous le désirez.
Si vous utilisez le ramassage auto, maintenez MAJ pour le désactiver temporairement.]=] -- Needs review
L["LMTitle"] = "Loot Manager" -- Needs review
L["LMWarnLMTitle"] = "Alerte : Maître du Butin" -- Needs review
L["LMWarnLMTooltip"] = "Si coché, Broker_Garbage affichera un message vous rappelant d'assigner les objets." -- Needs review

elseif current == "ptBR" then
	
elseif current == "itIT" then
	
elseif current == "koKR" then
	
elseif current == "esMX" then
	
elseif current == "esES" then
	
end
