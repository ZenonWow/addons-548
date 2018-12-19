-- Thanks to Dridzt for the 5.0.4 update

local update, indicator = nil, nil
update = function()
	local hasData, leaderNeeds, tankNeeds, healerNeeds, dpsNeeds, _, _, _, _, instanceSubType, _, _, _, _, _, myWait, queuedTime = GetLFGQueueStats(LE_LFG_CATEGORY_LFD)
	if instanceSubType == LFG_SUBTYPEID_RAID or instanceSubType == LFG_SUBTYPEID_SCENARIO then
			return
	end
	if not indicator then  -- setup indicators
		QueueStatusMinimapButton.lfgindicators = CreateFrame("Frame", nil, QueueStatusMinimapButton)
		indicator = QueueStatusMinimapButton.lfgindicators
		local temp = 180 / math.pi / 5
		for i = 1, 5, 1 do
			local t = indicator:CreateTexture(nil, "OVERLAY")
			t:SetTexture("Interface\\AddOns\\LFGStatusIcon\\indicator.tga")
			t:SetWidth(5)
			t:SetHeight(5)
			t:SetPoint("CENTER", QueueStatusMinimapButton, "CENTER", 11 * math.cos((i - 1) * temp - 0.32), 11 * math.sin((i - 1) * temp - 0.32))
			indicator[i] = t
		end
	end
	if type(Capping) == "table" then
		if not Capping.LFG_PROPOSAL_SHOW then
			Capping:RegisterEvent("LFG_PROPOSAL_SHOW")
			function Capping:LFG_PROPOSAL_SHOW()
				self:StopBar(LOOKING_FOR_DUNGEON or "LFD")
				self:StartBar(ENTER_DUNGEON or "Enter Dungeon", 40, 40, "Interface\\Icons\\Ability_TownWatch", "info2", true, true)
			end

			Capping:RegisterEvent("LFG_PROPOSAL_FAILED")
			function Capping:LFG_PROPOSAL_FAILED()
				self:StopBar(LOOKING_FOR_DUNGEON or "LFD")
				self:StopBar(ENTER_DUNGEON or "Enter Dungeon")
			end
		end
		if hasData and dpsNeeds then
			if queuedTime then
				indicator.startTime = queuedTime
			elseif not indicator.startTime then
				indicator.startTime = GetTime()
			end
			myWait = myWait or 1
			Capping:StartBar(LOOKING_FOR_DUNGEON or "LFD", myWait, myWait - (GetTime() - indicator.startTime), "Interface\\Icons\\INV_Misc_Note_03", "info1", 120, true)
		else
			indicator.startTime = nil
			Capping:StopBar(LOOKING_FOR_DUNGEON or "LFD")
			Capping:StopBar(ENTER_DUNGEON or "Enter Dungeon")
		end
	end
	if not hasData or not dpsNeeds then  -- hide indicators if no data available
		for i = 1, 5, 1 do
			indicator[i]:SetVertexColor(1, 1, 1, 0)
		end
		return
	end

	for i = 1, 5, 1 do
		if i <= (3 - dpsNeeds) then
			indicator[i]:SetVertexColor(1, 0, 0, 0.9)
		else
			indicator[i]:SetVertexColor(1, 0.9, 0.9, 0.5)
		end
	end
	if healerNeeds == 0 then
		indicator[4]:SetVertexColor(0, 1, 0, 0.9)
	else
		indicator[4]:SetVertexColor(0.9, 1, 0.9, 0.5)
	end
	if tankNeeds == 0 then
		indicator[5]:SetVertexColor(0, 0, 1, 0.9)
	else
		indicator[5]:SetVertexColor(0.9, 0.9, 1, 0.5)
	end
end

hooksecurefunc("QueueStatusEntry_SetUpLFG", update)
QueueStatusMinimapButton:HookScript("OnShow", update)
if QueueStatusMinimapButton:IsShown() then
	update()
end
--[[
MoP changes
MiniMapLFGFrame -> QueueStatusMinimapButton
LFGSearchStatus_Update -> QueueStatusEntry_SetUpLFG
LFG_UpdateFramesIfShown -> 'nothing' (the events end up calling QueueStatusEntry_SetUpLFG)
]]