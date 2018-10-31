
BindingOverrideFrame= CreateFrame("Frame", nil, nil)

-- Override all bindings for  originalCommand with bindings to  overrideCommand
-- overrideCommand == ''  to disable  originalCommand
-- overrideCommand == nil  to remove previous bindings
-- registers for UPDATE_BINDINGS and refreshes overrides if the original bindings change

function  BindingOverrideFrame:SetCommandOverride(originalCommand, overrideCommand)
  self.OverrideCommands= self.OverrideCommands or {}
  self.OverrideCommands[originalCommand]= overrideCommand
  self:RefreshBindings(originalCommand, overrideCommand)
  self:UpdateBindingsRegistration()
end

function  BindingOverrideFrame:ClearBindings()
  ClearOverrideBindings(self)
  self.OverrideCommands= nil
  self.CommandKeys= nil
end


function  BindingOverrideFrame:RefreshBindings(originalCommand, overrideCommand, keys)
  self.CommandKeys= self.CommandKeys  or  {}
  local prevKeys= self.CommandKeys[originalCommand]  or  {}
  keys= keys or { GetBindingKey(originalCommand) }
  
  -- clear previous bindings
  for  i,key  in  ipairs(prevKeys)  do
    SetOverrideBinding(self, false, key, nil)
  end
  
  -- return if no new binding
  if  overrideCommand == nil  then
    self.CommandKeys[originalCommand]= nil
    return
  end
  
  -- set new bindings
  self.CommandKeys[originalCommand]= keys
  for  i,key  in  ipairs(keys)  do 
    SetOverrideBinding(self, false, key, overrideCommand)
  end
end


function  BindingOverrideFrame:UpdateBindingsRegistration()
  local register=  self.OverrideCommands  and  next(self.OverrideCommands) == nil
  if  self.RegisteredForEvents == register  then  return  end
  self.RegisteredForEvents= register
  
  if  register  then  self:RegisterEvent('UPDATE_BINDINGS')
  else  self:UnregisterEvent('UPDATE_BINDINGS')
  end
end

function  BindingOverrideFrame:OnEvent(self, event)
  if  event ~= 'UPDATE_BINDINGS'  then  return  end
  for  originalCommand, prevKeys  in  pairs(self.CommandKeys)  do
    local keys= { GetBindingKey(originalCommand) }
    if  keys ~= prevKeys  then
      DEFAULT_CHAT_FRAME:AddMessage('Updating command override bindings for  ' .. originalCommand .. '  from  ' .. prevKeys .. '  to  ' .. keys)
      self:RefreshBindings(originalCommand, self.OverrideCommands[originalCommand], keys)
    end
  end
end


