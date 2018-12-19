


SLASH_MY_VIEWPORT1 = '/viewport'
SLASH_MY_VIEWPORT2 = '/vp'

SlashCmdList['MY_VIEWPORT']= function(msg, editbox)
  if  msg == ""  then
    WorldFrame:SetUserPlaced(false)
    return
  fi
  
  local lxs,tys,rxs,bys = string.match(msg, "(%d*),?%s*(%d*),?%s*(%d*),?%s*(%d*)")
  local lx = tonumber(lxs)
  local ty = tonumber(tys)
  local rx = tonumber(rxs)
  local by = tonumber(bys)
  if  lx or ty or rx or by  then
    WorldFrame:SetUserPlaced(true)
    WorldFrame:ClearAllPoints()
    if  lx or ty  then  WorldFrame:SetPoint('TOPLEFT',lx,ty)
    if  rx or by  then  WorldFrame:SetPoint('BOTTOMRIGHT',rx,by)
  end
end

