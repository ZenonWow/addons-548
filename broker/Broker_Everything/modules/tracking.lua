
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Tracking" -- L["Tracking"]
local tt = nil
local GetNumTrackingTypes,GetTrackingInfo = GetNumTrackingTypes,GetTrackingInfo


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
--I[name] = {iconfile="Interface\\Addons\\"..addon.."\\media\\tracking"}
I[name] = {iconfile="Interface\\minimap\\tracking\\none"}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show what you are currently tracking. You can also change the tracking types from this broker."],
	events = {
		"MINIMAP_UPDATE_TRACKING",
		"PLAYER_LOGIN",
		"PLAYER_ENTERING_WORLD"
	},
	updateinterval = nil, -- 10
	config_defaults = {
		displaySelection = true,
		hideMinimapButton = false
	},
	config_allowed = nil,
	config = {
		height=52,
		elements = {
			{
				type = "check",
				name = "displaySelection",
				label = L["Display selection"],
				desc = L["Display one of the selected tracking options in broker text."],
				event = true
			},
			{
				type = "check",
				name = "hideMinimapButton",
				label = L["Hide minimap button"],
				desc = L["Hide blizzard's tracking button on minimap"],
				event = "BE_HIDE_TRACKING"
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------
local function updateTracking()
	local tActive = 0
	local n = {}

	for i = 1, GetNumTrackingTypes() do
		local name, tex, active, category = GetTrackingInfo(i)
		if active == 1 then
			tActive = tActive + 1
			n[tActive] = {["Name"] = name, ["Texture"] = tex}
		end
	end

	return tActive, n
end 


------------------------------------
-- module (BE internal) functions --
------------------------------------
module.preinit = function()
	ns.hideFrame("MiniMapTracking", module.modDB.hideMinimapButton)
end

module.onevent = function(self,event,msg)
	local numActive, trackActive = updateTracking()
	local n = L[name]

	if Broker_EverythingDB[name].displaySelection then
		if numActive == 0 then 
			n = "None"
		else
			for i = 1, numActive, 1 do
				n = trackActive[i]["Name"]
			end
		end
	end

	if event == "BE_HIDE_TRACKING" then -- custom event on config changed
		ns.hideFrame("MiniMapTracking", module.modDB.hideMinimapButton)
	end

	module.obj.text = n
end

module.ontooltip = function(tt)
	local numActive, trackActive = updateTracking()
	ns.tooltipScaling(tt)
	tt:AddLine(L[name])
	tt:AddLine(" ")

	if numActive == 0 then
		tt:AddLine(C("white",L["No tracking option active."]))
	else
		for i = 1, numActive do 
			tt:AddDoubleLine(C("white",trackActive[i]["Name"]))
			tt:AddTexture(trackActive[i]["Texture"])
		end
	end

	if Broker_EverythingDB.showHints then
		tt:AddLine(" ")
		tt:AddLine(C("copper",L["Click"]).." || "..C("green",L["Open tracking menu"]))
	end
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
module.onclick = function(display, button)
	ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, display, 0, 0)
	if  not MiniMapTrackingDropDown:IsShown()  then
		-- ns.defaultOnEnter(module, display)
		local OnEnter = display:GetScript('OnEnter')
		assert(OnEnter, "BE.modules.tracking.onclick():  Broker display did not set OnEnter script.")
		OnEnter(display)
	elseif module.tooltip then
		-- ns.hideTooltip(module.tooltip, nil, true)
		module.tooltip:Hide()
		module.tooltip = nil
	end
end


-- final module registration --
-------------------------------
ns.modules[name] = module

