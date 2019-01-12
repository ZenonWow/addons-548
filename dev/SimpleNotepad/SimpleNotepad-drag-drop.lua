
--[[ Simple Notepad Drag and Drop links.
    Drag and Drop using left mouse bottom creating colour coded item Text.
    Links to tool tips. I hope.
    
    Thanks to SimpleNotepadEditBoxN Dancer (aka ZathrasEU) who wrote the code this is based on 
--]]

     -- SimpleNotepad_EditBox text formatting & insert code --
     
    --NOTES--
    -- clear character encoding from specified text --
    
function SimpleNotepadEditBoxN_ClearEscapeCodes(text)
	-- clear hyperlink encoding (but only if entire sequence is within our selected text) --
	text = text:gsub("(|H.-|h)(.-)(|h)", "%2")
	text = text:gsub("(|c%x%x%x%x%x%x%x%x)(.-)(|r)", "%2")
	return text
end


function SimpleNotepadEditBoxN_GetTextPositions(text, startTxt, endTxt, cursorPos)
	-- get positions of text markers within a string, with optional starting position --
	cursorPos = cursorPos or 0		-- default value of 0
	
	local pos = 1
	local startPtr = 0
	local endPtr = 0
	
	while (pos and pos < strlen(text)) do    
		startPtr = string.find(text, startTxt, pos, true)
		
		if (not startPtr) then 
			return nil, nil
		else
			endPtr = string.find(text, endTxt, startPtr, true)
			
			if (startPtr and startPtr < cursorPos and endPtr and endPtr > cursorPos) then
				return startPtr, endPtr + endTxt:len() - 1
			end
			
			pos = endPtr
		end
	end
	
	return nil, nil
end



    -- SimpleNotepadEditBoxN_EditBox cursor & selection code --

    -- WorldFrame:HookScript --
function SimpleNotepadEditBoxN_EditBoxMouseDown()
	SimpleNotepadEditBoxN_ClearFocus()
	SimpleNotepadEditBoxN_MouseButton = button
end


function SimpleNotepadEditBoxN_ClearFocus()
	if SimpleNotepadEditBoxN then SimpleNotepadEditBoxN:ClearFocus() end
	
end


function SimpleNotepadEditBoxN_EditBoxCursor(self, y, cursorHeight)
	local cursorPos = SimpleNotepadEditBoxN:GetCursorPosition()
	
	if cursorPos ~= SimpleNotepadEditBoxN_CursorPos then	-- only run code if editbox cursor changes (not mouse position)
		if SimpleNotepadEditBoxN_MouseButton == "LeftButton" then return end
		
		SimpleNotepadEditBoxN_UndoEnabled = 0
		
		-- scroll to cursor --
		y = -y
		local scroller = SimpleNotepadEditBoxN:GetParent()
		local offset = scroller:GetVerticalScroll()
		
		if y < offset then
			scroller:SetVerticalScroll(y)
		else
			y = y + cursorHeight - scroller:GetHeight()
			if y > offset then scroller:SetVerticalScroll(y) end
		end
		
		
		-- check for link --
	
		local text = SimpleNotepadEditBoxN:GetText()
		local startPtr, endPtr = SimpleNotepadEditBoxN_GetTextPositions(text, "|H", "|r", cursorPos)
		local x, y = GetCursorPosition()
		
		if (startPtr and endPtr) then
			-- we have found a link, so show its tooltip --
			GameTooltip:SetOwner(SimpleNotepadEditBoxN, "ANCHOR_TOPRIGHT")
			GameTooltip:SetHyperlink( strsub(text, startPtr, endPtr) )
		else
			-- no link, hide --
			GameTooltip:Hide()
			
			
			-- store selection & update cursor --
			
			if SimpleNotepadEditBoxN_MouseButton == "LeftButton" then
				local text = SimpleNotepadEditBoxN:GetText()
				SimpleNotepadEditBoxN:Insert("") -- Delete selected text
				
				local textNew = SimpleNotepadEditBoxN:GetText()
				local cursorNew = SimpleNotepadEditBoxN:GetCursorPosition()
				
				SimpleNotepadEditBoxN_SelectionStart = cursorNew
				SimpleNotepadEditBoxN_SelectionEnd = #text - (#textNew - cursorNew)
				
				-- Restore previous text --
				SimpleNotepadEditBoxN:SetText(text)
				
				-- always update cursor on left-click --
				SimpleNotepadEditBoxN_CursorPos = cursorPos
			else
				-- only update cursor if no selection --
				if SimpleNotepadEditBoxN_SelectionStart == SimpleNotepadEditBoxN_SelectionEnd and cursorPos ~= SimpleNotepadEditBoxN_SelectionStart then
					SimpleNotepadEditBoxN_CursorPos = cursorPos
				end
			end
			
			-- restore cursor & selection --
			SimpleNotepadEditBoxN_RestoreSelection()
		end
		
		SimpleNotepadEditBoxN_UndoEnabled = 1
	end
end


function SimpleNotepadEditBoxN_RestoreSelection()
	if SimpleNotepadEditBoxN then
		SimpleNotepadEditBoxN:SetCursorPosition(SimpleNotepadEditBoxN_CursorPos)
		
		if not SimpleNotepadEditBoxN_SelectionStart and not SimpleNotepadEditBoxN_SelectionEnd then
			-- force 'selection' to cursor pos if vars are nil --
			SimpleNotepadEditBoxN_SelectionStart = SimpleNotepadEditBoxN_CursorPos
			SimpleNotepadEditBoxN_SelectionEnd = SimpleNotepadEditBoxN_CursorPos
		end
			
		SimpleNotepadEditBoxN:HighlightText(SimpleNotepadEditBoxN_SelectionStart, SimpleNotepadEditBoxN_SelectionEnd)
	end
end

function SimpleNotepadEditBoxN_RestoreSelection()
	if SimpleNotepadEditBoxN then
		SimpleNotepadEditBoxN:SetCursorPosition(SimpleNotepadEditBoxN_CursorPos)
		
		if not SimpleNotepadEditBoxN_SelectionStart and not SimpleNotepadEditBoxN_SelectionEnd then
			-- force 'selection' to cursor pos if vars are nil --
			SimpleNotepadEditBoxN_SelectionStart = SimpleNotepadEditBoxN_CursorPos
			SimpleNotepadEditBoxN_SelectionEnd = SimpleNotepadEditBoxN_CursorPos
		end
			
		SimpleNotepadEditBoxN:HighlightText(SimpleNotepadEditBoxN_SelectionStart, SimpleNotepadEditBoxN_SelectionEnd)
	end
