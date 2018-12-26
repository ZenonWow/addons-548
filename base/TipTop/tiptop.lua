--CREATE & ASSIGN FRAMES--
TipTop = CreateFrame("FRAME", nil, GameTooltip)
	local TipTop = TipTop
local tt = GameTooltip
local ttSBar = GameTooltipStatusBar
local ttSBarBG = CreateFrame("Frame", nil, ttSBar)
local ttHealth = ttSBar:CreateFontString("ttHealth", "OVERLAY")
	ttHealth:SetPoint("CENTER")
local raidIcon = ttSBar:CreateTexture(nil, "OVERLAY")

--OTHER LOCALS--
local LSM = LibStub("LibSharedMedia-3.0")
local player = UnitName("player")
local server = GetRealmName()
local _, db, BGPosition, color, font, classif, factionIcon, factionTable
local tooltips = {	GameTooltip,
					ItemRefTooltip,
					BattlePetTooltip,
					ShoppingTooltip1,
					ShoppingTooltip2,
					ShoppingTooltip3,
					ItemRefShoppingTooltip1,
					ItemRefShoppingTooltip2,
					ItemRefShoppingTooltip3,
					WorldMapTooltip}

--UPVALUES--
local table_sort = _G.table.sort
local GetItemInfo = _G.GetItemInfo
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local SetRaidTargetIconTexture = _G.SetRaidTargetIconTexture
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitExists = _G.UnitExists
local UnitHealth = _G.UnitHealth
local UnitIsAFK = _G.UnitIsAFK
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsDND = _G.UnitIsDND
local UnitIsTapped = _G.UnitIsTapped
local UnitIsTappedByPlayer = _G.UnitIsTappedByPlayer
local UnitIsFriend = _G.UnitIsFriend
local UnitLevel = _G.UnitLevel
local UnitHealthMax = _G.UnitHealthMax
local UnitName = _G.UnitName
local UnitFactionGroup = _G.UnitFactionGroup
local UnitPlayerControlled = _G.UnitPlayerControlled
local GameTooltipTextLeft1 = GameTooltipTextLeft1
local qualityColor = ITEM_QUALITY_COLORS
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetInspectSpecialization = _G.GetInspectSpecialization
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetGuildInfo = _G.GetGuildInfo


function TipTop:SetBackgrounds()
	local backdrop = {	bgFile = LSM:Fetch("background", db.bg),
						insets = {left=db.inset, right=db.inset, top=db.inset, bottom=db.inset},
						edgeFile = LSM:Fetch("border", db.border),
						edgeSize = db.borderWidth	}
	for i = 1, #tooltips do
		tooltips[i]:SetScale(db.scale)
		tooltips[i]:SetBackdrop(backdrop)
		tooltips[i]:SetBackdropColor(db.bgColor.r, db.bgColor.g, db.bgColor.b, db.alpha)
		tooltips[i]:SetBackdropBorderColor(db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a)
	end
	TipTop:SetBackdrop(backdrop)
	TipTop:SetBackdropColor(db.bgColor.r, db.bgColor.g, db.bgColor.b, db.alpha)
	TipTop:SetBackdropBorderColor(db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a)
	TipTop:SetFrameLevel(tt:GetFrameLevel() - 1)	--make sure the tooltip isn't overlapped by the bg frame
	
	--make the tooltip transparent to see the TipTop frame behind it
	tt:SetBackdrop({})
	--make other frames look like TipTop's tooltips if they imitate the tooltip
	tt.GetBackdrop = function() return backdrop end
	tt.GetBackdropColor = function() return db.bgColor.r, db.bgColor.g, db.bgColor.b, db.alpha end
	tt.GetBackdropBorderColor = function() return db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a end
--	TOOLTIP_DEFAULT_COLOR = db.borderColor
--	TOOLTIP_DEFAULT_BACKGROUND_COLOR = db.bgColor
	-- make the map's tooltip always match (will reset itself on every OnShow)
	WorldMapTooltip.SetBackdropColor = function() end
	WorldMapTooltip.SetBackdropBorderColor = function() end
