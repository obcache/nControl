#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}
;libGuiKeybindsTab
GuiKeybindsTab(&ui)
{
	ui.MainGuiTabs.UseTab("Bindings")
	drawOutlineMainGui(10,40,445,120,cfg.ThemeBrightBorderTopColor,cfg.ThemeBrightBorderBottomColor,2)
	ui.MainGuiTabs.AddListBox()
}