#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}

InitGui(&cfg, &ui)
{
	ui.TransparentColor := "F1F2F3"
	ui.MainGui := Gui()
	ui.MainGui.Name := "nControl"
	ui.MainGui.BackColor := ui.TransparentColor
	ui.MainGui.Color := ui.TransparentColor
	
	ui.MainGui.Opt("-Caption -Border")
	if (cfg.AlwaysOnTopEnabled)
	{
		ui.MainGui.Opt("+AlwaysOnTop")
	}

	ui.DownButton 	:= ui.MainGui.AddPicture("x438 y0 w32 h32 section Background" cfg.ThemeFont1Color,"./Img/button_minimize.png")
	ui.DownButton.OnEvent("Click",HideGui)
	ui.DownButton.ToolTip := "Minimizes nControl App"

	ui.ExitButton 	:= ui.MainGui.AddPicture("x471 ys w32 h32 Background" cfg.ThemeFont1Color,"./Img/button_quit.png")
	ui.ExitButton.OnEvent("Click",ExitButtonPushed)
	ui.ExitButton.ToolTip := "Terminates nControl App"


	
	
	ui.MainGui.MarginX := 0
	ui.MainGui.MarginY := 0
	ui.MainGui.SetFont("s13 c" cfg.ThemeFont1Color,"Calibri")
	ui.MainGuiTabs := ui.MainGui.AddTab3("x3 y3 w505 h214 Buttons +Redraw Background" cfg.ThemeBackgroundColor " -E0x200", ["Sys","AFK","Keymaps","Dock","Setup","Audio"])
	ui.MainGuiTabs.OnEvent("Change",TabsChanged)
	ui.MainGuiTabs.Choose("AFK")
	
	GuiOperationsTab(&ui,&cfg)
	GuiAFKTab(&ui,&afk)
	GuiDockTab(&ui)
	GuiSetupTab(&ui,&cfg)
	; GuiSystemTab(&ui)	
	GuiAudioTab(&ui,&audio)

	ui.MainGuiTabs.UseTab("")
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri")
	ui.gvConsole := ui.MainGui.AddListBox("section xs-12 y+50 w527 h192 +Background" cfg.ThemeConsoleBgColor)
	ui.gvConsole.Color := cfg.Theme3dBorderShadowColor
	
	if (FileExist("./Logs/persist.log"))
	{
		Loop Read, "./Logs/persist.log"
		{
			ui.gvConsole.Add([A_LoopReadLine])
		}
		FileDelete("./Logs/persist.log")
	}
	ui.MainGui.AddPicture("x504 y3 w32 h214 section","./Img/handlebar_vertical.png")
	
	WinSetTransColor(ui.TransparentColor,ui.MainGui)

	drawOutlineMainGui(0,0,534,220,cfg.ThemeBrightBorderTopColor,cfg.ThemeBrightBorderBottomColor,1)   	;Main Gui Outline
	drawOutlineAfkGui(1,2,511,28,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,1)
	drawOutlineMainGui(1,33,503,184,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,1)			;
	drawOutlineMainGui(0,218,532,184,cfg.ThemeBrightBorderTopColor,cfg.ThemeBrightBorderBottomColor,1) 	;Log Panel Outline
	drawOutlineMainGui(1,223,532,177,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,1)		;Log Panel 3D Effect
	;drawOutlineMainGui(438,3,63,30,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)			;Titlebar Buttons 3D Effect
	WinSetTransparent(0,ui.MainGui)
	
	ui.MainGui.Show("x" cfg.GuiX " y" cfg.GuiY " w532 h220 NoActivate")
	ui.MainGuiTabs.Choose("Sys")
	
	Transparency := 0
	BlockInput(True)
	While Transparency < 253
	{
		Transparency += 2.5
		WinSetTransparent(Round(Transparency),ui.MainGui)
		Sleep(1)
	}
	BlockInput(False)
	InitOSDGui()
	
	ui.AfkGui.Opt("+Owner" ui.MainGui.Hwnd)
	if (cfg.AlwaysOnTopEnabled)
	{
		ui.AfkGui.Opt("+AlwaysOnTop")
	}
	debugLog("Interface Initialized")


}

