------------
-- Hunter --
------------
if (not Watcher) then
	return;
end

if (string.upper(select(2,  UnitClass('player'))) ~=  string.upper('Hunter')) then
	return;
end


Watcher.defaults.class.Hunter = {
   ["priorityLists"] = {
      [1] = {
         ["spellConditions"] = {
            [13] = {
               ["spellId"] = 77767;
               ["filterSetId"] = 17;
            };
            [7] = {
               ["spellId"] = 82692;
               ["filterSetId"] = 36;
            };
            [1] = {
               ["spellId"] = 121818;
               ["filterSetId"] = 39;
            };
            [2] = {
               ["spellId"] = 121818;
               ["filterSetId"] = 38;
            };
            [4] = {
               ["spellId"] = 53351;
               ["filterSetId"] = 16;
            };
            [8] = {
               ["spellId"] = 117050;
               ["filterSetId"] = 30;
            };
            [9] = {
               ["spellId"] = 120679;
               ["filterSetId"] = 34;
            };
            [5] = {
               ["spellId"] = 19574;
               ["filterSetId"] = 27;
            };
            [10] = {
               ["spellId"] = 120697;
               ["filterSetId"] = 33;
            };
            [3] = {
               ["spellId"] = 1978;
               ["filterSetId"] = 26;
            };
            [6] = {
               ["spellId"] = 34026;
               ["filterSetId"] = 29;
            };
            [12] = {
               ["spellId"] = 3044;
               ["filterSetId"] = 28;
            };
            [11] = {
               ["spellId"] = 121818;
               ["filterSetId"] = 11;
            };
         };
         ["name"] = "Beast Mastery";
         ["filters"] = {
            [1] = {
               ["specNum"] = 1;
               ["filterType"] = "spec";
            };
         };
      };
      [2] = {
         ["name"] = "Marksmanship";
         ["spellConditions"] = {};
         ["filters"] = {
            [1] = {
               ["specNum"] = 2;
               ["filterType"] = "spec";
            };
         };
      };
      [3] = {
         ["name"] = "Survival";
         ["spellConditions"] = {
            [7] = {
               ["spellId"] = 117050;
               ["filterSetId"] = 30;
            };
            [1] = {
               ["spellId"] = 121818;
               ["filterSetId"] = 38;
            };
            [2] = {
               ["spellId"] = 121818;
               ["filterSetId"] = 39;
            };
            [4] = {
               ["spellId"] = 53301;
               ["filterSetId"] = 12;
            };
            [8] = {
               ["spellId"] = 3044;
               ["filterSetId"] = 37;
            };
            [9] = {
               ["spellId"] = 120697;
               ["filterSetId"] = 33;
            };
            [5] = {
               ["spellId"] = 53351;
               ["filterSetId"] = 16;
            };
            [10] = {
               ["spellId"] = 120679;
               ["filterSetId"] = 34;
            };
            [3] = {
               ["spellId"] = 1978;
               ["filterSetId"] = 26;
            };
            [6] = {
               ["spellId"] = 3674;
               ["filterSetId"] = 1;
            };
            [12] = {
               ["spellId"] = 77767;
               ["filterSetId"] = 17;
            };
            [11] = {
               ["spellId"] = 3044;
               ["filterSetId"] = 28;
            };
         };
         ["filters"] = {
            [1] = {
               ["specNum"] = 3;
               ["filterType"] = "spec";
            };
         };
      };
   };
   ["spells"] = {
      [34026] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [29] = true;
         };
      };
      [1978] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [3] = true;
            [9] = true;
            [26] = true;
         };
      };
      [82692] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [35] = true;
            [36] = true;
         };
      };
      [19574] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [27] = true;
         };
      };
      [77767] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [17] = true;
         };
      };
      [117050] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [30] = true;
            [31] = true;
            [23] = true;
            [32] = true;
         };
      };
      [120679] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [18] = true;
            [34] = true;
         };
      };
      [53351] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [16] = true;
         };
      };
      [109215] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [20] = true;
         };
      };
      [109248] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [21] = true;
         };
      };
      [3674] = {
         ["settings"] = {
            ["label"] = "d";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [1] = true;
         };
      };
      [131894] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [25] = true;
         };
      };
      [120697] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [19] = true;
            [33] = true;
         };
      };
      [82726] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [24] = true;
         };
      };
      [53301] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [12] = true;
         };
      };
      [120360] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [22] = true;
         };
      };
      [3044] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [14] = true;
            [28] = true;
            [37] = true;
         };
      };
      [121818] = {
         ["settings"] = {
            ["label"] = "bob";
            ["keepEnoughResources"] = false;
         };
         ["filterSetIds"] = {
            [11] = true;
            [39] = true;
            [38] = true;
         };
      };
   };
   ["filterSets"] = {
      [27] = {
         ["spellId"] = 19574;
         ["name"] = "Usable";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [2] = {
         ["spellId"] = 120360;
         ["name"] = "Usable";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [38] = {
         ["spellId"] = 121818;
         ["name"] = "Procs";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
            [2] = {
               ["filterType"] = "auras";
               ["refreshThreshold"] = 0;
               ["auraName"] = "Heroism";
               ["stackCount"] = 0;
               ["playerIsCaster"] = true;
               ["invert"] = true;
               ["isBuff"] = true;
            };
         };
      };
      [3] = {
         ["spellId"] = 1978;
         ["name"] = "Usable";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [4] = {
         ["spellId"] = 121818;
         ["name"] = "Usable";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [5] = {
         ["spellId"] = 53301;
         ["name"] = "Usable";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [6] = {
         ["spellId"] = 53351;
         ["name"] = "Usable";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [7] = {
         ["spellId"] = 3044;
         ["name"] = "Usable";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [8] = {
         ["spellId"] = 77767;
         ["name"] = "Usable";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [10] = {
         ["name"] = "Usable";
         ["spellId"] = 120360;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [12] = {
         ["name"] = "Usable";
         ["spellId"] = 53301;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [14] = {
         ["name"] = "Usable";
         ["spellId"] = 3044;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [16] = {
         ["name"] = "Usable";
         ["spellId"] = 53351;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [20] = {
         ["name"] = "Usable";
         ["spellId"] = 109215;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [24] = {
         ["name"] = "Usable";
         ["spellId"] = 82726;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [28] = {
         ["spellId"] = 3044;
         ["name"] = "Focus Dump";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
            [2] = {
               ["threshold"] = 73;
               ["invert"] = false;
               ["filterType"] = "power";
            };
         };
      };
      [32] = {
         ["spellId"] = 117050;
         ["name"] = "Dire Beast";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
            [2] = {
               ["talentNum"] = 11;
               ["filterType"] = "talent";
            };
         };
      };
      [33] = {
         ["spellId"] = 120697;
         ["name"] = "Lynx Rush";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
            [2] = {
               ["talentNum"] = 15;
               ["filterType"] = "talent";
            };
         };
      };
      [17] = {
         ["name"] = "Usable";
         ["spellId"] = 77767;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [21] = {
         ["name"] = "Usable";
         ["spellId"] = 109248;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [25] = {
         ["name"] = "Usable";
         ["spellId"] = 131894;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [29] = {
         ["spellId"] = 34026;
         ["name"] = "Usable";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [34] = {
         ["spellId"] = 120679;
         ["name"] = "Dire Beast";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
            [2] = {
               ["talentNum"] = 11;
               ["filterType"] = "talent";
            };
         };
      };
      [9] = {
         ["spellId"] = 1978;
         ["name"] = "Test";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [11] = {
         ["name"] = "Usable";
         ["spellId"] = 121818;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [13] = {
         ["name"] = "Usable";
         ["spellId"] = 53351;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [15] = {
         ["name"] = "Usable";
         ["spellId"] = 77767;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [18] = {
         ["name"] = "Usable";
         ["spellId"] = 120679;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [22] = {
         ["name"] = "Usable";
         ["spellId"] = 120360;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [26] = {
         ["name"] = "Dot";
         ["spellId"] = 1978;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
            [2] = {
               ["isBuff"] = false;
               ["refreshThreshold"] = 0;
               ["invert"] = false;
               ["stackCount"] = 0;
               ["playerIsCaster"] = true;
               ["auraName"] = "Serpent Sting";
               ["filterType"] = "auras";
            };
         };
      };
      [30] = {
         ["spellId"] = 117050;
         ["name"] = "Glaive Toss";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
            [2] = {
               ["talentNum"] = 16;
               ["filterType"] = "talent";
            };
         };
      };
      [36] = {
         ["spellId"] = 82692;
         ["name"] = "Frenzy";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
            [2] = {
               ["filterType"] = "auras";
               ["refreshThreshold"] = 0;
               ["auraName"] = "Frenzy";
               ["stackCount"] = 5;
               ["playerIsCaster"] = true;
               ["invert"] = true;
               ["isBuff"] = true;
            };
         };
      };
      [37] = {
         ["spellId"] = 3044;
         ["name"] = "Thrill of the Hunt";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
            [2] = {
               ["filterType"] = "auras";
               ["refreshThreshold"] = 0;
               ["auraName"] = "";
               ["stackCount"] = 0;
               ["playerIsCaster"] = true;
               ["invert"] = false;
               ["isBuff"] = true;
            };
         };
      };
      [39] = {
         ["spellId"] = 121818;
         ["name"] = "Trinket";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
            [2] = {
               ["filterType"] = "auras";
               ["refreshThreshold"] = 0;
               ["auraName"] = "Dextrous";
               ["stackCount"] = 0;
               ["playerIsCaster"] = true;
               ["invert"] = true;
               ["isBuff"] = true;
            };
         };
      };
      [35] = {
         ["spellId"] = 82692;
         ["name"] = "Usable";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [1] = {
         ["spellId"] = 3674;
         ["name"] = "Usable";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
         };
      };
      [19] = {
         ["name"] = "Usable";
         ["spellId"] = 120697;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [23] = {
         ["name"] = "Usable";
         ["spellId"] = 117050;
         ["filters"] = {
            [1] = {
               ["ignore"] = false;
               ["filterType"] = "usability";
            };
         };
      };
      [31] = {
         ["spellId"] = 117050;
         ["name"] = "LynX Rush";
         ["filters"] = {
            [1] = {
               ["filterType"] = "usability";
               ["ignore"] = false;
            };
            [2] = {
               ["talentNum"] = 15;
               ["filterType"] = "talent";
            };
         };
      };
   };
};
