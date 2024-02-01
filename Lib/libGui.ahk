#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}

initGui(&cfg, &ui) {
	ui.TransparentColor := "010203"
	ui.MainGui := Gui()
	ui.MainGui.Name := "nControl"
	ui.TaskbarHeight := GetTaskBarHeight()
	ui.MainGui.BackColor := ui.TransparentColor
	ui.MainGui.Color := ui.TransparentColor
	ui.MainGui.Opt("-Caption -Border")
	if (cfg.AlwaysOnTopEnabled)
	{
		ui.MainGui.Opt("+AlwaysOnTop 0x4000000")
	}

	ui.titleBarButtonGui := Gui()
	ui.titleBarButtonGui.Opt("-Caption -Border AlwaysOnTop Owner" ui.MainGui.Hwnd)
	ui.titleBarButtonGui.BackColor := ui.TransparentColor
	ui.titleBarButtonGui.Color := ui.TransparentColor
	ui.DownButton := ui.titleBarButtonGui.AddPicture("x451 y0 w35 h35 section Background" cfg.ThemeFont1Color,"./Img/button_minimize.png")
	ui.DownButton.OnEvent("Click",HideGui)
	ui.DownButton.ToolTip := "Minimizes nControl App"
	
	ui.ExitButton 	:= ui.titleBarButtonGui.AddPicture("x+5 ys section w35 h35 Background" cfg.ThemeFont1Color,"./Img/button_power_ready.png")
	ui.ExitButton.OnEvent("Click",ExitButtonPushed)
	ui.ExitButton.ToolTip := "Terminates nControl App"

	ui.buttonUndockAfk := ui.titleBarButtonGui.AddPicture("x+6 ys w35 h35 hidden Background" cfg.ThemeButtonAlertColor,"./Img/button_dockright_ready.png")
	ui.buttonUndockAfk.OnEvent("Click",ToggleAfkDock)
	ui.buttonUndockAfk.ToolTip := "Undocks AFK Window"
	
	ui.MainGui.MarginX := 0
	ui.MainGui.MarginY := 0
	ui.MainGui.SetFont("s13 c" cfg.ThemeFont1Color,"Calibri")
	ui.MainGuiTabs := ui.MainGui.AddTab3("x35 y1 w495 h213 Buttons -Redraw Background" cfg.ThemeBackgroundColor " -E0x200", cfg.mainTabList)
	ui.MainGuiTabs.OnEvent("Change",TabsChanged)
;	ui.MainGuiTabs.Choose(cfg.mainTabList[3])
	ui.MainGuiTabs.UseTab("")
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri")
	ui.handleBarImage := ui.MainGui.AddPicture("x0 y-2 w35 h216","./Img/handlebar_vertical.png")
	ui.rightHandlebarImage := ui.titleBarButtonGui.AddPicture("x527 w35 y3 h216","./Img/handlebar_vertical.png")
	ui.rightHandlebarImage2 := ui.mainGui.AddPicture("x527 w35 y0 h216 section","./Img/handlebar_vertical.png")

	ui.handleBarImage.OnEvent("DoubleClick",ToggleGuiCollapse)
	ui.handleBarImage.OnEvent("Click",WM_LBUTTONDOWN_callback)

	ui.gvConsole := ui.MainGui.AddListBox("x35 y220 w500 h192 +Background" cfg.ThemePanel1Color)
	ui.gvConsole.Color := cfg.ThemeBright1Color	

	afk 						:= Object()
	populateClassList()
	GuiAFKTab(&ui,&afk)
	GuiOperationsTab(&ui,&cfg,&afk)	
	GuiDockTab(&ui)
	GuiSetupTab(&ui,&cfg)
	GuiAudioTab(&ui,&cfg,&audio)
	GuiGameTab(&ui,&cfg)
	
	if (FileExist("./Logs/persist.log"))
	{
		Loop Read, "./Logs/persist.log"
		{
			ui.gvConsole.Add([A_LoopReadLine])
		}
		FileDelete("./Logs/persist.log")
		}
	WinSetTransparent(0,ui.MainGui)
	WinSetTransparent(0,ui.titleBarButtonGui)
	winSetTransparent(0,ui.gameSettingsGui)
	
	ui.titleBarButtonGui.Show("x" cfg.GuiX " y" cfg.GuiY-3 " w565 h218 NoActivate")
	ui.MainGui.Show("x" cfg.GuiX " y" cfg.GuiY " w562 h214 NoActivate")

	ui.MainGuiTabs.Choose(cfg.mainTabList[cfg.activeMainTab])

	InitOSDGui()

	if (cfg.consoleVisible) {
		(cfg.consoleVisible := !cfg.consoleVisible)
		toggleConsole()
	}
	
	if (cfg.AlwaysOnTopEnabled) 
	{
		ui.MainGui.Opt("+AlwaysOnTop")
		ui.titleBarButtonGui.Opt("+AlwaysOnTop")
		ui.AfkGui.Opt("+AlwaysOnTop")
	} else {
		ui.MainGui.Opt("-AlwaysOnTop")
		ui.titleBarButtonGui.Opt("-AlwaysOnTop")
		ui.AfkGui.Opt("-AlwaysOnTop")	
	}
	
	debugLog("Interface Initialized")
	ui.MainGuiTabs.UseTab("")

	OnMessage(0x0200, WM_MOUSEMOVE)
	OnMessage(0x0201, WM_LBUTTONDOWN)
	;OnMessage(0x0202, WM_LBUTTONUP)
	OnMessage(0x47, WM_WINDOWPOSCHANGED)
}



