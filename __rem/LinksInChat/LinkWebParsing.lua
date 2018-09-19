--####################################################################################
--####################################################################################
--Link Web Parsing
--####################################################################################
--Dependencies: LinksInChat.lua, HiddenTooltip.lua

local LinkWebParsing	= {};
LinkWebParsing.__index	= LinkWebParsing;
LinksInChat_LinkWebParsing	= LinkWebParsing; --Global declaration

local HiddenTooltip = LinksInChat_HiddenTooltip; --Local pointer


--Local variables that cache stuff so we dont have to recreate large objects
local cache_IsRegistered	= false;--Boolean
local cache_EventFunction	= nil;	--Nil or pointer to the eventhandler
local cache_Link			= {};	--Table where the key is the untranslated link and value is the translated link.
local cache_LinkCount		= 0;	--Size of cache_Link table. The table will grow during the playsession. If it ever reaches CONST_LINKMAX we simply reset the table to empty.
--local cache_PlayerName	= "";	--Name of the player.
local cache_prevMessage		= "";	--Orignal message that was last passed to MessageEventFilter()
local cache_prevMessageNew	= "";	--Modified message that was last passed to MessageEventFilter()


--Local Constants
local CONST_LINKMAX			= 500; --Max number of entries allowed in cache_Link. This is to prevent scenarios with very long playsessions that accumulate huge number of itemlinks that might affect memory too much.
local CONST_CHATEVENTS		= {"CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_CHANNEL", "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM", "CHAT_MSG_BN_CONVERSATION", "CHAT_MSG_BN_INLINE_TOAST_BROADCAST", "CHAT_MSG_BN_INLINE_TOAST_BROADCAST_INFORM"};
							--Table with all chat events we subscribe to.
local CONST_WEBLINKPATTERN	= nil; --Table with patterns used by getWebLinks() to find url's. Variable will get populated by Fill_CONST_WEBLINKPATTERN() function.


--Local pointers to global functions
local pairs		= pairs;
local strfind	= strfind;
local strmatch	= strmatch;
local strsub	= strsub;
local strlen	= strlen;
local strtrim	= strtrim;
local strlower	= strlower;
local tostring	= tostring;


--####################################################################################
--####################################################################################
--Public
--####################################################################################


--Register or unregister to chat channels
function LinkWebParsing:RegisterMessageEventFilters(register)
	if (register ~= true) then register = false; end --Boolean
	if (register == cache_IsRegistered) then return register; end --Don't do anything if its already done

	--Created a permanent pointer to the eventhandler function. We need this to register/unregister from chat events
	if (cache_EventFunction == nil) then
		cache_EventFunction = function(objSelf, channel, message, author, ...) return self:MessageEventFilter(objSelf, channel, message, author, ...) end;
	end--if

	local reg = ChatFrame_AddMessageEventFilter; --local fpointer
	if (register ~= true) then reg = ChatFrame_RemoveMessageEventFilter; end

	--Hook cache_EventFunction to all the different chat events listed in CONST_CHATEVENTS
	for key, eventName in pairs(CONST_CHATEVENTS) do
		reg(eventName, cache_EventFunction);
	end--for

	--Cache the player's name
	--cache_PlayerName = GetUnitName("player", false);

	cache_IsRegistered = register;
	return register;
end


--Event handler for ChatFrame_AddMessageEventFilter()
function LinkWebParsing:MessageEventFilter(objSelf, channel, message, author, ...)
	--Return TRUE to stop the message from propagating. Return FALSE + all arguments to keep propagating it
	--For our purposes we can use the same eventhandler for both CHAT_MSG_* and CHAT_MSG_BN_* since we only want to inspect the message and not mess with the authorname, etc.

	--Source: http://www.wowwiki.com/API_ChatFrame_AddMessageEventFilter
	--Note that your function will be called once for every frame the message-event is registered for. It's possible to get two calls for whisper, say, and yell messages, and seven for channel messages. Due to this non-deterministic calling, your filter function should not have side-effects.
	if (cache_prevMessage == message) then return false, cache_prevMessageNew, author, ...; end

	--Keep for faster return later
	cache_prevMessage	 = message;				--Original message
	cache_prevMessageNew = cache_prevMessage;	--(Possibly) modified message

	--if (author ~= cache_PlayerName) then --Ignore links that the player send himself
	--Can't ignore links that the player send himself because we need to convert them too into clickable hyperlinks for later
		message = self:getWebLinks(message); --Convert any web-links in the string into hyperlinks that the eventhandler can trigger on them later
		cache_prevMessageNew = message;
	--end--if author

	return false, message, author, ...;
