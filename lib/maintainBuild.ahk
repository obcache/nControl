;MaintainBuild.ahk
#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

; if (InStr(A_LineFile,A_ScriptFullPath)){
	; Run(A_ScriptDir "/../nControl.ahk")
	; ExitAppE
	; Return
; }

MainScriptFile := "E:\Documents\Resources\AutoHotKey\__nControl\nControl.ahk"
Loop Read MainScriptFile, MainScriptFile "-tmp"
{
	CurrLine := A_LoopReadLine
   If (A_Index == 1)
	{ 
		OldBuildNumber := FileRead("E:\Documents\Resources\AutoHotKey\__nControl\nControl_currentBuild.dat")
		BuildNumber := OldBuildNumber + 1
		FileDelete("E:\Documents\Resources\AutoHotKey\__nControl\nControl_currentBuild.dat")
		FileAppend(BuildNumber,"E:\Documents\Resources\AutoHotKey\__nControl\nControl_currentBuild.dat")
		A_BuildVersion := SubStr(BuildNumber,1,1) "." SubStr(BuildNumber,2,1) "." SubStr(BuildNumber,3,1) "." SubStr(BuildNumber,4,1)
		CurrLine := 'A_FileVersion := "' A_BuildVersion '"' 
	}
   FileAppend(CurrLine "`n")
}
msgBox(MainScriptFile "`n" OldBuildNumber)
FileMove(MainScriptFile,"E:\documents\resources\autoHotKey\__nControl\backups\nControl-" OldBuildNumber ".ahk")
FileMove(MainScriptFile "-tmp",MainScriptFile,1)
RunWait('"c:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "E:\Documents\Resources\AutoHotKey\__nControl\nControl.ahk" /out "E:\Documents\Resources\AutoHotKey\__nControl\Bin\nControl_' BuildNumber '.exe"')
;FileCreateShortcut("E:\Documents\Resources\AutoHotKey\__nControl\Bin\nControl_" BuildNumber ".exe","e:\desktop\ncontrol.lnk")
if (FileExist(A_Desktop "/ncontrol.lnk"))
	FileDelete(A_Desktop "\ncontrol.lnk")
FileCreateShortcut("E:\Documents\Resources\AutoHotKey\__nControl\Bin\nControl_" BuildNumber ".exe", A_Desktop "\nControl.lnk",,,"nControl-Latest Build",,"i")
if (FileExist("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\_nControl.lnk"))
	FileDelete("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\_nControl.lnk")
FileCreateShortcut("E:\Documents\Resources\AutoHotKey\__nControl\Bin\nControl_" BuildNumber ".exe", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\_nControl.lnk",,,"nControl-Latest Build",,"i")