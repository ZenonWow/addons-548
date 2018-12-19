local GlobalAddonName, ExRT = ...

local L = ExRT.L

L.message = "Заметка"
L.marks = "Метки"
L.bossmods = "Боссмоды"
L.timers = "Таймеры"
L.raidcheck = "Проверка рейда"
L.marksbar = "Панель меток"
L.invite = "Автоинвайтер"
L.help = "Помощь"
L.cd2 = "Рейд-кулдауны"
L.sooitems = "Рейд-лут"
L.sallspells = "Заклинания"
L.scspells = "Классы"
L.sencounter = "Статистика боссов"
L.BossWatcher = "Журнал боя"
L.InspectViewer = "Осмотр рейда"
L.Coins = "Дополнительная добыча"

L.raidtargeticon1 = "{звезда}"
L.raidtargeticon2 = "{круг}"
L.raidtargeticon3 = "{ромб}"
L.raidtargeticon4 = "{треугольник}"
L.raidtargeticon5 = "{полумесяц}"
L.raidtargeticon6 = "{квадрат}"
L.raidtargeticon7 = "{крест}"
L.raidtargeticon8 = "{череп}"

L.messagebutsend = "Отправить"
L.messagebutclear = "Очистить"
L.messageButCopy = "Перенести в чистовик, сохранить и отправить"
L.messagebutfix = "Фиксировать"
L.messagebutfixtooltip = "Возможность перемещать и изменять размеры окна заметки"
L.messagebutalpha = "Прозрачность заметки"
L.messagebutscale = "Масштаб заметки"
L.messagebutsendtooltip = "Сохранить и отправить сообщение заметки всем учасникам рейда"
L.messageOutline = "Шрифт с обводкой"
L.messageBackAlpha = "Прозрачность фона"
L.messageTab1 = "Заметка"
L.messageTab2 = "Черновик"
L.NoteResetPos = "Сбросить расположение"
L.NoteResetPosTooltip = "Переместить фрейм заметки в центр экрана"
L.NoteColor = "Цвет"
L.NoteColorTooltip1 = "Текст, находящийся между тегами |cff00ff00||cXXXXXXXX|r (где XXXXXXXX - код цвета) и |cff00ff00||r|r будет окрашен."
L.NoteColorTooltip2 = "Выделите текст и выберите цвет в выпадающем списке для окраски."
L.NoteColorRed = "Красный"
L.NoteColorGreen = "Зеленый"
L.NoteColorBlue = "Синий"
L.NoteColorYellow = "Желтый"
L.NoteColorPurple = "Пурпурный"
L.NoteColorAzure = "Голубой"
L.NoteColorBlack = "Черный"
L.NoteColorGrey = "Серый"
L.NoteColorRedSoft = "Мягкий красный"
L.NoteColorGreenSoft = "Мягкий зеленый"
L.NoteColorBlueSoft = "Мягкий синий"

L.setminimap1 = "Скрыть иконку у мини-карты"
L.setauthor = "Автор"
L.setver = "Версия"
L.setcontact = "Контакты"
L.setEggTimerSlider = "Обновление каждые, мс."
L.SetThanks = "Благодарности"
L.YesText = "Да"
L.NoText = "Нет"
L.SetErrorInCombat = "Невозможно загрузить интерфейс, в связи с ограничениями Blizzard. Выйдите из режима боя и повторите попытку."
L.SetAdditionalTabs = "Дополнительные вкладки"

L.bossmodstot = "Престол Гроз"
L.bossmodsradenhelp = "Ра-ден bossmod. Игроки отсортированы в двух столбцах (2 и 4 группа в левом столбце, 3 и 5 - в правом). Игрок с дебафом чейны выделен зеленым цветом, игроки с дебафом восприимчивости - красным, без дебафов - белым"
L.bossmodsradenonly25 = "Внимание! Только для 25ппл рейдов"
L.bossmodsraden ="Ра-ден"
L.bossmodssoo = "Осада Оргриммара"
L.bossmodsalpha = "Прозрачность"
L.bossmodsscale = "Масштаб"
L.bossmodsclose = "Закрыть все боссмоды"
L.bossmodsmalkorok ="Малкорок"
L.bossmodsmalkorokai ="Малкорок AI"
L.bossmodsmalkorokhelp ="Малкорок bossmod. Левый клик по \"пирожку\" для выбора, правый для отмены."
L.bossmodsmalkorokaihelp ="Малкорок AI bossmod. Автоматический выбор \"пирожка\" с наименьшим количеством людей во время аое. Подсвечивается оранжевым в течении 5 секунд. Достаточно быть запущеным одновременно только у одного человека в рейде с промоутом."
L.bossmodsmalkorokdanger ="<<< Danger >>>"
L.bossmodsshaofpride = "Норусхен / Ша Гордыни"
L.bossmodsSpoilsofPandaria = "Пандарийские трофеи"
L.bossmodsAutoLoadTooltip = "Автоматическая загрузка боссмода на необходимом энкаунтере"
L.bossmodstok = "Ток Кровожадный"
L.BossmodsSpoilsofPandariaMogu = "Могу"
L.BossmodsSpoilsofPandariaKlaxxi = "Клакси"
L.BossmodsSpoilsofPandariaOpensBox = "открыл ящик на стороне"
L.BossmodsResetPos = "Сбросить расположение"
L.BossmodsResetPosTooltip = "Переместить фреймы всех боссмодов в центр экрана"
L.BossmodsMalkorokSkada = "Малкорок Skada"
L.BossmodsMalkorokSkadaTooltip = "Модуль для аддона Skada для подсчета эффективного исцеления на энкаунтере (Все исцеление при зеленом щите |TInterface\\Icons\\ability_malkorok_blightofyshaarj_green:0|t\|cff00ff00Крепкий древний барьер|r на цели будет считатся избыточным)"
L.BossmodsMalkorokSkadaError1 = "Skada не обнаружена"
L.BossmodsMalkorokSkadaError2 = "Модуль уже загружен"
L.BossmodsMalkorokSkadaOnLoad1 = "Модуль \"Малкорок Skada\" загружен!"
L.BossmodsMalkorokSkadaOnLoad2 = "Внимание! Для отключения модуля \"Малкорок Skada\" нужно перезагрузить пользовательский интерфейс коммандой чата \"/reload\""

