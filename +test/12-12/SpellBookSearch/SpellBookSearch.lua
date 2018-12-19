local ADDON, Addon = ...

local function UpdateSearch()
  SpellBookFrame_Update()
end

local function SearchBox_OnTextChanged(self, userInput)
  Addon.SearchBox_OldOnTextChanged(self, userInput)
  SpellBookFrame_Update()
end

local function dbgprnt (...)
  --return print(...)
end

function Addon:getOrCreateSearchBox()
  if (Addon.SearchBox ~= nil) then
    return Addon.SearchBox
  end

  Addon.SearchBox = CreateFrame("EditBox","SearchBox",SpellBookFrame,"SearchBoxTemplate")
  Addon.SearchBox:SetWidth(150) -- Set these to whatever height/width is needed
  Addon.SearchBox:SetHeight(20) -- for your Texture
  Addon.SearchBox:SetPoint("TOPRIGHT", SpellBookFrame, "TOPRIGHT", -25, -1)
  Addon.SearchBox:Show()
  Addon.SearchBox.Left:Hide()
  Addon.SearchBox.Right:Hide()
  Addon.SearchBox.Middle:Hide()

  Addon.SearchBox:SetScript("OnEnterPressed", UpdateSearch)
  Addon.SearchBox_OldOnTextChanged = Addon.SearchBox:GetScript("OnTextChanged")
  Addon.SearchBox:SetScript("OnTextChanged", SearchBox_OnTextChanged)

  return Addon.SearchBox;
end

function Addon:updateSearchBox()
  local box = Addon:getOrCreateSearchBox()
  if (SpellBookFrame.bookType ~= BOOKTYPE_SPELL) then
    box:Hide()
  else
    box:Show()
  end
end

local function GetFullSpellName(slot, bookType)
  local spellName, subSpellName = GetSpellBookItemName(slot, bookType);
  local isPassive = IsPassiveSpell(slot, bookType);

  if (not subSpellName) then
    subSpellName = ""
  end

  if ( subSpellName == "" ) then
    if ( IsTalentSpell(slot, bookType) ) then
      if ( isPassive ) then
        subSpellName = TALENT_PASSIVE
      else
        subSpellName = TALENT
      end
    elseif ( isPassive ) then
      subSpellName = SPELL_PASSIVE;
    end
  end

  return spellName .. " " .. subSpellName
end

OldSpellBookFrame_Update = SpellBookFrame_Update

function Addon:findSpells()
  if (SpellBookFrame.bookType ~= BOOKTYPE_SPELL) then
    Addon.spells = {};
    Addon.numSpells = j;
    return
  end

  if ( not SpellBookFrame.selectedSkillLine ) then
		SpellBookFrame.selectedSkillLine = 2;
	end

	local _, _, offset, numSlots, _, _ = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);

  Addon.spells = {};
  local j = 1
  dbgprnt ("Indexing from" .. offset .. "up to " .. (numSlots+offset)
     .. " on " .. SpellBookFrame.bookType)
  for i=1,numSlots do

    local slotType, spellID = GetSpellBookItemInfo(i+offset, SpellBookFrame.bookType);
    local fullSpellName = GetFullSpellName(i+offset, SpellBookFrame.bookType);
    local searchText = Addon:getOrCreateSearchBox():GetText():gsub("%s+", "")
    local desc = GetSpellDescription(spellID)

    dbgprnt(spellName)
    if searchText == "" or
      fullSpellName:lower():match(searchText:lower()) then
      Addon.spells[offset+j] = i+offset;
      j = j + 1
    end
  end
  Addon.numSpells = j
end

--override
function SpellBookFrame_Update()
  Addon:updateSearchBox()
  Addon:findSpells()
  OldSpellBookFrame_Update()
end

--override
function SpellBook_GetCurrentPage()
	local currentPage, maxPages;
	local numPetSpells = HasPetSpells() or 0;
	if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		currentPage = SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET];
		maxPages = ceil(numPetSpells/SPELLS_PER_PAGE);
	elseif ( SpellBookFrame.bookType == BOOKTYPE_SPELL) then
		currentPage = SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine];
		local _, _, _, numSlots = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
		maxPages = ceil(Addon.numSpells/SPELLS_PER_PAGE);
	end
	return currentPage, maxPages;
end

--override
function SpellBook_GetSpellBookSlot(spellButton)
	local id = spellButton:GetID()
	if ( SpellBookFrame.bookType == BOOKTYPE_PROFESSION) then
		return id + spellButton:GetParent().spellOffset;
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		local slot = id + (SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] - 1));
  	local slotType, slotID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		return slot, slotType, slotID;
	else
		local relativeSlot = id + ( SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] - 1));
		if ( SpellBookFrame.selectedSkillLineNumSlots and relativeSlot <= SpellBookFrame.selectedSkillLineNumSlots) then
			local slot = SpellBookFrame.selectedSkillLineOffset + relativeSlot;
      dbgprnt("Slot" .. slot)
      local filteredSlot = Addon.spells[slot];
      if filteredSlot then
        dbgprnt(" to " .. filteredSlot)
	  		local slotType, slotID = GetSpellBookItemInfo(Addon.spells[slot], SpellBookFrame.bookType);
        local spellName, subSpellName = GetSpellBookItemName(Addon.spells[slot], SpellBookFrame.bookType);
        dbgprnt(spellName)
			  return filteredSlot, slotType, slotID;
      end
      return nil, nil
		else
			return nil, nil;
		end
	end
end

--override
function SpellButton_OnClick(self, button)
	local slot, slotType = SpellBook_GetSpellBookSlot(self);
	if ( slot > MAX_SPELLS or slotType == "FUTURESPELL") then
		return;
	end

	if ( HasPendingGlyphCast() and SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		local slotType, spellID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		if (slotType == "SPELL") then
			if ( HasAttachedGlyph(spellID) ) then
				if ( IsPendingGlyphRemoval() ) then
					StaticPopup_Show("CONFIRM_GLYPH_REMOVAL", nil, nil, {name = GetCurrentGlyphNameForSpell(spellID), id = spellID});
				else
					StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", nil, nil, {name = GetPendingGlyphName(), currentName = GetCurrentGlyphNameForSpell(spellID), id = spellID});
				end
			else
				AttachGlyphToSpell(spellID);
			end
		elseif (slotType == "FLYOUT") then
			SpellFlyout:Toggle(spellID, self, "RIGHT", 1, false, self.offSpecID, true);
			SpellFlyout:SetBorderColor(181/256, 162/256, 90/256);
		end
		return;
	end

	if (self.isPassive) then
		return;
	end

	if ( button ~= "LeftButton" and SpellBookFrame.bookType == BOOKTYPE_PET ) then
		if ( self.offSpecID == 0 ) then
			ToggleSpellAutocast(slot, SpellBookFrame.bookType);
		end
	else
		local _, id = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		if (slotType == "FLYOUT") then
			SpellFlyout:Toggle(id, self, "RIGHT", 1, false, self.offSpecID, true);
			SpellFlyout:SetBorderColor(181/256, 162/256, 90/256);
		else
			if ( SpellBookFrame.bookType ~= BOOKTYPE_SPELLBOOK or self.offSpecID == 0 ) then
				--CastSpell(slot, SpellBookFrame.bookType);
			end
		end
		SpellButton_UpdateSelection(self);
	end
end
