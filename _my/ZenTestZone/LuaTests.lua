--[[
TODO test:
ViragDevTool function exec
InterfaceOptionsFrame_OpenToCategory

/run InterfaceOptionsFrame_OpenToCategory("Ellipsis")

--]]


local LuaTests = _G.LuaTests or {}
_G.LuaTests = LuaTests

--[[
/dump strsplit(" ,", "	1		2	3		")
/dump strsplit(" 	,", "	1		2	3		")
/dump strsplit(" ,", "  1		2 	3 	")
/dump strsplit(" ,", "  1, ,2,,,3   4  ,")
/dump select('#', nil, 1, nil, nil)
/dump geterrorhandler()("Hello Handler")
/dump tostring(geterrorhandler())
/dump tostringall(pcall(geterrorhandler))
/dump tostringall(xpcall(geterrorhandler, nil))
/dump tostringall(xpcall(BugGrabber.original.geterrorhandler, nil))
/dump tostringall(BugGrabber.original.geterrorhandler(), BugGrabber.RuntimeErrorHandler, geterrorhandler(), BugGrabber.PublicErrorHandler)
/dump pcall(function() error("Hello Pcall") end)
/dump xpcall(function() error("Hello XPcall") end)
/dump xpcall(function() geterrorhandler()("With geterrorhandler") end, geterrorhandler())
/dump xpcall(function() return NIL.NIL end)
/dump xpcall(function() error("Hello XPcall - print") end, function(...) print(...) end))
/dump xpcall(function() error("Hello XPcall - geterrorhandler") end, geterrorhandler())
/dump  1, 2 or 2.5, (3,3.5), nil, 5, nil
--]]
local fields = {
"X-NoComma",
"X-JustComma", --
"X-CommaUndSpace", -- 
"X-CommaUnd4Space", --    
"X-CommaUndTab", --	
"X-CommaUnd2Tab", --		
"X-Trimm", --    		    <-4s2t4s    		    4s2t4s->    		    
"X-Dupli", -- 1 \n 2 \n 3
}


--[[
/dump 'MissingAddon', LoadAddOn('MissingAddon')
/dump 'DisabledAddon', LoadAddOn('tekErr'), 'Loaded?', IsAddOnLoaded('tekErr')
/run LuaTests.SetScript()
/run LuaTests.HookScript()
/run LuaTests.hooksecurefunc()
/run LuaTests.pcall()
/run LuaTests.AceTimer()
/dump SlashCmdList  -- is wiped after hashing the contents
/run LuaTests.SlashTest()
/st 1 2 3    4		5    		
/run LuaTests.FieldTest()
--]]

--[[
/run print("UnitExists('mouseover')="..tostring(UnitExists('mouseover'))) ; MouselookStart() ; print("MouselookStart(); UnitExists('mouseover')="..tostring(UnitExists('mouseover'))) ; MouselookStop()
/run function trickyIter(t,i) print('is this a valid iteration?') ; return nil,(i==0 and 'YES') end ; for a,b in trickyIter,'YES',0 do print(a,b) end
/run function trickyIter(t,i) print('is this a valid iteration?') ; return i==0 and 'YES' or nil end ; for a,b in trickyIter,'YES',0 do print(a,b) end
/dump CanLootUnit, CanInteractUnit, CanLoot, HasLoot
/dump CanLootUnit('target')
/dump CanInteractUnit('target')
--]]
function LuaTests.MouselookTest()
	print("UnitExists('mouseover')="..tostring(UnitExists('mouseover')))
	MouselookStart()
	print("MouselookStart(); UnitExists('mouseover')="..tostring(UnitExists('mouseover')))
	MouselookStop()
end


function LuaTests.MetaTableTest()
	obj = setmetatable({}, { __tostring = function() return nil end }) ; print( "tostring() returns type '"..type( tostring(obj) ).."' if __tostring returns nil." )
	-- print(tostring( (function() end)() ))
	print(tostring(1,2))
	obj = setmetatable({}, { __index = "Hello! Nothin 'ere." }) ; print(obj.something)
	obj = setmetatable({}, { __index = false }) ; print(obj.something)
end


