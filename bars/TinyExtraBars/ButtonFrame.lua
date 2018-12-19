--[[ ButtonFrame ]]

TEB_ButtonFrame = {}


function TEB_ButtonFrame_New(id, parent)
	local bf = _G[parent:GetName().."ButtonFrame"..id]
	if not(bf) then
		bf = CreateFrame("Frame", parent:GetName().."ButtonFrame"..id, UIParent, "TinyExtraBarsButtonFrameTemplate")

		local count = TEB_Toggler:GetAttribute("FramesCount")
		if not(count) then
			count = 1
		else
			count = count + 1
		end
		TEB_Toggler:SetAttribute("FramesCount", count)
		TEB_Toggler:SetFrameRef("TEB_ButtonFrame"..count, bf)
	end
	bf.container = parent
	bf:SetID(id)

	-- settings
	bf.title = TinyExtraBarsPC:Get({'Containers', parent:GetID(), 'tabs', id, "title"}, 'Tab'..id)
	bf.visibility = TinyExtraBarsPC:Get({'Containers', parent:GetID(), 'tabs', id, "Visibility"}, nil)
	if not(bf.visibility) then
		bf.visibility = {
			["Talents"] = {
				[1] = true,
				[2] = true,
			},
			["Stance"] = {
				[1] = true,
				[2] = false,
				[3] = false,
				[4] = false,
				[5] = false,
				[6] = false,
				[7] = false,
				[8] = false,
				[9] = false,
			},
			["Vehicle"] = { 
				[1] = false,
				[2] = true,
			},
			["BonusBar"] = {
				[1] = false,
				[2] = true,
			},
			["PetBattle"] = {
				[1] = false,
				[2] = true,
			},
			["Custom"] = "",
		}
	else
		if not(bf.visibility["Talents"]) then
			bf.visibility["Talents"] = {
				[1] = true,
				[2] = true,
			}
		end
		if not(bf.visibility["Stance"]) then
			bf.visibility["Stance"] = {
				[1] = true,
				[2] = false,
				[3] = false,
				[4] = false,
				[5] = false,
				[6] = false,
				[7] = false,
				[8] = false,
				[9] = false,
			}
		end
		if not(bf.visibility["Vehicle"]) then
			bf.visibility["Vehicle"] = {
				[1] = false,
				[2] = true,
			}
		end
		if not(bf.visibility["BonusBar"]) then
			bf.visibility["BonusBar"] = {
				[1] = false,
				[2] = true,
			}
		end
		if not(bf.visibility["PetBattle"]) then
			bf.visibility["PetBattle"] = {
				[1] = false,
				[2] = true,
			}
		end
		if not(bf.visibility["Custom"]) then
			bf.visibility["Custom"] = ""
		end
	end
	
	-- adding methods to frame
	for k, v in pairs(TEB_ButtonFrame) do
		if type(v) == "function" then
			bf[k] = v
		end
	end
	
	bf.ButtonList = {}
	
	bf:SetAttribute("_onstate-combat", [[self:ChildUpdate('combat', newstate)]])
	--RegisterStateDriver(bf, "combat", "[nocombat] 0; [combat] 1;")

	bf:SetCustomAlpha()	
	bf:UpdateVisibilityDriver()	
	bf:RegisterEvents()	
	bf:EnableMouse(not(bf.container.clickthrough))
	
	return bf
end

function TEB_ButtonFrame:SaveVisibilityDriver()
	TinyExtraBarsPC:Set({'Containers', self.container:GetID(), 'tabs', self:GetID(), "Visibility"}, self.visibility)
end

function TEB_ButtonFrame:UpdateVisibilityDriver()
	if TEB_SettingsMode then
		self:DisableVisibilityDriver()
		return
	end

	self:SaveVisibilityDriver()
	
	local text = ""
	--if (TEB_SettingsMode) then
	--	text = text.."[nocombat] show; "
	--end
	if not(self.visibility["Talents"][1]) then
		text = text.."[spec:1] hide; "
	end
	if not(self.visibility["Talents"][2]) then
		text = text.."[spec:2] hide; "
	end
	if (self.visibility["Vehicle"][2]) then
		text = text.."[vehicleui] hide; "
	end
	if (self.visibility["BonusBar"][2]) then
		text = text.."[overridebar] hide; "
	end
	if (self.visibility["PetBattle"][2]) then
		text = text.."[petbattle] hide; "
	end
	if not(self.visibility["Stance"][1]) then
		local temp = ""
		for i = 2, #self.visibility["Stance"] do
			if not(self.visibility["Stance"][i]) then
				temp = temp..(i - 2).."/"
			end
		end
		if temp:len() > 0 then
			temp = temp:sub(1, temp:len() - 1)
			text = text.."[stance:"..temp.."] hide; "
		end
	end
	
	--print(text)
	local customText = self.visibility["Custom"]
	if (customText ~= "") then
		RegisterStateDriver(self, "visibility", text..customText)
		self:SetAttribute("StateDriverString", text..customText)
	else
		if (text ~= "") then
			RegisterStateDriver(self, "visibility", text.."show")
			self:SetAttribute("StateDriverString", text.."show")
		else
			UnregisterStateDriver(self, "visibility")
			self:SetAttribute("StateDriverString", "")
		end
	end
end

