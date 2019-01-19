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

