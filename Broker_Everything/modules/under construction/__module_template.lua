
--[[
-- ns.modules[name] = {
--    desc           string       Module description
--    icon           string|path  Path to an icon to display in bars and panels
--    events         table        Event table to register events for Event function
--    updateinterval integer      Update interval in seconds
--    config         table        Table with elements to display in Option Panel
-- }
--
-- ~~ all functions must be defined after table creation ~~
--
-- ns.modules[name].init           function     Init function
-- ns.modules[name].onevent        function     Event function triggered by events defined in event table
-- ns.modules[name].onclick        function     On click event function
-- ns.modules[name].ondblclick     function     On double click event function
-- ns.modules[name].onwheel        function     On mouse wheel event function
-- ns.modules[name].ontooltip      function     Tooltip content update function
-- ns.modules[name].onupdate       function     Update function executed by update interval
-- ns.modules[name].optionspanel   function     Optionspanel function
--
--]]

----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = (Broker_EverythingDB.usePrefix and "BE.." or "")..""
local ldbName = name


---------------------------------------
-- module variables for registration --
---------------------------------------
I[name] = "Interface\\Addons\\"..addon.."\\media\\"

ns.modules[name] = {
	desc = L[""],
	events = {},
	updateinterval = nil, -- 10
	config = nil -- {}
}


--------------------------
-- some local functions --
--------------------------


------------------------------------
-- module (BE internal) functions --
------------------------------------
--[[ ns.modules[name].init = function(obj) end ]]

--[[ ns.modules[name].onevent = function(self,event,msg) end ]]

--[[ ns.modules[name].onupdate = function(self) end ]]

--[[ ns.modules[name].optionspanel = function(panel) end ]]

--[[ ns.modules[name].onmousewheel = function(self,direction) end ]]

--[[ ns.modules[name].ontooltip = function(tooltip) end ]]


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
--[[ ns.modules[name].onenter = function(self) end ]]

--[[ ns.modules[name].onleave = function(self) end ]]

--[[ ns.modules[name].onclick = function(self,button) end ]]

--[[ ns.modules[name].ondblclick = function(self,button) end ]]



-- onenter
	--self:EnableMouseWheel(1) 
	--self:SetScript("OnMouseWheel", OnMouseWheel)
