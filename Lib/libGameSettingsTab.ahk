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
GuiGameTab(&ui,&cfg) {
	global	
	loop cfg.gameModuleList.length {
		if fileExist("./lib/lib" cfg.gameModuleList[A_Index])
			runWait("./lib/lib" cfg.gameModuleList[A_Index])
	}

	ui.gameSettingsGui := Gui()
	ui.gameSettingsGui.Name := "nControl Game Settings"
	ui.gameSettingsGui.BackColor := cfg.themeBackgroundColor
	ui.gameSettingsGui.Color := cfg.themeBackgroundColor
	ui.gameSettingsGui.MarginX := 5
	ui.gameSettingsGui.Opt("-Caption -Border +AlwaysOnTop +ToolWindow +Owner" ui.MainGui.Hwnd)
	ui.gameSettingsGui.SetFont("s14 c" cfg.ThemeFont1Color,"Calibri")
	ui.gameTabs := ui.gameSettingsGui.addTab3("x-1 y-5 w497 h181 0x400 bottom c" cfg.themeFont1Color " choose" cfg.activeGameTab,cfg.gameModuleList)
	ui.gameTabs.choose(cfg.gameModuleList[cfg.activeGameTab])
	ui.gameTabs.setFont("s10")
	ui.gameTabs.onEvent("Change",gameTabChanged)
	ui.MainGui.GetPos(&winX,&winY,,)

 Loop cfg.gameList.length {
		try {
			runWait("./lib/lib" cfg.gameList[a_index])
			ui.gameTabs.value([cfg.gameList[a_index]])
			ui.gameTabs.useTab(cfg.gameList[a_index])
		}
	}
} 

