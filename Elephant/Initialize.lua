--[[
When addon is initialized. Registers database,
options, initializes the main frame, Elephant
button if required, enables/disables WoW chat
logging, and initializes other useful data.
]]
function Elephant:OnInitialize()
  -- Registering database with defaults: cloning objects to avoid problems
  Elephant.db = LibStub("AceDB-3.0"):New("ElephantDB", {
    profile = Elephant:clone(Elephant.defaultConf.savedconfdefaults)
  })
  Elephant.dbpc = LibStub("AceDB-3.0"):New("ElephantDBPerChar", {
    char = Elephant:clone(Elephant.defaultConf.savedpercharconfdefaults)
  })

  -- Options
  Elephant:SetupOptions()

  -- General frame
  Elephant:SetTitleInfoMaxLog()

  -- Elephant button
  if Elephant.db.profile.button == true then
    Elephant:CreateButton()
  end

  -- Enabling/disabling chat logging if required
  Elephant:ChatLogEnable(Elephant.db.profile.chatlog)
  Elephant:CombatLogEnable(Elephant.db.profile.combatlog)

  -- Checks & creates default log structures
  Elephant:InitDefaultLogStructures()
  Elephant:AddHeaderToStructures()

  -- Getting current loot method to avoid displaying too many times
  -- the same loot method in case of ReloadUI()
  -- Note: in case of login, a PARTY_LOOT_METHOD_CHANGED
  -- event is triggered anyway
  Elephant.tempConf.lootmethod = GetLootMethod()

  -- Minimap icon
  Elephant:RegisterLDBIcon()
end

--[[
When addon is enabled. Register events
and "displays" the current log (even if main
frame isn't shown).
]]
function Elephant:OnEnable()
  -- Registering events
  Elephant:RegisterEventsRefresh()
	Elephant:RegisterEvent('PLAYER_LOGOUT', Elephant.OnLogout, nil)

  -- Displays default log
  if not Elephant.dbpc.char.logs[Elephant.dbpc.char.currentlogindex] then
    Elephant.dbpc.char.currentlogindex = Elephant.defaultConf.defaultlogindex
  end
  Elephant.tempConf.currentline = #Elephant.dbpc.char.logs[Elephant.dbpc.char.currentlogindex].logs
  Elephant:ShowCurrentLog()
end

--[[
When addon is disabled. Unregister events
and log disable message.
]]
function Elephant:OnDisable()
  -- Unregister events
  Elephant:UnregisterAllEvents()
	Elephant:AddHeaderToStructures(true, true)
end

--[[
Handle PLAYER_LOGOUT event. (Unused alternative: PLAYER_LEAVING_WORLD)
Log stop message.
]]
function Elephant.OnLogout()
	Elephant:AddHeaderToStructures(true, true)
end

