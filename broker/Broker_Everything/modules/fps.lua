
----------------------------------
-- module independent variables --
----------------------------------
local addon, ns = ...
local C, L, I = ns.LC.color, ns.L, ns.I
graphicsSetsDB = {}

-----------------------------------------------------------
-- module own local variables and local cached functions --
-----------------------------------------------------------
local name = "FPS" -- L["FPS"]
local tt2,tt3 = nil,nil,nil
local GetFramerate = GetFramerate
local _, playerClass = UnitClass("player")
local _minmax = {[1] = nil,[2] = nil}
local graph_maxValues,graph_maxHeight = 50,50
local fps = 0
local minmax_delay = 3
local gfxRestart = {}
local gameRestart = {}

local options = {
	-- options for tt2_normal & tt2_advanced
	["displaymode"] = {
		{label=VIDEO_OPTIONS_WINDOWED,            gxWindow=1,gxMaximize=0},
		{label=VIDEO_OPTIONS_WINDOWED_FULLSCREEN, gxWindow=1,gxMaximize=1},
		{label=VIDEO_OPTIONS_FULLSCREEN,          gxWindow=0,gxMaximize=0}
	},
	["texturedetails"] = {
		{label=VIDEO_OPTIONS_LOW,    terrainMipLevel=1, componentTextureLevel=1, worldBaseMip=2},
		{label=VIDEO_OPTIONS_FAIR,   terrainMipLevel=1, componentTextureLevel=1, worldBaseMip=1},
		{label=VIDEO_OPTIONS_MEDIUM, terrainMipLevel=0, componentTextureLevel=0, worldBaseMip=1},
		{label=VIDEO_OPTIONS_HIGH,   terrainMipLevel=0, componentTextureLevel=0, worldBaseMip=0}
	},
	["textureFilteringMode"] = {
		{label=VIDEO_OPTIONS_BILINEAR,       textureFilteringMode=0},
		{label=VIDEO_OPTIONS_TRILINEAR,      textureFilteringMode=1},
		{label=VIDEO_OPTIONS_2XANISOTROPIC,  textureFilteringMode=2},
		{label=VIDEO_OPTIONS_4XANISOTROPIC,  textureFilteringMode=3},
		{label=VIDEO_OPTIONS_8XANISOTROPIC,  textureFilteringMode=4},
		{label=VIDEO_OPTIONS_16XANISOTROPIC, textureFilteringMode=5}
	},
	["gfxapi"] = {
		{label="DirectX 9",  gxapi="D3D9",  check=(IsWindowsClient() and IsLinuxClient()==nil)},
		{label="DirectX 11", gxapi="D3D11", check=(IsWindowsClient() and IsLinuxClient()==nil)},
		{label="OpenGL",     gxapi="OpenGL"}
	},
	["sunshafts"] = {
		{label=VIDEO_OPTIONS_DISABLED, sunshafts=0},
		{label=VIDEO_OPTIONS_LOW,      sunshafts=1},
		{label=VIDEO_OPTIONS_HIGH,     sunshafts=2}
	},
	["ssao"] = {
		{label=VIDEO_OPTIONS_DISABLED, ssao=0},
		{label=VIDEO_OPTIONS_LOW,      ssao=1},
		{label=VIDEO_OPTIONS_HIGH,     ssao=2}
	},

	-- unclear
	["farclip"] = { -- ??
		{label=VIDEO_OPTIONS_LOW,    farClip=0,    wmoLodDist=0,   terrainLodDist=0,   terrainTextureLod=0},
		{label=VIDEO_OPTIONS_FAIR,   farClip=600,  wmoLodDist=300, terrainLodDist=300, terrainTextureLod=1},
		{label=VIDEO_OPTIONS_MEDIUM, farClip=800,  wmoLodDist=400, terrainLodDist=450, terrainTextureLod=1},
		{label=VIDEO_OPTIONS_HIGH,   farClip=1000, wmoLodDist=500, terrainLodDist=500, terrainTextureLod=0},
		{label=VIDEO_OPTIONS_ULTRA,  farClip=1300, wmoLodDist=650, terrainLodDist=650, terrainTextureLod=0}
	},

	-- options for tt2_normal only
	["environmentDetail"] = {
		{label=VIDEO_OPTIONS_LOW,    environmentDetail=50},
		{label=VIDEO_OPTIONS_FAIR,   environmentDetail=75},
		{label=VIDEO_OPTIONS_MEDIUM, environmentDetail=100},
		{label=VIDEO_OPTIONS_HIGH,   environmentDetail=125},
		{label=VIDEO_OPTIONS_ULTRA,  environmentDetail=150}
	},
	["shadowquality"] = { 
		{label=VIDEO_OPTIONS_LOW,    shadowMode=0},
		{label=VIDEO_OPTIONS_FAIR,   shadowMode=1, shadowTextureSize=1024},
		{label=VIDEO_OPTIONS_MEDIUM, shadowMode=1, shadowTextureSize=2048},
		{label=VIDEO_OPTIONS_HIGH,   shadowMode=2, shadowTextureSize=2048},
		{label=VIDEO_OPTIONS_ULTRA,  shadowMode=3, shadowTextureSize=2048}
	},
	["liquiddetails"] = {
		{label=VIDEO_OPTIONS_LOW,    waterDetail=0},
		{label=VIDEO_OPTIONS_FAIR,   waterDetail=1, reflectionMode=0, rippleDetail=0},
		{label=VIDEO_OPTIONS_MEDIUM, waterDetail=2, reflectionMode=1, rippleDetail=0},
		{label=VIDEO_OPTIONS_ULTRA,  waterDetail=3, reflectionMode=2, rippleDetail=1}
	},
	["groundclutter"] = {
		{label=VIDEO_OPTIONS_LOW,    groundEffectDist=70,  groundEffectDensity=16},
		{label=VIDEO_OPTIONS_FAIR,   groundEffectDist=110, groundEffectDensity=40},
		{label=VIDEO_OPTIONS_MEDIUM, groundEffectDist=160, groundEffectDensity=64},
		{label=VIDEO_OPTIONS_HIGH,   groundEffectDist=200, groundEffectDensity=80},
		{label=VIDEO_OPTIONS_ULTRA,  groundEffectDist=260, groundEffectDensity=128}
	},
	["particledensity"] = {
		{label=VIDEO_OPTIONS_LOW,    particleDensity=10,  weatherDensity=0},
		{label=VIDEO_OPTIONS_FAIR,   particleDensity=40,  weatherDensity=1},
		{label=VIDEO_OPTIONS_MEDIUM, particleDensity=60,  weatherDensity=1},
		{label=VIDEO_OPTIONS_HIGH,   particleDensity=80,  weatherDensity=2},
		{label=VIDEO_OPTIONS_ULTRA,  particleDensity=100, weatherDensity=3}
	},

	-- options for tt2_advanced only
}

