
-- saved variables
goldDB = {}

----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I


-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Gold" -- L["Gold"]
local tt = nil
local ttName = name.."TT"
local login_money = nil
local next_try = false
local current_money = 0
local goldInit = false
local goldLoaded = false
local faction = UnitFactionGroup("Player")


-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="Interface\\Minimap\\TRACKING\\Auctioneer",coords={0.05,0.95,0.05,0.95}}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show gold information. Shows gold amounts for characters on the same ns.realm and faction and the amount made or lost for the session."],
	events = {
		"PLAYER_LOGIN",
		"PLAYER_MONEY",
		"PLAYER_TRADE_MONEY",
		"TRADE_MONEY_CHANGED",
		"PLAYER_ENTERING_WORLD",
		"NEUTRAL_FACTION_SELECT_RESULT"
	},
	updateinterval = nil, -- 10
	config_defaults = {
		goldColor = false
	},
	config_allowed = nil,
	config = {
		height = 52,
		elements = {
			{
				type = "check",
				name = "goldColor",
				label = L["Gold coloring"],
				desc = L["Use colors instead of icons for gold, silver and copper"],
				event = true
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------


------------------------------------
-- module (BE internal) functions --
------------------------------------
local function initDB()
	if not goldDB[faction] then
		goldDB[faction] = { [ns.realm]={ [ns.player.name] = {0,ns.player.class} } }
	elseif not goldDB[faction][ns.realm] then
		goldDB[faction][ns.realm] = { [ns.player.name] = {0,ns.player.class} }
	end
end

module.preinit = initDB

module.onevent = function(self,event,msg)
	current_money = GetMoney()
	goldDB[faction][ns.realm][ns.player.name] = {current_money,ns.player.class}

	if event=="PLAYER_LOGIN" or (next_try and login_money==nil) then
		login_money = current_money
		next_try = (next_try==false and login_money==nil)
	end

	if event == "NEUTRAL_FACTION_SELECT_RESULT" then
		faction = UnitFactionGroup("Player")
		initDB()
		goldDB[faction][ns.realm][ns.player.name] = {current_money,ns.player.class}
		goldDB["Neutral"][ns.realm][ns.player.name] = nil
	end

	self.obj.text = ns.GetCoinColorOrTextureString(name,current_money)
end

local function addCharGoldInfo(tt,k,v)
		if type(v)~="table" then v = {v,"white"} end
		return  tt:AddLine(C(v[2],ns.scm(k)), ns.GetCoinColorOrTextureString(name,v[1]))
end


local function addFactionGoldInfo(tt,faction)
	local totalGold = 0

	for k,v in ns.pairsByKeys(goldDB[faction][ns.realm]) do  if  k ~= ns.player.name  then
		local line, column = addCharGoldInfo(tt,k,v)
		ns.highlightOnMouseover(tt, line)
		tt:SetLineScript(line, "OnMouseUp", function(self,button)
			if button == "RightButton" and IsShiftKeyDown() then
				goldDB[faction][ns.realm][k] = nil
				tt:Clear()
				module.ontooltip(tt)
			end 
		end)
		totalGold = totalGold + v[1]
		line, column = nil, nil
	end end
	
	return totalGold
end

module.ontooltip = function(tt)
	if (not tt.key) or tt.key~=ttName then return end -- don't override other LibQTip tooltips...

	local totalGold = 0
	local diff_money

	current_money = GetMoney()
	local playerMoney = {current_money,ns.player.class}
	goldDB[faction][ns.realm][ns.player.name] = playerMoney

	tt:Clear()
	--tt:AddHeader(C("dkyellow",L["Gold information"])
	--tt:AddSeparator()
	tt:AddHeader(C("ltgreen", faction))
	addCharGoldInfo(tt, ns.player.name, playerMoney)
	totalGold = playerMoney[1]
  
	totalGold = totalGold + addFactionGoldInfo(tt, faction)
  for  otherFaction,_  in  pairs(goldDB)  do  if  otherFaction ~= faction  then
    tt:AddSeparator()
    tt:AddHeader(C("ltgreen", otherFaction))
    totalGold= totalGold + addFactionGoldInfo(tt, otherFaction)
  end end
  
	tt:AddSeparator()
	tt:AddLine(L["Total Gold"], ns.GetCoinColorOrTextureString(name,totalGold))
	tt:AddSeparator(3,0,0,0,0)

	if login_money == nil then
		tt:AddLine(L["Session profit"], C("orange","Error"))
	elseif current_money == login_money then
		tt:AddLine(L["Session profit"], ns.GetCoinColorOrTextureString(name,0))
	elseif current_money > login_money then
		tt:AddLine(C("ltgreen",L["Session profit"]), "+ " .. ns.GetCoinColorOrTextureString(name,current_money - login_money))
	else
		tt:AddLine(C("ltred",L["Session loss"]), "- " .. ns.GetCoinColorOrTextureString(name,login_money - current_money))
	end

	if Broker_EverythingDB.showHints then
		tt:AddSeparator(3,0,0,0,0)
		line, column = tt:AddLine()
		tt:SetCell(line, 1, C("ltblue",L["Shift-RightClick"]).." || "..C("green",L["Remove entry"]), nil, nil, 2)
		line, column = tt:AddLine()
		tt:SetCell(line, 1, C("copper",L["Click"]).." || "..C("green",L["Open currency pane"]), nil, nil, 2)
	end
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
module.onenter = function(self)
	if (ns.tooltipChkOnShowModifier(false)) then return; end

	tt = ns.LQT:Acquire(ttName, 2, "LEFT", "RIGHT")
	module.ontooltip(tt)
	ns.createTooltip(self,tt)
end

module.onleave = function(self)
	ns.hideTooltip(tt,ttName,false,true)
end

module.onclick = function(self,button)
	securecall("ToggleCharacter","TokenFrame")
end


-- final module registration --
-------------------------------
ns.modules[name] = module

