#SingleInstance
#Warn All, Off

if !(StrCompare(A_LineFile,A_ScriptFullPath))
{
	InstallDir 		:= IniRead("./nControl.ini","System","InstallDir",A_MyDocuments "\nControl")
	MainScriptName 	:= IniRead("./nControl.ini","System","MainScriptName","nControl")
	;MsgBox(A_LineFile " doesn't match " A_ScriptFullPath ": running main code")
	Run(A_ScriptDir "/../" MainScriptName ".ahk")
	ExitApp
}

GuiDockTab(&ui)
{
	ui.MainGuiTabs.UseTab("Dock")
	
	ui.SetMonitorButton := ui.MainGui.AddPicture("x20 y40 w60 h20 section","./Img/Button_Change.png")
	ui.SetMonitorButton.OnEvent("Click", SetMonitorButtonPush)
	ui.SetMonitorButton.ToolTip := "Selects secondary monitor to display docked apps while gaming"
	
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont2Color,"Calibri")
	cfg.nControlMonitorLabel := ui.MainGui.AddText("ys-2 w35 Center","Monitor")
	cfg.nControlMonitorLabel.OnEvent("Click", SetMonitorButtonPush)
	cfg.nControlMonitorLabel.ToolTip := "Selects secondary monitor to display docked apps while gaming"
	
	ui.nControlMonitorText := ui.MainGui.AddText("x+8 ys w30 Center background" cfg.ThemeEditboxColor " c" cfg.ThemeFont1Color, cfg.nControlMonitor)
	ui.nControlMonitorText.OnEvent("Click", SetMonitorButtonPush)
	ui.nControlMonitorText.ToolTip := "Monitor currently selected to display docked apps while gaming"
	
	drawOutlineMainGui(150,39,30,25,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont2Color, "Calibri Bold")
	ui.nControlMonitorUpdatedText := ui.MainGui.AddText("ys+2 w130","")
	
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont2Color,"Calibri Bold")
	ui.SetDockFileButton := ui.MainGui.AddPicture("x20 y90 w60 h20 section", "./Img/Button_Select.png")
	ui.SetDockFileButton.OnEvent("Click", app2browse)
	ui.SetDockFileButton.ToolTip := "Assigns app to dock above taskbar"
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont2Color,"Calibri")
	ui.MainGui.AddText("ys-2","Dock App")
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color, "Calibri")
	ui.app2filename := ui.MainGui.AddText("x152 ys+0 w195 h20 Background" cfg.ThemeEditboxColor,"")
	drawOutlineMainGui(150,87,200,25,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont2Color,"Calibri")
	ui.MainGui.AddText("xs+3 y+5 w100 section","Path")
	ui.MainGui.SetFont("s10 c" cfg.ThemeFont1Color, "Calibri")
	ui.app2path := ui.MainGui.AddText("x59 ys+1 w288 h20 Background" cfg.ThemeEditboxColor,"")
	drawOutlineMainGui(57,115,293,25,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)

	ui.MainGui.SetFont("s14 c" cfg.ThemeFont2Color,"Calibri")
	ui.SetWorkFileButton := ui.MainGui.AddPicture("x20 y+5 w60 h20 section", "./Img/Button_Select.png")
	ui.SetWorkFileButton.OnEvent("Click", app1browse)
	ui.SetWorkFileButton.ToolTip := "Assigns app to fill remainder of screen"
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont2Color,"Calibri")
	ui.MainGui.AddText("ys-2","Dock App")
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color, "Calibri")
	ui.app1filename := ui.MainGui.AddText("x152 ys+0 w195 h20 Background" cfg.ThemeEditboxColor,"")
	drawOutlineMainGui(150,143,200,25,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont2Color,"Calibri")
	ui.MainGui.AddText("xs+3 y+5 w100 section","Path")
	ui.MainGui.SetFont("s10 c" cfg.ThemeFont1Color, "Calibri")
	ui.app1path := ui.MainGui.AddText("x59 ys+1 w288 h20 Background" cfg.ThemeEditboxColor,"")
	drawOutlineMainGui(57,170,293,25,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)
	; ui.button_app1select := ui.MainGui.AddPicture("ys w60 h25","./Img/button_select.png")
	; ui.button_app1select.OnEvent("Click",app1browse)
	; ui.button_app1select.ToolTip := "Browse for file"
	
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri")
	TextDockApps := ui.MainGui.AddText("x350 y40 w100 Right section","GameDash  ")
	

	ui.ButtonDockApps := ui.MainGui.AddPicture("ys-2 w30 h30","./Img/button_ready.png")
	ui.ButtonDockApps.OnEvent("Click",DockApps)

	ui.MainGui.AddText("xs y+3 section w100 Right","Pin App1  ")
	ui.PinDockButton := ui.MainGui.AddPicture("ys-3 w30 h30","./Img/button_ready.png")
	ui.PinDockButton.OnEvent("Click",TogglePinDockApp)
	
	ui.MainGui.AddText("xs y+4 section w100 Right","Pin App2  ")
	ui.PinWorkAppButton := ui.MainGui.AddPicture("ys-4 w30 h30","")
	ui.PinWorkAppButton.OnEvent("Click",TogglePinWorkApp)
	ui.PinWorkAppButton.Value := "./Img/button_ready.png"
	 
	ui.app1filename.text := cfg.app1filename
	ui.app2filename.text := cfg.app2filename
	ui.app1path.text := cfg.app1path
	ui.app2path.text := cfg.app2path

}


