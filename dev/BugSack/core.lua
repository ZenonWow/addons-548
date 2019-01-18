local ADDON_NAME, addon = ...
local _G, L = _G, addon.L
local BugGrabber = BugGrabber

-----------------------------------------------------------------------
-- Make sure we are prepared
--

local function print(...) _G.print("|cff259054BugSack:|r", ...) end

if not BugGrabber then
	local msg = L["|cffff4411BugSack requires the |r|cff44ff44!BugGrabber|r|cffff4411 addon, which you can download from the same place you got BugSack. Happy bug hunting!|r"]
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", function()
		RaidNotice_AddMessage(RaidWarningFrame, msg, {r=1, g=0.3, b=0.1})
		print(msg)
		f:UnregisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", nil)
		f = nil
	end)
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	return
end

-- We seem fine, let the world access us.
_G[ADDON_NAME] = addon


local LSM

function addon:InitLSM()
	if  LSM  then  return  end
	LSM = _G.LibStub("LibSharedMedia-3.0", true)
	if  not LSM  then  return  end
	LSM:Register("sound", "TMW - Ding 1",  [[Interface\Addons\BugSack\Media\Ding1.ogg]])
	LSM:Register("sound", "BugSack: Fatality", [[Interface\AddOns\BugSack\Media\error.ogg]])
end


-----------------------------------------------------------------------
-- Utility
--

local eventFrame = CreateFrame("Frame")
-- eventFrame:Hide()

do
	local lastUpdate = 0
	local lastNotify = 0
	
	local function UpdateDisplay()
		lastUpdate = _G.GetTime()
		-- Update dataobject and frame if open.
		if  addon.window  then  addon.window:UpdateErrors()  end
		if  addon.dataobject  then  addon.dataobject:UpdateErrors()  end
	end

	local function ScheduleUpdateDisplay()
		-- Create a Timer to UpdateDisplay() after 2 seconds.
		-- This will update the changes from the last 2 seconds.
		if  not eventFrame.timer  then
			eventFrame.anim = eventFrame:CreateAnimationGroup()
			eventFrame.anim:SetLooping('NONE')
			eventFrame.timer = eventFrame.anim:CreateAnimation()
			eventFrame.timer:SetScript('OnFinished', UpdateDisplay)
			eventFrame.timer:SetDuration(2)
		end
		if  not eventFrame.anim:IsPlaying()  then
			eventFrame.anim:Play()
		end
	end
	
	function addon:BugGrabber_BugGrabbed(event, errorObject)
		-- print("BugSack:BugGrabber_BugGrabbed("..tostring(errorObject and errorObject.message)..")")
		-- Delay until end of loading screen. PLAYER_LOGIN() will call it.
		if  not IsLoggedIn()  then  return  end
		
		-- No more errors if errorObject == nil - BugGrabber:Reset() happened.
		if  not errorObject  then  return  end
		
		-- Throttle down to one UpdateDisplay() every 2 seconds.
		local now = _G.GetTime()
		if  2 <= now - lastUpdate  then  UpdateDisplay()
		else  ScheduleUpdateDisplay()
		end
		
		-- Throttle the notifications to one per 10 seconds.
		if  now - lastNotify < 10  then  return  end
		lastNotify = now
		if not self.db.mute then
			local sound = LSM and LSM:Fetch("sound", self.db.soundMedia)
			PlaySoundFile(sound)
		end
		if  self.db.chatframe then
			if  BugGrabber.PrintErrorLink  then  BugGrabber.PrintErrorLink(errorObject)
			else  print(L["There's a bug in your soup!"])
			end
		end
		if  self.db.auto  and  not InCombatLockdown()  then
			-- Open frame and select new error.
			self:OpenSack(errorObject)
		end
	end
end


-- Register with BugGrabber
do
	BugGrabber.RegisterCallback(addon, 'BugGrabber_BugGrabbed')  -- register addon:BugGrabber_BugGrabbed(event, errorObject)
	if  BugGrabber.DisplayAddons  then  table.insert(BugGrabber.DisplayAddons, addon)  end    -- _G.BugSack
	-- BugGrabber.PrintErrorLinks = false    -- Still print errors if OnError fails.