end

function TipTop:SetFonts()
	font = LSM:Fetch("font", db.font)	--grab font from LSM
	ttHealth:SetFont(font, 12, "OUTLINE")
	GameTooltipHeaderText:SetFont(font, 12 + 2, db.fontFlag)
	GameTooltipText:SetFont(font, 12, db.fontFlag)
	GameTooltipTextSmall:SetFont(font, 12 - 2, db.fontFlag)
	ShoppingTooltip1TextLeft1:SetFont(font, 12 -2, db.fontFlag)
	ShoppingTooltip1TextLeft2:SetFont(font, 12, db.fontFlag)
	ShoppingTooltip1TextLeft3:SetFont(font, 12 -2, db.fontFlag)
	ShoppingTooltip2TextLeft1:SetFont(font, 12 -2, db.fontFlag)
	ShoppingTooltip2TextLeft2:SetFont(font, 12, db.fontFlag)
	ShoppingTooltip2TextLeft3:SetFont(font, 12 -2, db.fontFlag)
	ShoppingTooltip3TextLeft1:SetFont(font, 12 -2, db.fontFlag)
	ShoppingTooltip3TextLeft2:SetFont(font, 12, db.fontFlag)
	ShoppingTooltip3TextLeft3:SetFont(font, 12 -2, db.fontFlag)
	--these were in the tips' onshow before - need to check later
	for i = 1, ShoppingTooltip1:NumLines() do
		_G["ShoppingTooltip1TextRight"..i]:SetFont(font, 12 -2, db.fontFlag)
	end
	for i = 1, ShoppingTooltip2:NumLines() do
		_G["ShoppingTooltip2TextRight"..i]:SetFont(font, 12 -2, db.fontFlag)
	end
	for i = 1, ShoppingTooltip3:NumLines() do
		_G["ShoppingTooltip3TextRight"..i]:SetFont(font, 12 -2, db.fontFlag)
	end
	if GameTooltipMoneyFrame1 then
		GameTooltipMoneyFrame1PrefixText:SetFont(font, 12, db.fontFlag)
		GameTooltipMoneyFrame1SuffixText:SetFont(font, 12, db.fontFlag)
		GameTooltipMoneyFrame1CopperButtonText:SetFont(font, 12, db.fontFlag)
		GameTooltipMoneyFrame1SilverButtonText:SetFont(font, 12, db.fontFlag)
		GameTooltipMoneyFrame1GoldButtonText:SetFont(font, 12, db.fontFlag)
	end
end

local SetSBarColor = ttSBar.SetStatusBarColor
ttSBar.SetStatusBarColor = function() return end
function TipTop:SBarCustom()
	ttSBar:SetStatusBarTexture(LSM:Fetch("statusbar", db.healthBar))
	SetSBarColor(ttSBar, db.sbarcolor.r, db.sbarcolor.g, db.sbarcolor.b, db.sbarcolor.a)
	ttSBarBG:SetAllPoints()
	ttSBarBG:SetFrameLevel(ttSBar:GetFrameLevel() - 1)
	ttSBarBG:SetBackdrop({bgFile = LSM:Fetch("statusbar", db.sbarbg)})
	ttSBarBG:SetBackdropColor(db.sbarbgcolor.r, db.sbarbgcolor.g, db.sbarbgcolor.b, db.sbarbgcolor.a)
end

