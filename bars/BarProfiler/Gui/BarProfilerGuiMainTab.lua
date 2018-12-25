BPFunc.GUI.MainTab = {
-------------------------------------------------------------------------------------------------------------------------------------------
	Layout = function()
		BPGUI.MainTab = {}
		local GUI = BPGUI.MainTab
		local Var = BPTemp.Main
		local Func = BPFunc.GUI.MainTab
			
		GUI.ListFrame = BarProfilerGui:Create("InlineGroup")
			GUI.ListFrame:SetWidth(230)
			GUI.ListFrame:SetLayout("List")
			GUI.ListFrame:SetAutoAdjustHeight(false)
			GUI.ListFrame:SetHeight(280)
			BPGUI.Main.TabGroup:AddChild(GUI.ListFrame)
			
		GUI.NewProfile = BarProfilerGui:Create("EditBox")
			GUI.NewProfile:SetLabel("Enter a name to create a new Profile:")
			GUI.NewProfile:SetCallback("OnEnterPressed", 	function(widget, event, ProfileName) Func.NewProfileHandler(ProfileName) end)
			GUI.ListFrame:AddChild(GUI.NewProfile)
			
		GUI.ProfileList = BarProfilerGui:Create("InlineGroup")
			GUI.ProfileList:SetWidth(210)
			GUI.ProfileList:SetHeight(200)
			GUI.ProfileList:SetAutoAdjustHeight(false)
			GUI.ProfileList:SetLayout("Fill")
			GUI.ListFrame:AddChild(GUI.ProfileList)
			
		GUI.ListBox = BarProfilerGui:Create("ScrollFrame")
			GUI.ListBox:SetAutoAdjustHeight(false)
			GUI.ProfileList:AddChild(GUI.ListBox)
			
			GUI.ListValue = {}
			for Key, Value in pairs(BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].ProfileList) do
				GUI.ListValue[Key] = BarProfilerGui:Create("InteractiveLabel")
					GUI.ListValue[Key]:SetFont ("Fonts\\FRIZQT__.TTF", 12)
					GUI.ListValue[Key]:SetText(Value)
					GUI.ListValue[Key]:SetCallback("OnClick", function(Widget) Func.ListValueHandler(Widget) end)
					GUI.ListBox:AddChild(GUI.ListValue[Key])
			end	
			
		GUI.ToolBox = BarProfilerGui:Create("InlineGroup")
			GUI.ToolBox:SetLayout("Flow")
			GUI.ToolBox:SetWidth(230)
			GUI.ToolBox:SetAutoAdjustHeight(false)
			GUI.ToolBox:SetHeight(280)
			BPGUI.Main.TabGroup:AddChild(GUI.ToolBox)
		
		GUI.LoadButton = BarProfilerGui:Create("Button")
			GUI.LoadButton:SetText("Load Bars")
			GUI.LoadButton:SetCallback("OnClick", 	function(widget) Func.LoadButtonHandler() end)		
			GUI.LoadButton:SetHeight(50)
			GUI.ToolBox:AddChild(GUI.LoadButton)
			GUI.LoadButton:SetDisabled(1)
			
		GUI.SaveButton = BarProfilerGui:Create("Button")
			GUI.SaveButton:SetText("Save Bars")
			GUI.SaveButton:SetCallback("OnClick", 	function(widget) Func.SaveButtonHandler() end)
			GUI.SaveButton:SetHeight(50)
			GUI.SaveButton:SetWidth(100)
			GUI.ToolBox:AddChild(GUI.SaveButton)
			GUI.SaveButton:SetDisabled(1)
			
		GUI.DeleteButton = BarProfilerGui:Create("Button")
			GUI.DeleteButton:SetText("Delete Profile")
			GUI.DeleteButton:SetCallback("OnClick", function(widget) Func.DeleteButtonHandler() end)
			GUI.DeleteButton:SetHeight(50)
			GUI.DeleteButton:SetWidth(100)
			GUI.ToolBox:AddChild(GUI.DeleteButton)
			GUI.DeleteButton:SetDisabled(1)
			
		GUI.Spacer = BarProfilerGui:Create("Label")
			GUI.Spacer:SetWidth(200)
			GUI.Spacer:SetHeight (80)
			GUI.ToolBox:AddChild(GUI.Spacer)
			
		GUI.RenameProfile = BarProfilerGui:Create("EditBox")
			GUI.RenameProfile:SetLabel("Enter a name to rename the profile")
			GUI.RenameProfile:SetCallback("OnEnterPressed", 	function(widget, event, NewProfileName) Func.RenameProfileHandler(NewProfileName) end)
			GUI.ToolBox:AddChild(GUI.RenameProfile)		
			GUI.RenameProfile:SetDisabled(1)
			
		if Var.SelectedProfile ~= nil then
			Func.ListValueHandler(GUI.ListValue[Var.SelectedProfile])
		end
			
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	NewProfileHandler = function(ProfileName)
		BPFunc.Profiles.Create(ProfileName)
		BPFunc.GUI.Main.Close()
		BarProfiler:BarProfilerSlash(nil)
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	ListValueHandler = function(Widget)
		local GUI = BPGUI.MainTab
		local Var = BPTemp.Main
		
		Var.SelectedProfile = BPFunc.General.FindKey(GUI.ListValue, Widget)

		for Key, Value in pairs(GUI.ListValue) do
			GUI.ListValue[Key]:SetColor (1, 1, 1)
		end
		
		GUI.ListValue[Var.SelectedProfile]:SetColor (1, 0, 0)
		
		GUI.DeleteButton:SetDisabled(nil)
		GUI.LoadButton:SetDisabled(nil)
		GUI.SaveButton:SetDisabled(nil)
		GUI.RenameProfile:SetDisabled(nil)

	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	DeleteButtonHandler = function()
		local str = "Caution: This profile and the action bars saved under it will be lost. Are you sure you wish to continue?"
		BPFunc.GUI.Warning.Layout(str, "DeleteProfile")
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	SaveButtonHandler = function()
		local str = "Caution: The current action bar data for this profile will be lost. Are you sure you wish to continue?"
		BPFunc.GUI.Warning.Layout(str, "SaveBars")
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	LoadButtonHandler = function()
		local str = "Caution: Loading a profile will re-arrange all of your current action bars. It is advised you save your current action bars before doing this. Are you sure you wish to continue?"
		BPFunc.GUI.Warning.Layout(str, "LoadBars")
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	RenameProfileHandler = function(NewProfileName)
		BPFunc.Profiles.Rename(NewProfileName)
		BPFunc.GUI.Main.Close()
		BarProfiler:BarProfilerSlash()
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	Unlock = function()
		local me = BPGUI.MainTab
		me.DeleteButton:SetDisabled(nil)
		me.LoadButton:SetDisabled(nil)
		me.SaveButton:SetDisabled(nil)
		me.RenameProfile:SetDisabled(nil)
	end
}