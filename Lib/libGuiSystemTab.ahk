#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../GameView.ahk2")
	ExitApp
	Return
}
; GuiSystemTab(&ui)
; {
	; ui.MainGuiTabs.UseTab("Dev")
	; ui.MainGui.SetFont("s16 c" cfg.ThemeFont1Color,"Calibri Bold")
	; ui.testCommandLabel := ui.MainGui.AddText("section","Enter Test AHK Command Below")
	; ui.MainGui.SetFont("s12")
	; ui.testCommand := ui.MainGui.AddEdit("xs w440 r5 background" cfg.ThemeBackgroundColor)
	; ui.testCommandButton := ui.MainGui.AddPicture("xs y+5","./Img/button_execute.png")
	; ui.testCommandButton.OnEvent("Click",executeTestCommand)
; }

executeTestCommand(*)
{
	try FileDelete(A_Temp "/tmpCmd.ahk")
	FileAppend("#SingleInstance`n" ui.testCommand.text, A_Temp "/tmpCmd.ahk")
	Run(A_Temp "/tmpCmd.ahk")
}
