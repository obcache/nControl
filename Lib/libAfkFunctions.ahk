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

{ ;Primary Action Interface Functions
	toggleAutoFire(*) {
		try {
			WinNumber := GetWinNumber()
		} catch {
			debugLog("Couldn't get Window Number")
		}
		
		if (WinNumber) 
		{
			(ui.AutoFire%WinNumber%Enabled := !ui.AutoFire%WinNumber%Enabled)
			
			if (ui.AutoFire%WinNumber%Enabled)
			{
				NotifyOSD("Win" WinNumber ": AutoFire Enabled",10)
			}
			
		AutoFire(WinNumber)
		}
		debugLog("AutoFire WinNumber: " WinNumber)
	}

	toggleAutoClicker(*) {

		ui.AutoClickerEnabled := !ui.AutoClickerEnabled

		if (ui.AutoClickerEnabled)
		{
			ui.buttonAutoClicker.Opt("Background" cfg.ThemeButtonOnColor)
			ui.buttonAutoClicker.Value := "./Img/button_autoClicker_on.png"
		}
		
		While (ui.AutoClickerEnabled)
		{
			if (A_TimeIdlePhysical > 1500 && A_TimeIdleMouse > 1500)
			{
				Send("{LButton}")
				Sleep(cfg.AutoClickerSpeed*7.8125)
		}
			} 	
		ui.buttonAutoClicker.Opt("Background" cfg.ThemeButtonReadyColor)
		ui.buttonAutoClicker.Value := "./Img/button_autoClicker_ready.png"
	}

	toggleTower(*) {
		Global
		; ControlClick("x90 y10 SysTabControl321",ui.MainGui)
		; ControlClick("Static16",ui.AfkGui)
		; ControlClick("Static1",ui.AfkGui)

		if ui.towerEnabled = true
		{
			ui.towerEnabled := false
			;ui.buttonTower.value := "./Img/button_repeat.png"
			ui.AfkStatus1.value := "./Img/label_timer_off.png"
			ui.OpsStatus1.value := "./Img/label_timer_off.png"
			ui.OpsTowerButton.Opt("Background" cfg.ThemeButtonReadyColor)
			ui.OpsTowerButton.Redraw()

			ui.buttonTower.Opt("Background" cfg.ThemeButtonReadyColor)
			ui.buttonTower.Redraw()
			SetTimer(RestartTower,0)
			SetTimer(UpdateTimer,0)
			ui.progress.value := 0
			ui.OpsProgress.value := 0
		} else {
			ui.towerEnabled := true
			;ui.buttonTower.value := "./Img/button_repeating.png"
			if !(cfg.CelestialTowerEnabled) {
				ui.AfkStatus1.value := "./Img/label_infinite_tower.png"
				ui.OpsStatus1.value := "./Img/label_infinite_tower.png"
			} else { 
				ui.AfkStatus1.value := "./Img/label_infinite_tower.png"
				ui.OpsStatus1.value := "./Img/label_infinite_tower.png"
			}			
			ui.OpsTowerButton.Opt("Background" cfg.ThemeButtonOnColor)
			ui.OpsTowerButton.Redraw()
			ui.buttonTower.Opt("Background" cfg.ThemeButtonOnColor)
			ui.buttonTower.Redraw()
			SetTimer(UpdateTimer,1000)
			SetTimer(RestartTower,270000)
			UpdateTimer()
			RestartTower()
		}
	}

	toggleAntiIdle1(*) {
		(ui.AntiIdle1_enabled := !ui.AntiIdle1_enabled) ? AntiIdle1On() : AntiIdle1Off()
		
		antiIdle1On() {
			;SetTimer(AntiIdle,1080000)
			;SetTimer(UpdateTimer,4000)
			SetTimer(AntiIdle1,120000)
			SetTimer(UpdateTimer1,400)
			ui.progress.value := 0
			ui.OpsProgress1.value := 0
			;ui.buttonAntiIdle1.value := "./Img/button_on.png"
			ui.buttonTower.OnEvent("Click",ToggleTower,False)
			ui.AfkStatus1.value := "./Img/label_anti_idle_timer.png"
			ui.OpsStatus1.value := "./Img/label_anti_idle_timer.png"
			ui.OpsAntiIdle1Button.Value := "./Img/button_antiIdle_on.png"
			ui.OpsAntiIdle1Button.Opt("Background" cfg.ThemeButtonOnColor)
			ui.OpsAntiIdle1Button.Redraw()
			ui.buttonAntiIdle1.Value := "./Img/button_antiIdle_on.png"
			ui.buttonAntiIdle1.Opt("Background" cfg.ThemeButtonOnColor)
			ui.buttonAntiIdle1.Redraw()
			ui.buttonTower.ToolTip := "Tower timer disabled while AntiIdle is running."
			AntiIdle(1)
		}

		antiIdle1Off() {
			SetTimer(AntiIdle,0)
			SetTimer(UpdateTimer,0)
			ui.buttonTower.ToolTip := "Starts Infinte Tower"
			ui.AfkStatus1.value := "./Img/label_timer_off.png"
			ui.OpsStatus1.value := "./Img/label_timer_off.png"
			ui.OpsAntiIdle1Button.Opt("Background" cfg.ThemeButtonReadyColor)
			ui.OpsAntiIdle1Button.Redraw()
			ui.buttonAntiIdle1.Value := "./Img/button_antiIdle_ready.png"
			ui.buttonAntiIdle1.Opt("Background" cfg.ThemeButtonReadyColor)
			ui.buttonAntiIdle1.Redraw()
			ui.buttonTower.OnEvent("Click",ToggleTower)
			ui.progress.value := 0
			ui.Opsprogress.value := 0
		}
	}	

	toggleAntiIdle2(*) {
		(ui.AntiIdle2_enabled := !ui.AntiIdle2_enabled) ? AntiIdle2On() : AntiIdle2Off()

		antiIdle2On() {
			;SetTimer(AntiIdle2,1080000)
			;SetTimer(UpdateTimer,4000)
			SetTimer(AntiIdle2,120000)
			SetTimer(UpdateTimer2,400)
			ui.progress.value := 0
			ui.OpsProgress2.value := 0
			;ui.buttonAntiIdle2.value := "./Img/button_on.png"
			ui.buttonTower.OnEvent("Click",ToggleTower,False)
			ui.AfkStatus1.value := "./Img/label_anti_idle_timer.png"
			ui.OpsStatus2.value := "./Img/label_anti_idle_timer.png"
			ui.OpsAntiIdle2Button.Value := "./Img/button_antiIdle_on.png"
			ui.OpsAntiIdle2Button.Opt("Background" cfg.ThemeButtonOnColor)
			ui.OpsAntiIdle2Button.Redraw()
			ui.buttonAntiIdle2.Value := "./Img/button_antiIdle_on.png"
			ui.buttonAntiIdle2.Opt("Background" cfg.ThemeButtonOnColor)
			ui.buttonAntiIdle2.Redraw()
			ui.buttonTower.ToolTip := "Tower timer disabled while AntiIdle is running."
			AntiIdle(2)
		}		

		antiIdle2Off() {
			SetTimer(AntiIdle,0)
			SetTimer(UpdateTimer,0)
			ui.buttonTower.ToolTip := "Starts Infinte Tower"
			ui.AfkStatus1.value := "./Img/label_timer_off.png"
			ui.OpsStatus1.value := "./Img/label_timer_off.png"
			ui.OpsAntiIdle1Button.Opt("Background" cfg.ThemeButtonReadyColor)
			ui.OpsAntiIdle1Button.Redraw()
			ui.buttonAntiIdle1.Value := "./Img/button_antiIdle_ready.png"
			ui.buttonAntiIdle1.Opt("Background" cfg.ThemeButtonReadyColor)
			ui.buttonAntiIdle1.Redraw()
			ui.buttonTower.OnEvent("Click",ToggleTower)
			ui.progress.value := 0
			ui.Opsprogress.value := 0
		}


	}	


	antiIdle(WinNumber := 0) {
		Try
			ui.CurrWin := WinExist("A")

		CoordMode("Mouse","Client")
		MouseGetPos(&mouseX,&mouseY)
		
		Loop 2 {
			if (cfg.Game%A_Index%StatusEnabled) && ((WinNumber == A_Index) || (WinNumber == 0)) {
				WinActivate("ahk_id " ui.Win%A_Index%Hwnd)
				autoFire()
				
				if (cfg.SilentIdleEnabled)
				{
					WinMinimize("ahk_id " ui.Win%A_Index%Hwnd)
				}
			}
		}
		
		WinActivate("ahk_id " ui.CurrWin)
		Sleep(150)
		MouseMove(mouseX,mouseY)
	}


	toggleAntiIdleBoth(*) {
		(ui.AntiIdle_enabled := !ui.AntiIdle_enabled) ? AntiIdleBothOn() : AntiIdleBothOff()
	
		antiIdleBothOff() {
			SetTimer(AntiIdle,0)
			SetTimer(UpdateTimer,0)
			ui.buttonTower.ToolTip := "Starts Infinte Tower"
			ui.AfkStatus1.value := "./Img/label_timer_off.png"
			ui.OpsStatus1.value := "./Img/label_timer_off.png"
			ui.OpsAntiIdle1Button.Opt("Background" cfg.ThemeButtonReadyColor)
			ui.OpsAntiIdle1Button.Redraw()
			ui.buttonAntiIdle1.Value := "./Img/button_antiIdle_ready.png"
			ui.buttonAntiIdle1.Opt("Background" cfg.ThemeButtonReadyColor)
			ui.buttonAntiIdle1.Redraw()
			ui.buttonTower.OnEvent("Click",ToggleTower)
			ui.progress.value := 0
			ui.Opsprogress.value := 0
		}

		antiIdleBothOn() {
			;SetTimer(AntiIdle,1080000)
			;SetTimer(UpdateTimer,4000)
			SetTimer(AntiIdle,120000)
			SetTimer(UpdateTimer,400)
			ui.progress.value := 0
			ui.OpsProgress1.value := 0
			ui.OpsProgress2.value := 0
			;ui.buttonAntiIdle1.value := "./Img/button_on.png"
			ui.buttonTower.OnEvent("Click",ToggleTower,False)
			ui.AfkStatus1.value := "./Img/label_anti_idle_timer.png"
			ui.OpsStatus1.value := "./Img/label_anti_idle_timer.png"
			ui.OpsAntiIdle1Button.Value := "./Img/button_antiIdle_on.png"
			ui.OpsAntiIdle1Button.Opt("Background" cfg.ThemeButtonOnColor)
			ui.OpsAntiIdle1Button.Redraw()
			ui.buttonAntiIdle1.Value := "./Img/button_antiIdle_on.png"
			ui.buttonAntiIdle1.Opt("Background" cfg.ThemeButtonOnColor)
			ui.buttonAntiIdle1.Redraw()
			ui.buttonTower.ToolTip := "Tower timer disabled while AntiIdle is running."
			;ui.buttonAntiIdle2.value := "./Img/button_on.png"
			ui.buttonTower.OnEvent("Click",ToggleTower,False)
			ui.AfkStatus1.value := "./Img/label_anti_idle_timer.png"
			ui.OpsStatus2.value := "./Img/label_anti_idle_timer.png"
			ui.OpsAntiIdle2Button.Value := "./Img/button_antiIdle_on.png"
			ui.OpsAntiIdle2Button.Opt("Background" cfg.ThemeButtonOnColor)
			ui.OpsAntiIdle2Button.Redraw()
			ui.buttonAntiIdle2.Value := "./Img/button_antiIdle_on.png"
			ui.buttonAntiIdle2.Opt("Background" cfg.ThemeButtonOnColor)
			ui.buttonAntiIdle2.Redraw()
			ui.buttonTower.ToolTip := "Tower timer disabled while AntiIdle is running."
			AntiIdle(0)
		}
	}

	toggleAFK(*) {
		(ui.afkEnabled := !ui.afkEnabled) ? StartAFK() : StopAFK()
	}

	startAFK(*) {
		Global
		debugLog("Starting AFK")
		
		if (WinExist("ahk_id " ui.Win1Hwnd) && (ui.Win2Hwnd == "" || WinExist("ahk_id " ui.Win2Hwnd)))
		{
			RefreshWinHwnd()
		}
		;ui.buttonStartAFK.value := "./Img/button_started.png"
		ui.OpsAfkButton.Opt("Background" cfg.ThemeButtonOnColor)
		ui.buttonStartAFK.Opt("Background" cfg.ThemeButtonOnColor)
		ui.OpsAfkButton.Redraw()
		ui.buttonStartAFK.Redraw()	
		
		ui.Win1CurrentStep := 0
		ui.Win2CurrentStep := 0
		LoadAfkDataFile(&ui,&cfg,&afk)
		SetTimer(RunAfkRoutines,3000)
		;SetTimer(AfkRoutine,6000)
	;	AfkRoutine()
	}	

	stopAFK(*) {
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
		ui.OpsAfkButton.Opt("Background" cfg.ThemeButtonReadyColor)
		ui.buttonStartAFK.Opt("Background" cfg.ThemeButtonReadyColor)
		ui.OpsAfkButton.Redraw()
		ui.buttonStartAFK.Redraw()
		;SetTimer(RunAfkRoutines,0)
		SetTimer(AfkRoutine,0)
	}
} ;End Primary Action Interface Functions

