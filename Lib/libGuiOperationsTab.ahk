#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	Return
}

GuiOperationsTab(&ui,&cfg,&afk) { ;libGuiOperationsTab
	
		Afk.DataRow := Array()
	ui.ProfileList := Array()
	ui.ProfileListString := ""
	Loop read, cfg.AfkDataFile
	{
		LineNumber := A_Index
		Afk.DataColumn := Array()
		Loop parse, A_LoopReadLine, "CSV"
		{
			if (A_Index == 1 && !(InStr(ui.ProfileListString,A_LoopField)))
			{
				ui.ProfileListString .= A_LoopField ","
				ui.ProfileList.Push(A_LoopField)
			}
		}
		
	}
	
	debugLog("Finished Reading AfkData File")
	
	ui.MainGuiTabs.UseTab("Sys")
	ui.MainGui.SetFont("s14","Calibri Thin")

	ui.OpsDockButton := ui.MainGui.AddPicture("x38 y34 w27 h27 section Background" cfg.ThemeButtonReadyColor,"./Img/button_dockLeft_ready.png")
	ui.OpsDockButton.OnEvent("Click",ToggleAfkDock)
	ui.OpsDockButton.ToolTip := "Dock AFK Panel"
	
	ui.OpsTowerButton := ui.MainGui.AddPicture("x+1 ys+0 w27 h27 Background" cfg.ThemeButtonReadyColor,"./Img/button_tower_ready.png")
	ui.OpsTowerButton.OnEvent("Click",ToggleTower)
	ui.OpsTowerButton.ToolTip := "Toggle Tower Timer + AFK"
	
	ui.OpsAfkButton := ui.MainGui.AddPicture("x+1 ys+0 w27 h27 Background" cfg.ThemeButtonReadyColor,"./Img/button_afk_ready.png")
	ui.OpsAfkButton.OnEvent("Click",ToggleAFK)
	ui.OpsAfkButton.ToolTip := "Toggle AFK"
	
	ui.OpsAntiIdleButton := ui.MainGui.AddPicture("x+1 ys+0 w27 h27 Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
	ui.OpsAntiIdleButton.OnEvent("Click",ToggleAntiIdle)
	ui.OpsAntiIdleButton.ToolTip := "Toggle Anti-Idle"
	
	ui.buttonAutoFire := ui.MainGui.AddPicture("x+1 ys+0 w27 h27 Background" cfg.ThemeButtonReadyColor,"./Img/button_AutoFire_ready.png")
	ui.buttonAutoFire.OnEvent("Click",toggleAutoFire)
	ui.buttonAutoFire.ToolTip := "Toggles AutoFire on Current Window"
	
	ui.buttonAutoClicker := ui.MainGui.AddPicture("x+1 ys+0 w27 h27 Background" cfg.ThemeButtonReadyColor,"./Img/button_AutoClicker_ready.png")
	ui.buttonAutoClicker.OnEvent("Click",ToggleAutoClicker)
	ui.buttonAutoClicker.ToolTip := "Toggles AutoClicker"
	
	ui.OpsClockModeLabel := ui.MainGui.AddText("x+2 ys+1 section w30 h24 Background" cfg.ThemePanel2Color,"Clock")
	ui.OpsClockModeLabel.SetFont("s8 c" cfg.ThemeFont2Color,"Ariel Bold")
	
	ui.OpsClock := ui.MainGui.AddText("x+0 ys+1 w120 Right h23 Background" cfg.ThemePanel2Color " c" cfg.ThemeFont2Color,)
	ui.OpsClock.SetFont("s16","Orbitron")
	ui.OpsClock.OnEvent("Click",ChangeClockMode)
	ui.OpsClock.OnEvent("ContextMenu",ShowClockMenu)
	ui.OpsClock.ToolTip := "Left Click Starts/Stops Timer. `nRight Click Resets Timer. `nDouble-Click to Return to Time Mode."
	SetTimer(opsClickTimeUpdate,1000)

	ui.RefreshWindowHandlesButton := ui.MainGui.AddPicture("x+1 ys-2 section w27 h27 Background" cfg.ThemeFont1Color, "./Img/button_refresh.png")	
	ui.RefreshWindowHandlesButton.OnEvent("Click",RefreshWinHwnd)
	ui.RefreshWindowHandlesButton.ToolTip := "If enabled,  `"Current Game`" will automatically set`n itself to top entry in the Games List that is currently running."
	
	; ui.GameAddButton := ui.MainGui.AddPicture("ys w30 h26 section Background" cfg.ThemeButtonReadyColor,"./Img/button_plus_ready.png")
	; ui.GameAddButton.OnEvent("Click",AddGame)
	; ui.GameAddButton.ToolTip := "Add New Game to List"
	
	; ui.GameRemoveButton	:= ui.MainGui.AddPicture("ys w29 h26 Background" cfg.ThemeButtonReadyColor,"./Img/button_minus_ready.png")
	; ui.GameRemoveButton.OnEvent("Click",RemoveGame)
	; ui.GameRemoveButton.ToolTip := "Remove Selected Game from List"

	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri Thin")
	
	ui.GameDDL := ui.MainGui.AddDropDownList("x+2 ys w148 Background" cfg.ThemeEditboxColor " AltSubmit -E0x200 Choose" cfg.Game,cfg.GameList)
	ui.GameDDL.ToolTip := "Select the Game You Are Playing"
	ui.GameDDL.OnEvent("Change",ChangeGameDDL)
	ui.MainGuiTabs.Focus()

	ui.MainGui.SetFont("s10 c" cfg.ThemeFont1Color,"Calibri")	
	ui.GameWindowsListBox := ui.MainGui.AddListBox("x38 y+1 w0 r10 section hidden Background" cfg.ThemePanel1Color " -E0x200 multi",ui.gameWindowsList)
	ui.GameWindowsListBox.ToolTip := "List of available game windows in session"


	{ ;GameWindows Gui Controls


		
		ui.MainGui.SetFont("s9 c" cfg.ThemeFont1Color,"Calibri")
		ui.Win1Label := ui.MainGui.AddText("xs-2 y62 section w70 h20 c" cfg.ThemeFont2Color " Center Background" cfg.ThemePanel1Color,"Game1")

		ui.Game1StatusIcon := ui.MainGui.AddPicture("xs section w70 h25 Background" cfg.ThemeButtonReadyColor, cfg.toggleOff)
		ui.Game1StatusIcon.OnEvent("Click",ToggleGame1Status)
		ui.Game1StatusIcon.ToolTip := "Toggle to have this window ignored by nControl"

		ui.MainGui.SetFont("s8 c" cfg.ThemeFont2Color,"Calibri")

		ui.Win1Name := ui.MainGui.AddText("ys-18 section w155 h15 Right Background" cfg.ThemePanel2AccentColor,"Game   ")
		ui.Win1ProcessName := ui.MainGui.AddText("xs y+-1 section w155 h15 Right Background" cfg.ThemePanel2AccentColor,"Not   ")
		ui.Win1HwndText := ui.MainGui.AddText("xs y+-1 section w155 h15 Right Background" cfg.ThemePanel2AccentColor,"Found   ")
		ui.Win1HwndText.ToolTip := "Window ID for Game Window 1"	
		ui.buttonSwapHwnd := ui.MainGui.AddPicture("ys-30 section w45 h45 Background" (cfg.HwndSwapEnabled ? cfg.ThemeButtonOnColor : cfg.ThemeBackgroundColor), (cfg.HwndSwapEnabled ? "./Img/button_swapHwnd_enabled.png" : "./Img/button_swapHwnd_disabled.png"))
		ui.buttonSwapHwnd.OnEvent("Click",ToggleHwndSwap)
		ui.buttonSwapHwnd.ToolTip := "Swap Windows"
		


		
		;ui.MainGui.SetFont("s13 c" cfg.ThemeFont1Color,"Calibri")
		ui.MainGui.SetFont("s8 c" cfg.ThemeFont2Color,"Calibri")
		ui.Win2Name := ui.MainGui.AddText("ys+2 section w155 h15 Background" cfg.ThemePanel2AccentColor," Game")
		ui.Win2ProcessName := ui.MainGui.AddText("xs y+-1 section w155 h15 Background" cfg.ThemePanel2AccentColor," Not")
		ui.Win2HwndText := ui.MainGui.AddText("xs y+-1  section w155 h15 Background" cfg.ThemePanel2AccentColor," Found")
		ui.Win2HwndText.ToolTip := "Window ID for Game Window 1"	
		ui.MainGui.SetFont("s9 c" cfg.ThemeFont1Color,"Calibri")
		ui.Win2Label := ui.MainGui.AddText("ys-30 section w70 h20 c" cfg.ThemeFont2Color " Center Background" cfg.ThemePanel1Color,"Game2")
		ui.Game2StatusIcon := ui.MainGui.AddPicture("xs section w70 h25 Background" cfg.ThemeButtonReadyColor, cfg.toggleOff)
		ui.Game2StatusIcon.OnEvent("Click",ToggleGame1Status)
		ui.Game2StatusIcon.ToolTip := "Toggle to have this window ignored by nControl"

		drawOpsOutlines()
	ui.Win1Status := ui.MainGui.AddText("xs-425 section w45 h22 +Background" cfg.ThemePanel1Color,"")
	ui.Win1Icon := ui.MainGui.AddPicture("ys section w25 h22 Background" cfg.ThemePanel1Color,"./Img/sleep_icon.png")
	ui.Win1ClassDDL := ui.MainGui.AddDDL("ys w155 AltSubmit choose3 Background" cfg.ThemeEditBoxColor, ui.ProfileList)
	ui.Win1ClassDDL.SetFont("s11")
	ui.Win1ClassDDL.OnEvent("Change",RefreshWin1AfkRoutine)

	ui.Win2ClassDDL := ui.MainGui.AddDDL("x+47 ys w155 AltSubmit choose3 Background" cfg.ThemeEditBoxColor, ui.ProfileList)
	ui.Win2ClassDDL.SetFont("s11")
	ui.Win2ClassDDL.OnEvent("Change",RefreshWin2AfkRoutine)
	ui.Win2Icon := ui.MainGui.AddPicture("ys w25 h22 Background" cfg.ThemePanel1Color,"./Img/sleep_icon.png")
	ui.Win2Status := ui.MainGui.AddText("x+0 ys section w45 h22 +Background" cfg.ThemePanel1Color,"")

	
	ui.MainGui.AddPicture("x132 y148 w15 h40 section","./Img/label_left_trim.png")
	ui.OpsStatus := ui.MainGui.AddPicture("ys w100 h40 Background" cfg.ThemeButtonReadyColor,"./Img/label_timer_off.png")  ; XX & YY serve to auto-size the window.
	ui.MainGui.AddPicture("x+0 ys w15 h40","./Img/label_right_trim.png")
	drawOutline(ui.mainGui,35,182,227,27,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,3)	;Status Bar
	drawOutline(ui.mainGui,35,180,224,27,cfg.ThemeBorderLightColor,cfg.ThemeBorderDarkColor,2)	;Status Bar

	ui.OpsProgress := ui.MainGui.AddProgress("x37 y184 w220 h20 c" cfg.ThemeFont1Color " vTimerProgress Smooth Range0-270 Background" cfg.ThemePanel1Color,0)	
;	ui.MainGui.SetFont("s14","Calibri")

	; ui.buttonDockAfk := ui.MainGui.AddPicture("x+-5 y2 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_dockLeft_ready.png")
	; ui.buttonDockAfk.OnEvent("Click",ToggleAfkDock)
	; ui.buttonDockAfk.ToolTip := "Dock AFK Panel"
	
	; ui.buttonStartAFK := ui.MainGui.AddPicture("xs-450 section w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_afk_ready.png")
	; ui.buttonStartAFK.OnEvent("Click",ToggleAFK)
	; ui.buttonStartAFK.ToolTip := "Toggle AFK"
	
	; ui.buttonTower := ui.MainGui.AddPicture("x+2 ys0 section w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_tower_ready.png")
	; ui.buttonTower.OnEvent("Click",ToggleTower)
	; ui.buttonTower.ToolTip := "Starts Infinte Tower"
	
	; ui.buttonAntiIdle := ui.MainGui.AddPicture("x+2 ys0 section w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
	; ui.buttonAntiIdle.OnEvent("Click",ToggleAntiIdle)
	; ui.buttonAntiIdle.ToolTip := "Toggles AntiIdle Mode On/Off"
	


	
	; ui.buttonAfkHide := ui.MainGui.AddPicture("x+0 ys0 w30 h30 hidden Background" cfg.ThemeButtonReadyColor,"./Img/button_hide.png")
	; ui.buttonAfkHide.OnEvent("Click",HideMainGui)
	; ui.buttonAfkHide.ToolTip := "Minimizes AFK Window to System Tray"
	
	; ui.buttonAfkUndock := ui.MainGui.AddPicture("x+0 ys0 w30 h30 hidden Background" cfg.ThemeButtonReadyColor,"./Img/button_dockright_ready.png")
	; ui.buttonAfkUndock.OnEvent("Click",ToggleAfkDock)
	; ui.buttonAfkUndock.ToolTip := "Undocks AFK Window"

	; ui.buttonPopout := ui.MainGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_popout_ready.png")
	; ui.buttonPopout.OnEvent("Click",AfkPopoutButtonPushed)
	
	; ui.Win1Label := ui.MainGui.AddPicture("xs+15 y+8 section w35 h29","./Img/arrow_left.png")
	; ui.MainGui.SetFont("s12","Calibri")






	;ui.Win1Hwnd := ui.MainGui.AddText("ys w60 hidden", "")

;	ui.Win2Label := ui.MainGui.AddPicture("xs2 y+7 section w35 h29","./Img/arrow_right.png")

	;ui.Win2Hwnd := ui.MainGui.AddText("ys w60 hidden","")
	ui.Win1ClassDDL.Choose(1)
	ui.Win2ClassDDL.Choose(2)

	RefreshWin1AfkRoutine()
	RefreshWin2AfkRoutine()	
	

;	ui.MainGui.SetFont("s16 bold")  ; Set a large font size (32-point).
	;ui.Title := ui.MainGui.AddText("","")
	



	} ;End GameWindow Gui Controls

	{ ;System Gui Controls
		ui.ButtonDebug := ui.MainGui.AddPicture("x+136 ys+34 w138 h32 section Background" cfg.ThemeButtonReadyColor,"./Img/button_viewlog_down.png")
		ui.ButtonDebug.OnEvent("Click",toggleConsole)	
	} ;End System Gui Controls
		
	{ ;Gui Outlines
		drawOutline(ui.mainGui,205,34,154,27,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Ops Clock Outline
		drawOutline(ui.mainGui,37,30,500,32,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar Outline
		drawOutline(ui.mainGui,37,60,498,154,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Ops GameWindowBox Outline	
		drawOutline(ui.mainGui,37,60,498,48,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Ops GameWindowBox Outline
		drawOutline(ui.mainGui,37,106,225,27,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)	;Status Bar
		drawOutline(ui.mainGui,308,107,225,24,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Status Bar



		;drawOutlineMainGui(7,65,355,61,cfg.ThemeBright2Color,cfg.ThemeBright2Color,2)	;Ops Window Status Icons Outline
		;drawOutlineMainGui(7,95,355,2,cfg.ThemeBright2Color,cfg.ThemeBright2Color,2)		;Ops Window Handle Divider Outline
		;drawOutlineMainGui(360,180,143,34,cfg.ThemeBright2Color,cfg.ThemeBright2Color,1)	;Ops Log Viewer Button Outline
	} ;End Gui Outlines

	{ ;Declarations
		ui.ClockMode := "Clock"
		ui.ClockTime := FormatTime(,"hh:mm:ss") " "
		ui.TimerTime := FormatTime(20000101240000,"hh:mm:ss")
		ui.TimerState := "Stopped"
		ui.StartTime := 0	
		ui.StopwatchTime := "00:00 "
		ui.StopwatchState := "Stopped"
		ui.GameDDL.Choose(1)
	} ;End Declarations
		

}

{ ;Functions

	toggleHwndSwap(*) {
		ui.buttonSwapHwnd.Value := ((cfg.HwndSwapEnabled := !cfg.HwndSwapEnabled) ? (ui.buttonSwapHwnd.Opt("Background" cfg.ThemeButtonOnColor), "./Img/button_swapHwnd_enabled.png") : (ui.buttonSwapHwnd.Opt("Background" cfg.ThemeBackgroundColor), "./Img/button_swapHwnd_disabled.png"))
		tmpGame2StatusEnabled := cfg.Game2StatusEnabled
		cfg.Game2StatusEnabled := cfg.Game1StatusEnabled
		cfg.Game1StatusEnabled := tmpGame2StatusEnabled
		RefreshWinHwnd()
	}

	setTimerTime(*) {
		MsgBox("This feature has not`nyet been implemented")
	}

	viewClock(*) {
		ui.ClockMode := "Clock"
		ui.OpsClockModeLabel.Text := "Clock"
		ui.OpsClock.Text := FormatTime(,"hh:mm:ss") " "
	}

	viewStopwatch(*) {
		ui.ClockMode := "Stopwatch"
		ui.OpsClockModeLabel.Text := "Stop`nWatch"
		ui.OpsClock.Text := ui.StopwatchTime " "
	}

	viewTimer(*) {
		ui.ClockMode := "Timer"
		ui.OpsClockModeLabel.Text := "Timer"
		ui.OpsClock.Text := "Timer N/A"
	}

	showClockMenu(*) {
		ClockMenu := Menu()
		ClockMenu.Add("View Current Time",ViewClock)
		ClockMenu.Add("View Stopwatch",ViewStopwatch)
		ClockMenu.Add("Start/Stop Stopwatch (Ctrl-Click)",StopwatchToggle)
		ClockMenu.Add()
		ClockMenu.Add("[Click] to Toggle Clock/Stopwatch",HelpScreen)
		ClockMenu.Add("[Ctrl-Click] to Start/Stop Timer",HelpScreen)
		ClockMenu.Disable("[Click] to Toggle Clock/Stopwatch")
		ClockMenu.Disable("[Ctrl-Click] to Start/Stop Timer")


		MouseGetPos(&MouseX,&MouseY)
		ClockMenu.Show(MouseX,MouseY)
	}

	helpScreen(*) {

	}

	changeClockMode(*) {
		if (GetKeyState("Ctrl"))
		{
			ViewStopwatch()
			StopwatchToggle()
		} else {
		
			Switch
			{
				case ui.ClockMode == "Clock":
				{
					ViewStopwatch()
				}
				case ui.ClockMode == "Stopwatch":
				{
					ViewTimer()
				}
				Default:
				{
					ViewClock()
				}
			}
		}
	}


	opsClickTimeUpdate(*) {
		ui.ClockTime := FormatTime("T12","Time")
		if (ui.ClockMode == "Clock")
			ui.OpsClock.Value := ui.ClockTime " "
	}

	stopwatchToggle(*) {
		Global
		Switch
		{
			case ui.StopwatchState == "Stopped":
			{
				ui.StopwatchState := "Running"
				StopwatchStart()
			}
			case ui.StopwatchState == "Running":
			{
				ui.StopwatchState := "Stopped"
				StopwatchStop()
			}
		}
	}

	stopwatchStart(*) {
		ui.StartTime := A_NowUTC
		SetTimer(StopwatchTimer,1000)
	}

	stopwatchStop(*) {
		SetTimer(StopwatchTimer,0)
	}

	stopwatchReset(*) {
		ui.OpsClock.Value := FormatTime(0,"hh:mm:ss") " "
	}

	stopwatchTimer(*) {
		Global
		SecondsElapsed := DateDiff(A_NowUTC,ui.StartTime,"Seconds")
		ui.StopwatchTime := Format("{:02}:{:02}", SecondsElapsed//60, Mod(SecondsElapsed,60))
		if (ui.ClockMode == "Stopwatch")
		{
			ui.OpsClock.Text := ui.StopwatchTime " "
		}
	}

	toggleGame1Status(*) {
		cfg.Game1StatusEnabled := !cfg.Game1StatusEnabled 
		RefreshWinHwnd()
	}	
				
	toggleGame2Status(*) {
		cfg.Game2StatusEnabled := !cfg.Game2StatusEnabled
		RefreshWinHwnd()
	}	
					
	changeGameDDL(*) {
		debugLog("Game Profile Changed to: " ui.GameDDL.Text)
		If !(WinExist("ahk_id " ui.Win1Hwnd) || WinExist("ahk_id " ui.Win2Hwnd.Text))
			RefreshWinHwnd()
	}

	refreshWinHwnd(*) { ;Performs Window Discovery, Game Identification and Gui Data Updates
		Thread("NoTimers")
		debugLog("Refreshing Game Window HWND IDs")
		
		ui.GameWindowsListBox.Delete()
		ui.AllGameWindowsList := WinGetList(ui.GameDDL.Text)
		ui.FilteredGameWindowsList := Array()
		
		Loop 2
		{
			ui.Game%A_Index%StatusIcon.Opt("Background" cfg.ThemeButtonReadyColor)
		}

		Loop ui.AllGameWindowsList.Length
		{
			if (WinGetProcessName("ahk_id " ui.AllGameWindowsList[A_Index]) != "Windows10Universal.exe") 
			&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[A_Index]) != "Chrome.exe") 
			&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[A_Index]) != "msedge.exe") 
			{
				ui.FilteredGameWindowsList.Push(ui.AllGameWindowsList[A_Index])
			}
		}	

		Loop ui.FilteredGameWindowsList.Length
		{	
		
			WinGetPos(&Win1X,&Win1Y,&Win1W,&Win1H,"ahk_id " ui.FilteredGameWindowsList[1])
			if (ui.FilteredGameWindowsList.Length > 1) {
				WinGetPos(&Win2X,&Win2Y,&Win2W,&Win2H,"ahk_id " ui.FilteredGameWindowsList[2])
			} else {
				Win2X := 999999
			}
			
			WinNumber := (Win1X > Win2X) ? ((A_Index == 1) ? 2 : 1) : (WinNumber := A_Index)
			WinNumber := (cfg.HwndSwapEnabled) ? ((WinNumber == 1) ? 2 : 1) : WinNumber
			
			ui.Win%WinNumber%Hwnd := ui.FilteredGameWindowsList[A_Index]
			ui.Win%WinNumber%HwndText.Text := "  " ui.FilteredGameWindowsList[A_Index] "  "
			ui.Win%WinNumber%Name.Text := "  " WinGetTitle("ahk_id " ui.FilteredGameWindowsList[A_Index]) "  "
			ui.Win%WinNumber%ProcessName.Text := "  " WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd) "  "
			ui.GameWindowsListBox.Add([((WinNumber == 1) ? "[Left]" : "[Right]") "[" ui.Win%WinNumber%Hwnd "][" WinGetTitle("ahk_id " ui.Win%WinNumber%Hwnd) "][" WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd) "]"])

			if (cfg.Game%WinNumber%StatusEnabled)
			{
				ui.Game%WinNumber%StatusIcon.Value := "./Img/toggle_on.png"
				ui.Game%WinNumber%StatusIcon.Opt("Background" cfg.ThemeButtonOnColor)
				ui.Win%WinNumber%ProcessName.Opt("-Disabled Background" cfg.ThemePanel2Color)
				ui.Win%WinNumber%HwndText.Opt("-Disabled Background" cfg.ThemePanel2Color)
				ui.Win%WinNumber%Name.Opt("-Disabled Background" cfg.ThemePanel2Color)
				ui.Win%WinNumber%ClassDDL.Opt("-Disabled")
				;ui.Game%WinNumber%StatusIcon.ToolTip := ((WinNumber == 1) ? "[Left]" : "[Right]") " [" WinGetTitle("ahk_id " ui.Win%WinNumber%Hwnd) "] [" ui.Win%WinNumber%Hwnd "] [" WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd) "]"


			} else {
				ui.Game%WinNumber%StatusIcon.Value := "./Img/toggle_off.png"
				ui.Game%WinNumber%StatusIcon.Opt("Background" cfg.ThemeButtonReadyColor)
				ui.Win%WinNumber%ProcessName.Opt("+Disabled Background" cfg.ThemePanel2AccentColor)
				ui.Win%WinNumber%HwndText.Opt("+Disabled Background" cfg.ThemePanel2AccentColor)
				ui.Win%WinNumber%Name.Opt("+Disabled Background" cfg.ThemePanel2AccentColor)
				ui.Win%WinNumber%ClassDDL.Opt("+Disabled")	
			}
			; ui.Game%WinNumber%StatusIcon.Redraw()
			; ui.Win%WinNumber%ProcessName.Redraw()
			; ui.Win%WinNumber%HwndText.Redraw()
		}
		ui.buttonSwapHwnd.Value := cfg.HwndSwapEnabled ? "./Img/button_swapHwnd_enabled.png" : "./Img/button_swapHwnd_disabled.png"
		;ui.buttonSwapHwnd.Redraw()
		drawOpsOutlines()
	}

	{ ;Functions for Game Profile List Management (Including Modal Pop-up Interaces)
		addGame(*) {
			Global
			ui.NewGameGui := Gui(,"Add Game Profile")
			ui.NewGameGui.BackColor := "505050"
			ui.NewGameGui.Color := "212121"
			ui.NewGameGui.Opt("-Caption -Border +AlwaysOnTop -DPIScale")
			ui.NewGameGui.SetFont("s16 cFF00FF", "Calibri Bold")
			
			ui.NewGameGui.AddText("x10 y10 section","Enter New Game Name")
			cfg.NewGameEdit := ui.NewGameGui.AddEdit("xs section w180","")
			cfg.NewGameOkButton := ui.NewGameGui.AddPicture("x+-7 ys w60 h34","./Img/button_add.png")
			cfg.NewGameOkButton.OnEvent("Click",AddGameProfile)
			ui.NewGameGui.Show("w260 h110 NoActivate")
			drawOutlineNewGameGui(5,5,250,100,cfg.ThemeBright2Color,cfg.ThemeBright1Color,2)

			addGameProfile(*) {
				Global
				cfg.GameList.Push(cfg.NewGameEdit.Value)
				currentGame := cfg.Game
				ui.GameDDL.Delete()
				ui.GameDDL.Add(cfg.GameList)
				ui.GameDDL.Choose(1)
				ui.NewGameGui.Destroy()
			}
		}

		removeGame(*) {
			Global
			cfg.GameList.RemoveAt(cfg.Game)
			ui.GameDDL.Delete()
			ui.GameDDL.Add(cfg.GameList)
			ui.GameDDL.Choose(1)
		}
	} ;End Game Profile List Modal Gui

drawOpsOutlines() {

	ui.MainGuiTabs.UseTab("Sys")
	drawOutline(ui.MainGui,306,76,155,15,cfg.ThemeFont2Color,cfg.ThemeFont2Color,1)
	drawOutline(ui.MainGui,306,62,155,45,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)
	drawOutline(ui.MainGui,106,76,155,15,cfg.ThemeFont2Color,cfg.ThemeFont2Color,1)
	drawOutline(ui.MainGui,106,62,155,45,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)
	drawOutline(ui.MainGui,37,62,496,45,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)

}

} ;End Functions
		

	