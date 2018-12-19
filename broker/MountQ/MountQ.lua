MountQ = LibStub("AceAddon-3.0"):NewAddon("MountQ", "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0");
local ldb = LibStub:GetLibrary("LibDataBroker-1.1");
local LibQTip = LibStub("LibQTip-1.0");
local LibIcon = LibStub("LibDBIcon-1.0");

local AceConfigReg = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

MountQ.MQ = {};
local MQ = MountQ.MQ;

local MQicon = "Interface\\Icons\\Ability_Mount_RidingHorse"
local tooltip;
local appName = ...

MQ.DEBUG_MODE = false;
MQ.KnownMounts = {};
MQ.SORT_ALPHABETIC = 1;
MQ.SORT_TYPE = 2;
MQ.VERSION = GetAddOnMetadata(appName, "Version");
MQ.MinSubCategoryCount = 1;
MQ.IconFormat = "|T%s:20:20|t";
MQ.HasFlightForm = nil;
MQ.HasSwimForm = nil

MQ.DISPLAY_GROUND = 0;
MQ.DISPLAY_FLYING = 1;

MQ.WindowSizeX = 800;
MQ.WindowSizeY = 475;

BINDING_HEADER_MOUNTQ = "MountQ"
_G[ "BINDING_NAME_CLICK MountQBtn:LeftButton" ] = "Call Random Mount"
_G[ "BINDING_NAME_CLICK MountQFav:LeftButton" ] = "Call Favorite Mount"
--BINDING_NAME_MOUNTQFAVORITE = "Call Favorite Mount"

local defaults = {
	profile = {
		SortType = MQ.SORT_TYPE;
		AllowFly = true;
		Scale = 1;
		LastVersion = MQ.VERSION;
		FavoriteMount = nil;
		DisplayType = MQ.DISPLAY_GROUND;
		GroundList = {};
		FlyList = {};

	},
	global = {
		minimap = { hide = false },
		mod = 1,
		modother = 1,
	}
}

function MQ.Debug(...)
	if(MQ.DEBUG_MODE) then
		local output, part
		for i=1, select("#", ...) do
			part = select(i, ...)
			part = tostring(part):gsub("{{", "|cffddeeff"):gsub("}}", "|r")
			if (output) then output = output .. " " .. part
			else output = part end
		end
		ChatFrame1:AddMessage(output, 1.0, 1.0, 1.0);
	end
end

-- Saved variables change from version to version
-- Clean them up
function MQ.CleanUpOldData()
	if profile.LastVersion ~= MQ.VERSION then
		profile.LastVersion = MQ.VERSION
	end
	if MQ.db.global.modother == nil then
		MQ.db.global.modother = 1
	end
	if MQ.db.global.mod == nil then
		MQ.db.global.mod = 1
	end
	if profile.MountQList ~= nil then
		-- COPY OLD LIST TO GROUND / FLY HERE!
		profile.GroundList = {};
		profile.FlyList = {};
		for i,j in pairs(profile.MountQList) do
			table.insert(profile.FlyList, 1, j);
			table.insert(profile.GroundList, 1, j);
		end
		table.sort(profile.FlyList, function(a,b) return a < b end)
		table.sort(profile.GroundList, function(a,b) return a < b end)
		profile.MountQList = nil;
	end
end

function MountQ:RegisterSlashCommands()
	self:RegisterChatCommand("mq", "ChatCmd");
end

function MountQ:ChatCmd(args)
	AceConfigDialog:Open(appName);
end
	
function MountQ:OnInitialize()
	MQ.db = LibStub("AceDB-3.0"):New("MountQDB", defaults, true);
	-- MQ.db.ResetDB();
	
	MQ.broker = ldb:NewDataObject("MountQ", {
		type = "data source", 
		icon = MQicon, 
		label = "MountQ",
		text = "MountQ",
		OnEnter = function(self, button) MountQ:OnEnter(self, button) end,

	});

	MountQ:RegisterSlashCommands()

	MQ.CleanUpOldData();
	LibIcon:Register(appName, MQ.broker, MQ.db.global.minimap);
	
	AceConfigReg:RegisterOptionsTable(appName, MountQ.CreateOpt);
	AceConfigDialog:AddToBlizOptions(appName, appName);
	AceConfigDialog:SetDefaultSize(appName, MQ.WindowSizeX, MQ.WindowSizeY);

	MQ.db.RegisterCallback(MountQ, "OnProfileChanged", "OnProfileChanged")
	MQ.db.RegisterCallback(MountQ, "OnProfileCopied", "OnProfileChanged")
	MQ.db.RegisterCallback(MountQ, "OnProfileReset", "OnProfileChanged")
	MountQData_Initialize();
