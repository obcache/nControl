#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)) {
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
	
	;ui.handleBarImage := ui.titleBarButtonGui.AddPicture("x0 y+3 w35 h214","./Img/handlebar_vertical.png")
	;ui.handleBarImage.OnEvent("DoubleClick",ToggleGuiCollapse)

	ui.DownButton := ui.titleBarButtonGui.AddPicture("x454 y0 w35 h35 section Background" cfg.ThemeFont1Color,"./Img/button_minimize.png")
	ui.DownButton.OnEvent("Click",HideGui)
	ui.DownButton.ToolTip := "Minimizes nControl App"

	ui.ExitButton 	:= ui.titleBarButtonGui.AddPicture("x+5 ys section w35 h35 Background" cfg.ThemeFont1Color,"./Img/button_quit.png")
	ui.ExitButton.OnEvent("Click",ExitButtonPushed)
	ui.ExitButton.ToolTip := "Terminates nControl App"
	
	ui.MainGui.MarginX := 0
	ui.MainGui.MarginY := 0
	ui.MainGui.SetFont("s13 c" cfg.ThemeFont1Color,"Calibri")
	ui.MainGuiTabs := ui.MainGui.AddTab3("x35 y1 w504 h214 Buttons -Redraw Background" cfg.ThemeBackgroundColor " -E0x200", ["Sys","AFK","Bindings","Dock","Setup","Audio"])
	ui.MainGuiTabs.OnEvent("Change",TabsChanged)
	ui.MainGuiTabs.Choose("AFK")
	ui.MainGuiTabs.UseTab("")
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri")
	ui.handleBarImage := ui.MainGui.AddPicture("x0 y-2 w35 h216","./Img/handlebar_vertical.png")
	ui.handleBarImage.OnEvent("DoubleClick",ToggleGuiCollapse)
	ui.handleBarImage.OnEvent("Click",WM_LBUTTONDOWN_callback)
	ui.rightHandlebarImage := ui.MainGui.AddPicture("x530 w35 y-2 h216 section","./Img/handlebar_vertical.png")
	;ui.rightHandlebarImage.OnEvent("DoubleClick",ToggleGuiCollapse)

	ui.gvConsole := ui.MainGui.AddListBox("x35 y220 w500 h192 +Background" cfg.ThemePanel1Color)
	ui.gvConsole.Color := cfg.ThemeBright1Color	

	afk 						:= Object()

	GuiAFKTab(&ui,&afk)

	GuiDockTab(&ui)
	GuiSetupTab(&ui,&cfg)
	;GuiSystemTab(&ui)	 
	GuiAudioTab(&ui,&audio)

	GuiOperationsTab(&ui,&cfg,&afk)

	if (FileExist("./Logs/persist.log"))
	{
		Loop Read, "./Logs/persist.log"
		{
			ui.gvConsole.Add([A_LoopReadLine])
		}
		FileDelete("./Logs/persist.log")
	}


	;drawOutlineTitleBarButtonGui(31,0,5,35,cfg.ThemeBright1Color,cfg.ThemeBright1Color,3)
	;drawOutlineTitleBarButtonGui(73,0,2,35,cfg.ThemeBright1Color,cfg.ThemeBright1Color,3)
	drawOutlineNamed("tabsUnderline",ui.MainGui,35,29,502,3,cfg.ThemeBackgroundColor,cfg.ThemeBackgroundColor,2)
	;drawOutlineMainGui(421,0,10,32,cfg.ThemeBackgroundColor,cfg.ThemeBackgroundColor,16)
	; drawOutlineNamed("mainGuiOutline",ui.MainGui,35,30,506,212,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,1)   	;Main Gui Outline
	drawOutlineNamed("afkGuiOutline",ui.afkGui,35,2,450,28,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,1)
	;drawOutlineMainGui(2,33,503,184,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,1)			;
	drawOutlineNamed("consolePanelOutline",ui.mainGui,35,220,498,184,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,1) 	;Log Panel Outline
	drawOutlineNamed("consolePanelOutline2",ui.mainGui,35,220,498,184,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,1)		;Log Panel 3D Effect
	;drawOutlineMainGui(438,3,63,30,cfg.ThemeBright1Color,cfg.ThemeBorderLightColor,2)			;Titlebar Buttons 3D Effect
		
	WinSetTransparent(0,ui.MainGui)
	WinSetTransparent(0,ui.titleBarButtonGui)
	
	ui.titleBarButtonGui.Show("x35" cfg.GuiX " y" cfg.GuiY-3 " w570 h218 NoActivate")
	ui.MainGui.Show("x" cfg.GuiX " y" cfg.GuiY " w569 h214 NoActivate")

	ui.MainGuiTabs.Choose("Sys")

	FadeIn()
	
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
	;drawOutline(ui.MainGui,534,0,35,214,cfg.ThemeBright2Color,cfg.ThemeBright2Color,2)

	;drawOutline(ui.titleBarButtonGui,0,3,35,214,cfg.ThemeBright2Color,cfg.ThemeBright2Color,2)