L.timerstxt1 = "/rt pull\n/rt pull X\n/rt afk X\n/rt afk 0\n/rt timer S X\n|cFFFFFFFFПовторный запуск таймера пула до окончания действия текущего отменяет его|r\n\n\n/rt mytimer X"
L.timerstxt2 = "- таймер пула на 10 секунд\n- таймер пула на X секунд\n- таймер перерыва на X минут\n- отмена таймера перерыва\n- запустить таймер с названием S длительностью X секунд\n\n\n\n- обратный отсчет на таймере боя (должен быть включен) с X секунд"
L.timerattack = "Атака"
L.timerattackcancel = "Атака отменена"
L.timerattackt = "Атака через"
L.timerafk = "Перерыв"
L.timerafkcancel = "Перерыв отменен"
L.timermin = "минут"
L.timersec = "сек."
L.timerTimerFrame = "Включить таймер боя"
L.TimerTimeToKill = "Время до убийства цели"

L.raidchecknofood = "Нет еды"
L.raidchecknoflask = "Нет фласок"
L.raidcheckfood = "Проверить еду"
L.raidcheckfoodchat = "Опубликовать еду в чат"
L.raidcheckflask = "Проверить фласки"
L.raidcheckflaskchat = "Опубликовать фласки в чат"
L.raidcheckslak = "Публиковать слакеров в чат во время проверки готовности"
L.raidcheckPotion = "Поты: "
L.raidcheckHS = "Камни здоровья: "
L.raidcheckPotionCheck = "Включить слежение за потами и камнями здоровья"
L.raidcheckPotionLastPull = "Поты за последний бой"
L.raidcheckPotionLastPullToChat = "Поты за последний бой в чат"
L.raidcheckHSLastPull = "Камни здоровья за последний бой"
L.raidcheckHSLastPullToChat = "Опубликовать камни здоровья в чат"
L.raidcheckReadyCheck = "Проверка готовности"
L.raidcheckReadyCheckScale = "Масштаб"
L.raidcheckReadyCheckTest = "Показать тестовое окно"
L.raidcheckReadyCheckTimerTooltip = "Время исчезновения после окончания проверки (сек.):"
L.raidcheckReadyCheckSec = "сек."

L.marksbarstart = "Очистить"
L.marksbardel = "Удалить"
L.marksbarrc = "РЧ"
L.marksbarpull = "Пулл"
L.marksbarshowmarks = "Отображать метки"
L.marksbarshowpermarks = "Отображать конпки пермамарок"
L.marksbarshowfloor = "Отображать конпки меток на пол"
L.marksbarshowrcpull = "Отображать конпки рч и пулл"
L.marksbaralpha = "Прозрачность"
L.marksbarscale = "Масштаб"
L.marksbartmr = "Таймер пулла, сек.:"
L.marksbarWMView = "Вид меток:"
L.MarksBarResetPos = "Сбросить расположение"
L.MarksBarResetPosTooltip = "Переместить фрейм панели в центр экрана"

L.inviterank = "Звание:"
L.inviteinv = "Пригласить"
L.inviteguildonly = "Приглашать только тех, кто в гильдии"
L.invitewords = "Приглашать по ключевым словам в приват"
L.invitewordstooltip = "Ключевые слова для автоинвайта через пробел"
L.invitedis = "Распустить рейд"
L.inviteReInv = "Пересобрать рейд"
L.inviteaccept = "Автопринятие приглашение от друзей и согильдийцев"
L.inviteAutoPromote = "Автоматически назначать помощников в рейде"
L.inviteAutoPromoteTooltip = "Ники игроков для автоназначения помощников через пробел"
L.inviteAutoPromoteDontUseGuild = "Не использовать"
L.inviteHelpRaid = "Общее управление рейдом. В выпадающем списке выбирается минимальное звание для автоприглашений. Все игроки, находящиеся в нем или выше будут приглашены в рейд после нажатия кнопки \"".. L.inviteinv .."\". Так же можно распустить рейд или пересобрать его в течении 5 секунд."
L.inviteHelpAutoInv = "Приглашение в группу или рейд игроков, которые напишут вам в приватные сообщения любую из ключевых фраз, которые задаются в поле для ввода"
L.inviteHelpAutoAccept = "Автоматическое мгновенное принятие приглашений в группу или рейд"
L.inviteHelpAutoPromote = "Функция для рейд-лидера. Автоматическое повышение звания в рейде до помощника игрокам с выбранными никами или находящихся в гильдии в звании, выбранном в выпадающем списке, или выше."
L.inviteRaidDemote = "Разжаловать всех"

