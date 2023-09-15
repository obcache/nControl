#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}

Afk			:= Object()

ToggleAutoFire(*)
{
	WinNumber := GetWinNumber()
	if (WinNumber) 
	{
		if (ui.AutoFire%WinNumber%Enabled)
		{
			NotifyOSD("Win" WinNumber ": AutoFire Enabled",10)
		}
		
	AutoFire(WinNumber)
	}
	debugLog("AutoFire WinNumber: " WinNumber)
}

ToggleAutoClicker(*) {

	ui.AutoClickerEnabled := !ui.AutoClickerEnabled

	if (ui.AutoClickerEnabled)
	{
		ui.buttonAutoClicker.Opt("Background" cfg.ThemeButtonOnColor)
		ui.buttonAutoClicker.Value := "./Img/button_autoClicker_on.png"
	}
	
	While (ui.AutoClickerEnabled)
	{
		if !(A_TimeIdlePhysical > 1500 and A_TimeIdleMouse > 1500)
		{
			Send("{LButton}")
			Sleep(cfg.AutoClickerSpeed)
		} 	
	}
	ui.buttonAutoClicker.Opt("Background" cfg.ThemeButtonReadyColor)
	ui.buttonAutoClicker.Value := "./Img/button_autoClicker_ready.png"
}
	
ResetAutoFireStatus(*) {
	ui.AutoFire1Enabled := false
	ui.AutoFire2Enabled := false
	ui.buttonAutoFire.Opt("Background" cfg.ThemeButtonReadyColor)
	ui.buttonAutoFire.Value := "./Img/button_autoFire_ready.png"
	ui.buttonAutoFire.Redraw()
}



AutoFire(WinNumber := GetWinNumber())
{
	if (WinNumber == 0)
		Return 1
	if !(ui.AutoFire%WinNumber%Enabled)
	{
		ui.AutoFire%WinNumber%Enabled := true
		WinActivate("ahk_id " ui.Win%WinNumber%Hwnd.Text)
		debugLog("Enabling AutoFire on Win" WinNumber)
		ui.buttonAutoFire.Opt("Background" cfg.ThemeButtonOnColor)
		ui.buttonAutoFire.Value := "./Img/button_autoFire" WinNumber "_on.png"
		ui.buttonAutoFire.Redraw()
		SetTimer(ResetAutoFireStatus,-5000)
		CoordMode("Mouse","Client")
		WinGetPos(&WinX,&WinY,&WinW,&WinH,"ahk_id " ui.Win%WinNumber%Hwnd.Text)
		MouseMove(WinW-50,WinH-120)
		MouseClick("Left",WinW-50,WinH-120)
	
		if (WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd.Text) == "RobloxPlayerBeta.exe")
		{	
			debugLog("RobloxPlayerBeta AutoFire Start")
		
			MouseClick("Left",WinW-50,WinH-120)
			Sleep(250)
			Send("{LButton Down}")
			Sleep(250)
			Send("!{Tab}")
			Sleep(250)
			Send("{LButton Up}")
			Sleep(250)
			Send("!{Tab}")
		
		} else {
			Sleep(250)
			MouseClickDrag("Left",WinW-50,WinH-120,WinW+50,WinH-120,5)
		}
	} else {
		ui.AutoFire%WinNumber%Enabled := false
		debugLog("Disabling AutoFire")
		Send("{LButton}")
		ui.buttonAutoFire.Opt("Background" cfg.ThemeButtonReadyColor)
		ui.buttonAutoFire.Value := "./Img/button_autoFire_ready.png"
		ui.buttonAutoFire.Redraw()
	}

}

AttackWin(WinNumber,Command)
{
	Global
	CoordMode("Mouse","Client")
	if (A_TimeIdlePhysical > 1500 and A_TimeIdleMouse > 1500)
	{
		CurrentHwnd := ui.Win%WinNumber%Hwnd.Text
		ui.Win%WinNumber%Icon.value := "./Img/sleep_icon.png"
		ui.Win%WinNumber%Status.text := ""
		ui.Win%WinNumber%Icon.value := "./Img/attack_icon.png"
		ui.Win%WinNumber%Status.SetFont("s14 c00FFFF","Calibri")
		ui.Win%WinNumber%Status.text := "  " Command
		
		WinActivate("ahk_id " CurrentHwnd)
		WinGetPos(&WinX,&WinY,&WinW,&WinH,"ahk_id " CurrentHwnd)

		MouseClick("Left",WinW-50, WinH-120)
		
		Sleep(400)
		SendEvent("{" Command "}")
		Sleep(150)
		SendEvent("{" Command "}")

		if !(ui.Win%WinNumber%ClassDDL.Text == "Demon") 
		{
			AutoFire()
		}	
	}
}