app1browse(*)
{
	SelectedFile := FileSelect()
	SplitPath(SelectedFile,&selectedFilename,&selectedPath,&selectedExt,&selectedName,&selectedDrive)
	cfg.app1filename := selectedFilename
	cfg.app1path := selectedPath
	ui.app1filename.text := selectedFilename
	ui.app1path.text := selectedPath
	ui.app1filename.Redraw()
	ui.app1path.Redraw()

}

app2browse(*)
{
	SelectedFile := FileSelect()
	SplitPath(SelectedFile,&selectedFilename,&selectedPath,&selectedExt,&selectedName,&selectedDrive)
	cfg.app2filename := selectedFilename
	cfg.app2path := selectedPath
	ui.app2filename.text := selectedFilename
	ui.app2path.text := selectedPath
	ui.app2filename.Redraw()
	ui.app2path.Redraw()

}

ChooseApp1(*)
{
	ChooseApp("1")
}

ChooseApp2(*)
{
	ChooseApp("2")
}

ChooseApp(AppNumber)
{
	Global
	Thread "NoTimers"
	DialogBox("Click anywhere in the window`nthat you would like to select.")
	Sleep(750)
	appSelected := KeyWait("LButton", "D T15")
	if (appSelected = 0)
	{	
		ui.MainGui.Opt("-AlwaysOnTop")
		DialogBoxClose()
		MsgBox("An App was not selected in time.`nPlease try again.")
		Return 0
	} else {
		SelectedFile := WinGetProcessPath("A")
		DialogBoxClose()
	}
	Thread "NoTimers", false	
	SplitPath(SelectedFile,&selectedFilename,&selectedPath,&selectedExt,&selectedName,&selectedDrive)
	cfg.app%AppNumber%filename := selectedFilename
	cfg.app%AppNumber%path := selectedPath
	ui.app%AppNumber%filename.text := selectedFilename
	ui.app%AppNumber%path.text := selectedPath
	ui.app%AppNumber%filename.Redraw()
	ui.app%AppNumber%path.Redraw()
	IniWrite(cfg.app%AppNumber%filename,cfg.file,"nControl","app" AppNumber "filename")
	IniWrite(cfg.app%AppNumber%path,cfg.file,"nControl","app" AppNumber "path")
	debugLog("GameDash App #" AppNumber " Updated to " cfg.app%AppNumber%filename)
}

TogglePinDockApp(*)
{
	MsgBoxResult := ""
	if !WinExist("ahk_exe" ui.app2filename.text)
	{
		MsgBoxResult := MsgBox(ui.app2filename.text " not running.`nWould you like to start it now?",,"Y/N T10")
		Switch MsgBoxResult
		{
			case "Timeout": NotifyOSD("No answer received, cancelling request to pin Work App",3000)
			case "N": Return
			case "Y": StartDockApp(&DockApp)
			default: Return
		}
	} else {
		WinSetAlwaysOnTop(-1,"ahk_exe " ui.app2filename.text)
		if (WinGetExStyle("ahk_exe" ui.app2filename.text) & 0x8)
		{
			ui.PinDockAppButton.Value := "./Img/button_on.png"
		} else {
			ui.PinDockAppButton.Value := "./Img/button_ready.png"
		}
	}
}	

