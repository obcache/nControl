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


populateClassList() {
	ui.ProfileList 			:= Array()
	ui.ProfileListStr 		:= ""

	Loop read, cfg.AfkDataFile
	{
		if (strSplit(a_loopReadLine,",").length < 5) {
			notifyOSD("Your AfkData file is outdated or corrupted.`nPlease try your last upgrade again,`nand choose NOT to keep your files when prompted.`n`nOr verify that your AfkData file has 5 columns.`n(The 5th columnn is the name of the game)",5000)
			Return
		}

	lineRoutineName := strSplit(a_loopReadLine,",")[1]
	lineGameName := strSplit(a_loopReadLine,",")[5]

	if !(inStr(ui.profileListStr,lineRoutineName)) && lineGameName == ui.gameDDL.text
		{
			debugLog("Profile: " lineRoutineName "  Game: " lineGameName)
			ui.ProfileListStr .= lineRoutineName ","
			ui.ProfileList.Push(lineRoutineName)
		}
		
	}
	ui.win1classDDL.Delete
	ui.win1classDDL.add(ui.profileList)
	ui.afkwin1classDDL.Delete
	ui.afkwin1classDDL.add(ui.profileList)
	try {
		ui.win1classDDL.choose(1)
		ui.afkwin1classDDL.choose(1)
	}
	try {
		ui.win1classDDL.choose(cfg.win1class)
		ui.afkwin1classDDL.choose(cfg.win1class)
	}
	ui.win2classDDL.Delete
	ui.win2classDDL.add(ui.profileList)
	ui.afkwin2classDDL.Delete
	ui.afkwin2classDDL.add(ui.profileList)
	try {
		ui.win2classDDL.choose(1)
		ui.afkwin2classDDL.choose(1)
	}
	try {
		ui.win2classDDL.choose(cfg.win2class)
		ui.afkwin2classDDL.choose(cfg.win2class)
	}
}

