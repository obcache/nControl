A_FileVersion := "4.2.4.8"
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

persistent()
installMouseHook()
installKeybdHook()
keyHistory(10)
setWorkingDir(a_scriptDir)



a_restarted := 
	(inStr(dllCall("GetCommandLine","Str"),"/restart"))
		? true
		: false

onMessage(0x0202, WM_LBUTTONDOWN)
onMessage(0x47, WM_WINDOWPOSCHANGED)


installDir 		:= a_myDocuments "\nControl"
configFileName 	:= "nControl.ini"
themeFileName	:= "nControl.themes"

preAutoExec(InstallDir,ConfigFileName)
initTrayMenu()

; ui.AfkGui 		:= Gui()
dockApp 		:= Object()
workApp			:= Object()
cfg.file 		:= "./" ConfigFileName
cfg.ThemeFile	:= "./" ThemeFileName
ui.pinned 		:= 0
ui.hidden 		:= 0
ui.hwndAfkGui 	:= ""
logData 		:= ""
ui.AfkHeight 	:= 170
ui.latestVersion := ""
ui.installedVersion := ""

MonitorGet(MonitorGetprimary(),
	&primaryMonitorLeft,
	&primaryMonitorTop,
	&primaryMonitorRight,
	&primaryMonitorBottom)

MonitorGetWorkArea(MonitorGetprimary(),
	&primaryWorkAreaLeft,
	&primaryWorkAreaTop,
	&primaryWorkAreaRight,
	&primaryWorkAreaBottom)

ui.taskbarHeight := primaryMonitorBottom - primaryWorkAreaBottom

cfgLoad(&cfg, &ui)
initGui(&cfg, &ui)
initConsole(&ui)

#include <libGui>
#include <libWinMgr>
#include <libGlobal>
#include <libGuiOperationsTab>
#include <libGuiAFKTab>
#include <libAfkFunctions>
#include <libGuiSetupTab>
#include <libGuiAppDockTab>
#include <libGameSettingsTab>
#include <libEditorTab>

#include <libGuiSystemTab>
#include <libHotkeys>
#include <libRoutines>
#include <Class_SQLiteDB>
#include <libThemeCreator>


	debugLog("Interface Initialized")

OnExit(ExitFunc)


	debugLog("Console Initialized")

ui.gameTabs.choose(cfg.gameModuleList[cfg.activeGameTab])

autoUpdate()

winGetPos(&MainGuiX,&MainGuiY,,,ui.mainGui)
if cfg.startMinimizedEnabled
	hideGui()

createDockBar()
changeGameDDL()

winSetTransparent(0,ui.gameSettingsGui)
winSetTransparent(0,ui.afkGui)
ui.gameSettingsGui.show("x" mainGuiX+35 " y" mainGuiY+32 " w495 h176 noActivate")
drawAfkOutlines()
ui.afkGui.show("x" mainGuiX+45 " y" mainGuiY+50 " w270 h140 noActivate")
ui.MainGuiTabs.Choose(cfg.mainTabList[cfg.activeMainTab])
fadeIn()
tabsChanged()


