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
	;ui.mainGui.addPicture("x0 y0 w600	h220","./img/mainBg.png")
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
	ui.win1statusBg := ui.afkGui.addText("x5 y38 w85 h25 background" cfg.themeEditboxColor,"")
	ui.win2statusBg := ui.afkGui.addText("x5 y72 w85 h25 background" cfg.themeEditboxColor,"")
	

	ui.buttonDockAfk := ui.AfkGui.AddPicture("x7 y2 w30 h30 section Background" cfg.ThemeButtonReadyColor,"./Img/button_dockLeft_ready.png")
	ui.buttonDockAfk.OnEvent("Click",ToggleAfkDock)
	ui.buttonDockAfk.ToolTip := "Dock AFK Panel"	
	
	ui.buttonStartAFK := ui.AfkGui.AddPicture("x+0 y2 section w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_afk_ready.png")
	ui.buttonStartAFK.OnEvent("Click",ToggleAFK)
	ui.buttonStartAFK.ToolTip := "Toggle AFK"
	
	ui.buttonTower := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 section Background" cfg.ThemeButtonReadyColor,"./Img/button_tower_ready.png")
	ui.buttonTower.OnEvent("Click",ToggleTower)
	ui.buttonTower.ToolTip := "Starts Infinte Tower"
	
	ui.buttonAutoClicker := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_AutoClicker_ready.png")
	ui.buttonAutoClicker.OnEvent("Click",ToggleAutoClicker)
	ui.buttonAutoClicker.ToolTip := "Toggles AutoClicker"
	ui.buttonAntiIdle1 := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 hidden Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
	ui.buttonAntiIdle1.OnEvent("Click",ToggleAntiIdleBoth)
	ui.buttonAntiIdle1.ToolTip := "Toggles AntiIdle Mode On/Off"
	
	ui.buttonAutoFire := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 hidden Background" cfg.ThemeButtonReadyColor,"./Img/button_AutoFire_ready.png")
	ui.buttonAutoFire.OnEvent("Click",toggleAutoFire)
	ui.buttonAutoFire.ToolTip := "Toggles AutoFire on Current Window"
	



	ui.buttonAfkHide := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 hidden Background" cfg.ThemeButtonReadyColor,"./Img/button_hide.png")
	ui.buttonAfkHide.OnEvent("Click",HideAfkGui)
	hideAfkGui(*) {
		guiVis(ui.afkGui,false)
	}
	ui.buttonAfkHide.ToolTip := "Minimizes AFK Window to System Tray"
	
	ui.buttonPopout := ui.AfkGui.AddPicture("x+-0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_popout_ready.png")
	ui.buttonPopout.OnEvent("Click",AfkPopoutButtonPushed)
	
	ui.Win1Label := ui.AfkGui.AddPicture("x6 y+8 section w25 h23 background" cfg.themeEditboxColor,"./Img/arrow_left.png")

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
	ui.Title := ui.AfkGui.AddText("x0 y+13","")
	ui.AfkGui.SetFont("s16 bold")  ; Set a large font size (32-point).
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
		guiVis(ui.titleBarButtonGui,false)
		guiVis(ui.gameSettingsGui,false)
		guiVis(ui.afkGui,false)
		While Transparency < 253
		{
			Transparency += 2.5
			WinSetTransparent(Round(Transparency),ui.MainGui)			
			Sleep(1)
		}
	}
	guiVis(ui.mainGui,true)
	winGetPos(&mainGuiX,&mainGuiY,,,ui.mainGui)
	drawAfkOutlines()		
	ui.titleBarButtonGui.Move(mainGuiX,mainGuiY-5)
	ui.gameSettingsGui.show("x" mainGuiX+35 " y" mainGuiY+35 " w495 h170 noActivate")
	ui.AfkGui.Show("x" mainGuiX+40 " y" mainGuiY+50 " w280 h140 NoActivate")
	; guiVis(ui.MainGui,true)
	guiVis(ui.titleBarButtonGui,true)

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
			ui.MainGui.Move(mainX,mainY,GuiWidth,)
			GuiWidth -= 30
			sleep(20)
		}	
	}
	ui.MainGui.Move(mainX,mainY,35,)
}

