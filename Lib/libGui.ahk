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
	ui.DownButton := ui.titleBarButtonGui.AddPicture("x456 y0 w35 h35 section Background" cfg.ThemeFont1Color,"./Img/button_minimize.png")
	ui.DownButton.OnEvent("Click",HideGui)
	ui.DownButton.ToolTip := "Minimizes nControl App"
	
	ui.ExitButton 	:= ui.titleBarButtonGui.AddPicture("x+3 ys section w35 h35 Background" cfg.ThemeFont1Color,"./Img/button_power_ready.png")
	ui.ExitButton.OnEvent("Click",ExitButtonPushed)
	ui.ExitButton.ToolTip := "Terminates nControl App"

	ui.buttonUndockAfk := ui.titleBarButtonGui.AddPicture("x+6 ys w35 h35 hidden Background" cfg.ThemeButtonAlertColor,"./Img/button_dockright_ready.png")
	ui.buttonUndockAfk.OnEvent("Click",ToggleAfkDock)
	ui.buttonUndockAfk.ToolTip := "Undocks AFK Window"
	
	ui.MainGui.MarginX := 0
	ui.MainGui.MarginY := 0
	ui.MainGui.SetFont("s13 c" cfg.ThemeFont1Color,"Calibri")
	ui.MainGuiTabs := ui.MainGui.AddTab3("x35 y1 w495 h213 Buttons -redraw Background" cfg.ThemeBackgroundColor " -E0x200", cfg.mainTabList)
	ui.MainGuiTabs.OnEvent("Change",TabsChanged)