end

function MountQ:SecurePreClick(btn, secure, mount)
	MQ.Debug("PreClick Button "..btn);
	local skipswim = false;

	if mount then
		skipswim = true;
		MQ.NextMount = mount;
	else
		MQ.NextMount = MountQ:ButtonClick(btn);
		if MQ.NextMount == nil then return end;
	end

	if UnitInVehicle("player") then
		VehicleExit();
		return;
	end
	if MQ.RemoveForms(self, secure) == true then
		MQ.NextMount = nil;
		return;
	end

	if IsMounted() == 1 then
		MQ.Debug("Dismiss Mount");
		Dismount();
		MQ.NextMount = nil;
		return;
	end

	local falling = MountQ:CheckFalling();
	if falling then MQ.NextMount = falling; end

	local swimming = MountQ:CheckSwimming();
	if not skipswim and swimming then MQ.NextMount = swimming; end

	-- Spell casts need to be cast in preclick 
	if MountQData_IsForm(MQ.NextMount) == true then
		MQ.Debug("PreClick Select Mount");
		MQ.SelectMount(self, MQ.NextMount, secure);
	end
end

function MountQ:SecurePostClick(secure)
	-- Non forms need to be done post or the shapeshift didn't finish
	if InCombatLockdown() then return end
	if MountQData_IsForm(MQ.NextMount) == false then
		MQ.Debug("PostClick Select Mount");
		MQ.SelectMount(self, MQ.NextMount, MountQBtn);
	end
	secure:SetAttribute("type", nil);
	secure:SetAttribute("spell", nil);
end

function MountQ:OnEnable()
	self:RegisterEvent("COMPANION_LEARNED")
--	self:RegisterEvent("PLAYER_LEVEL_UP");
	MQ.class = select(2, UnitClass("player"))
	MQ.race = UnitRace("player");
	MountQ:ValidateMounts();

	-- Favorites secure Button
	CreateFrame("Button", "MountQFav", UIParent, "SecureActionButtonTemplate");
	MountQFav:SetScript('PreClick', function (_, btn) 
		MountQ:SecurePreClick(btn, MountQFav, MQ.db.profile.FavoriteMount);
	end);
	MountQFav:SetScript('PostClick', function (_, btn) 
		MountQ:SecurePostClick(MountQFav);
	end);

	-- Broker Secure Button
	CreateFrame("Button", "MountQBtn", UIParent, "SecureActionButtonTemplate");
	MountQBtn:SetScript('PreClick', function (_, btn) 
		MountQ:SecurePreClick(btn, MountQBtn, nil);
	end);
	MountQBtn:SetScript('PostClick', function (_, btn) 
		MountQ:SecurePostClick(MountQBtn);
	end);
	MountQBtn:SetScript("OnEnter", function(self) 
		MQ.Debug("Entering!!!") 
		MountQ:OnEnterSecure(self, button);
	end);
	MountQBtn:RegisterForClicks('AnyUp');
	MountQBtn:Hide();

	CreateFrame("Button", "MountQMenu", UIParent, "SecureActionButtonTemplate") 
	MountQMenu:RegisterForClicks('LeftButtonUp');
	MountQMenu:Hide();
end

function MountQ:ValidateMounts()
	if MountQ:UpdateKnownMounts() == false then
		MountQ:ScheduleTimer("ValidateMounts", 0.5)
		MQ.Debug("Scheduling validate pets in .5");
		return;
	end
	MountQ:RemoveBadMounts();
	MountQ:UpdateIcon();
end

