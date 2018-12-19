local addon, ns = ...
local L = ns.L

-- ------------------------------- --
-- modules table and init function --
-- ~Hizuro                         --
-- ------------------------------- --
ns.modules = {}
ns.updateList = {}
ns.timeoutList = {}

local function moduleInit(name)

		local ldbName = (Broker_EverythingDB.usePrefix and "BE.." or "")..name
		local data = ns.modules[name]

		-- module load on demand like
		if data.enabled==nil then
			data.enabled = true
		end

		-- check if savedvariables for module present?
		if Broker_EverythingDB[name] == nil then
			Broker_EverythingDB[name] = {enabled = data.enabled}
		elseif type(Broker_EverythingDB[name].enabled)~="boolean" then
			Broker_EverythingDB[name].enabled = data.enabled
		end

		if data.config_defaults then
			for i,v in pairs(data.config_defaults) do
				if Broker_EverythingDB[name][i] == nil then
					Broker_EverythingDB[name][i] = v
				elseif data.config_allowed~=nil and data.config_allowed[i]~=nil then
					if data.config_allowed[i][Broker_EverythingDB[name][i]]~=true then
						Broker_EverythingDB[name][i] = v
					end
				end
			end
		end

		-- force enabled status of non Broker modules.
		if data.noBroker then
			data.enabled = true
			Broker_EverythingDB[name].enabled = true
		end

		if Broker_EverythingDB[name].enabled==true then

			if (data.onupdate) then
				ns.updateList[name] = {
					firstUpdate = false,
					func = data.onupdate,
					interval = data.updateinterval,
					elapsed = 0
				}
			end

			if (data.ontimeout) and type(data.timeout)=="number" and data.timeout>0 then
				ns.timeoutList[name] = CreateFrame("frame")
				local tmp = ns.timeoutList[name]
				tmp.timeout = data.timeout
				tmp.afterEvent = data.afterEvent
				tmp.func = data.ontimeout
				tmp.run = false -- true = running, false = waiting, nil = finished
				tmp.elapsed = 0
				if (tmp.afterEvent) then
					tmp:RegisterEvent(tmp.afterEvent)
					tmp:SetScript("OnEvent",function(self,event)
						self:UnregisterEvent(event)
						self:SetScript("OnEvent",nil)
						tmp.afterEvent = nil
						tmp.run = true
					end)
				else
					tmp.run = true
				end
			end

			-- pre LDB init
			if data.init then
				data.init()
			end

			if (not data.noBroker) then
				if (not data.onenter) and data.ontooltip then
					data.ontooltipshow = data.ontooltip
				end

				local icon = ns.I(name .. (data.icon_suffix or ""))
				local iColor = Broker_EverythingDB.iconcolor
				data.obj = ns.LDB:NewDataObject(ldbName, {

					-- button data
					type          = "data source",
					label         = data.label or L[name],
					icon          = icon.iconfile, -- default or custom icon
					staticIcon    = icon.iconfile, -- default icon only
					iconCoords    = icon.coords or {0, 1, 0, 1},

					-- button event functions
					OnEnter       = data.onenter or nil,
					OnLeave       = data.onleave or nil,
					OnClick       = data.onclick or nil,
					OnDoubleClick = data.ondblclick or nil,
					OnTooltipShow = data.ontooltipshow or nil
				})

				ns.updateIconColor(name)

				if Broker_EverythingDB.libdbicon then
					if Broker_EverythingDB[name].dbi==nil then Broker_EverythingDB[name].dbi = {} end
					data.dbi = ns.LDBI:Register(ldbName,data.obj,Broker_EverythingDB[name].dbi)
				end
			end

			-- event handler registration
			if data.onevent then
				data.event = CreateFrame("frame")
				for _, e in pairs(data.events) do
					data.event:RegisterEvent(e)
				end
				data.event:SetScript("OnEvent",data.onevent)
			end

			-- post LDB init
			if data.init then
				data.init(data)
			end

			-- panels for single modules
			if data.optionpanel then
				ns.OP[name.."Subpanel"] = ns.LSO.AddSuboptionsPanel(addon, data.label, data.optionspanel)
			end

			-- chat command registration
			if data.chatcommands then
				for i,v in pairs(data.chatcommands) do
					if type(i)=="string" and ns.commands[i]==nil then -- prevents overriding
						ns.commands[i] = v
					end
				end
			end

			data.init = nil
		end

end

ns.moduleInit = function(name)
	if name then
		moduleInit(name)
	else
		local i = 0
		for name, data in pairs(ns.modules) do
			moduleInit(name)
			i = i+1
		end
	end
end


function ns.highlightOnMouseover(tt, line)
	tt:SetLineScript(line, "OnEnter", function(self) tt:SetLineColor(line, 1,192/255, 90/255, 0.3) end )
	tt:SetLineScript(line, "OnLeave", function(self) tt:SetLineColor(line, 0,0,0,0) end)
end

