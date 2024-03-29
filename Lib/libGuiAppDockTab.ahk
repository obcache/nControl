#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}
	

if !(StrCompare(A_LineFile,A_ScriptFullPath))
{
	InstallDir 		:= IniRead("./nControl.ini","System","InstallDir",A_MyDocuments "\nControl")
	MainScriptName 	:= IniRead("./nControl.ini","System","MainScriptName","nControl")
	Run(A_ScriptDir "/../" MainScriptName ".ahk")
	ExitApp
}

GuiDockTab(&ui)
{
	ui.MainGuiTabs.UseTab("AppDock")
	ui.appDockTopPanel := ui.mainGui.addText("x41 y35 w385 h33 background" cfg.themePanel4color,"")
	ui.appDockBottomPanel := ui.mainGui.addText("x41 y75 w385 h124 background" cfg.themePanel4color,"")
	ui.appDockRightPanel := ui.mainGui.addText("x434 y35 w93 h166 background" cfg.themePanel4Color,"")
	
	drawOutlineNamed("appDockTopPanel",ui.mainGui,39,35,389,35,cfg.themeBorderLightColor,cfg.themeBorderDarkColor,1)

	drawOutlineNamed("appDockRightPanel",ui.mainGui,433,35,93,166,cfg.themeBorderLightColor,cfg.themeBorderDarkColor,1)
	drawOutlineNamed("appDockBottomPanel",ui.mainGui,39,75,389,126,cfg.themeBorderLightColor,cfg.themeBorderDarkColor,1)
	ui.MainGui.SetFont("s16 c" cfg.ThemeFont1Color,"Calibri")
	ui.SetMonitorButton := ui.MainGui.AddPicture("x45 y36 w80 h32 section backgroundTrans backgroundTrans","./Img/Button_Change.png")
	ui.SetMonitorButton.OnEvent("Click", SetMonitorButtonPush)
	ui.SetMonitorButton.ToolTip := "Selects secondary monitor to display docked apps while gaming"
	
	ui.MainGui.SetFont("s16 c" cfg.ThemeFont1Color,"Calibri Bold")
	cfg.nControlMonitorLabel := ui.MainGui.AddText("x+3 ys+2 w35 Center backgroundTrans","Monitor")
	cfg.nControlMonitorLabel.OnEvent("Click", SetMonitorButtonPush)
	cfg.nControlMonitorLabel.ToolTip := "Selects secondary monitor to display docked apps while gaming"
	
	ui.nControlMonitorText := ui.MainGui.AddText("x+8 ys+4 w31 h24 Center background" cfg.ThemeEditboxColor " c" cfg.ThemeFont1Color, cfg.nControlMonitor)
	ui.nControlMonitorText.OnEvent("Click", SetMonitorButtonPush)
	ui.nControlMonitorText.ToolTip := "Monitor currently selected to display docked apps while gaming"
	ui.appDockTitle := ui.mainGui.addText("x315 y38 w120 h25 backgroundTrans c" cfg.themeFont1Color,"Dock Apps")	
	drawOutlineMainGui(207,41,30,23,cfg.themePanel4Color,cfg.themeBorderDarkColor,1)
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont1Color, "Calibri Bold")
	ui.nControlMonitorUpdatedText := ui.MainGui.AddText("ys+3 w130 backgroundTrans","")
	
	ui.MainGui.SetFont("s13 c" cfg.ThemeFont1Color,"Calibri Bold")
	ui.MainGui.AddText("y84 x118 w68 h22 background" cfg.themeBackgroundColor,"  Upper")
	
	drawOutlineNamed("app1label",ui.mainGui,118,83,65,23,cfg.themeBorderLightColor,cfg.themeBorderDarkColor,1)
	ui.Setapp1Button := ui.MainGui.AddPicture("x43 y77 w82 h35 section backgroundTrans", "./Img/Button_Select.png")
	ui.Setapp1Button.OnEvent("Click", app1browse)
	ui.Setapp1Button.ToolTip := "Assigns app to dock above taskbar"
	ui.MainGui.SetFont("s13 c" cfg.ThemeFont1Color,"Calibri")
	ui.app1filename := ui.MainGui.AddText("x183 ys+7 w236 h22 Background" cfg.ThemeEditboxColor,"")
	drawOutlineMainGui(183,83,237,23,cfg.themeBorderLightColor,cfg.themeBorderDarkColor,1)
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri")
	ui.MainGui.AddText("xs+3 y+7 w100 section backgroundTrans","Path")
	ui.MainGui.SetFont("s13 c" cfg.ThemeFont1Color,"Calibri")
	ui.app1path := ui.MainGui.AddText("x84 ys w334 h22 Background" cfg.ThemeEditboxColor,"")
	drawOutlineMainGui(82,111,338,24,cfg.themeBorderLightColor,cfg.themeBorderDarkColor,1)

	ui.MainGui.SetFont("s13 c" cfg.ThemeFont1Color,"Calibri Bold")
	ui.MainGui.AddText("y141 x118 w68 h22 background" cfg.themeBackgroundColor,"  Lower")
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont1Color,"Calibri")
	drawOutlineNamed("app1label",ui.mainGui,118,140,65,23,cfg.themeBorderLightColor,cfg.themeBorderDarkColor,1)
	ui.Setapp2Button := ui.MainGui.AddPicture("x43 y134 w82 h35 section backgroundTrans backgroundTrans", "./Img/Button_Select.png")
	ui.Setapp2Button.OnEvent("Click", app2browse)
	ui.Setapp2Button.ToolTip := "Assigns app to fill remainder of screen"

	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color, "Calibri")
	ui.app2filename := ui.MainGui.AddText("x183 ys+7 w236 h22 Background" cfg.ThemeEditboxColor,"")
	drawOutlineMainGui(183,140,237,23,cfg.themeBorderLightColor,cfg.themeBorderDarkColor,1)
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri")
	ui.MainGui.AddText("xs+3 y+7 w100 section backgroundTrans backgroundTrans","Path")
	ui.app2path := ui.MainGui.AddText("x84 ys+0 w334 h22 Background" cfg.ThemeEditboxColor,"")
	drawOutlineMainGui(82,168,338,24,cfg.themeBorderLightColor,cfg.themeBorderDarkColor,1)
	; ui.button_app1select := ui.MainGui.AddPicture("ys w60 h25","./Img/button_select.png")
	; ui.button_app1select.OnEvent("Click",app1browse)
	; ui.button_app1select.ToolTip := "Browse for file"
	
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri")
	TextDockApps := ui.MainGui.AddText("x412 y40 w80 Right section backgroundTrans backgroundTrans","Dock ")
	

	ui.ButtonDockApps := ui.MainGui.AddPicture("ys+1 w30 h20 section backgroundTrans backgroundTrans","./Img/button_up.png")
	ui.ButtonDockApps.OnEvent("Click",DockApps)
	ui.MainGui.AddText("xs-60 y+3 section backgroundTrans w60 Right backgroundTrans","Titlebar ")
	ui.toggleCaption := ui.MainGui.AddPicture("ys+1 w30 h20","./Img/button_up.png")
	ui.toggleCaption.toolTip := "Enable/Disable the caption bar on any window."
	ui.toggleCaption.OnEvent("Click",toggleCaption)
	
	ui.MainGui.AddText("xs y+4 section backgroundTrans w60 Right backgroundTrans","OnTop ")
	ui.universalOnTop := ui.MainGui.AddPicture("ys+1 w30 h20","")
	ui.universalOnTop.OnEvent("Click",universalOnTop)
	ui.universalOnTop.Value := "./Img/button_up.png"
	ui.universalOnTop.toolTip := "Set any window to AlwaysOnTop"
	 
	; ui.MainGui.AddText("xs y+3 section backgroundTrans w140  Right","Snap Windows")
	; ui.snapWindows := ui.MainGui.AddPicture("ys-3 w30 h30","./Img/button_ready.png")
	; ui.snapWindows.toolTip := "Launches and Snaps Roblox Windows"
	; ui.snapWindows.OnEvent("Click",snapWindows)
	
	; ui.MainGui.AddText("xs y+4 section backgroundTrans w140	Right","Pin App2  ")
	; ui.PinWorkAppButton := ui.MainGui.AddPicture("ys-4 w30 h30","")
	; ui.PinWorkAppButton.OnEvent("Click",TogglePinWorkApp)
	; ui.PinWorkAppButton.Value := "./Img/button_ready.png"
	 
	ui.app1filename.text := " " cfg.app1filename
	ui.app2filename.text := " " cfg.app2filename
	ui.app1path.text := " " subStr(cfg.app1path,1,40)
	ui.app2path.text := " " subStr(cfg.app2path,1,40)

}

