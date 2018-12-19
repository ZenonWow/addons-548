--[[
	This file imports localization data from curse.com
	If you wish to get your language and/or translations used, submit them at http://wow.curseforge.com/addons/broker_garbage/localization and inform me via private message or an addon issue ticket
--]]
local _, BGC = ...
local L = BGC.locale

local current = GetLocale()
if current == "zhTW" then
	L["actionButtonsUse"] = [=[|cffffd200拍賣按鈕|r
下面這視窗你可以看到5個按鈕和搜尋條。
|TInterface\Icons\Spell_ChargePositive:18|t |cffffd200附加|r: 新增物品到目前顯示的列表。只需要拖曳到附加。新增|cffffd200分類|r，右鍵-點擊 附加並且選擇分類。
|cffAAAAAA例如 "Tradeskill > Recipe" "Misc > Key"|r
|TInterface\Icons\Spell_ChargeNegative:18|t |cffffd200減少|r: 點選在列表裡標記的物品。當你點擊減少，就會從列表中移除。
|TInterface\Icons\INV_Misc_GroupLooking:18|t |cffffd200局部|r: 被標記的物品會放到你的局部列表，這想規則只作用在你目前啟動的角色。
|TInterface\Icons\INV_Misc_GroupNeedMore:18|t |cffffd200全局|r: 某些是局部，只有這項物品會被放到你的全局列表。這些規則對你所有角色都有效。
|TInterface\Icons\INV_Misc_Coin_02:18|t |cffffd200Set Price|r: Marked items will get their value set to whatever is specified in the following popup dialogue.
|TInterface\Buttons\UI-GroupLoot-Pass-UP:18|t |cffffd200清空|r: 點擊這按鈕來移除任何角色個別(局部)物品。Shift-點擊 清空任何帳號的廣泛(局部)規則。|cffff0000使用警告!|r]=]
L["addedTo_autoSellList"] = "在商人時%s自動賣出。"
L["addedTo_exclude"] = "%s已新增到保留列表。"
L["addedTo_forceVendorPrice"] = "%s只會有它認定的商店價格。"
L["addedTo_include"] = "%s已新增到垃圾列表。"
L["anythingCalled"] = "物品名稱"
L["armorClass"] = "護甲類型"
L["AuctionAddon"] = "拍賣插件"
L["AuctionAddonTooltip"] = "Broker_Garbage會從這插件獲得拍賣價值。如果沒有在列表，你可能扔然有Broker_Garbage所不知道的插件的拍賣價值。"
L["autoRepairGuildText"] = "勾選允許Broker_Garbage使用公會金錢來修理。"
L["autoRepairGuildTitle"] = "使用公會資金"
L["autoRepairText"] = "勾選來自動修理當在商人時。"
L["autoRepairTitle"] = "自動修理"
L["autoSellText"] = "勾選讓Broker_Garbage自動賣出你的灰色和垃圾物品。"
L["autoSellTitle"] = "自動賣出"
L["AverageDropValueTitle"] = "平均丟棄價值"
L["AverageDropValueTooltip"] = "你所丟棄/刪除的物品平均價值。計算如金錢失去/物品丟棄。"
L["AverageSellValueTitle"] = "平均賣出價值"
L["AverageSellValueTooltip"] = "你所獲得的物品平均價值。計算如金錢獲得/物品賣出。"
L["BasicOptionsText"] = "你不想要自動賣出/修理?和商人說話時按住Shift(根據你的設定)!"
L["BasicOptionsTitle"] = "基本設定"
L["categoriesHeading"] = "分類"
L["categoryTestItemEntry"] = "%s不在任何已使用的分類。"
L["categoryTestItemSlot"] = "拖物品到這個槽來搜尋任何有包含它的分類。"
L["categoryTestItemTitle"] = [=[%s已經在這些分類...
]=]
L["categoryTestOthersTitle"] = "整體的結果在LibPeriodic的目錄:" -- Needs review
L["CollectMemoryUsageTooltip"] = "|cffffffff點擊|r 開始內建的垃圾收集。"
L["debugTitle"] = "列出除錯輸出"
L["debugTooltip"] = "勾選顯示Broker_Garbage的除錯資訊。往往對你而言是垃圾，你必須注意。"
L["defaultListsText"] = "預設列表"
L["defaultListsTooltip"] = [=[|cffffffff點擊|r 手動建立預設局部列表項目。
 |cffffffffShift-點擊|r 建立預設全局列表。]=]
