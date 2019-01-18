--
-- $Id: BugGrabber.lua 201 2013-11-28 03:43:26Z funkydude $
--
-- The BugSack and !BugGrabber team is:
-- Current Developer: Funkydude, Rabbit
-- Past Developers: Rowne, Ramble, industrial, Fritti, kergoth, ckknight
-- Testers: Ramble, Sariash
--
--[[

!BugGrabber, World of Warcraft addon that catches errors and formats them with a debug stack.
Copyright (C) 2013 The !BugGrabber Team

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

]]


--[[ To acknowledge and forget the handler error:
/run BugGrabber.internalError = nil
/dump #BugGrabber:GetSessionErrors()
/dump #BugGrabber:GetPreviousErrors()
/dump #BugGrabber:GetDB()
/dump GetCVar("ScriptErrors")
/console scriptErrors 1
/console taintLog 0
/console taintLog 2
/run BugGrabber.original.seterrorhandler(BugGrabber.ErrorHandlerDispatcher)
/run BugGrabber.original.seterrorhandler(BugGrabber.GrabError)
/run error('test')
/run BugGrabber.original.errorhandler("Hello")
--]]


-----------------------------------------------------------------------
-- local-ization, mostly for use with the FindGlobals script to catch
-- misnamed variable names. We're not hugely concerned with performance.

local _G, ADDON_NAME, _ADDON = _G, ...
local STANDALONE_NAME = "!BugGrabber"
local type, table, next, wipe = type, table, next, wipe
local tostring, tonumber, print = tostring, tonumber, print
local date, time, GetTime = date, time, GetTime

-- GLOBALS: LibStub, GetLocale,GetBuildInfo,Swatter
-- GLOBALS: BugGrabberDB, ItemRefTooltip
-- GLOBALS: IsAddOnLoaded, GetAddOnMetadata, DisableAddOn,GetAddOnInfo
-- GLOBALS: MAX_BUGGRABBER_ERRORS, BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE
-- GLOBALS: SlashCmdList, SLASH_SWATTER1, SLASH_SWATTER2

-----------------------------------------------------------------------
-- Check if we already exist in the global space
-- If we do - bail out early, there's no version checks.
if _G.BugGrabber then return end

-- If we're embedded we create a .BugGrabber object on the addons
-- table, unless we find a standalone !BugGrabber addon.
if ADDON_NAME ~= STANDALONE_NAME then
	for i, handler in next, { STANDALONE_NAME, "!Swatter", "!ImprovedErrorFrame" } do
		local _, _, _, enabled = GetAddOnInfo(handler)
		if enabled then return end -- Bail out
	end
end

-----------------------------------------------------------------------
-- Global environment
--

local BugGrabber = _ADDON.BugGrabber or {}
-- Export to addon environment
_ADDON.BugGrabber = BugGrabber
-- Export to global environment
_G.BugGrabber = BugGrabber

local original = {
	geterrorhandler   = _G.geterrorhandler,
	seterrorhandler   = _G.seterrorhandler,
	debugstack        = _G.debugstack,
	debuglocals       = _G.debuglocals,
	debugprofilestop  = _G.debugprofilestop,
	debugprofilestart = _G.debugprofilestart,
	errorhandler      = _G.geterrorhandler(),
	printhandler      = _G.getprinthandler(),
	pcall             = _G.pcall,
	xpcall            = _G.xpcall,
	print             = _G.print,
}
-- Export copy of original, this way the local table won't be modified by other addons.
BugGrabber.original = _G.CopyTable(original)    -- CopyTable from FrameXML/Util.lua does deepcopy

-- Always use debugprofilestop(), never debugprofilestart.
function _G.debugprofilestart()  return _G.debugprofilestop()  end

-----------------------------------------------------------------------
-- Global config variables
--

-- Max number of errors stored in a session.
MAX_BUGGRABBER_ERRORS = 1000
-- If we get more errors than this per second, we stop all capturing
BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE = 10

-- By default print errors if there are no handlers for BugGrabber_BugGrabbed. BugSack is one.
BugGrabber.PrintErrorLinks = nil
-- Insert BugSack and Bugger in this array. First one is used, order can be freely altered.
BugGrabber.DisplayAddons = {}

-----------------------------------------------------------------------
-- Localization
--
local L = {
	ADDON_CALL_PROTECTED = "[%s] AddOn '%s' tried to call the protected function '%s'.",
	ADDON_CALL_PROTECTED_MATCH = "^%[(.*)%] (AddOn '.*' tried to call the protected function '.*'.)$",
	ADDON_DISABLED = "|cffffff00!BugGrabber and %s cannot coexist; %s has been forcefully disabled. If you want to, you may log out, disable !BugGrabber, and enable %s.|r",
	BUGGRABBER_STOPPED = "There are too many errors in your UI. As a result, your game experience may be degraded. Disable or update the failing addons if you don't want to see this message again.",
	ERROR_DETECTED = "%s |cffffff00captured, click the link for more information.|r",
	ERROR_UNABLE = "|cffffff00!BugGrabber is unable to retrieve errors from other players by itself. Please install BugSack or a similar display addon that might give you this functionality.|r",
	NO_DISPLAY_1 = "|cffffff00You seem to be running !BugGrabber with no display addon to go along with it. Although a slash command is provided for accessing error reports, a display can help you manage these errors in a more convenient way.|r",
	NO_DISPLAY_2 = "|cffffff00The standard display is called BugSack, and can probably be found on the same site where you found !BugGrabber.|r",
	NO_DISPLAY_STOP = "|cffffff00If you don't want to be reminded about this again, run /stopnag.|r",
	STOP_NAG = "|cffffff00!BugGrabber will not nag about missing a display addon again until next patch.|r",
	USAGE = "|cffffff00Usage: /bug <1-%d>.|r",
}

