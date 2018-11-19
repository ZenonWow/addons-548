local LuaTests = {}
_G.LuaTests = LuaTests

--[[
/dump strsplit(" ,", "	1		2	3		")
/dump strsplit(" 	,", "	1		2	3		")
/dump strsplit(" ,", "  1		2 	3 	")
/dump strsplit(" ,", "  1, ,2,,,3   4  ,")
/dump select('#', nil, 1, nil, nil)
/dump geterrorhandler()("Hello Handler")
/dump pcall(function() error("Hello Pcall") end)
/dump xpcall(function() error("Hello XPcall") end)
/dump xpcall(function() error("Hello XPcall - print") end, function(...) print(...) end))
/dump xpcall(function() error("Hello XPcall - geterrorhandler") end, geterrorhandler())
/dump  1, 2 or 2.5, (3,3.5), nil, 5, nil
--]]
local fields = {
"X-NoComma"
"X-JustComma" --
"X-CommaUndSpace" -- 
"X-CommaUnd4Space" --    
"X-CommaUndTab" --	
"X-CommaUnd2Tab" --		
"X-Trimm" --    		    <-4s2t4s    		    4s2t4s->    		    
"X-Dupli" -- 1 \n 2 \n 3
}

function LuaTests.FieldTest()
	for i,fi in ipairs(fields) do
		print("## "..fi..": '"..GetAddOnMetadata(ADDON_NAME, fi).."'")
	end
end

--[[
/run LuaTests.FieldTest()
/run LuaTests.SetScript()

--]]

function LuaTests.SetScript()
	local fOnShow(self, ...)  print("fOnShow():", ...)  end
	local f=CreateFrame('Frame')
	print("f:IsShown() = "..tostring(f:IsShown()))
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Hide()
	
	print(0)
	f:SetScript('OnShow', fOnShow)
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Show() f:Hide()
	print(1)
	f:SetScript('OnShow', fOnShow, 1)
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Show() f:Hide()
	print(2)
	f:SetScript('OnShow', fOnShow, 1, 2)
	print("f.OnShow = "..tostring(f:GetScript('OnShow')))
	f:Show() f:Hide()
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


