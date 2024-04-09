#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)) { ;run main app
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}

{ ;global UI
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
		ui.gameTabs := ui.gameSettingsGui.addTab3("x-1 y-5 w496 h181 0x400 bottom c" cfg.themeFont1Color " choose" cfg.activeGameTab,cfg.gameModuleList)
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
} ;END global UI

{ ;Global UI Logic
	drawGameTabs(cfg.activeGameTab)
	;gameTabChanged()

	gameTabChanged(*) {
		cfg.activeGameTab := ui.gametabs.value
		drawGameTabs(ui.gameTabs.value)
		guiVis(ui.gameTabGui,true)
		controlFocus(ui.buttonDockAfk)
	}

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
		ui.gameTab1Skin.setFont((tabNum == 1 ? "s14" : "s11"),"Impact")
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
				: "s11")
			,"Impact")
		ui.gameTabGui.addText("ys+0 x+0 w2 " (tabNum == 1 ? "h26" : "h27") " section background" cfg.themeBright1Color,"")
		guiVis(ui.gameTabGui,false)
		winGetPos(&winX,&winY,,,ui.mainGui.hwnd)
		ui.gameTabGui.show("w227 h29 x" winX+35 " y" winY+184 " noActivate")
	}
}

{ ;d2 Logic
	ui.d2IsReloading := false
	ui.d2IsSprinting := false
	
	d2reload(*) {
		
		if cfg.d2AlwaysRunEnabled {
			d2ToggleAlwaysRunOff()
			setTimer () => (ui.d2IsReloading := false,d2ToggleAlwaysRunOn()),-3000
		}	
		;setTimer () => d2ToggleAlwaysRunOn(), -2600
	}

	d2MountVehicle(*) {
		send("{tab down}")
		send("{e down}{e up}")
		send("{tab}")
	}

	hotIfWinActive("ahk_exe destiny2.exe")
		hotKey(cfg.d2AppVehicleKey,d2MountVehicle)
		hotKey(cfg.d2AppToggleSprintKey,d2ToggleAlwaysRun)
		hotKey("~*r",d2reload)
	hotIf()

	hotIf(d2ReadyToReload)
		hotKey("~*r",d2reload)
	hotIf()
	
	hotIf(d2ReadyToSprint)
		hotKey("~*w",d2StartSprinting)
	hotIf()

	d2FireButtonClicked(*) {
	send("{LButton Down}")
	keyWait("LButton")

	send("{LButton Up}")
	if ui.d2IsSprinting
		send("{" cfg.d2GameToggleSprintKey "}")
}
	d2ReadyToReload(*) {
		if winActive("ahk_exe destiny2.exe") && !ui.d2IsReloading	
			return 1
		else
			return 0	
	}
	
	d2ReadyToSprint(*) {
		if (winActive("ahk_exe destiny2.exe") && cfg.d2AlwaysRunEnabled && !getKeyState("RButton"))
			return 1
		else
			return 0
	}
	
	d2startSprinting(*) {
		ui.d2IsSprinting := true
		;send("{w down}")
		if (cfg.d2AlwaysRunEnabled) {
			send("{" strLower(cfg.d2GameToggleSprintKey) "}")
		}
		setCapsLockState("Off")
		keyWait("w","L")
		send("{w up}")
	}


	d2ToggleAlwaysRun(*) {
		(cfg.d2AlwaysRunEnabled := !cfg.d2AlwaysRunEnabled)
			? d2ToggleAlwaysRunOn()
			: d2ToggleAlwaysRunOff()
	}

	d2ToggleAlwaysRunOn() {
		SetCapsLockState("Off")
		cfg.d2AlwaysRunEnabled := true
		;ui.d2Log.text := " start: SPRINT`n rcvd: " strUpper(subStr(cfg.d2AppToggleSprintKey,1,8)) "`n" ui.d2Log.text
		ui.d2AlwaysSprint.Opt("Background" cfg.ThemeButtonOnColor)
		ui.d2AlwaysSprint.value := "./img/toggle_vertical_trans_on.png"
		try {
			ui.dockBarD2AlwaysRun.Opt("Background" cfg.ThemeButtonOnColor)
			ui.dockBarD2AlwaysRun.value := "./img/toggle_vertical_trans_on.png"
		}
	}

	d2ToggleAlwaysRunOff() {
		if ui.d2IsSprinting
			send("{" cfg.d2AppToggleSprintKey "}")
		ui.d2IsSprinting := false
		SetCapsLockState("Off")
		cfg.d2AlwaysRunEnabled := false
		

		;ui.d2Log.text := " stop: SPRINT`n rcvd: " strUpper(subStr(cfg.d2AppToggleSprintKey,1,8)) "`n" ui.d2Log.text
		ui.d2AlwaysSprint.opt("background" cfg.ThemeButtonReadyColor)
		ui.d2AlwaysSprint.value := "./img/toggle_vertical_trans_off.png"
		try {
			ui.dockBarD2AlwaysRun.opt("background" cfg.ThemeButtonReadyColor)
			ui.dockBarD2AlwaysRun.value := "./img/toggle_vertical_trans_off.png"
		}
	}

	
	
	
	
	keyCleanUp(this,*) {
		for keyForCleanup in 
					[cfg.d2GameToggleSprintKey
					,cfg.d2GameHoldSprintKey
					,cfg.d2AppToggleSprintKey
					,cfg.d2GameHoldCrouchKey
					,"Shift"
					,"Ctrl"
					,"Alt"]
			send("{" keyForCleanup "}")
			SetCapsLockState("Off")
			d2cleanupNeeded := false
	}

} ;END d2 Logic

