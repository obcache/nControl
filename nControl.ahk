;@Ahk2Exe-SetName nControl
;@Ahk2Exe-SetVersion 1.1.3.1-beta
;@Ahk2Exe-ExeName E:\Desktop\nControl.exe

#Requires AutoHotkey v2.0
#SingleInstance
#Warn All, Off


Persistent()
InstallMouseHook()
InstallKeybdHook()
KeyHistory(10)

SetWorkingDir(A_ScriptDir)

cfg			:= Object()
ui 			:= Object()
InstallDir := A_MyDocuments "\nControl"
ConfigFileName := "nControl.ini"
ui.AntiIdle_enabled := false
cfg.afk_enabled := false


PreAutoExec(InstallDir,ConfigFileName)

ErrorLevel 		:= 0 
ui.AfkGui 		:= Gui()

dockApp 	:= Object()
workApp		:= Object()

cfg.file := "./" ConfigFileName
ui.pinned := 0
ui.hidden := 0

ui.hwndAfkGui := ""
ui.AfkHeight := 170

; cfg.ThemeBorderDarkColor := "212121"
; cfg.ThemeBorderLightColor := "555555"
; cfg.ThemeBright1Color := "00FFFF"
; cfg.ThemeBright2Color := "FF00FF"
; cfg.ThemeBackgroundColor := "363636"
; cfg.ThemeFont1Color := "00FFFF"
; cfg.ThemeFont2Color := "FF00FF"
; cfg.ThemeConsoleBgColor := "204040"
; cfg.ThemeEditboxColor := "353535"
; cfg.ThemeDisabledColor := "212121"

MonitorGet(MonitorGetPrimary(),&PrimaryMonitorLeft,&PrimaryMonitorTop,&PrimaryMonitorRight,&PrimaryMonitorBottom)
MonitorGetWorkArea(MonitorGetPrimary(),&PrimaryWorkAreaLeft,&PrimaryWorkAreaTop,&PrimaryWorkAreaRight,&PrimaryWorkAreaBottom)
ui.TaskbarHeight := PrimaryMonitorBottom - PrimaryWorkAreaBottom

LogData := ""
dockApp.enabled := 0

ui.AfkDocked := false
ui.AfkAnchoredToGui := true
ui.AfkEnabled := false
ui.towerEnabled := false

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
CfgLoad(&cfg, &ui)
InitGui(&cfg, &ui)
InitConsole(&ui)
debugLog("Interface Initialized")

OnExit(ExitFunc)

;debugLog("Console Initialized")
if (cfg.consoleEnabled == true)
{
	ToggleDebug()
}



InitTrayMenu(&ThisTray)

OnMessage(0x0200, WM_MOUSEMOVE)
OnMessage(0x0201, WM_LBUTTONDOWN)
OnMessage(0x47, WM_WINDOWPOSCHANGED)

RefreshWinHwnd()
	
;AutoDetectGameToggle()
;AutoDetectGameToggle()

;END AUTOEXEC