L.cd2fix = "Фиксировать"
L.cd2alpha = "Прозрачность кд"
L.cd2scale = "Масштаб кд"
L.cd2lines = "Количество строк кд"
L.cd2split = "Разделить на окна"
L.cd2splittooltip = "Разбить каждый столбец на отдельное независимое окно"
L.cd2width = "Ширина строки"
L.cd2graytooltip = "Иконки недоступных кд стают серыми"
L.cd2noraid = "Показывать вне рейда"
L.cd2Spells = "Заклинания"
L.cd2Appearance = "Внешний вид"
L.cd2PriorityTooltip = "Чем меньше значение, тем выше приоритет кулдауна. \nС одинаковыми значениями выше приоритет у кулдауна с меньшим spell id"
L.cd2ColNum = "Номер колонки"
L.cd2Priority = "Приоритет"
L.cd2SpellID = "Spell ID"
L.cd2EditBoxCDTooltip = "CD, сек."
L.cd2EditBoxDurationTooltip = "Длительность, сек."
L.cd2Class = "Класс"
L.cd2Spec = "Спек"
L.cd2RemoveButton = "Удалить"
L.cd2AddSpell = "Добавить заклинание"
L.cd2AddSpellFromList = "Добавить заклинание из списка"
L.cd2AddSpellFrameName = "Список заклинаний"
L.cd2AddSpellFrameCDText = "кд"
L.cd2AddSpellFrameDurationText = "длительность"
L.cd2AddSpellFrameColumnText = "Колонка"
L.cd2AddSpellFrameTalent = "Талант"
L.cd2AddSpellFrameDuration = "Время действия меняется с помощью"
L.cd2AddSpellFrameCDChange = "Время восстановления меняется с помощью"
L.cd2AddSpellFrameCharge = "Имеет заряды"
L.cd2AddSpellFrameChargeChange = "Получает заряды с помощью"
L.cd2AddSpellFrameCast = "Отображается время чтения"
L.cd2AddSpellFrameDurationLost = "Время действия отменяется при спадении ауры"
L.cd2AddSpellFrameSharing = "Дополнительно запускает время восстановления"
L.cd2AddSpellFrameDispel = "Заклинание рассеивания"
L.cd2AddSpellFrameReplace = "Стает недоступным при использовании таланта"
L.cd2AddSpellFrameRadiness = "Готовность"
L.cd2ButtonModify = "Настроить >>"
L.cd2TextSpell = "Заклинание"
L.cd2TextAdd = "Добавить"
L.cd2ColSet = "Настройка колонки"
L.cd2ColSetBotToTop = "Рост полос в колонке снизу вверх"
L.cd2ColSetGeneral = "Использовать общие настройки"
L.cd2ColSetResetPos = "Сбросить расположение"
L.cd2ColSetTextRight = "Текст справа"
L.cd2ColSetTextCenter = "Текст по центру"
L.cd2ColSetTextLeft = "Текст слева"
L.cd2ColSetTextReset = "Все очень сложно, я запутался. Вернуть стандартное"
L.cd2ColSetTextTooltip = "Используйте эти шаблны в текстовых полях выше:|n|cff00ff00%name%|r - имя игрока|n|cff00ff00%time%|r - время восстановления|n|cff00ff00%name_time%|r - имя игрока. Если на кд, то время|n|cff00ff00%spell%|r - имя заклинания|n|cff00ff00%stime%|r - \"кототкое время\". Без нулей у минутных таймеров|n|cff00ff00%name_stime%|r - имя игрока. Если на кд, то \"кототкое время\"|n|cff00ff00%status%|r - состояние кд, если игрок мертв/оффлайн"
L.cd2ColSetMethodCooldown = "Анимация восстановления заклинания для иконки"
L.cd2ColSetTextIconName = "Имя игрока на иконке"
L.cd2ColSetColsInCol = "Количество кд в ряд"
L.cd2GeneralSet = "Общие настройки"
L.cd2GeneralSetTestMode = "Тестовый режим"
L.cd2OtherSet = "Другие настройки"
L.cd2OtherSetTexture = "Текстура"
L.cd2OtherSetColor = "Настроить цвета"
L.cd2OtherSetColorFrameText = "Цвет доступного кд"
L.cd2OtherSetColorFrameActive = "Цвет активного кд"
L.cd2OtherSetColorFrameCooldown = "Цвет недоступного кд"
L.cd2OtherSetColorFrameCast = "Цвет каста"
L.cd2OtherSetColorFrameAlpha = "Прозрачность фона"
L.cd2OtherSetColorFrameAlphaCD = "Прозрачность полосы времени"
L.cd2OtherSetColorFrameAlphaCooldown = "Общая прозрачность полосы, если на кд"
L.cd2OtherSetColorFrameReset = "Вернуть стандартные"
L.cd2OtherSetColorFrameSoften = "Смягчить цвета"
L.cd2OtherSetColorFrameClass = "Использовать цвет класса"
L.cd2OtherSetColorFrameTopText = "Текст"
L.cd2OtherSetColorFrameTopBack = "Фон"
L.cd2OtherSetColorFrameTopTimeLine = "Полоса"
L.cd2OtherSetIconSize = "Размер иконки"
L.cd2OtherSetFontSize = "Размер шрифта"
L.cd2OtherSetFont = "Шрифт"
L.cd2OtherSetOutline = "Обводка шрифта"
L.cd2OtherSetFontShadow = "Тень шрифта"
L.cd2OtherSetAnimation = "Анимация кулдауна"
L.cd2OtherSetReset = "По умолчанию"
L.cd2OtherSetOnlyOnCD = "Показывать, только если на кд"
L.cd2OtherSetIconPosition = "Расположение иконки"
L.cd2OtherSetIconPositionLeft = "Иконка слева"
L.cd2OtherSetIconPositionRight = "Иконка справа"
L.cd2OtherSetIconPositionNo = "Не показывать иконку"
L.cd2OtherSetStyleAnimation = "Стиль анимации кулдауна"
L.cd2OtherSetStyleAnimation1 = "Стартовать заполненым"
L.cd2OtherSetStyleAnimation2 = "Стартовать пустым"
L.cd2OtherSetTimeLineAnimation = "Анимация доступного кд"
L.cd2OtherSetTimeLineAnimation1 = "Не заполнять полосой времени"
L.cd2OtherSetTimeLineAnimation2 = "Заполнять полосой времени"
L.cd2OtherSetTabNameGeneral = "Общие настройки"
L.cd2OtherSetTabNameIcons = "Иконки"
L.cd2OtherSetTabNameColors = "Текстуры и Цвета"
L.cd2OtherSetTabNameFont = "Шрифт"
L.cd2OtherSetTabNameText = "Имя и время"
L.cd2OtherSetTabNameOther = "Другие настройки"
L.cd2OtherSetTabNameTemplate = "Шаблоны"
L.cd2OtherSetTemplateRestore = "Что же я наделал :( Вернуть всё как было"
L.cd2fastSetupTitle = "Быстрая настройка"
L.cd2fastSetupTooltip = "Список заклинаний"
L.cd2fastSetupTitle1 = "Рейд сейвы"
L.cd2fastSetupTitle2 = "Директ сейвы"
L.cd2fastSetupTitle3 = "Баттлресы"
L.cd2fastSetupTitle4 = "Прерывания"
L.cd2fastSetupTitle5 = "Провокации"
L.cd2fastSetupTitle6 = "Рассеивания"
L.cd2History = "История применений"
L.cd2HistoryClear = "Очистить"
L.cd2HelpFastSetup = "Сразу в бой! Включите модуль, переместите фрейм с кулдаунами в желаемое место и не забудьте зафиксировать его. Используйте кнопки \"Быстрой настройки\" для комплексного включения заклинаний в настройках."
L.cd2HelpOnOff = "Проставьте галочки около интересующих вас заклинаний для включения слежения за ними"
L.cd2HelpCol = "Выберите класс владельца заклинания"
L.cd2HelpPriority = "Выбор приоритета заклинаний. Заклинание с меньшим числом приоритета будет показано выше остальных в пределах своей колонки"
L.cd2HelpTime = "В появившемся окне настройте время восстановления, время длительности и колонку заклинаний. (* В предустановленых заклинаниях невозможно изменить время восстановления и время действия). Настройка каждого отдельного спека преобладает над настройкой для всех специализаций."
L.cd2HelpColSetup = "Персональные настройки каждой колонки. Не забудьте их \"включить\" для отображения. Можете разделить все колонки на отдельные фреймы с помощью галочки \"".. L.cd2split .. "\". При включении кнопки \""..L.cd2ColSetGeneral.."\" для каждой отдельной группы настроек выбранная в текущий момент колонка наследует параметры общих настроек, независимо от индивидуальных."
L.cd2HelpTestButton = "Посмотреть как выглядит в рейде и для более удобной настройки воспользуйтесь кнопкой \"".. L.cd2GeneralSetTestMode .."\""
L.cd2HelpButtonDefault = "Сбросить все настройки выбранной в текущий момент колонки на стандартные"
L.cd2HelpAddButton = "Добавьте интересующие заклинания вручную. Пролистайте список вниз и нажмите \"".. L.cd2AddSpell .."\". В первое текстовое поле введите ID заклинания, выберете класс, нажмите кнопку \"".. L.cd2ButtonModify .."\". В появившемся окне напротив нужной специализации нажмите кнопку \"".. L.cd2TextAdd .."\" и введите ID заклинания (может быть разным для разных специализаций, но чаще совпадает), время кулдауна и время действия (или 0 если мгновенное). Настройка каждого отдельного спека преобладает над настройкой для всех специализаций. Для удаления настройки для специализации воспользуйтесь кнопкой \"Удалить\" справа. Для удаления заклинания воспользуйтесь кнопкой \"Удалить\" в главном окне справа."
L.cd2HelpHistory = "История применения всех выбранных заклинаний будет отображаться в этом окне. *В фигурных скобках указано время с начала боя с боссом."
L.cd2ColSetFontOtherAvailable = "Настройки для каждого расположения отдельно"
L.cd2ColSetFontPosGeneral = "Общие"
L.cd2ColSetFontPosLeft = "Слева"
L.cd2ColSetFontPosRight = "Справа"
L.cd2ColSetFontPosCenter = "По центру"
L.cd2ColSetFontPosIcon = "На иконке"
L.cd2ColSetBetweenLines = "Отступы между полосами"
L.cd2BlackBack = "Прозрачность фона колонки"
L.cd2StatusOffline = "(оффлайн)"
L.cd2StatusDead = "(мертв)"
L.cd2InspectHaste = "%+(%d+) к скорости"
L.cd2InspectHasteGem = "%+(%d+) к показателю скорости"
L.cd2InspectMastery = "%+(%d+) к искусности"
L.cd2InspectMasteryGem = "%+(%d+) к показателю искусности"
L.cd2InspectCrit = "%+(%d+) к критическому удару"
L.cd2InspectCritGem = "%+(%d+) к показателю критического удара"
L.cd2InspectCritGemLegendary = "%+%]%](%d+) к показателю критического удара"
L.cd2InspectSpirit = "%+(%d+) к духу"
L.cd2InspectInt = "%+(%d+) к интеллекту"
L.cd2InspectIntGem = "%+(%d+) к интелл%.," -- Legendary
L.cd2InspectStr = "%+(%d+) к силе$"
L.cd2InspectStrGem = "%+(%d+) к силе и"
L.cd2InspectAgi = "%+(%d+) к ловкости"
L.cd2InspectSpd = "%+(%d+) к силе заклинаний"
L.cd2InspectAll = "%+(%d+) ко всем характеристикам"
L.cd2OtherSetBorder = "Обводка"
L.cd2OtherSetIconToolip = "Подсказка заклинания при наведении на иконку"
L.cd2OtherSetLineClick = "Отправлять сообщение в чат при нажатии на полосу с кд"

