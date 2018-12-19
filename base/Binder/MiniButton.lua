--[[
    This handles the creation and configuration of the minimap/DataBroker button
--]]

local AddonName = ...
local LibDBIcon = LibStub('LibDBIcon-1.0')

local MiniButton = {}
Binder_Frame.MiniButton = MiniButton


function MiniButton:Init()
	local minimapButton = {
		type = "launcher",
		icon = "Interface\\MacroFrame\\MacroFrame-Icon",
		label = "Binder",
		OnClick = function(self, button)
			if button == 'LeftButton' then
				if IsShiftKeyDown() then
					Binder_KeyBound_OnClick()
					--[[ prefer RightButton instead for keybindings frame (equivalent of settings in this case)
				elseif IsControlKeyDown() then
					Binder_Frame:KeyBindingFrame_OnClick()
					--]]
				else
					Binder_Toggle()
				end
			elseif button == 'RightButton' then
				Binder_KeyBindingFrame_OnClick()
			end
		end,
		OnTooltipShow = function(tooltip)
			if  not tooltip  or  not tooltip.AddLine  then  return  end
			tooltip:AddLine("Binder")
			tooltip:AddLine("Left Click: open Profiles frame")
			tooltip:AddLine("Shift-Left Click: modify Acionbar keybindings")
			tooltip:AddLine("Right Click: open Keybindings frame")
			--tooltip:AddLine("Hold Left Button: Move")
		end,
	}

	self.dataObject = LibStub("LibDataBroker-1.1"):NewDataObject(AddonName, minimapButton)
end

function MiniButton:OnLoad()
	BinderSettingsDB = BinderSettingsDB  or  {}
	if  not BinderSettingsDB.minimap  then
		BinderSettingsDB.minimap = BinderMinimapSettings  and  {
			minimapPos = BinderMinimapSettings.degree,
			hide = not BinderMinimapSettings.ShowMinimapButton,
		}  or  {}
		BinderMinimapSettings= nil
	end
	
	LibDBIcon:Register(AddonName, self.dataObject, BinderSettingsDB.minimap)
end

function MiniButton:Update(newSettings)
	if  newSettings  then  for  k,v  in  pairs(newSettings)  do
		BinderSettingsDB.minimap[k]= v
	end end
	LibDBIcon:Refresh(AddonName)
end




MiniButton:Init()

