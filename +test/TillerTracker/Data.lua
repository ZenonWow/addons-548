local ADDON_NAME, private = ...

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

private.QUESTS = {
	[30402] = { 
		NAME = L["A Dish for Chee Chee"], 		
		FOOD_ID = 74647, 
		LOCATION = { 34.4, 46.8 }, 
		MATS = { { COUNT = 1, ITEM_ID = 74864 }, { COUNT = 1, ITEM_ID = 74839 } },
		REP_ID = 1277,
		RECIPE_ID = 104302
	},	
	[30386] = { 
		NAME = L["A Dish for Ella"], 			
		FOOD_ID = 74651, 
		LOCATION = { 31.6, 58.0 }, 
		MATS = { { COUNT = 1, ITEM_ID = 74857 } },
		REP_ID = 1275,
		RECIPE_ID = 104307
	},
	[30421] = { 
		NAME = L["A Dish for Farmer Fung"], 	
		FOOD_ID = 74654, 
		LOCATION = { 48.2, 33.8 }, 
		MATS = { { COUNT = 1, ITEM_ID = 74839 } },
		REP_ID = 1283,
		RECIPE_ID = 104310
	},
	[30427] = { 
		NAME = L["A Dish for Fish"], 			
		FOOD_ID = 74655, 
		LOCATION = { 41.6, 30.0 }, 
		MATS = { { COUNT = 2, ITEM_ID = 74865 } },
		REP_ID = 1282,
		RECIPE_ID = 104311
	},
	[30390] = { 
		NAME = L["A Dish for Gina"], 			
		FOOD_ID = 74644, 
		LOCATION = { 53.2, 51.6 }, 
		MATS = { { COUNT = 1, ITEM_ID = 74856 } },
		REP_ID = 1281,
		RECIPE_ID = 104304
	},
	[30414] = { 
		NAME = L["A Dish for Haohan"], 			
		FOOD_ID = 74642, 
		LOCATION = { 44.6, 34.0 }, 
		MATS = { { COUNT = 1, ITEM_ID = 74833 } },
		REP_ID = 1279,
		RECIPE_ID = 104298
	},
	[30439] = { 
		NAME = L["A Dish for Jogu"], 			
		FOOD_ID = 74643, 
		LOCATION = { 53.6, 52.4 }, 
		MATS = { { COUNT = 2, ITEM_ID = 74841 } },
		REP_ID = 1273,
		RECIPE_ID = 104301
	},
	[30396] = { 
		NAME = L["A Dish for Old Hillpaw"], 	
		FOOD_ID = 74649, 
		LOCATION = { 31.0, 53.0 }, 
		MATS = { { COUNT = 1, ITEM_ID = 74837 }, { COUNT = 5, ITEM_ID = 74841 } },
		REP_ID = 1276,
		RECIPE_ID = 104305
	},
	[30408] = { 
		NAME = L["A Dish for Sho"], 			
		FOOD_ID = 74645, 
		LOCATION = { 29.6, 30.6 }, 
		MATS = { { COUNT = 1, ITEM_ID = 74856 }, { COUNT = 5, ITEM_ID = 74848 } },
		REP_ID = 1278,
		RECIPE_ID = 104299
	},
	[30433] = { 
		NAME = L["A Dish for Tina"], 			
		FOOD_ID = 74652, 
		LOCATION = { 45.0, 33.8 }, 
		MATS = { { COUNT = 1, ITEM_ID = 74859 }, { COUNT = 5, ITEM_ID = 74843 } },
		REP_ID = 1280,
		RECIPE_ID = 104308		
	}
}	