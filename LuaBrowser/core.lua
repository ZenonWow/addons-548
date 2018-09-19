local modName = "LuaBrowser";
local core = CreateFrame("Frame",modName,UIParent);
local rawget = rawget;
local type = type;

-- Global Chat Message Function
function AzMsg(msg) DEFAULT_CHAT_FRAME:AddMessage(tostring(msg):gsub("|1","|cffffff80"):gsub("|2","|cffffffff"),0.5,0.75,1.0); end

-- Settings
local filter;
local sortMethod = "type";
local typeFilter = {};

-- Constants
local ITEM_HEIGHT;
local NUM_ITEMS = 12;

-- Work Variables
local root;
local history = {};
local data = {};
local rootTypes = {};
local metaParent;

-- Data
local sortMethods = { "none", "type", "name", "data" };
local typeList = {
	["nil"]			= { color = "|cffc0c0c0", icon = "Interface\\Icons\\Spell_Shadow_MindTwisting" },
	["function"]	= { color = "|cffff5000", icon = "Interface\\Icons\\Inv_Misc_SummerFest_BrazierRed" },
	["string"]		= { color = "|cff00ff00", icon = "Interface\\Icons\\Inv_Misc_SummerFest_BrazierGreen" },
	["number"]		= { color = "|cff00c0ff", icon = "Interface\\Icons\\Inv_Misc_SummerFest_BrazierBlue" },
	["boolean"]		= { color = "|cffff60ff", icon = "Interface\\Icons\\Ability_Creature_Disease_05" },
	["table"]		= { color = "|cffffff00", icon = "Interface\\Icons\\Inv_Misc_SummerFest_BrazierOrange" },
	["userdata"]	= { color = "|cffffffff", icon = "Interface\\Icons\\Spell_DeathKnight_AntiMagicZone" },
	["widget"]		= { color = "|cff00dbba", icon = "Interface\\Icons\\Ability_Druid_LunarGuidance" },
};

-- Show all types
for k in next, typeList do
	typeFilter[k] = true;
end

--------------------------------------------------------------------------------------------------------
--                                          Helper Functions                                          --
--------------------------------------------------------------------------------------------------------

-- Own version of type() which detects widgets
local function datatype(v)
	local dType = type(v);
	if (dType == "table") and (rawget(v,0)) and (type(v[0]) == "userdata") then
		return "widget";
	else
		return dType;
	end
end

-- Sorts Entries
local function SortEntriesFunc(a,b)
	if (sortMethod == "type") then
		local infoA, infoB = datatype(rawget(root,a)), datatype(rawget(root,b));
		if (infoA ~= infoB) then
			return infoA < infoB;
		end
	elseif (sortMethod == "data") then
		local infoA, infoB = rawget(root,a), rawget(root,b);
		if (infoA ~= infoB) then
			return tostring(infoA) < tostring(infoB);
		end
	end
	return tostring(a) < tostring(b);
end

-- Counts Number of Entries
local function GetTableEntries(tbl)
	local cnt = 0;
	for _ in next, tbl do
		cnt = (cnt + 1);
	end
	return cnt;
end

--------------------------------------------------------------------------------------------------------
--                                                Code                                                --
--------------------------------------------------------------------------------------------------------

