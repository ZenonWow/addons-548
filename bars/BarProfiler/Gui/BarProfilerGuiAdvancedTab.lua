BPFunc.GUI.AdvTab = {
-------------------------------------------------------------------------------------------------------------------------------------------
	Layout = function()
		BPGUI.AdvTab = {}
		local GUI = BPGUI.AdvTab
		local Func = BPFunc.GUI.AdvTab
		local Var = BPTemp.Adv	
		
		BPGUI.Main.TabGroup:SetLayout("Flow")
		
		GUI.RealmDrop = BarProfilerGui:Create("Dropdown")
			GUI.RealmDrop:SetLabel("Realm:")
			GUI.RealmDrop:SetCallback("OnValueChanged", function(widget, event, key) Func.RealmDropHandler(key) end)
			BPGUI.Main.TabGroup:AddChild(GUI.RealmDrop)
			
		GUI.CharacterDrop = BarProfilerGui:Create("Dropdown")
			GUI.CharacterDrop:SetLabel("Character:")
			GUI.CharacterDrop:SetCallback("OnValueChanged", function(widget, event, key) Func.CharacterDropHandler(key) end)
			BPGUI.Main.TabGroup:AddChild(GUI.CharacterDrop)
			
		GUI.ProfileDrop = BarProfilerGui:Create("Dropdown")
			GUI.ProfileDrop:SetLabel("Profile:")
			GUI.ProfileDrop:SetCallback("OnValueChanged", function(widget, event, key) Func.ProfileDropHandler(key) end)
			BPGUI.Main.TabGroup:AddChild(GUI.ProfileDrop)
			
		GUI.IgnoreAllButton = BarProfilerGui:Create("Button")	
			GUI.IgnoreAllButton:SetText("Ignore All")
			GUI.IgnoreAllButton:SetCallback("OnClick", 	function(widget) Func.IgnoreButtonHandler(true) end)
			BPGUI.Main.TabGroup:AddChild(GUI.IgnoreAllButton)
		
		GUI.IgnoreNoneButton = BarProfilerGui:Create("Button")	
			GUI.IgnoreNoneButton:SetText("Ignore None")
			GUI.IgnoreNoneButton:SetCallback("OnClick", 	function(widget) Func.IgnoreButtonHandler(false) end)
			BPGUI.Main.TabGroup:AddChild(GUI.IgnoreNoneButton)
			
		GUI.ImportBox = BarProfilerGui:Create("EditBox")
			GUI.ImportBox:SetLabel("Copy Profile")
			GUI.ImportBox:SetCallback("OnEnterPressed", function(widget, event, key) Func.ImportBoxHandler(key) end)
			BPGUI.Main.TabGroup:AddChild(GUI.ImportBox)
		
		GUI.PreviewFrame = BarProfilerGui:Create("InlineGroup")
			GUI.PreviewFrame:SetFullHeight(true)
			GUI.PreviewFrame:SetFullWidth(true)
			GUI.PreviewFrame:SetLayout("Fill")
			BPGUI.Main.TabGroup:AddChild(GUI.PreviewFrame)
			
		GUI.PreviewFrameScroll = BarProfilerGui:Create("ScrollFrame")
			GUI.PreviewFrameScroll:SetLayout("Flow")
			GUI.PreviewFrame:AddChild(GUI.PreviewFrameScroll)
				
		if Var.SelectedRealm == nil then
			Var.SelectedRealm = BPTemp.CurrentRealm
			Var.SelectedCharacter = BPTemp.CurrentCharacter
			Var.SelectedRealmKey = BPFunc.General.FindKey(BarProfilerDb.RealmList, Var.SelectedRealm)
			Var.SelectedCharacterKey = BPFunc.General.FindKey(BarProfilerDb.Realms[Var.SelectedRealm].CharacterList, Var.SelectedCharacter)
		end
		
		GUI.RealmDrop:SetList(BarProfilerDb.RealmList)
		GUI.RealmDrop:SetValue(Var.SelectedRealmKey)
		Func.RealmDropHandler(Var.SelectedRealmKey)
		GUI.CharacterDrop:SetValue(Var.SelectedCharacterKey)
		Func.CharacterDropHandler(Var.SelectedCharacterKey)
		
		if Var.SelectedProfile ~= nil then
			GUI.ProfileDrop:SetValue(Var.SelectedProfileKey)
			Func.ProfileDropHandler(Var.SelectedProfileKey)
		end	
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	RealmDropHandler = function(key)
		local GUI = BPGUI.AdvTab
		local Var = BPTemp.Adv
		local Func = BPFunc.GUI.AdvTab
		GUI.PreviewFrameScroll:ReleaseChildren()
		
		if key ~= Var.SelectedRealmKey then
			Var.SelectedRealmKey = key
			Var.SelectedRealm = BarProfilerDb.RealmList[key]
			Var.SelectedCharacterKey = nil
			Var.SelectedCharacter = nil
			Var.SelectedProfileKey = nil
			Var.SelectedProfile = nil
		end
		
		GUI.CharacterDrop:SetList(BarProfilerDb.Realms[Var.SelectedRealm].CharacterList)
		GUI.CharacterDrop:SetValue(0)
		GUI.ProfileDrop:SetValue(0)
		
		for Key, Value in pairs(BarProfilerDb.Realms[Var.SelectedRealm].CharacterList) do
			local PointVersion = BarProfilerDb.Realms[Var.SelectedRealm].Characters[Value].Version
			if PointVersion == nil or PointVersion == "0.1.2" then
				BPGUI.AdvTab.CharacterDrop:SetItemDisabled(Key, true)
			end
		end
		
		GUI.ProfileDrop:SetDisabled(1)
		GUI.IgnoreAllButton:SetDisabled(1)
		GUI.IgnoreNoneButton:SetDisabled(1)
		GUI.ImportBox:SetDisabled(1)

	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	CharacterDropHandler = function(key)
		local GUI = BPGUI.AdvTab
		local Var = BPTemp.Adv
		local Func = BPFunc.GUI.AdvTab
		
		GUI.PreviewFrameScroll:ReleaseChildren()

		if key ~= Var.SelectedCharacterKey then
			Var.SelectedCharacterKey = key
			Var.SelectedCharacter = BarProfilerDb.Realms[Var.SelectedRealm].CharacterList[key]
			Var.SelectedProfileKey = nil
			Var.SelectedProfile = nil
		end
		
		if next(BarProfilerDb.Realms[Var.SelectedRealm].Characters[Var.SelectedCharacter].ProfileList) ~= nil then
			GUI.ProfileDrop:SetDisabled()
			GUI.ProfileDrop:SetList(BarProfilerDb.Realms[Var.SelectedRealm].Characters[Var.SelectedCharacter].ProfileList)
		end
		
		GUI.IgnoreAllButton:SetDisabled(1)
		GUI.IgnoreNoneButton:SetDisabled(1)
		GUI.ImportBox:SetDisabled(1)
		
		GUI.ProfileDrop:SetValue(0)
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	ProfileDropHandler = function(key)
		local GUI = BPGUI.AdvTab
		local Var = BPTemp.Adv
		local Func = BPFunc.GUI.AdvTab
		GUI.PreviewFrameScroll:ReleaseChildren()
		Var.SelectedProfileKey = key
		Var.SelectedProfile = BarProfilerDb.Realms[Var.SelectedRealm].Characters[Var.SelectedCharacter].ProfileList[key]
		
		if BPTemp.CurrentCharacter ~= Var.SelectedCharacter then
			GUI.IgnoreAllButton:SetDisabled(1)
			GUI.IgnoreNoneButton:SetDisabled(1)
		else
			GUI.IgnoreAllButton:SetDisabled()
			GUI.IgnoreNoneButton:SetDisabled()
		end
		
	--	if BarProfilerDb.Realms[Var.SelectedRealm].Characters[Var.SelectedCharacter].Class ~= BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Class then
	--		GUI.ImportBox:SetDisabled(1)
	--	else
			GUI.ImportBox:SetDisabled()
	--	end
		
		Func.SlotDisplay()
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	SlotDisplay = function()
		local Func = BPFunc.GUI.AdvTab
		local GUI = BPGUI.AdvTab
		local Var = BPTemp.Adv
		local SlotLoop
		GUI.Slot = {}
		for SlotLoop = 1, 120 do
			local Slot = BarProfilerDb.Realms[Var.SelectedRealm].Characters[Var.SelectedCharacter].Profiles[Var.SelectedProfile][SlotLoop]
			if math.modf(((SlotLoop - 1) / 12) + 1) ~= math.modf(((SlotLoop - 2) / 12) + 1) then
				GUI.SlotLabel = BarProfilerGui:Create("Label")
					GUI.SlotLabel:SetText(math.modf(((SlotLoop - 1) / 12) + 1))
					GUI.SlotLabel:SetWidth(20)
					GUI.SlotLabel:SetFont ("Fonts\\FRIZQT__.TTF", 15)
					GUI.PreviewFrameScroll:AddChild(GUI.SlotLabel)
			end
			GUI.Slot[SlotLoop] = BarProfilerGui:Create("Icon")
				GUI.Slot[SlotLoop]:SetHeight(50)
				GUI.Slot[SlotLoop]:SetWidth(50)
				GUI.Slot[SlotLoop]:SetImageSize(50, 50)
				GUI.Slot[SlotLoop]:SetImage(Slot.Texture)
				--todo: unnecasary variables being sent
				GUI.Slot[SlotLoop]:SetCallback("OnEnter", function(Widget) Func.GUISlotOnEnter(Widget) end)
				GUI.Slot[SlotLoop]:SetCallback("OnLeave", function(Widget) Func.GUISlotOnLeave(Widget) end)
				GUI.Slot[SlotLoop]:SetCallback("OnClick", function(Widget) Func.GUISlotOnClick(Widget) end)
				if Slot.Ignore == true then
					GUI.Slot[SlotLoop].image:SetVertexColor(0.2, 0.2, 0.2)
				end
				GUI.PreviewFrameScroll:AddChild(GUI.Slot[SlotLoop])
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	IgnoreButtonHandler = function(Ignore)
		local Func = BPFunc.GUI.AdvTab
		local SlotLoop
		for SlotLoop = 1, 120 do
			Func.IgnoreToggle(SlotLoop, Ignore)
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	ImportBoxHandler = function(key)
		local Var = BPTemp.Adv
		local GUI = BPGUI.AdvTab
		local Func = BPFunc.GUI.AdvTab
		local Old = BarProfilerDb.Realms[Var.SelectedRealm].Characters[Var.SelectedCharacter].Profiles[Var.SelectedProfile]
		
		local New = BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Profiles[key]
		
		BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Imports = {
			Data = {},
			Backup = {}
		}
		
		local Import = BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Imports.Data
		
		for CreateSlotsLoop = 1, 120 do
			BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Imports.Data[CreateSlotsLoop] = {}
			BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Imports.Backup[CreateSlotsLoop] = {}
		end
		
		BPFunc.Bars.Save("Imports", "Backup")
		
		Import.DataCheck = 1
		for SlotLoop = 1, 120 do
				Import[SlotLoop] = Old[SlotLoop]
		end
		
		BPFunc.Bars.Load("Imports", "Data")
		
		BPFunc.Profiles.Create(key)
		BPFunc.Bars.Save("Profiles", key)
		BPFunc.Bars.Load("Imports", "Backup")
		
		BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].Imports = nil
		
		GUI.ImportBox:SetText()

		Var.SelectedRealm = BPTemp.CurrentRealm
		Var.SelectedCharacter = BPTemp.CurrentCharacter
		Var.SelectedProfile = key
		
		Var.SelectedRealmKey = BPFunc.General.FindKey(BarProfilerDb.RealmList, Var.SelectedRealm)
		Var.SelectedCharacterKey = BPFunc.General.FindKey(BarProfilerDb.Realms[Var.SelectedRealm].CharacterList, Var.SelectedCharacter)
		Var.SelectedProfileKey = BPFunc.General.FindKey(BarProfilerDb.Realms[Var.SelectedRealm].Characters[Var.SelectedCharacter].ProfileList, Var.SelectedProfile)
		
		GUI.RealmDrop:SetValue(Var.SelectedRealmKey)
		Func.RealmDropHandler(Var.SelectedRealmKey)
		GUI.CharacterDrop:SetValue(Var.SelectedCharacterKey)
		Func.CharacterDropHandler(Var.SelectedCharacterKey)
		GUI.ProfileDrop:SetValue(Var.SelectedProfileKey)
		Func.ProfileDropHandler(Var.SelectedProfileKey)
		
		BarProfiler:Print ("Profile Copy Successful")

	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	IgnoreToggle = function(Key, Ignore)
		local GUI = BPGUI.AdvTab
		local Var = BPTemp.Adv
		local Func = BPFunc.GUI.AdvTab
		local Slot = BarProfilerDb.Realms[Var.SelectedRealm].Characters[Var.SelectedCharacter].Profiles[Var.SelectedProfile][Key]
		if Ignore == nil then
			if Slot.Ignore == true then
				Slot.Ignore = nil
				GUI.Slot[Key].image:SetVertexColor(1, 1, 1)
			else
				Slot.Ignore = true
				GUI.Slot[Key].image:SetVertexColor(0.2, 0.2, 0.2)
			end
		elseif Ignore == true then
			Slot.Ignore = true
			GUI.Slot[Key].image:SetVertexColor(0.2, 0.2, 0.2)
		elseif Ignore == false then
			Slot.Ignore = nil
			GUI.Slot[Key].image:SetVertexColor(1, 1, 1)
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	GUISlotOnEnter = function(Widget)
		local GUI = BPGUI.AdvTab
		local Var = BPTemp.Adv
		local Key = BPFunc.General.FindKey(GUI.Slot, Widget)
		if Var.SelectedProfile ~= nil then
			me =  BarProfilerDb.Realms[Var.SelectedRealm].Characters[Var.SelectedCharacter].Profiles[Var.SelectedProfile][Key]
			GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			if me.Type == "spell" then
				GameTooltip:SetSpellByID(me.GlobalID)
			elseif me.Type == "item" then
				GameTooltip:SetItemByID(me.GlobalID)
			elseif me.Type == "macro" then
				GameTooltip:AddLine(me.Name, 1, 1, 1)
				GameTooltip:AddLine("Macro")
			elseif me.Type == "equipmentset" then
				GameTooltip:AddLine(me.GlobalID, 1, 1, 1)
				GameTooltip:AddLine("Equipment Set")
			elseif me.Type == "companion" then
				GameTooltip:AddLine(me.Name, 1, 1, 1)
				if me.SubType == "CRITTER" then
					GameTooltip:AddLine("Pet")
				elseif me.SubType == "MOUNT" then
					GameTooltip:AddLine("Mount")
				end
			elseif me.Type == "flyout" then
				local Name = GetFlyoutInfo (me.GlobalID)	--Should be saved, do it next time char db is updated
				GameTooltip:AddLine(Name, 1, 1, 1)
				GameTooltip:AddLine("Flyout")
			end
			GameTooltip:Show()
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	GUISlotOnLeave = function(Widget)
		local GUI = BPGUI.AdvTab
		local Var = BPTemp.Adv
		local Func = BPFunc.GUI.AdvTab
		local Key = BPFunc.General.FindKey(GUI.Slot, Widget)
		if BPTemp.CurrentCharacter == Var.SelectedCharacter then --todo: some form of message sayign it MUST be the right mouse button
			if IsMouseButtonDown(2) == 1 and GetCursorInfo() == nil then	--mousebutton can be handled with key?
				me = BarProfilerDb.Realms[Var.SelectedRealm].Characters[Var.SelectedCharacter].Profiles[Var.SelectedProfile][Key]
				BPFunc.Bars.PickUpAction(Key, me.Type, me.GlobalID, me.SubType, me.Name, me.Body)
				me.GlobalID = nil
				me.Type = nil
				me.SubType = nil
				me.Texture = "Interface\\BUTTONS\\UI-EmptySlot-Disabled"
				me.Name = nil
				GUI.Slot[Key]:SetImage("Interface\\BUTTONS\\UI-EmptySlot-Disabled")
			end
			if IsMouseButtonDown(1) == 1 and GetCursorInfo() == nil then
				Func.IgnoreToggle(Key)
			end
		end
		GameTooltip:Hide()
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	GUISlotOnClick=function(Widget)
		local GUI = BPGUI.AdvTab
		local Var = BPTemp.Adv
		local Func = BPFunc.GUI.AdvTab
		local Key = BPFunc.General.FindKey(GUI.Slot, Widget)
		local Type, GlobalID, SubType, Name, BType, BGlobalID, BSubType, BName
		if BPTemp.CurrentCharacter == Var.SelectedCharacter then
			if GetCursorInfo() == nil then
				Func.IgnoreToggle(Key)
			else
			me = BarProfilerDb.Realms[Var.SelectedRealm].Characters[Var.SelectedCharacter].Profiles[Var.SelectedProfile][Key]
			--Backup existing data from barprofiler slot
			Type = me.Type
			GlobalID = me.GlobalID
			SubType = me.SubType
			Texture = me.Texture
			Name = me.Name
			--Backup action in slot 1
			BType, BGlobalID, BSubType, BTexture, BName, BBody = BPFunc.Bars.GetAction(1)	--Bname probabnly not wanted
			--Place new action in slot 1
			PlaceAction(1)
			--Save new action in slot 1
			me.Type, me.GlobalID, me.SubType, me.Texture, me.Name, me.Body = BPFunc.Bars.GetAction(1)
			GUI.Slot[Key]:SetImage(me.Texture)
			ClearCursor()
			--Get old action that was orig in slot 1
			BPFunc.Bars.PickUpAction(1, BType, BGlobalID, BSubType, BName, BBody)
			--place action in slot 1
			BPFunc.Bars.PlaceAction(1)
			--pickup existing action from barprofiler slot
			BPFunc.Bars.PickUpAction(1, Type, GlobalID, SubType, Name, Body)
			end
		end
	end
-------------------------------------------------------------------------------------------------------------------------------------------
}