ui.gameTabs.useTab("Destiny2") 
	ui.d2Sliding := false
	ui.d2HoldingRun := false         
	ui.d2cleanupNeeded := false

	ui.gameSettingsGui.setFont("s10")

	;UI.alwaysRunGb := ui.gameSettingsGui.addGroupbox("x10 y0 w270 h70","Always Run")
	ui.gameSettingsGui.addText("x10 y7 w475 h65 background" cfg.themePanel1Color,"")
	drawOutlineNamed("d2AlwaysRunOutline",ui.gameSettingsGui,10,6,475,67,cfg.themeBright2Color,cfg.themeDark2Color,1)
	drawOutlineNamed("d2AlwaysRunOutline",ui.gameSettingsGui,20,6,70,1,cfg.themeBackgroundColor,cfg.themeBackgroundColor,2)
	drawOutlineNamed("d2AlwaysRunOutline",ui.gameSettingsGui,20,6,70,7,cfg.themeBackgroundColor,cfg.themeBright2Color,1)
	ui.gameSettingsGui.addText("x21 y-2 w68 h14 c" cfg.themeFont1Color " background" cfg.themeBackgroundColor," Always Run")
	drawOutlineNamed("d2AlwaysRunOutline",ui.gameSettingsGui,20,6,1,7,cfg.themeDark1Color,cfg.themeBright2Color,1)

	ui.d2AlwaysRun := ui.gameSettingsGui.addPicture("x19 y18 w30 h45 section " 
	((cfg.d2AlwaysRunEnabled) 
		? ("Background" cfg.ThemeButtonOnColor) 
			: ("Background" cfg.themeButtonReadyColor)),
	((cfg.d2AlwaysRunEnabled) 
		? ("./img/toggle_vertical_trans_on.png") 
			: ("./img/toggle_vertical_trans_off.png")))

	ui.panelColoring			:= ui.gameSettingsGui.addText("x11 y79 w475 h67 background" cfg.themePanel1Color,"")
	drawOutlineNamed("gameSettingsD2Panel",ui.gameSettingsGui,10,79,475,65,cfg.themeBright2Color,cfg.themeDark2Color,1)
	ui.d2SprintKey				:= ui.gameSettingsGui.AddPicture("xs+38 ys+0 w100 h33 section backgroundTrans","./img/keyboard_key_up.png")
	ui.d2SprintKeyData 			:= ui.gameSettingsGui.addText("xs y+-28 w100 h25 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2SprintKey),1,8))
	ui.d2SprintKeyLabel			:= ui.gameSettingsGui.addText("xs-1 y+0 w100 h20 center c" cfg.themeFont1Color " backgroundTrans","Sprint")
	ui.d2CrouchKey				:= ui.gameSettingsGui.addPicture("x+8 ys w100 h33 section backgroundTrans","./img/keyboard_key_up.png")
	ui.d2CrouchKeyData 			:= ui.gameSettingsGui.addText("xs y+-28 w100 h25 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2CrouchKey),1,8))
	ui.d2CrouchKeyLabel 		:= ui.gameSettingsGui.addText("xs-1 y+0 w100 h20 center c" cfg.themeFont1Color " backgroundTrans","Crouch")
	ui.d2ToggleWalkKey			:= ui.gameSettingsGui.addPicture("x+8 ys w100 h33 section backgroundTrans","./img/keyboard_key_up.png")
	ui.d2ToggleWalkKeyData 		:= ui.gameSettingsGui.addText("xs y+-28 w100 h25 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2ToggleWalkKey),1,8))
	ui.d2ToggleWalkKeyLabel		:= ui.gameSettingsGui.addText("xs-1 y+0 w100 h20 center c" cfg.themeFont1Color " backgroundTrans","Toggle Walk")
	ui.d2HoldWalkKey			:= ui.gameSettingsGui.addPicture("x+8 ys w100 h33 section backgroundTrans","./img/keyboard_key_up.png")
	ui.d2HoldWalkKeyData 		:= ui.gameSettingsGui.addText("xs y+-28 w100 h25 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2HoldWalkKey),1,8))
	ui.d2HoldWalkKeyLabel		:= ui.gameSettingsGui.addText("xs-1 y+0 w100 h20 center c" cfg.themeFont1Color " backgroundTrans","Hold to Walk")
	ui.d2LaunchDIMbutton		:= ui.gameSettingsGui.addPicture("xs-355 y+18 section w53 h53 backgroundTrans","./Img2/d2_button_DIM.png")
	ui.d2LaunchLightGGbutton	:= ui.gameSettingsGui.addPicture("x+10 ys w53 h53 backgroundTrans","./Img2/d2_button_LightGG.png")
	ui.d2LaunchBlueberriesButton := ui.gameSettingsGui.addPicture("x+10 ys w53 h53 backgroundTrans","./Img2/d2_button_bbgg.png")
	ui.d2LaunchD2CheckListButton := ui.gameSettingsGui.addPicture("x+10 ys w53 h53 backgroundTrans","./Img2/d2_button_d2CheckList.png")

	ui.d2AlwaysRun.ToolTip 			:= "Toggles holdToCrouch"
	ui.d2SprintKey.ToolTip 			:= "Click to Assign"
	ui.d2SprintKeyData.ToolTip  	:= "Click to Assign"
	ui.d2SprintKeyLabel.ToolTip		:= "Click to Assign"
	ui.d2CrouchKey.ToolTip			:= "Click to Assign"
	ui.d2CrouchKeyData.ToolTip  	:= "Click to Assign"
	ui.d2CrouchKeyLabel.ToolTip		:= "Click to Assign"
	ui.d2ToggleWalkKey.ToolTip		:= "Click to Assign"
	ui.d2ToggleWalkKeyData.ToolTip  := "Click to Assign"
	ui.d2ToggleWalkKeyLabel.ToolTip	:= "Click to Assign"
	ui.d2HoldWalkKey.ToolTip		:= "Click to Assign"
	ui.d2HoldWalkKeyData.ToolTip  	:= "Click to Assign"
	ui.d2HoldWalkKeyLabel.ToolTip	:= "Click to Assign"
	ui.d2LaunchDIMbutton.ToolTip	:= "Launch DIM in Browser"
	ui.d2LaunchLightGGbutton.toolTip := "Launch Light.gg in Browser"
	ui.d2LaunchBlueberriesButton.toolTip	:= "Launch Blueberries.gg in Browser"
	ui.d2Launchd2CheckListButton.toolTip	:= "Launch D2Checklist.com in Browser"

	ui.d2CrouchKeyData.setFont("s13")
	ui.d2SprintKeyData.setFont("s13")
	ui.d2ToggleWalkKeyData.setFont("s13")
	ui.d2HoldWalkKeyData.setFont("s13")
	ui.d2CrouchKeyLabel.setFont("s11")
	ui.d2SprintKeyLabel.setFont("s11")
	ui.d2ToggleWalkKeyLabel.setFont("s11")
	ui.d2HoldWalkKeyLabel.setFont("s11")

	ui.d2AlwaysRun.OnEvent("Click", toggleAlwaysRun)
	ui.d2CrouchKey.onEvent("click",d2CrouchKeyClicked)
	ui.d2SprintKey.onEvent("click",d2SprintKeyClicked)
	ui.d2ToggleWalkKey.onEvent("click",d2ToggleWalkKeyClicked)
	ui.d2HoldWalkKey.onEvent("click",d2HoldWalkKeyClicked)
	ui.d2CrouchKeyData.onEvent("click",d2CrouchKeyClicked)
	ui.d2SprintKeyData.onEvent("click",d2SprintKeyClicked)
	ui.d2ToggleWalkKeyData.onEvent("click",d2ToggleWalkKeyClicked)
	ui.d2HoldWalkKeyData.onEvent("click",d2HoldWalkKeyClicked)
	ui.d2LaunchDIMbutton.onEvent("click",d2launchDIMbuttonClicked)
	ui.d2LaunchLightGGbutton.onEvent("click",d2launchLightGGbuttonClicked)
	ui.d2LaunchD2checkListButton.onEvent("click",d2launchd2checklistButtonClicked)
	ui.d2LaunchBlueberriesButton.onEvent("click",d2LaunchBlueBerriesButtonClicked
)

toggleAlwaysRun(*) {
	(cfg.d2AlwaysRunEnabled := !cfg.d2AlwaysRunEnabled)
		? thisToggleOn()
		: thisToggleOff()

	thisToggleOn() {
		ui.d2AlwaysRun.Opt("Background" cfg.ThemeButtonOnColor)
		ui.d2AlwaysRun.value := "./img/toggle_vertical_trans_on.png"
		try {
			ui.dockBarD2AlwaysRun.Opt("Background" cfg.ThemeButtonOnColor)
			ui.dockBarD2AlwaysRun.value := "./img/toggle_vertical_trans_on.png"
		}
	}
	thisToggleOff() {
		ui.d2AlwaysRun.opt("background" cfg.ThemeButtonReadyColor)
		ui.d2AlwaysRun.value := "./img/toggle_vertical_trans_off.png"
		try {
			ui.dockBarD2AlwaysRun.opt("background" cfg.ThemeButtonReadyColor)
			ui.dockBarD2AlwaysRun.value := "./img/toggle_vertical_trans_off.png"
		}
	}
send("{" cfg.d2ToggleWalkKey " Down}")
sleep(150)
send("{" cfg.d2ToggleWalkKey "}")
SetCapsLockState("Off")

}
	

d2LaunchDIMButtonClicked(*) {
	ui.d2LaunchDIMbutton.value := "./Img2/d2_button_DIM_down.png"
	setTimer () => ui.d2LaunchDIMbutton.value := "./Img2/d2_button_DIM.png",-400
	
	run("chrome.exe http://app.destinyitemmanager.com")
}

d2LaunchLightGGbuttonClicked(*) {
	ui.d2LaunchLightGGbutton.value := "./Img2/d2_button_LightGG_down.png"
	setTimer () => ui.d2LaunchLightGGbutton.value := "./Img2/d2_button_LightGG.png",-400
	run("chrome.exe https://www.light.gg/god-roll/roll-appraiser/")	
}

d2LaunchBlueBerriesButtonClicked(*) {
	ui.d2LaunchBlueberriesButton.value := "./Img2/d2_button_bbgg_down.png"
	setTimer () => ui.d2LaunchBlueberriesButton.value := "./Img2/d2_button_bbgg.png",-400
	run("chrome.exe https://www.blueberries.gg")
	}
d2Launchd2CheckListButtonClicked(*) {
	ui.d2Launchd2ChecklistButton.value := "./Img2/d2_button_d2Checklist_down.png"
	setTimer () => ui.d2Launchd2ChecklistButton.value := "./Img2/d2_button_d2Checklist.png",-400
	run("chrome.exe https://www.d2checklist.com")
	}

d2SprintKeyClicked(*) {
	DialogBox('Press "Hold to Sprint" Key`n Bound in Destiny 2',"Center")
	Sleep(100)
d2SprintInput := InputHook("L1 T6",inputHookAllowedKeys,"+V")
	d2SprintInput.start()
	d2SprintInput.wait()
	if (d2SprintInput.endKey == "" && d2SprintInput.input =="") {
		DialogBoxClose()
		notifyOSD('No Key Detected.`nPlease Try Again.',2000,"Center")
	} else {
		if (d2SprintInput.input)
		{
			cfg.d2SprintKey := d2SprintInput.input
		} else {
			cfg.d2SprintKey := d2SprintInput.endKey
		}
		ui.d2SprintKeyData.text := subStr(strUpper(cfg.d2SprintKey),1,8)
	}

	DialogBoxClose()
}

d2CrouchKeyClicked(*) {
	DialogBox('Press "Hold to Crouch" Key`nBound in Destiny 2',"Center")
	Sleep(100)
	d2CrouchInput := InputHook("L1 T6", inputHookAllowedKeys,"+V")
	d2CrouchInput.start()
	d2CrouchInput.wait()
	if (d2CrouchInput.endKey == "" && d2CrouchInput.input == "") {
		DialogBoxClose()
		notifyOSD('No Key Detected.`nPlease Try Again.',2000,"Center")
	} else {
		if (d2CrouchInput.input)
		{
			cfg.d2CrouchKey := d2CrouchInput.input
		} else {
			cfg.d2CrouchKey := d2CrouchInput.endKey
		}
		ui.d2CrouchKeyData.text := subStr(strUpper(cfg.d2CrouchKey),1,8)
	}
	DialogBoxClose()
}

d2ToggleWalkKeyClicked(*) {
	DialogBox('Press Key to Assign to: `n"Toggle Walk"',"Center")
	Sleep(100)
	d2ToggleWalkInput := InputHook("L1 T6", inputHookAllowedKeys,"+V")
	d2ToggleWalkInput.start()
	d2ToggleWalkInput.wait()
	if (d2ToggleWalkInput.endKey == "" && d2ToggleWalkInput.input == "") {
		DialogBoxClose()
		notifyOSD('No Key Detected.`nPlease Try Again.',2000,"Center")
	} else {
		if (d2ToggleWalkInput.input)
		{
			cfg.d2ToggleWalkKey := d2ToggleWalkInput.input
		} else {
			cfg.d2ToggleWalkKey := d2ToggleWalkInput.endKey
		}
		ui.d2ToggleWalkKeyData.text := subStr(strUpper(cfg.d2ToggleWalkKey),1,8)
	}
	DialogBoxClose()
}

d2HoldWalkKeyClicked(*) {
	DialogBox('Press Key to Assign to: `n"Hold to Walk"',"Center")
	Sleep(100)
	d2HoldWalkInput := InputHook("L1 T6", inputHookAllowedKeys,"+V")
	d2HoldWalkInput.start()
	d2HoldWalkInput.wait()
	if (d2HoldWalkInput.endKey == "" && d2HoldWalkInput.input == "") {
		DialogBoxClose()
		notifyOSD('No Key Detected.`nPlease Try Again.',2000,"Center")
	} else {
		if (d2HoldWalkInput.input)
		{
			cfg.d2HoldWalkKey := d2HoldWalkInput.input
		} else {
			cfg.d2HoldWalkKey := d2HoldWalkInput.endKey
		}
		ui.d2HoldWalkKeyData.text := subStr(strUpper(cfg.d2HoldWalkKey),1,8)
	}
	DialogBoxClose()
}

HotIf(readyToRun)
	hotKey("w",startRunning)
HotIf()

HotIf(d2IsRunning)
	hotKey("w up",stopRunning)
hotIf()


keyCleanUp(this,*) {
	for keyForCleanup in 
				[cfg.d2ToggleWalkKey
				,cfg.d2HoldWalkKey
				,cfg.d2SprintKey
				,cfg.d2CrouchKey
				,"Shift"
				,"Ctrl"
				,"Alt"]
		send("{" keyForCleanup "}")
		SetCapsLockState("Off")
		d2cleanupNeeded := false
}

d2IsRunning(*) {
	if getKeyState(cfg.d2SprintKey)
		return 1
	else
		return 0
}

HotIfWinActive("ahk_exe destiny2.exe")
	hotKey("~" cfg.d2holdWalkKey,holdToWalk)
	hotKey(cfg.d2ToggleWalkKey,toggleAlwaysRun)
	hotKey("r",d2reload)
HotIf()

; hotIf(winActive("ahk_exe destiny2.exe")) {
	; for keyForCleanup in 
				; [cfg.d2ToggleWalkKey
				; ,cfg.d2HoldWalkKey
				; ,cfg.d2SprintKey
				; ,cfg.d2CrouchKey
				; ,"Shift"
				; ,"Ctrl"
				; ,"Alt"]
		; hotkey("{" keyForCleanup "}",keyCleanUp)
; hotIf()
readyToRun(*) {
	if (winActive("ahk_exe destiny2.exe") && cfg.d2AlwaysRunEnabled && !(getKeyState("RButton") || getKeyState(cfg.d2HoldWalkKey)))
		Return 1
	else
		Return 0
}

holdToWalk(*) {
	if ui.d2Running 
		send("{" strLower(cfg.d2SprintKey) " up}")
	ui.dockBarWin1Cmd.text := strUpper(cfg.d2SprintKey)
	send("{" cfg.d2holdWalkKey " Down}")
	keyWait(cfg.d2HoldWalkKey,"L")
	send("{" cfg.d2HoldWalkKey "}")

	if ui.d2Running
		send("{" strLower(cfg.d2SprintKey) " down}")
	ui.d2cleanupNeeded := true
}

stopRunning(*) {
	ui.d2Running := false
	send("{" strLower(cfg.d2SprintKey) " up}{w up}")
		ui.dockBarWin1Cmd.text := "--"
	ui.d2cleanupNeeded := true
}

startRunning(*) {
	ui.d2Running := true
		ui.dockBarWin1Cmd.text := strUpper(subStr(cfg.d2SprintKey,1,2))
	send("{w down}{" strLower(cfg.d2sprintKey) " down}")
	ui.d2cleanupNeeded := true
}

toggleToWalk(*) {
	ui.d2AlwaysRun.value := 
		(cfg.d2AlwaysRunEnabled := !cfg.d2AlwaysRunEnabled)
			? (ui.d2AlwaysRun.opt("background" cfg.themeButtonOnColor),"./img/toggle_vertical_trans_on.png")
			: (ui.d2AlwaysRun.opt("background" cfg.themeButtonReadyColor),"./img/toggle_vertical_trans_off.png")
	ui.d2cleanupNeeded := true
}

d2reload(*) {
	send("{r}")
	ui.d2Reloading := true
	setTimer () => ui.d2Reloading := false, -2000
	ui.d2cleanupNeeded := true
}


	ui.gameTabs.useTab("World//Zero")
	ui.gameSettingsGui.addText("x10 y7 w475 h65 background" cfg.themePanel1Color,"")
	drawOutlineNamed("w0AutoTowerOutline",ui.gameSettingsGui,10,6,475,67,cfg.themeBright2Color,cfg.themeDark2Color,1)
	drawOutlineNamed("w0AutoTowerHorizLine",ui.gameSettingsGui,20,6,70,1,cfg.themeBackgroundColor,cfg.themeBackgroundColor,2)
	drawOutlineNamed("w0AutoTowerVertLine",ui.gameSettingsGui,20,6,70,7,cfg.themeBackgroundColor,cfg.themeBright2Color,1)
	ui.gameSettingsGui.addText("x21 y-2 w68 h14 c" cfg.themeFont1Color " background" cfg.themeBackgroundColor," Auto Tower")
	drawOutlineNamed("w0AutoAfkTabs",ui.gameSettingsGui,20,6,1,7,cfg.themeDark1Color,cfg.themeBright2Color,1)
	ui.gameSettingsGui.setFont("s10")
	ui.toggleCelestialTower := ui.gameSettingsGui.AddPicture("x20 y20 w60 h25 section vCelestialTower " (cfg.CelestialTowerEnabled ? ("Background" cfg.ThemeButtonAlertColor) : ("Background" cfg.ThemeButtonAlertColor)),((cfg.CelestialTowerEnabled) ? "./img/towerToggle_celestial.png" : "./img/towerToggle_infinite.png"))
	ui.toggleCelestialTower.OnEvent("Click", towerToggleChanged)
	ui.toggleCelestialTower.ToolTip := "Toggles between Infinite and Celestial Towers."
	ui.towerIntervalSlider := ui.gameSettingsGui.addSlider("x+0 ys-4 w160 h30 tickInterval5 altSubmit vTowerCycleLength thick18 center section Range1-50  background" 
	cfg.themePanel1Color " ToolTip",cfg.towerInterval)
	ui.towerIntervalSlider.onEvent("change",towerCycleChange)
	towerCycleChange(*) {
		ui.cycleLengthData.value := ui.towerIntervalSlider.value
		controlFocus(ui.gameTabs)
	}
	ui.cycleLengthData := ui.gameSettingsGui.AddText("x+0 ys+3 w35 h30 section center background" cfg.themeBackgroundColor,ui.towerIntervalSlider.value)
	ui.cycleLengthData.setFont("s18")
	ui.labelCelestialTower:= ui.gameSettingsGui.AddText("xs-220 y+-1 w60 section backgroundTrans","Tower Type")
	ui.labelTowerTiming := ui.gameSettingsGui.AddText("ys w160 center section backgroundTrans","Cycle Length")	
	drawOutlineNamed("towerCycleLength",ui.gameSettingsGui,239,19,36,31,cfg.themeDark2Color,cfg.themeBright2Color,1)
	ui.towerIntervalSlider.OnEvent("Change",towerIntervalChanged)
	ui.towerIntervalSlider.ToolTip := "Tower Restart Interval"
	ToggleCelestialTower(*)
	{
		ui.toggleCelestialTower.Opt((cfg.CelestialTowerEnabled := !cfg.CelestialTowerEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleCelestialTower.Redraw()
	}
		towerIntervalChanged(*) {
		cfg.towerInterval := ui.towerIntervalSlider.Value
	}

	ToggleSilentIdle(*)
	{
		ui.toggleSilentIdle.Opt((cfg.SilentIdleEnabled := !cfg.SilentIdleEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.toggleSilentIdle.Redraw()
	}
	ui.toggleSilentIdle := ui.gameSettingsGui.AddPicture("xs-60 y+45 w60 h25 section vSilentIdle " (r)),((cfg.SilentIdleEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor) ? (cfg.toggleOn) : (cfg.toggleOff)))
	ui.toggleSilentIdle.OnEvent("Click", toggleChanged)
	ui.toggleSilentIdle.ToolTip := "Minimizes Roblox Windows While Anti-Idling"
	ui.labelSilentIdle:= ui.gameSettingsGui.AddText("xs-8 y+0 w80 center backgroundTrans","Silent AntiIdle")
	
	
	
	
	drawGameTabs(tabNum := 1) {	
	try	 
		ui.gameTabGui.destroy()
	ui.gameTabGui := gui()
	ui.gameTabGui.opt("-caption toolWindow alwaysOnTop +E0x20 owner" ui.gameSettingsGui.hwnd)
	ui.gameTabGui.backColor := ui.transparentColor
	ui.gameTabGui.color := ui.transparentColor
	drawOutlineNamed("gameTabOutline",ui.gameTabGui,0,0,227,28,cfg.themeBright1Color,cfg.themeBright1Color,1)
	
	winSetTransColor(ui.transparentColor,ui.gameTabGui)
	ui.gameTabGui.addText("x1 y0 w0 h27 section background" cfg.themeBright1Color,"")
	ui.gameTab1Skin := ui.gameTabGui.addText(
		((tabNum == 1) ? "ys+0 h27" : "ys+1 h26")
		" x+0 w110 section center background" 
		((tabNum == 1) ? cfg.themeBackgroundColor : cfg.themePanel4Color) 
		" c" ((tabNum == 1) ? cfg.themeFont1Color : cfg.themeFont4Color)
		,"Destiny 2")
	ui.gameTab1Skin.setFont((tabNum == 1 ? "s14" : "s12"),"Impact")
	ui.gameTabGui.addText("ys x+0  w2 h27 section background" cfg.themeBright1Color,"")
	ui.gameTab2Skin := ui.gameTabGui.addText(
		((tabNum == 2) 
			? "ys-1 h27" 
			: "ys+2 h25")
		" x+0 w112 section center background" 
		((tabNum == 2) 
			? cfg.themeBackgroundColor 
			: cfg.themePanel4Color)
		" c" ((tabNum == 2)
			? cfg.themeFont1Color 
			: cfg.themeFont4Color)
		,"World//Zero")
	ui.gameTab2Skin.setFont(
		((tabNum == 2)
			? "s14" 
			: "s12")
		,"Impact")
	ui.gameTabGui.addText("ys+0 x+0 w2 " (tabNum == 1 ? "h26" : "h27") " section background" cfg.themeBright1Color,"")
	; ui.gameTabPadding := ui.gameTabGui.addText("x227 y1 w275 h28 section background" cfg.themeBackgroundColor)
	; ui.gameTabPadding.setFont("s14")
	guiVis(ui.gameTabGui,false)
	winGetPos(&winX,&winY,,,ui.mainGui.hwnd)
	ui.gameTabGui.show("w227 h29 x" winX+35 " y" winY+184 " noActivate")
}

drawGameTabs(cfg.activeGameTab)
;gameTabChanged()



gameTabChanged(*) {
	cfg.activeGameTab := ui.gametabs.value
	drawGameTabs(ui.gameTabs.value)
	guiVis(ui.gameTabGui,true)
	controlFocus(ui.buttonDockAfk)
}