L["disableKey_ALT"] = "ALT"
L["disableKey_CTRL"] = "CTRL"
L["disableKey_None"] = "無"
L["disableKey_SHIFT"] = "SHIFT"
L["DKTitle"] = "暫時停用快捷鍵"
L["DKTooltip"] = "設定快捷鍵來暫時性的停用BrokerGarbage。"
L["dropQualityText"] = "選到物品門檻可能被列舉為可刪除。預設：貧乏"
L["dropQualityTitle"] = "丟棄品質"
L["enchanterTitle"] = "附魔"
L["enchanterTooltip"] = [=[勾選這如果你有/知道附魔師。
當勾選分解價值被考慮，那些高於商店價格。]=]
L["equipmentManager"] = "裝備管理"
L["GlobalItemsSoldTitle"] = "物品賣出"
L["GlobalMoneyEarnedTitle"] = "總共賺取金額"
L["GlobalMoneyLostTitle"] = "總共失去金額"
L["GlobalSetting"] = [=[
|cffffff9a這設定是全局。]=]
L["GlobalStatisticsHeading"] = "帳號廣泛統計："
L["GroupBehavior"] = "行為"
L["GroupDisplay"] = "顯示"
L["GroupOutput"] = "文字輸出"
L["GroupTooltip"] = "提示"
L["GroupTresholds"] = "門檻"
L["hideZeroTitle"] = "隱藏價值0銅的物品"
L["hideZeroTooltip"] = "勾選來隱藏不值任何的物品。預設啟用。"
L["iconButtonsUse"] = [=[|cffffd200物品按鈕|r
對任何物品你可以看到圖示，如果分類或是或是伺服器無法辨識的問題。
在左上的任何按鈕你可以看見"G"(或是沒有)。如果有，物品在你的|cffffd200全局列表|r，指的是對你所有角色都有影響。
在你垃圾列表的物品也有個|cffffd200限制|r。會在右下角顯示小數字，在按鈕上使用|cffffd200滑鼠滾輪|r你可以改變數字。For categories, the number of all corresponding items will be added up.
If a limit is surpassed, items will be considered expendable, or in case of Keep-List limits regarded as regular items.]=]
L["inDev"] = "根據發展"
L["invalidArgument"] = "你輸入無效的參數。請檢查你的輸入並再一次嘗試。"
L["itemAlreadyOnList"] = "%s已經在列表!"
L["ItemsDroppedTitle"] = "物品丟棄"
L["keepForLaterDETitle"] = "分解技能差距"
L["keepForLaterDETooltip"] = "保留需要至多<x>更多技能點數來由你的角色分解。"
L["keepMaxItemLevelText"] = "勾選以保留最高物品等級裝備，當出售過時裝備時。"
L["keepMaxItemLevelTitle"] = "保留最高物品等級"
L["LDBDisplayTextHelpTooltip"] = [=[|cffffffff基本標籤:|r
[itemname] - 物品連結
[itemicon] - 物品圖示
[itemcount] - 物品統計
[itemvalue] - 物品價值
[junkvalue] - 總共自動賣出價值

|cffffffff背包空間標籤:|r
[freeslots] - 空間包包槽
[totalslots] - 所有包包槽
[basicfree],[specialfree] - 空間
[basicslots],[specialslots] - 總共

|cffffffff顏色標籤:|r
[bagspacecolor]... - 所有包包
[basicbagcolor]... - 只有基本
[specialbagcolor]... - 只有特別
...[endcolor] 結束部分顏色]=]
L["LDBDisplayTextTitle"] = "LDB顯示文字"
L["LDBDisplayTextTooltip"] = "設定在LDB插件顯示的文字。"
L["LDBNoJunkTextTooltip"] = "設定當沒有垃圾時顯示的文字。"
L["limitSet"] = "%s已經被分配一個限制%d。"
L["listsBestUse"] = [=[|cffffd200列表舉例|r
不要忘記使用預設列表!他們提供最好的例子。
首先，放置任何你不想失去的物品在你的|cffffd200保留列表|r。用好分類使用(看以下)! 如果拾取管理員啟動，將會嘗試拾取物品。
|cffAAAAAA例如 class reagents, flasks|r
物品在你|cffffd200垃圾列表|r將被任何時候被丟棄。
|cffAAAAAA例如 summoned food & drink, argent lance|r
假如你遇到高度高估的物品，放置他們到你的|cffffd200Fixed Price List|r。他們就只會有商店價格而不是拍賣或是分解價格。Alternatively, you can set a custom price by using |TInterface\Icons\INV_Misc_Coin_02:18|t.
|cffAAAAAAe.g. fish oil (vendor price), Broiled Dragon Feast (custom price of e.g. 20g)|r
放置物品到你的|cffffd200賣出列表|r當你訪問商人會被賣出。
|cffAAAAAA例如 water as a warrior, cheese|r]=]
L["listsSpecialOptions"] = [=[|cffffd200垃圾列表特別設定|r
|cffffd200賣出垃圾列表物品|r: 對那些不想要區分賣出列表跟垃圾列的人這設定是有用的。如果你勾選，當你訪問商店任何在你垃圾或賣出列表的物品會被賣出。
|cffffd200使用真實的價值|r: 這設定改變垃圾列表的行為。根據預設(禁用)垃圾列表會讓他們的價值設定為0銅(統計扔然會工作得很好!)並且第一時間被顯示在提示中。如果你啟用這設定，這些物品會保留他們合理的價值並且只會在提示裡顯示一次他們的價值。]=]
L["LocalStatisticsHeading"] = "角色(%s)的統計:"
L["LODemote"] = "|cffffffff點擊|r讓任何被標記的物品被使用作為角色的個別規則。"
L["LOEmptyList"] = [=[|cffff0000注意!|r
|cffffffff點擊|r清空任何局部列表項目。
|cffff0000Shift-點擊!|r 清空任何全局項目。]=]
L["LOIncludeAutoSellText"] = "賣出垃圾列表物品"
L["LOIncludeAutoSellTooltip"] = "勾選來自動賣出在你包含列表裡的物品當在商人時。沒有價值的物品會被忽略。"
L["LOMinus"] = "從列表中選擇物品移除，然後|cffffffff點擊|r這裡。"
L["LOPlus"] = [=[|cffffffff拖曳|r物品到按鈕來新增物品到列表。
|cffffffff右鍵-點擊|r 新增種類!]=]
L["LOPromote"] = "|cffffffff點擊|r來使用任何被標記的物品作為帳號的廣泛規則。"
L["LOSetPrice"] = "|cffffffff點擊|r 以為所有選定的項目設定一個自訂價格。"
L["LOSubTitle"] = [=[|cffffd200垃圾|r: 在列表的物品可能會被丟出如果背包需要空間。
|cffffd200保留|r: 在列表的物品不會被刪除或賣出。
|cffffd200商店價格|r: 在列表裡的物品只使用商店價值。(這列表是全局的)
|cffffd200賣出|r: 在列表的物品當在商人時會被賣掉。這也只使用商店價值。

!! Always use the 'Rescan Inventory' button after you make changes !!]=]
L["LOTabTitleAutoSell"] = "賣出"
L["LOTabTitleExclude"] = "保留"
L["LOTabTitleInclude"] = "垃圾"
L["LOTabTitleVendorPrice"] = "修正過價格"
L["LOTitle"] = "列表"
L["LOUseRealValues"] = "使用實際的垃圾物品價值"
L["LOUseRealValuesTooltip"] = "勾選來讓垃圾物品被考慮到實際的價值，而不是0銅。"
L["LPTNotLoaded"] = "LibPeriodicTable未載入"
L["maxHeightText"] = "設定提示的高度。預設：220"
L["maxHeightTitle"] = "最大高度"
L["maxItemsText"] = "設定多少行你要顯示在提示裡。預設：9"
L["maxItemsTitle"] = "最多物品"
L["MemoryUsageTitle"] = "記憶體使用(KB)"
L["minSlotsSet"] = "拾取管理員嘗試保留至少%s空間。"
L["minValueSet"] = "物品價值小於%s將不會再被捨取。"
L["moneyFormatText"] = "改變金錢顯示方式。"
L["moneyFormatTitle"] = "金錢格式"
L["na"] = "不可用"
L["namedItems"] = "物品名稱..."
L["namedItemsInfo"] = "|cffffd200增加物品名稱規則|r|n插入一個物品名稱或圖示:|n例如 \"|cFF36BFA8卷軸 *|r\"將會符合\"|cFF2bff58敏捷卷軸|r\" 或 \"|cFF2bff58虎之卷軸|r\""
L["overrideLPTTitle"] = "覆蓋LPT垃圾"
L["overrideLPTTooltip"] = [=[勾選忽略任何LibPeriodicTable分類資料庫的灰色物品。
某些物品不再需要(灰色)但是扔然在列表中 例如：藥劑在LPT中。]=]
L["PTCategoryTest"] = "分類測試"
L["PTCategoryTestDropdownText"] = "選擇分類字串"
L["PTCategoryTestDropdownTitle"] = "分類檢查"
L["PTCategoryTestExplanation"] = [=[只需選擇以下的分類就會顯示在你背包相符的所有物品。
分類資訊由LibPeriodicTable提供。]=]
L["reportDEGearTitle"] = "報告分解淘汰的裝備"
L["reportDEGearTooltip"] = "勾選當物品變淘汰時列出訊息(根據TopFit所指)所以你可能不會分解。"
L["requiresLootManager"] = "這個命令須要拾取經理。"
L["rescanInventoryText"] = "更新背包"
L["rescanInventoryTooltip"] = "|cffffffff點擊|r 讓Broker_Garbage重新掃描你的背包。當你改變列表項目都要這樣做!"
L["ResetAllText"] = "重置全部"
L["ResetAllTooltip"] = "|cffffffff點擊|r 重置所有角色個別統計。|cffffffffSHIFT-點擊|r 清除所有全局統計。"
L["ResetStatistic"] = [=[|cffffffff點擊|r 重置統計。
|cFFff0000警告：這無法完成。]=]
L["ResetToDefault"] = "重置到預設值。"
L["restackTitle"] = "自動重新堆疊"
L["restackTooltip"] = "勾選自動壓縮你的背包物品在你拾取之後。"
L["search"] = "搜尋..."
L["sellLogTitle"] = "列出賣出紀錄"
L["sellLogTooltip"] = "勾選列出任何由Broker_Garbage賣出的物品到聊天視窗。"
L["sellNotUsableText"] = [=[勾選讓Broker_Garbage賣出所有你不能穿的靈魂綁定裝備。
(只在不是附魔師使用)]=]
L["sellNotUsableTitle"] = "賣出無法使用裝備"
L["setPriceInfo"] = "|cffffd200設定自訂價格|r|n點擊商店價格以使用商業價格。"
L["showAutoSellIconText"] = "勾選顯示圖示來手動地自動賣出當在商人時。"
L["showAutoSellIconTitle"] = "顯示商人圖示"
L["showEarnedText"] = "勾選顯示角色賺得的金錢(根據賣出垃圾)"
L["showEarnedTitle"] = "賺得"
L["showIconText"] = "勾選在提示裡的物品連結前面顯示物品圖示。"
L["showIconTitle"] = "圖示"
L["showItemTooltipDetailText"] = "勾選以顯示Broker_Garbage指定標籤的詳細訊息在物品的工具提示。"
L["showItemTooltipDetailTitle"] = "顯示原因"
L["showItemTooltipLabelText"] = "勾選以顯示Broker_Garbage的指定標籤在物品的工具提示。"
L["showItemTooltipLabelTitle"] = "顯示標籤"
L["showLostText"] = "勾選在提示上顯示角色失去的金錢。"
L["showLostTitle"] = "失去"
L["showNothingToSellText"] = "勾選顯示聊天訊息當在商人時，但是卻沒有東西可以賣。"
L["showNothingToSellTitle"] = "'沒有東西可以賣'"
L["showSourceText"] = "勾選顯示在提示的最後一行，顯示物品數值來源。"
L["showSourceTitle"] = "來源"
L["slashCommandHelp"] = [=[以下命令是可行的:
    |cFF36BFA8config|r 開啟設定面板。
    |cFF36BFA8add|r |cFF2bff58<list>|r |cFF2bff58<item>|r Add an item/category to a list.
    |cFF36BFA8remove|r |cFF2bff58<list>|r |cFF2bff58<item>|r Remove item/category from a given list.
        Possible list names: |cFF2bff58keep|r, |cFF2bff58junk|r, |cFF2bff58vendor|r, |cFF2bff58forceprice|r
    |cFF36BFA8update|r |cFF2bff58<itemID>|r Refresh saved data
    |cFF36BFA8format ||cFF2bff58<text>|r 讓你自訂LDB顯示文字，|cFF2bff58reset|r 重置。
    |cFF36BFA8categories|r |cFF2bff58<item>|r list of used categories with this item.]=]