end


--Determines what URL to return based on settings, and hyperlink data.
function LinkWebParsing:getHyperLinkURI(link, text, tblProvider, booSimple, booUseHTTPS) --Returns an string or nil.
	--link:			Hyperlink data
	--text:			Hyperlink text
	--tblProvider:	Table. All date for the Provider
	--booSimple:	Boolean. Just use simple url's for providers
	--print("text '"..tostring(text).."'");
	--print("link '"..tostring(link).."'");

	local linkType, linkID, arrLink = "", "", self:split(link, ":"); --Split linkdata into an array
	if (arrLink ~= nil and #arrLink > 1) then
		linkType = strlower(tostring(arrLink[1]));
		linkID	 = strtrim(tostring(arrLink[2]));
		--print("linkType '"..tostring(linkType).."'");
		--print("linkID '"..tostring(linkID).."'");
	end--if

	--We ignore tradeskill, player and instancelock links, They can't be searched for.
	if (linkType == "trade" or linkType == "player" or linkType == "instancelock") then return nil; end

	--Special case: Tooltipscanning crashes when attempting to scan battlepet links. We need to ask the PetJournal and match on the Species number (SpeciesID == you can have 3 pets of a species like 'Albino snake')
	if (linkType == "battlepet") then text = tostring(C_PetJournal.GetPetInfoBySpeciesID(linkID)); end

	--Special case: For currencies, 'text' is an empty string. We look up the name from the API
	if (linkType == "currency") then text = tostring(GetCurrencyInfo(linkID)); end --There are more arguments returned from this function but they vary depending on the currency and they are not documented

	--For some hyperlinks 'text' will sometimes be an empty string and we will use tooltip scanning to get a name for it.
	if (text == "") then
		text = HiddenTooltip:GetEquipmentItemInfo(link, "TITLE");
		--print("text '"..tostring(text).."' (TOOLTIPSCANNER)");
	end--if text

	if (booSimple == true and text == "") then return nil; end --If 'text' is empty we have failed.

	--Providers can either be simple: just search for the hyperlink's text
	--or they can be advanced: parse hyperlink and do different things for the providers (wowhead: /item=xxx, /achievement=yyy and so on)
	local res = "";
	if (booSimple == false and tblProvider["Advanced"] ~= "") then --Advanced
		local tmp = tblProvider["Advanced-"..linkType];	--A string if this linktype is supported by this provider. Otherwise nil.
		if (tmp ~= nil) then res = tmp..linkID; end		--Any other hyperlink type not listed here will fall back to using the simple approach
	end--if booSimple

	if (res == "") then --Simple search
		local pText = LinksInChat:HyperLink_Strip(text); --Convert 'text' to plain text string
		if (pText == nil) then
			pText = text;
		else
			pText = self:replace(pText, "[", "");
			pText = self:replace(pText, "]", "");
		end--if pText
		local uText = self:URLEncode(pText); --URL encoded plaintext string
		res = tblProvider["Simple"]..uText;--Simple search
	end--if res

	if (booUseHTTPS ~= true) then res = self:replace(res, "https://", "http://"); end --All URL's are https:// by default unless they for some reason are not supported by the webserver...
	return res;
end


--####################################################################################
--####################################################################################
--Support functions
--####################################################################################


--URL encode the string
function LinkWebParsing:URLEncode(str)
	--Source: http://lua-users.org/wiki/StringRecipes
	if (str) then
		str = string.gsub(str, "\n", "\r\n");
		str = string.gsub(str, "([^%w %-%_%.%~])", function (c) return string.format ("%%%02X", string.byte(c)) end );
		str = string.gsub (str, " ", "+");
	end
	return str;
end


--Replace all old links with the new links
function LinkWebParsing:replaceLinks(message, arrLinks)
	local pairs	= pairs; --local fpointer
	local gsub	= gsub;
	for old, new in pairs(arrLinks) do
		old = self:escapeMagicalCharacters(old); --escape any magical characters so that they are seen as literal strings
		message = gsub(message, old, new);
	end--for
	return message;
end


--[[
function foo()
	--local h1 = "|cffe5cc80|Hitem:104406:0:0:0:0:0:0:0:0:0:0|h[Hellscream's War Staff]|h|r";
	local h1 = "|cffe5cc80|Hitem:104406:|h[Hellscream's War Staff]|h|r";

	local a = "";
	--a = "hello "..h1.." world"; --PASSED
	--a = "hello"..h1.."world"; --PASSED
	--a = "hello www.site.com world"; --PASSED
	--a = "hellowww.site.com world"; --PASSED
	--a = "hello http://www.httpsite.com world"; --PASSED
	--a = "hellohttp://www.httpsite.com world"; --PASSED
	--a = "hello http://www.httpsite.com"; --PASSED
	--a = "hello www.site.com "..h1.." world"; --PASSED
	--a = "hellowww.site.com"..h1.."world"; --PASSED
	--a = "hello "..h1.." www.site.com world"; --PASSED
	--a = "hello "..h1.."http://www.site.com world"; --PASSED
	--a = "hello"..h1.."http://www.site.com world"; --PASSED
	--a = "hello foo@bar.com world"; --PASSED
	--a = "hello foo@bar.com "..h1.." world"; --PASSED
	--a = "hello "..h1.." foo@bar.com world"; --PASSED
	--a = "hello player#1234 world"; --PASSED
	--a = "hello player#1234 "..h1.." world"; --PASSED
	--a = "hello "..h1.." player#1234 world"; --PASSED

	local b = LinksInChat_LinkWebParsing:getWebLinks(a);
	print("  ");
	print("   '"..b.."'");
	print("  ");
	return a, b, "";
end]]--


--Traverse string and convert any web-links into hyperlinks that the event handler can trigger on.
function LinkWebParsing:getWebLinks(message)
	--Will return converted string or original string.
	local strfind	= strfind; --local fpointer
	local strsub	= strsub;

	message = self:strip_Hurl(message); --Remove any |Hurl: hyperlinks

	--Put a space after "|h|r" if there is no space there
	local p = "|h|r[^%s]";
	local startPos, endPos, firstWord, restOfString = strfind(message, p);
	while (startPos ~= nil) do
		local a, c = strsub(message, 1, (endPos-1) ), strsub(message, endPos);
		message = a.." "..c;
		startPos, endPos, firstWord, restOfString = strfind(message, p, endPos);
	end--while

	--Put a space before "|c" if there is no space there
	local p = "[^%s]|c";
	local startPos, endPos, firstWord, restOfString = strfind(message, p);
	while (startPos ~= nil) do
		local a, c = strsub(message, 1, startPos), strsub(message, (startPos+1) );
		message = a.." "..c;
		startPos, endPos, firstWord, restOfString = strfind(message, p, endPos);
	end--while

	message = message.." "; --Add a space to the end of the line so that the patterns will work even when at the end of the line
	local messageL = strlower(message); --Case-insensitive matching

	local arrP = CONST_WEBLINKPATTERN; --table with all the patterns for web-links we want to find.
	if (arrP == nil and self["Fill_CONST_WEBLINKPATTERN"] ~= nil) then arrP = self:Fill_CONST_WEBLINKPATTERN(); end --Will run once and create CONST_WEBLINKPATTERN table.

	for i = 1, #arrP do
		local p = arrP[i];
		local startPos, endPos, firstWord, restOfString = strfind(messageL, p);

		while (startPos ~= nil) do
			local orgWord	= strtrim( strsub(message, startPos, endPos) ); --String with original format.
			local orgWord2	= LinksInChat:WebLink_Strip(orgWord);			--Strip away any weblink found inside the string (www. can be inside http://)

			if (orgWord2 ~= orgWord) then
				message = self:replaceAt(message, orgWord2, startPos, endPos);
				endPos = endPos - ( strlen(orgWord) - strlen(orgWord2) ); --adjust the endPos to the new string-lenght
				orgWord = orgWord2;
			end--if orgWord2

			local newLink = LinksInChat:HyperLink_Create(orgWord);

			--message = self:replace(message, orgWord, newLink); --This approach is buggy since we are doing multiple iterations of replace() repeatedly on the same string (links, within links, within links etc)
			message = self:replaceAt(message, newLink, startPos, endPos);
			messageL = strlower(message);
			endPos = endPos + ( strlen(newLink) - strlen(orgWord) );					--Adjust the endPos to the new string-lenght
			startPos, endPos, firstWord, restOfString = strfind(messageL, p, endPos);	--Resume from the end of this link
		end--while
	end--for i

	return strtrim(message);
end


--Runs one time, populates CONST_WEBLINKPATTERN and then removes itself
function LinkWebParsing:Fill_CONST_WEBLINKPATTERN()
	--Create the pattern table for the getWebLinks() function.
	local arrP = {};
	arrP[#arrP+1] = "([A-Za-z0-9áàÁÀéèÉÈíìÍÌóòÓÒúùÚÙýÝäÄëËïÏöÖüÜÿâÂêÊîÎôÔûÛßæÆøØåÅ]+#+%d%d%d%d)%s";	--Battletag (accented characters supported, dont know how it will with Asia & Russia tho)
	arrP[#arrP+1] = "([A-Za-z0-9%.%%%+%-%_]+@[A-Za-z0-9%.%%%+%-%_]+%.%w%w%w?%w?)%s";				--Email

	--HARDCODED: Last updated: 2014-05-11 (instead of using a generic pattern that can mess up too much we only define a subset of the most (likely) protocols to be used with WoW (communication, social stuff etc)
	--Source: http://en.wikipedia.org/wiki/URI_scheme
	--arrP[#arrP+1] = "([A-Za-z0-9]+://.-)%s"; --this will catch all "<string>://<string><space>" but is too generic
	arrP[#arrP+1] = "(www%..-)%s";	--The 2 main patterns that we are looking for: http:// and www. and they must be in a specific order (inner to outer matching)
	arrP[#arrP+1] = "(http://.-)%s";
	arrP[#arrP+1] = "(https://.-)%s";
	arrP[#arrP+1] = "(mumble://.-)%s";			--Mumble
	arrP[#arrP+1] = "(teamspeak://.-)%s";		--Teamspeak
	arrP[#arrP+1] = "(ts3server://.-)%s";		--Teamspeak 3
	arrP[#arrP+1] = "(ventrilo://.-)%s";		--Ventrilo
	arrP[#arrP+1] = "(callto://.-)%s";			--Skype
	arrP[#arrP+1] = "(skype://.-)%s";			--Skype
	arrP[#arrP+1] = "(irc://.-)%s";				--IRC
	arrP[#arrP+1] = "(irc6://.-)%s";			--IRC ipv6
	arrP[#arrP+1] = "(ircs://.-)%s";			--Secure IRC
	arrP[#arrP+1] = "(git://.-)%s";				--Github
	arrP[#arrP+1] = "(svn://.-)%s";				--Subversion

	self["Fill_CONST_WEBLINKPATTERN"] = nil; --Cleanup ourselves
	CONST_WEBLINKPATTERN = arrP; --Store table
	return CONST_WEBLINKPATTERN;
end


--This function will strip out any |Hurl: hyperlinks.
function LinkWebParsing:strip_Hurl(message)
	--This function will strip out any |Hurl: hyperlinks. Addons like Chatter uses those to make clickable links out of hyperlinks. We basically need to strip them out before we do our own thing.
	local p = "%|c[A-Fa-f]+%|Hurl:(.-)%|h%[(.-)%]%|h%|r"; --Will extract the text of the hyperlink

	local startPos, endPos, firstWord, restOfString = strfind(message, p);
	while (startPos ~= nil) do
		message = self:replaceAt(message, firstWord, startPos, (endPos+1));
		startPos, endPos, firstWord, restOfString = strfind(message, p);
	end--while
	return message;
end


--Traverse string and return table with unique links or nil
function LinkWebParsing:getHyperLinks(message)
	--Will return nil or a table with subtable(s) with itemlink data in them.
	local strfind	= strfind; --local fpointer

	--local p = "|H(.-):(%d+).*%|h[(.+)%]"; --Original from phanx
	local p = "|H(.-):(%d+).-%|h%[(.-)%]%|h"; --Narrowed down so that it will find the nearest end of the link in the string (|h) (we also ignore the color in this pattern)

	local startPos, endPos, firstWord, restOfString = strfind(message, p);
	if (startPos == nil) then return nil; end

	local strmatch	= strmatch; --local fpointer
	local strsub	= strsub;
	local tostring	= tostring;

	local res = {}; --Result table
	while (startPos ~= nil) do
		local linkType, linkID, linkText = strmatch(message, p, startPos);
		local strLink					 = tostring(strsub(message, startPos,endPos)); --extract the whole link as-is (used with tooltipscanning)
		--print("    startPos: "..tostring(startPos).. " endPos:"..tostring(endPos).." firstWord: '"..tostring(firstWord).."' restOfString: '"..tostring(restOfString).."'");
		--print("    type: "..tostring(linkType).. " id:"..tostring(linkID).." text: '"..tostring(linkText).."' Link: '"..tostring(strLink).."'\n");

		--Store for later translation
		local tmp = { ["TYPE"]=tostring(linkType), ["TEXT"]=tostring(linkText) }; --["ID"]=linkID, ["LINK"]=strLink
		if (linkType == "trade" or linkType == "battlepet") then tmp["ID"] = linkID; end --Special cases: we only need the spellID for tradelinks and battlepets
		res[strLink] = tmp; --If the same link is being repeated in the message, then as a bonus of using it as the key we wont store it more than once in the result

		startPos, endPos, firstWord, restOfString = strfind(message, p, endPos); --resume from the end of this link
	end--while

	return res;
end


--This replace uses indexes to determine where to start and end the replace
function LinkWebParsing:replaceAt(str, new, startPos, endPos)
	local a = strsub(str, 1, (startPos-1));
	local c = strsub(str, endPos);
	local res = a..new..c;
	return res;
end


--This is copied from StringParsing.lua
--------------------------------------------------------------------------------------
	--Local variables that cache stuff so we dont have to recreate large objects
	local CONST_escapeMagicalCharacters	= {"(",")",".","%","+","-","*","?","[","]","^","$"}; --Hardcoded, these are the magical characters that have special meaning when it comes to LUA patterns, by adding % infront of them we escape them
	local CONST_escapeMagicalPattern	= "[%(%)%.%%%+%-%*%?%[%]%^%$]+"; --Pattern used to determine if a magical char is in the string

	--Replaces any occurences of ( ) . % + - * ? [ ] ^ $ by adding a % ahead of it
	function LinkWebParsing:escapeMagicalCharacters(str)
		local start = strfind(str, CONST_escapeMagicalPattern, 1); --We look for any of the magical characters, if none are in there then skip the loop
		if (start == nil) then
			return str;
		else
			local _strsub = strsub; --local fpointer
			local res = "";
			local esc = CONST_escapeMagicalCharacters;
			for i = 1, strlen(str) do
				local char = _strsub(str,i,i);
				for j = 1, #esc do
					if (char == esc[j]) then
						char = "%"..char;
						break;
					end--if
				end--for j
				res = res..char;
			end--for i
			return res;
		end
	end


--Replaces any occurences of 'old' with 'new'
function LinkWebParsing:replace(str, old, new)
	old = self:escapeMagicalCharacters(old); --escape any magical characters so that they are seen as literal strings
	return gsub(str, old, new);
end


--Split a string into an array using 'item' as a separator
function LinkWebParsing:split(str, item)
	if (str == nil or str == "" or item == nil or item == "") then return nil end
	if (strlen(item) > strlen(str)) then return nil end

	local sPos		= self:indexOf(str, item, 1); --find index of splitter
	if (sPos == nil) then return nil end --exit condition if there are no more splitters
	local tinsert	= tinsert; --local fpointer
	local strsub	= strsub;
	local strlen	= strlen;

	local res = {};
	while (sPos ~=nil) do
		local line = strsub(str, 1, (sPos-1)); --extract the line from the string (except the item itself)
		tinsert(res,line); --add the line into the array

		str  = strsub(str,(sPos+strlen(item)),-1); --remove the part of the string that we just added to the array
		sPos = self:indexOf(str, item, 1); --find the next index of splitter
	end
	--Append the remainder of the string as the last item
	if (strlen(str) > 0) then tinsert(res, str) end

	return res;
end


--Returns the index of the first found occurence of a string (left to right), will return nil if not found
function LinkWebParsing:indexOf(str, item, startPos)
	if (str == nil or str == "" or item == nil or item == "") then return nil end
	if (strlen(item) > strlen(str) or startPos > strlen(str)) then return nil end
	if (startPos < 1) then startPos = 1 end
	return strfind(str, item, startPos, true); --Plain find, Will return nil if not found
end


--####################################################################################
--####################################################################################