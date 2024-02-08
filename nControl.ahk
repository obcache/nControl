A_FileVersion := "3.5.9.2"
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
refreshWinHwnd()
ui.gameTabs.choose(cfg.gameModuleList[1])
;ui.mainGuiTabs.choose(cfg.mainTabList[cfg.activeMainTab])

ui.gameTabs.choose(cfg.gameModuleList[2])
ui.gameTabs.choose(cfg.gameModuleList[cfg.activeGameTab])


autoUpdate()

if (cfg.startMinimizedEnabled)
	hideGui()
ui.mainGui.getPos(&MainGuiX,&MainGuiY,,)
fadeIn()
guiVis(ui.afkGui,(ui.activeTab == "AFK") ? true : false)
guiVis(ui.gameSettingsGui,(ui.activeTab = "Game") ? true : false)	
tabsChanged()
changeGameDDL()
controlFocus(ui.d2AlwaysRun)
