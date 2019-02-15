local M, F, L, D = unpack(stAddonManager) --Import: Modules, Functions/Utilities, Locales, Data
local AM = stAddonManager
local LSM = LibStub('LibSharedMedia-3.0')

----------------------
-- DEFAULTS ----------
----------------------

D.DefaultConfig = {
	Font = { LSM:Fetch('font', 'Agency FB'), 12, '' },
	Colors = {
		backdrop = { .07, .07, .07 },
		border = { .2, .2, .2 },
		hover = { 0/255, 170/255, 255/255 },
	},
	AddonsPerPage = 20,
	CheckButtonHeight = 10, --Used for checkboxes
	CheckButtonWidth = 10,
}