L["SNUMaxQualityText"] = "選擇最大物品品質來賣出當'賣出無法使用裝備'或是'淘汰的護甲'被勾選。"
L["SNUMaxQualityTitle"] = "賣出品質"
L["StatisticsHeading"] = "統計"
L["StatisticsLocalAmountEarned"] = "總共賺得"
L["StatisticsLocalAmountLost"] = "總共失去"
L["TOC_Notes"] = "Broker_Garbage的設置面板與它的掛件"
L["tooltipHeadingOther"] = "其它"
L["TopFitOldItem"] = "淘汰的護甲"
L["TopFitOldItemText"] = "如果插件TopFit已載入，Broker_Garbage可以請求淘汰的裝備並且直接賣掉。"
L["unknown"] = "未知"
L["updateCache"] = "請更新物品快取藉由指令 /garbage update"
L["warnClamsText"] = [=[勾選時，Broker_Garbage會警告你有蚌在你的背包。
當蚌堆疊，你不會浪費任何槽因為沒有勾選這。]=]
L["warnClamsTitle"] = "蚌"
L["warnContainersText"] = "勾選時，Broker_Garbage會警告你有未開啟的箱子。"
L["warnContainersTitle"] = "箱子"

elseif current == "zhCN" then
	L["autoRepairGuildText"] = "如果选择，Broker_Garbage将不会再尝试使用公会仓库金钱修复。"
