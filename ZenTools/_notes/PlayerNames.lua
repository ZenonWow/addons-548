


--[[
  from FrameXML/Bindings.xml:
	<ModifiedClick action="FOCUSCAST" default="NONE"/>
	<ModifiedClick action="CHATLINK" default="SHIFT-BUTTON1"/>
	<ModifiedClick action="DRESSUP" default="CTRL-BUTTON1"/>
	<ModifiedClick action="SOCKETITEM" default="SHIFT-BUTTON2"/>
--]]

--[[
Btn1: target, keep history of them
Shift-Btn1: focus, link into editbox/chat, query who (copy to editbox),
   save into list
Ctrl-Btn1: open whisper chat (builtin for Btn1)
Alt-Btn1: set alt/main

Btn2: open who (copy to editbox), maybe focus (if no user-set focus)
Shift-Btn2: dropdown (builtin for Btn2)
Ctrl-Btn2: trade
Alt-Btn2: invite

always keep history of targeted (also unsuccessful),  linked/queried, chatted, partied (invite), traded with
--]]

--[[
Modifier or binding for copying what you click:  CHATLINK
Show the last on LDB, show last 10 on tooltip, show last 100 in WhoPanel/SocialPanel
Extremely useful for: PlayerNames in chat, and funky/special characters
Copy playername to WhoFrame -> 	WhoFrameEditBox:SetText(playername);  	SendWho(msg);  		ShowWhoPanel(); 
Only reliable solution with default ui is:
rightclick player name/frame -> Who Is? -> open Who frame -> select name -> Ctrl-C
--]]

--[[
  from FrameXML/Bindings.xml:
	<Binding name="INTERACTMOUSEOVER" category="BINDING_HEADER_TARGETING">
		if ( not InteractUnit("mouseover") ) then
			InteractUnit("target");
		end
	</Binding>
	<Binding name="INTERACTTARGET" category="BINDING_HEADER_TARGETING">
		InteractUnit("target");
	</Binding>
--]]

--[[
Modifier for focusing instead of targeting mouseover: FOCUS
	<ModifiedClick action="FOCUS"    default="SHIFT-BUTTON1"/>
See also builtin FOCUSCAST:
	<ModifiedClick action="FOCUSCAST" default="NONE"/>  -- preferred: SHIFT

Modifier or binding for interacting with what you click:  INTERACT
Interact with Player name in chat / player frame -> Whisper
	<ModifiedClick action="INTERACT" default="CTRL-BUTTON1"/>
--]]


