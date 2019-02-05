
-- Reorder gear item icons on Blizzard_InspectUI
local function ChangeInspectGearOrder()
	InspectHeadSlot      :SetID( GetInventorySlotInfo( "HeadSlot"     ) )
	InspectNeckSlot      :SetID( GetInventorySlotInfo( "ShoulderSlot" ) )
	InspectShoulderSlot  :SetID( GetInventorySlotInfo( "ChestSlot"    ) )
	InspectBackSlot      :SetID( GetInventorySlotInfo( "WristSlot"    ) )
	InspectChestSlot     :SetID( GetInventorySlotInfo( "HandsSlot"    ) )
	InspectShirtSlot     :SetID( GetInventorySlotInfo( "WaistSlot"    ) )
	InspectTabardSlot    :SetID( GetInventorySlotInfo( "LegsSlot"     ) )
	InspectWristSlot     :SetID( GetInventorySlotInfo( "FeetSlot"     ) )

	InspectHandsSlot     :SetID( GetInventorySlotInfo( "BackSlot"     ) )
	InspectWaistSlot     :SetID( GetInventorySlotInfo( "ShirtSlot"    ) )
	InspectLegsSlot      :SetID( GetInventorySlotInfo( "TabardSlot"   ) )
	InspectFeetSlot      :SetID( GetInventorySlotInfo( "NeckSlot"     ) )
	InspectFinger0Slot   :SetID( GetInventorySlotInfo( "Finger0Slot"  ) )
	InspectFinger1Slot   :SetID( GetInventorySlotInfo( "Finger1Slot"  ) )
	InspectTrinket0Slot  :SetID( GetInventorySlotInfo( "Trinket0Slot" ) )
	InspectTrinket1Slot  :SetID( GetInventorySlotInfo( "Trinket1Slot" ) )
end

if  IsAddOnLoaded('Blizzard_InspectUI')  then
	-- Delayed load after Blizzard_InspectUI
	ChangeInspectGearOrder()
else
	-- Register callback for loading Blizzard_InspectUI
	local eventFrame = CreateFrame('Frame', nil, UIParent)
	eventFrame:RegisterEvent('ADDON_LOADED')
	eventFrame:SetScript('OnEvent', function (self, event, addonName)
		if  addonName ~= 'Blizzard_InspectUI'  then  return  end
		eventFrame:SetScript('OnEvent', nil)
		eventFrame:UnregisterEvent('ADDON_LOADED')
		ChangeInspectGearOrder()
	end)
end