L["autoRepairGuildTitle"] = "没有公会修理"
L["autoRepairText"] = "切换自动修复你的装备"
L["autoRepairTitle"] = "自动修复"
L["autoSellText"] = "切换自动卖出你的装备物品"
L["autoSellTitle"] = "自动卖出"
L["AverageDropValueTitle"] = "平均丢弃价值"
L["AverageSellValueTitle"] = "平均卖出价值"
L["BasicOptionsText"] = "你不想要自动卖出/修理?和商人说话时按住Shift(根据你的设定)!"
L["BasicOptionsTitle"] = "基本设定"
L["CollectMemoryUsageTooltip"] = "点击开始垃圾收集(内建功能)"
L["disableKey_ALT"] = "ALT"
L["disableKey_CTRL"] = "CTRL"
L["disableKey_None"] = "无"
L["disableKey_SHIFT"] = "SHIFT"
L["DKTitle"] = "暂存。停用按键"
L["DKTooltip"] = "设定一个按键来暂时性的停用BrokerGarbage。"
L["dropQualityText"] = "最多选择treshold物品可能被列表当作可删除。预设：Poor (0)"
L["dropQualityTitle"] = "丢弃品质"
L["enchanterTitle"] = "附魔"
L["enchanterTooltip"] = "勾选这个如果你有/知道附魔。当勾选，Broker_Garbage将使用分解物品，通常高于商店价钱。"
L["GlobalItemsSoldTitle"] = "物品卖出"
L["GlobalMoneyEarnedTitle"] = "全部已赚的总额"
L["GlobalMoneyLostTitle"] = "全部失去的总额"
L["GlobalStatisticsHeading"] = "整体金钱统计："
L["ItemsDroppedTitle"] = "物品丢弃"
L["LDBDisplayTextHelpTooltip"] = [=[字符串格式帮助:
[itemname] - 物品连结
[itemcount] - 物品计数
[itemvalue] - 物品数值
[freeslots] - 任意包包槽
[totalslots] - 所有包包槽
[junkvalue] - 所有自动售出数值
[bagspacecolor]...[endcolor]来着色]=]
L["LDBDisplayTextTitle"] = "LDB显示文字"
L["LDBDisplayTextTooltip"] = "使用这项来改变你在LDB显示里所看到的文字。"
L["LDBNoJunkTextTooltip"] = "使用这改变你所看到的文字当没有垃圾被显示。"
L["limitSet"] = "%s已经被分配一个限制%d。"
L["LocalStatisticsHeading"] = "%s的统计:"
L["maxHeightText"] = "设定提示高度。预设：220"
L["maxHeightTitle"] = "最大。高度"
L["maxItemsText"] = "设定多少行你要显示在提示。预设：9"
L["maxItemsTitle"] = "最大。物品"
L["MemoryUsageTitle"] = "内存使用(KB)"
L["minValueSet"] = "物品价值小于%s将不会再被舍取。"
L["moneyFormatText"] = "改变金钱显示方式(即金/银/铜)。预设：2"
L["moneyFormatTitle"] = "金钱格式"
L["sellNotUsableText"] = "勾选这来让Broker_Garbage卖出所有你不能穿的灵魂绑定装备。"
L["sellNotUsableTitle"] = "卖出装备"
L["showAutoSellIconText"] = "切换显示图标来手动卖出。"
L["showAutoSellIconTitle"] = "显示图标"
L["showEarnedText"] = "切换显示提示'金钱赚得'行。"
L["showEarnedTitle"] = "显示金钱获得"
L["showLostText"] = "切换显示'金钱失去'行提示。"
L["showLostTitle"] = "显示金钱失去"
L["showNothingToSellText"] = "切换显示提示当在一个商店且没有东西可以卖。"
L["showNothingToSellTitle"] = "'没有东西可以卖'"
L["showSourceText"] = "切换在提示显示最后列，显示物品数值来源。"
L["showSourceTitle"] = "显示来源"
L["slashCommandHelp"] = [=[以下命令可以启动: |cffc0c0c0/garbage|r
|cffc0c0c0config|r 开启设定面板。
|cffc0c0c0format |cffc0c0ffformatstring|r 让你自订LDB显示文字， |cffc0c0c0 format reset|r 重置。
|cffc0c0c0stats|r 回传统计。
|cffc0c0c0limit |cffc0c0ffitemLink/ID count|r 在目前的角色上设定给予物品限制。
|cffc0c0c0globallimit |cffc0c0ffitemLink/ID count|r 设定所有角色限制。
|cffc0c0c0value |cffc0c0ffvalueInCopper|r 设定舍取物品的最小数值(Loot Manager 需要)。]=]
L["SNUMaxQualityText"] = "当'卖出装备'被勾选，选择最大质量来卖。"
L["SNUMaxQualityTitle"] = "最大。品质"
L["StatisticsHeading"] = [=[统计，所有人都需要！
要删除任何一部分，点击红x。]=]
L["StatisticsLocalAmountEarned"] = "总共赚得"
L["StatisticsLocalAmountLost"] = "总共失去"