toggleCaption(*) {
	ui.toggleCaption.value := "./img/button_down.png"
	ui.toggleCaption.opt("background" cfg.themeButtonAlertColor)
	SetTimer(releaseButton1,-400)
	releaseButton1(*) {
		ui.toggleCaption.value := "./img/button_up.png"
		ui.toggleCaption.opt("background" cfg.themeButtonReadyColor)
	}
	DialogBox("Click anywhere on the window you'd like to toggle caption on.")
	Sleep(750)
	ClickStatus := KeyWait("LButton", "D T15")

	if (ClickStatus = 0)
	{	
		MsgBox("A window was not selected in time.`nPlease try again.")
		DialogBoxClose()
	} else {
		WinSetStyle("^0xC00000","A")
		DialogBoxClose()
	}
}

universalOnTop(*) {
	ui.universalOnTop.value := "./img/button_down.png"
	ui.universalOnTop.opt("background" cfg.themeButtonAlertColor)
	SetTimer(releaseButton,-400)
	releaseButton(*) {
		ui.universalOnTop.value := "./img/button_up.png"
	ui.universalOnTop.opt("background" cfg.themeButtonReadyColor)
	
	}	
	DialogBox("Click anywhere on the window you'd like to toggle AlwaysOnTop on.")
	Sleep(750)
	ClickStatus := KeyWait("LButton", "D T15")

	if (ClickStatus = 0)
	{	
		MsgBox("A window was not selected in time.`nPlease try again.")
		DialogBoxClose()
	} else {
		WinSetAlwaysOnTop(-1,"A")
		DialogBoxClose()
	}
}


	
snapWindows(*) {
	DetectHiddenWindows(true)
	setTimer(launchRobloxPlayer,-10)
	setTimer(launchRobloxApp,-10)
	
	launchRobloxPlayer() {
		if !(winExist("ahk_exe RobloxPlayerBeta.exe")) {
			runApp("Roblox Player")
		} else {
			if (WinExist("ahk_exe RobloxPlayerInstaller.exe")) {
				SetTimer(launchRobloxPlayer,-2000)
				Return
			}
		
		WinActivate("ahk_exe RobloxPlayerBeta.exe")
		}
		
		robloxPlayerHwnd := WinWait("ahk_exe RobloxPlayerBeta.exe")
		Send("#{Left}")
	
	}
	
	launchRobloxApp() {
		if !(winExist("ahk_exe ApplicationFrameHost.exe")) {
			runApp("Roblox")
		} else {
			WinActivate("ahk_exe ApplicationFrameHost.exe")
		}
		robloxAppHwnd := WinWait("ahk_exe ApplicationFrameHost.exe")
		Send("#{Right}")
	}
}

