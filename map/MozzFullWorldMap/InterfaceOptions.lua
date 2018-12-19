--[[--------------------------------------------------------------------------------------------

MozzFullWorldMap.lua

*****************************************************************
SEE ReadMe.txt for latest Patch Notes for (Fan's Update) versions
*****************************************************************

--]]--------------------------------------------------------------------------------------------

local function OnMapTintValuesChanged( colorWheelChanged )

	local tintColor = MFWM.emerald;
	local alpha = 1;
	
	if not MFWM_OptionsFrame_ShowKnownDataCheckButton:GetChecked() then

		alpha = MFWM_OptionsFrame_OpacitySliderFrame:GetValue();

		if MFWM_OptionsFrame_UseNormalTintCheckButton:GetChecked() then
			tintColor = MFWM.white;		
		elseif not MFWM_OptionsFrame_UseBlueTintCheckButton:GetChecked() then
			tintColor = 
			{
				r = MFWM_OptionsFrame_RedSliderFrame:GetValue(),
				g = MFWM_OptionsFrame_GreenSliderFrame:GetValue(),
				b = MFWM_OptionsFrame_BlueSliderFrame:GetValue()
			};
		end
							
		MFWM_OptionsFrame_RedSliderFrame:SetValue( tintColor.r );
		MFWM_OptionsFrame_GreenSliderFrame:SetValue( tintColor.g );
		MFWM_OptionsFrame_BlueSliderFrame:SetValue( tintColor.b );
		
		MFWM_OptionsFrame_OpacitySliderValue:SetText(  ("%0.0f%%"):format( alpha * 100 ) );
		MFWM_OptionsFrame_RedSliderValue:SetText( ("%0.0f%% / 0x%02X / %0.0f"):format( tintColor.r * 100, tintColor.r * 255, tintColor.r * 255 ) );
		MFWM_OptionsFrame_GreenSliderValue:SetText( ("%0.0f%% / 0x%02X / %0.0f"):format( tintColor.g * 100, tintColor.g * 255, tintColor.g * 255 ) );
		MFWM_OptionsFrame_BlueSliderValue:SetText( ("%0.0f%% / 0x%02X / %0.0f"):format( tintColor.b * 100, tintColor.b * 255, tintColor.b * 255 ) );
		
		if not colorWheelChanged then		
			MFWM_OptionsFrame:SetColorRGB( tintColor.r, tintColor.g, tintColor.b );
		end

	end			
	
	for i=1,9 do
		getglobal("MFWM_OptionsFrame_ColorSwatch"..i):SetVertexColor( tintColor.r, tintColor.g, tintColor.b );
		getglobal("MFWM_OptionsFrame_ColorSwatch"..i):SetAlpha( alpha );
	end
	
end

------------------------------------------------------------------------------------------------

local recursionOK = true;

local function OnColorWheelChanged()

	if recursionOK then
	
		recursionOK = false;
		
		if MFWM_OptionsFrame_UseCustomTintCheckButton:GetChecked() then
		
			local r, g, b = MFWM_OptionsFrame:GetColorRGB();
			
			MFWM_OptionsFrame_RedSliderFrame:SetValue( r );
			MFWM_OptionsFrame_GreenSliderFrame:SetValue( g );
			MFWM_OptionsFrame_BlueSliderFrame:SetValue( b );
		
			OnMapTintValuesChanged( true );
		
		else
		
			MFWM_OptionsFrame:SetColorRGB(
				MFWM_OptionsFrame_RedSliderFrame:GetValue(),
				MFWM_OptionsFrame_GreenSliderFrame:GetValue(),
				MFWM_OptionsFrame_BlueSliderFrame:GetValue()
			);
			
			
		end
		
		recursionOK = true;
		
	end	
end

------------------------------------------------------------------------------------------------

local function OnVisibilityChanged()

	if MFWM_OptionsFrame_ShowKnownDataCheckButton:GetChecked()
	or not MFWM_OptionsFrame_ShowMapCheckButton:GetChecked()
	then
	
		MFWM_OptionsFrame_UseNormalTintCheckButton:Hide();
		MFWM_OptionsFrame_UseBlueTintCheckButton:Hide();
		MFWM_OptionsFrame_UseCustomTintCheckButton:Hide();
		MFWM_OptionsFrame_OpacitySliderFrame:Hide();
		MFWM_OptionsFrame_RedSliderFrame:Hide();
		MFWM_OptionsFrame_GreenSliderFrame:Hide();
		MFWM_OptionsFrame_BlueSliderFrame:Hide();
		MFWM_OptionsFrame_ColorPickerWheel:Hide();
		MFWM_OptionsFrame_ColorPickerThumb:Hide();
		
		if not MFWM_OptionsFrame_ShowKnownDataCheckButton:GetChecked() then
			MFWM_OptionsFrame_SampleMapFrame:Hide();
		end
		
	else
	
		MFWM_OptionsFrame_UseNormalTintCheckButton:Show();
		MFWM_OptionsFrame_UseBlueTintCheckButton:Show();
		MFWM_OptionsFrame_UseCustomTintCheckButton:Show();
		MFWM_OptionsFrame_OpacitySliderFrame:Show();
		MFWM_OptionsFrame_SampleMapFrame:Show();
		
		if not MFWM_OptionsFrame_ShowKnownDataCheckButton:GetChecked() then
		
			MFWM_OptionsFrame_RedSliderFrame:Show();
			MFWM_OptionsFrame_GreenSliderFrame:Show();
			MFWM_OptionsFrame_BlueSliderFrame:Show();
			MFWM_OptionsFrame_ColorPickerWheel:Show();
			MFWM_OptionsFrame_ColorPickerThumb:Show();
				
		end
	end

	OnMapTintValuesChanged();
		
end

------------------------------------------------------------------------------------------------

local function OnUseNormalTintClicked()

	MFWM_OptionsFrame_UseNormalTintCheckButton:SetChecked( true );
	MFWM_OptionsFrame_UseBlueTintCheckButton:SetChecked( false );
	MFWM_OptionsFrame_UseCustomTintCheckButton:SetChecked( false );
	
	OnMapTintValuesChanged();
	
end

------------------------------------------------------------------------------------------------

local function OnUseBlueTintClicked()

	MFWM_OptionsFrame_UseNormalTintCheckButton:SetChecked( false );
	MFWM_OptionsFrame_UseBlueTintCheckButton:SetChecked( true );
	MFWM_OptionsFrame_UseCustomTintCheckButton:SetChecked( false );
	
	OnMapTintValuesChanged();
	
end

------------------------------------------------------------------------------------------------

local function OnUseCustomTintClicked()

	MFWM_OptionsFrame_UseNormalTintCheckButton:SetChecked( false );
	MFWM_OptionsFrame_UseBlueTintCheckButton:SetChecked( false );
	MFWM_OptionsFrame_UseCustomTintCheckButton:SetChecked( true );
	
	OnMapTintValuesChanged();

end

------------------------------------------------------------------------------------------------

local function OnRefresh()

	MFWM_OptionsFrame_ShowMapCheckButton:SetChecked( MFWM_PlayerData.Options.enabled and true or false );
	MFWM_OptionsFrame_ShowKnownDataCheckButton:SetChecked( MFWM_PlayerData.Options.showKnownData and true or false );
	MFWM_OptionsFrame_SaveMapDataCheckButton:SetChecked( MFWM_PlayerData.Options.dumpData and true or false );
	MFWM_OptionsFrame_DebugCheckButton:SetChecked( MFWM_PlayerData.Options.debug and true or false );
	MFWM_OptionsFrame_LabelPanelsCheckButton:SetChecked( MFWM_PlayerData.Options.labelPanels and true or false );

	if MFWM_PlayerData.Options.colorStyle == 1 then
		OnUseNormalTintClicked();
	elseif MFWM_PlayerData.Options.colorStyle == 2 then
		OnUseCustomTintClicked();
	else	
		OnUseBlueTintClicked();
	end
		
	MFWM_OptionsFrame_OpacitySliderFrame:SetValue( MFWM_PlayerData.Options.transparency or 1 );

	if MFWM_OptionsFrame_UseCustomTintCheckButton:GetChecked() 
	then
		MFWM_OptionsFrame_RedSliderFrame:SetValue( MFWM_PlayerData.Options.colorArray and MFWM_PlayerData.Options.colorArray.r or 1 );
		MFWM_OptionsFrame_GreenSliderFrame:SetValue( MFWM_PlayerData.Options.colorArray and MFWM_PlayerData.Options.colorArray.g or 1 );
		MFWM_OptionsFrame_BlueSliderFrame:SetValue( MFWM_PlayerData.Options.colorArray and MFWM_PlayerData.Options.colorArray.b or 1 );
	end
	
	OnVisibilityChanged();	
	OnMapTintValuesChanged();
	
end

------------------------------------------------------------------------------------------------

local function OnClickedOkay()

	MFWM_PlayerData.Options.enabled       = MFWM_OptionsFrame_ShowMapCheckButton:GetChecked() and true or false;
	MFWM_PlayerData.Options.showKnownData = MFWM_OptionsFrame_ShowKnownDataCheckButton:GetChecked() and true or false;
	MFWM_PlayerData.Options.dumpData      = MFWM_OptionsFrame_SaveMapDataCheckButton:GetChecked() and true or false;
	MFWM_PlayerData.Options.debug         = MFWM_OptionsFrame_DebugCheckButton:GetChecked() and true or false;
	MFWM_PlayerData.Options.labelPanels   = MFWM_OptionsFrame_LabelPanelsCheckButton:GetChecked() and true or false;
	MFWM_PlayerData.Options.transparency  = MFWM_OptionsFrame_OpacitySliderFrame:GetValue() or 1;
	
	MozzWorldMapShowAllCheckButton:SetChecked( MFWM_PlayerData.Options.enabled );
	
	if MFWM_OptionsFrame_UseCustomTintCheckButton:GetChecked() then
	
		MFWM_PlayerData.Options.colorStyle = 2;
		MFWM_PlayerData.Options.colorArray =
		{
			r = MFWM_OptionsFrame_RedSliderFrame:GetValue(),
			g = MFWM_OptionsFrame_GreenSliderFrame:GetValue(),
			b = MFWM_OptionsFrame_BlueSliderFrame:GetValue(),
		};
		
	elseif MFWM_OptionsFrame_UseNormalTintCheckButton:GetChecked() then
		MFWM_PlayerData.Options.colorStyle = 1;
		MFWM_PlayerData.Options.colorArray = nil;
	else
		MFWM_PlayerData.Options.colorStyle = 0;
		MFWM_PlayerData.Options.colorArray = nil;
	end
	
	MFWM.RefreshMapOverlays();
	
end

------------------------------------------------------------------------------------------------

local function OnClickedCancel()
end

------------------------------------------------------------------------------------------------

local function OnClickedDefaults()

	wipe( MFWM_PlayerData.Options );
	
	MFWM_PlayerData.Options = MFWM.TableCopy( MFWM.DefaultOptions )
	
end

------------------------------------------------------------------------------------------------

MFWM.InitSettingsPanel = function()

	MFWM_OptionsFrame.name   = "MozzFullWorldMap";
	
	if arg1 == "nUI6" then
		MFWM_OptionsFrame.parent = "nUI6";
	end

	MFWM_OptionsFrame.okay    = OnClickedOkay;
	MFWM_OptionsFrame.canel   = OnClickedCancel;
	MFWM_OptionsFrame.default = OnClickedDefaults;
	MFWM_OptionsFrame.refresh = OnRefresh;

	MFWM_OptionsFrame_SampleMapFrame:SetScale( 0.55 );
	
	MFWM_OptionsFrame_Message:SetText( MFWM.L["OPTION_MESSAGE"] );
	
	MFWM_OptionsFrame_ShowMapLabel:SetText( MFWM.L["OPTION_SHOW"] );
	MFWM_OptionsFrame_ShowKnownDataLabel:SetText( MFWM.L["OPTION_DATA"] );
	MFWM_OptionsFrame_SaveMapDataLabel:SetText( MFWM.L["OPTION_DUMP"] );
	MFWM_OptionsFrame_DebugLabel:SetText( MFWM.L["OPTION_DEBUG"] );
	MFWM_OptionsFrame_LabelPanelsLabel:SetText( MFWM.L["OPTION_LABEL"] );
	
	MFWM_OptionsFrame_UseNormalTintLabel:SetText( MFWM.L["OPTION_NORMAL"] );
	MFWM_OptionsFrame_UseBlueTintLabel:SetText( MFWM.L["OPTION_EMERALD"] );
	MFWM_OptionsFrame_UseCustomTintLabel:SetText( MFWM.L["OPTION_CUSTOM"] );
	MFWM_OptionsFrame_OpacitySliderLabel:SetText( MFWM.L["OPTION_ALPHA"] );
	
	MFWM_OptionsFrame_RedSliderLabel:SetText( MFWM.L["OPTION_RED"] );
	MFWM_OptionsFrame_GreenSliderLabel:SetText( MFWM.L["OPTION_GREEN"] );
	MFWM_OptionsFrame_BlueSliderLabel:SetText( MFWM.L["OPTION_BLUE"] );
	
	MFWM_OptionsFrame_ShowMapCheckButton:SetScript( "OnClick", OnVisibilityChanged );
	MFWM_OptionsFrame_ShowKnownDataCheckButton:SetScript( "OnClick", OnVisibilityChanged );
	
	MFWM_OptionsFrame_UseNormalTintCheckButton:SetScript( "OnClick", OnUseNormalTintClicked );
	MFWM_OptionsFrame_UseBlueTintCheckButton:SetScript( "OnClick", OnUseBlueTintClicked );
	MFWM_OptionsFrame_UseCustomTintCheckButton:SetScript( "OnClick", OnUseCustomTintClicked );
	
	MFWM_OptionsFrame_OpacitySliderFrame:SetScript( "OnValueChanged", OnMapTintValuesChanged );
	MFWM_OptionsFrame_RedSliderFrame:SetScript( "OnValueChanged", OnMapTintValuesChanged );
	MFWM_OptionsFrame_GreenSliderFrame:SetScript( "OnValueChanged", OnMapTintValuesChanged );
	MFWM_OptionsFrame_BlueSliderFrame:SetScript( "OnValueChanged", OnMapTintValuesChanged );
	
	MFWM_OptionsFrame:SetScript( "OnColorSelect", OnColorWheelChanged );
	
	InterfaceOptions_AddCategory( MFWM_OptionsFrame );
	
end
