------------
-- PRIEST --
------------

if (not Watcher) then
    return;
end

if (string.upper(select(2, UnitClass('player'))) ~= "PRIEST") then
    return;
end


Watcher.defaults.class.Priest = {
   ["priorityLists"] = {
         [1] = {
         ["spellConditions"] = {};
         ["name"] = "Discipline";
         ["filters"] = {
            [1] = {
               ["specNum"] = 1;
               ["filterType"] = "spec";
            };
         };
      };
      [2] = {
         ["name"] = "Holy";
         ["spellConditions"] = {};
         ["filters"] = {
            [1] = {
               ["specNum"] = 2;
               ["filterType"] = "spec";
            };
         };
      };
      [3] = {
         ["name"] = "Shadow";
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
