HackExamples = {
   examplebook = {
      name = "Examples Book",
      data = {
      {
         name = "|cff7cb8c7Welcome to Hack!  |cffff0000READ ME FIRST!!",
         data = "Welcome to Hack, a notebook and/or UI tweaking tool.\n\nI've included example pages to show how Hack can be used. Most examples will interest only addon developers, but a few are generally useful (e.g. try /bs to search your bags).  You can delete any pages you don't want, or nuke them all at once via the books tab.\n\nThe UI is mostly self-explanatory; mouse over buttons to see what they do. A few things deserve special mention:\n   \n   1. Run the selected page as Lua code by clicking the 'play' button at the top of edit window (this one) or by pressing SHIFT+TAB from within the editor.\n   \n   2.  You can make a page run automatically when Hack loads by clicking the 'play' button next to it's name in the list window. This makes Hack useful for little UI tweaks that don't warrant a full-blown addon. For example, I hate the mail font. It's easy to fix, but I don't want to write a whole addon for two lines of code. I type the lines into a Hack page and flag it to execute. Done.\n   \n   NOTES:\n   \n   * Pages are saved as you type and there is no undo, so be careful. If you really screw up a page, you can hit the Revert button, which will give you back the page as it was when you first opened it.\n   \n   * The list frame and edit frame are resizable. Just grab the little handle in the bottom right corner.\n   \n   * Page search is case insensitive. You can use regex (Lua patterns) with the exception of [] or ().\n   \n   * You can double-click a page name to rename it (in addition to using the rename button).\n   \n   * Autorun pages run in the order they appear, so you can control their execution order by moving them up and down the list. \n   \n   IMPORT:\n   \n   The first four scripts allow you to import your pages from other popular notepad addons. If your favorite isn't here, let me know. Note that LuaSlinger also supports triggering pages via events, which we can easily copy using a simple event library hack (lib:event) . To run an importer, just click on it then click the Run button above the script text.\n   \n   \n   EXAMPLES:\n   \n   The \"lib:\" pages contain library code I find useful in many scripts. Lib:core contains \"require\", which can be used to make sure a page you are dependent on is loaded, while preventing it from being loaded more than once.\n   \n   The arg processing examples show how you can execute a page by name, optionally passing arguments and/or receiving return values.\n   \n   The \"timer lib\" examples show how to use \"lib: timer\".\n   \n   The \"cmd:\" examples add new slash commands to the game.\n   \n   The \"ui:\" examples are various minor tweaks to the UI.\n   \n   The \"hack:\" examples are bits of code I used to write Hack. Saves you a lot of reloading to develop with a tool like this.\n   \n   Cheers,\n   Eric Tetz \n   <erictetz@gmail.com>",
         autorun = nil,
         colorize = nil,
      },
      {
         name = "import: TinyPad pages",
         data = "if TinyPadPages then\n   local hacks = HackDB.books[HackDB.book].data\n   for i,page in ipairs(TinyPadPages) do\n      hacks[#hacks+1] = {name='TinyPad page #'..i, data=page}\n   end\n   Hack.UpdateListItems()\nend",
         autorun = nil,
         colorize = true,
      },
      {
         name = "import: Nefpad pages",
         data = "if NefpadDB then\n   local hacks = HackDB.books[HackDB.book].data\n   for name,text in pairs(NefpadDB.savedfiles) do\n      table.insert(hacks, {name='Nefpad page: '..name, data=text} )\n   end\n   Hack.UpdateListItems()\nend",
         autorun = nil,
         colorize = true,
      },
      {
         name = "import: WowLua pages",
         data = "if WowLua_DB then\n   local hacks = HackDB.books[HackDB.book].data\n   for i,page in pairs(WowLua_DB.pages) do\n      table.insert(hacks, {name='WowLua page: '..page.name, data=page.content} )\n   end\n   Hack.UpdateListItems()\nend",
         autorun = nil,
         colorize = true,
      },
      {
         name = "import: LuaSlinger pages,library,events,etc.",
         data = "if LUASLINGER_VERSION=='1.2' then\n   local hacks = HackDB.books[HackDB.book].data\n   local name = 'LuaSlinger '\n   local sname = name..'Script #'\n   -- implement LuaSlinger event dispatcher with lib:event\n   local dispatch = \"Hack.Require 'lib: event'\"\n   for event,pages in pairs(LUASLINGER_EVENT_DISPATCH) do\n      for i,page in pairs(pages) do\n         dispatch = format(\n            \"%sAddEventListener('%s',Hack.Run,'%s')\",\n            dispatch, event, sname..page\n         )\n      end\n   end\n   local function add(n,t,r)\n      if t ~= '' then\n         hacks[#hacks+1] = {name=n,data=t,autorun=r}\n      end\n   end\n   add(name..'Library', LuaSlinger_getLibrary())\n   add(name..'Scratch', LuaSlinger_getScratch())\n   add(name..'Event Dispatcher', dispatch, true)\n   for i,page in ipairs(LUASLINGER_SCRIPTS) do\n      add(sname..i, LuaSlinger_getScript(i).text)\n   end \n   Hack.UpdateListItems()\n   print(\"NOTE: if you rename your imported scripts, you'll need to\")\n   print(\"update LuaSlinger Event Dispatcher page, which refers to\")\n   print(\"the imported scripts by name.\")\nend",
         autorun = nil,
         colorize = true,
      },
      {
         name = "cmd: /foodcheck",
         data = "-- Use /foodcheck  to show who in your raid needs a food buff.\n-- Announces to raid by default, but you can pass an argument\n-- (anything) to make it show only you.\n\nSlashCmdList['FOODCHECK_DISPLAY'] = function(silent)\n   for i=1,40 do\n      local unit = 'raid'..i\n      local name = UnitName(unit)\n      if name and not (UnitBuff(unit, 'Well Fed') or UnitBuff(unit, 'Food')) then\n         local msg = 'food check: '..name..' needs to eat!'\n         if silent ~= ''then print(msg)\n         else SendChatMessage(msg, 'raid') end\n      end\n   end\nend\nSLASH_FOODCHECK_DISPLAY1 = '/foodcheck'",
         autorun = true,
         colorize = true,
      },
      {
         name = "cmd: /bs  -  bag search",
         data = "-- Use /bs <text>  to search bags by item name\n-- Use /bs -r [0-6] to search bags by rarity level \n-- Matchng item slots will be highlighted for a few seconds.\n\nHack.Require 'lib: core'\nHack.Require 'lib: timer'\n\nlocal function getobj(...) return getglobal(format(...)) end\nlocal function print(...) _G.print('||cffffff00<BagSearch>:',...) end\n\nlocal color1, color2 = {.3,.3,.3}, {1,1,1}\n\nlocal function highlightSlots(bag, slot)\n   local icon = getobj('ContainerFrame%dItem%dIconTexture', bag, slot)\n   local back = getobj('ContainerFrame%dItem%dNormalTexture', bag, slot)\n   local blinks = 20\n   local function blinker()\n      local color = math.fmod(blinks,2)==0 and color1 or color2\n      icon:SetVertexColor(unpack(color))\n      back:SetVertexColor(unpack(color))\n      blinks = blinks - 1\n      return blinks == 0\n   end\n   SetTimer(.2, blinker, true)\nend\n\n-- find container items matching given criteria and highlight them\nlocal function find(match)\n   local stacks = 0\n   local total = 0\n   for bag=0,16 do\n      local numslots = GetContainerNumSlots(bag)\n      for slot=1,numslots do\n         local link = GetContainerItemLink(bag,slot)\n         if link and match(link) then\n            local _,count,_,qual = GetContainerItemInfo(bag, slot)\n            stacks = stacks + 1\n            total = total + count\n            highlightSlots(bag+1, numslots-slot+1)\n         end\n      end\n   end\n   if total > 0 then\n      print(('%d items in %d stacks'):format(total, stacks))\n   else\n      print('no items found')\n   end\nend\n\nlocal function slashHandler(msg)\n   if msg == '' then\n      print('usage: /bs <text to search for>')\n      print('usage: /bs -q [0-6]       {search by quality level}')\n   elseif msg:match('-q %d') then -- search by item quality (number from 0 to 6)\n      local itemlevel = tonumber( msg:match('-q (%d)') )\n      find(function(link)\n            return itemlevel == select(3, GetItemInfo(link))\n      end)\n   else -- search by name\n      local pattern = caseInsensitivePattern(msg)\n      find(function(link) \n            return link:match(pattern)\n      end)\n   end\nend\n\nSLASH_BAGSEARCH_DISPLAY1 = '/bs'\nSlashCmdList['BAGSEARCH_DISPLAY'] = slashHandler\nprint('loaded')",
         autorun = true,
         colorize = true,
      },
      {
         name = "cmd: /qq  - quest query",
         data = "-- Type  /qq <text>  to search your quest log.\n-- Matching quests will be linked in your chat window.\n\nHack.Require 'lib: core'\n\nlocal function qqPrint(...)\n   print('<QuestQuery>:', format(...) )\nend\n\nlocal function qqCreateLink(id,title,level,details,status,search)\n   local titlec, detailsc, matchc, levelc = '||cffffffff', '||cffafafaf', '||cffafafff', GetDifficultyColor(level)\n   levelc = format('||cff%02x%02x%02x', levelc.r* 255, levelc.g * 255, levelc.b * 255)\n   details = details:gsub( search, format('%s%%1%s', matchc, detailsc ) ) -- highlight search string\n   title   = title  :gsub( search, format('%s%%1%s', matchc, titlec   ) ) -- highlight search string\n   title   = title  :gsub('%[%d+%w%]%s*', '') -- if another addon added level, strip it\n   return format( '||Hqql:%s||h%s[%s] %s%s ||cffdddddd%s\\n%s%s', id, levelc, level,\n   titlec, title, status, detailsc, details )\nend\n\n-- search full text of every quest log entry\nlocal function qqFind(search)\n   search = caseInsensitivePattern(search)\n   ExpandQuestHeader(0) -- expand all headers (we can only iterate through visible items)\n   local currentLogSelection = GetQuestLogSelection() -- to restore later\n   local found = {} -- matches stored here\n   local region = '' -- keep track of current region as we iterate\n   for questID=1,GetNumQuestLogEntries() do\n      SelectQuestLogEntry(questID) -- must select the log entry before calling GetQuestLogQuestText\n      local title, level, tag, group, header, collapsed, status, daily = GetQuestLogTitle(questID)\n      if level == 0 then\n         region = title\n      else\n         local description, details = GetQuestLogQuestText()\n         status = (status == 1 and '(Complete)') or (status == -1 and '(Failed)') or ''\n         if table.concat{ \n            region, title, level, description, details, tag or '', \n            status, daily == 1 and 'daily' or '' \n         }:match( search ) then\n            found[ #found+1 ] = qqCreateLink(questID, title, level, details, status, search)\n         end\n      end\n   end\n   qqPrint('%d matches found.', #found)\n   for _,link in pairs(found) do\n      DEFAULT_CHAT_FRAME:AddMessage(link)\n   end\n   SelectQuestLogEntry(currentLogSelection)\nend\n\nlocal SetItemRef_original = SetItemRef\nfunction SetItemRef(link, text, mousebutton)\n   if strsub(link, 1, 3) == 'qql' then\n      local questID = tonumber( strsub(link,5) )\n      -- show quest log, select the correct quest and scroll to it\n      if not QuestLogFrame:IsVisible() then\n         ShowUIPanel(QuestLogFrame)\n      end\n      ExpandQuestHeader(0) -- must expand all entries for the scrolling to work\n      QuestLogListScrollFrameScrollBar:SetValue((questID - 1) * QUESTLOG_QUEST_HEIGHT)\n      local buttonId = questID - FauxScrollFrame_GetOffset(QuestLogListScrollFrame)\n      local button = getglobal('QuestLogTitle'..buttonId)\n      QuestLogTitleButton_OnClick(button, mousebutton)\n   else\n      SetItemRef_original(link, text, mousebutton)\n   end\nend\n\nSlashCmdList['QUESTQUERY_DISPLAY'] = function(msg)\n   if msg == '' then\n      qqPrint('usage: /qq <text to search for>')\n   else\n      qqFind(msg)\n   end\nend\nSLASH_QUESTQUERY_DISPLAY1 = '/qq'\nqqPrint('v1.0 loaded')",
         autorun = true,
         colorize = true,
      },
      {
         name = "ui: auto-vendor greys",
         data = "-- automatically sells any grey items in your bags\n\nHack.Require 'lib: core'\nHack.Require 'lib: event'\n\nAddEventListener( 'MERCHANT_SHOW', \n   function()\n      for bag=0,16 do\n         for slot=1,GetContainerNumSlots(bag) do\n            local link = GetContainerItemLink(bag,slot)\n            if link and 0 == select(3, GetItemInfo(link)) then\n               printf('Selling %s', link, bag+1, slot)\n               UseContainerItem(bag, slot)\n            end\n         end\n      end\n   end\n)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "ui: loot filter",
         data = "-- Automatically delete unwanted items, or open items (like clams).\n-- To add/remove items, edit one of the following lists and (re)run the page.\n\nlocal DELETE = [[\nBarrelhead Goby\nRaw Brilliant Smallfish\nRaw Longjaw Mud Snapper\nRaw Bristle Whisker Catfish\nFractured Canine\nSmall Barnacled Clam\nShellfish\nShiny Fish Scales\nSewer Carp\nBonescale Snapper\nRaw Spotted Yellowtail\n]]\n\nlocal OPEN = [[\nReinforced Crate\n]]\n\nHack.Require 'lib: core'\nHack.Require 'lib: event'\nHack.Require 'lib: timer'\n\n-- convert delete&open lists into lookup tables\nfunction split(s) \n   local t={} \n   s:gsub('([^\\n]*)', function(s) t[s]=true end) \n   return t\nend\nDELETE = split(DELETE)\nOPEN = split(OPEN)\n\nlocal function lootFilter()\n   for bag=0,16 do\n      for slot=1,GetContainerNumSlots(bag) do\n         local item = GetContainerItemLink(bag,slot)\n         if item then\n            local name = item:match('%[(.-)%]')\n            if DELETE[name] then\n               printf('Deleting %s (%d,%d)', item, bag+1, slot)\n               PickupContainerItem(bag, slot)\n               if CursorHasItem() then\n                  DeleteCursorItem()\n               end\n            elseif OPEN[name] then\n               printf('Opening %s (%d,%d)', item, bag+1, slot)\n               UseContainerItem(bag, slot)\n            end\n         end\n      end \n   end\nend\n\n\nif lootFilterEventListener then\n   RemoveEventListener('ITEM_PUSH', lootFilterEventListener)\nend\n\nlootFilterEventListener = AddEventListener(\n   'ITEM_PUSH', function() SetTimer( 1, lootFilter ) end\n)\n\nlootFilter()",
         autorun = nil,
         colorize = true,
      },
      {
         name = "ui: set viewport",
         data = "-- play around with these inset values... very fun!\n\nlocal left, right, top, bottom = 0, 0, 0, 100 -- inset amounts\n\nfunction setViewport(left, right, top, bottom)\n   WorldFrame:SetPoint('TopLeft', nil, 'TopLeft', left, -top)\n   WorldFrame:SetPoint('BottomRight', nil, 'BottomRight', -right, bottom)\nend\n\n-- restore fullscreen viewport when UI hidden\nUIParent:SetScript('OnHide', function() setViewport(0, 0, 0, 0) end)\nUIParent:SetScript('OnShow', function() setViewport(left, right, top, bottom) end)\n\nsetViewport(left, right, top, bottom)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "ui: make mail readable",
         data = "-- change mail font into something legible\n\nlocal font, size ='Fonts\\\\FRIZQT__.TTF', 14\nSendMailBodyEditBox:SetFont(font, size)\nOpenMailBodyText:SetFont(font, size)",
         autorun = true,
         colorize = true,
      },
      {
         name = "ui: add copy/paste buttons to Color Picker",
         data = "-- add copy and paste buttons to any Color Picker in the UI\n\nlocal r,g,b = 1,1,1\n\nlocal cp = CreateFrame('Button', nil, ColorPickerFrame, 'OptionsButtonTemplate')\ncp:SetText('Copy')\ncp:SetPoint('BOTTOMLEFT', ColorPickerFrame, 'TOPLEFT',0,2)\ncp:SetScript('OnClick', function() ColorPickerFrame:SetColorRGB(r,g,b) end)\n\n\nlocal ps = CreateFrame('Button', nil, ColorPickerFrame, 'OptionsButtonTemplate')\nps:SetText('Paste')\nps:SetPoint('BOTTOMRIGHT', ColorPickerFrame, 'TOPRIGHT',0,2)\nps:SetScript('OnClick', function() r,g,b = ColorPickerFrame:GetColorRGB() end)",
         autorun = true,
         colorize = true,
      },
      {
         name = "ui: show XP gain",
         data = "Hack.Require 'lib: event'\n\nlocal output = ChatFrame1\nlocal previous\n\nAddEventListener('PLAYER_REGEN_DISABLED', \n   function()\n      previous = UnitXP('player')\n   end\n)    \n\nAddEventListener('PLAYER_REGEN_ENABLED', \n   function()\n      local current = UnitXP('player')\n      local gained = current - previous\n      previous = current\n      if gained > 0 then \n         local toLevel = UnitXPMax('player') - current\n         output:AddMessage(\n            string.format('+%d XP (1/%d)', \n               gained, toLevel/gained\n            ), .435, .435, 1\n         )\n      end    \n   end\n)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "ui: report who's pinging the map",
         data = "Hack.Require 'lib: core'\nHack.Require 'lib: event'\n\nAddEventListener('MINIMAP_PING', \n   function(self, event, unit, x, y)\n      printf('%s pinged the minimap.', GetUnitName(unit))\n   end\n)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "ui: increase max camera distance/speed",
         data = "-- this only needs to be run once, then\n-- it's stored in wtfconfig.wtf\n\nConsoleExec 'set cameraSmoothStyle 0'\nConsoleExec 'set cameraDistanceMoveSpeed 40'\nConsoleExec 'set cameraDistanceSmoothSpeed 10'\nConsoleExec 'set cameraDistanceMax 40'\nConsoleExec 'set cameraDistanceMaxFactor 2'",
         autorun = nil,
         colorize = true,
      },
      {
         name = "ui: minimap mousewheel zoom",
         data = "-- add mousewheel support to minimap (for zoom)\n\nlocal maxzoom = Minimap:GetZoomLevels()\nlocal function OnMouseWheel(self,value)\n   local zoom = Minimap:GetZoom() + value\n   if 0 <= zoom and zoom < maxzoom then\n      Minimap:SetZoom(zoom)\n   end\nend\n\nlocal overlay = CreateFrame('Frame', nil, Minimap)\noverlay:SetAllPoints(Minimap)\noverlay:EnableMouseWheel(true)\noverlay:SetScript('OnMouseWheel', OnMouseWheel)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "ui: square minimap",
         data = "-- Strip extra bullshit off the minimap & make it square.\n-- Click on zone text to toggle (since we're hiding toggle button).\n\n-- uncomment these lines to reposition the minimap\n--Minimap:ClearAllPoints()\n--Minimap:SetPoint('TOPLEFT',UIParent,'TOPLEFT',-10,-20)\n\nMinimap:SetMaskTexture('Interface\\\\AddOns\\\\Hack\\\\Media\\\\Square')\n\nMinimapZoneTextButton:ClearAllPoints()\nMinimapZoneTextButton:SetPoint('BOTTOM',Minimap,'BOTTOM',0,5)\nMinimapZoneTextButton:SetFrameStrata('DIALOG')\nMinimapZoneTextButton:SetScript('OnClick',ToggleMinimap)\n\nMinimapToggleButton:Hide()\nMinimapZoomIn      :Hide()\nMinimapZoomOut     :Hide()    \nMinimapBorder      :Hide()\nMinimapBorderTop   :Hide()",
         autorun = nil,
         colorize = true,
      },
      {
         name = "ui: map coordinate frame",
         data = "-- Show map coordinates in minimap. If you want\n-- to drag it somewhere else, uncomment the\n-- 'MakeFrameDraggable' line.\n\nHack.Require 'lib: core'\nHack.Require 'lib: timer'\n\nlocal parent = Minimap\nlocal f = CreateFrame('Frame', 'MapCoordFrame', Minimap)\nf:SetWidth(75)\nf:SetHeight(25)\nf:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 5, 13)\nf:SetAlpha(.6)\n--MakeFrameDraggable(f)\n\nlocal text = f:CreateFontString()\ntext:SetFont('Fonts\\\\FRIZQT__.TTF', 12)\ntext:SetPoint('CENTER', f, 'CENTER', 0, 0)\n\nlocal oldx, oldy\nlocal function update()\n   SetMapToCurrentZone() \n   local x, y = GetPlayerMapPosition('player')\n   x = math.floor(x*100+.5)\n   y = math.floor(y*100+.5)\n   -- only update when x,y have actually changed\n   if x ~= oldx or y ~= oldy then\n      oldx, oldy = x, y\n      text:SetText( format('%d, %d', x, y) )\n   end\nend\n\nSetTimer(.3, update, true)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "ui: hide chat buttons, enable mouse scroll, move editbox to top",
         data = "-- hide chat buttons\n-- enable mouse scroll\n-- move editbox to top\n-- remove resize limit\n-- turn off auto-fade\n\nHack.Require 'lib: core'\n\nlocal function onChatScroll(self, direction)\n   if direction > 0 then\n      if IsShiftKeyDown() then\n         self:ScrollToTop()\n      elseif IsControlKeyDown() then\n         self:PageUp()\n      else\n         self:ScrollUp()\n      end\n   else\n      if IsShiftKeyDown() then\n         self:ScrollToBottom()\n      elseif IsControlKeyDown() then\n         self:PageDown()\n      else\n         self:ScrollDown()\n      end\n   end\nend\n\nfor i=1,NUM_CHAT_WINDOWS do\n   local chatFrame = getobj('ChatFrame%d', i)\n   if chatFrame then\n      chatFrame:SetFading(false)\n      chatFrame:EnableMouseWheel(true)\n      chatFrame:SetMaxResize(0,0)\n      chatFrame:SetScript(\"OnMouseWheel\", onChatScroll)\n      for _,which in pairs{ 'Up', 'Down', 'Bottom' } do\n         local button = getobj('ChatFrame%d%sButton', i, which)\n         button:SetAlpha(0)\n         button:EnableMouse(false) \n      end\n   end\nend\n\nChatFrameMenuButton:Hide()\nChatFrameEditBox:ClearAllPoints()\nChatFrameEditBox:SetPoint('BOTTOMLEFT', ChatFrame1,'TOPLEFT',-5,-1)\nChatFrameEditBox:SetPoint('BOTTOMRIGHT', ChatFrame1,'BOTTOMRIGHT',5,-1)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "ui: move framerate text",
         data = "-- put framerate text in better position\n\nFramerateLabel:ClearAllPoints()\nFramerateLabel:SetPoint('TOP')\nFramerateLabel:SetTextColor(.5,.5,.5)\n\nFramerateText:ClearAllPoints()\nFramerateText:SetPoint('LEFT',FramerateLabel,'RIGHT')\n\n-- prevent it from being moved\nlocal nop = function() end\nFramerateLabel.SetPoint = nop\nFramerateText.SetPoint = nop",
         autorun = nil,
         colorize = true,
      },
      {
         name = "ui: art frames",
         data = "local f = CreateFrame('Frame', 'BottomBackPanel', UIParent)\nf:SetPoint('BOTTOM', 0,-10)\nf:SetPoint('LEFT',-10,0)\nf:SetPoint('RIGHT',10,0)\nf:SetHeight(167)\nf:SetFrameStrata('Background')\nf:SetBackdrop { \n   bgFile = 'Interface\\\\Addons\\\\Hack\\\\Media\\\\EditorTile',\n   edgeFile = 'Interface\\\\Addons\\\\Hack\\\\Media\\\\Border',\n   tile = true, tileSize = 128, edgeSize = 14, \n}",
         autorun = nil,
         colorize = true,
      },
      {
         name = "lib: core",
         data = "-- some handy functions to have around\n\nfunction printf(...)\n   print(format(...))\nend\n\n-- use a format pattern to access a global object\nfunction getobj(...)\n   return _G[ format(...)  ]\nend\n\n-- make a pattern case insensitive\nfunction caseInsensitivePattern(s)\n   return s:gsub('%a', function(c) return format('[%s%s]', c:lower(), c:upper()) end)\nend\n\nfunction MakeFrameDraggable(f)\n   f:EnableMouse(true)\n   f:SetMovable(true)\n   f:RegisterForDrag('LeftButton')\n   f:SetScript('OnDragStart', function() f:StartMoving() end)\n   f:SetScript('OnDragStop', function() \n         f:StopMovingOrSizing() \n         local p1, parent, p2, x, y = f:GetPoint()\n         printf('Moved to %s, %s, %d, %d', p1, p2, x, y)\n   end)\nend",
         autorun = true,
         colorize = true,
      },
      {
         name = "lib: timer",
         data = "--[[\n   timer SetTimer( interval, callback, [ recur, ... ] )\n      recur: if true, repeat every interval\n      ...: arguments to pass to the callback\n\n   KillTimer( timer)\n      timer: object returned by SetTimer\n\n   A recurring timer can be killed by returning 'true'\n   from it's callback, by setting recur=false in it's\n   timer object, or by calling KillTimer on it.\n]]\n\nif SetTimer then return end\n\nlocal timers = {}\n\nfunction SetTimer( interval, callback, recur, ...)\n   local timer = {\n      interval = interval,\n      callback = callback,\n      recur = recur,\n      update = 0,\n      ...\n   }\n   timers[timer] = timer\n   return timer\nend\n\nfunction KillTimer( timer )\n   timers[timer] = nil\nend\n\n-- How often to check timers. Lower values are more CPU intensive.\nlocal granularity = 0.1\n\nlocal totalElapsed = 0\nlocal function OnUpdate(self, elapsed)\n   totalElapsed = totalElapsed + elapsed\n   if totalElapsed > granularity then\n      for k,t in pairs(timers) do\n         t.update = t.update + totalElapsed\n         if t.update > t.interval then\n            local success, rv = pcall(t.callback, unpack(t))\n            if not rv and t.recur then\n               t.update = 0\n            else\n               timers[t] = nil\n               if not success then Hack.ScriptError('timer callback', rv) end\n            end\n         end\n      end\n      totalElapsed = 0\n   end\nend\nCreateFrame('Frame'):SetScript('OnUpdate', OnUpdate)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "lib: event",
         data = "--[[\nlistener AddEventListener    (event, callback [, userparam])\n         RemoveEventListener (event, listener)\n\nTo remove a listener, you can return true from your listener callback, OR\npass the value returned by AddEventListener to RemoveEventListener\n]]\n\n\n-- IMPLEMENTATON\n\nlocal registry = {}\nlocal frame = CreateFrame('Frame')\n\nlocal function UnregisterOrphanedEvent(event)\n   if not next(registry[event]) then\n      registry[event] = nil\n      frame:UnregisterEvent(event)\n   end\nend\n\nlocal function OnEvent(...)\n   local self, event = ...\n   for listener,val in pairs(registry[event]) do\n      local success, rv = pcall(listener[1], listener[2], select(2,...))\n      if rv then\n         registry[event][listener] = nil\n         if not success then Hack.ScriptError('event callback', rv) end\n      end\n   end        \n   UnregisterOrphanedEvent(event)\nend\n\nframe:SetScript('OnEvent', OnEvent)\n\n-- INTERFACE\n\nfunction AddEventListener (event, callback, userparam)\n   assert(callback, 'invalid callback')\n   if not registry[event] then\n      registry[event] = {}\n      frame:RegisterEvent(event)\n   end\n   local listener = { callback, userparam }\n   registry[event][listener] = true\n   return listener\nend\n\nfunction RemoveEventListener (event, listener)\n   registry[event][listener] = nil\n   UnregisterOrphanedEvent(event)\nend",
         autorun = nil,
         colorize = true,
      },
      {
         name = "lib: debug",
         data = "-- exports 'format_table' and 'print_table'\n\n-- Format a table for printing. Descends recursively, with nested tables\n-- properly indented, avoiding cyclic references.\nlocal function format_table_impl (table, out, indent, visited)\n   indent  = indent or 2     -- indentation level for current table\n   visited = visited or {}   -- visited tables, avoid infinite recursion\n   visited[table] = true     -- mark current table as visited\n   out[#out+1] = format('%s {\\n', tostring(table))\n   for k,v in pairs(table) do\n      out[#out+1] = format('%s%s = ', string.rep(' ',indent), tostring(k))\n      if type(v) == 'table' then\n         if visited[v] then\n            out[#out+1] = format('%s { already shown }\\n', tostring(v))\n         else\n            format_table_impl (v, out, indent+2, visited)\n         end\n      else\n         out[#out+1] = format('%s\\n', tostring(v))\n      end\n   end \n   out[#out+1] = format('%s},\\n', string.rep(' ', indent-2))\nend\n\nfunction format_table(t)\n   local out = {}\n   format_table_impl(t, out)\n   return table.concat(out)\nend\n\nfunction print_table(table)\n   DEFAULT_CHAT_FRAME:AddMessage(format_table(table))\nend",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev: clear chat",
         data = "DEFAULT_CHAT_FRAME:Clear()",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev: toggle UI zoom",
         data = "-- useful for getting art pixel-perfect without going blind\nzoom = not zoom\nif not savedUIScale then\n   savedUIScale = UIParent:GetScale()\nend\nUIParent:SetScale( zoom and 2*savedUIScale or savedUIScale)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev: increase chat frame height",
         data = "-- useful when using chat frame for debugging output\nChatFrame1:SetHeight(1000)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev: print errors to chat frame with stack trace",
         data = "Hack.Require 'lib: core'\n\nlocal function OnError(msg)\n   printf('%s\\n%s', msg, debugstack(2, 20, 20))\nend\n\nseterrorhandler(OnError)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev: frame finder",
         data = "--Handy development tool: shows info about the\n--object under the cursor. Rerun this script to \n-- toggle on/off.\n\nlocal a1, a2, x, y = 'TOP', 'TOP', 0, 0\n\nif FFind then\n   if FFind:IsVisible() then FFind:Hide()\n   else FFind:Show() end\n   return\nend\n\nlocal ff = CreateFrame('Frame', 'FFind')\nff:SetFrameStrata('TOOLTIP')\nff:SetWidth(100)\nff:SetHeight(100)\nff:SetPoint(a1, UIParent, a2, x, y)\nMakeFrameDraggable(ff)\n\nff.text = ff:CreateFontString()\nff.text:SetFont('Fonts\\\\FRIZQT__.TTF', 8)\nff.text:SetPoint('TOPLEFT', ff, 'TOPLEFT', 0, 0)\nff.text:SetJustifyH('LEFT') \nff.text:SetShadowOffset(-.4,-.4)\n\nlocal buf\nlocal function out(...) \n   for i=1,select('#',...) do\n      buf[ #buf+1 ] = select(i,...)\n   end\nend\nlocal function showFrame(f)\n   local name = f:GetName()\n   local strata = f.GetFrameStrata and f:GetFrameStrata()\n   local level  = f.GetFrameLevel and f:GetFrameLevel()\n   out('||cFFFFFFFF',name and name or '--',' ')\n   if strata then out('||cFFAAAAAA',tostring(strata)) end\n   if level then out('(', tostring(level),')') end\n   out('\\n')\nend\nlocal function showGroup(header, ...)\n   out( format('\\n||cFFFF8800%s||cFFFFFFFF', header), '\\n' )\n   for _, f in pairs{...} do \n      showFrame(f)\n   end\nend\nlocal function UpdateText(f)\n   if f then\n      buf = { '||cFFFF2200' }\n      showFrame(f)\n      local parent = f:GetParent()\n      showGroup(\"parent\", par)\n      showGroup(\"parent's parent\", parent and parent:GetParent())\n      showGroup(\"children\", f:GetChildren()) \n      showGroup(\"regions\",  f:GetRegions()) \n      ff.text:SetText(table.concat(buf))\n   else\n      ff.text:SetText('')\n   end\nend\n\nlocal currentframe\nlocal function OnUpdate()\n   local obj = GetMouseFocus()\n   if obj then\n      local name = obj:GetName()\n      if currentframe ~= name then\n         currentframe = name\n         UpdateText(obj)\n      end\n   end\nend\n\nff:SetScript('OnUpdate', OnUpdate)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev: toggle UI scale",
         data = "-- toggles zooming screen to double scale and back\n-- handy for fine tuning UI elements without going blind\nhackScale = hackScale or UIParent:GetScale()\nhackZoom = not hackZoom\nUIParent:SetScale(hackZoom and 2*hackScale or hackScale)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev: show Hack on startup",
         data = "-- enable this to show Hack every time the UI loads\nHackListFrame:Show()",
         autorun = false,
         colorize = 1,
      },
      {
         name = "dev example: arg processing, caller",
         data = "-- RUN ME!\n-- Examples of calling other Hack pages\n\n-- call a Hack by name:\nHack.Run('example: arg processing, callee')\n\n-- don't need the full name, as long as there are no conflicts\nHack.Run('callee')\n\n-- we can pass arguments:\nHack.Run('callee', 'donut', 'cookie', 'pie', 'cake')\n\n-- the called hack can return values:\nlocal x, y =Hack.Run('callee', 'one', 'two', 'three')\nprint( x, y )\n\n-- you can also grab a compiled version of a Hack,\n-- if you plan to call it multiple times\nlocal callee = Hack.Get('callee')\n\nx, y = callee('one', 'two', 'three')",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev example: arg processing, callee",
         data = "-- Processing arguments and return values.\n\n-- arguments (if any) are recieved via ...\nlocal args = {...}\nprintf('Got %d args.', #args)\nfor i,arg in ipairs(args) do\n   printf('  [%d] = %s', i, arg)\nend\n\n-- we can also return values to the caller\nreturn #args, table.concat(args, ',')",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev example: using event lib",
         data = "-- auto-accept part invites\n\nHack.Require 'lib: event'\n\nAddEventListener('PARTY_INVITE_REQUEST', \n   function()\n      AcceptGroup()\n      StaticPopup1:Hide()\n   end\n)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev example: using timer lib 1",
         data = "-- RUN ME!\n-- Simple examples of using the 'lib: timer' hack.\n\nfunction hello()\n   print( 'Hello, World!' )\nend\n\n-- call hello in 1 second\nSetTimer( 1, hello )\n\n-- another way to do the same thing is to call print\n-- directly, passing the string as an argument\nSetTimer( 2, print, false, 'Hello, World!' )\n\n-- you can have any number of args\nSetTimer( 3, print, false, 'Hello', 'World', '!' )",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev example: using timer lib 2",
         data = "-- RUN ME!\n-- This example shows how we can maintain timer state\n-- via a user parameter\n\nHack.Require 'lib: timer'\n\nlocal function countdown(state)\n   print( state.count )\n   state.count = state.count - 1\n   return state.count==0 -- abort recurring timer\nend\n\nSetTimer( .3, countdown, true, { count=10 } )",
         autorun = nil,
         colorize = true,
      },
      {
         name = "dev example: using timer lib 3",
         data = "-- RUN ME!\n-- This example shows how we can manipulate a timer object\n-- after it's been created.\n\nHack.Require 'lib: timer'\n\nlocal function print_uppercase(...)\n   print( table.concat({...}, ' '):upper() )\nend\n\n-- create a timer that calls 'print' every second\ntimer = SetTimer( .5, print, true, 'some', 'args', 'to', 'print' )\n\n-- change arguments passed to first timer in 3 seconds\nSetTimer( 3, function() table.insert(timer, 'more args!') end )\n\n-- change the callback of the first timer in 6 seconds\nSetTimer( 6, function() timer.callback = print_uppercase end )\n\n-- kill the first timer in 9 seconds\nSetTimer( 9, KillTimer, false, timer )",
         autorun = nil,
         colorize = true,
      },
      {
         name = "hack: add reload UI button to Hack window",
         data = "-- Example of Hacking Hack :)\n-- In this case, we're adding a reload button\n\nHack.tooltips.HackReloadUI = 'Reload UI'\n\nlocal button = CreateFrame('Button', 'HackReloadUI', HackListFrame, 'T_HackButton')\nbutton:SetPoint('LEFT', HackSend, 'RIGHT',0,1)\nbutton:SetScript('OnClick', ReloadUI)\n\nfunction addButtonTexture(which, l, r, t, b)\n   local txt = button:CreateTexture()\n   txt:SetAllPoints(button)\n   txt:SetTexture('Interface\\\\AddOns\\\\Hack\\\\Media\\\\Buttons')\n   txt:SetTexCoord(l, r, t, b)\n   which(button,  txt)\nend\n\naddButtonTexture(button.SetNormalTexture, .625, .75, 0, .125)\naddButtonTexture(button.SetPushedTexture, .75, .875, 0, .125)",
         autorun = nil,
         colorize = true,
      },
      {
         name = "hack: restore default font/layout",
         data = "HackDB.font = 2\nHackDB.fontsize = 11\nHackListFrame:SetUserPlaced(false)\nHackEditFrame:SetUserPlaced(false)\nReloadUI()",
         autorun = nil,
         colorize = true,
      },
      },
   },
}