initOSDGui() {
	Global 
	afk := Object()
	MsgString := ""
	ui.afkEnabled := false
	TimerEnabled := false
	GuiX := IniRead(cfg.file,"AFK","GuiX",A_ScreenWidth*0.3)
	GuiY := IniRead(cfg.file,"AFK","GuiY",A_ScreenHeight*0.3)
	RunCount := 0

	ui.AfkGui := Gui()
	ui.AfkGui.Name := "nControlMain"
	ui.AfkGui.BackColor := cfg.ThemeBackgroundColor
	ui.AfkGui.Color := ui.TransparentColor
	ui.AfkGui.MarginX := 5
	ui.AfkGui.Opt("-Caption -Border +AlwaysOnTop +ToolWindow +0x4000000 +Owner" ui.MainGui.Hwnd)
	ui.AfkGui.SetFont("s14 c" cfg.ThemeFont1Color,"Calibri")
	
	ui.buttonDockAfk := ui.AfkGui.AddPicture("x+-5 y2 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_dockLeft_ready.png")
	ui.buttonDockAfk.OnEvent("Click",ToggleAfkDock)
	ui.buttonDockAfk.ToolTip := "Dock AFK Panel"
	ui.buttonStartAFK := ui.AfkGui.AddPicture("x+2 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_afk_ready.png")
	ui.buttonStartAFK.OnEvent("Click",ToggleAFK)
	ui.buttonStartAFK.ToolTip := "Toggle AFK"
	
	ui.buttonTower := ui.AfkGui.AddPicture("x+2 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_tower_ready.png")
	ui.buttonTower.OnEvent("Click",ToggleTower)
	ui.buttonTower.ToolTip := "Starts Infinte Tower"
	
	ui.buttonAntiIdle1 := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
	ui.buttonAntiIdle1.OnEvent("Click",ToggleAntiIdleBoth)
	ui.buttonAntiIdle1.ToolTip := "Toggles AntiIdle Mode On/Off"
	
	ui.buttonAutoFire := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_AutoFire_ready.png")
	ui.buttonAutoFire.OnEvent("Click",toggleAutoFire)
	ui.buttonAutoFire.ToolTip := "Toggles AutoFire on Current Window"
	
	ui.buttonAutoClicker := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_AutoClicker_ready.png")
	ui.buttonAutoClicker.OnEvent("Click",ToggleAutoClicker)
	ui.buttonAutoClicker.ToolTip := "Toggles AutoClicker"

	ui.buttonAfkHide := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 hidden Background" cfg.ThemeButtonReadyColor,"./Img/button_hide.png")
	ui.buttonAfkHide.OnEvent("Click",HideAfkGui)
	ui.buttonAfkHide.ToolTip := "Minimizes AFK Window to System Tray"
	
	ui.buttonPopout := ui.AfkGui.AddPicture("x+-0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_popout_ready.png")
	ui.buttonPopout.OnEvent("Click",AfkPopoutButtonPushed)
	
	ui.Win1Label := ui.AfkGui.AddPicture("xs+5 y+6 section w35 h29","./Img/arrow_left.png")
	ui.AfkGui.SetFont("s12","Calibri")
	ui.afkWin1ClassDDL := ui.AfkGui.AddDDL("x+10 ys w125 altSubmit choose" cfg.win1class " background" cfg.ThemeEditboxColor, ui.profileList)
	ui.afkWin1ClassDDL.OnEvent("Change",afkWin1ClassChange)
	ui.AfkGui.SetFont("s14","Calibri")
	ui.Win1AfkIcon := ui.AfkGui.AddPicture("ys-2 w25 h25","./Img/sleep_icon.png")
	ui.Win1AfkStatus := ui.AfkGui.AddText("x+-1 ys+3 w35 +BackgroundTrans","")

	ui.Win2Label := ui.AfkGui.AddPicture("xs2 y+7 section w35 h29","./Img/arrow_right.png")
	ui.AfkGui.SetFont("s12","Calibri")
	ui.afkWin2ClassDDL := ui.AfkGui.AddDDL("x+8 ys-2 w125 altSubmit choose" cfg.win2class " background" cfg.ThemeEditboxColor,ui.profileList)
	ui.afkWin2ClassDDL.OnEvent("Change",afkWin2ClassChange)
	; loop ui.profileList.length {
		; if (ui.profileList[a_index] == cfg.win1class) {
			; ui.afkWin1ClassDDL.choose(a_index)
		; }
		; if (ui.profileList[a_index] == cfg.win2class) {
			; ui.afkWin2ClassDDL.choose(a_index)
		; }
	; }
	ui.AfkGui.SetFont("s14","Calibri")
	ui.Win2AfkIcon := ui.AfkGui.AddPicture("ys-2 w25 h25","./Img/sleep_icon.png")
	ui.Win2AfkStatus := ui.AfkGui.AddText("x+0 ys w35 +BackgroundTrans","")
	ui.AfkGui.SetFont("s16 bold")  ; Set a large font size (32-point).
	
	ui.Title := ui.AfkGui.AddText("x0 y+13","")
	ui.AfkGui.AddPicture("x+-8 ys+35 w10 h30","./Img/label_left_trim.png")
	ui.AfkStatus1 := ui.AfkGui.AddPicture("x+0 ys+35 w70 h30 Background" cfg.ThemeButtonReadyColor,"./Img/label_timer_off.png")  ; XX & YY serve to auto-size the window.
	ui.AfkGui.AddPicture("x+0 ys+35 w10 h30","./Img/label_right_trim.png")
	ui.afkProgress := ui.AfkGui.AddProgress("x97 y106 w147 h29 c" cfg.ThemeBright2Color " vTimerProgress Smooth Range0-" cfg.towerInterval " Background" cfg.themeBackgroundColor " ",0)
	ui.AfkGui.Opt("+LastFound")
	WinSetTransparent(210)

	ui.AfkAnchoredToGui := true
	ui.HandlebarAfkGui := ui.AfkGui.AddPicture("x245 y30 w30 h116 section +Hidden","./Img/handlebar_vertical.png")
	ui.AfkGui.Opt("+LastFound")
	guiVis(ui.afkGui,false)
}

