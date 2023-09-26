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
<<<<<<< HEAD

	ui.KeyBindList := ui.MainGui.AddListBox("x5 y33 w300 section c" cfg.ThemeFont2Color " Background" cfg.ThemeBackgroundColor)
=======
>>>>>>> 6369ce33ca03d30e8dec681be47725668dede52c
	;drawOutlineMainGui(10,40,445,120,cfg.ThemeBright1Color,cfg.ThemeBright2Color,2)
	ui.MainGuiTabs.AddListBox()
}