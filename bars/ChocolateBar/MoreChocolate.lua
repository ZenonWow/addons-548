﻿local _G, ADDON_NAME, _ADDON = _G, ...
local ChocolateBar = _ADDON.ChocolateBar
local LDB = _ADDON.LDB
local L = _ADDON.L

-- An LDB object that will show/hide the chocolatebar designated for newly installed broker/addons.
local counter = 0
local delay = 4
-- local Timer = CreateFrame("Frame")
local bar
local wipe, pairs = wipe, pairs
--GLOBALS: InterfaceOptionsFrame_OpenToCategory

local moreChocolate = LDB:NewDataObject("ChocolateBar", {
	type = "launcher",
	icon = "Interface\\AddOns\\ChocolateBar\\pics\\ChocolatePiece",
	label = "ChocolateBar",
	
	OnClick = function(self, btn)
		if btn == "LeftButton" then
			ChocolateBar:ToggleEditMode()
			--[[
			local bar = ChocolateBar:GetNewPiecesBar()
			if bar then  bar:Toggle()  end
			if bar then
				if bar:IsShown() then
					bar:Hide()
					Timer:SetScript("OnUpdate", nil)
				else
					bar:Show()
					--bar:ShowAll()
					if delay > 0 then
						Timer:SetScript("OnUpdate", Timer.OnUpdate)
					end
				end
			end
			--]]
		elseif btn == "MiddleButton" then
			ChocolateBar:ToggleInterfaceOptions()
		elseif btn == "RightButton" then
			ChocolateBar:ChatCommand()
		end
	end,
})
moreChocolate.barNames = {none = "None"}

local function GetList()
	wipe(moreChocolate.barNames)
	moreChocolate.barNames.none = L["None"]
	for k,v in pairs(ChocolateBar.chocolateBars) do
		moreChocolate.barNames[k] = k
	end
	return moreChocolate.barNames
end
--[[
function Timer:OnUpdate(elapsed)
	counter = counter + elapsed
	if counter >= delay and bar and not ChocolateBar.dragging then
		bar:Hide()
		counter = 0
		Timer:SetScript("OnUpdate", nil)
	end
end

function moreChocolate:OnEnter()
	counter = 0
	if delay > 0 then
		Timer:SetScript("OnUpdate", Timer.OnUpdate)
	end
	if bar then
		bar:Show()
		--bar:ShowAll()
	end
end

function moreChocolate:SetBar(db)
	bar = ChocolateBar:GetBar(db.moreBar)
	if bar and bar:IsShown() then
		bar:Hide()
	end
	delay = db.moreBarDelay
end
--]]

function moreChocolate:GetOptions()
	local options ={
			name="MoreChocolate",
			type="group",
			order = 9,
			args={
				--[[
				header = {
					order = 1,
					type = "header",
					name =  "MoreChocolate",
				},
				--]]
				moreChocolate = {
					inline = true,
					name="MoreChocolate",
					type="group",
					order = 0,
					args={
						label = {
							order = 2,
							type = "description",
							name = L["A broker plugin to toggle the bar for new chocolate pieces."],
						},
						selectBar = {
							type = 'select',
							values = GetList,
							order = 3,
							name = L["Select Bar"],
							desc = L["Select Bar"],
							get = function() 
								return ChocolateBar.db.profile.moreBar
							end,
							set = function(info, value)
								if bar then
									bar:Show()
								end
								ChocolateBar.db.profile.moreBar = value
								-- moreChocolate:SetBar(ChocolateBar.db.profile)
							end,
						},
						delay = {
							type = 'range',
							order = 4,
							name = L["Delay"],
							desc = L["Set seconds until bar will hide."],
							min = 0,
							max = 15,
							step = 1,
							get = function(name)
								return ChocolateBar.db.profile.moreBarDelay
							end,
							set = function(info, value)
								delay = value
								ChocolateBar.db.profile.moreBarDelay = value
							end,
						},	
					},
				},
			},
		}
	return options
end
