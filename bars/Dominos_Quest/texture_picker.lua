local L
local function AddTextures()
	if L then
		return
	end
	L = LibStub('LibSharedMedia-3.0')
	local statusbar = {
		None = "",
		Marble = "Interface/ItemTextFrame/ItemText-Marble-TopLeft",
		Stone = "Interface/ItemTextFrame/ItemText-Stone-TopLeft",
		Bronze = "Interface/ItemTextFrame/ItemText-Bronze-TopLeft",
		Silver = "Interface/ItemTextFrame/ItemText-Silver-TopLeft",
		Glow = "Interface/WorldMap/QuestPoiGlow",
		Sky = "Interface/MINIMAP/HumanUITile-TimeIndicator",
		CheckerBoard = "Interface/InventoryItems/NOART",
		["Status Bar"] = "Interface\\TargetingFrame\\UI-StatusBar",
		Tribal = "Interface/ACHIEVEMENTFRAME/UI-Achievement-Tsunami-Horizontal",
		["Round Corners"] = "Interface/Archeology/Arch-Progress-Fill",
		Bars = "Interface/CHARACTERFRAME/Char-Paperdoll-Horizontal",
		Electric = "Interface/UnitPowerBarAlt/Onyxia_Horizontal_Flash",
		["Gray Scale"] = "Interface/OPTIONSFRAME/21STEPGRAYSCALE",
		["Brushed Metal"] = "Interface/ItemTextFrame/ItemText-Silver-BotLeft",
		Flash = "Interface/Cooldown/starburst",
		Horde = "Interface/PlayerActionBarAlt/SpellBar-Horde_center",
		Alliance = "Interface/PlayerActionBarAlt/SpellBar-Alliance_center",
		X = "Interface/RAIDFRAME/ReadyCheck-NotReady",
		Double = "Interface/HELPFRAME/HelpFrameButton-Highlight",
		Emblems = "Interface/GuildFrame/GuildEmblems_01",
		["Raid Bar"] = "Interface/RaidFrame/Raid-Bar-Hp-Fill",
	}
	local border = {
		Empty = "",
		Wood = "Interface/ACHIEVEMENTFRAME/UI-Achievement-WoodBorder",
		Default = "Interface/Tooltips/UI-Tooltip-Border",
		['LFG Border'] = "Interface/LFGFRAME/LFGBorder",
		Tooltip = "Interface/MINIMAP/TooltipBackdrop",
		['Chat Bubble'] = "Interface/Tooltips/ChatBubble-Backdrop",
		Arena = "Interface/ArenaEnemyFrame/UI-Arena-Border",
		['Dialog Box Silver'] = "Interface/DialogFrame/UI-DialogBox-Border",
		['Dialog Box Gold'] = "Interface/DialogFrame/UI-DialogBox-Gold-Border",
		Glow = "Interface/TUTORIALFRAME/UI-TutorialFrame-CalloutGlow",
		['Glow 2'] = "Interface/FriendsFrame/PendingFriendGlow",
		['Toast Border'] = "Interface/FriendsFrame/UI-Toast-Border",
		['Party Border'] = "Interface/CHARACTERFRAME/UI-Party-Border",
		Shadowed = "Interface/ACHIEVEMENTFRAME/UI-Shadow-Backdrop",
	}
	local background = {
		None = "",
		Marble = "Interface/ItemTextFrame/ItemText-Marble-TopLeft",
		Stone = "Interface/ItemTextFrame/ItemText-Stone-TopLeft",
		Bronze = "Interface/ItemTextFrame/ItemText-Bronze-TopLeft",
		Silver = "Interface/ItemTextFrame/ItemText-Silver-TopLeft",
		Glow = "Interface/WorldMap/QuestPoiGlow",
		Blue = "Interface/WorldMap/UI-QuestBlob-Inside-blue",
		Red = "Interface/WorldMap/UI-QuestBlob-Inside-red",
		['Green Rune'] = "Interface/SpellShadow/Spell-Shadow-Acceptable",
		Sky = "Interface/MINIMAP/HumanUITile-TimeIndicator",
		--['Blizzard Dialog'] = 'Interface\\DialogFrame\\UI-DialogBox-Background',
		['Blizzard Dialog Dark'] = "Interface/DialogFrame/UI-DialogBox-Background-Dark",
		['Blizzard Dialog Gold'] = "Interface/DialogFrame/UI-DialogBox-Gold-Background",
		['Blood Elf'] = "Interface/DressUpFrame/DressUpBackground-BloodElf1",
		['Death Knight'] = "Interface/DressUpFrame/DressUpBackground-DeathKnight1",
		Draenei = "Interface/DressUpFrame/DressUpBackground-Draenei1",
		Dwarf = "Interface/DressUpFrame/DressUpBackground-Dwarf1",
		Gnome = "Interface/DressUpFrame/DressUpBackground-Gnome1",
		Goblin = "Interface/DressUpFrame/DressUpBackground-Goblin1",
		Human = "Interface/DressUpFrame/DressUpBackground-Human1",
		['Night Elf'] = "Interface/DressUpFrame/DressUpBackground-NightElf1",
		Undead = "Interface/DressUpFrame/DressUpBackground-Scourge1",
		Tauren = "Interface/DressUpFrame/DressUpBackground-Tauren1",
		Troll = "Interface/DressUpFrame/DressUpBackground-Troll1",
		Horde = "Interface/Calendar/UI-Calendar-Event-PVP01",
		Alliance = "Interface/Calendar/UI-Calendar-Event-PVP02",
		CheckerBoard = "Interface/InventoryItems/NOART",
	}
	
	for i, b in pairs(statusbar) do
		L:Register("statusbar", i, b, "enUS")
	end
	for i, b in pairs(border) do
		L:Register("border", i, b, "enUS")
	end
	for i, b in pairs(background) do
		L:Register("background", i, b, "enUS")
	end