LoadAfkDataFile(&ui,&cfg,&afk)
{
	debugLog("Loading AFK Routine Data File")
	debugLog("[DataRow],[AFK Profile],[Step],[Action],[Mouse To/From],[ClickX],[ClickY],[PreDelay],[Duration],[PostDelay]")
	
	Afk.DataRow := Array()
	Loop read, cfg.AfkDataFile
	{
		LineNumber := A_Index
		LogRow := LineNumber
		
		Afk.DataColumn := Array()
		Loop parse, A_LoopReadLine, "CSV"
		{
			Afk.DataColumn.InsertAt(A_Index,A_LoopField)
			LogRow .= "," A_LoopField 
		}
		Afk.DataRow.InsertAt(LineNumber,Afk.DataColumn)
		debugLog(LogRow)
	}
	debugLog("Finished Reading AfkData File")
}	

RunAfkRoutines(*)	
{
	if (WinExist("ahk_id " ui.Win1Hwnd.Text))
	{
		Loop Afk.DataRow.Length
		{
			if !(ui.AfkEnabled)
			{
				debugLog("AFK Disabled - Exiting Routine")
				Break
			}
			ui.Win1StillWorking := ""
	
			Try
			{
				if ((Afk.DataRow.Get(A_Index).Get(1) == ui.Win1ClassDDL.Text) && (Afk.DataRow.Get(A_Index).Get(2) > ui.Win1CurrentStep))
				{
					AttackWin(1,Afk.DataRow.Get(A_Index).Get(3))
					ui.Win1CurrentStep := Afk.DataRow.Get(A_Index).Get(2)
					ui.Win1StillWorking := true
					Break
				}
			}
		}

		if !(ui.Win1StillWorking)
		{
			debugLog("Finished Win1 AFK - Restarting")
			ui.Win1CurrentStep := 0
		}
	} else {
		RefreshWinHwnd()
	}

	if (WinExist("ahk_id " ui.Win2Hwnd.Text))
	{
		Loop Afk.DataRow.Length
		{
			if !(ui.AfkEnabled)
			{
				debugLog("AFK Disabled - Exiting Routine")
				Break
			}
			
			ui.Win2StillWorking := ""
			Try
			{
				if ((Afk.DataRow.Get(A_Index).Get(1) == ui.Win2ClassDDL.Text) && (Afk.DataRow.Get(A_Index).Get(2) > ui.Win2CurrentStep))
				{
					AttackWin(2,Afk.DataRow.Get(A_Index).Get(3))
					ui.Win2CurrentStep := Afk.DataRow.Get(A_Index).Get(2)
					ui.Win2StillWorking := true
					Break
				}
			}
		}
		if !(ui.Win2StillWorking)
		{
			debugLog("Finished Win2 AFK - Restarting")
			ui.Win2CurrentStep := 0
		}
	} 
}

ToggleAntiIdle(*)
{
	Global
	(ui.AntiIdle_enabled := !ui.AntiIdle_enabled) ? AntiIdleOn() : AntiIdleOff()
}	

AntiIdleOff()
{
	SetTimer(AntiIdle,0)
	SetTimer(UpdateTimer,0)
	;ui.buttonAntiIdle.value := "./Img/button_ready.png"
	ui.buttonTower.ToolTip := "Starts Infinte Tower"
	ui.status.value := "./Img/timer_off.png"
	ui.OpsAntiIdleButton.Opt("Background" cfg.ThemeDisabledColor)
	ui.OpsAntiIdleButton.Redraw()
	ui.buttonAntiIdle.Value := "./Img/button_antiIdle_ready.png"
	ui.buttonAntiIdle.Opt("Background" cfg.ThemeDisabledColor)
	ui.buttonAntiIdle.Redraw()
	ui.buttonTower.OnEvent("Click",ToggleTower)
	ui.progress.value := 0
}

AntiIdleOn()
{
	SetTimer(AntiIdle,1080000)
	SetTimer(UpdateTimer,4000)
	;ui.buttonAntiIdle.value := "./Img/button_on.png"
	ui.buttonTower.OnEvent("Click",ToggleTower,False)
	ui.status.value := "./Img/timer_antiIdle.png"
	ui.OpsAntiIdleButton.Opt("Background" cfg.ThemeFont1Color)
	ui.OpsAntiIdleButton.Redraw()
	ui.buttonAntiIdle.Value := "./Img/button_antiIdle_on.png"
	ui.buttonAntiIdle.Opt("Background" cfg.ThemeFont1Color)
	ui.buttonAntiIdle.Redraw()
	ui.buttonTower.ToolTip := "Tower timer disabled while AntiIdle is running."
	AntiIdle()
}