GuiOperationsTab(&ui,&cfg,&afk) { ;libGuiOperationsTab
	global

	ui.MainGuiTabs.UseTab("Sys")
	ui.win1GridLines := ui.mainGui.addText("x105 y62 w150 h40 background" cfg.themeDark1color,"")
	ui.win2GridLines := ui.mainGui.addText("x285 y62 w200 h40 background" cfg.themeDark1color,"")
	ui.MainGui.SetFont("s14","Calibri Thin")

	ui.OpsDockButton := ui.MainGui.AddPicture("x38 y34 w32 h27 section Background" cfg.ThemeButtonReadyColor,"./Img/button_dockLeft_ready.png")
	ui.OpsDockButton.OnEvent("Click",toggleAfkDock)
	ui.OpsDockButton.ToolTip 		:= "Dock AFK Panel"
	
	ui.topDockButton := ui.mainGui.addPicture("x+0 ys w32 h27 section background" cfg.themeButtonReadyColor,"./img/button_dockUp_ready.png")
	ui.topDockButton.onEvent("click",topDockOn)
	ui.topDockButton.toolTip := "Dock to top of screen" 
	

	ui.MainGui.SetFont("s11 c" cfg.ThemeFont3Color,"Calibri Thin")
	ui.OpsClockModeLabel := ui.MainGui.AddText("x+3 ys+1 section w31 h24 Background" cfg.ThemePanel3Color," Clock")
	ui.OpsClockModeLabel.SetFont("s7 c" cfg.ThemeFont3Color,"Cascadia Code")
	
	ui.OpsClock := ui.MainGui.AddText("x+0 ys w105 Left h24 Background" cfg.ThemePanel3Color " c" cfg.ThemeFont3Color,)
	ui.OpsClock.SetFont("s16","Orbitron")
	ui.OpsClock.OnEvent("Click",ChangeClockMode)
	ui.OpsClock.OnEvent("ContextMenu",ShowClockMenu)
	ui.OpsClock.ToolTip := "Left Click Starts/Stops Timer. `nRight Click Resets Timer. `nDouble-Click to Return to Time Mode."
	SetTimer(opsClickTimeUpdate,1000)
	
	ui.ButtonDebug := ui.MainGui.AddPicture( 
	(cfg.consoleVisible) 
		? "x+1 ys-1 w27 h27 section Background" cfg.ThemeButtonOnColor 
		: "x+1 ys-1 w27 h27 section Background" cfg.ThemeButtonReadyColor,
	(cfg.consoleVisible) 
		? "./Img/button_console_ready.png" 
		: "./Img/button_console_ready.png")
	
	ui.ButtonDebug.OnEvent("Click",toggleConsole)		

	ui.RefreshWindowHandlesButton := ui.MainGui.AddPicture("x+1 ys section w27 h27 Background" cfg.ThemeButtonReadyColor, "./Img/button_refresh.png")	
	ui.RefreshWindowHandlesButton.OnEvent("Click",refreshWinHwnd)
	ui.RefreshWindowHandlesButton.ToolTip := "Rescan for windows matching the selected game profile."

	ui.ButtonHelp := ui.MainGui.AddPicture("x+1 ys w27 h27 section Background" cfg.ThemeButtonReadyColor,"./Img/button_help_ready.png")
	ui.ButtonHelp.OnEvent("Click",ToggleHelp)


	ui.GameDDL := ui.MainGui.AddDropDownList("x+1 ys+1 w135 Background" cfg.ThemeEditboxColor " -E0x200 Choose" cfg.game,cfg.GameList)
	ui.GameDDL.ToolTip := "Select the Game You Are Playing"
	ui.GameDDL.OnEvent("Change",ChangeGameDDL)
	ui.gameDDL.SetFont("s11.8 c" cfg.ThemeFont1Color)
	postMessage("0x153", -1, 21,, "AHK_ID " ui.gameDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
	postMessage("0x153", 0, 20,, "AHK_ID " ui.gameDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
	ui.GameAddButton := ui.MainGui.AddPicture("ys+0 x+3 w32 h27 section Background" cfg.ThemeButtonReadyColor,"./Img/button_plus_ready.png")
	ui.GameAddButton.OnEvent("Click",AddGame)
	ui.GameAddButton.ToolTip := "Add New Game to List"
	ui.GameRemoveButton	:= ui.MainGui.AddPicture("ys w32 h27 Background" cfg.ThemeButtonReadyColor,"./Img/button_minus_ready.png")
	ui.GameRemoveButton.OnEvent("Click",RemoveGame)
	ui.GameRemoveButton.ToolTip := "Remove Selected Game from List"

	unFocusOpsDDL(*) {
		ui.mainGuiTabs.focus()
	}
	unFocusOpsDDL()
	
	ui.MainGui.SetFont("s10 c" cfg.ThemeFont1Color,"Calibri")	
	ui.GameWindowsListBox := ui.MainGui.AddListBox("x38 y+1 w0 r10 section hidden Background" cfg.ThemePanel1Color " -E0x200 multi",ui.gameWindowsList)
	ui.GameWindowsListBox.ToolTip := "List of available game windows in session"


	{ ;GameWindows Gui Controls
		ui.MainGui.SetFont("s11 c" cfg.ThemeFont1Color,"Calibri")
		ui.Win1Label := ui.MainGui.AddText("xs-2 y62 section w68 h20 Border h20 c" cfg.ThemeFont1Color " Center Background" cfg.ThemePanel1Color,"Game1")

		ui.Win1EnabledToggle := ui.mainGui.AddPicture("xs-1 y+0 section w68 h25 Background" cfg.ThemeButtonReadyColor, cfg.toggleOff)


		ui.MainGui.SetFont("s8 c" cfg.ThemeFont4Color,"Calibri")

		ui.Win1Name := ui.MainGui.AddText("ys-17 x+3 section w150 Right Background" cfg.ThemePanel4Color,"Game  ")
		ui.Win1ProcessName := ui.MainGui.AddText("xs y+1 section w150 Right Background" cfg.ThemePanel4Color,"Not  ")
		ui.Win1HwndText := ui.MainGui.AddText("xs y+1 section w150 Right Background" cfg.ThemePanel4Color,"Found  ")
		ui.Win1HwndText.ToolTip := "Window ID for Game Window 1"
		
		ui.buttonSwapHwnd := ui.MainGui.AddPicture("ys-29 x+4 section w47 h45 Background" (cfg.HwndSwapEnabled ? cfg.ThemeButtonOnColor : cfg.ThemeButtonReadyColor), (cfg.HwndSwapEnabled ? "./Img/button_swapHwnd_enabled.png" : "./Img/button_swapHwnd_disabled.png"))
		ui.buttonSwapHwnd.OnEvent("Click",ToggleHwndSwap)
		ui.buttonSwapHwnd.ToolTip := "Swap Windows"

		;ui.MainGui.SetFont("s13 c" cfg.ThemeFont1Color,"Calibri")
		ui.MainGui.SetFont("s8 c" cfg.ThemeFont4Color,"Calibri")
		ui.Win2Name := ui.MainGui.AddText("x+3 ys+1 section w150 Background" cfg.ThemePanel4Color,"  Game  ")
		ui.Win2ProcessName := ui.MainGui.AddText("xs y+1 section w150 Background" cfg.ThemePanel4Color,"  Not  ")
		ui.Win2HwndText := ui.MainGui.AddText("xs y+1 w150 section Background" cfg.ThemePanel4Color,"  Found  ")
		ui.Win2HwndText.ToolTip := "Window ID for Game Window 1"

		ui.MainGui.SetFont("s11 c" cfg.ThemeFont1Color,"Calibri")
		ui.Win2Label := ui.MainGui.AddText("ys-30 section w70 h20 c" cfg.ThemeFont1Color " Center Background" cfg.ThemePanel1Color,"Game2")

		ui.Win2EnabledToggle := ui.MainGui.AddPicture("xs+2 y+-1 section w69 h25 Background" cfg.ThemeButtonReadyColor, cfg.toggleOff)
		
		ui.opsWin1AfkStatus := ui.MainGui.AddText("xs-429 y+1 section w40 h22 Background" cfg.ThemePanel1Color,"")
		ui.opsWin1AfkStatus.setFont("s14")
		ui.opsWin1AfkIcon 	:= ui.MainGui.AddPicture("ys section w25 h22 Background" cfg.ThemePanel1Color,"./Img/sleep_icon.png")
		ui.opsWin1AfkPad	:= ui.MainGui.AddText("ys section w5 h22 Background" cfg.ThemePanel1Color,"")

		ui.Win1ClassDDL := ui.MainGui.AddDDL("ys-2 x+0 w155 r6 AltSubmit choose" cfg.win1class " Background" cfg.ThemeEditBoxColor, ui.ProfileList)
		ui.Win1ClassDDL.SetFont("s12")
		ui.Win1ClassDDL.OnEvent("Change",opsWin1ClassChange)
		PostMessage("0x153", -1, 22,, "AHK_ID " ui.Win1ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
		PostMessage("0x153", 0, 22,, "AHK_ID " ui.Win1ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153	
		ui.OpsAfkButton := ui.MainGui.AddPicture("ys-1 x+2 w47 h48 section Background" cfg.ThemeButtonReadyColor,"./Img/button_afk_ready.png")
		ui.OpsAfkButton.OnEvent("Click",ToggleAFK)
		ui.OpsAfkButton.ToolTip := "Toggle AFK"
	
		ui.Win2ClassDDL := ui.MainGui.AddDDL("x+2 ys-1 w154 r6 section AltSubmit choose" cfg.win2class " Background" cfg.ThemeEditBoxColor, ui.ProfileList)
		ui.Win2ClassDDL.SetFont("s12","impact light")
		ui.Win2ClassDDL.OnEvent("Change",opsWin2ClassChange)
		PostMessage("0x153", -1, 22,, "AHK_ID " ui.Win2ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
		PostMessage("0x153", 0, 22,, "AHK_ID " ui.Win2ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153		
		ui.opsWin2AfkPad	:= ui.MainGui.AddText("ys+2 x+0 section w6 h22 Background" cfg.ThemePanel1Color,"")
		ui.opsWin2AfkIcon 	:= ui.MainGui.AddPicture("ys w25 h22 section Background" cfg.ThemePanel1Color,"./Img/sleep_icon.png")
		ui.opsWin2AfkStatus := ui.MainGui.AddText("x+0 ys section w50 h22 +Background" cfg.ThemePanel1Color,"")
		UI.opsWin2AfkStatus.setFont("s14")

		ui.autoFireWin1Button := ui.MainGui.AddPicture("x36 y132 section w32 h30 Disabled Background" cfg.ThemeButtonReadyColor,"./Img/button_autoFire1_ready.png")
		ui.autoFireWin1Button.Tooltip := "Window1 AutoFire"
		ui.autoFireWin1Button.OnEvent("Click",autoFireWin1)

		ui.OpsAntiIdle1Button := ui.MainGui.AddPicture("ys x+0 w35 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
		ui.OpsAntiIdle1Button.OnEvent("Click",ToggleAntiIdle1)
		ui.OpsAntiIdle1Button.ToolTip := "Toggle Anti-Idle"
		
		ui.OpsProgress1 := ui.MainGui.AddProgress("ys x+-2 section w156 h28 c" cfg.ThemeFont1Color " Smooth Range0-" cfg.towerInterval " Background" cfg.ThemePanel1Color,0)	
	
		ui.OpsTowerButton := ui.MainGui.AddPicture("x+1 ys+22 w48 h45 section Background" cfg.ThemeButtonReadyColor,"./Img/button_tower_ready.png")
		ui.OpsTowerButton.OnEvent("Click",ToggleTower)
		ui.OpsTowerButton.ToolTip := "Toggle Tower Timer + AFK"
	
		ui.OpsProgress2 := ui.MainGui.AddProgress("x+4 ys-22 section w153 h28 c" cfg.ThemeFont1Color " Smooth Range0-" cfg.towerInterval " Background" cfg.ThemePanel1Color,0)	

		ui.OpsAntiIdle2Button := ui.MainGui.AddPicture("x+1 ys w33 h30 section Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
		ui.OpsAntiIdle2Button.OnEvent("Click",ToggleAntiIdle2)
		ui.OpsAntiIdle2Button.ToolTip := "Toggle Anti-Idle"
		ui.mainGui.addText("ys w1 h30 section background" cfg.themeBright1Color,"")
		ui.autoFireWin2Button := ui.MainGui.AddPicture("ys x+0 section w33 h30 Disabled Background" cfg.ThemeButtonReadyColor,"./Img/button_autoFire2_ready.png")
		ui.autoFireWin2Button.Tooltip := "Window2 AutoFire"
		ui.autoFireWin2Button.OnEvent("Click",autoFireWin2)
		

		ui.OpsStatusLeftTrim := ui.mainGui.AddPicture("x144 y161 w15 h38 section","./Img/label_left_trim.png")
		ui.OpsStatus1 := ui.MainGui.AddPicture("ys w100 h38 section Background" cfg.ThemeButtonReadyColor,"./Img/label_timer_off.png")  ; XX & YY serve to auto-size the window.
		ui.OpsStatus2 := ui.MainGui.AddPicture("x+52 ys w100 h38 section Background" cfg.ThemeButtonReadyColor,"./Img/label_timer_off.png")  ; XX & YY serve to auto-size the window.
		ui.OpsStatusRightTrim := ui.mainGui.AddPicture("ys w15 h38","./Img/label_right_trim.png")


		ui.Win1EnabledToggle.OnEvent("Click",ToggleGame1Status)
		ui.Win1EnabledToggle.ToolTip := "Toggle to have this window ignored by nControl"

		ui.Win2EnabledToggle.OnEvent("Click",ToggleGame2Status)
		ui.Win2EnabledToggle.ToolTip := "Toggle to have this window ignored by nControl"

		drawOpsOutlines()
		ui.win2enabledToggle.redraw()
		;msgbox(cfg.win1class '`n' cfg.win2class)
		
	

	} ;End GameWindow Gui Controls
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
	
	
	ui.BuildNumber :=ui.HelpGui.AddText("x900 y15 w300 h25 BackgroundTrans","Build: " A_FileVersion)
	ui.buildNumber.setFont("s10 cbbaa99")
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
	; tmpGame2StatusDisabled := cfg.win2disabled
	; cfg.win2disabled := cfg.win1disabled
	; cfg.win1disabled := <tmpgame2statusdisabled></tmpgame2statusdisabled>

	
	ui.win1hwnd := ""
	ui.win2hwnd := ""
	; Loop 2 {
		; if !cfg.win%a_index%disabled {
			; ui.win%a_index%enabledToggle.Opt("+Disabled Background" cfg.ThemeDisabledColor)
			; ui.win%a_index%enabledToggle.Value := cfg.toggleOff
		; }
	; }
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
	if !(winExist("ahk_id " ui.win1hwnd))
		return
	ui.Win1EnabledToggle.Value := 												;Property in which ternary output will be stored
		!(cfg.win1disabled := !cfg.win1disabled) 									;Toggles the bit for the Win1Enabled variable
		? (																		;IF (after being toggled) it is true
			ui.Win1EnabledToggle.Opt("Background" cfg.ThemeButtonOnColor)		;Set BG color of the control to theme's Button-On
			,cfg.toggleOn														;Returns png path for toggle's On state			
		) : (																	;ELSE
			ui.Win1EnabledToggle.Opt("Background" cfg.ThemeButtonReadyColor)	;Set BG color of the control to theme's Button-Off
			,cfg.toggleOff 														;Returns png path for toggle's Off state
		)
	if !(ui.win1Hwnd) {
		ui.win1enabledToggle.opt("background" cfg.themeDisabledColor)
	}
	RefreshWinHwnd()
}	
			
toggleGame2Status(*) {
	if !(winExist("ahk_id " ui.win2hwnd))
		return
	ui.Win2EnabledToggle.Value := 												;Property in which ternary output will be stored
		!(cfg.win2disabled := !cfg.win2disabled)									;Toggles the bit for the Win1Enabled variable
		? (																		;IF (after being toggled) it is true
			ui.Win2EnabledToggle.Opt("Background" cfg.ThemeButtonOnColor)		;Set BG color of the control to theme's Button-On
			,cfg.toggleOn														;Returns png path for toggle's On state			
		) : (																	;ELSE
			ui.Win2EnabledToggle.Opt("Background" cfg.ThemeButtonReadyColor)	;Set BG color of the control to theme's Button-Off
			,cfg.toggleOff 														;Returns png path for toggle's Off state
		)																		
	if !(ui.win2Hwnd) {
		ui.win2enabledToggle.opt("background" cfg.themeDisabledColor)
	}
	RefreshWinHwnd()
}			

toggleWinEnabled(toggleControl,instance,*) {
	toggleControl.Value := 												;Property in which ternary output will be stored
		!(ui.win1enabled := !ui.win1enabled) 									;Toggles the bit for the Win1Enabled variable
		? (																		;IF (after being toggled) it is true
			toggleControl.Opt("Background" cfg.ThemeButtonOnColor)		;Set BG color of the control to theme's Button-On
			,cfg.toggleOn														;Returns png path for toggle's On state			
		) : (																	;ELSE
			toggleControl.Opt("Background" cfg.ThemeButtonReadyColor)	;Set BG color of the control to theme's Button-Off
			,cfg.toggleOff 														;Returns png path for toggle's Off state
		)																		
}	

changeDockGameDDL(*) {
	cfg.game := ui.dockGameDDL.value
	ui.gameDDL.text := ui.dockGameDDL.text
	changeGameDDL()
}

changeGameDDL(*) {
	debugLog("Game Profile Changed to: " ui.GameDDL.Text)
	ui.dockBarGui.destroy()
	createDockBar()
	switch ui.gameDDL.text {
		case "Destiny 2":
			dockBarIcons("Destiny 2","Add")
		case "World//Zero":
			dockBarIcons("World//Zero","Add")
	}
	if cfg.topDockEnabled 
		showDockBar()
;If !(WinExist("ahk_id " ui.Win1Hwnd) || WinExist("ahk_id " ui.Win2Hwnd))
	populateClassList()
	RefreshWinHwnd()
	controlFocus(ui.buttonSwapHwnd,ui.mainGui)
	refreshAfkRoutine()
	
	
	if ui.profileList.length > cfg.win1class && cfg.win1class > 0
		ui.Win1ClassDDL.Choose(ui.profileList[cfg.win1class])
	if ui.profileList.length > cfg.win2class && cfg.win2class > 0
		ui.Win2ClassDDL.Choose(ui.profileList[cfg.win2class])
	
}

monitorGameWindows(*) {
	if (!winExist("ahk_id " ui.win1hwnd)) {
		if (winGetList(ui.gameDDL.text).length > 0)
			refreshWinHwnd(1)
	}
	if (!winExist("ahk_id " ui.win2hwnd)) {
		if (winGetList(ui.gameDDL.text).length > 0)
			refreshWinHwnd(2)
	}
}

noGameAlert() {
	if (A_TimeIdlePhysical > 2000 and A_TimeIdleMouse > 2000) {
		static colorIndex := 0
		colorList := [cfg.themePanel3Color,cfg.themePanel2Color]
		colorIndex := (colorIndex + 1 > colorList.length) ? (colorIndex + 1) - colorList.length : colorIndex + 1
		bgColor := (colorIndex > colorList.length) ? ColorList[ColorIndex - colorList.length] : ColorList[colorIndex]
		fgColor := (colorIndex + 1 > colorList.length) ? ColorList[(ColorIndex + 1) - colorList.length] : ColorList[ColorIndex + 1]
		ui.gameDDL.opt("background" bgColor)
		ui.gameDDL.setFont("c" fgColor)
	}
}


RefreshAfkRoutine(*) {
	global
	
	win1afk.steps 			:= array()
	win1afk.waits			:= array()
	win2afk.steps			:= array()
	win2afk.waits			:= array()
	win1afk.routine.delete()
	win2afk.routine.delete()

	Loop read, cfg.AfkDataFile
	{
		if ui.profileList.length < cfg.win1class {
			cfg.win1class := 1 
		} 
		
		
		if (cfg.win1class > 0) && (cfg.win1class <= ui.profileList.length) {
			if (StrSplit(a_loopReadLine,',')[1] == ui.profileList[cfg.win1class]) 
			{
				win1afk.routine.add(,strSplit(a_LoopReadLine,',')[1],strSplit(a_LoopReadLine,',')[2],strSplit(a_LoopReadLine,',')[3],strSplit(a_LoopReadLine,',')[4])
				win1afk.steps.push(StrSplit(a_LoopReadLine,',')[3])
				win1afk.waits.push(StrSplit(a_loopReadLine,',')[4])
			}
		}

		if ui.profileList.length < cfg.win2class {
			cfg.win2class :=1 
		} 
		if (cfg.win2class > 0) && (cfg.win2class <= ui.profileList.length) {
			if (StrSplit(a_loopReadLine,',')[1] == ui.profileList[cfg.win2class])
			{
				win2afk.routine.add(,strSplit(a_LoopReadLine,',')[1],strSplit(a_LoopReadLine,',')[2],strSplit(a_LoopReadLine,',')[3],strSplit(a_LoopReadLine,',')[4])
				win2afk.steps.push(StrSplit(a_LoopReadLine,',')[3])
				win2afk.waits.push(StrSplit(a_loopReadLine,',')[4])
			}
		}
	}
	debugLog("Finished Reading AfkData File")
	; reload()
}

gameInfoUpdate(winNumber,OnOff := false) {

	if (OnOff) {
		fontColor 	:= cfg.themeFont2Color
		bgColor		:= cfg.themePanel2Color
	} else {
		fontColor	:= cfg.ThemeFont4Color
		bgColor		:= cfg.ThemePanel4Color
	}
		
	opsTextControls 	:= array()
	opsTextControls 	:= ["ProcessName","Name","HwndText"]
		
	Loop opsTextControls.Length {
		ui.win%WinNumber%%opsTextControls[A_Index]%.setFont("c" fontColor)
		ui.win%WinNumber%%opsTextControls[A_Index]%.opt("Background" bgColor)
		ui.win%WinNumber%%opsTextControls[A_Index]%.redraw()
	}
	ui.autoFireWin%winNumber%Button.Opt("Background" bgColor)
	if OnOff {
		ui.autoFireWin%winNumber%Button.Value := "./Img/button_autoFire" winNumber "_on.png"
		ui.win%winNumber%classDDL.opt("-disabled background" cfg.themePanel3Color " c" cfg.themeFont3Color)
		ui.afkWin%winNumber%classDDL.opt("-disabled background" cfg.themePanel3Color " c" cfg.themeFont3Color)
		ui.win%winNumber%gridLines.opt("background" cfg.themePanel3Color)
		ui.win%winNumber%gridLines.redraw()
	} else {
		ui.autoFireWin%winNumber%Button.Value := "./Img/button_autoFire" winNumber "_disabled.png"
		ui.win%winNumber%classDDL.opt("disabled background" cfg.themeDisabledColor " c" cfg.themeFont4Color)
		ui.afkWin%winNumber%classDDL.opt("disabled background" cfg.themeDisabledColor " c" cfg.themeFont4Color)
		ui.win%winNumber%gridLines.opt("background" cfg.themeDisabledColor)
		ui.win%winNumber%gridLines.redraw()
		; ui.win%winNumber%enabledToggle.opt("background" cfg.themeDisabledColor)

	}
}

disableWin(winNumber) {
	ui.Win%winNumber%Name.Text := "  Game  "
	ui.Win%winNumber%ProcessName.Text := "  Not  "
	ui.Win%winNumber%HwndText.Text := "  Found  "
	gameInfoUpdate(winNumber,false)
}

updateWin(winNumber) {
		ui.win%winNumber%Name.text 			:= "  " winGetTitle("ahk_id " ui.win%winNumber%hwnd) "  "
		ui.win%winNumber%ProcessName.text 	:= "  " winGetProcessName("ahk_id " ui.win%winNumber%hwnd) "  "
		ui.win%winNumber%HwndText.text 		:= "  " ui.Win%WinNumber%Hwnd "  "
		gameInfoUpdate(winNumber,true)
}

refreshWinHwnd(*) {
	ui.RefreshWindowHandlesButton.opt("background" cfg.themeButtonAlertColor)
	ui.refreshWindowHandlesButton.redraw()
	setTimer () => 	(ui.RefreshWindowHandlesButton.opt("background" cfg.themeButtonReadyColor),ui.refreshWindowHandlesButton.redraw()),-1250
	refreshWin(1)
	refreshWin(2)
	if !ui.win1enabled && !ui.win2enabled {
		ui.gameDDL.setFont("c" cfg.themeFont1color,"calibri bold")
		ui.gameDDL.opt("background" cfg.themeEditboxColor)
		ui.gameDDL.redraw()
		ui.dockGameDDL.setFont("c" cfg.themeFont1Color,"calibri bold")
		ui.dockGameDDL.opt("background" cfg.themeEditboxColor)
		ui.dockGameDDL.redraw()
		controlFocus(ui.mainGuiTabs)
		controlFocus(ui.dockTopDockButton)
		; setTimer(watchForGames,3000)
	} else {
		ui.gameDDL.setFont("c" cfg.themeFont3Color,"calibri bold")
		ui.gameDDL.opt("background" cfg.themePanel3Color)
		ui.gameDDL.redraw()
		ui.dockGameDDL.setFont("c" cfg.themeFont3Color,"calibri bold")
		ui.dockGameDDL.opt("background" cfg.themePanel3Color)
		ui.dockGameDDL.redraw()
		controlFocus(ui.mainGuiTabs)
		controlFocus(ui.dockTopDockButton)
		; setTimer(watchForGames,0)
	}

}

watchForGames(*) {
	loop cfg.gameList.length {
		winGetID(cfg.gameList[a_index])
		if !InStr(cfg.excludedProcesses,WinGetProcessName("ahk_id " winGetId(cfg.gameList[A_Index]))) {
			ui.gameDDL.choose(a_index)
			changeGameDDL()
		}		
	}
}

refreshWin(winNumber) { ;Performs Window Discovery, Game Identification and Gui Data Updates
	Thread("NoTimers")
	debugLog("Refreshing Game Window HWND IDs") 


	origWinNumber := winNumber
	
	winNumber := 
	(cfg.hwndSwapEnabled) 
		? ((winNumber == 1) 
			? 2 
		: 1) 
			: winNumber	
			
	ui.AllGameWindowsList := WinGetList(strReplace(ui.GameDDL.Text,"World//Zero","Roblox"))
	ui.FilteredGameWindowsList := Array()
	Loop ui.AllGameWindowsList.Length {
		if !InStr(cfg.excludedApps,WinGetProcessName("ahk_id " ui.AllGameWindowsList[A_Index])) {
			ui.FilteredGameWindowsList.Push(ui.AllGameWindowsList[A_Index])
		}
	}

	ui.win%winNumber%enabled := false
	if (ui.filteredGameWindowsList.length >= origWinNumber && winExist("ahk_id " ui.filteredGameWindowsList[origWinNumber])) {
		ui.win%winNumber%enabled := true
		ui.win%WinNumber%Hwnd := ui.filteredGameWindowsList[origWinNumber]
		ui.win%winNumber%HwndText.text := ui.Win%WinNumber%Hwnd
		ui.win%winNumber%Name.text
		updateWin(winNumber)
		ui.win%winNumber%enabledToggle.opt("-disabled")
		if !cfg.win%winNumber%disabled {
			ui.win%winNumber%enabledToggle.value := cfg.toggleOn
			ui.win%origWinNumber%enabledToggle.opt("background" cfg.themeButtonOnColor)
		}	

	} else { 
		ui.win%winNumber%enabled == false
		disableWin(winNumber)
		;ui.win%winNumber%enabledToggle.opt("+disabled")
		ui.win%winNumber%enabledToggle.value := cfg.toggleOff
		ui.win%winNumber%enabledToggle.opt("background" cfg.themeButtonReadyColor)
	}
	
		ui.Win%winNumber%EnabledToggle.Value := 												;Property in which ternary output will be stored
		!(cfg.win%winNumber%disabled)					 									;Toggles the bit for the Win%winNumber%Enabled variable
		? (																		;IF (after being toggled) it is true
			ui.Win%winNumber%EnabledToggle.Opt("Background" cfg.ThemeButtonOnColor)		;Set BG color of the control to theme's Button-On
			,cfg.toggleOn														;Returns png path for toggle's On state			
		) : (																	;ELSE
			ui.Win%winNumber%EnabledToggle.Opt("Background" cfg.ThemeButtonReadyColor)	;Set BG color of the control to theme's Button-Off
			,cfg.toggleOff 														;Returns png path for toggle's Off state
		)
		
	
	if (cfg.win%winNumber%disabled) {
		gameInfoUpdate(winNumber,false)
		ui.win%winNumber%enabledToggle.value := cfg.toggleOff
		ui.win%winNumber%enabledToggle.opt("background" cfg.themeButtonReadyColor)
	}
	ui.RefreshWindowHandlesButton.opt("background" cfg.themeButtonReadyColor)

}	
/* 

									Loop ui.FilteredGameWindowsList.Length
									{	
										

										ui.gameDDL.opt("background" cfg.themeEditBoxColor)
										ui.gameDDL.setFont("c" cfg.themeFont1Color)
										ui.win%winNumber%enabled := true
										ui.win%WinNumber%Hwnd := ui.FilteredGameWindowsList[A_Index]
										ui.win%WinNumber%HwndText.Text := "  " ui.Win%WinNumber%Hwnd "  "
										ui.win%WinNumber%Name.Text := "  " WinGetTitle("ahk_id " ui.FilteredGameWindowsList[A_Index]) "  "
										ui.win%WinNumber%ProcessName.Text := "  " WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd) "  "
										gameInfoUpdate(winNumber,1)
										if !(winExist("ahk_id " ui.win%winNumber%hwnd)) {
											ui.win%WinNumber%enabledToggle.Opt("+Disabled Background" cfg.ThemeDisabledColor)
											ui.win%WinNumber%enabledToggle.Value := cfg.toggleOff
											ui.opsWin%winNumber%classDDL.opt("disabled")
											ui.win%winNumber%classDDL.opt("disabled")
										}
										
									; else {
										; if !cfg.win%winNumber%disabled
										; {
											; ui.win%WinNumber%enabledToggle.Opt("+Disabled Background" cfg.ThemeButtonOnColor)
											; ui.win%WinNumber%enabledToggle.Value := cfg.toggleOn
											; ui.win%winNumber%GridLines.opt("background" cfg.themeBright2Color)
										; }
									; }
										if !(cfg.win%winNumber%disabled) && (winExist("ahk_id " ui.win%winNumber%hwnd)) {
											ui.win%WinNumber%EnabledToggle.Opt("Background" cfg.themeButtonOnColor)
											ui.win%WinNumber%EnabledToggle.Value := cfg.toggleOn

											ui.win%WinNumber%ClassDDL.Opt("-Disabled")
											ui.afkWin%WinNumber%ClassDDL.Opt("-Disabled")
											ui.Win%WinNumber%ClassDDL.SetFont("c" cfg.ThemeFont1Color)
											ui.afkWin%WinNumber%ClassDDl.setFont("c" cfg.themeFont1Color)
											ui.autoFireWin%WinNumber%Button.Opt("-Disabled Background" cfg.ThemeButtonReadyColor)
											ui.autoFireWin%WinNumber%Button.Value := "./Img/button_autoFire" WinNumber "_ready.png"				
											ui.win%WinNumber%enabledToggle.Opt("-Disabled Background" cfg.ThemeButtonOnColor)

										} else {
											ui.Win%WinNumber%ProcessName.SetFont("c" cfg.ThemeFont4Color)
											ui.Win%WinNumber%Name.SetFont("c" cfg.ThemeFont4Color)
											ui.Win%WinNumber%HwndText.SetFont("c" cfg.ThemeFont4Color)

											ui.Win%WinNumber%ProcessName.Opt("Background" cfg.ThemePanel4Color)
											ui.Win%WinNumber%HwndText.Opt("Background" cfg.ThemePanel4Color)
											ui.Win%WinNumber%Name.Opt("Background" cfg.ThemePanel4Color)
											ui.win%winNumber%gridLines.opt("background" cfg.themeFont4Color)
											ui.win%winNumber%gridLines.redraw()
											ui.autoFireWin%WinNumber%Button.Opt("Disabled Background" cfg.ThemePanel4Color)
											ui.autoFireWin%WinNumber%Button.Value := "./Img/button_autoFire" WinNumber "_disabled.png"
											ui.opsWin%winNumber%classDDL.opt("disabled")
											ui.win%winNumber%classDDL.opt("disabled")
										}
									}
									ui.buttonSwapHwnd.Value := cfg.HwndSwapEnabled ? "./Img/button_swapHwnd_enabled.png" : "./Img/button_swapHwnd_disabled.png"
									ui.buttonSwapHwnd.Redraw()
								} else {
									ui.Win%winNum%Name.Text := "  Game  "
									ui.Win%winNum%Name.SetFont("c" cfg.ThemeFont4Color)
									ui.Win%winNum%Name.Opt("Background" cfg.ThemePanel4Color)
									ui.Win%winNum%ProcessName.Text := "  Not  "
									ui.Win%winNum%ProcessName.SetFont("c" cfg.ThemeFont4Color)
									ui.Win%winNum%ProcessName.Opt("Background" cfg.ThemePanel4Color)
									ui.Win%winNum%HwndText.Text := "  Found  "
									ui.Win%winNum%HwndText.SetFont("c" cfg.ThemeFont4Color)
									ui.Win%winNum%HwndText.Opt("Background" cfg.ThemePanel4Color)
									ui.autoFireWin%winNum%Button.Opt("Background" cfg.ThemePanel4Color)
									ui.autoFireWin%winNum%Button.Value := "./Img/button_autoFire" winNum "_on.png"
									ui.opsWin%winNumber%classDDL.opt("disabled")
									ui.win%winNumber%classDDL.opt("disabled")
									ui.win%winNumber%GridLines.opt("background" cfg.themeDark2Color)
									Loop ui.AllGameWindowsList.Length {
										if (WinGetProcessName("ahk_id " ui.AllGameWindowsList[winNum]) != "Windows10Universal.exe") 
										&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[winNum]) != "explorer.exe") 
										&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[winNum]) != "RobloxPlayerLauncher.exe")
										&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[winNum]) != "RobloxPlayerInstaller.exe") 
										&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[winNum]) != "Chrome.exe") 
										&& (WinGetProcessName("ahk_id " ui.AllGameWindowsList[winNum]) != "msedge.exe") 
										{
											ui.FilteredGameWindowsList.Push(ui.AllGameWindowsList[winNum])
										}
									}
									Win1X := "",		Win2X := 999999
									Win1Y := "",		Win2Y := ""
									Win1W := "",		Win2W := ""
									Win1H := "",		Win2H := ""
								
									textList := ""
									Loop ui.FilteredGameWindowsList.Length {
										textList .= ui.FilteredGameWindowsList[winNum] ", "
									}
									
									debugLog("Found the following matching HWNDs: " rtrim(textList,", "))		
									
									Loop ui.FilteredGameWindowsList.Length {
										WinGetPos(&Win%winNum%X,&Win%winNum%Y,&Win%winNum%W,&Win%winNum%H,"ahk_id " ui.FilteredGameWindowsList[winNum])
									}

									Loop ui.FilteredGameWindowsList.Length
									{	
										winNumber := 
											(Win1X >  Win2X) 
											? ((winNum == 1) 
												? 2 
												: 1) 
											: winNum
										
										winNumber := 
											(cfg.hwndSwapEnabled) 
											? ((winNumber == 1) 
												? 2 
												: 1) 
											: winNumber			

										ui.win%winNumber%enabled := true
										ui.win%winNumber%GridLines.opt("background" cfg.themeDark2Color)
										ui.win%WinNumber%Hwnd := ui.FilteredGameWindowsList[winNum]
										ui.win%WinNumber%HwndText.Text := "  " ui.Win%WinNumber%Hwnd "  "
										ui.win%WinNumber%Name.Text := "  " WinGetTitle("ahk_id " ui.FilteredGameWindowsList[winNum]) "  "
										ui.win%WinNumber%ProcessName.Text := "  " WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd) "  "
								
								
										if !(winExist("ahk_id " ui.win%winNumber%hwnd)) {
											ui.win%WinNumber%enabledToggle.Opt("+Disabled Background" cfg.ThemeDisabledColor)
											ui.win%WinNumber%enabledToggle.Value := cfg.toggleOff

										} else {
											if !cfg.win%winNumber%disabled
											{
												ui.win%WinNumber%enabledToggle.Opt("+Disabled Background" cfg.ThemeButtonOnColor)
												ui.win%WinNumber%enabledToggle.Value := cfg.toggleOn			
											}
										}
										if !(cfg.win%winNumber%disabled) && (winExist("ahk_id " ui.win%winNumber%hwnd)) {
											ui.win%WinNumber%EnabledToggle.Opt("Background" cfg.themeButtonOnColor)
											ui.win%WinNumber%EnabledToggle.Value := cfg.toggleOn

											opsTextControls 	:= array()
											opsTextControls 	:= ["ProcessName","Name","HwndText"]
											
											Loop opsTextControls.Length {
												ui.win%WinNumber%%opsTextControls[winNum]%.setFont("c" cfg.themeFont2Color)
												ui.win%WinNumber%%opsTextControls[winNum]%.opt("Background" cfg.themePanel2Color)
												ui.win%WinNumber%%opsTextControls[winNum]%.redraw()
											}
											
											ui.win%WinNumber%ClassDDL.Opt("-Disabled")
											ui.afkWin%WinNumber%ClassDDL.Opt("-Disabled")
											ui.Win%WinNumber%ClassDDL.SetFont("c" cfg.ThemeFont1Color)
											ui.afkWin%WinNumber%ClassDDl.setFont("c" cfg.themeFont1Color)
											ui.autoFireWin%WinNumber%Button.Opt("-Disabled Background" cfg.ThemeButtonReadyColor)
											ui.autoFireWin%WinNumber%Button.Value := "./Img/button_autoFire" WinNumber "_ready.png"				
											ui.win%WinNumber%enabledToggle.Opt("-Disabled Background" cfg.ThemeButtonOnColor)
											ui.win%WinNumber%enabledToggle.Value := cfg.toggleOn
										} else {
											ui.Win%WinNumber%ProcessName.SetFont("c" cfg.ThemeFont4Color)
											ui.Win%WinNumber%Name.SetFont("c" cfg.ThemeFont4Color)
											ui.Win%WinNumber%HwndText.SetFont("c" cfg.ThemeFont4Color)


											ui.Win%WinNumber%ProcessName.Opt("Background" cfg.ThemePanel4Color)
											ui.Win%WinNumber%HwndText.Opt("Background" cfg.ThemePanel4Color)
											ui.Win%WinNumber%Name.Opt("Background" cfg.ThemePanel4Color)
								
											ui.autoFireWin%WinNumber%Button.Opt("Disabled Background" cfg.ThemePanel4Color)
											ui.autoFireWin%WinNumber%Button.Value := "./Img/button_autoFire" WinNumber "_disabled.png"
									}
								}
									
								;ui.Win%WinNumber%ClassDDL.Opt("+Disabled")
								;ui.afkWin%WinNumber%ClassDDL.Opt("+Disabled")
								ui.buttonSwapHwnd.Value := cfg.HwndSwapEnabled ? "./Img/button_swapHwnd_enabled.png" : "./Img/button_swapHwnd_disabled.png"
ui.buttonSwapHwnd.Redraw()*/

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

	

	
	
