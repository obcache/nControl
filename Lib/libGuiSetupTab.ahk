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
	
	
	
	
	ui.toggleToolTips := ui.MainGui.AddPicture("x85 y35 w60 h25 section vToolTips " ((cfg.ToolTipsEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),((cfg.ToolTipsEnabled) ? (cfg.toggleOn) : (cfg.toggleOff)))
	ui.toggleToolTips.OnEvent("Click", toggleChanged)
	ui.toggleToolTips.ToolTip := "Toggles ToolTips"
	ui.labelToolTips := ui.MainGui.AddText("x+3 ys+3 BackgroundTrans","ToolTips")


	
	ToggleAfkSnap(*)
	{
		ui.toggleAfkSnap.Opt((cfg.AfkSnapEnabled := !cfg.AfkSnapEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleAfkSnap.Redraw()
	}
	
	ui.toggleAfkSnap := ui.MainGui.AddPicture("xs w60 h25 section vAfkSnap " (cfg.AfkSnapEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),((cfg.AfkSnapEnabled) ? (cfg.toggleOn) : (cfg.toggleOff)))
	ui.toggleAfkSnap.OnEvent("Click", toggleChanged)
	ui.toggleAfkSnap.ToolTip := "Toggles Afk Screen Snapping"
	ui.labelAfkSnap:= ui.MainGui.AddText("x+3 ys+3","AFK Snapping")

	ToggleSilentIdle(*)
	{
		ui.toggleSilentIdle.Opt((cfg.SilentIdleEnabled := !cfg.SilentIdleEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleSilentIdle.Redraw()
	}
	ui.toggleSilentIdle := ui.MainGui.AddPicture("xs w60 h25 section vSilentIdle " (cfg.SilentIdleEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),((cfg.SilentIdleEnabled) ? (cfg.toggleOn) : (cfg.toggleOff)))
	ui.toggleSilentIdle.OnEvent("Click", toggleChanged)
	ui.toggleSilentIdle.ToolTip := "Minimizes Roblox Windows While Anti-Idling"
	ui.labelSilentIdle:= ui.MainGui.AddText("x+3 ys+3","Silent AntiIdle")

	ToggleAlwaysOnTop(*)
	{
		ui.toggleAlwaysOnTop.Opt((cfg.AlwaysOnTopEnabled := !cfg.AlwaysOnTopEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleAlwaysOnTop.Redraw()
	}
	ui.toggleAlwaysOnTop := ui.MainGui.AddPicture("xs w60 h25 section vAlwaysOnTop " (cfg.AlwaysOnTopEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),((cfg.AlwaysOnTopEnabled) ? (cfg.toggleOn) : (cfg.toggleOff)))
	ui.toggleAlwaysOnTop.OnEvent("Click", ToggleChanged)
	ui.toggleAlwaysOnTop.ToolTip := "Keeps this app on top of all other windows."
	ui.labelAlwaysOnTop:= ui.MainGui.AddText("x+3 ys+3","AlwaysOnTop")	
	

	
	ToggleAnimations(*)
	{
		ui.toggleAnimations.Opt((cfg.AnimationsEnabled := !cfg.AnimationsEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleAnimations.Redraw()
	}
	ui.toggleAnimations := ui.MainGui.AddPicture("xs w60 h25 section vAnimations " (cfg.AnimationsEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),((cfg.AnimationsEnabled) ? (cfg.toggleOn) : (cfg.toggleOff)))
	ui.toggleAnimations.OnEvent("Click", toggleChanged)
	ui.toggleAnimations.ToolTip := "Keeps this app on top of all other windows."
	ui.labelAnimations:= ui.MainGui.AddText("x+3 ys+3","Animations")	
	
	ToggleCelestialTower(*)
	{
		ui.toggleCelestialTower.Opt((cfg.CelestialTowerEnabled := !cfg.CelestialTowerEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleCelestialTower.Redraw()
	}
	ui.toggleCelestialTower := ui.MainGui.AddPicture("xs w60 h25 section vCelestialTower " (cfg.CelestialTowerEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),((cfg.CelestialTowerEnabled) ? (cfg.toggleOn) : (cfg.toggleOff)))
	ui.toggleCelestialTower.OnEvent("Click", toggleChanged)
	ui.toggleCelestialTower.ToolTip := "Switches Tower AFK to Celestial."
	ui.labelCelestialTower:= ui.MainGui.AddText("x+3 ys+3","Celestial Tower")	
	
	ToggleHoldToCrouch(*)
	{
		ui.toggleHoldToCrouch.Opt((cfg.holdToCrouch := !cfg.holdToCrouchEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.ToggleHoldToCrouch.Redraw()
	}
	
	; ui.holdToCrouch := ui.MainGui.AddPicture("xs w60 h25 section vHoldToCrouch " (cfg.holdToCrouchEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),((cfg.holdToCrouchEnabled) ? (cfg.toggleOn) : (cfg.toggleOff)))
	; ui.holdToCrouch.OnEvent("Click", toggleChanged)
	; ui.holdToCrouch.ToolTip := "Hold Left Shit to Crouch/Slide."
	; ui.holdToCrouch:= ui.MainGui.AddText("x+3 ys+3","Hold To Crouch")	
	


	; ui.ThemeDDLlabel := ui.MainGui.AddText("x100 y33 w60 BackgroundTrans","Theme")
	; ui.ThemeDDLlabel.SetFont("s10 c" cfg.ThemeFont2Color)	
	;ui.ColorSelectorHeader := ui.MainGui.AddText("x115 ym+30 section w80 r1"," Color Selector")

	ui.ColorSelectorLabel2 := ui.MainGui.AddText("x230 y35 h25 section w75 BackgroundTrans c"
		((cfg.ColorPickerEnabled) 
			? cfg.ThemeButtonReadyColor 
			: cfg.ThemeButtonAlertColor)
		,((cfg.ColorPickerEnabled) 
			? ("Color App") 
			: (" Swatches ")))
	
	ui.ColorSelectorLabel2.SetFont("s13")

	ui.toggleColorSelector := ui.MainGui.AddPicture("ys section w55 h24 ", (cfg.ColorPickerEnabled) ? ("./Img/toggle_right.png") : ("./Img/toggle_left.png"))
	ui.toggleColorSelector.OnEvent("Click", ToggleColorSelector)
	ui.toggleColorSelector.ToolTip := "Select color picking method for theming features"


	ToggleColorSelector(*)
	{
		ui.toggleColorSelector.Value := 
			(cfg.ColorPickerEnabled := !cfg.ColorPickerEnabled) 
				? (ui.ColorSelectorLabel2.Opt("c" cfg.ThemeButtonReadyColor)
					,ui.ColorSelectorLabel2.Text := "Color App"
					,"./Img/toggle_right.png")
				: (ui.ColorSelectorLabel2.Opt("c" cfg.ThemeButtonAlertColor)
					,ui.ColorSelectorLabel2.Text := " Swatches "
					,"./Img/toggle_left.png")
		ui.toggleColorSelector.Redraw()
	}
	ui.buttonNewTheme := ui.MainGui.AddPicture("ys+1  section w23 h22 Background" cfg.ThemeButtonReadyColor,"./Img/button_plus_ready.png")
	ui.buttonNewTheme.OnEvent("Click",addTheme)
	
	ui.ThemeDDL := ui.MainGui.AddDDL("ys-1 w120 section center Background" cfg.ThemeEditboxColor,cfg.ThemeList)
	;
	ui.ThemeDDL.OnEvent("Change",ThemeChanged)
	ui.ThemeDDL.OnEvent("Focus",RepaintThemeDDL)
	ui.ThemeDDL.OnEvent("LoseFocus",RepaintThemeDDL)

	ui.ThemeDDL.ToolTip := "Select Theme Preset"
	ui.buttonDelTheme := ui.MainGui.AddPicture("ys+1 x+-2 w23 h22 Background" cfg.ThemeButtonReadyColor,"./Img/button_minus_ready.png")	
	ui.buttonDelTheme.OnEvent("Click",removeTheme)
	drawOutlineNamed("ThemeOutline",ui.MainGui,305,34,222,27,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,3)
	drawOutlineNamed("ThemeOutlineShadow",ui.MainGui,305,34,222,27,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)
	ui.ThemeDDL.Choose(1)
	Loop cfg.ThemeList.Length {
		if (cfg.ThemeList[A_Index] == cfg.Theme) {
			ui.ThemeDDL.Choose(cfg.Theme)
			Break
		}
	}

	ui.ThemeDDL.SetFont("s11")
	ui.ThemeElements := [
		"ThemePanel1Color",		"ThemePanel2Color",		
		"ThemeFont1Color",		"ThemeFont2Color",
		"ThemeBright1Color",	"ThemeBright2Color",	"ThemeEditboxColor",
		"ThemePanel3Color",		"ThemePanel4Color",
		"ThemeFont3Color",		"ThemeFont4Color",	
		"ThemeDark1Color",		"ThemeDark2Color",		"ThemeProgressColor",		
		"ThemeBackgroundColor",	"ThemeDisabledColor",
		"ThemeBorderDarkColor",	"ThemeBorderLightColor",
		"ThemeButtonReadyColor","ThemeButtonOnColor", 	"ThemeButtonAlertColor"]

	ui.MainGui.SetFont("s10")
	ui.MainGui.AddText("x255 y52 section hidden")

	Loop ui.ThemeElements.Length
	{
		this_color := ui.ThemeElements[A_Index]
		if (A_Index == 8 || A_Index == 15)
			ui.MainGui.AddText("x+5 y52 section hidden")
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
		IniWrite(cfg.%this_color%,cfg.themeFile,cfg.Theme,this_color)
		;ui.ThemeDDL.Choose("Custom")
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
	
	RepaintThemeDDL(*) {
		ui.themeDDL.choose(ui.themeDDL.value)
		drawOutlineNamed("ThemeOutline",ui.MainGui,305,34,222,27,cfg.ThemeBorderLightColor,cfg.ThemeBorderLightColor,3)
		drawOutlineNamed("ThemeOutlineShadow",ui.MainGui,305,34,222,27,cfg.ThemeBorderDarkColor,cfg.ThemeBorderDarkColor,2)
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
				if (InStr(ChosenColor,"0x")) {
					ChosenColor := SubStr(ChosenColor,3,6)
				}
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
					if (InStr(ChosenColor,"0x")) {
						ChosenColor := SubStr(ChosenColor,3,6)
					}
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

	{ ;Functions for Game Profile List Management (Including Modal Pop-up Interaces)
		addTheme(*) {
			Global
			ui.newThemeGui := Gui(,"Add New Theme")
			ui.newThemeGui.BackColor := "505050"
			ui.newThemeGui.Color := "212121"
			ui.newThemeGui.Opt("-Caption -Border +AlwaysOnTop")
			ui.newThemeGui.SetFont("s16 cFF00FF", "Calibri Bold")
			
			ui.newThemeGui.AddText("x10 y10 section","Choose Name for New Custom Theme")
			ui.newThemeEdit := ui.newThemeGui.AddEdit("xs section w180","")
			ui.newThemeOkButton := ui.newThemeGui.AddPicture("x+-7 ys w40 h40 Background" cfg.ThemeButtonReadyColor,"./Img/button_save_up.png")
			ui.newThemeOkButton.OnEvent("Click",addThemeToDDL)
			ui.newThemeGui.Show("w260 h110 NoActivate")
			drawOutline(ui.newThemeGui,5,5,250,100,cfg.ThemeBright2Color,cfg.ThemeBright1Color,2)	;New App Profile Modal Outline

			addThemeToDDL(*) {
				Global
				cfg.themeList.Push(ui.newThemeEdit.Value)
				currentTheme := cfg.Theme
				newThemeName := ui.newThemeEdit.value
				ui.themeDDL.Delete()
				ui.themeDDL.Add(cfg.themeList)
				ui.themeDDL.Choose(ui.newThemeEdit.value)

				{ ;write new Theme to ini
				IniWrite(cfg.ThemeBright2Color,cfg.file,ui.newThemeEdit.Value,"ThemeBright2Color")
				IniWrite(cfg.ThemeBright1Color,cfg.file,ui.newThemeEdit.Value,"ThemeBright1Color")
				IniWrite(cfg.ThemeDark2Color,cfg.file,ui.newThemeEdit.Value,"ThemeDark2Color")
				IniWrite(cfg.ThemeDark1Color,cfg.file,ui.newThemeEdit.Value,"ThemeDark1Color")
				IniWrite(cfg.ThemeBorderDarkColor,cfg.file,ui.newThemeEdit.Value,"ThemeBorderDarkColor")
				IniWrite(cfg.ThemeBorderLightColor,cfg.file,ui.newThemeEdit.Value,"ThemeBorderLightColor")
				IniWrite(cfg.ThemeBackgroundColor,cfg.file,ui.newThemeEdit.Value,"ThemeBackgroundColor")
				IniWrite(cfg.ThemeFont1Color,cfg.file,ui.newThemeEdit.Value,"ThemeFont1Color")
				IniWrite(cfg.ThemeFont2Color,cfg.file,ui.newThemeEdit.Value,"ThemeFont2Color")
				IniWrite(cfg.ThemeFont3Color,cfg.file,ui.newThemeEdit.Value,"ThemeFont3Color")
				IniWrite(cfg.ThemeFont4Color,cfg.file,ui.newThemeEdit.Value,"ThemeFont4Color")
				IniWrite(cfg.ThemePanel1Color,cfg.file,ui.newThemeEdit.Value,"ThemePanel1Color")
				IniWrite(cfg.ThemePanel3Color,cfg.file,ui.newThemeEdit.Value,"ThemePanel3Color")
				IniWrite(cfg.ThemePanel2Color,cfg.file,ui.newThemeEdit.Value,"ThemePanel2Color")
				IniWrite(cfg.ThemePanel4Color,cfg.file,ui.newThemeEdit.Value,"ThemePanel4Color")
				IniWrite(cfg.ThemeEditboxColor,cfg.file,ui.newThemeEdit.Value,"ThemeEditboxColor")
				IniWrite(cfg.ThemeProgressColor,cfg.file,ui.newThemeEdit.Value,"ThemeProgressColor")
				IniWrite(cfg.ThemeDisabledColor,cfg.file,ui.newThemeEdit.Value,"ThemeDisabledColor")
				IniWrite(cfg.ThemeButtonOnColor,cfg.file,ui.newThemeEdit.Value,"ThemeButtonOnColor")
				IniWrite(cfg.ThemeButtonReadyColor,cfg.file,ui.newThemeEdit.Value,"ThemeButtonReadyColor")
				IniWrite(cfg.ThemeButtonAlertColor,cfg.file,ui.newThemeEdit.Value,"ThemeButtonAlertColor")
				} ;end writing theme to ini
				
				ui.newThemeGui.Destroy()
				
			}
		}

		removeTheme(*) {
			if cfg.themeList.Length == 1 {
			{
				ResetDefaultThemes()
			} else {
				cfg.themeList.RemoveAt(ui.themeDDL.value)
				ui.themeDDL.Delete()
				ui.themeDDL.Add(cfg.themeList)
				ui.themeDDL.Choose(1)
			}
		}
	} ;End Game Profile List Modal Gui



ui.defaultThemes := "
(
[Interface]
ThemeList=Modern Class,Cold Steel,Militarized,Neon,Ocean
[Modern Class]
ThemeBorderLightColor=C0C0C0
ThemeBorderDarkColor=333333
ThemeBright1Color=1D1D1D
ThemeBright2Color=19F9F
ThemeBackgroundColor=4A5A60
ThemeFont1Color=1FFFF
ThemeFont2Color=FCC84B
ThemePanel1Color=355051
ThemePanel2Color=674704
ThemePanel3Color=355051
ThemePanel4Color=1D5852
ThemeEditboxColor=292929
ThemeDisabledColor=212121
ThemeButtonOnColor=FF01FF
ThemeButtonReadyColor=1FFFF
ThemeButtonAlertColor=FFCC00
[Cold Steel]
ThemeBorderLightColor=888888
ThemeBorderDarkColor=333333
ThemeBright1Color=313131
ThemeBright2Color=C0C0C0
ThemeBackgroundColor=414141
ThemeFont1Color=1FFFF
ThemeFont2Color=FAE7AD
ThemePanel1Color=204040
ThemePanel2Color=984C01
ThemePanel3Color=70D1C8
ThemePanel4Color=654901
ThemeEditboxColor=292929
ThemeDisabledColor=212121
ThemeButtonOnColor=FF01FF
ThemeButtonReadyColor=1FFFF
ThemeButtonAlertColor=FFCC00
[Militarized]
ThemeBorderLightColor=888888
ThemeBorderDarkColor=333333
ThemeBright1Color=66B1FE
ThemeBright2Color=FEFE98
ThemeBackgroundColor=606060
ThemeFont1Color=98CBFE
ThemeFont2Color=FE8001
ThemePanel1Color=202020
ThemePanel2Color=984C01
ThemePanel3Color=355051
ThemePanel4Color=70D1C8
ThemeEditboxColor=292929
ThemeDisabledColor=212121
ThemeButtonOnColor=01FE80
ThemeButtonReadyColor=CFA645
ThemeButtonAlertColor=FFCC00
[Ocean]
ThemeBorderLightColor=446466
ThemeBorderDarkColor=333333
ThemeBright1Color=365154
ThemeBright2Color=3C3C3C
ThemeBackgroundColor=2C3537
ThemeFont1Color=1FFFF
ThemeFont2Color=256D65
ThemePanel1Color=355051
ThemePanel2Color=70D1C8
ThemePanel3Color=355051
ThemePanel4Color=70D1C8
ThemeEditboxColor=292929
ThemeDisabledColor=212121
ThemeButtonOnColor=1FFFF
ThemeButtonReadyColor=9D9D9D
ThemeButtonAlertColor=FFCC00
[LCD]
ThemeBackgroundColor=B0C6B6
ThemeBorderLightColor=5B8471
ThemeBorderDarkColor=5E5E01
ThemeBright1Color=1D1D1D
ThemeBright2Color=19F9F
ThemeFont1Color=E9F977
ThemeFont2Color=303030
ThemePanel1Color=6D8B87
ThemePanel2Color=73714D
ThemePanel3Color=6D8B87
ThemePanel4Color=73714D
ThemeEditboxColor=CEAFD1
ThemeDisabledColor=212121
ThemeButtonOnColor=FF01FF
ThemeButtonReadyColor=D7FF82
ThemeButtonAlertColor=FFCC00
[Neon]
ThemeBackgroundColor=414141
ThemeBorderLightColor=888888
ThemeBorderDarkColor=333333
ThemeBright1Color=C0C0C0
ThemeBright2Color=FFFFFF
ThemeFont1Color=1FFFF0
ThemeFont2Color=FBD58E
ThemePanel1Color=204040
ThemePanel2Color=804001
ThemePanel3Color=204040
ThemePanel4Color=804001
ThemeEditboxColor=292929
ThemeDisabledColor=212121
ThemeButtonOnColor=FF01FF
ThemeButtonReadyColor=1FFFF0
ThemeButtonAlertColor=FFCC00
)"
}