L.sallspellsEggClear = "Очистить"
L.sallspellsEgg = "Лог заклинаний"
L.sallspellsEggPlayers = "Записывать игроков тоже"
L.sallspellsEggAutoLoad = "Автозагрузка"

L.sooitemssooboss1 = "Глубиний"
L.sooitemssooboss2 = "Павшие защитники"
L.sooitemssooboss3 = "Норусхен"
L.sooitemssooboss4 = "Ша Гордыни"
L.sooitemssooboss5 = "Галакрас"
L.sooitemssooboss6 = "Железный исполин"
L.sooitemssooboss7 = "Кор'кронские шаманы"
L.sooitemssooboss8 = "Генерал Назгрим"
L.sooitemssooboss9 = "Малкорок"
L.sooitemssooboss10 = "Пандарийские трофеи"
L.sooitemssooboss11 = "Ток Кровожадный"
L.sooitemssooboss12 = "Черноплавс"
L.sooitemssooboss13 = "Идеалы клакси"
L.sooitemssooboss14 = "Гаррош Адский Крик"
L.sooitemstotboss1 = "Джин'рок Разрушитель"
L.sooitemstotboss2 = "Хорридон"
L.sooitemstotboss3 = "Совет старейшин"
L.sooitemstotboss4 = "Тортос"
L.sooitemstotboss5 = "Мегера"
L.sooitemstotboss6 = "Цзи-Кунь"
L.sooitemstotboss7 = "Дуруму Позабытый"
L.sooitemstotboss8 = "Изначалий"
L.sooitemstotboss9 = "Темный Анимус"
L.sooitemstotboss10 = "Кон Железный"
L.sooitemstotboss11 = "Наложницы-близнецы"
L.sooitemstotboss12 = "Лэй Шэнь"
L.sooitemstotboss13 = "Ра-ден"
L.sooitemstrash = "Треш"
L.sooitemssets = "Сеты"
L.sooitemst15 = "Престол Гроз"
L.sooitemst16 = "Осада Оргриммара"

