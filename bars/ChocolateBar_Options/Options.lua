local LibStub = LibStub
local AceCfgDlg = LibStub("AceConfigDialog-3.0")
local broker = LibStub("LibDataBroker-1.1")
local LSM = LibStub("LibSharedMedia-3.0")

local APPNAME = "ChocolateBar"
local ChocolateBar = LibStub("AceAddon-3.0"):GetAddon(APPNAME)
local L = LibStub("AceLocale-3.0"):GetLocale(APPNAME)
local version = GetAddOnMetadata(APPNAME,"X-Curse-Packaged-Version") or ""

local Debug = ChocolateBar.Debug
local Drag = ChocolateBar.Drag
local _G, pairs, string = _G, pairs, string
local db, moreChocolate
local index = 0
local Options = ChocolateBar.Options or {}
ChocolateBar.Options = Options

local DEFAULT_ICON_TEX = "Interface\\AddOns\\ChocolateBar\\pics\\ChocolatePiece"



local function GetStats(info)
	local total = 0
	local enabled = 0
	local data = 0
	for name, obj in broker:DataObjectIterator() do
		local t = obj.type
		if t == "data source" or t == "launcher" then
			total = total + 1
			if t == "data source" then
				data = data + 1
			end
			local settings = rawget(db.objSettings, name)
			if settings and settings.enabled then
				enabled = enabled +1
			end
		end
	end

	return _G.strjoin("\n","|cffffd200"..L["Enabled"].."|r  "..enabled,
						"|cffffd200"..L["Disabled"].."|r  "..total-enabled,
						"|cffffd200"..L["Total"].."|r  "..total,
						"",
						"|cffffd200"..L["Data Source"].."|r  "..data,
						"|cffffd200"..L["Launcher"].."|r  "..total-data
	)
end



local function EnableAll(info)
	for name, obj in LibStub("LibDataBroker-1.1"):DataObjectIterator() do
		ChocolateBar:EnableDataObject(name, obj)
	end
end

local function DisableAll(info)
	for name, obj in LibStub("LibDataBroker-1.1"):DataObjectIterator() do
		ChocolateBar:DisableDataObject(name)
	end
end

local function DisableLauncher(info)
	for name, obj in LibStub("LibDataBroker-1.1"):DataObjectIterator() do
		if obj.type ~= "data source" then
			ChocolateBar:DisableDataObject(name)
		end
	end
end

local function DeleteAllMissing(info)
	for name, obj in LibStub("LibDataBroker-1.1"):DataObjectIterator() do
		ChocolateBar:DisableDataObject(name)
	end
end




-- Options.NewBarName = nil

