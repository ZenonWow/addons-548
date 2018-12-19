-------------
-- WARLOCK --
-------------

if (not Watcher) then
    return;
end

if (string.upper(select(2, UnitClass('player'))) ~= "WARLOCK") then
    return;
end

Watcher.defaults.class.Warlock = {
   ["priorityLists"] = {
         [1] = {
         ["spellConditions"] = {};
         ["name"] = "Affliction";
         ["filters"] = {
            [1] = {
               ["specNum"] = 1;
               ["filterType"] = "spec";
            };
         };
      };
      [2] = {
         ["name"] = "Demonology";
         ["spellConditions"] = {};
         ["filters"] = {
            [1] = {
               ["specNum"] = 2;
               ["filterType"] = "spec";
            };
         };
      };
      [3] = {
         ["name"] = "Destruction";
         ["spellConditions"] = {};
         ["filters"] = {
            [1] = {
               ["specNum"] = 3;
               ["filterType"] = "spec";
            };
         };
      };

   };
   ["spells"] = {
   };
   ["filterSets"] = {
   };
};
