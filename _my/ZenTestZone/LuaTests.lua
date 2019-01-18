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

function LuaTests.pcall()
	eh = geterrorhandler()
	print("errorhandler        = "..tostring(eh))
	peh = select(2,pcall(geterrorhandler))
	print("pcall errorhandler  = "..tostring(peh))
	xpeh = select(2,xpcall(geterrorhandler, geterrorhandler()))
	print("xpcall errorhandler  = "..tostring(xpeh))
end


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
	local AceTimer = _G.LibStub.AceTimer
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


