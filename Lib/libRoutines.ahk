#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}


RobloxLauncher() {
	BlockInput(true)
	BlockInput("SendAndMouse")
	SetTitleMatchMode(3)
	CoordMode("Mouse","Client")
	debugLog("Executing Roblox")
	Win1Exec := "explorer.exe shell:appsFolder\ROBLOXCORPORATION.ROBLOX_55nm5eh3cm0pr!App"
	Win2Exec := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Roblox\Roblox Player.lnk"
	Run(Win1Exec)
	Run(Win2Exec)
	debugLog("Pausing 10 seconds for Roblox to start")
	Sleep(10000)

	debugLog("Getting Roblox App ID")
	CurrWin := "ahk_exe ApplicationFrameHost.exe"
	ClickX := 140
	ClickY := 615
	WinActivate(CurrWin)
	Sleep(1000)
	debugLog("Maximizing Roblox App")

	WinMaximize(CurrWin)
	Sleep(2000)
	SendEvent("{LWin Down}{Right}{LWin Up}")
	Sleep(3000)
	debugLog("Clicking Start on Roblox App")
	MouseMove(ClickX,ClickY,5)
	Sleep(1000)
	MouseMove(ClickX+5,ClickY,5)
	Sleep(1000)
	MouseClick("Left",ClickX,ClickY)
	Sleep(1000)
	MouseClick("Left",ClickX,ClickY)

	CurrWin := "ahk_exe RobloxPlayerBeta.exe"
	ClickX := 140
	ClickY := 585
	WinActivate(CurrWin)
	Sleep(1000)
	debugLog("Maximizing Roblox Client")

	WinMaximize(CurrWin)
	Sleep(2000)
	SendEvent("{LWin Down}{Left}{LWin Up}")
	Sleep(3000)
	debugLog("Clicking Start on World//Zero for Roblox Client")
	MouseMove(ClickX,ClickY,5)
	Sleep(1000)
	MouseMove(ClickX+5,ClickY,5)
	Sleep(1000)
	MouseClick("Left",ClickX,ClickY)
	Sleep(1000)
	MouseClick("Left",ClickX,ClickY)
	Sleep(10000)

	debugLog("Clicking Play in World//Zero on Roblox App")
	CurrWin := "ahk_exe ApplicationFrameHost.exe"
	WinActivate(CurrWin)
	WinGetPos(&WinX,&WinY,&WinW,&WinH,CurrWin)
	SendEvent("{CLick " WinW/2 " " WinH-85 " Left}")
	Sleep(1000)
	SendEvent("{CLick " WinW/2 " " WinH-85 " Left}")
	Sleep(6000)

	debugLog("Clicking Play in World//Zero on Roblox Client")
	CurrWin := "ahk_exe RobloxPlayerBeta.exe"
	WinActivate(CurrWin)
	WinGetPos(&WinX,&WinY,&WinW,&WinH,CurrWin)
	SendEvent("{CLick " WinW/2 " " WinH-115 " Left}")
	Sleep(1000)
	SendEvent("{CLick " WinW/2 " " WinH-115 " Left}")
	BlockInput(false)
	BlockInput("Off")
	RefreshWinHwnd()
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

RestartTower(*) {
	if (ui.afkEnabled = true)
	{
		StopAFK()
		Sleep(1000)
		StopAFK()
		Sleep(2000)
		StopAFK()
	}

	ui.afkProgress.value := 0
	if (WinExist("ahk_id " ui.Win1Hwnd) && (ui.Win2Hwnd == "" || WinExist("ahk_id " ui.Win2Hwnd)))
	{
		RefreshWinHwnd()
	}
	
	Loop 2
	{
		this_window := "ahk_id " ui.Win%A_Index%Hwnd
		if (cfg.win%A_Index%Enabled)
		{
			WinActivate(this_window)
		
			CoordMode("Mouse","Client")
			WinGetPos(&WinX,&WinY,&WinW,&WinH,this_window)
			InfTowerButtonX := (WinW/2)-40
			InfTowerButtonY := (WinH/2)+130
			StartButtonX 	:= (WinW/2)+240
			StartButtonY 	:= (WinH/2)+130
			
			if (WinGetProcessName(this_window) == "ApplicationFrameHost.exe")
			{
				InfTowerButtonY += 30
				StartButtonY 	+= 30
			}
		
			Sleep(250)
			Send("{V}")
			Sleep(1200)

			Mouse(InfTowerButtonX,InfTowerButtonY)
			Sleep(1000)
			Mouse(StartButtonX,StartButtonY)
			Sleep(1000)
		}
	}
}