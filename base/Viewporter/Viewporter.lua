Viewporter = CreateFrame("Frame")
local _ = _
local self = Viewporter
SLASH_VIEWPORTER1, SLASH_VIEWPORTER2, SLASH_VIEWPORTER3 = "/vp", "/viewporter", "/viewport";

--viewport setting code stolen from Electroflux Textronator
function self:setViewport()
  if not self.db.enabled then return end
  local scale = 768 / UIParent:GetHeight()

  WorldFrame:SetPoint("TOPLEFT", ( self.db.left * scale ), -( self.db.top * scale ) )
  WorldFrame:SetPoint("BOTTOMRIGHT", -( self.db.right * scale ), ( self.db.bottom * scale ) )
end

function self:onLoad( event, name )
  self.db = ViewporterDB or {
    enabled = true,
    top    = 0,
    bottom = 0,
    left   = 0,
    right  = 0,
    firsttime = true
  }
  ViewporterDB = self.db

  --minor database upgrade for those who were using an older version
  if not self.db.left then self.db.left = 0 end
  if not self.db.right then self.db.right = 0 end

  if self.db.firsttime then
    print("Viewporter by sztanpet loaded. /vp for help")
    self.db.firsttime = false
  end

  self:setViewport()
end

function self.onChatCommand( msg )
  local _, _, command, value = string.find( msg, "^(%S*)%s*(.-)$")

  if command == "enable" then
    self.db.enabled = true
  elseif command == "disable" then
    self.db.enabled = false
  elseif command == "reset" then
    self.db.top    = 0
    self.db.bottom = 0
    self.db.left   = 0
    self.db.right  = 0
  elseif ( command == "top" or command == "bottom" or 
           command == "left" or command == "right" 
         ) and tonumber( value ) then
    self.db[ command ] = value
  else
    return print("Viewporter: invalid or empty command, try enable/disable/reset or top/bottom/left/right with a number argument, for example /vp top 10")
  end

  self:setViewport()
end

SlashCmdList["VIEWPORTER"] = self.onChatCommand;
self:SetScript("OnEvent", self.onLoad )
self:RegisterEvent("ADDON_LOADED")