GuiAFKTab(&ui,&afk)
{
	ui.MainGuiTabs.UseTab("AFK")
	;Any logic needed for the AFK tab beneath the docked AfkGui
	ui.Win1AfkRoutine := ui.MainGui.AddText("x292 y40 section w206 h81 Background" cfg.ThemeConsoleBgColor,"")
	ui.Win2AfkRoutine := ui.MainGui.AddText("xs y+6 w206 h81 Background" cfg.ThemeConsoleBgColor,"")
	ui.Win1AfkRoutine.SetFont("s10")
	ui.Win2AfkRoutine.SetFont("s10")
	
	drawOutlineMainGui(290,38,210,85,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)
	drawOutlineMainGui(290,125,210,85,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)
}

InitOSDGui()
{
	Global 

	GameWinID := WinGetList("Roblox")

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
	ui.AfkGui.Opt("-Caption -Border +AlwaysOnTop +ToolWindow +Owner" ui.MainGui.Hwnd)
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
	ui.buttonAutoFire.OnEvent("Click",AutoFireButtonClicked)
	ui.buttonAutoFire.ToolTip := "Toggles AutoFire on Current Window"
	
	ui.buttonAutoClicker := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 Background" cfg.ThemeButtonReadyColor,"./Img/button_AutoClicker_ready.png")
	ui.buttonAutoClicker.OnEvent("Click",ToggleAutoClicker)
	ui.buttonAutoClicker.ToolTip := "Toggles AutoClicker"

	
	ui.buttonAfkHide := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 hidden Background" cfg.ThemeButtonReadyColor,"./Img/button_hide.png")
	ui.buttonAfkHide.OnEvent("Click",HideAfkGui)
	ui.buttonAfkHide.ToolTip := "Minimizes AFK Window to System Tray"
	
	; ui.buttonAfkUndock := ui.AfkGui.AddPicture("x+0 ys0 w30 h30 hidden Background" cfg.ThemeButtonReadyColor,"./Img/button_dockright_ready.png")
	; ui.buttonAfkUndock.OnEvent("Click",ToggleAfkDock)
	; ui.buttonAfkUndock.ToolTip := "Undocks AFK Window"

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

	ui.Win1ClassDDL := ui.AfkGui.AddDDL("x+10 ys w115 AltSubmit choose3 Background" cfg.ThemeDisabledColor, ui.ProfileList)
	ui.Win1ClassDDL.OnEvent("Change",RefreshWin1AfkRoutine)
	ui.Win1Icon := ui.AfkGui.AddPicture("ys+2 w25 h25","./Img/sleep_icon.png")
	ui.AfkGui.SetFont("s14","Calibri")
	ui.Win1Status := ui.AfkGui.AddText("x+-1 ys+3 w35 +BackgroundTrans","")
	;ui.Win1Hwnd := ui.AfkGui.AddText("ys w60 hidden", "")

	ui.Win2Label := ui.AfkGui.AddPicture("xs2 y+7 section w35 h29","./Img/arrow_right.png")
	ui.AfkGui.SetFont("s12","Calibri")
	ui.Win2ClassDDL := ui.AfkGui.AddDDL("x+8 ys-2 w115 AltSubmit choose3 Background" cfg.ThemeDisabledColor, ui.ProfileList)
	ui.Win2ClassDDL.OnEvent("Change",RefreshWin2AfkRoutine)
	ui.AfkGui.SetFont("s14","Calibri")
	ui.Win2Icon := ui.AfkGui.AddPicture("ys-2 w25 h25","./Img/sleep_icon.png")
	ui.Win2Status := ui.AfkGui.AddText("x+0 ys w35 +BackgroundTrans","")
	;ui.Win2Hwnd := ui.AfkGui.AddText("ys w60 hidden","")
	ui.Win1ClassDDL.Choose(1)
	ui.Win2ClassDDL.Choose(2)

	RefreshWin1AfkRoutine()
	RefreshWin2AfkRoutine()	
	

	ui.AfkGui.SetFont("s16 bold")  ; Set a large font size (32-point).
	ui.Title := ui.AfkGui.AddText("x5 y+13","")
	
	ui.Status := ui.AfkGui.AddPicture("x+0 ys+37 w220 h30","./Img/timer_off.png")  ; XX & YY serve to auto-size the window.
	
	ui.Progress := ui.AfkGui.AddProgress("x16 y145 w220 h20 c" cfg.ThemeBrightBorderBottomColor " vTimerProgress Smooth Range0-270 Background858585 ",0)
	
	

	;ui.AfkGui.Show("x137 y730 w250 NoActivate")  ; NoActivate avoids deactivating the currently active window.
	ui.hwndAfkGui := ui.AfkGui.Hwnd
	ui.AfkGui.Opt("+LastFound")
	WinSetTransColor("F1F2F3 0")
	WinSetTransparent(210)
	drawOutlineAfkGui(14,142,224,24,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)
	drawOutlineAfkGui(180,40,67,58,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)
	 
	OnMessage(0x0201, wmAfkLButtonDown)

	;WinGetPos(&MainGuiX,&MainGuiY,,,ui.MainGui)
	;ui.AfkGui.Show("x" MainGuix+10 " y" MainGuiY+35 " w350 NoActivate")
	ui.AfkAnchoredToGui := true
	ui.HandlebarAfkGui := ui.AfkGui.AddPicture("x250 y0 w24 h170 section +Hidden","./Img/handlebar_vertical.png")
	ui.AfkGui.Opt("+LastFound")
}
	
