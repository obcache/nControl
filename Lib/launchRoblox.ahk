#requires autohotkey v2.0+
#singleinstance


appPID := ""
clientID := ""
; SetTimer(moveWindows,5)

robloxPlayerInstaller 	:= regRead("HKEY_CURRENT_USER\Software\ROBLOX Corporation\Environments\roblox-player",,)
;robloxPlayerVersion		:= regRead("HKEY_CURRENT_USER\Software\ROBLOX Corporation\Environments\roblox-player","version",)


SetTitleMatchMode(3)
runApp("roblox")
if (oldClientID := winExist("ahk_exe robloxPlayerBeta.exe"))
	winKill(oldClientID)
run(robloxPlayerInstaller)
sleep(1000)
while !(winExist("ahk_exe robloxplayerbeta.exe")) {
	sleep(500)
}
while (winExist("ahk_exe robloxPlayerBeta.exe") == clientID) {
	sleep(500)
}
clientID := WinExist("ahk_exe robloxPlayerBeta.exe")
winMove(-7,0,(A_ScreenWidth*0.5)+14,(A_ScreenHeight-GetTaskbarHeight())+7,"ahk_id " clientID)

;winWait("Roblox","Roblox",15)
winMove((A_ScreenWidth*0.5)-7,-7,(A_ScreenWidth*0.5)+14,A_ScreenHeight-GetTaskbarHeight()+14,"ahk_exe applicationframehost.exe")

Sleep(1000)
;launchWorldZero()
	
runApp(appName) {
	global
	For app in ComObject('Shell.Application').NameSpace('shell:AppsFolder').Items
	(app.Name = appName) && RunWait('explorer shell:appsFolder\' app.Path,,,&appPID)
}

GetTaskbarHeight()
{
	MonitorGet(MonitorGetPrimary(),,,,&TaskbarBottom)
	MonitorGetWorkArea(MonitorGetPrimary(),,,,&TaskbarTop)
		
	TaskbarHeight := TaskbarBottom - TaskbarTop
	Return TaskbarHeight
}

launchWorldZero() {
global
coordmode("mouse","screen")
WinGetPos(&x,&y,&w,&h,"ahk_exe applicationFrameHost.exe")
winActivate("ahk_exe applicationFrameHost.exe")
sleep(500)
MouseClick("Left",(x+(w*0.1)),(y+(h*0.32)))
sleep(500)

winActivate("ahk_id " clientID)
WinGetPos(&cx,&cy,&cw,&ch,"ahk_id " clientID)
sleep(1000)
MouseMove(((a_screenwidth/2)*0.1),((a_screenheight-getTaskbarHeight())*0.32))
sleep(3000)
SendEvent("{LButton}")
Sleep(1000)
SendEvent("{LButton}")
Sleep(1000)
SendEvent("{LButton}")
Sleep(1000)
SendEvent("{LButton}")
}


;175,444 1718,1360