towerToggleChanged(toggleControl,*) {
	toggleControl.value := 
		(cfg.%toggleControl.name%Enabled := !cfg.%toggleControl.name%Enabled)
			? (toggleControl.Opt("Background" cfg.ThemeButtonAlertColor),"./img/towerToggle_celestial.png")
			: (toggleControl.Opt("Background" cfg.ThemeButtonAlertColor),"./img/towerToggle_infinite.png")
		; reload()
}

toggleChanged(toggleControl,*) {
	toggleControl.value := 
		(cfg.%toggleControl.name%Enabled := !cfg.%toggleControl.name%Enabled)
			? (toggleControl.Opt("Background" cfg.ThemeButtonOnColor),cfg.toggleOn)
			: (toggleControl.Opt("Background" cfg.ThemeButtonReadyColor),cfg.toggleOff)
		; reload()
		}
		
toggleChange(name) {
	(%name%Enabled := !%name%Enabled) 
	? (%name%Toggle.Opt("Background" cfg.ThemeButtonOnColor)
		,cfg.toggleOn) 
	: (%name%Toggle.Opt("Background" cfg.ThemeButtonReadyColor)
		,cfg.toggleOff)
}
	
fadeIn() {
	if (cfg.AnimationsEnabled) && !(inStr(DllCall("GetCommandLine","Str"),"/restart")) {
		Transparency := 0
		While Transparency < 140
		{
			Transparency += 2.5
			WinSetTransparent(Round(Transparency),ui.MainGui)			
			; WinSetTransparent(Round(Transparency),ui.opsGui)
			Sleep(1)
		}

		While Transparency < 253
		{
			Transparency += 2.5
			WinSetTransparent(Round(Transparency),ui.MainGui)
			winSetTransparent(Round(Transparency),ui.gameSettingsGui)
			winSetTransparent(Round(Transparency),ui.afkGui)
			; WinSetTransparent(Round(Transparency),ui.opsGui)
			Sleep(1)
		}
	}
	
	ui.mainGui.getPos(&winX,&winY,,)
	ui.AfkGui.Move(winX+45,winY+35,280,140)
	ui.titleBarButtonGui.Move(winX,WinY-3)
	guiVis(ui.MainGui,true)
	guiVis(ui.titleBarButtonGui,true)
	; guiVis(ui.opsGui,true)
}