end

-- Register chat command
do
	SlashCmdList.BugSack = function()
		InterfaceOptionsFrame_OpenToCategory(ADDON_NAME)
		InterfaceOptionsFrame_OpenToCategory(ADDON_NAME)
	end
	SLASH_BugSack1 = "/bugsack"
	SLASH_BugSack2 = "/bs"
end



-----------------------------------------------------------------------
-- Event handling
--

eventFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

function eventFrame:ADDON_LOADED(event, loadedAddon)
	if loadedAddon ~= ADDON_NAME then return end
	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil

	if type(BugSackDB) ~= "table" then BugSackDB = {} end
	local sv = BugSackDB
	sv.profileKeys = nil
	sv.profiles = nil
	if type(sv.mute) ~= "boolean" then sv.mute = false end
	if type(sv.auto) ~= "boolean" then sv.auto = false end
	if type(sv.chatframe) ~= "boolean" then sv.chatframe = false end
	if type(sv.soundMedia) ~= "string" then sv.soundMedia = "TMW - Ding 1" end
	if type(sv.fontSize) ~= "string" then sv.fontSize = "GameFontHighlight" end
	addon.db = sv

	if  addon.dataobject  then  addon.dataobject:OnAddonLoaded()  end

	addon:InitComm()
	--error('test')
end