function LuaTests.SlashTest()
	SlashCmdList.SlashTest = function(...)  print(strjoin("|",...))  end
	_G.SLASH_SlashTest1 = "/st"
end

function LuaTests.FieldTest()
	for i,fi in ipairs(fields) do
		print("## "..fi..": '"..GetAddOnMetadata(ADDON_NAME, fi).."'")
	end
end

function LuaTests.SetScript()
	local function fOnShow(self, ...)  print("fOnShow():", ...)  end
	local f=CreateFrame('Frame')
	print("f:IsShown() = "..tostring(f:IsShown()))
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Hide()
	
	print("0: SetScript")
	f:SetScript('OnShow', fOnShow)
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Show() f:Hide()
	print("0: SetScript, 1")
	f:SetScript('OnShow', fOnShow, 1)
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Show() f:Hide()
	--[[
	2x attempt to call a number value
[game engine]:: in function 'Show'
ZenTestZone\LuaTests.lua:85: in function 'SetScript'
[loadstring(?,"LuaTests.SetScript()")]:1: in main chunk
[game engine]:: in function 'RunScript'
FrameXML\ChatFrame.lua:2036: in function '?'
FrameXML\ChatFrame.lua:4315: in function <FrameXML\ChatFrame.lua:4262>
[game engine]:: in function 'ChatEdit_ParseText'
FrameXML\ChatFrame.lua:3969: in function 'ChatEdit_SendText'
FrameXML\ChatFrame.lua:4008: in function 'ChatEdit_OnEnterPressed'
[loadstring(?,"*:OnEnterPressed")]:1: in function <[loadstring(?,"*:OnEnterPressed")]:1>

Locals:
fOnShow = <function> defined @ZenTestZone\LuaTests.lua:72
	--]]
	print("0: SetScript, 1, 2")
	f:SetScript('OnShow', fOnShow, 1, 2)
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Show() f:Hide()
end


function LuaTests.HookScript()
	local function fOnShowHook(self, ...)  print("fOnShowHook():", ...)  end
	local f=CreateFrame('Frame')
	print("f:IsShown() = "..tostring(f:IsShown()))
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Hide()
	
	print("0: Hooked once")
	f:HookScript('OnShow', fOnShowHook)
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Show() f:Hide()
	print("0: Hooked 2 times")
	f:HookScript('OnShow', fOnShowHook)
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Show() f:Hide()
	print("2: Hooked 3 times")
	f:HookScript('OnShow', fOnShowHook)
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Show() f:Hide()
end
--[[
[14:37:46] 阿依土鳖公主 has gone offline.
[15:25:02] ESC -> CloseOneWindow(): UISpecialFrames[20] == ScriptErrorsFrame
[15:25:03] f:IsShown() = 1
[15:25:03] f.OnShow = nil
[15:25:03] 0: Hooked once
[15:25:03] f.OnShow = function: 26780420
[15:25:03] fOnShowHook():
[15:25:03] 0: Hooked 2 times
[15:25:03] f.OnShow = function: 32EE28A8
[15:25:03] fOnShowHook():
[15:25:03] fOnShowHook():
[15:25:03] 2: Hooked 3 times
[15:25:03] f.OnShow = function: 32EE2928
[15:25:03] fOnShowHook():
[15:25:03] fOnShowHook():
[15:25:03] fOnShowHook():
--]]


function Dummy1()
	print("Dummy1")
end            
function Dummy2()
	print("Dummy2")
end
function Dummyhook1()
	print("Dummyhook1")
end                
function Dummyhook1b()
	print("Dummyhook1b")
end                
function Dummyhook2()
	print("Dummyhook2")
end

function LuaTests.hooksecurefunc()
	print("    call Dummy1():")
	hooksecurefunc('Dummy1', Dummyhook1)
	Dummy1()
	print("    Dummy1orig = Dummy1, call Dummy1orig():")
	Dummy1orig = Dummy1
	Dummy1orig()
	print("    Dummy1 = nil, call Dummy1orig():")
	Dummy1 = nil
	Dummy1orig()
	print("    Dummy1 = Dummy2, call Dummy1orig():")
	Dummy1 = Dummy2
	Dummy1orig()
	print("    Dummy1 = Dummy2, call Dummy1():")
	Dummy1()
	print("    Dummy1 = Dummy1orig, call Dummy1():")
	Dummy1 = Dummy1orig
	Dummy1()
	print("    call Dummy1() with hooks 1,1b,1b:")
	hooksecurefunc('Dummy1', Dummyhook1b)
	hooksecurefunc('Dummy1', Dummyhook1b)
	Dummy1()