autoFireButtonClicked(*) {
	ToggleAutoFire()
}


toggleGuiCollapse(*) {
	static activeMainTab := ui.mainGuiTabs.value
		
	(ui.GuiCollapsed := !ui.GuiCollapsed) 
		? CollapseGui(&activeMainTab) 
		: UncollapseGui(&activeMainTab)
}


CollapseGui(&activeMainTab) {
;		guiVis(ui.titleBarButtonGui,false)
;		ui.MainGuiTabs.Choose(cfg.mainTabList[1])
		if (cfg.AnimationsEnabled) {
			GuiWidth := cfg.GuiW
			While GuiWidth > 5 {
				redrawGuis(GuiWidth)
				GuiWidth -= 30
				sleep(20)
			}	
		}
		ui.MainGui.Move(,,35,)
}

redrawGuis(GuiWidth) {
	ui.MainGui.Move(,,GuiWidth,)

	ui.mainGui.getPos(&mainX,&mainY,&mainW,&mainH)
	if guiWidth < 350
		ui.afkGui.move(mainX+40,mainY+35,guiWidth-35,)
	ui.gameSettingsGui.move(mainX+35,mainY+35,guiWidth-35,)
	ui.titleBarButtonGui.move(mainX-(565-guiWidth),mainY-3,guiWidth,)
}

UncollapseGui(&activeMainTab) {
	GuiWidth := 0
	if (cfg.AnimationsEnabled) {
		While GuiWidth < 575 {
			redrawGuis(GuiWidth)
			GuiWidth += 30
			sleep(20)
		}
	}
	ui.mainGui.getPos(&mainX,&mainY,&mainW,&mainH)
	ui.gameSettingsGui.move(mainX+35,mainY+35,495,)
	ui.afkGui.move(mainX+40,mainY+35,275,)
	;guiVis(ui.titleBarButtonGui,true)
	; guiVis(ui.gameSettingsGui,true)
	; guiVis(ui.afkGui,true)
}

toggleAfkDock(*) {
	(ui.AfkDocked := !ui.AfkDocked) 
	? dockAfkGui() 
	: undockAfkGui()
}


dockAfkGui(*) {
	; guiVis(ui.opsGui,false)


	ui.AfkAnchoredToGui := false
	WinGetPos(&GuiPrevX,&GuiPrevY,,,ui.mainGui)
	ui.GuiX := GuiPrevX
	ui.GuiY := GuiPrevY
	guiVis(ui.mainGui,false)
	ui.AfkGui.Show("x" MainGuix+45 " y" MainGuiY+35 " w225 h140 NoActivate")
	
	ui.buttonDockAfk.Opt("Hidden")
	ui.buttonUndockAfk.Opt("-Hidden")
	ui.HandlebarAfkGui.Opt("-Hidden")
	ui.buttonPopout.Opt("+Hidden")
	ui.buttonStartAFK.Move(3,3)
	ui.buttonTower.Move(33,3)
	ui.buttonAntiIdle1.Move(63,3)
	ui.buttonAutoFire.Move(93,3)
	ui.buttonAutoClicker.Move(123,3)
	ui.downButton.opt("hidden")
	ui.exitButton.Move(10,0)
	ui.buttonUndockAfk.Move(49,0)

	ui.AfkGui.Move(0,A_ScreenHeight-ui.TaskbarHeight-140,265,140)	
	WinGetPos(&AfkGuiX,&AfkGuiY,&AfkGuiW,&AfkGuiH,ui.afkGui)
	ui.titleBarButtonGui.Opt("Owner" ui.AfkGui.Hwnd)
	ui.titleBarButtonGui.Move(0,A_ScreenHeight-ui.TaskbarHeight-150,90,500)
	;guiVis(ui.titleBarButtonGui,true)
	guiVis(ui.mainGui,false)
	guiVis(ui.afkGui,true)
	WinSetTransparent(210,ui.AfkGui)
	WinSetTransparent(210,ui.HandlebarAfkGui)
	controlFocus(ui.buttonUndockAfk)
}
	
