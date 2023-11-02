A_FileVersion := "3.1.5.6"
A_AppName := "nControl"
;@Ahk2Exe-Let FileVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% 

;@Ahk2Exe-SetName nControl
;@Ahk2Exe-SetVersion %U_FileVersion%
;@Ahk2Exe-SetFileVersion %U_FileVersion%


#Requires AutoHotkey v2.0
#SingleInstance
#Warn All, Off


Persistent()
InstallMouseHook()
InstallKeybdHook()
KeyHistory(10)

SetWorkingDir(A_ScriptDir)

cfg				:= Object()
ui 				:= Object()
InstallDir 		:= A_MyDocuments "\nControl"
ConfigFileName := "nControl.ini"
ThemeFileName	:= "nControl.themes"

PreAutoExec(InstallDir,ConfigFileName)

ErrorLevel 		:= 0 
ui.AfkGui 		:= Gui()

dockApp 		:= Object()
workApp			:= Object()

cfg.file 		:= "./" ConfigFileName
cfg.ThemeFile	:= "./" ThemeFileName
ui.pinned 		:= 0
ui.hidden 		:= 0

ui.hwndAfkGui 	:= ""
ui.AfkHeight 	:= 170

; cfg.ThemeBright1Color := "212121"
; cfg.ThemeBright2Color := "555555"
; cfg.ThemePanel3Color := "00FFFF"
; cfg.ThemePanel4Color := "FF00FF"
; cfg.ThemeBackgroundColor := "363636"
; cfg.ThemeFont1Color := "00FFFF"
; cfg.ThemeFont2Color := "FF00FF"
; cfg.ThemePanel1Color := "204040"
; cfg.ThemeEditboxColor := "353535"
; cfg.ThemeDisabledColor := "212121"

MonitorGet(MonitorGetPrimary(),&PrimaryMonitorLeft,&PrimaryMonitorTop,&PrimaryMonitorRight,&PrimaryMonitorBottom)
MonitorGetWorkArea(MonitorGetPrimary(),&PrimaryWorkAreaLeft,&PrimaryWorkAreaTop,&PrimaryWorkAreaRight,&PrimaryWorkAreaBottom)
ui.TaskbarHeight := PrimaryMonitorBottom - PrimaryWorkAreaBottom

LogData := ""

CfgLoad(&cfg, &ui)
InitGui(&cfg, &ui)
InitConsole(&ui)
#include <libGui>
#include <libWinMgr>
#include <libGlobal>
#include <libGuiAFKTab>
#include <libAfkFunctions>
#include <libGuiOperationsTab>
#include <libGuiSetupTab>
#include <libGuiAppDockTab>
#include <libGuiKeybindsTab>
#include <libGuiAudioTab>

#include <libGuiSystemTab>
#include <libHotkeys>
#include <libRoutines>
#include <Class_SQLiteDB>

resetDefaultThemes() {
	ui.themeResetScheduled := true
	Reload()
}
debugLog("Interface Initialized")

OnExit(ExitFunc)

debugLog("Console Initialized")
; if (cfg.ConsoleVisible == true)
; {
	; toggleConsole()
; }																																																																																																																																																																																																																																																																																																																																			



InitTrayMenu(&ThisTray)



RefreshWinHwnd()
	
;AutoDetectGameToggle()
;AutoDetectGameToggle()

;END AUTOEXEC


