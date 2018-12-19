--[[========================================================================================
      ActionSwap 2, a World of Warcraft addon which swaps out sets of actions, glyphs, and
      keybindings.
      
      Copyright (c) 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      All Rights Reserved unless otherwise explicitly stated.
    ========================================================================================]]

-- This is a small replacement for AceEvent that allows you to implement the observer
-- pattern by firing messages on a per-object basis rather than globally, and also
-- allows multiple observers for each message.

local AS2 = ActionSwap2
if AS2.DEBUG and LibDebug then LibDebug() end
local AceEvent = LibStub("AceEvent-3.0")

local dispatchedFuncs = { }

-- Registers a message that will be sent from the given object.
function AS2:RegisterMessage(object, message)
	assert(object and message, "NIL_ARGUMENT")
	if not object.callbacks then object.callbacks = { } end
	assert(not object.callbacks[message], "Message already defined")
	object.callbacks[message] = { }
end

-- Registers a function that will be called when the given message fires on the given object.
-- (context is the first parameter passed to that function)
function AS2:AddCallback(object, message, callback, context)
	assert(object and message and callback, "NIL_ARGUMENT")
	assert(object.callbacks and object.callbacks[message], "Message not defined")
	tinsert(object.callbacks[message], {callback, context})
end

-- Unregisters a function/callback pair from the given message on the given object.
function AS2:RemoveCallback(object, message, callback, context)
	assert(object and message and callback, "NIL_ARGUMENT")
	assert(object.callbacks and object.callbacks[message], "Message not defined")
	for i, c in ipairs(object.callbacks[message]) do
		if c[1] == callback and c[2] == context then
			tremove(object.callbacks[message], i)
			return
		end
	end
	error("Callback not found")
end

-- Unregisters all callbacks associated with the given context.
function AS2:RemoveAllCallbacksWithContext(object, context)
	assert(object, "NIL_ARGUMENT")
	if object.callbacks then
		for message, callbacks in pairs(object.callbacks) do
			for i = #callbacks, 1, -1 do
				if callbacks[i][2] == context then
					tremove(callbacks, i)
				end
			end
		end
	end
end

-- Sends the given message from the given object, notifying all observers.
function AS2:SendMessage(object, message, ...)
	assert(object and message, "NIL_ARGUMENT")
	assert(object.callbacks and object.callbacks[message], "Message not defined")
	for _, c in ipairs(object.callbacks[message]) do
		c[1](c[2], ...)
	end
end

-- Executes the given function on the next update instead of immediately.
-- (when combined with flags, useful in collapsing multiple update messages)
function AS2:Dispatch(func, arg)
	tinsert(dispatchedFuncs, function() func(arg) end)	-- MAINTENANCE: Investigate whether this can be done more efficiently (w/o the function objects)
end

-- (displays the error, but doesn't halt execution)
local function myErrorHandler(err)
	_ERRORMESSAGE(err)
end

-- Runs all functions dispatched since the last call.
function AS2:RunDispatched()
	local count = #dispatchedFuncs
	if count > 0 then	-- (small optimization; not sure how efficient wiping an empty table is)
		for i = 1, count do
			xpcall(dispatchedFuncs[i], myErrorHandler)
		end
		wipe(dispatchedFuncs)
	end
end

-- Though we've largely replaced the messaging system of AceEvent, do import certain features.
AS2.RegisterEvent = AceEvent.RegisterEvent
AS2.UnregisterEvent = AceEvent.UnregisterEvent
