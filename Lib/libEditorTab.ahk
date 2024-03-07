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
	
inputHookAllowedKeys := "{All}{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{Left}{Right}{Up}{Down}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}{Tab}{Enter}{ScrollLock}"	

GuiEditorTab() {
	ui.editorGui := Gui()
	ui.editorGui.Name := "nControl Game Settings"
	ui.editorGui.BackColor := cfg.themeBackgroundColor
	ui.editorGui.Color := cfg.themeBackgroundColor
	ui.editorGui.MarginX := 5
	ui.editorGui.Opt("-Caption -Border +AlwaysOnTop +ToolWindow +Owner" ui.MainGui.Hwnd)
	ui.editorGui.SetFont("s14 c" cfg.ThemeFont1Color,"Calibri")
	cfg.activeEditorTab := iniRead(cfg.file,"Interface","ActiveEditorTab","Hotkeys")
	ui.editorTabs := ui.editorGui.addTab3("x-1 y-5 w497 h181 bottom c" cfg.themeFont1Color " choose" cfg.activeEditorTab,["Hotkeys","Keybinds","Macros"])
	drawOutlineNamed("gameSettingsOutline",ui.editorGui,0,0,488,180,cfg.themeBorderDarkColor,cfg.themeBorderLightColor,0)
	ui.editorTabs.choose(cfg.activeEditorTab)
	ui.editorTabs.setFont("s14")
	ui.editorTabs.onEvent("Change",editorTabChanged)
	
	

	ui.editorTabs.useTab("Hotkeys") 

	ui.editorGui.setFont("s10")
	ui.editorGui.addText("x5 y5 w480 h130 background" cfg.themePanel1Color,"")
	drawOutlineNamed("d2AlwaysRunOutline",ui.editorGui,5,4,480,132,cfg.themeBright2Color,cfg.themeDark2Color,1)
	drawOutlineNamed("d2AlwaysRunOutline",ui.editorGui,15,4,93,1,cfg.themeBackgroundColor,cfg.themeBackgroundColor,2)
	drawOutlineNamed("d2AlwaysRunOutline",ui.editorGui,15,4,93,7,cfg.themeBackgroundColor,cfg.themeBright2Color,1)
	ui.editorGui.addText("x16 y-4 w91 h14 c" cfg.themeFont1Color " background" cfg.themeBackgroundColor,"  App Shortcuts")
	drawOutlineNamed("d2AlwaysRunOutline",ui.editorGui,15,4,1,7,cfg.themeDark1Color,cfg.themeBright2Color,1)
	ui.hotKeyLV := ui.editorGui.addListView("x7 y0 w470 h126",["Name","Keybind","Exe","Desc"])
	guiVis(ui.editorGui,false)
	ui.editorGui.show("w485 h175 noActivate")

		
		

		
	editorTabChanged(*) {
		cfg.activeEditorTab := ui.editorTabs.value
		iniWrite(cfg.activeEditorTab,cfg.file,"Interface","ActiveEditorTab")
		controlFocus(ui.editorTabs)
	}	
;ui.editorTabs.useTab("")

	


}	; ui.keyInputGui	:= gui()
	; ui.keyInputGui.opt("-caption toolWindow owner" ui.editorGui.hwnd)
	; ui.keyInputPanelColoring			:= ui.keyInputGui.addText("x11 y70 w475 h65 background" cfg.themePanel1Color,"")
		; drawOutlineNamed("gameSettingsD2Panel",ui.keyInputGui,10,69,475,65,cfg.themeDark1Color,cfg.themeDark2Color,1)
		; ui.d2SprintKey				:= ui.keyInputGui.AddPicture("xs+38 ys-1 w100 h33 section backgroundTrans","./img/keyboard_key_up.png")
		; ui.d2SprintKeyData 			:= ui.keyInputGui.addText("xs y+-28 w100 h25 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2SprintKey),1,8))
		; ui.d2SprintKeyLabel			:= ui.keyInputGui.addText("xs-1 y+0 w100 h20 center c" cfg.themeFont1Color " backgroundTrans","Sprint")
		; ui.d2CrouchKey				:= ui.keyInputGui.addPicture("x+8 ys w100 h33 section backgroundTrans","./img/keyboard_key_up.png")
		; ui.d2CrouchKeyData 			:= ui.keyInputGui.addText("xs y+-28 w100 h25 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2CrouchKey),1,8))
		; ui.d2CrouchKeyLabel 		:= ui.keyInputGui.addText("xs-1 y+0 w100 h20 center c" cfg.themeFont1Color " backgroundTrans","Crouch")
		; ui.d2ToggleWalkKey			:= ui.keyInputGui.addPicture("x+8 ys w100 h33 section backgroundTrans","./img/keyboard_key_up.png")
		; ui.d2ToggleWalkKeyData 		:= ui.keyInputGui.addText("xs y+-28 w100 h25 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2ToggleWalkKey),1,8))
		; ui.d2ToggleWalkKeyLabel		:= ui.keyInputGui.addText("xs-1 y+0 w100 h20 center c" cfg.themeFont1Color " backgroundTrans","Toggle Walk")
		; ui.d2HoldWalkKey			:= ui.keyInputGui.addPicture("x+8 ys w100 h33 section backgroundTrans","./img/keyboard_key_up.png")
		; ui.d2HoldWalkKeyData 		:= ui.keyInputGui.addText("xs y+-28 w100 h25 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2HoldWalkKey),1,8))
		; ui.d2HoldWalkKeyLabel		:= ui.keyInputGui.addText("xs-1 y+0 w100 h20 center c" cfg.themeFont1Color " backgroundTrans","Hold to Walk")
		; ui.d2LaunchDIMbutton		:= ui.keyInputGui.addPicture("xs-368 y+5 section w160 h60 backgroundTrans","./Img/button_launchDIM.png")
		; ui.d2LaunchLightGGbutton	:= ui.keyInputGui.addPicture("x+-4 ys w160 h60 backgroundTrans","./Img/button_launchLightGG.png")
		; ui.d2LaunchBlueberriesButton := ui.keyInputGui.addPicture("x+-4 ys w160 h60 backgroundTrans","./Img/button_launchBlueberries.png")
		

		; ui.d2AlwaysRun.ToolTip := "Toggles holdToCrouch"
		; ui.d2SprintKey.ToolTip 		:= "Click to Assign"
		; ui.d2SprintKeyData.ToolTip  := "Click to Assign"
		; ui.d2SprintKeyLabel.ToolTip	:= "Click to Assign"
		; ui.d2CrouchKey.ToolTip		:= "Click to Assign"
		; ui.d2CrouchKeyData.ToolTip  := "Click to Assign"
		; ui.d2CrouchKeyLabel.ToolTip	:= "Click to Assign"
		; ui.d2ToggleWalkKey.ToolTip		:= "Click to Assign"
		; ui.d2ToggleWalkKeyData.ToolTip  := "Click to Assign"
		; ui.d2ToggleWalkKeyLabel.ToolTip	:= "Click to Assign"
		; ui.d2HoldWalkKey.ToolTip		:= "Click to Assign"
		; ui.d2HoldWalkKeyData.ToolTip  := "Click to Assign"
		; ui.d2HoldWalkKeyLabel.ToolTip	:= "Click to Assign"
		; ui.d2LaunchDIMbutton.ToolTip	:= "Launch DIM in Browser"
		; ui.d2LaunchLightGGbutton.toolTip := "Launch Light.gg in Browser"
		; ui.d2LaunchBlueberriesButton.toolTip	:= "Launch Blueberries.gg in Browser"

		; ui.d2CrouchKeyData.setFont("s13")
		; ui.d2SprintKeyData.setFont("s13")
		; ui.d2ToggleWalkKeyData.setFont("s13")
		; ui.d2HoldWalkKeyData.setFont("s13")
		; ui.d2CrouchKeyLabel.setFont("s11")
		; ui.d2SprintKeyLabel.setFont("s11")
		; ui.d2ToggleWalkKeyLabel.setFont("s11")
		; ui.d2HoldWalkKeyLabel.setFont("s11")
		
		; ui.d2AlwaysRun.OnEvent("Click", toggleAlwaysRun)
		; ui.d2CrouchKey.onEvent("click",d2CrouchKeyClicked)
		; ui.d2SprintKey.onEvent("click",d2SprintKeyClicked)
		; ui.d2ToggleWalkKey.onEvent("click",d2ToggleWalkKeyClicked)
		; ui.d2HoldWalkKey.onEvent("click",d2HoldWalkKeyClicked)
		; ui.d2CrouchKeyData.onEvent("click",d2CrouchKeyClicked)
		; ui.d2SprintKeyData.onEvent("click",d2SprintKeyClicked)
		; ui.d2ToggleWalkKeyData.onEvent("click",d2ToggleWalkKeyClicked)
		; ui.d2HoldWalkKeyData.onEvent("click",d2HoldWalkKeyClicked)
		; ui.d2LaunchDIMbutton.onEvent("click",d2launchDIMbuttonClicked)
		; ui.d2LaunchLightGGbutton.onEvent("click",d2launchLightGGbuttonClicked)
		; ui.d2LaunchBlueberriesButton.onEvent("click",d2LaunchBlueBerriesButtonClicked)