local tt2_normal = {
	{head  = DISPLAY_HEADER},
	{sep   = true},
	{label = DISPLAY_MODE,				option = "displaymode", gxRestart=true},
	{label = VERTICAL_SYNC,				boolean   = "gxVSync", gxRestart=true},

	{sep   = {3,0,0,0,0}},
	{head  = TEXTURES_SUBHEADER},
	{sep   = true},
	{label = TEXTURE_DETAIL,			option = "texturedetails"},
	{label = ANISOTROPIC,				option = "textureFilteringMode"},
	{label = PROJECTED_TEXTURES,		boolean   = "projectedTextures"},

	{sep   = {3,0,0,0,0}},
	{head  = EFFECTS_SUBHEADER},
	{sep   = true},
	{label = SHADOW_QUALITY,			option = "shadowquality"},
	{label = LIQUID_DETAIL,				option = "liquiddetails"},
	{label = SUNSHAFTS,					option = "sunshafts"},
	{label = PARTICLE_DENSITY,			option = "particledensity"},
	{label = SSAO_LABEL,				option = "ssao"},

	{sep   = {3,0,0,0,0}},
	{head  = ENVIRONMENT_SUBHEADER},
	{sep   = true},
	{label = FARCLIP,					option = "farclip"},
	{label = ENVIRONMENT_DETAIL,		option = "environmentDetail"},
	{label = GROUND_CLUTTER,			option = "groundclutter"},

	{sep   = {3,0,0,0,0}},
	{head  = CAMERA_LABEL},
	{sep   = true},
	{label = FOLLOW_TERRAIN,			boolean   = "cameraTerrainTilt"},
	{label = HEAD_BOB,					boolean   = "cameraBobbing"},
	{label = WATER_COLLISION,			boolean   = "cameraWaterCollision"},
	{label = SMART_PIVOT,				boolean   = "cameraPivot"},

	{sep   = {3,0,0,0,0}},
	{head  = EFFECTS_LABEL},
	{sep   = true},
	{label = TRIPLE_BUFFER,				boolean   = "gxTripleBuffer", gxRestart=true},
	{label = FIX_LAG,					boolean   = "gxFixLag", gxRestart=true},
	{label = HARDWARE_CURSOR,			boolean   = "gxCursor", gxRestart=true},
	{label = GXAPI,						option    = "gfxapi", gameRestart=true},
}
--[[
local tt2_advanced = {
	{head  = DISPLAY_HEADER},
	{sep   = true},
	{label = DISPLAY_MODE,				option = "displaymode", gxRestart=true},
	{label = VERTICAL_SYNC,				boolean   = "gxVSync", gxRestart=true},

	{sep   = {3,0,0,0,0}},
	{head  = TEXTURES_SUBHEADER},
	{sep   = true},
	{label = TEXTURE_DETAIL,			option = "texturedetails"},
	{label = ANISOTROPIC,				option = "textureFilteringMode"},
	{label = PROJECTED_TEXTURES,		boolean   = "projectedTextures"},

	{sep   = {3,0,0,0,0}},
	{head  = EFFECTS_SUBHEADER},
	{sep   = true},
	{label = SHADOW_QUALITY,			option = "shadowquality"},
	{label = LIQUID_DETAIL,				option = "liquiddetails"},
	{label = SUNSHAFTS,					option = "sunshafts"},
	{label = PARTICLE_DENSITY,			option = "particledensity"},
	{label = SSAO_LABEL,				option = "ssao"},

	{sep   = {3,0,0,0,0}},
	{head  = ENVIRONMENT_SUBHEADER},
	{sep   = true},
	{label = FARCLIP,					option = "farclip"},
	{label = ENVIRONMENT_DETAIL,		option = "environmentDetail"},
	{label = GROUND_CLUTTER,			option = "groundclutter"},

	{sep   = {3,0,0,0,0}},
	{head  = CAMERA_LABEL},
	{sep   = true},
	{label = FOLLOW_TERRAIN,			boolean   = "cameraTerrainTilt"},
	{label = HEAD_BOB,					boolean   = "cameraBobbing"},
	{label = WATER_COLLISION,			boolean   = "cameraWaterCollision"},
	{label = SMART_PIVOT,				boolean   = "cameraPivot"},

	{sep   = {3,0,0,0,0}},
	{head  = EFFECTS_LABEL},
	{sep   = true},
	{label = TRIPLE_BUFFER,				boolean   = "gxTripleBuffer", gxRestart=true},
	{label = FIX_LAG,					boolean   = "gxFixLag", gxRestart=true},
	{label = HARDWARE_CURSOR,			boolean   = "gxCursor", gxRestart=true},
	{label = GXAPI,						option    = "gfxapi", gameRestart=true},
}
]]

