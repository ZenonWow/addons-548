-----------------------
-- Class Icon Widget --
-----------------------
local path = "Interface\\AddOns\\TidyPlates_ThreatPlates\\Widgets\\ClassIconWidget\\"

local function enabled()
	local db = TidyPlatesThreat.db.profile.classWidget
	return db.ON
end

local function UpdateSettings(frame)
	local db = TidyPlatesThreat.db.profile.classWidget
	frame:SetHeight(db.scale)
	frame:SetWidth(db.scale)		
	frame:SetPoint((db.anchor), frame:GetParent(), (db.x), (db.y))
end

local function UpdateClassIconWidget(frame, unit)
	local db = TidyPlatesThreat.db.profile
	if not enabled() then frame:Hide(); return end
	local class 
	if unit.class and (unit.class ~= "UNKNOWN") then
		class = unit.class
	elseif db.friendlyClassIcon then
		if unit.guid then
			local _, Class = GetPlayerInfoByGUID(unit.guid)
			if not db.cache[unit.name] then
				if db.cacheClass then
					db.cache[unit.name] = Class
				end
				class = Class
			else
				class = db.cache[unit.name]
			end
		end			
	end
	if class then -- Value shouldn't need to change
		UpdateSettings(frame)
		frame.Icon:SetTexture(path..db.classWidget.theme.."\\"..class)
		frame:Show()
	else
		frame:Hide()	
	end
end

local function CreateClassIconWidget(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(64)
	frame:SetWidth(64)
	frame.Icon = frame:CreateTexture(nil, "OVERLAY")
	frame.Icon:SetAllPoints(frame)
	frame:Hide()
	frame.Update = UpdateClassIconWidget
	return frame
end

ThreatPlatesWidgets.RegisterWidget("ClassIconWidget",CreateClassIconWidget,false,enabled)

ThreatPlatesWidgets.CreateClassIconWidget = CreateClassIconWidget
