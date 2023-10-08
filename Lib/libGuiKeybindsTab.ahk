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

	ui.KeyBindList := ui.MainGui.AddListBox("x5 y33 w300 section c" cfg.ThemeFont2Color " Background" cfg.ThemeBackgroundColor)
	;drawOutlineMainGui(10,40,445,120,cfg.ThemeConsole1AccentColor,cfg.ThemeConsole2AccentColor,2)
	ui.MainGuiTabs.AddListBox()
}