elseif current == "ruRU" then
	L["AverageDropValueTitle"] = "Средняя ценность выброшенных"
L["AverageSellValueTitle"] = "Среднее  ценность продаж"
L["BasicOptionsText"] = "Не хотите производить авто-продажу/ремонт? Удерживайте Shift (в зависимости от ваших настроек) при беседе с торговцем!"
L["BasicOptionsTitle"] = "Основные настройки"
L["CollectMemoryUsageTooltip"] = "Клик -  произвести сбор мусора Blizzard."
L["disableKey_ALT"] = "ALT"
L["disableKey_CTRL"] = "CTRL"
L["disableKey_None"] = "Нету"
L["disableKey_SHIFT"] = "SHIFT"
L["DKTitle"] = "Клавиша временного отключения"
L["DKTooltip"] = "Установка клавиши, для временного отключения BrokerGarbage."
L["dropQualityText"] = "Выберите порог предметов по качеству которые могут быть занесены в список удаления. По умолчанию: Низкое (0)"
L["dropQualityTitle"] = "Качество для выбрасывания"
L["enchanterTitle"] = "Наложение чар"
L["enchanterTooltip"] = "Выберите данную опцию, если вы владеете умением Наложение чар. Если отмечено, Broker_Garbage будет использовать ценность Распыления для предметов которые можно распылить, зто как правило, выгоднее, чем продавать торговцу."
L["GlobalItemsSoldTitle"] = "Продано предметов"
L["GlobalMoneyEarnedTitle"] = "Всего заработано"
L["GlobalMoneyLostTitle"] = "Всего потрачено"
L["GlobalStatisticsHeading"] = "Общая статистика валюты:"
L["ItemsDroppedTitle"] = "Выброшено предметов"
L["LDBDisplayTextHelpTooltip"] = [=[Основные теги:
[itemname] - ссылка на предмет
[itemcount] - количество предмета
[itemvalue] - цена предмета
[freeslots] - свободные ячейки сумки
[totalslots] - всего ячеек сумки
[junkvalue] - общая цена авто-продажы
[bagspacecolor]...[endcolor] - окраска]=]
L["LDBDisplayTextTitle"] = "Вид текста на LDB"
L["LDBDisplayTextTooltip"] = "Настройка отображаемого текста на панеле LDB."
L["LDBNoJunkTextTooltip"] = "Настройка отображаемого текста когда нету хлама."
L["limitSet"] = "%s был назначен предел %d."
L["maxHeightText"] = "Установка максимальной высоты подсказки. По умолчанию: 220"
L["maxHeightTitle"] = "Макс. высота"
L["maxItemsText"] = "Установка количества строк отображаемых в подсказке. По умолчанию: 9"
L["maxItemsTitle"] = "Макс. предметов"
L["MemoryUsageTitle"] = "Использование памяти (кБ)"
L["minValueSet"] = "Предметы, каторых ценность ниже %s, больше не будут подбераться."
L["moneyFormatText"] = "Изменение формата отображения денег (например: золото/серебро/медь). По умолчанию: 2"
L["moneyFormatTitle"] = "Формат денег"
L["sellNotUsableText"] = [=[Выбрав данную опцию, позволит Broker_Garbage продавать все снарежение с меткой 'Персональный предмет' которое вы не можете носить.
(Применяется только, если вы не владеете умением Наложение чар)]=]
L["sellNotUsableTitle"] = "Продажа снаряжения"
L["showAutoSellIconText"] = "Вкл/выкл отображения иконки для ручной авто-продажи у торговца."
L["showAutoSellIconTitle"] = "Показать иконку"
L["showEarnedText"] = "Вкл/выкл отображения строки количества заработанных денег в подсказке."
L["showEarnedTitle"] = "Заработано денег"
L["showLostText"] = "Вкл/выкл отображения строки количества потраченных денег в подсказке."
L["showLostTitle"] = "Потрачено денег"
L["showNothingToSellText"] = "Вкл/выкл отображения извещения когда вы у торговца но у вас нечего продать ему."
L["showNothingToSellTitle"] = "'Нечего продать'"
L["showSourceText"] = "Вкл/выкл отображения в последней графе подсказки источник цены предмета."
L["showSourceTitle"] = "Показать источник"
L["slashCommandHelp"] = [=[Доступны следующие команды: |cffc0c0c0/garbage|r
|cffc0c0c0config|r открывает панель настроек.
|cffc0c0c0format |cffc0c0ffformatstring|r позволяет вам настроить отображение LDB текста, |cffc0c0c0 format reset|r сброс.
|cffc0c0c0stats|r вывод статистики.
|cffc0c0c0limit |cffc0c0ffitemLink/ID count|r устанавливает предел для данного предмета у текущего персонажа.
|cffc0c0c0globallimit |cffc0c0ffitemLink/ID count|r устанавливает предел для всех персонажей.
|cffc0c0c0value |cffc0c0ffvalueInCopper|r устанавливает мин. цену предмета для выполнения сбора (требуется Менеджер добычи).]=]
L["SNUMaxQualityText"] = "Выберите максимальное качество предмета для продажи при включенной опции 'Продажа снаряжения'."
L["SNUMaxQualityTitle"] = "Макс. качество"
L["StatisticsHeading"] = [=[Статистика, каждый нуждается в ней!
Чтобы удалить какую-либо часть из неё, нажмите на красный x.]=]
L["StatisticsLocalAmountEarned"] = "Заработано"
L["StatisticsLocalAmountLost"] = "Потрачено"

