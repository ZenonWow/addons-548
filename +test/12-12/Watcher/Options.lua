---------------------
-- SEE LICENSE.TXT --
---------------------

-------------
-- OPTIONS --
-------------
-- TODO: insert licence
if (not Watcher) then
    return;
end


---------------
-- LIBRARIES --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("Watcher");
local media = LibStub:GetLibrary("LibSharedMedia-3.0");
local _;


-------------
-- GLOBALS --
-------------
Watcher.configurationSelections = {};
local S = Watcher.configurationSelections;
Watcher.changelog = "Still in active development!\nDefault values can now be set per class.";
Watcher.message = "Hello!\n\nWelcome to the new version of Watcher. A bunch of things have changed around here and if you were using it before, your settings have been reset.\n\nSorry about that.\n\nBut sometimes, we as addon developers have to inconvience you to provide you with the best experience, which we hope that this new version will do.\n\n Enjoy the new version of Watcher!\n\n\n-- The Watcher Team";


--------------------
-- LOOK UP TABLES --
--------------------
Watcher.relationships = {
    ["At Least"] = L["At Least"],
    ["At Most"] = L["At Most"],
    ["Equals"] = L["Equals"],
}
Watcher.unitClassifications = {
    ["worldboss"] = L["worldboss"],
    ["rareelite"] = L["rareelite"],
    ["elite"] = L["elite"],
    ["rare"] = L["rare"],
    ["normal"] = L["normal"],
    ["trivial"] = L["trivial"],
    ["minus"] = L["minus"],
};
Watcher.unitClassificationsValues = {
    ["worldboss"] = 7,
    ["rareelite"] = 6,
    ["elite"] = 5,
    ["rare"] = 4,
    ["normal"] = 3,
    ["minus"] = 2,
    ["trivial"] = 1,
};
Watcher.resourceTypes = {
	[-1] = L["Combo Points (Druid) (Rogue)"],
    [-2] = L["Death Runes (Death Knight)"],
    [-3] = L["Blood Runes (Death Knight)"],
    [-4] = L["Frost Runes (Death Knight)"],
    [-5] = L["Unholy Runes (Death Knight)"],
	[7] = L["Soul Shards (Warlock)"],
    [8] = L["Eclipse (Druid)"],
    [9] = L["Holy Power (Paladin)"],
    [12] = L["Chi (Monk)"],
	[13] = L["Shadow Orbs (Priest)"],
    [14] = L["Burning Embers (Warlock)"],
    [15] = L["Demonic Fury (Warlock)"],
}
Watcher.textAnchor = {
    ["top"] = "top";
    ["bottom"] = "bottom";
    ["center"] = "center";
};
Watcher.directions = {
	["up"] = "up",
	["down"] = "down",
	["left"] = "left",
    ["right"] = "right",
}
Watcher.fontEffects = {
    ["none"] = L["None"],
	["OUTLINE"] = L["OUTLINE"],
	["THICKOUTLINE"] = L["THICKOUTLINE"],
	--["MONOCHROME"] = L["MONOCHROME"],
};
Watcher.totems = {
    [1] = L["Fire"],
    [2] = L["Earth"],
    [3] = L["Water"],
    [4] = L["Air"],
};
Watcher.mushrooms = {
    [1] = L["Mushroom #1"],
    [2] = L["Mushroom #2"],
    [3] = L["Mushroom #3"],
}