L.sencounterUnknown = "unknown"
L.sencounter5ppl = "5ппл подземелье"
L.sencounter5pplHC = "5ппл героическое подземелье"
L.sencounter10ppl = "10ппл рейд"
L.sencounter25ppl = "25ппл рейд"
L.sencounter10pplHC = "10ппл героический рейд"
L.sencounter25pplHC = "25ппл героический рейд"
L.sencounterLfr = "Сложность поиск рейда"
L.sencounterChall = "Режим испытаний"
L.sencounter40ppl = "40ппл рейд"
L.sencounter3pplHC = "Героический сценарий"
L.sencounter3ppl = "Сценарий"
L.sencounterFlex = "Гибкий рейд"
L.sencounterMystic = "mythic *"
L.sencounterWODNormal = "Обычная сложность"
L.sencounterWODHeroic = "Героическая сложность"
L.sencounterWODMythic = "Эпохальная сложность"
L.sencounterBossName = "Имя босса"
L.sencounterFirstKill = "ФК"
L.sencounterWipes = "Пуллов"
L.sencounterKills = "Килов"
L.sencounterFirstBlood = "First Blood"
L.sencounterWipeTime = "Время вайпа"
L.sencounterKillTime = "Время кила"
L.sencounterOnlyThisChar = "Только этого персонажа"
L.EncounterClear = "Очистить все данные"
L.EncounterClearPopUp = "Все данные будут безвозвратно удалены. Вы уверены?"

