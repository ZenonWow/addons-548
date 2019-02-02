
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I
mailDB = {}

-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "Mail" -- L["Mail"]
local tooltip, tt, player_realm
local icons = {}
do for i=1, 22 do local _ = ("inv_letter_%02d"):format(i) icons[_] = "|Tinterface\\icons\\".._..":16:16:0:0|t" end end

-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name] = {iconfile="interface\\icons\\inv_letter_15",coords={0.05,0.95,0.05,0.95}}
--I[name..'_new'] = {iconfile="interface\\icons\\inv_letter_16",coords={0.05,0.95,0.05,0.95}}
I[name..'_new'] = {iconfile="interface\\icons\\inv_letter_18",coords={0.05,0.95,0.05,0.95}}
I[name..'_stored'] = {iconfile="interface\\icons\\inv_letter_03",coords={0.05,0.95,0.05,0.95}}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to alert you if you have mail."],
	events = {
		"UPDATE_PENDING_MAIL",
		"MAIL_INBOX_UPDATE",
		"MAIL_CLOSED",
		"PLAYER_LOGIN",
		"PLAYER_ENTERING_WORLD",
		"MAIL_SHOW"
	},
	updateinterval = nil, -- 10
	config_defaults = {
		playsound = false,
		showDaysLeft = true,
		hideMinimapMail = false
	},
	config_allowed = nil,
	config = {
		height = 52, --92,
		elements = {
			{
				type = "check",
				name = "playsound",
				label = L["Play sound on new mail"],
				desc = L["Enable to play a sound on receiving a new mail message. Default is off"]
			},
			{
				type = "check",
				name = "showDaysLeft",
				label = L["List mails on chars"],
				desc = L["Display a list of chars on all realms with there mail counts and 3 lowest days before return to sender. Chars with empty mail box aren't displayed."]
			},
			{
				type = "check",
				name = "hideMinimapMail",
				label = L["Hide minimap mail icon"],
				desc = L[""],
				event = "BE_HIDE_MINIMAPMAIL"
			}
		}
	}
}


