local addonName, addon = ...
local L = addon.L

addon.defaults = {
    char = {},
    profile = {
        positions = {},

		sources = {
			corpse = true,
			questobj = true,
			archaeodig = true,
		},

        showMapIconsZone = false,
        showMapIconsContinent = false,

        corpseArrow = true,

		forceUpdateThrottle = 2.0,

        goodcolor = {0, 1, 0},
        badcolor = {1, 0, 0},
        middlecolor = {1, 1, 0},
    },
}