end
--[[
[15:25:56]     call Dummy1():
[15:25:56] Dummy1
[15:25:56] Dummyhook1
[15:25:56]     Dummy1orig = Dummy1, call Dummy1orig():
[15:25:56] Dummy1
[15:25:56] Dummyhook1
[15:25:56]     Dummy1 = nil, call Dummy1orig():
[15:25:56] Dummy1
[15:25:56] Dummyhook1
[15:25:56]     Dummy1 = Dummy2, call Dummy1orig():
[15:25:56] Dummy1
[15:25:56] Dummyhook1
[15:25:56]     Dummy1 = Dummy2, call Dummy1():
[15:25:56] Dummy2
[15:25:56]     Dummy1 = Dummy1orig, call Dummy1():
[15:25:56] Dummy1
[15:25:56] Dummyhook1
[15:25:56]     call Dummy1() with hooks 1,1b,1b:
[15:25:56] Dummy1
[15:25:56] Dummyhook1
[15:25:56] Dummyhook1b
[15:25:56] Dummyhook1b
--]]

function LuaTests.pcall()
	eh = geterrorhandler()
	print("errorhandler        = "..tostring(eh))
	peh = select(2,pcall(geterrorhandler))
	print("pcall errorhandler  = "..tostring(peh))
	xpeh = select(2,xpcall(geterrorhandler, geterrorhandler()))
	print("xpcall errorhandler  = "..tostring(xpeh))
end
--[[
[15:26:57] errorhandler        = function: 28E0E710
[15:26:57] pcall errorhandler  = function: 28E0E710
[15:26:57] xpcall errorhandler  = function: 28E0E710
--]]

local updFrame = CreateFrame('Frame')
updFrame:Hide()
updFrame:SetScript('OnUpdate', afterUp)

local lastMs = debugprofilestop()
function getElapsed()  local prev, now = lastMs, debugprofilestop() ; lastMs = now ; return now-prev  end
function afterUp(frame)  print('afterUp: +'..getElapsed()..'ms')  end
function after00(self)   print('after00: +'..getElapsed()..'ms')  end
function after01(self)   print('after01: +'..getElapsed()..'ms')  end
function afterEE(self)   print('afterEE: +'..getElapsed()..'ms') ; updFrame:Hide()  end

function LuaTests.AceTimer()
	lastMs = debugprofilestop()
	print("AceTimer:ScheduleTimer(after0, 0)")
	local AceTimer = _G.LibStub.AceTimer3
	updFrame:Show()
	AceTimer:ScheduleTimer(after00, 0, 0)
	AceTimer:ScheduleTimer(after00, 0.01, 0.01)
	AceTimer:ScheduleTimer(after00, 0.02, 0.02)
	AceTimer:ScheduleTimer(after00, 0.03, 0.03)
	AceTimer:ScheduleTimer(after00, 0.04, 0.04)
	AceTimer:ScheduleTimer(after00, 0.1, 0.1)
	AceTimer:ScheduleTimer(after00, 0.2, 0.2)
	AceTimer:ScheduleTimer(afterEE, 0.3, 0.3)
end


--[[
[08:13:54] Dump: value=strsplit(" ,", "  1, ,2,,,3   4  ,")
[08:13:54] [1]="",
[08:13:54] [2]="",
[08:13:54] [3]="1",
[08:13:54] [4]="",
[08:13:54] [5]="",
[08:13:54] [6]="2",
[08:13:54] [7]="",
[08:13:54] [8]="",
[08:13:54] [9]="3",
[08:13:54] [10]="",
[08:13:54] [11]="",
[08:13:54] [12]="4",
[08:13:54] [13]="",
[08:13:54] [14]="",
[08:13:54] [15]=""
--]]