end


-- returns current selected text (or nil if no selection)
function SimpleNotepadEditBoxN_GetSelectedText()
	local text
	
	if SimpleNotepadEditBoxN_SelectionStart ~= nil and SimpleNotepadEditBoxN_SelectionEnd > SimpleNotepadEditBoxN_SelectionStart then
		text = SimpleNotepadEditBoxN:GetText()
		text = text:sub(SimpleNotepadEditBoxN_SelectionStart + 1, SimpleNotepadEditBoxN_SelectionEnd)
	end
	
	return text
end



    -- SimpleNotepadEditBoxN_EditBox text formatting & insert code --


    -- manages items dragged into EditBox --
    
function SimpleNotepadEditBoxN_Drag()
	local infoType, info1, info2 = GetCursorInfo()
	local text = ""
	
	if (infoType == "item") then
		text = info2
	elseif (infoType == "spell") then
        local skillType, spellId = GetSpellBookItemInfo(info1, "player")
        text = GetSpellLink(spellId)
	elseif (infoType == "merchant") then
		text = GetMerchantItemLink(info1)
	elseif (infoType == "macro") then
		text = GetMacroInfo(info1) .. " macro:\n" .. GetMacroBody(info1)
	end
	
	if text ~= "" and SimpleNotepadEditBoxN then
		SimpleNotepadEditBoxN:Insert(text)
	end
	
	ClearCursor()
end


    -- set selected text to hex colour --
function SimpleNotepadEditBoxN_EditBoxSetTextColour(colour)
	
	if SimpleNotepadEditBoxN and SimpleNotepadEditBoxN_SelectionStart ~= SimpleNotepadEditBoxN_SelectionEnd then
		local text = SimpleNotepadEditBoxN_GetSelectedText()							-- get text from EditBox
		local newText = "|cff" .. colour .. SimpleNotepadEditBoxN_ClearEscapeCodes(text) .. "|r"
		local sizeReduction = #text - #newText							-- calc size difference
		
		SimpleNotepadEditBoxN:Insert(newText)
		
		SimpleNotepadEditBoxN_CursorPos = SimpleNotepadEditBoxN_CursorPos - sizeReduction				-- update cursor pos
		SimpleNotepadEditBoxN_SelectionEnd = SimpleNotepadEditBoxN_SelectionEnd - sizeReduction			-- update selection var
		SimpleNotepadEditBoxN_RestoreSelection()										-- restore selection
	end
end


    -- clear selected text (or all text if no selection) --
function SimpleNotepadEditBoxN_EditBoxClearEscapes()
	
	local text = SimpleNotepadEditBoxN_GetSelectedText() -- get text from EditBox --
	if not text then text = SimpleNotepadEditBoxN:GetText() end	-- or entire text if no selection --
	
	local newText = SimpleNotepadEditBoxN_ClearEscapeCodes(text) -- set new var with cleared text --
	local sizeReduction = #text - #newText	-- calc size difference --
	
	SimpleNotepadEditBoxN_CursorPos = SimpleNotepadEditBoxN_CursorPos - sizeReduction -- update cursor pos --
	
	-- insert/set new text
	if SimpleNotepadEditBoxN_SelectionStart ~= nil and SimpleNotepadEditBoxN_SelectionEnd > SimpleNotepadEditBoxN_SelectionStart then
		SimpleNotepadEditBoxN:Insert(newText)
		SimpleNotepadEditBoxN_SelectionEnd = SimpleNotepadEditBoxN_SelectionEnd - sizeReduction -- update selection var --
		SimpleNotepadEditBoxN_RestoreSelection() -- restore selection --
	else
		SimpleNotepadEditBoxN:SetText(newText)
		SimpleNotepadEditBoxN:SetCursorPosition(SimpleNotepadEditBoxN_CursorPos)  -- restore cursor --
	end
end


    -- CHARACTER --
    -- clear character encoding from specified text --
    
function SimpleNotepadEditBoxC_ClearEscapeCodes(text)
	-- clear hyperlink encoding (but only if entire sequence is within our selected text) --
	text = text:gsub("(|H.-|h)(.-)(|h)", "%2")
	text = text:gsub("(|c%x%x%x%x%x%x%x%x)(.-)(|r)", "%2")
	return text
end


function SimpleNotepadEditBoxC_GetTextPositions(text, startTxt, endTxt, cursorPos)
	-- get positions of text markers within a string, with optional starting position --
	cursorPos = cursorPos or 0		-- default value of 0
	
	local pos = 1
	local startPtr = 0
	local endPtr = 0
	
	while (pos and pos < strlen(text)) do    
		startPtr = string.find(text, startTxt, pos, true)
		
		if (not startPtr) then 
			return nil, nil
		else
			endPtr = string.find(text, endTxt, startPtr, true)
			
			if (startPtr and startPtr < cursorPos and endPtr and endPtr > cursorPos) then
				return startPtr, endPtr + endTxt:len() - 1
			end
			
			pos = endPtr
		end
	end
	
	return nil, nil
end



    -- SimpleNotepadEditBoxN_EditBox cursor & selection code --

    -- WorldFrame:HookScript --
function SimpleNotepadEditBoxC_EditBoxMouseDown()
	SimpleNotepadEditBoxC_ClearFocus()
	SimpleNotepadEditBoxC_MouseButton = button
end


function SimpleNotepadEditBoxC_ClearFocus()
	if SimpleNotepadEditBoxC then SimpleNotepadEditBoxC:ClearFocus() end
	
end


