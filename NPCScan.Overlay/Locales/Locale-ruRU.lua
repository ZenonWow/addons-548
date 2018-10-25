--[[****************************************************************************
  * _NPCScan.Overlay by Saiket                                                 *
  * Locales/Locale-ruRU.lua - Localized string constants (ru-RU).              *
  ****************************************************************************]]


if ( GetLocale() ~= "ruRU" ) then
	return;
end


-- See http://wow.curseforge.com/addons/npcscan-overlay/localization/ruRU/
local private = select( 2, ... );
private.L = setmetatable( {
	NPCs = setmetatable( {
	}, { __index = private.L.NPCs; } );
}, { __index = private.L; } );

private.L.NPCs["100"] = "Графф Быстрохват"
private.L.NPCs["10077"] = "Гиблопасть"
private.L.NPCs["10078"] = "Искра Ужаса"
private.L.NPCs["10080"] = "Сандарр Разоритель Барханов"
private.L.NPCs["10081"] = "Пыльный призрак"
private.L.NPCs["10082"] = "Зериллис"
private.L.NPCs["10119"] = "Волкан"
private.L.NPCs["10196"] = "Генерал Колбатанн"
private.L.NPCs["10197"] = "Меззир Ревун"
private.L.NPCs["10198"] = "Кашох Разоритель"
private.L.NPCs["10199"] = "Гриззл Снежная Лапа"
private.L.NPCs["10200"] = "Рак'шири"
private.L.NPCs["10202"] = "Лазурис"
private.L.NPCs["10263"] = "Пылающий страж Скверны"
private.L.NPCs["10356"] = "Зверр"
private.L.NPCs["10357"] = "Куссан Жалящий"
private.L.NPCs["10358"] = "Тень Феллисенты"
private.L.NPCs["10359"] = "Шри'скалк"
private.L.NPCs["10376"] = "Хрустальный Клык"
private.L.NPCs["10393"] = "Череп"
private.L.NPCs["10509"] = "Джед Руновед"
private.L.NPCs["10558"] = "Певчий Форрестен"
private.L.NPCs["10559"] = "Леди Веспия"
private.L.NPCs["1063"] = "Нефрит"
private.L.NPCs["10639"] = "Роргиш Мощная Челюсть"
private.L.NPCs["10640"] = "Дуболап"
private.L.NPCs["10641"] = "Веткохват"
private.L.NPCs["10642"] = "Эк'алом"
private.L.NPCs["10644"] = "Ревун из тумана"
private.L.NPCs["10647"] = "Принц Рейз"
private.L.NPCs["10741"] = "Сиан-Ротам"
private.L.NPCs["10809"] = "Каменный Гребень"
private.L.NPCs["10817"] = "Дугган Громовой Молот"
private.L.NPCs["10818"] = "Рыцарь Смерти Терзатель Душ"
private.L.NPCs["10819"] = "Барон Кровопорч"
private.L.NPCs["10820"] = "Герцог Беспощадный"
private.L.NPCs["10821"] = "Хед'маш Гниющий"
private.L.NPCs["10823"] = "Зул'Брин Криводрев"
private.L.NPCs["10824"] = "Смертолов Ястребиное Копье"
private.L.NPCs["10825"] = "Гиш Недвижимый"
private.L.NPCs["10826"] = "Лорд Темнокос"
private.L.NPCs["10827"] = "Вестница смерти Селендра"
private.L.NPCs["10828"] = "Линния Аббендис"
private.L.NPCs["1106"] = "Повар из племени Заблудших"
private.L.NPCs["1112"] = "Кровавая Вдова"
private.L.NPCs["1119"] = "Твердоспин"
private.L.NPCs["1130"] = "Бьярн"
private.L.NPCs["1132"] = "Серый"
private.L.NPCs["1137"] = "Идан Ревун"
private.L.NPCs["11383"] = "Верховная жрица Хай'ватна"
private.L.NPCs["1140"] = "Острозуб-матриарх"
private.L.NPCs["11447"] = "Мушгог"
private.L.NPCs["11467"] = "Цу'зи"
private.L.NPCs["11497"] = "Разза"
private.L.NPCs["11498"] = "Скарр Сломленный"
private.L.NPCs["11688"] = "Проклятый кентавр"
private.L.NPCs["12037"] = "Урсол'лок"
private.L.NPCs["12237"] = "Мешлок Жнец"
private.L.NPCs["12431"] = "Жуткоклык"
private.L.NPCs["12433"] = "Кретис Тенеткач"
private.L.NPCs["1260"] = "Великий Отец Арктикус"
private.L.NPCs["12902"] = "Лоргус Джетт"
private.L.NPCs["13896"] = "Чешуебород"
private.L.NPCs["1398"] = "Главарь Галгош"
private.L.NPCs["1399"] = "Магош"
private.L.NPCs["14221"] = "Гравис Слипнот"
private.L.NPCs["14222"] = "Арага"
private.L.NPCs["14223"] = "Злобный Бенджи"
private.L.NPCs["14224"] = "7:XT"
private.L.NPCs["14225"] = "Принц Келлен"
private.L.NPCs["14226"] = "Каскк"
private.L.NPCs["14227"] = "Шшшперак"
private.L.NPCs["14228"] = "Хохотунья"
private.L.NPCs["14229"] = "Проклятый Скользящий Плавник"
private.L.NPCs["14230"] = "Воровской Глаз"
private.L.NPCs["14231"] = "Дрогот Бродяга"
private.L.NPCs["14232"] = "Дарт"
private.L.NPCs["14233"] = "Чешуекус"
private.L.NPCs["14234"] = "Хайок"
private.L.NPCs["14235"] = "Гниль"
private.L.NPCs["14236"] = "Морской черт"
private.L.NPCs["14237"] = "Слизнечерв"
private.L.NPCs["1424"] = "Старший землекоп"
private.L.NPCs["1425"] = "Кубб"
private.L.NPCs["14266"] = "Шанда Прядильщица"
private.L.NPCs["14267"] = "Амогг Сокрушитель"
private.L.NPCs["14268"] = "Лорд Кондар"
private.L.NPCs["14269"] = "Искатель Аквалон"
private.L.NPCs["14270"] = "Кальмарник"
private.L.NPCs["14271"] = "Костелом"
private.L.NPCs["14272"] = "Огнемордик"
private.L.NPCs["14273"] = "Камнесерд"
private.L.NPCs["14275"] = "Тамран Грозовая Вершина"
private.L.NPCs["14276"] = "Шрамник"
private.L.NPCs["14277"] = "Леди Зефрис"
private.L.NPCs["14278"] = "Ро'Барк"
private.L.NPCs["14279"] = "Ползух"
private.L.NPCs["14280"] = "Большой Самрас"
private.L.NPCs["14281"] = "Джимми Вымогатель"
private.L.NPCs["14339"] = "Смертный вой"
private.L.NPCs["14340"] = "Алшир Гиблодых"
private.L.NPCs["14342"] = "Яролап"
private.L.NPCs["14343"] = "Олм Мудрый"
private.L.NPCs["14344"] = "Полукров"
private.L.NPCs["14345"] = "Онгар"
private.L.NPCs["14424"] = "Подболотник"
private.L.NPCs["14425"] = "Костоглод"
private.L.NPCs["14426"] = "Харб Поганая Гора"
private.L.NPCs["14427"] = "Глупошмыг"
private.L.NPCs["14428"] = "Урусон"
private.L.NPCs["14429"] = "Зловещая Утроба"
private.L.NPCs["14430"] = "Закатный ловец"
private.L.NPCs["14431"] = "Фурия Шельда"
private.L.NPCs["14432"] = "Треггил"
private.L.NPCs["14433"] = "Болотный слякоч"
private.L.NPCs["14445"] = "Капитан Змеюк"
private.L.NPCs["14446"] = "Узкий Плавник"
private.L.NPCs["14447"] = "Гилмориан"
private.L.NPCs["14448"] = "Облезлый Шип"
private.L.NPCs["14471"] = "Сетис"
private.L.NPCs["14472"] = "Гретир"
private.L.NPCs["14473"] = "Лапресс"
private.L.NPCs["14474"] = "Зора"
private.L.NPCs["14475"] = "Рекс Ашил"
private.L.NPCs["14476"] = "Креллак"
private.L.NPCs["14477"] = "Грубтор"
private.L.NPCs["14478"] = "Ураганий"
private.L.NPCs["14479"] = "Сумеречный владыка Эверан"
private.L.NPCs["14487"] = "Барабуль"
private.L.NPCs["14488"] = "Ролох"
private.L.NPCs["14490"] = "Потрошила"
private.L.NPCs["14491"] = "Курмокк"
private.L.NPCs["14492"] = "Мигафоникс"
private.L.NPCs["1531"] = "Заблудшая душа"
private.L.NPCs["1533"] = "Страдающая душа"
private.L.NPCs["1552"] = "Чешуйчатое брюхо"
private.L.NPCs["16179"] = "Хиакисс Скрытень"
private.L.NPCs["16180"] = "Шадикит Скользящий"
private.L.NPCs["16181"] = "Рокад Опустошитель"
private.L.NPCs["16184"] = "Нерубский надзиратель"
private.L.NPCs["16854"] = "Элдинаркус"
private.L.NPCs["16855"] = "Трегла"
private.L.NPCs["17144"] = "Жуткозуб"
private.L.NPCs["18241"] = "Цапчик"
private.L.NPCs["1837"] = "Судья из Алого ордена"
private.L.NPCs["1838"] = "Дознаватель из Алого ордена"
private.L.NPCs["1839"] = "Верховный священник Алого ордена"
private.L.NPCs["1841"] = "Палач из Алого ордена"
private.L.NPCs["1843"] = "Штейгер Джеррис"
private.L.NPCs["1844"] = "Штейгер Маркрид"
private.L.NPCs["1847"] = "Скверногрив"
private.L.NPCs["1848"] = "Лорд Малдаззар"
private.L.NPCs["1849"] = "Шепот Ужаса"
private.L.NPCs["1850"] = "Гнилиус"
private.L.NPCs["1851"] = "Кикиморд"
private.L.NPCs["18677"] = "Мекторг Дикий"
private.L.NPCs["18678"] = "Обжорень"
private.L.NPCs["18679"] = "Воракем Глашатай Судьбы"
private.L.NPCs["18680"] = "Мартикар"
private.L.NPCs["18681"] = "Эмиссар резервуара Кривого Клыка"
private.L.NPCs["18682"] = "Трясинный скрытень"
private.L.NPCs["18683"] = "Охотник Бездны Яр"
private.L.NPCs["18684"] = "Бро'Газ Без Клана"
private.L.NPCs["18685"] = "Окрек"
private.L.NPCs["18686"] = "Вестник рока Джурим"
private.L.NPCs["18689"] = "Расчленитель"
private.L.NPCs["18690"] = "Моркруш"
private.L.NPCs["18692"] = "Гематион"
private.L.NPCs["18693"] = "Проповедник Маргром"
private.L.NPCs["18694"] = "Страж портала Коллидус"
private.L.NPCs["18695"] = "Посол Жеррикар"
private.L.NPCs["18696"] = "Краатор"
private.L.NPCs["18697"] = "Главный инженер Лортандер"
private.L.NPCs["18698"] = "Недремлющий Каратель"
private.L.NPCs["1885"] = "Кузнец Алого ордена"
private.L.NPCs["1910"] = "Муад"
private.L.NPCs["1911"] = "Диб"
private.L.NPCs["1936"] = "Фермер Соллиден"
private.L.NPCs["2090"] = "Ма'рук Змеиная Чешуя"
private.L.NPCs["20932"] = "Нурамок"
private.L.NPCs["2108"] = "Гарнег Обугленный Череп"
private.L.NPCs["2162"] = "Агал"
private.L.NPCs["2172"] = "Долгоног-несушка"
private.L.NPCs["21724"] = "Ловец ястребов"
private.L.NPCs["2175"] = "Тенекоготь"
private.L.NPCs["2184"] = "Леди Луноокая"
private.L.NPCs["2186"] = "Карнивус Разрушитель"
private.L.NPCs["2191"] = "Лисиллин"
private.L.NPCs["2192"] = "Радисон Призыватель Огня"
private.L.NPCs["22060"] = "Фенисса Убийца"
private.L.NPCs["22062"] = "Доктор Белоручка"
private.L.NPCs["2258"] = "Маггаррак"
private.L.NPCs["2452"] = "Сквой"
private.L.NPCs["2453"] = "Ло'Грош"
private.L.NPCs["2476"] = "Гош-Халдир"
private.L.NPCs["2541"] = "Лорд Сакрасис"
private.L.NPCs["2598"] = "Дарбелла Монтроуз"
private.L.NPCs["2600"] = "Певица"
private.L.NPCs["2601"] = "Гнилобрюх"
private.L.NPCs["2602"] = "Руул Одинокий Камень"
private.L.NPCs["2603"] = "Коворк"
private.L.NPCs["2604"] = "Молок Сокрушитель"
private.L.NPCs["2605"] = "Залас Сухокожий"
private.L.NPCs["2606"] = "Нимар Душегуб"
private.L.NPCs["2609"] = "Геомант Кремненож"
private.L.NPCs["2744"] = "Тенегорнский командир"
private.L.NPCs["2749"] = "Баррикада"
private.L.NPCs["2751"] = "Боевой голем"
private.L.NPCs["2752"] = "Грохотун"
private.L.NPCs["2753"] = "Барнабус"
private.L.NPCs["2754"] = "Анатемус"
private.L.NPCs["2779"] = "Принц Назжак"
private.L.NPCs["2850"] = "Сломанный зуб"
private.L.NPCs["2931"] = "Зарикотль"
private.L.NPCs["3058"] = "Арра'чея"
private.L.NPCs["3068"] = "Маззранач"
private.L.NPCs["32357"] = "Старый кристальный древень"
private.L.NPCs["32358"] = "Фумблуб Ветрозуб"
private.L.NPCs["32361"] = "Ледорог"
private.L.NPCs["32377"] = "Перобас Кровожадный"
private.L.NPCs["32386"] = "Вигдис Воительница"
private.L.NPCs["32398"] = "Король Пинг"
private.L.NPCs["32400"] = "Тюкмут"
private.L.NPCs["32409"] = "Обезумевший беглец из деревни Инду'ле"
private.L.NPCs["32417"] = "Верховный лорд Алого Натиска Дайон"
private.L.NPCs["32422"] = "Гроклар"
private.L.NPCs["32429"] = "Пылающая ненависть"
private.L.NPCs["32435"] = "Верн"
private.L.NPCs["32438"] = "Сирейна Костерез"
private.L.NPCs["32447"] = "Часовой Зул'драка"
private.L.NPCs["32471"] = "Григен"
private.L.NPCs["32475"] = "Ткач ужаса"
private.L.NPCs["32481"] = "Аотона"
private.L.NPCs["32485"] = "Король Круш"
private.L.NPCs["32487"] = "Гниллий Древний"
private.L.NPCs["32491"] = "Затерянный во времени протодракон"
private.L.NPCs["32495"] = "Хильдана Похитительница Смерти"
private.L.NPCs["32500"] = "Дирки"
private.L.NPCs["32501"] = "Верховный тан Йорфус"
private.L.NPCs["32517"] = "Локе'нахак"
private.L.NPCs["3253"] = "Силитид-жнец"
private.L.NPCs["32630"] = "Вирагоса"
private.L.NPCs["3270"] = "Старый мистик Остроморд"
private.L.NPCs["3295"] = "Слякохлюп"
private.L.NPCs["33776"] = "Гондрия"
private.L.NPCs["3398"] = "Гешарахан"
private.L.NPCs["3470"] = "Раториан"
private.L.NPCs["35189"] = "Сколл"
private.L.NPCs["3535"] = "Черномшец злосмрадный"
private.L.NPCs["3581"] = "Тварь из Стоков"
private.L.NPCs["3652"] = "Тригор Хлестун"
private.L.NPCs["3672"] = "Боан"
private.L.NPCs["3735"] = "Аптекарь Фалтис"
private.L.NPCs["3736"] = "Темный душегуб Мортентал"
private.L.NPCs["3773"] = "Аккрилус"
private.L.NPCs["3792"] = "Вожак терроволков"
private.L.NPCs["38453"] = "Арктур"
private.L.NPCs["3872"] = "Капитан служителей Смерти"
private.L.NPCs["39183"] = "Скорпитар"
private.L.NPCs["39185"] = "Слюнявая пасть"
private.L.NPCs["39186"] = "Сглазень"
private.L.NPCs["4066"] = "Нал'тазар"
private.L.NPCs["4132"] = "Кркк'кс"
private.L.NPCs["4339"] = "Краегор"
private.L.NPCs["43488"] = "Мордей Земледробитель"
private.L.NPCs["43613"] = "Вестник рока Мудрый Гонец"
private.L.NPCs["43720"] = "\"Малыш\" Терновая Мантия"
private.L.NPCs["4380"] = "Черная вдова Мглистой пещеры"
private.L.NPCs["44224"] = "Двупалыш"
private.L.NPCs["44225"] = "Руфий Темный Выстрел"
private.L.NPCs["44226"] = "Зарлозуб"
private.L.NPCs["44227"] = "Газз Озерный Охотник"
private.L.NPCs["4425"] = "Слепой охотник"
private.L.NPCs["44714"] = "Фронкл Потревоженный"
private.L.NPCs["44722"] = "Странное отражение Нарайна"
private.L.NPCs["44750"] = "Калиф Жало Скорпида"
private.L.NPCs["44759"] = "Андре Огнебородый"
private.L.NPCs["44761"] = "Акваментий Неудержимый"
private.L.NPCs["44767"] = "Оккулус Порочный"
private.L.NPCs["45257"] = "Мордак Явление Ночи"
private.L.NPCs["45258"] = "Кассия Королева Скользящих"
private.L.NPCs["45260"] = "Чернолист"
private.L.NPCs["45262"] = "Нарикс Вестник Рока"
private.L.NPCs["45369"] = "Морик Темновар"
private.L.NPCs["45380"] = "Чернобурка"
private.L.NPCs["45384"] = "Мудрий"
private.L.NPCs["45398"] = "Гризлак"
private.L.NPCs["45399"] = "Оптимо"
private.L.NPCs["45401"] = "Беложабр"
private.L.NPCs["45402"] = "Никт"
private.L.NPCs["45404"] = "Землемучительница Марена"
private.L.NPCs["45739"] = "Неизвестный солдат"
private.L.NPCs["45740"] = "Дозорный Ив"
private.L.NPCs["45771"] = "Марус"
private.L.NPCs["45785"] = "Опустошенный"
private.L.NPCs["45801"] = "Элиза"
private.L.NPCs["45811"] = "Марина Десиррус"
private.L.NPCs["462"] = "Сарыч"
private.L.NPCs["46981"] = "Плеть ночи"
private.L.NPCs["46992"] = "Берард Лунатик"
private.L.NPCs["47003"] = "Болгафф"
private.L.NPCs["47008"] = "Фенвик Татрос"
private.L.NPCs["47009"] = "Акварий Освобожденный"
private.L.NPCs["47010"] = "Индигос"
private.L.NPCs["47012"] = "Эфрит"
private.L.NPCs["47015"] = "Потерянный сын Аругала"
private.L.NPCs["47023"] = "Тул Коготь Ворона"
private.L.NPCs["471"] = "Мать Клык"
private.L.NPCs["472"] = "Федфенхель"
private.L.NPCs["47386"] = "Айнамисс Королева Улья"
private.L.NPCs["47387"] = "Харакисс Заразитель"
private.L.NPCs["4842"] = "Заклинательница земли Халмгар"
private.L.NPCs["49822"] = "Нефритовый Клык"
private.L.NPCs["49913"] = "Леди Ла-Ла"
private.L.NPCs["50005"] = "Посейдус"
private.L.NPCs["50009"] = "Мобус"
private.L.NPCs["50050"] = "Шок'шарак"
private.L.NPCs["50051"] = "Призрачный Краб"
private.L.NPCs["50052"] = "Углик Черносерд"
private.L.NPCs["50053"] = "Тартук Изгой"
private.L.NPCs["50056"] = "Гарр"
private.L.NPCs["50057"] = "Жарокрыл"
private.L.NPCs["50058"] = "Калентий"
private.L.NPCs["50059"] = "Голгарок"
private.L.NPCs["50060"] = "Тербурий"
private.L.NPCs["50061"] = "Зариона"
private.L.NPCs["50062"] = "Эонакс"
private.L.NPCs["50063"] = "Акма'хат"
private.L.NPCs["50064"] = "Сирус Блек"
private.L.NPCs["50065"] = "Армагедилло"
private.L.NPCs["50085"] = "Властитель Губительная Ярость"
private.L.NPCs["50086"] = "Тарвий Злобный"
private.L.NPCs["50089"] = "Джулак-Рок"
private.L.NPCs["50138"] = "Карома"
private.L.NPCs["50154"] = "Мадекс"
private.L.NPCs["50159"] = "Самбас"
private.L.NPCs["50328"] = "Фангор"
private.L.NPCs["50329"] = "Рракк"
private.L.NPCs["50330"] = "Кри"
private.L.NPCs["50331"] = "Го-Кан"
private.L.NPCs["50332"] = "Корда Торрос"
private.L.NPCs["50333"] = "Лонь Бык"
private.L.NPCs["50334"] = "Дак Крушитель"
private.L.NPCs["50335"] = "Алитий"
private.L.NPCs["50336"] = "Йорик Острый Глаз"
private.L.NPCs["50337"] = "Клекан"
private.L.NPCs["50338"] = "Кор'нас Ночной Изверг"
private.L.NPCs["50339"] = "Сулик'шор"
private.L.NPCs["50340"] = "Гаарн Ядовитый"
private.L.NPCs["50341"] = "Борджинн Кулак Тьмы"
private.L.NPCs["50342"] = "Геронис"
private.L.NPCs["50343"] = "Пейрак"
private.L.NPCs["50344"] = "Норлакс"
private.L.NPCs["50345"] = "Алит"
private.L.NPCs["50346"] = "Ронак"
private.L.NPCs["50347"] = "Карр Несущий Тьму"
private.L.NPCs["50348"] = "Нориссис"
private.L.NPCs["50349"] = "Кан Похититель Душ"
private.L.NPCs["50350"] = "Моргринн Треснувший Клык"
private.L.NPCs["50351"] = "Джон-Дар"
private.L.NPCs["50352"] = "Ку'нас"
private.L.NPCs["50353"] = "Манас"
private.L.NPCs["50354"] = "Хавак"
private.L.NPCs["50355"] = "Ках'тир"
private.L.NPCs["50356"] = "Крол Клинок"
private.L.NPCs["50357"] = "Солнечное Крыло"
private.L.NPCs["50358"] = "Взбешенный голем Похитителей Солнца"
private.L.NPCs["50359"] = "Урголакс"
private.L.NPCs["50361"] = "Орнат"
private.L.NPCs["50362"] = "Торфоног Клыкастый"
private.L.NPCs["50363"] = "Кракс'ик"
private.L.NPCs["50364"] = "Нал'лак Раздиратель"
private.L.NPCs["50370"] = "Карапакс"
private.L.NPCs["50388"] = "Торик-Этис"
private.L.NPCs["50409"] = "Странная фигурка верблюда"
private.L.NPCs["506"] = "Сержант Острый Коготь"
private.L.NPCs["507"] = "Фенрос"
private.L.NPCs["50724"] = "Хребтоход"
private.L.NPCs["50725"] = "Азелиск"
private.L.NPCs["50726"] = "Каликс"
private.L.NPCs["50727"] = "Штрикс Шершавый"
private.L.NPCs["50728"] = "Кромсак"
private.L.NPCs["50730"] = "Ядоспин"
private.L.NPCs["50731"] = "Иглозуб"
private.L.NPCs["50733"] = "Ски'тик"
private.L.NPCs["50734"] = "Лит'ик Охотник"
private.L.NPCs["50735"] = "Гремучий немигай"
private.L.NPCs["50737"] = "Акронисс"
private.L.NPCs["50738"] = "Блестошкур"
private.L.NPCs["50739"] = "Гар'лок"
private.L.NPCs["50741"] = "Какс"
private.L.NPCs["50742"] = "Квем"
private.L.NPCs["50743"] = "Манакс"
private.L.NPCs["50744"] = "Кву'рик"
private.L.NPCs["50745"] = "Лозаж"
private.L.NPCs["50746"] = "Борникс Могильщик"
private.L.NPCs["50747"] = "Тикс"
private.L.NPCs["50748"] = "Ньяж"
private.L.NPCs["50749"] = "Кал'тик Болезнетворный"
private.L.NPCs["50750"] = "Этис"
private.L.NPCs["50752"] = "Тарантис"
private.L.NPCs["50759"] = "Вдова Ирисс"
private.L.NPCs["50763"] = "Тенелов"
private.L.NPCs["50764"] = "Паралисс"
private.L.NPCs["50765"] = "Миасмисс"
private.L.NPCs["50766"] = "Селе'на"
private.L.NPCs["50768"] = "Курниф Долгоног"
private.L.NPCs["50769"] = "Зей Изгой"
private.L.NPCs["50770"] = "Зорн"
private.L.NPCs["50772"] = "Ишилон"
private.L.NPCs["50775"] = "Ликк Ловец"
private.L.NPCs["50776"] = "Налаш Зеленый"
private.L.NPCs["50777"] = "Ткач"
private.L.NPCs["50778"] = "Железный Ткач"
private.L.NPCs["50779"] = "Спореггон"
private.L.NPCs["50780"] = "Сан Охотник Прилива"
private.L.NPCs["50782"] = "Сарнак"
private.L.NPCs["50783"] = "Сальинь-разведчик"
private.L.NPCs["50784"] = "Анит"
private.L.NPCs["50785"] = "Полнеб"
private.L.NPCs["50786"] = "Блестокрыл"
private.L.NPCs["50787"] = "Арнесс Чешуйчатый"
private.L.NPCs["50788"] = "Кетцаль"
private.L.NPCs["50789"] = "Нессос Прозорливый"
private.L.NPCs["50790"] = "Ионис"
private.L.NPCs["50791"] = "Силстрисс Точильщик"
private.L.NPCs["50792"] = "Чиа"
private.L.NPCs["50797"] = "Юкико"
private.L.NPCs["50803"] = "Костеглод"
private.L.NPCs["50804"] = "Рвущее Крыло"
private.L.NPCs["50805"] = "Омнис Гринлок"
private.L.NPCs["50806"] = "Молдо Одноглазый"
private.L.NPCs["50807"] = "Катал"
private.L.NPCs["50808"] = "Странствующий Уроби"
private.L.NPCs["50809"] = "Хересс"
private.L.NPCs["50810"] = "Любимец Изисет"
private.L.NPCs["50811"] = "Нашра Пятнистая Шкура"
private.L.NPCs["50812"] = "Арае"
private.L.NPCs["50813"] = "Фене-мал"
private.L.NPCs["50814"] = "Мертвоед"
private.L.NPCs["50815"] = "Скарр"
private.L.NPCs["50816"] = "Жуунь Призрачная Лапа"
private.L.NPCs["50817"] = "Ахон Странствующая"
private.L.NPCs["50818"] = "Крадущийся-во-Тьме"
private.L.NPCs["50819"] = "Ледяной Коготь"
private.L.NPCs["50820"] = "Юл Дикая Лапа"
private.L.NPCs["50821"] = "Ай-Ли Небесное Зеркало"
private.L.NPCs["50822"] = "Ай-Жань Летящее Облако"
private.L.NPCs["50823"] = "Мистер Лютый"
private.L.NPCs["50825"] = "Ферас"
private.L.NPCs["50828"] = "Бонобос"
private.L.NPCs["50830"] = "Хмызень"
private.L.NPCs["50831"] = "Шкряб"
private.L.NPCs["50832"] = "Изувой"
private.L.NPCs["50833"] = "Темныш"
private.L.NPCs["50836"] = "Ик-Ик Проворный"
private.L.NPCs["50837"] = "Кэш"
private.L.NPCs["50838"] = "Муарш"
private.L.NPCs["50839"] = "Хромус"
private.L.NPCs["50840"] = "Майор Наннерс"
private.L.NPCs["50842"] = "Магмаган"
private.L.NPCs["50846"] = "Рабоглот"
private.L.NPCs["50855"] = "Джакс Бешеный"
private.L.NPCs["50856"] = "Снарк"
private.L.NPCs["50858"] = "Пылекрыл"
private.L.NPCs["50864"] = "Чащмень"
private.L.NPCs["50865"] = "Саурикс"
private.L.NPCs["50874"] = "Тенок"
private.L.NPCs["50875"] = "Найхус"
private.L.NPCs["50876"] = "Авиз"
private.L.NPCs["50882"] = "Чупакаброс"
private.L.NPCs["50884"] = "Пылекрыл Трусливый"
private.L.NPCs["50886"] = "Морское Крыло"
private.L.NPCs["50891"] = "Борос"
private.L.NPCs["50892"] = "Цинь"
private.L.NPCs["50895"] = "Волюкс"
private.L.NPCs["50897"] = "Ффекс Ловчий Дюн"
private.L.NPCs["50901"] = "Теромак"
private.L.NPCs["50903"] = "Орликс Владыка Болот"
private.L.NPCs["50905"] = "Цида"
private.L.NPCs["50906"] = "Мутилакс"
private.L.NPCs["50908"] = "Ночной Вой"
private.L.NPCs["50915"] = "Фырч"
private.L.NPCs["50916"] = "Хромолап Плаксивый"
private.L.NPCs["50922"] = "Ворог"
private.L.NPCs["50925"] = "Хозяин Рощи"
private.L.NPCs["50926"] = "Седой Бен"
private.L.NPCs["50929"] = "Бьорник"
private.L.NPCs["50930"] = "Гибеорн Спящий"
private.L.NPCs["50931"] = "Чесун"
private.L.NPCs["50937"] = "Ветчиног"
private.L.NPCs["50940"] = "Сви"
private.L.NPCs["50942"] = "Корней Рылеев"
private.L.NPCs["50945"] = "Окорошкур"
private.L.NPCs["50946"] = "Свизилла"
private.L.NPCs["50947"] = "Вар"
private.L.NPCs["50948"] = "Кристаспин"
private.L.NPCs["50949"] = "Гамбит Финна"
private.L.NPCs["50952"] = "Краб Джим"
private.L.NPCs["50955"] = "Карчинак"
private.L.NPCs["50957"] = "Клещер"
private.L.NPCs["50959"] = "Каркин"
private.L.NPCs["50964"] = "Грызжем"
private.L.NPCs["50967"] = "Кро Опустошитель"
private.L.NPCs["50986"] = "Золотистый Бок"
private.L.NPCs["50993"] = "Гал'дорак"
private.L.NPCs["50995"] = "Забияка"
private.L.NPCs["50997"] = "Борнак Поддевающий"
private.L.NPCs["51000"] = "Черноспин Неприступный"
private.L.NPCs["51001"] = "Ядоклац"
private.L.NPCs["51002"] = "Скорпокс"
private.L.NPCs["51004"] = "Токс"
private.L.NPCs["51007"] = "Серкетт"
private.L.NPCs["51008"] = "Колючий Ужас"
private.L.NPCs["51010"] = "Секач"
private.L.NPCs["51014"] = "Террапис"
private.L.NPCs["51017"] = "Гезан"
private.L.NPCs["51018"] = "Зормус"
private.L.NPCs["51021"] = "Вихрай"
private.L.NPCs["51022"] = "Хордикс"
private.L.NPCs["51025"] = "Диленна"
private.L.NPCs["51026"] = "Гнус"
private.L.NPCs["51027"] = "Спирокула"
private.L.NPCs["51028"] = "Глубинный Копатель"
private.L.NPCs["51029"] = "Парасий"
private.L.NPCs["51031"] = "Следопыт"
private.L.NPCs["51037"] = "Потерявшийся гилнеасский бойцовый пес"
private.L.NPCs["51040"] = "Нюхрс"
private.L.NPCs["51042"] = "Темносерд"
private.L.NPCs["51044"] = "Чумаз"
private.L.NPCs["51045"] = "Аркан"
private.L.NPCs["51046"] = "Фидонис"
private.L.NPCs["51048"] = "Рексус"
private.L.NPCs["51052"] = "Гиб Ценитель Бананов"
private.L.NPCs["51053"] = "Квирикс"
private.L.NPCs["51057"] = "Долгоносик"
private.L.NPCs["51058"] = "Афис"
private.L.NPCs["51059"] = "Черное Копыто"
private.L.NPCs["51061"] = "Рот-Салам"
private.L.NPCs["51062"] = "Хеп-Ра"
private.L.NPCs["51063"] = "Фаланг"
private.L.NPCs["51066"] = "Клыстарь"
private.L.NPCs["51067"] = "Блестер"
private.L.NPCs["51069"] = "Синтилекс"
private.L.NPCs["51071"] = "Капитан Флоренс"
private.L.NPCs["51076"] = "Лопекс"
private.L.NPCs["51077"] = "Огнехвост"
private.L.NPCs["51078"] = "Фердинанд"
private.L.NPCs["51079"] = "Капитан Злозюйд"
private.L.NPCs["51401"] = "Мадекс"
private.L.NPCs["51402"] = "Мадекс"
private.L.NPCs["51403"] = "Мадекс"
private.L.NPCs["51404"] = "Мадекс"
private.L.NPCs["51658"] = "Мог Мертвец"
private.L.NPCs["51661"] = "Тсул'Калу"
private.L.NPCs["51662"] = "Махамба"
private.L.NPCs["51663"] = "Погеан"
private.L.NPCs["519"] = "Сларк"
private.L.NPCs["520"] = "Бракк"
private.L.NPCs["521"] = "Волкус"
private.L.NPCs["52146"] = "Трещун"
private.L.NPCs["534"] = "Нефару"
private.L.NPCs["5343"] = "Леди Сзалла"
private.L.NPCs["5345"] = "Ромбоголов"
private.L.NPCs["5346"] = "Рокотун Ловец"
private.L.NPCs["5347"] = "Антилус Парящий"
private.L.NPCs["5348"] = "Двуязыкий Сновидец"
private.L.NPCs["5349"] = "Араш-етис"
private.L.NPCs["5350"] = "Квирот"
private.L.NPCs["5352"] = "Старый Серобрюх"
private.L.NPCs["5354"] = "Брат листвы"
private.L.NPCs["5356"] = "Рыкун"
private.L.NPCs["54318"] = "Анха"
private.L.NPCs["54319"] = "Магрия"
private.L.NPCs["54320"] = "Бан'талос"
private.L.NPCs["54321"] = "Соликс"
private.L.NPCs["54322"] = "Мер'тилак"
private.L.NPCs["54323"] = "Кирикс"
private.L.NPCs["54324"] = "Жарисс"
private.L.NPCs["54338"] = "Антрисс"
private.L.NPCs["54533"] = "Принц Лакма"
private.L.NPCs["56081"] = "Оптимист Бенж"
private.L.NPCs["572"] = "Лепритус"
private.L.NPCs["573"] = "Врагорез-4000"
private.L.NPCs["574"] = "Нараксис"
private.L.NPCs["5785"] = "Сестра Плеть Ненависти"
private.L.NPCs["5786"] = "Кривое Копье"
private.L.NPCs["5787"] = "Головорез Эмильгунд"
private.L.NPCs["5807"] = "Цап-царап"
private.L.NPCs["5809"] = "Сержант Кертис"
private.L.NPCs["5822"] = "Скорнн Ткач Скверны"
private.L.NPCs["5823"] = "Смертоносный живодер"
private.L.NPCs["5824"] = "Капитан Тупой Клык"
private.L.NPCs["5826"] = "Владычица земель Рябка"
private.L.NPCs["5828"] = "Вожак стаи Хумар"
private.L.NPCs["5829"] = "Фырк Дразнила"
private.L.NPCs["5830"] = "Сестра Коготь Кургана"
private.L.NPCs["5831"] = "Быстрогрив"
private.L.NPCs["5832"] = "Громоступ"
private.L.NPCs["58336"] = "Кролик ярмарки Новолуния"
private.L.NPCs["5834"] = "Аззира Клинок Небес"
private.L.NPCs["5835"] = "Штейгер Грилз"
private.L.NPCs["5836"] = "Инженер Безобразец"
private.L.NPCs["5837"] = "Каменная рука"
private.L.NPCs["5838"] = "Копьелом"
private.L.NPCs["584"] = "Казон"
private.L.NPCs["5841"] = "Каменное Копье"
private.L.NPCs["5842"] = "Такк Прыгун"
private.L.NPCs["5847"] = "Хеггин Камнеус"
private.L.NPCs["58474"] = "Кроволапка"
private.L.NPCs["5848"] = "Малгин Ячменовар"
private.L.NPCs["5849"] = "Землекоп Огнеплав"
private.L.NPCs["5851"] = "Капитан Герогг Тяжелоступ"
private.L.NPCs["5859"] = "Хагг Тауребой"
private.L.NPCs["5863"] = "Жрица Земли Гукк'рок"
private.L.NPCs["5864"] = "Свинеар Копьешкур"
private.L.NPCs["5865"] = "Дишу"
private.L.NPCs["58768"] = "Хрустозуб"
private.L.NPCs["58769"] = "Злобнохап"
private.L.NPCs["58771"] = "Склизень"
private.L.NPCs["58778"] = "Айта"
private.L.NPCs["58817"] = "Дух Лао-Фэ"
private.L.NPCs["58949"] = "Бай-Цзинь Мясник"
private.L.NPCs["5912"] = "Загадочный чудесный дракончик"
private.L.NPCs["5915"] = "Брат Вороний Дуб"
private.L.NPCs["5928"] = "Крыло скорби"
private.L.NPCs["5930"] = "Сестра Терзающая"
private.L.NPCs["5932"] = "Надсмотрщик Хлестоклык"
private.L.NPCs["5933"] = "Акеллиос Изгнанник"
private.L.NPCs["5935"] = "Железноглаз Неуязвимый"
private.L.NPCs["59369"] = "Доктор Теолен Крастинов"
private.L.NPCs["5937"] = "Коварное Жало"
private.L.NPCs["596"] = "Зомбированный дворянин"
private.L.NPCs["599"] = "Мариса дю Пэж"
private.L.NPCs["60491"] = "Ша Злости"
private.L.NPCs["61"] = "Турос Ловкорук"
private.L.NPCs["6118"] = "Привидение Варо'тена"
private.L.NPCs["616"] = "Трещунья"
private.L.NPCs["62"] = "Гуг Толстая Свеча"
private.L.NPCs["6228"] = "Посол из клана Черного Железа"
private.L.NPCs["62346"] = "Галеон"
private.L.NPCs["62880"] = "Гочао Железный Кулак"
private.L.NPCs["62881"] = "Гаохунь Ловец Душ"
private.L.NPCs["63101"] = "Генерал Темуджа"
private.L.NPCs["63240"] = "Повелитель теней Сайдоу"
private.L.NPCs["63510"] = "Улунь"
private.L.NPCs["63691"] = "Хо-Шуан"
private.L.NPCs["63695"] = "Баолай Воспламенитель"
private.L.NPCs["63977"] = "Вираксис"
private.L.NPCs["63978"] = "Кри'чон"
private.L.NPCs["64403"] = "Алани"
private.L.NPCs["6581"] = "Равазавр-матриарх"
private.L.NPCs["6582"] = "Матка Завас"
private.L.NPCs["6583"] = "Графф"
private.L.NPCs["6584"] = "Король Мош"
private.L.NPCs["6585"] = "Ак'лок"
private.L.NPCs["6648"] = "Антилос"
private.L.NPCs["6649"] = "Леди Сесспира"
private.L.NPCs["6650"] = "Генерал Фангферрор"
private.L.NPCs["6651"] = "Привратник Грознорев"
private.L.NPCs["68317"] = "Мавис Хармс"
private.L.NPCs["68318"] = "Далан Разрушитель Ночи"
private.L.NPCs["68319"] = "Диша Защищающая от Страха"
private.L.NPCs["68320"] = "Убунти Тень"
private.L.NPCs["68321"] = "Кар Развязывающий Войну"
private.L.NPCs["68322"] = "Муэрта"
private.L.NPCs["69099"] = "Налак"
private.L.NPCs["69664"] = "Мумта"
private.L.NPCs["69768"] = "Зандаларский военный разведчик"
private.L.NPCs["69769"] = "Зандаларский завоеватель"
private.L.NPCs["69841"] = "Зандаларский завоеватель"
private.L.NPCs["69842"] = "Зандаларский завоеватель"
private.L.NPCs["69843"] = "Зао'чо"
private.L.NPCs["69996"] = "Ку'лаи Коготь Небес"
private.L.NPCs["69997"] = "Породитель"
private.L.NPCs["69998"] = "Года"
private.L.NPCs["69999"] = "Бог-исполин Рамук"
private.L.NPCs["70000"] = "Ал'табим Всевидящий"
private.L.NPCs["70001"] = "Ломатель хребтов Уру"
private.L.NPCs["70002"] = "Лю-Бань"
private.L.NPCs["70003"] = "Молтор"
private.L.NPCs["70096"] = "Бог войны Дока"
private.L.NPCs["70126"] = "Уилли Уайлдер"
private.L.NPCs["7015"] = "Грязнюк Жестокий"
private.L.NPCs["7016"] = "Леди Веспира"
private.L.NPCs["7017"] = "Лорд Нечестивец"
private.L.NPCs["70238"] = "Немигающий глаз"
private.L.NPCs["70243"] = "Предводитель ритуалистов Келад"
private.L.NPCs["70249"] = "Сосредоточенный глаз"
private.L.NPCs["70276"] = "Но'ку Буревестник"
private.L.NPCs["70323"] = "Кракканон"
private.L.NPCs["70430"] = "Скальный ужас"
private.L.NPCs["70440"] = "Монара"
private.L.NPCs["70530"] = "Ра'ша"
private.L.NPCs["7104"] = "Дессекус"
private.L.NPCs["7137"] = "Испепелитель"
private.L.NPCs["71864"] = "Чароброд"
private.L.NPCs["71919"] = "Чжу-Гонь Прокисший"
private.L.NPCs["71992"] = "Лунная волчица"
private.L.NPCs["72045"] = "Шелон"
private.L.NPCs["72048"] = "Косохрип"
private.L.NPCs["72049"] = "Журавлецап"
private.L.NPCs["72193"] = "Карканос"
private.L.NPCs["72245"] = "Зесква"
private.L.NPCs["72769"] = "Дух Нефритового Пламени"
private.L.NPCs["72775"] = "Буфо"
private.L.NPCs["72808"] = "Тсаво'ка"
private.L.NPCs["72909"] = "Гу'чи Зовущий Рой"
private.L.NPCs["72970"] = "Голганарр"
private.L.NPCs["73157"] = "Пещерный Мох"
private.L.NPCs["73158"] = "Изумрудный гусак"
private.L.NPCs["73160"] = "Твердорогий сталемех"
private.L.NPCs["73161"] = "Большая черепаха Гневный Панцирь"
private.L.NPCs["73163"] = "Императорский питон"
private.L.NPCs["73166"] = "Огромный хребтохват"
private.L.NPCs["73167"] = "Холон"
private.L.NPCs["73169"] = "Якур Ордосский"
private.L.NPCs["73170"] = "Смотритель Осу"
private.L.NPCs["73171"] = "Защитник Черного Пламени"
private.L.NPCs["73172"] = "Повелитель кремня Гайран"
private.L.NPCs["73173"] = "Урдур Прижигатель"
private.L.NPCs["73174"] = "Архиерей пламени"
private.L.NPCs["73175"] = "Пеплопад"
private.L.NPCs["73277"] = "Целитель листвы"
private.L.NPCs["73279"] = "Вечножор"
private.L.NPCs["73281"] = "Проклятый корабль \"Вазувий\""
private.L.NPCs["73282"] = "Гарния"
private.L.NPCs["73293"] = "Виззиг"
private.L.NPCs["73666"] = "Архиерей пламени"
private.L.NPCs["73704"] = "Вонекос"
private.L.NPCs["763"] = "Вождь из племени Заблудших"
private.L.NPCs["7846"] = "Теремус Пожиратель"
private.L.NPCs["79"] = "Нарг Надсмотрщик"
private.L.NPCs["8199"] = "Военный вождь Краззилак"
private.L.NPCs["8200"] = "Джин'Заллах Хозяин Барханов"
private.L.NPCs["8201"] = "Омгорн Заблудший"
private.L.NPCs["8203"] = "Крегг Кильватель"
private.L.NPCs["8204"] = "Сориид Пожиратель"
private.L.NPCs["8205"] = "Хаарка Ненасытный"
private.L.NPCs["8207"] = "Углекрыл"
private.L.NPCs["8210"] = "Бритвокоготь"
private.L.NPCs["8211"] = "Старый утесный прыгун"
private.L.NPCs["8212"] = "Рик"
private.L.NPCs["8213"] = "Сталеспин"
private.L.NPCs["8214"] = "Джалинда Дракон Лета"
private.L.NPCs["8215"] = "Мрачноус"
private.L.NPCs["8216"] = "Ретерокк Берсерк"
private.L.NPCs["8217"] = "Мит'ретис Чаротворец"
private.L.NPCs["8218"] = "Сухосерд Ловчий"
private.L.NPCs["8219"] = "Зул'арек Злобный Охотник"
private.L.NPCs["8277"] = "Рекк'тилак"
private.L.NPCs["8278"] = "Смолдар"
private.L.NPCs["8279"] = "Неисправный боевой голем"
private.L.NPCs["8280"] = "Шлейпнарр"
private.L.NPCs["8281"] = "Жар"
private.L.NPCs["8282"] = "Верховный лорд Мастрогонд"
private.L.NPCs["8283"] = "Повелитель рабов Черносерд"
private.L.NPCs["8296"] = "Моджо Зловредный"
private.L.NPCs["8297"] = "Магронос Неуступчивый"
private.L.NPCs["8298"] = "Провидец Акубар"
private.L.NPCs["8299"] = "Злобоклюй"
private.L.NPCs["8300"] = "Разор"
private.L.NPCs["8301"] = "Щелкун Разоритель"
private.L.NPCs["8302"] = "Смертеглаз"
private.L.NPCs["8303"] = "Хрюггер"
private.L.NPCs["8304"] = "Бесстрашный"
private.L.NPCs["8503"] = "Гибломор"
private.L.NPCs["8660"] = "Эвалчарр"
private.L.NPCs["8923"] = "Панцер Непобедимый"
private.L.NPCs["8924"] = "Чудище"
private.L.NPCs["8976"] = "Гематос"
private.L.NPCs["8978"] = "Таурис Бальгарр"
private.L.NPCs["8979"] = "Груклаш"
private.L.NPCs["8981"] = "Сломанный разоритель"
private.L.NPCs["9217"] = "Лорд-волхв из клана Черной Вершины"
private.L.NPCs["9218"] = "Боевой предводитель клана Черной Вершины"
private.L.NPCs["9219"] = "Мясник из клана Черной Вершины"
private.L.NPCs["947"] = "Рохх Молчаливый"
private.L.NPCs["9596"] = "Баннок Люторез"
private.L.NPCs["9602"] = "Хак'Зор"
private.L.NPCs["9604"] = "Горгон'ох"
private.L.NPCs["9718"] = "Гок Крепкобив"
private.L.NPCs["9736"] = "Интендант Зигрис"
private.L.NPCs["99"] = "Моргана Лукавая"

