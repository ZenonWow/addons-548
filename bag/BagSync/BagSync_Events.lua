-- Addon private namespace
local ADDON_NAME, ns = ...
-- Addon global namespace
local _G = _G
local BagSync = _G.BagSync
-- Localization
local L = BAGSYNC_L
-- Imported from BagSync.lua
local Debug = ns.Debug

-- Events monitored
ns.EventsToScan = {
	'BANKFRAME_OPENED',
	'BANKFRAME_CLOSED',
	'PLAYERBANKSLOTS_CHANGED',
	'PLAYERBANKBAGSLOTS_CHANGED',
	
	'GUILDBANKFRAME_OPENED',
	'GUILDBANKFRAME_CLOSED',
	'GUILDBANKBAGSLOTS_CHANGED',
	
	'MAIL_SHOW',
	'MAIL_INBOX_UPDATE',
	
	'AUCTION_HOUSE_SHOW',
	'AUCTION_OWNED_LIST_UPDATE',
	
	--void storage
	'VOID_STORAGE_OPEN',
	'VOID_STORAGE_CLOSE',
	'VOID_STORAGE_UPDATE',
	'VOID_STORAGE_CONTENTS_UPDATE',
	'VOID_TRANSFER_DONE',
	
	--this will be used for getting the tradeskill link
	'TRADE_SKILL_SHOW',
}
ns.EventsToScanAfterInitial = {
	'PLAYER_MONEY',
	'CURRENCY_DISPLAY_UPDATE',
	'BAG_UPDATE',
	'UNIT_INVENTORY_CHANGED',
	'GUILD_ROSTER_UPDATE',
}




------------------------------
--      Event Handlers      --
------------------------------


----------------------------
--      BAG UPDATES  	    --
----------------------------

--[[
function BagSync:PLAYER_MONEY()
	PlayerDB.gold = GetMoney()
end
--]]

function BagSync:BAG_UPDATE(event, bagID, slotID)
	print("BagSync:"..event.."(bagID="..bagID..", slotID="..tostring(slotID)..")")
	self:ScheduleScanContainer(bagID)
	-- When items in the builtin bank change PLAYERBANKSLOTS_CHANGED event is sent instead of BAG_UPDATE(BANK_CONTAINER).
	-- Changing equipped bags fires only BAG_UPDATE(BACKPACK_CONTAINER) event.
	if  bagID == BACKPACK_CONTAINER  then  self:Schedule( self.ScanBackpackBags )  end
end

function BagSync:UNIT_INVENTORY_CHANGED(event, unit, slotID)
	print("BagSync:"..event.."("..unit..", slotID="..tostring(slotID).."): Schedule ScanEquipment()")
	if unit == 'player' then
		self:Schedule( self.ScanEquipment )
	end
end

----------------------------
--      BANK	            --
----------------------------

function BagSync:BANKFRAME_OPENED()
	ns.atBank = true
	self:Schedule( self.ScanEntireBank )
end

-- From FrameXML/Constants.lua:
local BANK_CONTAINER = _G.BANK_CONTAINER or -1
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS or 4
local NUM_BANKGENERIC_SLOTS = _G.NUM_BANKGENERIC_SLOTS or 28
local NUM_BANKBAGSLOTS = _G.NUM_BANKBAGSLOTS or 7

function BagSync:BANKFRAME_CLOSED()
	ns.atBank = false
	-- Drop scheduled bank bag scans
	self.BagsToScan[BANK_CONTAINER] = nil
	for  bagID = NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS  do
		self.BagsToScan[bagID] = nil
	end
end


function BagSync:PLAYERBANKSLOTS_CHANGED(event, slotID)
	print("BagSync:"..event.."(slotID="..tostring(slotID)..")")
	if  0 < slotID  and  slotID <= NUM_BANKGENERIC_SLOTS  then
		-- return self:BAG_UPDATE(event, BANK_CONTAINER, slotID)
		self:ScheduleScanContainer(BANK_CONTAINER)
	elseif  NUM_BANKGENERIC_SLOTS < slotID  and  slotID <= NUM_BANKGENERIC_SLOTS+NUM_BANKBAGSLOTS  then
		local bagID = NUM_BAG_SLOTS + slotID - NUM_BANKGENERIC_SLOTS
		self:ScanBankBags(bagID)
	else
		-- When items in the builtin bank change PLAYERBANKSLOTS_CHANGED event is sent instead of BAG_UPDATE(BANK_CONTAINER).
		self:ScheduleScanContainer(BANK_CONTAINER)
		self:ScanBankBags()
	end