--------------------
-- OPTIONS TABLES --
--------------------
Watcher.generalOptions = {
    name = "Watcher",
    handler = Watcher,
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = L["General"],
            order = 1,
            inline = true,
            args = {
                enable = {
                    type = 'toggle',
                    name = L["Enable"],
                    desc = L["help_enable"],
                    get = "IsEnabled",
                    set = function(_, newValue) if (not newValue) then Watcher:Disable(); else Watcher:Enable(); end end,
                    order = 1,
                },
                disable = { --TODO: check up on
                    type = 'toggle',
                    name = L["Disable"],
                    desc = L["help_enable"],
                    get = "IsEnabled",
                    set = function(_, newValue) if newValue then Watcher:Disable(); else Watcher:Enable(); end end,
                    guiHidden = true,
                    order = 1,
                },
                move = {
                    type = 'toggle',
                    name = L["Move Frames"],
                    desc = L["help_move"],
                    get = function() return Watcher.db.char.unlocked; end,
                    set = function(_, newValue) Watcher.db.char.unlocked = newValue; Watcher:SetupPriorityFrame(); end,
                    order = 2,
                },
                reset = {
                    type = 'execute',
                    name = L["Reset"],
                    desc = L["help_reset"],
                    confirm = true,
                    func = "Reset",
                    order = 4,
                },
                export = {
                    type = 'execute',
                    name = L["Export"],
                    desc = L["help_export"],
                    confirm = false,
                    func = "Export",
                    order = 5,
                },
            },
        },
        messageGroup = {
            type = 'group',
            name = L["Author's Message"],
            order = 5,
            cmdHidden = true,
            inline = true,
            args = {
                message = {
                    type = 'description',
                    name = Watcher.message,
                    fontSize = "medium",
                    width = "full",
                    order = 1,
                },
            }
        },
        changeLogGroup = {
            type = 'group',
            name = L["Changelog (Major)"],
            order = 6,
            cmdHidden = true,
            inline = true,
            args = {
                changelog = {
                    type = 'description',
                    name = Watcher.changelog,
                    fontSize = "medium",
                    width = "full",
                    order = 1,
                },
            }
        },
    },
};
Watcher.displayOptions = {
    name = L["Display Settings"],
    type = 'group',
    handler = Watcher,
    childGroups = 'tab',
    order = 1,
    args = {
        general = {
            type = 'group',
            name = L["General"],
            order = 1,
            args = {
                displayType = {
                    type = 'select',
                    name = L["Display Type"],
                    desc = L["help_display_type"],
                    get = function() return 1; end, -- TODO: implement
                    set = function(_, newValue) end,
                    values = {"Timeline"},
                    order = 1,
                },
                direction = {
                    type = 'select',
                    name = L["Direction"],
                    desc = L["help_dir"],
                    get = function() return Watcher.db.char.growDir; end,
                    set = function(_, newValue) Watcher.db.char.growDir = newValue; Watcher:SetupPriorityFrame(); end,
                    values = Watcher.directions,
                    order = 2,
                },
                numIcons = {
                    type = 'range',
                    name = L["Max Number of Icons"],
                    desc = L["help_num_icons"],
                    min = 1,
                    max = 12,
                    disabled = true,
                    step = 1,
                    get = function() return Watcher.db.char.numIcons; end,
                    set = function(_, newValue) Watcher.db.char.numIcons = newValue; Watcher:SetupPriorityFrame(); end,
                    order = 3,
                },
                visiblity = {
                    type = 'group',
                    name = L["Visibility"];
                    inline = true,
                    order = 4,
                    args = {
                        combat = {
                            type = 'toggle',
                            name = L["Show only in combat"],
                            get = function() return Watcher.db.char.showOnlyInCombat; end,
                            set = function(_, newValue) Watcher.db.char.showOnlyInCombat = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 1,
                        },
                        target = {
                            type = 'toggle',
                            name = L["Show only if target exists"],
                            get = function() return Watcher.db.char.showOnlyOnAttackableTarget; end,
                            set = function(_, newValue) Watcher.db.char.showOnlyOnAttackableTarget = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 2,
                        },
                        solo = {
                            type = 'toggle',
                            name = L["Show while solo"],
                            get = function() return Watcher.db.char.showWhileSolo; end,
                            set = function(_, newValue) Watcher.db.char.showWhileSolo = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 3,
                        },
                        party = {
                            type = 'toggle',
                            name = L["Show in party"],
                            get = function() return Watcher.db.char.showInParty; end,
                            set = function(_, newValue) Watcher.db.char.showInParty = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 4,
                        },
                        raid = {
                            type = 'toggle',
                            name = L["Show in raid"],
                            get = function() return Watcher.db.char.showInRaid; end,
                            set = function(_, newValue) Watcher.db.char.showInRaid = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 5,
                        },
                        pvp = {
                            type = 'toggle',
                            name = L["Show in PVP"],
                            get = function() return Watcher.db.char.showWhilePVP; end,
                            set = function(_, newValue) Watcher.db.char.showWhilePVP = newValue; Watcher:ShowHidePriorityFrame(); end,
                            order = 6,
                        },
                    },
                },
                sizing = {
                    type = 'group',
                    name = L["Sizing"];
                    inline = true,
                    order = 5,
                    args = {
                        scale = {
                            type = 'range',
                            name = L["Scale"],
                            desc = L["help_scale"],
                            min = 0.25,
                            max = 3.00,
                            step = 0.05,
                            get = function() return Watcher.db.char.scale; end,
                            set = function(_, newValue) Watcher.db.char.scale = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                        iconSize = {
                            type = 'range',
                            name = L["Icon Size"],
                            desc = L["help_size"],
                            min = 10,
                            max = 75,
                            step = 5,
                            get = function() return Watcher.db.char.iconSize; end,
                            set = function(_, newValue) Watcher.db.char.iconSize = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 2,
                        },
                    },
                },
                alpha = {
                    type = 'group',
                    name = L["Alpha"];
                    inline = true,
                    order = 6,
                    args = {
                        iconAlpha = {
                            type = 'range',
                            name = L["Icon Alpha"],
                            desc = L["help_alpha"],
                            min = 0,
                            max = 1,
                            step = 0.05,
                            get = function() return Watcher.db.char.iconAlpha end;
                            set = function(_, newValue) Watcher.db.char.iconAlpha = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                        backgroundAlpha = {
                            type = 'range',
                            name = L["Background Alpha"],
                            desc = L["help_balpha"],
                            min = 0,
                            max = 1,
                            step = 0.05,
                            get = function() return Watcher.db.char.backgroundAlpha end;
                            set = function(_, newValue) Watcher.db.char.backgroundAlpha = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 2,
                        },
                    },
                },
            }
        },
        text = {
            name = L["Text Settings"],
            type = 'group',
            order = 2,
            args = {
                visibility = {
                    name = L["Visibility"],
                    type = 'group',
                    order = 1,
                    inline = true,
                    args = {
                        cooldownText = {
                            type = 'toggle',
                            name = L["Show CD Text"],
                            disabled = true,
                            get = function() return Watcher.db.char.showCooldownText; end,
                            set = function(_, newValue) Watcher.db.char.showCooldownText = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                        labelText = {
                            type = 'toggle',
                            name = L["Show Labels"],
                            get = function() return Watcher.db.char.showLabel; end,
                            set = function(_, newValue) Watcher.db.char.showLabel = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 2,
                        },
                    },
                },
                display = {
                    name = L["Text Display"],
                    type = 'group',
                    order = 2,
                    inline = true,
                    args = {
                        font = {
                            type = 'select',
                            name = L["Font"],
                            get = function() return Watcher.db.char.iconFont; end,
                            set = function(_, newValue) Watcher.db.char.iconFont = newValue; Watcher:SetupPriorityFrame(); end,
                            values = "GetFontList",
                            order = 1,
                        },
                        effect = {
                            type = 'select',
                            name = L["Font Effect"],
                            get = function() return Watcher.db.char.iconFontEffect; end,
                            set = function(_, newValue) Watcher.db.char.iconFontEffect = newValue; Watcher:SetupPriorityFrame(); end,
                            values = Watcher.fontEffects,
                            order = 2,
                        },
                        textsize = {
                            type = 'range',
                            name = L["Font Size"],
                            min = 6,
                            max = 36,
                            step = 1,
                            get = function() return Watcher.db.char.iconFontSize; end,
                            set = function(_, newValue) Watcher.db.char.iconFontSize = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 3,
                        },
                        labelColor = {
                            type = 'color',
                            name = L["Label Color"],
                            hasAlpha = true;
                            get = function() return Watcher.db.char.labelColor.r, Watcher.db.char.labelColor.g, Watcher.db.char.labelColor.b, Watcher.db.char.labelColor.a; end,
                            set = function(_, r, g, b, a) Watcher.db.char.labelColor.r = r; Watcher.db.char.labelColor.g = g; Watcher.db.char.labelColor.b = b; Watcher.db.char.labelColor.a = a; Watcher:SetupPriorityFrame(); end,
                            order = 4,
                        },
                    },
                },
                position = {
                    name = L["Position"],
                    type = 'group',
                    order = 4,
                    inline = true,
                    args = {
                        textAnchor = {
                            type = 'select',
                            name = L["Text Anchor"],
                            desc = L["help_text_anchor"],
                            get = function() return Watcher.db.char.textAnchor; end,
                            set = function(_, newValue) Watcher.db.char.textAnchor = newValue; Watcher:SetupPriorityFrame(); end,
                            values = Watcher.textAnchor,
                            order = 1,
                        },
                        labelVertPos = {
                            type = 'range',
                            name = L["Label Vertical Position"],
                            min = -60,
                            max = 60,
                            step = 2,
                            get = function() return Watcher.db.char.labelVertPos; end,
                            set = function(_, newValue) Watcher.db.char.labelVertPos = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 2,
                        },
                        labelHoriPos = {
                            type = 'range',
                            name = L["Label Horizontal Position"],
                            min = -60,
                            max = 60,
                            step = 2,
                            get = function() return Watcher.db.char.labelHoriPos; end,
                            set = function(_, newValue) Watcher.db.char.labelHoriPos = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 3,
                        },
                    },
                },
            },
        },
        timeLine = {
            name = L["Timeline Settings"],
            type = 'group',
            disabled = function() end,
            order = 3,
            args = {
                sizing = {
                    type = 'group',
                    name = L["Sizing"];
                    inline = true,
                    order = 2,
                    args = {
                        barSize = {
                            type = 'range',
                            name = L["Time Segment Width"],
                            desc = L["segment_size_help"],
                            min = 10,
                            max = 100,
                            step = 1,
                            get = function() return Watcher.db.char.timeSegmentWidth; end,
                            set = function(_, newValue) Watcher.db.char.timeSegmentWidth = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                    },
                },
                display = {
                    type = 'group',
                    name = L["Display"];
                    inline = true,
                    order = 1,
                    args = {
                        showIncrementText = {
                            type = 'toggle',
                            name = L["Show Time Increments"],
                            get = function() return Watcher.db.char.showIncrementText; end,
                            set = function(_, newValue) Watcher.db.char.showIncrementText = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 1,
                        },
                        maxStackedIcons = {
                            type = 'range',
                            name = L["Max Icon Stack"],
                            desc = L["Sets the maximum number of stacked icons."],
                            min = 2,
                            max = 12,
                            step = 1,
                            get = function() return Watcher.db.char.maxStackedIcons; end,
                            set = function(_, newValue) Watcher.db.char.maxStackedIcons = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 2,
                        },
                        stackHeight = {
                            type = 'range',
                            name = L["Stack Height"],
                            desc = L["Sets the percentage of the icon that is visable when stacked."],
                            min = .1,
                            max = 1,
                            step = .05,
                            get = function() return Watcher.db.char.stackHeight; end,
                            set = function(_, newValue) Watcher.db.char.stackHeight = newValue; Watcher:SetupPriorityFrame(); end,
                            order = 3,
                        },
                    },
                },
                timeSegments = {
                    type = 'group',
                    name = L["Time Segments"];
                    inline = true,
                    order = 3,
                    args = {
                        addTime = {
                            type = 'input',
                            name = L["Add Time Segment"],
                            desc = L["Add a time segment to the timeline bar (in seconds)."],
                            get = function() return "" end,
                            set = function(_, newValue) if (tonumber(newValue) and (tonumber(newValue) >= 0)) then Watcher:AddTimeSegment(tonumber(newValue)); end end,
                            order = 1,
                        },
                        removeTime = {
                            type = 'input',
                            name = L["Remove Time Segment"],
                            desc = L["Remove a time segment from the timeline bar (in seconds)."],
                            get = function() return "" end,
                            set = function(_, newValue) if (tonumber(newValue) and (tonumber(newValue) >= 0)) then Watcher:RemoveTimeSegment(tonumber(newValue)); end end,
                            order = 2,
                        },
                        resetSegments = {
                            type = 'execute',
                            name = L["Reset Time Segments"],
                            desc = L["Resets the timeline time segments to the default configuration."],
                            func = "ResetTimeSegments";
                            order = 3,
                        },
                    },
                },
            },
        },
    },
};
Watcher.spellOptions = {
    name = L["Spells"],
    type = 'group',
    handler = Watcher,
    order = 1,
    args = {
        spell = {
            type = 'select',
            name = L["Spell"],
            desc = L["The spell to configure."],
            get = function() if (not S.spellId) then S.spellId = next(Watcher.db.char.spells); if (S.spellId) then S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end end return S.spellId; end,
            set = function(_, newValue) S.spellId = newValue; S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end,
            values = "GetSpellList",
            order = 1,
        },
        removeSpell = {
            type = 'execute',
            name = L["Delete Spell"],
            desc = L["Delete the currently selected spell"],
            hidden = function() return (not S.spellId); end;
            disabled = function() return (not S.spellId); end;
            func = function() Watcher:RemoveSpell(S.spellId); end,
            order = 2,
        },
        addSpell = {
            type = 'input',
            name = L["Add New Spell"],
            desc = L["Input a spell name or spellId to add."],
            get = function() return "" end,
            set = function(_, newValue) if (tonumber(newValue)) then Watcher:AddNewSpell(tonumber(newValue)); else Watcher:AddNewSpell(Watcher:GetSpellIdFromName(newValue)); end end,
            order = 3,
        },
        spellOptions = {
            type = 'group',
            name = L["Spell Options"];
            inline = true,
            hidden = function() return (not S.spellId); end;
            order = 4,
            args = {
                keepEnoughResources = {
                    type = 'toggle',
                    name = L["Keep Enough Resources"],
                    desc = L["Keep enough resources to keep this ability on cooldown."],
                    disabled = function() return true; end;
                    get = function() if (not S.spellId) then return false; end return Watcher.db.char.spells[S.spellId].settings.keepEnoughResources; end,
                    set = function(_, newValue) Watcher.db.char.spells[S.spellId].settings.keepEnoughResources = newValue; end,
                    order = 1,
                },
                keybindLabel = {
                    type = 'input',
                    name = L["Keybind Label"],
                    desc = L["The keybind label that will appear on the spell."],
                    get = function() if (not S.spellId) then return ""; end return Watcher.db.char.spells[S.spellId].settings.label; end,
                    set = function(_, newValue) Watcher.db.char.spells[S.spellId].settings.label = newValue; end,
                    order = 2,
                },
                divider = {
                    type = 'header',
                    name = "",
                    order = 3,
                },
                filterSet = {
                    type = 'select',
                    name = L["Filter Set"],
                    desc = L["The filter set to configure."],
                    get = function() if (not S.spellId) then return; end if (not S.filterSetId and (Watcher.db.char.spells[S.spellId])) then S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end return S.filterSetId; end,
                    set = function(_, newValue) S.filterSetId = newValue; Watcher:InjectFilterOptions(); end,
                    values = function() return Watcher:GetFilterSets(S.spellId); end,
                    order = 4,
                },
                deleteFilterSet = {
                    type = 'execute',
                    name = L["Delete Filter Set"],
                    desc = L["Delete the currently selected filter set."],
                    disabled = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                    hidden = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                    func = function() Watcher:RemoveFilterSet(S.filterSetId); end,
                    order = 5,
                },
                addFilterSet = {
                    type = 'input',
                    name = L["Add New Filter Set"],
                    desc = L["Input a new filter set name."],
                    get = function() return "" end,
                    set = function(_, newValue) Watcher:AddNewFilterSet(newValue, S.spellId); end,
                    order = 6,
                },
                filterSetOptions = {
                    type = 'group',
                    name = L["Filter Set Options"];
                    inline = true,
                    disabled = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                    hidden = function() return ((not S.filterSetId) or Watcher.db.char.filterSets[S.filterSetId].name == L["Usable"]); end,
                    order = 7,
                    args = {
                        bottomFilterDivider = {
                            type = 'header',
                            name = "",
                            order = -3,
                        },
                        selectFilterToAdd = {
                            type = 'select',
                            name = L["Select Filter Type To Add"],
                            get = function() if (not S.filterType) then S.filterType = next(Watcher:GetFilters()); end return S.filterType; end,
                            set = function(_, newValue) S.filterType = newValue; end,
                            values = "GetFilters",
                            width = "double",
                            order = -2,
                        },
                        addNewFilter = {
                            type = 'execute',
                            name = L["Add New Filter"],
                            desc = L["Adds a new filter to this filter set."],
                            func = function() if (not S.filterType or not S.filterSetId) then return; end Watcher:AddFilter(S.filterType, S.filterSetId); end,
                            order = -1,
                        },
                    },
                },
            },
        },
    },
};
Watcher.priorityOptions = {
    name = L["Priority Lists"],
    type = "group",
    handler = Watcher,
    childGroups = "select",
    order = 1,
    args = {

    },
};


----------------------
-- OPTION FUNCTIONS --
----------------------
function Watcher:Export()
	StaticPopupDialogs["EXAMPLE_HELLOWORLD"] = {
		text = "Do you want to greet the world today?",
		button3 = "Close",
		OnShow = function (self, data)
		local className = UnitClass("player")

        local header = string.format(
[[------------
-- %s --
------------
if (not Watcher) then
	return;
end

if (select(2,  string.upper(UnitClass('player'))) ~=  string.upper('%s')) then
	return;
end


]], className, className);


			local prioList = table.show(Watcher.defaults.class[className],"Watcher.defaults.class."..className)

			self.editBox:SetText(header..prioList)
			self.editBox:HighlightText()
		end,
		hasEditBox = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
	}

StaticPopup_Show ("EXAMPLE_HELLOWORLD")
end

function Watcher:RegisterOptions()
		local AceConfigDialog = LibStub("AceConfigDialog-3.0")

		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Watcher", self.generalOptions);
        self.optionsFrame = AceConfigDialog:AddToBlizOptions("Watcher", "Watcher");

        LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Watcher Display Settings", self.displayOptions);
		self.optionsFrame["Display"] = AceConfigDialog:AddToBlizOptions("Watcher Display Settings", L["Display Settings"], "Watcher");

        LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Watcher Spell Options", self.spellOptions);
		self.optionsFrame["Display"] = AceConfigDialog:AddToBlizOptions("Watcher Spell Options", L["Spells"], "Watcher");

        self:InjectPriorityOptions();
        LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Watcher Priority Options", self.priorityOptions);
		self.optionsFrame["Display"] = AceConfigDialog:AddToBlizOptions("Watcher Priority Options", L["Priority Lists"], "Watcher");
end

function Watcher:InjectFilterOptions()
    -- clear the old stuff out of the menu
    for k, v in pairs(self.spellOptions.args.spellOptions.args.filterSetOptions.args) do
        if (string.find(k, "^filter")) then
            self.spellOptions.args.spellOptions.args.filterSetOptions.args[k] = nil;
        end
    end

    if (S.filterSetId) then
        for filterId, value in pairs(self.db.char.filterSets[S.filterSetId].filters) do
            self.spellOptions.args.spellOptions.args.filterSetOptions.args["filterBegin"..filterId] = {
                type = 'header',
                name = L[self.db.char.filterSets[S.filterSetId].filters[filterId].filterType],
                order = (2*(filterId - 1)) + 3,
            };
            self.spellOptions.args.spellOptions.args.filterSetOptions.args["filter"..filterId] = self:GetFilterOptions(S.filterSetId, filterId);
        end
    end

    LibStub("AceConfigRegistry-3.0"):NotifyChange("Watcher");
end

function Watcher:GetFilterOptions(filterSetId, filterId)
    local conditionFilterOptions = {
        ["usability"] = {
            ignoreUsability = {
                name = L["Ignore Usability"],
                desc = L["Enable if you want the filter to ignore usability (not enough mana, don't have skill, etc)."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].ignore; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].ignore = newValue; end,
                order = 1,
            }
        },
        ["auras"] = {
            auraName = {
                type = 'input',
                name = L["Aura Name"],
                desc = L["The name of the buff or debuff."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].auraName; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].auraName = newValue; end,
                order = 1,
            },
            isBuff = {
                name = L["Is Player Buff"],
                desc = L["The aura is a buff on the player, if not selected, the aura is a debuff on the target."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].isBuff; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].isBuff = newValue; end,
                order = 2,
            },
            invert = {
                name = L["When Aura Exists"],
                desc = L["Enable if you want the filter to trigger when the aura exists."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].invert; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].invert = newValue; end,
                order = 3,
            },
            playerIsCaster = {
                name = L["Player Is Caster"],
                desc = L["If enabled, the player must be the caster of the aura."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].playerIsCaster; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].playerIsCaster = newValue; end,
                order = 4,
            },
            refreshThreshold = {
                type = 'range',
                name = L["Refresh Threshold"],
                desc = L["When the remaining time is less then the refresh threshold, the filter triggers."],
                min = 0,
                max = 60,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].refreshThreshold; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].refreshThreshold = newValue; end,
                order = 5,
            },
            stackCount = {
                type = 'range',
                name = L["Stack Count"],
                desc = L["The number of stacks to maintain. 0 for non-stacking auras."],
                min = 0,
                max = 10,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].stackCount; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].stackCount = newValue; end,
                order = 6,
            },
        },
        ["power"] = {
            threshold = {
                type = 'range',
                name = L["Threshold"],
                desc = L["Threshold to triggen when above."],
                min = 0,
                max = 100,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].threshold; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].threshold = newValue; end,
                order = 1,
            },
            invert = {
                name = L["When Below"],
                desc = L["Enable if you want the filter to trigger when below the set power threshold."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].invert; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].invert = newValue; end,
                order = 2,
            },
        },
        ["secondaryResource"] = {
            relationship = {
                type = 'select',
                name = "",
                desc = L["At least will allow anything higher; at most anything lower."],
                disabled = "CheckClassSecondaryResource",
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].relationship; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].relationship = newValue; end,
                values = self.relationships,
                order = 1,
            },
            value = {
                type = 'input',
                name = "",
                desc = L["The value of the secondary resource."],
                disabled = "CheckClassSecondaryResource",
                get = function() return ""..self.db.char.filterSets[filterSetId].filters[filterId].value; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].value = tonumber(newValue); end,
                pattern = "%d+",
                order = 2,
            },
            resourceType = {
                type = 'select',
                name = L["Resource Type"],
                desc = L["The secondary resource type to use."],
                disabled = "CheckClassSecondaryResource",
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].resourceType; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].resourceType = newValue; end,
                values = "GetSecondaryResourceList",
                order = 3,
            },
        },
        ["health"] = {
            threshold = {
                type = 'range',
                name = L["Threshold"],
                desc = L["Set the health percent to be below set value."],
                min = 0,
                max = 100,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].threshold; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].threshold = newValue; end,
                order = 1,
            },
            invert = {
                name = L["When Above"],
                desc = L["Enable if you want the filter to trigger when above the set health threshold."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].invert; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].invert = newValue; end,
                order = 2,
            },
            player = {
                name = L["Check Player"],
                desc = L["Enable if you want the filter to check player health instead of target health."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].player; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].player = newValue; end,
                order = 3,
            },
        },
        ["timeToLive"] = {
            value = {
                type = 'range',
                name = L["Time To Live (seconds)"],
                desc = L["Set the time to live threshold (in seconds), i.e. only cast if target will last x seconds."],
                min = 0,
                max = 120,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].value; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].value = newValue; end,
                order = 1,
            },
            invert = {
                name = L["Invert"],
                desc = L["Inverts the time to live threshold. Cast if target will not last x seconds."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].invert; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].invert = newValue; end,
                order = 2,
            },
        },
        ["classification"] = {
            relationship = {
                type = 'select',
                name = "",
                desc = L["At least will allow anything higher; at most anything lower."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].relationship; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].relationship = newValue; end,
                values = self.relationships,
                order = 1,
            },
            value = {
                type = 'select',
                name = L["Classification"],
                desc = L["The classification of the target to filter on."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].value; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].value = newValue; end,
                values = self.unitClassifications,
                order = 2,
            },
        },
        ["targetAura"] = {
            stealable = {
                name = L["Stealable"],
                desc = L["Check if target has stealable buff."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].stealable; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].stealable = newValue; end,
                order = 1,
            },
            dispellable = {
                name = L["Dispellable"],
                desc = L["Check if target has dispellable buff/debuff."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].dispellable; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].dispellable = newValue; end,
                order = 2,
            },
            useWhitelist = {
                name = L["Use Whitelist"],
                desc = L["Uses the whitelist to select which buffs to steal/interrupt."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist = newValue; end,
                order = 4,
            },
            whitelistAdd = {
                type = 'input',
                name = L["Add to Whitelist"],
                desc = L["Enter a enemy buff to add to the whitelist."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist); end,
                get = function() return ""; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].whitelist[newValue] = newValue; end,
                order = 5,
            },
            whitelistRemove = {
                type = 'select',
                name = L["Remove from Whitelist"],
                desc = L["Select a enemy buff in the whitelist to remove."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist); end,
                get = function() return ""; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].whitelist[newValue] = nil; end,
                values = function() return self.db.char.filterSets[filterSetId].filters[filterId].whitelist; end,
                order = 6,
            },
        },
        ["targetCastingInterruptable"] = {
            useWhitelist = {
                name = L["Use Whitelist"],
                desc = L["Uses the whitelist to select which spells to interrupt."],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist = newValue; end,
                order = 1,
            },
            whitelistAdd = {
                type = 'input',
                name = L["Add to Whitelist"],
                desc = L["Enter a spell to add to the interruptable spell whitelist."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist); end,
                get = function() return ""; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].whitelist[newValue] = newValue; end,
                order = 2,
            },
            whitelistRemove = {
                type = 'select',
                name = L["Remove from Whitelist"],
                desc = L["Select a spell in the whitelist to remove."],
                disabled = function() return (not self.db.char.filterSets[filterSetId].filters[filterId].useWhitelist); end,
                get = function() return ""; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].whitelist[newValue] = nil; end,
                values = function() return self.db.char.filterSets[filterSetId].filters[filterId].whitelist; end,
                order = 3,
            },
        },
        ["aoe"] = {
            relationship = {
                type = 'select',
                name = "",
                desc = L["At least will allow anything higher; at most anything lower."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].relationship; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].relationship = newValue; end,
                values = self.relationships,
                order = 1,
            },
            activeEnemies = {
                type = 'range',
                name = L["Number of Active Enemies"],
                desc = L["Set the threshold of active enemies."],
                min = 1,
                max = 20,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].activeEnemies; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].activeEnemies = newValue; end,
                order = 2,
            },
            grouped = {
                name = L["Grouped"],
                desc = L["Attempts to only show filter if the active enemies are grouped together. EXPERIMENTAL!"],
                type = 'toggle',
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].grouped; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].grouped = newValue; end,
                order = 3,
            },
        },
        ["totem"] = {
            slot = {
                type = 'select',
                name = L["Type"],
                desc = L["What type of totem or mushroom to check for."],
                disabled = function() local _, class = UnitClass("player"); if not (class == "SHAMAN" or class == "DRUID") then return true; else return false; end end,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].slot; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].slot = newValue; end,
                values = function() local _, class = UnitClass("player"); if (class == "SHAMAN") then return self.totems; elseif (class == "DRUID") then return self.mushrooms; end return {}; end,
                order = 1,
            },
            exists = {
                name = L["If Exists"],
                desc = L["Check if the totem or mushroom exists. If unchecked, if it doesn't."],
                type = 'toggle',
                disabled = function() local _, class = UnitClass("player"); if not (class == "SHAMAN" or class == "DRUID") then return true; else return false; end end,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].exists; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].exists = newValue; end,
                order = 3,
            },
            refreshThreshold = {
                type = 'range',
                name = L["Refresh Threshold"],
                desc = L["When the remaining time is less then the refresh threshold, the filter triggers."],
                disabled = function() local _, class = UnitClass("player"); if not (class == "SHAMAN" or class == "DRUID") then return true; else return false; end end,
                min = 0,
                max = 12,
                step = 1,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].refreshThreshold; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].refreshThreshold = newValue; end,
                order = 4,
            },
            name = {
                type = 'input',
                name = L["Name"],
                desc = L["Enter a name of the totem to look for. Blank if all of that type."],
                disabled = function() local _, class = UnitClass("player"); if not (class == "SHAMAN" or class == "DRUID") then return true; else return false; end end,
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].name; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].name = newValue; end,
                order = 2,
            },
        },
        ["spec"] = {
            specNum = {
                type = 'select',
                name = L["spec"],
                desc = L["Filter is active if you are in this spec."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].specNum; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].specNum = newValue; end,
                values = "GetSpecList",
                order = 1,
            },
        },
        ["talent"] = {
            talentNum = {
                type = 'select',
                name = L["talent"],
                desc = L["Filter is active if you have this talent."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].talentNum; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].talentNum = newValue; end,
                values = "GetTalentList",
                order = 1,
            },
        },
        ["glyph"] = {
            glyphSpellId = {
                type = 'select',
                name = L["Glyph of (the).."],
                desc = L["Filter is active if you have this glyph equipped."],
                get = function() return self.db.char.filterSets[filterSetId].filters[filterId].glyphSpellId; end,
                set = function(_, newValue) self.db.char.filterSets[filterSetId].filters[filterId].glyphSpellId = newValue; end,
                values = "GetGlyphList",
                order = 1,
            },
        },
    };

    local filterOptions = {
        name = "",
        type = 'group',
        handler = Watcher,
        order = (2*(filterId - 1)) + 4,
        args = conditionFilterOptions[self.db.char.filterSets[filterSetId].filters[filterId].filterType],
    };

    filterOptions.args.remove = {
        type = 'execute',
        name = L["Remove Filter"],
        desc = L["Removes this filter from this filter set."],
        func = function() self.db.char.filterSets[filterSetId].filters[filterId] = nil; self.spellOptions.args.spellOptions.args.filterSetOptions.args["filter"..filterId] = nil; self:InjectFilterOptions(); end,
        hidden = function() return self.db.char.filterSets[filterSetId].filters[filterId].filterType == "usability"; end;
        width = "full",
        order = 0,
    };

    return filterOptions;