function SimpleNotepadEditBoxC_EditBoxCursor(self, y, cursorHeight)
	local cursorPos = SimpleNotepadEditBoxC:GetCursorPosition()
	
	if cursorPos ~= SimpleNotepadEditBoxC_CursorPos then	-- only run code if editbox cursor changes (not mouse position)
		if SimpleNotepadEditBoxC_MouseButton == "LeftButton" then return end
		
		SimpleNotepadEditBoxC_UndoEnabled = 0
		
		-- scroll to cursor --
		y = -y
		local scroller = SimpleNotepadEditBoxC:GetParent()
		local offset = scroller:GetVerticalScroll()
		
		if y < offset then
			scroller:SetVerticalScroll(y)
		else
			y = y + cursorHeight - scroller:GetHeight()
			if y > offset then scroller:SetVerticalScroll(y) end
		end
		
		
		-- check for link --
	
		local text = SimpleNotepadEditBoxC:GetText()
		local startPtr, endPtr = SimpleNotepadEditBoxC_GetTextPositions(text, "|H", "|r", cursorPos)
		local x, y = GetCursorPosition()
		
		if (startPtr and endPtr) then
			-- we have found a link, so show its tooltip --
			GameTooltip:SetOwner(SimpleNotepadEditBoxC, "ANCHOR_TOPRIGHT")
			GameTooltip:SetHyperlink( strsub(text, startPtr, endPtr) )
		else
			-- no link, hide --
			GameTooltip:Hide()
			
			
			-- store selection & update cursor --
			
			if SimpleNotepadEditBoxC_MouseButton == "LeftButton" then
				local text = SimpleNotepadEditBoxC:GetText()
				SimpleNotepadEditBoxC:Insert("") -- Delete selected text
				
				local textNew = SimpleNotepadEditBoxC:GetText()
				local cursorNew = SimpleNotepadEditBoxC:GetCursorPosition()
				
				SimpleNotepadEditBoxC_SelectionStart = cursorNew
				SimpleNotepadEditBoxC_SelectionEnd = #text - (#textNew - cursorNew)
				
				-- Restore previous text --
				SimpleNotepadEditBoxC:SetText(text)
				
				-- always update cursor on left-click --
				SimpleNotepadEditBoxC_CursorPos = cursorPos
			else
				-- only update cursor if no selection --
				if SimpleNotepadEditBoxC_SelectionStart == SimpleNotepadEditBoxC_SelectionEnd and cursorPos ~= SimpleNotepadEditBoxC_SelectionStart then
					SimpleNotepadEditBoxC_CursorPos = cursorPos
				end
			end
			
			-- restore cursor & selection --
			SimpleNotepadEditBoxC_RestoreSelection()
		end
		
		SimpleNotepadEditBoxC_UndoEnabled = 1
	end
end


function SimpleNotepadEditBoxC_RestoreSelection()
	if SimpleNotepadEditBoxC then
		SimpleNotepadEditBoxC:SetCursorPosition(SimpleNotepadEditBoxC_CursorPos)
		
		if not SimpleNotepadEditBoxC_SelectionStart and not SimpleNotepadEditBoxC_SelectionEnd then
			-- force 'selection' to cursor pos if vars are nil --
			SimpleNotepadEditBoxC_SelectionStart = SimpleNotepadEditBoxC_CursorPos
			SimpleNotepadEditBoxC_SelectionEnd = SimpleNotepadEditBoxC_CursorPos
		end
			
		SimpleNotepadEditBoxC:HighlightText(SimpleNotepadEditBoxC_SelectionStart, SimpleNotepadEditBoxC_SelectionEnd)
	end
end

function SimpleNotepadEditBoxC_RestoreSelection()
	if SimpleNotepadEditBoxC then
		SimpleNotepadEditBoxC:SetCursorPosition(SimpleNotepadEditBoxC_CursorPos)
		
		if not SimpleNotepadEditBoxC_SelectionStart and not SimpleNotepadEditBoxC_SelectionEnd then
			-- force 'selection' to cursor pos if vars are nil --
			SimpleNotepadEditBoxC_SelectionStart = SimpleNotepadEditBoxC_CursorPos
			SimpleNotepadEditBoxC_SelectionEnd = SimpleNotepadEditBoxC_CursorPos
		end
			
		SimpleNotepadEditBoxC:HighlightText(SimpleNotepadEditBoxC_SelectionStart, SimpleNotepadEditBoxC_SelectionEnd)
	end
end


-- returns current selected text (or nil if no selection)
function SimpleNotepadEditBoxC_GetSelectedText()
	local text
	
	if SimpleNotepadEditBoxC_SelectionStart ~= nil and SimpleNotepadEditBoxC_SelectionEnd > SimpleNotepadEditBoxC_SelectionStart then
		text = SimpleNotepadEditBoxC:GetText()
		text = text:sub(SimpleNotepadEditBoxC_SelectionStart + 1, SimpleNotepadEditBoxC_SelectionEnd)
	end
	
	return text
end



    -- SimpleNotepadEditBoxC_EditBox text formatting & insert code --


    -- manages items dragged into EditBox --
    
function SimpleNotepadEditBoxC_Drag()
	local infoType, info1, info2 = GetCursorInfo()
	local text = ""
	
	if (infoType == "item") then
		text = info2
	elseif (infoType == "spell") then
        local skillType, spellId = GetSpellBookItemInfo(info1, "player")
        text = GetSpellLink(spellId)
	elseif (infoType == "merchant") then
		text = GetMerchantItemLink(info1)
	elseif (infoType == "macro") then
		text = GetMacroInfo(info1) .. " macro:\n" .. GetMacroBody(info1)
	end
	
	if text ~= "" and SimpleNotepadEditBoxC then
		SimpleNotepadEditBoxC:Insert(text)
	end
	
	ClearCursor()
end


    -- set selected text to hex colour --
function SimpleNotepadEditBoxC_EditBoxSetTextColour(colour)
	
	if SimpleNotepadEditBoxC and SimpleNotepadEditBoxC_SelectionStart ~= SimpleNotepadEditBoxC_SelectionEnd then
		local text = SimpleNotepadEditBoxC_GetSelectedText()							-- get text from EditBox
		local newText = "|cff" .. colour .. SimpleNotepadEditBoxC_ClearEscapeCodes(text) .. "|r"
		local sizeReduction = #text - #newText							-- calc size difference
		
		SimpleNotepadEditBoxC:Insert(newText)
		
		SimpleNotepadEditBoxC_CursorPos = SimpleNotepadEditBoxC_CursorPos - sizeReduction				-- update cursor pos
		SimpleNotepadEditBoxC_SelectionEnd = SimpleNotepadEditBoxC_SelectionEnd - sizeReduction			-- update selection var
		SimpleNotepadEditBoxC_RestoreSelection()										-- restore selection
	end
