stldb = LibStub("LibDataBroker-1.1"):NewDataObject("SetTheory", {type='data source', icon="Interface\\GossipFrame\\HealerGossipIcon", label="SetTheory"})
local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

function stldb.OnClick(self, button)
	if button == "RightButton" and IsShiftKeyDown() then
		if SetTheory.working then return end
		if GetActiveTalentGroup() == 1 then SetActiveTalentGroup(2) else SetActiveTalentGroup(1) end
	elseif button == "RightButton" then
		if SetTheory.working then return end
		EasyMenu(SetTheory:GetMenuList(), SetTheory:GetMenuFrame(), "cursor", -5, 10, "MENU")
	else
		LibStub('AceConfigDialog-3.0'):Open('SetTheory')
	end
end

function stldb.OnTooltipShow(tt)
	tt:AddLine("SetTheory")
	tt:AddLine(L["Left Click"])
	if not SetTheory.working then
		tt:AddLine(L["Right Click"]) 
		tt:AddLine(L["Shift-Right Click"])
	end

	tt:AddLine(' ')
	UpdateAddOnMemoryUsage()
	local mem = GetAddOnMemoryUsage('SetTheory')
	tt:AddLine(L["Memory usage: "].. (mem > 1024 and ("|cff8080ff%.2f|r MiB"):format(mem / 1024) or ("|cff8080ff%.0f|r KiB"):format(mem)))
end

function stldb:Update()
	--self.text = "SetTheory: "
	self.text = ""
	if SetTheory.working then 
		self.text = self.text.. ""..L["Processing actions"]
		return
	end
	if SetTheory.db.char.active_set then
		self.text = self.text..SetTheory.db.char.active_set	
	else 	
		self.text = self.text .. L["No Set"]
	end
end

