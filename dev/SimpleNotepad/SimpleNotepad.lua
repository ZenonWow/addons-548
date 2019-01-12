
-- SIMPLENOTEPAD --
-- Written by Jaxom of Hellfire --
-- All rights Reserved --

SimpleNotepad_Version = GetAddOnMetadata("SimpleNotepad", "Version")

-- DEFAULTS --

local playerName = UnitName("player");		
local guildName = GetGuildInfo("player");    
local self = SimpleNotepad;  

-- ON LOAD --

function SimpleNotepad_OnLoad()

    
     -- SIDE BUTTONS START --
        
        PanelTemplates_SetNumTabs(SimpleNotepadFrame, 5);  -- 5 = frames total. --
        PanelTemplates_SetTab(SimpleNotepadFrame, 1);      -- 1 = tab 1 selected. --
        SimpleNotepadEditBoxN:Show();  -- Show page 1.
        SimpleNotepadEditBoxC:Hide();  -- Hide all other pages. --
        SimpleNotepadEditBoxP:Hide();
        SimpleNotepadEditBoxT:Hide();
        SimpleNotepadEditBoxR:Hide();
        
        
        -- FRAME SIZE SETTINGS --
        
        SimpleNotepadFrame:SetMinResize(315,150);
        SimpleNotepadFrame:SetMaxResize(550,550);
        
        -- REGISTER EVENTS --
        
        SimpleNotepad:RegisterEvent("VARIABLES_LOADED");
        SimpleNotepad:RegisterEvent("STORETEXT");
        SimpleNotepad:RegisterEvent("ONTEXTCHANGED");
        SimpleNotepad:RegisterEvent("UPDATE");
        SimpleNotepad:RegisterEvent("GETTEXT");
        SimpleNotepad:RegisterEvent("SETTEXT");
        SimpleNotepad:RegisterEvent("ONFOCUS");
        SimpleNotepad:RegisterEvent("SETFOCUS");
        SimpleNotepad:RegisterEvent("CLEARFOCUS");
        SimpleNotepad:RegisterEvent("ONSHOW");
        SimpleNotepad:RegisterEvent("ONHIDE");
        SimpleNotepad:RegisterEvent("ONCLICK");
        SimpleNotepad:RegisterEvent("REGISTERFORDRAG");
        
	    table.insert(UISpecialFrames,"SimpleNotepadFrame");    
               
        -- SLASH COMMANDS --
        
        SlashCmdList["SIMPLENOTEPAD"] = function(sMsg)
			SimpleNotepad_Slash_Command(sMsg)
		end
		SLASH_SIMPLENOTEPAD1 = "/snp";
end
        


function SimpleNotepad_Loaded()
    if SimpleNotepad_Vars == nil then
        SimpleNotepad_Vars = SimpleNotepad_Defaults
        DEFAULT_CHAT_FRAME:AddMessage("SimpleNotepad Text database not found. Generating Defaults...");
        end
    if (SimpleNotepad_Vars["version"] < SimpleNotepad_Version) then
        SimpleNotepad_Vars_temp = SimpleNotepad_Defaults;
        for k,v in SimpleNotepad_Vars do
    if (SimpleNotepad_Defaults["Vars"][k]) then
        SimpleNotepad_Vars_temp[k] = v;
     end
  end
        SimpleNotepad_Vars_temp["version"] = SimpleNotepad_Version;
        SimpleNotepad_Vars = SimpleNotepad_Vars_temp;
    end
end



-- EVENT FUNCTIONS --

