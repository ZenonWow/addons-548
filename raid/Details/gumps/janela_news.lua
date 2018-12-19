local _detalhes = 		_G._detalhes
local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )

local g =	_detalhes.gump
local _

function _detalhes:OpenNewsWindow()
	local news_window = _detalhes:CreateOrOpenNewsWindow()
	
	news_window:Title (Loc ["STRING_NEWS_TITLE"])
	news_window:Text (Loc ["STRING_VERSION_LOG"])
	news_window:Icon ("Interface\\CHARACTERFRAME\\TempPortrait")
	news_window:Show()
end

function _detalhes:CreateOrOpenNewsWindow()
	local frame = _G.DetailsNewsWindow

	-- /script _detalhes.OpenNewsWindow()
	
	if (not frame) then
		--> construir a janela de news
		frame = CreateFrame ("frame", "DetailsNewsWindow", UIParent, "ButtonFrameTemplate")
		frame:SetPoint ("center", UIParent, "center")
		frame:SetFrameStrata ("FULLSCREEN")
		frame:SetMovable (true)
		frame:SetWidth (512)
		frame:SetHeight (512)
		tinsert (UISpecialFrames, "DetailsNewsWindow")
		
		frame:SetScript ("OnMouseDown", function(self, button)
			if (self.isMoving) then
				return
			end
			if (button == "RightButton") then
				self:Hide()
			else
				self:StartMoving() 
				self.isMoving = true
			end
		end)
		frame:SetScript ("OnMouseUp", function(self, button) 
			if (self.isMoving and button == "LeftButton") then
				self:StopMovingOrSizing()
				self.isMoving = nil
			end
		end)
		
		--> reinstall textura
		local textura = _detalhes.gump:NewImage (frame, [[Interface\DialogFrame\DialogAlertIcon]], 64, 64, nil, nil, nil, "$parentExclamacao")
		textura:SetPoint ("topleft", frame, "topleft", 60, -10)
		--> reinstall aviso
		local reinstall = _detalhes.gump:NewLabel (frame, nil, "$parentReinstall", nil, "", "GameFontHighlightLeft", 10)
		reinstall:SetPoint ("left", textura, "right", 2, -2)
		reinstall.text = Loc ["STRING_NEWS_REINSTALL"]
		
		
		local frame_upper = CreateFrame ("scrollframe", nil, frame)
		local frame_lower = CreateFrame ("frame", nil, frame_upper)
		frame_lower:SetSize (450, 2000)
		frame_upper:SetPoint ("topleft", frame, "topleft", 15, -70)
		frame_upper:SetWidth (465)
		frame_upper:SetHeight (400)
		frame_upper:SetBackdrop({
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
				tile = true, tileSize = 16,
				insets = {left = 1, right = 1, top = 0, bottom = 1},})
		frame_upper:SetBackdropColor (.1, .1, .1, .3)
		frame_upper:SetScrollChild (frame_lower)
		
		local slider = CreateFrame ("slider", nil, frame)
		slider.bg = slider:CreateTexture (nil, "background")
		slider.bg:SetAllPoints (true)
		slider.bg:SetTexture (0, 0, 0, 0.5)
		
		slider.thumb = slider:CreateTexture (nil, "OVERLAY")
		slider.thumb:SetTexture ("Interface\\Buttons\\UI-ScrollBar-Knob")
		slider.thumb:SetSize (25, 25)
		
		slider:SetThumbTexture (slider.thumb)
		slider:SetOrientation ("vertical");
		slider:SetSize (16, 399)
		slider:SetPoint ("topleft", frame_upper, "topright")
		slider:SetMinMaxValues (0, 2000)
		slider:SetValue(0)
		slider:SetScript("OnValueChanged", function (self)
		      frame_upper:SetVerticalScroll (self:GetValue())
		end)
  
		frame_upper:EnableMouseWheel (true)
		frame_upper:SetScript("OnMouseWheel", function (self, delta)
		      local current = slider:GetValue()
		      if (IsShiftKeyDown() and (delta > 0)) then
				slider:SetValue(0)
		      elseif (IsShiftKeyDown() and (delta < 0)) then
				slider:SetValue (2000)
		      elseif ((delta < 0) and (current < 2000)) then
				slider:SetValue (current + 20)
		      elseif ((delta > 0) and (current > 1)) then
				slider:SetValue (current - 20)
		      end
		end)
  
		--> text box
		local texto = frame_lower:CreateFontString ("DetailsNewsWindowText", "overlay", "GameFontNormal")
		texto:SetPoint ("topleft", frame_lower, "topleft")
		texto:SetJustifyH ("left")
		texto:SetJustifyV ("top")
		texto:SetTextColor (1, 1, 1)
		texto:SetWidth (450)
		texto:SetHeight (2500)
		-- /script _detalhes.OpenNewsWindow()
		--> forum text
		local forum_button = CreateFrame ("Button", "DetailsNewsWindowForumButton", frame, "OptionsButtonTemplate")
		forum_button:SetPoint ("bottomleft", frame, "bottomleft", 10, 4)
		forum_button:SetText ("Forum Thread")
		forum_button:SetScript ("OnClick", function (self)
			--> copy and paste
			_detalhes:CopyPaste ("http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks")
		end)
		forum_button:SetWidth (130)
		
		local forum_button_texto = frame:CreateFontString ("DetailsNewsWindowForumButtonText", "overlay", "GameFontHighlightSmall")
		forum_button_texto:SetPoint ("left", forum_button, "right", 3, 0)
		forum_button_texto:SetText ("on mmo-champions, for feedback, feature request, bug report.")
		forum_button_texto:SetTextColor (.7, .7, .7, 1)
		
		function frame:Title (title)
			frame.TitleText:SetText (title or "")
		end
		
		function frame:Text (text)
			texto:SetText (text or "")
		end
		
		function frame:Icon (path)
			frame.portrait:SetTexture (path or nil)
		end
		
		frame:Hide()
	end
	
	return frame
end