undockAfkGui(*) {
	; IniWrite(cfg.GuiX,"nControl.ini","Interface","GuiX")
	; IniWrite(cfg.GuiY,"nControl.ini","Interface","GuiY")
	; guiVis(ui.opsGui,true)
	ui.buttonDockAfk.Opt("-Hidden")
	ui.buttonUndockAfk.Opt("Hidden")
	ui.HandlebarAfkGui.Opt("Hidden")	
	ui.buttonPopout.Opt("-Hidden")
	ui.buttonDockAfk.Move(2,2)
	ui.buttonStartAFK.Move(32,2)
	ui.buttonTower.Move(62,2)
	ui.buttonAntiIdle1.Move(92,2)
	ui.buttonAutoFire.Move(122,2)
	ui.buttonAutoClicker.Move(152,2)
	ui.downButton.Move(454,3)
	ui.exitButton.Move(494,3)
	ui.titleBarButtonGui.Opt("Owner" ui.MainGui.Hwnd)
	ui.MainGui.GetPos(&winX,&winY,,)
	ui.AfkGui.Move(winX+30,winY+35,,)
	ui.titleBarButtonGui.Move(winX+1,WinY-5,565,)
	; ui.opsGui.Move(winX,winY)

	guiVis(ui.titleBarButtonGui,true)
	guiVis(ui.mainGui,true)
	if !(ui.MainGuiTabs.Text == "AFK")
	{
		guiVis(ui.afkGui,false)
		AfkPopoutButtonPushed()
	} else {
		guiVis(ui.afkGui,true)
	}
	controlFocus(ui.buttonDockAfk)
}	

afkPopoutButtonPushed(*) {

	(ui.AfkAnchoredToGui := !ui.AfkAnchoredToGui)
	? afkPopIn()
	: afkPopOut()
	
	afkPopOut() {
		debugLog("PopOut of AFK Gui")
		ui.buttonPopout.Value := "./Img/button_popout_on.png"
		ui.buttonPopout.Opt("Background" cfg.ThemeButtonOnColor)

		; guiVis(ui.opsGui,false)
		guiVis(ui.MainGui,false)
		ui.downButton.Move(3,3)
		ui.exitButton.Move(43,3)
		ui.buttonPopout.move(270,3)
		WinGetPos(&AfkGuiX,&AfkGuiY,&AfkGuiW,&AfkGuiH,ui.afkGui)
		ui.afkGui.move(afkGuiX,afkGuiY,300,)
		WinSetTransparent(210,ui.AfkGui)
		ui.HandlebarAfkGui.Opt("-Hidden")
		ui.AfkAnchoredToGui := false
		ui.AfkDocked := false
		;ui.AfkGui.Move(0,A_ScreenHeight-ui.TaskbarHeight-AfkGuiH,275,)	
		ui.titleBarButtonGui.Opt("Owner" ui.AfkGui.Hwnd)
		ui.titleBarButtonGui.Move(AfkGuiX+190,AfkGuiY-5,109)
		guiVis(ui.titleBarButtonGui,true)
		guiVis(ui.mainGui,false)
		guiVis(ui.afkGui,true)
		WinSetTransparent(210,ui.AfkGui)
		WinSetTransparent(210,ui.HandlebarAfkGui)

		MouseGetPos(&mX,&mY)
		CoordMode("Mouse","Client")
		MouseClick("Left",285,80)
		MouseMove(mX,mY)
	}
	
	afkPopIn() {
		ui.buttonPopout.Value := "./Img/button_popout_ready.png"
		ui.buttonPopout.Opt("Background" cfg.ThemeButtonReadyColor)
		WinGetPos(&winX,&winY,,,ui.mainGui)
		ui.buttonAfkHide.opt("+hidden")
		ui.HandlebarAfkGui.Opt("+Hidden")
		ui.downButton.Move(454,3)
		ui.exitButton.Move(494,3)
		ui.buttonPopout.move(225,3)
		ui.titleBarButtonGui.Opt("Owner" ui.MainGui.Hwnd)
		ui.AfkGui.Move(winX+40,winY+35,,)
		ui.titleBarButtonGui.Move(winX+1,WinY-5,570,)
		guiVis(ui.titleBarButtonGui,true)
		guiVis(ui.mainGui,true)
		
		if !(ui.MainGuiTabs.Text == "AFK")
		{
			guiVis(ui.afkGui,false)
		}
		ui.AfkDocked := false
		ui.AfkAnchoredToGui := true
	}
}


hideAfkGui(*) {
	WinSetTransparent(0,ui.AfkGui)
}