OnMessage(0x0200, WM_MOUSEMOVE)
OnMessage(0x0201, WM_LBUTTONDOWN)
OnMessage(0x47, WM_WINDOWPOSCHANGED)
}

guiAFKTab(&ui,&afk) {
	ui.MainGuiTabs.UseTab("AFK")
	;Any logic needed for the AFK tab beneath the docked AfkGui
	ui.Win1AfkRoutine := ui.MainGui.AddText("x362 y40 section w206 h81 Background" cfg.ThemePanel1Color,"")
	ui.Win2AfkRoutine := ui.MainGui.AddText("xs y+6 w206 h81 Background" cfg.ThemePanel1Color,"")
	ui.Win1AfkRoutine.SetFont("s10")
	ui.Win2AfkRoutine.SetFont("s10")
	drawOutlineAfkGui(240,40,67,58,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)
	drawOutlineMainGui(360,38,210,85,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)
	drawOutlineMainGui(360,125,210,85,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)
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
	
	ui.buttonUndockAfk := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 hidden Background" cfg.ThemeButtonAlertColor,"./Img/button_dockright_ready.png")
	ui.buttonUndockAfk.OnEvent("Click",ToggleAfkDock)
	ui.buttonUndockAfk.ToolTip := "Undocks AFK Window"

	ui.buttonPopout := ui.AfkGui.AddPicture("x+-15 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_popout_ready.png")
	ui.buttonPopout.OnEvent("Click",AfkPopoutButtonPushed)
	
	ui.Win1Label := ui.AfkGui.AddPicture("xs+15 y+4 section w35 h29","./Img/arrow_left.png")
	ui.AfkGui.SetFont("s12","Calibri")

	Afk.DataRow := Array()
	ui.ProfileList := Array()
	ui.ProfileListStr := ""
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

	ui.Win1ClassDDL := ui.AfkGui.AddDDL("x+10 ys w125 AltSubmit choose1 Background" cfg.ThemeEditboxColor, ui.ProfileList)
	ui.Win1ClassDDL.OnEvent("Change",RefreshWin1AfkRoutine)
	ui.AfkGui.SetFont("s14","Calibri")
	ui.Win1AfkIcon := ui.AfkGui.AddPicture("ys-2 w25 h25","./Img/sleep_icon.png")
	ui.Win1AfkStatus := ui.AfkGui.AddText("x+-1 ys+3 w35 +BackgroundTrans","")
	;ui.Win1Hwnd := ui.AfkGui.AddText("ys w60 hidden", "")

	ui.Win2Label := ui.AfkGui.AddPicture("xs2 y+7 section w35 h29","./Img/arrow_right.png")
	ui.AfkGui.SetFont("s12","Calibri")
	ui.Win2ClassDDL := ui.AfkGui.AddDDL("x+8 ys-2 w125 AltSubmit choose1 Background" cfg.ThemeEditboxColor, ui.ProfileList)
	ui.Win2ClassDDL.OnEvent("Change",RefreshWin2AfkRoutine)
	ui.AfkGui.SetFont("s14","Calibri")
	ui.Win2AfkIcon := ui.AfkGui.AddPicture("ys-2 w25 h25","./Img/sleep_icon.png")
	ui.Win2AfkStatus := ui.AfkGui.AddText("x+0 ys w35 +BackgroundTrans","")
	;ui.Win2Hwnd := ui.AfkGui.AddText("ys w60 hidden","")

	Loop ui.ProfileList.Length {
		if (cfg.Win1Class == ui.ProfileList[A_Index])
			ui.Win1ClassDDL.Choose(ui.ProfileList[A_Index])
	}
	
	Loop ui.ProfileList.Length {
		if (cfg.Win2Class == ui.ProfileList[A_Index])
			ui.Win2ClassDDL.Choose(ui.ProfileList[A_Index])
	}
	RefreshWin1AfkRoutine()
	RefreshWin2AfkRoutine()	
	
	ui.AfkGui.SetFont("s16 bold")  ; Set a large font size (32-point).
	ui.Title := ui.AfkGui.AddText("x5 y+13","")
	
	ui.AfkGui.AddPicture("x+-3 ys+31 w15 h40","./Img/label_left_trim.png")
	ui.AfkStatus1 := ui.AfkGui.AddPicture("x+0 ys+31 w100 h40 Background" cfg.ThemeButtonReadyColor,"./Img/label_timer_off.png")  ; XX & YY serve to auto-size the window.
	ui.AfkGui.AddPicture("x+0 ys+31 w15 h40","./Img/label_right_trim.png")
	
	ui.afkProgress := ui.AfkGui.AddProgress("xs y141 w236 h20 c" cfg.ThemeBright2Color " vTimerProgress Smooth Range0-270 Background858585 ",0)
	
	ui.AfkGui.Opt("+LastFound")
	WinSetTransparent(210)
	 
	OnMessage(0x0201, wmAfkLButtonDown)

	ui.AfkAnchoredToGui := true
	ui.HandlebarAfkGui := ui.AfkGui.AddPicture("x252 y35 w24 h170 section +Hidden","./Img/handlebar_vertical.png")
	ui.AfkGui.Opt("+LastFound")
	guiVis(ui.afkGui,false)
	ui.mainGui.getPos(&MainGuiX,&MainGuiY,,)
	drawOutlineAfkGui(14,138,240,24,cfg.ThemeBright1Color,cfg.ThemeBright2Color,2)
	drawOutlineAfkGui(190,36,67,58,cfg.ThemeBright1Color,cfg.ThemeBright2Color,2)
	ui.AfkGui.Show("x" MainGuix+45 " y" MainGuiY+35 " w300 h170 NoActivate")
}

