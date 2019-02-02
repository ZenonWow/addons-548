
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Dualspec" -- L["Dualspec"]
local unspent = 0, 0
local specs = {}


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile=GetItemIcon(7516),coords={0.05,0.95,0.05,0.95}}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show and switch your character specializations"],
	events = {
		"PLAYER_LOGIN",
		"ACTIVE_TALENT_GROUP_CHANGED",
		"PLAYER_ENTERING_WORLD",
		"SKILL_LINES_CHANGED",
		"CHARACTER_POINTS_CHANGED",
		"PLAYER_TALENT_UPDATE",
	},
	updateinterval = nil, -- 10
	config_defaults = nil,
	config_allowed = nil,
	config = nil,
}


--------------------------
-- some local functions --
--------------------------



------------------------------------
-- module (BE internal) functions --
------------------------------------

module.onevent = function(self,event,msg)
	local specName = L["No Spec!"]
	local icon = I(name)
	local spec = GetSpecialization()
	local _ = nil
	local dataobj = self.obj
	unspent = GetNumUnspentTalents()

	if spec ~= nil then
		 _, specName, _, icon.iconfile, _, _ = GetSpecializationInfo(spec)
	end

	dataobj.iconCoords = icon.coords
	dataobj.icon = icon.iconfile

	if unspent~=0 then
		dataobj.text = C("ltred",string.format(L["Unspent talents: %d"],unspent))
	else
		dataobj.text = specName
	end

end

module.ontooltip = function(tt)
	ns.tooltipScaling(tt)
	tt:AddLine(L["Talents"])

	local activeSpec = GetSpecialization()
	local numberSpecs = GetNumSpecGroups()
	local specs = { }
		
	for i=1, numberSpecs do
		specs["spec" .. i] = GetSpecialization(false,false,i)
	end

	if specs.spec1 == nil and specs.spec2 == nil then
		tt:AddLine(L["No specialisation found"])
	else
		for k, v in pairs(specs) do
			local _, specName, _, icon, _, _ = GetSpecializationInfo(v)
			if v == activeSpec then
				tt:AddDoubleLine(specName, L["Active"])
			else
				tt:AddDoubleLine(specName, "")
			end

			tt:AddTexture(icon)
		end
	end

	if unspent ~= 0 then
		tt:AddLine(" ")
		tt:AddLine(C("ltred",string.format(unspent==1 and L["%d unspent talent"] or L["%d unspent talents"],unspent)))
	end

	if Broker_EverythingDB.showHints then
		tt:AddLine(" ")
		tt:AddLine(C("copper",L["Double Click"]).." || "..C("green",L["Switch spec."]))
		tt:AddLine(C("copper",L["Left-Click"]) .." || "..C("green",L["Open specializations pane"]))
		tt:AddLine(C("copper",L["Shift + Left-Click"]) .." || "..C("green",L["Open default pane"]))
		tt:AddLine(C("copper",L["Right-Click"]).." || "..C("green",L["Open talents pane"]))
		tt:AddLine(C("copper",L["Alt + Right-Click"]) .." || "..C("green",L["Open glyphs pane"]))
	end
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------

module.onclick = function(self,button)
	TalentFrame_LoadUI()
	local open = PlayerTalentFrame:IsShown()
	local opentab = PanelTemplates_GetSelectedTab(PlayerTalentFrame)    -- PlayerTalentFrame.selectedTab
	local showtab
	if button == "LeftButton" then
		if  IsShiftKeyDown()  then
			ToggleTalentFrame()  -- Open Blizz suggested tab
			return
		else
			showtab = SPECIALIZATION_TAB
		end
	elseif button == "RightButton" then
		if  IsAltKeyDown()  then
			GlyphFrame_LoadUI()
			-- ToggleGlyphFrame()
			-- PlayerTalentFrame_OpenGlyphFrame(GetActiveSpecGroup())
			showtab = GLYPH_TAB
		else
			showtab = TALENTS_TAB
		end
	end

	if  open  and  opentab == showtab  then
		HideUIPanel(PlayerTalentFrame)
	else
		ShowUIPanel(PlayerTalentFrame)
		PlayerTalentFrameTab_OnClick(_G["PlayerTalentFrameTab"..showtab])
		-- PlayerSpecTab_OnClick(specTabs[index])
	end
end

module.ondblclick = function(self,button)
	-- 1->2, 2->1
	SetActiveSpecGroup(3 - GetActiveSpecGroup())
end


-- final module registration --
-------------------------------
ns.modules[name] = module

