------------------
-- DEATH KNIGHT --
------------------

if (not Watcher) then
    return;
end

if (string.upper(select(2, UnitClass('player'))) ~= "DEATHKNIGHT") then
    return;
end

Watcher.defaults.class.Deathknight = {
   ["priorityLists"] = {
         [1] = {
         ["spellConditions"] = {};
         ["name"] = "Blood";
         ["filters"] = {
            [1] = {
               ["specNum"] = 1;
               ["filterType"] = "spec";
            };
         };
      };
      [2] = {
         ["name"] = "Frost";
         ["spellConditions"] = {};
         ["filters"] = {
            [1] = {
               ["specNum"] = 2;
               ["filterType"] = "spec";
            };
         };
      };
      [3] = {
         ["name"] = "Unholy";
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