L.BossWatcherFilterTaunts = "Провокации"
L.BossWatcherFilterOnlyBuffs = "Только баффы"
L.BossWatcherFilterOnlyDebuffs = "Только дебаффы"
L.BossWatcherFilterBySpellID = "Spell ID:"
L.BossWatcherFilterLagFix = "Lag Fix"
L.BossWatcherFilterTooltip = "Список заклинаний"
L.BossWatcherFilterStun = "Оглушения"
L.BossWatcherFilterPersonal = "Защитные"
L.BossWatcherChkShowGUIDs = "Показывать уникальный ID"
L.BossWatcherTabMobs = "Урон"
L.BossWatcherTabInterruptAndDispel = "Прерывания, рассеивания"
L.BossWatcherTabBuffsAndDebuffs = "Ауры"
L.BossWatcherTabBuffsAndDebuffsTooltip = "Баффы и дебаффы"
L.BossWatcherReportTotal = "Всего"
L.BossWatcherReportCast = "Заклинанием"
L.BossWatcherReportSwitch = "Целью"
L.BossWatcherDamageSwitchTabDamage = "Урон"
L.BossWatcherDamageSwitchTabSwitch = "Время переключения"
L.BossWatcherDamageSwitchTabInfo = "Информация"
L.BossWatcherDamageSwitchTabInfoNoInfo = "Нет информации"
L.BossWatcherDamageSwitchTabInfoRIP = "R.I.P."
L.BossWatcherInterrupts = "Прерывания"
L.BossWatcherDispels = "Рассеивания"
L.BossWatcherBuffsAndDebuffsTextOn = "на"
L.BossWatcherBuffsAndDebuffsTooltipTitle = "События"
L.BossWatcherBuffsAndDebuffsFilterSource = "Источник"
L.BossWatcherBuffsAndDebuffsFilterTarget = "Цель"
L.BossWatcherBuffsAndDebuffsFilterAll = "всё"
L.BossWatcherBuffsAndDebuffsFilterFriendly = "дружественные"
L.BossWatcherBuffsAndDebuffsFilterHostile = "враждебные"
L.BossWatcherBuffsAndDebuffsFilterSpecial = "Особые"
L.BossWatcherBuffsAndDebuffsFilterClear = "Очистить фильтр"
L.BossWatcherBuffsAndDebuffsFilterNone = "Нет"
L.BossWatcherBuffsAndDebuffsFilterFilter = "Фильтр"
L.BossWatcherBuffsAndDebuffsTooltipCountText = "Количество"
L.BossWatcherBuffsAndDebuffsTooltipUptimeText = "Общее время действия"
L.BossWatcherUnknown = "Неизвестно"
L.BossWatcherLastFight = "Последний бой"
L.BossWatcherTimeLineTooltipTitle = "События"
L.BossWatcherTimeLineCast = "применяет"
L.BossWatcherTimeLineCastStart = "начинает чтение"
L.BossWatcherTimeLineDies = "погибает"
L.BossWatcherTimeLineOnText = "на"
L.BossWatcherInterruptText = "прерывает"
L.BossWatcherByText = "с помощью"
L.BossWatcherDispelText = "рассеивает"
L.BossWatcherToChat = "Отправить в чат"
L.BossWatcherClear = "Очистить"
L.BossWatcherSegments = "Сегменты"
L.BossWatcherSegmentsTooltip = "Для начала записи нового сегмента во время боя наберите в чате команду \"/rt seg\".\nДля просмотра журнала боя выберите требуемые сегменты, отметив их галочками в списке слева.\n\nМожно настроить автоматический старт новых сегментов при выполнении условий, заданых в настройках ниже."
L.BossWatcherSegmentEventsUSS = "Успешное применение заклинания"
L.BossWatcherSegmentEventsSAR = "Спадение баффа/дебаффа"
L.BossWatcherSegmentEventsSAA = "Наложение баффа/дебаффа"
L.BossWatcherSegmentEventsUD = "Смерть NPC"
L.BossWatcherSegmentEventsCMRBE = "Сообщение в чате о способности босса"
L.BossWatcherSegmentNamesUSS = "Заклинание"
L.BossWatcherSegmentNamesSAA = "+ аура"
L.BossWatcherSegmentNamesSAR = "- аура"
L.BossWatcherSegmentNamesUD = "Смерть"
L.BossWatcherSegmentNamesES = "Начало боя"
L.BossWatcherSegmentNamesSC = "Комманда в чате"
L.BossWatcherSegmentNamesCMRBE = "Сообщение чате"
L.BossWatcherSegmentsSpellTooltip = "Spell ID или NPC ID"
L.BossWatcherSegmentSelectAll = "Выбрать все"
L.BossWatcherSegmentSelectNothing = "Выбрать ничего"
L.BossWatcherFilterBySpellName = "Spell Name:"
L.BossWatcherSendToChat = "Отправить в чат"
L.BossWatcherOverkills = "Смертельный урон"
L.BossWatcherOverkillText = "убивает"
L.BossWatcherOverkillWithText = "с помощью"
L.BossWatcherOverkillOnText = "на"
L.BossWatcherPetOwner = "Питомец %s"
L.BossWatcherDoNotReset = "Не очищать"
L.BossWatcherDoNotResetTooltip = "Не сбрасывать данные в начале каждого боя, а дописывать их к предыдущему. (Удобно при использовании в режимах испытаний. Не рекомендуется использовать в рейдах)|n*Как альтернативу можно использовать комманды чата \"/rt bw start\" и \"/rt bw end\" для записи абсолютно всех событй между их вводами (во время опции \"Не очищать\" события записываются только в то время, когда игрок находится в бою (вне рейдовых подзмемлий) или рейд находится в бою с боссом (для рейдовых подземелий))"
L.BossWatcherPetText = "Питомец"
L.BossWatcherMarkOnDeath = "Метка при смерти"
L.BossWatcherSegmentClear = "Очистить"
L.BossWatcherSegmentPreSet = "Готовые решения"
L.BossWatcherOptions = "Другие настройки"
L.BossWatcherOptionsFightsSave = "Сохранять количество боев:"
L.BossWatcherOptionsFightsWarning = "* Большее число сохраняемых боев требует больше ресурсов"
L.BossWatcherSelectFight = "Выбрать бой"
L.BossWatcherSelectFightClose = "Закрыть"
L.BossWatcherChatSpellMsg = "Сообщение в чате о способности"
L.BossWatcherFilterPotions = "Поты"
L.BossWatcherFilterRaidSaves = "Рейд-сейвы"
L.BossWatcherFilterPandaria = "Пандария: легенда"
L.BossWatcherFilterTier16 = "Осада Оргриммара"
L.BossWatcherOptionSpellID = "Показывать ID заклинаний на полосе вреиени"
L.BossWatcherTabPlayersSpells = "Заклинания"
L.BossWatcherTabPlayersSpellsTooltip = "Лог успешно произнесенных заклинаний игроков"
L.BossWatcherDamageBoxPlayerTooltip = "Нажать для информации по заклинаниям"
L.BossWatcherSegmentNowTooltip = "Заклинание в текущий момент:"
L.BossWatcherTabHeal = "Исцеление"
L.BossWatcherTabInterruptAndDispelShort = "Прерыв.,рассеив."
L.BossWatcherHealBySource = "По источникам"
L.BossWatcherHealByTarget = "По целям"
L.BossWatcherHealAllSourceText = "Все источники"
L.BossWatcherHealAllTargetText = "Все цели"
L.BossWatcherErrorInCombat = "Невозможно обновить данные, в связи с ограничениями Blizzard. Выйдите из режима боя и повторите попытку."
L.BossWatcherTabEnergy = "Ресурсы"
L.BossWatcherEnergyOnce1 = "раз"
L.BossWatcherEnergyOnce2 = "раза"
L.BossWatcherEnergyType0 = "Мана"
L.BossWatcherEnergyType1 = "Ярость"
L.BossWatcherEnergyType2 = "Фокус"
L.BossWatcherEnergyType3 = "Энергия"
L.BossWatcherEnergyType5 = "Руны"
L.BossWatcherEnergyType6 = "Руническая сила"
L.BossWatcherEnergyType7 = "Осколки душ"
L.BossWatcherEnergyType8 = "Затмение"
L.BossWatcherEnergyType9 = "Энергия света"
L.BossWatcherEnergyType10 = "Альтернативный ресурс"
L.BossWatcherEnergyType12 = "Чи"
L.BossWatcherEnergyType13 = "Темные сферы"
L.BossWatcherEnergyType14 = "Раскаленные угли"
L.BossWatcherEnergyType15 = "Демоническая ярость"
L.BossWatcherEnergyTypeUnknown = "ID ресурса: "