private.L["BUTTON_TOOLTIP_LINE1"] = "|cffffee00 _NPCScan.Overlay|r"
private.L["BUTTON_TOOLTIP_LINE2"] = "|cffd6ff00 Щелчок: |r Переключить отображение маршрутов на карте мира" -- Needs review
private.L["BUTTON_TOOLTIP_LINE3"] = "|cffd6ff00 Shift+щелчок: |r Переключить отображение списка редких существ на карте мира" -- Needs review
private.L["BUTTON_TOOLTIP_LINE4"] = "|cffd6ff00 Щелчок правой кнопкой: |r Переключить отображение маршрутов на миникарте" -- Needs review
private.L["BUTTON_TOOLTIP_LINE5"] = "|cffaaf200 Щелчок средней кнопкой: |r Переключить отображение маршрутов на миникарте и карте мира" -- Needs review
private.L["BUTTON_TOOLTIP_LINE6"] = "|cff6cff00 Shift+щелчок средней кнопкой: |r Открыть меню настроек" -- Needs review
private.L["CONFIG_ALPHA"] = "Прозрачность"
private.L["CONFIG_COLORLIST_INST"] = "Нажмите на имя существа, чтобы выбрать его цвет."
private.L["CONFIG_COLORLIST_LABEL"] = "Таблица цветов маршрутов на карте"
private.L["CONFIG_COLORLIST_PLACEHOLDER"] = "Имя существа"
private.L["CONFIG_DESC"] = "Выбор карт, на которых будут показаны маршруты существ.  Большинство модификаций, изменяющих стандартную карту,   настраиваются с помощью раздела \"Основная карта мира\"."
private.L["CONFIG_LOCKSWAP"] = "Инвертировать управление списком"
private.L["CONFIG_LOCKSWAP_DESC"] = "Заставляет список существ перемещаться при наведении мыши, для игнорирования необходимо удерживать Shift."
private.L["CONFIG_SETCOLOR"] = "Настроить цвет маршрутов"
private.L["CONFIG_SETCOLOR_DESC"] = "Позволяет настроить цвет имен существ и цвет их маршрутов."
private.L["CONFIG_SHOWALL"] = "Всегда показывать все маршруты."
private.L["CONFIG_SHOWALL_DESC"] = "Обычно, когда существо не отслеживается, его маршрут не отображается на карте. Включите данную функцию, чтобы отображать все известные маршруты."
private.L["CONFIG_SHOWKEY"] = "Показать список существ на карте"
private.L["CONFIG_SHOWKEY_DESC"] = "Управляет отображением списка существ на карте мира."
private.L["CONFIG_TITLE"] = "Наложение"
private.L["CONFIG_TITLE_STANDALONE"] = "_|cffCCCC88NPCScan|r.Overlay"
private.L["MODULE_ALPHAMAP3"] = "Модификация AlphaMap3"
private.L["MODULE_BATTLEFIELDMINIMAP"] = "Карта боевой зоны"
private.L["MODULE_MINIMAP"] = "Миникарта"
private.L["MODULE_OMEGAMAP"] = "Модификация OmegaMap"
private.L["MODULE_RANGERING_DESC"] = "Примечание: Область слежения появляется только в зонах с отслеживаемыми существами."
private.L["MODULE_RANGERING_FORMAT"] = "Примерный радиус области слежения: %dyd"
private.L["MODULE_WORLDMAP"] = "Основная карта мира"
private.L["MODULE_WORLDMAP_KEY_FORMAT"] = "• %s"
private.L["MODULE_WORLDMAP_KEYTOGGLE"] = "Список"
private.L["MODULE_WORLDMAP_KEYTOGGLE_DESC"] = "Включить/выключить показ маршрутов"
private.L["MODULE_WORLDMAP_TOGGLE"] = "НИПы"
private.L["MODULE_WORLDMAP_TOGGLE_DESC"] = "Включить/выключить показ маршрутов _|cffCCCC88NPCScan|r.Overlay для отслеживаемых НИПов."
