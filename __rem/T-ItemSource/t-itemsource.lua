local WHITE		= "|cFFFFFFFF"
local RED		= "|cFFFF0000"
local GREEN		= "|cFF00FF00"
local YELLOW	= "|cFFFFFF00"
local ORANGE	= "|cFFFF7F00"
local TEAL		= "|cFF00FF9A"
local GOLD		= "|cFFFFD700"


Titemsourcever="1.0.0"

local PT = LibStub("LibPeriodicTable-3.1")
local TipHooker = LibStub("LibTipHooker-1.1")

 DEFAULT_CHAT_FRAME:AddMessage("T-ItemSource v"..Titemsourcever,0.1,1,1);

local DataSources = {
	"InstanceLoot",
	"InstanceLootHeroic",
	"CurrencyItems",
	"Tradeskill",
	"Reputation"
}

function TitemsourceGetSource(searchedID)
	local info, source
	for _, v in pairs(DataSources) do
		info, source = PT:ItemInSet(searchedID, v)
		if source then
			local tipus, fo, al = strsplit(".", source)	
			return v,fo,al,info;
		end
	end
end


function TitemsourceProcess(tooltip, name, link, ...)
  local _,itemID = strsplit(":",link);
  local tipus,fo,al,info =TitemsourceGetSource(itemID)
if ((fo==nil) or (tipus==nil))
then
--
else

if ((info==nil) or (info==0) or (type(info)=="boolean")) then info="";end;

  if (tipus=="InstanceLoot") then tooltip:AddLine(RED.."T-ItemSource: "..TEAL..fo..WHITE.." / "..GOLD..al);end;
  if (tipus=="InstanceLootHeroic") then tooltip:AddLine(RED.."T-ItemSource: "..TEAL..fo.." (HC)"..WHITE.." / "..GOLD..al);end;
  if (tipus=="CurrencyItems") then tooltip:AddLine(RED.."T-ItemSource: "..TEAL..fo..""..WHITE.." x "..GOLD..info);end;
  if (tipus=="Tradeskill") then tooltip:AddLine(RED.."T-ItemSource: "..TEAL..al..WHITE.." / "..GOLD..info);end;
  if (tipus=="Reputation") then tooltip:AddLine(RED.."T-ItemSource: "..TEAL..fo..WHITE.." / "..GOLD..al.." reputation");end;

end
tooltip:Show()
end

TipHooker:Hook(TitemsourceProcess, "item")
