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

	ui.DownButton 	:= ui.titleBarButtonGui.AddPicture("x458 y0 w35 h35 section Background" cfg.ThemeFont1Color,"./Img/button_minimize.png")
	ui.DownButton.OnEvent("Click",HideGui)
	ui.DownButton.ToolTip := "Minimizes nControl App"

	ui.ExitButton 	:= ui.titleBarButtonGui.AddPicture("x+3 ys section w35 h35 Background" cfg.ThemeFont1Color,"./Img/button_quit.png")
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
	ui.rightHandlebarImage := ui.MainGui.AddPicture("x535 w35 y-2 h216 section","./Img/handlebar_vertical.png")
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
	drawOutlineMainGui(35,29,500,3,cfg.ThemeBackgroundColor,cfg.ThemeBackgroundColor,2)
	;drawOutlineMainGui(421,0,10,32,cfg.ThemeBackgroundColor,cfg.ThemeBackgroundColor,16)
	drawOutlineMainGui(35,0,500,214,cfg.ThemeBright1Color,cfg.ThemeBright2Color,2)   	;Main Gui Outline
	drawOutlineAfkGui(37,2,498,28,cfg.ThemeBright1Color,cfg.ThemeBright2Color,1)
	;drawOutlineMainGui(2,33,503,184,cfg.ThemeBright1Color,cfg.ThemeBright2Color,1)			;
	drawOutlineMainGui(35,218,532,184,cfg.ThemeBright1Color,cfg.ThemeBright2Color,1) 	;Log Panel Outline
	drawOutlineMainGui(37,220,532,187,cfg.ThemeBright1Color,cfg.ThemeBright2Color,1)		;Log Panel 3D Effect
	;drawOutlineMainGui(438,3,63,30,cfg.ThemeBright1Color,cfg.ThemeBright2Color,2)			;Titlebar Buttons 3D Effect
	
	
	WinSetTransparent(0,ui.MainGui)
	WinSetTransparent(0,ui.titleBarButtonGui)
	
	ui.titleBarButtonGui.Show("x35" cfg.GuiX " y" cfg.GuiY-3 " w570 h218 NoActivate")
	ui.MainGui.Show("x" cfg.GuiX " y" cfg.GuiY " w569 h214 NoActivate")

	ui.MainGuiTabs.Choose("Sys")

	if (cfg.AnimationsEnabled) {
		Transparency := 0
		While Transparency < 253
		{
			Transparency += 2.5
			WinSetTransparent(Round(Transparency),ui.MainGui)
			;WinSetTransparent(Round(Transparency),ui.titleBarButtonGui)
			Sleep(1)
		}
	}
	WinSetTransparent(255,ui.MainGui)
	WinSetTransparent(255,ui.titleBarButtonGui)
	WinSetTransparent("Off",ui.MainGui)	
	WinSetTransparent("Off",ui.titleBarButtonGui)	
	WinSetTransColor(ui.TransparentColor ,ui.titleBarButtonGui)
	WinSetTransColor(ui.TransparentColor ,ui.MainGui)	
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
	
	ui.buttonAntiIdle := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_antiIdle_ready.png")
	ui.buttonAntiIdle.OnEvent("Click",ToggleAntiIdle)
	ui.buttonAntiIdle.ToolTip := "Toggles AntiIdle Mode On/Off"
	
	ui.buttonAutoFire := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_AutoFire_ready.png")
	ui.buttonAutoFire.OnEvent("Click",toggleAutoFire)
	ui.buttonAutoFire.ToolTip := "Toggles AutoFire on Current Window"
	
	ui.buttonAutoClicker := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_AutoClicker_ready.png")
	ui.buttonAutoClicker.OnEvent("Click",ToggleAutoClicker)
	ui.buttonAutoClicker.ToolTip := "Toggles AutoClicker"

	
	ui.buttonAfkHide := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 hidden Background" cfg.ThemeButtonReadyColor,"./Img/button_hide.png")
	ui.buttonAfkHide.OnEvent("Click",HideAfkGui)
	ui.buttonAfkHide.ToolTip := "Minimizes AFK Window to System Tray"
	
	ui.buttonUndockAfk := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 hidden Background" cfg.ThemeButtonReadyColor,"./Img/button_dockright_ready.png")
	ui.buttonUndockAfk.OnEvent("Click",ToggleAfkDock)
	ui.buttonUndockAfk.ToolTip := "Undocks AFK Window"

	ui.buttonPopout := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_popout_ready.png")
	ui.buttonPopout.OnEvent("Click",AfkPopoutButtonPushed)
	
	ui.Win1Label := ui.AfkGui.AddPicture("xs+15 y+8 section w35 h29","./Img/arrow_left.png")
	ui.AfkGui.SetFont("s12","Calibri")

	Afk.DataRow := Array()
	ui.ProfileList := Array()
	ui.ProfileListString := ""
	Loop read, cfg.AfkDataFile
	{
		LineNumber := A_Index
		Afk.DataColumn := Array()
		Loop parse, A_LoopReadLine, "CSV"
		{
			if (A_Index == 1 && !(InStr(ui.ProfileListString,A_LoopField)))
			{
				ui.ProfileListString .= A_LoopField ","
				ui.ProfileList.Push(A_LoopField)
			}
		}
		
	}
	
	debugLog("Finished Reading AfkData File")

	ui.Win1ClassDDL := ui.AfkGui.AddDDL("x+10 ys w125 AltSubmit choose3 Background" cfg.ThemeEditboxColor, ui.ProfileList)
	ui.Win1ClassDDL.OnEvent("Change",RefreshWin1AfkRoutine)
	ui.AfkGui.SetFont("s14","Calibri")
	ui.Win1Icon := ui.AfkGui.AddPicture("ys+2 w25 h25","./Img/sleep_icon.png")
	ui.Win1Status := ui.AfkGui.AddText("x+-1 ys+3 w35 +BackgroundTrans","")
	;ui.Win1Hwnd := ui.AfkGui.AddText("ys w60 hidden", "")

	ui.Win2Label := ui.AfkGui.AddPicture("xs2 y+7 section w35 h29","./Img/arrow_right.png")
	ui.AfkGui.SetFont("s12","Calibri")
	ui.Win2ClassDDL := ui.AfkGui.AddDDL("x+8 ys-2 w125 AltSubmit choose3 Background" cfg.ThemeEditboxColor, ui.ProfileList)
	ui.Win2ClassDDL.OnEvent("Change",RefreshWin2AfkRoutine)
	ui.AfkGui.SetFont("s14","Calibri")
	ui.Win2Icon := ui.AfkGui.AddPicture("ys-2 w25 h25","./Img/sleep_icon.png")
	ui.Win2Status := ui.AfkGui.AddText("x+0 ys w35 +BackgroundTrans","")
	;ui.Win2Hwnd := ui.AfkGui.AddText("ys w60 hidden","")

	ui.Win1ClassDDL.Choose(1)
	Loop ui.ProfileList.Length {
		if (cfg.Win1Class == ui.ProfileList[A_Index])
			ui.Win1ClassDDL.Choose(ui.ProfileList[A_Index])
	}
	
	ui.Win2CLassDDL.Choose(1)
	Loop ui.ProfileList.Length {
		if (cfg.Win2Class == ui.ProfileList[A_Index])
			ui.Win2ClassDDL.Choose(ui.ProfileList[A_Index])
	}
		
	RefreshWin1AfkRoutine()
	RefreshWin2AfkRoutine()	
	
	ui.AfkGui.SetFont("s16 bold")  ; Set a large font size (32-point).
	ui.Title := ui.AfkGui.AddText("x5 y+13","")
	
	ui.AfkGui.AddPicture("x+-3 ys+35 w15 h40","./Img/label_left_trim.png")
	ui.Status := ui.AfkGui.AddPicture("x+0 ys+35 w100 h40 Background" cfg.ThemeButtonReadyColor,"./Img/label_timer_off.png")  ; XX & YY serve to auto-size the window.
	ui.AfkGui.AddPicture("x+0 ys+35 w15 h40","./Img/label_right_trim.png")
	
	ui.Progress := ui.AfkGui.AddProgress("xs y145 w240 h20 c" cfg.ThemeBright2Color " vTimerProgress Smooth Range0-270 Background858585 ",0)
	
	

	;ui.AfkGui.Show("x137 y730 w250 NoActivate")  ; NoActivate avoids deactivating the currently active window.
	ui.AfkGui.Opt("+LastFound")
	WinSetTransparent(210)
	 
	OnMessage(0x0201, wmAfkLButtonDown)

	ui.AfkAnchoredToGui := true
	ui.HandlebarAfkGui := ui.AfkGui.AddPicture("x265 y0 w24 h170 section +Hidden","./Img/handlebar_vertical.png")
	ui.AfkGui.Opt("+LastFound")
	WinSetTransparent(0,ui.AfkGui)
	ui.MainGui.GetPos(&MainGuiX,&MainGuiY,,)
	drawOutlineAfkGui(14,143,244,24,cfg.ThemeBright1Color,cfg.ThemeBright2Color,2)
	drawOutlineAfkGui(190,40,67,58,cfg.ThemeBright1Color,cfg.ThemeBright2Color,2)
	ui.AfkGui.Show("x" MainGuix+45 " y" MainGuiY+35 " w275 h170 NoActivate")
}
	
