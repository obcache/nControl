;##################Header v1.0#####################
;A_AppName 			:= "nControl"
;A_Filename 		:= "libThemeCreator.ahk"
;A_FileAuthor		:= "obcache"
;A_FileCreateDate	:= "20240204
;A_FileDescription	:= "Theme creation/editing Gui"
;##################################################

#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
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
