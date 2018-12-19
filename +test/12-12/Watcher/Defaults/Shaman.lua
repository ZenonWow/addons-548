------------
-- SHAMAN --
------------

if (not Watcher) then
    return;
end

if (string.upper(select(2, UnitClass('player'))) ~= "SHAMAN") then
    return;
end

Watcher.defaults.class.Shaman = {
   ["priorityLists"] = {
         [1] = {
         ["spellConditions"] = {};
         ["name"] = "Elemental";
         ["filters"] = {
            [1] = {
               ["specNum"] = 1;
               ["filterType"] = "spec";
            };
         };
      };
      [2] = {
         ["name"] = "Enchancement";
         ["spellConditions"] = {};
         ["filters"] = {
            [1] = {
               ["specNum"] = 2;
               ["filterType"] = "spec";
            };
         };
      };
      [3] = {
         ["name"] = "Restoration";
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
