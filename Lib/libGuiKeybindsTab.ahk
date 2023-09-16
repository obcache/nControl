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
	;drawOutlineMainGui(10,40,445,120,cfg.ThemeBright1Color,cfg.ThemeBright2Color,2)
=======
	drawOutlineMainGui(10,40,445,120,cfg.ThemeBrightBorderTopColor,cfg.ThemeBrightBorderBottomColor,2)
>>>>>>> 169606a70753258dc2f103a2ec48e6d3aac9edc4
	ui.MainGuiTabs.AddListBox()
}