-- from FrameXML/Constants.lua:
--[[
local NORMAL_FONT_COLOR_CODE		  = NORMAL_FONT_COLOR_CODE		  or "|cffffd200";
local HIGHLIGHT_FONT_COLOR_CODE	  = HIGHLIGHT_FONT_COLOR_CODE	  or "|cffffffff";
local RED_FONT_COLOR_CODE			    = RED_FONT_COLOR_CODE			    or "|cffff2020";
local GREEN_FONT_COLOR_CODE		    = GREEN_FONT_COLOR_CODE		    or "|cff20ff20";
local GRAY_FONT_COLOR_CODE		    = GRAY_FONT_COLOR_CODE		    or "|cff808080";
local YELLOW_FONT_COLOR_CODE		  = YELLOW_FONT_COLOR_CODE		  or "|cffffff00";
local LIGHTYELLOW_FONT_COLOR_CODE	= LIGHTYELLOW_FONT_COLOR_CODE	or "|cffffff9a";
local ORANGE_FONT_COLOR_CODE		  = ORANGE_FONT_COLOR_CODE		  or "|cffff7f3f";
local ACHIEVEMENT_COLOR_CODE		  = ACHIEVEMENT_COLOR_CODE		  or "|cffffff00";
local BATTLENET_FONT_COLOR_CODE	  = BATTLENET_FONT_COLOR_CODE	  or "|cff82c5ff";
--]]
local FUNCTION_COLOR = ORANGE_FONT_COLOR_CODE				or "|cffff7f3f";
local MESSAGE_COLOR  = LIGHTYELLOW_FONT_COLOR_CODE	or "|cffffff9a";

-----------------------------------------------------------------------
-- Locals
--

-- Reverse search in array
local function tindexOfRev(arr, item)
	for i = #arr,1,-1  do  if  arr[i] == item  then  return i  end end
end

