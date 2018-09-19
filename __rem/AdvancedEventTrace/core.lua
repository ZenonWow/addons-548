local AddOnName,E=...
_G[AddOnName]=E
local AddOn=LibStub("AceAddon-3.0"):NewAddon(AddOnName,"AceEvent-3.0","AceHook-3.0")
E[1]=AddOn

local select=select

local defaults={
	global={
		general={
			numToCapture=0,
		},
		interface={
			autoShow=true,
			point=E.POINTS.TOPLEFT,
			relativePoint=E.POINTS.TOPRIGHT,
			offsetX=0,
			offsetY=0,
		},
		filtering={
			useFilter=true,
			filters={
				Default={
					events={},
				},
			},
			activeFilter="Default",
		},
		hooks={
			whitelists={
				Default={},
			},
			activeWhitelist="Default",
			stackOffset=0,
			stackTop=-1,
			stackBottom=-1,
		},
	}
}

local AC=LibStub("AceConfig-3.0")
local ACD=LibStub("AceConfigDialog-3.0")
local ACR=LibStub("AceConfigRegistry-3.0")
local AG=LibStub("AceGUI-3.0")
local ADB=LibStub("AceDB-3.0")

local OptionsFrame

AddOn.options={
	type="group",
	name=AddOnName,
	childGroups="tab",
	get=function(info)return E.db[info[#info]]end,
	set=function(info,value)E.db[info[#info]]=value end,
	args={},
}

function AddOn:OnInitialize()
	AddOn:ReserveModules()
	
	E.ETF=EventTraceFrame
	E.TT=EventTraceTooltip
	
	AddOn:SecureHook("EventTraceFrame_HandleSlashCmd")
	AddOn:SecureHookScript(E.ETF,"OnShow","EventTraceFrame_OnShow")
	AddOn:SecureHookScript(E.ETF,"OnHide","EventTraceFrame_OnHide")
	
	local IDB=defaults.global.interface
	IDB.maxEntries=EVENT_TRACE_MAX_ENTRIES
	IDB.smallerSystemTooltips=not EVENT_TRACE_SYSTEM_TIMES["System"]
	IDB.smallerElapsedTooltips=not EVENT_TRACE_SYSTEM_TIMES["Elapsed"]
	IDB.systemColors=EVENT_TRACE_EVENT_COLORS["System"]
	IDB.elapsedColors=EVENT_TRACE_EVENT_COLORS["Elapsed"]
	IDB.width=E.ETF:GetWidth()*2
	IDB.height=E.ETF:GetHeight()
	
	E.db=ADB:New("AdvETraceDB",defaults,true).global
	
	AC:RegisterOptionsTable(AddOnName, AddOn.options)
	
	E.AETF=AG:Create("Frame")
	E.AETF:Hide()
	E.AETF:SetLayout("Fill")
	--E.AETF:SetParent(E.ETF)
	E.AETF:SetTitle(AddOnName)
	
	OptionsFrame=AG:Create("SimpleGroup")
	OptionsFrame:SetLayout("Fill")
	E.AETF:AddChild(OptionsFrame)
end

function AddOn:EventTraceFrame_HandleSlashCmd(msg)
	msg=msg:lower()
	if msg=="adv" or msg=="aet" or msg=="advanced" or msg=="options" or msg=="settings" or msg=="config" then
		if E.AETF:IsShown() then
			AddOn:EventTraceFrame_OnHide(E.ETF,true)
		else
			AddOn:EventTraceFrame_OnShow(E.ETF,true)
		end
	end
end

function AddOn:EventTraceFrame_OnHide(frame,force)
	if force or E.db.interface.autoShow then
		ACD:Close(AddOnName)
		E.AETF:Hide()
	end
end

function AddOn:EventTraceFrame_OnShow(frame,force)
	if force or E.db.interface.autoShow then
		AddOn:UpdateFrame()
		E.AETF:Show()
		AddOn:ResizeAndAnchorFrame()
	end
end

function AddOn:HashBytes(length,...)
	local h=0
	local emptyChar
	for i=1,146 do
		h=127*h
		if not emptyChar then
			h=h+(select(i,...))
			emptyChar=(i>=length)
		end
	end
	return h
end

function AddOn:HashCode(str)
	local length=str:len()
	if length==0 then return 0 end
	return AddOn:HashBytes(length,str:byte(1,length))
end

function AddOn:ReserveModules()
	E.RESERVED.Object[self]=1
	for _,module in self:IterateModules() do
		AddOn.ReserveModules(module)
	end
end

function AddOn:ResizeAndAnchorFrame()
	E.AETF:SetWidth(E.db.interface.width)
	E.AETF:SetHeight(E.db.interface.height)
	E.AETF:ClearAllPoints()
	E.AETF:SetPoint(E.db.interface.point,E.ETF,E.db.interface.relativePoint,E.db.interface.offsetX,E.db.interface.offsetY)
end

function AddOn:Status(status)
	E.AETF:SetStatusText(status)
end

function AddOn:UpdateFrame()
	ACD:Open(AddOnName,OptionsFrame)
end