local aceoptions = {
	name = APPNAME.." "..version,
	handler = ChocolateBar,
	type='group',
	desc = APPNAME,
		args = {
		general={
			name = L["Look and Feel"],
			type="group",
			order = 0,

			args={
				general = {
					inline = true,
					name = L["General"],
					type="group",
					order = 3,
					args={
						editMode = {
							type = 'toggle',
							order = 1,
							name = L["Movable Plugins"],
							desc = L["Hold alt key to drag a plugin if disabled."],
							get = function(info, value)
									return db.editMode
							end,
							set = function(info, value)
									-- db.editMode = value
									ChocolateBar:ToggleEditMode(value)
							end,
						},
						gap = {
							type = 'range',
							order = 2,
							name = L["Gap"],
							desc = L["Set the gap between the plugins."],
							min = 0,
							max = 50,
							step = 1,
							get = function(name)
								return db.gap
							end,
							set = function(info, value)
								db.gap = value
								ChocolateBar.ChocolatePiece:UpdateGap(value)
								ChocolateBar:UpdateChoclates("updateSettings")
							end,
						},
						textOffset = {
							type = 'range',
							order = 2,
							name = L["Text Offset"],
							desc = L["Set the distance between the icon and the text."],
							min = -5,
							max = 15,
							step = 1,
							get = function(name)
								return db.textOffset
							end,
							set = function(info, value)
								db.textOffset = value
								--ChocolateBar.ChocolatePiece:UpdateGap(value)
								ChocolateBar:UpdateChoclates("updateSettings")
							end,
						},
						size = {
							type = 'range',
							order = 3,
							name = L["Bar Size"],
							desc = L["Bar Size"],
							min = 12,
							max = 30,
							step = 1,
							get = function(name)
								return db.height
							end,
							set = function(info, value)
								db.height = value
								ChocolateBar:UpdateBarOptions("UpdateHeight")
							end,
						},
						iconSize = {
							type = 'range',
							order = 3,
							name = L["Icon Size"],
							desc = L["Icon size in relation to the bar height."],
							min = 0,
							max = 1,
							step = 0.001,
							bigStep = 0.05,
							isPercent = true,
							get = function(name)
								return db.iconSize
							end,
							set = function(info, value)
								if value > 1 then
									value = 1
								elseif value < 0.01 then
									value = 0.001
								end
								db.iconSize = value
								ChocolateBar:UpdateBarOptions("UpdateHeight")
							end,
						},
						strata = {
							type = 'select',
							values = {FULLSCREEN_DIALOG="Fullscreen_Dialog",FULLSCREEN="Fullscreen",
										DIALOG="Dialog",HIGH="High",MEDIUM="Medium",LOW="Low",BACKGROUND="Background"},
							order = 6,
							name = L["Bar Strata"],
							desc = L["Bar Strata"],
							get = function()
								return db.strata
							end,
							set = function(info, value)
								db.strata = value
								ChocolateBar:UpdateBarOptions("UpdateStrata")
							end,
						},
						moveFrames = {
							type = 'toggle',
							--width = "double",
							order = 7,
							name = L["Adjust Blizzard Frames"],
							desc = L["Move Blizzard frames above/below bars"],
							get = function(info, value)
									return db.moveFrames
							end,
							set = function(info, value)
									db.moveFrames = value
									ChocolateBar:UpdateBarOptions("UpdateAutoHide")
							end,
						},
						barRightClick = {
							type = 'select',
							values = {NONE=L["none"],OPTIONS=L["ChocolateBar Options"],
										BLIZZ=L["Blizzard Options"]},
							order = 8,
							name = L["Bar Right Click"],
							desc = L["Select the action when right clicking on a bar."],
							get = function()
								return db.barRightClick
							end,
							set = function(info, value)
								db.barRightClick = value
							end,
						},
						adjustCenter = {
							type = 'toggle',
							width = "double",
							order = 9,
							name = L["Update Center Position"],
							desc = L["Always adjust the center group based on the current width of the plugins. Disable this to align the center group based only on the number of plugins."],
							get = function(info, value)
									return db.adjustCenter
							end,
							set = function(info, value)
									db.adjustCenter = value
									ChocolateBar:UpdateBarOptions("UpdateBar")
							end,
						},
						hideBarsPetBattle = {
							type = 'toggle',
							order = 10,
							name = L["Hide Bars in Pet Battle"],
							desc = L["Hide Bars during a Pet Battle."],
							get = function(info, value)
									return db.petBattleHideBars
							end,
							set = function(info, value)
									db.petBattleHideBars = value
							end,
						},
					},
				},
				defaults = {
					inline = true,
					name= L["Defaults"],
					type="group",
					order = 4,
					args={
						label = {
							order = 0,
							type = "description",
							name = L["Automatically disable new plugins of type:"],
						},
						dataobjects = {
							type = 'toggle',
							order = 1,
							name = L["Data Source"],
							desc = L["If enabled new plugins of type data source will automatically be disabled."],
							get = function()
									return db.autodissource
							end,
							set = function(info, value)
									db.autodissource = value
							end,
						},
						launchers = {
							type = 'toggle',
							order = 2,
							name = L["Launcher"],
							desc = L["If enabled new plugins of type launcher will automatically be disabled."],
							get = function()
									return db.autodislauncher
							end,
							set = function(info, value)
									db.autodislauncher = value
							end,
						},
					},
				},
				combat = {
					--inline = true,
					name= L["In Combat"],
					type="group",
					order = 0,
					args={
						combat = {
							inline = true,
							name= L["In Combat"],
							type="group",
							order = 0,
							args={
								hidetooltip = {
									type = 'toggle',
									order = 1,
									name = L["Disable Tooltips"],
									desc = L["Disable Tooltips"],
									get = function(info, value)
											return db.combathidetip
									end,
									set = function(info, value)
											db.combathidetip = value
									end,
								},
								hidebars = {
									type = 'toggle',
									order = 2,
									name = L["Hide Bars"],
									desc = L["Hide Bars"],
									get = function(info, value)
											return db.combathidebar
									end,
									set = function(info, value)
											db.combathidebar = value
									end,
								},
								disablebar = {
									type = 'toggle',
									order = 2,
									name = L["Disable Clicking"],
									desc = L["Disable Clicking"],
									get = function(info, value)
											return db.combatdisbar
									end,
									set = function(info, value)
											db.combatdisbar = value
									end,
								},
								disableoptons = {
									type = 'toggle',
									order = 2,
									name = L["Disable Options"],
									desc = L["Disable options dialog on right click"],
									get = function(info, value)
											return db.disableoptons
									end,
									set = function(info, value)
											db.disableoptons = value
									end,
								},
								combatopacity = {
									type = 'range',
									order = 3,
									name = L["Opacity"],
									desc = L["Set the opacity of the bars during combat."],
									min = 0,
									max = 1,
									step = 0.001,
									bigStep = 0.05,
									isPercent = true,
									get = function(name)
										return db.combatopacity
									end,
									set = function(info, value)
										if value > 1 then
											value = 1
										elseif value < 0.01 then
											value = 0.001
										end
										db.combatopacity = value
										--ChocolateBar:UpdateBarOptions("UpdateOpacity")
										for name,bar in pairs(ChocolateBar.chocolateBars) do
											bar.tempHide = bar:GetAlpha()
											bar:SetAlpha(db.combatopacity)
										end
									end,
								},
							},
						},
					},
				},
				background = {
					--inline = true,
					name = L["Fonts and Textures"],
					type = "group",
					order = 4,
					args ={
						backbround = {
							inline = true,
							name = L["Textures"],
							type = "group",
							order = 2,
							args ={
								textureStatusbar = {
									type = 'select',
									dialogControl = 'LSM30_Statusbar',
									values = AceGUIWidgetLSMlists.statusbar,
									order = 1,
									name = L["Background Texture"],
									desc = L["Some of the textures may depend on other addons."],
									get = function()
										return db.background.textureName
									end,
									set = function(info, value)
										db.background.texture = LSM:Fetch("statusbar", value)
										db.background.textureName = value
										db.background.tile = false
										ChocolateBar:UpdateBarOptions("UpdateTexture")
									end,
								},
								colour = {
									type = "color",
									order = 5,
									name = L["Texture Color/Alpha"],
									desc = L["Texture Color/Alpha"],
									hasAlpha = true,
									get = function(info)
										local t = db.background.color
										return t.r, t.g, t.b, t.a
									end,
									set = function(info, r, g, b, a)
										local t = db.background.color
										t.r, t.g, t.b, t.a = r, g, b, a
										ChocolateBar:UpdateBarOptions("UpdateColors")
									end,
								},
								bordercolour = {
									type = "color",
									order = 6,
									name = L["Border Color/Alpha"],
									desc = L["Border Color/Alpha"],
									hasAlpha = true,
									get = function(info)
										local t = db.background.borderColor
										return t.r, t.g, t.b, t.a
									end,
									set = function(info, r, g, b, a)
										local t = db.background.borderColor
										t.r, t.g, t.b, t.a = r, g, b, a
										ChocolateBar:UpdateBarOptions("UpdateColors")
									end,
								},
							},
						},
						background1 = {
							inline = true,
							name = L["Advanced Textures"],
							type = "group",
							order = 3,
							args ={
								textureBackground = {
									type = 'select',
									dialogControl = 'LSM30_Background',
									values = AceGUIWidgetLSMlists.background,
									order = 2,
									name = L["Background Texture"],
									desc = L["Some of the textures may depend on other addons."],
									get = function()
										return db.background.textureName
									end,
									set = function(info, value)
										db.background.texture = LSM:Fetch("background", value)
										db.background.textureName = value
										db.background.tile = true
										local t = db.background.color
										t.r, t.g, t.b, t.a = 1, 1, 1, 1
										ChocolateBar:UpdateBarOptions("UpdateTexture")
									end,
								},
								textureTile = {
									type = 'toggle',
									order = 3,
									name = L["Tile"],
									desc = L["Tile the Texture. Disable to stretch the Texture."],
									get = function()
											return db.background.tile
									end,
									set = function(info, value)
											db.background.tile = value
											ChocolateBar:UpdateBarOptions("UpdateTexture")
									end,
								},
								textureTileSize = {
									type = 'range',
									order = 4,
									name = L["Tile Size"],
									desc = L["Adjust the size of the tiles."],
									min = 1,
									max = 256,
									step = 1,
									bigStep = 5,
									isPercent = false,
									get = function(name)
										return db.background.tileSize
									end,
									set = function(info, value)
										if value > 256 then
											value = 256
										elseif value < 1 then
											value = 1
										end
										db.background.tileSize = value
										ChocolateBar:UpdateBarOptions("UpdateTexture")
									end,
								},
							},
						},
						fonts = {
							inline = true,
							name = L["Font"],
							type = "group",
							order = 1,
							args ={
								font = {
								type = 'select',
								dialogControl = 'LSM30_Font',
								values = AceGUIWidgetLSMlists.font,
								order = 1,
								name = L["Font"],
								desc = L["Some of the fonts may depend on other addons."],
								get = function()
									return db.fontName
								end,
								set = function(info, value)
									db.fontPath = LSM:Fetch("font", value)
									db.fontName = value
									ChocolateBar:UpdateChoclates("updatefont")
								end,
								},
								fontSize = {
									type = 'range',
									order = 2,
									name = L["Font Size"],
									desc = L["Font Size"],
									min = 8,
									max = 20,
									step = .5,
									get = function(name)
										return db.fontSize
									end,
									set = function(info, value)
										db.fontSize = value
										ChocolateBar:UpdateChoclates("updatefont")
									end,
								},
								textcolour = {
									type = "color",
									order = 3,
									name = L["Text color"],
									desc = L["Default text color of a plugin. This will not overwrite plugins that use own colors."],
									hasAlpha = true,
									get = function(info)
										local t = db.textColor or {r = 1, g = 1, b = 1, a = 1}
										return t.r, t.g, t.b, t.a
									end,
									set = function(info, r, g, b, a)
										db.textColor = db.textColor or {r = 1, g = 1, b = 1, a = 1}
										local t = db.textColor
										t.r, t.g, t.b, t.a = r, g, b, a
										ChocolateBar:UpdateChoclates("updateSettings")
									end,
								},
								iconcolour = {
									type = "toggle",
									order = 4,
									name = L["Desaturated Icons"],
									desc = L["Show icons in gray scale mode (This will not affect icons embedded in the text of a plugin)."],
									get = function(info)
										return db.desaturated
									end,
									set = function(info, value)
										db.desaturated = value
										for name, obj in broker:DataObjectIterator() do
											if db.objSettings[name] then
												if db.objSettings[name].enabled then
													local choco = ChocolateBar:GetChocolate(name)
													if choco and choco.icon then
														choco:Update(choco, "iconR", nil)
													end
												end
											end
										end
									end,
								},
								forceColor = {
									type = 'toggle',
									width = "double",
									order = 9,
									name = L["Force Text Color"],
									desc = L["Remove custom colors from plugins."],
									get = function(info, value)
										return db.forceColor
									end,
									set = function(info, value)
										db.forceColor = value
										for name, obj in broker:DataObjectIterator() do
											if db.objSettings[name] then
												if db.objSettings[name].enabled then
													local choco = ChocolateBar:GetChocolate(name)
													if choco then
														choco:Update(choco, "text", obj.text)
													end
												end
											end
										end
									end,
								},
							},
						},
					},
				},
				--[===[@debug@
				debug = {
					type = 'toggle',
					--width = "half",
					order = 20,
					name = "Debug",
					desc = "This one is for me, not for you :P",
					get = function(info, value)
							return ChocolateBar.db.char.debug
					end,
					set = function(info, value)
							ChocolateBar.db.char.debug = value
					end,
				},
				--@end-debug@]===]
			},
		},
		bars={
			name = L["Bars"],
			type ="group",
			order = 20,
			args ={
				barName = {
					type = 'input',
					order = 0,
					name = L["Bar name"],
					desc = L["Name of your bar becomes a global frame name if you include 'Choco'!"],
					set = function(info, value)
						Options.NewBarName = value
					end,
				},
				new = {
					type = 'execute',
					--width = "half",
					order = 1,
					name = L["Create Bar"],
					desc = L["Create a new Bar"],
					func = function()
						local name = ChocolateBar:CreateBar(Options.NewBarName)
						ChocolateBar:AddBarOptions(name)
					end,
				},
			},
		},
		chocolates={
			name = L["Plugins"],
			type="group",
			order = 30,
			args={
				stats = {
					inline = true,
					name = L["Plugin Statistics"],
					type="group",
					order = 1,
					args={
						stats = {
							order = 1,
							type = "description",
							name = GetStats,
						},
					},
				},
				quickconfig = {
					inline = true,
					name = L["Quick Config"],
					type = "group",
					order = 2,
					args ={
						enableAll = {
							type = 'execute',
							order = 3,
							name = L["Enable All"],
							desc = L["Get back my plugins!"],
							func = EnableAll,
						},
						disableAll = {
							type = 'execute',
							order = 4,
							name = L["Disable All"],
							desc = L["Eat all the chocolate at once, uff..."],
							func = DisableAll,
						},
						disableLauncher = {
							type = 'execute',
							order = 5,
							name = L["Disable all Launchers"],
							desc = L["Disable all the bad guy's:)"],
							func = DisableLauncher,
						},
					},
				},
			},
		},
		missingChocolate={
			name = L["Missing Plugins"],
			type="group",
			order = 40,
			disable = true,
			args={
				quickconfig = {
					inline = true,
					name = L["Quick Config"],
					type = "group",
					order = 2,
					args ={
						enableAll = {
							type = 'execute',
							order = 3,
							name = L["Delete All"],
							desc = L["Forget missing addons"],
							func = DeleteAllMissing,
						},
					},
				},
			},
		},
	},
}
local barOptions = aceoptions.args.bars.args
local chocolateOptions = aceoptions.args.chocolates.args
local missingChocolate = aceoptions.args.missingChocolate.args
Options.barOptions = barOptions
Options.chocolateOptions = chocolateOptions
Options.missingChocolate = missingChocolate