-- Shorthand to the saved previousDB[#previousDB].
-- Available from the start, even before loading SavedVariables.
local currentSessionDB = {}
-- These come from the SavedVariables
local currentSessionId, previousDB
-- Error messages captured in the last framedraw.
local newError = {}

-- The registered errorhandler
local ErrorHandler
-- Forward declaration
local triggerEvent
local callbacks = nil

-- Event handler frame
local frame = CreateFrame("Frame")
frame:Hide()

-- Error links
local playerName = UnitName("player")
local chatLinkFormat = "|Hbuggrabber:%s:%s|h|cffff0000[Error %s]|r|h"


-----------------------------------------------------------------------
-- Internal-error handler
--

local function safe_print(...)
	-- Using the backend of print to avoid  print_inner()  (see FrameXML/RestrictedInfrastructure.lua)
	-- calling  original.geterrorhandler()(errorObject)  on error, which could cause infinite recursion.
	-- If there is an error, just drop it.
	return original.pcall(getprinthandler(), ...)
	-- _ = original.pcall(getprinthandler(), msg)  or  original.pcall(original.printhandler, msg)    -- if any addon would overwrite the printhandler
end

local function reportInternalError(message, whileError)
	local now = time()
	-- Report only once every minute
	if  BugGrabber.internalErrorTime  and  now - BugGrabber.internalErrorTime < 60  then  return message  end
	BugGrabber.internalErrorTime = now
	
	-- Store the error
	local err = {
		message = message,
		stack = original.pcall(original.debugstack, 3),
		locals = original.pcall(original.debuglocals, 3),
		-- calleeLocals = original.pcall(original.debuglocals, 4),
		session = currentSessionId,
		time = date("%Y/%m/%d %H:%M:%S"),
		counter = 1,
	}
	
	BugGrabber.internalError = err
	newError[#newError+1] = err
	
	-- Show frame to run OnUpdate() on next framedraw. It notifies callbacks and checks if ErrorHandlerDispatcher returned correctly, clearing dispatcherLevel.
	original.pcall(frame.Show, frame)
	
	-- Save it
	original.pcall(BugGrabber.StoreError, BugGrabber, err)
	
	-- Append outer error message for printing.
	local withError = message
	if  whileError  then
		withError = withError .. "\n"..MESSAGE_COLOR.."While handling original error:|r\n" .. tostring(whileError)
	end
	
	-- Custom print implementation to avoid recursively calling  original.geterrorhandler()(errorObject)
	safe_print(withError)
	
	if  not BugGrabber.poppedOriginalHandler  then
		-- Show Bliz Lua Error frame once until BugGrabber:Reset()
		BugGrabber.poppedOriginalHandler = now
		original.pcall(original.errorhandler, withError)
	end
	
	return message
end

if  original.errorhandler ~= _G._ERRORMESSAGE  then
	reportInternalError("The builtin errorhandler has already been hooked before BugGrabber loaded. BugGrabber will replace it.\n"..
	"To avoid this message disable one of the addons, or add the  "..LIGHTYELLOW_FONT_COLOR_CODE.."OptionalDeps: !BugGrabber|r  field to the other addon's .toc file.")
end

-- The global seterrorhandler() will just print a message.
_G.seterrorhandler = function(newhandler)
	local caller = original.debugstack(2, 1, 0) or ""
	local fileName, addonName = caller:match([[^Interface\AddOns\((.-)\.-):]])
	local pre = fileName and fileName..": "  or  "Another addon "
	reportInternalError(pre.."conflicts with BugGrabber as it intends to override the errorhandler. If this causes an issue, then disable one of the addons or consult with the developers.")
	return false
end

-- Replace original.errorhandler. Any error while loading is saved by the minimal internalError handler.
ErrorHandler = reportInternalError
original.seterrorhandler(ErrorHandler)


-----------------------------------------------------------------------
-- Store error to SavedVariables.

function BugGrabber:StoreError(errorObject)
	currentSessionDB[#currentSessionDB+1] = errorObject
	
	-- Save only the last MAX_BUGGRABBER_ERRORS errors (otherwise the SV gets too big)
	if #currentSessionDB > MAX_BUGGRABBER_ERRORS then
		table.remove(currentSessionDB, 1)
	end
	
	if  allErrors  and  #allErrors < MAX_BUGGRABBER_ERRORS  then
		-- Note: allErrors will become inconsistent if MAX_BUGGRABBER_ERRORS is reached. At that point does not really matter.
		allErrors[#allErrors+1] = errorObject
	end
end


-----------------------------------------------------------------------
-- Error handler: GrabError() collects and saves stacktrace and local variables

local GrabError
do
	-- Forward declaration of functions used in GrabError()
	local findVersions, fetchFromDatabase
	-- Throttle error spam.
	local msgsAllowed = BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE
	local msgsAllowedLastTime = GetTime()
	-- Error on previous recursion level.
	local grabbingError = nil
	
	function GrabError(errorParam, options)
		local errorMessage =  tostring(errorParam)
		if  grabbingError   then
			if  errorMessage:find("BugGrabber")  then
				return reportInternalError(FUNCTION_COLOR.."BugGrabber.GrabError()|r"..MESSAGE_COLOR.." internal error:|r\n".. errorMessage)
			else
				return reportInternalError(FUNCTION_COLOR.."BugGrabber.GrabError()|r"..MESSAGE_COLOR.." looping while handling error:|r\n".. errorMessage)
			end
		end
		-- Save error on previous recursion level.
		local parentError = grabbingError
		grabbingError = errorParam

		-- Flood protection --
		msgsAllowed = msgsAllowed + (GetTime()-msgsAllowedLastTime)*BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE
		msgsAllowedLastTime = GetTime()
		if msgsAllowed < 1 then
			if  not BugGrabber.paused  then
				if  ADDON_NAME == STANDALONE_NAME  then
					reportInternalError(errorMessage)
					safe_print(FUNCTION_COLOR.."BugGrabber:|r "..L.BUGGRABBER_STOPPED)
				end
				BugGrabber.paused = true
				triggerEvent("BugGrabber_CapturePaused")
			end
			grabbingError = parentError
			return errorParam
		end

		BugGrabber.paused = false
		if msgsAllowed > BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE then
			msgsAllowed = BUGGRABBER_ERRORS_PER_SEC_BEFORE_THROTTLE
		end
		msgsAllowed = msgsAllowed - 1

		-- Grab it --
		local sanitizedMessage = findVersions(errorMessage)

		-- Insert the error into the correct database if it's not there already.
		-- If it is, just increment the counter.
		local fromdb = fetchFromDatabase(sanitizedMessage)
		-- fetchFromDatabase removed the errorObject from currentSessionDB, if it was found.

		local err = fromdb  or  type(options) == 'table'  and  options

		if  fromdb  then
			-- err = fromdb
			err.session = currentSessionId
			err.counter = err.counter + 1
		else
			local stack =  err and err.stack  or  _G.debugstack(2)
			--[[ Callstack from here:
/run error()
0: [C]: in function `debugstack'		-- BugGrabber.debugstack()
1: !BugGrabber\BugGrabber.lua:435: in function <!BugGrabber\BugGrabber.lua:374>		-- GrabError()
-> 2: [C]: ?
3: [C]: in function `error'
4: [string "error()"]:1: in main chunk
5: [C]: in function `RunScript'

/run NIL()
1x [string "NIL()"]:1: attempt to call global 'NIL' (a nil value)
0:[C]: in function `debugstack'
1:!BugGrabber\BugGrabber.lua:435: in function <!BugGrabber\BugGrabber.lua:374>
-> 2:[C]: in function `NIL'
3: [string "NIL()"]:1: in main chunk
4:[C]: in function `RunScript'
			--]]

			-- Scan for version numbers in the stack
			local stackFrames = {}
			for line in stack:gmatch("(.-)\n") do
				stackFrames[#stackFrames+1] = findVersions(line)
			end

			-- Store the error
			err = err or {}
			err.message = sanitizedMessage
			err.stack = table.concat(stackFrames, "\n")
			err.locals = _G.debuglocals(3)
			err.calleeLocals = _G.debuglocals(4)
			err.session = currentSessionId
			err.time = date("%Y/%m/%d %H:%M:%S")
			err.counter = 1
		end

		-- Save to DB
		BugGrabber:StoreError(err)
		newError[errorParam] = err

		-- Notify listeners (callbacks) in next OnUpdate()
		newError[#newError+1] = err
		original.pcall(frame.Show, frame)

		-- If this function is aborted by an error then  grabbingError  is not cleared.
		grabbingError = parentError
		return errorParam
	end


	-- Find and remove repeated error from currentSessionDB.
	function fetchFromDatabase(findMessage)
		local found
		local t = currentSessionDB
		for  i = #t,1,-1  do
			if  t[i].message == findMessage  then
				-- Index from the end is the same in allErrors.
				local inAll = i + #allErrors - #t
				found = table.remove(t, i)
				if  allErrors  then
					if  found == allErrors[inAll]  then
						table.remove(allErrors, inAll)
					else
						safe_print("Inconsistency: BugGrabber:GetDB()["..inAll.."] ~= BugGrabber:GetSessionErrors()["..i.."]. Clear all bugs.")
					end
				end
				return found
			end
		end
	end


	-- Insert addon and library version numbers into stacktrace:  findVersions(line)
	do
		local function scanObject(o)
			local version, revision = nil, nil
			for k, v in next, o do
				if type(k) == "string" and (type(v) == "string" or type(v) == "number") then
					local low = k:lower()
					if not version and low:find("version") then
						version = v
					elseif not revision and low:find("revision") then
						revision = v
					end
				end
				if version and revision then break end
			end
			return version, revision
		end

		local findLibName
		local function findLibVersion()
			local name = findLibName
			if type(name) ~= "string" or #name < 3 then return end
			
			local found = nil
			-- First see if it's a library
			if _G.LibStub then
				local lib, minor = _G.LibStub:GetLibrary(name, true)
				found = minor
			end
			-- Perhaps it's a global object?
			if not found then
				local o = _G[name] or _G[name:upper()]
				if type(o) == "table" then
					local v, r = scanObject(o)
					if v or r then
						found = tostring(v) .. "." .. tostring(r)
					end
				elseif o then
					found = o
				end
			end
			if not found then
				found = _G[name:upper() .. "_VERSION"]
			end
			if type(found) == "string" or type(found) == "number" then
				return found
			end
		end

		--[[
		local escapeCache = setmetatable({}, { __index = function(self, key)
			local escaped = key:gsub("([%.%-%(%)%+])", "%%%1")
			self[key] = escaped
			return escaped
		end })
		--]]

		local libReplaceCache = {}
		local function appendLibVersion(prefix, name, tail)
			local withVersion = libReplaceCache[name]
			if  withVersion ~= nil  then  return withVersion  end
			
			findLibName = name
			local ran, version = xpcall(findLibVersion, reportInternalError)
			findLibName = nil
			
			if ran and version then
				withVersion = (prefix ~= 1 and prefix or "") .. name.."("..version..")" .. (type(tail) == "string" and tail or "")
			else
				withVersion = false
			end
			libReplaceCache[name] = withVersion
			return withVersion
		end

		local addonReplaceCache = {}
		local function appendAddonVersion(addonName)
			local withVersion = addonReplaceCache[addonName]
			if  withVersion ~= nil  then  return withVersion  end
			
			withVersion = false
			-- See if we can get some addon metadata
			if  IsAddOnLoaded(addonName)  then
				local version = GetAddOnMetadata(addonName, "X-Curse-Packaged-Version")
					or  GetAddOnMetadata(addonName, "Version")
				if version then  withVersion = addonName.."("..version..")"  end
			end
			addonReplaceCache[addonName] = withVersion
			return withVersion
		end

		local addonPrefix = [[Interface\AddOns\]]
		local addonRegex = [[^Interface\AddOns\([^\]+)]]  -- Interface\AddOns\<addonName>\
		local libRegex = [[(\)([^\]+)(%.lua)]]            -- \<Anything-except-backslashes>.lua
		--[[
		local matchers = {
			"(\\)([^\\]+)(%.lua)",       -- \Anything-except-backslashes.lua
			"^()([^\\]+)(\\)",           -- Start-of-the-line-until-first-backslash\
			"()(%a+%-%d%.?%d?)()",       -- Anything-#.#, where .# is optional
			"()(Lib%u%a+%-?%d?%.?%d?)()" -- LibXanything-#.#, where X is any capital letter and -#.# is optional
		} --]]
		function findVersions(line)
			-- if not line or line:find("FrameXML\\") then return line end
			line = line:gsub(addonRegex, appendAddonVersion)
			line = line:gsub(libRegex, appendLibVersion)
			line = line:gsub(addonPrefix, "")
			return line
		end
	end

end  -- GrabError and helper functions


-- Replace errorhandler with GrabError after its helper functions are loaded.
ErrorHandler = GrabError
original.seterrorhandler(ErrorHandler)



--[[
-----------------------------------------------------------------------
-- ErrorHandlerDispatcher manages multiple error handlers.

local ErrorHandlers = {}

local runningErrorHandlers = {}
local dispatcherLevel = nil
local dispatchingError
local skipStackFrames = 0
local hooked = {}
hooked.debugstack, hooked.debuglocals = _G.debugstack, _G.debuglocals
-- skipStackFrames + 1: skip the hook BugGrabber.debugstack() aswell
function BugGrabber.debugstack (skip, ...)  return hooked.debugstack (type(skip) == 'number'  and  skip > 1  and  skip + skipStackFrames + 1  or  skip, ...)  end
function BugGrabber.debuglocals(skip, ...)  return hooked.debuglocals(type(skip) == 'number'  and  skip > 1  and  skip + skipStackFrames + 1  or  skip, ...)  end

local ErrorHandlerDispatcher

-- The global errorhandler that dispatches to registered errorhandlers, including GrabError.
function BugGrabber.ErrorHandlerDispatcher(errorParam, options)
	local parentLevel = dispatcherLevel
	dispatcherLevel = (parentLevel or 0) + 1
	if  2 < dispatcherLevel  then
		if  dispatcherLevel <= 3 then
			-- Called recursively 2 times:  error() -> dispatcher 1 -> error() -> dispatcher 2 -> error() -> dispatcher 3.
			reportInternalError(FUNCTION_COLOR.."BugGrabber.ErrorHandlerDispatcher()|r"..MESSAGE_COLOR.." entered an infinite loop while handling error:|r\n"..tostring(errorParam))
		else
			-- This got out of hand. Do nothing.
		end
		dispatcherLevel = parentLevel
		return errorParam
	end
	
	if  dispatchingError == errorParam  then
		-- Called recursively with same error parameter: very likely it was called from an additionalHandler intending to replace the Bliz handler.
		-- Swatter would do this if disabled with /swat disable. No problem as Swatter addon should not be loaded.
		-- Other addons hopefully don't hook like this. Although if it happens this code will just report and return.
		local ran, caller = original.pcall(original.debugstack, 4, 1, 0)
		reportInternalError( FUNCTION_COLOR.."BugGrabber.ErrorHandlerDispatcher()|r"..MESSAGE_COLOR.." recursively called from hooking errorhandler:|r\n"
			..(caller or "<debugstack() failed>").."\nWhile handling error:|r\n" .. tostring(errorParam) )
		dispatcherLevel = parentLevel
		return errorParam
	end
	
	-- Show frame to run OnUpdate() on next framedraw. It notifies callbacks and checks if ErrorHandlerDispatcher returned correctly, clearing dispatcherLevel.
	original.pcall(frame.Show, frame)
	
	-- Hook debug functions to skip the dispatcher from the callstack.
	hooked.debugstack, hooked.debuglocals = _G.debugstack, _G.debuglocals
	_G.debugstack, _G.debuglocals = BugGrabber.debugstack, BugGrabber.debuglocals
	local handlersRan, handler, firstResult, wasError = 0
	-- local function handlerThunk()  local res = handler(errorParam, options) ; return res  end  -- Disable tail cail for readable stacktrace.
	local function handlerThunk()  return handler(errorParam, options)  end
	
	for  i = 1,#ErrorHandlers  do
		handler = ErrorHandlers[i]
		if  not runningErrorHandlers[handler]  then
			-- Catching errors in handlers will recurse, then skip the faulty errorhandler.
			runningErrorHandlers[handler] = handler
			skipStackFrames = 4    -- skip RuntimeErrorHandler, ErrorHandlerDispatcher, xpcall, handlerThunk -- tailcall is visible in stacktrace
			local ran, result
			-- If recursive (internal error in a handler) then fail silently (pcall) and reportInternalError at the end.
			if  not parentLevel  then  ran, result = original.xpcall(handlerThunk, RuntimeErrorHandler)
			else  ran, result = original.pcall(handler, errorParam, options)
			end
			skipStackFrames = 0
			runningErrorHandlers[handler] = nil
			firstResult = firstResult  or  ran and result
			if  ran  then
				handlersRan = handlersRan + 1
			elseif  not wasError  then
				reportInternalError( FUNCTION_COLOR.."BugGrabber.ErrorHandlerDispatcher()|r"..MESSAGE_COLOR.." encountered internal error in errorhandler:|r\n".. tostring(result) )
				reportInternalError( errorParam )
				wasError = true
			end
		end
	end
	
	-- Restore hooked debug functions. Errorhandlers are expected to not change these permanently, otherwise their hook is lost.
	_G.debugstack, _G.debuglocals = hooked.debugstack, hooked.debuglocals
	
	-- If GrabError failed then use Bliz errorhandler.
	if  not wasError  and  not newError[errorParam]  then  reportInternalError(FUNCTION_COLOR.."BugGrabber|r"..MESSAGE_COLOR.." failed to save error:|r\n"..tostring(errorParam))  end
	
	dispatcherLevel = parentLevel
	-- xpcall() will return what this errorhandler returns:
	return firstResult or errorParam
end
-- END BugGrabber.ErrorHandlerDispatcher()
ErrorHandlerDispatcher = BugGrabber.ErrorHandlerDispatcher


-- BugGrabber.ErrorHandlerDispatcher = ErrorHandlerDispatcher
BugGrabber.GrabError = GrabError

local internalHandlers = {} 
internalHandlers[GrabError] = true
internalHandlers[ErrorHandlerDispatcher] = true
internalHandlers[original.errorhandler] = true


-- Add additional errorhandler.
function BugGrabber.adderrorhandler(additionalHandler)
	assert(additionalHandler, "Provide parameter additionalHandler for BugGrabber.adderrorhandler(additionalHandler: function)")
	if  internalHandlers[additionalHandler]  then
		-- local old = geterrorhandler() ; seterrorhandler(otherHandler) ; dosomthin() ; seterrorhandler(old)  -- results in old == ErrorHandlerDispatcher
		-- meaning it is meant to remove the last added otherHandler
		return BugGrabber.removeerrorhandler()
	elseif  not ErrorHandlers[additionalHandler]  then
		ErrorHandlers[#ErrorHandlers+1] = additionalHandler
		ErrorHandlers[additionalHandler] = additionalHandler
	else
		-- Added again, so ignore. Probably a result of calling seterrorhandler(additionalHandler) twice, maybe there was a seterrorhandler(otherHandler) in between.
	end
end

-- Remove additional errorhandler.
function BugGrabber.removeerrorhandler(handler)
	-- Remove the last added handler if not specified. If specified, it is probably the last one, so search in reverse from the end.
	local index =  not handler  and  #ErrorHandlers  or  tindexOfRev(ErrorHandlers, handler)  or  0
	-- Do not remove ErrorHandlers[1] == ErrorHandlerDispatcher  and  return if #ErrorHandlers == 0
	if  index <= 1  then  return nil  end
	
	-- Remove from the array
	local found = table.remove(ErrorHandlers, index)
	-- Remove from the map. If it wasn't found in the array then remove the provided handler.
	ErrorHandlers[found or handler] = nil
	return found
end

function BugGrabber.geterrorhandler()  return  ErrorHandler  end


-----------------------------------------------------------------------
-- Replace the global errorhandler

-- The first handler.
BugGrabber.adderrorhandler(GrabError)

if  original.errorhandler ~= _G._ERRORMESSAGE  then
	print("The builtin errorhandler has already been hooked before BugGrabber loaded. BugGrabber will replace it and call it if an error occurs.")
	print("To avoid this message disable one of the addons, or add the  "..ORANGE_FONT_COLOR_CODE.."OptionalDeps: !BugGrabber|r  field to the other addon's .toc file.")
	BugGrabber.adderrorhandler(original.errorhandler)
end

-- Replace GrabError with ErrorHandlerDispatcher.
ErrorHandler = RuntimeErrorHandler
original.seterrorhandler(ErrorHandler)

-- The global seterrorhandler() will add the errorhandler without replacing other handlers.
_G.seterrorhandler = BugGrabber.adderrorhandler
_G.geterrorhandler = BugGrabber.geterrorhandler

--]]


-----------------------------------------------------------------------
-- API for addons:
--

-----------------------------------------------------------------------
-- Callbacks

function BugGrabber.RegisterCallback(...)
	local oldMockFunc = BugGrabber.RegisterCallback
	local CallbackHandler = _G.LibStub("CallbackHandler-1.0")
	callbacks = CallbackHandler:New(BugGrabber)
	-- Overwrote the RegisterCallback method?
	if  oldMockFunc == BugGrabber.RegisterCallback  then  return false  end
	-- Call the real method
	return BugGrabber.RegisterCallback(...)
end

function triggerEvent(eventName, ...)
	if  not callbacks  then  return  end
	local handlers = rawget(callbacks.events, eventName)
	local hasHandlers = handlers and next(handlers) and true
	local handlersRan = callbacks:Fire(eventName, ...)
	return hasHandlers
end


-- Notify callbacks (BugSack, Bugger) in the next draw cycle.
function frame:OnUpdate(elapsed)
	local err = newError[1]
	if  dispatcherLevel  then
		reportInternalError(FUNCTION_COLOR.."BugGrabber.ErrorHandlerDispatcher()|r"..MESSAGE_COLOR.." did not run to completion.|r")
		-- Reset to indicate ErrorHandlerDispatcher is not running.
		dispatcherLevel = nil
	end
	
	-- No OnUpdate() until next error.
	wipe(newError)
	self:Hide()
	
	local handled = triggerEvent("BugGrabber_BugGrabbed", err)
	if  err  then
		if  BugGrabber.PrintErrorLinks == nil and not handled  or  BugGrabber.PrintErrorLinks  then
			BugGrabber.PrintErrorLink(err)
		end
	end
end



-- Returns nil before ADDON_LOADED (SavedVariables loaded)
function BugGrabber:GetSessionId()  return currentSessionId  end
-- Returns true if BugGrabber catches too many errors and stopped saving all of them (throttled down).
function BugGrabber:IsPaused() return self.paused end

-- Get errors in current session.
function BugGrabber:GetSessionErrors()  return currentSessionDB  end
-- Get archived errors from previous sessions.
function BugGrabber:GetPreviousErrors()  return previousDB or {}  end

-- Get all errors in one array.
-- Use BugGrabber:GetSessionErrors() to query current session.
function BugGrabber:GetDB()
	if  allErrors  then  return allErrors  end
	-- If only one session then return it.
	if  not previousDB  or  #previousDB == 0  then
		allErrors = currentSessionDB
		return allErrors
	end
	
	-- Otherwise concatenate session arrays.
	allErrors = {}
	for  _, err  in ipairs(previousDB) do        allErrors[#allErrors+1] = err  end
	for  _, err  in ipairs(currentSessionDB) do  allErrors[#allErrors+1] = err  end
	return allErrors
end

-- Delete all errors.
function BugGrabber:Reset()
	self.poppedOriginalHandler = nil
	self.internalError = nil
	self.internalErrorTime = nil
	
	-- Reset to indicate ErrorHandlerDispatcher is not running.
	dispatcherLevel = nil
	wipe(newError)
	
	allErrors = nil
	wipe(currentSessionDB)
	if  currentSessionId  then  currentSessionId = 1  end
	if  _G.BugGrabberDB  then  _G.BugGrabberDB.session = currentSessionId  end
	if  previousDB  then
		wipe(previousDB)
		-- _G.BugGrabberDB.previousDB (== previousDB) is empty as a result.
	end
	
	-- Update display
	triggerEvent("BugGrabber_BugGrabbed", nil)
	-- print(L["All stored bugs have been exterminated painfully."])
end



function BugGrabber:GetErrorID(errorObject) return tostring(errorObject):sub(8) end

function BugGrabber:GetErrorByPlayerAndID(player, id)
	if player == playerName then return self:GetErrorByID(id) end
	print(L.ERROR_UNABLE)
end

function BugGrabber:GetErrorByID(errorId)
	local objId = "table: "..errorId
	-- errorId == objId:sub(8)
	
	local t = currentSessionDB
	for  i = #t,1,-1  do  if  tostring(t[i]) == objId  then  return t[i]  end end
	if  not previousDB  then  return  end
	t = previousDB[sIdx]
	for  i = #t,1,-1  do  if  tostring(t[i]) == objId  then  return t[i]  end end
end


-----------------------------------------------------------------------
-- Error printing in chat

function BugGrabber.PrintErrorObject(errorObject)
	local done
	local display = BugGrabber.DisplayAddons[1]
	if type(display) == "table" then
		-- Note: For compatibility reason display:ShowError(errorObject) cannot be used, using :DisplayError(errorObject) instead.
		-- Bugger addon allocated :ShowError(index), expecting a number as parameter, and crashing if provided an errorObject.
		if  type(display.DisplayError) == "function"  then
			-- display:DisplayError(errorObject) ; done = true
			done = xpcall(function()  display:DisplayError(errorObject)  end, _G.geterrorhandler())
		end
		if  not done  and  type(display.FormatError) == "function"  then
			done = xpcall(function()  print(display:FormatError(errorObject))  end, _G.geterrorhandler())
		end
	end
	if not done then
		print(tostring(errorObject.message))
		print(tostring(errorObject.stack))
		print(tostring(errorObject.locals))
	end
end

-----------------------------------------------------------------------
-- Error links in chat

-- Weak keyed map from errorObject -> time when it was printed. Entries are automatically dropped and gc'd when deleted from previousDB.
local lastPrintTime = setmetatable({}, { __mode = "k" })

function BugGrabber.PrintErrorLink(errorObject)
	local now = time()
	local lastTime = lastPrintTime[errorObject]
	if  not lastTime  then
		-- print only once every error
		lastPrintTime[errorObject] = now
		print(L.ERROR_DETECTED:format(BugGrabber:GetChatLink(errorObject)))
	end
end


do
	local function createChatHook()
		-- Set up the ItemRef hook that allow us to link bugs.
		local SetHyperlink = ItemRefTooltip.SetHyperlink
		function ItemRefTooltip:SetHyperlink(link, ...)
			local player, tableId = link:match("^buggrabber:([^:]+):(%x+)")
			if player then
				BugGrabber:HandleBugLink(player, tableId, link)
			else
				SetHyperlink(self, link, ...)
			end
		end
	end

	-- We need to hook the chat frame when anyone requests a chat link from us,
	-- in case some other addon has hooked :HandleBugLink to process it. If not,
	-- we could've just created the hook in GrabError when we do the print.
	function BugGrabber:GetChatLink(errorObject)
		if createChatHook then createChatHook() createChatHook = nil end
		local tableId = tostring(errorObject):sub(8)
		return chatLinkFormat:format(playerName, tableId, errorObject.message)
	end
end

function BugGrabber:HandleBugLink(player, id, link)
	local errorObject = self:GetErrorByPlayerAndID(player, id)
	if  not errorObject  then  return  end
	BugGrabber.PrintErrorObject(errorObject)
end




-----------------------------------------------------------------------
-- Initialization
--

local function initDatabase()
	assert(not previousDB, "initDatabase() called twice")
	local sv = _G.BugGrabberDB
	if  type(sv) ~= "table"  then
		sv = {}
		_G.BugGrabberDB = sv
	end
	
	sv.lastSanitation = nil
	sv.sessionsDB = nil

	previousDB = type(sv.previousErrors) == "table"  and  0 < #sv.previousErrors  and  sv.previousErrors
	local lastDB = type(sv.errors) == "table"  and  0 < #sv.errors  and  sv.errors

	-- Migrate sv.errors from previous session into previousDB.
	if  lastDB  and  previousDB  then
		-- Append lastDB to previousDB
		for  i = 1,#lastDB  do  previousDB[#previousDB+1] = lastDB[i]  end
		lastDB = nil
	elseif  lastDB  then
		-- No previousDB so lastDB becomes previousDB.
		previousDB = lastDB
		sv.previousErrors = previousDB
	elseif  not previousDB  then
		-- Empty previousDB to avoid nil pointer. Not saved to sv.previousErrors
		previousDB = {}
		sv.previousErrors = nil
	else
		-- 0 < #previousDB  and  previousDB == sv.previousErrors
	end

	-- Increase currentSessionId
	currentSessionId = sv.previousErrors and type(sv.session) == "number" and sv.session + 1  or  1
	sv.session = currentSessionId
	-- Store currentSessionDB: errors from this session.
	sv.errors = currentSessionDB

	-- If there were any load errors, we need to iterate them,
	-- set the session id and add previous error counter, if any.
	for  i,err  in ipairs(currentSessionDB)  do
		err.session = currentSessionId -- Update the session ID directly
		local existed = fetchFromDatabase(err.message)
		if  existed  then  err.counter = err.counter + existed.counter  end
		-- existed was removed from previousDB.
	end

	-- load locales
	if type(BugGrabber.LoadTranslations) == "function" then
		local locale = GetLocale()
		if locale ~= "enUS" and locale ~= "enGB" then
			BugGrabber:LoadTranslations(locale, L)
		end
		BugGrabber.LoadTranslations = nil
	end

	initDatabase = nil
end


function BugGrabber:CheckDisplayAddon()
	if  not self.DisplayAddons[1]  then
		-- Should implement :FormatError(errorTable).
		for i = 1, GetNumAddOns() do
			local displayObjectName = GetAddOnMetadata(i, "X-BugGrabber-Display")
			if displayObjectName then
				local _, _, _, enabled = GetAddOnInfo(i)
				if enabled then
					table.insert(self.DisplayAddons, _G[displayObjectName])
					break
				end
			end
		end
	end

	if  not self.DisplayAddons[1]  then
		local sv = _G.BugGrabberDB
		local _, _, _, currentInterface = GetBuildInfo()
		if type(currentInterface) ~= "number" then currentInterface = 0 end
		if not sv.stopnag or sv.stopnag < currentInterface then
			print(L.NO_DISPLAY_1)
			print(L.NO_DISPLAY_2)
			print(L.NO_DISPLAY_STOP)
			_G.SlashCmdList.BugGrabberStopNag = function()
				print(L.STOP_NAG)
				sv.stopnag = currentInterface
			end
			_G.SLASH_BugGrabberStopNag1 = "/stopnag"
		end
	end
end

function BugGrabber:CheckErrorHandler(event)
	local runtimeHandler, publicHandler = original.geterrorhandler(), _G.geterrorhandler()
	if  runtimeHandler ~= ErrorHandler  then
		original.seterrorhandler(ErrorHandler)
		if  runtimeHandler == _G._ERRORMESSAGE  then  runtimeHandler = '_ERRORMESSAGE'  end
		print(event.."(): BugGrabber's errorhandler was replaced with "..tostring(runtimeHandler)..". This can be done only by the client or with internal knowledge of BugGrabber, as seterrorhandler() won't do it.")
	elseif  publicHandler ~= ErrorHandler  then
		if  publicHandler == _G._ERRORMESSAGE  then  runtimeHandler = '_ERRORMESSAGE'  end
		print(event.."(): BugGrabber's errorhandler was replaced in geterrorhandler() with "..tostring(publicHandler))
	end
end


local function createSwatter()
	-- Need this so Stubby will feed us errors instead of just
	-- dumping them to the chat frame.
	_G.Swatter = {
		IsEnabled = function() return true end,
		OnError = function(msg, frame, stack, etype, ...)
			ErrorHandler(msg, { stack = stack })
		end,
		isFake = true,
	}
end

local function disableSwatter()
	print(L.ADDON_DISABLED:format("Swatter", "Swatter", "Swatter"))
	DisableAddOn("!Swatter")
	SlashCmdList.SWATTER = nil
	SLASH_SWATTER1, SLASH_SWATTER2 = nil, nil
	for k, v in next, _G.Swatter do
		if type(v) == "table" then
			if v.UnregisterAllEvents then
				v:UnregisterAllEvents()
			end
			if v.Hide then
				v:Hide()
			end
		end
	end
	_G.Swatter = nil

	local _, _, _, enabled = GetAddOnInfo("Stubby")
	if enabled then createSwatter() end

	BugGrabber:CheckErrorHandler(event)
end

-----------------------------------------------------------------------
-- Event handlers
--

function frame:ADDON_LOADED(event, addonName)
	if addonName == "Stubby" then createSwatter() end
	if initDatabase then
		-- If we're running embedded, just init as soon as possible,
		-- but if we are running separately we init when !BugGrabber
		-- loads so that our SVs are available.
		if ADDON_NAME ~= STANDALONE_NAME or addonName == ADDON_NAME then
			initDatabase()
		end
	end

	if Swatter and not Swatter.isFake then
		BugGrabber.swatterDisabled = true
		disableSwatter()
	end
end


function frame:PLAYER_LOGIN(event)
	-- Was the errorhandler replaced?
	BugGrabber:CheckErrorHandler(event)
	
	-- Only warn about missing display if we're running standalone.
	if  ADDON_NAME == STANDALONE_NAME  then  BugGrabber:CheckDisplayAddon()  end
	
	frame:UnregisterEvent("PLAYER_LOGIN")
	frame.PLAYER_LOGIN = nil
end


local badAddons = {}
function frame:ADDON_ACTION_FORBIDDEN(event, addonName, addonFunc)
	local name = addonName or "<name>"
	if not badAddons[name] then
		badAddons[name] = addonFunc
		ErrorHandler(L.ADDON_CALL_PROTECTED:format(event, name or "<name>", addonFunc or "<function>"))
	end
end
frame.ADDON_ACTION_BLOCKED = frame.ADDON_ACTION_FORBIDDEN -- XXX Unused?


-- Re-enabled until someone complains and demands that they go away again.
local function registerAddonActionEvents()
	frame:RegisterEvent("ADDON_ACTION_BLOCKED")
	frame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
end

local function unregisterAddonActionEvents()
	frame:UnregisterEvent("ADDON_ACTION_BLOCKED")
	frame:UnregisterEvent("ADDON_ACTION_FORBIDDEN")
end


frame:SetScript("OnUpdate", frame.OnUpdate)
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
registerAddonActionEvents()



-----------------------------------------------------------------------
-- Slash handler
--

local function slashHandler(indexStr)
	local index =  indexStr  and  tonumber(indexStr)  or  #currentSessionDB
	local err = type(index) == "number" and currentSessionDB[index]
	if  not err  then
		print(L.USAGE:format(#currentSessionDB))
		return
	end
	BugGrabber.PrintErrorObject(err)
end

-- Set up slash command
_G.SlashCmdList.BugGrabber = slashHandler
_G.SLASH_BugGrabber1 = "/buggrabber"
_G.SLASH_BugGrabber2 = "/bug"




--[[ Builtin error handler from FrameXML/BasicControls.xml:
	<!-- This function is called when a script error occurs -->
	<Script>
		_ERROR_COUNT = 0;
		_ERROR_LIMIT = 1000;
		
		function _ERRORMESSAGE(message)
			debuginfo() -- Debugging information for internal use.
			
			LoadAddOn("Blizzard_DebugTools");
			local loaded = IsAddOnLoaded("Blizzard_DebugTools");
			
			if ( GetCVarBool("scriptErrors") ) then
				if ( not loaded or DEBUG_DEBUGTOOLS ) then
					BasicScriptErrorsText:SetText(message);
					BasicScriptErrors:Show();
					if ( DEBUG_DEBUGTOOLS ) then
						ScriptErrorsFrame_OnError(message);
					end
				else
					ScriptErrorsFrame_OnError(message);
				end
			elseif ( loaded ) then
				local HIDE_ERROR_FRAME = true;
				ScriptErrorsFrame_OnError(message, false, HIDE_ERROR_FRAME);
			end
			
			-- Show a warning if there are too many errors
			_ERROR_COUNT = _ERROR_COUNT + 1;
			if ( _ERROR_COUNT == _ERROR_LIMIT ) then
				StaticPopup_Show("TOO_MANY_LUA_ERRORS");
			end

			return message;
		end

		seterrorhandler(_ERRORMESSAGE);
	</Script>
--]]

