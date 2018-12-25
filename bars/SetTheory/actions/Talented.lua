local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

function SetTheory:LoadTalentedAction()
	if select(4, GetAddOnInfo('Talented')) and IsAddOnLoadOnDemand('Talented') then  --FIXME: Load Talented via Blizzard_TalentUI
		LoadAddOn('Blizzard_TalentUI')

		local oldToPlayerArt = MainMenuBar_ToPlayerArt --FIXME: Hack so that MainMenuBar_ToPlayerArt is not called when switching spec if it's not already shown (for some reason the call is not made if the TalentUI has been shown but is called from PlayerTalentFrame_OnEvent if the TalentUI has been loaded but not shown, i.e. by the call above.)
		MainMenuBar_ToPlayerArt = function(self)
			if MainMenuBar:IsShown() then oldToPlayerArt(self) end
		end
	end

	if Talented and SetTheory then
		local talented = {};
		talented.name = "SetTheory_Talented"
		talented.desc = L["Talented"]

		function talented.set(opts)
			if not opts.template then return end
			local oldTemplate = Talented.template
			Talented.template = Talented.db.global.templates[opts.template]
			Talented:UnpackTemplate(Talented.template)
			Talented:ApplyCurrentTemplate()
			LearnPreviewTalents()
			Talented.template = oldTemplate
			Talented:EnableUI(true)
		end

		function templates()
			local ret = {}
			for name, code in pairs(Talented.db.global.templates) do
				local class = code.class
				if not class and code.code then _, class = Talented:StringToTemplate(code.code) end
				if class == select(2, UnitClass("player")) then ret[name] = name end
			end
			return ret
		end

		function exists(i, v)
			local found = false
			for name, code in pairs(Talented.db.global.templates) do
				if name == v then
					local class = code.class
					if not class and code.code then _, class = Talented:StringToTemplate(code.code) end
					if class == select(2, UnitClass("player"))then
						found = true
						break
					end
				end
			end
			return found
		end
		
		talented.opts = {
			type = "group",
			name = L["Talented"],
			handler = SetTheory,
			set = "SetActionOption",
			get = "GetActionOption",
			args = {
				actionInstructions = {
					type = "description",
					name = L["Select which Talented template you'd like to apply"],
					order = 0,
				},
				template = {
					name = L["Template"],
					desc = L["The talented template you'd like to apply"],
					type = "select",
					values = templates,
					validate = exists,
				},
			}
		}

		SetTheory:RegisterAction(talented)
	end
end