-- Update List
local function EntryList_Update()
	FauxScrollFrame_Update(core.scroll,#data,#core.entries,ITEM_HEIGHT);
	local index = core.scroll.offset;
	for i = 1, #core.entries do
		index = (index + 1);
		local btn = core.entries[i];
		if (index <= #data) then
			local k = data[index];
			local v = rawget(root,k);
			local dType = datatype(v);
			-- very messy line, but just trying to avoid string garbage
			btn.name:SetFormattedText("%s%s\n|cffc0c0c0%s%s%s",typeList[dType].color,tostring(k),dType,(dType == "table" or dType == "widget") and "; entries = "..GetTableEntries(v) or "",dType == "widget" and "; "..v:GetObjectType() or "");
			btn.value:SetText(tostring(v));
			btn.icon:SetTexture(typeList[dType].icon);
			btn.key = k;
			btn:Show();
		else
			btn:Hide();
		end
	end
	-- Resize
	core.entries[1]:SetPoint("TOPRIGHT",(#data <= #core.entries and -8 or -24),-8);
end

-- Set Filter
local function SetFilter(newFilter)
	filter = newFilter;
	if (filter) then
		core.btnReset:Enable();
	else
		core.btnReset:Disable();
	end
end

-- Set Browsing Root
local function SetRoot(newRoot)
	-- Backup History
	if (root) and (root ~= newRoot) and (#history == 0 or newRoot ~= history[#history].root) then
		history[#history + 1] = { root = root, offset = core.scroll.offset, filter = filter };
		SetFilter(nil);
	end
	-- Copy root to indexed table
	lbRoot = newRoot;
	root = newRoot;
	wipe(data);
	for k, v in next, root do
		local dType = datatype(v);
		if (typeFilter[dType] ~= false) and (not filter or tostring(k):lower():match(filter) or ((dType == "string" or dType == "number") and tostring(v):lower():match(filter))) then
			data[#data + 1] = k;
		end
	end
	-- Header
	local origCount = GetTableEntries(root);
	core.header:SetFormattedText("Lua Browser (|cffffff00%s|r)",(origCount == #data and #data or #data.."|r/|cffffff00"..origCount));
	-- Name
	local frameRoot = (metaParent or root);
	local frameName = (type(frameRoot.GetName) == "function" and tostring(frameRoot:GetName()));
	if (frameName) then
		core.root:SetFormattedText("%s%s|r\n%s",(metaParent and "|cffff00ff" or "|cffffff80"),frameName,tostring(root));
	else
		core.root:SetText(tostring(root));
	end
	-- Fin
	if (sortMethod ~= "none") then
		sort(data,SortEntriesFunc);
	end
	EntryList_Update();
end

-- History: Go Back
local function HistoryGoBack()
	if (#history > 0) then
		local entry = history[#history];
		SetFilter(entry.filter);
		SetRoot(entry.root);
		FauxScrollFrame_OnVerticalScroll(core.scroll,entry.offset * ITEM_HEIGHT,ITEM_HEIGHT,EntryList_Update);
		history[#history] = nil;
	end
end

-- Entry OnClick
local function Entry_OnClick(self,button)
	-- Right
	if (button == "RightButton") then
		if (IsShiftKeyDown()) then
			root[self.key] = nil;
			SetRoot(root);
		else
			HistoryGoBack();
		end
	-- Left
	else
		local v = rawget(root,self.key);
		local dType = type(v);
		-- link value
		local activeEdit = ChatEdit_GetActiveWindow();
		if (IsModifiedClick("CHATLINK")) and (activeEdit and activeEdit:IsVisible()) then
			if (IsControlKeyDown()) then
				activeEdit:Insert(self.key);
			else
				activeEdit:Insert(self.key.." = "..tostring(v));
			end
		-- table
		elseif (dType == "table") then
			if (IsShiftKeyDown()) then
				local mt = getmetatable(v);
				if (mt) then
					metaParent = v;
					core.btnMeta:Enable();
					SetRoot(mt);
				else
					AzMsg("Table has no meta table.");
				end
			else
				SetRoot(v);
			end
		-- function
		elseif (dType == "function") then
			local ret = { v(metaParent or IsShiftKeyDown() and root or nil) };
			if (#ret > 0) then
				SetRoot(ret);
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------
--                                          DropDown - Filter                                         --
--------------------------------------------------------------------------------------------------------

local function DropDown_Init(dropDown,list)
	for typeName, typeTbl in next, typeList do
		local tbl = list[#list + 1];
		tbl.text = typeTbl.color..typeName; tbl.value = typeName; tbl.checked = typeFilter[typeName];
	end
end

local function DropDown_SelectValue(dropDown,entry,index)
	if (IsShiftKeyDown()) then
		for key in next, typeFilter do
			typeFilter[key] = (key == entry.value) or not typeFilter[key];
		end
	else
		typeFilter[entry.value] = not typeFilter[entry.value];
	end
	SetRoot(root);
end

core.dropDown = AzDropDown.CreateDropDown(core,120,nil,DropDown_Init,DropDown_SelectValue);
core.dropDown:SetPoint("BOTTOMLEFT",12,12);
core.dropDown.label:SetText("Type Filter...");

--------------------------------------------------------------------------------------------------------
--                                           DropDown - Sort                                          --
--------------------------------------------------------------------------------------------------------

local function DropDown2_Init(dropDown,list)
	for index, method in ipairs(sortMethods) do
		list[index].text = method; list[index].value = method; list[index].checked = (sortMethod == method);
	end
end

local function DropDown2_SelectValue(dropDown,entry,index)
	sortMethod = entry.value;
	if (sortMethod ~= "none") then
		sort(data,SortEntriesFunc);
		EntryList_Update();
	else
		SetRoot(root);
	end
end

core.dropDown2 = AzDropDown.CreateDropDown(core,120,nil,DropDown2_Init,DropDown2_SelectValue);
core.dropDown2:SetPoint("LEFT",core.dropDown,"RIGHT",8,0);
core.dropDown2.label:SetText("Sort Method...");

--------------------------------------------------------------------------------------------------------
--                                           Widget Creation                                          --
--------------------------------------------------------------------------------------------------------

local function OnMouseDown(self,button)
	if (button == "LeftButton") then
		core:StartMoving();
	end
end

local function OnMouseUp(self,button)
	if (button == "LeftButton") then
		core:StopMovingOrSizing();
	else
		HistoryGoBack();
	end
end

core:SetWidth(520);
core:SetHeight(420);
core:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 } });
core:SetBackdropColor(0.1,0.22,0.35,1);
core:SetBackdropBorderColor(0.1,0.1,0.1,1);
core:EnableMouse(1);
core:SetMovable(1);
core:SetFrameStrata("HIGH");
core:SetToplevel(1);
core:SetPoint("CENTER");
core:Hide();

core:SetScript("OnMouseDown",OnMouseDown);
core:SetScript("OnMouseUp",OnMouseUp);

core.outline = CreateFrame("Frame",nil,core);
core.outline:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
core.outline:SetBackdropColor(0.1,0.1,0.2,1);
core.outline:SetBackdropBorderColor(0.8,0.8,0.9,0.4);
core.outline:SetPoint("TOPLEFT",12,-38);
core.outline:SetPoint("BOTTOMRIGHT",-12,42);

core.close = CreateFrame("Button",nil,core,"UIPanelCloseButton");
core.close:SetPoint("TOPRIGHT",-5,-5);
core.close:SetScript("OnClick",function() core:Hide(); end);

core.header = core:CreateFontString(nil,"ARTWORK","GameFontHighlight");
core.header:SetFont(core.header:GetFont(),24,"THICKOUTLINE");
core.header:SetPoint("TOPLEFT",12,-12);

core.root = core:CreateFontString(nil,"ARTWORK","GameFontHighlight");
core.root:SetFont(core.header:GetFont(),16,"OUTLINE");
core.root:SetPoint("RIGHT",core.close,"LEFT",-8,-1);
core.root:SetJustifyH("RIGHT");

local function RootFrame_OnEnter(self)
	wipe(rootTypes);
	for k, v in next, root do
		local dType = datatype(v);
		rootTypes[dType] = (rootTypes[dType] or 0) + 1;
	end
	GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
	GameTooltip:AddLine("Data Type Count",1,1,1);
	for type, count in next, rootTypes do
		GameTooltip:AddDoubleLine(type,count,nil,nil,nil,1,1,1);
	end
	GameTooltip:Show();
end

core.rootFrame = CreateFrame("Frame",nil,core);
core.rootFrame:SetHeight(20);
core.rootFrame:SetPoint("LEFT",core.root);
core.rootFrame:SetPoint("RIGHT",core.root);
core.rootFrame:EnableMouse(1);
core.rootFrame:SetScript("OnLeave",function(self) GameTooltip:Hide(); end);
core.rootFrame:SetScript("OnEnter",RootFrame_OnEnter);
core.rootFrame:SetScript("OnMouseDown",OnMouseDown);
core.rootFrame:SetScript("OnMouseUp",OnMouseUp);

core.btnRefresh = CreateFrame("Button",nil,core,"UIPanelButtonTemplate");
core.btnRefresh:SetWidth(75);
core.btnRefresh:SetHeight(24);
core.btnRefresh:SetPoint("BOTTOMRIGHT",-12,12);
core.btnRefresh:SetScript("OnClick",function(self) SetRoot(root); end);
core.btnRefresh:SetText("Refresh");

core.btnReset = CreateFrame("Button",nil,core,"UIPanelButtonTemplate");
core.btnReset:SetWidth(75);
core.btnReset:SetHeight(24);
core.btnReset:SetPoint("RIGHT",core.btnRefresh,"LEFT",-6,0);
core.btnReset:SetScript("OnClick",function(self) SetFilter(nil); SetRoot(root); end);
core.btnReset:SetText("Clear Filter");
core.btnReset:Disable();

core.btnMeta = CreateFrame("Button",nil,core,"UIPanelButtonTemplate");
core.btnMeta:SetWidth(75);
core.btnMeta:SetHeight(24);
core.btnMeta:SetPoint("RIGHT",core.btnReset,"LEFT",-6,0);
core.btnMeta:SetScript("OnClick",function(self) metaParent = nil; self:Disable(); end);
core.btnMeta:SetText("Clear Meta");
core.btnMeta:Disable();

-- Create Entries
ITEM_HEIGHT = (core.outline:GetHeight() - 16) / NUM_ITEMS - 1;
core.entries = {};
for i = 1, NUM_ITEMS do
	local e = CreateFrame("Button",nil,core.outline);
	e:SetWidth(ITEM_HEIGHT);
	e:SetHeight(ITEM_HEIGHT);
	e:RegisterForClicks("AnyUp");
	e:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	e:SetScript("OnClick",Entry_OnClick);

	if (i == 1) then
		e:SetPoint("TOPLEFT",8,-8);
		e:SetPoint("TOPRIGHT",-8,-8);
	else
		e:SetPoint("TOPLEFT",core.entries[i - 1],"BOTTOMLEFT",0,-1);
		e:SetPoint("TOPRIGHT",core.entries[i - 1],"BOTTOMRIGHT",0,-1);
	end

	e.icon = e:CreateTexture(nil,"ARTWORK");
	e.icon:SetPoint("TOPLEFT");
	e.icon:SetPoint("BOTTOMLEFT");
	e.icon:SetWidth(ITEM_HEIGHT);
	e.icon:SetTexCoord(0.07,0.93,0.07,0.93);

	e.name = e:CreateFontString(nil,"ARTWORK","GameFontNormal");
	e.name:SetPoint("LEFT",e.icon,"RIGHT",4,0);
	e.name:SetJustifyH("LEFT");

	e.value = e:CreateFontString(nil,"ARTWORK","GameFontNormal");
	e.value:SetPoint("RIGHT",-4,0);
	e.value:SetPoint("LEFT",e.name,"RIGHT",12,0);
	e.value:SetJustifyH("RIGHT");

	core.entries[i] = e;
end

core.scroll = CreateFrame("ScrollFrame",modName.."Scroll",core,"FauxScrollFrameTemplate");
core.scroll:SetPoint("TOPLEFT",core.entries[1]);
core.scroll:SetPoint("BOTTOMRIGHT",core.entries[#core.entries],-6,-1);
core.scroll:SetScript("OnVerticalScroll",function(self,offset) FauxScrollFrame_OnVerticalScroll(self,offset,ITEM_HEIGHT,EntryList_Update) end);

--------------------------------------------------------------------------------------------------------
--                                           Slash Handling                                           --
--------------------------------------------------------------------------------------------------------
_G["SLASH_"..modName.."1"] = "/lb";
_G["SLASH_"..modName.."2"] = "/luabrowser";
SlashCmdList[modName] = function(cmd)
	-- Extract Parameters
	local param1, param2 = cmd:match("^([^%s]+)%s*(.*)$");
	param1 = (param1 and param1:lower() or cmd:lower());
	-- Options
	if (param1 == "") then
		if (#data == 0) then
			SetRoot(_G);
		end
		core:Show();
	-- Mouse
	elseif (param1 == "mouse") then
		SetRoot(GetMouseFocus());
		core:Show();
	-- MouseMeta
	elseif (param1 == "mousemeta") then
		metaParent = GetMouseFocus();
		SetRoot(getmetatable(metaParent));
		core.btnMeta:Enable();
		core:Show();
	-- Code
	elseif (param1 == "code") then
		RunScript("LuaBrowserTemp = "..param2);
		if (type(LuaBrowserTemp) == "table") then
			SetRoot(LuaBrowserTemp);
			core:Show();
		else
			AzMsg("Code result is not a table");
		end
		LuaBrowserTemp = nil;
	-- MetaCode
	elseif (param1 == "codemeta") then
		RunScript("LuaBrowserTemp = "..param2);
		if (type(LuaBrowserTemp) == "table") then
			local meta = getmetatable(LuaBrowserTemp);
			if (meta) then
				metaParent = LuaBrowserTemp;
				core.btnMeta:Enable();
				SetRoot(meta);
				core:Show();
			else
				AzMsg("Table has no meta table");
			end
		else
			AzMsg("Code result is not a table");
		end
		LuaBrowserTemp = nil;
	-- Filter
	elseif (param1 == "filter") then
		SetFilter(param2 ~= "" and param2:lower() or nil);
		SetRoot(root or _G);
		AzMsg("Filter set to |cff00ff00\""..tostring(filter).."\"|r.");
		core:Show();
	-- Invalid or No Command
	else
		UpdateAddOnMemoryUsage();
		AzMsg(format("----- |2%s|r |1%s|r ----- |1%.2f |2kb|r -----",modName,GetAddOnMetadata(modName,"Version"),GetAddOnMemoryUsage(modName)));
		AzMsg("The following |2parameters|r are valid for this addon:");
		AzMsg(" |2mouse|r = Browse GetMouseFocus()");
		AzMsg(" |2mousemeta|r = Browse the metatable of GetMouseFocus()");
		AzMsg(" |2code <code>|r = Browse the return of RunScript(code)");
		AzMsg(" |2codemeta <code>|r = Browse the return of getmetatable(RunScript(code))");
		AzMsg(" |2filter <word>|r = Sets the filter");
	end
end