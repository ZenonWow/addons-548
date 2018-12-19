--
-- PrefixTable
--
-- Simple class for storing prefixes and their matches.
-- No duplicate values allowed for any given prefix.
--
-- Usage:
-- initialize:
--     table_name = PrefixTable::New()
-- add a key:
--     VAL = { test = "test" }
--     table_name:Add("fear", VAL)
-- check if a prefix exists:
--     if (table_name:Exists("fear"))
-- get a list of spells that match a given string:
--     list = table_name:GetList("fear")
-- clear the table:
--     table_name:Clear()

-- Global scope for methods.
PrefixTable = {}

-- Upvalues
local _UTIL = FitzUtils

-- The empty value returned--no need to create new memory every time.
local _EMPTY = {}

--
-- Members of the PrefixTable class
--

-- Global factory method to create PrefixTables.
function PrefixTable:New()
   local prefix_table = {}
   setmetatable(prefix_table, self)
   self.__index = self
   prefix_table.ptable = {}
   return prefix_table
end

-- Add the prefix and spell (key and value, respectively) to the table.
-- If the prefix already exists in table, then retrieve the list, append
-- the spell to the end of it, and assign it back to the prefix in the table.
local function AddPrefix(prefix_table, prefix, value)
   if prefix_table[prefix] then
      -- Check to see if value already in the prefix table; disallow dups.
      -- TODO: Fix this; as written, it is expensive.
      for i = 1, _UTIL:NumKeys(prefix_table[prefix]), 1 do
         if _UTIL:IsEqual(prefix_table[prefix][i], value) then
            return
         end
      end
      -- New value; insert.
      table.insert(prefix_table[prefix], value)
   else
      prefix_table[prefix] = { value }
   end
end

-- Add a key/value to the table.  This generates prefix strings based on
-- the passed in key, starting with the first letter and growing until we are
-- adding the entire key as a prefix.
function PrefixTable:Add(key, value)
   assert(key ~= nil, "the key must be defined")
   assert(value ~= nil, "the value must be defined")
   assert(type(key) == "string", "the key must be of type string")
   assert(string.len(key) > 0, "the key must have length > 0")
   

   -- For each prefix in key, call AddPrefix
   local prefix = ""
   for i = 1, string.len(key), 1 do
      prefix = string.sub(key, 1, i)
      AddPrefix(self.ptable, prefix, value)
   end
end

-- Check if the prefix already exists in the table.
-- Return true if it does exist.
function PrefixTable:Exists(prefix)
   assert(type(prefix) == "string", "the key must be of type string")
   if self.ptable[prefix] then
      return true
   end
   return false
end

-- Retrieve the list of spells that match the given prefix string.
function PrefixTable:GetList(prefix)
   return _UTIL:DeepCopy(self.ptable[prefix]) or EMPTY
end

-- Clear the table.
function PrefixTable:Clear()
   self.ptable = {}
end

-- Get the number of entries in the table.
function PrefixTable:Size()
   return FitzUtils:NumKeys(self.ptable)
end