--------------------------
-- some local functions --
--------------------------
function module.onqtip(tt)
	if not tt then  return  end

	tt:Clear()
	tt:SetColumnLayout(1, "LEFT", "RIGHT")
	tt:AddHeader(C("dkyellow",L[name]))
	tt:AddSeparator()

	local newMails = {GetLatestThreeSenders()}
	tt:AddLine(C("ltblue",L["Last 3 new mails"]),#newMails.." "..L["mails"])

	if #newMails>0 then
		for i,v in ipairs(newMails) do
			tt:AddLine("   "..ns.scm(v))
		end
	end

	if module.modDB.showDaysLeft then

		tt:AddSeparator(3,0,0,0,0)
		tt:AddHeader(C("dkyellow",L["Leave in mailbox"]))
		tt:AddSeparator()

		local n,x,t = nil,false,nil
		for i,v in ns.pairsByKeys(mailDB) do
			if i~="v2" and #v.mails~=0 then
				n = {strsplit("/",i)}
				tt:AddLine(("%s (%s)"):format(C(v.class,ns.scm(n[2])),C("dkyellow",ns.scm(n[1]))),v.count.." "..L["mails"])
				for I,V in ipairs(v.mails) do
					t = V.returns~=nil and V.returns-(time()-V.last) or 30*86400
					tt:AddLine(
						"   "..
						ns.scm(V.sender)
						.." "..
						(V.money and " |TInterface\\Minimap\\TRACKING\\Auctioneer:12:12:0:-1:64:64:4:56:4:56|t" or "")
						..
						(V.items and " |TInterface\\icons\\INV_Crate_02:12:12:0:-1:64:64:4:56:4:56|t" or "")
						..
						(V.gm and " |TInterface\\chatframe\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t" or ""),
						C((t<86400 and "red") or (t<(3*86400) and "orange") or (t<(7*86400) and "yellow") or "green",SecondsToTime(t))
					)
				end
				x = true
			end
		end
		if x==false then
			--tt:AddSeparator()
			tt:AddLine(L["No data"])
		end
	end
end


------------------------------------
-- module (BE internal) functions --
------------------------------------

module.preinit = function()
	ns.hideFrame("MiniMapMailFrame", module.modDB.hideMinimapMail)

	player_realm = ns.realm.."/"..ns.player.name

	local tmp = {}
	for i,v in pairs(mailDB)do
		if i:match("/") and #v.mails>0 then
			tmp[i] = v
		end
	end
	mailDB = tmp

	if (not mailDB[player_realm]) then
		mailDB[player_realm] = {
			count=0,
			class=ns.player.class,
			mails={}
		}
	end
end


module.onevent = function(self,event,msg)
	local dataobj = self.obj
	local mailState = 0
	
	if event == "UPDATE_PENDING_MAIL" or event == "PLAYER_ENTERING_WORLD" or event =="PLAYER_LOGIN" then
--		local sender1, sender2, sender3 = GetLatestThreeSenders()

		if HasNewMail()==true or GetLatestThreeSenders()~=nil then
			mailState = 1
		elseif #mailDB[player_realm].mails>0 then
			mailState = 2
		end
		
		if HasNewMail() and Broker_EverythingDB[name].playsound == true then
			PlaySoundFile("Interface\\Addons\\"..addon.."\\media\\mailalert.mp3", "Master")
		end
	
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:UnregisterEvent("PLAYER_LOGIN")
	end
	
	if event == "MAIL_INBOX_UPDATE" or event == "MAIL_SHOW" or event == "MAIL_CLOSED" then
		local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, wasReturned, textCreated, canReply, isGM, dt, ht, mailStored, firstItemQuantity
		local num,returns,next1,next2,next3,tmp = GetInboxNumItems(),(99*86400),nil,nil,nil,nil
		for i=1, num do
			packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, itemCount, wasRead, wasReturned, textCreated, canReply, isGM, firstItemQuantity = GetInboxHeaderInfo(i)
			itemCount = itemCount or 0 -- pre WoD compatibility

			dt, ht = floor(daysLeft) * 86400, (1 - (daysLeft-floor(daysLeft))) * 86400
			tmp = {
				sender=sender,
				subject=subject,
				money=money>0,
				items=itemCount>0,
				gm=(isGM),
				last=time(),
				returns=floor(dt-ht)
			}
			--ns.print_t(event,tmp)

			if not (wasReturned) then
				if tmp.returns < returns then
					returns = tmp.returns
				end
				if next1==nil then
					next1=tmp
					mailStored = true
				elseif tmp.returns < next1.returns then
					if next2~=nil then
						next3=next2
					end
					next2=next1
					next1=tmp
				end
			end
		end
		mailDB[player_realm] = {
			class = ns.player.class,
			count = num,
			mails = {next1,next2,next3}
		}
		if mailStored and mailState==0 then
			mailState = 2
		end
	end

	if event == "BE_HIDE_MINIMAPMAIL" then
		ns.hideFrame("MiniMapMailFrame", module.modDB.hideMinimapMail)
	end

	local icon, text = I(name), L["No Mail"]
	if mailState==1 then
		icon, text = I(name.."_new"), C("green",L["New mail"])
	elseif mailState==2 then
		icon, text = I(name.."_stored"), C("yellow",L["Stored mails"])
	end
	dataobj.iconCoords = icon.coords or {0,1,0,1}
	dataobj.icon = icon.iconfile
	dataobj.text = text
	
	module.onqtip(module.tooltip)
end



module.ontooltip = function(tooltip)
	local sender1, sender2, sender3 = GetLatestThreeSenders()
	ns.tooltipScaling(tooltip)
	tooltip:AddLine(L[name])

	tooltip:AddLine(" ")
	if not sender1 then
		tooltip:AddLine(L["No Mail"])
		return
	end

	tooltip:AddLine(L["Mail from"])
	tooltip:AddLine(ns.scm(sender1))
	if sender2 then tooltip:AddLine(ns.scm(sender2)) end
	if sender3 then tooltip:AddLine(ns.scm(sender3)) end
end


-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------

-- MinimapMailFrameUpdate


--_G['MiniMapMailFrame']:HookScript("OnLoad",function(self) if Broker_EverythingDB[name].hideMinimapMail then self:UnregisterEvent("UPDATE_PENDING_MAIL") end end)
--_G['MiniMapMailFrame']:HookScript("OnEvent",function(self) if Broker_EverythingDB[name].hideMinimapMail then self:Hide() end end)


--[[

 -- DBR = Days Before Return
Broker_EverythingDB[name].showRealmCharsMailCount
Broker_EverythingDB[name].critDBR -- crit warn display in broker. in tooltip red
Broker_EverythingDB[name].warnDBR -- display in tooltip orange.

realm wide mail count with lowest days before return to sender
warn on critical "days before return" (choosable)

or realm independent? maybe... 
Broker_EverythingDB[name].showAllRealms :) let the use choose.

]]


-- final module registration --
-------------------------------
ns.modules[name] = module