function MountQ:UpdateKnownMounts()
	MQ.Debug("Updating Mount List");
	table.wipe(MQ.KnownMounts);
	local NumMounts = GetNumCompanions("MOUNT");
	local FoundAll = true;
	
	for i = 1, NumMounts do
		local creatureID, creatureName, creatureSpellID, icon, issummoned, mountFlags = GetCompanionInfo("MOUNT", i);
		if creatureName ~= nil then

			MountQData_AddKnownMount(creatureSpellID, creatureName, icon, mountFlags);
			table.insert(MQ.KnownMounts, 1, { creatureName, creatureSpellID, i });
		else
			FoundAll = false;
		end
	end
	if MQ.race == "Worgen" then
		MQ.Debug("Worgen race");
		local name, rank, icon = GetSpellInfo("Running Wild");
		if name ~= nil then
			MountQData_AddKnownMount(87840, name, icon, 0x01+0x04+0x08+0x10);
			table.insert(MQ.KnownMounts, 1, { name, 87840 });
		end
	end

	if MQ.class == "DRUID" then
		local name, rank, icon = GetSpellInfo("Swift Flight Form");
		if name ~= nil then
			MQ.HasFlightForm = "Swift Flight Form";
			MountQData_AddKnownMount(40120, name, icon, 0x02+0x04);
			table.insert(MQ.KnownMounts, 1, { name, 40120 });
		end
		local name, rank, icon = GetSpellInfo("Flight Form");
		if name ~= nil then
			MQ.HasFlightForm = "Flight Form";
			MountQData_AddKnownMount(33943, name, icon, 0x02+0x04);
			table.insert(MQ.KnownMounts, 1, { name, 33943 });
		end
		local name, rank, icon = GetSpellInfo("Aquatic Form");
		if name ~= nil then
			MQ.HasSwimForm = "Aquatic Form";
			MountQData_AddKnownMount(1066, name, icon, 0x04+0x08);
			table.insert(MQ.KnownMounts, 1, { name, 1066 });
		end
	end
--	if MQ.class == "SHAMAN" then
--		local name, rank, icon = GetSpellInfo("Ghost Wolf");
--		if name ~= nil then
--			MountQData_AddKnownMount(2645, name, icon, 0x01+0x10);
--			table.insert(MQ.KnownMounts, 1, { name, 2645 });
--		end
--
--	end
	table.sort(MQ.KnownMounts, function(a,b) return a[1] < b[1] end)
	return FoundAll;
end

