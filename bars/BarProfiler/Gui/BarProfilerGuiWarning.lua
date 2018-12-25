BPFunc.GUI.Warning = {
-------------------------------------------------------------------------------------------------------------------------------------------
	Layout = function(PrintString, Destination)
		BPGUI.Warning = {}
		local Func = BPFunc.GUI.Warning
		local GUI = BPGUI.Warning
		local PointChar = BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter]
		local ProfileName = PointChar.ProfileList[BPTemp.Main.SelectedProfile]
		local Pos = BarProfilerDb.GUI.ConfirmationWindow
		BPFunc.GUI.Main.Close()
		BarProfilerDb.GUI.Inhibit = true
		
		if Destination == "LoadBars" then
			if PointChar.Profiles[ProfileName].DataCheck == nil then
				BarProfiler:Print ("Error - There is no data to load")
				BarProfilerDb.GUI.Inhibit = nil
				BarProfiler:BarProfilerSlash(nil)
				return
			end
		elseif Destination == "SaveBars" then
			if PointChar.Profiles[ProfileName].DataCheck == nil then
				BPFunc.Bars.Save("Profiles", PointChar.ProfileList[BPTemp.Main.SelectedProfile], false)
				BarProfilerDb.GUI.Inhibit = nil
				BarProfiler:BarProfilerSlash(nil)
				return
			end
		end
		if BarProfilerDb.GUI.HideWarnings == true then
			Func.YesButtonHandler(Destination)
			BarProfilerDb.GUI.Inhibit = nil
			BarProfiler:BarProfilerSlash(nil)
			return
		end
		
		GUI.Frame = BarProfilerGui:Create("Window")	--bug workaround
		BarProfilerGui:Release(GUI.Frame)	--bug workaround
		
		GUI.Frame = BarProfilerGui:Create("Window")
			GUI.Frame:EnableResize(Hide)
			GUI.Frame:SetWidth(520)
			GUI.Frame:SetHeight(200)
			GUI.Frame:SetTitle("Confirmation Needed")
			GUI.Frame:SetLayout("Flow")
			GUI.Frame:SetCallback("OnClose", function(widget) Func.Close(widget) end)
			GUI.Frame:SetPoint(Pos.point, Pos.relativeTo, Pos.relativePoint, Pos.xOfs, Pos.yOfs)
			
		GUI.UpperGroup = BarProfilerGui:Create("InlineGroup")
			GUI.UpperGroup:SetWidth(500)
			GUI.UpperGroup:SetLayout("Fill")
			GUI.Frame:AddChild(GUI.UpperGroup)
			
		GUI.Message = BarProfilerGui:Create("Label")
			GUI.Message:SetWidth(500)
			GUI.Message:SetText (PrintString)
			GUI.Message:SetFont ("Fonts\\FRIZQT__.TTF", 15)
			GUI.UpperGroup:AddChild(GUI.Message)
			
		GUI.YesButton = BarProfilerGui:Create("Button")
			GUI.YesButton:SetWidth(245)
			GUI.YesButton:SetText ("Yes")
			GUI.YesButton:SetCallback("OnClick", function(widget) Func.YesButtonHandler(Destination, Data) end)
			GUI.Frame:AddChild(GUI.YesButton)
			
		GUI.NoButton = BarProfilerGui:Create("Button")
			GUI.NoButton:SetWidth(245)
			GUI.NoButton:SetText ("No")
			GUI.NoButton:SetCallback("OnClick", function(widget) Func.Close() end)
			GUI.Frame:AddChild(GUI.NoButton)
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	YesButtonHandler = function(Destination)
		local Func = BPFunc.GUI.Warning
		local PointChar = BarProfilerDb.Realms[BPTemp.CurrentRealm].Characters[BPTemp.CurrentCharacter]
		if Destination == "DeleteProfile" then
			BPFunc.Profiles.Delete()
		elseif Destination == "SaveBars" then
			BPFunc.Bars.Save("Profiles", PointChar.ProfileList[BPTemp.Main.SelectedProfile], false)
		elseif Destination == "LoadBars" then
			BPFunc.Bars.Load("Profiles", PointChar.ProfileList[BPTemp.Main.SelectedProfile], false)
			BPGUI.Main.Frame:SetStatusText("Last Profile Loaded: " .. PointChar.LoadedProfile)
		end
		if BarProfilerDb.GUI.HideWarnings == false then
			Func.Close()
		else
			BarProfiler:BarProfilerSlash(nil)
		end
	end,
-------------------------------------------------------------------------------------------------------------------------------------------
	Close = function()
		local GUI = BPGUI.Warning
		local point, relativeTo, relativePoint, xOfs, yOfs = GUI.Frame:GetPoint()
		if relativeTo == nil then
			BarProfilerDb.GUI.ConfirmationWindow = {
				point = point,
				relativeTo = relativeTo,
				relativePoint = relativePoint,
				xOfs = xOfs,
				yOfs = yOfs
			}
		end
		BarProfilerDb.GUI.Inhibit = nil
		BarProfilerGui:Release(GUI.Frame)
		BarProfiler:BarProfilerSlash(nil)
	end
-------------------------------------------------------------------------------------------------------------------------------------------
}