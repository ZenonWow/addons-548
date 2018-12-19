--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsCommon.lua

  Common utils for the UI options panels.

  Copyright 2011-2013 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

-- Recurse all children finding any FontStrings and replacing their texts
-- with localized copies.
function LiteMount_Frame_AutoLocalize(f)
    if not L then return end

    local regions = { f:GetRegions() }
    for _,r in ipairs(regions) do
        if r and r:IsObjectType("FontString") and not r.autoLocalized then
            r:SetText(L[r:GetText()])
            r.autoLocalized = true
        end
    end

    local children = { f:GetChildren() }
    for _,c in ipairs(children) do
        if not c.autoLocalized then
            LiteMount_Frame_AutoLocalize(c)
            c.autoLocalized = true
        end
    end
end

function LiteMount_OpenOptionsPanel()
    local panel = LiteMountOptions.CurrentOptionsPanel  or  LiteMountOptionsMounts
    if  not panel:IsVisible()  then
        InterfaceOptionspanel_OpenToCategory(panel)
        InterfaceOptionspanel_OpenToCategory(panel)
    else
        InterfaceOptionsFrame:Hide()
    end
end

function LiteMount_ToggleMountsPanel()
    if  not LiteMountOptionsMounts:IsVisible()  then
        InterfaceOptionsFrame_OpenToCategory(LiteMountOptionsMounts)
        InterfaceOptionsFrame_OpenToCategory(LiteMountOptionsMounts)
    else
        InterfaceOptionsFrame:Hide()
    end
end

