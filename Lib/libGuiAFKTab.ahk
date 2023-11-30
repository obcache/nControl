#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
}	
	
guiAFKTab(&ui,&afk) {
	ui.MainGuiTabs.UseTab("AFK")
	;Any logic needed for the AFK tab beneath the docked AfkGui
	ui.Win1AfkRoutine := ui.MainGui.AddText("x348 y37 section w178 h78 Background" cfg.ThemePanel1Color,"")
	ui.Win2AfkRoutine := ui.MainGui.AddText("xs y+10 w178 h78 Background" cfg.ThemePanel1Color,"")
	ui.Win1AfkRoutine.SetFont("s10")
	ui.Win2AfkRoutine.SetFont("s10")
	
}