;	ui.MainGuiTabs.Choose(cfg.mainTabList[3])
	ui.MainGuiTabs.UseTab("")
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri")
	ui.handleBarImage := ui.MainGui.AddPicture("x0 y-2 w35 h216","./Img/handlebar_vertical.png")
	ui.handleBarImage.ToolTip := "Drag Handlebar to Move.`nDouble-Click to collapse/uncollapse."
	ui.rightHandlebarImage := ui.titleBarButtonGui.AddPicture("x530 w35 y3 h216","./Img/handlebar_vertical.png")
	ui.rightHandlebarImage2 := ui.mainGui.AddPicture("x530 w35 y0 h216 section","./Img/handlebar_vertical.png")

	ui.handleBarImage.OnEvent("DoubleClick",ToggleGuiCollapse)
	ui.rightHandleBarImage.OnEvent("DoubleClick",ToggleGuiCollapse)
	ui.handleBarImage.OnEvent("Click",WM_LBUTTONDOWN_callback)
	ui.rightHandleBarImage.OnEvent("Click",WM_LBUTTONDOWN_callback)
	

	ui.gvConsole := ui.MainGui.AddListBox("x35 y220 w500 h192 +Background" cfg.ThemePanel1Color)
	ui.gvConsole.Color := cfg.ThemeBright1Color	

	afk 						:= Object()

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
	winSetTransparent(0,ui.afkGui)
	ui.titleBarButtonGui.Show("x" cfg.GuiX " y" cfg.GuiY-5 " w562 h218 NoActivate")
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
	ui.win1statusBg := ui.afkGui.addText("x5 y38 w85 h25 background " cfg.themeEditboxColor,"")
	ui.win2statusBg := ui.afkGui.addText("x5 y72 w85 h25 background " cfg.themeEditboxColor,"")
	
	ui.buttonDockAfk := ui.AfkGui.AddPicture("x6 y2 w30 h30 section Background" cfg.ThemeButtonReadyColor,"./Img/button_dockLeft_ready.png")
	ui.buttonDockAfk.OnEvent("Click",ToggleAfkDock)
	ui.buttonDockAfk.ToolTip := "Dock AFK Panel"
	ui.buttonStartAFK := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_afk_ready.png")
	ui.buttonStartAFK.OnEvent("Click",ToggleAFK)
	ui.buttonStartAFK.ToolTip := "Toggle AFK"
	
	ui.buttonTower := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_tower_ready.png")
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
	hideAfkGui(*) {
		guiVis(ui.afkGui,false)
	}
	ui.buttonAfkHide.ToolTip := "Minimizes AFK Window to System Tray"
	
	ui.buttonPopout := ui.AfkGui.AddPicture("x+-0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_popout_ready.png")
	ui.buttonPopout.OnEvent("Click",AfkPopoutButtonPushed)
	
	ui.Win1Label := ui.AfkGui.AddPicture("xs y+8 section w25 h23 background" cfg.themeEditboxColor,"./Img/arrow_left.png")

	ui.AfkGui.SetFont("s14","Calibri")
	ui.Win1AfkIcon := ui.AfkGui.AddPicture("x+0 ys w28 h23 right background" cfg.themeEditboxColor,"./Img/sleep_icon.png")
	ui.Win1AfkStatus := ui.AfkGui.AddText("x+0 ys w28 h23 background" cfg.themeEditboxColor,"")
	ui.AfkGui.SetFont("s12","Calibri")
	ui.afkWin1ClassDDL := ui.AfkGui.AddDDL("x+0 ys-1 w158 altSubmit choose" cfg.win1class " background" cfg.ThemeEditboxColor, ui.profileList)
	ui.afkWin1ClassDDL.OnEvent("Change",afkWin1ClassChange)
	postMessage("0x153", -1, 19,, "AHK_ID " ui.afkWin1ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
	postMessage("0x153", 0, 19,, "AHK_ID " ui.afkWin1ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
	ui.Win2Label := ui.AfkGui.AddPicture("xs y+8 section w25 h23 background" cfg.themeEditboxColor,"./Img/arrow_right.png")
	; loop ui.profileList.length {
		; if (ui.profileList[a_index] == cfg.win1class) {
			; ui.afkWin1ClassDDL.choose(a_index)
		; }
		; if (ui.profileList[a_index] == cfg.win2class) {
			; ui.afkWin2ClassDDL.choose(a_index)
		; }
	; }
	ui.AfkGui.SetFont("s14","Calibri")
	ui.Win2AfkIcon := ui.AfkGui.AddPicture("x+0 ys w28 h23 background" cfg.themeEditboxColor,"./Img/sleep_icon.png")
	ui.Win2AfkStatus := ui.AfkGui.AddText("x+0 ys w28 h23 background" cfg.themeEditboxColor,"")
	ui.AfkGui.SetFont("s12","Calibri")
	ui.afkWin2ClassDDL := ui.AfkGui.AddDDL("x+0 ys-2 w158 altSubmit choose" cfg.win2class " background" cfg.ThemeEditboxColor,ui.profileList)
	ui.afkWin2ClassDDL.OnEvent("Change",afkWin2ClassChange)
	postMessage("0x153", -1, 20,, "AHK_ID " ui.afkWin2ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
	postMessage("0x153", 0, 20,, "AHK_ID " ui.afkWin2ClassDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
	ui.AfkGui.SetFont("s16 bold")  ; Set a large font size (32-point).
	ui.Title := ui.AfkGui.AddText("x0 y+13","")
	ui.AfkGui.AddPicture("x+-8 ys+30 w10 h28","./Img/label_left_trim.png")
	ui.AfkStatus1 := ui.AfkGui.AddPicture("x+0 ys+30 w65 h28 Background" cfg.ThemeButtonReadyColor,"./Img/label_timer_off.png")  ; XX & YY serve to auto-size the window.
	ui.AfkGui.AddPicture("x+0 ys+30 w10 h28 section","./Img/label_right_trim.png")
	ui.afkProgress := ui.AfkGui.AddProgress("x+-1 ys+3 w155 h22 c" cfg.ThemeBright2Color " vTimerProgress Smooth Range0-" cfg.towerInterval " Background" cfg.themeEditboxColor " ",0)
	ui.AfkGui.Opt("+LastFound")
	WinSetTransparent(210)

	ui.AfkAnchoredToGui := true
	ui.HandlebarAfkGui := ui.AfkGui.AddPicture("x245 y35 w30 h100 +Hidden","./Img/handlebar_vertical.png")
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
		
toggleVerticalChanged(toggleControl,*) {
	toggleControl.value := 
		(cfg.%toggleControl.name%Enabled := !cfg.%toggleControl.name%Enabled)
			? (toggleControl.Opt("Background" cfg.ThemeButtonOnColor),"./img/toggle_vertical_trans_on.png")
			: (toggleControl.Opt("Background" cfg.ThemeButtonReadyColor),"./img/toggle_vertical_trans_off.png")
		; reload()
		}
		
toggleChange(name,onOff := "",toggleOnImg := cfg.toggleOn,toggleOffImg := cfg.toggleOff,toggleOnColor := cfg.themeButtonOnColor,toggleOffColor := cfg.themeButtonReadyColor) {
	 (onOff)
		? (%name%.Opt("Background" toggleOnColor),toggleOnImg) 
		: (%name%.Opt("Background" toggleOffColor),toggleOffImg)
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
	winGetPos(&mainGuiX,&mainGuiY,,,ui.mainGui)
	drawAfkOutlines()		
	ui.titleBarButtonGui.Move(mainGuiX,mainGuiY-5)
	guiVis(ui.afkGui,true)
	guiVis(ui.MainGui,true)
	guiVis(ui.titleBarButtonGui,true)
	ui.gameSettingsGui.show("x" mainGuiX+35 " y" mainGuiY+35 " w495 h170 noActivate")
	ui.AfkGui.Show("x" mainGuiX+40 " y" mainGuiY+50 " w280 h140 NoActivate")
; guiVis(ui.opsGui,true)
}

autoFireButtonClicked(*) {
	ToggleAutoFire()
}


toggleGuiCollapse(*) {
	static activeMainTab := ui.mainGuiTabs.value
		
	(ui.GuiCollapsed := !ui.GuiCollapsed) 
		? CollapseGui() 
		: UncollapseGui()
}


CollapseGui() {
	winGetPos(&mainX,&mainY,&mainW,&mainH,ui.mainGui)
	GuiWidth := mainW
	guiVis(ui.titleBarButtonGui,false)
	guiVis(ui.afkGui,false)
	guiVis(ui.gameSettingsGui,false)
	if (cfg.AnimationsEnabled) {
		While GuiWidth > 5 {
			redrawGuis(GuiWidth,mainX,mainY)
			GuiWidth -= 30
			sleep(20)
		}	
	}
	ui.MainGui.Move(mainX,mainY,35,)
}

redrawGuis(GuiWidth,mainX,mainY) {
	ui.MainGui.Move(mainX,mainY,GuiWidth,)
	; if guiWidth < 310
		; ui.afkGui.move(mainX+45,mainY+35,guiWidth-35,)
	;ui.gameSettingsGui.move(mainX+35,mainY+35,guiWidth-35,)
}

UncollapseGui() {
	winGetPos(&mainX,&mainY,&mainW,&mainH,ui.mainGui)
	GuiWidth := 0
	guiVis(ui.titleBarButtonGui,false)
	if (cfg.AnimationsEnabled) {
		While GuiWidth < 575 {
			redrawGuis(GuiWidth,mainX,mainY)
			GuiWidth += 30
			sleep(20)
		}
	}
	ui.mainGui.getPos(&mainX,&mainY,&mainW,&mainH)
	ui.gameSettingsGui.move(mainX+35,mainY+35,495,)
	ui.afkGui.move(mainX+40,mainY+50,275,)
	guiVis(ui.titleBarButtonGui,true)
	tabsChanged()
}

toggleAfkDock(*) {
	(ui.AfkDocked := !ui.AfkDocked) 
	? dockAfkGui() 
	: undockAfkGui()
}


dockAfkGui(*) {
	; guiVis(ui.opsGui,false)
	saveGuiPos()
	ui.AfkDocked := true
	ui.AfkAnchoredToGui := false
	ui.titleBarButtonGui.Opt("Owner" ui.AfkGui.Hwnd)
	ui.mainGui.opt("owner" ui.afkGui.hwnd)
	guiVis(ui.mainGui,false)
	guiVis(ui.titleBarButtonGui,false)	
	ui.buttonDockAfk.Opt("Hidden")
	ui.handleBarAfkGui.opt("-hidden")




	; ui.afkGui.show("x5 y" a_screenHeight-ui.TaskbarHeight-150 " w270 h140")


	ui.AfkGui.Move(0,A_ScreenHeight-ui.TaskbarHeight-134,272,134)
	winGetPos(&AfkGuiX,&AfkGuiY,,,ui.afkGui)
	ui.titleBarButtonGui.move(afkGuiX+185,afkGuiY,90,50)
	; ui.mainGui.move(afkGuiX-45,afkGuiX-35)

	; ui.titleBarButtonGui.Move(,,90,50)
	ui.handleBarAfkGui.move(245,35,25,100)

	ui.buttonUndockAfk.Opt("-Hidden")
	ui.buttonPopout.Opt("-Hidden")
	ui.buttonStartAFK.Move(6,2)
	ui.buttonTower.Move(36,2)
	ui.buttonAntiIdle1.Move(66,2)
	ui.buttonAutoFire.Move(96,2)
	ui.buttonAutoClicker.Move(126,2)
	ui.buttonPopout.move(156,2)
	ui.downButton.opt("hidden")
	ui.exitButton.Move(10,0)
	ui.buttonUndockAfk.Move(49,0)
	guiVis(ui.afkGui,true)
	guiVis(ui.titleBarButtonGui,true)
	
	WinGetPos(&AfkGuiX,&AfkGuiY,&AfkGuiW,&AfkGuiH,ui.afkGui)



	WinSetTransparent(210,ui.AfkGui)
	WinSetTransparent(210,ui.HandlebarAfkGui)
	controlFocus(ui.buttonUndockAfk)
}
	
undockAfkGui(*) {
	ui.titleBarButtonGui.Opt("Owner" ui.MainGui.Hwnd)
	ui.afkGui.opt("Owner" ui.mainGui.hwnd)	
	ui.mainGui.move(ui.prevGuiX,ui.prevGuiY)
	ui.AfkGui.Move(cfg.guiX+40,cfg.guiY+50,,)
	ui.titleBarButtonGui.Move(cfg.guiX,cfg.guiY-5,575,220)
	ui.gameSettingsGui.move(cfg.guiX+35,cfg.guiY+35)
	ui.AfkAnchoredToGui := true
	ui.AfkDocked := false
	; IniWrite(cfg.GuiX,"nControl.ini","Interface","GuiX")
	; IniWrite(cfg.GuiY,"nControl.ini","Interface","GuiY")
	; guiVis(ui.opsGui,true)
	ui.buttonDockAfk.Opt("-Hidden")
	ui.buttonUndockAfk.Opt("Hidden")
	ui.HandlebarAfkGui.Opt("Hidden")	
	ui.buttonPopout.Opt("-Hidden")
	ui.downButton.opt("-hidden")
	ui.buttonDockAfk.Move(6,2)
	ui.buttonStartAFK.Move(36,2)
	ui.buttonTower.Move(66,2)
	ui.buttonAntiIdle1.Move(96,2)
	ui.buttonAutoFire.Move(126,2)
	ui.buttonAutoClicker.Move(156,2)
	ui.buttonPopout.move(217,2)
	ui.downButton.Move(456,0)
	ui.exitButton.Move(494,0)
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
	saveGuiPos()
}	

afkPopoutButtonPushed(*) {

	(ui.AfkAnchoredToGui := !ui.AfkAnchoredToGui)
	? afkPopIn()
	: afkPopOut()
	
	afkPopOut() {
		saveGuiPos()
		debugLog("PopOut of AFK Gui")
		ui.AfkDocked := false
		guiVis(ui.titleBarButtonGui,false)
		guiVis(ui.MainGui,false)
		ui.handleBarAfkGui.opt("-hidden") 
		WinSetTransparent(210,ui.AfkGui)
		ui.buttonPopout.Value := "./Img/button_popout_on.png"
		ui.buttonPopout.Opt("Background" cfg.ThemeButtonOnColor)
		ui.buttonPopout.move(245,2)
	}
	
	afkPopIn() {
		ui.AfkDocked := false
		ui.buttonAfkHide.opt("+hidden")
		ui.handleBarAfkGui.opt("+hidden")
		ui.mainGui.move(ui.prevGuiX,ui.prevGuiY)
		guiVis(ui.titleBarButtonGui,true)
		guiVis(ui.mainGui,true)
		ui.AfkGui.Move(ui.prevGuiX+40,ui.prevGuiY+50,,)
		ui.buttonPopout.Value := "./Img/button_popout_ready.png"
		ui.buttonPopout.Opt("Background" cfg.ThemeButtonReadyColor)
		ui.buttonPopout.move(217,2)
		
		if !(ui.MainGuiTabs.Text == "AFK")
		{
			guiVis(ui.afkGui,false)
		}

	}
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

	ui.gamingModeLabel := ui.exitMenuGui.addText("x3 y2 w70 h15 background" cfg.themePanel3color " c" cfg.themeFont3Color," Gaming Mode")
	ui.gamingModeLabel.setFont("s8")
	ui.gamingLabels := ui.exitMenuGui.addText("x3 y16 w70 h20 background" cfg.themePanel3color " c" cfg.themeFont2Color," Stop   Start")
	ui.gamingLabels.setFont("s10")
	ui.stopGamingButton := ui.exitMenuGui.addPicture("x3 y32 section w35 h35 background" cfg.themeButtonReadyColor,"./img/button_quit.png")
	ui.startGamingButton := ui.exitMenuGui.addPicture("x+3 ys w35 h34 background" cfg.themeButtonReadyColor,"./img/button_exit_gaming.png")
	ui.stopGamingButton.onEvent("Click",exitAppCallback)
	ui.startGamingButton.onEvent("Click",stopGaming)
	WinSetTransColor(ui.transparentColor,ui.exitMenuGui)
	ui.exitMenuGui.show("x" tbX+470 " y" tbY-70 " AutoSize noActivate")
	
	exitAppCallback(*) {
		ExitApp
	}
}

hideGui(*) {
	saveGuiPos()
	winMinimize(ui.mainGui)
	; saveGuiPos()
	; guiVis(ui.mainGui,false)
	; guiVis(ui.titleBarButtonGui,false)
	; guiVis(ui.afkGui,false)
	; guiVis(ui.handleBarAfkGui,false)
	; guiVis(ui.gameSettingsGui,false)
	debugLog("Hiding Interface")
}

saveGuiPos(*) {
	Global
	winGetPos(&GuiX,&GuiY,,,ui.MainGui)
	cfg.GuiX := GuiX
	cfg.GuiY := GuiY
	ui.prevGuiX := GuiX
	ui.prevGuiY := GuiY
	IniWrite(cfg.GuiX,cfg.file,"Interface","GuiX")
	IniWrite(cfg.GuiY,cfg.file,"Interface","GuiY")
	debugLog("Saving Window Location at x" GuiX " y" GuiY)
}

showGui(*) {
	detectHiddenWindows(true)

	winActivate(ui.mainGui)
	winRestore(ui.mainGui)
	ui.mainGui.move(cfg.GuiX,cfg.GuiY)	
	; lowX 		:= 0
	; highX 		:= 0
	; lowY 		:= 0
	; highY 		:= 0
	; cfg.GuiX 	:= IniRead(cfg.file,"Interface","GuiX",PrimaryWorkAreaLeft+200)
	; cfg.GuiY 	:= IniRead(cfg.file,"Interface","GuiY",PrimaryWorkAreaTop+200)

	; loop monitorGetCount() {
		; monitorNum := a_index
		; monitorGetWorkArea(monitorNum,&tmpMonLeft,&tmpMonTop,&tmpMonRight,&tmpMonBottom)
		; if tmpMonLeft < lowX
			; lowX := tmpMonLeft
		; if (tmpMonRight) > highX 
			; highX := tmpMonRight
		; if tmpMonTop < lowY
			; lowY := tmpMonTop
		; if (tmpMonBottom) > highY 
			; highY := tmpMonBottom
		; }
	; winGetPos(&guiX,&guiY,&guiW,&guiH,ui.mainGui)
	; if (guiX < lowX || cfg.guiX > highX)
		; cfg.guiX := 200
	; if (guiY < lowY || cfg.guiY > highY)
	; cfg.guiY := 200
		
	; ui.mainGui.move(cfg.guiX,cfg.guiY,,)	
	; if ui.afkDocked {
		; guiVis(ui.afkGui,true)
		; guiVis(ui.handleBarAfkGui,true)
	; } else {
		; guiVis(ui.mainGui,true)
		; guiVis(ui.titleBarButtonGui,true)
	; }
	
	; ui.AfkAnchoredToGui := true

	; debugLog("Showing Interface at x" cfg.GuiX " y" cfg.GuiY)
	
	; if ui.afkDocked {
		; guiVis(ui.afkGui,true)
		; guiVis(ui.HandlebarAfkGui,true)
		; WinSetTransparent(210,ui.AfkGui)
		; WinSetTransparent(210,ui.HandlebarAfkGui)
	; } else {
		; guiVis(ui.mainGui,true)
		; guiVis(ui.titleBarButtonGui,true)
		; tabsChanged()
	; }
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
		}
		case (ui.activeTab == "Setup"):
		{
			ControlFocus(ui.toggleColorSelector,ui.mainGui)
		}
	}
	ui.previousTab := ui.activeTab
	controlFocus(ui.buttonAfkHide)
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
	drawOutlineNamed("afkOutline1",ui.afkGui,5,104,240,28,cfg.themeBright1Color,cfg.themeBright2Color,2)
;	drawOutlineNamed("afkOutline2",ui.afkGui,178,38,67,58,cfg.themeBright1Color,cfg.themeBright2Color,2)
;	drawOutlineNamed("afkOutline3",ui.afkGui,240,40,67,58,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)
	drawOutlineNamed("afkGuiOutline",ui.afkGui,5,0,184,34,cfg.ThemeBright1Color,cfg.ThemeBright1Color,1)
	drawOutlineNamed("afkGuiOutline",ui.afkGui,6,1,182,32,cfg.ThemeDark1Color,cfg.ThemeDark1Color,1)
	drawOutlineNamed("mainOutline1",ui.mainGui,322,34,205,84,cfg.ThemeBright1Color,cfg.ThemeBright1Color,1)
	drawOutlineNamed("mainOutline2",ui.mainGui,322,122,205,84,cfg.ThemeBright1Color,cfg.ThemeBright1Color,1)
	drawOutlineNamed("win1statusRow",ui.afkGui,5,38,240,27,cfg.themeBright1Color,cfg.themeBright1Color,2)
	drawOutlineNamed("win2statusRow",ui.afkGui,5,72,240,27,cfg.themeBright1Color,cfg.themeBright1Color,2)
	

}
drawMainOutlines() {
ui.mainGuiTabs.useTab("")

	drawOutlineNamed("consolePanelOutline",ui.mainGui,35,150,498,6,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2) 	;Log Panel Outline
	drawOutlineNamed("consolePanelOutline2",ui.mainGui,35,220,498,184,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,1)		;Log Panel 3D Effect
}
drawOpsOutlines() {
	ui.mainGuiTabs.useTab("")
	drawOutlineNamed("bottomLine",ui.mainGui,37,208,492,4,cfg.themeBorderDarkColor,cfg.themeBorderLightColor,2)
	ui.mainGuiTabs.useTab("Sys")
	drawGridlines()
	drawOutlineNamed("tabsUnderline",ui.MainGui,35,29,502,3,cfg.ThemeBackgroundColor,cfg.ThemeBackgroundColor,2)
	drawOutlineNamed("opsClock",ui.mainGui,66,33,171,28,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,1)		;Ops Clock
	drawOutlineNamed("opsClock",ui.mainGui,67,34,169,26,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,1)	
	drawOutlineNamed("opsToolbarOutline2",ui.mainGui,36,33,494,30,cfg.ThemeBright1Color,cfg.ThemeBright1Color,1)		;Ops Toolbar Outline
	drawOutlineNamed("opsStatusBarRightDark",ui.mainGui,306,132,228,30,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)	;Status Bar
	drawOutlineNamed("opsStatusBarRightLight",ui.mainGui,306,131,227,32,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)	;Status Bar
	drawOutlineNamed("opsStatusBarLeftDark",ui.mainGui,34,132,227,30,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)	;Status Bar
	drawOutlineNamed("opsStatusBarLeftLight",ui.mainGui,33,131,228,32,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)	;Status Bar
	drawOutlineNamed("opsMiddleColumnOutlineLight",ui.mainGui,259,62,48,137,cfg.ThemeDark1Color,cfg.ThemeDark2Color,2)		;Ops Toolbar
	drawOutlineNamed("opsMiddleColumnMiddleRow",ui.mainGui,259,105,50,50,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,2)		;Ops Toolbar Outline
	drawOutlineNamed("opsMiddleColumnOutlineDark",ui.mainGui,258,62,52,139,cfg.ThemeBright1Color,cfg.ThemeBright2Color,2)		;Ops Toolbar Outline

	; drawOutlineNamed("opsBottomMiddleLine",ui.mainGui,259,198,49,2,cfg.themeBorderDarkColor,cfg.themeBorderDarkColor,2)
	; drawOutlineNamed("opsBottom2MiddleLine",ui.mainGui,258,200,51,2,cfg.themeBorderLightColor,cfg.themeBorderLightColor,2)
}

drawGridLines() {
ui.MainGuiTabs.UseTab("Sys")
	drawOutline(ui.MainGui,103,77,156,15,cfg.ThemeBright2Color,cfg.ThemeBright2Color,1)				;Win1 Info Gridlines  
	drawOutline(ui.MainGui,308,77,155,15,cfg.ThemeBright2Color,cfg.ThemeBright2Color,1)				;Win2 Info Gridlines
	drawOutline(ui.MainGui,308,62,155,72,cfg.ThemeBright1Color,cfg.ThemeBright1Color,2)	;WIn2 Info Frame
	drawOutline(ui.MainGui,103,62,156,72,cfg.ThemeBright1Color,cfg.ThemeBright1Color,2) ;Win1 Info Frame

}
ui.topDockEnabled := false
ui.topDocPrevTab	:= ""
toggleTopDock(*) {
		(ui.topDockEnabled := !ui.topDockEnabled)
			? topDockOn()
			: topDockOff()
	}
	
topDockOn() {
	ui.topDockPrevTab := ui.mainGuiTabs.Text
	ui.mainGuiTabs.choose(cfg.mainTabList[1])
	winSetTransparent(0,ui.titleBarButtonGui)
	transparent := 255
	while transparent > 20 {
		transparent -= 10
		winSetTransparent(transparent,ui.mainGui)
		sleep(10)
	}
	winSetTransparent(0,ui.mainGui)

	winGetPos(&vX,&vY,&vW,&vH,ui.mainGui)
	ui.prevGuiX := vX
	ui.prevGuiY := vY
	ui.prevGuiW := vW
	ui.prevGuiH := vH
	ui.mainGui.move((a_screenWidth/2)-(vW/2),-35,,63)
	winSetRegion("38-35 w490 h25",ui.mainGui)	
	while transparent < 170 {
		transparent += 10
		winSetTransparent(transparent, ui.mainGui)
		sleep(10)
	}
	guiVis(ui.titleBarButtonGui,false)
	winSetTransparent(180,ui.mainGui)
	ui.opsDockButton.opt("background" cfg.themeButtonOnColor)
}

topDockOff(*) {
	transparent := 255
	winSetTransparent(0,ui.titleBarButtonGui)
	while transparent > 10 {
		transparent -= 10
		winSetTransparent(transparent,ui.mainGui)
		sleep(10)
	}
	winSetTransparent(0,ui.mainGui)
	winSetTransColor("Off",ui.titleBarButtonGui)
	winSetRegion(,ui.mainGui)
	guiVis(ui.titleBarButtonGui,false)
	
	
	ui.mainGui.move(ui.prevGuiX,ui.prevGuiY,ui.prevGuiW,ui.prevGuiH)
	
while transparent < 245 {
		transparent += 10
		winSetTransparent(transparent, ui.mainGui)
		sleep(10)
	}
	winSetTransparent(255,ui.mainGui)
	ui.mainGuiTabs.choose(ui.topDockPrevTab)
	guivis(ui.titleBarbuttonGui,true)
	ui.opsDockButton.opt("background" cfg.themeButtonReadyColor)
}
