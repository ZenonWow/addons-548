local L = LibStub("AceLocale-3.0"):GetLocale("SetTheory", true)

if Outfitter and SetTheory then
	local outfitter = {};
	outfitter.name = "SetTheory_Outfitter"
	outfitter.desc = L["Outfitter"]
	outfitter.wait = 2

	function outfitter.set(opts)
		if not opts.outfit or opts.outfit == "" then return end
		Outfitter:WearOutfitByName(opts.outfit)	
		local wearing = Outfitter:WearingOutfitName(opts.outfit)
		if wearing then	
			SetTheory:SelectStatus(L["Setting outfit"]..opts.outfit)
			return true
		else return false
		end
	end

	function outfitter.alreadySet(opts)
		local outfit = Outfitter:FindOutfitByName(opts.outfit)

		return Outfitter.OutfitStack:IsTopmostOutfit(outfit)
	end
	
	function outfitter.exists(i, outfit)
		outfit = Outfitter:FindOutfitByName(outfit)
		if not outfit then return L["No Outfit"] else return true end
	end

	function outfitter.outfits()
		local ret = {}
		local outfits = Outfitter.Settings.Outfits;
		for _, v in pairs(outfits) do
			for _, outfit in ipairs(v) do
				local equipable = Outfitter.ItemList_GetEquippableItems()
				local missing, banked = Outfitter.ItemList_GetMissingItems(equipable, Outfitter:FindOutfitByName(outfit.Name))
				name = outfit.Name
				if missing then name = name .. " ("..L["incomplete"]..")" end
				if banked then name = name .. " ("..L["banked"]..")" end
				ret[outfit.Name] = name
			end
		end
		return ret
	end

	outfitter.opts = {
		type = "group",
		name = L["Outfitter"],
		handler = SetTheory,
		args = {
			actionInstructions = {
				type = "description",
				name = L["Select which outfit you'd like to wear"],
				order = 0,
			},
			outfit = {
				name = L["Outfit"],
				desc = L["Changes your active outfit"],
				type = "select",
				values = outfitter.outfits,
				validate = outfitter.exists,
				set = "SetActionOption",
				get = "GetActionOption",
			},
		}
	}

	SetTheory:RegisterAction(outfitter)
end