end

BagSync.PLAYERBANKBAGSLOTS_CHANGED = BagSync.BAG_UPDATE
--[[
function BagSync:PLAYERBANKBAGSLOTS_CHANGED(event, bagID, slotID)
	--print("BagSync:"..event.."(bagID="..bagID..", slotID="..tostring(slotID)..")")
	self:BAG_UPDATE(event, BANK_CONTAINER, slotID)
end
--]]

----------------------------
--      VOID BANK	        --
----------------------------

function BagSync:VOID_STORAGE_OPEN()
	ns.atVoidBank = true
	self:Schedule( self.ScanVoidBank )
end

function BagSync:VOID_STORAGE_CLOSE()
	ns.atVoidBank = false
end

function BagSync:VOID_STORAGE_UPDATE(event)
	print("BagSync:"..event.."()")
	self:Schedule( self.ScanVoidBank )
end

function BagSync:VOID_STORAGE_CONTENTS_UPDATE(event)
	print("BagSync:"..event.."()")
	self:Schedule( self.ScanVoidBank )
end

function BagSync:VOID_TRANSFER_DONE(event)
	print("BagSync:"..event.."()")
	self:Schedule( self.ScanVoidBank )
end

------------------------------
--      GUILD BANK	        --
------------------------------

--[[
function BagSync:GUILD_ROSTER_UPDATE()
	local newGuild =  IsInGuild()  and  GetGuildInfo('player')
	
	if  PlayerDB.guild ~= newGuild  then
		PlayerDB.guild = newGuild
		-- Delete guild bank data now  or  keep until next login
		if  self.instantForgetGuildData  then  self:FixDB_Data(true)  end
	end
end
--]]

function BagSync:GUILDBANKFRAME_OPENED()
	ns.atGuildBank = true
	if  not _G.BagSyncOpt.enableGuild  then  return  end
	
	ns.guildTabQueryQueue = {}
	local numTabs = GetNumGuildBankTabs()
	for  tabID = 1, numTabs  do
		-- add this tab to the queue to refresh; if we do them all at once the server bugs and sends massive amounts of events
		local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(tabID)
		if  isViewable  then
			ns.guildTabQueryQueue[tabID] = true
		end
	end
end

function BagSync:GUILDBANKFRAME_CLOSED()
	ns.atGuildBank = false
	ns.guildTabQueryQueue = nil
end

function BagSync:GUILDBANKBAGSLOTS_CHANGED(event, tabID, slotID)
	if  not _G.BagSyncOpt.enableGuild  then  return  end
	print("BagSync:"..event.."(tabID="..tostring(tabID)..", slotID="..tostring(slotID)..")")

	if  ns.guildTabQueryQueue  then
		-- check if we need to process the queue
		local tabID = next(ns.guildTabQueryQueue)
		if tabID then
			QueryGuildBankTab(tabID)
			ns.guildTabQueryQueue[tabID] = nil
		else
			-- the bank is ready for reading
			self:Schedule( self.ScanGuildBank )
		end
	end
end

------------------------------
--      MAILBOX  	        --
------------------------------

function BagSync:MAIL_SHOW()
	if ns.isCheckingMail then return end
	if not _G.BagSyncOpt.enableMailbox then return end
	self:Schedule( self.ScanMailbox )
end

function BagSync:MAIL_INBOX_UPDATE()
	if ns.isCheckingMail then return end
	if not _G.BagSyncOpt.enableMailbox then return end
	self:Schedule( self.ScanMailbox )
end

------------------------------
--     AUCTION HOUSE        --
------------------------------

function BagSync:AUCTION_HOUSE_SHOW()
	Debug('BagSync:AUCTION_HOUSE_SHOW()')
	if not _G.BagSyncOpt.enableAuction then return end
	self:Schedule( self.ScanAuctionHouse )
end

function BagSync:AUCTION_OWNED_LIST_UPDATE()
	Debug('BagSync:AUCTION_OWNED_LIST_UPDATE()')
	if not _G.BagSyncOpt.enableAuction then return end
	self:Schedule( self.ScanAuctionHouse )
end





------------------------
--      TOKENS        --
------------------------

-- Called from  MainMenuBar_OnEvent(CURRENCY_DISPLAY_UPDATE)
hooksecurefunc('BackpackTokenFrame_Update', BagSync.ScanTokens)

