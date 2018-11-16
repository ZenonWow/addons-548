LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Routes", {
	type = "launcher",
	label = "Routes",
	icon = [[Interface\Addons\Routes\icon.tga]],
	OnClick = function(clickedframe, button)
		--Routes.ToggleConfig()
		LibStub("AceAddon-3.0"):GetAddon("Routes").ToggleConfig()
	end,
});
