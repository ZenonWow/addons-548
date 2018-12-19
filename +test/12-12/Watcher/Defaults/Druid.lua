-----------
-- DRUID --
-----------

if (not Watcher) then
    return;
end

if (string.upper(select(2, UnitClass('player'))) ~= "DRUID") then
    return;
end

Watcher.defaults.class.Druid = {
   ["priorityLists"] = {
         [1] = {
         ["spellConditions"] = {};
         ["name"] = "Feral";
         ["filters"] = {
            [1] = {
               ["specNum"] = 1;
               ["filterType"] = "spec";
            };
         };
      };
      [2] = {
         ["name"] = "Balance";
         ["spellConditions"] = {};
         ["filters"] = {
            [1] = {
               ["specNum"] = 2;
               ["filterType"] = "spec";
            };
         };
      };
      [3] = {
         ["name"] = "Guardian";
         ["spellConditions"] = {};
         ["filters"] = {
            [1] = {
               ["specNum"] = 3;
               ["filterType"] = "spec";
            };
         };
      };
      [4] = {
         ["name"] = "Restoration";
         ["spellConditions"] = {};
         ["filters"] = {
            [1] = {
               ["specNum"] = 4;
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
