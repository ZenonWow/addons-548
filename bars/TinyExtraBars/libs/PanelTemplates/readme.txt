Standard PanelTemplates global functions using protected frames and causing taints when used by third-party addons. But it is possible to avoid taints by using same functionality with that library.

== What is it ==
Library is standard code from Blizzard's files UIPanelTemplates.lua with functions renamed to:
* "Lib_" added at the start

== Functions ==
* Lib_PanelTemplates_Tab_OnClick
* Lib_PanelTemplates_SetTab
* Lib_PanelTemplates_GetSelectedTab
* Lib_PanelTemplates_UpdateTabs
* Lib_PanelTemplates_GetTabWidth
* Lib_PanelTemplates_TabResize
* Lib_PanelTemplates_SetNumTabs
* Lib_PanelTemplates_DisableTab
* Lib_PanelTemplates_EnableTab
* Lib_PanelTemplates_DeselectTab
* Lib_PanelTemplates_SelectTab
* Lib_PanelTemplates_SetDisabledTabState

== How to use it ==

* Add it to your toc. 
* Like ordinal code for UIPanelTemplates with "Lib_" instead.