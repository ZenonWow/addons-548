local _G, ADDON_NAME, _ADDON = _G, ...
local ImmersiveAction = _G.ImmersiveAction or {}
local Log = ImmersiveAction.Log or {}  ;  ImmersiveAction.Log = Log


---------------------------
-- Log: print state transitions, commands, etc.
---------------------------

--[[
-- logging:
/run ImmersiveAction.logging.all= false
/run ImmersiveAction.logging.Anomaly= false
/run ImmersiveAction.logging.State= false
/run ImmersiveAction.logging.Update= true
/run ImmersiveAction.logging.Command= true
-- set to true or false  to override individual event settings
/run ImmersiveAction.logging.Event.all= false
-- individual events
/run ImmersiveAction.logging.Event.CURSOR_UPDATE= false
/run ImmersiveAction.logging.Event.PLAYER_TARGET_CHANGED= false
/run ImmersiveAction.logging.Event.PET_BAR_UPDATE= false
/run ImmersiveAction.logging.Event.ACTIONBAR_UPDATE_STATE= false
/run ImmersiveAction.logging.Event.QUEST_PROGRESS= false
/run ImmersiveAction.logging.Event.QUEST_FINISHED= false
--]]
ImmersiveAction.logging= {
	-- all= false,		-- set to false/true to override individual event settings.
	-- all= true,
	State= false,
	Update= false,
	Command= false,
	-- Anomaly= false,
	Anomaly= true,
	Init= false,
	Frame= false,
}
ImmersiveAction.logging.Event= {
	all= false,		-- set to false/true to override individual event settings.
	-- all= true,
	CURSOR_UPDATE= false,
	PLAYER_TARGET_CHANGED= true,
	-- PET_BAR_UPDATE= true,
	-- ACTIONBAR_UPDATE_STATE= false,
	QUEST_PROGRESS= true,
	QUEST_FINISHED= true,
}


local function makeLogFunc(Log, logging, categ)
	Log[categ] =  function(...)  if logging:_on(categ) then print(...) end  end
end
function ImmersiveAction.logging:_on(categ)
	return  self.all~=false  and  (self[categ] or self.all)
end

ImmersiveAction.logging.Event._on = ImmersiveAction.logging._on
function ImmersiveAction.logging:_onevent(event)
	return  self.all ~= false  and  self.Event  and  self.Event:_on(event)
end

makeLogFunc(Log, ImmersiveAction.logging, 'State')
makeLogFunc(Log, ImmersiveAction.logging, 'Update')
makeLogFunc(Log, ImmersiveAction.logging, 'Command')
makeLogFunc(Log, ImmersiveAction.logging, 'Anomaly')
makeLogFunc(Log, ImmersiveAction.logging, 'Init')
makeLogFunc(Log, ImmersiveAction.logging, 'Frame')

function Log.Event(event, extraMessage)
	if  ImmersiveAction.logging:_onevent(event)  then
		print(event ..':  cursor='.. (GetCursorInfo() or 'hand')
		..' CursorPickedUp()='.. ImmersiveAction.colorBoolStr(CursorPickedUp(),true)
		..' SpellIsTargeting()='.. ImmersiveAction.colorBoolStr(SpellIsTargeting(),true)
		.. (extraMessage or '') )
	end
end



--[[ Change colors used in logging
/run ImmersiveAction.colors['nil']= ImmersiveAction.colors.blue
/run ImmersiveAction.colors[false]= ImmersiveAction.colors.blue
/run ImmersiveAction.colors[true]= ImmersiveAction.colors.green
--]]
local colors = {
		black			= "|cFF000000",
		white			= "|cFFffffff",
		gray			= "|cFFbeb9b5",
		blue			= "|cFF00b4ff",
		lightblue	= "|cFF96c0ff",
		purple		= "|cFFcc00ff",
		green			= "|cFF00ff00",
		green2		= "|cFF66ff00",
		lightgreen= "|cFF98fb98",
		darkred		= "|cFFc25b56",
		red				= "|cFFff0000",
		orange		= "|cFFff9900",
		yellow		= "|cFFffff00",
		parent		= "|cFFbeb9b5",
		error			= "|cFFff0000",
		ok				= "|cFF00ff00",
		restore		= "|r",
}
ImmersiveAction.colors = colors
colors['nil']			= colors.lightblue
colors[false]			= colors.lightblue
colors[true]			= colors.green
colors.missedup		= colors.orange
colors.up					= colors.orange
colors.down				= colors.green		--colors.purple
colors.show				= colors.green
colors.hide				= colors.lightblue
colors.event			= colors.lightgreen
-- colors.ActionMode   = colors.orange
colors.Mouselook  = colors.yellow


function ImmersiveAction.colorBoolStr(value, withColor)
	local boolStr=  value == true and 'ON'  or  value == false and 'OFF'  or  tostring(value)
	if  withColor == true  then  withColor= ImmersiveAction.colors[value == nil  and  'nil'  or  value]  end
	return  withColor  and  withColor .. boolStr .. ImmersiveAction.colors.restore  or  boolStr
end
local colorBoolStr = ImmersiveAction.colorBoolStr



