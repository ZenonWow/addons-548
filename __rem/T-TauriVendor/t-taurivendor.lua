-- Title: T-TauriVendor
-- Desc: Megadja a TauriVendor helyzetet
-- Author: Totoo
-- Version: 1.0.0
DEFAULT_CHAT_FRAME:AddMessage("T-TauriVendor v1.0",0.1,1,1);
function  ttvendorkiiralli(mit,cmd)	
    if (cmd=="guild") then
        SendChatMessage(mit, "GUILD", "Common", nil);
    else
        DEFAULT_CHAT_FRAME:AddMessage(mit,0.3,0.4,1);
    end;
end;
function  ttvendorkiirhorda(mit,cmd) 
    if (cmd=="guild") then
        SendChatMessage(mit, "GUILD", "Common", nil);   
    else
        DEFAULT_CHAT_FRAME:AddMessage(mit,1,0.3,0.3);
    end;
end;

function ttvendor_Command(cmd)
if ((cmd=="all") or (cmd=="mind") or (cmd=="list")) then 
  ttvendorkiiralli("TauriVendor - STORMWIND (0-4)");
  ttvendorkiirhorda("TauriVendor - UNDERCITY (4-8)");
  ttvendorkiiralli("TauriVendor - IRONFORGE (8-12)");
  ttvendorkiirhorda("TauriVendor - ORGRIMMAR (12-16)");
  ttvendorkiiralli("TauriVendor - DARNASUS (16-20)");
  ttvendorkiirhorda("TauriVendor - THUNDER BLUFF (20-24)");
else
	oras,percs=GetGameTime();
    ora=tonumber(oras);
    if ((ora>=0) and (ora<4)) then ttvendorkiiralli("TauriVendor - STORMWIND (0-4)",cmd);end;
    if ((ora>=4) and (ora<8)) then ttvendorkiirhorda("TauriVendor - UNDERCITY (4-8)",cmd);end;
    if ((ora>=8) and (ora<12)) then ttvendorkiiralli("TauriVendor - IRONFORGE (8-12)",cmd);end;
    if ((ora>=12) and (ora<16)) then ttvendorkiirhorda("TauriVendor - ORGRIMMAR (12-16)",cmd);end;
    if ((ora>=16) and (ora<20)) then ttvendorkiiralli("TauriVendor - DARNASUS (16-20)",cmd);end;
    if ((ora>=20)) then ttvendorkiirhorda("TauriVendor - THUNDER BLUFF (20-24)",cmd);end;
    end;
 end;
SLASH_TVEND1= "/vendor";SLASH_TVEND2= "/tvendor";SlashCmdList["TVEND"] = ttvendor_Command;
