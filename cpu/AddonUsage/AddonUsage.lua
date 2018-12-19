--[[	AddonUsage

This is a simple mod to display comparative memory and cpu usage of addons.

2.0.1 10/25/13 rewrite/facelift, realtime cpu monitoring option
1.14 9/11/13 toc update for 5.4
1.13 5/21/13 toc update for 5.3
1.12 8/28/12 fixed _ tainting
1.11 8/27/12 5.0 (Mists of Pandaria) update
1.1 4/10/09 belated fix for scrollbar change in 3.02
1.0 7/14/08 initial release
]]

BINDING_HEADER_ADDONUSAGE = "AddonUsage"

local au = AddonUsage

au.profiling = GetCVarBool("scriptProfile") -- whether cpu profiling is enabled

au.list = {} -- the master list of addons, numerically indexed { {"Name",memory,memory%,cpu,cpu%} }
au.listCache = {} -- cache list of addons, indexed by name, that are already in the above list

local sortKey = 2 -- 1=name, 2=memory, 4=cpu
local sortDir = 1 -- 0=ascending order, 1=descending order

-- this is used by the BuildList function to sort the addons by sortKey and sortDir
local function sortList(e1,e2)
	if sortDir==1 then
		if e1[sortKey] and e2[sortKey] and e1[sortKey]>e2[sortKey] then
			return true
		end
	else
		if e1[sortKey] and e2[sortKey] and e1[sortKey]<e2[sortKey] then
			return true
		end
	end
end

--[[ UI bits ]]

au:RegisterEvent("PLAYER_LOGIN")
function au:OnEvent(event,...)
	if au[event] then
		au[event](self,...)
	end
end

function au:PLAYER_LOGIN()
	au:BuildUI()
	au:BuildList()
end

-- the meat of the addon, populates au.list with loaded addons and their memory(+cpu if enabled) usages
function au:BuildList()
	local list = au.list
	local cache = au.listCache
	-- find any new addons loaded
	for i=1,GetNumAddOns() do
		local name,_,_,enabled = GetAddOnInfo(i)
		if enabled and IsAddOnLoaded(name) and not cache[name] then
			tinsert(list,{name})
			cache[name] = 1
		end
	end
	-- gather memory usage
	UpdateAddOnMemoryUsage()
	local total = 0
	-- first run through and populate memoryusage of each addon, tallying a total
	for i=1,#list do
		local mem = GetAddOnMemoryUsage(list[i][1])
		list[i][2] = mem
		total = total + mem
	end
	-- now go through and populate memory % from totals
	for i=1,#list do
		if total>0 then
			list[i][3] = list[i][2]*100/total
		else
			list[i][3] = 0
		end
	end
	if au.profiling then -- repeat above for cpu if profiling enabled
		UpdateAddOnCPUUsage()
		total = 0
		for i=1,#list do
			local cpu = GetAddOnCPUUsage(list[i][1])
			list[i][4] = cpu
			total = total + cpu
		end
		for i=1,#list do
			if total>0 then
				list[i][5] = list[i][4]*100/total
			else
				list[i][5] = 0
			end
		end
	end
	table.sort(list,sortList) -- sort data
	au.scrollFrame.update() -- update scrollframe
end

-- finishes the UI bits after login and adjusts width depending on whether scriptProfile cvar enabled
function au:BuildUI()

	SetPortraitToTexture(au.portrait,"Interface\\Icons\\Achievement_GuildPerk_WorkingOvertime")

	au.profilingCheckButton.text:SetText("Monitor CPU usage")
	au.autoCheckButton.text:SetText("Realtime updates")

	au.profilingCheckButton:SetChecked(au.profiling)

	-- create hybridscrollframe
	sortKey = au.profiling and 4 or 2 -- initially sort by cpu if profiling enabled, by memory otherwise
	au.scrollFrame.update = au.UpdateList
	au.scrollFrame.stepSize = 40
	au.scrollFrame.scrollBar.doNotHide = 1
	HybridScrollFrame_CreateButtons(au.scrollFrame,"AddonUsageListTemplate")

	-- if scriptProfile disabled, narrow window
	if not au.profiling then
		au:SetWidth(232)
		for i=1,#au.scrollFrame.buttons do
			au.scrollFrame.buttons[i].cpu:Hide() -- hide cpu column
			au.scrollFrame.buttons[i]:SetWidth(192)
		end
		au.sortCPU:Hide() -- hide cpu sort header
		au.sortMemory:SetWidth(88)
		au.closeButton:SetWidth(76)
		au.resetButton:SetWidth(76)
		au.updateButton:SetWidth(76)
	end

end

function au:Toggle()
	au:SetShown(not au:IsVisible())
end

-- HybridScrollFrame update
function au:UpdateList()
	local height = 16
	local offset = HybridScrollFrame_GetOffset(au.scrollFrame)
	local buttons = au.scrollFrame.buttons
	for i=1, #buttons do
		local index = i + offset
		local button = buttons[i]
		button:Hide()
		if ( index <= #au.list ) then
			button:SetID(index)
			button.name:SetText(au.list[index][1])
			button.mem:SetText(format("%.1fk",au.list[index][2]))
			button.memPercent:SetText(format("%d%%",au.list[index][3]))
			if au.profiling then
				button.cpu:SetText(format("%d%%",au.list[index][5]))
			end
			button:Show()
		end
	end
	HybridScrollFrame_Update(au.scrollFrame, height*#au.list, height)
end

--[[ buttons clicks ]]

function au:ButtonOnClick()
	if self==au.closeButton then
		au:Hide()
	elseif self==au.updateButton then
		au:BuildList()
	elseif self==au.resetButton then
		collectgarbage()
		if au.profiling then
			ResetCPUUsage()
		end
		au:BuildList()
	end
end

function au:SortOnClick()
	local id = self:GetID()
	if id==sortKey then
		sortDir = 1-sortDir
	else
		sortKey = id
		sortDir = id==1 and 0 or 1
	end
	au:BuildList()
end

function au:CheckOnClick()
	if self==au.autoCheckButton then
		au.timer = 0
		au:SetScript("OnUpdate",self:GetChecked() and au.OnUpdate)
	elseif self==au.profilingCheckButton then
		local enable = self:GetChecked()
		-- todo: see if these still cause taint; not that big a deal since seeing one means a reload will probably happen
		StaticPopupDialogs["ADDONUSAGEPROFILE"] = {
				text=enable and "CPU monitoring causes overhead that will affect performance while it is enabled.\n\nRemember to turn it off when done testing.\n\nDo you want to turn CPU monitoring on and reload the UI?" or "Turn off CPU monitoring and reload the UI?",
				button1="Yes", button2="No", timeout=30, whileDead=1, showAlert=enable,
				OnAccept=function() SetCVar("scriptProfile",enable) ReloadUI() end,
				OnCancel=function() AddonUsage.profilingCheckButton:Enable() AddonUsage.profilingCheckButton:SetChecked(not enable) end
			}
		au.profilingCheckButton:Disable()
		StaticPopup_Show("ADDONUSAGEPROFILE")
	end

end

-- this runs while the autoCheckButton ("Realtime updates") is checked and the window is shown
function au:OnUpdate(elapsed)
	self.timer = self.timer + elapsed
	if self.timer > 1 then
		self.timer = 0
		au:BuildList()
	end
end

SlashCmdList["ADDONUSAGE"] = au.Toggle
SLASH_ADDONUSAGE1 = "/addonusage"
SLASH_ADDONUSAGE2 = "/usage"
SLASH_ADDONUSAGE3 = "/au"