autoFireButtonClicked(*) {
	ToggleAutoFire()
}

refreshWin1AfkRoutine(*) {
	try
	{
		ui.Win1AfkRoutine.Text := ""
		
		Afk.DataRow := Array()
		ui.ProfileList := Array()
		ui.ProfileListString := ""
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
		ui.ProfileListString := ""
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

toggleGuiCollapse(*) {
	Global
	(ui.GuiCollapsed := !ui.GuiCollapsed) ? CollapseGui() : UncollapseGui()

	CollapseGui() {
		ui.titleBarButtonGui.Show("w35")
		if (cfg.AnimationsEnabled) {
			GuiWidth := 567
			While GuiWidth > 35 {
				ui.MainGui.Show("w" GuiWidth)
				;ui.titleBarButtonGui.Show("w" GuiWidth+35)
				GuiWidth -= 10
			}	
		}
		ui.MainGui.Show("w35")

	}
	
	UncollapseGui() {
		GuiWidth := 0
		if (cfg.AnimationsEnabled) {
			While GuiWidth < 567 {
				ui.MainGui.Show("w" GuiWidth)
				;ui.titleBarButtonGui.Show("w" GuiWidth+35)
				GuiWidth += 10
			}
		}
		ui.MainGui.Show("w567")
		ui.titleBarButtonGui.Show("w567")
	}
}

toggleAfkDock(*) {
	Global
	
	(ui.AfkDocked) ? undockAfkGui() : dockAfkGui()
}

dockAfkGui() {
	Global
	ui.AfkDocked := true
	ui.AfkAnchoredToGui := false

	;ui.buttonDockAfk.Value := "./Img/button_dockRight.png"
	ui.MainGui.GetPos(&GuiPrevX,&GuiPrevY,,)
	ui.GuiPrevX := GuiPrevX
	ui.GuiPrevY := GuiPrevY
	HideGui()
	
	
	;ui.AfkGui.Show("y" A_ScreenHeight-ui.TaskbarHeight-ui.AfkHeight)

	WinSetTransparent(0,ui.MainGui)
	WinSetTransparent(0,ui.titleBarButtonGui)
	ui.buttonDockAfk.Opt("Hidden")
	ui.buttonUndockAfk.Opt("-Hidden")
	ui.HandlebarAfkGui.Opt("-Hidden")
	ui.buttonPopout.Opt("+Hidden")
	ui.buttonStartAFK.Move(2,3)
	ui.buttonTower.Move(32,3)
	ui.buttonAntiIdle.Move(62,3)
	ui.buttonAutoFire.Move(92,3)
	ui.buttonAutoClicker.Move(122,3)
	;ui.MainGui.Show("x-10 y" A_ScreenHeight-ui.TaskbarHeight-ui.AfkHeight-33 " NoActivate")
	;ui.AfkGui.Show("x0 y" (A_ScreenHeight-(ui.TaskbarHeight+ui.AfkHeight)) " w290 h" ui.AfkHeight " NoActivate")
	WinGetPos(&AfkGuiX,&AfkGuiY,&AfkGuiW,&AfkGuiH,ui.AfkGui)
	ui.AfkTransRect1 := ui.AfkGui.AddText("x154 y0 w108 h32 BackgroundFFFFFF")
	;WinSetTransColor(ui.TransparentColor " 0",ui.titleBarButtonGui)
	;WinSetTransparent(210,ui.AfkGui)
	
	ui.titleBarButtonGui.Opt("Owner" ui.AfkGui.Hwnd)
	ui.titleBarButtonGui.Move(AfkGuiX+154,AfkGuiY-3,109,)
	WinSetTransparent(255,ui.AfkGui)
	WinSetTransparent(255,ui.titleBarButtonGui)
	WinSetTransparent("Off",ui.AfkGui)
	WinSetTransparent("Off",ui.titleBarButtonGui)

;	WinSetTransColor(ui.TransparentColor " 210",ui.AfkGui)
	WinSetTransparent(210,ui.titleBarButtonGui)

	HideGui()
}
	
undockAfkGui() {
	Global
	ui.AfkDocked := false
	ui.GuiX := ui.GuiPrevX
	ui.GuiY := ui.GuiPrevY
	IniWrite(ui.GuiX,"nControl.ini","Interface","GuiX")
	IniWrite(ui.GuiY,"nControl.ini","Interface","GuiY")
	WinSetTransparent(0,ui.titleBarButtonGui)
	WinSetTransparent(0,ui.MainGui)
	WinSetTransparent(0,ui.AfkGui)
	ui.AfkTransRect1.Opt("BackgroundTrans")
	
	if !(ui.MainGuiTabs.Text == "AFK")
	{
		AfkPopoutButtonPushed()
	}
	ui.buttonDockAfk.Opt("-Hidden")
	ui.buttonUndockAfk.Opt("Hidden")		
	ui.buttonPopout.Opt("-Hidden")
	ui.buttonStartAFK.Move(32,2)
	ui.buttonTower.Move(62,2)
	ui.buttonAntiIdle.Move(92,2)
	ui.buttonAutoFire.Move(122,2)
	ui.buttonAutoClicker.Move(152,2)

	BlockInput(True)
	ShowGui()
	BlockInput(False)
	ui.titleBarButtonGui.Opt("Owner" ui.MainGui.Hwnd)
	ui.titleBarButtonGui.Move(GuiX+425,GuiY-7,72,)
	WinSetTransparent(255,ui.titleBarButtonGui)
	WinSetTransparent(255,ui.MainGui)
	WinSetTransparent(255,ui.AfkGui)
	WinSetTransparent("Off",ui.titleBarButtonGui)
	WinSetTransparent("Off",ui.MainGui)
	WinSetTransparent("Off",ui.AfkGui)
	WinSetTransColor(ui.TransparentColor ,ui.titleBarButtonGui)
}	

afkPopoutButtonPushed(*) {
	Global
	
	ui.MainGui.GetPos(&PrevAfkX,&PrevAfkY,,)	
	
	if (ui.AfkAnchoredToGui)
	{
		debugLog("PopOut of AFK Gui")
		ui.AfkAnchoredToGui := false
		ui.buttonPopout.Value := "./Img/button_popout_on.png"
		ui.buttonPopout.Opt("Background" cfg.ThemeButtonOnColor)
		if !(ui.AfkDocked)
			ui.titleBarButtonGui.Hide()
		HideGui()
		ui.HandlebarAfkGui.Opt("-Hidden")


		; if (cfg.AfkSnapEnabled) && !(ui.AfkDocked)
		; {
			; Switch
			; {
				; case (AfkX < 100): 
					ui.AfkGui.Show("x0 NoActivate")
			
				; case (AfkX > A_ScreenWidth-100):
					ui.AfkGui.Show("x" A_ScreenHeight-275 " NoActivate")
				
				; case (AfkY < 100):
					ui.AfkGui.Show("y0 NoActivate")
		
				; case (AfkY > A_ScreenHeight-130):
					ui.AfkGui.Show("y" A_ScreenHeight-ui.TaskbarHeight-ui.AfkHeight " NoActivate")
				
				; Default:
					ui.AfkGui.Show("x" PrevAfkX " y" PrevAfkY " NoActivate")
			; }
		; }		
	} else {
		ui.buttonPopout.Value := "./Img/button_popout_ready.png"
		ui.buttonPopout.Opt("Background" cfg.ThemeButtonReadyColor)
		
		ui.AfkGui.GetPos(&AfkX,&AfkY,,)
		ui.buttonAfkHide.opt("+hidden")
		ui.HandlebarAfkGui.Opt("+Hidden")
		ui.titleBarButtonGui.Show()
		
		if !(ui.MainGuiTabs.Text == "AFK")
		{
			ui.AfkGui.Hide()
		}
		
		ui.MainGui.Show("x" PrevAfkX " y" PrevAfkY " NoActivate")	
		ui.AfkAnchoredToGui := true
		ui.AfkDocked := false
	}
}

hideAfkGui(*) {
	ui.AfkGui.Hide()
}

showAfkInGui() {
		ui.MainGui.GetPos(&MainGuiX,&MainGuiY,,)
		;ui.AfkGui.Show("x" MainGuix+10 " y" MainGuiY+35 " w275 h170 NoActivate")
}

toggleGui(*) {
	global
	If !(ui.hidden)
	{
		ui.hidden := 1
		;ShowToolbar()
	} else {
		ui.hidden := 0
		ui.Pinned := 0
		ShowGui()
	}
	debugLog("Interface Toggled")
}

exitButtonPushed(*) {
	ExitApp
}

hideGui(*) {
	Global
	SaveGuiPos()
	WinSetTransparent(255,ui.MainGui)
	if ui.AfkAnchoredToGui = true
	{
		ui.AfkGui.Hide()
		ui.titleBarButtonGui.Hide()
	}
	
	ui.MainGui.Hide()
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

readGuiPos(*) {
	Global
	cfg.GuiX := IniRead(cfg.file,"Interface","GuiX",A_ScreenWidth/2)
	cfg.GuiY := IniRead(cfg.file,"Interface","GuiY",A_ScreenHeight/2)
	if (ui.MainGuiTabs.text = "AFK")
	{
		;ui.AfkGui.Show("x" cfg.GuiX+10 " y" cfg.GuiY+35 " w275 h170 NoActivate")
	
	}
	debugLog("Showing Interface at x" cfg.GuiX " y" cfg.GuiY)
}

showGui(*) {
	Global
	if !(ui.MainGuiTabs.Text == "AFK")
	{
		ui.AfkGui.Hide()
	}	
	ReadGuiPos()
	ui.MainGui.GetPos(&MainGuiX,&MainGuiY,,,)
	if (ui.MainGuiTabs.Text = "AFK")
	{
		ui.HandlebarAfkGui.Opt("+Hidden")
		ui.buttonAfkHide.opt("+hidden")
		ui.AfkAnchoredToGui := true
		ui.AfkDocked := false
		;ui.AfkGui.Show("x" MainGuiX+10 " y" MainGuiY+35 " w275 h170 NoActivate")
	}
	ui.MainGui.Show("x" cfg.GuiX " y" cfg.GuiY " NoActivate")
	debugLog("Showing Interface")
}

toggleConsole(*) {
	Global
	if (cfg.ConsoleVisible == false)
	{
		cfg.ConsoleVisible := true
		
		ui.ButtonDebug.Value := "./Img/button_viewlog_down.png"
		ui.ButtonDebug.Opt("Background" cfg.ThemeButtonOnColor)
		
		;MsgBox("here")
		if (cfg.AnimationsEnabled) {
		GuiH := 214	
			While (GuiH < 395)
			{
				GuiH += 10
				ui.MainGui.move(,,,GuiH) 
				Sleep(10)
			}
		}

		ui.mainGui.show("h400")
		ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
		;MsgBox(GuiX "`n" GuiY "`n" GuiW "`n" GuiH)
		debugLog("Showing Log")
	} else {
		cfg.ConsoleVisible := false
		ui.ButtonDebug.Value := "./Img/button_viewlog_up.png"
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
		ui.MainGui.move(,,,214)
		debugLog("Hiding Log")
	}
}

dockApps(*) {
	global
	dockApp.enabled := !dockApp.enabled
	
	if (dockApp.enabled)
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

tabsChanged(*) {
	ui.activeTab := ui.MainGuiTabs.Text

	Switch {
		case (ui.activeTab == "AFK") && !(ui.afkDocked) && (ui.afkAnchoredToGui):
		{
			WinSetTransparent(255,ui.AfkGui)
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
		default:
		{
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


	drawOutlineTitleBarButtonGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
		
		ui.titleBarButtonGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
		ui.titleBarButtonGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
		ui.titleBarButtonGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
		ui.titleBarButtonGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
	}
} ;End Draw Outline Functions