-- ------------------------------------- --
-- register icon names and default files --
-- ------------------------------------- --
I[name..'_yellow'] = {iconfile="Interface\\Addons\\"..addon.."\\media\\fps_yellow"}
I[name..'_red']    = {iconfile="Interface\\Addons\\"..addon.."\\media\\fps_red"}
I[name..'_blue']   = {iconfile="Interface\\Addons\\"..addon.."\\media\\fps_blue"}
I[name..'_green']  = {iconfile="Interface\\Addons\\"..addon.."\\media\\fps_green"}


---------------------------------------
-- module variables for registration --
---------------------------------------
local module = {
	desc = L["Broker to show your frames per second."],
	icon_suffix = "_blue",
	events = {},
	updateinterval = 1,
	config_defaults = nil,
	config_allowed = nil,
	config = nil -- {}
}


--------------------------
-- some local functions --
--------------------------
local function minmax(f)
	if minmax_delay~=0 then minmax_delay = minmax_delay - 1 return end
	if (not _minmax[1]) or _minmax[1] > f then _minmax[1]=f end
	if (not _minmax[2]) or _minmax[2] < f then _minmax[2]=f end
end

local function fps_color(f)
	if not f then return {"","","?"} end
	local c = (f<20 and {"_red","red"}) or (f<30 and {"_yellow","dkyellow"}) or (f<100 and {"_green","green"}) or {"_blue","ltblue"}
	table.insert(c,C(c[2],f)..C("suffix","fps"))
	return c