elseif current == "frFR" then
	L["autoRepairGuildText"] = "Quand sélectionné, Broker_Garbage n'essaiera jamais de réparer avec l'argent de la banque de guilde."
L["autoRepairGuildTitle"] = "Pas de réparation de guilde"
L["autoRepairText"] = "Active la réparation automatique de votre équipement chez les marchands."
L["autoRepairTitle"] = "Réparation auto"
L["autoSellText"] = "Active la vente automatique de vos objets gris chez les marchands."
L["autoSellTitle"] = "Vendre auto"
L["AverageDropValueTitle"] = "Valeur moyenne supprimée"
L["AverageSellValueTitle"] = "Valeur moyenne vendue"
L["BasicOptionsText"] = "Vous ne voulez pas de vente/réparation auto ? Maintenez Shift (selon votre réglage) en parlant au marchand !"
L["BasicOptionsTitle"] = "Options basiques"
L["CollectMemoryUsageTooltip"] = "Cliquez pour lancer le garbage collection (fonction de Blizzard)"
L["disableKey_ALT"] = "ALT"
L["disableKey_CTRL"] = "CTRL"
L["disableKey_None"] = "Aucun"
L["disableKey_SHIFT"] = "MAJ"
L["DKTitle"] = "Touche désactivation temp."
L["DKTooltip"] = "Définissez une touche pour désactiver BrokerGarbage temporairement."
L["dropQualityText"] = "Sélectionnez à quel seuil les objets seront considérés comme supprimables. Défaut : Médiocre (0)"
L["dropQualityTitle"] = "Qualité d'objet."
L["enchanterTitle"] = "Enchanteur"
L["enchanterTooltip"] = "Cochez ici si vous avez/connaissez un enchanteur. Broker_Garbage utilisera alors la valeur du désenchantement pour les objets désenchantables, ce qui a souvent plus de valeur que les prix des marchands."
L["GlobalItemsSoldTitle"] = "Objets vendus"
L["GlobalMoneyEarnedTitle"] = "Montant total gagné"
L["GlobalMoneyLostTitle"] = "Montant total perdu"
L["GlobalStatisticsHeading"] = "Statistiques de richesse globale"
L["ItemsDroppedTitle"] = "Objets supprimés"
L["LDBDisplayTextHelpTooltip"] = [=[Formatage de l'affichage :
[itemname] - nom de l'objet
[itemcount] - nombre d'objets
[itemvalue] - valeur de l'objet
[freeslots] - emplacements de sac libres
[totalslots] - emplacements de sac total
[junkvalue] - valeur totale des déchets
[bagspacecolor]...[endcolor] pour coloriser]=]
L["LDBDisplayTextTitle"] = "Affichage LDB"
L["LDBDisplayTextTooltip"] = "Utilisez ceci pour changer le texte de l'affichage LDB."
L["LDBNoJunkTextTooltip"] = "Utilisez ceci pour changer le texte quand il n'y a aucun déchet à afficher."
L["limitSet"] = "%s a une limite de %d."
L["LocalStatisticsHeading"] = "Statistiques de %s :"
L["maxHeightText"] = "Défini la hauteur de l'infobulle. Défaut : 220"
L["maxHeightTitle"] = "Hauteur max."
L["maxItemsText"] = "Définissez combien de lignes vous souhaitez afficher dans l'infobulle. Défaut : 9"
L["maxItemsTitle"] = "Objets max."
L["MemoryUsageTitle"] = "Utilisation mémoire (ko)"
L["minValueSet"] = "Les objets valant moins de %s ne seront plus ramassés."
L["moneyFormatText"] = "Change l'affichage de la monnaie (or/argent/cuivre). Défaut : 2"
L["moneyFormatTitle"] = "Format de monnaie"
L["PTCategoryTest"] = "Ajouter des catégories"
L["PTCategoryTestExplanation"] = "Naviguez ce menu et ajoutez les catégories en cliquant dessus."
L["rescanInventoryText"] = "Rescanner l'inventaire"
L["rescanInventoryTooltip"] = "Cliquez pour rescanner manuellement votre inventaire. Généralement pas nécessaire."
L["sellNotUsableText"] = [=[Cochez pour que Broker_Garbage vende tout l'équipement lié que vous ne pouvez porter.
(seulement si vous n'êtes pas enchanteur)]=]
L["sellNotUsableTitle"] = "Vendre équipement"
L["showAutoSellIconText"] = "Affiche une icône pour auto-vendre manuellement aux marchands."
L["showAutoSellIconTitle"] = "Afficher icône"
L["showEarnedText"] = "Affiche dans l'infobulle la ligne 'Argent gagné'"
L["showEarnedTitle"] = "Afficher 'Argent gagné'"
L["showLostText"] = "Affiche dans l'infobulle la ligne 'Argent perdu'"
L["showLostTitle"] = "Afficher 'Argent perdu'"
L["showNothingToSellText"] = "Affiche un message quand vous êtes à un marchand et qu'il n'y a rien à vendre."
L["showNothingToSellTitle"] = "'Rien à vendre'"
L["showSourceText"] = "Affiche la dernière colonne de l'infobulle, qui affiche la source de la valeur de l'objet."
L["showSourceTitle"] = "Montrer la source"
L["slashCommandHelp"] = [=[Les commandes suivantes sont disponibles: |cffc0c0c0/garbage|r
|cffc0c0c0config|r ouvre le panneau des options.
|cffc0c0c0format |cffc0c0ffformatstring|r vous permet de changer l'affichage LDB, |cffc0c0c0 format reset|r le réinitialise.
|cffc0c0c0stats|r affiche des statistiques.
|cffc0c0c0limit |cffc0c0ffitemLink/ID count|r définit une limite pour l'objet pour le personnage actuel.
|cffc0c0c0globallimit |cffc0c0ffitemLink/ID count|r définit une limite pour tous les personnages.
|cffc0c0c0value |cffc0c0ffvalueInCopper|r définit la valeur minimum d'un objet pour le ramasser (Loot Manager requis).]=]
L["SNUMaxQualityText"] = "Sélectionnez la qualité maximum à vendre quand 'Vendre équipement' est coché."
L["SNUMaxQualityTitle"] = "Qualité max."
L["StatisticsHeading"] = [=[Statistiques, tout le monde en a besoin !
Pour en supprimer une partie, cliquez le X rouge.]=]
L["StatisticsLocalAmountEarned"] = "Montant gagné"
L["StatisticsLocalAmountLost"] = "Montant perdu"

elseif current == "ptBR" then
	
elseif current == "itIT" then
	
elseif current == "koKR" then
	
elseif current == "esMX" then
	
elseif current == "esES" then
	
end
