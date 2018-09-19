local AddOnName,E=...
local AddOn=E[1]
local F=AddOn:NewModule("Filters","AceEvent-3.0","AceHook-3.0")

local tonumber,wipe,pairs,floor,type=tonumber,wipe,pairs,floor,type
local EventTraceFrameEventHideButton_OnClick=EventTraceFrameEventHideButton_OnClick

local ignoredEvents

local Blacklist,Whitelist="Blacklist","Whitelist"
local numFilters=0
local newName,newIsWhitelist

local db
local config={
	get=function(info)return db[info[#info]]end,
	set=function(info,value)db[info[#info]]=value end,
	order=2,
	name="Filtering",
	desc="Options for blacklisting or whitelisting events",
	type="group",
	args={
		useFilter={
			order=1,
			name="Enable filter",
			desc="If unchecked, ETF will always show all events",
			type="toggle",
			set=function(info,value)db[info[#info]]=value F:DBToETF()end,
		},
		activeFilter={
			order=2,
			name="Active filter",
			type="select",
			hidden=function()return not db.useFilter end,
			set=function(info,value)db[info[#info]]=value F:UpdateFilter()end,
			values={},
		},
		removeFilter={
			order=3,
			name="Delete this filter",
			type="execute",
			func=function()F:DeleteFilter()end,
			confirm=function()return ("Delete %s?"):format(db.activeFilter)end,
			hidden=function()return not db.useFilter or numFilters<=1 end,
		},
		newEvent={
			order=4,
			name=function()local filter=db.activeFilter return ("Add event to %s (%s)"):format(filter,F:GetType(filter))end,
			type="group",
			hidden=function()return not db.useFilter end,
			args={
				add={
					order=1,
					name="Event",
					type="input",
					set=function(info,value)F:ChangeEventFilter(value:upper(),true,true)end,
					confirm=function(info,value)local event=value:upper()return (tonumber(event) or not E.EVENTS[event]) and ("%s is not a known event. Proceed?"):format(event)end,
				},
			},
		},
		filteredEvents={
			order=5,
			name="Filtered events",
			desc=function()return ("These are the only events that will %s be shown in ETF when they fire"):format(F:GetType()==Blacklist and "not" or "")end,
			type="group",
			hidden=function()return not db.useFilter end,
			args={},
		},
		reFilter={
			order=6,
			name="Refresh filter",
			desc="Apply the filter to events that are currently displayed in ETF (only useful if you just changed the filter and don't want to clear all events)",
			type="group",
			hidden=function()return not db.useFilter end,
			args={
				all={
					order=1,
					name="(Slow) Remove ignored entries",
					type="execute",
					func=function()F:ReFilter()end,
				},
			},
		},
		addFilter={
			order=7,
			name="Create new filter",
			type="group",
			args={
				name={
					order=1,
					name="Filter name",
					type="input",
					get=function(info)return newName end,
					set=function(info,value)newName=value:trim() end,
				},
				filterType={
					order=2,
					name="Type",
					desc="A blacklist prevents ETF from displaying any filtered events. A whitelist prevents ETF from displaying any events that are not filtered.",
					type="select",
					values={
						Blacklist=Blacklist,
						Whitelist=Whitelist,
					},
					get=function(info)return F:GetType(newIsWhitelist)end,
					set=function(info,value)newIsWhitelist=value==Whitelist end,
				},
				add={
					order=3,
					name="Create",
					type="execute",
					func=function()F:AddFilter()end,
					hidden=function()return not newName or newName=="" end,
				},
			},
		},
	},
}

function F:OnInitialize()
	AddOn.options.args.filtering=config
	db=E.db.filtering
	ignoredEvents=E.ETF.ignoredEvents
	
	F:SecureHookScript(E.ETF,"OnShow","EventTraceFrame_OnShow")
	F:SecureHook("EventTraceFrame_OnSizeChanged")
	F:EventTraceFrame_OnSizeChanged(E.ETF,E.ETF:GetWidth(),E.ETF:GetHeight(),true)
	
	F:GenerateFilterNames()
	F:ReinitalizeListDisplay()
end

function F:AddFilter()
	db.filters[newName]={
		isWhitelist=newIsWhitelist,
		events={},
	}
	config.args.activeFilter.values[newName]=newName
	numFilters=numFilters+1
	db.activeFilter=newName
	db.useFilter=true
	F:UpdateFilter()
	AddOn:Status(("Created event %s %s"):format(F:GetType(newIsWhitelist),newName))
	newName=nil
end

function F:ChangeEventFilter(event,setFiltered,sendToETF)
	if not event then return end
	setFiltered=setFiltered and 1 or nil
	local filter=F:GetActiveFilter()
	if sendToETF then
		F:SetIgnoredEvent(filter.isWhitelist,event,setFiltered)
	end
	filter.events[event]=setFiltered
	F:UpdateListDisplay(event,setFiltered)
	if setFiltered then
		AddOn:Status(("Added %s to events %s"):format(event,F:GetType(filter)))
	else
		AddOn:Status(("Removed %s from events %s"):format(event,F:GetType(filter)))
	end
end

function F:DBToETF()
	wipe(ignoredEvents)
	local filter=F:GetActiveFilter()
	local EVENT_LIST=E.EVENTS
	if filter.isWhitelist then
		for i=1,#EVENT_LIST do
			local event=EVENT_LIST[i].name
			local isFiltered=filter.events[event]
			F:SetIgnoredEvent(true,event,isFiltered)
		end
	else
		for event,isFiltered in pairs(filter.events) do
			F:SetIgnoredEvent(false,event,isFiltered)
		end
	end
end

function F:DeleteFilter()
	local name=db.activeFilter
	db.filters[name]=nil
	config.args.activeFilter.values[name]=nil
	numFilters=numFilters-1
	for newName,_ in pairs(db.filters)do
		db.activeFilter=newName
		break
	end
	F:UpdateFilter()
	AddOn:Status(("Deleted event %s %s"):format(F:GetType(newIsWhitelist),name))
end

function F:EventTraceFrame_OnSizeChanged(frame,width,height,override)
	local numButtonsToDisplay=floor((height-36)/EVENT_TRACE_EVENT_HEIGHT)
	local numButtonsCreated=override and 0 or #frame.buttons
	if numButtonsCreated<numButtonsToDisplay then
		for i=numButtonsCreated+1,numButtonsToDisplay do
			local button=_G["EventTraceFrameButton"..i.."HideButton"]
			AddOn:SecureHookScript(button,"OnClick", F.EventTraceFrameEventHideButton_OnClick)
		end
	end
end

function F:EventTraceFrame_OnShow()
	F:DBToETF()
end

function F:EventTraceFrameEventHideButton_OnClick()
	local newEvent
	if not db.useFilter then
		wipe(ignoredEvents)
		return
	end
	local filter=F:GetActiveFilter()
	for event,isFiltered in pairs(ignoredEvents) do
		if isFiltered then
			local isNew=filter.events[event]
			if not filter.isWhitelist then
				isNew=not isNew
			end
			if isNew then
				newEvent=event
				break
			end
		end
	end
	F:ChangeEventFilter(newEvent,not filter.isWhitelist,false)
	AddOn:UpdateFrame()
end

function F:GenerateFilterNames()
	local t=config.args.activeFilter.values
	wipe(t)
	numFilters=0
	for k,_ in pairs(db.filters)do
		t[k]=k
		numFilters=numFilters+1
	end
end

function F:GetActiveFilter()
	return db.filters[db.activeFilter]
end

function F:GetType(arg)
	arg=arg or db.activeFilter
	local isWhitelist
	local datatype=type(arg)
	if datatype=="string" then
		isWhitelist=db.filters[arg].isWhitelist
	elseif datatype=="table" then
		isWhitelist=arg.isWhitelist
	else
		isWhitelist=arg
	end
	return isWhitelist and Whitelist or Blacklist
end

function F:ReFilter()--slow
	local buttons=E.ETF.buttons
	for event,isFiltered in pairs(ignoredEvents)do
		for i=1,#buttons do
			local frame=buttons[i]
			if frame and frame.event:GetText()==event then
				EventTraceFrameEventHideButton_OnClick(frame.HideButton)
				break
			end
		end
	end
end

function F:ReinitalizeListDisplay()
	wipe(config.args.filteredEvents.args)
	for event,isFiltered in pairs(F:GetActiveFilter().events)do
		F:UpdateListDisplay(event,isFiltered)
	end
end

function F:SetIgnoredEvent(isWhitelist,event,setFiltered)
	local ignore
	if db.useFilter then
		ignore=not setFiltered
		if not isWhitelist then
			ignore=not ignore
		end
	end
	ignoredEvents[event]=ignore and 1 or nil
end

function F:UpdateFilter()
	F:DBToETF()
	F:ReinitalizeListDisplay()
end

function F:UpdateListDisplay(event,setFiltered)
	local t=config.args.filteredEvents.args
	if setFiltered then
		t[event]={
			order=E.EVENTS[event] or #E.EVENTS+1,
			name=event,
			type="group",
			args={
				delete={
					order=1,
					name="Remove from Whitelist",
					type="execute",
					func=function()F:ChangeEventFilter(event,false,true)end,
					confirm=function()local filter=db.activeFilter return ("Remove %s from %s %s?"):format(event,F:GetType(filter),filter)end,
				}
			}
		}
	else
		t[event]=nil
	end
end