function GetItemLink(itemIDorLink)
	local link = type(itemIDorLink) == 'number'  and  "item:"..itemIDorLink  or  itemIDorLink
	return select(2,GetItemInfo(link))
end