function TipTop:SBarPosition()
	ttSBar:ClearAllPoints()
	if db.insideBar then
		if db.topBar then
			ttSBar:SetPoint("TOPRIGHT", tt, "TOPRIGHT", -7, 3)
			ttSBar:SetPoint("TOPLEFT", tt, "TOPLEFT", 10, 3)
			BGPosition = function()	--make the TipTop bg frame resize around the health bar
					if ttSBar:IsShown() then
						TipTop:ClearAllPoints()
						TipTop:SetPoint("BOTTOMRIGHT", tt, "BOTTOMRIGHT", 2, 0)
						TipTop:SetPoint("TOPLEFT", ttSBar, "TOPLEFT", -9, 10)
					else
						TipTop:ClearAllPoints()
						TipTop:SetAllPoints(tt)
					end
				end
		else
			ttSBar:SetPoint("BOTTOMRIGHT", tt, "BOTTOMRIGHT", -7, -5)
			ttSBar:SetPoint("BOTTOMLEFT", tt, "BOTTOMLEFT", 11, -5)
			BGPosition = function()	--make the TipTop bg frame resize around the health bar
					if ttSBar:IsShown() then
						TipTop:ClearAllPoints()
						TipTop:SetPoint("TOPRIGHT", tt, "TOPRIGHT", 2, 0)
						TipTop:SetPoint("BOTTOMLEFT", ttSBar, "BOTTOMLEFT", -9, -9)
					else
						TipTop:ClearAllPoints()
						TipTop:SetAllPoints(tt)
					end
				end
		end
	else
		if db.topBar then
			ttSBar:SetPoint("BOTTOMLEFT", tt, "TOPLEFT", 0, 4)
			ttSBar:SetPoint("BOTTOMRIGHT", tt, "TOPRIGHT", 0, 4)
		else
			ttSBar:SetPoint("TOPLEFT", tt, "BOTTOMLEFT", 0, -4)
			ttSBar:SetPoint("TOPRIGHT", tt, "BOTTOMRIGHT", 0, -4)
		end
		BGPosition = function() end
		TipTop:ClearAllPoints()
		TipTop:SetAllPoints(tt)
	end
end

function TipTop:FactionIcon()
	if not factionIcon then
		factionIcon = ttSBar:CreateTexture(nil, "OVERLAY")
		factionTable = {
				["Alliance"] = "Interface\\Timer\\Alliance-Logo",
				["Horde"] = "Interface\\Timer\\Horde-Logo",
				["Neutral"] = "Interface\\Timer\\Panda-Logo",
			}
	end
	factionIcon:SetWidth(db.factionIconSize)
	factionIcon:SetHeight(db.factionIconSize)
	factionIcon:SetPoint("CENTER", TipTop, db.factionIconPosition, db.factionIconX, db.factionIconY)
	factionIcon:Hide()
end

function TipTop:RaidIcon()
	raidIcon:SetWidth(db.raidIconSize)
	raidIcon:SetHeight(db.raidIconSize)
	raidIcon:SetTexture("Interface\\TARGETINGFRAME\\UI-RaidTargetingIcons")
	raidIcon:SetPoint("CENTER", TipTop, db.raidIconPosition, db.raidIconX, db.raidIconY)
	raidIcon:Hide()
end

local function FactionIconUpdate(unit)
	if UnitPlayerControlled(unit) then
		factionIcon:SetTexture(factionTable[UnitFactionGroup(unit)])
		factionIcon:Show()
	else
		factionIcon:Hide()
	end
end

local function RaidIconUpdate(unit)
	local icon = GetRaidTargetIndex(unit)
	if icon then
		SetRaidTargetIconTexture(raidIcon, icon)
		raidIcon:Show()
	else
		raidIcon:Hide()
	end
end

local function FadedTip(unit)	--grays out tooltip if unit is tapped or dead
	local tapped = false
	if not UnitPlayerControlled(unit) then
		if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
			tapped = true
		end
	end
	if UnitIsDead(unit) or tapped or not UnitIsConnected(unit) then
		local borderColor = db.borderColor
		TipTop:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
		local bgColor = db.bgColor
		TipTop:SetBackdropColor(bgColor.r + .2, bgColor.g +.2, bgColor.b + .2, db.alpha-.1)
	end
end

