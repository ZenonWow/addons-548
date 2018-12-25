local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

function SetTheory:Progress(i, actions, act)
	local act = act or ""
	local i = i or self.progressBar:GetValue()+1 or 0
	local actions = actions or select(2, self.progressBar:GetMinMaxValues())

	if i and act and actions then
		if not self.progressBar then
			local f = CreateFrame("StatusBar", "SetTheoryProgressBar", UIParent)
			--[[f:SetBackdrop({
				bgFile = "Interface\\AddOns\\SetTheory\\progress.tga",
				insets = {left=0, right=0, top=0, bottom=0}
			})]]

			f.txt = f:CreateFontString(_, "ARTWORK", "GameFontHighlight")
			f.txt:SetPoint("CENTER", 0, 0)

			f:SetWidth(220); f:SetHeight(20);
			f:SetPoint("CENTER", 0, 0)
			f:SetStatusBarTexture("Interface\\AddOns\\SetTheory\\progress.tga")
			local classColour = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
			f:SetStatusBarColor(classColour.r, classColour.g, classColour.b, 0.9)

			self.progressBar = f
		end

		local f = self.progressBar
		f:SetMinMaxValues(0, actions)
		f:SetValue(i)
		f.txt:SetText(act)

		self:CheckProgress()
	end
end

function SetTheory:CheckProgress()
	local f = self.progressBar

	if select(2, f:GetMinMaxValues()) == f:GetValue() then 
		f.txt:SetText(L['Done'])
		self:ScheduleTimer(function() self.progressBar:Hide() end, 1)
	else
		if self.db.char.progress then f:Show() else f:Hide() end
	end
end

function SetTheory:UpdateProgressTime(arg)
	local a= arg.action
	local s= arg.secs

	self.progressBar.txt:SetText(a.. ' ('..math.ceil(s)..' '..L['secs']..')')
	self.progressBar:SetValue(self.progressBar:GetValue() + 1)

	if s >= 0.1 then 
		s = s - 0.1
		self:ScheduleTimer("UpdateProgressTime", 0.1, {action=a, secs=s})
	end

	self:CheckProgress()
end