AutoFireButtonClicked(*) {
	if (WinExist("ahk_id " (WinHwnd := WinGetID(ui.GameDDL.Text))))
	WinActivate("ahk_id " WinHwnd)
	
	ToggleAutoFire()
}

RefreshWin1AfkRoutine(*)
{
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

RefreshWin2AfkRoutine(*)
{
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


	
ToggleAfkDock(*)
{
	Global
	if (ui.AfkDocked)
	{
		ui.AfkDocked := false
		ui.GuiX := ui.GuiPrevX
		ui.GuiY := ui.GuiPrevY
		IniWrite(ui.GuiX,"nControl.ini","Interface","GuiX")
		IniWrite(ui.GuiY,"nControl.ini","Interface","GuiY")
		if !(ui.MainGuiTabs.Text == "AFK")
		{
			AfkPopoutButtonPushed()
		}
		ui.buttonDockAfk.Opt("Background" cfg.ThemeButtonReadyColor)
		ui.buttonDockAfk.Value := "./Img/button_dockleft_ready.png"
		;ui.OpsDockButton.Opt("Background" cfg.ThemeButtonReadyColor)
		ui.buttonPopout.Opt("-Hidden")
		BlockInput(True)
		ShowGui()
		BlockInput(False)
		
	
	} else {
	
		ui.AfkDocked := true
		ui.AfkAnchoredToGui := false
		ui.TaskbarHeight := GetTaskBarHeight()
		ui.buttonDockAfk.Opt("Background" cfg.ThemeButtonOnColor)
		ui.buttonDockAfk.Value := "./Img/button_dockRight_on.png"
		ui.MainGui.GetPos(&GuiPrevX,&GuiPrevY,,)
		ui.GuiPrevX := GuiPrevX
		ui.GuiPrevY := GuiPrevY
		HideGui()
		
		ui.HandlebarAfkGui.Opt("-Hidden")
		;ui.AfkGui.Show("y" A_ScreenHeight-ui.TaskbarHeight-ui.AfkHeight)
		
		WinSetTransparent(0,ui.MainGui)
		ui.buttonDockAfk.Value := "./Img/button_dockright.png"
		ui.buttonPopout.Opt("+Hidden")
		ui.MainGui.Show("x-10 y" A_ScreenHeight-ui.TaskbarHeight-ui.AfkHeight-33 " NoActivate")
		ui.AfkGui.Show("x0 y" (A_ScreenHeight-ui.TaskbarHeight-(ui.AfkHeight*(A_ScreenDPI/96))) " w275 h" ui.AfkHeight " NoActivate")
		HideGui()


	}
}

ShowAfkInGui()
{
		ui.MainGui.GetPos(&MainGuiX,&MainGuiY,,)
		ui.AfkGui.Show("x" MainGuix+10 " y" MainGuiY+35 " w275 h170 NoActivate")
}

TabsChanged(*)
{
	debugLog("Tab Changed to " ui.MainGuiTabs.Text)
	if (ui.MainGuiTabs.Text = "AFK" and (ui.AfkAnchoredToGui))
	{
			ShowAfkInGui()
	} else {
		ui.AfkGui.Hide()
	}
}

InitConsole(&ui)
{
	ui.gvMonitorSelectGui := Gui()
	ui.gvMonitorSelectGui.Opt("-Theme -Border -Caption +AlwaysOnTop +Parent" ui.MainGui.Hwnd " +Owner" ui.MainGui.Hwnd)
	ui.gvMonitorSelectGui.BackColor := "212121"
	ui.gvMonitorSelectGui.SetFont("s16 c00FFFF","Calibri Bold")
	ui.gvMonitorSelectGui.Add("Text",,"Click anywhere on the screen`nyou'd like your nControlDock on.")
}

ToggleGui(*)
{
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

ExitButtonPushed(*)
{
	ExitApp
}

AfkPopoutButtonPushed(*)
{
	Global
	
	ui.MainGui.GetPos(&PrevAfkX,&PrevAfkY,,)	
	
	if (ui.AfkAnchoredToGui)
	{
		debugLog("PopOut of AFK Gui")
		ui.AfkAnchoredToGui := false
		ui.buttonPopout.Value := "./Img/button_popout_on.png"
		ui.buttonPopout.Opt("Background" cfg.ThemeButtonOnColor)
	
		HideGui()
		ui.HandlebarAfkGui.Opt("-Hidden")


		if (cfg.AfkSnapEnabled) && !(ui.AfkDocked)
		{
			Switch
			{
				case (AfkX < 100): 
					ui.AfkGui.Show("x0 NoActivate")
			
				case (AfkX > A_ScreenWidth-100):
					ui.AfkGui.Show("x" A_ScreenHeight-275 " NoActivate")
				
				case (AfkY < 100):
					ui.AfkGui.Show("y0 NoActivate")
		
				case (AfkY > A_ScreenHeight-130):
					ui.AfkGui.Show("y" A_ScreenHeight-ui.TaskbarHeight-ui.AfkHeight " NoActivate")
				
				Default:
					ui.AfkGui.Show("x" PrevAfkX " y" PrevAfkY " NoActivate")
			}
		}		
	} else {
		ui.buttonPopout.Value := "./Img/button_popout_ready.png"
		ui.buttonPopout.Opt("Background" cfg.ThemeButtonReadyColor)
		
		ui.AfkGui.GetPos(&AfkX,&AfkY,,)
		ui.buttonAfkHide.opt("+hidden")
		ui.HandlebarAfkGui.Opt("+Hidden")
		if !(ui.MainGuiTabs.Text == "AFK")
		{
			ui.AfkGui.Hide()
		}
		
		ui.MainGui.Show("x" PrevAfkX " y" PrevAfkY " NoActivate")	
		ui.AfkAnchoredToGui := true
		ui.AfkDocked := false
	}
}

HideGui(*)
{
	Global
	SaveGuiPos()
	WinSetTransparent(255,ui.MainGui)
	if ui.AfkAnchoredToGui = true
	{
		ui.AfkGui.Hide()
	}
	
	ui.MainGui.Hide()
	ui.buttonAfkHide.opt("-hidden")
	debugLog("Hiding Interface")
}

SaveGuiPos(*)
{
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

ReadGuiPos(*)
{
	Global
	cfg.GuiX := IniRead(cfg.file,"Interface","GuiX",A_ScreenWidth/2)
	cfg.GuiY := IniRead(cfg.file,"Interface","GuiY",A_ScreenHeight/2)
	ui.MainGui.Show("x" cfg.GuiX " y" cfg.GuiY " NoActivate")
	if (ui.MainGuiTabs.text = "AFK")
	{
		ui.AfkGui.Show("x" cfg.GuiX+10 " y" cfg.GuiY+35 " w275 h170 NoActivate")
	
	}
	debugLog("Showing Interface at x" cfg.GuiX " y" cfg.GuiY)
}

ShowGui(*)
{
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
		ui.AfkGui.Show("x" MainGuiX+10 " y" MainGuiY+35 " w275 h170 NoActivate")
	}
	debugLog("Showing Interface")
}

ShowToolbar(*)
{
	Global
	If (ui.Pinned)
	{
		ui.Pinned := 0
		ui.MainGui.Show("NoActivate")
		gvToolbar.GetPos(&ToolbarX,&ToolbarY,&ToolbarW,&ToolbarH)
		ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
		gvToolbar.Hide()
		ui.MainGui.Show("x" ToolbarX-GuiW+ToolbarW " y" ToolbarY " NoActivate")
		debugLog("Showing Main App")
	} else {	
			ui.Pinned := 1
			gvToolbar.Show("NoActivate")
			gvToolbar.GetPos(&ToolbarX,&ToolbarY,&ToolbarW,&ToolbarH)
			ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
			ui.MainGui.Hide() 
			gvToolbar.Show("x" GuiX+GuiW-ToolbarW+10 " y" GuiY " NoActivate")
			debugLog("Showing Toolbar")
	}
}


ToggleDebug(*)
{
	Global
	if (cfg.debugEnabled == false)
	{
		cfg.debugEnabled := 1
		BlockInput(true)
		ui.ButtonDebug.Value := "./Img/button_viewlog_down.png"
		ui.ButtonDebug.Opt("Background" cfg.ThemeButtonOnColor)
		BlockInput(false)
		ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
		While (GuiH < 403)
		{
			GuiH += 10
			ui.MainGui.Show("h" GuiH " NoActivate") 
			Sleep(10)
		}
			
		ui.MainGui.Show("h397 NoActivate")
		debugLog("Showing Log")
	} else {
		cfg.debugEnabled := 0
		BlockInput(true)	 
		ui.ButtonDebug.Value := "./Img/button_viewlog_up.png"
		ui.ButtonDebug.Opt("Background" cfg.ThemeButtonReadyColor)
		BlockInput(false)
		ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
		While (GuiH > 218)
		{
			GuiH -= 10
			ui.MainGui.Show("h" GuiH " NoActivate")
			Sleep(10)
		}
		ui.MainGui.Show("h220 NoActivate")
		debugLog("Hiding Log")
	}
}

DockApps(*)
{
	ToggleDockApps()
}

ToggleDockApps()
{
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
		ui.buttonDockApps.Opt("Background" cfg.ThemeButtonDisabledColor)
		nControl("Off",&cfg)
	}
	
	UnpushButton(*) {
		ui.buttonDockApps.Value := "./Img/button_ready.png"
	}
}

drawOutlineMainGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1)
{	
	ui.MainGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
	ui.MainGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
	ui.MainGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
	ui.MainGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
}

drawOutlineDialogBoxGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1)
{	
	ui.dialogBoxGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
	ui.dialogBoxGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
	ui.dialogBoxGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
	ui.dialogBoxGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
}

drawOutlineNewGameGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1)
{	
	ui.NewGameGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
	ui.NewGameGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
	ui.NewGameGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
	ui.NewGameGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
}

drawOutlineNotifyGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1)
{	
	ui.NotifyGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
	ui.NotifyGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
	ui.NotifyGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
	ui.NotifyGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
}


drawOutlineAfkGui(X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1)
{	
	
	ui.AfkGui.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
	ui.AfkGui.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
	ui.AfkGui.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
	ui.AfkGui.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
}

; toggleButton(featureName) {
	; %featureName%_enabled := ! %featureName%_enabled
; button%featureName%.Value := "./Img/" buttonName "_on.png"
; SetTimer(buttonOff,-1000)
; %buttonName%.Opt("Background" cfg.ThemeButtonOnColor)
; buttonRelease(*) {
	; %buttonName%.Value := "./Img" buttonName "_ready.png"

; }

; }

; ToggleAFK(*)
; {
	; Global
	; ui.afkEnabled := !ui.afkEnabled
	;IniWrite(ui.afkEnabled,cfg.file,"AFK","Enabled")
	; if (ui.afkEnabled)
	; {
		; ui.buttonStartAFK.Value := "./Img/button_on.png"

		; WindowsLocked := 0

		; GameWindow := WinGetList("Roblox")

		; Msg := ""
	
		; if(GameWindow.Length > 1)
			; SetTimer(win2timer,ui.Win2Timing.Value)
		; if(GameWindow.Length > 0)
			; SetTimer(win1timer,ui.Win2Timing.Value)
		; else
		; {
			; MsgBox("There are no Roblox windows. Disabling AFK")
		; }
	
		; Thread "NoTimers", True

		
	; } else {
		; ui.buttonStartAFK.Value := "./Img/button_ready.png"
		; SetTimer(win1timer,0)
		; SetTimer(win2timer,0)
	; }
; }


; win1timer()
; {
	; global
	; if (GameWindow[1])
	; {
		; if (WindowsLocked = 1)
		; Loop {
			; if (WindowsLocked = 0)
				; Break
			; Sleep(100)
		; }
			
		; WindowsLocked := 1
		; WinActivate(GameWindow[1])
		; Sleep(100)
		; Send("{" ui.Win1Key.Value "}")
		; WindowsLocked := 0
	; }
; }
	
; win2timer()
; {
	; global
	; if (GameWindow[2])
	; {
		; if (WindowsLocked = 1)
		; Loop {
			; if (WindowsLocked = 0)
				; Break
			; Sleep(100)
		; }
			
		; WindowsLocked := 1
		; WinActivate(GameWindow[2])
		; Sleep(100)
		; Send("{" ui.Win2Key.Value "}")
		; WindowsLocked := 0
	; }
; }