exitButtonPushed(*) {
	exitMenuShow()
	keyWait("LButton")
	mouseGetPos(,,,&ctrlUnderMouse,2)
	
	switch ctrlUnderMouse
	{
		case ui.startGamingButton.hwnd:
			ui.exitMenuGui.destroy()
			startGaming()
		case ui.stopGamingButton.hwnd:
			ui.exitMenuGui.destroy()
			stopGaming()
		case ui.exitButton.hwnd:
			ui.exitMenuGui.destroy()
			exitApp()
		default: 
			ui.exitMenuGui.destroy()
	}
}

stopGaming(*) {
	ui.dividerGui.hide()
	while a_index <= cfg.gamingStopProc.length {
		try	
			processClose(cfg.gamingStopProc[a_index])
		processIndex := a_index
	}
	try
		winWaitClose("ahk_exe " cfg.gamingStopProc[processIndex],,5)
	
	exitApp()
}
	
startGaming(*) {
	while a_index <= cfg.gamingStartProc.length {
		try
			run(cfg.gamingStartProc[a_index])
	}
	
	; try {
		; run('./redist/nircmd setdefaultsounddevice "Microphone"')
		; run('./redist/nircmd setdefaultsounddevice "Speakers"')
		; run('./redist/nircmd setdefaultsounddevice "Headphones"')
	; }	
}

exitMenuShow() {
	winGetPos(&tbX,&tbY,,,ui.titleBarButtonGui)
	ui.exitMenuGui := gui()
	ui.exitMenuGui.Opt("-caption -border AlwaysOnTop Owner" ui.mainGui.hwnd)
	ui.exitMenuGui.BackColor := ui.transparentColor

	ui.gamingModeLabel := ui.exitMenuGui.addText("x0 y0 w70 h15 backgroundTrans c" cfg.themeFont2Color,"Gaming Mode")
	ui.gamingModeLabel.setFont("s8")
	ui.gamingLabels := ui.exitMenuGui.addText("x0 y15 w70 h20 backgroundTrans c" cfg.themeFont1Color,"Stop   Start")
	ui.gamingLabels.setFont("s10")
	ui.stopGamingButton := ui.exitMenuGui.addPicture("x0 y35 section w35 h35 background" cfg.themeButtonReadyColor,"./img/button_quit.png")
	ui.startGamingButton := ui.exitMenuGui.addPicture("x+0 ys w35 h35 background" cfg.themeButtonReadyColor,"./img/button_exit_gaming.png")
	ui.stopGamingButton.onEvent("Click",exitAppCallback)
	ui.startGamingButton.onEvent("Click",stopGaming)
	WinSetTransColor(ui.transparentColor,ui.exitMenuGui)
	ui.exitMenuGui.show("x" tbX+491 " y" tbY-70 " AutoSize noActivate")
	
	exitAppCallback(*) {
		ExitApp
	}
}

hideGui(*) {
	SaveGuiPos()
	WinSetTransparent(0,ui.MainGui)
	if ui.AfkAnchoredToGui = true
	{
		WinSetTransparent(0,ui.AfkGui)
		WinSetTransparent(0,ui.titleBarButtonGui)
		WinSetTransparent(0,ui.HandlebarAfkGui)
		WinSetTransparent(0,ui.gameSettingsGui)
		; WinSetTransparent(0,ui.opsGui)
	}
	debugLog("Hiding Interface")
}

saveGuiPos(*) {
	Global
	ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
	ui.AfkGui.GetPos(&AfkX,&AfkY,&AfkW,&AfkH)
	cfg.GuiX := GuiX*(A_ScreenDPI/96)
	cfg.GuiY := GuiY*(A_ScreenDPI/96)
	cfg.AfkX := AfkX*(A_ScreenDPI/96)
	cfg.AfkY := AfkY*(A_ScreenDPI/96)
	IniWrite(cfg.GuiX,cfg.file,"Interface","GuiX")
	IniWrite(cfg.GuiY,cfg.file,"Interface","GuiY")
	IniWrite(cfg.AfkX,cfg.file,"Interface","AfkX")
	IniWrite(cfg.AfkY,cfg.file,"Interface","AfkY")
	
	debugLog("Saving Window Location at x" GuiX " y" GuiY)
}

showGui(*) {
	global
	cfg.GuiX := IniRead(cfg.file,"Interface","GuiX",A_ScreenWidth/2)
	cfg.GuiY := IniRead(cfg.file,"Interface","GuiY",A_ScreenHeight/2)
	debugLog("Showing Interface at x" cfg.GuiX " y" cfg.GuiY)
	ui.MainGui.GetPos(&MainGuiX,&MainGuiY,,,)

;	ui.mainGuiTabs.Choose(ui.previousTab)
	ui.HandlebarAfkGui.Opt("+Hidden")
	ui.buttonAfkHide.opt("+hidden")
	ui.AfkAnchoredToGui := true
	ui.AfkDocked := false
	tabsChanged()
	debugLog("Showing Interface")
}