end


    -- clear selected text (or all text if no selection) --
function SimpleNotepadEditBoxC_EditBoxClearEscapes()
	
	local text = SimpleNotepadEditBoxC_GetSelectedText() -- get text from EditBox --
	if not text then text = SimpleNotepadEditBoxC:GetText() end	-- or entire text if no selection --
	
	local newText = SimpleNotepadEditBoxC_ClearEscapeCodes(text) -- set new var with cleared text --
	local sizeReduction = #text - #newText	-- calc size difference --
	
	SimpleNotepadEditBoxC_CursorPos = SimpleNotepadEditBoxC_CursorPos - sizeReduction -- update cursor pos --
	
	-- insert/set new text
	if SimpleNotepadEditBoxC_SelectionStart ~= nil and SimpleNotepadEditBoxC_SelectionEnd > SimpleNotepadEditBoxC_SelectionStart then
		SimpleNotepadEditBoxC:Insert(newText)
		SimpleNotepadEditBoxC_SelectionEnd = SimpleNotepadEditBoxC_SelectionEnd - sizeReduction -- update selection var --
		SimpleNotepadEditBoxC_RestoreSelection() -- restore selection --
	else
		SimpleNotepadEditBoxC:SetText(newText)
		SimpleNotepadEditBoxC:SetCursorPosition(SimpleNotepadEditBoxC_CursorPos)  -- restore cursor --
	end
end

    -- PROFFESIONS --
    -- clear character encoding from specified text --
    
function SimpleNotepadEditBoxP_ClearEscapeCodes(text)
	-- clear hyperlink encoding (but only if entire sequence is within our selected text) --
	text = text:gsub("(|H.-|h)(.-)(|h)", "%2")
	text = text:gsub("(|c%x%x%x%x%x%x%x%x)(.-)(|r)", "%2")
	return text
end


function SimpleNotepadEditBoxP_GetTextPositions(text, startTxt, endTxt, cursorPos)
	-- get positions of text markers within a string, with optional starting position --
	cursorPos = cursorPos or 0		-- default value of 0
	
	local pos = 1
	local startPtr = 0
	local endPtr = 0
	
	while (pos and pos < strlen(text)) do    
		startPtr = string.find(text, startTxt, pos, true)
		
		if (not startPtr) then 
			return nil, nil
		else
			endPtr = string.find(text, endTxt, startPtr, true)
			
			if (startPtr and startPtr < cursorPos and endPtr and endPtr > cursorPos) then
				return startPtr, endPtr + endTxt:len() - 1
			end
			
			pos = endPtr
		end
	end
	
	return nil, nil
end



    -- SimpleNotepadEditBoxP_EditBox cursor & selection code --

    -- WorldFrame:HookScript --
function SimpleNotepadEditBoxP_EditBoxMouseDown()
	SimpleNotepadEditBoxP_ClearFocus()
	SimpleNotepadEditBoxP_MouseButton = button
end


function SimpleNotepadEditBoxP_ClearFocus()
	if SimpleNotepadEditBoxP then SimpleNotepadEditBoxP:ClearFocus() end
	
end


function SimpleNotepadEditBoxP_EditBoxCursor(self, y, cursorHeight)
	local cursorPos = SimpleNotepadEditBoxP:GetCursorPosition()
	
	if cursorPos ~= SimpleNotepadEditBoxP_CursorPos then	-- only run code if editbox cursor changes (not mouse position)
		if SimpleNotepadEditBoxP_MouseButton == "LeftButton" then return end
		
		SimpleNotepadEditBoxP_UndoEnabled = 0
		
		-- scroll to cursor --
		y = -y
		local scroller = SimpleNotepadEditBoxP:GetParent()
		local offset = scroller:GetVerticalScroll()
		
		if y < offset then
			scroller:SetVerticalScroll(y)
		else
			y = y + cursorHeight - scroller:GetHeight()
			if y > offset then scroller:SetVerticalScroll(y) end
		end
		
		
		-- check for link --
	
		local text = SimpleNotepadEditBoxP:GetText()
		local startPtr, endPtr = SimpleNotepadEditBoxP_GetTextPositions(text, "|H", "|r", cursorPos)
		local x, y = GetCursorPosition()
		
		if (startPtr and endPtr) then
			-- we have found a link, so show its tooltip --
			GameTooltip:SetOwner(SimpleNotepadEditBoxP, "ANCHOR_TOPRIGHT")
			GameTooltip:SetHyperlink( strsub(text, startPtr, endPtr) )
		else
			-- no link, hide --
			GameTooltip:Hide()
			
			
			-- store selection & update cursor --
			
			if SimpleNotepadEditBoxP_MouseButton == "LeftButton" then
				local text = SimpleNotepadEditBoxP:GetText()
				SimpleNotepadEditBoxP:Insert("") -- Delete selected text
				
				local textNew = SimpleNotepadEditBoxP:GetText()
				local cursorNew = SimpleNotepadEditBoxP:GetCursorPosition()
				
				SimpleNotepadEditBoxP_SelectionStart = cursorNew
				SimpleNotepadEditBoxP_SelectionEnd = #text - (#textNew - cursorNew)
				
				-- Restore previous text --
				SimpleNotepadEditBoxP:SetText(text)
				
				-- always update cursor on left-click --
				SimpleNotepadEditBoxP_CursorPos = cursorPos
			else
				-- only update cursor if no selection --
				if SimpleNotepadEditBoxP_SelectionStart == SimpleNotepadEditBoxP_SelectionEnd and cursorPos ~= SimpleNotepadEditBoxP_SelectionStart then
					SimpleNotepadEditBoxP_CursorPos = cursorPos
				end
			end
			
			-- restore cursor & selection --
			SimpleNotepadEditBoxP_RestoreSelection()
		end
		
		SimpleNotepadEditBoxP_UndoEnabled = 1
	end
end


