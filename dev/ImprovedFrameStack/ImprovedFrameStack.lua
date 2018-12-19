﻿-- Better framestack


local function insert(t, k)
	
	tinsert(t, 1, k)
end

local STR_UNKNOWN = "?"

-- Format the path nicely for the tooltip. Make it look like an actual["table"]["lookup"]["chain"]
local function fmt(t)
	local s = ""
	for i = 1, #t do
		local k = t[i]
		local str = tostring(k)
		
		if i == 1 then
			s = k
		else
			if type(k) == "number" then
				k = "[" .. k .. "]"
			elseif str == STR_UNKNOWN then
				k = "[" .. str .. "]"

			--elseif str:find("[^A-Za-z_0-9]") or str:find("^[0-9]") then
			else
				k = "[\"" .. str .. "\"]"

			--else
			--    k = "." .. str
			end

			s = s .. k
		end
	end
	
	return s
end


local searchResults = {}
local fmtTable = {}

-- Generate the path for a frame and store it in searchResults
local function scanTables(parent, child, depth, maxDepth)
	depth = depth + 1
	for k, v in pairs(parent) do
		if v == child then
			insert(fmtTable, k)
			return true
		end
	end

	-- Breadth first. Limit the depth each time.
	for i = depth+1, maxDepth do
		for k, v in pairs(parent) do
			if type(v) == "table" and depth < maxDepth then
				local found = scanTables(v, child, depth, i)
				if found then
					insert(fmtTable, k)
					return true
				end
			end
		end
	end
end

local function generateFramePathString(frame)
	wipe(fmtTable)

	local parent = frame

	-- Edge case: no parent at all.
	if not frame:GetParent() then
		searchResults[tostring(frame)] = "<No Parent>"
		return
	end
	
	local done = false
	while true do
		local child = parent
		parent = parent:GetParent()
		
		-- Might happen if a frame was orphaned on purpose.
		-- Accidental ophaning isn't possible in WoW as far as I know,
		-- with maybe exception of changing a scroll child and not re-parenting the old child
		if not parent then 
			break
		end
		
		local foundChildKey = scanTables(parent, child, 0, IFS_MaxDepth or 3)


		if not foundChildKey then
			-- We didn't find a key so that parent[key] = child, so insert STR_UNKNOWN
			-- to show that there is no straightforward ref from parent to child.
			insert(fmtTable, STR_UNKNOWN)
		end

		if parent:GetName() then
			-- This parent is named, so we now have a path from a named ancestor to the current frame.
			-- This is what we want, so we are done with this frame now.
			insert(fmtTable, parent:GetName())

			searchResults[tostring(frame)] = fmt(fmtTable)

			return
		end
	end


	insert(fmtTable, "<Unknown Parent>")

	searchResults[tostring(frame)] = fmt(fmtTable)
end


-- Maintains a map of {[address] = frame} so that we don't have to enumerate over every frame 
-- every single time we do a search in order to find the frames we want to lookup.
-- We can't just store the resolved path because, although it will very seldom happen, it can change,
-- and if our improved tooltip doesn't reflect changes in parents then that will lead to some very confused developers.
-- Doing it this way should prevent us from calling EnumerateFrames 99% of the time.
local frameCache = setmetatable({}, {__mode='kv'})
local function cacheFrame(frame)
	frameCache[tostring(frame)] = frame
end

-- Search for all the anonymous frames in tableNames and store the results in searchResults.
local function searchForFrames(tableNames, numToFind)
	wipe(searchResults)
	
	if numToFind == 0 then
		return
	end

	local numFound = 0

	for frameName in pairs(tableNames) do
		local cachedFrame = frameCache[frameName]
		if cachedFrame then
			generateFramePathString(cachedFrame)
			numFound = numFound + 1
		end

		if numFound >= numToFind then
			return searchResults
		end
	end

	local frame = EnumerateFrames()
	while frame and numToFind > numFound do
		--if MouseIsOver(frame) then
			--local name = frame:GetName()
			--if not name then
			local str = tostring(frame)
			if tableNames[str] and not searchResults[str] then
				cacheFrame(frame)
				generateFramePathString(frame)
				numFound = numFound + 1
			end

			
		--end
		frame = EnumerateFrames(frame)
	end

	return searchResults