-----
-- bar option functions
-----

-- return the number of bars aligend to align (top or bottom)
function ChocolateBar:GetNumBars(align)
	local i = 0
	for k,v in pairs(ChocolateBar.chocolateBars) do
		if v.settings.align == align then
			i = i + 1
		end
	end
	return i
end

local function GetBarLabel(info)
	local name = info[#info-2]
	local settings = db.barSettings[name]
	if settings.align then
		name = name.." ("..settings.align..") "
	end
	return name
end

local function ChangeBarName(info)
	local name = info[#info]
	local newName = Options.ChangeBarName

	ChocolateBar.chocolateBars[newName] = ChocolateBar.chocolateBars[name]
	ChocolateBar.chocolateBars[name] = nil
	db.barSettings[newName] = db.barSettings[name]
	db.barSettings[name] = nil
	barOptions[newName] = barOptions[name]
	barOptions[name] = nil

	Options.ChangeBarName = nil
	-- LibStub("AceConfigRegistry-3.0"):NotifyChange(APPNAME)
	return name
end

local function GetBarIndex(info)
	local name = info[#info]
	local settings = db.barSettings[name]
	local index = settings.index
	if settings.align == "bottom" then
		--reverse order and force below top bars
		index = index *-1 + 100
	end
	return index
end

local function SetBarAlign(info, value)
	local name = info[#info-2]
	if value then
		db.barSettings[name].align = value
		local bar = ChocolateBar:GetBar(name)
		if bar then
			bar:UpdateAutoHide(db)
			ChocolateBar:AnchorBars()
		end
	end
end

local function GetBarAlign(info, value)
	local name = info[#info-2]
	return db.barSettings[name].align
end

local function EatBar(info, value)
	local name = info[#info-2]
	ChocolateBar:RemoveBar(name)
end

local function MoveUp(info, value)
	local name = info[#info-2]
	local settings = db.barSettings[name]
	local index = settings.index
	do
		if settings.align == "bottom" then
			index = index +1.5
			if index > (ChocolateBar:GetNumBars("bottom")+1) then
				index = ChocolateBar:GetNumBars("top")+1
				SetBarAlign(info, "top")
			end
		elseif settings.align == "top" then
			index = index -1.5
		else
			settings.align = "top"
			index = 0
			SetBarAlign(info, "top")
		end
		settings.index = index
		ChocolateBar:AnchorBars()
	end
end

local function MoveDown(info, value)
	local name = info[#info-2]
	local settings = db.barSettings[name]
	local index = settings.index
	if bar then
		if settings.align == "bottom" then
			index = index -1.5
		elseif settings.align == "top" then
			index = index +1.5
			if index > (ChocolateBar:GetNumBars("top")+1) then
				index = ChocolateBar:GetNumBars("bottom")+1
				SetBarAlign(info, "bottom")
			end
		else
			settings.align = "top"
			index = 0
			SetBarAlign(info, "top")
		end
		settings.index = index
		ChocolateBar:AnchorBars()
	end
end

local function getAutoHide(info, value)
	local name = info[#info-2]
	return db.barSettings[name].autohide
end

local function setAutoHide(info, value)
	local name = info[#info-2]
	db.barSettings[name].autohide = value
	local bar = ChocolateBar:GetBar(name)
	if bar then  bar:UpdateAutoHide(db)  end
	--ChocolateBar:UpdateBarOptions("UpdateAutoHide")
end

--hide bar during combat
local function gethideBarInCombat(info, value)
	local name = info[#info-2]
	return db.barSettings[name].hideBarInCombat
end

local function sethideBarInCombat(info, value)
	local name = info[#info-2]
	db.barSettings[name].hideBarInCombat = value
end

local function GetBarWidth(info)
	--Debug(GetScreenWidth(),UIParent:GetEffectiveScale(),UIParent:GetWidth(),math.floor(GetScreenWidth()))
	local name = info[#info-2]
	local maxBarWidth = _G.math.floor(_G.GetScreenWidth())

	return db.barSettings[name].width
end

local function SetBarWidth(info, value)
	--Debug("SetBarWidht", value)
	local name = info[#info-2]
	local settings = db.barSettings[name]
	settings.width = value
	local bar = ChocolateBar:GetBar(name)
	if not bar then  return  end

	if value > _G.GetScreenWidth() or value == 0 then
		bar:SetPoint("RIGHT", "UIParent" ,"RIGHT",0, 0);
	else
		local relative, relativePoint
		settings.barPoint ,relative ,relativePoint,settings.barOffx ,settings.barOffy = bar:GetPoint()
		if settings.barOffy == 0 then settings.barOffy = 1 end
		bar:ClearAllPoints()
		bar:SetPoint(settings.barPoint, "UIParent",settings.barOffx,settings.barOffy)
		bar:SetWidth(value)
	end
end

local moveBarDummy
local function OnDragStart(self)
	self:StartMoving()
	self.isMoving = true
end

local function OnDragStop(self)
	self:StopMovingOrSizing()
	self.isMoving = false
end

local function SetLockedBar(info, value)
	--Debug("SetLockedBar", value)
	local name = info[#info-2]
	local bar = ChocolateBar:GetBar(name)
	if not bar then  return  end

	local settings = db.barSettings[name]
	bar.locked = value
	if not value then
		--unlock
		if not moveBarDummy then
			moveBarDummy = _G.CreateFrame("Frame",bar)
			moveBarDummy:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
												nil,
												tile = true, tileSize = 16, edgeSize = 16,
												nil});
			moveBarDummy:SetBackdropColor(1,0,0,1);
			moveBarDummy:RegisterForDrag("LeftButton")
			moveBarDummy:SetFrameStrata("FULLSCREEN_DIALOG")
			moveBarDummy:SetFrameLevel(10)
			moveBarDummy:SetScript("OnMouseUp", function(self, btn)
				if btn == "RightButton" then
					ChocolateBar:ChatCommand()
				end
			end)
		end
		moveBarDummy.bar = bar
		moveBarDummy:SetAllPoints(bar)
		moveBarDummy:Show()

		bar:RegisterForDrag("LeftButton")
		bar:EnableMouse(true)
		bar:SetFrameStrata("FULLSCREEN_DIALOG")
		bar:SetFrameLevel(20)
		bar:SetMovable(true)
		bar:SetScript("OnDragStart",OnDragStart)
		bar:SetScript("OnDragStop",OnDragStop)
		bar:SetClampedToScreen(true)
		for k, v in pairs(bar.chocolist) do
			v:Hide()
		end
	else
		bar:SetClampedToScreen(false)
		for k, v in pairs(bar.chocolist) do
			v:Show()
		end
		bar:SetScript("OnDragStart", nil)
		local relative, relativePoint
		settings.barPoint, relative, relativePoint, settings.barOffx ,settings.barOffy = bar:GetPoint()
		--Debug("bar:GetPoint()",settings.barPoint ,relative ,relativePoint,settings.barOffx ,settings.barOffy)
		if settings.barOffy == 0 then settings.barOffy = 1 end
		bar:SetPoint(settings.barPoint, "UIParent",settings.barOffx,settings.barOffy)
		settings.align = "custom"
		settings.width = bar:GetWidth()
		bar:SetFrameStrata(db.strata)
		bar:SetFrameLevel(1)
		if moveBarDummy then moveBarDummy:Hide() end
	end
end

local function GetFreeBar(info)
	local name = info[#info-2]
	--Debug("GetManageBar", db.barSettings[name].align)
	return db.barSettings[name].align == "custom"
end

local function SetFreeBar(info, value)
	local name = info[#info-2]
	--db.barSettings[name].align = value and "custom" or "top"
	--Debug("SetFreeBar", db.barSettings[name].align,value,name)
	db.barSettings[name].align =  value  and  "custom"  or  "top"
	local bar = ChocolateBar:GetBar(name)
	if not bar then  return  end

	if not value then
		SetLockedBar(info, true)
		bar:SetPoint("RIGHT", "UIParent" ,"RIGHT",0, 0);
		ChocolateBar:AnchorBars()
	end
	bar:UpdateJostle(db)
	--Debug("SetFreeBar", db.barSettings[name].align,value,name)
end

local function GetBarOffX(info, value)
	--Debug(info[#info-1],info[#info-2],info[#info-3],info[#info])
	local name = info[#info-2]
	--return db.barSettings[name].barOffx
	return db.barSettings[name].fineX
end

local function GetBarOffY(info, value)
	local name = info[#info-2]
	--return db.barSettings[name].barOffy
	return db.barSettings[name].fineY
end

local function SetBarOff(info, value)
	local name = info[#info-2]
	local offtype = info[#info]
	local settings = db.barSettings[name]
	local relative, relativePoint
	settings.barPoint ,relative ,relativePoint,settings.barOffx ,settings.barOffy = bar:GetPoint()
	if offtype == "xoff" then
		settings.fineX = value
	else
		settings.fineY = value
	end

	local bar = ChocolateBar:GetBar(name)
	if not bar then  return  end
	bar:ClearAllPoints()
	bar:SetPoint(settings.barPoint, "UIParent",settings.barOffx + settings.fineX ,settings.barOffy + settings.fineY)
end

local function GetLockedBar(info, value)
	local name = info[#info-2]
	local bar = ChocolateBar:GetBar(name)
	return  not bar or  bar.locked
end



-------------
-- bar options disabled/enabled
--------------------
local function IsDisabledFreeMove(info)
	local name = info[#info-2]
	local settings = db.barSettings[name]
	Debug("IsDisabledFreeMove", not (settings.align == "custom"),settings.align,name)
	return not (settings.align == "custom")
end

--[[
--return true if RemoveBar is disabled
local function IsDisabledRemoveBar(info)
	local name = info[#info-2]
	return name == db.moreBar
end
--]]

local function IsDisabledMoveDown(info)
	local name = info[#info-2]
	local settings = db.barSettings[name]
	return settings.align == "custom" or (settings.align == "bottom" and  settings.index < 1.5)
end

local function IsDisabledMoveUp(info)
	local name = info[#info-2]
	local settings = db.barSettings[name]
	return settings.align == "custom" or (settings.align == "top" and  settings.index < 1.5)
end




-----
-- chocolate option functions
-----
local  function GetCleanName(label)
	local cleanName
	cleanName = string.gsub(label, "\|c........", "")
	cleanName = string.gsub(cleanName, "\|r", "")
	cleanName = string.gsub(cleanName, "[%c \127]", "")
	return cleanName
end

local function GetFormattedName(info)
	-- local cleanName = info[#info]
	-- local name = chocolateOptions[cleanName].desc
	local name = info[#info]
	local dataobj = info.option.arg
	local cleanName = info.option.cleanName    --  or GetCleanName(dataobj.label or name)
	--local icon = chocolateOptions[cleanName].icon
	--local dataobj = broker:GetDataObjectByName(name)
	if(not db.objSettings[name].enabled)then
		-- disabled
		--cleanName = "|TZZ"..cleanName.."|t|T"..icon..":18|t |cFFFF0000"..cleanName.."|r"
		cleanName = "|H"..cleanName.."|h|cFFFF0000"..cleanName.."|r"
	elseif dataobj and dataobj.type == "data source" then
		--enabled data source
		cleanName = "|H"..cleanName.."|h"..cleanName
	else
		--enabled launcher
		cleanName = "|H"..cleanName.."|h|cFFBBBBBB"..cleanName.."|r"
	end
	return cleanName
end
--[[
local function GetType(info)
	local cleanName = info[#info-2]
	local name = chocolateOptions[cleanName].desc
	return (broker:GetDataObjectByName(name).type == "data source" and L["Type"]..": "..L["Data Source"].."\n") or L["Type"]..": "..L["Launcher"].."\n"
end
--]]
local function GetTypeText(objtype)
	return objtype == "data source"  and  L["Type"]..": "..L["Data Source"].."\n"
		or  L["Type"]..": "..L["Launcher"].."\n"
end

local function GetAlignment(info)
	-- local cleanName = info[#info-2]
	-- local name = chocolateOptions[cleanName].desc
	local name = info[#info-2]
	return db.objSettings[name].align
end

local function SetAlignment(info, value)
	local name = info[#info-2]
	local settings = db.objSettings[name]
	settings.align = value
	settings.index = 500
	local choco = ChocolateBar:GetChocolate(name)
	if choco and choco.bar then
		choco.bar:UpdateBar(true)
		--choco.bar:UpdateBar()
	end
end

local function SetEnabled(info, value)
	local name = info[#info-2]
	if value then
		ChocolateBar:EnableDataObject(name)
	else
		ChocolateBar:DisableDataObject(name)
	end
end

local function GetEnabled(info, value)
	local name = info[#info-2]
	return db.objSettings[name].enabled
end

local function GetIcon(info, value)
	local name = info[#info-2]
	return db.objSettings[name].showIcon
end

local function SetIcon(info, value)
	local name = info[#info-2]
	db.objSettings[name].showIcon = value
	ChocolateBar:AttributeChanged(nil, name, "updateSettings", value)
end

local function GetText(info, value)
	local name = info[#info-2]
	return db.objSettings[name].showText
end

local function SetText(info, value)
	local name = info[#info-2]
	db.objSettings[name].showText = value
	ChocolateBar:AttributeChanged(nil, name, "updateSettings", value)
end

local function GetTextOffset(info, value)
	local name = info[#info-2]
	return db.objSettings[name].textOffset or db.textOffset
end

local function SetTextOffset(info, value)
	local name = info[#info-2]
	db.objSettings[name].textOffset = value
	ChocolateBar:AttributeChanged(nil, name, "updateSettings", value)
end

local function GetWidth(info)
	local name = info[#info-2]
	return db.objSettings[name].width
end

local function SetWidth(info, value)
	local name = info[#info-2]
	db.objSettings[name].width = value
	ChocolateBar:AttributeChanged(nil, name, "updateSettings", value)
end

local function GetWidthBehavior(info)
	local name = info[#info-2]
	--return db.objSettings[name].widthBehavior or "free" and db.objSettings[name].width == 0 or "fixed"
	if not db.objSettings[name].widthBehavior and db.objSettings[name].width == 0 then
		return "free"
	else
		return db.objSettings[name].widthBehavior or "fixed"
	end
end

local function SetWidthBehavior(info, value)
	local name = info[#info-2]
	db.objSettings[name].widthBehavior = value
	ChocolateBar:AttributeChanged(nil, name, "updateSettings", value)
end

local function IsDisabledTextWidth(info)
	local name = info[#info-2]
	return true and (db.objSettings[name].widthBehavior == "free" or not db.objSettings[name].widthBehavior) or false
end

--[[
local function GetIconImage(info, name)
	if info then  name = info[#info-2]  end
	local obj = broker:GetDataObjectByName(name)
	return  obj and obj.icon  or  DEFAULT_ICON_TEX
end
--]]

local function GetIconCoords(info)
	-- local cleanName = info[#info]
	-- local name = chocolateOptions[cleanName].desc
	-- local obj = broker:GetDataObjectByName(name)
	-- local name = info[#info]
	local obj = info.option.arg
	return obj and obj.iconCoords
end

local function IsDisabledIcon(info)
	local name = info[#info-2]
	local obj = broker:GetDataObjectByName(name)
	return not (obj and obj.icon) --return true if there is no icon
end

local function IsDisabledSetTextOffset(info)
	local name = info[#info-2]
	return not db.objSettings[name].textOffset
end

local function IsEnabledSetTextOffset(info)
	local name = info[#info-2]
	return db.objSettings[name].textOffset
end

local function SetEnabledSetTextOffset(info)
	local name = info[#info-2]
	local settings =  db.objSettings[name]
	if settings.textOffset then
		settings.textOffset = nil
	else
		settings.textOffset = db.textOffset
	end
	ChocolateBar:AttributeChanged(nil, name, "updateSettings", value)
end

local function SetEnabledOverwriteIconSize(info)
	local name = info[#info-2]
	local settings =  db.objSettings[name]
	if settings.iconSize then
		settings.iconSize = nil
	else
		settings.iconSize = db.iconSize
	end
	ChocolateBar:AttributeChanged(nil, name, "updateSettings", value)
end

local function SetCustomIconSize(info, value)
	local name = info[#info-2]
	if value > 1 then
		value = 1
	elseif value < 0.01 then
		value = 0.001
	end
	db.objSettings[name].iconSize = value
	ChocolateBar:UpdateBarOptions("UpdateHeight")
end

local function GetCustomIconSize(info, value)
	local name = info[#info-2]
	return db.objSettings[name].iconSize or db.iconSize
end

local function IsEnabledOvwerwriteIconSize(info)
	local name = info[#info-2]
	return db.objSettings[name].iconSize
end

local function IsDisabledOvwerwriteIconSize(info)
	local name = info[#info-2]
	return not db.objSettings[name].iconSize
end

local function GetHeaderName(obj, name)
	return "|T"..(obj.icon or DEFAULT_ICON_TEX)..":18|t "..name
	-- return obj.icon  and  "|T"..obj.icon..":18|t "..name  or  name
end

--[[
local function GetHeaderName(info)
	-- local cleanName = info[#info-1]
	-- local name = chocolateOptions[cleanName].desc
	local name = info[#info-1]
	return "|T"..GetIconImage(nil, name)..":18|t "..name
end
--]]

--[[
local function GetHeaderImage(info)
	local name = info[#info-2]
	local obj = broker:GetDataObjectByName(name)
	return (obj.icon or DEFAULT_ICON_TEX), 20 ,20
end
--]]




-- remove a bar and disable all plugins in it
function ChocolateBar:RemoveBar(name, bar, noupdate)
	bar = bar or self:GetBar(name)
	if bar then
		-- Disable all data pieces.
		for name,choco in pairs(self.chocolist) do
			ChocolateBar:DisableDataObject(name, choco, true)
		end
		wipe(self.chocolist)

		self:DestroyBar(bar, noupdate)
	end

	barOptions[name] = nil
	db.barSettings[name] = nil
end



function ChocolateBar:AddBarOptions(name)
	if barOptions[name] then  return barOptions[name]  end

	barOptions[name] = {
		name = GetBarLabel,
		desc = name,
		type = "group",
		order = GetBarIndex,
		args={
			general = {
				inline = true,
				name = name,
				type ="group",
				order = 0,
				args = {
					name = {
						type = 'input',
						order = 11,
						name = L["Name"],
						desc = L["Enter the name of this bar."],
						get = function(info, value)  Options.ChangeBarName or name  end,
						set = function(info, value)  Options.ChangeBarName = value  end,
					},
					rename = {
						type = 'execute',
						order = 12,
						name = L["Rename Bar"],
						desc = L["Change the name of this bar."],
						width = 'half',
						func = ChangeBarName,
						disabled = function(info)  return Options.ChangeBarName and Options.ChangeBarName:trim() ~= ""  end,
						confirm = true,
					},
					eatBar = {
						type = 'execute',
						order = 13,
						name = L["Remove Bar"],
						desc = L["Eat a whole chocolate bar, oh my.."],
						width = 'half',
						func = EatBar,
						-- disabled = IsDisabledRemoveBar,
						confirm = true,
					},
					hidebar = {
						type = 'toggle',
						order = 21,
						name = L["Hide In Combat"],
						desc = L["Hide this bar during combat."],
						get = gethideBarInCombat,
						set = sethideBarInCombat,
					},
					autohide = {
						type = 'toggle',
						order = 22,
						name = L["Autohide"],
						desc = L["Autohide"],
						get = getAutoHide,
						set = setAutoHide,
					},
					free = {
						type = 'toggle',
						order = 31,
						name = L["Free Placement"],
						desc = L["Enable free placement for this bar"],
						get = GetFreeBar,
						set = SetFreeBar,
					},
				},
			},
			move = {
				inline = true,
				name=L["Managed Placement"],
				type="group",
				order = 2,
				args={
					moveup = {
						type = 'execute',
						order = 3,
						name = L["Move Up"],
						desc = L["Move Up"],
						func = MoveUp,
						disabled = IsDisabledMoveUp,
					},
					movedown = {
						type = 'execute',
						order = 4,
						name = L["Move Down"],
						desc = L["Move Down"],
						func = MoveDown,
						disabled = IsDisabledMoveDown,
					},
				},
			},
			free = {
				inline = true,
				name=L["Free Placement"],
				type="group",
				order = -1,
				args={
					locked = {
						type = 'toggle',
						order = 7,
						name = L["Locked"],
						desc = L["Unlock to to move the bar anywhere you want."],
						get = GetLockedBar,
						set = SetLockedBar,
						disabled = IsDisabledFreeMove,
					},
					width = {
						type = 'range',
						order = 8,
						name = L["Bar Width"],
						desc = L["Set a width for the bar."],
						min = 0,
						--max = maxBarWidth,
						max = 3000,
						step = 1,
						get = GetBarWidth,
						set = SetBarWidth,
						disabled = IsDisabledFreeMove,
					},
					--[[
					xoff = {
						type = 'range',
						order = 9,
						name = L["Horizontal Offset"],
						desc = L["Horizontal Offset"],
						min = -5,
						max = 5,
						step = 1,
						get = GetBarOffX,
						set = SetBarOff,
						disabled = IsDisabledFreeMove,
					},
					yoff = {
						type = 'range',
						order = 10,
						name = L["Vertical Offset"],
						desc = L["Vertical Offset"],
						min = -5,
						max = 5,
						step = 1,
						get = GetBarOffY,
						set = SetBarOff,
						disabled = IsDisabledFreeMove,
					},
					--]]
				},
			},
		},
	}
end




local alignments = {left=L["Left"],center=L["Center"], right=L["Right"]}
local widthBehaviorTypes  = {free=L["Free"],fixed=L["Fixed"], max=L["Max"]}

function ChocolateBar:AddObjectOptions(name,obj)
	local t = obj.type
	if t ~= "data source" and t ~= "launcher" then  return false  end
	--local curse = GetAddOnMetadata(name,"X-Curse-Packaged-Version") or ""
	--local version = GetAddOnMetadata(name,"Version") or ""

	--use cleanName of name because aceconfig does not like some characters in the plugin names
	if chocolateOptions[name] then  return chocolateOptions[name]  end

	chocolateOptions[name] = {
		arg = obj,
		objName = name,
		cleanName = GetCleanName(obj.label or name),
		name = GetFormattedName,
		desc = name,
		--icon = GetIconImage,
		icon = obj.icon,
		--iconTexCoords = obj.iconCoords,
		iconCoords = GetIconCoords,
		type = "group",
		args={
			chocoSettings = {
				inline = true,
				name = GetHeaderName(obj, name),
				type="group",
				order = 1,
				args={
					label = {
						order = 2,
						type = "description",
						name = GetTypeText(obj.type),
						--image = GetHeaderImage(obj),
					},
					enabled = {
						type = 'toggle',
						--width "half",
						order = 3,
						name = L["Enabled"],
						desc = L["Enabled"],
						get = GetEnabled,
						set = SetEnabled,
					},
					text = {
						type = 'toggle',
						--width = "half",
						order = 4,
						name = L["Show Text"],
						desc = L["Show Text"],
						get = GetText,
						set = SetText,
					},
					icon = {
						type = 'toggle',
						--width = "half",
						order = 5,
						name = L["Show Icon"],
						desc = L["Show Icon"],
						get = GetIcon,
						set = SetIcon,
						disabled = IsDisabledIcon,
					},
					alignment = {
						type = 'select',
						order = 6,
						values = alignments,
						name = L["Alignment"],
						desc = L["Alignment"],
						get = GetAlignment,
						set = SetAlignment,
					},
					widthBehavior = {
						type = 'select',
						order = 7,
						values = widthBehaviorTypes,
						name = L["Width Behavior"],
						desc = L["How should the plugin width adapt to the text?"],
						get = GetWidthBehavior,
						set = SetWidthBehavior,
					},
					width = {
						type = 'range',
						order = 8,
						name = L["Fixed/Max Text Width"],
						desc = L["Set fixed or max width for the text."],
						min = 0,
						max = 500,
						step = 1,
						get = GetWidth,
						set = SetWidth,
						disabled = IsDisabledTextWidth,
					},
				},
			},
			textOffset = {
				inline = true,
				name=L["Overwrite Text Offset"],
				type="group",
				order = 2,
				args={
					enabled = {
						type = 'toggle',
						order = 2,
						name = L["Overwrite Text Offset"],
						desc =  L["Overwrite Text Offset"],
						get = IsEnabledSetTextOffset,
						set = SetEnabledSetTextOffset,
					},
					textOffset = {
						type = 'range',
						order = 3,
						name = L["Text Offset"],
						desc = L["Set the distance between the icon and the text."],
						min = -5,
						max = 15,
						step = 1,
						get = GetTextOffset,
						set = SetTextOffset,
						disabled = IsDisabledSetTextOffset,
					},
				},
			},
			iconSize = {
				inline = true,
				name=L["Overwrite Icon Size"],
				type="group",
				order = 2,
				args={
					enabled = {
						type = 'toggle',
						order = 2,
						name = L["Overwrite Icon Size"],
						desc =  L["Overwrite Icon Size"],
						get = IsEnabledOvwerwriteIconSize,
						set = SetEnabledOverwriteIconSize,
					},
					iconSize = {
						type = 'range',
						order = 3,
						name = L["Icon Size"],
						desc = L["Icon size in relation to the bar height."],
						min = 0,
						max = 1,
						step = 0.001,
						bigStep = 0.05,
						isPercent = true,
						get = GetCustomIconSize,
						set = SetCustomIconSize,
						disabled = IsDisabledOvwerwriteIconSize,
					},
				},
			},
		},
	}
	return chocolateOptions[name]
end




-- call when general bar options change
-- updatekey: the key of the update function
function ChocolateBar:UpdateBarOptions(updatekey, value)
	for name,bar in pairs(self.chocolateBars) do
		local func = bar[updatekey]
		if func then
			func(bar, db)
		else
			Debug("UpdateBarOptions: invalid updatekey", updatekey)
		end
	end
end


function ChocolateBar:RefreshBarOptions()
	for barName, options in pairs(barOptions) do
		-- Drop options panel of removed bars.
		if  not rawget(db.barSettings, barName)  then  barOptions[barName] = nil  end
	end
	for barName, settings in pairs(db.barSettings) do
		-- Add options panel for new bars.
		self:AddBarOptions(barName)
	end
end


function ChocolateBar:RefreshObjectOptions()
	--[[
	for cleanName, options in pairs(chocolateOptions) do
		-- Drop options panel of removed bars.
		if  not rawget(db.objSettings, options.objName)  then  chocolateOptions[cleanName] = nil  end
	end
	--]]
	for name, options in pairs(chocolateOptions) do
		-- Drop options panel of removed bars.
		if  not rawget(db.objSettings, name)  then  chocolateOptions[name] = nil  end
	end
	for name, obj in broker:DataObjectIterator() do
		self:AddObjectOptions(name, obj)
	end
end


function ChocolateBar:OnProfileChanged(event, database, newProfileKey)
	Debug("OnProfileChanged", event, database, newProfileKey)
	db = database.profile
	self:UpdateDB(db)

	-- Drop the Bar frames, but keep chocolateObjects, without parent.
	self:UnloadBars()
	-- Load Bars of new profile, refresh .settings, put reused chocolateObjects on them.
	self:OnEnable()

	wipe(barOptions)
	self:RefreshBarOptions()

	--[[ self:OnEnable() does differential EnableDataObject()/DisableDataObject()
	for name, obj in broker:DataObjectIterator() do
		local t = obj.type
		if t == "data source" or t == "launcher" then
			--for name, obj in pairs(dataObjects) do
			if db.objSettings[name].enabled then
				local choco = self:GetChocolate(name)
				if choco then
					choco.settings = db.objSettings[name]
				end
				self:DisableDataObject(name)
				self:EnableDataObject(name,obj, true) --no bar update
			else
				self:DisableDataObject(name)
			end
		end
	end
	self:UpdateBars(true) --update chocolateBars here
	self:UpdateChoclates("resizeFrame")
	moreChocolate = broker:GetDataObjectByName("MoreChocolate")
	if moreChocolate then moreChocolate:SetBar(db) end
	--]]
end




function ChocolateBar:RegisterOptions(database)
	--self.db = LibStub("AceDB-3.0"):New("ChocolateBarDB", defaults, "Default")
	db = database
	moreChocolate = broker:GetDataObjectByName("MoreChocolate")
	if moreChocolate then
		aceoptions.args.morechocolate = moreChocolate:GetOptions()
	end

	aceoptions.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(APPNAME, aceoptions)

	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")

	-- local optionsFrame = AceCfgDlg:AddToBlizOptions(APPNAME, APPNAME)
	AceCfgDlg:SetDefaultSize(APPNAME, 600, 600)
end

local firstOpen = true
function ChocolateBar:OpenOptions(optionsFrame, database, input, pluginName)
	if firstOpen then
		ChocolateBar:RegisterOptions(database)
		-- AceCfgDlg:SelectGroup(APPNAME, "chocolates")
		AceCfgDlg:SelectGroup(APPNAME, "general")
		firstOpen = nil
	end

	if pluginName then  AceCfgDlg:SelectGroup(APPNAME, "chocolates", pluginName)  end

	self:ToggleEditMode(true)
	self:RefreshBarOptions()
	self:RefreshObjectOptions()

	if not input or input:trim() == "" then
		AceCfgDlg:Open(APPNAME, optionsFrame)
	else
		--AceCfgDlg:SelectGroup(APPNAME, "chocolates", input)
		LibStub("AceConfigCmd-3.0").HandleCommand(ChocolateBar, "chocolatebar", APPNAME, input)
	end
end



