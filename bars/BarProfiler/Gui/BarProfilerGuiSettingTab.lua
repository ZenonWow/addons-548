BPFunc.GUI.SettingsTab = {
-------------------------------------------------------------------------------------------------------------------------------------------
	Layout = function()
		BPGUI.SettingsTab = {}	
		local GUI = BPGUI.SettingsTab
		local Func = BPFunc.GUI.SettingsTab
		local Var = BPTemp.Adv	
			GUI.MiniMapCheck = BarProfilerGui:Create("CheckBox")
			GUI.MiniMapCheck:SetLabel("Hide Minimap Button")
			GUI.MiniMapCheck:SetCallback("OnValueChanged", 	function(widget, event, Value) Func.MiniMapCheckHandler(Value) end)
			GUI.MiniMapCheck:SetValue(BarProfilerDb.Minimap.Hide)
			BPGUI.Main.TabGroup:AddChild(GUI.MiniMapCheck)
			
		GUI.WarningCheck = BarProfilerGui:Create("CheckBox")
			GUI.WarningCheck:SetLabel("Disable Warning Message")
			GUI.WarningCheck:SetCallback("OnValueChanged", 	function(widget, event, Value) Func.WarningCheckHandler(Value) end)
			GUI.WarningCheck:SetValue(BarProfilerDb.GUI.HideWarnings)
			BPGUI.Main.TabGroup:AddChild(GUI.WarningCheck)
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	MiniMapCheckHandler = function(Value)
		BarProfilerDb.Minimap.Hide = Value
		if BarProfilerDb.Minimap.Hide == true then
			BarProfilerIcon:Hide("BarProfiler")
		else
			BarProfilerIcon:Show("BarProfiler")
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	WarningCheckHandler = function(Value)
		BarProfilerDb.GUI.HideWarnings = Value
	end
-------------------------------------------------------------------------------------------------------------------------------------------
}