TogglePinWorkApp(*)
{
	Global
	MsgBoxResult := ""
	if !WinExist("ahk_exe" cfg.app1filename)
	{
		MsgBoxResult := MsgBox(cfg.filename " not running.`nWould you like to start it now?",,"Y/N T10")
		Switch MsgBoxResult
		{
			case "Timeout": NotifyOSD("No answer received, cancelling request to pin Work App",3000)
			case "N": Return
			case "Y": StartWorkApp(&WorkApp)
			default: Return
		}
	} else {
		WinSetAlwaysOnTop(-1,"ahk_exe " ui.app1filename.text)
		if (WinGetExStyle("ahk_exe" ui.app1filename.text) & 0x8)
		{
			ui.PinWorkAppButton.Value := "./Img/button_on.png"
		} else {
			ui.PinWorkAppButton.Value := "./Img/button_ready.png"
		}
	}
}	



SetMonitorButtonPush(*)
{
	SetnControlMonitor()
}

SetnControlMonitor()
{
	Global
	DialogBox("Click anywhere on the screen to which you'd like your apps docked.")
	Sleep(750)
	MonitorSelectStatus := KeyWait("LButton", "D T15")
	CoordMode("Mouse","Screen")
	MouseGetPos(&MouseX,&MouseY)

	if (MonitorSelectStatus = 0)
	{	
		MsgBox("A monitor was not selected in time.`nPlease try again.")
		DialogBoxClose()
	} else {
	
		Loop MonitorGetCount()
		{
			MonitorGet(A_Index, &Left, &Top, &Right, &Bottom)
			if (MouseX > Left) and (MouseX < Right) and (MouseY > Top) and (MouseY < Bottom)
			{
				cfg.nControlMonitor := A_Index
				IniWrite(cfg.nControlMonitor, cfg.file, "nControl", "cfg.nControlMonitor")
				ui.nControlMonitorText.Text := cfg.nControlMonitor
				ui.nControlMonitorUpdatedText.Text := "UPDATED"
				ToolTip("")
				TrayTip("Monitor[" cfg.nControlMonitor "] is now your nControl display","nControl Settings","Mute")
				SetTimer(RemoveNotice,-2500)
				DialogBoxClose()
				Return 0
			}
		}
	
	}
Return 0
}

RemoveNotice()
{
	ui.nControlMonitorUpdatedText.Text := ""
}