function SimpleNotepadEditBoxP_RestoreSelection()
	if SimpleNotepadEditBoxP then
		SimpleNotepadEditBoxP:SetCursorPosition(SimpleNotepadEditBoxP_CursorPos)
		
		if not SimpleNotepadEditBoxP_SelectionStart and not SimpleNotepadEditBoxP_SelectionEnd then
			-- force 'selection' to cursor pos if vars are nil --
			SimpleNotepadEditBoxP_SelectionStart = SimpleNotepadEditBoxP_CursorPos
			SimpleNotepadEditBoxP_SelectionEnd = SimpleNotepadEditBoxP_CursorPos
		end
			
		SimpleNotepadEditBoxP:HighlightText(SimpleNotepadEditBoxP_SelectionStart, SimpleNotepadEditBoxP_SelectionEnd)
	end
end

function SimpleNotepadEditBoxP_RestoreSelection()
	if SimpleNotepadEditBoxP then
		SimpleNotepadEditBoxP:SetCursorPosition(SimpleNotepadEditBoxP_CursorPos)
		
		if not SimpleNotepadEditBoxP_SelectionStart and not SimpleNotepadEditBoxP_SelectionEnd then
			-- force 'selection' to cursor pos if vars are nil --
			SimpleNotepadEditBoxP_SelectionStart = SimpleNotepadEditBoxP_CursorPos
			SimpleNotepadEditBoxP_SelectionEnd = SimpleNotepadEditBoxP_CursorPos
		end
			
		SimpleNotepadEditBoxP:HighlightText(SimpleNotepadEditBoxP_SelectionStart, SimpleNotepadEditBoxP_SelectionEnd)
	end
end


-- returns current selected text (or nil if no selection)
function SimpleNotepadEditBoxP_GetSelectedText()
	local text
	
	if SimpleNotepadEditBoxP_SelectionStart ~= nil and SimpleNotepadEditBoxP_SelectionEnd > SimpleNotepadEditBoxP_SelectionStart then
		text = SimpleNotepadEditBoxP:GetText()
		text = text:sub(SimpleNotepadEditBoxP_SelectionStart + 1, SimpleNotepadEditBoxP_SelectionEnd)
	end
	
	return text
end



    -- SimpleNotepadEditBoxP_EditBox text formatting & insert code --


    -- manages items dragged into EditBox --
    
function SimpleNotepadEditBoxP_Drag()
	local infoType, info1, info2 = GetCursorInfo()
	local text = ""
	
	if (infoType == "item") then
		text = info2
	elseif (infoType == "spell") then
        local skillType, spellId = GetSpellBookItemInfo(info1, "player")
        text = GetSpellLink(spellId)
	elseif (infoType == "merchant") then
		text = GetMerchantItemLink(info1)
	elseif (infoType == "macro") then
		text = GetMacroInfo(info1) .. " macro:\n" .. GetMacroBody(info1)
	end
	
	if text ~= "" and SimpleNotepadEditBoxP then
		SimpleNotepadEditBoxP:Insert(text)
	end
	
	ClearCursor()
end


    -- set selected text to hex colour --
function SimpleNotepadEditBoxP_EditBoxSetTextColour(colour)
	
	if SimpleNotepadEditBoxP and SimpleNotepadEditBoxP_SelectionStart ~= SimpleNotepadEditBoxP_SelectionEnd then
		local text = SimpleNotepadEditBoxP_GetSelectedText()							-- get text from EditBox
		local newText = "|cff" .. colour .. SimpleNotepadEditBoxP_ClearEscapeCodes(text) .. "|r"
		local sizeReduction = #text - #newText							-- calc size difference
		
		SimpleNotepadEditBoxP:Insert(newText)
		
		SimpleNotepadEditBoxP_CursorPos = SimpleNotepadEditBoxP_CursorPos - sizeReduction				-- update cursor pos
		SimpleNotepadEditBoxP_SelectionEnd = SimpleNotepadEditBoxP_SelectionEnd - sizeReduction			-- update selection var
		SimpleNotepadEditBoxP_RestoreSelection()										-- restore selection
	end
end


    -- clear selected text (or all text if no selection) --
function SimpleNotepadEditBoxP_EditBoxClearEscapes()
	
	local text = SimpleNotepadEditBoxP_GetSelectedText() -- get text from EditBox --
	if not text then text = SimpleNotepadEditBoxP:GetText() end	-- or entire text if no selection --
	
	local newText = SimpleNotepadEditBoxP_ClearEscapeCodes(text) -- set new var with cleared text --
	local sizeReduction = #text - #newText	-- calc size difference --
	
	SimpleNotepadEditBoxP_CursorPos = SimpleNotepadEditBoxP_CursorPos - sizeReduction -- update cursor pos --
	
	-- insert/set new text
	if SimpleNotepadEditBoxP_SelectionStart ~= nil and SimpleNotepadEditBoxP_SelectionEnd > SimpleNotepadEditBoxP_SelectionStart then
		SimpleNotepadEditBoxP:Insert(newText)
		SimpleNotepadEditBoxP_SelectionEnd = SimpleNotepadEditBoxP_SelectionEnd - sizeReduction -- update selection var --
		SimpleNotepadEditBoxP_RestoreSelection() -- restore selection --
	else
		SimpleNotepadEditBoxP:SetText(newText)
		SimpleNotepadEditBoxP:SetCursorPosition(SimpleNotepadEditBoxP_CursorPos)  -- restore cursor --
	end
end


    -- TO DO --
   -- clear character encoding from specified text --
    
function SimpleNotepadEditBoxT_ClearEscapeCodes(text)
	-- clear hyperlink encoding (but only if entire sequence is within our selected text) --
	text = text:gsub("(|H.-|h)(.-)(|h)", "%2")
	text = text:gsub("(|c%x%x%x%x%x%x%x%x)(.-)(|r)", "%2")
	return text
end


function SimpleNotepadEditBoxT_GetTextPositions(text, startTxt, endTxt, cursorPos)
	-- get positions of text markers within a string, with optional starting position --
	cursorPos = cursorPos or 0		-- default value of 0
	
	local pos = 1
	local startPtr = 0
	local endPtr = 0
	
	while (pos and pos < strlen(text)) do    
		startPtr = string.find(text, startTxt, pos, true)
		
		if (not startPtr) then 
			return nil, nil
		else
			endPtr = string.find(text, endTxt, startPtr, true)
			
			if (startPtr and startPtr < cursorPos and endPtr and endPtr > cursorPos) then
				return startPtr, endPtr + endTxt:len() - 1
			end
			
			pos = endPtr
		end
	end
	
	return nil, nil