function SimpleNotepad_OnEvent(event, self, ...)
        if event == "VARIABLES_LOADED" then
            
		SimpleNotepad_Vars.NOTES_TEXT = tostring(SimpleNotepad_Vars.NOTES_TEXT);
		if SimpleNotepad_Vars.NOTES_TEXT == "nil" then
			SimpleNotepad_Vars.NOTES_TEXT = "";
		end
		
		SimpleNotepad_Varsc.CHAR_TEXT = tostring(SimpleNotepad_Varsc.CHAR_TEXT);
		if SimpleNotepad_Varsc.CHAR_TEXT == "nil" then
			SimpleNotepad_Varsc.CHAR_TEXT = "";
		end
        
        SimpleNotepad_Vars.PROFF_TEXT = tostring(SimpleNotepad_Vars.PROFF_TEXT);
		if SimpleNotepad_Vars.PROFF_TEXT == "nil" then
			SimpleNotepad_Vars.PROFF_TEXT = "";
		end
        
        SimpleNotepad_Vars.TODO_TEXT = tostring(SimpleNotepad_Vars.TODO_TEXT);
		if SimpleNotepad_Vars.TODO_TEXT == "nil" then
			SimpleNotepad_Vars.TODO_TEXT = "";
		end
        
        SimpleNotepad_Vars.RTIT_TEXT = tostring(SimpleNotepad_Vars.RTIT_TEXT);
		if SimpleNotepad_Vars.RTIT_TEXT == "nil" then
			SimpleNotepad_Vars.RTIT_TEXT = "";
        end
        
        SimpleNotepad_Vars.Lock = tostring(SimpleNotepad_Vars.Lock);
        if SimpleNotepad_Vars.Lock == "nil" then
            SimpleNotepad_Vars.Lock = "";
        end 
        
        SimpleNotepad_Vars.MinimapPos = tostring(SimpleNotepad_Vars.MinimapPos);
        if SimpleNotepad_Vars.MinimapPos == "nil" then
            SimpleNotepad_Vars.MinimapPos = "";
        end   
         
        
        SimpleNotepad_UpdateLock();
        SimpleNotepad_Loaded();
        SimpleNotepad_SetText();
        
        
    end 
end


-- FRAME STARTS HERE --

    -- SHOW FRAME --    
function SimpleNotepad_OnShow(self)
    SimpleNotepad_UpdateLock();
    SimpleNotepadFrame:Show();
    SimpleNotepad_Update();
    SimpleNotepad_SetText();
end

    -- TOGGLES FRAME USEING SLASH COMMAND --
function SimpleNotepad_Slash_Command(sMsg)
	if SimpleNotepadFrame:IsVisible() then
		SimpleNotepadFrame:Hide();
	else
		SimpleNotepadFrame:Show();
	end
end

    -- MOVES FRAME --
function SimpleNotepad_OnMouseDown(self)
    if Button == "RightButton" then
	    SimpleNotepadFrame:StartMoving();
    end
end

function SimpleNotepad_OnMouseUp(self)
	if Button == "RightButton" then
	SimpleNotepadFrame:StopMovingOrSizing();
	end
end

         

-- CHANGE BORDER AND RESIZE GRIP LOCK STATUS --
function SimpleNotepad_UpdateLock()
	if SimpleNotepad_Vars.Lock == true then
		SimpleNotepadResizeGrip:Hide();
        SimpleNotepadFrame:SetBackdropBorderColor(0,0,0,1)
        else
		SimpleNotepadFrame:SetBackdropBorderColor(1,1,1,1)
		SimpleNotepadResizeGrip:Show()
	end
	SimpleNotepad_MakeESCable("SimpleNotepadFrame",SimpleNotepad_Vars.Lock)
end

-- REMOVES FRAME IF DISABLE TRUE --
function SimpleNotepad_MakeESCable(frame,disable)
	local idx
	for i=1,#(UISpecialFrames) do
		if UISpecialFrames[i]==frame then
			idx = i
			break
		end
	end
	if idx and disable then
		table.remove(UISpecialFrames,idx)
	elseif not idx and not disable then
		table.insert(UISpecialFrames,1,frame)
	end
end

    -- ON TEXT CHANGE ADJUST SCROLL BAR --
function SimpleNotepad_OnTextChanged(self)
	local scrollBar = getglobal(self:GetParent():GetName().."ScrollBar")
	self:GetParent():UpdateScrollChildRect()
	local min, max = scrollBar:GetMinMaxValues()
	if self.max and max > self.max and abs(self.max - floor(scrollbar:GetValue())) < 0.001 then
		scrollbar:SetValue(max)
		self.max = max
	end
end



-- TEXT FUNCTIONS --


