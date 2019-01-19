local lib = LibStub:NewLibrary("FindGlobals", 1)
if  not lib  then  return  end

-- local _G, _ADDON = LibEnv.UseNoGlobals(...)
local _G, _ADDON = LibEnv.UseGlobalEnv(...)

local ENABLED = false
if  ENABLED  then  _G.FindGlobals = lib  end
local TEST_FILES = {
	[[Leatrix_Plus\LauncherButton.lua]],
}

local FUNCTION_COLOR = _G.ORANGE_FONT_COLOR_CODE
local MESSAGE_COLOR  = _G.LIGHTYELLOW_FONT_COLOR_CODE

--[[ Usage:

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded. Format also understood by Mikk's FindGlobals script.
local FGDATA = _G.FindGlobals  and  _G.FindGlobals([==[
-- GLOBALS: getfenv,setfenv,getmetatable,setmetatable,rawget,print,assert
]==])

--]]


lib.envData = lib.envData or {}
lib.fileData = lib.fileData or {}

local function report(envData, var, action)
	if  envData.allowed[var]  then  return  end
	
	local varData = envData.found[var]
	if  not varData  then  varData = {}  envData.found[var] = varData  end
	local acData = varData[action]
	if  not acData  then  acData = {}  varData[action] = acData  end
	
	local fileLine = _G.debugstack(3, 1, 0):match([[\AddOns\(.-:.-:)]])
	-- 0:debugstack, 1:report, 2:__index, 3:caller
	local prev = acData[fileLine]
	if  not prev  then  print(FUNCTION_COLOR.."FindGlobals:|r  "..fileLine.."  "..action.." global  "..MESSAGE_COLOR..var)  end
	acData[fileLine] = (prev or 0) + 1
	acData._all = (acData._all or 0) + 1
end

local FindGlobalsMeta = {
	__index = function(testEnv, var)
		local envData = lib.envData[testEnv]
		report(envData, var, 'read')
		return envData.origEnv[var]
	end,
	__newindex = function(testEnv, var, value)
		local envData = lib.envData[testEnv]
		report(envData, var, 'set')
		envData.origEnv[var] = value
	end,
}



function lib.AllowGlobals(envData, globalsStr)
	if  envData == nil  then  return  end
	if  envData == lib  then  envData = lib.envData[getfenv(2)]  end
	local allowed = envData.allowed

	for  name  in  globalsStr:gmatch("[%a0-9_:]+")  do
		allowed[var] = true
	end
	-- Drop "GLOBALS:", it is markup meant for Mikk's FindGlobals script.
	allowed["GLOBALS:"] = nil
end



local IgnoreGlobalsMeta = {
	__index = function(testEnv, var)
		local envData = lib.envData[testEnv]
		envData.allowed[var] = true
		envData.ignoreList[#envData.ignoreList+1] = var
		local value = envData.origEnv[var]
		envData.ignoreValue[#envData.ignoreValue+1] = value
		return value
	end,
}

function lib.AllowedGlobalsCapture(envData)
	if  envData == nil  then  return  end
	local testEnv = getfenv(2)
	if  envData == lib  then  envData = lib.envData[testEnv]
	else  assert(testEnv == envData.testEnv, "AllowedGlobalsCapture(): testEnv mismatch")
  end
	envData.ignoreList = {}
	envData.ignoreValue = {}
	assert(getmetatable(testEnv) == FindGlobalsMeta, "Call FindGlobals('filename') before to set up test environment.")
	setmetatable(testEnv, IgnoreGlobalsMeta)
	
	return function(...)
		setmetatable(testEnv, FindGlobalsMeta)
		local envData = lib.envData[testEnv]
		local ignoreValue, skipped, prev = envData.ignoreValue, 0
		for  i = 1, select('#',...)  do
			if  ignoreValue[i-skipped] ~= select(i,...)  then
				prev = prev or envData.ignoreList[i-skipped-1] or "<first>"
				skipped = skipped + 1
			elseif  prev  then
				local curr = envData.ignoreList[i-skipped]
				print(FUNCTION_COLOR.."FindGlobals:|r  "..envData.envName.."  not global(s) between  "..prev.."  and  "..curr)
				prev = nil
			end
		end
		if  prev  then
			print(FUNCTION_COLOR.."FindGlobals:|r  "..envData.envName.."  not global(s) between  "..prev.."  and  <last>")
		end
		envData.ignoreList = nil
		envData.ignoreValue = nil
	end
end



-- local FGDATA, _ENV = _G.FindGlobals  and  _G.FindGlobals()
function lib:Setup(allowedGlobals)
	local filePath = _G.debugstack(2, 1, 0):match([[\AddOns\(.-):]])
	if  not TEST_FILES[filePath]  then
		lib.disabledFiles = lib.disabledFiles or {}
		lib.disabledFiles[#lib.disabledFiles+1] = filePath
		return
	end
	local envData = lib.fileData[filePath]
	if  envData  then
		print("_G.FindGlobals() called again in file '"..filePath.."'.")
		return envData, envData.testEnv
	end
	
	local testEnv = setmetatable({}, FindGlobalsMeta)
	envData = {
		filePath = filePath,
		testEnv = testEnv,
		origEnv = getfenv(2),
		allowed = {}, found = {}
	}
	if  allowedGlobals  then  envData:AllowGlobals(allowedGlobals)  end
	
	lib.envData[testEnv] = envData
	lib.fileData[filePath] = envData
	
	setfenv(2, testEnv)
	return envData, testEnv
end

setmetatable(lib, { __call = lib.Setup  })