toggleChange(name) {
	(%name%Enabled := !%name%Enabled) 
	? (%name%Toggle.Opt("Background" cfg.ThemeButtonOnColor)
		,cfg.toggleOn) 
	: (%name%Toggle.Opt("Background" cfg.ThemeButtonReadyColor)
		,cfg.toggleOff)
}
	
fadeIn() {
	if (cfg.AnimationsEnabled) {
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
			; WinSetTransparent(Round(Transparency),ui.opsGui)
			Sleep(1)
		}
	}
	
	ui.mainGui.getPos(&winX,&winY,,)
	ui.AfkGui.Move(winX+45,winY+35,,)
	ui.titleBarButtonGui.Move(winX+2,WinY-5)
	guiVis(ui.MainGui,true)
	guiVis(ui.titleBarButtonGui,true)
	; guiVis(ui.opsGui,true)
}

autoFireButtonClicked(*) {
	ToggleAutoFire()
}


toggleGuiCollapse(*) {
	(ui.GuiCollapsed := !ui.GuiCollapsed) ? CollapseGui() : UncollapseGui()

	CollapseGui() {
		guiVis(ui.titleBarButtonGui,false)
		; guiVis(ui.opsGui,false)
	
		if (cfg.AnimationsEnabled) {
			GuiWidth := cfg.GuiW
			While GuiWidth > 35 {
				ui.MainGui.Move(,,GuiWidth,)
				GuiWidth -= 10
			}	
		}
		ui.MainGui.Move(,,35,)
	}
	
	UncollapseGui() {
		GuiWidth := 0
		if (cfg.AnimationsEnabled) {
			While GuiWidth < 567 {
				ui.MainGui.Move(,,GuiWidth,)
				GuiWidth += 10
			}
		}
		ui.MainGui.Move(,,567,)
		guiVis(ui.titleBarButtonGui,true)
		; guiVis(ui.opsGui,true)
	}
}

toggleAfkDock(*) {
	(ui.AfkDocked := !ui.AfkDocked) 
	? dockAfkGui() 
	: undockAfkGui()
}