{ ;Primary AFK Action Function
	loadAfkDataFile(&ui,&cfg,&afk) { ;Loads Automation Instruction Sets from Data File
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


	runAfkRoutines(*) { ;Executes Instruction Sets
		Global
		ui.Win1StillWorking := ""
		ui.Win2StillWorking := ""
		Thread("NoTimers",True)
			if (WinExist("ahk_id " ui.Win1Hwnd) && cfg.win2Enabled)
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

			if (WinExist("ahk_id " ui.Win2Hwnd) && cfg.win2Enabled)
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

	autoFire(WinNumber := GetWinNumber()) {
		if (WinNumber == 0) {
			debugLog("Couldn't Identify Window to Enable")
			Return 1
		}

		debugLog("Enabling AutoFire on Win" WinNumber)
		ui.buttonAutoFire.Opt("Background" cfg.ThemeButtonOnColor)
		ui.buttonAutoFire.Value := "./Img/button_autoFire" WinNumber "_on.png"
		ui.buttonAutoFire.Redraw()

		SetTimer(ResetAutoFireStatus,-1500)
		CoordMode("Mouse","Client")
		WinGetPos(&WinX,&WinY,&WinW,&WinH,"ahk_id " ui.Win%WinNumber%Hwnd)
		MouseMove(WinW-50,WinH-120)
		MouseClick("Left",WinW-50,WinH-120)
		
		if (WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd) == "RobloxPlayerBeta.exe")
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
		WinActivate("ahk_id " ui.Win%WinNumber%Hwnd)
	}


} ;End Primary AFK Action Functions

{ ;Primary Action Helper Functions
	attackWin(WinNumber,Command) {
		Global
		CoordMode("Mouse","Client")
		if (A_TimeIdlePhysical > 1500 and A_TimeIdleMouse > 1500)
		{
			CurrentHwnd := ui.Win%WinNumber%Hwnd
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

	resetAutoFireStatus(*) {
		ui.buttonAutoFire.Opt("Background" cfg.ThemeButtonReadyColor)
		ui.buttonAutoFire.Value := "./Img/button_autoFire_ready.png"
		ui.buttonAutoFire.Redraw()
	}

	updateTimer(Interval := 270) {
		if ui.Progress.value > Interval-1
			ui.Progress.value := 0
		ui.Progress.value += 1
	}

	inputWatcher() {
		if (A_TimeIdlePhysical < 2000) or (A_TimeIdleMouse < 2000) and (ui.afkEnabled) and (A_PriorKey = "Delete")
		{	
			;StopAFK()
		}
	}
	
	mouse(clickX,clickY,clickButton := "Left", ClickDirection := "") {
		SendEvent("{Click " clickX " " clickY " " clickButton " " clickDirection "}")
		Sleep(150)
	}	

} ;End Primary Action Helper Functions




	
	