local ADDON_NAME, addon = ...
local _G, L = _G, addon.L
local BugGrabber = BugGrabber
if  not BugGrabber  then  return  end

local LDB = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not LDB then return end

local ICON_GREEN = [[Interface\AddOns\BugSack\Media\icon]]
local ICON_RED   = [[Interface\AddOns\BugSack\Media\icon_red]]
local ICON_TEKERR = [[Interface\Icons\INV_Elemental_Primal_Fire]]

local dataobj = {
	type = "data source",
	label = "Bugs",
	-- text = "0",
	icon = ICON_GREEN,
}

function dataobj.OnClick(self, mouseButton)
	if  mouseButton == "RightButton"  then
		InterfaceOptionsFrame_OpenToCategory(ADDON_NAME)
		InterfaceOptionsFrame_OpenToCategory(ADDON_NAME)
	else
		if  IsModifiedClick()  then
			if IsAltKeyDown() then  addon:Reset()  end
			if IsControlKeyDown() and IsShiftKeyDown() then  ReloadUI()  end
		else
			addon.window:Toggle()
		end
	end
end

do
	local errorsInTooltip = 8
	local hint = 
[[|cffeda55fClick|r to toggle BugSack bugs window.
|cffeda55fCtrl+Shift-Click|r to reload the user interface.
|cffeda55fAlt-Click|r to clear all bugs.]]
	local line = "%d. %s (x%d)"
	function dataobj.OnTooltipShow(tt)
		addon.lastTooltip = tt
		addon.lastTooltipOwner = tt:GetOwner()
		local errors = addon:GetSessionErrors()
		
		if #errors == 0 then
			tt:AddLine(L["You have no bugs, yay!"])
		else
			tt:AddLine(ADDON_NAME)
			local from = max(#errors-errorsInTooltip+1, 1)
			for  i = #errors, from, -1  do
				local err = errors[i]
				tt:AddLine(line:format(i, addon.ColorStack(err.message), err.counter), .5, .5, .5)
			end
		end
		tt:AddLine(" ")
		tt:AddLine(hint, 0.2, 1, 0.2, 1)
		tt:Show()
	end
end




function dataobj:UpdateErrors()
	local count = #addon:GetSessionErrors()
	-- print("BugSack.dataobject:UpdateErrors() count="..count)
	self.text = tostring(count)
	self.icon =  count == 0  and  ICON_GREEN  or  ICON_RED

	local tt = addon.lastTooltip
	if  tt and tt:GetOwner() == addon.lastTooltipOwner and tt:IsShown()  then
		-- Update tooltip if visible.
		tt:Hide()
		self.OnTooltipShow(tt)
	else
		addon.lastTooltip = nil
	end
	
end


function dataobj:OnAddonLoaded()
	local LibDBIcon = LibStub("LibDBIcon-1.0", true)
	if not LibDBIcon then return end
	if not BugSackLDBIconDB then BugSackLDBIconDB = {} end
	LibDBIcon:Register(ADDON_NAME, self, BugSackLDBIconDB)
	self.OnAddonLoaded = nil
	self:UpdateErrors()
end

addon.dataobject = LDB:NewDataObject(ADDON_NAME, dataobj)

