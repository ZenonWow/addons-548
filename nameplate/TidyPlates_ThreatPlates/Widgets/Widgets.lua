local _, ns = ...
local t = ns.ThreatPlates

do
	local function AuraFilter(aura)
	
		local DB = TidyPlatesThreat.db.profile.debuffWidget
		local isType, isShown
		
		if aura.reaction == 1 and DB.showEnemy then
			isShown = true
		elseif aura.reaction == 2 and DB.showFriendly then
			isShown = true
		end
		if DB.displays[aura.type] then
			isType = true
		end		
		if isShown and isType then
			local mode = DB.mode
			local spellfound = tContains(DB.filter, aura.name)
			if spellfound then spellfound = true end
			local isMine = (aura.caster == UnitGUID("Player"))
			if mode == "whitelist" then
				return spellfound
			elseif mode == "whitelistMine" then
				if isMine then
					return spellfound
				end
			elseif mode == "all" then
				return true
			elseif mode == "allMine" then
				if isMine then
					return true
				end
			elseif mode == "blacklist" then
				return not spellfound
			elseif mode == "blacklistMine" then
				if isMine then
					return not spellfound
				end
			end
		end
	end
	
	local isAuraEnabled
	local function AuraEnable()
		if TidyPlatesThreat.db.profile.debuffWidget.ON then
			if not isAuraEnabled then
				TidyPlatesWidgets.EnableAuraWatcher()
				TidyPlatesWidgets.SetAuraFilter(AuraFilter)
				isAuraEnabled = true
			end
		else
			if isAuraEnabled then
				TidyPlatesWidgets.DisableAuraWatcher()
				isAuraEnabled = false
			end
		end
		return TidyPlatesThreat.db.profile.debuffWidget.ON
	end
	
	local function CustomAuraUpdate(frame, unit)
		if TidyPlatesThreat.db.profile.debuffWidget.targetOnly and not unit.isTarget then
			frame:Hide()
			return
		end
		frame.OldUpdate(frame,unit)
		frame:SetScale(TidyPlatesThreat.db.profile.debuffWidget.scale)
		frame:SetPoint(TidyPlatesThreat.db.profile.debuffWidget.anchor, frame:GetParent(), TidyPlatesThreat.db.profile.debuffWidget.x, TidyPlatesThreat.db.profile.debuffWidget.y)
		frame:Show()		
	end
	
	local function CreateAuraWidget(plate)
		local frame
		frame = TidyPlatesWidgets.CreateAuraWidget(plate)
		frame.OldUpdate = frame.Update
		frame.Update = CustomAuraUpdate
		frame.Filter = AuraFilter
		return frame
	end
	
	ThreatPlatesWidgets.RegisterWidget("AuraWidget",CreateAuraWidget,true,AuraEnable)
	
	-- End Aura Widget --
	
	------------------------
	-- Threat Line Widget --
	------------------------
	
	local function ThreatLineEnable()
		return TidyPlatesThreat.db.profile.tankedWidget.ON
	end
	
	--ThreatPlatesWidgets.RegisterWidget("ThreatLineWidget",CreateAuraWidget,true,AuraEnable)
	-- End Threat Line Widget --
	
	----------------------------
	-- Healer Tracking Widget --
	----------------------------
	
	local healerTrackerEnabled
	local function HealerTrackerEnable()
		if TidyPlatesThreat.db.profile.healerTracker.ON then
			if not healerTrackerEnabled then
				TidyPlatesUtility.EnableHealerTrack()
			end
		else
			if healerTrackerEnabled then
				TidyPlatesUtility.DisableHealerTrack()
			end
		end
		return TidyPlatesThreat.db.profile.healerTracker.ON
	end
	
	local function CustomHealerTrackerUpdate(frame, unit)
		frame.OldUpdate(frame,unit)
		frame:SetScale(TidyPlatesThreat.db.profile.healerTracker.scale)
		frame:SetPoint(TidyPlatesThreat.db.profile.healerTracker.anchor, frame:GetParent(), TidyPlatesThreat.db.profile.healerTracker.x, TidyPlatesThreat.db.profile.healerTracker.y)
		frame:Show()
	end
	
	
	local function CreateHealerTrackerWidget(plate)
		local frame
		frame = TidyPlatesWidgets.CreateHealerWidget(plate)
		frame.OldUpdate = frame.Update
		frame.Update = CustomHealerTrackerUpdate
		frame.Filter = AuraFilter
		return frame
	end
	
	ThreatPlatesWidgets.RegisterWidget("HealerTracker",CreateHealerTrackerWidget,true,HealerTrackerEnable)
end