AntiIdle(*)
{
	Global
	
	ui.progress.value := 0

	Try
		ui.CurrWin := WinExist("A")

	CoordMode("Mouse","Client")
	MouseGetPos(&mouseX,&mouseY)
	RobloxWindow := WinGetList("Roblox")
	
	Loop RobloxWindow.Length
	{
		DllCall("SetForegroundWindow", "UInt", RobloxWindow[A_Index])
		Sleep(150)
		Send("{Space}")
		if (cfg.SilentIdleEnabled)
		{
			WinMinimize("ahk_id " RobloxWindow[A_Index])
		}
	}
	
	WinActivate("ahk_id " ui.CurrWin)
	Sleep(150)
	MouseMove(mouseX,mouseY)
}

ToggleAFK(*)
{
	Global
	(ui.afkEnabled := !ui.afkEnabled) ? StartAFK() : StopAFK()
}

StartAFK(*)
{
	Global
	ui.afkEnabled := true
	debugLog("Starting AFK")
	
	if !(ui.AfkDocked)
	{
		ToggleAfkDock()
	}
	
	if (WinExist("ahk_id " ui.Win1Hwnd.Text) && (ui.Win2Hwnd.Text == "" || WinExist("ahk_id " ui.Win2Hwnd.Text)))
	{
		RefreshWinHwnd()
	}
	;ui.buttonStartAFK.value := "./Img/button_started.png"
	ui.OpsAfkButton.Opt("Background" cfg.ThemeFont1Color)
	ui.OpsAfkButton.Redraw()
	ui.buttonStartAFK.Opt("Background" cfg.ThemeFont1Color)
	ui.buttonStartAFK.Redraw()	
	
	ui.Win1CurrentStep := 0
	ui.Win2CurrentStep := 0
	LoadAfkDataFile(&ui,&cfg,&afk)
	SetTimer(RunAfkRoutines,3000)
	;SetTimer(AfkRoutine,6000)
;	AfkRoutine()
}	

StopAFK(*)
{
	Global
	Thread("NoTimers",true)
	SendEvent("{LButton Up}")
	ui.afkEnabled := false
	debugLog("Stopping AFK")
	;ui.buttonStartAFK.value := "./Img/button_start.png"
	ui.Win1Icon.value := "./Img/sleep_icon.png"
	ui.Win1Status.text := ""
	ui.Win2Icon.value := "./Img/sleep_icon.png"
	ui.Win2Status.text := ""
	;ui.buttonStartAFK.value := "./Img/button_start.png"
	ui.OpsAfkButton.Opt("Background" cfg.ThemeDisabledColor)
	ui.OpsAfkButton.Redraw()
	ui.buttonStartAFK.Opt("Background" cfg.ThemeDisabledColor)
	ui.buttonStartAFK.Redraw()
	;SetTimer(RunAfkRoutines,0)
	SetTimer(AfkRoutine,0)
}

AfkRoutine(*)
{
	Global
	
	Sleep(1000)
	if (ui.Win1Hwnd.Text)
		if (ui.Win1ClassDDL.text != "Summoner")
			AttackWin(1,"R")

	Sleep(2000)
	if (ui.Win2Hwnd.Text)
		AttackWin(2,"X")
		
	if (ui.Win1Hwnd.Text)
		AttackWin(1,"F")

	Sleep(3000)
	if (ui.Win2Hwnd.Text)
		if (ui.Win2ClassDDL.text != "Demon")
			AttackWin(2,"E")
		
	if (ui.Win1Hwnd.Text)
		AttackWin(1,"1")

	Sleep(2000)
	if (ui.Win2Hwnd.Text)
		if (ui.Win2ClassDDL.text != "Summoner")
			AttackWin(2,"R")
		
	if (ui.Win1Hwnd.Text)
		AttackWin(1,"X")

	Sleep(3000)
	if (ui.Win2Hwnd.Text)
		AttackWin(2,"F")
		
	if (ui.Win1Hwnd.Text)
		if (ui.Win1ClassDDL.text != "Demon")
			AttackWin(1,"E")

	Sleep(2000)
	if (ui.Win2Hwnd.Text)
		AttackWin(2,"1")
}

ToggleTower(*)
{
	Global
	ControlClick("x90 y10 SysTabControl321",ui.MainGui)
	ControlClick("Static16",ui.AfkGui)
	ControlClick("Static1",ui.AfkGui)

	if ui.towerEnabled = true
	{
		ui.towerEnabled := false
		;ui.buttonTower.value := "./Img/button_repeat.png"
		ui.status.value := "./Img/timer_off.png"
		ui.OpsTowerButton.Opt("Background" cfg.ThemeDisabledColor)
		ui.OpsTowerButton.Redraw()
		ui.buttonTower.Opt("Background" cfg.ThemeDisabledColor)
		ui.buttonTower.Redraw()
		SetTimer(RestartTower,0)
		SetTimer(UpdateTimer,0)
		ui.progress.value := 0
	} else {
		ui.towerEnabled := true
		;ui.buttonTower.value := "./Img/button_repeating.png"
		ui.status.value := "./Img/timer_infiniteTower.png"
		ui.OpsTowerButton.Opt("Background" cfg.ThemeFont1Color)
		ui.OpsTowerButton.Redraw()
		ui.buttonTower.Opt("Background" cfg.ThemeFont1Color)
		ui.buttonTower.Redraw()
		SetTimer(UpdateTimer,1000)
		SetTimer(RestartTower,270000)
		UpdateTimer()
		RestartTower()
	}
}

