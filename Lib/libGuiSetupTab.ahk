#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}

;libGuiSetupTab
	
GuiSetupTab(&ui,&cfg)
{
	ui.MainGuiTabs.UseTab("Setup")
	ui.MainGui.SetFont("s09")
	ui.AutoClickerSpeedSlider := ui.MainGui.AddSlider("x40 y40 w25 h160 Range1-64 Vertical Left TickInterval8 Invert ToolTipTop",cfg.AutoClickerSpeed)
	ui.AutoClickerSpeedSlider.ToolTip := "AutoClicker Speed"
	ui.AutoClickerSpeedSliderLabel2 := ui.MainGui.AddText("x30 y195 w50 r1 Center BackgroundTrans","CPS")
	
	ui.AutoClickerSpeedSlider.OnEvent("Change",AutoClickerSpeedChanged)
	
	ui.MainGui.SetFont("s10")
	drawOutlineMainGui(39,31,499,182,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,2)
	
	ui.MainGui.SetFont("s10")
	
	
	
	
	ui.toggleToolTips := ui.MainGui.AddPicture("x85 y50 w50 h25 section " ((cfg.ToolTipsEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),((cfg.ToolTipsEnabled) ? (cfg.toggleOn) : (cfg.toggleOff)))
	ui.toggleToolTips.OnEvent("Click", ToggleToolTips)
	ui.toggleToolTips.ToolTip := "Toggles ToolTips"
	ui.labelToolTips := ui.MainGui.AddText("x+3 ys+3 BackgroundTrans","ToolTips")
	ToggleToolTips(*)
	{
		ui.toggleToolTips.value := 
			(cfg.ToolTipsEnabled := !cfg.ToolTipsEnabled) 
				? (ui.toggleToolTips.Opt("Background" cfg.ThemeButtonOnColor),cfg.toggleOn) 
				: (ui.toggleToolTips.Opt("Background" cfg.ThemeButtonReadyColor),cfg.toggleOff)
		ui.toggleToolTips.Redraw()
	}

	ToggleAfkSnap(*)
	{
		ui.toggleAfkSnap.Opt((cfg.AfkSnapEnabled := !cfg.AfkSnapEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleAfkSnap.Redraw()
	}
	
	ui.toggleAfkSnap := ui.MainGui.AddPicture("xs w50 h25 section " (cfg.AfkSnapEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),"./Img/toggle_off.png")
	ui.toggleAfkSnap.OnEvent("Click", ToggleAfkSnap)
	ui.toggleAfkSnap.ToolTip := "Toggles Afk Screen Snapping"
	ui.labelAfkSnap:= ui.MainGui.AddText("x+3 ys+3","AFK Snapping")

	ToggleSilentIdle(*)
	{
		ui.toggleSilentIdle.Opt((cfg.SilentIdleEnabled := !cfg.SilentIdleEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleSilentIdle.Redraw()
	}
	ui.toggleSilentIdle := ui.MainGui.AddPicture("xs w50 h25 section " (cfg.SilentIdleEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),"./Img/toggle_off.png")
	ui.toggleSilentIdle.OnEvent("Click", ToggleSilentIdle)
	ui.toggleSilentIdle.ToolTip := "Minimizes Roblox Windows While Anti-Idling"
	ui.labelSilentIdle:= ui.MainGui.AddText("x+3 ys+3","Silent AntiIdle")

	ToggleAlwaysOnTop(*)
	{
		ui.toggleAlwaysOnTop.Opt((cfg.AlwaysOnTopEnabled := !cfg.AlwaysOnTopEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleAlwaysOnTop.Redraw()
	}
	ui.toggleAlwaysOnTop := ui.MainGui.AddPicture("xs w50 h25 section " (cfg.AlwaysOnTopEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),"./Img/toggle_off.png")
	ui.toggleAlwaysOnTop.OnEvent("Click", ToggleAlwaysOnTop)
	ui.toggleAlwaysOnTop.ToolTip := "Keeps this app on top of all other windows."
	ui.labelAlwaysOnTop:= ui.MainGui.AddText("x+3 ys+3","AlwaysOnTop")	
	
	ToggleAnimations(*)
	{
		ui.toggleAnimations.Opt((cfg.AnimationsEnabled := !cfg.AnimationsEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleAnimations.Redraw()
	}
	ui.toggleAnimations := ui.MainGui.AddPicture("xs w50 h25 section " (cfg.AnimationsEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),"./Img/toggle_off.png")
	ui.toggleAnimations.OnEvent("Click", ToggleAnimations)
	ui.toggleAnimations.ToolTip := "Keeps this app on top of all other windows."
	ui.labelAnimations:= ui.MainGui.AddText("x+3 ys+3","Animations")	
	
		ToggleCelestialTower(*)
	{
		ui.toggleCelestialTower.Opt((cfg.CelestialTowerEnabled := !cfg.CelestialTowerEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleCelestialTower.Redraw()
	}
	ui.toggleCelestialTower := ui.MainGui.AddPicture("xs w50 h25 section " (cfg.CelestialTowerEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),"./Img/toggle_off.png")
	ui.toggleCelestialTower.OnEvent("Click", ToggleCelestialTower)
	ui.toggleCelestialTower.ToolTip := "Switches Tower AFK to Celestial."
	ui.labelCelestialTower:= ui.MainGui.AddText("x+3 ys+3","Celestial Tower")	
	

	ui.buttonNewTheme := ui.MainGui.AddPicture("x245 y36 section w24 h23 Background" cfg.ThemeButtonReadyColor,"./Img/button_plus_ready.png")

	ui.ThemeDDL := ui.MainGui.AddDDL("ys w120 section center Background" cfg.ThemeEditboxColor,cfg.ThemeList)
	ui.ThemeDDl.Choose(cfg.Theme)
	ui.ThemeDDL.OnEvent("Change",ThemeChanged)
	ui.ThemeDDL.ToolTip := "Select Theme Preset"
	ui.buttonDelTheme := ui.MainGui.AddPicture("x+0 ys+1 w24 h23 Background" cfg.ThemeButtonReadyColor,"./Img/button_minus_ready.png")	

	ui.ThemeDDL.Choose(1)
	Loop cfg.ThemeList.Length {
		if (cfg.ThemeList[A_Index] == cfg.Theme) {
			ui.ThemeDDL.Choose(cfg.Theme)
			Break
		}
	}

	ui.ThemeDDL.SetFont("s10")
	ui.ThemeElements := ["ThemeBackgroundColor","ThemePanel1Color","ThemePanel2Color","ThemeFont1Color","ThemeFont2Color","ThemeButtonReadyColor","ThemeButtonOnColor","ThemeButtonAlertColor","ThemeBright1Color","ThemeBright2Color","ThemeDisabledColor","ThemeEditboxColor","ThemeBorderDarkColor","ThemeBorderLightColor"]

	; ui.ThemeDDLlabel := ui.MainGui.AddText("x100 y33 w60 BackgroundTrans","Theme")
	; ui.ThemeDDLlabel.SetFont("s10 c" cfg.ThemeFont2Color)	
	;ui.ColorSelectorHeader := ui.MainGui.AddText("x115 ym+30 section w80 r1"," Color Selector")

	ui.toggleColorSelector := ui.MainGui.AddPicture("x440 y32 w60 h25 section", (cfg.ColorPickerEnabled) ? ("./Img/toggle_right.png") : ("./Img/toggle_left.png"))
	ui.toggleColorSelector.OnEvent("Click", ToggleColorSelector)
	ui.toggleColorSelector.ToolTip := "Select color picking method for theming features"
	ui.ColorSelectorLabel2 := ui.MainGui.AddText("xs+3 section w60 BackgroundTrans", (cfg.ColorPickerEnabled) ? ("Color App") : (" Swatches"))
	ui.ColorSelectorLabel2.SetFont("s10 c" cfg.ThemeFont2Color)

	ToggleColorSelector(*)
	{
		ui.toggleColorSelector.Value := (cfg.ColorPickerEnabled := !cfg.ColorPickerEnabled) ? ("./Img/toggle_right.png") : ("./Img/toggle_left.png")
		ui.ColorSelectorLabel2.Text := (cfg.ColorPickerEnabled) ? ("Color App") : (" Swatches")
		ui.toggleColorSelector.Redraw()
	}

	ui.MainGui.SetFont("s10")
	ui.MainGui.AddText("x255 y52 section hidden")

	Loop ui.ThemeElements.Length
	{
		this_color := ui.ThemeElements[A_Index]
		if (A_Index == 8)
			ui.MainGui.AddText("x+30 y52 section hidden")
		ui.%this_color%Picker := ui.MainGui.AddText("xs y+2 section w30 h20 Border Background" cfg.%this_color% " c" cfg.%this_color%,this_color)
		ui.%this_color%Label := ui.MainGui.AddText("x+5 ys+2 c" cfg.ThemeFont1Color,StrReplace(SubStr(this_color,6),"Color"))
		ui.%this_color%Picker.OnEvent("Click",PickColor)
	}

	ControlFocus(ui.toggleColorSelector,ui.mainGui)

	PickColor(Obj,msg,Info*)
	{
		this_color := Obj.Text
		prev_color := cfg.%this_color%
		cfg.%this_color% := ChooseColor(this_color,prev_color)
		ui.ThemeDDL.Choose("Custom")
		;Sleep(1000)
		Reload
	}
  
  	AutoClickerSpeedChanged(*) {
		
	cfg.AutoClickerSpeed := (ui.AutoClickerSpeedSlider.Value/0.128)
			
		; Switch
		; {
			
			; case ui.AutoClickerSpeedSlider.Value < 20:
			; {
				; cfg.AutoClickerSpeed := (ui.AutoClickerSpeedSlider.Value * .75)
			; }
			; case ui.AutoClickerSpeedSlider.Value >= 20:
			; {
				; cfg.AutoClickerSpeed := ui.AutoClickerSpeedSlider.Value
			; }
		; }
	}
	
	ThemeChanged(*) {
		Reload()
	}

	ChooseColor(ColorType,prev_color)
	{
		if (cfg.ColorPickerEnabled)
		{
			DialogBox("Click the color you'd like to use for " ColorType "`non the Color Chart","Selecting Color for " ColorType)
			ChosenColor := Format("{:X}", RunWait('./lib/ColorChooser.exe 0x' cfg.%ColorType% ' ' cfg.GuiX ' ' cfg.GuiY))
		
			DialogBoxClose()
			if (ChosenColor == 0) || (ChosenColor == "")
			{
				DialogBox("No Color Chosen")
				SetTimer(DialogBoxClose,-3000)
				Return prev_color
			} else {
				DialogBox("You have selected: " ChosenColor "`nfor the " ColorType " category.")
				SetTimer(DialogBoxClose,-3000)
				Return ChosenColor	
			}
		} else {
			ui.MainGui.GetPos(&DialogX,&DialogY,&DialogW,&DialogH)
			ui.colorGui := Gui()
			ui.colorGui.Opt("+AlwaysOnTop -Caption +Owner" ui.MainGui.Hwnd)
			ui.ColorPicker := ui.colorGui.AddPicture("w515 h1000","./Img/color_swatches.png")
			ui.colorGui.Show("x" DialogX " y" DialogY+DialogH " NoActivate")
			Sleep(1000)
			ClickReceived := KeyWait("LButton","D T15")
			
			if (ClickReceived)
			{
				MouseGetPos(&MouseX,&MouseY)
				ChosenColor := PixelGetColor(MouseX,MouseY)
				if (ChosenColor == 0) || (ChosenColor == "")
				{
					DialogBox("No Color Chosen")
					SetTimer(DialogBoxClose,-3000)
					Return prev_color
				} else {
					DialogBox("You have selected: " ChosenColor "`nfor the " ColorType " category.")
					SetTimer(DialogBoxClose,-3000)		
					Return ChosenColor	
				}
			} else {
				DialogBoxClose()
				DialogBox("No Color Chosen. `nReturning to App.")
				SetTimer(DialogBoxClose,-3000)
			}
			
			ui.colorGui.Destroy()
		}
	}

}