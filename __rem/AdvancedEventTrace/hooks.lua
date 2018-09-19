local AddOnName,E=...
local AddOn=E[1]
local H=AddOn:NewModule("Hooks","AceEvent-3.0","AceHook-3.0")
local UH=H:NewModule("UserHooks","AceEvent-3.0","AceHook-3.0")

local EventTraceFrame_OnEvent=EventTraceFrame_OnEvent
local tremove,pairs,getmetatable,tostring,setmetatable,type,wipe,loadstring,pcall,debugstack,select,error=tremove,pairs,getmetatable,tostring,setmetatable,type,wipe,loadstring,pcall,debugstack,select,error

local STACK_BASE_LEVEL=4
local TRUNCATE_PARTS={
	{"Interface\\Add"			,	"(%.%.%.[%a\\]*)Ons\\.+"		},
	{"Interface\\Frame"			,	"(%.%.%.[%a\\]*)XML\\.+"		},
	{"Interface\\Addons\\Blizz"	,	"(%.%.%.[%a\\]*)ard_%a*\\.+"	},
}
local TRUNCATE_NUM=#TRUNCATE_PARTS
local Function,Method,Script="Function","Method","Script"
local numWhitelists=0
local hookType,objectName,object,methodOrScriptName=Function,nil,nil,nil
H.DELIMS={
	Function="",
	Method=".",
	Script="~",
}

