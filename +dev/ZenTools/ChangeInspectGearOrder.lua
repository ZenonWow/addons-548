local OldToNewOrder = {
	--[[
	HeadSlot      = "HeadSlot"    ,
	--]]
	NeckSlot      = "ShoulderSlot",
	ShoulderSlot  = "ChestSlot"   ,
	BackSlot      = "WristSlot"   ,
	ChestSlot     = "HandsSlot"   ,
	ShirtSlot     = "WaistSlot"   ,
	TabardSlot    = "LegsSlot"    ,
	WristSlot     = "FeetSlot"    ,

	HandsSlot     = "BackSlot"    ,
	WaistSlot     = "ShirtSlot"   ,
	LegsSlot      = "TabardSlot"  ,
	FeetSlot      = "NeckSlot"    ,
	--[[
	Finger0Slot   = "Finger0Slot" ,
	Finger1Slot   = "Finger1Slot" ,
	Trinket0Slot  = "Trinket0Slot",
	Trinket1Slot  = "Trinket1Slot",
	--]]
}
local OriginalNames = {}
PaperDollFrame.OriginalNames = OriginalNames

local function GetNewName(button)  return button.newName  end

-- Reorder gear item icons on PaperDollFrame
-- framePrefix = 'Character' or 'Inspect'
local function ChangeGearOrder(framePrefix)
	local buttonOnLoad = framePrefix == 'Character' and _G.PaperDollItemSlotButton_OnLoad
		or 'Inspect' and _G.InspectPaperDollItemSlotButton_OnLoad
	
	assert(buttonOnLoad, "ChangeGearOrder: framePrefix must be 'Character' or 'Inspect'")
	
	for  oldSlot, newSlot  in pairs(OldToNewOrder) do
		local oldName = framePrefix..oldSlot
		OriginalNames[oldName] = _G[oldName]
		OriginalNames[oldName..'IconTexture'] = _G[oldName..'IconTexture']
		OriginalNames[oldName..'Cooldown'] = _G[oldName..'Cooldown']
	end
	for  oldSlot, newSlot  in pairs(OldToNewOrder) do
		local oldName, newName = framePrefix..oldSlot, framePrefix..newSlot
		_G[newName] = OriginalNames[oldName]
		_G[newName..'IconTexture'] = OriginalNames[oldName..'IconTexture']
		_G[newName..'Cooldown'] = OriginalNames[oldName..'Cooldown']
		local button = _G[oldName]
		--button:SetName(newName)
		button.newName = newName
		button.GetName_ = button.GetName
		button.GetName = GetNewName
		buttonOnLoad(button)
		--button.GetName = button.GetName_
	end
end



local function ChangeCharacterGearOrder1()
	--[[
	CharacterHeadSlot      :SetID( GetInventorySlotInfo( "HeadSlot"     ) )
	--]]
	CharacterNeckSlot      :SetID( GetInventorySlotInfo( "ShoulderSlot" ) )
	CharacterShoulderSlot  :SetID( GetInventorySlotInfo( "ChestSlot"    ) )
	CharacterBackSlot      :SetID( GetInventorySlotInfo( "WristSlot"    ) )
	CharacterChestSlot     :SetID( GetInventorySlotInfo( "HandsSlot"    ) )
	CharacterShirtSlot     :SetID( GetInventorySlotInfo( "WaistSlot"    ) )
	CharacterTabardSlot    :SetID( GetInventorySlotInfo( "LegsSlot"     ) )
	CharacterWristSlot     :SetID( GetInventorySlotInfo( "FeetSlot"     ) )

	CharacterHandsSlot     :SetID( GetInventorySlotInfo( "BackSlot"     ) )
	CharacterWaistSlot     :SetID( GetInventorySlotInfo( "ShirtSlot"    ) )
	CharacterLegsSlot      :SetID( GetInventorySlotInfo( "TabardSlot"   ) )
	CharacterFeetSlot      :SetID( GetInventorySlotInfo( "NeckSlot"     ) )
	--[[
	CharacterFinger0Slot   :SetID( GetInventorySlotInfo( "Finger0Slot"  ) )
	CharacterFinger1Slot   :SetID( GetInventorySlotInfo( "Finger1Slot"  ) )
	CharacterTrinket0Slot  :SetID( GetInventorySlotInfo( "Trinket0Slot" ) )
	CharacterTrinket1Slot  :SetID( GetInventorySlotInfo( "Trinket1Slot" ) )
	--]]
end

local function ChangeCharacterGearOrder2()
	local NewToOldOrder = {
		CharacterShoulderSlot = _G.CharacterNeckSlot    ,
		CharacterChestSlot    = _G.CharacterShoulderSlot,
		CharacterWristSlot    = _G.CharacterBackSlot    ,
		CharacterHandsSlot    = _G.CharacterChestSlot   ,
		CharacterWaistSlot    = _G.CharacterShirtSlot   ,
		CharacterLegsSlot     = _G.CharacterTabardSlot  ,
		CharacterFeetSlot     = _G.CharacterWristSlot   ,
		
		CharacterBackSlot     = _G.CharacterHandsSlot   ,
		CharacterShirtSlot    = _G.CharacterWaistSlot   ,
		CharacterTabardSlot   = _G.CharacterLegsSlot    ,
		CharacterNeckSlot     = _G.CharacterFeetSlot    ,
	}
	for k,v in pairs(NewToOldOrder) do  _G[k] = v  end
end

local function ChangeCharacterGearOrder3()
	-- Chained and sorted reordering with only one carry
	local CharacterFeetSlot  = _G.CharacterFeetSlot
	_G.CharacterFeetSlot     = _G.CharacterWristSlot   
	_G.CharacterWristSlot    = _G.CharacterBackSlot    
	_G.CharacterBackSlot     = _G.CharacterHandsSlot   
	_G.CharacterHandsSlot    = _G.CharacterChestSlot   
	_G.CharacterChestSlot    = _G.CharacterShoulderSlot
	_G.CharacterShoulderSlot = _G.CharacterNeckSlot    
	_G.CharacterNeckSlot     = CharacterFeetSlot    
	
	_G.CharacterWaistSlot, _G.CharacterShirtSlot     = _G.CharacterShirtSlot,  _G.CharacterWaistSlot   
	_G.CharacterLegsSlot,  _G.CharacterTabardSlot    = _G.CharacterTabardSlot, _G.CharacterLegsSlot    
end






ChangeGearOrder('Character')

local function ChangeInspectGearOrder()
	if  not ChangeInspectGearOrder  then  return  end
	ChangeGearOrder('Inspect')
	ChangeGearOrder = nil
	ChangeInspectGearOrder = nil
end

if  IsAddOnLoaded('Blizzard_InspectUI')  then
	-- Delayed load after Blizzard_InspectUI
	ChangeInspectGearOrder()
else
	hooksecurefunc('InspectFrame_LoadUI', ChangeInspectGearOrder)
end

