--
-- SpellSearchUI
--
-- The UI of the SpellSearch addon.  This sets up and updates the visual
-- components of the addon.
--
-- (c) Tessalina of Uldaman
-- dangster@gmail.com
--

-- Module Constants
local _SS_FRAME
local _SS_FRAME_WIDTH = 210
local _SS_FRAME_HEIGHT = 375
local _SS_RESULT_FRAMES
local _SS_RESULT_FRAME_MAX = 6
local _SS_ICON_SIZE = 40
local _SS_RESULT_HEIGHT = 75
local _SS_RESULT_FRAME_HEIGHT = 50
local _SEARCH_PROMPT = "Search for spell..."

-- Upvalues, for convenience
local _UTIL = FitzUtils;
local _MAIN = SpellSearch;

-- Disable/enable debug output
_UTIL:SetDebug(false)

-- Handler for a Spell Icon click. Allows user to pick up a skill from the
-- spellbook so that it can be placed on an action bar.
local function SpellIcon_OnClick(self, button)
   PickupSpellBookItem(self.SS_spell_attr["name"])
end

-- Handler for a Spell Icon mousever. Allows user to view the Tooltip for
-- the given skill.
local function SpellIcon_OnEnter(self, button)
   GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
   if (GameTooltip:SetSpellBookItem(self.SS_spell_attr["spellbook_ID"],
                                    BOOKTYPE_SPELL)) then
      self.UpdateTooltip = SpellButton_OnEnter
   else
      self.UpdateTooltip = nil
   end
end

-- Function for initializing a spell icon button.
local function CreateSpellIcon(id, parent_frame)
   local spell_button = CreateFrame("Button", "SpellButton" .. id,
                                    parent_frame)
   spell_button:SetWidth(_SS_ICON_SIZE)
   spell_button:SetHeight(_SS_ICON_SIZE)
   return spell_button
end

-- Function for modifying a spell icon button. Set up the spell icon image,
-- set the attributes, and set up the action scripts.  Since only the first
-- two tabs are scanned, every spell result is actionable.
-- TODO: Use GetSpellBookItemInfo() check if skilltype = FUTURESPELL, in which
-- case, we call SetDesaturated() on texture to gray it out.
local function UpdateSpellIcon(spell_attr, spell_button)
   local spell_texture = GetSpellTexture(spell_attr["spellbook_ID"],
                                         BOOKTYPE_SPELL)
   spell_button:SetNormalTexture(spell_texture)
   spell_button.SS_spell_attr = spell_attr
   spell_button:RegisterForClicks("LeftButtonUp")
   spell_button:SetScript("OnClick", SpellIcon_OnClick)
   spell_button:SetScript("OnEnter", SpellIcon_OnEnter)
   spell_button:Show()
end

-- Update the result frame by updating the spell icon, then the text.
-- TODO: If skilltype = FUTURESPELL, we gray out the spell name text.
local function UpdateSpellResult(spell_attr, result_frame)
   UpdateSpellIcon(spell_attr, result_frame.icon)
   result_frame.title:SetText(spell_attr["name"])
   result_frame:Show()
end

-- Create an empty result frame.  Set up the button and text. Upon
-- initialization, the result frame isn't shown.
local function CreateSpellResult(id)
   local result_frame = CreateFrame("Frame", "ResultFrame" .. id,
                                    _SS_FRAME.result_list_frame)
   result_frame:SetWidth(_SS_FRAME_WIDTH)
   result_frame:SetHeight(_SS_RESULT_HEIGHT)
   result_frame:SetPoint("TOPLEFT", _SS_FRAME.result_list_frame,
                         "TOPLEFT", 5, 
                         -1 *_SS_RESULT_FRAME_HEIGHT * (id - 1.65))

   -- Set up spell icon button.
   local icon_button = CreateSpellIcon(id, result_frame)
   icon_button:SetPoint("TOPLEFT", result_frame, "LEFT", 0, 0)
   result_frame.icon = icon_button

   -- Set up spell name text.
   result_frame.title = result_frame:CreateFontString("spell_name", "OVERLAY",
                                                      "GameFontNormal")
   result_frame.title:SetPoint("LEFT", 45, -20)

   result_frame:Hide()
   return result_frame
