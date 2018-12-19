-- Core Localization for SpellSearch
--
-- By default, US English is used.  For translations, redefine
-- variables in the appropriate "GetLocale" block.
--

-- Upvalues
local Main = SpellSearch


-- English (default)
-- No need to define translations, set __index to return index string.
-- Usage example: Main.Text["This is some text"] returns "This is some text"
Main.Text = setmetatable({ }, { __index = function(loc_table, str) return str end })


-- German (example)
-- Usage example: Text.L["good"] returns "gut"
if (GetLocale() == "deDE") then 
   Main.Text = {
      -- Translations here.
      ["good"] = "gut",
   }
end


