A_FileVersion := "3.6.4.1"
;@Ahk2Exe-Let FileVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% 

A_AppName := "nControl"
if (fileExist("./nControl_currentBuild.dat"))
	A_FileVersion := FileRead("./nControl_currentBuild.dat")
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

A_Restarted := 
	(inStr(DllCall("GetCommandLine","Str"),"/restart"))
		? true
		: false
		
cfg				:= Object()
ui 				:= Object()
InstallDir 		:= A_MyDocuments "\nControl"
ConfigFileName 	:= "nControl.ini"
ThemeFileName	:= "nControl.themes"
ErrorLevel 		:= 0 

PreAutoExec(InstallDir,ConfigFileName)
InitTrayMenu()

ui.AfkGui 		:= Gui()
dockApp 		:= Object()
workApp			:= Object()
cfg.file 		:= "./" ConfigFileName
cfg.ThemeFile	:= "./" ThemeFileName
ui.pinned 		:= 0
ui.hidden 		:= 0
ui.hwndAfkGui 	:= ""
LogData 		:= ""
ui.AfkHeight 	:= 170
ui.latestVersion := ""
ui.installedVersion := ""

MonitorGet(MonitorGetPrimary(),
	&PrimaryMonitorLeft,
	&PrimaryMonitorTop,
	&PrimaryMonitorRight,
	&PrimaryMonitorBottom)

MonitorGetWorkArea(MonitorGetPrimary(),
	&PrimaryWorkAreaLeft,
	&PrimaryWorkAreaTop,
	&PrimaryWorkAreaRight,
	&PrimaryWorkAreaBottom)

ui.TaskbarHeight := PrimaryMonitorBottom - PrimaryWorkAreaBottom

CfgLoad(&cfg, &ui)
InitGui(&cfg, &ui)
InitConsole(&ui)

#include <libGui>
#include <libWinMgr>
#include <libGlobal>
#include <libGuiOperationsTab>
#include <libGuiAFKTab>
#include <libAfkFunctions>
#include <libGuiSetupTab>
#include <libGuiAppDockTab>
#include <libGameSettingsTab>
#include <libGuiAudioTab>

#include <libGuiSystemTab>
#include <libHotkeys>
#include <libRoutines>
#include <Class_SQLiteDB>
#include <libThemeCreator>

debugLog("Interface Initialized")

OnExit(ExitFunc)

debugLog("Console Initialized")
; if (cfg.ConsoleVisible == true)
; {
	; toggleConsole()
; }																																																				

;setTimer(monitorGameWindows,2500)
; refreshWinHwnd()
ui.gameTabs.choose(cfg.gameModuleList[1])
;ui.mainGuiTabs.choose(cfg.mainTabList[cfg.activeMainTab])

ui.gameTabs.choose(cfg.gameModuleList[2])
ui.gameTabs.choose(cfg.gameModuleList[cfg.activeGameTab])


autoUpdate()


winGetPos(&MainGuiX,&MainGuiY,,,ui.mainGui)
if cfg.startMinimizedEnabled
	hideGui()

createDockBar()
if cfg.topDockEnabled
	showDockBar()


changeGameDDL()
winSetTransparent(0,ui.gameSettingsGui)
winSetTransparent(0,ui.afkGui)
ui.gameSettingsGui.show("x" mainGuiX+35 " y" mainGuiY+35 " w495 h170 noActivate")
ui.AfkGui.Show("x" mainGuiX+40 " y" mainGuiY+50 " w280 h140 NoActivate")

ui.MainGuiTabs.Choose(cfg.mainTabList[cfg.activeMainTab])
fadeIn()
switch ui.mainGuiTabs.text {
	case "AFK":
		guiVis(ui.afkGui,true)
	case "Game":
		guiVis(ui.gameSettingsGui,true)
}
tabsChanged()