end

function module.onqtip(tt)
	if  not tt  or  tt.key ~= module.name  then  return  end

	tt:Clear()
	tt:SetColumnLayout(2, "LEFT", "RIGHT")
	tt:AddHeader(C("dkyellow",L[name]))
	tt:AddSeparator()
	tt:AddLine(L["Current"]..":",fps_color(fps)[3])
	tt:AddSeparator(3,0,0,0,0)
	tt:AddLine(L["Min."]..":",fps_color(_minmax[1])[3])
	tt:AddLine(L["Max."]..":",fps_color(_minmax[2])[3])

	--[[
	local l, c, cell
	tt:AddSeparator(3,0,0,0,0)
	l,c = tt:AddLine()
	tt:SetCell(l,1,"",nil,nil,2)
	local cell = tt.lines[l].cells[1]

	local f = ns.tooltipGraph(name,graph_maxValues,graph_maxHeight,true)
	f:SetParent(cell)
	f:SetPoint("TOPLEFT", cell,"TOPLEFT", 0, 0)
	cell:SetWidth(f:GetWidth())
	cell:SetHeight(f:GetHeight())
	]]

	--if Broker_EverythingDB.showHints then
	if false then
		tt:AddLine(" ")
		tt:AddLine(C("copper",L["Click"]).." ||",C("green",L["Open graphics set manager"]))
		tt:AddLine(C("copper",L["Right-Click"]).." ||",C("green",L["Open graphics menu"]))
	end
end

local function graphicsSetManager(display)
	local tt2, reused = ns.LQT:Acquire(name.."TT2", 1, "LEFT")
	ns.attachTooltip(module, tt2)

	tt2:Clear()
	
	-- tt2:SetScript('OnEnter', function() end)

	tt2:AddHeader(C("ltblue","Graphics set manager"))
	tt2:AddSeparator()
	tt2:AddLine(L["No set found"])

	if Broker_EverythingDB.showHints then
		tt2:AddLine(" ")
		line, column = tt2:AddLine()
		tt2:SetCell(line, 1,
			C("ltblue",L["Click"]).." || "..C("green",L["Use a set"])
			.."|n"..
			C("ltblue",L["Shift+Click"]).." || "..C("green",L["Update/save a set"])
			.."|n"..
			C("ltblue",L["Ctrl+Click"]).." || "..C("green",L["Delete a set"])
			, nil, nil, 1)
	end

	ns.createTooltip(display,tt2,true)
end

local function checkSelection(selName)
	local bool,cvars=true,{}
	for i,v in ipairs(options[selName]) do
		bool=true
		for I,V in pairs(v) do
			if I~="label" and I~="check" then
				if selName=="gfxapi" then
					if cvars[I]==nil then cvars[I] = strlower(GetCVar(I)) end -- reduce call of GetCVar
					V=strlower(V)
				else
					if cvars[I]==nil then cvars[I] = tonumber(GetCVar(I)) end -- reduce call of GetCVar
				end
				if cvars[I]~=V then bool=false end
			end
		end
		if bool==true then
			return v.label
		end
	end
	return C("gray",VIDEO_QUALITY_LABEL6)