app1browse(*)
{
	SelectedFile := FileSelect()
	SplitPath(SelectedFile,&selectedFilename,&selectedPath,&selectedExt,&selectedName,&selectedDrive)
	cfg.app1filename := selectedFilename
	cfg.app1path := selectedPath
	ui.app1filename.text := " " selectedFilename
	ui.app1path.text := " " selectedPath
	ui.app1filename.Redraw()
	ui.app1path.Redraw()

}

app2browse(*)
{
	SelectedFile := FileSelect()
	SplitPath(SelectedFile,&selectedFilename,&selectedPath,&selectedExt,&selectedName,&selectedDrive)
	cfg.app2filename := selectedFilename
	cfg.app2path := selectedPath
	ui.app2filename.text := " " selectedFilename
	ui.app2path.text := " " selectedPath
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
				; ui.nControlMonitorText.Text := cfg.nControlMonitor
				; ui.nControlMonitorUpdatedText.Text := "UPDATED"
				ToolTip("")
				TrayTip("Monitor[" cfg.nControlMonitor "] is now your nControl display","nControl Settings","Mute")
				; SetTimer(RemoveNotice,-2500)
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
dockApps(*) {
	global
	try {
		ui.dockApp_enabled := !ui.dockApp_enabled
	} catch {
		ui.dockApp_enabled := true
	}
	
	if (ui.dockApp_enabled)
	{
		ui.ButtonDockApps.Value := "./Img/button_down.png"
		SetTimer(UnpushButton,-500)
		ui.buttonDockApps.Opt("Background" cfg.ThemeButtonOnColor)
		nControl("On",&cfg)
	} else {
		ui.ButtonDockApps.Value := "./Img/button_down.png"
		SetTimer(UnpushButton,-500)
		ui.buttonDockApps.Opt("Background" cfg.ThemeButtonAlertColor)
		nControl("Off",&cfg)
	}
	
	UnpushButton(*) {
		ui.buttonDockApps.Value := "./Img/button_up.png"
		ui.buttonDockApps.Opt("Background" cfg.ThemeButtonReadyColor)
	}
}

drawDivider(DockY) { 
	MonitorGetWorkArea(cfg.nControlMonitor, &Left, &Top, &Right, &Bottom)
	WorkAreaHeightWhenDocked :=  (Bottom - Top - cfg.DockHeight)
	ui.dividerGui.opt("-caption +alwaysOnTop +ToolWindow +0x4000000")
	ui.dividerGui.backColor := cfg.themeBright1Color
	ui.dividerGui.show("x" Left " y" DockY-8 " w" Right-Left " h12 NoActivate")
	winSetTransparent(255,ui.dividerGui)
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
		DockW := Right - Left + ((cfg.DockMarginSize-1) * 2)
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
		WinMove(WorkAreaX,WorkAreaY,WorkAreaW,WorkAreaH-8, "ahk_exe " ui.app1filename.text)

		If (WinGetMinMax("ahk_exe " ui.app2filename.text) = 1 or WinGetMinMax("ahk_exe " ui.app2filename.text) = -1)
		{
			WinRestore("ahk_exe " ui.app2filename.text)
			Sleep(500)
		}
		
		WinActivate("ahk_exe " ui.app2filename.text)
		SetWinDelay(150)


		;Send "^+{PgDn}"
		WinRedraw("ahk_exe " ui.app2filename.text)
		WinMove(DockX,DockY-4,DockW,DockH+4, "ahk_exe " ui.app2filename.text)
		; drawDivider(DockY)
	} else {
		debugLog("Undocking Apps")
		ui.dividerGui.hide()
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