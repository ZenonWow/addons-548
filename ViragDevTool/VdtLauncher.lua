-- _NPCScan.Overlay.Broker  by Darkclaw of Hyjal
-- $Revision: 11 $
-- $Date: 2011-02-01 02:15:54 +0000 (Tue, 01 Feb 2011) $


VdtLauncher= {
	type = "launcher",
	label= 'DevTool',
	text= '/VDT',
	--value= '/VDT',
	--icon = "Interface\\AddOns\\ViragDevTool\\icon",
	OnClick = function(self, button)
		if  button == "LeftButton"  then
			if  IsControlKeyDown()  then  ViragDevTool:ToggleFrameStack()
			elseif  IsAltKeyDown()  then  ViragDevTool:ToggleEventTrace()
			else
				-- LeftButton toggles the debug/watches UI
				ViragDevTool:ToggleUI()
			end
		elseif  button == "RightButton"  then
			-- Open TinyPad lua editor
			if  TinyPad and TinyPad.SlashHandler
			then  TinyPad:Toggle()  end
		elseif button == "MiddleButton" then
			ViragDevTool:ExecuteCMD('', true)
		end
	end,
	OnTooltipShow = function(tooltip)
		if  not tooltip  or  not tooltip.AddLine  then  return  end
		tooltip:AddLine("|cffffffff Virag's DevTool |r")
		tooltip:AddLine("|cffd6ff00 Click: |r Toggles /VDT watch frame")
		tooltip:AddLine("|cffd6ff00 Ctrl-Click: |r Toggle /fstack FrameStack")
		tooltip:AddLine("|cffd6ff00 Alt-Click:  |r Toggle /etrace EventTrace")
		tooltip:AddLine("|cffaaf200 Middle-Click: |r Toggle ...")	
		tooltip:AddLine("|cff6cff00 Right-Click: |r Toggle TinyPad executable editor")
	end,
}

LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("ViragDevTool", VdtLauncher)


function  ViragDevTool:ToggleFrameStack()
	-- souce: ViragDevTool.xml
	--self.isActive = not self.isActive
	UIParentLoadAddOn("Blizzard_DebugTools");
	local showHidden = false; -- todo add this functionality
	local showRegions = false;
	FrameStackTooltip_Toggle(showHidden, showRegions);
end

function  ViragDevTool:ToggleEventTrace()
end