function BagSync:CURRENCY_DISPLAY_UPDATE(event)
	print('BagSync:CURRENCY_DISPLAY_UPDATE()')
	self:Schedule( self.ScanTokens )
end

--[[
function BagSync:PLAYER_REGEN_ENABLED(event)
	if  self.DelayTokenScan()  then  return  end
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	-- we're out of an arena or battleground scan the points
	ns.doTokenUpdate = 0
	self:Schedule( self.ScanTokens )
end
--]]




------------------------------
--     PROFESSION           --
------------------------------

local PlayerCraftDB

local function doRegularTradeSkill(numIndex, dbIdx)
	local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine, skillModifier = GetProfessionInfo(numIndex)
	if name and skillLevel then
		PlayerCraftDB[dbIdx] = format('%s,%s', name, skillLevel)
	end
end

function BagSync:TRADE_SKILL_SHOW()
	--IsTradeSkillLinked() returns true only if trade window was opened from chat link (meaning another player)
	if (not IsTradeSkillLinked()) then
		
		local playerRealm = GetRealmName()
		local RealmCraftDB = _G.BagSyncCRAFT_DB[playerRealm]
		local playerName = UnitName('player')
		PlayerCraftDB    = RealmCraftDB[playerName]
		
		local tradename = _G.GetTradeSkillLine()
		local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
		
		local iconProf1 = prof1 and select(2, GetProfessionInfo(prof1))
		local iconProf2 = prof2 and select(2, GetProfessionInfo(prof2))
		
		--list of tradeskills with NO skill link but can be used as primaries (ex. a person with two gathering skills)
		local noLinkTS = {
			["Interface\\Icons\\Trade_Herbalism"] = true, --this is Herbalism
			["Interface\\Icons\\INV_Misc_Pelt_Wolf_01"] = true, --this is Skinning
			["Interface\\Icons\\INV_Pick_02"] = true, --this is Mining
		}
		
		--prof1
		if prof1 and (GetProfessionInfo(prof1) == tradename) and GetTradeSkillListLink() then
			local skill = select(3, GetProfessionInfo(prof1))
			PlayerCraftDB[1] = { tradename, GetTradeSkillListLink(), skill }
		elseif prof1 and iconProf1 and noLinkTS[iconProf1] then
			--only store if it's herbalism, skinning, or mining
			doRegularTradeSkill(prof1, 1)
		elseif not prof1 and PlayerCraftDB[1] then
			--they removed a profession
			PlayerCraftDB[1] = nil
		end

		--prof2
		if prof2 and (GetProfessionInfo(prof2) == tradename) and GetTradeSkillListLink() then
			local skill = select(3, GetProfessionInfo(prof2))
			PlayerCraftDB[2] = { tradename, GetTradeSkillListLink(), skill }
		elseif prof2 and iconProf2 and noLinkTS[iconProf2] then
			--only store if it's herbalism, skinning, or mining
			doRegularTradeSkill(prof2, 2)
		elseif not prof2 and PlayerCraftDB[2] then
			--they removed a profession
			PlayerCraftDB[2] = nil
		end
		
		--archaeology
		if archaeology then
			doRegularTradeSkill(archaeology, 3)
		elseif not archaeology and PlayerCraftDB[3] then
			--they removed a profession
			PlayerCraftDB[3] = nil
		end
		
		--fishing
		if fishing then
			doRegularTradeSkill(fishing, 4)
		elseif not fishing and PlayerCraftDB[4] then
			--they removed a profession
			PlayerCraftDB[4] = nil
		end
		
		--cooking
		if cooking and (GetProfessionInfo(cooking) == tradename) and GetTradeSkillListLink() then
			local skill = select(3, GetProfessionInfo(cooking))
			PlayerCraftDB[5] = { tradename, GetTradeSkillListLink(), skill }
		elseif not cooking and PlayerCraftDB[5] then
			--they removed a profession
			PlayerCraftDB[5] = nil
		end
		
		--firstAid
		if firstAid and (GetProfessionInfo(firstAid) == tradename) and GetTradeSkillListLink() then
			local skill = select(3, GetProfessionInfo(firstAid))
			PlayerCraftDB[6] = { tradename, GetTradeSkillListLink(), skill }
		elseif not firstAid and PlayerCraftDB[6] then
			--they removed a profession
			PlayerCraftDB[6] = nil
		end
		
	end
end



