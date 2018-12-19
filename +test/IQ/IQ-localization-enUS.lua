-- -------------------------------------------------------------------------- --
-- IQ DEFAULT (english) Localization                                          --
-- Please make sure to save this file as UTF-8. ¶                             --
-- -------------------------------------------------------------------------- --

IQ_Locales = {

["Slots"] = true,
["Gems"] = true,
["not used"] = true,

}

function IQ_Locales:CreateLocaleTable(t)
	for k,v in pairs(t) do
		self[k] = (v == true and k) or v
	end
end

IQ_Locales:CreateLocaleTable(IQ_Locales)