end

local function setSelection(selName,index)
end

local function graphicsMenuSelection(lineFrame,selName)
	tt3 = ns.LQT:Acquire(name.."TT3", 1, "LEFT")
	tt3:Clear()

	local l,c
	for i,v in ipairs(options[selName]) do
		if v.label~=nil then
			l,c = tt3:AddLine(v.label)
			tt3:SetLineScript(l,"OnMouseUp",function()
				setSelection(selName,i)
			end)
		end
	end

	ns.createTooltip(lineFrame,tt3,true)
	tt3:ClearAllPoints()
	tt3:SetPoint("LEFT",tt2,"RIGHT",-15,0)
	tt3:SetPoint("TOP",lineFrame,"TOP",0,5)
	tt3:SetFrameLevel(tt2:GetFrameLevel()+3)
end

local function graphicsMenu(display)
	-- ns.hideTooltip(module.tooltip,nil,true)

	local tt2, reused = ns.LQT:Acquire(name.."TT2", 2, "LEFT", "RIGHT")
	ns.attachTooltip(module, tt2)
	-- module.tooltip = tt2
	-- tt2:SetScript('OnLeave', function() ns.hideTooltip(tt2, nil) end)
	tt2:Clear()

	local l,c
	for i,v in ipairs(tt2_normal) do
		if v.head~=nil then
			tt2:AddLine(C("ltblue",v.head))
		elseif v.sep==true then
			tt2:AddSeparator()
		elseif v.sep~=nil then
			tt2:AddSeparator(unpack(v.sep))
		elseif v.label~=nil then
			l,c = tt2:AddLine()
			tt2:SetCell(l,1,C("ltyellow",v.label))
			if v.boolean~=nil then
				tt2:SetCell(l,2, GetCVar(v.boolean)=="1" and C("green",VIDEO_OPTIONS_ENABLED) or C("red",VIDEO_OPTIONS_DISABLED))
				tt2:SetLineScript(l,"OnMouseUp",function(lineFrame,button) ns.SetCVar(v.boolean,GetCVar(v.boolean)=="1" and "0" or "1") graphicsMenu(display) end)
			elseif v.option~=nil then
				tt2:SetCell(l,2,checkSelection(v.option))
				tt2:SetLineScript(l,"OnEnter",function(lineFrame)
					graphicsMenuSelection(lineFrame,v.option)
					-- Not pragmatic, but serves the purpose:
					tt2:SetAutoHideDelay(0.001, tt3)
				end)
				--[[ tt3:SetAutoHideDelay(0.001, tooltip.owner) in ns.createTooltip(lineFrame,tt3,true)
				tt2:SetLineScript(l,"OnLeave", function(lineFrame)
					ns.hideTooltip(tt3, nil)
				end)
				--]]
			else
				tt2:SetCell(l,2,C("gray","?"))
			end
		end
	end

	ns.createTooltip(display,tt2,true)
end

local function getSettings()
	
end

------------------------------------
-- module (BE internal) functions --
------------------------------------

module.onupdate = function(module)
	fps = floor(GetFramerate())
	local c = fps_color(fps)
	local obj = module.obj

	minmax(fps)
	--ns.tooltipGraphAddValue(name,fps,graph_maxValues)

	local icon = I(name..c[1])
	obj.iconCoords = icon.coords or {0,1,0,1}
	obj.icon = icon.iconfile
	obj.text = c[3]

	module.onqtip(module.tooltip)
end

-------------------------------------------
-- module functions for LDB registration --
-------------------------------------------
module.onenter = function(display)
	if  tt2  and  tt2.key == tt2Name  and  tt2:IsShown()  then  return  end
	ns.defaultOnEnter(module, display)
end

module.mouseOverTooltip = nil

module.onclick = function(display,button)
	if button == "LeftButton" then
		graphicsSetManager(display)
	elseif button == "RightButton" then
		graphicsMenu(display)
	end
end


-- final module registration --
-------------------------------
ns.modules[name] = module

