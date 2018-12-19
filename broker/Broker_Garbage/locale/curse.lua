--[[
	This file imports localization data from curse.com
	If you wish to get your language and/or translations used, submit them at http://wow.curseforge.com/addons/broker_garbage/localization and inform me via private message or an addon issue ticket
--]]
local _, BG = ...
local L = BG.locale

local current = GetLocale()
if current == "zhTW" then
	L["addedTo_exclude"] = "%s已經新增到保留列表。"
L["addedTo_forceVendorPrice"] = "%s只會考慮它自己的商店價錢。"
L["autoSellTooltip"] = "賣出物品：%s"
L["couldNotMoveItem"] = "錯誤！移動的物品並不符合要求的項目。"
L["couldNotRepair"] = "無法修理，因為你沒有足夠的錢。你需要%s。"
L["disenchantOutdated"] = "%1$s 已經淘汰並且應該分解。"
L["guildRepair"] = "(公會)"
L["headerAltClick"] = "Alt-點擊：使用商店價格"
L["headerCtrlClick"] = "CTRL-點擊：保留"
L["headerRightClick"] = "右鍵-點擊：設定"
L["headerShiftClick"] = "SHIFT-點擊：摧毀"
L["increaseTreshold"] = "提升品質門檻"
L["itemDeleted"] = "%1$sx%2$d 已經被刪除。"
L["label"] = "垃圾，沒有了！"
L["listAuction"] = "拍賣"
L["listCustom"] = "自訂價格"
L["listDisenchant"] = "分解"
L["listExclude"] = "保留"
L["listInclude"] = "包含"
L["listOutdated"] = "過時"
L["listSell"] = "自動出售"
L["listsUpdatedPleaseCheck"] = "你的列表已更新。請看看你的設定並且檢查是否符合你的需要。"
L["listUnusable"] = "不可用裝備"
L["listVendor"] = "商店"
L["moneyEarned"] = "金錢賺得："
L["moneyLost"] = "金錢損失："
L["noItems"] = "沒有物品刪除。"
L["openPlease"] = "未開啟的箱子在你的背包"
L["repair"] = "修理：%1$s%2$s。"
L["reportCannotSell"] = "這商人不買物品"
L["reportNothingToSell"] = "沒有東西可賣！"
L["sell"] = "賣出垃圾：%s。"
L["sellAndRepair"] = "賣出垃圾：%1$s，修理：%2$s%3$s。改變：%4$s。"
L["sellItem"] = "%3$s 賣出 %1$sx%2$d。"
L["TOC_Notes"] = "不再背包過滿！區別垃圾與寶物，並且找到物品以快速丟棄。"

elseif current == "zhCN" then
	L["autoSellTooltip"] = "卖出物品：%s"
L["headerCtrlClick"] = "CTRL-点击：保留"
L["headerRightClick"] = "右键点击设定"
L["headerShiftClick"] = "SHIFT-点击：摧毁"
L["increaseTreshold"] = "提升质量门坎"
L["itemDeleted"] = "%1$sx%2$d 已经被删除。"
L["label"] = "垃圾，去吧！"
L["moneyEarned"] = "金钱赚得："
L["moneyLost"] = "金钱失去："
L["noItems"] = "没有物品删除。"
L["openPlease"] = "请打开你的%s。它在你的背包，偷窃你的空间！"
L["repair"] = "修理：%s。"
L["reportNothingToSell"] = "没有东西可以卖！"
L["sell"] = "卖出垃圾：%s。"
L["sellAndRepair"] = "卖出垃圾：%1$s，修理：%2$s。改变：%3$s。"

elseif current == "ruRU" then
	L["addedTo_exclude"] = "%s добавлено в список Хранения."
L["autoSellTooltip"] = "Продано хлама на сумму: %s"
L["headerCtrlClick"] = "CTRL-Клик: Сохранить"
L["headerRightClick"] = "Right-Клик: настройки"
L["headerShiftClick"] = "SHIFT-Клик: уничтожить"
L["increaseTreshold"] = "Повышение порога качества"
L["itemDeleted"] = "%1$sx%2$d удален."
L["label"] = "Хлама, нету!"
L["moneyEarned"] = "Заработано денег:"
L["moneyLost"] = "Потрачено денег:"
L["noItems"] = "Нет предмета для удаления."
L["openPlease"] = "Пожалуйста, откройте ваш: %s. Оно в вашей сумке, занемает лишнее место!"
L["repair"] = "Потрачено на ремонт: %s."
L["reportNothingToSell"] = "Нечего продать!"
L["sell"] = "Продано хлама на сумму: %s."
L["sellAndRepair"] = "Продано хлама на сумму: %1$s, потрачено на ремонт: %2$s. Сдача: %3$s."

elseif current == "frFR" then
	L["autoSellTooltip"] = "Vendre les objets pour %s" -- Needs review
L["headerCtrlClick"] = "Ctrl-Clic : garder" -- Needs review
L["headerRightClick"] = "Clic-droit pour les options" -- Needs review
L["headerShiftClick"] = "MAJ-Clic : Détruire" -- Needs review
L["increaseTreshold"] = "Augmenter le seuil de qualité" -- Needs review
L["itemDeleted"] = "%1$sx%2$d a été détruit." -- Needs review
L["label"] = "La poubelle est vide" -- Needs review
L["moneyEarned"] = "Argent gagné :" -- Needs review
L["moneyLost"] = "Argent perdu :" -- Needs review
L["noItems"] = "Aucun objet à supprimer." -- Needs review
L["openPlease"] = "Ouvrez votre %s. C'est dans votre sac, ça prend de la place !" -- Needs review
L["repair"] = "Réparations pour %s." -- Needs review
L["reportNothingToSell"] = "Rien à vendre !" -- Needs review
L["sell"] = "Déchets vendus pour %s." -- Needs review
L["sellAndRepair"] = "Déchets vendus pour %1$s, réparations pour %2$s. Solde : %3$s." -- Needs review

elseif current == "ptBR" then
	
elseif current == "itIT" then
	
elseif current == "koKR" then
	
elseif current == "esMX" then
	
elseif current == "esES" then
	
end
