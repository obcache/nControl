A_FileVersion := "1.1.3.0"
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
	if fileExist("./nControl_latestVersion.dat")
	{
		winClose("ahk_exe nControl.exe")
		latestVersion := fileRead("./nControl_latestVersion.dat")
		latestBuild := subStr(latestVersion,1,1) subStr(latestVersion,3,1) subStr(latestVersion,5,1) subStr(latestVersion,7,1)
		if !(DirExist(InstallDir "/versions"))
			DirCreate(InstallDir "/versions")
		
		if winExist("ahk_exe nControl.exe")
			processClose("ahk.exe")
		download("https://raw.githubusercontent.com/obcache/nControl/main/Bin/nControl_" latestVersion ".exe",A_MyDocuments "nControl/versions/nControl_" latestBuild ".exe")
		pbNotify("Downloading nControl v" latestVersion " installer")
		run(A_MyDocuments "/nControl/versions/nControl_" latestBuild ".exe")
	}
	
}
; if (DirExist("./versions")) {
		; fileList := array()  

		; Loop files, "./versions/*.exe"
		; {
			; fileList.push(A_LoopFileName)
		; }
		; currentBuildExe := fileList[fileList.length]		
		
		; if (fileExist(currentBuildExe))
		; {	
			; winWaitClose("ahk_exe nControl.exe")
			; fileDelete("./nControl.exe")
			; fileDelete("./nControl_currentBuild.dat")
			; run(currentBuildExe)
		; }
	; }
	; exitApp
; }
A_FileVersion := "1.1.3.1"
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
	if fileExist("./nControl_latestVersion.dat")
	{
		winClose("ahk_exe nControl.exe")
		latestVersion := fileRead("./nControl_latestVersion.dat")
		latestBuild := subStr(latestVersion,1,1) subStr(latestVersion,3,1) subStr(latestVersion,5,1) subStr(latestVersion,7,1)
		if !(DirExist(InstallDir "/versions"))
			DirCreate(InstallDir "/versions")
		
		if winExist("ahk_exe nControl.exe")
			processClose("ahk.exe")
		download("https://raw.githubusercontent.com/obcache/nControl/main/Bin/nControl_" latestVersion ".exe",A_MyDocuments "nControl/versions/nControl_" latestBuild ".exe")
		pbNotify("Downloading nControl v" latestVersion " installer")
		run(A_MyDocuments "/nControl/versions/nControl_" latestBuild ".exe")
	}
	
}
; if (DirExist("./versions")) {
		; fileList := array()  

		; Loop files, "./versions/*.exe"
		; {
			; fileList.push(A_LoopFileName)
		; }
		; currentBuildExe := fileList[fileList.length]		
		
		; if (fileExist(currentBuildExe))
		; {	
			; winWaitClose("ahk_exe nControl.exe")
			; fileDelete("./nControl.exe")
			; fileDelete("./nControl_currentBuild.dat")
			; run(currentBuildExe)
		; }
	; }
	; exitApp
; }