function SimpleNotepad_Update()
	-- set current page name & contents --
	if (SimpleNotepadEditBoxN:IsShown()) then
		SimpleNotepadPageName:SetText("Simple Notepad: Notes  " ..SimpleNotepad_Version.."");
        SimpleNotepadEditScrollFrame:SetScrollChild(SimpleNotepadEditBoxN);
        end
	if (SimpleNotepadEditBoxC:IsShown()) then
		SimpleNotepadPageName:SetText("Simple Notepad: " .. playerName .. "'s Notes");
        SimpleNotepadEditScrollFrame:SetScrollChild(SimpleNotepadEditBoxC);
        end
    if (SimpleNotepadEditBoxP:IsShown()) then
        SimpleNotepadPageName:SetText("Simple Notepad: Professions");
        SimpleNotepadEditScrollFrame:SetScrollChild(SimpleNotepadEditBoxP);
        end
    if (SimpleNotepadEditBoxT:IsShown()) then
        SimpleNotepadPageName:SetText("Simple Notepad: Things To Do");
        SimpleNotepadEditScrollFrame:SetScrollChild(SimpleNotepadEditBoxT);
        end
    if (SimpleNotepadEditBoxR:IsShown()) then
        SimpleNotepadPageName:SetText("Simple Notepad: Raid Notes");
        SimpleNotepadEditScrollFrame:SetScrollChild(SimpleNotepadEditBoxR);
    end
        SimpleNotepadEditBoxN:SetWidth(SimpleNotepadFrame:GetWidth()-50)
        SimpleNotepadEditBoxC:SetWidth(SimpleNotepadFrame:GetWidth()-50)
        SimpleNotepadEditBoxP:SetWidth(SimpleNotepadFrame:GetWidth()-50)
        SimpleNotepadEditBoxT:SetWidth(SimpleNotepadFrame:GetWidth()-50)
        SimpleNotepadEditBoxR:SetWidth(SimpleNotepadFrame:GetWidth()-50)
end

function SimpleNotepad_SetText()
	-- SET EDITBOX TEXT FROM SAVED VARS --
	SimpleNotepadEditBoxN:SetText(SimpleNotepad_Vars.NOTES_TEXT);
	SimpleNotepadEditBoxC:SetText(SimpleNotepad_Varsc.CHAR_TEXT);
    SimpleNotepadEditBoxP:SetText(SimpleNotepad_Vars.PROFF_TEXT);
    SimpleNotepadEditBoxT:SetText(SimpleNotepad_Vars.TODO_TEXT);
    SimpleNotepadEditBoxR:SetText(SimpleNotepad_Vars.RTIT_TEXT);
end

function SimpleNotepad_StoreText(playSoundFx)
	-- SAVE TEXT TO STORED VAR --
	SimpleNotepad_Vars.NOTES_TEXT = SimpleNotepadEditBoxN:GetText();
	SimpleNotepad_Varsc.CHAR_TEXT = SimpleNotepadEditBoxC:GetText();
    SimpleNotepad_Vars.PROFF_TEXT = SimpleNotepadEditBoxP:GetText();
    SimpleNotepad_Vars.TODO_TEXT = SimpleNotepadEditBoxT:GetText();
    SimpleNotepad_Vars.RTIT_TEXT = SimpleNotepadEditBoxR:GetText();
    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Your Note has Been Saved") 
	
	PlaySound("WriteQuest");
	
end


function SimpleNotepad_Cancel()
	-- REVERT TO PREVIOUS TEXT --
	SimpleNotepad_SetText();
    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00All Changes Have Been CANCELLED")
end
 
    
    -- ITEM AND SPELL LINK FUNCTIONS --
    

function SimpleNotepadEditBoxNDrag()
	local infoType, info1, info2 = GetCursorInfo()
	local text = ""
	
	if (infoType == "item") then
		text = info2
	elseif (infoType == "spell") then
        local skillType, spellId = GetSpellBookItemInfo(info1, "player")
        text = GetSpellLink(spellId)
	elseif (infoType == "merchant") then
		text = GetMerchantItemLink(info1)
	elseif (infoType == "macro") then
		text = GetMacroInfo(info1) .. " macro:\n" .. GetMacroBody(info1)
	end
	
	if text ~= "" and SimpleNotepadEditBoxN then
		SimpleNotepadEditBoxN:Insert(text)
	end
	
	ClearCursor()
