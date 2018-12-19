--
-- SpellSearch
--
-- WoW addon for searching spells in your Spell Book.
--
--(c) Tessalina of Uldaman
-- dangster@gmail.com
--

-- Module Constants
local _SS_PREFIX_TABLE
local _SS_SLASH_COMMAND_FRAME
local _SS_RESULT_FRAME_MAX = 6

-- 1 = General, 2 = Main Spec
local _SS_TAB_LIST = { 1, 2 }

-- Upvalues, for convenience
local _UTIL        = FitzUtils;
local _MAIN        = SpellSearch;
local _L           = SpellSearch.Text;
local _LC          = string.lower;

-- Disable/enable debug output
_UTIL:SetDebug(false)

-- Handlers for all slash command functionality.
local _HANDLERS = {
   [_L["about"]] = {
      help = _L["SpellSearch allows users to quickly search for spells in " ..
         "SpellBook to learn more about them or drag to their action bars"],
      run  = function()
                _UTIL:Info(_MAIN.AboutString)
             end,
   },
   [_L["help"]] = {
      help = _L["To search for a spell, open your SpellBook and type in " ..
         "all or part of a spell name in the text box that appears at the " ..
            "bottom of the SpellBook. Matching spells will automatically " ..
            "appear in a list. Mouseover the results to view the tooltip, " ..
            "or click on an icon to drag it to your action bar."],
      run = nil,
   },
}

-- Create the spell attribute table for the given spell atttributes. We're not
-- using all of them at them moment, but they may come in handy later.
local function CreateSpellAttributes(spell_name, spell_id, spellbook_id,
                                     tab_name, tab_id)
   -- We'll actually store the tab info in a later release.
   local spell_attributes = { name = spell_name, spell_ID = spell_id,
      spellbook_ID = spellbook_id }
   return spell_attributes
end

-- Scan the user's spells and store them in a prefix table.  Hide any
-- existing search results, since they may no longer be valid.
local function ScanStoreSpells()
   _SS_PREFIX_TABLE = PrefixTable:New()
   -- Scan the user's SpellBook tabs.  For now, the tab list only contains 
   -- the general and main spec tabs (1 and 2, respectively).  Future updates 
   -- to this addon will scan the other (inactive) tabs.
   for i, tab_num in ipairs(_SS_TAB_LIST) do
      local tab_name, texture, offset, tab_num_spells =
         GetSpellTabInfo(tab_num)
      for spell_num = offset + 1, offset + tab_num_spells do
         local spell_name, subtext = GetSpellBookItemName(spell_num, "spell")
         local skill_type, spell_id = GetSpellBookItemInfo(spell_name)
         if spell_id ~= nil then
            local spell_attributes =
               CreateSpellAttributes(spell_name, spell_id, spell_num,
                                     tab_name, tab_num)
            -- Add both the proper spell name and lowercased spell name to the
            -- prefix table.  We need the lowercased name because most users 
            -- won't bother capitalizing their search terms and it'd be easier
            -- to match two lowercased strings.  However, some languages don't
            -- support lowercase, so we do need the original spell name in that
            -- case.
            _SS_PREFIX_TABLE:Add(spell_name, spell_attributes)
            _SS_PREFIX_TABLE:Add(_LC(spell_name), spell_attributes)
         end
      end
   end
   _MAIN:HideSpellFrameResults()
end

-- Search for spells that begin with the argument string.  We'll automatically
-- capitalize the first letter in the search string, since the spell names
-- are stored that way in the prefix table.
function _MAIN:SearchSpell(search_string)
   _UTIL:Debug("Searching for \"" .. search_string .. "\" ...")
   _MAIN:HideSpellFrameResults()
   local result_list = {}
   if _SS_PREFIX_TABLE:Exists(search_string) then
      result_list = _SS_PREFIX_TABLE:GetList(search_string)
   elseif _SS_PREFIX_TABLE:Exists(_LC(search_string)) then
      result_list = _SS_PREFIX_TABLE:GetList(_LC(search_string))
   end
   if (#result_list > 0) then
      if (#result_list <= _SS_RESULT_FRAME_MAX) then
         _MAIN:UpdateSpellFrameResults(result_list)
      else
         _UTIL:Debug(_L["Too many results"])
         _MAIN:DisplayResultText("Too many results")
      end
   else
      _UTIL:Debug(_L["No spells found!"])
      _MAIN:DisplayResultText("No spells found!")
   end
end

--
-- Slash Commands
--

-- Helper to create help output from the command table.
local function HelpCmdHelper(cmd_tbl, s, prefix)
   prefix = prefix or ""
   for cmd,v in pairs(cmd_tbl) do
      if v.help then
         print(table.concat( { s.._UTIL:ColorText(prefix..cmd),
                               s.." "..v.help },
                             "\n"))
      else
         print(HelpCmdHelper(v, s, cmd.." "))
      end
   end
end

-- Dispatch, based off of ideas in "World of Warcraft Programmng 2nd Ed"
-- These variables are set in global scope.
SLASH_SPELLSEARCH1 = _L["/spellsearch"]
SLASH_SPELLSEARCH2 = _L["/ss"]

local function HandleSlashCmd(msg, tbl)
   local cmd, param = string.match(msg, "^(%w+)%s*(.*)$")
   cmd = cmd or ""
   local e = tbl[cmd:lower()]
   if not e or cmd == _L["help"] then
      -- Not recognized, output slash command help.
      _UTIL:Info(SLASH_SPELLSEARCH1)
      _UTIL:Info(SLASH_SPELLSEARCH2)
      HelpCmdHelper(_HANDLERS, "      ")
   elseif e.run then
      e.run(param)
   else
      HandleSlashCmd(param or "", e)
   end
end

-- Register commands.
SlashCmdList["SPELLSEARCH"] = function (msg) HandleSlashCmd(msg, _HANDLERS) end

-- Register the events.  The only event that matters is SPELLS_CHANGED, which
-- is fired whenever the user logs in, changes spec, resets spec, learns a
-- new spell, resets talents, etc.
local function HandleEvents()
   _SS_SLASH_COMMAND_FRAME = CreateFrame("FRAME", "SpellSearchCLIFrame")
   _SS_SLASH_COMMAND_FRAME:RegisterEvent("SPELLS_CHANGED")
   _SS_SLASH_COMMAND_FRAME:SetScript("OnEvent", ScanStoreSpells)
end


-- Initialize the addon.  Called only after "ADDON_LOADED" event fires.
local function Init()
   _UTIL:Debug("Initializing SpellSearch. . . ")
   local version = GetAddOnMetadata("SpellSearch", "Version")
   _MAIN.TitleString =  _L["SpellSearch"].." v"..version
   _MAIN.AboutString = _MAIN.TitleString.._L[", by Tessalina of Uldaman US"]
   HandleEvents()
   _MAIN:CreateUI()
   _UTIL:Info(_MAIN.TitleString.._L[" loaded successfully!  Type /ss for options."])
   _UTIL:Debug("SpellSearch Initialized!")
end

-- Kick off addon init.
Init()