local function Appendices(unit)	--appends info to the name/guild of the unit - ALSO sets elite graphic
	classif = UnitClassification(unit)
	if db.elite and not elitetexture then
		elitetexture = TipTop:CreateTexture(nil, "OVERLAY")
		elitetexture:SetHeight(70)
		elitetexture:SetWidth(70)
		elitetexture:SetPoint("CENTER", TipTop, "TOPLEFT", 8, -18)
		elitetexture:Hide()
	end
	if classif == "rare" or classif == "rareelite" then
		tt:AppendText(" (Rare)")
		if db.elite and classif == "rareelite" then
			elitetexture:SetTexture("Interface\\AddOns\\TipTop\\media\\rare_graphic")
			elitetexture:Show()
		end
	elseif classif == "elite" or classif == "worldboss" or classif == "boss" then 
		if db.elite then
			elitetexture:SetTexture("Interface\\AddOns\\TipTop\\media\\elite_graphic")
			elitetexture:Show()
		end
	end
	
	if db.gender == nil then db.gender = true end
	if db.lookFor == nil then db.lookFor = true end
	
	local gen= db.gender and UnitSex(unit)
	if gen then
	  
	  local genTxt= gen==3 and "(Female)"  or  gen==2 and "(Male)"  or  gen==1  and  ""  or  "(Gender " .. gen .. ")"

	  local achievementId= 2422  -- Shake Your Bunny-Maker  (Noblegarden Event - in April)
	  local unitRace= UnitRace(unit)
	  local lookingFor= false
	  if db.lookFor and gen == 3 then  -- Female
	    for i = 1,GetAchievementNumCriteria(achievementId) do
	      lookForRace,_,complete = GetAchievementCriteriaInfo(achievementId, i)
	      if lookForRace == unitRace then
	        lookingFor= not complete
	        break
	      end
	    end
	  end
	  
	  if lookingFor then  -- found it?
	    genTxt= '|cffff0000' .. genTxt .. ' -> SHAKE IT|r'
	    --genTxt= genTxt .. '|cffff0000 -> SHAKE IT|r'
	    TipTop:SetBackdropColor(8, db.bgColor.g, db.bgColor.b, db.alpha)
	  end
	  
	  
	  --local achievementId= 283  -- The Masquerade  (Hallow's End Event - in October)
	  local achievementId= 291  -- Check Your Head  (Hallow's End Event - in October)
	  --local unitRace= UnitRace(unit)
	  local lookingFor= false
	  if  db.lookFor  then
	    for i = 1,GetAchievementNumCriteria(achievementId) do
	      lookForRace,_,complete = GetAchievementCriteriaInfo(achievementId, i)
	      if lookForRace == unitRace then
	        lookingFor= not complete
	        break
	      end
	    end
	  end
	  
	  if lookingFor then  -- found it? make it red
	    genTxt= genTxt .. '|cffff0000 -> JACK-O-IT|r'
	    local r= db.bgColor.r + 8
	    --TipTop:SetBackdropColor(8, db.bgColor.g, db.bgColor.b, db.alpha)
	  end
	  
	  tt:AppendText(" " .. genTxt)
	end
	
	
	if UnitIsAFK(unit) then
		tt:AppendText(" (AFK)")
	elseif UnitIsDND(unit) then
		tt:AppendText(" (DND)")
	end
	if db.guildRank then
		local guild, rank = GetGuildInfo(unit)
		if guild then
			local text = nil
			text = GameTooltipTextLeft2:GetText()
			if text == guild then
				GameTooltipTextLeft2:SetFormattedText("%s (%s)", text, rank)
				tt:Show()
			end
		end
	end
end

local function BorderClassColor(unit)	--colors tip border
	local _,class = UnitClass(unit)
	local level = UnitLevel(unit)
	if db.diffColor and level then	--if coloring by difficulty
		if db.classColor and class and UnitIsFriend("player", unit) then	--if class enabled, too, use that if unit is friendly
			TipTop:SetBackdropBorderColor(color[class].r - .2, color[class].g - .2, color[class].b - .2, db.borderColor.a)
		else	--all else, color by difficulty
			if level == -1 then	--account for bosses and elites being harder
				level = 90
			elseif classif == "elite" or classif == "rareelite" then
				level = level + 3
			elseif classif == "boss" or classif == "worldboss" then
				level = level + 5
			end
			level = GetQuestDifficultyColor(level)
			TipTop:SetBackdropBorderColor(level.r, level.g, level.b, db.borderColor.a)
		end
	elseif db.classColor and class then	--if just coloring by class
		TipTop:SetBackdropBorderColor(color[class].r - .2, color[class].g - .2, color[class].b - .2, db.borderColor.a)
	else	--default border color
		local borderColor = db.borderColor
		TipTop:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
	end
	if db.classIcon and class then
		local text = nil	--reset text var to maybe, hopefully quell repeating icon issue...
		text = GameTooltipTextLeft1:GetText()
		if text then
			GameTooltipTextLeft1:SetText("|TInterface\\AddOns\\TipTop\\media\\"..class..":20|t "..text)
			tt:Show()
		end
	end
	if db.sbarclass and class then
		SetSBarColor(ttSBar, color[class].r, color[class].g, color[class].b)
	end
end

local function ItemQualityBorder(tip)	--colors tip border by item quality
	if  not db.itemColor  then
		if tip == ItemRefTooltip then
			local qc = db.borderColor
			tip:SetBackdropBorderColor(qc.r, qc.g, qc.b, qc.a)
		end
		return
	end
	
	local _,item = tip:GetItem()	--tip is whatever tooltip called the OnTooltipSetItem script
	if  not item  then  return  end
	local _,_,quality = GetItemInfo(item)
	if  not quality  then  return  end
	
	local qc = qualityColor[quality]
	if qc.r and qc.g and qc.b then
		if tip == tt then  tip = TipTop  end
		tip:SetBackdropBorderColor(qc.r - .2, qc.g - .2, qc.b - .2, db.borderColor.a)
	end
end

local function PetQualityBorder(tip, quality)	--colors tip border by item quality
	if  not db.itemColor  then  return  end
	if  not quality  then  return  end
	local qc = qualityColor[quality]
	if qc.r and qc.g and qc.b then
		tip:SetBackdropBorderColor(qc.r - .2, qc.g - .2, qc.b - .2, db.borderColor.a)
	end
end

local function CalcHealth(unit, hp)	--sets health text on status bar
	if db.healthText then
		local per, hpmult, hpdiv, maxhpmult, maxhpdiv, hpformat, maxhpformat	--upvalues
		local maxhp = UnitHealthMax(unit)
		if maxhp == 0 then maxhp = 1 end
		local hp = hp or UnitHealth(unit)
		if db.textformat == "100/100" then
			ttHealth:SetFormattedText("%d / %d", hp, maxhp)
		elseif db.textformat == "100%" then
			per = (hp/maxhp) * 100
			if per <= 100 then	--gives maxhp of 1 sometimes when tooltip fades?
				ttHealth:SetFormattedText("%d%%", per)
			end
		elseif db.textformat == "100/100 (100%)" then
			per = (hp/maxhp) * 100
			if per <= 100 then
				ttHealth:SetFormattedText("%d / %d (%d%%)", hp, maxhp, per)
			end
		elseif db.textformat == "1.2k/1.2k" then
			hpformat, maxhpformat = "%.1f", "%.1f"
			if hp >= 1000000 then
				hpmult, hpdiv = "m", 1000000
			elseif hp >= 1000 then
				hpmult, hpdiv = "k", 1000
			else
				hpmult, hpdiv = "", 1
				hpformat = "%d"
			end
			if maxhp >= 1000000 then
				maxhpmult, maxhpdiv = "m", 1000000
			elseif hp >= 1000 then
				maxhpmult, maxhpdiv = "k", 1000
			else
				maxhpmult, maxhpdiv = "", 1
				maxhpformat = "%d"
			end
			ttHealth:SetFormattedText(hpformat.."%s / "..maxhpformat.."%s", hp/hpdiv, hpmult, maxhp/maxhpdiv, maxhpmult)
		end
	end
end

local function TargetTextUpdate()	--shows and updates target text
	if db.showTargetText then
		local unittarget = tt:GetUnit() .. "target"
		local target, tserver = UnitName(unittarget)
		local _,tclass = UnitClass(unittarget)
		if target and target ~= UNKNOWN and tclass then
			local targetLine
			for i=1, GameTooltip:NumLines() do	--scan tip to see if Target line is already added
				local left, right, leftText, rightText
				left = _G[GameTooltip:GetName().."TextLeft"..i]
				leftText = left:GetText()
				right = _G[GameTooltip:GetName().."TextRight"..i]
				if leftText == "Target:" then	--if already present, then just update it
					if db.you and target == player and (tserver == nil or tserver == server) then
						right:SetText("<<YOU>>")
						right:SetTextColor(.9, 0, .1)
					else
						right:SetText(target)
						right:SetTextColor(color[tclass].r,color[tclass].g,color[tclass].b)
					end
					tt:Show()
					targetLine = true
				end
			end
			if targetLine ~= true then	--if not present, then add it
				if db.you and target == player and (tserver == nil or tserver == server) then
					tt:AddDoubleLine("Target:", "<<YOU>>", nil, nil, nil, .9, 0, .1)
				else
					local tcolor = color[tclass]
					if tcolor then	--sometimes get an error about tcolor being nil - maybe from tips appearing/disappearing too fast?
						tt:AddDoubleLine("Target:", target, nil,nil,nil,tcolor.r,tcolor.g,tcolor.b)
					end
				end
				tt:Show()
			else 
				targetLine = false
			end
		end
	end
end


--[[
local patchedInspectFrame

local function PatchInspectUI(InspectFrame, f2, f3, f4)
	if  not InspectFrame  then  return  end
	patchedInspectFrame = InspectFrame

	-- The same condition is copied 4 times, yet it fails to check if the INSPECT_READY event is for the actual inspected player/npc,
	-- therefore the event has to be registered only for one INSPECT_READY event after InspectFrame_Show()
	local _ = InspectFrame:UnregisterEvent('INSPECT_READY')
	_ =  f2  and  f2:UnregisterEvent('INSPECT_READY')
	_ =  f3  and  f3:UnregisterEvent('INSPECT_READY')
	_ =  f4  and  f4:UnregisterEvent('INSPECT_READY')
	
	hooksecurefunc('InspectFrame_Show', function ()
		local _ = InspectFrame:RegisterEvent('INSPECT_READY')
		--[=[
		_ =  f2  and  f2:RegisterEvent('INSPECT_READY')
		_ =  f3  and  f3:RegisterEvent('INSPECT_READY')
		_ =  f4  and  f4:RegisterEvent('INSPECT_READY')
		--]=]
	end
	
	InspectFrame:HookScript('OnEvent', function (self, event, guid, ...)
		if  event ~= 'INSPECT_READY'  then  return  end
		local _ = InspectFrame:UnregisterEvent('INSPECT_READY')
		_ =  f2  and  f2:GetScript('OnEvent')(f2, event, guid, ...)
		_ =  f3  and  f3:GetScript('OnEvent')(f3, event, guid, ...)
		_ =  f4  and  f4:GetScript('OnEvent')(f4, event, guid, ...)
		--[=[
		_G.InspectGuildFrame_OnEvent(_G.InspectGuildFrame, event, guid, ...)
		_G.InspectPaperDollFrame_OnEvent(_G.InspectPaperDollFrame, event, guid, ...)
		_G.InspectTalentFrame_OnEvent(_G.InspectTalentFrame, event, guid, ...)
		--]=]
	end)
end
--]]

--[[
local suspendedInspectFrames = {}

local function ResumeInspectEvent()
	for  i,frame  in pairs(suspendedInspectFrames) do
		frame:RegisterEvent('INSPECT_READY')
	end
	wipe(suspendedInspectFrames)
end

local function SuspendInspectEvent(...)
	local inspectUIloaded
	for  i = 1,select('#',...)  do
		local frame = select(i,...)
		if  frame  and  frame:IsEventRegistered('INSPECT_READY')  then
			inspectUIloaded = true
			--tinsert(suspendedInspectFrames, frame)
			suspendedInspectFrames[frame] = frame
			frame:UnregisterEvent('INSPECT_READY')
		end
	end
	if  inspectUIloaded  and  not patchedInspectUI  and  _G.InspectFrame_Show  then
		patchedInspectUI = true
		hooksecurefunc('InspectFrame_Show', ResumeInspectEvent)
	end
end
--]]


local function StopInspect()
	if  _G.INSPECTED_UNIT == TipTop.unit  then
		ClearInspectPlayer(TipTop.unit)
		_G.INSPECTED_UNIT = nil
	end
	
	TipTop.unit = nil
	TipTop.guid = nil
	TipTop:UnregisterEvent('INSPECT_READY')
end

local function CheckInspectFrame(frame)
	-- Return NotifyInspect() to Examiner / InspectFrame 's unit
	if  frame  and  frame:IsShown()  and  CanInspect(frame.unit)  then
		if  TipTop.guid ~= UnitGUID(unit)  then  StopInspect()  end
		
		_G.INSPECTED_UNIT = unit
		NotifyInspect(unit)
		return true
	end
end


local function TalentQuery(unit)	--send request for talent info
	if  not db.showTalentText  or  not CanInspect(unit)  then
		if  TipTop.guid  then  StopInspect()  end
		return
	end
	
	--if  UnitName(unit) ~= player  then  return  end
	if  UnitLevel(unit) < 10  then  return  end
	
	local talentline = nil
	for i=1, tt:NumLines() do
		local left = _G["GameTooltipTextLeft"..i]
		if  left:GetText() == "Specialization:"  then
			talentline = i
			break
		end
	end
	if   talentline  then  return  end
	
	
	--[[
	-- Both Examiner and InspectFrame checks guid and should be safe from concurrent queries.
	local InspectFrame, Examiner = _G.InspectFrame, _G.Examiner
	if  not patchedInspectFrame  and  InspectFrame  then  PatchInspectUI(InspectFrame, _G.InspectGuildFrame, _G.InspectPaperDollFrame, _G.InspectTalentFrame)  end
	--SuspendInspectEvent(InspectFrame, _G.InspectGuildFrame, _G.InspectPaperDollFrame, _G.InspectTalentFrame)
	
	if  Examiner  and  Examiner:IsShown()  and  Examiner:IsEventRegistered('INSPECT_READY')  then
		tt:AddDoubleLine("Specialization:", "Examiner frame is querying", nil,nil,nil, 1,0,0)
	elseif  InspectFrame  and  InspectFrame:IsShown()  then	--to not step on default UI's toes
		tt:AddDoubleLine("Specialization:", "Inspect Frame is querying", nil,nil,nil, 1,0,0)
	else
	--]]
	do
		tt:AddDoubleLine("Specialization:", "...")	--adds the Specialization line with a placeholder for info
		TipTop.unit = unit
		TipTop.guid = guid
		TipTop:RegisterEvent('INSPECT_READY')
		
		_G.INSPECTED_UNIT = unit
		NotifyInspect(unit)
	end
	tt:Show()
end

local function TalentText()
	local unit = TipTop.unit
	local maxtree,left,leftText
	if UnitExists(unit) then
		maxtree = GetInspectSpecialization(unit)
		if maxtree and maxtree > 0 then
			for i=1, tt:NumLines() do
				left = _G[GameTooltip:GetName().."TextLeft"..i]
				leftText = left:GetText()
				-- Find the Specialization line and update with info
				if leftText == "Specialization:" then
					_G[GameTooltip:GetName().."TextRight"..i]:SetText(select(2,GetSpecializationInfoByID(maxtree)))
				end
				tt:Show()
			end
		end
	end
end

local ttWidth
local function MouseoverTargetUpdate()	--do this stuff whenever the mouseover unit is changed
	local unit = tt:GetUnit()
	Appendices(unit)
	BorderClassColor(unit)
	CalcHealth(unit)
	RaidIconUpdate(unit)
	TalentQuery(unit)
	FadedTip(unit)
	if db.factionIcon then
		FactionIconUpdate(unit)
	end
	--sets min size for aesthetics and for extended health text
	ttWidth = tt:GetWidth()
	if ttWidth < 175 and db.healthText and db.textformat == "100/100 (100%)" then
		tt:SetWidth(200)
	elseif ttWidth < 125 then
		tt:SetWidth(125)
	end
end

local function TipShow()	--do this stuff whenever the tip is shown
	if not tt:GetUnit() and not tt:GetItem() then
		local borderColor = db.borderColor
		TipTop:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
	end
	local bgColor = db.bgColor
	TipTop:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, db.alpha)
	BGPosition()
	if elitetexture then
		elitetexture:Hide()	--hide this in case tip isn't showing a unit or the unit is not elite/rare atm
	end
end

local function PlayerLogin()
	if TipTopPCDB.charSpec then
		db = TipTopPCDB
	else
		db = TipTopDB
	end
	TipTop:SetBackgrounds()
	TipTop:SBarCustom()
	TipTop:SBarPosition()
	TipTop:SetFonts()
	TipTop:RaidIcon()
	if db.factionIcon then
		TipTop:FactionIcon()
	end
	
	color = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS	--support for CUSTOM_CLASS_COLORS addons
	if CUSTOM_CLASS_COLORS then
		CUSTOM_CLASS_COLORS:RegisterCallback(function() color = CUSTOM_CLASS_COLORS end)
	end

	--moves tooltip
	hooksecurefunc("GameTooltip_SetDefaultAnchor", function (tooltip, parent)
			if db.onCursor then
				tt:SetOwner(parent, "ANCHOR_CURSOR")
			else
				tt:SetOwner(parent, "ANCHOR_NONE")
				tt:SetPoint(db.anchor, UIParent, db.anchor, db.offsetX, db.offsetY)
			end
		end)
	
	TipTop:UnregisterEvent("PLAYER_LOGIN")
	--TipTop:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	GameTooltip:HookScript("OnTooltipSetUnit", MouseoverTargetUpdate)
	GameTooltip:HookScript("OnTooltipCleared", StopInspect)
	GameTooltip:HookScript("OnHide", StopInspect)
	TipTop:SetScript("OnEvent", function(_, event, arg)
		--[[
		if event == "UPDATE_MOUSEOVER_UNIT" then
			MouseoverTargetUpdate()
		end
		--]]
		if  event == 'INSPECT_READY'  then
			if TipTop.guid == arg then	--only gather information about the unit we requested
				TalentText()
				local _ =  CheckInspectFrame(_G.Examiner)  or  CheckInspectFrame(_G.InspectFrame)
			end
		end
	end)
	
	local moneyfontset
	-- TipTop\tiptop-2.13.3.lua:588: BattlePetTooltip doesn't have a "OnTooltipSetItem" script
	-- if  tooltips[i]:HasScript('OnTooltipSetItem')  then
	for i=1,#tooltips do  if  BattlePetTooltip ~= tooltips[i]  then
		tooltips[i]:HookScript("OnTooltipSetItem", function(tip)
				ItemQualityBorder(tip)
				--the vendor price strings don't exist until the first time they're needed
				if GameTooltipMoneyFrame1 and not moneyfontset then
					TipTop:SetFonts()
					moneyfontset = true
				end
			end)
	end end
	ttSBar:HookScript("OnValueChanged", function(_,hp) CalcHealth(tt:GetUnit(), hp) end)
	ttSBar:HookScript("OnUpdate", TargetTextUpdate)
	
	hooksecurefunc('BattlePetToolTip_Show', function (speciesID, level, breedQuality, maxHealth, power, speed, customName)
		PetQualityBorder(BattlePetTooltip, breedQuality)
	end)
	
	
	PlayerLogin = nil	--let this function be garbage collected
end


TipTop:RegisterEvent("PLAYER_LOGIN")
TipTop:SetScript("OnEvent", PlayerLogin)
TipTop:SetScript("OnShow", TipShow)
-- Survive delayed load
if  IsLoggedIn()  then  PlayerLogin()  end