ReturnToWorld(*)
{
	Global
	Thread("NoTimers",true)

	if (WinExist("ahk_id " ui.Win1Hwnd.Text) && (ui.Win2Hwnd.Text == "" || WinExist("ahk_id " ui.Win2Hwnd.Text)))
	{
		RefreshWinHwnd()
	}
	
	Loop GameWinID.Length
	{
		WinActivate("ahk_id " GameWinID[A_Index])
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

RestartTower(*)
{
	Global

	if (ui.afkEnabled = true)
	{
		StopAFK()
		Sleep(1000)
		StopAFK()
		Sleep(2000)
		StopAFK()
	}

	ui.progress.value := 0
	if (WinExist("ahk_id " ui.Win1Hwnd.Text) && (ui.Win2Hwnd.Text == "" || WinExist("ahk_id " ui.Win2Hwnd.Text)))
	{
		RefreshWinHwnd()
	}
	
	Loop GameWinID.Length
	{
		WinActivate("ahk_id " GameWinID[A_Index])
		CoordMode("Mouse","Client")
		WinGetPos(&WinX,&WinY,&WinW,&WinH,"ahk_id " GameWinID[A_Index])
		InfTowerButtonX := (WinW/2)-40
		InfTowerButtonY := (WinH/2)+130
		StartButtonX 	:= (WinW/2)+240
		StartButtonY 	:= (WinH/2)+130
		
		if (WinGetProcessName("ahk_id " ui.Win%A_Index%Hwnd.Text) = "ApplicationFrameHost.exe")
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
	StartAFK()
}
	
; RefreshWinHwnd()
; {
	; Global
	; WinNum := 1
	; GameWinID := WinGetList("Roblox")

	; Loop GameWinID.Length
	; {
		; if (WinGetProcessName(GameWinID[WinNum]) == "RobloxPlayerBeta.exe" || WinGetProcessName(GameWinID[WinNum]) == "ApplicationFrameHost.exe")
		; {
			; WinNum += 1
		; } else {
			; GameWinID.RemoveAt(A_Index)
		; }
	; }
	
	; if (GameWinID.Length < 2)
	; {
		; debugLog("Only 1 Roblox Window Found")
		; ui.Win2ClassDDL.Add(["Disabled"])
		; ui.Win2ClassDDL.Text := "Disabled"
		; ui.Win2ClassDDL.Opt("+disabled")
	; } else {
		; ui.Win2ClassDDL.Opt("-disabled")
	; }

	; RobloxWinNum := 0
	; Loop GameWinID.Length
	; {
		; if (WinGetProcessName(GameWinID[A_Index]) || WinGetProcessName(GameWinID[A_Index]))
		; {
			; RobloxWinNum += 1
			; ui.Win%RobloxWinNum%Hwnd.Text := GameWinID[A_Index]
		; }
		; debugLog("Assigned " ui.Win%A_Index%Hwnd.Text " to Window " A_Index)
	; }
	
	; if !(ui.Win1Hwnd.Text)
	; {
		; debugLog("No Roblox Windows Found")
		; StopAFK()
		; if (ui.towerEnabled = true)
		; {
			; ToggleTower()
		; }
		; if (ui.antiIdleEnabled = true)
		; {
			; ToggleAntiIdle()
		; }
	; }
; }


		


UpdateTimer(Interval := 270)
{
	if ui.Progress.value > Interval-1
		ui.Progress.value := 0
	ui.Progress.value += 1
}

Mouse(clickX,clickY,clickButton := "Left", ClickDirection := "")
{
	SendEvent("{Click " clickX " " clickY " " clickButton " " clickDirection "}")
	Sleep(150)
}	

InputWatcher()
{
	Global
	if (A_TimeIdlePhysical < 2000) or (A_TimeIdleMouse < 2000) and (ui.afkEnabled) and (A_PriorKey = "Delete")
	{	
		;StopAFK()
	}
}

HideAfkGui(*)
{
	global
	ui.AfkGui.Hide()
}
	
wmAfkLButtonDown(wParam, lParam, msg, hwnd)
{
	Global
	if !(ui.AfkAnchoredToGui)
		PostMessage(0xA1, 2)
}
	