function eventFrame:PLAYER_LOGIN(event)
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
	addon:InitLSM()

	--[[
	-- TODO: pop up a tooltip on ldb dataobject or minimap icon to inform the user about any errors before this (while loading)
	-- Make sure we grab any errors fired before bugsack loaded.
	local session = addon:GetErrors(BugGrabber:GetSessionId())
	if #session > 0 then onError() end
	--]]
	if  BugGrabber.GetSessionErrors  then
		-- New version with separate session DBs.
		-- Show errors if there is at least one error.
		local sessionDB = BugGrabber:GetSessionErrors()
		if  sessionDB[1]  then  addon:BugGrabber_BugGrabbed(event, sessionDB[1])  end
	else
		-- Old version with flat DB containing errors from all sessions.
		-- Show errors if there last error is from this session.
		local db, sessionId = BugGrabber:GetDB(), BugGrabber:GetSessionId()
		if  db[#db].session == sessionId  then  addon:BugGrabber_BugGrabbed(event, db[#db])  end
	end
end

-----------------------------------------------------------------------
-- API
--

-- Call on user interaction (clicking error link).
function addon:DisplayError(errorObject)
	return addon:OpenSack(errorObject, true)
end

-- Call for auto-popup. Does not change the current error if already open.
function addon:OpenSack(errorObject, selectIfOpen)
	if  not self.window  then  return false  end
	-- If already open then leave the selected error as it is.
	if  selectIfOpen  or  not self.window:IsShown()  then
		self.window:SelectError(errorObject)
		ShowUIPanel(self.window)
	end
end

function addon:CloseSack()
	HideUIPanel(self.window)
end

function addon:Reset()
	self:CloseSack()
	BugGrabber:Reset()
end


do
	local function colorStack(ret)
		ret = tostring(ret) or "" -- Yes, it gets called with nonstring from somewhere /mikk
		ret = ret:gsub("[%.I][%.n][%.t][%.e][%.r]face\\", "")
		ret = ret:gsub("%.?%.?%.?\\?AddOns\\", "")
		ret = ret:gsub("|([^chHr])", "||%1"):gsub("|$", "||") -- Pipes
		ret = ret:gsub("<(.-)>", "|cffffea00<%1>|r") -- Things wrapped in <>
		ret = ret:gsub("%[(.-)%]", "|cffffea00[%1]|r") -- Things wrapped in []
		ret = ret:gsub("([\"`'])(.-)([\"`'])", "|cff8888ff%1%2%3|r") -- Quotes
		ret = ret:gsub(":(%d+)([%S\n])", ":|cff00ff00%1|r%2") -- Line numbers
		ret = ret:gsub("([^\\]+%.lua)", "|cffffffff%1|r") -- Lua files
		return ret
	end
	addon.ColorStack = colorStack

	local function colorLocals(ret)
		ret = tostring(ret) or "" -- Yes, it gets called with nonstring from somewhere /mikk
		ret = ret:gsub("[%.I][%.n][%.t][%.e][%.r]face\\", "")
		ret = ret:gsub("%.?%.?%.?\\?AddOns\\", "")
		ret = ret:gsub("|(%a)", "||%1"):gsub("|$", "||") -- Pipes
		ret = ret:gsub("> %@(.-):(%d+)", "> @|cffeda55f%1|r:|cff00ff00%2|r") -- Files/Line Numbers of locals
		ret = ret:gsub("(%s-)([%a_%(][%a_%d%*%)]+) = ", "%1|cffffff80%2|r = ") -- Table keys
		ret = ret:gsub("= (%-?[%d%p]+)\n", "= |cffff7fff%1|r\n") -- locals: number
		ret = ret:gsub("= nil\n", "= |cffff7f7fnil|r\n") -- locals: nil
		ret = ret:gsub("= true\n", "= |cffff9100true|r\n") -- locals: true
		ret = ret:gsub("= false\n", "= |cffff9100false|r\n") -- locals: false
		ret = ret:gsub("= <(.-)>", "= |cffffea00<%1>|r") -- Things wrapped in <>
		return ret
	end
	addon.ColorLocals = colorLocals

	-- Method for BugGrabber.DisplayAddons:
	local errorFormat = "%dx %s\n\nLocals:\n%s"
	function addon:FormatError(err)
		local s = colorStack(tostring(err.message) .. "\n" .. tostring(err.stack))
		local l = colorLocals(tostring(err.locals))
		return errorFormat:format(err.counter or -1, s, l)
	end
end



function addon:GetPreviousErrors()
	if  BugGrabber.GetPreviousErrors  then
		return BugGrabber:GetPreviousErrors()
	else
		local errors = {}
		local db = BugGrabber:GetDB()
		sessionId =  BugGrabber:GetSessionId()
		-- Select errors before this sessionId
		for i = 1,#db do
			if sessionId == db[i].session then  break  end
			errors[#errors+1] = db[i]
		end
		return errors
	end
end

function addon:GetSessionErrors()
	if  BugGrabber.GetSessionErrors  then
		return BugGrabber:GetSessionErrors()
	else
		local errors = {}
		local db = BugGrabber:GetDB()
		sessionId =  BugGrabber:GetSessionId()
		-- Select errors with this sessionId
		for i = 1,#db do
			if sessionId == db[i].session then
				errors[#errors+1] = db[i]
			end
		end
		return errors
	end
end

function addon:GetAllErrors()
	return  BugGrabber:GetDB()
end




function addon:InitComm()
	local ac = _G.LibStub("AceComm-3.0", true)
	if ac then ac:Embed(addon) end
	local as = _G.LibStub("AceSerializer-3.0", true)
	if as then as:Embed(addon) end

	if addon.RegisterComm then
		addon:RegisterComm("BugSack", "OnBugComm")
	end

	local popup = _G.StaticPopupDialogs
	if type(popup) ~= "table" then popup = {} end
	if type(popup.BugSackSendBugs) ~= "table" then
		popup.BugSackSendBugs = {
			text = L["Send all bugs from the currently viewed session (%d) in the sack to the player specified below."],
			button1 = L["Send"],
			button2 = CLOSE,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			hasEditBox = true,
			OnAccept = function(self, data)
				local recipient = self.editBox:GetText()
				addon:SendBugsToUser(recipient, data)
			end,
			OnShow = function(self)
				self.button1:Disable()
			end,
			EditBoxOnTextChanged = function(self, data)
				local t = self:GetText()
				if t:len() > 2 and not t:find("%s") then
					self:GetParent().button1:Enable()
				else
					self:GetParent().button1:Disable()
				end
			end,
			enterClicksFirstButton = true,
			--OnCancel = function() show() end, -- Need to wrap it so we don't pass |self| as an error argument to show().
			preferredIndex = STATICPOPUP_NUMDIALOGS,
		}
	end
end

-- Sends the current session errors to another player using AceComm-3.0
function addon:SendBugsToUser(player, session)
	if type(player) ~= "string" or player:trim():len() < 2 then
		error(L["Player needs to be a valid name."])
	end
	if not self.Serialize then return end

	local errors = self:GetErrors(session)
	if not errors or #errors == 0 then return end
	local sz = self:Serialize(errors)
	self:SendCommMessage("BugSack", sz, "WHISPER", player, "BULK")

	print(L["%d bugs have been sent to %s. He must have BugSack to be able to examine them."]:format(#errors, player))
end

function addon:OnBugComm(prefix, message, distribution, sender)
	if prefix ~= "BugSack" or not self.Deserialize then return end

	local good, deSz = self:Deserialize(message)
	if not good then
		print(L["Failure to deserialize incoming data from %s."]:format(sender))
		return
	end

	-- Store recieved errors in the current session database with a source set to the sender
	local s = BugGrabber:GetSessionId()
	for i, err in next, deSz do
		err.source = sender
		err.session = s
		BugGrabber:StoreError(err)
	end

	print(L["You've received %d bugs from %s."]:format(#deSz, sender))

	wipe(deSz)
	deSz = nil
end

--[[

do
	local commFormat = "1#%s#%s"
	local function transmit(command, target, argument)
		SendAddonMessage("BugGrabber", commFormat:format(command, argument), "WHISPER", target)
	end

	local retrievedErrors = {}
	function addon:GetErrorByPlayerAndID(player, id)
		if player == playerName then return self:GetErrorByID(id) end
		-- This error was linked by someone else, we need to retrieve it from them
		-- using the addon communication channel.
		if retrievedErrors[id] then return retrievedErrors[id] end
		transmit("FETCH", player, id)
		print(L.ERROR_INCOMING:format(id, player))
	end

	local fakeAddon, comm, serializer = nil, nil, nil
	local function commBugCatcher(prefix, message, distribution, sender)
		local good, deSz = fakeAddon:Deserialize(message)
		if not good then
			print("damnit")
			return
		end
		retrievedErrors[deSz.originalId] = deSz
		
	end
	local function hasTransmitFacilities()
		if fakeAddon then return true end
		if not serializer then serializer = LibStub("AceSerializer-3.0", true) end
		if not comm then comm = LibStub("AceComm-3.0", true) end
		if comm and serializer then
			fakeAddon = {}
			comm:Embed(fakeAddon)
			serializer:Embed(fakeAddon)
			fakeAddon:RegisterComm("BGBug", commBugCatcher)
			return true
		end
	end

	function frame:CHAT_MSG_ADDON(event, prefix, message, distribution, sender)
		if prefix ~= "BugGrabber" then return end
		local version, command, argument = strsplit("#", message)
		if tonumber(version) ~= 1 or not command then return end
		if command == "FETCH" then
			local errorObject = addon:GetErrorByID(argument)
			if errorObject then
				if hasTransmitFacilities() then
					errorObject.originalId = argument
					local sz = fakeAddon:Serialize(errorObject)
					fakeAddon:SendCommMessage("BGBug", sz, "WHISPER", sender, "BULK")
				else
					-- We can only transmit a gimped and sanitized message
					transmit("BUG", sender, errorObject.message:sub(1, 240):gsub("#", ""))
				end
			else
				transmit("FAIL", sender, argument)
			end
		elseif command == "FAIL" then
			print(L.ERROR_FAILED_FETCH:format(argument, sender))
		elseif command == "BUG" then
			print(L.CRIPPLED_ERROR:format(sender, argument))
		end
	end
end]]

