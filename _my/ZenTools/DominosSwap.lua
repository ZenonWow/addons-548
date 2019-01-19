
--[[
/run ExchangeButtons(13, 61)
/run ExchangeButtons(25, 49)
/run ExchangeMixedup()
/run Dominos.db.char.unMixed = nil
--]]
function ExchangeButtons(fr, to)
	PickupAction(fr)
	if  CursorHasItem()  then  PlaceAction(to)
	else  PickupAction(to)  end
	PlaceAction(fr)
end

function ExchangeBars(fr, to)
	for  i = 1,12  do
		ExchangeButtons(fr*12 - i, to*12 - i)
	end
end

function ExchangeMixedup()
	ExchangeBars(2,6)
	ExchangeBars(3,5)
	print(GREEN_FONT_COLOR_CODE.."Dominos: |r"..ORANGE_FONT_COLOR_CODE..UnitName('player').." action bar unmixed.|r")
end


function DominosSwap()
	if  not Dominos.db.char.unMixed  then
		ExchangeMixedup()
		Dominos.db.char.unMixed = date("%Y-%m-%d %H:%M:%S")
	end
end

LibStub.AceEvent3.RegisterEvent("DominosSwap", "PLAYER_LOGIN", DominosSwap)
-- TODO: LibStub.AceEvent3:RegisterEvent("PLAYER_LOGIN", DominosSwap)

