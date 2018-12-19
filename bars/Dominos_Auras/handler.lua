function Dominos:NewAurabar(name, filter,parent)
	local headerAura = CreateFrame("Frame", name, parent, "SecureAuraHeaderTemplate");
	headerAura:SetAttribute("unit", "player"); -- to activate UNITAURA event refresh
	headerAura:SetAttribute("filter", filter);
	headerAura:SetAttribute("template", "DominosAuraTemplate"); -- must be the template name of your XML

	function headerAura:UpdateLayout(spacing, cols, rows, LR, TB, method, direction)
		for i,aura in headerAura:ActiveChildren() do
			if (tonumber(cols)and tonumber(rows)) and (tonumber(i) > (tonumber(cols)* tonumber(rows))) then
				aura:Hide()
			end
		end
		local base = (30 + spacing)
		headerAura:SetAttribute("minWidth", base);
		headerAura:SetAttribute("minHeight", base);

		headerAura:SetAttribute("wrapAfter", cols);
		headerAura:SetAttribute("maxWraps", rows);
		
		local hori, vert
		
		if not LR then	
			vert = "Left"
			headerAura:SetAttribute("xOffset", base);
			headerAura:SetAttribute("yOffset", 0);
		else
			vert = "Right"
			headerAura:SetAttribute("xOffset", -base);
			headerAura:SetAttribute("yOffset", 0);
		end
		if not TB then
			hori = "Top"
			headerAura:SetAttribute("wrapXOffset", 0);
			headerAura:SetAttribute("wrapYOffset", -base);	
		else
			hori = "Bottom"
			headerAura:SetAttribute("wrapXOffset", 0);
			headerAura:SetAttribute("wrapYOffset", base);
		end
		headerAura:SetAttribute("point", hori..vert);
		headerAura:SetAttribute("sortMethod", method); -- INDEX or NAME or TIME
		headerAura:SetAttribute("sortDirection", direction); -- - to reverse
	end


	headerAura:Show();
	-- provide a simple iterator to the header
	local function siter_active_children(header, i)
		i = i + 1;
		local child = header:GetAttribute("child" .. i);
		if child and child:IsShown() then
			return i, child, child:GetAttribute("index");
		end
	end

	function headerAura:ActiveChildren() return siter_active_children, self, 0; end

	-- The update style function
	local function updateStyle()
		for _,aura in headerAura:ActiveChildren() do
			local name, _, icon, count, debuffType, duration, expirationTime = UnitAura(headerAura:GetAttribute("unit"), aura:GetID(), headerAura:GetAttribute("filter"));
			if name then
				aura.tex:SetTexture(icon);
				aura.cd:SetCooldown(expirationTime - duration, duration);
				if not (count>1)then count=""end
				aura.txt:SetText(count);
				aura.tex:Show();
				aura.cd:Show();
				aura.txt:Show();
			else
				aura.tex:Hide();
				aura.cd:Hide();
				aura.txt:Hide();
			end
		end
	end
	headerAura:UpdateLayout(3, "TopLeft", 4, 4, true, true,"Time", "+")

	local f = CreateFrame("Frame");
	f:RegisterEvent("UNIT_AURA");
	f:RegisterEvent("PLAYER_ENTERING_WORLD");
	f:SetScript("OnEvent", function()
		updateStyle()
	end)
	headerAura.event = f
	return headerAura
end