toggleConsole(*) {
	Global
	if (cfg.ConsoleVisible == false)
	{
		cfg.ConsoleVisible := true
		
		ui.ButtonDebug.Value := "./Img/button_console_on.png"
		ui.ButtonDebug.Opt("Background" cfg.ThemeButtonOnColor)
		
		;MsgBox("here")
		if (cfg.AnimationsEnabled) {
		GuiH := 214	
			While (GuiH < 395)
			{
				GuiH += 10
				ui.mainGui.move(,,,GuiH) 
				Sleep(10)
			}
		}
		GuiH := 430
		ui.mainGui.Move(,,,GuiH)
		ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
		;MsgBox(GuiX "`n" GuiY "`n" GuiW "`n" GuiH)
		debugLog("Showing Log")
	} else {
		cfg.ConsoleVisible := false
		ui.ButtonDebug.Value := "./Img/button_console_ready.png"
		ui.ButtonDebug.Opt("Background" cfg.ThemeButtonReadyColor)

		ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
		if (cfg.AnimationsEnabled) {
			While (GuiH > 225)
			{
				GuiH -= 10
				ui.MainGui.move(,,,GuiH)
				Sleep(10)
			}
		}
		GuiH := 214
		ui.MainGui.move(,,,GuiH)
		debugLog("Hiding Log")
	}
}



initConsole(&ui) {
	ui.gvMonitorSelectGui := Gui()
	ui.gvMonitorSelectGui.Opt("-Theme -Border -Caption +AlwaysOnTop +Parent" ui.MainGui.Hwnd " +Owner" ui.MainGui.Hwnd)
	ui.gvMonitorSelectGui.BackColor := "212121"
	ui.gvMonitorSelectGui.SetFont("s16 c00FFFF","Calibri Bold")
	ui.gvMonitorSelectGui.Add("Text",,"Click anywhere on the screen`nyou'd like your nControlDock on.")
}


guiVis(guiName,isVisible:= true) {
	if (isVisible) {
		WinSetTransparent(255,guiName)
		WinSetTransparent("Off",guiName)
		WinSetTransColor(ui.TransparentColor,guiName)
	} else {
		WinSetTransparent(0,guiName)
	}
}

tabsChanged(*) {
	ui.activeTab := ui.mainGuiTabs.Text
	cfg.activeMainTab := ui.mainGuiTabs.value

	;guiVis(ui.mainGui,true)
	;guiVis(ui.titleBarButtonGui,true)
	guiVis(ui.afkGui,(ui.activeTab == "AFK") ? true : false)
	guiVis(ui.gameSettingsGui,(ui.activeTab = "Game") ? true : false)	
	Switch {
		case (ui.activeTab == "zGame") || (ui.activeTab == "zAudio"):
		{
			msgBox('here')
			ui.MainGuiTabs.Choose(ui.previousTab)
			SetTimer(GameDisabled,-1)
			GameDisabled() {
				notifyOSD("Tab currently disabled `nby developer",2500)
			}
			Return				
		}a
		case (ui.activeTab == "Setup"):
		{
			ControlFocus(ui.toggleColorSelector,ui.mainGui)
		}
		case (ui.activeTab == "AFK"):
		{
			ui.mainGui.getPos(&MainGuiX,&MainGuiY,,)
			drawAfkOutlines()
			ui.AfkGui.Show("x" MainGuix+45 " y" MainGuiY+35 " w280 h140 NoActivate")
		}
		case (ui.activeTab == "Game"):
		{
			winSetTransparent(255,ui.gameSettingsGui)
			ui.gameSettingsGui.show("x" cfg.GuiX+35 " y" cfg.GuiY+35 " w490 h172")
		}
	}
	
	ui.previousTab := ui.activeTab
}