end

function Watcher:InjectPriorityOptions()
    -- clear old
    self.priorityOptions.args = {};

    for i, v in pairs(self.db.char.priorityLists) do
        self.priorityOptions.args["PriorityList"..i] = self:GetPriorityListOptions(i, "PriorityList"..i);
    end

    self:SetupPriorityFrame();
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Watcher");
end

function Watcher:GetPriorityListOptions(priorityListId, listName)
    local priorityList = {
        name = self.db.char.priorityLists[priorityListId].name,
        type = "group",
        handler = Watcher,
        childGroups = "tree",
        order = function() if (self.db.char.priorityLists[priorityListId].filters[1] and self.db.char.priorityLists[priorityListId].filters[1].filterType == "spec" and GetSpecialization() and GetSpecialization() == self.db.char.priorityLists[priorityListId].filters[1].specNum) then return 1; end  return 2; end, --TODO: THIS IS A HACK
        args = {
            addSpell = {
                name = L["Add Spell"],
                type = "group",
                handler = Watcher,
                inline = true,
                order = 1,
                args = {
                    spell = {
                        type = 'select',
                        name = L["Spell"],
                        get = function() if (not S.spellId) then S.spellId = next(Watcher.db.char.spells); if (S.spellId) then S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end end return S.spellId; end,
                        set = function(_, newValue) S.spellId = newValue; S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end,
                        values = "GetSpellList",
                        order = 1,
                    },
                    filterSet = {
                        type = 'select',
                        name = L["Filter Set"],
                        get = function() if (not S.spellId) then return; end if (not S.filterSetId and (Watcher.db.char.spells[S.spellId])) then S.filterSetId = next(Watcher.db.char.spells[S.spellId].filterSetIds); Watcher:InjectFilterOptions(); end return S.filterSetId; end,
                        set = function(_, newValue) S.filterSetId = newValue; Watcher:InjectFilterOptions(); end,
                        values = function() return Watcher:GetFilterSets(S.spellId); end,
                        order = 2,
                    },
                    add = {
                        type = 'execute',
                        name = L["Add"],
                        func = function() Watcher:AddSpellToPriorityList(S.spellId, S.filterSetId, priorityListId) end,
                        disabled = function() return not (S.spellId and S.filterSetId); end,
                        order = 3,
                    },
                },
            },
        },
    };

    for i, v in ipairs(self.db.char.priorityLists[priorityListId].spellConditions) do
        priorityList.args["spellCondition"..i] = self:GetPriorityListEntryOptions(i, priorityListId, listName);
    end

    return priorityList;