local db
local config={
	get=function(info)return db[info[#info]]end,
	set=function(info,value)db[info[#info]]=value end,
	order=3,
	name="Hooks",
	desc="Options for displaying function, method, and script calls in ETF",
	type="group",
	args={
		activeWhitelist={
			order=1,
			name="Active whitelist",
			type="select",
			values={},
			set=function(info,value)db[info[#info]]=value H:UpdateWhitelist(true,true)end,
		},
		removeWhitelist={
			order=2,
			name="Delete this whitelist",
			type="execute",
			func=function()H:DeleteWhitelist()end,
			confirm=function()return ("Delete %s?"):format(db.activeWhitelist)end,
			hidden=function()return numWhitelists<=1 end,
		},
		newHook={
			order=3,
			name="Add new hook",
			type="group",
			args={
				hookType={
					order=1,
					name="Type",
					type="select",
					values={
						Function=Function,
						Method=Method,
						Script=Script,
					},
					set=function(info,value)hookType=value H:GetObject(objectName or "")methodOrScriptName=nil if value==Function or objectName=="_G" then objectName,object=nil,nil end end,
					get=function(info)return hookType end,
				},
				objectToHook={
					order=2,
					name="Object",
					type="input",
					set=function(info,value)methodOrScriptName=nil end,
					get=function(info)return objectName end,
					hidden=function(info)return hookType~=Method and hookType~=Script end,
					validate=function(info,value)return H:GetObject(value:trim())end
				},
				methodToHook={
					order=3,
					name=function()return hookType end,
					type="input",
					set=function(info,value)methodOrScriptName=strmatch(value:trim(),"^([%a_][%w_]*)%(?%)?$")end,
					get=function(info)return methodOrScriptName end,
					disabled=function(info)return hookType==Method and (not object or not objectName) end,
					hidden=function(info)return hookType~=Function and hookType~=Method end,
					validate=function(info,value)return H:ValidateMethodOrScript(value:trim()) end,
				},
				scriptToHook={
					order=4,
					name=function()return hookType end,
					type="select",
					values={},
					set=function(info,value)methodOrScriptName=value:trim()end,
					get=function(info)return methodOrScriptName end,
					disabled=function(info)return not object or not objectName end,
					hidden=function(info)return hookType~=Script end,
					validate=function(info,value)return H:ValidateMethodOrScript(value:trim()) end,
				},
				add={
					order=5,
					name=function()return ("Add %s"):format(hookType)end,
					desc="Activate this hook",
					type="execute",
					func=function(info)H:AddHook()end,
					disabled=function(info)return ((hookType==Method or hookType==Script) and (not object or not objectName)) or not methodOrScriptName end,
				},
			},
		},
		activeHooks={
			order=4,
			name="Active hooks",
			desc="Hooks that will show up in ETF",
			type="group",
			args={},
		},
		inactiveHooks={
			order=5,
			name="Inactive hooks",
			desc="Hooks that were not loaded because the function, method, or script did not exist previously",
			type="group",
			args={},
		},
		reHook={
			order=6,
			name="Refresh hooks",
			desc="Re-hook functions, methods, or scripts that may have been re-created or re-assigned",
			type="group",
			args={
				all={
					order=1,
					name="Re-hook all",
					desc="Re-hooks inactive and active hooks",
					type="execute",
					func=function(info)H:UpdateWhitelist()end,
				},
				-- inactive={
					-- order=2,
					-- name="Re-hook inactive",
					-- type="execute",
					-- func=function(info)H:UpdateWhitelist()end,
				-- },
				-- active={
					-- order=3,
					-- name="Re-hook active",
					-- type="execute",
					-- func=function(info)H:UpdateWhitelist()end,
				-- },
			},
		},
		addWhitelist={
			order=7,
			name="Create new whitelist",
			type="group",
			args={
				add={
					order=1,
					name="Whitelist name",
					type="input",
					set=function(info,value)H:AddWhitelist(value:trim())end,
				},
			},
		},
		callStack={
			order=8,
			name="Call stack",
			desc="Options for displaying the stack trace for function and method hooks",
			type="group",
			disabled=function(info)return info[#info]~="callStack" and not db.showStack end,
			args={
				showStack={
					order=1,
					name="Show stack",
					desc="Enables recording of the stack trace, which will display in the ETF tooltip",
					type="toggle",
					disabled=false,
				},
				stackDescend={
					order=2,
					name="Invert display",
					desc="If checked, the top of the stack will display at the bottom of the tooltip",
					type="toggle",
				},
				includeCrap={
					order=3,
					name="Include unknown calls",
					desc="If checked, \"[C]: ?\" and \"(tail call): ?\" elements will not be removed from the display",
					type="toggle",
				},
				elements={
					order=4,
					name="Elements",
					desc="Options for changing how much of the stack trace is shown",
					type="group",
					args={
						stackOffset={
							order=1,
							name="Offset",
							desc="An offset of -1 will show the top of the stack as the hooked function itself. Each additional unit of offset will remove one element from the top of the stack when recording the stack trace.",
							type="range",
							min=-1,
							max=100,
							softMax=5,
							step=1,
						},
						stackTop={
							order=2,
							name="Top",
							type="range",
							min=-1,
							max=100,
							softMax=10,
							step=1,
							hidden=true,
						},
						stackBottom={
							order=3,
							name="Bottom",
							type="range",
							min=-1,
							max=100,
							softMax=10,
							step=1,
							hidden=true,
						},
					},
				},
				textTrimming={
					order=5,
					name="Text trimming",
					type="group",
					args={
						fullStringWrappers={
							order=1,
							name="Wrap loaded strings",
							desc="If unchecked, text like [string \"return func()\"] will be displayed as \"return func()\"",
							type="toggle",
						},
						hideDirectories={
							order=2,
							name="Hide all directories",
							desc="If checked, everything except file names will be stripped from all displayed file paths",
							type="toggle",
						},
						fullFileNames={
							order=3,
							name="Show full file names",
							desc="If unchecked, \"Interface\\Addons\\\", \"Interface\\Addons\\Blizzard_%a*\\\", and \"Interface\\FrameXML\\\" will be stripped from all displayed file paths",
							type="toggle",
							disabled=function()return db.hideDirectories end,
						},
						fullLibs={
							order=4,
							name="Show lib directories",
							desc="If unchecked, parent directory names will be stripped from apparent library files' file paths",
							type="toggle",
							disabled=function()return db.hideDirectories end,
						},
					},
				},
			},
		},
	},
}

function H:OnInitialize()
	AddOn.options.args.hooks=config
	db=E.db.hooks
	
	H.stacks={}
	
	H:SecureHook("EventTraceFrame_OnEvent")
	H:SecureHook("EventTraceFrame_Update")
	H:SecureHook("EventTraceFrame_RemoveEvent")
	H:SecureHook("EventTraceFrameEvent_DisplayTooltip")
	
	H:GenerateWhitelistNames()
	
	H:RegisterEvent("PLAYER_LOGIN")
end

function H:PLAYER_LOGIN()
	H:UpdateWhitelist()
	H:UnregisterEvent("PLAYER_LOGIN")
end

function H:AddToTables(displayName,objectName,methodOrScriptName,addToDB,active)
	if addToDB then
		H:GetActiveWhitelist()[displayName]={
			hookType=hookType,
			objectName=objectName,
			methodOrScriptName=methodOrScriptName,
		}
	end
	config.args[active and "activeHooks" or "inactiveHooks"].args[displayName]={
		order=AddOn:HashCode(displayName),
		name=displayName,
		type="group",
		args={
			delete={
				order=1,
				name="Remove from Whitelist",
				type="execute",
				func=function()H:RemoveHook(displayName,objectName,methodOrScriptName)end,
				confirm=function()return ("Remove %s from %s?"):format(displayName,db.activeWhitelist)end,
			},
		},
	}
end

function H:AddWhitelist(name)
	db.whitelists[name]={}
	config.args.activeWhitelist.values[name]=name
	numWhitelists=numWhitelists+1
	db.activeWhitelist=name
	H:UpdateWhitelist()
	AddOn:Status(("Created hook Whitelist %s"):format(name))
end

function H:EventTraceFrame_OnEvent(self,event,...)
	if self.lastIndex>EVENT_TRACE_MAX_ENTRIES then
		local staleIndex=self.lastIndex-EVENT_TRACE_MAX_ENTRIES
		H.stacks[staleIndex]=nil
	end
end

function H:EventTraceFrame_RemoveEvent(i)
	if i>=1 and i<E.ETF.lastIndex then
		tremove(H.stacks,i)
	end
end

function H:EventTraceFrame_Update()
	
end

function H:EventTraceFrameEvent_DisplayTooltip(eventButton)
	if db.showStack then
		local stack=H.stacks[eventButton.index]
		if stack then
			E.TT:AddDoubleLine("Called at:","In Function:")
			local desc=db.stackDescend
			local size=#stack
			for i=(desc and size or 1),(desc and 1 or size),(desc and -1 or 1) do
				E.TT:AddDoubleLine(stack[i][1],stack[i][2],1,1,1,1,1,1)
			end
			E.TT:Show()
		end
	end
end

function H:DisplayName(hookType,objectName,methodOrScriptName)
	return ("%s%s%s%s"):format(objectName,H.DELIMS[hookType],methodOrScriptName,(hookType==Function or hookType==Method) and "()" or "")
end

function H:AddHook()
	local displayName=H:DisplayName(hookType,object~=_G and objectName or "",methodOrScriptName)
	if db.whitelists[db.activeWhitelist][displayName] then
		AddOn:Status(("%s is already being traced."):format(displayName))
		return
	end
	H:DoHook(hookType,objectName,object,methodOrScriptName,displayName)
	H:AddToTables(displayName,objectName,methodOrScriptName,true,true)
	AddOn:Status(("Added %s to hooks Whitelist"):format(displayName))
	objectName,object,methodOrScriptName=nil,nil,nil
end

function H:DeleteWhitelist()
	local name=db.activeWhitelist
	db.whitelists[name]=nil
	config.args.activeWhitelist.values[name]=nil
	numWhitelists=numWhitelists-1
	for newName,_ in pairs(db.whitelists)do
		db.activeWhitelist=newName
		break
	end
	H:UpdateWhitelist()
	AddOn:Status(("Deleted hook Whitelist %s"):format(name))
end

function H:DoHook(hookType,objectName,object,methodOrScriptName,displayName)
	local mt=getmetatable(object) or {}
	local defaultToString=mt.__tostring and mt.__tostring(object) or tostring(object)
	mt.__tostring=function(...)return H:ToString(defaultToString)end
	setmetatable(object,mt)
	local hookFunc=function(...)return H:ReportCall(hookType,methodOrScriptName,displayName,...)end
	UH[hookType==Script and "SecureHookScript" or "SecureHook"](UH,object,methodOrScriptName,hookFunc)
end

function H:FilterScripts()
	if hookType~=Script then return end
	local t=config.args.newHook.args.scriptToHook.values
	if not object or type(object.HasScript)~="function" then
		wipe(t)
		return
	end
	for scriptName,_ in pairs(E.SCRIPTS) do
		t[scriptName]=object:HasScript(scriptName) and scriptName or nil
	end
end

function H:GenerateWhitelistNames()
	local t=config.args.activeWhitelist.values
	wipe(t)
	numWhitelists=0
	for k,_ in pairs(db.whitelists)do
		t[k]=k
		numWhitelists=numWhitelists+1
	end
end

function H:GetActiveWhitelist()
	return db.whitelists[db.activeWhitelist]
end

function H:GetObject(objectString,thisHookType)
	objectName,object=nil,nil
	AddOn:UpdateFrame()
	local discard=thisHookType and true
	thisHookType=thisHookType or hookType
	if thisHookType==Function then
		return discard and _G or nil
	end
	if not objectString or objectString=="" then
		--AddOn:Status(format("You cannot hook a %s without an object",thisHookType))
		return
	end
	local thisObjectName,thisObject
	if objectString:match("^[%a_][%w_]*$") then
		thisObjectName=objectString
		thisObject=_G[thisObjectName]
	else
		local func,loadErr=loadstring("return "..objectString)
		if not func then
			if not discard then
				local shortErr=loadErr:match("%[string \"return .+\"%]:1: (.+)")
				AddOn:Status(("\"%s\" has syntax errors: %s"):format(objectString,shortErr or loadErr))
			end
			return
		end
		local success,arg1=pcall(func)
		if not success then
			if not discard then
				local shortErr=arg1:match("%[string \"return .+\"%]:1: (.+)")
				AddOn:Status(("\"%s\" could not be loaded: %s"):format(objectString,shortErr or arg1))
			end
			return
		end
		thisObject=arg1
	end
	if thisObject==_G then
		if not discard then
			hookType=Function
			object=nil
			objectName=thisObjectName
		end
		return _G
	end
	local datatype=type(thisObject)
	if datatype~="table" and datatype~="userdata" then
		AddOn:Status(("%s is of type %s and cannot have %ss"):format(objectString,datatype,thisHookType:lower()))
		return
	end
	if E.RESERVED.Object[thisObject] then
		AddOn:Status(("For addon stability, %s cannot be hooked"):format(objectString))
		return
	end
	if thisHookType==Script and (type(thisObject.IsObjectType)~="function" or not thisObject:IsObjectType("Object") or type(thisObject.HasScript)~="function")then
		thisObjectName=nil
		AddOn:Status(("%s cannot have scripts"):format(objectString))
		return
	end
	thisObjectName=thisObjectName or (type(thisObject.GetName)=="function" and thisObject:GetName()) or tostring(thisObject)
	if type(thisObjectName)~="string" or thisObjectName:find(("^%s: %%x%%x%%x%%x%%x%%x%%x%%x%%x%%x%%x%%x%%x%%x%%x%%x$"):format(datatype)) or _G[thisObjectName]~=thisObject or thisObjectName:trim()=="" then
		thisObjectName=objectString
	end
	AddOn:Status()
	if not discard then
		objectName=thisObjectName
		object=thisObject
	end
	H:FilterScripts()
	return thisObject
end

function H:GuessTruncated(stackLine)
	for i=1,TRUNCATE_NUM do
		local parts=TRUNCATE_PARTS[i]
		local prefix=parts[1]
		for i=1,2 do
			local trunc=stackLine:match(parts[2])
			if not trunc then
				return stackLine
			end
			local length=3-#trunc
			if length==0 or prefix:sub(length)==trunc:sub(length) then
				stackLine=stackLine:gsub(trunc,prefix)
			end
		end
	end
	return stackLine
end

function H:RemoveHook(displayName,objectName,methodOrScriptName)
	H:GetActiveWhitelist()[displayName]=nil
	config.args.activeHooks.args[displayName]=nil
	config.args.inactiveHooks.args[displayName]=nil
	local object=objectName and _G[objectName]
	pcall(UH.Unhook,UH,object,methodOrScriptName)
	AddOn:Status(("Removed %s from hooks Whitelist"):format(displayName))
end

function H:ReportCall(hookType,methodOrScriptName,displayName,...)
	if E.ETF.started then
		EventTraceFrame_OnEvent(E.ETF,displayName,...)
		if hookType~=Script and db.showStack then
			H.stacks[E.ETF.lastIndex]=H:SplitStack(methodOrScriptName,("\n"):split(debugstack(STACK_BASE_LEVEL,100,100)))
		end
	end
end

function H:SplitStack(methodOrScriptName,...)
	local stack={}
	for i=1,select("#",...)-1 do --strsplit says there is an extra \n at the end of the debugstack
		--[[Known Formats]]--
		--left side:
			--filePath\\fileName:line:
			--...ePath\\fileName:line:
			--[C]:
			--[string "funcString"]:line:
		--right side (in function):
			--<[string "funcString"]:line>
			--<filePath\\fileName:line>
			--<...ePath\\fileName:line>
			--`functionName'
			--`?'
		--others:
			--[C]: ?
			--(tail call): ?
			--...
			--Called at: in main chunk
		
		local left,right
		local stackLine=select(i,...)
		if stackLine=="..." then
			left,right=stackLine,stackLine
		else
			if db.hideDirectories then
				stackLine=stackLine:gsub("[^ :%?\"`'%[%]<>\\]+\\","")
			else
				if not db.fullLibs then
					stackLine=stackLine:gsub("[^ :%?\"`'%[%]<>]*[%.\\][Ll]ibs?\\","")
				end
				stackLine=H:GuessTruncated(stackLine)
				if not db.fullFileNames then
					stackLine=stackLine:gsub("Interface\\AddOns\\Blizzard_%a*\\","")
					stackLine=stackLine:gsub("Interface\\AddOns\\","")
					stackLine=stackLine:gsub("Interface\\FrameXML\\","")
				end
			end
			left,right=stackLine:match("^(.*): in (.*)$")
			if right and right~="main chunk" then
				right=right:match("^function [<`](.*)['>]$")
			end
			if not db.fullStringWrappers then
				if left then
					local str,line=left:match("^%[string (\".*\")%](:%d)$")
					left=str and line and str..line or left
				end
				if right then
					local str,line=right:match("^%[string (\".*\")%](:%d)$")
					right=str and line and str..line or right
				end
			end
			if (not left or not right) and db.includeCrap then
				left,right=stackLine:match("^([^:]*): ([^:]*)$")
			end
		end
		if left and right then
			tinsert(stack,{left,right})
		elseif stackLine~="[C]: ?" and stackLine~="(tail call): ?" then
			error("Unknown call stack syntax: "..stackLine)
		end
	end
	if db.includeCrap then
		while true do
			local top=stack[1]
			if not top or top[2]~="?" then
				break
			end
			tremove(stack,1)
		end
	end
	local toremove=db.stackOffset+1
	while toremove>0 do
		tremove(stack,1)
		toremove=toremove-1
	end
	return stack
end

function H:ToString(default)
	if debugstack(STACK_BASE_LEVEL,1,0)=="...e\\AddOns\\Blizzard_DebugTools\\Blizzard_DebugTools.lua:386: in function <...e\\AddOns\\Blizzard_DebugTools\\Blizzard_DebugTools.lua:378>\n...\n" then
		return "self"
	else
		return default
	end
end

function H:UpdateWhitelist()
	wipe(config.args.activeHooks.args)
	wipe(config.args.inactiveHooks.args)
	UH:UnhookAll()
	for displayName,v in pairs(H:GetActiveWhitelist())do
		local hookType,objectName,methodOrScriptName=v.hookType,v.objectName,v.methodOrScriptName
		local active,err
		local object=H:GetObject(objectName,hookType)
		if object then
			active,err=pcall(H.DoHook,H,hookType,objectName,object,methodOrScriptName,displayName)
		end
		H:AddToTables(displayName,objectName,methodOrScriptName,false,active)
	end
	AddOn:Status()
end

function H:ValidateMethodOrScript(methodOrScriptString)
	methodOrScriptName=nil
	AddOn:UpdateFrame()
	if not methodOrScriptString or methodOrScriptString=="" then
		return
	end
	if hookType==Script then
		if object and (not object.HookScript or not type(object.HasScript)=="function" or not object:HasScript(methodOrScriptString)) then
			AddOn:Status(("%s cannot have a handler of type %s"):format(objectName,methodOrScriptString))
			return
		end
		local objectReservedTable=E.RESERVED.Script[object]
		if objectReservedTable and objectReservedTable[methodOrScriptString] then
			AddOn:Status(("For addon stability, %s%s%s cannot be hooked"):format(objectName,H.DELIMS.Script,methodOrScriptString))
			return
		end
	else
		local cleanString=(methodOrScriptString):match("^([%a_][%w_]*)%(?%)?$")
		if not cleanString then
			AddOn:Status(("%s contains invalid characters"):format(methodOrScriptString))
			return
		end
		object=object or _G
		objectName=objectName or "_G"
		local method=object[cleanString]
		if type(method)~="function" then
			if hookType==Function then
				AddOn:Status(("%s is not a function"):format(cleanString))
				return
			elseif hookType==Method then
				AddOn:Status(("%s does not have a method named %s"):format(objectName,cleanString))
				return
			end
		end
		local objectReservedTable=E.RESERVED.Method[object]
		if objectReservedTable and objectReservedTable[methodOrScriptString] then
			AddOn:Status(("For addon stability, %s%s%s() cannot be hooked"):format(hookType==Method and objectName or "",H.DELIMS[hookType],methodOrScriptString))
			return
		end
	end
	AddOn:Status()
	return true
end