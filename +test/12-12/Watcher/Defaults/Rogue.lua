-----------
-- ROGUE --
-----------

if (not Watcher) then
    return;
end

if (string.upper(select(2, UnitClass('player'))) ~= "ROGUE") then
    return;
end


Watcher.defaults.class.Rogue = {
   ["priorityLists"] = {
         [1] = {
         ["spellConditions"] = {};
         ["name"] = "Assassination";
         ["filters"] = {
            [1] = {
               ["specNum"] = 1;
               ["filterType"] = "spec";
            };
         };
      };
      [2] = {
         ["name"] = "Combat";
         ["spellConditions"] = {};
         ["filters"] = {
            [1] = {
               ["specNum"] = 2;
               ["filterType"] = "spec";
            };
         };
      };
      [3] = {
         ["name"] = "Subtlety";
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