end



 -- LDB LAUNCHER AND MINIMAP ICON --
 
 --Local-- NOTE: Probably dont need half of these!
    
    local SimpleNotepad_Vars = SimpleNotepad_Vars
    local self = snpldb
    local snpldb = LibStub:GetLibrary("LibDataBroker-1.1")
    local snpldb = LibStub:GetLibrary("LibDBIcon-1.0") 
    
local snpldb = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("SimpleNotepad", {
            type = "launcher",
	        text = "SimpleNotepad",
            tocname = "SimpleNotepad",
            icon = "Interface\\AddOns\\SimpleNotepad\\images\\NotePadL.tga",
            OnClick = function(self, button)
        if (button == "LeftButton") then
           if SimpleNotepadFrame:IsVisible() then
		        SimpleNotepadFrame:Hide()
	        else
		        SimpleNotepadFrame:Show()
	    end
       	elseif (button == "RightButton") then
		    InterfaceOptionsFrame_OpenToCategory("SimpleNotepad") 
            end
        end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine('Simple Notepad')
                tooltip:AddLine('|cffffff00Left click for Simple Notepad')
                tooltip:AddLine('|cffffff00Right Click for Interface Panel')
            end,
        })


   -- MINIMAP BUTTON --
   
local snpicon = LibStub:GetLibrary("LibDBIcon-1.0")
        snpicon:Register("SimpleNotepad", snpldb, SimpleNotepad_Vars["minimap_button"]) 


   -- INTERFACE OPTIONS MENU -- 
    
   -- FRAME 1 --
  
    
	local simplenotepad = CreateFrame("Frame", "SimpleNotepad", UIParent)
	simplenotepad:Hide()
    simplenotepad:IsResizable(true)
    simplenotepad:SetMinResize(350,250)
	simplenotepad.name = "SimpleNotepad"
    simplenotepad:SetBackdropColor(0, 0, 0, 1)
	simplenotepad:SetWidth(250)
	simplenotepad:SetHeight(400)
	simplenotepad:SetPoint("CENTER", UIParent, "CENTER")
	InterfaceOptions_AddCategory(simplenotepad)

	local title = simplenotepad:CreateFontString("SimpleNotepadTitle", "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -20)
	title:SetText("SimpleNotepad ("..SimpleNotepad_Version..")" )
 
    
    local snpEditBox = CreateFrame("EditBox", "SimpleNotepadEditBox", simplenotepad)
    snpEditBox:SetPoint ("TOPLEFT",26,-42)
	snpEditBox:EnableMouse(false)
	snpEditBox:SetAutoFocus(false)
	snpEditBox:SetFontObject(GameFontNormal)
	snpEditBox:SetWidth(450)
	snpEditBox:SetHeight(120)
    snpEditBox:SetText("")
	snpEditBox:Show()
    
    local snpEditBoxText = snpEditBox:CreateFontString("SimpleNotepadEditBoxTitle", "ARTWORK", "GameFontHighlight")
	snpEditBoxText:SetPoint("BOTTOMLEFT", snpEditBox, 5, -5)
	snpEditBoxText:SetWidth(420)
	snpEditBoxText:SetHeight(110)
    snpEditBoxText:SetFontObject(GameFontHighlight)
    snpEditBoxText:SetJustifyH("LEFT")
	snpEditBoxText:SetText("This is a Simple Note Pad. It was designed and built to remember all those things we forget, things like what poisons to put on which dagger when on your rogue. All notes except Character are saved globally so you can access them from any character, Character Notes are saved per Character so you can have character specific notes, Loose focus by clicking Escape or another tab, Drag Spells and Items onto window to create Link. SimpleNotepad has full LDB support, so will work on your Minimap, Norgannas SlideBar, Ttian Panel, Bazzoka etc, or /snp, you choose which to use.                                          |cff00aa00To use click on frame of your choice, type, click save, that simple.")
    
    local snpEditBoxText2 = snpEditBox:CreateFontString("SimpleNotepadEditBoxTitle", "ARTWORK", "GameFontHighlight")
	snpEditBoxText2:SetPoint("BOTTOMLEFT", snpEditBox, 5, -115)
	snpEditBoxText2:SetWidth(420)
	snpEditBoxText2:SetHeight(110)
    snpEditBoxText2:SetFontObject(GameFontHighlight)
    snpEditBoxText2:SetJustifyH("LEFT")
	snpEditBoxText2:SetText("Thank you to Mumm for bugging me to make a simple notepad without any bells and whistles. A special thanks to Gello and Zathras who gave me some new ideas and increased my understanding of xml. |cff007fffJaxom of Hellfire EU")
      

     -- OPTIONS TITLE --
    
    local snptitle = simplenotepad:CreateFontString("SimpleNotepadTitle", "ARTWORK", "GameFontHighlightLarge")
	snptitle:SetPoint("TOPLEFT", 16, -287)
	snptitle:SetText("|cff007fffOptions")       
                    
    -- HIDE MINIMAP BUTTON --
    
    local snpmini = CreateFrame("CheckButton", "SimpleNotepadButton1", simplenotepad)
	snpmini:SetWidth(26)
	snpmini:SetHeight(26)
	snpmini:SetPoint("TOPLEFT", 16, -317)
    snpmini:SetChecked(SimpleNotepad_Vars.minimap_button.hide == false)
    snpmini:SetScript("OnClick", function(self)
            if self:GetChecked() then
            snpicon:Show("SimpleNotepad")
            DEFAULT_CHAT_FRAME:AddMessage("|cff00aa00[SimpleNotepad] - |cff007fffMinimap Button is now ON");
            else
            snpicon:Hide("SimpleNotepad")
            DEFAULT_CHAT_FRAME:AddMessage("|cff00aa00[SimpleNotepad] - |cff007fffMinimap Button is now OFF");
            end
	end--function
    )
    
   
	snpmini:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	snpmini:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	snpmini:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	snpmini:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

	local snpminiText = snpmini:CreateFontString("SimpleNotepadButton1Title", "ARTWORK", "GameFontHighlight")
	snpminiText:SetPoint("LEFT", snpmini, "RIGHT", 0, 2)
	snpminiText:SetText("|CFF00AA00Hide Minimap Button|r")
    
    local snpminiText2 = snpmini:CreateFontString("SimpleNotepadButton1Title", "ARTWORK", "GameFontHighlightSmall")
	snpminiText2:SetPoint("LEFT", snpmini, "RIGHT", 5, -10)
    snpminiText2:SetText("LDB Slidebar Icon and Titan Panel is Available")
    
    -- LOCK THE FRAME SIZER --
    
    local snplock = CreateFrame("CheckButton", "SimpleNotepadButton2", simplenotepad)
	snplock:SetWidth(26)
	snplock:SetHeight(26)
	snplock:SetPoint("TOPLEFT", 16, -357)
    snplock:SetChecked(SimpleNotepad_Vars.Lock == true)
    snplock:SetScript("OnClick", function(self)
            if self:GetChecked() then
            SimpleNotepad_Vars.Lock = (true)
            DEFAULT_CHAT_FRAME:AddMessage("|cff00aa00[SimpleNotepad] - |cff007fffFrame is Now Locked");
            else 
            SimpleNotepad_Vars.Lock = (false)
            DEFAULT_CHAT_FRAME:AddMessage("|cff00aa00[SimpleNotepad] - |cff007fffFrame is Now Unlocked");
         end
      end
	)
	snplock:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	snplock:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	snplock:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	snplock:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

	local snplockText = snplock:CreateFontString("SimpleNotepadButton2Title", "ARTWORK", "GameFontHighlight")
	snplockText:SetPoint("LEFT", snplock, "RIGHT", 0, 2)
	snplockText:SetText("|CFF00AA00Lock SimpleNotepad Frame Sizer.|r")
    
    local snplockText2 = snplock:CreateFontString("SimpleNotepadButton2Title", "ARTWORK", "GameFontHighlightSmall")
	snplockText2:SetPoint("LEFT", snplock, "RIGHT", 5, -10)
    snplockText2:SetText("When Locked the Frame cannot be Resized, but can still be moved")
    
    local snplockText3 = snplock:CreateFontString("SimpleNotepadButton2Title", "ARTWORK", "GameFontHighlight")
	snplockText3:SetPoint("LEFT", snplock, "RIGHT", 5, -25)
    snplockText3:SetText("To Move Frame, Right Click in Title Region")
    
    
    