end



    -- SimpleNotepadEditBoxT_EditBox cursor & selection code --

    -- WorldFrame:HookScript --
function SimpleNotepadEditBoxT_EditBoxMouseDown()
	SimpleNotepadEditBoxT_ClearFocus()
	SimpleNotepadEditBoxT_MouseButton = button
end


function SimpleNotepadEditBoxT_ClearFocus()
	if SimpleNotepadEditBoxT then SimpleNotepadEditBoxT:ClearFocus() end
	
end


function SimpleNotepadEditBoxT_EditBoxCursor(self, y, cursorHeight)
	local cursorPos = SimpleNotepadEditBoxT:GetCursorPosition()
	
	if cursorPos ~= SimpleNotepadEditBoxT_CursorPos then	-- only run code if editbox cursor changes (not mouse position)
		if SimpleNotepadEditBoxT_MouseButton == "LeftButton" then return end
		
		SimpleNotepadEditBoxT_UndoEnabled = 0
		
		-- scroll to cursor --
		y = -y
		local scroller = SimpleNotepadEditBoxT:GetParent()
		local offset = scroller:GetVerticalScroll()
		
		if y < offset then
			scroller:SetVerticalScroll(y)
		else
			y = y + cursorHeight - scroller:GetHeight()
			if y > offset then scroller:SetVerticalScroll(y) end
		end
		
		
		-- check for link --
	
		local text = SimpleNotepadEditBoxT:GetText()
		local startPtr, endPtr = SimpleNotepadEditBoxT_GetTextPositions(text, "|H", "|r", cursorPos)
		local x, y = GetCursorPosition()
		
		if (startPtr and endPtr) then
			-- we have found a link, so show its tooltip --
			GameTooltip:SetOwner(SimpleNotepadEditBoxT, "ANCHOR_TOPRIGHT")
			GameTooltip:SetHyperlink( strsub(text, startPtr, endPtr) )
		else
			-- no link, hide --
			GameTooltip:Hide()
			
			
			-- store selection & update cursor --
			
			if SimpleNotepadEditBoxT_MouseButton == "LeftButton" then
				local text = SimpleNotepadEditBoxT:GetText()
				SimpleNotepadEditBoxT:Insert("") -- Delete selected text
				
				local textNew = SimpleNotepadEditBoxT:GetText()
				local cursorNew = SimpleNotepadEditBoxT:GetCursorPosition()
				
				SimpleNotepadEditBoxT_SelectionStart = cursorNew
				SimpleNotepadEditBoxT_SelectionEnd = #text - (#textNew - cursorNew)
				
				-- Restore previous text --
				SimpleNotepadEditBoxT:SetText(text)
				
				-- always update cursor on left-click --
				SimpleNotepadEditBoxT_CursorPos = cursorPos
			else
				-- only update cursor if no selection --
				if SimpleNotepadEditBoxT_SelectionStart == SimpleNotepadEditBoxT_SelectionEnd and cursorPos ~= SimpleNotepadEditBoxT_SelectionStart then
					SimpleNotepadEditBoxT_CursorPos = cursorPos
				end
			end
			
			-- restore cursor & selection --
			SimpleNotepadEditBoxT_RestoreSelection()
		end
		
		SimpleNotepadEditBoxT_UndoEnabled = 1
	end
end


function SimpleNotepadEditBoxT_RestoreSelection()
	if SimpleNotepadEditBoxT then
		SimpleNotepadEditBoxT:SetCursorPosition(SimpleNotepadEditBoxT_CursorPos)
		
		if not SimpleNotepadEditBoxT_SelectionStart and not SimpleNotepadEditBoxT_SelectionEnd then
			-- force 'selection' to cursor pos if vars are nil --
			SimpleNotepadEditBoxT_SelectionStart = SimpleNotepadEditBoxT_CursorPos
			SimpleNotepadEditBoxT_SelectionEnd = SimpleNotepadEditBoxT_CursorPos
		end
			
		SimpleNotepadEditBoxT:HighlightText(SimpleNotepadEditBoxT_SelectionStart, SimpleNotepadEditBoxT_SelectionEnd)
	end
end

function SimpleNotepadEditBoxT_RestoreSelection()
	if SimpleNotepadEditBoxT then
		SimpleNotepadEditBoxT:SetCursorPosition(SimpleNotepadEditBoxT_CursorPos)
		
		if not SimpleNotepadEditBoxT_SelectionStart and not SimpleNotepadEditBoxT_SelectionEnd then
			-- force 'selection' to cursor pos if vars are nil --
			SimpleNotepadEditBoxT_SelectionStart = SimpleNotepadEditBoxT_CursorPos
			SimpleNotepadEditBoxT_SelectionEnd = SimpleNotepadEditBoxT_CursorPos
		end
			
		SimpleNotepadEditBoxT:HighlightText(SimpleNotepadEditBoxT_SelectionStart, SimpleNotepadEditBoxT_SelectionEnd)
	end
end


-- returns current selected text (or nil if no selection)
function SimpleNotepadEditBoxT_GetSelectedText()
	local text
	
	if SimpleNotepadEditBoxT_SelectionStart ~= nil and SimpleNotepadEditBoxT_SelectionEnd > SimpleNotepadEditBoxT_SelectionStart then
		text = SimpleNotepadEditBoxT:GetText()
		text = text:sub(SimpleNotepadEditBoxT_SelectionStart + 1, SimpleNotepadEditBoxT_SelectionEnd)
	end
	
	return text
end



    -- SimpleNotepadEditBoxT_EditBox text formatting & insert code --


    -- manages items dragged into EditBox --
    
function SimpleNotepadEditBoxT_Drag()
	local infoType, info1, info2 = GetCursorInfo()
	local text = ""
	
	if (infoType == "item") then
		text = info2
	elseif (infoType == "spell") then
        local skillType, spellId = GetSpellBookItemInfo(info1, "player")
        text = GetSpellLink(spellId)
	elseif (infoType == "merchant") then
		text = GetMerchantItemLink(info1)
	elseif (infoType == "macro") then
		text = GetMacroInfo(info1) .. " macro:\n" .. GetMacroBody(info1)
	end
	
	if text ~= "" and SimpleNotepadEditBoxT then
		SimpleNotepadEditBoxT:Insert(text)
	end
	
	ClearCursor()