redrawGuis(GuiWidth,mainX,mainY) {
	
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
			ui.MainGui.Move(mainX,mainY,GuiWidth,)
			GuiWidth += 30
			sleep(20)
		}
	}
	ui.mainGui.move(,,562,)
	winGetPos(&mainX,&mainY,&mainW,&mainH,ui.mainGui)
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
	savePrevGuiPos()
	ui.topDockEnabled := false
	ui.AfkDocked := true
	ui.AfkAnchoredToGui := false
	ui.titleBarButtonGui.Opt("Owner" ui.AfkGui.Hwnd)
	ui.mainGui.opt("owner" ui.afkGui.hwnd)
	guiVis(ui.mainGui,false)
	guiVis(ui.titleBarButtonGui,false)	
	ui.AfkGui.Move(0,A_ScreenHeight-ui.TaskbarHeight-134,272,134)
	winGetPos(&AfkGuiX,&AfkGuiY,,,ui.afkGui)
	ui.titleBarButtonGui.move(afkGuiX+185,afkGuiY,90,50)
	ui.mainGui.move(afkGuiX-45,afkGuiX-35)
	ui.handleBarAfkGui.move(245,35,25,100)
	ui.buttonDockAfk.opt("background" cfg.themeButtonAlertColor)
	ui.buttonDockAfk.value := "./img/button_dockright_ready.png"
	ui.handleBarAfkGui.opt("-hidden")
	ui.buttonPopout.Opt("Hidden")
	ui.downButton.opt("hidden")
	guiVis(ui.afkGui,true)
	guiVis(ui.titleBarButtonGui,true)
	WinGetPos(&AfkGuiX,&AfkGuiY,&AfkGuiW,&AfkGuiH,ui.afkGui)
	WinSetTransparent(210,ui.AfkGui)
	WinSetTransparent(210,ui.HandlebarAfkGui)
	controlFocus(ui.buttonUndockAfk)

	; ui.buttonUndockAfk.Opt("-Hidden")

	; ui.exitButton.Move(10,0)
	;ui.buttonUndockAfk.Move(49,0)
}
	
undockAfkGui(*) {
	ui.AfkAnchoredToGui := true
	ui.AfkDocked := false
	ui.titleBarButtonGui.Opt("Owner" ui.MainGui.Hwnd)
	ui.afkGui.opt("Owner" ui.mainGui.hwnd)	
	cfg.guiX := ui.prevGuiX
	cfg.guiY := ui.prevGuiY
	ui.buttonDockAfk.opt("background" cfg.themeButtonOnColor)
	ui.buttonDockAfk.value := "./img/button_dockLeft_ready.png"
	ui.mainGui.move(cfg.guiX,cfg.guiY)
	ui.AfkGui.Move(cfg.guiX+40,cfg.guiY+50,,)
	ui.titleBarButtonGui.Move(cfg.guiX,cfg.guiY-5,575,220)
	ui.gameSettingsGui.move(cfg.guiX+35,cfg.guiY+35)
	ui.HandlebarAfkGui.Opt("Hidden")	
	ui.buttonPopout.Opt("-Hidden")
	ui.downButton.opt("-hidden")
	; ui.downButton.Move(456,0)
	; ui.exitButton.Move(494,0)

	; IniWrite(cfg.GuiX,"nControl.ini","Interface","GuiX")
	; IniWrite(cfg.GuiY,"nControl.ini","Interface","GuiY")
	; guiVis(ui.opsGui,true)
	; ui.buttonDockAfk.Opt("-Hidden")
	; ui.buttonUndockAfk.Opt("Hidden")
	; ui.buttonDockAfk.Move(6,2)
	; ui.buttonStartAFK.Move(36,2)
	; ui.buttonTower.Move(66,2)
	; ui.buttonAntiIdle1.Move(96,2)
	; ui.buttonAutoFire.Move(126,2)
	; ui.buttonAutoClicker.Move(156,2)
	; ui.buttonPopout.move(217,2)
	; ui.opsGui.Move(winX,winY)

	guiVis(ui.titleBarButtonGui,true)
	;ui.mainGui.move(ui.prevGuiX,ui.prevGuiY)
	if !(ui.MainGuiTabs.Text == "AFK")
	{
		guiVis(ui.afkGui,false)
		AfkPopoutButtonPushed()
	} else {
		guiVis(ui.afkGui,true)
	}
	guiVis(ui.mainGui,true)
	ui.mainGuiTabs.choose("AFK")
	controlFocus(ui.buttonDockAfk)
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

	ui.gamingModeLabel := ui.exitMenuGui.addText("x0 y2 w72 h15 center background" cfg.themePanel3color " c" cfg.themeFont2Color," Gaming Mode")
	ui.gamingModeLabel.setFont("s8")
	ui.gamingLabels := ui.exitMenuGui.addText("x0 y16 w72 h52 center background" cfg.themePanel3color " c" cfg.themeFont3Color," Stop   Start ")
	ui.gamingLabels.setFont("s10")
	ui.stopGamingButton := ui.exitMenuGui.addPicture("x0 y32 section w35 h35 background" cfg.themeFont2Color,"./img/button_quit.png")
	ui.startGamingButton := ui.exitMenuGui.addPicture("x+2 ys w35 h35 background" cfg.themeFont2Color,"./img/button_exit_gaming.png")
	ui.stopGamingButton.onEvent("Click",exitAppCallback)
	ui.startGamingButton.onEvent("Click",stopGaming)
	WinSetTransColor(ui.transparentColor,ui.exitMenuGui)
	drawOutlineNamed("exitMenuBorder",ui.exitMenuGui,0,0,74,68,cfg.themeFont3Color,cfg.themeFont3Color,2)
	ui.exitMenuGui.show("x" tbX+470 " y" tbY-70 " AutoSize noActivate")
	
	exitAppCallback(*) {
		ExitApp
	}
}

