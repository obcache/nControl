A_FileVersion := "1.1.2.5"
A_AppName := "nControl_updater"
;@Ahk2Exe-Let FileVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% 

;@Ahk2Exe-SetName nControl
;@Ahk2Exe-SetVersion %U_FileVersion%
;@Ahk2Exe-SetFileVersion %U_FileVersion%

#Requires AutoHotkey v2.0
#SingleInstance
#Warn All, Off

InstallMouseHook()
InstallKeybdHook()
KeyHistory(10)
SetWorkingDir(A_ScriptDir)

cfg				:= Object()
ui 				:= Object()

if (A_Args.length > 0) && FileExist("./versions/" A_Args[1]) {
	winWaitClose("ahk_exe nControl.exe")
	run("./versions/" A_Args[1])
	exitApp
} else {
	if (DirExist("./versions")) {
		fileList := ""  

		Loop files, "./versions/*.exe"
		{
			fileList .= A_LoopFileName ","
		}
		fileList := Sort(FileList, "R")
		currentBuildExe := rtrim(fileList[1],",")		
		if (fileExist(currentBuildExe))
		{	run(currentBuildExe)
			exitApp
		}
	}

exitApp
}