{ ;d2 UI
		ui.gameTabs.useTab("Destiny2") 
		
		ui.d2Sliding := false
		ui.d2HoldingRun := false         
		ui.d2cleanupNeeded := false

		ui.gameSettingsGui.setFont("s10")
		ui.gameSettingsGui.addText("x6 y3 w480 h62 background" cfg.themePanel1Color,"")
		ui.gameSettingsGui.addText("x6 y68 w480 h79 background" cfg.themePanel1Color,"")

		ui.gameSettingsGui.addText("x24 y74 w445 h64 c" cfg.themePanel1Color " background" cfg.themePanel2Color)
		drawOutlineNamed("d2AlwaysRunOutline",ui.gameSettingsGui,22,72,447,67,cfg.themeBright2Color,cfg.themeBright1Color,1)
		drawOutlineNamed("d2AlwaysRunOutline",ui.gameSettingsGui,6,3,480,62,cfg.themeBright2Color,cfg.themeDark2Color,1)
		drawOutlineNamed("d2AlwaysRunOutline",ui.gameSettingsGui,6,66,480,80,cfg.themeBright2Color,cfg.themeBright2Color,1)


		ui.gameSettingsGui.addText("hidden x19 y18 section")
		ui.gameSettingsGui.addText("x40 y10 w260 h43 background" cfg.themePanel2color " c" cfg.themeFont4color,"")
		drawOutlineNamed("gameSettings",ui.gameSettingsGui,40,11,260,42,cfg.themeDark1Color,cfg.themeBright1Color,1)
		ui.gameSettingsGui.addText("x306 y10 w173 h43 background" cfg.themePanel2color " c" cfg.themeFont4color,"")		
		drawOutlineNamed("appSettings",ui.gameSettingsGui,306,11,173,42,cfg.themeDark1Color,cfg.themeBright1Color,1)

		ui.d2gameToggleSprintKey			:= ui.gameSettingsGui.addPicture("x43 y20 w84  h28 section backgroundTrans","./img/keyboard_key_up.png")
		ui.d2gameToggleSprintKeyData 		:= ui.gameSettingsGui.addText("xs-3 y+-23 w84  h21 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2gameToggleSprintKey),1,8))
		ui.d2gameToggleSprintKeyLabel		:= ui.gameSettingsGui.addText("xs-1 y+-33 w84  h20 center c" cfg.themeFont1Color " backgroundTrans","Toggle Sprint")
		ui.d2gameHoldCrouchKey				:= ui.gameSettingsGui.addPicture("x+2 ys w84  h28 section backgroundTrans","./img/keyboard_key_up.png")
		ui.d2gameHoldCrouchKeyData 			:= ui.gameSettingsGui.addText("xs-3 y+-23 w84  h21 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2gameHoldCrouchKey),1,8))
		ui.d2gameHoldCrouchKeyLabel 		:= ui.gameSettingsGui.addText("xs-1 y+-33 w84  h20 center c" cfg.themeFont1Color " backgroundTrans","Hold to Crouch")
		ui.d2gameHoldSprintKey				:= ui.gameSettingsGui.AddPicture("x+2 ys w84  h28 section backgroundTrans","./img/keyboard_key_up.png")
		ui.d2gameHoldSprintKeyData 			:= ui.gameSettingsGui.addText("xs-3 y+-23 w84  h21 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2gameHoldSprintKey),1,8))
		ui.d2gameHoldSprintKeyLabel			:= ui.gameSettingsGui.addText("xs-1 y+-33 w84  h20 center c" cfg.themeFont1Color " backgroundTrans","Hold to Sprint")
		
		ui.d2AppToggleSprintKey				:= ui.gameSettingsGui.AddPicture("x309 y20 w84  h28 section backgroundTrans","./img/keyboard_key_up.png")
		ui.d2AppToggleSprintKeyData 		:= ui.gameSettingsGui.addText("xs-3 y+-23 w84  h21 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2AppToggleSprintKey),1,8))
		ui.d2AppToggleSprintKeyLabel		:= ui.gameSettingsGui.addText("xs-1 y+-33 w84  h20 center c" cfg.themeFont1Color " backgroundTrans","Toggle Sprint")
		ui.d2AppHoldCrouchKey				:= ui.gameSettingsGui.addPicture("x+2 ys w84  h28 section backgroundTrans","./img/keyboard_key_up.png")
		ui.d2AppHoldCrouchKeyData 			:= ui.gameSettingsGui.addText("xs-3 y+-23 w84  h21 center c" cfg.themeButtonAlertColor " backgroundTrans",subStr(strUpper(cfg.d2AppHoldCrouchKey),1,8))
		ui.d2AppHoldCrouchKeyLabel			:= ui.gameSettingsGui.addText("xs-1 y+-33 w84  h20 center c" cfg.themeFont1Color " backgroundTrans","Hold to Crouch")
		ui.d2AppVehicleKey					:= ui.gameSettingsGui.addPicture("x15 y55 w84  h28 section hidden backgroundTrans","./img/keyboard_key_up.png")
		ui.d2AppVehicleKeyData 				:= ui.gameSettingsGui.addText("xs y+-23 w84  h21 center c" cfg.themeButtonAlertColor " hidden backgroundTrans",subStr(strUpper(cfg.d2AppVehicleKey),1,8))
		ui.d2AppVehicleKeyLabel 			:= ui.gameSettingsGui.addText("xs-1 y+-20 w84  h20 hidden center c" cfg.themeFont1Color " backgroundTrans","Mount Vehicle")

		ui.d2LaunchDIMbutton				:= ui.gameSettingsGui.addPicture("xs+18 y+-5 section w60  h60 backgroundTrans","./Img2/d2_button_DIM.png")
		ui.d2LaunchLightGGbutton			:= ui.gameSettingsGui.addPicture("x+13 ys w60  h60 backgroundTrans","./Img2/d2_button_LightGG.png")
		ui.d2LaunchBlueberriesButton 		:= ui.gameSettingsGui.addPicture("x+13 ys w60  h60 backgroundTrans","./Img2/d2_button_bbgg.png")
		ui.d2LaunchD2CheckListButton 		:= ui.gameSettingsGui.addPicture("x+13 ys w60  h60 backgroundTrans","./Img2/d2_button_d2CheckList.png")
		ui.d2LaunchDestinyRecipesButton 	:= ui.gameSettingsGui.addPicture("x+13 ys w60  h60 backgroundTrans","./Img2/d2_button_destinyrecipes.png")
		ui.d2LaunchBrayTechButton 			:= ui.gameSettingsGui.addPicture("x+13 ys w60  h60 backgroundTrans","./Img2/d2_button_braytech.png")

		drawPanelLabel(guiName,labelX,labelY,labelW := 100,labelH := 20,labelText := "needs value",backColor := "gray",outlineColor := "white",fontColor := "white") {
			static labelName := array()
			static labelNum := 0
			labelNum +=1
			labelName.push("labelName" labelNum)
			labelName[labelNum] := guiName.addText("x" labelX " y" labelY " w" labelW " h" labelH/2-1 " background" outlineColor,"")
			labelName[labelNum].setFont("s10")
			labelNum +=1
			labelName.push("labelName" labelNum)
			labelName[labelNum] := guiName.addText("x" labelX+1 " y" labelY+1 " w" labelW-2 " h" labelH-2 " background" backColor " center c" fontColor) 
			labelName[labelNum].setFont("s10")
			labelName[labelNum] := guiName.addText("x" labelX+1 " y" labelY-1 " w" labelW-2 " h" labelH " backgroundTrans center c" fontColor, labelText) 
			labelName[labelNum].setFont("s10")
		}
		
		drawPanelLabel(ui.gameSettingsGui,125,47,90,15,"Game Settings",cfg.themePanel1Color,cfg.themeBright1Color,cfg.themeFont1Color)
		drawPanelLabel(ui.gameSettingsGui,349,47,80,15,"App Settings",cfg.themePanel1Color,cfg.themeBright1Color,cfg.themeFont1Color)
		
		; drawOutlineNamed("d2AlwaysRunOutline3",ui.gameSettingsGui,121,47,90,5,cfg.themeBright1Color,cfg.themePanel1Color,1)		
		; ui.gameSettingsGui.addText("x122 y48 w88 h15 c" cfg.themeFont1Color " background" cfg.themePanel1Color,"  Game Settings")
		; drawOutlineNamed("d2AlwaysRunOutline4",ui.gameSettingsGui,210,47,1,5,cfg.themeBright1Color,cfg.themeBright1Color,1)						 
			
		; }

		; drawOutlineNamed("d2AlwaysRunOutline3",ui.gameSettingsGui,349,47,85,5,cfg.themeBright1Color,cfg.themeBackgroundColor,1)		
		; ui.gameSettingsGui.addText("x350 y48 w83 h15 c" cfg.themeFont1Color " background" cfg.themePanel1Color,"   App Settings")
		; drawOutlineNamed("d2AlwaysRunOutline4",ui.gameSettingsGui,433,47,1,6,cfg.themeBright1Color,cfg.themeBright1Color,1)	
; ui.d2DestinySetupLabel 		:= ui.gameSettingsGui.addText("x15 y18 w84  h20  right section backgroundTrans","D2 Setup")
		; ui.d2AppSetupLabel 			:= ui.gameSettingsGui.addText("xs+0 y+25  w84  h20 right backgroundTrans","Your Binds")
		; ui.d2AppSetupLabel.setFont("s13")
		; ui.d2DestinySetupLabel.setFont("s13")

		
		; ui.d2AppSetupLabelInfo		:= ui.gameSettingsGui.addPicture("x105 y4 section w16 h16 backgroundTrans","./img2/icon_info.png")
		; ui.d2DestinySetupLabelInfo	:= ui.gameSettingsGui.addPicture("x105 y88 section w16 h16 backgroundTrans","./img2/icon_info.png")	
		; ui.d2AppSetupLabelInfo.toolTip 		:= "Bind these to what you'd`nlike to use when playing."
		; ui.d2DestinySetupLabelInfo.toolTip	:= "Bind these to whatever they're set to in Destiny 2."
		
		ui.d2AlwaysSprint := ui.gameSettingsGui.addPicture("x12 y10 w25 h43 section "
		((cfg.d2AlwaysRunEnabled) 
			? ("Background" cfg.ThemeButtonOnColor) 
				: ("Background" cfg.themeButtonReadyColor)),
		((cfg.d2AlwaysRunEnabled) 
			? ("./img/toggle_vertical_trans_on.png") 
				: ("./img/toggle_vertical_trans_off.png")))
		ui.d2Log			:= ui.gameSettingsGui.addText("x405 y10 w68 h80 hidden background" cfg.themePanel3color " c" cfg.themeFont3color," Destiny 2`n Log Started`n Waiting for Input")
		ui.d2Log.setFont("s7","ariel")

		ui.d2AlwaysSprint.ToolTip 			:= "Toggles holdToCrouch"
		ui.d2gameHoldSprintKey.ToolTip 			:= "Click to Assign"
		ui.d2gameHoldSprintKeyData.ToolTip  	:= "Click to Assign"
		ui.d2gameHoldSprintKeyLabel.ToolTip		:= "Click to Assign"
		ui.d2gameHoldCrouchKey.ToolTip			:= "Click to Assign"
		ui.d2gameHoldCrouchKeyData.ToolTip  	:= "Click to Assign"
		ui.d2gameHoldCrouchKeyLabel.ToolTip		:= "Click to Assign"
		ui.d2gameToggleSprintKey.ToolTip		:= "Click to Assign"
		ui.d2gameToggleSprintKeyData.ToolTip  := "Click to Assign"
		ui.d2gameToggleSprintKeyLabel.ToolTip	:= "Click to Assign"
		ui.d2AppToggleSprintKey.ToolTip		:= "Click to Assign"
		ui.d2AppToggleSprintKeyData.ToolTip  	:= "Click to Assign"
		ui.d2AppToggleSprintKeyLabel.ToolTip	:= "Click to Assign"
		ui.d2AppVehicleKey.ToolTip		:= "Click to Assign"
		ui.d2AppVehicleKeyData.ToolTip  	:= "Click to Assign"
		ui.d2AppVehicleKeyLabel.ToolTip	:= "Click to Assign"
		ui.d2AppHoldCrouchKey.ToolTip		:= "Click to Assign"
		ui.d2AppHoldCrouchKeyData.ToolTip  	:= "Click to Assign"
		ui.d2AppHoldCrouchKeyLabel.ToolTip	:= "Click to Assign"
		ui.d2LaunchDIMbutton.ToolTip	:= "Launch DIM in Browser"
		ui.d2LaunchLightGGbutton.toolTip := "Launch Light.gg in Browser"
		ui.d2LaunchBlueberriesButton.toolTip	:= "Launch Blueberries.gg in Browser"
		ui.d2Launchd2CheckListButton.toolTip	:= "Launch D2Checklist.com in Browser"
		ui.d2LaunchDestinyRecipesButton.toolTip	:= "Launch DestinyRecipes.com in Browser"
		ui.d2LaunchBrayTechButton.toolTip	:= "Launch Bray.Tech in Browser"

		ui.d2gameHoldCrouchKeyData.setFont("s11")
		ui.d2gameHoldSprintKeyData.setFont("s11")
		ui.d2gameToggleSprintKeyData.setFont("s11")
		ui.d2AppVehicleKeyData.setFont("s11")
		ui.d2AppHoldCrouchKeyData.setFont("s11")
		ui.d2AppToggleSprintKeyData.setFont("s11")

		ui.d2gameHoldCrouchKeyLabel.setFont("s9")
		ui.d2gameHoldSprintKeyLabel.setFont("s9")
		ui.d2gameToggleSprintKeyLabel.setFont("s9")
		
		ui.d2AppVehicleKeyLabel.setFont("s9")
		ui.d2AppHoldCrouchKeylabel.setFont("s9")
		ui.d2AppToggleSprintKeyLabel.setFont("s9")
		
		ui.d2AlwaysSprint.OnEvent("Click", d2ToggleAlwaysRun)
		
		ui.d2gameHoldCrouchKey.onEvent("click",d2gameHoldCrouchKeyClicked)
		ui.d2gameHoldSprintKey.onEvent("click",d2gameHoldSprintKeyClicked)
		ui.d2gameToggleSprintKey.onEvent("click",d2gameToggleSprintKeyClicked)
		
		ui.d2gameHoldCrouchKeyData.onEvent("click",d2gameHoldCrouchKeyClicked)
		ui.d2gameHoldSprintKeyData.onEvent("click",d2gameHoldSprintKeyClicked)
		ui.d2gameToggleSprintKeyData.onEvent("click",d2gameToggleSprintKeyClicked)
		
		ui.d2AppVehicleKey.onEvent("click",d2AppVehicleKeyClicked)
		ui.d2AppHoldCrouchKey.onEvent("click",d2AppHoldCrouchKeyClicked)
		ui.d2AppToggleSprintKey.onEvent("click",d2AppToggleSprintKeyClicked)
		
		ui.d2AppVehicleKeyData.onEvent("click",d2AppVehicleKeyClicked)
		ui.d2AppHoldCrouchKeyData.onEvent("click",d2AppHoldCrouchKeyClicked)
		ui.d2AppToggleSprintKeyData.onEvent("click",d2AppToggleSprintKeyClicked)
		
		ui.d2LaunchDIMbutton.onEvent("click",d2launchDIMbuttonClicked)
		ui.d2LaunchLightGGbutton.onEvent("click",d2launchLightGGbuttonClicked)
		ui.d2LaunchD2checkListButton.onEvent("click",d2launchd2checklistButtonClicked)
		ui.d2LaunchBlueberriesButton.onEvent("click",d2LaunchBlueBerriesButtonClicked)
		ui.d2LaunchDestinyRecipesButton.onEvent("click",d2LaunchDestinyRecipesButtonClicked)
		ui.d2LaunchBrayTechButton.onEvent("click",d2LaunchBrayTechButtonClicked)

} ;end d2 ui
	
{ ;d2 UI Logic

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

	d2LaunchDestinyRecipesButtonClicked(*) {
		ui.d2LaunchDestinyRecipesButton.value := "./Img2/d2_button_destinyrecipes_down.png"
		setTimer () => ui.d2LaunchDestinyRecipesButton.value := "./Img2/d2_button_destinyrecipes.png",-400
		run("chrome.exe https://www.destinyrecipes.com")
		}

	d2LaunchBrayTechButtonClicked(*) {
		ui.d2LaunchBrayTechButton.value := "./Img2/d2_button_braytech_down.png"
		setTimer () => ui.d2LaunchBrayTechButton.value := "./Img2/d2_button_braytech.png",-400
		run("chrome.exe https://www.bray.tech")
		}

	d2GameHoldSprintKeyClicked(*) {
		DialogBox('Press "Hold to Sprint" Key`n Bound in Destiny 2',"Center")
		Sleep(100)
		d2GameHoldSprintKeyInput := InputHook("L1 T6",inputHookAllowedKeys,"+V")
		d2GameHoldSprintKeyInput.start()
		d2GameHoldSprintKeyInput.wait()
		if (d2GameHoldSprintKeyInput.endKey == "" && d2GameHoldSprintKeyInput.input =="") {
			DialogBoxClose()
			notifyOSD('No Key Detected.`nPlease Try Again.',2000,"Center")
		} else {
			if (d2GameHoldSprintKeyInput.input)
			{
				cfg.d2GameHoldSprintKey := d2GameHoldSprintKeyInput.input
			} else {
				cfg.d2GameHoldSprintKey := d2GameHoldSprintKeyInput.endKey
			}
			ui.d2GameHoldSprintKeyData.text := subStr(strUpper(cfg.d2GameHoldSprintKey),1,8)
		}

		DialogBoxClose()
	}

	d2gameHoldCrouchKeyClicked(*) {
		DialogBox('Press "Hold to Crouch" Key`nBound in Destiny 2',"Center")
		Sleep(100)
		d2GameHoldCrouchKeyInput := InputHook("L1 T6", inputHookAllowedKeys,"+V")
		d2GameHoldCrouchKeyInput.start()
		d2GameHoldCrouchKeyInput.wait()
		if (d2GameHoldCrouchKeyInput.endKey == "" && d2GameHoldCrouchKeyInput.input == "") {
			DialogBoxClose()
			notifyOSD('No Key Detected.`nPlease Try Again.',2000,"Center")
		} else {
			if (d2GameHoldCrouchKeyInput.input)
			{
				cfg.d2GameHoldCrouchKey := d2GameHoldCrouchKeyInput.input
			} else {
				cfg.d2GameHoldCrouchKey := d2GameHoldCrouchKeyInput.endKey
			}
			ui.d2GameHoldCrouchKeyData.text := subStr(strUpper(cfg.d2GameHoldCrouchKey),1,8)
		}
		DialogBoxClose()
	}



	d2GameToggleSprintKeyClicked(*) {
		DialogBox('Press Key to Assign to: `n"Hold to Walk"',"Center")
		Sleep(100)
		d2GameToggleSprintKeyInput := InputHook("L1 T6", inputHookAllowedKeys,"+V")
		d2GameToggleSprintKeyInput.start()
		d2GameToggleSprintKeyInput.wait()
		if (d2GameToggleSprintKeyInput.endKey == "" && d2GameToggleSprintKeyInput.input == "") {
			DialogBoxClose()
			notifyOSD('No Key Detected.`nPlease Try Again.',2000,"Center")
		} else {
			if (d2GameToggleSprintKeyInput.input)
			{
				cfg.d2GameToggleSprintKey := d2GameToggleSprintKeyInput.input
			} else {
				cfg.d2GameToggleSprintKey := d2GameToggleSprintKeyInput.endKey
			}
			ui.d2GameToggleSprintKeyData.text := subStr(strUpper(cfg.d2GameToggleSprintKey),1,8)
		}
		DialogBoxClose()
	}

	d2AppToggleSprintKeyClicked(*) {
		DialogBox('Press Key to Assign to: `n"Toggle Walk"',"Center")
		Sleep(100)
		d2AppToggleSprintKeyInput := InputHook("L1 T6", inputHookAllowedKeys,"+V")
		d2AppToggleSprintKeyInput.start()
		d2AppToggleSprintKeyInput.wait()
		if (d2AppToggleSprintKeyInput.endKey == "" && d2AppToggleSprintKeyInput.input == "") {
			DialogBoxClose()
			notifyOSD('No Key Detected.`nPlease Try Again.',2000,"Center")
		} else {
			if (d2AppToggleSprintKeyInput.input)
			{
				cfg.d2AppToggleSprintKey := d2AppToggleSprintKeyInput.input
			} else {
				cfg.d2AppToggleSprintKey := d2AppToggleSprintKeyInput.endKey
			}
			ui.d2AppToggleSprintKeyData.text := subStr(strUpper(cfg.d2AppToggleSprintKey),1,8)
		}
		DialogBoxClose()
	}


	d2AppVehicleKeyClicked(*) {
		DialogBox('Press Key to Assign to: `n"Toggle Walk"',"Center")
		Sleep(100)
		d2AppVehicleKeyInput := InputHook("L1 T6", inputHookAllowedKeys,"+V")
		d2AppVehicleKeyInput.start()
		d2AppVehicleKeyInput.wait()
		if (d2AppVehicleKeyInput.endKey == "" && d2AppVehicleKeyInput.input == "") {
			DialogBoxClose()
			notifyOSD('No Key Detected.`nPlease Try Again.',2000,"Center")
		} else {
			if (d2AppVehicleKeyInput.input)
			{
				cfg.d2AppVehicleKey := d2AppVehicleKeyInput.input
			} else {
				cfg.d2AppVehicleKey := d2AppVehicleKeyInput.endKey
			}
			ui.d2AppVehicleKeyData.text := subStr(strUpper(cfg.d2AppVehicleKey),1,8)
		}
		DialogBoxClose()
	}

	d2AppHoldCrouchKeyClicked(*) {
		DialogBox('Press Key to Assign to: `n"Mount Vehicle"',"Center")
		Sleep(100)
		d2AppHoldCrouchKeyInput := InputHook("L1 T6", inputHookAllowedKeys,"+V")
		d2AppHoldCrouchKeyInput.start()
		d2AppHoldCrouchKeyInput.wait()
		if (d2AppHoldCrouchKeyInput.endKey == "" && d2AppHoldCrouchKeyInput.input == "") {
			DialogBoxClose()
			notifyOSD('No Key Detected.`nPlease Try Again.',2000,"Center")
		} else {
			if (d2AppHoldCrouchKeyInput.input)
			{
				cfg.d2AppHoldCrouchKey := d2AppHoldCrouchKeyInput.input
			} else {
				cfg.d2AppHoldCrouchKey := d2AppHoldCrouchKeyInput.endKey
			}
			ui.d2AppHoldCrouchKeyData.text := subStr(strUpper(cfg.d2AppHoldCrouchKey),1,8)
		}
		DialogBoxClose()
	}

} ;END d2 UI Logic

{ ;w0 Tab
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
	ui.labelSilentIdle:= ui.gameSettingsGui.AddText("xs-8 y+0 w82 center backgroundTrans","Silent AntiIdle")
	
} ;end w0 tab
