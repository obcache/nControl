#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
}	
	
guiAFKTab(&ui,&afk) {
	global
	ui.MainGuiTabs.UseTab("AFK")
	;Any logic needed for the AFK tab beneath the docked AfkGui
	win1afk.routine := ui.mainGui.addText("x330 y37 section w196 h78 0xC Background" cfg.ThemePanel1Color,"")
	win2afk.routine := ui.mainGui.addText("xs y+10 w196 h78 0xC Background" cfg.ThemePanel1Color,"")
	win1afk.routine.SetFont("s10")
	win2afk.routine.SetFont("s10")
	
	
	
}