end


--[[
	Texture Picker
--]]

local function NewTextureButton(name, parent)
	local button = CreateFrame('Button', name, parent)
	button:SetWidth(parent:GetWidth())
	button:SetHeight((parent:GetHeight()/10) - 2)
	button:SetNormalFontObject('GameFontNormalLeft')
	button:SetHighlightFontObject('GameFontHighlightLeft')
	return button
end

local function NewScrollFrame(parent)
	local frame = CreateFrame("ScrollFrame", parent:GetName().."ScrollFrame", parent)
	frame:SetPoint("Center")
	
	frame.bar = CreateFrame("Slider", frame:GetName().."Bar", frame, "OptionsSliderTemplate")
	_G[frame.bar:GetName() .. 'High']:SetText("")
	_G[frame.bar:GetName() .. 'Low']:SetText("")
	frame.bar:SetOrientation("VERTICAL")
	frame.bar:SetWidth(16)
	frame.bar:SetScript("OnValueChanged", function (l, value) 
		frame:SetVerticalScroll(value)
		parent:update(value)
	end)
	frame.bar:SetScript("OnMouseWheel", function(self, delta)
		self:SetValue(self:GetValue() - (delta * self:GetValueStep()))
	end)
	frame:SetScript("OnMouseWheel", function(self, delta)
		self.bar:GetScript("OnMouseWheel")(self.bar, delta)
	end)

	frame.bar:SetMinMaxValues(1, 200) 
	frame.bar:SetValueStep(10) 
	frame.bar.scrollStep = 1 

	return frame
end

local Picker = CreateFrame("Frame", "TexturePicker", UIParent, "TranslucentFrameTemplate")
Picker:SetSize(200, 300)
Picker:SetPoint("Center")
Picker:Hide()

Picker.title = Picker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Picker.title:SetPoint("TopLeft", 13, -12)


local scroll = NewScrollFrame(Picker, "textures")
scroll:Show()
scroll:SetPoint("TopLeft", 12, -30)
scroll:SetPoint("BottomRight", -12, 12)
Picker.scroll = scroll

Picker.close = Picker.close or CreateFrame("Button", Picker:GetName().."CloseButton", Picker, "UIPanelCloseButton")
Picker.close:SetPoint("TopRight", -6, -6)
Picker.close:SetSize(25, 25)

local name = "textures"
scroll.buttons = {}

function Picker:SetSelect(textureName, texturePath)
	Picker.accept(textureName, texturePath)
	Picker:Hide()
end

for i = 1, 10 do
	local b = NewTextureButton(name .. i, scroll)
	local h = b:GetHeight() + 2
	b:SetPoint('TOPLEFT', 0, -((h * i) - h))
	scroll.buttons[i] = b
end

function Picker:UpdateButtons()
	local self = Picker
	local SML = LibStub('LibSharedMedia-3.0')
	local textures = LibStub('LibSharedMedia-3.0'):List(self.kind)

	local max = 0
	
	if #textures > 10 then
		max = #textures - 10
	end
	Picker.scroll.bar:SetMinMaxValues(0, max)
	
	for i,button in pairs(self.scroll.buttons) do
		local index = i + self.scroll.bar:GetValue()
		if index <= #textures then
			button:SetText(textures[index])
			local texture = SML:Fetch(self.kind, textures[index])
			button.texture = texture
			button:SetBackdrop({})	
			if self.kind == "border" then
				button:SetBackdrop({
					edgeFile= button.texture ,
					edgeSize = 16,

				})
			else
				button:SetBackdrop({
					bgFile= button.texture ,
				})
			end
			button:SetScript("OnClick", function()
				Picker:SetSelect(textures[index], button.texture)
			end)
			button:Show()
		else
			button:Hide()
		end
	end
end

Picker.update = Picker.UpdateButtons

function Picker:Set(kind)
	local textures = LibStub('LibSharedMedia-3.0'):List(kind)
	self.textures = {}
	self.kind = kind
	self:UpdateButtons()
	print(kind)
end

function ShowTexturePicker(kind, setFunc)
	Picker.title:SetText("Textures: "..kind)
	AddTextures()
	Picker.kind = kind
	Picker.accept = setFunc
	Picker.scroll.bar:SetValue(0)
	Picker:UpdateButtons()
	Picker:Show()
end

--[[

ShowTexturePicker("background", function(textureName, texturePath)
	print(textureName, texturePath)
end)

--]]

