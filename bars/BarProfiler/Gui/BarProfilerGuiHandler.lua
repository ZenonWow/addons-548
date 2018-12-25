BPFunc.GUI = {}
BPFunc.GUI.Main = {
-------------------------------------------------------------------------------------------------------------------------------------------
	Frame = function()
		local meGUI = BarProfilerDb.GUI
		local meLoaded = BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter].LoadedProfile
		BPGUI = {}
		BPGUI.Main = {}
		BPGUI.Main.Frame = BarProfilerGui:Create("Frame")
			BPGUI.Main.Frame:SetTitle("Bar Profiler")
			BPGUI.Main.Frame:EnableResize(Hide)
			BPGUI.Main.Frame:SetWidth(720)
			BPGUI.Main.Frame:SetHeight(400)
			BPGUI.Main.Frame:SetCallback("OnClose",	function(widget, event, profilename) BPFunc.GUI.Main.Close(widget) end)
			BPGUI.Main.Frame:SetLayout("Fill")
			BPGUI.Main.Frame:SetPoint(meGUI.Main.point, meGUI.Main.relativeTo, meGUI.Main.relativePoint, meGUI.Main.xOfs, meGUI.Main.yOfs)
			if meLoaded ~= nil then
				BPGUI.Main.Frame:SetStatusText("Last Profile Loaded: " .. meLoaded)
			end
			BPGUI.Main.Frame.statustext:SetTextColor(1, 1, 1)
			BPGUIEsc = BPGUI.Main.Frame	--Bug Workaround
			
		BPGUI.Main.TabGroup =  BarProfilerGui:Create("TabGroup")
			BPGUI.Main.TabGroup:SetLayout("Flow")
			BPGUI.Main.TabGroup:SetTabs({{text="Main", value="Main"}, {text="Advanced", value="Advanced"}, {text="Settings", value="Settings"}})
			BPGUI.Main.TabGroup:SetCallback("OnGroupSelected", BPFunc.GUI.Main.SelectTab)
			BPGUI.Main.TabGroup:SelectTab("Main")	--save current tab?
			BPGUI.Main.Frame:AddChild(BPGUI.Main.TabGroup)
		end,
-------------------------------------------------------------------------------------------------------------------------------------------
	SelectTab = function(container, event, group)
		container:ReleaseChildren()	--annoying
		if group == "Main" then
			BPFunc.GUI.MainTab.Layout()
		elseif group == "Advanced" then
			BPFunc.GUI.AdvTab.Layout ()
		elseif group == "Settings" then
			BPFunc.GUI.SettingsTab.Layout()
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------	
	Close = function()
		local point, relativeTo, relativePoint, xOfs, yOfs = BPGUI.Main.Frame:GetPoint()
		if relativeTo == nil then
			BarProfilerDb.GUI.Main = {
				point = point,
				relativeTo = relativeTo,
				relativePoint = relativePoint,
				xOfs = xOfs,
				yOfs = yOfs
			}
		end
		BarProfilerGui:Release(BPGUI.Main.Frame)
		BarProfilerSlashCount = 0
	end
-------------------------------------------------------------------------------------------------------------------------------------------	
}