function MountQ:UpdateIcon()
	local profile = MQ.db.profile
	-- Update broker icon
	local mount = profile.FavoriteMount;

	if mount == nil and #profile.FlyList > 0 then
		mount = profile.FlyList[random(#profile.FlyList)];
	end
	if mount == nil and #profile.GroundList > 0 then
		mount = profile.GroundList[random(#profile.GroundList)];
	end
	if mount == nil and #MQ.KnownMounts > 0 then
		mount = MQ.KnownMounts[random(#MQ.KnownMounts)][1]
	end

	if mount then
		MQ.broker.icon = MountQData_GetIcon(mount);
	end
end

-- Removes a mount that's in our favorite list, but is no longer valid.
function MountQ:RemoveBadMounts()
  local profile = MQ.db.profile
	local ValidMounts = {};
	for i, j in pairs(MQ.KnownMounts) do
		table.insert(ValidMounts, 1, j[1]);
	end
	for i, j in pairs(profile.FlyList) do
		local flying = MountQData_IsFlier(j);
		if tContains(ValidMounts, j) == nil or flying == false then
			MQ.Debug("Removing mount "..j..", which is no longer valid.");
			table.remove(profile.FlyList, i);
			MountQ:RemoveBadMounts();
			return;
		end
	end
	for i, j in pairs(profile.GroundList) do
		local ground = MountQData_IsGround(j);
		if tContains(ValidMounts, j) == nil or ground == false then
			MQ.Debug("Removing mount "..j..", which is no longer valid.");
			table.remove(profile.GroundList, i);
			MountQ:RemoveBadMounts();
			return;
		end
	end
	if profile.FavoriteMount ~= nil then
		if tContains(ValidMounts, profile.FavoriteMount) == nil then
			MQ.Debug("Removing favorite mount "..profile.FavoriteMount..", which is no longer valid.");
			profile.FavoriteMount = nil;
		end
	end
end

function MountQ:PLAYER_LEVEL_UP(self, event, arg1)
	MQ.Debug("Player Level Up");
	MountQ:UpdateKnownMounts();
	AceConfigReg:RegisterOptionsTable(appName, MountQ.CreateOpt)
	AceConfigReg:NotifyChange(appName);
end

function MountQ:COMPANION_LEARNED(self, event, arg1)
	MQ.Debug("Companion Learned");
	MountQ:UpdateKnownMounts();
	AceConfigReg:RegisterOptionsTable(appName, MountQ.CreateOpt)
	AceConfigReg:NotifyChange(appName);
end

function MountQ:CallRandom()
	MQ.Debug("CallRandom");
	local profile = MQ.db.profile
	if MountQ:CanFlyNow() == true and #profile.FlyList > 0 then
		local val = profile.FlyList[random(#profile.FlyList)]
		return val;
	else
		if #profile.GroundList == 0 then
			return
		end
		return profile.GroundList[random(#profile.GroundList)];
	end
end

function MountQ:CheckSwimming()
	MQ.Debug("CheckSwimming");
	if MQ.HasSwimForm ~= nil and IsSwimming() == 1 and MountQ:CanFlyNow() == false then
		return MQ.HasSwimForm;
	end

	local turtle = MountQData_IsKnown("Sea Turtle");
	turtle = 0;
	local seahorse = MountQData_IsKnown("Abyssal Seahorse");

	if seahorse == 1 then
		local ZoneName = GetZoneText();
		if ZoneName == "Abyssal Depths" or ZoneName == "Shimmering Expanse" or ZoneName == "Kelp'thar Forest" or ZoneName == "Vashj'ir" then
			if IsUsableSpell(75207) then return "Abyssal Seahorse" end;
		end
	end

	if turtle == 1 and IsSwimming() == 1 then
		if MountQ:CanFlyNow() == false and IsUsableSpell(64731) then
			return "Sea Turtle";
		end
	end
	return nil;
end

function MountQ:CheckFalling()
	MQ.Debug("CheckFalling");
	if IsFalling() == 1 then
		if MountQ:CanFlyNow() == true and MQ.HasFlightForm ~= nil then
			return MQ.HasFlightForm;
		end
	end
	return nil;
end

function MountQ:CallFavorite(secure)
  local FavoriteMount = MQ.db.profile.FavoriteMount
	if  FavoriteMount  then
		MQ.SelectMount(self, FavoriteMount, secure);
	end
end

function MountQ:ButtonClick(button)
	MQ.Debug("Button Click");
  local profile = MQ.db.profile

	if button == "RightButton" then
		AceConfigDialog:Open(appName);
		return nil;
	elseif button == "LeftButton" and IsControlKeyDown() then
		if tooltip ~= nil then
			tooltip:Hide();
		end
		return profile.FavoriteMount;
	elseif button == "LeftButton" then
		if tooltip ~= nil then
			tooltip:Hide();
		end
		return MountQ:CallRandom()
	end
	return nil;
end

function MountQ:CanFlyNow()
	if IsUsableSpell(60025) then
		return true;
	else
		return false;
	end
end

function MountQ:OnEnter(brokerframe, button)

	MQ.Debug("MountQ:OnEnter Called");
	if InCombatLockdown() then return end

	MountQBtn:RegisterForDrag("LeftButton")
	MountQBtn:SetMovable(true)
	MountQBtn:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then return end
		if GameTooltip ~= nil then GameTooltip:Hide() end
		brokerframe:GetScript("OnDragStart")(brokerframe)
		MQ.Debug("Dragging!");
		self:SetScript("OnUpdate", function(self)
			self:SetAllPoints(brokerframe)
			if not IsMouseButtonDown("LeftButton") then
				brokerframe:GetScript("OnDragStop")(brokerframe)
				MQ.Debug("Drag stopped");
				self:SetScript("OnUpdate",nil)
			end
		end)
		self:Show()
	end)

	brokerframe:SetScript("OnHide", function()
		if not InCombatLockdown() then MountQBtn:Hide(); end
	end)

	MountQBtn:SetFrameStrata(brokerframe:GetFrameStrata())
	MountQBtn:SetFrameLevel(brokerframe:GetFrameLevel()+1)
	MountQBtn:SetAllPoints(brokerframe)
	MountQBtn:Show()
end

function MountQ:OnEnterSecure(self, button)
	local fly = MountQ:CanFlyNow()

	if GameTooltip ~= nil then GameTooltip:Hide(); end

	tooltip = LibQTip:Acquire("MountQTooltip", 1, "LEFT", "LEFT");
	if tooltip:IsShown() then
		return;
	end
	tooltip:SetScale(MQ.db.profile.Scale);
	tooltip:SmartAnchorTo(self)
	
	tooltip:Clear();

	local line = tooltip:AddLine();
	tooltip:SetCell(line, 1, "|cff00E5EEMountQ|r", nil, "CENTER", 1);
	local line = tooltip:AddLine();
	if fly == true then
		tooltip:SetCell(line, 1, "|cff00E5EEFlying|r", nil, "CENTER", 1);
	else
		tooltip:SetCell(line, 1, "|cff00E5EEGround|r", nil, "CENTER", 1);
	end
	tooltip:AddSeparator();

	if (MQ.db.global.modother == 2 and IsControlKeyDown()) or
	   (MQ.db.global.modother == 3 and IsShiftKeyDown()) or
	   (MQ.db.global.modother == 4 and IsAltKeyDown()) then
		fly = not fly;
	end

	if MQ.db.global.mod == 1 or
	   (MQ.db.global.mod == 2 and IsControlKeyDown()) or
	   (MQ.db.global.mod == 3 and IsShiftKeyDown()) or
	   (MQ.db.global.mod == 4 and IsAltKeyDown()) then
		MQ.UpdateTooltip(tooltip, fly);
	end

	tooltip:EnableMouse()
	tooltip:SmartAnchorTo(self)
	tooltip:SetAutoHideDelay(0.25, self)
	tooltip:UpdateScrolling()
	tooltip:Show()
end

function MQ.SecureTooltipEnter(self, mount)
	local button = self;
	if InCombatLockdown() then return end
	
	MountQMenu:SetScript("OnEnter", function(self)
		if button then button:GetScript("OnEnter")(self); end
		MQ.Debug("Entering Secure Button")
	end);
	MountQMenu:SetScript("OnLeave", function(self)
		if button then button:GetScript("OnLeave")(self); end
		MQ.Debug("Leaving Secure Button")
		MountQMenu:Hide();
	end)	
	self:SetScript("OnHide", function()
		MountQMenu:Hide();
	end)
	MountQMenu:SetScript('PreClick', function (_, btn) 
		MountQ:SecurePreClick(btn, MountQMenu, mount)
	end);
	MountQMenu:SetScript('PostClick', function (_, btn) 
		MountQ:SecurePostClick(MountQMenu)
	end)
	MountQMenu:SetFrameStrata(self:GetFrameStrata())
	MountQMenu:SetFrameLevel(self:GetFrameLevel()+1)
	MountQMenu:SetAllPoints(self)
	MountQMenu:Show()
end

function MQ.UpdateTooltip(tooltip, fly)
  local profile = MQ.db.profile
	local format = "%s";
	format = "|cffffc1c1"..format.."|r";
	local Mounts;
	
	if fly == true then
		Mounts = profile.FlyList;
	else
		Mounts = profile.GroundList;
	end
	for i, j in pairs(Mounts) do
		local line = tooltip:AddLine();
		tooltip:SetCell(line, 1, string.format(MQ.IconFormat, MountQData_GetIcon(j)).." "..j, nil, "LEFT", 1);
		tooltip:SetCellScript(line, 1, "OnEnter", MQ.SecureTooltipEnter, j);
	end

	if #Mounts == 0 then
		local line = tooltip:AddLine();
		tooltip:SetCell(line, 1, "Right Click to add mounts to this menu.");
		line = tooltip:AddLine();
		tooltip:SetCell(line, 1, "Left Click to call a random mount.");
		line = tooltip:AddLine();
		tooltip:SetCell(line, 1, "Click mount in menu to call a specific mount.");
		line = tooltip:AddLine();
		tooltip:SetCell(line, 1, "Shift Click to dismiss your mount.");
		tooltip:SetColumnScript(1, "OnMouseDown", MQ.OpenConfig);
	end
end

function MQ.RemoveForms(self, button)
	if InCombatLockdown() then return false end;
	
	MQ.Debug("Race = "..MQ.race);
	if MQ.class == "DRUID" or MQ.class == "SHAMAN" or MQ.race == "Worgen" then
		local buffs, name = 0
		repeat
			buffs = buffs + 1
			name = UnitBuff("player", buffs)
		until not name or name =="Bear Form" or name == "Dire Bear Form" or name == "Cat Form" or name == "Travel Form" or name == "Tree of Life" or name == "Moonkin Form" or name == "Flight Form" or name == "Swift Flight Form" or name == "Ghost Wolf" or name == "Running Wild" or name == "Aquatic Form"
		if name then 
			button:SetAttribute("type", "spell");
			button:SetAttribute("spell", name);
			MQ.Debug("Removing "..name);
			if name == "Flight Form" or name == "Swift Flight Form" or name == "Running Wild" then
				return true -- Dismounted
			else
				return false
			end
		end
	end
	return false;
end

MQ.noloop = false;
function MQ.SelectMount(self, MountName, secure)
	if MountName == nil then return end;
	MQ.Debug("Selecting mount "..MountName);
	if MountQData_IsForm(MountName) == true then
		secure:SetAttribute("type", "spell");
		secure:SetAttribute("spell", MountName);
		return;
	end

	-- Fix for mounts :)
	Dismount();
	
	for i,j in pairs(MQ.KnownMounts) do
		if j[1] == MountName then
			MQ.broker.icon = MountQData_GetIcon(MountName);
			local creatureID, creatureName = GetCompanionInfo("MOUNT", j[3]);
			if creatureName ~= j[1] and MQ.noloop == false then
				MountQ:ValidateMounts();
				MQ.noloop = true;
				MQ.SelectMount(self, MountName, secure);
				return;
			end
			
			MQ.noloop = false;
			CallCompanion("MOUNT", j[3]);
			return;
		end
	end
end

function MQ.OpenConfig(self, button)
	AceConfigDialog:Open(appName);
end

function MQ.ToggleDisplayType()
  local profile = MQ.db.profile
	if profile.DisplayType == MQ.DISPLAY_GROUND then
		profile.DisplayType = MQ.DISPLAY_FLYING;
		MQ.Debug("Show Flying");
	else
		profile.DisplayType = MQ.DISPLAY_GROUND;
		MQ.Debug("Show Ground");
	end
	AceConfigReg:NotifyChange(appName);
end

function MQ.ToggleSortType()
	if MQ.db.profile.SortType == MQ.SORT_ALPHABETIC then
		MQ.db.profile.SortType = MQ.SORT_TYPE;
		MQ.Debug("Sorting by Type");
	else
		MQ.db.profile.SortType = MQ.SORT_ALPHABETIC
		MQ.Debug("Sorting Alphabetic");
	end
	AceConfigReg:NotifyChange(appName);
end

function MQ.ToggleCatMounts(key)
  local profile = MQ.db.profile
	local category = key["arg"];
	local category_count = 0;
	local ToggleOnList = {};
	local ToggleOffList = {};
	local name;
	local MountList;
	if profile.DisplayType == MQ.DISPLAY_FLYING then
		MountList = profile.FlyList;
	else
		MountList = profile.GroundList;
	end

	MQ.Debug("Toggle category "..category.." on/off");

	for i, j in pairs(MQ.KnownMounts) do
		name = j[1];
		if MountQData_IsMountInCat(name, category) == true then
			if tContains(MountList, name) ~= nil then
				table.insert(ToggleOffList, 1, name);
			end
			table.insert(ToggleOnList, 1, name);
		end
	end

	local _
	if #ToggleOffList == 0 then
		MQ.Debug("Turn on all in list");
		for _, name in pairs(ToggleOnList) do
			if tContains(MountList, name) == nil then
				table.insert(MountList, 1, name);
			end
		end
	else
		MQ.Debug("Turn off all in list");
		for _, name in pairs(ToggleOffList) do
			local index = 1;
			while MountList[index] do
				if MountList[index] == name then
					table.remove(MountList, index);
					index = #MountList;
				else
					index = index + 1;
				end
			end
		end
		table.sort(MountList, function(a,b) return a < b end)
	end
end

function MQ.ToggleAll()
  local profile = MQ.db.profile
	local MountList;
	if profile.DisplayType == MQ.DISPLAY_FLYING then
		MountList = profile.FlyList;
	else
		MountList = profile.GroundList;
	end
	if #MountList > 0 then
		table.wipe(MountList);
	else
		table.wipe(MountList);
		for i,j in pairs(MQ.KnownMounts) do
			local flying = MountQData_IsFlier(j[1]);
			local ground = MountQData_IsGround(j[1]);

			if flying == true and profile.DisplayType == MQ.DISPLAY_FLYING then
				table.insert(profile.FlyList, 1, j[1]);
			elseif ground == true and profile.DisplayType == MQ.DISPLAY_GROUND then
				table.insert(profile.GroundList, 1, j[1]);
			end
		end
		if profile.DisplayType == MQ.DISPLAY_FLYING then
			table.sort(profile.FlyList, function(a,b) return a < b end)
		else
			table.sort(profile.GroundList, function(a,b) return a < b end)
		end
	end
end

function MQ.GetMountToggle(key)
  local profile = MQ.db.profile
	local MountList;
	if profile.DisplayType == MQ.DISPLAY_FLYING then
		MountList = profile.FlyList;
	else
		MountList = profile.GroundList;
	end
	if tContains(MountList, key["arg"]) ~= nil then
		return true;
	else
		return false;
	end
end

function MQ.SetMountToggle(key, val)
  local profile = MQ.db.profile
	local MountList;
	if profile.DisplayType == MQ.DISPLAY_FLYING then
		MountList = profile.FlyList;
	else
		MountList = profile.GroundList;
	end
	local ClickedMount = key["arg"];
	local favorite = false;
	if IsControlKeyDown() then
		profile.FavoriteMount = key["arg"];
		MQ.Debug("Select Favorite as "..profile.FavoriteMount);
		favorite = true;
	end
	if val then
		table.insert(MountList, 1, ClickedMount);
		table.sort(MountList, function(a,b) return a < b end)
	elseif favorite == false then
		for i,j in pairs(MountList) do
			if j == ClickedMount then
				table.remove(MountList, i);
				return;
			end
		end
	end
end

local function CategorySort(a, b)
	local acat = a[1];
	local bcat = b[1];

	if a[1] == MountQAllType and b[1] ~= MountQAllType then
		return nil;
	elseif b[1] == MountQAllType and a[1] ~= MountQAllType then
		return 1;
	end
	if acat < bcat then
		return 1;
	elseif acat > bcat then
		return nil;
	end
	
	acat = a[2];
	bcat = b[2];

	if a[2] == MountQGeneralType and b[2] ~= MountQGeneralType then
		return nil;
	elseif b[2] == MountQGeneralType and a[2] ~= MountQGeneralType then
		return 1;
	end
	if acat < bcat then
		return 1;
	elseif acat > bcat then
		return nil;
	end

	if a[4] < b[4] then
		return 1;
	else
		return nil;
	end
end

local function GetCatCount(category, mountlist)
	local count = 0;
	for i, j in pairs(mountlist) do
		if(j[1] == category) then
			count = count + 1;
		end
	end
	return count;
end

local function SubCatToGeneral(SortList, subcat)
	for i, j in pairs(SortList) do
		if j[2] ~= MountQGeneralType and j[2] == subcat then
			SortList[i][2] = MountQGeneralType;
		end
	end
end

local function OrderConf(reset)
	if reset ~= nil then
		MQ.next_order = reset
	end
	MQ.next_order = MQ.next_order + 1;
	return MQ.next_order;
end

function MountQ:OnProfileChanged()
	MQ.Debug("Profile changed");
	MQ.Debug("Scale "..MQ.db.profile.Scale);
end

function MountQ:CreateOpt()
  local profile = MQ.db.profile
	local options = { name = "MountQ", type = "group", childGroups = "tab", order = OrderConf(0) };

	local optargs = {};

	optargs["header1"] = { name = "MountQ Configuration - "..MQ.VERSION.." - "..#MQ.KnownMounts.." Total Mounts - "..#profile.GroundList+#profile.FlyList.." Favored", type = "header", order = OrderConf() }

	optargs["mounts"] = { name = "Mounts", type = "group", childGroups = "tree", order = OrderConf(), get = MQ.GetMountToggle, set = MQ.SetMountToggle }
	optargs["config"] = { name = "Config", type = "group", childGroups = "tree", order = OrderConf() }

	optargs["config"]["args"] = MountQ:CreateConfig();
	optargs["mounts"]["args"] = MountQ:CreateOptMounts();
	options["args"] = optargs;

--	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(MQ.db)

	return options;
end

function MountQ:CreateOptMounts()
  local profile = MQ.db.profile
	local SortString = "";
	if MQ.db.profile.SortType == MQ.SORT_ALPHABETIC then
		SortString = "Sort by Type";
	elseif MQ.db.profile.SortType == MQ.SORT_TYPE then
		SortString = "Sort Alphabetic";
	end

	local DisplayString = "";
	local DisplayText = "";
	if profile.DisplayType == MQ.DISPLAY_FLYING then
		DisplayString = "Show Ground Mounts";
		DisplayText = "Currently Showing Flying Mounts";
	elseif profile.DisplayType == MQ.DISPLAY_GROUND then
		DisplayString = "Show Flying Mounts";
		DisplayText = "Currently Showing Ground Mounts";
	end

	local optmounts = {};

	local favorite = profile.FavoriteMount;
	if favorite == nil then
		favorite = "(ctrl click a mount below to set)	"..DisplayText;
	else
		favorite = favorite.." (ctrl click bar to mount, or name below to set)"..DisplayText;
	end
	optmounts["favorite"] = { name = "Favorite Mount: "..favorite, type = "description", order = OrderConf() }

	optmounts["displaytype"] = { name = DisplayString, desc = DisplayString, type = "execute", order = OrderConf(), func = function() MQ.ToggleDisplayType() end }

	optmounts["sorttype"] = { name = SortString, desc = "Sort by Name/Type", type = "execute", order = OrderConf(), func = function() MQ.ToggleSortType() end }

	optmounts["checkall"] = { name = "Toggle All On/Off", desc = "Toggle all mounts in all categories on or off", type = "execute", confirm = true, order = OrderConf(), func = function() MQ.ToggleAll() end }

	if MQ.db.profile.SortType == MQ.SORT_ALPHABETIC then
		optmounts["header2"] = { name = "MountQ Mount List", type = "header", order = OrderConf() }

		for i, j in pairs(MQ.KnownMounts) do
			local flying = MountQData_IsFlier(j[1]);
			local ground = MountQData_IsGround(j[1]);
			if (flying == true and profile.DisplayType == MQ.DISPLAY_FLYING) or (ground == true and profile.DisplayType == MQ.DISPLAY_GROUND) then
				local mount = j[1];
				local icon = MountQData_GetIcon(j[1]);
				optmounts[mount] = {name = mount, type = "toggle", order = OrderConf(), arg = mount, image = icon }
			end
		end
	else
		local SortList = {};
		local SubCatCounts = {};
		for i, j in pairs(MQ.KnownMounts) do
			-- Mountlist is name, spellid, icon
			local mount = j[1];
			local spellid = j[2];
			local mounticon = MountQData_GetIcon(j[1]);
			local flying = MountQData_IsFlier(j[1]);
			local ground = MountQData_IsGround(j[1]);
			if (flying == true and profile.DisplayType == MQ.DISPLAY_FLYING) or (ground == true and profile.DisplayType == MQ.DISPLAY_GROUND) then
				local categories = MountQData_GetCatList(spellid, j[1]);
				local _
				for _, mounttype in pairs(categories) do
					local category = mounttype[1];
					local subcategory = mounttype[2];
					table.insert(SortList, 1, {category, subcategory, i, mount, mounticon});

					if subcategory ~= MountQGeneralType then
						if SubCatCounts[subcategory] == nil then
							SubCatCounts[subcategory] = 1
						else
							SubCatCounts[subcategory] = SubCatCounts[subcategory] + 1;
						end
					end
				end
			end
		end
		for i,j in pairs(SubCatCounts) do
			if j < MQ.MinSubCategoryCount then
				SubCatToGeneral(SortList, i);
			end
		end
		table.sort(SortList, CategorySort);
		for i,j in pairs(SortList) do
			local category = j[1];
			if optmounts[category] == nil then
				local count = GetCatCount(j[1], SortList);
				optmounts[category] = { name = category.." ["..count.."]", type = "group", order = OrderConf(), childGroups = "tree" };
				optmounts[category]["args"] = {};

				optmounts[category]["args"]["checkcat"..category] = { name = "Toggle Below On/Off", desc = "Toggle all mounts listed below on/off.", type = "execute", order = OrderConf(), func = MQ.ToggleCatMounts, arg = category  }
			end
			local subcategory = j[2];
			if optmounts[category]["args"][subcategory] == nil then
				optmounts[category]["args"][subcategory] = { name = subcategory, type = "header", order = OrderConf() }
			end
			optmounts[category]["args"][j[4]] = { name = j[4], type = "toggle", order = OrderConf(), arg = j[4], image = j[5] };
		end
	end

	return optmounts;
	
end

function MountQ:CreateConfig()
	local optconfig = {};
	optconfig["scale"] = { name = "Menu Scale", desc = "Size of the menu bar", type = "range", min = 0.5, max = 1.5, step = 0.05, get = function() return MQ.db.profile.Scale end, set = MQ.MenuScale, order = OrderConf() };

--	optconfig["fly"] = { name = "Allow in Flight", desc = "Safe Flight", type = "toggle", order = OrderConf(), get = function() return MQ.db.profile.AllowFly; end, set = function(key, val) MQ.db.profile.AllowFly = val; end }

	optconfig["map"] = { name = "Minimap Icon", desc = "Toggle Minimap icon", type = "toggle", order = OrderConf(), get = function () return not MQ.db.global.minimap.hide end, 
	      set = function(_, val) 
		      MQ.db.global.minimap.hide = not val;
		      if val then
			      LibIcon:Show(appName);
		      else
			      LibIcon:Hide(appName);
		      end
	      end }

	optconfig["modifiershow"] = { name = "Modifier to Show Dropdown", desc = "Show mount list only when this modifier is pressed", type = "select", order = OrderConf(), style = "dropdown", values = {"None", "Control", "Shift", "Alt"}, get = function () return MQ.db.global.mod end, set = function(key, val) MQ.db.global.mod = val; end}

	optconfig["modifierother"] = { name = "Modifier to Show Ground/Flying", desc = "Show opposite mount list (ie, ground when flying available) when this modifier is pressed. Checks only as you open the menu.", type = "select", order = OrderConf(), style = "dropdown", values = {"None", "Control", "Shift", "Alt"}, get = function () return MQ.db.global.modother end, set = function(key, val) MQ.db.global.modother = val; end}

	return optconfig;
end

function MQ.MenuScale(key, val)
	MQ.db.profile.Scale = val;
end

-- Scale, Min number subgroups, 
-- Unregister events for stealth and invis when off
