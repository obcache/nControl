;MaintainBuild.ahk
#Requires AutoHotkey v2.0+
#SingleInstance
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
FileMove(MainScriptFile,"E:\Backups\nControl\nControl-" OldBuildNumber ".ahk",1)
FileMove(MainScriptFile "-tmp",MainScriptFile,1)
RunWait('"c:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "E:\Documents\Resources\AutoHotKey\__nControl\nControl.ahk" /out "E:\Documents\Resources\AutoHotKey\__nControl\Bin\nControl_' BuildNumber '.exe"')
FileCreateShortcut("E:\Documents\Resources\AutoHotKey\__nControl\Bin\nControl_" BuildNumber ".exe","e:\desktop\ncontrol.lnk")