end

-- Initialize the result frames.
local function CreateSpellResultFrames()
   _SS_RESULT_FRAMES = {}
   for id = 1, _SS_RESULT_FRAME_MAX do
      _SS_RESULT_FRAMES[id] = CreateSpellResult(id)
   end
end

-- Resize and re-position the result list frame.  The height and
-- orientation of this frame is dependent on the number of results.
local function ResizeSpellResultFrame(numResults)
   local height = numResults * _SS_RESULT_FRAME_HEIGHT
   local dist_to_bottom = SpellBookFrame:GetBottom()
   -- If the frame height is larger than the distance between the bottom of
   -- the SpellBook and the bottom of the screen, then flip the result list
   -- frame up, so that the results appear above the search box.
   if (height > dist_to_bottom) then
      -- 212 is the offset for the height when placing above the search box.
      _SS_FRAME.result_list_frame:SetPoint("TOPLEFT", _SS_FRAME,
                                           "TOPLEFT", 0, height - 212)
   else
      -- Place 45 below the height center of the addon frame.
      _SS_FRAME.result_list_frame:SetPoint("TOPLEFT", _SS_FRAME,
                                           "LEFT", 0, -45)
   end
   _SS_FRAME.result_list_frame:SetHeight(height)
end


-- Given the result list, update the spell result frames.
function _MAIN:UpdateSpellFrameResults(result_list)
   for n = 1, #result_list do
      local spell_attr = result_list[n]
      UpdateSpellResult(spell_attr, _SS_RESULT_FRAMES[n])
   end
   ResizeSpellResultFrame(#result_list)
   _SS_FRAME.result_list_frame:Show()
end

-- Hide the result frames.
function _MAIN:HideSpellFrameResults()
   for id = 1, _SS_RESULT_FRAME_MAX do
      _SS_RESULT_FRAMES[id]:Hide()
   end
   _SS_FRAME.result_list_frame:Hide()
end

-- Updates the result text.
function _MAIN:DisplayResultText(text)
   _SS_FRAME.result_text:SetText(text)
end

-- Clears the result text.
local function ClearResultText()
   _SS_FRAME.result_text:SetText("")
end

-- Handles the search by getting the current text in the text box, then passing
-- it back to SpellSearch.lua.
local function HandleSearch()
   _UTIL:Debug("HandleSearch")
   local search_string = _SS_FRAME.search_box:GetText()
   _UTIL:Debug("searching for " .. search_string)

   -- Determine if this is a hotkey press or an actual search.
   local key1, key2 = GetBindingKey("TOGGLESPELLBOOK")
   -- HACK HACK HACK
   -- SS_FRAME will store the time when the ToggleSpellBook() is called (see
   -- HandleToggleBookEvent() below).  If the delta (frame shown, first
   -- keypress) == small AND the first keypress is a "p" (or whatever is
   -- stored as the SpellBook keybind), disregard it.
   -- Since OnKeyUp doesn't work for EditFrames, this is the only way to
   -- "consume" this keypress.
   -- We need to compare both the actual search string AND its uppercase
   -- version with the 2 keybinds for opening spellbook, because:
   -- (1) the keybind is always stored as uppercase (even though both the lower
   -- and upper key works), and
   -- (2) not all languages support string.upper() (i.e., can't be uppercased)
   -- so we need to compare the original string as well.
   if (abs(GetTime() - _SS_FRAME.time) < 0.01) and
      (search_string == key1 or string.upper(search_string) == key1 or
       search_string == key2 or string.upper(search_string) == key2) then
      -- nom nom nom hotkey
      search_string = ""
      _SS_FRAME.search_box:SetText(_SEARCH_PROMPT)
      _SS_FRAME.search_box:HighlightText()
   -- Clear the results if we have a search.
   elseif search_string ~= "" and search_string ~= _SEARCH_PROMPT then
      ClearResultText()
      _MAIN:SearchSpell(search_string)
   elseif search_string == "" then
      ClearResultText()
      _MAIN:HideSpellFrameResults()
   end
end

-- Hooked to SpellBookFrame:Hide().  Clears the search results frame.
local function HandleCloseEvent()
   _UTIL:Debug("HandleCloseEvent")
   _MAIN:HideSpellFrameResults()
   ClearResultText()
end

-- Hooked to SpellBookFrame:ToggleSpellBook().  When the user switches between
-- different the bottom SpellBook tabs (Professions, Pets, etc), it hides the
-- SpellSearch frame--unless the current SpellBook tab is the actual
-- SpellBook, of course.
local function HandleToggleBookEvent()
   _UTIL:Debug("HandleToggleBookEvent")
   if SpellBookFrame.bookType ~= BOOKTYPE_SPELL then
      _SS_FRAME:Hide()
   else
      _SS_FRAME.search_box:SetText(_SEARCH_PROMPT)
      _SS_FRAME.search_box:HighlightText()
      _SS_FRAME.result_text:SetText("")
      _SS_FRAME.result_list_frame:Hide()
      _SS_FRAME:Show()
      -- Need to save the time when this event is called.
      _SS_FRAME.time = GetTime()
   end
end

-- Handles the escape keypress.  This closes the SpellBookFrame.
local function HandleEscEvent()
   _UTIL:Debug("HandleEscEvent")
   ToggleSpellBook(SpellBookFrame.bookType)
   return
end

-- Create the UI.
function _MAIN:CreateUI()
   -- Create and position the frame at the bottom of the Spellbook frame.
   _SS_FRAME = CreateFrame("Frame", "SpellSearchFrame", SpellBookFrame,
                          UIPanelScrollFrameTemplate)
   _SS_FRAME:SetFrameStrata("HIGH")
   _SS_FRAME:SetPoint("TOPLEFT", SpellBookFrame, "TOPLEFT", 90, -240)
   _SS_FRAME:SetWidth(_SS_FRAME_WIDTH)
   _SS_FRAME:SetHeight(_SS_FRAME_HEIGHT)

   -- Create the result list frame.
   -- Don't set the position or the length, as that will be set upon search.
   _SS_FRAME.result_list_frame = CreateFrame("Frame", "ResultListFrame",
                                             _SS_FRAME)
   _SS_FRAME.result_list_frame:SetFrameStrata("HIGH")
   _SS_FRAME.result_list_frame:SetWidth(_SS_FRAME_WIDTH)

   -- Set the backdrop and border for the result list.
   _SS_FRAME.result_list_frame:SetBackdrop( {
              bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
              edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
              tile = true, tileSize = 10, edgeSize = 10,
              insets = { left = 4, right = 4, top = 4, bottom = 4 }});
   _SS_FRAME.result_list_frame:SetBackdropColor(0, 0, 0, 1)

   -- Set the search text box.
   -- This offset is needed to make things look nicer.
   local offset = 5
   _SS_FRAME.search_box = CreateFrame("EditBox", "SearchBox", _SS_FRAME,
                                     "InputBoxTemplate")
   _SS_FRAME.search_box:SetSize(_SS_FRAME_WIDTH - offset, 20)
   _SS_FRAME.search_box:SetPoint("TOPLEFT", _SS_FRAME, "LEFT", offset, -25)
   _SS_FRAME.search_box:SetFocus(true)
   _SS_FRAME.search_box:EnableKeyboard(true)
   _SS_FRAME.search_box:SetScript("OnTextChanged", HandleSearch)
   _SS_FRAME.search_box:SetScript("OnEscapePressed", HandleEscEvent)

   -- Set the result text.  This will display any messages about the search
   -- results (no results or too many to display).
   _SS_FRAME.result_text = _SS_FRAME:CreateFontString("result_string",
                                                      "OVERLAY",
                                                      "GameFontNormal")
   _SS_FRAME.result_text:SetPoint("TOPLEFT", _SS_FRAME, "LEFT", 5, -50)

   -- Initialize the result frames.
   CreateSpellResultFrames()

   -- Hooks for hiding and switching between spellbooks.
   hooksecurefunc(SpellBookFrame, "Hide", HandleCloseEvent)
   hooksecurefunc("ToggleSpellBook", HandleToggleBookEvent)
 end