end

local framesToResolve = {}
-- Scan the tooltip and compile all the anonymous frames we need to resolve.
-- Store them in framesToResolve along with the fontString they are on in the tooltip.
local function getFramesToResolve(...)
	wipe(framesToResolve)
	local numToFind = 0

	for i = 1, select("#", ...) do
		local region = select(i, ...)

		if region:GetObjectType() == "FontString" then
			local text = region:GetText()
			if text then
				if text == " <0> WorldFrame" then
					break
				end
				
				local name = text:trim():match("<%d+> (.*)")

				if name and name:match("^table:") then
					framesToResolve[name] = region
					numToFind = numToFind + 1
				end
			end
		end
	end

	return numToFind
end




--[[ Highlight the frame under the mouse
/run a= GetMouseFocus()
/dump GetMouseFocus()
/dump GetMouseFocus():GetBackdrop()
/dump GetMouseFocus():GetBackdropColor()
/dump GetMouseFocus():GetBackdropBorderColor()
/run GetMouseFocus():SetBackdropColor()
--]]

local highlighter
local highBackdrop = { 
	bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 0,
	edgeSize = 4, 
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

local function HighlightFrame(newFrame)
	if  newFrame == WorldFrame  then  newFrame = nil  end
	if  not highlighter  then
		if  not newFrame  then  return  end
		highlighter = CreateFrame('Frame', "HighlighterFrame")
		--  https://wow.gamepedia.com/API_Frame_SetBackdrop
		--  https://wow.gamepedia.com/API_Frame_SetBackdropColor
		highlighter:SetBackdrop(highBackdrop)
		highlighter:SetBackdropColor(0.3,0.3,0.3,0.5)
		highlighter:SetBackdropBorderColor(0.5,1,0.5,0.75)
		
	end
	
	--highlighter:SetParent(newFrame)
	local ran, res = pcall(highlighter.SetParent, highlighter, newFrame)
	if  not ran  then  print("Frame "..(newFrame.GetName and newFrame:GetName() or "?").." not a good parent") ; highlighter:SetParent(nil) ; newFrame = nil  end
	
	if  newFrame  then
		highlighter:SetAllPoints()
		highlighter:Show()
	else
		highlighter:Hide()
		highlighter:ClearAllPoints()
	end
end



local function FrameStackTooltip_OnHide(self)
	highlighter:Hide()
	highlighter:SetParent(nil)
	highlighter = nil
end


-- Figure out what frames to resolve, search for those frames, and then modify the tooltip.
local function hook(self, doHidden)
	local numToFind = getFramesToResolve(self:GetRegions())

	local searchResults = searchForFrames(framesToResolve, numToFind)


	local maxLen = 0
	for tableName, TTfontString in pairs(framesToResolve) do
		local resolvedPath = searchResults[tableName]
		local tableNameReplace = tableName:gsub("table: 0+", "table: 0x")

		if not resolvedPath then
			TTfontString:SetText(TTfontString:GetText():gsub(tableName,  tableNameReplace .. " (couldn't resolve)"))
		else
			TTfontString:SetText(TTfontString:GetText():gsub(tableName,  resolvedPath .. " (" .. tableNameReplace .. ")"))
		end

		maxLen = max(maxLen, TTfontString:GetWidth())
	end

	if maxLen > FrameStackTooltip:GetWidth() then
		FrameStackTooltip:SetWidth(maxLen + 20)
	end
	
	HighlightFrame( GetMouseFocus() )
end



local function load(when)
	hooksecurefunc(FrameStackTooltip, "SetFrameStack", hook)
	FrameStackTooltip:HookScript("OnHide", FrameStackTooltip_OnHide)
	if  IsLoggedIn()  then  print("|cff33ff99ImprovedFrameStack|r: Loaded "..when.." Blizzard_DebugTools.")  end
end


if IsAddOnLoaded("Blizzard_DebugTools") then
	load("with")
else
	-- The .toc is set to ##LoadWith: Blizzard_DebugTools, so this should never happen.
	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", function(self, event, addon)
		if addon == "Blizzard_DebugTools" then
			load("after")
			f:UnregisterAllEvents()
		end
	end)
end