nControl(Status,&cfg)
{
	hwndActiveWin := WinActive("A")

	if (cfg.nControlMonitor > MonitorGetCount())
	{
		SetnControlMonitor()
	}

	MonitorGetWorkArea(cfg.nControlMonitor, &Left, &Top, &Right, &Bottom)
	WorkAreaHeightWhenDocked :=  (Bottom - Top - cfg.DockHeight)
	
	CoordMode("Mouse","Screen")
	MouseGetPos(&mX,&mY)
	
	debugLog("Current nControl Monitor: " cfg.nControlMonitor)


	If (Status == "On")
	{
		debugLog("Docking Apps")
		
		DockX := Left - cfg.DockMarginSize
		DockY := Top + WorkAreaHeightWhenDocked - cfg.DockMarginSize
		DockW := Right - Left + (cfg.DockMarginSize * 2)
		DockH := cfg.DockHeight + (cfg.DockMarginSize * 2)
		debugLog("DockApp Pos: x" DockX " y" DockY " w" DockW " h" DockH)
		;MsgBox("about to move")
		;MsgBox("finished move")
		
		
		
		WorkAreaX := Left
		WorkAreaY := Top
		WorkAreaW := Right - Left
		WorkAreaH := WorkAreaHeightWhenDocked

		
		StartNonRunningApps()
		
		;WinWait("ahk_exe " cfg.app2filename)
		WinSetStyle("-0xC00000","ahk_exe " ui.app2filename.text)
		WinSetTransColor("0x000002", "ahk_exe " ui.app2filename.text)
		WinSetAlwaysOnTop(1, "ahk_exe " ui.app2filename.text)
		WinMove(dockX,dockY,dockW,dockH,"ahk_exe " ui.app2filename.text)
	
		;WinWait("ahk_exe " cfg.app1filename)
		 If (WinGetMinMax("ahk_exe " ui.app1filename.text) = 1) or (WinGetMinMax("ahk_exe " ui.app1filename.text) = -1)
		 {
			 WinRestore("ahk_exe " ui.app1filename.text)
			 Sleep(500)

		 }
		WinMove(WorkAreaX,WorkAreaY,WorkAreaW,WorkAreaH, "ahk_exe " ui.app1filename.text)

		If (WinGetMinMax("ahk_exe " ui.app2filename.text) = 1 or WinGetMinMax("ahk_exe " ui.app2filename.text) = -1)
		{
			WinRestore("ahk_exe " ui.app2filename.text)
			Sleep(500)
		}
		
		WinActivate("ahk_exe " ui.app2filename.text)
		SetWinDelay(150)

		Send "^+{PgDn}"
		WinRedraw("ahk_exe " ui.app2filename.text)
		WinMove(DockX,DockY-4,DockW,DockH+4, "ahk_exe " ui.app2filename.text)
	} else {
		debugLog("Undocking Apps")
		DockX := Left
		DockY := Top
		DockW := 1600
		DockH := 1000
		If WinExist("ahk_exe " ui.app2filename.text)
		{
			WinMove(3500,250,1200,600,"ahk_exe " ui.app2filename.text)
			ui.app2hwnd := WinWait("ahk_exe " ui.app2filename.text)
		
			If (WinGetMinMax() = 1 or WinGetMinMax() = -1)
			{
				WinRestore("ahk_exe " ui.app2filename.text)
				Sleep(500)
			}

			WinMove(DockX,DockY,DockW,DockH)
			WinSetStyle("+0xC00000")
			WinSetTransColor("0x000001")
			WinSetAlwaysOnTop(0)
			WinRedraw("ahk_exe " ui.app2filename.text)
		}
		
		if (WinExist("ahk_exe " ui.app1filename.text))
		{
			WorkAreaX := Left
			WorkAreaY := Top
			WorkAreaW := 1600
			WorkAreaH := 1000

			ui.app1hwnd := WinWait("ahk_exe " ui.app1filename.text)
			If (WinGetMinMax() = 1 or WinGetMinMax() = -1)
				WinRestore("ahk_exe " ui.app1filename.text)
		
			WinMove(WorkAreaX,WorkAreaY,WorkAreaW,WorkAreaH)
		}
	}

	if (hwndActiveWin)
	{
		WinActivate("ahk_id " hwndActiveWin)
		MouseMove(mX,mY)
	}
	Return 0
}


StartNonRunningApps()
{
	StartWorkApp()
	Sleep(1500)
	StartDockApp()
}

StartWorkApp(*) {
	StartApp(1)
}

StartDockApp(*) {
	StartApp(2)
}


StartApp(AppNumber)
{
	If !(WinExist("ahk_exe " ui.app%AppNumber%filename.text))
	{
		DetectHiddenWindows(1)
		SetTitleMatchMode(2)
		
		Try {
			Run(ui.app%AppNumber%path.text "\" ui.app%AppNumber%filename.text)
		} Catch {
			NotifyOSD("Couldn't start " ui.app%AppNumber%filename.text)
			; debugLog("Couldn't start " ui.app%AppNumber%filename.text)
			Return 1
		}
		
		Loop 3
		{
			if (WinWait("ahk_exe " ui.app%AppNumber%filename.text,,30))
			{
				NotifyOSD("Successfuly started " ui.app%AppNumber%filename.text)
				; debugLog("Successfully Started " ui.app%AppNumber%filename.text)
				Return 0
			} else {
				NotifyOSD("Retrying " ui.app%AppNumber%filename.text " `nand waiting an additional 30 seconds to start.`nAttempt " A_Index " of 3")
				; debugLog("Retrying " ui.app%AppNumber%filename.text " `nand waiting an additional 30 seconds to start. `nAttempt " A_Index " of 3")
				Run(ui.app2path.text "\" ui.app%AppNumber%filename.text)
			}
		}
		
		NotifyOSD("Couldn't start " ui.app%AppNumber%filename.text)
		; debugLog("Couldn't start " ui.app%AppNumber%filename.text)
		Return 1
	}

}