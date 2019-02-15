local LSM = LibStub('LibSharedMedia-3.0')

----------------------
-- ENGINE ------------
----------------------
local AM = CreateFrame('Frame', 'stAddonManager', UIParent)

AM[1] = {}; -- Modules
AM[2] = {}; -- Functions/Utilities
AM[3] = {}; -- Locales
AM[4] = {}; -- Data

local M, F, L, D = unpack(AM) --Import: Modules, Functions/Utilities, Locales, Data

----------------------
-- VARIABLES ---------
----------------------

D.name = AM:GetName()
D.scrollOffset = 0
D.FontStrings = {} --Store all strings in here

D.barTex = format('Interface\\AddOns\\%s\\media\\normTex.tga', ...)
D.blankTex = format('Interface\\AddOns\\%s\\media\\blankTex.tga', ...)
D.glowTex = format('Interface\\AddOns\\%s\\media\\glowTex.tga', ...)
D.ButtonHeight = 20 --Used for general buttons (ReloadUI/Config/etc.)

----------------------
-- INITIALIZATION ----
----------------------
function AM:AddGameMenuButton()
	--localize the game menu buttons
	local menu = _G.GameMenuFrame
	local macros = _G.GameMenuButtonMacros
	local ratings = _G.GameMenuButtonRatings
	local logout = _G.GameMenuButtonLogout
	
	--create the new game menu button
	local addons = CreateFrame("Button", "GameMenuButtonAddOns", menu, "GameMenuButtonTemplate")
	addons:SetText("Addons")


	addons:SetPoint('TOP', GameMenuButtonStore, 'BOTTOM', 0, -1)
	GameMenuButtonOptions:ClearAllPoints()
	GameMenuButtonOptions:SetPoint('TOP', addons, 'BOTTOM', 0, -1)
	GameMenuButtonOptions.SetPoint = function() end

	GameMenuButtonContinue:ClearAllPoints()
	GameMenuButtonContinue:SetPoint('TOP', GameMenuButtonQuit, 'BOTTOM', 0, -1)

	--Set it to load up the addon window on click
	addons:SetScript("OnClick", function() self:LoadMainWindow() end)
end

function AM:Initialize()
	self:UnregisterEvent('PLAYER_ENTERING_WORLD')

	local default = F.CopyTable(D.DefaultConfig, true)
	D.Saved = F.MergeTable(default, stAM_Config or {})

	-- D.Saved = stAM_Config or D.DefaultConfig --replace this with tablecopy later
	D.GlobalProfiles = stAM_Profiles or {}
	D.PrivateProfiles = stAM_ProfilesPerChar or {}

	self:AddGameMenuButton()
end

AM:RegisterEvent("PLAYER_ENTERING_WORLD")
AM:SetScript("OnEvent", function(self, event, ...) self:Initialize(event, ...) end)

SLASH_STADDONMANAGER1, SLASH_STADDONMANAGER2, SLASH_STADDONMANAGER3 = "/staddonmanager", "/stam", "/staddon"
SlashCmdList["STADDONMANAGER"] = function() AM:LoadMainWindow() end