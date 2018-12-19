------------
-- HUNTER --
------------

if (not Watcher) then
    return;
end

if (select(2, UnitClass('player')) ~= "HUNTER") then
    return;
end

Watcher.defaults.class.Hunter = {
			["priorityLists"] = {
				{
					["spellConditions"] = {
						{
							["spellId"] = 121818,
							["filterSetId"] = 39,
						}, -- [1]
						{
							["spellId"] = 121818,
							["filterSetId"] = 38,
						}, -- [2]
						{
							["spellId"] = 1978,
							["filterSetId"] = 26,
						}, -- [3]
						{
							["spellId"] = 53351,
							["filterSetId"] = 16,
						}, -- [4]
						{
							["spellId"] = 19574,
							["filterSetId"] = 27,
						}, -- [5]
						{
							["spellId"] = 34026,
							["filterSetId"] = 29,
						}, -- [6]
						{
							["spellId"] = 82692,
							["filterSetId"] = 36,
						}, -- [7]
						{
							["spellId"] = 117050,
							["filterSetId"] = 30,
						}, -- [8]
						{
							["spellId"] = 120679,
							["filterSetId"] = 34,
						}, -- [9]
						{
							["spellId"] = 120697,
							["filterSetId"] = 33,
						}, -- [10]
						{
							["spellId"] = 121818,
							["filterSetId"] = 11,
						}, -- [11]
						{
							["spellId"] = 3044,
							["filterSetId"] = 28,
						}, -- [12]
						{
							["spellId"] = 77767,
							["filterSetId"] = 17,
						}, -- [13]
					},
					["name"] = "Beast Mastery",
					["filters"] = {
						{
							["specNum"] = 1,
							["filterType"] = "spec",
						}, -- [1]
					},
				}, -- [1]
				{
					["name"] = "Marksmanship",
					["filters"] = {
						{
							["specNum"] = 2,
							["filterType"] = "spec",
						}, -- [1]
					}					,
					["spellConditions"] = {
					},
				}, -- [2]
				{
					["name"] = "Survival",
					["spellConditions"] = {
						{
							["spellId"] = 121818,
							["filterSetId"] = 38,
						}, -- [1]
						{
							["spellId"] = 121818,
							["filterSetId"] = 39,
						}, -- [2]
						{
							["spellId"] = 1978,
							["filterSetId"] = 26,
						}, -- [3]
						{
							["spellId"] = 53301,
							["filterSetId"] = 12,
						}, -- [4]
						{
							["spellId"] = 53351,
							["filterSetId"] = 16,
						}, -- [5]
						{
							["spellId"] = 3674,
							["filterSetId"] = 1,
						}, -- [6]
						{
							["spellId"] = 117050,
							["filterSetId"] = 30,
						}, -- [7]
						{
							["spellId"] = 3044,
							["filterSetId"] = 37,
						}, -- [8]
						{
							["spellId"] = 120697,
							["filterSetId"] = 33,
						}, -- [9]
						{
							["spellId"] = 120679,
							["filterSetId"] = 34,
						}, -- [10]
						{
							["spellId"] = 3044,
							["filterSetId"] = 28,
						}, -- [11]
						{
							["spellId"] = 77767,
							["filterSetId"] = 17,
						}, -- [12]
					},
					["filters"] = {
						{
							["specNum"] = 3,
							["filterType"] = "spec",
						}, -- [1]
					},
				}, -- [3]
			},
			["spells"] = {

				[34026] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[29] = true,
					},
				},
				[1978] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[3] = true,
						[9] = true,
						[26] = true,
					},
				},
				[82692] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[35] = true,
						[36] = true,
					},
				},
				[19574] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[27] = true,
					},
				},
				[77767] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[17] = true,
					},
				},
				[117050] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[30] = true,
						[31] = true,
						[23] = true,
						[32] = true,
					},
				},
				[120679] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[18] = true,
						[34] = true,
					},
				},
				[53351] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[16] = true,
					},
				},
				[109215] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[20] = true,
					},
				},
				[109248] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[21] = true,
					},
				},
				[3674] = {
					["settings"] = {
						["label"] = "d",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						true, -- [1]
					},
				},
				[131894] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[25] = true,
					},
				},
				[120697] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[19] = true,
						[33] = true,
					},
				},
				[82726] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[24] = true,
					},
				},
				[53301] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[12] = true,
					},
				},
				[120360] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[22] = true,
					},
				},
				[3044] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[14] = true,
						[28] = true,
						[37] = true,
					},
				},
				[121818] = {
					["settings"] = {
						["label"] = "bob",
						["keepEnoughResources"] = false,
					},
					["filterSetIds"] = {
						[11] = true,
						[39] = true,
						[38] = true,
					},
				},
			},
			["filterSets"] = {
				{
					["spellId"] = 3674,
					["name"] = "Usable",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [1]
				{
					["spellId"] = 120360,
					["name"] = "Usable",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [2]
				{
					["spellId"] = 1978,
					["name"] = "Usable",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [3]
				{
					["spellId"] = 121818,
					["name"] = "Usable",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [4]
				{
					["spellId"] = 53301,
					["name"] = "Usable",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [5]
				{
					["spellId"] = 53351,
					["name"] = "Usable",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [6]
				{
					["spellId"] = 3044,
					["name"] = "Usable",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [7]
				{
					["spellId"] = 77767,
					["name"] = "Usable",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [8]
				{
					["spellId"] = 1978,
					["name"] = "Test",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [9]
				{
					["name"] = "Usable",
					["spellId"] = 120360,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [10]
				{
					["name"] = "Usable",
					["spellId"] = 121818,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [11]
				{
					["name"] = "Usable",
					["spellId"] = 53301,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [12]
				{
					["name"] = "Usable",
					["spellId"] = 53351,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [13]
				{
					["name"] = "Usable",
					["spellId"] = 3044,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [14]
				{
					["name"] = "Usable",
					["spellId"] = 77767,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [15]
				{
					["name"] = "Usable",
					["spellId"] = 53351,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [16]
				{
					["name"] = "Usable",
					["spellId"] = 77767,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [17]
				{
					["name"] = "Usable",
					["spellId"] = 120679,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [18]
				{
					["name"] = "Usable",
					["spellId"] = 120697,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [19]
				{
					["name"] = "Usable",
					["spellId"] = 109215,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [20]
				{
					["name"] = "Usable",
					["spellId"] = 109248,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [21]
				{
					["name"] = "Usable",
					["spellId"] = 120360,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [22]
				{
					["name"] = "Usable",
					["spellId"] = 117050,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [23]
				{
					["name"] = "Usable",
					["spellId"] = 82726,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [24]
				{
					["name"] = "Usable",
					["spellId"] = 131894,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
					},
				}, -- [25]
				{
					["name"] = "Dot",
					["spellId"] = 1978,
					["filters"] = {
						{
							["ignore"] = false,
							["filterType"] = "usability",
						}, -- [1]
						{
							["isBuff"] = false,
							["refreshThreshold"] = 0,
							["invert"] = false,
							["stackCount"] = 0,
							["playerIsCaster"] = true,
							["auraName"] = "Serpent Sting",
							["filterType"] = "auras",
						}, -- [2]
					},
				}, -- [26]
				{
					["spellId"] = 19574,
					["name"] = "Usable",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [27]
				{
					["spellId"] = 3044,
					["name"] = "Focus Dump",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
						{
							["threshold"] = 73,
							["invert"] = false,
							["filterType"] = "power",
						}, -- [2]
					},
				}, -- [28]
				{
					["spellId"] = 34026,
					["name"] = "Usable",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [29]
				{
					["spellId"] = 117050,
					["name"] = "Glaive Toss",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
						{
							["talentNum"] = 16,
							["filterType"] = "talent",
						}, -- [2]
					},
				}, -- [30]
				{
					["spellId"] = 117050,
					["name"] = "LynX Rush",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
						{
							["talentNum"] = 15,
							["filterType"] = "talent",
						}, -- [2]
					},
				}, -- [31]
				{
					["spellId"] = 117050,
					["name"] = "Dire Beast",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
						{
							["talentNum"] = 11,
							["filterType"] = "talent",
						}, -- [2]
					},
				}, -- [32]
				{
					["spellId"] = 120697,
					["name"] = "Lynx Rush",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
						{
							["talentNum"] = 15,
							["filterType"] = "talent",
						}, -- [2]
					},
				}, -- [33]
				{
					["spellId"] = 120679,
					["name"] = "Dire Beast",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
						{
							["talentNum"] = 11,
							["filterType"] = "talent",
						}, -- [2]
					},
				}, -- [34]
				{
					["spellId"] = 82692,
					["name"] = "Usable",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
					},
				}, -- [35]
				{
					["spellId"] = 82692,
					["name"] = "Frenzy",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
						{
							["filterType"] = "auras",
							["refreshThreshold"] = 0,
							["auraName"] = "Frenzy",
							["stackCount"] = 5,
							["playerIsCaster"] = true,
							["invert"] = true,
							["isBuff"] = true,
						}, -- [2]
					},
				}, -- [36]
				{
					["spellId"] = 3044,
					["name"] = "Thrill of the Hunt",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
						{
							["filterType"] = "auras",
							["refreshThreshold"] = 0,
							["auraName"] = "",
							["stackCount"] = 0,
							["playerIsCaster"] = true,
							["invert"] = false,
							["isBuff"] = true,
						}, -- [2]
					},
				}, -- [37]
				{
					["spellId"] = 121818,
					["name"] = "Procs",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
						{
							["filterType"] = "auras",
							["refreshThreshold"] = 0,
							["auraName"] = "Heroism",
							["stackCount"] = 0,
							["playerIsCaster"] = true,
							["invert"] = true,
							["isBuff"] = true,
						}, -- [2]
					},
				}, -- [38]
				{
					["spellId"] = 121818,
					["name"] = "Trinket",
					["filters"] = {
						{
							["filterType"] = "usability",
							["ignore"] = false,
						}, -- [1]
						{
							["filterType"] = "auras",
							["refreshThreshold"] = 0,
							["auraName"] = "Dextrous",
							["stackCount"] = 0,
							["playerIsCaster"] = true,
							["invert"] = true,
							["isBuff"] = true,
						}, -- [2]
					},
				}, -- [39]
			},
}
