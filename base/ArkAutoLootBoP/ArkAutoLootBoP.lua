-- (c) 2010-2012, all rights reserved.

local _G = _G
local pairs = _G.pairs


local enabled = false
local frame = CreateFrame( "FRAME" )
local confirm = { }

local function ManualLootClick( self )
	if enabled and GetLootSlotType( self.slot ) == LOOT_SLOT_ITEM then
		--print( string.format( "slot %s - bop loot confirmed", self.slot ) )
		ConfirmLootSlot( self.slot )
	end
end

local function EventHandler( self, event, ... )
	
	if GetNumGroupMembers( ) > 0 then
		
		if enabled then
			-- disable mod, were in a group
			--print( "disabling mod" )
			UIParent:RegisterEvent( "LOOT_BIND_CONFIRM" )
			enabled = false
			return
		end
		
		-- and make sure we dont go past here
		return
		
	else
		
		if not enabled then
			--print( "enabling mod" )
			-- enable mod, not in a group
			UIParent:UnregisterEvent( "LOOT_BIND_CONFIRM" )
			enabled = true
		end
		
	end
	
	if event == "LOOT_OPENED" then
		
		local auto = ...
		
		--print( string.format( "loot opened - auto = %s", auto or "nil" ) )
		
		if auto then
			-- loot and confirm just the bop items
			for slot in pairs( confirm ) do
				LootSlot( slot )
				ConfirmLootSlot( slot )
				--print( string.format( "slot %s - bop looted", slot ) )
			end
		end
		
	elseif event == "LOOT_CLOSED" then
		
		--print( "loot closed" )
		
		wipe( confirm )
		
	elseif event == "LOOT_BIND_CONFIRM" then
		
		local slot = ...
		
		--print( string.format( "slot %s - needs confirmation", slot ) )
		
		confirm[slot] = true
		
	end
	
end

frame:RegisterEvent( "LOOT_BIND_CONFIRM" )
frame:RegisterEvent( "LOOT_OPENED" )
frame:RegisterEvent( "LOOT_CLOSED" )

frame:RegisterEvent( "PARTY_MEMBERS_CHANGED" )
frame:RegisterEvent( "GROUP_ROSTER_UPDATE" )
frame:RegisterEvent( "RAID_ROSTER_UPDATE" )

frame:SetScript( "OnEvent", EventHandler )

-- hook for manual looting clicks
hooksecurefunc( "LootButton_OnClick", ManualLootClick )