L.InspectViewerTalents = "Таланты и символы"
L.InspectViewerInfo = "Другая информация"
L.InspectViewerItems = "Экипировка"
L.InspectViewerNoData = "Нет данных"
L.InspectViewerEnabledTooltip = "Невозможно отключить при работающем модуле \""..L.cd2.."\""
L.InspectViewerRadiness = "Готовность"
L.InspectViewerRaidIlvl = "Средний уровень предметов рейда"
L.InspectViewerRaidIlvlData = "данные %d игроков"
L.InspectViewerHaste = "Скорость"
L.InspectViewerMastery = "Искусность"
L.InspectViewerCrit = "Крит."
L.InspectViewerSpirit = "Дух"
L.InspectViewerInt = "Интеллект"
L.InspectViewerStr = "Сила"
L.InspectViewerAgi = "Ловкость"
L.InspectViewerSpd = "Сила закл."

L.CoinsSpoilsOfPandariaWinTrigger = "Система перезагружается. Не выключать питание, иначе возможен взрыв."
L.CoinsEmpty = "Здесь пока пусто"
L.CoinsHelp = "История бросков монет дополнительной добычи участниками рейда и полученных ими бонусных предметов"
L.CoinsClear = "Очистить все данные"
L.CoinsClearPopUp = "Все данные будут безвозвратно удалены. Вы уверены?"

L.senable = "Включить"

L.minimaptooltiplmp = "ЛКМ - Перемещение"
L.minimaptooltiprmp = "ПКМ - Открыть меню"
L.minimaptooltipfree = "Shift+Alt+ЛКМ - Свободное перемещение"
L.minimapmenu = "Меню ExRT"
L.minimapmenuset = "Настройки"
L.minimapmenuclose = "Закрыть"