hideGui(*) {
	saveGuiPos()
	winMinimize(ui.mainGui)
	debugLog("Hiding Interface")
}

savePrevGuiPos(*) {
	winGetPos(&prevGuiX,&prevGuiY,,,ui.mainGui)
	ui.prevGuiX := prevGuiX
	ui.prevGuiY := prevGuiY
}

saveGuiPos(*) {
	Global
	winGetPos(&GuiX,&GuiY,,,ui.MainGui)
	cfg.GuiX := GuiX
	cfg.GuiY := GuiY
	IniWrite(cfg.GuiX,cfg.file,"Interface","GuiX")
	IniWrite(cfg.GuiY,cfg.file,"Interface","GuiY")
	debugLog("Saving Window Location at x" GuiX " y" GuiY)
}

showGui(*) {
	detectHiddenWindows(true)
	winActivate(ui.mainGui)
	winRestore(ui.mainGui)
	ui.mainGui.move(cfg.GuiX,cfg.GuiY)	
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
		winGetPos(&GuiX,&GuiY,&GuiW,&GuiH,ui.mainGui)
		;MsgBox(GuiX "`n" GuiY "`n" GuiW "`n" GuiH)
		debugLog("Showing Log")
	} else {
		cfg.ConsoleVisible := false
		ui.ButtonDebug.Value := "./Img/button_console_ready.png"
		ui.ButtonDebug.Opt("Background" cfg.ThemeButtonReadyColor)

		winGetPos(&GuiX,&GuiY,&GuiW,&GuiH,ui.mainGui)
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

{ ;BEGIN = outline parameters
	drawAfkOutlines() {	
	ui.mainGuiTabs.UseTab("AFK")
		drawOutlineNamed("afkToolbarOutline",ui.afkGui,5,0,123,34,cfg.ThemeBright1Color,cfg.ThemeBright1Color,1)
		drawOutlineNamed("win1statusRow",ui.afkGui,5,38,240,27,cfg.themeBright1Color,cfg.themeBright1Color,2)
		drawOutlineNamed("win2statusRow",ui.afkGui,5,72,240,27,cfg.themeBright1Color,cfg.themeBright1Color,2)
		drawOutlineNamed("afkTimeStatusOutline",ui.afkGui,5,104,240,28,cfg.themeBright1Color,cfg.themeBright2Color,2)
		drawOutlineNamed("afkRoutine1Outline",ui.mainGui,322,34,205,84,cfg.ThemeBright1Color,cfg.ThemeBright1Color,1)
		drawOutlineNamed("afkRoutine2Outline",ui.mainGui,322,122,205,84,cfg.ThemeBright1Color,cfg.ThemeBright1Color,1)

}

	drawMainOutlines() {
	ui.mainGuiTabs.useTab("")
		drawOutlineNamed("consolePanelOutline",ui.mainGui,35,150,498,6,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2) 		;Log Panel Outline
		drawOutlineNamed("consolePanelOutline2",ui.mainGui,35,220,498,184,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,1)		;Log Panel 3D Effect
	}

	drawOpsOutlines() {
		ui.mainGuiTabs.useTab("")
		drawOutlineNamed("bottomLine",ui.mainGui,36,211,494,2,cfg.themeBright2Color,cfg.themeBright2Color,1)
		drawOutlineNamed("bottomLine",ui.mainGui,36,208,494,3,cfg.themeBright1Color,cfg.themeBright1Color,2)
		ui.mainGuiTabs.useTab("Sys")
		drawGridlines()
		drawOutlineNamed("tabsUnderline",ui.MainGui,35,29,502,3,cfg.ThemeBackgroundColor,cfg.ThemeBackgroundColor,2)
		drawOutlineNamed("opsClock",ui.mainGui,103,33,139,28,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)		;Ops Clock
		drawOutlineNamed("opsClock",ui.mainGui,325,33,138,28,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)		;Ops Clock
		drawOutlineNamed("opsToolbarOutline2",ui.mainGui,36,33,494,30,cfg.ThemeBright1Color,cfg.ThemeBright1Color,1)	;Ops Toolbar Outline

		drawOutlineNamed("opsMiddleColumnOutlineLight",ui.mainGui,259,62,51,141,cfg.themeDark1Color,cfg.themeDark1Color,2)		;Ops Toolbar
		drawOutlineNamed("opsMiddleColumnOutlineDark",ui.mainGui,258,62,53,141,cfg.themeBright1Color,cfg.themeBright1Color,2)	;Ops Toolbar Outline
		drawOutlineNamed("opsMiddleColumnOutlineDark",ui.mainGui,258,62,50,141,cfg.themeBright1Color,cfg.themeBright1Color,1)	;Ops Toolbar Outline
		drawOutlineNamed("opsAfkStatusLeft",ui.mainGui,36,107,66,24,cfg.themeBright1Color,cfg.themeBright1Color,1)
		drawOutlineNamed("opsAfkStatusRight",ui.mainGui,464,107,66,24,cfg.themeBright1Color,cfg.themeBright1Color,1)	
		drawOutlineNamed("opsAfkStatusLeft",ui.mainGui,36,132,66,30,cfg.themeBright1Color,cfg.themeBright1Color,1)
		drawOutlineNamed("opsAfkStatusRight",ui.mainGui,464,132,66,30,cfg.themeBright1Color,cfg.themeBright1Color,1)
	}

	drawGridLines() {
	ui.MainGuiTabs.UseTab("Sys")
		drawOutline(ui.MainGui,103,77,157,15,cfg.ThemeBright2Color,cfg.ThemeBright2Color,1)		;Win1 Info Gridlines  
		drawOutline(ui.MainGui,308,77,155,15,cfg.ThemeBright2Color,cfg.ThemeBright2Color,1)		;Win2 Info Gridlines
		drawOutline(ui.MainGui,308,62,155,100,cfg.ThemeBright1Color,cfg.ThemeBright1Color,2)	;WIn2 Info Frame
		drawOutline(ui.MainGui,103,62,157,100,cfg.ThemeBright1Color,cfg.ThemeBright1Color,2) 	;Win1 Info Frame

	}
} ;END - outline parameters


tabsChanged(*) {
	ui.activeTab := ui.mainGuiTabs.Text
	cfg.activeMainTab := ui.mainGuiTabs.value

	switch ui.activeTab {
		case "AFK":
			guiVis(ui.mainGui,true)
			guiVis(ui.afkGui,true)
			guiVis(ui.gameSettingsGui,false)
			controlFocus(ui.buttonTower,ui.afkGui)
			
		case "Game":
			guiVis(ui.mainGui,true)
			guiVis(ui.gameSettingsGui,true)
			guiVis(ui.afkGui,false)
			controlFocus(ui.d2AlwaysRun,ui.gameSettingsGui)
		default:
			guiVis(ui.gameSettingsGui,false)
			guiVis(ui.afkGui,false)
			guiVis(ui.mainGui,true)
			controlFocus(ui.mainGuiTabs,ui.mainGui)
		} 
		ui.previousTab := ui.activeTab	
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

ui.dockBarWidth := 0

createDockBar() {
	ui.dockBarGui := gui()
	ui.dockBarGui.opt("alwaysOnTop owner" ui.mainGui.hwnd " -caption")
	ui.dockBarGui.backColor := cfg.themeBackgroundColor
	ui.dockBarGui.color := cfg.themeBackgroundColor
	guiVis(ui.dockBarGui,false)
	ui.dockBarWidth := 0
	ui.dockBarGui.SetFont("s14","Calibri Thin")
	ui.dockOpsDockButton := ui.dockBarGui.AddPicture("x1 y0 w25 h25 section Background" cfg.ThemeButtonReadyColor,"./Img/button_dockLeft_ready.png")
	ui.dockOpsDockButton.OnEvent("Click",toggleAfkDock)
	ui.dockOpsDockButton.ToolTip 		:= "Dock AFK Panel"
	ui.dockBarWidth += 26
	
	ui.docktopDockButton := ui.dockBarGui.addPicture("x+0 ys w25 h25 section background" cfg.themeButtonOnColor,"./img/button_dockDown_ready.png")
	ui.docktopDockButton.onEvent("click",topDockOff)
	ui.docktopDockButton.toolTip := "Dock to top of screen"
	ui.dockBarWidth += 25
	ui.dockAutoClicker 		:= ui.dockBarGui.addPicture("x+0 ys w25 h25 section background" cfg.themeButtonReadyColor,"./img/button_AutoClicker_ready.png")
	ui.dockAutoClicker.onEvent("click", ToggleAutoClicker)
	ui.dockAutoClicker.ToolTip := "AutoClicker Status. (Use settings screen to adjust timing)"
	ui.dockBarWidth += 25
	ui.dockPadBar1 			:= ui.dockBarGui.addText("x+0 ys w1 h25 section background" cfg.themeBright1Color,"")
	ui.dockBarWidth += 1
	ui.dockBarWin1Icon		:= ui.dockBarGui.addPicture("x+0 ys w25 h25 section background" cfg.themePanel1Color,"./img/sleep_icon.png")
	ui.dockBarWidth	+= 25
	ui.dockBarWin1Cmd		:= ui.dockBarGui.addText("x+0 ys w25 h25 section center background" cfg.themePanel3Color " c" cfg.themeFont3Color,"--")
	ui.dockBarWin1Cmd.setFont("s14")
	ui.dockBarWidth += 25
	ui.dockBarGui.addPicture("x+0 ys w25 h25 section background" cfg.themeBackgroundColor,"./img/arrow_left.png")
	ui.dockBarWidth += 25
	; ui.dockBarGamelabel		:= ui.dockBarGui.addText("x+0 ys w40 h25 section backgroundTrans c" cfg.themeButtonOnColor,"AFK")
	; ui.dockBarGamelabel.setFont("s14")
	; ui.dockBarWidth += 40
	ui.dockGameDDL := ui.dockBarGui.AddDropDownList("x+0 ys-1 w137 Background" cfg.ThemeEditboxColor " -E0x200 Choose" cfg.game,cfg.GameList)
	ui.dockBarWidth += 137
	ui.dockGameDDL.ToolTip := "Select the Game You Are Playing"
	ui.dockGameDDL.OnEvent("Change",ChangeDockGameDDL)
	ui.dockGameDDL.SetFont("s11.8 c" cfg.ThemeFont1Color)

	postMessage("0x153", -1, 20,, "AHK_ID " ui.gameDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153
	postMessage("0x153", 0, 20,, "AHK_ID " ui.gameDDL.Hwnd ) ; CB_SETITEMHEIGHT = 0x153

ui.dockBarGui.addPicture("x+0 ys w25 h25 section backgroundTrans","./img/arrow_right.png")
	ui.dockBarWidth += 25
	ui.dockBarWin2Cmd		:= ui.dockBarGui.addText("x+0 ys w25 h25 section center background" cfg.themePanel3Color " c" cfg.themeFont3Color," --")
	ui.dockBarWidth += 25
	ui.dockbarWin2Icon		:= ui.dockBarGui.addPicture("x+0 ys w25 h25 background" cfg.themePanel1Color,"./img/sleep_icon.png")
	ui.dockBarWidth += 25

	
}
showDockBar() {
	
		winGetPos(&tmpX,&tmpY,&tmpW,&tmpH,ui.mainGui)
		ui.dockBarGui.show("x" (a_ScreenWidth/2)-(ui.dockBarWidth/2) " y0 w" ui.dockBarWidth " h26 noActivate")
		drawOutlineNamed("dockBarOutline",ui.dockBarGui,0,0,ui.dockBarWidth,26,cfg.themeBorderLightColor,cfg.themeBorderDarkColor,1)
	if (cfg.topDockEnabled) {
	guiVis(ui.dockBarGui,true)
	}
}

dockBarIcons(game,operation := "") {
	if (operation == "Add") {
		switch game {
			case "Shatterline":
				;TBD
			case "Destiny 2":
				; ui.dockBarD2label := ui.dockbarGui.addText("ys w35 h25 section c" cfg.themeFont2color " background" cfg.themeEditboxColor,"D2")
				; ui.dockBarWidth += 35
				; ui.dockBarD2label.setFont("s14")
				ui.dockBarRunIcon := ui.dockBarGui.addPicture("x+-2 ys w25 h25 section background" cfg.themeDisabledColor, 
				"./img/icon_running.png")
				ui.dockBarWidth += 23
				ui.dockBarRunIcon.opt("Background" cfg.ThemeButtonAlertColor)
					
				ui.dockBarD2AlwaysRun := ui.dockBarGui.addPicture("x+0 ys w30 h25 section vd2AlwaysRun " 
				((cfg.d2AlwaysRunEnabled) 
					? ("Background" cfg.ThemeButtonOnColor) 
						: ("Background" cfg.themeButtonReadyColor)),
				((cfg.d2AlwaysRunEnabled) 
					? ("./img/toggle_vertical_trans_on.png") 
						: ("./img/toggle_vertical_trans_off.png")))			
				ui.dockBarWidth += 30
			case "World//Zero":
				; ui.dockBarW0label		:= ui.dockBarGui.addText("x+0 ys w35 h25 section background" cfg.themeEditboxColor " c" cfg.themeFont2Color,"W0")
				; ui.dockBarW0label.setFont("s14")
				; ui.dockBarWidth += 35
				ui.dockBarAfkButton 	:= ui.dockBarGui.addPicture("x+0 ys w25 h25 section background" cfg.themeButtonReadyColor,ui.buttonStartAfk.value)
				ui.dockBarWidth += 25
				ui.dockBarTowerButton	:= ui.dockBarGui.addPicture("x+0 ys w25 h25 section background" cfg.themeButtonReadyColor,ui.buttonTower.value)
				ui.dockBarWidth += 25
				((ui.towerEnabled) 
					? ("Background" cfg.ThemeButtonOnColor) 
						: ("Background" cfg.themeButtonReadyColor),
				((ui.towerEnabled) 
					? ("./img/toggle_vertical_trans_on.png") 
						: ("./img/toggle_vertical_trans_off.png")))
						
				ui.dockBarAfkButton.onEvent("click",dockToggleAfk)
				ui.dockBarTowerButton.onEvent("click",dockToggleTower)
				dockToggleAfk(*) {
					toggleAfk()
					controlFocus(ui.dockBarTowerButton)
				}
				dockToggleTower(*) {
					toggleTower()
					controlFocus(ui.dockBarTowerButton)
				}
			case "Clear": 
				ui.dockBarGui.destroy()
				createDockBar()
		}
	}
}



ui.topDocPrevTab	:= ""

toggleTopDock(*) {
		(cfg.topDockEnabled := !cfg.topDockEnabled)
			? topDockOn()
			: topDockOff()
}
	
topDockOn(*) {
	showDockBar()
	cfg.topDockEnabled := true
	saveGuiPos()
	guiVis(ui.titleBarButtonGui,false)
	transparent := 255
	while transparent > 20 {
		transparent -= 10
		winSetTransparent(transparent,ui.mainGui)
		sleep(10)
	}
	guiVis(ui.mainGui,false)
	
	try {	
		winGetPos(&vX,&vY,&vW,&vH,ui.mainGui)
		ui.prevGuiX := vX
		ui.prevGuiY := vY
		ui.prevGuiW := vW
		ui.prevGuiH := vH
	}
	
	while transparent < 245 {
		transparent += 10
		winSetTransparent(transparent, ui.dockBarGui)
		sleep(10)
	}
	ui.opsDockButton.opt("background" cfg.themeButtonOnColor)
	guiVis(ui.dockBarGui,true)
}

topDockOff(*) {
	cfg.topDockEnabled := false
	guiVis(ui.titleBarButtonGui,false)
	transparent := 255

	while transparent > 10 {
		transparent -= 10
		winSetTransparent(transparent,ui.dockBarGui)
			sleep(10)
	}
	guiVis(ui.dockBarGui,false)
	guiVis(ui.mainGui,false)
	
	winSetTransparent(0,ui.mainGui)
	
	while transparent < 245 {
		transparent += 10
		winSetTransparent(transparent, ui.mainGui)
		sleep(10)
	}
	;guiVis(ui.mainGui,true)
	;ui.mainGuiTabs.choose(ui.topDockPrevTab)
	guivis(ui.titleBarbuttonGui,true)
	ui.opsDockButton.opt("background" cfg.themeButtonReadyColor)
	ui.titleBarButtonGui.Show("x" cfg.GuiX " y" cfg.GuiY-5 " w562 h218 NoActivate")
	
}


