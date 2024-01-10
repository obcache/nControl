#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}
clientID := ""
StartRoblox(mode := "Both") {
	global
	appPID := ""
	clientID := ""
	loopCount := 0
	SetTitleMatchMode(3)

	if (mode == "both" || mode == "app") {
		debugLog("Launching Robox App")
		runApp("roblox")
		while !(winExist("ahk_exe applicationFrameHost.exe")) || (loopCount < 30) {
			loopCount += 1
			Sleep(500)
		}

		if loopCount >= 30 {
			debugLog("Couldn't start Roblox App")
		}
		loopCount := 0
	
	}

	if (mode == "both" || mode == "client") {
		robloxPlayerInstaller 	:= regRead("HKEY_CURRENT_USER\Software\ROBLOX Corporation\Environments\roblox-player",,)
		debugLog("Starting Roblox Client")

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
		while !(winExist("ahk_exe RobloxPlayerBeta.exe")) || (loopCount < 30) {
			loopCount += 1
			clientID := WinExist("ahk_exe robloxPlayerBeta.exe")
		}
		if loopCount >= 30 {
			debugLog("Can't start Roblox Client")
		}
		loopCount := 0
		clientID := WinExist("ahk_exe robloxPlayerBeta.exe")
		Sleep(1000)
	}
	RefreshWinHwnd()
	ui.mainGuiTabs.Choose("Sys")
}
robloxSplitScreen() {
	global
	CoordMode("Mouse","Client")
	winMove(-7,0,(A_ScreenWidth*0.5)+14,(A_ScreenHeight-GetTaskbarHeight())+7,"ahk_id " clientID)
	winWait("Roblox","Roblox",15)
	winMove((A_ScreenWidth*0.5)-7,-7,(A_ScreenWidth*0.5)+14,A_ScreenHeight-GetTaskbarHeight()+14,"ahk_exe applicationframehost.exe")

	Sleep(1000)
	A_CoordModePixel := "Client"

	CurrWin := "ahk_exe ApplicationFrameHost.exe"
	WinActivate(CurrWin)

}
RobloxLauncher() {
	global
	startRoblox("both")
	robloxSplitScreen()
	RefreshWinHwnd()


	; CurrWin := "ahk_exe RobloxPlayerBeta.exe"
	; WinActivate(CurrWin)
	; ClickX := (A_ScreenWidth*0.5)*0.10
	; ClickY := (A_ScreenHeight*.032)+35
	; Sleep(1000)
	; MouseMove(ClickX,ClickY,5)
	; Sleep(1000)
	; MouseMove(ClickX+5,ClickY,5)
	; Sleep(1000)
	; MouseClick("Left",ClickX,ClickY)
	; Sleep(1000)
	; MouseClick("Left",ClickX,ClickY)
	; MouseMove(ClickX,ClickY,5)
	; Sleep(1000)
	; MouseMove(ClickX+5,ClickY,5)
	; Sleep(1000)
	; MouseClick("Left",ClickX,ClickY)
	; Sleep(1000)
	; MouseClick("Left",ClickX,ClickY)


	; CurrWin := "ahk_exe ApplicationFrameHost.exe"
	; WinActivate(CurrWin)
	; MouseClick("Left",ClickX,ClickY)
	
	; while !(pixelSearch(&pX,&pY,300,300,600,400,0x00B06F)) {
		; sleep(500)
	; }
	; ClickX := pX+10
	; ClickY := pY+10
	; Sleep(1000)
	; MouseMove(ClickX,ClickY,5)
	; Sleep(1000)
	; MouseMove(ClickX+5,ClickY,5)
	; Sleep(1000)
	; MouseClick("Left",ClickX,ClickY)
	; Sleep(1000)
	; MouseClick("Left",ClickX,ClickY)

	; currWin := "ahk_exe robloxPlayerBeta.exe"
	; WinActivate(CurrWin)
	; while !(pixelSearch(&pX,&pY,300,300,600,400,0x00B06F)) {
		; sleep(500)
	; }
	; ClickX := pX+10
	; ClickY := pY+10
	; Sleep(1000)
	; MouseMove(ClickX,ClickY,5)
	; Sleep(1000)
	; MouseMove(ClickX+5,ClickY,5)
	; Sleep(1000)
	; MouseClick("Left",ClickX,ClickY)
	; Sleep(1000)
	; MouseClick("Left",ClickX,ClickY)


}

AfkRoutine(*) {
	Sleep(1000)
	if (ui.Win1Hwnd)
		if (ui.Win1ClassDDL.text != "Summoner")
			AttackWin(1,"R")

	Sleep(2000)
	if (ui.Win2Hwnd)
		AttackWin(2,"X")
		
	if (ui.Win1Hwnd)
		AttackWin(1,"F")

	Sleep(3000)
	if (ui.Win2Hwnd)
		if (ui.Win2ClassDDL.text != "Demon")
			AttackWin(2,"E")
		
	if (ui.Win1Hwnd)
		AttackWin(1,"1")

	Sleep(2000)
	if (ui.Win2Hwnd)
		if (ui.Win2ClassDDL.text != "Summoner")
			AttackWin(2,"R")
		
	if (ui.Win1Hwnd)
		AttackWin(1,"X")

	Sleep(3000)
	if (ui.Win2Hwnd)
		AttackWin(2,"F")
		
	if (ui.Win1Hwnd)
		if (ui.Win1ClassDDL.text != "Demon")
			AttackWin(1,"E")

	Sleep(2000)
	if (ui.Win2Hwnd)
		AttackWin(2,"1")
}


ReturnToWorld(*) {
	Thread("NoTimers",true)

	if (WinExist("ahk_id " ui.Win1Hwnd) && (ui.Win2Hwnd == "" || WinExist("ahk_id " ui.Win2Hwnd)))
	{
		RefreshWinHwnd()
	}
	
	Loop ui.FilteredGameWindowsList.Length
	{
		WinActivate("ahk_id " ui.FilteredGameWindowsList[A_Index])
		CoordMode("Mouse","Client")

		try
			ui.CurrWin := WinExist("A")

		WinGetPos(&WinX,&WinY,&WinW,&WinH,ui.CurrWin)
		ReturnToWorldButtonX := (WinW/2)-200
		ReturnToWorldButtonY := (WinH/2)-170
		
		if (WinGetProcessName("ahk_id " CurrWin) = "ApplicationFrameHost.exe")
		{
			ReturnToWorldButtonY += 30
		}
		
		if (A_TimeIdlePhysical < 1000) or (A_TimeIdleMouse < 1000)
			Return

		Sleep(250)
		Send("{N}")
		Sleep(1200)

		Mouse(ReturnToWorldButtonX,ReturnToWorldButtonY)
		Sleep(1000)
		Mouse(ReturnToWorldButtonX,ReturnToWorldButtonY)
		Sleep(1000)
	}
	StopAFK()
	if (ui.towerEnabled)
	{
		ToggleTower()
	}
}