{ ;Draw Outline Functions
	drawOutlineMainGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
		ui.MainGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
		ui.MainGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
		ui.MainGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
		ui.MainGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
	}

	drawOutlineDialogBoxGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
		ui.dialogBoxGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
		ui.dialogBoxGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
		ui.dialogBoxGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
		ui.dialogBoxGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
	}

	drawOutlineNewGameGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
		ui.NewGameGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
		ui.NewGameGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
		ui.NewGameGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
		ui.NewGameGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
	}

	drawOutlineNotifyGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
		ui.NotifyGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
		ui.NotifyGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
		ui.NotifyGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
		ui.NotifyGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
	}

	drawOutlineAfkGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
		
		ui.AfkGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
		ui.AfkGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
		ui.AfkGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
		ui.AfkGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
	}

	drawOutline(guiName, X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
		
		guiName.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
		guiName.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
		guiName.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
		guiName.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
	}	
	
	drawOutlineNamed(outLineName, guiName, X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
		outLineName1	:= outLineName "1"
		outLineName2	:= outLineName "2"
		outLineName3	:= outLineName "3"
		outLineName4	:= outLineName "4"
		(outLineName1 := outLineName "1") := guiName.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
		(outLineName2 := outLineName "2") := guiName.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
		(outLineName3 := outLineName "3") := guiName.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
		(outLineName4 := outLineName "4") := guiName.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
	}


	drawOutlineTitleBarButtonGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
		
		ui.titleBarButtonGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
		ui.titleBarButtonGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
		ui.titleBarButtonGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
		ui.titleBarButtonGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
	
	}
} ;End Draw Outline Functions

drawAfkOutlines() {	
ui.mainGuiTabs.UseTab("AFK")
	drawOutlineNamed("afkOutline1",ui.afkGui,96,105,150,32,cfg.themeBright1Color,cfg.themeBright2Color,2)
	drawOutlineNamed("afkOutline2",ui.afkGui,178,38,67,58,cfg.themeBright1Color,cfg.themeBright2Color,2)
;	drawOutlineNamed("afkOutline3",ui.afkGui,240,40,67,58,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)
	drawOutlineNamed("afkGuiOutline",ui.afkGui,0,2,182,32,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,1)
	drawOutlineNamed("mainOutline1",ui.mainGui,346,35,180,80,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)
	drawOutlineNamed("mainOutline2",ui.mainGui,346,125,180,80,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)
	

}
drawMainOutlines() {
ui.mainGuiTabs.useTab("")




	;drawOutlineNamed("consolePanelOutline",ui.mainGui,35,150,498,6,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,3) 	;Log Panel Outline
	;drawOutlineNamed("consolePanelOutline2",ui.mainGui,35,220,498,184,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,1)		;Log Panel 3D Effect
}
drawOpsOutlines() {
ui.mainGuiTabs.useTab("")
	drawOutlineNamed("bottomLine",ui.mainGui,37,208,492,6,cfg.themeBorderDarkColor,cfg.themeDisabledColor,3)
ui.mainGuiTabs.useTab("Sys")
	drawGridlines()
	drawOutlineNamed("tabsUnderline",ui.MainGui,35,29,502,3,cfg.ThemeBackgroundColor,cfg.ThemeBackgroundColor,2)
	drawOutlineNamed("opsClock",ui.mainGui,66,33,171,28,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,1)		;Ops Clock
	drawOutlineNamed("opsClock",ui.mainGui,67,34,169,26,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,1)	
	drawOutlineNamed("opsToolbarOutline2",ui.mainGui,35,33,497,30,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar Outline
	drawOutlineNamed("opsStatusBarRightDark",ui.mainGui,305,137,228,30,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)	;Status Bar
	drawOutlineNamed("opsStatusBarRightLight",ui.mainGui,306,136,227,32,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)	;Status Bar
	drawOutlineNamed("opsStatusBarLeftDark",ui.mainGui,34,137,227,30,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)	;Status Bar
	drawOutlineNamed("opsStatusBarLeftLight",ui.mainGui,33,136,228,32,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)	;Status Bar
	drawOutlineNamed("opsMiddleColumnMiddleRow",ui.mainGui,259,105,48,50,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar Outline
	drawOutlineNamed("opsMiddleColumnOutlineDark",ui.mainGui,258,62,50,143,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)		;Ops Toolbar Outline
	drawOutlineNamed("opsMiddleColumnOutlineLight",ui.mainGui,259,62,48,143,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar
}

drawGridLines() {
ui.MainGuiTabs.UseTab("Sys")
	;drawOutline(ui.MainGui,103,77,158,15,cfg.ThemeFont4Color,cfg.ThemeFont4Color,1)				;Win1 Info Gridlines  
	;drawOutline(ui.MainGui,305,77,157,15,cfg.ThemeFont4Color,cfg.ThemeFont4Color,1)				;Win2 Info Gridlines
	drawOutline(ui.MainGui,305,62,157,76,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)	;WIn2 Info Frame
	drawOutline(ui.MainGui,103,62,158,76,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2) ;Win1 Info Frame

}