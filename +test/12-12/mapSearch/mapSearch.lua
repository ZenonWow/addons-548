local editbox = CreateFrame("EditBox", "MapSearchBox", WorldMapPositioningGuide, "SearchBoxTemplate")
editbox:SetAutoFocus(false)
editbox:SetSize(150, 20)
editbox:SetPoint("TOPRIGHT", WorldMapPositioningGuide, -48, -2)

editbox.db = {}
for i=1, select("#", GetMapContinents()), 1 do
	local zonesdb = {}
	for j=1, select("#", GetMapZones(i)), 1 do
		tinsert(zonesdb, {id=j, name=select(j, GetMapZones(i))})
	end
	tinsert(editbox.db, {id=i, name=select(i, GetMapContinents()), zones = zonesdb })
end

editbox:SetScript("OnHide", BagSearch_OnHide)

editbox:SetScript("OnTextChanged", function(self)
	local searchdata = self:GetText()
	for i, v in pairs(self.db) do
		if v.name:lower():find(searchdata:lower()) then
			SetMapZoom(v.id)
			return
		end
		for j, k in pairs(v.zones) do
			if k.name:lower():find(searchdata:lower()) then
				SetMapZoom(v.id, k.id)
				return
			end
		end
	end
end)