end


    -- set selected text to hex colour --
function SimpleNotepadEditBoxT_EditBoxSetTextColour(colour)
	
	if SimpleNotepadEditBoxT and SimpleNotepadEditBoxT_SelectionStart ~= SimpleNotepadEditBoxT_SelectionEnd then
		local text = SimpleNotepadEditBoxT_GetSelectedText()							-- get text from EditBox
		local newText = "|cff" .. colour .. SimpleNotepadEditBoxT_ClearEscapeCodes(text) .. "|r"
		local sizeReduction = #text - #newText							-- calc size difference
		
		SimpleNotepadEditBoxT:Insert(newText)
		
		SimpleNotepadEditBoxT_CursorPos = SimpleNotepadEditBoxT_CursorPos - sizeReduction				-- update cursor pos
		SimpleNotepadEditBoxT_SelectionEnd = SimpleNotepadEditBoxT_SelectionEnd - sizeReduction			-- update selection var
		SimpleNotepadEditBoxT_RestoreSelection()										-- restore selection
	end
end


    -- clear selected text (or all text if no selection) --
function SimpleNotepadEditBoxT_EditBoxClearEscapes()
	
	local text = SimpleNotepadEditBoxT_GetSelectedText() -- get text from EditBox --
	if not text then text = SimpleNotepadEditBoxT:GetText() end	-- or entire text if no selection --
	
	local newText = SimpleNotepadEditBoxT_ClearEscapeCodes(text) -- set new var with cleared text --
	local sizeReduction = #text - #newText	-- calc size difference --
	
	SimpleNotepadEditBoxT_CursorPos = SimpleNotepadEditBoxT_CursorPos - sizeReduction -- update cursor pos --
	
	-- insert/set new text
	if SimpleNotepadEditBoxT_SelectionStart ~= nil and SimpleNotepadEditBoxT_SelectionEnd > SimpleNotepadEditBoxT_SelectionStart then
		SimpleNotepadEditBoxT:Insert(newText)
		SimpleNotepadEditBoxT_SelectionEnd = SimpleNotepadEditBoxT_SelectionEnd - sizeReduction -- update selection var --
		SimpleNotepadEditBoxT_RestoreSelection() -- restore selection --
	else
		SimpleNotepadEditBoxT:SetText(newText)
		SimpleNotepadEditBoxT:SetCursorPosition(SimpleNotepadEditBoxT_CursorPos)  -- restore cursor --
	end
end

    -- RAID --
   -- clear character encoding from specified text --
    
function SimpleNotepadEditBoxR_ClearEscapeCodes(text)
	-- clear hyperlink encoding (but only if entire sequence is within our selected text) --
	text = text:gsub("(|H.-|h)(.-)(|h)", "%2")
	text = text:gsub("(|c%x%x%x%x%x%x%x%x)(.-)(|r)", "%2")
	return text
end


function SimpleNotepadEditBoxR_GetTextPositions(text, startTxt, endTxt, cursorPos)
	-- get positions of text markers within a string, with optional starting position --
	cursorPos = cursorPos or 0		-- default value of 0
	
	local pos = 1
	local startPtr = 0
	local endPtr = 0
	
	while (pos and pos < strlen(text)) do    
		startPtr = string.find(text, startTxt, pos, true)
		
		if (not startPtr) then 
			return nil, nil
		else
			endPtr = string.find(text, endTxt, startPtr, true)
			
			if (startPtr and startPtr < cursorPos and endPtr and endPtr > cursorPos) then
				return startPtr, endPtr + endTxt:len() - 1
			end
			
			pos = endPtr
		end
	end
	
	return nil, nil
end



    -- SimpleNotepadEditBoxR_EditBox cursor & selection code --

    -- WorldFrame:HookScript --
function SimpleNotepadEditBoxR_EditBoxMouseDown()
	SimpleNotepadEditBoxR_ClearFocus()
	SimpleNotepadEditBoxR_MouseButton = button
end


function SimpleNotepadEditBoxR_ClearFocus()
	if SimpleNotepadEditBoxR then SimpleNotepadEditBoxR:ClearFocus() end
	
end


function SimpleNotepadEditBoxR_EditBoxCursor(self, y, cursorHeight)
	local cursorPos = SimpleNotepadEditBoxR:GetCursorPosition()
	
	if cursorPos ~= SimpleNotepadEditBoxR_CursorPos then	-- only run code if editbox cursor changes (not mouse position)
		if SimpleNotepadEditBoxR_MouseButton == "LeftButton" then return end
		
		SimpleNotepadEditBoxR_UndoEnabled = 0
		
		-- scroll to cursor --
		y = -y
		local scroller = SimpleNotepadEditBoxR:GetParent()
		local offset = scroller:GetVerticalScroll()
		
		if y < offset then
			scroller:SetVerticalScroll(y)
		else
			y = y + cursorHeight - scroller:GetHeight()
			if y > offset then scroller:SetVerticalScroll(y) end
		end
		
		
		-- check for link --
	
		local text = SimpleNotepadEditBoxR:GetText()
		local startPtr, endPtr = SimpleNotepadEditBoxR_GetTextPositions(text, "|H", "|r", cursorPos)
		local x, y = GetCursorPosition()
		
		if (startPtr and endPtr) then
			-- we have found a link, so show its tooltip --
			GameTooltip:SetOwner(SimpleNotepadEditBoxR, "ANCHOR_TOPRIGHT")
			GameTooltip:SetHyperlink( strsub(text, startPtr, endPtr) )
		else
			-- no link, hide --
			GameTooltip:Hide()
			
			
			-- store selection & update cursor --
			
			if SimpleNotepadEditBoxR_MouseButton == "LeftButton" then
				local text = SimpleNotepadEditBoxR:GetText()
				SimpleNotepadEditBoxR:Insert("") -- Delete selected text
				
				local textNew = SimpleNotepadEditBoxR:GetText()
				local cursorNew = SimpleNotepadEditBoxR:GetCursorPosition()
				
				SimpleNotepadEditBoxR_SelectionStart = cursorNew
				SimpleNotepadEditBoxR_SelectionEnd = #text - (#textNew - cursorNew)
				
				-- Restore previous text --
				SimpleNotepadEditBoxR:SetText(text)
				
				-- always update cursor on left-click --
				SimpleNotepadEditBoxR_CursorPos = cursorPos
			else
				-- only update cursor if no selection --
				if SimpleNotepadEditBoxR_SelectionStart == SimpleNotepadEditBoxR_SelectionEnd and cursorPos ~= SimpleNotepadEditBoxR_SelectionStart then
					SimpleNotepadEditBoxR_CursorPos = cursorPos
				end
			end
			
			-- restore cursor & selection --
			SimpleNotepadEditBoxR_RestoreSelection()
		end
		
		SimpleNotepadEditBoxR_UndoEnabled = 1
	end
