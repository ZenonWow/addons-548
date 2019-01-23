
-- saved variables
Broker_EverythingDB = {}
Broker_EverythingGlobalDB = {}

-- some usefull namespace to locals
local addon, ns = ...
local C, L = ns.LC.color, ns.L

local Broker_Everything = CreateFrame("Frame")
Broker_Everything:Hide()

--[[
ns.debugging = true
Broker_Everything:SetScript("OnUpdate",function(self,elapsed)
	for name, data in pairs(ns.updateList) do
		if data.interval~=nil then
			if data.interval == false then
				data.func(ns.modules[name],elapsed)
			elseif data.elapsed>=data.interval then
				data.elapsed = 0
				data.func(ns.modules[name],elapsed)
			else
				data.elapsed = data.elapsed + elapsed
			end
		end
	end
	for name, data in pairs(ns.timeoutList) do
		if data~=nil and (data.run) then
			if data.elapsed>=data.timeout then
				data.func(ns.modules[name])
				ns.timeoutList[name] = nil
			else
				data.elapsed = data.elapsed + elapsed
			end
		end
	end
	ns.bagScan:Update(elapsed)
end)

function Broker_Everything.resetDefaults()
	Broker_EverythingDB = {}
	Broker_EverythingGlobalDB = { global = true }

	for name, v in ipairs(ns.modules) do
		if name then
			if Broker_EverythingDB[name] == nil then
				Broker_EverythingDB[name] = {
					enabled = true,
				}
			end
		end
	end
end
--]]

Broker_Everything:SetScript("OnEvent", function (self, event, addonName)
	if event == "ADDON_LOADED" and addonName == addon then
		if  Broker_EverythingGlobalDB.global  then  Broker_EverythingDB = Broker_EverythingGlobalDB
		elseif  Broker_EverythingDB  then  Broker_EverythingCharDB = Broker_EverythingDB
		else  Broker_EverythingDB = Broker_EverythingCharDB
		end

		--[[
		if Broker_EverythingDB.reset == true then
			self.resetDefaults()
			Broker_EverythingDB["reset"] = false
			ns.Print(L["Warning"], L["saved variables have been reset."])
		end
		--]]

		for i,v in pairs({
			suffixColour = true,
			useBlizzGStings = false,
			tooltipScale = false,
			showHints = true,
			libdbicon = false,
			iconset = "NONE",
			iconcolor = C("white","colortable"),
			goldColor = false,
			usePrefix = false,
			maxTooltipHeight = 0.6,
			scm = false,
			ttModifierKey1 = "NONE",
			ttModifierKey2 = "NONE"
		}) do
			if Broker_EverythingDB[i]==nil then
				Broker_EverythingDB[i] = v
			end
		end

		Broker_EverythingDB.useBlizzStrings = false

		-- modules
		ns.modulesInit()

		self:UnregisterEvent("ADDON_LOADED")
	end
	if event == "PLAYER_ENTERING_WORLD" then

		-- iconset
		ns.I(true)
		ns.updateIcons()

		-- panels for broker and config
		ns.OP.brokerPanel = ns.LSO.AddOptionsPanel(addon, ns.OP.createBrokerPanel)
		ns.OP.configPanel = ns.LSO.AddSuboptionsPanel(addon, L["Options"], ns.OP.createConfigPanel)

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
	if  event == "PLAYER_LOGOUT"  then
		ns.modulesOnLogout()
		-- Save only Broker_EverythingCharDB and Broker_EverythingGlobalDB
		Broker_EverythingDB = nil
	end
	if event == "NEUTRAL_FACTION_SELECT_RESULT" then
		ns.player.faction,ns.player.factionL  = UnitFactionGroup("player")
		L[ns.player.faction] = ns.player.factionL
	end
end)

Broker_Everything:RegisterEvent("ADDON_LOADED")
Broker_Everything:RegisterEvent("PLAYER_ENTERING_WORLD")
Broker_Everything:RegisterEvent("PLAYER_LOGOUT")
Broker_Everything:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")