function TEB_ButtonFrame:DisableVisibilityDriver()
	UnregisterStateDriver(self, "visibility")
end

function TEB_ButtonFrame:SetAnchor(parent)
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
end

function TEB_ButtonFrame:SetSize(rows, cols)
	local width = TinyExtraBars_GetButtonsTotalSize(cols)
	local height = TinyExtraBars_GetButtonsTotalSize(rows)
	
	self:SetWidth(width)
	self:SetHeight(height)
end

function TEB_ButtonFrame:SetCustomAlpha()
	local value
	if TEB_SettingsMode then
		value = 1.0
	else
		value = self.container.alpha
	end
	self:SetAlpha(value)
end
function TEB_ButtonFrame:ResetCustomAlpha()
	self:SetAlpha(1.0)
end

function TEB_ButtonFrame:SetButtons(rows, cols)
	for r = 1, rows do
		for c = 1, cols do
			local btn = TEB_Button_AttachToFrame(self, r, c)
			local v = TinyExtraBarsPC:Get({'Containers', self.container:GetID(), 'tabs', self:GetID(), r, c}, nil)
			local keybind = TinyExtraBarsPC:Get({'Containers', self.container:GetID(), r, c, "keybind"}, nil)
			if (v) and (TEB_ACCEPTABLE_COMMANDS[v.command]) then
				if (v.command == "spell") then
					if not(v.value) then
						print(tostring(v.command).." "..tostring(v.subValue).." removed")
						btn:SaveCommand(nil, nil, nil, nil)
						btn:Set(nil, nil, nil, nil)
					else
						if not(v.id) then
							--fix broken spells
							--v.id = TinyExtraBars_FindSpellId(v.value)
							local _
							_, _, v.id = TinyExtraBars_FindSpellSlotGenIdByRealName(v.value)
							print(tostring(v.value).." fixed id = "..tostring(v.id))
						end
						btn:Set(v.command, v.value, v.subValue, v.id, v.macroValues)
					end
				elseif (v.command == "macrotext") then
					if not(v.value) then
						--print(tostring(v.command).." "..tostring(v.subValue).." removed")
						btn:SaveCommand(nil, nil, nil, nil)
						btn:Set(nil, nil, nil, nil)
					else
						local t = v.macroValues
						if t and type(t) == "table" then								
							btn:Set(v.command, v.value, v.subValue, v.id, v.macroValues)
						else
							--fix changes sinc 0.53
							t = {}
							t.texture = v.customIcon
							v.customIcon = nil
							t.value = v.subValue -- spell name or item hint
							v.subValue = "spell"
							t.id = TinyExtraBars_FindSpellId(t.value)
							btn:SaveCommand(v.command, v.value, v.subValue, v.id, t)
							btn:Set(v.command, v.value, v.subValue, v.id, t)
						end
					end
				else
					if not(v.value) then
						print(tostring(v.command).." "..tostring(v.subValue).." removed")
						btn:SaveCommand(nil, nil, nil, nil)
						btn:Set(nil, nil, nil, nil)
					else
						btn:Set(v.command, v.value, v.subValue, v.id, v.macroValues)
					end
				end
			else
				btn:Set(nil, nil, nil, nil)
			end
			if TEB_SettingsMode or btn.command then
				btn:Show()
			else
				btn:Hide()
			end
		end
	end
end

function TEB_ButtonFrame:SetButtonsCount(rows, cols)
	self:SetSize(rows, cols)
	
	-- hide unused buttons
	
	for r = 1, self.container.maxRows do
		for c = 1, self.container.maxCols do
			if r > rows or c > cols then
				local btn = self.ButtonList[r][c]
				if btn then
					--print("hiding "..r.." "..c)
					btn:HideButton()
				end
			end
		end
	end
end

function TEB_ButtonFrame:OnShow()
	--if ShowBorders then
	--	self:SetBackdrop({edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 8, edgeSize = 8, insets = { left = 4, right = 4, top = 4, bottom = 4 }})
	--else
	--	self:SetBackdrop({edgeFile = ""})
	--end
end

function TEB_ButtonFrame:OnHide()
end

local function EventShowGrid(self, ...)
	if not(InCombatLockdown()) and TEB_SettingsMode then
		self:SetFrameStrata("DIALOG")
	end
end

local function EventHideGrid(self, ...)
	if not(InCombatLockdown()) then
		self:SetFrameStrata(self.container.strata)
	end
end

function TEB_ButtonFrame:OnEvent(event, ...)
	if self.EventHandlersTable[event] then
		self.EventHandlersTable[event](self, ...)
	end
end

function TEB_ButtonFrame:RegisterEvents()
	--event table
	self.EventHandlersTable = {
		["ACTIONBAR_SHOWGRID"] 			= EventShowGrid,
		["ACTIONBAR_HIDEGRID"] 			= EventHideGrid,
	}
	self:RegisterEvent("ACTIONBAR_SHOWGRID")
	self:RegisterEvent("ACTIONBAR_HIDEGRID")
	
	self:SetScript("OnEvent", TEB_ButtonFrame.OnEvent)	
end

function TEB_ButtonFrame:UnregisterEvents()
	if self.EventHandlersTable then
		for k, _ in pairs(self.EventHandlersTable) do
			self:UnregisterEvent(k)
		end
	end
	self.EventHandlersTable = {}
end