end


function SimpleNotepadEditBoxR_RestoreSelection()
	if SimpleNotepadEditBoxR then
		SimpleNotepadEditBoxR:SetCursorPosition(SimpleNotepadEditBoxR_CursorPos)
		
		if not SimpleNotepadEditBoxR_SelectionStart and not SimpleNotepadEditBoxR_SelectionEnd then
			-- force 'selection' to cursor pos if vars are nil --
			SimpleNotepadEditBoxR_SelectionStart = SimpleNotepadEditBoxR_CursorPos
			SimpleNotepadEditBoxR_SelectionEnd = SimpleNotepadEditBoxR_CursorPos
		end
			
		SimpleNotepadEditBoxR:HighlightText(SimpleNotepadEditBoxR_SelectionStart, SimpleNotepadEditBoxR_SelectionEnd)
	end
end

function SimpleNotepadEditBoxR_RestoreSelection()
	if SimpleNotepadEditBoxR then
		SimpleNotepadEditBoxR:SetCursorPosition(SimpleNotepadEditBoxR_CursorPos)
		
		if not SimpleNotepadEditBoxR_SelectionStart and not SimpleNotepadEditBoxR_SelectionEnd then
			-- force 'selection' to cursor pos if vars are nil --
			SimpleNotepadEditBoxR_SelectionStart = SimpleNotepadEditBoxR_CursorPos
			SimpleNotepadEditBoxR_SelectionEnd = SimpleNotepadEditBoxR_CursorPos
		end
			
		SimpleNotepadEditBoxR:HighlightText(SimpleNotepadEditBoxR_SelectionStart, SimpleNotepadEditBoxR_SelectionEnd)
	end
end


-- returns current selected text (or nil if no selection)
function SimpleNotepadEditBoxR_GetSelectedText()
	local text
	
	if SimpleNotepadEditBoxR_SelectionStart ~= nil and SimpleNotepadEditBoxR_SelectionEnd > SimpleNotepadEditBoxR_SelectionStart then
		text = SimpleNotepadEditBoxR:GetText()
		text = text:sub(SimpleNotepadEditBoxR_SelectionStart + 1, SimpleNotepadEditBoxR_SelectionEnd)
	end
	
	return text
end



    -- SimpleNotepadEditBoxR_EditBox text formatting & insert code --


    -- manages items dragged into EditBox --
    
function SimpleNotepadEditBoxR_Drag()
	local infoType, info1, info2 = GetCursorInfo()
	local text = ""
	
	if (infoType == "item") then
		text = info2
	elseif (infoType == "spell") then
        local skillType, spellId = GetSpellBookItemInfo(info1, "player")
        text = GetSpellLink(spellId)
	elseif (infoType == "merchant") then
		text = GetMerchantItemLink(info1)
	elseif (infoType == "macro") then
		text = GetMacroInfo(info1) .. " macro:\n" .. GetMacroBody(info1)
	end
	
	if text ~= "" and SimpleNotepadEditBoxR then
		SimpleNotepadEditBoxR:Insert(text)
	end
	
	ClearCursor()
end


    -- set selected text to hex colour --
function SimpleNotepadEditBoxR_EditBoxSetTextColour(colour)
	
	if SimpleNotepadEditBoxR and SimpleNotepadEditBoxR_SelectionStart ~= SimpleNotepadEditBoxR_SelectionEnd then
		local text = SimpleNotepadEditBoxR_GetSelectedText()							-- get text from EditBox
		local newText = "|cff" .. colour .. SimpleNotepadEditBoxR_ClearEscapeCodes(text) .. "|r"
		local sizeReduction = #text - #newText							-- calc size difference
		
		SimpleNotepadEditBoxR:Insert(newText)
		
		SimpleNotepadEditBoxR_CursorPos = SimpleNotepadEditBoxR_CursorPos - sizeReduction				-- update cursor pos
		SimpleNotepadEditBoxR_SelectionEnd = SimpleNotepadEditBoxR_SelectionEnd - sizeReduction			-- update selection var
		SimpleNotepadEditBoxR_RestoreSelection()										-- restore selection
	end
end


    -- clear selected text (or all text if no selection) --
function SimpleNotepadEditBoxR_EditBoxClearEscapes()
	
	local text = SimpleNotepadEditBoxR_GetSelectedText() -- get text from EditBox --
	if not text then text = SimpleNotepadEditBoxR:GetText() end	-- or entire text if no selection --
	
	local newText = SimpleNotepadEditBoxR_ClearEscapeCodes(text) -- set new var with cleared text --
	local sizeReduction = #text - #newText	-- calc size difference --
	
	SimpleNotepadEditBoxR_CursorPos = SimpleNotepadEditBoxR_CursorPos - sizeReduction -- update cursor pos --
	
	-- insert/set new text
	if SimpleNotepadEditBoxR_SelectionStart ~= nil and SimpleNotepadEditBoxR_SelectionEnd > SimpleNotepadEditBoxR_SelectionStart then
		SimpleNotepadEditBoxR:Insert(newText)
		SimpleNotepadEditBoxR_SelectionEnd = SimpleNotepadEditBoxR_SelectionEnd - sizeReduction -- update selection var --
		SimpleNotepadEditBoxR_RestoreSelection() -- restore selection --
	else
		SimpleNotepadEditBoxR:SetText(newText)
		SimpleNotepadEditBoxR:SetCursorPosition(SimpleNotepadEditBoxR_CursorPos)  -- restore cursor --
	end
end 