end

function Watcher:GetPriorityListEntryOptions(spellConditionIndex, priorityListId, parentList)
    if (spellConditionIndex) then
        local priorityListEntry = {
            name = function() local name = spellConditionIndex.." - "..GetSpellInfo(self.db.char.priorityLists[priorityListId].spellConditions[spellConditionIndex].spellId); if (self.db.char.filterSets[self.db.char.priorityLists[priorityListId].spellConditions[spellConditionIndex].filterSetId].name ~= L["Usable"]) then name = name.." - "..self.db.char.filterSets[self.db.char.priorityLists[priorityListId].spellConditions[spellConditionIndex].filterSetId].name; end return name; end,
            type = "group",
            handler = Watcher,
            order = 1+spellConditionIndex,
            args = {
                moveUp = {
                    type = 'execute',
                    name = L["Up"],
                    func = function() if (spellConditionIndex ~= 1) then local temp = table.remove(self.db.char.priorityLists[priorityListId].spellConditions, spellConditionIndex); table.insert(self.db.char.priorityLists[priorityListId].spellConditions, spellConditionIndex-1, temp); self:InjectPriorityOptions(); LibStub("AceConfigDialog-3.0"):SelectGroup("Watcher Priority Options", parentList, "spellCondition"..(spellConditionIndex-1)); end end,
                    width = "half",
                    order = 1,
                },
                moveDown = {
                    type = 'execute',
                    name = L["Down"],
                    func = function() if (spellConditionIndex ~= #self.db.char.priorityLists[priorityListId].spellConditions) then local temp = table.remove(self.db.char.priorityLists[priorityListId].spellConditions, spellConditionIndex); table.insert(self.db.char.priorityLists[priorityListId].spellConditions, spellConditionIndex+1, temp); self:InjectPriorityOptions(); LibStub("AceConfigDialog-3.0"):SelectGroup("Watcher Priority Options", parentList, "spellCondition"..(spellConditionIndex+1)); end end,
                    width = "half",
                    order = 2,
                },
                removeItem = {
                    type = 'execute',
                    name = L["Remove"],
                    func = function() table.remove(self.db.char.priorityLists[priorityListId].spellConditions, spellConditionIndex); self:InjectPriorityOptions(); end,
                    width = "half",
                    order = 3,
                },
                edit = {
                    type = 'execute',
                    name = L["Edit"],
                    func = function() S.spellId = self.db.char.priorityLists[priorityListId].spellConditions[spellConditionIndex].spellId; S.filterSetId = self.db.char.priorityLists[priorityListId].spellConditions[spellConditionIndex].filterSetId; self:InjectFilterOptions(); LibStub("AceConfigDialog-3.0"):Open("Watcher Spell Options"); end,
                    width = "half",
                    order = 4,
                },
                messageGroup = {
                    type = 'group',
                    name = "",
                    order = 5,
                    inline = true,
                    args = {
                        message = {
                            type = 'description',
                            name = spellConditionIndex.."\n\n\n\n\nThere will be a display of the current spell and filter set options here.\n\n\n\n\nJust not yet.\n\n\n\n\n",
                            fontSize = "large",
                            width = "full",
                            order = 1,
                        },
                    }
                },
            },
        };

        return priorityListEntry;
    end
end
