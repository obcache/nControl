#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	Return
}


{ ;Declarations
	ui.ClockMode 		:= "Clock"
	ui.ClockTime 		:= FormatTime(,"hh:mm:ss") " "
	ui.TimerTime 		:= FormatTime(20000101240000,"hh:mm:ss")
	ui.TimerState 		:= "Stopped"
	ui.StartTime 		:= 0	
	ui.StopwatchTime 	:= "00:00 "
	ui.StopwatchState 	:= "Stopped"
} ;End Declarations



GuiOperationsTab(&ui,&cfg,&afk) { ;libGuiOperationsTab
	Afk.DataRow 		:= Array()
	ui.ProfileList 		:= Array()
	ui.ProfileListStr 	:= ""
	Loop read, cfg.AfkDataFile
	{
		LineNumber := A_Index
		Afk.DataColumn := Array()
		Loop parse, A_LoopReadLine, "CSV"
		{
			if (A_Index == 1 && !(InStr(ui.ProfileListStr,A_LoopField)))
			{
				ui.ProfileListStr .= A_LoopField ","
				ui.ProfileList.Push(A_LoopField)
			}
		}
		
	}
	
	debugLog("Finished Reading AfkData File")
	
	ui.MainGuiTabs.UseTab("Sys")
	ui.MainGui.SetFont("s14","Calibri Thin")

	ui.OpsDockButton := ui.MainGui.AddPicture("x38 y35 w27 h27 section Background" cfg.ThemeButtonReadyColor,"./Img/button_dockLeft_ready.png")
	ui.OpsDockButton.OnEvent("Click",ToggleAfkDock)
	ui.OpsDockButton.ToolTip 		:= "Dock AFK Panel"
	

	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri Thin")
	ui.OpsClockModeLabel := ui.MainGui.AddText("x+2 ys+2 section w53 h23 Background" cfg.ThemePanel2Color," Clock")
	ui.OpsClockModeLabel.SetFont("s8 c" cfg.ThemeFont2Color,"Ariel Bold")
	
	ui.OpsClock := ui.MainGui.AddText("x+0 ys w120 Right h23 Background" cfg.ThemePanel2Color " c" cfg.ThemeFont2Color,)
	ui.OpsClock.SetFont("s16","Orbitron")
	ui.OpsClock.OnEvent("Click",ChangeClockMode)
	ui.OpsClock.OnEvent("ContextMenu",ShowClockMenu)
	ui.OpsClock.ToolTip := "Left Click Starts/Stops Timer. `nRight Click Resets Timer. `nDouble-Click to Return to Time Mode."
	SetTimer(opsClickTimeUpdate,1000)
	
	ui.ButtonDebug := ui.MainGui.AddPicture( 
	(cfg.consoleVisible) ? "x+2 ys-2 w27 h27 section Background" cfg.ThemeButtonOnColor : "x+2 ys-2 w27 h27 section Background" cfg.ThemeButtonReadyColor,
	(cfg.consoleVisible) ? "./Img/button_console_ready.png" : "./Img/button_console_ready.png")
	ui.ButtonDebug.OnEvent("Click",toggleConsole)		


	ui.RefreshWindowHandlesButton := ui.MainGui.AddPicture("x+1 ys section w27 h27 Background" cfg.ThemeFont1Color, "./Img/button_refresh.png")	
	ui.RefreshWindowHandlesButton.OnEvent("Click",RefreshWinHwnd)
	ui.RefreshWindowHandlesButton.ToolTip := "Rescan for windows matching the selected game profile."

	ui.ButtonHelp := ui.MainGui.AddPicture("ys w27 h27 section Background" cfg.ThemeButtonReadyColor,"./Img/button_help_ready.png")
	ui.ButtonHelp.OnEvent("Click",ToggleHelp)


	ui.GameDDL := ui.MainGui.AddDropDownList("x+2 ys w150 Background" cfg.ThemeEditboxColor " -E0x200 Choose" cfg.game,cfg.GameList)
	ui.GameDDL.ToolTip := "Select the Game You Are Playing"
	ui.GameDDL.OnEvent("Change",ChangeGameDDL)

	ui.GameAddButton := ui.MainGui.AddPicture("ys x+2 w27 h27 section Background" cfg.ThemeButtonReadyColor,"./Img/button_plus_ready.png")
	ui.GameAddButton.OnEvent("Click",AddGame)
	ui.GameAddButton.ToolTip := "Add New Game to List"
	ui.GameRemoveButton	:= ui.MainGui.AddPicture("ys w27 h27 Background" cfg.ThemeButtonReadyColor,"./Img/button_minus_ready.png")
	ui.GameRemoveButton.OnEvent("Click",RemoveGame)
	ui.GameRemoveButton.ToolTip := "Remove Selected Game from List"


	ui.MainGuiTabs.Focus()

	ui.MainGui.SetFont("s10 c" cfg.ThemeFont1Color,"Calibri")	
	ui.GameWindowsListBox := ui.MainGui.AddListBox("x38 y+1 w0 r10 section hidden Background" cfg.ThemePanel1Color " -E0x200 multi",ui.gameWindowsList)
	ui.GameWindowsListBox.ToolTip := "List of available game windows in session"


	{ ;GameWindows Gui Controls
		ui.MainGui.SetFont("s11 c" cfg.ThemeFont1Color,"Calibri")
		ui.Win1Label := ui.MainGui.AddText("xs-2 y62 section w68 Border h20 c" cfg.ThemeFont1Color " Center Background" cfg.ThemePanel1Color,"Game1")

		ui.Win1EnabledToggle := ui.MainGui.AddPicture("xs-1 y+0 section w67 h25 Background" cfg.ThemeButtonReadyColor, cfg.toggleOff)
		ui.Win1EnabledToggle.OnEvent("Click",ToggleGame1Status)
		ui.Win1EnabledToggle.ToolTip := "Toggle to have this window ignored by nControl"

		ui.MainGui.SetFont("s8 c" cfg.ThemeFont4Color,"Calibri")

		ui.Win1Name := ui.MainGui.AddText("ys-18 x+3 section w154 Right Background" cfg.ThemePanel4Color,"Game  ")
		ui.Win1ProcessName := ui.MainGui.AddText("xs y+1 section w154 Right Background" cfg.ThemePanel4Color,"Not  ")
		ui.Win1HwndText := ui.MainGui.AddText("xs y+1 section w154 Right Background" cfg.ThemePanel4Color,"Found  ")
		ui.Win1HwndText.ToolTip := "Window ID for Game Window 1"
		
		ui.buttonSwapHwnd := ui.MainGui.AddPicture("ys-29 x+1 section w45 h45 Background" (cfg.HwndSwapEnabled ? cfg.ThemeButtonOnColor : cfg.ThemeButtonReadyColor), (cfg.HwndSwapEnabled ? "./Img/button_swapHwnd_enabled.png" : "./Img/button_swapHwnd_disabled.png"))
		ui.buttonSwapHwnd.OnEvent("Click",ToggleHwndSwap)
		ui.buttonSwapHwnd.ToolTip := "Swap Windows"

		;ui.MainGui.SetFont("s13 c" cfg.ThemeFont1Color,"Calibri")
		ui.MainGui.SetFont("s8 c" cfg.ThemeFont4Color,"Calibri")
		ui.Win2Name := ui.MainGui.AddText("x+2 ys+1 section w154 Background" cfg.ThemePanel4Color,"  Game  ")
		ui.Win2ProcessName := ui.MainGui.AddText("xs y+1 section w154 Background" cfg.ThemePanel4Color,"  Not  ")
		ui.Win2HwndText := ui.MainGui.AddText("xs y+1 w154 section Background" cfg.ThemePanel4Color,"  Found  ")
		ui.Win2HwndText.ToolTip := "Window ID for Game Window 1"

		ui.MainGui.SetFont("s11 c" cfg.ThemeFont1Color,"Calibri")
		ui.Win2Label := ui.MainGui.AddText("ys-30 section w70 h20 c" cfg.ThemeFont1Color " Center Background" cfg.ThemePanel1Color,"Game2")

		ui.Win2EnabledToggle := ui.MainGui.AddPicture("xs section w70 h25 Background" cfg.ThemeButtonReadyColor, cfg.toggleOff)
		ui.Win2EnabledToggle.OnEvent("Click",ToggleGame2Status)
		ui.Win2EnabledToggle.ToolTip := "Toggle to have this window ignored by nControl"

		ui.Win1AfkStatus := ui.MainGui.AddText("xs-427 section w45 h25 Background" cfg.ThemePanel1Color,"")
		ui.Win1AfkIcon := ui.MainGui.AddPicture("ys section w25 h25 Background" cfg.ThemePanel1Color,"./Img/sleep_icon.png")

		ui.Win1ClassDDL := ui.MainGui.AddDDL("ys-1 x+0 w156 r4 AltSubmit choose3 Background" cfg.ThemeEditBoxColor, ui.ProfileList)
		ui.Win1ClassDDL.SetFont("s11")
		ui.Win1ClassDDL.OnEvent("Change",RefreshWin1AfkRoutine)
		PostMessage("0x153", -1, 21,, "AHK_ID " ui.Win1ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
	
		ui.OpsAfkButton := ui.MainGui.AddPicture("ys x+-1 w45 h45 section Background" cfg.ThemeButtonReadyColor,"./Img/button_afk_ready.png")
		ui.OpsAfkButton.OnEvent("Click",ToggleAFK)
		ui.OpsAfkButton.ToolTip := "Toggle AFK"
	
		ui.Win2ClassDDL := ui.MainGui.AddDDL("x+1 ys-1 w156 r4 section AltSubmit choose3 Background" cfg.ThemeEditBoxColor, ui.ProfileList)
		ui.Win2ClassDDL.SetFont("s11")
		ui.Win2ClassDDL.OnEvent("Change",RefreshWin2AfkRoutine)
		PostMessage("0x153", -1, 21,, "AHK_ID " ui.Win2ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
		
		ui.Win2AfkIcon := ui.MainGui.AddPicture("ys+1 w25 h25 section Background" cfg.ThemePanel1Color,"./Img/sleep_icon.png")
		ui.Win2AfkStatus := ui.MainGui.AddText("x+0 ys section w50 h25 +Background" cfg.ThemePanel1Color,"")

		ui.autoFireWin1Button := ui.MainGui.AddPicture("x37 y132 section w30 h30 Disabled Background" cfg.ThemeButtonReadyColor,"./Img/button_autoFire1_ready.png")
		ui.autoFireWin1Button.Tooltip := "Window1 AutoFire"
		ui.autoFireWin1Button.OnEvent("Click",autoFireWin1)

		ui.OpsAntiIdle1Button := ui.MainGui.AddPicture("ys x+1 w33 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
		ui.OpsAntiIdle1Button.OnEvent("Click",ToggleAntiIdle1)
		ui.OpsAntiIdle1Button.ToolTip := "Toggle Anti-Idle"
		
		ui.OpsProgress1 := ui.MainGui.AddProgress("ys section w160 h30 c" cfg.ThemeFont1Color " Smooth Range0-270 Background" cfg.ThemePanel1Color,0)	
	
		ui.OpsTowerButton := ui.MainGui.AddPicture("x+-2 ys+19 w45 h46 section Background" cfg.ThemeButtonReadyColor,"./Img/button_tower_ready.png")
		ui.OpsTowerButton.OnEvent("Click",ToggleTower)
		ui.OpsTowerButton.ToolTip := "Toggle Tower Timer + AFK"
	
		ui.OpsProgress2 := ui.MainGui.AddProgress("ys-20 section w172 h30 c" cfg.ThemeFont1Color " Smooth Range0-270 Background" cfg.ThemePanel1Color,0)	

		ui.OpsAntiIdle2Button := ui.MainGui.AddPicture("x+0 ys+2 w28 h28 section Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
		ui.OpsAntiIdle2Button.OnEvent("Click",ToggleAntiIdle2)
		ui.OpsAntiIdle2Button.ToolTip := "Toggle Anti-Idle"
		
		ui.autoFireWin2Button := ui.MainGui.AddPicture("ys+0 x+0 section w28 h28 Disabled Background" cfg.ThemeButtonReadyColor,"./Img/button_autoFire2_ready.png")
		ui.autoFireWin2Button.Tooltip := "Window2 AutoFire"
		ui.autoFireWin2Button.OnEvent("Click",autoFireWin2)
		

		ui.OpsStatusLeftTrim := ui.mainGui.AddPicture("x146 y160 w15 h40 section","./Img/label_left_trim.png")
		ui.OpsStatus1 := ui.MainGui.AddPicture("ys w100 h40 section Background" cfg.ThemeButtonReadyColor,"./Img/label_timer_off.png")  ; XX & YY serve to auto-size the window.
		ui.OpsStatus2 := ui.MainGui.AddPicture("x+47 ys w100 h40 section Background" cfg.ThemeButtonReadyColor,"./Img/label_timer_off.png")  ; XX & YY serve to auto-size the window.
		ui.OpsStatusRightTrim := ui.mainGui.AddPicture("ys w15 h40","./Img/label_right_trim.png")
		
		drawGridLines()
		drawOpsOutlines()
		ui.Win1ClassDDL.Choose(1)
		ui.Win2ClassDDL.Choose(2)

		; RefreshWin1AfkRoutine()
		; RefreshWin2AfkRoutine()	
	} ;End GameWindow Gui Controls
}

{ ;Functions
drawGridLines() {
ui.MainGuiTabs.UseTab("Sys")
	drawOutline(ui.MainGui,103,77,158,15,cfg.ThemeFont4Color,cfg.ThemeFont4Color,1)				;Win1 Info Gridlines  
	drawOutline(ui.MainGui,305,77,157,15,cfg.ThemeFont4Color,cfg.ThemeFont4Color,1)				;Win2 Info Gridlines
	drawOutline(ui.MainGui,305,62,157,71,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)	;WIn2 Info Frame
	drawOutline(ui.MainGui,103,62,158,71,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2) ;Win1 Info Frame
	
	; drawOutline(ui.mainGui,259,106,47,47,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar Outline
	; drawOutline(ui.mainGui,258,62,49,138,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)		;Ops Toolbar Outline
	; drawOutline(ui.mainGui,259,62,47,136,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar Outline}
}

drawOpsOutlines() {
	ui.MainGuiTabs.UseTab("Sys")
	drawOutlineNamed("opsClock",ui.mainGui,65,32,176,30,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)		;Ops Clock
	drawOutlineNamed("opsToolbarOutline",ui.MainGui,103,62,500,45,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Toolbar Outlineine
	drawOutlineNamed("opsToolbarOutline2",ui.mainGui,35,32,500,32,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar Outline

	drawOutlineNamed("opsStatusBarRightDark",ui.mainGui,304,132,232,30,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)	;Status Bar
	drawOutlineNamed("opsStatusBarRightLight",ui.mainGui,305,131,230,32,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)	;Status Bar
	drawOutlineNamed("opsStatusBarLeftDark",ui.mainGui,35,131,225,32,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)	;Status Bar
	drawOutlineNamed("opsStatusBarLeftLight",ui.mainGui,36,131,224,32,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)	;Status Bar

	drawOutlineNamed("opsMiddleColumnMiddleRow",ui.mainGui,259,105,48,47,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar Outline
	drawOutlineNamed("opsMiddleColumnOutlineDark",ui.mainGui,258,62,50,138,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)		;Ops Toolbar Outline
	drawOutlineNamed("opsMiddleColumnOutlineLight",ui.mainGui,259,62,48,138,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar Outline
	; ui.MainGuiTabs.UseTab("")
	; drawOutlineNamed("mainGuiOutline",ui.MainGui,33,30,502,212,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)
	;drawOutline(ui.mainGui,106,106,157,25,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)			;Status Bar
	;drawOutline(ui.mainGui,37,106,224,27,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,1)			;Status Bar	
	;drawOutline(ui.mainGui,37,60,498,152,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Ops GameWindowBox Outline	
	;drawOutline(ui.mainGui,37,60,498,48,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Ops GameWindowBox Outline
	;drawOutline(ui.mainGui,35,133,224,36,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)	;Status Bar
	;drawOutline(ui.mainGui,308,133,230,36,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)	;Status Barock Outl
	;drawOutline(ui.mainGui,310,106,249,26,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)		;Status Bar
}


refreshWin1AfkRoutine(*) {
	try
	{
		ui.Win1AfkRoutine.Text := ""
		
		Afk.DataRow := Array()
		ui.ProfileList := Array()
		ui.ProfileListStr := ""
		Loop read, cfg.AfkDataFile
		{
			LineNumber := A_Index
			Afk.DataColumn := Array()
			Loop parse, A_LoopReadLine, "CSV"
			{
				if (A_Index == 1 && (ui.Win1ClassDDL.Text == A_LoopField))
				{
					ui.Win1AfkRoutine.Text .= "  " A_LoopReadLine "`n"
				}
			}
			
		}
	}
}

refreshWin2AfkRoutine(*) {
	try
	{
		ui.Win2AfkRoutine.Text := ""
		
		Afk.DataRow := Array()
		ui.ProfileList := Array()
		ui.ProfileListStr := ""
		Loop read, cfg.AfkDataFile
		{
			LineNumber := A_Index
			Afk.DataColumn := Array()
			Loop parse, A_LoopReadLine, "CSV"
			{
				if (A_Index == 1 && (ui.Win2ClassDDL.Text == A_LoopField))
				{
					ui.Win2AfkRoutine.Text .= "  " A_LoopReadLine "`n"
				}
			}
			
		}
	}
}


	ToggleHelp(*) {
		(ui.helpActive := !ui.helpActive) ? ShowHelp() : CloseHelp()
	}

	ShowHelp() {
		ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
		ui.DisableGui := Gui()
		ui.DisableGui.Opt("-Caption AlwaysOnTop Owner" ui.MainGui.Hwnd)
		ui.DisableGui.Color := "303030"
		ui.DisableGui.BackColor := "303030"
		ui.CloseHelp := ui.DisableGui.AddPicture("x40 y173 w40 h40 Background" cfg.ThemeButtonReadyColor,"./Img/button_help_ready.png")
		ui.CloseHelp.OnEvent("Click",ToggleHelp)		

		ui.HelpGui := Gui()
		ui.HelpGui.BackColor := "353535"
		ui.HelpGui.Title := "Help for nControl " A_FileVersion
		ui.HelpGui.Color := "353535"
		ui.HelpPng := ui.HelpGui.AddPicture("x0 y0","./Img/Help.png")
		ui.HelpPng.OnEvent("Click",ToggleHelp)
		ui.HelpGui.Opt("-Caption AlwaysOnTop +Owner" ui.MainGui.Hwnd)
		ui.MainGui.Opt("Disabled")
		WinSetTransparent(200,ui.DisableGui)		

		ui.DisableGui.Show("x" GuiX " y" GuiY-3 " w" GuiW " h" GuiH+3)
		ui.HelpGui.Show("w1000 h454")
	}

	CloseHelp(*) {
		ui.DisableGui.Destroy()
		ui.HelpGui.Destroy()
		ui.MainGui.Opt("-Disabled")
	}


	autoFireWin1(*) {
		autoFire(1)
	}
	
	autoFireWin2(*) {
		autoFire(2)
	}
	
	toggleHwndSwap(*) {
		ui.buttonSwapHwnd.Value := ((cfg.HwndSwapEnabled := !cfg.HwndSwapEnabled) ? (ui.buttonSwapHwnd.Opt("Background" cfg.ThemeButtonOnColor), "./Img/button_swapHwnd_enabled.png") : (ui.buttonSwapHwnd.Opt("Background" cfg.ThemeBackgroundColor), "./Img/button_swapHwnd_disabled.png"))
		tmpGame2StatusEnabled := cfg.win2Enabled
		cfg.win2Enabled := cfg.win1Enabled
		cfg.win1Enabled := tmpGame2StatusEnabled
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
		ui.Win1EnabledToggle.Value := 												;Property in which ternary output will be stored
			(cfg.win1Enabled := !cfg.win1Enabled) 									;Toggles the bit for the Win1Enabled variable
			? (																		;IF (after being toggled) it is true
				ui.Win1EnabledToggle.Opt("Background" cfg.ThemeButtonOnColor)		;Set BG color of the control to theme's Button-On
				,cfg.toggleOn														;Returns png path for toggle's On state			
			) : (																	;ELSE
				ui.Win1EnabledToggle.Opt("Background" cfg.ThemeButtonReadyColor)	;Set BG color of the control to theme's Button-Off
				,cfg.toggleOff 														;Returns png path for toggle's Off state
			)																		
		RefreshWinHwnd()
	}	
				
	toggleGame2Status(*) {
		ui.Win2EnabledToggle.Value := 												;Property in which ternary output will be stored
			(cfg.win2Enabled := !cfg.win2Enabled) 									;Toggles the bit for the Win1Enabled variable
			? (																		;IF (after being toggled) it is true
				ui.Win2EnabledToggle.Opt("Background" cfg.ThemeButtonOnColor)		;Set BG color of the control to theme's Button-On
				,cfg.toggleOn														;Returns png path for toggle's On state			
			) : (																	;ELSE
				ui.Win2EnabledToggle.Opt("Background" cfg.ThemeButtonReadyColor)	;Set BG color of the control to theme's Button-Off
				,cfg.toggleOff 														;Returns png path for toggle's Off state
			)																		
		RefreshWinHwnd()
	}			

	toggleWinEnabled(toggleControl,instance,*) {
		toggleControl.Value := 												;Property in which ternary output will be stored
			(cfg.win1Enabled := !cfg.win1Enabled) 									;Toggles the bit for the Win1Enabled variable
			? (																		;IF (after being toggled) it is true
				toggleControl.Opt("Background" cfg.ThemeButtonOnColor)		;Set BG color of the control to theme's Button-On
				,cfg.toggleOn														;Returns png path for toggle's On state			
			) : (																	;ELSE
				toggleControl.Opt("Background" cfg.ThemeButtonReadyColor)	;Set BG color of the control to theme's Button-Off
				,cfg.toggleOff 														;Returns png path for toggle's Off state
			)																		
	}	
	
	changeGameDDL(*) {
		debugLog("Game Profile Changed to: " ui.GameDDL.Text)
		;If !(WinExist("ahk_id " ui.Win1Hwnd) || WinExist("ahk_id " ui.Win2Hwnd))
			RefreshWinHwnd()
	}

	refreshWin(WinNumber) {
		Thread("NoTimers")
		debugLog("Refreshing Game Window HWND IDs")
		
		if !(tmpHwnd := WinExist("ahk_exe " ui.Win%WinNumber%ProcessName))
		{
			RefreshWinHwnd()
		} else {
			ui.Win%WinNumber%Hwnd := tmpHwnd
			ui.Win%WinNumber%HwndText.Text := "  " tmpHwnd "  "
			ui.Win%WinNumber%Name.Text := "  " WinGetTitle("ahk_id " tmpHwnd) "  "
			ui.Win%WinNumber%ProcessName.Text := "  " WinGetProcessName("ahk_id " tmpHwnd) "  "
	
			if (cfg.Win%WinNumber%Enabled)
			{
				ui.Win%WinNumber%ProcessName.Opt("-Disabled Background" cfg.ThemePanel2Color)
				ui.Win%WinNumber%HwndText.Opt("-Disabled Background" cfg.ThemePanel2Color)
				ui.Win%WinNumber%Name.Opt("-Disabled Background" cfg.ThemePanel2Color)
				ui.Win%WinNumber%ClassDDL.Opt("-Disabled")
				ui.autoFireWin%WinNumber%Button.Opt("-Disabled Background" cfg.ThemeButtonReadyColor)
				ui.autoFireWin%WinNumber%Button.Value := "./Img/button_autoFire" A_WinNumber "_ready.png"
				;ui.Win%WinNumber%EnabledToggle.ToolTip := ((WinNumber == 1) ? "[Left]" : "[Right]") " [" WinGetTitle("ahk_id " ui.Win%WinNumber%Hwnd) "] [" ui.Win%WinNumber%Hwnd "] [" WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd) "]"

			} else {
				ui.Win%WinNumber%ProcessName.Opt("+Disabled Background" cfg.ThemePanel4Color)
				ui.Win%WinNumber%HwndText.Opt("+Disabled Background" cfg.ThemePanel4Color)
				ui.Win%WinNumber%Name.Opt("+Disabled Background" cfg.ThemePanel4Color)
				ui.Win%WinNumber%ClassDDL.Opt("+Disabled")	
				ui.autoFireWin%WinNumber%Button.Opt("Disabled Background" cfg.ThemeButtonDisabledColor)
				ui.autoFireWin%WinNumber%Button.Value := "./Img/button_autoFire" A_WinNumber "_disabled.png"
			}
		}
		drawGridLines()
	}
		
	refreshWinHwnd(*) { ;Performs Window Discovery, Game Identification and Gui Data Updates
		; Thread("NoTimers")
		debugLog("Refreshing Game Window HWND IDs")
		
		ui.GameWindowsListBox.Delete()
		ui.AllGameWindowsList := WinGetList(ui.GameDDL.Text)
		ui.FilteredGameWindowsList := Array()
		
		Loop 2
		{
			;ui.Win%A_Index%Hwnd := ""
			ui.Win%A_Index%Name.Text := "  Game  "
			ui.Win%A_Index%Name.SetFont("c" cfg.ThemeFont4Color)
			ui.Win%A_Index%Name.Opt("Background" cfg.ThemePanel4Color)
			ui.Win%A_Index%ProcessName.Text := "  Not  "
			ui.Win%A_Index%ProcessName.SetFont("c" cfg.ThemeFont4Color)
			ui.Win%A_Index%ProcessName.Opt("Background" cfg.ThemePanel4Color)
			ui.Win%A_Index%HwndText.Text := "  Found  "
			ui.Win%A_Index%HwndText.SetFont("c" cfg.ThemeFont4Color)
			ui.Win%A_Index%HwndText.Opt("Background" cfg.ThemePanel4Color)
			ui.autoFireWin%A_Index%Button.Opt("Background" cfg.ThemePanel4Color)
			ui.autoFireWin%A_Index%Button.Value := "./Img/button_autoFire" A_Index "_on.png"
		}

		Loop ui.AllGameWindowsList.Length
		{
			;MsgBox(ui.AllGameWindowsList[A_Index])
			if (WinGetProcessName("ahk_id " ui.AllGameWindowsList[A_Index]) != "Windows10Universal.exe") 
			&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[A_Index]) != "explorer.exe") 
			&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[A_Index]) != "RobloxPlayerLauncher.exe")
			&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[A_Index]) != "RobloxPlayerInstaller.exe") 
			&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[A_Index]) != "Chrome.exe") 
			&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[A_Index]) != "msedge.exe") 
			{
				ui.FilteredGameWindowsList.Push(ui.AllGameWindowsList[A_Index])
			}
		}
		
		Win2X := 999999
		
		Loop ui.FilteredGameWindowsList.Length
		{	
			Switch A_Index
			{
				case 1:
				{
					WinGetPos(&Win1X,&Win1Y,&Win1W,&Win1H,"ahk_id " ui.FilteredGameWindowsList[1])	
				}
				case 2:
				{
					WinGetPos(&Win2X,&Win2Y,&Win2W,&Win2H,"ahk_id " ui.FilteredGameWindowsList[2])
				}
			}
			
			WinNumber := 
				(Win1X >  Win2X) 
				? ((A_Index == 1) 
					? 2 
					: 1) 
				: A_Index
			WinNumber := 
				(cfg.HwndSwapEnabled) 
				? ((WinNumber == 1) 
					? 2 
					: 1) 
				: WinNumber
			
			ui.Win%WinNumber%Hwnd := ui.FilteredGameWindowsList[A_Index]
			ui.Win%WinNumber%HwndText.Text := "  " ui.Win%WinNumber%Hwnd "  "
			ui.Win%WinNumber%Name.Text := "  " WinGetTitle("ahk_id " ui.FilteredGameWindowsList[A_Index]) "  "
			ui.Win%WinNumber%ProcessName.Text := "  " WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd) "  "
	
			if (cfg.Win%WinNumber%Enabled)
			{

				ui.Win%WinNumber%ProcessName.SetFont("c" cfg.ThemeFont2Color)
				ui.Win%WinNumber%Name.SetFont("c" cfg.ThemeFont2Color)
				ui.Win%WinNumber%HwndText.SetFont("c" cfg.ThemeFont2Color)
				ui.Win%WinNumber%ClassDDL.SetFont("c" cfg.ThemeFont2Color)

				ui.Win%WinNumber%ProcessName.Opt("Background" cfg.ThemePanel2Color)
				ui.Win%WinNumber%HwndText.Opt("Background" cfg.ThemePanel2Color)
				ui.Win%WinNumber%Name.Opt("Background" cfg.ThemePanel2Color)
				ui.Win%WinNumber%ClassDDL.Opt("-Disabled")
				ui.autoFireWin%WinNumber%Button.Opt("-Disabled Background" cfg.ThemeButtonReadyColor)
				ui.autoFireWin%WinNumber%Button.Value := "./Img/button_autoFire" WinNumber "_ready.png"
				;ui.Win%WinNumber%EnabledToggle.ToolTip := ((WinNumber == 1) ? "[Left]" : "[Right]") " [" WinGetTitle("ahk_id " ui.Win%WinNumber%Hwnd) "] [" ui.Win%WinNumber%Hwnd "] [" WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd) "]"
			} else {
				ui.Win%WinNumber%ProcessName.SetFont("c" cfg.ThemeFont4Color)
				ui.Win%WinNumber%Name.SetFont("c" cfg.ThemeFont4Color)
				ui.Win%WinNumber%HwndText.SetFont("c" cfg.ThemeFont4Color)
				ui.Win%WinNumber%ClassDDL.SetFont("c" cfg.ThemeFont4Color)

				ui.Win%WinNumber%ProcessName.Opt("Background" cfg.ThemePanel4Color)
				ui.Win%WinNumber%HwndText.Opt("Background" cfg.ThemePanel4Color)
				ui.Win%WinNumber%Name.Opt("Background" cfg.ThemePanel4Color)
				ui.Win%WinNumber%ClassDDL.Opt("+Disabled")	
				ui.autoFireWin%WinNumber%Button.Opt("Disabled Background" cfg.ThemePanel4Color)
				ui.autoFireWin%WinNumber%Button.Value := "./Img/button_autoFire" WinNumber "_disabled.png"
			}
			; ui.Win%WinNumber%EnabledToggle.Redraw()
			; ui.Win%WinNumber%ProcessName.Redraw()
			; ui.Win%WinNumber%HwndText.Redraw()
		}
		ui.buttonSwapHwnd.Value := cfg.HwndSwapEnabled ? "./Img/button_swapHwnd_enabled.png" : "./Img/button_swapHwnd_disabled.png"
		ui.buttonSwapHwnd.Redraw()

		; Loop 2 {
			 ; Try
				 ; ui.Win%A_Index%EnabledToggle.Value := 
					; (cfg.Win%A_Index%Enabled && ui.Win%A_Index%Hwnd) 
					; ? (ui.Win%A_Index%EnabledToggle.Opt("Background" cfg.ThemeButtonOnColor)
						; , cfg.toggleOn) 
					; : cfg.toggleOff
		
		; }
		
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
			drawOutlineNewGameGui(5,5,250,100,cfg.ThemeBright2Color,cfg.ThemeBright1Color,2)	;New App Profile Modal Outline

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


} ;End Functions
		

	
	
