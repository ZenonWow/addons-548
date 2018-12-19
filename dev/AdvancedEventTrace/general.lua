local AddOnName,E=...
local AddOn=E[1]
local G=AddOn:NewModule("General","AceEvent-3.0","AceHook-3.0")

local EventTraceFrame_HandleSlashCmd,EventTraceFrame_StopEventCapture,EventTraceFrame_Update,EventTraceFrame_StartEventCapture=EventTraceFrame_HandleSlashCmd,EventTraceFrame_StopEventCapture,EventTraceFrame_Update,EventTraceFrame_StartEventCapture
local wipe=wipe

local db
local config={
	get=function(info)return db[info[#info]]end,
	set=function(info,value)db[info[#info]]=value end,
	order=1,
	name=GENERAL,
	desc="Basic options for controlling ETF",
	type="group",
	args={
		numToCapture={
			order=1,
			name="Number to capture",
			desc="The number that will be captured when clicking \"Begin capture\". If set to 0, an unlimited number will be captured.",
			type="range",
			min=0,
			max=1000000,
			softMax=1000,
			step=1,
			bigStep=100,
		},
		startStop={
			order=2,
			name=function()return E.ETF.started and "End capture" or "Begin capture"end,
			desc="Toggle ETF's event/hook capturing",
			type="execute",
			func=function()local num=db.numToCapture EventTraceFrame_HandleSlashCmd((E.ETF.started and "stop") or (num>0 and num or "start"))end,
		},
		clear={
			order=3,
			name="Clear entries",
			desc="Delete all event/hook entries from the display",
			type="execute",
			func=function()G:Clear()end,
		},
	},
}

function G:OnInitialize()
	db=E.db.general
	AddOn.options.args.general=config
	
	G:SecureHook("EventTraceFrame_StartEventCapture",AddOn.UpdateFrame)
	G:SecureHook("EventTraceFrame_StopEventCapture",AddOn.UpdateFrame)
end

function G:Clear()
	local wasStarted=E.ETF.started
	if wasStarted then
		EventTraceFrame_StopEventCapture()
	end
	
	wipe(E.ETF.events)
	wipe(E.ETF.times)
	wipe(E.ETF.rawtimes)
	wipe(E.ETF.eventids)
	wipe(E.ETF.eventtimes)
	wipe(E.ETF.numhandlers)
	wipe(E.ETF.slowesthandlers)
	wipe(E.ETF.slowesthandlertimes)
	wipe(E.ETF.timeSinceLast)
	wipe(E.ETF.framesSinceLast)
	for i=1,#E.ETF.args do
		wipe(E.ETF.args[i])
	end
	E.ETF.lastIndex=0
	E.ETF.eventsToCapture=nil
	for i=1,#E.ETF.buttons do
		local button=E.ETF.buttons[i]
		button.time:SetText("")
		button.event:SetText("")
		button.index=nil
		button.HideButton:Hide()
		button:Hide()
	end
	
	EventTraceFrame_Update()
	if wasStarted then
		EventTraceFrame_StartEventCapture()
	end
end