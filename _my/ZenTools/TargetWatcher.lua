--[[
/run TargetWatcher:RegOnUpdate(true)
/run TargetWatcher:OnUpdate()
/run TargetWatcher.watchAll= true
--]]

TargetWatcher= CreateFrame('Frame','TargetWatcher')
--TargetWatcher:SetShown(false)
--TargetWatcher.prevGUID= UnitGUID('target')
--TargetWatcher.watchAll= false
TargetWatcher.npcIDs= {
-- http://www.wowhead.com/npc=18728/doom-lord-kazzak
	['18728'] = 1,
-- http://www.wowhead.com/npc=32491/time-lost-proto-drake
	['32491'] = 1,		-- npcID of Time-Lost Proto-Drake
-- http://www.wowhead.com/npc=50005/poseidus
	['50005'] = 1,
-- http://www.wowhead.com/npc=87493/rukhmar
	['87493'] = 1,
}

function TargetWatcher:OnEvent(event)
	local prevGUID= self.prevGUID
	local newGUID= UnitGUID('target')
	if  prevGUID == newGUID  then  return  end
	self.prevGUID= newGUID
	
	local prevID=  prevGUID  and  prevGUID:sub(18,22)
	local newID=  newGUID  and  newGUID:sub(18,22)
	local deselected=  self.npcIDs[prevID]
	local selected=  self.npcIDs[newID]
	
	if  deselected  or  selected  or  self.watchAll  then
		msg= event ..':   prevGUID=\124cFFff9900'.. tostring(prevGUID) ..'\124r   newGUID=\124cFFffff00'.. tostring(newGUID) ..'\124r'
		print(msg)
		if  deselected  or  selected  then
			SendChatMessage(msg, 'WHISPER', nil, UnitName('player'))
			Screenshot()
			PlaySound('RaidWarning', 'Master')
			TargetWatcher:RegOnUpdate(true)
		end
	end
end

function TargetWatcher:OnUpdate(event)
  self:OnEvent('TargetWatcher:OnUpdate')
end

function TargetWatcher:RegOnUpdate(enabled)
	--if  enabled == nil  then  enabled= not self.prevGUID  end
	self:SetScript('OnUpdate', enabled  and  self.OnUpdate  or  nil)
end

--TargetWatcher:RegOnUpdate()
TargetWatcher:OnUpdate()
TargetWatcher:SetScript('OnEvent', TargetWatcher.OnEvent)
TargetWatcher:RegisterEvent('PLAYER_TARGET_CHANGED')