L.classLocalizate = {
	["WARRIOR"] = "Воин",
	["PALADIN"] = "Паладин",
	["HUNTER"] = "Охотник",
	["ROGUE"] = "Разбойник",
	["PRIEST"] = "Жрец",
	["DEATHKNIGHT"] = "Рыцарь смерти",
	["SHAMAN"] = "Шаман",
	["MAGE"] = "Маг",
	["WARLOCK"] = "Чернокнижник",
	["MONK"] = "Монах",
	["DRUID"] = "Друид",
	["PET"] = "Питомцы",
}

L.specLocalizate = {
	["MAGEDPS1"] = "Тайная магия",
	["MAGEDPS2"] = "Огонь",
	["MAGEDPS3"] = "Лед",
	["PALADINHEAL"] = "Свет",
	["PALADINTANK"] = "Защита",
	["PALADINDPS"] = "Воздаяние",
	["WARRIORDPS1"] = "Оружие",
	["WARRIORDPS2"] = "Неистовство",
	["WARRIORTANK"] = "Защита",
	["DRUIDDPS1"] = "Баланс",
	["DRUIDDPS2"] = "Сила зверя",
	["DRUIDTANK"] = "Страж",
	["DRUIDHEAL"] = "Исцеление",
	["DEATHKNIGHTTANK"] = "Кровь",
	["DEATHKNIGHTDPS1"] = "Лед",
	["DEATHKNIGHTDPS2"] = "Нечестивость",
	["HUNTERDPS1"] = "Повелитель зверей",
	["HUNTERDPS2"] = "Стрельба",
	["HUNTERDPS3"] = "Выживание",
	["PRIESTHEAL1"] = "Послушание",
	["PRIESTHEAL2"] = "Свет",
	["PRIESTDPS"] = "Тьма",
	["ROGUEDPS1"] = "Ликвидация",
	["ROGUEDPS2"] = "Бой",
	["ROGUEDPS3"] = "Скрытность",
	["SHAMANDPS1"] = "Стихии",
	["SHAMANDPS2"] = "Совершенствование",
	["SHAMANHEAL"] = "Исцеление",
	["WARLOCKDPS1"] = "Колдовство",
	["WARLOCKDPS2"] = "Демонология",
	["WARLOCKDPS3"] = "Разрушение",
	["MONKTANK"] = "Хмелевар",
	["MONKDPS"] = "Танцующий с ветром",
	["MONKHEAL"] = "Ткач туманов",
	["NO"] = "Все специализации",
}

L.creatureNames = {	--> Used LibBabble-CreatureType and WowHead
	Abyssal = "Абиссал",
	Basilisk = "Василиск",
	Bat = "Летучая мышь",
	Bear = "Медведь",
	Beast = "Животное",
	Beetle = "Жук",
	["Bird of Prey"] = "Сова",
	Boar = "Вепрь",
	["Carrion Bird"] = "Падальщик",
	Cat = "Кошка",
	Chimaera = "Химера",
	["Core Hound"] = "Гончая Недр",
	Crab = "Краб",
	Crane = "Журавль",
	Critter = "Существо",
	Crocolisk = "Кроколиск",
	Demon = "Демон",
	Devilsaur = "Дьявозавр",
	Direhorn = "Дикорог",
	Dog = "Собака",
	Doomguard = "Стражник ужаса",
	Dragonhawk = "Дракондор",
	Dragonkin = "Дракон",
	Elemental = "Элементаль",
	Felguard = "Страж Скверны",
	Felhunter = "Охотник Скверны",
	["Fel Imp"] = "Бес Скверны",
	Fox = "Лиса",
	["Gas Cloud"] = "Газовое облако",
	Ghoul = "Вурдалак",
	Giant = "Великан",
	Goat = "Козел",
	Gorilla = "Горилла",
	Humanoid = "Гуманоид",
	Hyena = "Гиена",
	Imp = "Бес",
	Mechanical = "Механизм",
	Monkey = "Обезьяна",
	Moth = "Мотылек",
	["Nether Ray"] = "Скат Пустоты",
	["Non-combat Pet"] = "Спутник",
	["Not specified"] = "Не указано",
	Observer = "Наблюдатель",
	Porcupine = "Дикобраз",
	Quilen = "Цийлинь",
	Raptor = "Ящер",
	Ravager = "Опустошитель",
	["Remote Control"] = "Управление",
	Rhino = "Люторог",
	Scorpid = "Скорпид",
	Serpent = "Змей",
	["Shale Spider"] = "Сланцевый паук",
	Shivarra = "Шиварра",
	Silithid = "Силитид",
	Spider = "Паук",
	["Spirit Beast"] = "Дух зверя",
	Sporebat = "Спороскат",
	Succubus = "Суккуб",
	Tallstrider = "Долгоног",
	Terrorguard = "Стражник жути",
	Totem = "Тотем",
	Turtle = "Черепаха",
	Undead = "Нежить",
	Voidlord = "Повелитель Бездны",
	Voidwalker = "Демон Бездны",
	["Warp Stalker"] = "Прыгуана",
	Wasp = "Оса",
	["Water Elemental"] = "Элементаль воды",
	["Water Strider"] = "Водный Долгоног",
	["Wind Serpent"] = "Крылатый змей",
	Wolf = "Волк",
	Worm = "Червь",
	Wrathguard = "Страж гнева",
	[1] = "Упорство",
	[2] = "Хитрость",
	[3] = "Свирепость",
}