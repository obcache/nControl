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
		Loop parse, A_LoopReadLine, "CSV" 
		{
			if (A_Index == 1 && !(InStr(ui.ProfileListStr,A_LoopField)))
			{
				ui.ProfileListStr .= A_LoopField ","
				ui.ProfileList.Push(A_LoopField)
			}
		}
	}
}

GuiOperationsTab(&ui,&cfg,&afk) { ;libGuiOperationsTab
	global
	refreshAfkRoutine()
	ui.MainGuiTabs.UseTab("Sys")
	ui.MainGui.SetFont("s14","Calibri Thin")

	ui.OpsDockButton := ui.MainGui.AddPicture("x38 y35 w27 h27 section Background" cfg.ThemeButtonReadyColor,"./Img/button_dockLeft_ready.png")
	ui.OpsDockButton.OnEvent("Click",ToggleAfkDock)
	ui.OpsDockButton.ToolTip 		:= "Dock AFK Panel"
	

	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri Thin")
	ui.OpsClockModeLabel := ui.MainGui.AddText("x+2 ys+2 section w48 h22 Background" cfg.ThemePanel2Color," Clock")
	ui.OpsClockModeLabel.SetFont("s8 c" cfg.ThemeFont2Color,"Ariel Bold")
	
	ui.OpsClock := ui.MainGui.AddText("x+0 ys w120 Right h22 Background" cfg.ThemePanel2Color " c" cfg.ThemeFont2Color,)
	ui.OpsClock.SetFont("s16","Orbitron")
	ui.OpsClock.OnEvent("Click",ChangeClockMode)
	ui.OpsClock.OnEvent("ContextMenu",ShowClockMenu)
	ui.OpsClock.ToolTip := "Left Click Starts/Stops Timer. `nRight Click Resets Timer. `nDouble-Click to Return to Time Mode."
	SetTimer(opsClickTimeUpdate,1000)
	
	ui.ButtonDebug := ui.MainGui.AddPicture( 
	(cfg.consoleVisible) 
		? "x+2 ys-2 w27 h27 section Background" cfg.ThemeButtonOnColor 
		: "x+2 ys-2 w27 h27 section Background" cfg.ThemeButtonReadyColor,
	(cfg.consoleVisible) 
		? "./Img/button_console_ready.png" 
		: "./Img/button_console_ready.png")
	
	ui.ButtonDebug.OnEvent("Click",toggleConsole)		

	ui.RefreshWindowHandlesButton := ui.MainGui.AddPicture("x+1 ys section w27 h27 Background" cfg.ThemeFont1Color, "./Img/button_refresh.png")	
	ui.RefreshWindowHandlesButton.OnEvent("Click",refreshWinHwnd)
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
		ui.Win1Label := ui.MainGui.AddText("xs-2 y62 section w68 h20 Border h20 c" cfg.ThemeFont1Color " Center Background" cfg.ThemePanel1Color,"Game1")

		ui.Win1EnabledToggle := ui.mainGui.AddPicture("xs-1 y+0 section w69 h25 Background" ((cfg.win1disabled) ? cfg.ThemeButtonReadyColor : cfg.themeButtonOnColor),(cfg.win1disabled) ? cfg.toggleOff : cfg.toggleOn)


		ui.MainGui.SetFont("s8 c" cfg.ThemeFont4Color,"Calibri")

		ui.Win1Name := ui.MainGui.AddText("ys-18 x+3 section w154 Right Background" cfg.ThemePanel4Color,"Game  ")
		ui.Win1ProcessName := ui.MainGui.AddText("xs y+1 section w154 Right Background" cfg.ThemePanel4Color,"Not  ")
		ui.Win1HwndText := ui.MainGui.AddText("xs y+1 section w154 Right Background" cfg.ThemePanel4Color,"Found  ")
		ui.Win1HwndText.ToolTip := "Window ID for Game Window 1"
		
		ui.buttonSwapHwnd := ui.MainGui.AddPicture("ys-29 x+-1 section w45 h45 Background" (cfg.HwndSwapEnabled ? cfg.ThemeButtonOnColor : cfg.ThemeButtonReadyColor), (cfg.HwndSwapEnabled ? "./Img/button_swapHwnd_enabled.png" : "./Img/button_swapHwnd_disabled.png"))
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

		ui.Win2EnabledToggle := ui.MainGui.AddPicture("xs section w69 h25 Background" ((cfg.win1disabled) ? cfg.ThemeButtonReadyColor : cfg.themeButtonOnColor),(cfg.win1disabled) ? cfg.toggleOff : cfg.toggleOn)

		
		ui.opsWin1AfkStatus := ui.MainGui.AddText("xs-429 section w45 h30 Background" cfg.ThemePanel1Color,"")
		ui.opsWin1AfkStatus.setFont("s14")
		ui.opsWin1AfkIcon := ui.MainGui.AddPicture("ys section w25 h30 Background" cfg.ThemePanel1Color,"./Img/sleep_icon.png")

		ui.Win1ClassDDL := ui.MainGui.AddDDL("ys-1 x+0 w156 r6 AltSubmit choose" cfg.win1class " Background" cfg.ThemeEditBoxColor, ui.ProfileList)
		ui.Win1ClassDDL.SetFont("s14")
		ui.Win1ClassDDL.OnEvent("Change",opsWin1ClassChange)
		PostMessage("0x153", -1, 26,, "AHK_ID " ui.Win1ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
		PostMessage("0x153", 0, 26,, "AHK_ID " ui.Win1ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153	
		ui.OpsAfkButton := ui.MainGui.AddPicture("ys x+2 w47 h48 section Background" cfg.ThemeButtonReadyColor,"./Img/button_afk_ready.png")
		ui.OpsAfkButton.OnEvent("Click",ToggleAFK)
		ui.OpsAfkButton.ToolTip := "Toggle AFK"
	
		ui.Win2ClassDDL := ui.MainGui.AddDDL("x+-1 ys-1 w155 r6 section AltSubmit choose" cfg.win2class " Background" cfg.ThemeEditBoxColor, ui.ProfileList)
		ui.Win2ClassDDL.SetFont("s14")
		ui.Win2ClassDDL.OnEvent("Change",opsWin2ClassChange)
		PostMessage("0x153", -1, 26,, "AHK_ID " ui.Win2ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
		PostMessage("0x153", 0, 26,, "AHK_ID " ui.Win2ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153		
		ui.opsWin2AfkIcon := ui.MainGui.AddPicture("ys+1 w25 h30 section Background" cfg.ThemePanel1Color,"./Img/sleep_icon.png")
		ui.opsWin2AfkStatus := ui.MainGui.AddText("x+0 ys section w50 h30 +Background" cfg.ThemePanel1Color,"")
		UI.opsWin2AfkStatus.setFont("s14")

		ui.autoFireWin1Button := ui.MainGui.AddPicture("x36 y137 section w30 h30 Disabled Background" cfg.ThemeButtonReadyColor,"./Img/button_autoFire1_ready.png")
		ui.autoFireWin1Button.Tooltip := "Window1 AutoFire"
		ui.autoFireWin1Button.OnEvent("Click",autoFireWin1)

		ui.OpsAntiIdle1Button := ui.MainGui.AddPicture("ys x+1 w33 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
		ui.OpsAntiIdle1Button.OnEvent("Click",ToggleAntiIdle1)
		ui.OpsAntiIdle1Button.ToolTip := "Toggle Anti-Idle"
		
		ui.OpsProgress1 := ui.MainGui.AddProgress("ys section w158 h28 c" cfg.ThemeFont1Color " Smooth Range0-" cfg.towerInterval " Background" cfg.ThemePanel1Color,0)	
	
		ui.OpsTowerButton := ui.MainGui.AddPicture("x+2 ys+18 w47 h47 section Background" cfg.ThemeButtonReadyColor,"./Img/button_tower_ready.png")
		ui.OpsTowerButton.OnEvent("Click",ToggleTower)
		ui.OpsTowerButton.ToolTip := "Toggle Tower Timer + AFK"
	
		ui.OpsProgress2 := ui.MainGui.AddProgress("x+0 ys-17 section w167 h28 c" cfg.ThemeFont1Color " Smooth Range0-" cfg.towerInterval " Background" cfg.ThemePanel1Color,0)	

		ui.OpsAntiIdle2Button := ui.MainGui.AddPicture("x+0 ys w28 h28 section Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
		ui.OpsAntiIdle2Button.OnEvent("Click",ToggleAntiIdle2)
		ui.OpsAntiIdle2Button.ToolTip := "Toggle Anti-Idle"
		
		ui.autoFireWin2Button := ui.MainGui.AddPicture("ys x+0 section w28 h28 Disabled Background" cfg.ThemeButtonReadyColor,"./Img/button_autoFire2_ready.png")
		ui.autoFireWin2Button.Tooltip := "Window2 AutoFire"
		ui.autoFireWin2Button.OnEvent("Click",autoFireWin2)
		

		ui.OpsStatusLeftTrim := ui.mainGui.AddPicture("x146 y165 w15 h40 section","./Img/label_left_trim.png")
		ui.OpsStatus1 := ui.MainGui.AddPicture("ys w100 h40 section Background" cfg.ThemeButtonReadyColor,"./Img/label_timer_off.png")  ; XX & YY serve to auto-size the window.
		ui.OpsStatus2 := ui.MainGui.AddPicture("x+47 ys w100 h40 section Background" cfg.ThemeButtonReadyColor,"./Img/label_timer_off.png")  ; XX & YY serve to auto-size the window.
		ui.OpsStatusRightTrim := ui.mainGui.AddPicture("ys w15 h40","./Img/label_right_trim.png")


		ui.Win1EnabledToggle.OnEvent("Click",ToggleGame1Status)
		ui.Win1EnabledToggle.ToolTip := "Toggle to have this window ignored by nControl"

		ui.Win2EnabledToggle.OnEvent("Click",ToggleGame2Status)
		ui.Win2EnabledToggle.ToolTip := "Toggle to have this window ignored by nControl"

		drawOpsOutlines()
		;msgbox(cfg.win1class '`n' cfg.win2class)
		ui.Win1ClassDDL.Choose(ui.profileList[cfg.win1class])
		ui.Win2ClassDDL.Choose(ui.profileList[cfg.win2class])

		RefreshAfkRoutine()
		; RefreshWin2AfkRoutine()	
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
	ui.buttonSwapHwnd.Value := 
		((cfg.HwndSwapEnabled := !cfg.HwndSwapEnabled) 
			? (ui.buttonSwapHwnd.Opt("Background" cfg.ThemeButtonOnColor), "./Img/button_swapHwnd_enabled.png") 
			: (ui.buttonSwapHwnd.Opt("Background" cfg.ThemeBackgroundColor), "./Img/button_swapHwnd_disabled.png"))
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
		(cfg.win1disabled := !cfg.win1disabled) 									;Toggles the bit for the Win1Enabled variable
		? (																		;IF (after being toggled) it is true
			ui.Win1EnabledToggle.Opt("Background" cfg.ThemeButtonReadyColor)	;Set BG color of the control to theme's Button-Off
			,cfg.toggleOff 														;Returns png path for toggle's Off state
		) : (																	;ELSE
			ui.Win1EnabledToggle.Opt("Background" cfg.ThemeButtonOnColor)		;Set BG color of the control to theme's Button-On
			,cfg.toggleOn														;Returns png path for toggle's On state			
		)																		
	;RefreshWinHwnd()
}	
			
toggleGame2Status(*) {
	if !(winExist("ahk_id " ui.win2hwnd))
		return
msgBox('2')
ui.Win2EnabledToggle.Value := 												;Property in which ternary output will be stored
		(cfg.win2disabled := !cfg.win2disabled)									;Toggles the bit for the Win1Enabled variable
		? (																		;IF (after being toggled) it is true
			ui.Win2EnabledToggle.Opt("Background" cfg.ThemeButtonReadyColor)	;Set BG color of the control to theme's Button-Off
			,cfg.toggleOff 														;Returns png path for toggle's Off state
		) : (																	;ELSE
			ui.Win2EnabledToggle.Opt("Background" cfg.ThemeButtonOnColor)		;Set BG color of the control to theme's Button-On
			,cfg.toggleOn														;Returns png path for toggle's On state			
		)																		
	;RefreshWinHwnd()
}			

toggleWin1Enabled(toggleControl,instance,*) {
	toggleControl.Value := 												;Property in which ternary output will be stored
		!(ui.win1disabled := !ui.win1disabled) 									;Toggles the bit for the Win1Enabled variable
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


updateWinInfo(winNumber,enabled := 0,winTitle := " Game ",procName := " not ",winHwnd := "Found") {
	ui.win%winNumber%ProcessName.text 	:= procName
	ui.win%winNumber%Name.text 			:= winTitle
	ui.win%winNumber%HwndText.text 		:= winHwnd	

	opsTextControls 	:= array()
	opsTextControls 	:= ["ProcessName","Name","HwndText"]

	Loop opsTextControls.Length {
		ui.win%winNumber%ProcessName.setFont("c" ((enabled) ? cfg.themeFont2Color : cfg.thmeFont4Color))
		ui.win%winNumber%ProcessName.opt("Background" ((enabled) ? cfg.themePanel2Color : cfg.themePanel1Color))
		ui.win%winNumber%ProcessName.redraw()
		ui.win%winNumber%Name.setFont("c" ((enabled) ? cfg.themeFont2Color : cfg.thmeFont4Color))
		ui.win%winNumber%Name.opt("Background" ((enabled) ? cfg.themePanel2Color : cfg.themePanel1Color))
		ui.win%winNumber%Name.redraw()
		ui.win%winNumber%HwndText.setFont("c" ((enabled) ? cfg.themeFont2Color : cfg.thmeFont4Color))
		ui.win%winNumber%HwndText.opt("Background" ((enabled) ? cfg.themePanel2Color : cfg.themePanel1Color))
		ui.win%winNumber%HwndText.redraw()
		ui.win%winNumber%enabledToggle.opt("Background" ((enabled) ?  ((cfg.win%winNumber%disabled) ? cfg.themeButtonOnColor : cfg.themeButtonReadyColor) : cfg.themeDisabledColor))
	}
}	

refreshWinHwnd(*) {
	refreshWin(0)
}


refreshWin(winNumber := 0) { ;Performs Window Discovery, Game Identification and Gui Data Updates
	Thread("NoTimers")
	debugLog("Refreshing Game Window HWND IDs")
	ui.GameWindowsListBox.Delete()
	ui.AllGameWindowsList := WinGetList(ui.GameDDL.Text)
	ui.FilteredGameWindowsList := Array()
	
	winNumber := 
		(cfg.hwndSwapEnabled) 
			? ((winNumber == 1) 
				? 2 
				: winNumber) 
			: ((winNumber == 2)
				? 1
				: winNumber)
		
		
	Loop ui.AllGameWindowsList.Length {
			if !Instr(
			"Windows10Universal.exe,explorer.exe,RobloxPlayerInstaller.exe,RobloxPlayerLauncher.exe,Chrome.exe,msedge.exe"
			,WinGetProcessName("ahk_id " ui.AllGameWindowsList[A_Index]))
				ui.FilteredGameWindowsList.Push(ui.AllGameWindowsList[A_Index])
	}
	
	Win1X := 0,		Win2X := 999999
	Win1Y := 0,		Win2Y := 0
	Win1W := 0,		Win2W := 0
	Win1H := 0,		Win2H := 0

	textList := ""

	

			; if cfg.win%winNumber%disabled
			; {
				; ui.win%winNumber%enabledToggle.Opt("+Disabled Background" cfg.ThemeButtonOnColor)
				; ui.win%winNumber%enabledToggle.Value := cfg.toggleOn			
				; ui.autoFireWin%winNumber%Button.Value := "./Img/button_autoFire" winNumber "_on.png"	
			; } else {
				; ui.win%winNumber%enabledToggle.Opt("-Disabled Background" cfg.ThemeButtonReadyColor)
				; ui.win%winNumber%enabledToggle.Value := cfg.toggleOff
				; ui.autoFireWin%winNumber%Button.Value := "./Img/button_autoFire" winNumber "_disabled.png"
			; }

			; ui.Win%winNumber%Name.SetFont("c" cfg.ThemeFont4Color)
			; ui.Win%winNumber%Name.Opt("Background" cfg.ThemePanel4Color)
			; ui.Win%winNumber%ProcessName.SetFont("c" cfg.ThemeFont4Color)
			; ui.Win%winNumber%ProcessName.Opt("Background" cfg.ThemePanel4Color)
			; ui.Win%winNumber%HwndText.SetFont("c" cfg.ThemeFont4Color)
			; ui.Win%winNumber%HwndText.Opt("Background" cfg.ThemePanel4Color)
			; ui.autoFireWin%winNumber%Button.Opt("Background" cfg.ThemePanel4Color)
			; ui.autoFireWin%winNumber%Button.Value := "./Img/button_autoFire" winNumber "_on.png"

			
	loop 2 {
		if ui.FilteredGameWindowsList.length >= a_index && (WinExist("ahk_id " ui.filteredGameWindowsList[winNumber])) {	
			ui.win%a_index%enabled := true
			ui.win%a_index%Hwnd := ui.FilteredGameWindowsList[a_index]
			updateWinInfo(winNumber,1,"  " WinGetProcessName("ahk_id " ui.Win%winNumber%Hwnd) "  ","  " WinGetTitle("ahk_id " ui.FilteredGameWindowsList[a_index]) "  ","  " ui.Win%winNumber%Hwnd "  ")
				}
				; if !(cfg.win%winNumber%disabled) && (winExist("ahk_id " ui.win%winNumber%hwnd)) {
					; ui.win%winNumber%EnabledToggle.Opt("Background" cfg.themeButtonOnColor)
					; ui.win%winNumber%EnabledToggle.Value := cfg.toggleOn

					; ui.win%winNumber%ClassDDL.Opt("-Disabled")
					; ui.afkWin%winNumber%ClassDDL.Opt("-Disabled")
					; ui.Win%winNumber%ClassDDL.SetFont("c" cfg.ThemeFont1Color)
					; ui.afkWin%winNumber%ClassDDl.setFont("c" cfg.themeFont1Color)
					; ui.autoFireWin%winNumber%Button.Opt("-Disabled Background" cfg.ThemeButtonReadyColor)
					; ui.autoFireWin%winNumber%Button.Value := "./Img/button_autoFire" winNumber "_ready.png"				
					; ui.win%winNumber%enabledToggle.Opt("-Disabled Background" cfg.ThemeButtonOnColor)
					; ui.win%winNumber%enabledToggle.Value := cfg.toggleOn
				; } else {
					; ui.Win%winNumber%ProcessName.SetFont("c" cfg.ThemeFont4Color)
					; ui.Win%winNumber%Name.SetFont("c" cfg.ThemeFont4Color)
					; ui.Win%winNumber%HwndText.SetFont("c" cfg.ThemeFont4Color)


					; ui.Win%winNumber%ProcessName.Opt("Background" cfg.ThemePanel4Color)
					; ui.Win%winNumber%HwndText.Opt("Background" cfg.ThemePanel4Color)
					; ui.Win%winNumber%Name.Opt("Background" cfg.ThemePanel4Color)
		
					; ui.autoFireWin%winNumber%Button.Opt("Disabled Background" cfg.ThemePanel4Color)
					; ui.autoFireWin%winNumber%Button.Value := "./Img/button_autoFire" winNumber "_disabled.png"
				; }
			} else {
				ui.win%winNumber%enabledToggle.opt("background" cfg.themeDisabledColor)
			}
/* 		} else {
			updateWinInfo(1)
			updateWinInfo(2)
			
		} */
		
		;ui.Win%winNumber%ClassDDL.Opt("+Disabled")
		;ui.afkWin%winNumber%ClassDDL.Opt("+Disabled")
		ui.buttonSwapHwnd.Value := cfg.HwndSwapEnabled ? "./Img/button_swapHwnd_enabled.png" : "./Img/button_swapHwnd_disabled.png"
		ui.buttonSwapHwnd.Redraw()

	
}

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

	

	
	
