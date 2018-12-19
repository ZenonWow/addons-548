--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- PackageDefs.lua - this file pre-defines all package and object types so that load order doesn't
-- matter so long as this file is loaded first, and also sets up the root object type, ObjBase.

-- Create the addon object.
ActionSwap2 = LibStub("AceAddon-3.0"):NewAddon("ActionSwap2", "AceConsole-3.0", "AceTimer-3.0")

local AS2 = ActionSwap2
AS2.DEBUG = false			-- Enable / disable the debug library

if AS2.DEBUG and LibDebug then LibDebug() end

-- ========================================================================================
-- OBJECT MODEL IMPLEMENTATION

-- Define a small base object type, which simplifies object creation and allows us to specify inheritance
-- relationships before actually loading any files.  (and, as a result of this pre-definition, we don't need
-- to load our LUA files in any particular order)
local ObjBase = { }
AS2.ObjBase = ObjBase
function ObjBase:Derive(o)
	o = o or { }
	assert(o ~= self)
	setmetatable(o, self)	-- (self = object / prototype being derived from, not necessarily ObjBase!)
	self.__index = self
	o.superType = self
	return o
end

-- Allows the methods of this prototype to be accessed from the given object.  This is very helpful when
-- your class represents a single built-in UI element such as a frame or button, which may already have
-- a metatable of its own when created.  Derive() is preferred, however, when creating a new object / type
-- or applying to an object that doesn't already have a metatable.
function ObjBase:MixInto(o)
	assert(o ~= nil and o ~= self)
	local superType = { }	-- (indexing this object will index the super type instead)
	setmetatable(superType, getmetatable(o))
	setmetatable(o, {
		__index = function(t, k)	-- (note: do NOT index t from __index or it may loop)
			local r = self[k]		-- (mixed-in prototype)
			if r ~= nil then		-- (don't use "self[k] or superType[k]" or false won't work)
				return r
			else
				return superType[k]	-- (super type)
			end
		end
	})
	return o
end

-- ========================================================================================
-- CLASS DEFINITIONS

AS2.Controller = { }
AS2.Controller.ActionButtonManager = ObjBase:Derive()
AS2.Controller.BackupFrameController = ObjBase:Derive()
AS2.Controller.ButtonSetFrameController = ObjBase:Derive()
AS2.Controller.EventHandlers = { }
AS2.Controller.GlobalKeysetsFrameController = ObjBase:Derive()
AS2.Controller.GlyphActivationFrameController = ObjBase:Derive()
AS2.Controller.GlyphSetsFrameController = ObjBase:Derive()
AS2.Controller.ListControllerBase = ObjBase:Derive()
AS2.Controller.MainWindowController = ObjBase:Derive()
AS2.Controller.TalentActivationFrameController = ObjBase:Derive()
AS2.Controller.TalentSetsFrameController = ObjBase:Derive()
AS2.Controller.UIOperations = { }
AS2.Model = { }
AS2.Model.Action = { }
AS2.Model.ActionSet = ObjBase:Derive()
AS2.Model.BackupList = ObjBase:Derive()
AS2.Model.Binding = { }
AS2.Model.ButtonSetList = ObjBase:Derive()
AS2.Model.DataContext = ObjBase:Derive()
AS2.Model.GlobalKeyset = ObjBase:Derive()
AS2.Model.GlyphSet = ObjBase:Derive()
AS2.Model.Model = ObjBase:Derive()
AS2.Model.QuickCloneTable = ObjBase:Derive()
AS2.Model.QuickCloneTableCache = ObjBase:Derive()
AS2.Model.RealGameModel = { }
AS2.Model.SetListBase = ObjBase:Derive()
AS2.Model.TalentSet = ObjBase:Derive()
AS2.Model.Utilities = { }
AS2.View = { }
AS2.View.ActionBarPreviewFrame = ObjBase:Derive()
AS2.View.BackupFrame = ObjBase:Derive()
AS2.View.DialogUI = { }
AS2.View.GlyphActivationFrame = ObjBase:Derive()
AS2.View.GlyphDisplay = ObjBase:Derive()
AS2.View.GlyphOverlayFrame = ObjBase:Derive()
AS2.View.GlyphPreviewFrame = ObjBase:Derive()
AS2.View.IncludeButtonButton = ObjBase:Derive()
AS2.View.IncludeButtonsFrame = ObjBase:Derive()
AS2.View.ListButtonBase = ObjBase:Derive()
AS2.View.ListView = ObjBase:Derive()
AS2.View.MainWindow = ObjBase:Derive()
AS2.View.SecondaryFrame = ObjBase:Derive()
AS2.View.SetEditorDialog = ObjBase:Derive()
AS2.View.TalentActivationFrame = ObjBase:Derive()
AS2.View.TalentDisplay = ObjBase:Derive()
AS2.View.TalentOverlayFrame = ObjBase:Derive()
AS2.View.TalentPreviewFrame = ObjBase:Derive()
AS2.View.TutorialFrame = ObjBase:Derive()
AS2.View.Widgets = { }

-- Classes derived from other classes (1 level)
AS2.Controller.BackupListController = AS2.Controller.ListControllerBase:Derive()
AS2.Controller.SetListControllerBase = AS2.Controller.ListControllerBase:Derive()
AS2.Model.ButtonSet = AS2.Model.SetListBase:Derive()
AS2.Model.GlobalKeysetList = AS2.Model.SetListBase:Derive()
AS2.Model.GlyphSetList = AS2.Model.SetListBase:Derive()
AS2.Model.TalentSetList = AS2.Model.SetListBase:Derive()
AS2.View.BackupListButton = AS2.View.ListButtonBase:Derive()
AS2.View.ButtonSetFrame = AS2.View.SecondaryFrame:Derive()
AS2.View.GlobalKeysetsFrame = AS2.View.SecondaryFrame:Derive()
AS2.View.GlyphSetsFrame = AS2.View.SecondaryFrame:Derive()
AS2.View.SetListButton = AS2.View.ListButtonBase:Derive()
AS2.View.TalentSetsFrame = AS2.View.SecondaryFrame:Derive()

-- Classes derived from other classes (2+ levels)
AS2.Controller.ActionSetListController = AS2.Controller.SetListControllerBase:Derive()
AS2.Controller.ButtonSetListController = AS2.Controller.SetListControllerBase:Derive()
AS2.Controller.GlobalKeysetListController = AS2.Controller.SetListControllerBase:Derive()
AS2.Controller.GlyphSetListController = AS2.Controller.SetListControllerBase:Derive()
AS2.Controller.TalentSetListController = AS2.Controller.SetListControllerBase:Derive()


