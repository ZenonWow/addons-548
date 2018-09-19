local AddOnName,E=...
local AddOn=E[1]
local I=AddOn:NewModule("Interface","AceEvent-3.0","AceHook-3.0")

local EVENT_TRACE_SYSTEM_TIMES,EVENT_TRACE_EVENT_COLORS=EVENT_TRACE_SYSTEM_TIMES,EVENT_TRACE_EVENT_COLORS

local db
local config={
	get=function(info)return db[info[#info]]end,
	set=function(info,value)db[info[#info]]=value end,
	order=1,
	name="Interface",
	desc="Options for changing the UI",
	type="group",
	args={
		maxEntries={
			order=1,
			name="Max entries",
			desc="The maximum number of entries ETF should keep in memory",
			type="range",
			min=1,
			max=100000,
			step=1,
			softMin=5,
			softMax=5000,
			bigStep=50,
			set=function(info,value)db[info[#info]]=value EVENT_TRACE_MAX_ENTRIES=value end,
		},
		colors={
			order=2,
			name="Colors",
			desc="Currently only easily-accessible ETF variables are supported",
			type="group",
			get=function(info)return unpack(db[info[#info]])end,
			args={
				systemColors={
					order=1,
					name="\"System\" entries",
					type="color",
					hasAlpha=true,
					set=function(info,r,g,b,a)I:SetColor("System",info,r,g,b,a)end,
				},
				elapsedColors={
					order=2,
					name="\"Elapsed\" entries",
					type="color",
					hasAlpha=true,
					set=function(info,r,g,b,a)I:SetColor("Elapsed",info,r,g,b,a)end,
				},
			},
		},
		smallTooltips={
			order=3,
			name="Smaller tooltips",
			desc="Currently only easily-accessible ETF variables are supported",
			type="group",
			args={
				smallerSystemTooltips={
					order=1,
					name="\"System\" entries",
					type="toggle",
					set=function(info,value)db[info[#info]]=value EVENT_TRACE_SYSTEM_TIMES["System"]=not value end,
				},
				smallerElapsedTooltips={
					order=2,
					name="\"Elapsed\" entries",
					type="toggle",
					set=function(info,value)db[info[#info]]=value EVENT_TRACE_SYSTEM_TIMES["Elapsed"]=not value end,
				},
			},
		},
		
		AET={
			order=-1,
			name="This frame",
			desc="The appearance of AdvancedEventTrace's main UI",
			type="group",
			args={
				autoShow={
					order=1,
					name="Auto-show",
					desc="If checked, this frame will show when ETF is shown and hide when ETF is hidden",
					type="toggle",
				},
				width={
					order=2,
					name="Width",
					type="range",
					min=0,
					max=1920,
					softMin=200,
					softMax=1000,
					step=1,
					bigStep=20,
				},
				height={
					order=3,
					name="Height",
					type="range",
					min=0,
					max=1920,
					softMin=200,
					softMax=1000,
					step=1,
					bigStep=20,
				},
				point={
					order=4,
					name="Attach this frame's",
					type="select",
					values=E.POINTS,
					set=function(info,value)db[info[#info]]=value AddOn:ResizeAndAnchorFrame()end,
				},
				relativePoint={
					order=5,
					name="To ETF's",
					type="select",
					values=E.POINTS,
					set=function(info,value)db[info[#info]]=value AddOn:ResizeAndAnchorFrame()end,
				},
				offsetX={
					order=6,
					name="X offset",
					type="range",
					min=-1920,
					max=1920,
					softMin=-512,
					softMax=512,
					step=1,
					bigStep=20
				},
				offsetY={
					order=7,
					name="Y offset",
					type="range",
					min=-1080,
					max=1080,
					softMin=-288,
					softMax=288,
					step=1,
					bigStep=20
				},
				reanchor={
					order=8,
					name="Re-size/Re-anchor",
					type="execute",
					func=function()AddOn:ResizeAndAnchorFrame()end,
				},
			},
		},
	},
}

function I:OnInitialize()
	db=E.db.interface
	AddOn.options.args.interface=config
	
	EVENT_TRACE_MAX_ENTRIES=db.maxEntries
	EVENT_TRACE_SYSTEM_TIMES["System"]=not db.smallerSystemTooltips
	EVENT_TRACE_SYSTEM_TIMES["Elapsed"]=not db.smallerElapsedTooltips
	EVENT_TRACE_EVENT_COLORS["System"]=db.systemColors
	EVENT_TRACE_EVENT_COLORS["Elapsed"]=db.elapsedColors
end

function I:SetColor(typeStr,info,r,g,b,a)
	t=EVENT_TRACE_EVENT_COLORS[typeStr]
	t[1]=r
	t[2]=g
	t[3]=b
	t[4]=a
	db[info[#info]]=t
end