dockAfkGui(*) {
	; guiVis(ui.opsGui,false)
	guiVis(ui.mainGui,false)

	ui.AfkAnchoredToGui := false
	WinGetPos(&GuiPrevX,&GuiPrevY,,,ui.mainGui)
	ui.GuiX := GuiPrevX
	ui.GuiY := GuiPrevY
	
	ui.buttonDockAfk.Opt("Hidden")
	ui.buttonUndockAfk.Opt("-Hidden")
	ui.HandlebarAfkGui.Opt("-Hidden")
	ui.buttonPopout.Opt("+Hidden")
	ui.buttonStartAFK.Move(3,3)
	ui.buttonTower.Move(33,3)
	ui.buttonAntiIdle1.Move(63,3)
	ui.buttonAutoFire.Move(93,3)
	ui.buttonAutoClicker.Move(123,3)
	ui.buttonUndockAfk.Move(252,3)
	ui.downButton.Move(3,3)
	ui.exitButton.Move(43,3)
	WinGetPos(&AfkGuiX,&AfkGuiY,&AfkGuiW,&AfkGuiH,ui.afkGui)
	ui.AfkGui.Move(0,A_ScreenHeight-ui.TaskbarHeight-AfkGuiH,300,)	
	ui.titleBarButtonGui.Opt("Owner" ui.AfkGui.Hwnd)
	ui.titleBarButtonGui.Move(AfkGuiX+162,AfkGuiY-5,109)
	guiVis(ui.titleBarButtonGui,true)
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
	ui.titleBarButtonGui.Move(winX+1,WinY-5,570,)
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
		ui.buttonPopout.move(255,3)
		WinGetPos(&AfkGuiX,&AfkGuiY,&AfkGuiW,&AfkGuiH,ui.afkGui)
		ui.afkGui.move(afkGuiX,afkGuiY,300,)
		WinSetTransparent(210,ui.AfkGui)
		ui.titleBarButtonGui.Opt("Owner" ui.AfkGui.Hwnd)
		ui.titleBarButtonGui.Move(AfkGuiX+180,AfkGuiY-7,109,40)
		guiVis(ui.titleBarButtonGui,true)
		ui.HandlebarAfkGui.Opt("-Hidden")
		ui.AfkAnchoredToGui := false
		controlFocus(ui.buttonPopout)
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
		ui.AfkGui.Move(winX+30,winY+35,,)
		ui.titleBarButtonGui.Move(winX+1,WinY-5,570,)
		; ui.opsGui.Move(winX,winY)
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
	ExitApp
}

hideGui(*) {
	SaveGuiPos()
	WinSetTransparent(0,ui.MainGui)
	if ui.AfkAnchoredToGui = true
	{
		WinSetTransparent(0,ui.AfkGui)
		WinSetTransparent(0,ui.titleBarButtonGui)
		WinSetTransparent(0,ui.HandlebarAfkGui)
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

	ui.mainGuiTabs.Choose(ui.previousTab)
	ui.HandlebarAfkGui.Opt("+Hidden")
	ui.buttonAfkHide.opt("+hidden")
	ui.AfkAnchoredToGui := true
	ui.AfkDocked := false
	guiVis(ui.mainGui,true)
	guiVis(ui.titleBarButtonGui,true)

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

dockApps(*) {
	global
	ui.dockApp_enabled := !ui.dockApp_enabled
	
	if (ui.dockApp_enabled)
	{
		ui.ButtonDockApps.Value := "./Img/button_on.png"
		SetTimer(UnpushButton,500)
		ui.buttonDockApps.Opt("Background" cfg.ThemeButtonOnColor)
		nControl("On",&cfg)
	} else {
		ui.ButtonDockApps.Value := "./Img/button_on.png"
		SetTimer(UnpushButton,500)
		ui.buttonDockApps.Opt("Background" cfg.ThemeButtonAlertColor)
		nControl("Off",&cfg)
	}
	
	UnpushButton(*) {
		ui.buttonDockApps.Value := "./Img/button_ready.png"
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
	
	Switch {
		case (ui.activeTab == "Sys"): 
		{
			guiVis(ui.afkGui,false)
			;WinSetTransparent(0,ui.afkGui)
			; guiVis(ui.opsGui,true)
			; WinSetTransparent(255,ui.opsGui)
			; WinSetTransparent("Off",ui.OpsGui)
			; WinSetTransColor(ui.TransparentColor,ui.OpsGui)
		}
		case (ui.activeTab == "AFK"):
		{
			; WinSetTransparent(0,ui.opsGui)
			WinSetTransparent(255,ui.afkGui)
		}
		case (ui.activeTab == "Bindings") || (ui.activeTab == "Audio"):
		{
			ui.MainGuiTabs.Choose(ui.previousTab)
			SetTimer(BindingsDisabled,-1)
			BindingsDisabled() {
				notifyOSD("Tab currently disabled `nby developer",2500)
			}
			Return				
		}
		case (ui.activeTab == "Setup"):
		{
			; WinSetTransparent(0,ui.opsGui)
			WinSetTransparent(0,ui.afkGui)
			ControlFocus(ui.toggleColorSelector,ui.mainGui)
		}
		default:
		{
			; WinSetTransparent(0,ui.opsGui)
			WinSetTransparent(0,ui.AfkGui)
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