#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	Return
}

;libGuiOperationsTab
GuiOperationsTab(&ui,&cfg)
{
	ui.MainGuiTabs.UseTab("Sys")
	ui.MainGui.SetFont("s14","Calibri Thin")

	ui.OpsDockButton := ui.MainGui.AddPicture("x3 y34 w27 h27 section Background" cfg.ThemeButtonReadyColor,"./Img/button_dockLeft_ready.png")
	ui.OpsDockButton.OnEvent("Click",ToggleAfkDock)
	ui.OpsDockButton.ToolTip := "Dock AFK Panel"
	
	ui.OpsTowerButton := ui.MainGui.AddPicture("x+2 ys+0 w27 h27 Background" cfg.ThemeButtonReadyColor,"./Img/button_tower_ready.png")
	ui.OpsTowerButton.OnEvent("Click",ToggleTower)
	ui.OpsTowerButton.ToolTip := "Toggle Tower Timer + AFK"
	
	ui.OpsAfkButton := ui.MainGui.AddPicture("x+2 ys+0 w27 h27 Background" cfg.ThemeButtonReadyColor,"./Img/button_afk_ready.png")
	ui.OpsAfkButton.OnEvent("Click",ToggleAFK)
	ui.OpsAfkButton.ToolTip := "Toggle AFK"
	
	ui.OpsAntiIdleButton := ui.MainGui.AddPicture("x+1 ys+0 w30 h27 Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
	ui.OpsAntiIdleButton.OnEvent("Click",ToggleAntiIdle)
	ui.OpsAntiIdleButton.ToolTip := "Toggle Anti-Idle"

	ui.OpsClockModeLabel := ui.MainGui.AddText("x+1 section w30 h26 Background" cfg.ThemeConsoleBg2Color,"Clock")
	ui.OpsClockModeLabel.SetFont("s8 c" cfg.ThemeFont2Color,"Ariel Bold")
	
	ui.OpsClock := ui.MainGui.AddText("x+0 ys+1 w120 Right h25 Background" cfg.ThemeConsoleBg2Color " c" cfg.ThemeFont2Color,)
	ui.OpsClock.SetFont("s16","Orbitron")
	ui.OpsClock.OnEvent("Click",ChangeClockMode)
	ui.OpsClock.OnEvent("ContextMenu",ShowClockMenu)
	ui.OpsClock.ToolTip := "Left Click Starts/Stops Timer. `nRight Click Resets Timer. `nDouble-Click to Return to Time Mode."
	

	ui.RefreshWindowHandlesButton := ui.MainGui.AddPicture("x+1 ys section w28 h28 Background" cfg.ThemeFont1Color, "./Img/button_refresh.png")	
	ui.RefreshWindowHandlesButton.OnEvent("Click",RefreshWinHwnd)
	ui.RefreshWindowHandlesButton.ToolTip := "If enabled,  `"Current Game`" will automatically set`n itself to top entry in the Games List that is currently running."
	
	ui.GameAddButton := ui.MainGui.AddPicture("ys w30 h26 section Background" cfg.ThemeButtonReadyColor,"./Img/button_plus_ready.png")
	ui.GameAddButton.OnEvent("Click",AddGame)
	ui.GameAddButton.ToolTip := "Add New Game to List"
	
	ui.GameRemoveButton	:= ui.MainGui.AddPicture("ys w29 h26 Background" cfg.ThemeButtonReadyColor,"./Img/button_minus_ready.png")
	ui.GameRemoveButton.OnEvent("Click",RemoveGame)
	ui.GameRemoveButton.ToolTip := "Remove Selected Game from List"

	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri Thin")
	
	ui.GameDDL := ui.MainGui.AddDropDownList("x+2 ys w140 Background" cfg.ThemeEditboxColor " AltSubmit -E0x200 Choose" cfg.Game,cfg.GameList)
	ui.GameDDL.ToolTip := "Select the Game You Are Playing"
	ui.GameDDL.OnEvent("Change",ChangeGameDDL)
	ui.MainGuiTabs.Focus()
	


	ui.MainGui.SetFont("s10 c" cfg.ThemeFont1Color,"Calibri")	
	ui.GameWindowsListBox := ui.MainGui.AddListBox("x5 y+1 w355 r10 section Background" cfg.ThemeConsoleBgColor " -E0x200 multi",cfg.GameWindowsList)
	ui.GameWindowsListBox.ToolTip := "List of available game windows in session"
	

	ui.MainGui.SetFont("s15 c" cfg.ThemeFont1Color,"Calibri")
<<<<<<< HEAD
	ui.Win1Hwnd := ui.MainGui.AddText("ys+26 x+5 section Right w102 h30 Background" cfg.ThemeDisabledColor,"")
=======
	ui.Win1Hwnd := ui.MainGui.AddText("ys+60 x+5 section Right w102 h30 Background" cfg.ThemeDisabledColor,"")
>>>>>>> 6369ce33ca03d30e8dec681be47725668dede52c
	ui.Win1HwndPadding := ui.MainGui.AddText("ys+0 x+0 section w5 h30 Background" cfg.ThemeDisabledColor,"")
	ui.Win1Hwnd.Text := ""
	ui.Win1Hwnd.ToolTip := "Window ID for Game Window 1"	

	ui.Game1StatusIcon := ui.MainGui.AddPicture("x+0 ys-2 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_ready.png")
	ui.Game1StatusIcon.OnEvent("Click",ToggleGame1Status)
	ui.Game1StatusIcon.ToolTip := "Toggle to have this window ignored by nControl"
	
	ui.MainGui.SetFont("s15 c" cfg.ThemeFont1Color,"Calibri")
	ui.Win2Hwnd := ui.MainGui.AddText("xs-100 y+2 section Right w100 h30 Background" cfg.ThemeDisabledColor,"")
	ui.Win2HwndPadding := ui.MainGui.AddText("x+0 ys+0 section w5 h28 Background" cfg.ThemeDisabledColor,"")
	ui.Win2Hwnd.Text := ""
	ui.Win2Hwnd.ToolTip := "Window ID for Game Window 2"

	ui.Game2StatusIcon := ui.MainGui.AddPicture("x+0 ys-1 section w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_ready.png")
	ui.Game2StatusIcon.OnEvent("Click",ToggleGame2Status)
	ui.Game2StatusIcon.ToolTip := "Toggle to have this window ignored by nControl"


<<<<<<< HEAD
	ui.ButtonHelp := ui.MainGui.AddPicture("xs-108 y+1 w138 h32 section Background" cfg.ThemeButtonAlertColor,"./Img/button_help.png")
	ui.ButtonHelp.OnEvent("Click",LaunchHelp)
	ui.ButtonDebug := ui.MainGui.AddPicture("xs y+1 w138 h32 section Background" cfg.ThemeButtonReadyColor,"./Img/button_viewlog_up.png")
=======
	
	ui.ButtonDebug := ui.MainGui.AddPicture("xs-107 y+0 w138 h32 section Background" cfg.ThemeButtonReadyColor,"./Img/button_viewlog_down.png")
>>>>>>> 6369ce33ca03d30e8dec681be47725668dede52c
	ui.ButtonDebug.OnEvent("Click",ToggleDebug)	

	
	; ui.MainGui.SetFont("s14 c" cfg.ThemeFont1Color,"Calibri Thin")
	; ui.MainGui.AddText("x+10 ys+2","View Log")
	
<<<<<<< HEAD
=======
	drawOutlineMainGui(0,32,501,30,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar Outline
	;drawOutlineMainGui(0,58, 360,153,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Ops GameWindowBox Outline
	drawOutlineMainGui(118,33,154,29,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)	;Ops Clock Outline
	drawOutlineMainGui(363,120,140,62,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)	;Ops Window Status Icons Outline
	drawOutlineMainGui(363,150,140,2,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Ops Window Handle Divider Outline
	drawOutlineMainGui(360,180,143,34,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)	;Ops Log Viewer Button Outline

>>>>>>> 6369ce33ca03d30e8dec681be47725668dede52c
	ui.GameDDL.Choose(1)

	ui.ClockMode := "Clock"
	ui.ClockTime := FormatTime(,"hh:mm:ss") " "
	ui.TimerTime := FormatTime(20000101240000,"hh:mm:ss")
	ui.TimerState := "Stopped"
	ui.StartTime := 0	
	ui.StopwatchTime := "00:00 "
	ui.StopwatchState := "Stopped"
	
<<<<<<< HEAD
	ui.buttonSwapHwnd := ui.MainGui.AddPicture("x364 y89 w19 h57 BackgroundTrans","./Img/button_swapHwnd_disabled.png")
=======
	ui.buttonSwapHwnd := ui.MainGui.AddPicture("x364 y123 w19 h56 BackgroundTrans","./Img/button_swapHwnd_disabled.png")
>>>>>>> 6369ce33ca03d30e8dec681be47725668dede52c
	ui.buttonSwapHwnd.OnEvent("Click",ToggleHwndSwap)
	ui.buttonSwapHwnd.ToolTip := "Swap Windows"



}

ToggleDebug(*)
{
	(cfg.consoleEnabled := !cfg.consoleEnabled) ? ConsoleShow() : ConsoleHide()
}
ConsoleShow() {
	ui.ButtonDebug.Value := "./Img/button_viewlog_down.png"
	ui.ButtonDebug.Opt("Background" cfg.ThemeButtonOnColor)
	ui.buttonDebug.Redraw()
	
	ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
	if (cfg.AnimationsEnabled) {
		While (GuiH < 395)
		{
			GuiH += 10
			ui.MainGui.Show("h" GuiH " NoActivate") 
			Sleep(10)
		}
	}	
	ui.MainGui.Show("h395 NoActivate")
	debugLog("Showing Log")
}
	
ConsoleHide() { 
	ui.ButtonDebug.Value := "./Img/button_viewlog_up.png"
	ui.ButtonDebug.Opt("Background" cfg.ThemeButtonReadyColor)
	ui.buttonDebug.Redraw()
	ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
	if (cfg.AnimationsEnabled) {
		While (GuiH > 214)
		{
			GuiH -= 10
			ui.MainGui.Show("h" GuiH " NoActivate")
			Sleep(10)
		}
	}
	ui.MainGui.Show("h214 NoActivate")
	debugLog("Hiding Log")
}


LaunchHelp(*) {
	ui.HelpGui := Gui()
	ui.HelpGui.BackColor := "353535"
	ui.HelpGui.Color := "353535"
	ui.HelpPng := ui.HelpGui.AddPicture("x0 y0","./Img/Help.png")
	ui.HelpGui.Show("w1000 h454")
}

ToggleHwndSwap(*)
{
	cfg.HwndSwapEnabled := !cfg.HwndSwapEnabled
	tmpGame2StatusEnabled := cfg.Game2StatusEnabled
	cfg.Game2StatusEnabled := cfg.Game1StatusEnabled
	cfg.Game1StatusEnabled := tmpGame2StatusEnabled
	RefreshWinHwnd()
}

SetTimerTime(*)
{
	MsgBox("This feature has not`nyet been implemented")
}

ViewClock(*)
{
	ui.ClockMode := "Clock"
	ui.OpsClockModeLabel.Text := "Clock"
	ui.OpsClock.Text := FormatTime(,"hh:mm:ss") " "
}

ViewStopwatch(*)
{
	ui.ClockMode := "Stopwatch"
	ui.OpsClockModeLabel.Text := "Stop`nWatch"
	ui.OpsClock.Text := ui.StopwatchTime " "
}

ViewTimer(*)
{
	ui.ClockMode := "Timer"
	ui.OpsClockModeLabel.Text := "Timer"
	ui.OpsClock.Text := "Timer N/A"
}

ShowClockMenu(*)
{
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

ChangeClockMode(*)
{
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

SetTimer(OpsClickTimeUpdate,1000)

OpsClickTimeUpdate(*)
{
	ui.ClockTime := FormatTime("T12","Time")
	if (ui.ClockMode == "Clock")
		ui.OpsClock.Value := ui.ClockTime " "
}

StopwatchToggle(*)
{
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

StopwatchStart(*)
{
	ui.StartTime := A_NowUTC
	SetTimer(StopwatchTimer,1000)
}

StopwatchStop(*)
{
	SetTimer(StopwatchTimer,0)
}

StopwatchReset(*)
{
	ui.OpsClock.Value := FormatTime(0,"hh:mm:ss") " "
}

StopwatchTimer(*)
{
	Global
	SecondsElapsed := DateDiff(A_NowUTC,ui.StartTime,"Seconds")
	ui.StopwatchTime := Format("{:02}:{:02}", SecondsElapsed//60, Mod(SecondsElapsed,60))
	if (ui.ClockMode == "Stopwatch")
	{
		ui.OpsClock.Text := ui.StopwatchTime " "
	}
}

ToggleGame1Status(*)
{
	cfg.Game1StatusEnabled := !cfg.Game1StatusEnabled 
	RefreshWinHwnd()
}	
		
		
		
ToggleGame2Status(*)
{
	cfg.Game2StatusEnabled := !cfg.Game2StatusEnabled
	RefreshWinHwnd()
}	
		
		
ChangeGameDDL(*)
{
	debugLog("Game Profile Changed to: " ui.GameDDL.Text)
	If !(WinExist("ahk_id " ui.Win1Hwnd.Text) || WinExist("ahk_id " ui.Win2Hwnd.Text))
		RefreshWinHwnd()
}

RefreshWinHwnd(*)
{
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
		
		ui.Win%WinNumber%Hwnd.Text := ui.FilteredGameWindowsList[A_Index]
		ui.GameWindowsListBox.Add([((WinNumber == 1) ? "[Left]" : "[Right]") "[" ui.Win%WinNumber%Hwnd.Text "][" WinGetTitle("ahk_id " ui.Win%WinNumber%Hwnd.Text) "][" WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd.Text) "]"])

		if (cfg.Game%WinNumber%StatusEnabled)
		{
			ui.Game%WinNumber%StatusIcon.Value := "./Img/button_ready.png"
			ui.Game%WinNumber%StatusIcon.Opt("Background" cfg.ThemeButtonOnColor)
			ui.Win%WinNumber%HwndPadding.Opt("Background" cfg.ThemeConsoleBgColor)
			ui.Win%WinNumber%Hwnd.Opt("-Disabled Background" cfg.ThemeConsoleBgColor)
			ui.Win%WinNumber%ClassDDL.Opt("-Disabled")
			;ui.Game%WinNumber%StatusIcon.ToolTip := ((WinNumber == 1) ? "[Left]" : "[Right]") " [" WinGetTitle("ahk_id " ui.Win%WinNumber%Hwnd.Text) "] [" ui.Win%WinNumber%Hwnd.Text "] [" WinGetProcessName("ahk_id " ui.Win%WinNumber%Hwnd.Text) "]"


		} else {
			ui.Game%WinNumber%StatusIcon.Value := "./Img/button_ready.png"
			ui.Game%WinNumber%StatusIcon.Opt("Background" cfg.ThemeButtonReadyColor)
<<<<<<< HEAD
			ui.Win%WinNumber%HwndPadding.Opt("+Disabled Background" cfg.ThemeDisabledColor)
=======
			ui.Win%WinNumber%HwndPadding.Opt("Background" cfg.ThemeDisabledColor)
>>>>>>> 6369ce33ca03d30e8dec681be47725668dede52c
			ui.Win%WinNumber%Hwnd.Opt("+Disabled Background" cfg.ThemeDisabledColor)
			ui.Win%WinNumber%ClassDDL.Opt("+Disabled")	
		}
		ui.Game%WinNumber%StatusIcon.Redraw()
		ui.Win%WinNumber%HwndPadding.Redraw()
		ui.Win%WinNumber%Hwnd.Redraw()
	}
	ui.buttonSwapHwnd.Value := cfg.HwndSwapEnabled ? "./Img/button_swapHwnd_enabled.png" : "./Img/button_swapHwnd_disabled.png"
	ui.buttonSwapHwnd.Redraw()
	ui.MainGuiTabs.UseTab("Sys")
<<<<<<< HEAD

	drawOutlineMainGui(382,116,143,2,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Ops Window Handle Divider Outline
	drawOutlineMainGui(361,147,143,34,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)	;Ops Log Viewer Button Outline
	drawOutlineMainGui(361,178,143,34,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)	;Ops Log Viewer Button Outline	
	drawOutlineMainGui(361,86,143,63,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)	;Ops Window Status Icons Outline
	drawOutlineMainGui(4,63,359,151,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)
	drawOutlineMainGui(0,32,501,30,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar Outline
	;drawOutlineMainGui(0,58, 360,153,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Ops GameWindowBox Outline
	drawOutlineMainGui(118,33,154,29,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)	;Ops Clock Outline

	;Ops GameWindowBox Outline	
=======
	drawOutlineMainGui(4,63,358,151,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)		;Ops GameWindowBox Outline	
>>>>>>> 6369ce33ca03d30e8dec681be47725668dede52c
}

AddGame(*)
{
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
	drawOutlineNewGameGui(5,5,250,100,cfg.ThemeBorderLightColor,cfg.ThemeBorderDarkColor,2)
}

AddGameProfile(*)
{
	Global
	cfg.GameList.Push(cfg.NewGameEdit.Value)
	currentGame := cfg.Game
	ui.GameDDL.Delete()
	ui.GameDDL.Add(cfg.GameList)
	ui.GameDDL.Choose(1)
	ui.NewGameGui.Destroy()
}

RemoveGame(*)
{
	Global
	cfg.GameList.RemoveAt(cfg.Game)
	ui.GameDDL.Delete()
	ui.GameDDL.Add(cfg.GameList)
	MsgBox(cfg.Game)
	ui.GameDDL.Choose(1)
}

		

	