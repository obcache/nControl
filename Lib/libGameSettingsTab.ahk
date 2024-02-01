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
	
GuiGameTab(&ui,&cfg)
{
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
;	winSetTransColor(ui.transparentColor,ui.gameSettingsGui)
	ui.gameTabs := ui.gameSettingsGui.addTab3("x2 y-5 w490 h181 bottom c" cfg.themeFont2Color " choose" cfg.activeGameTab,cfg.gameModuleList)
	drawOutlineNamed("gameSettingsOutline",ui.gameSettingsGui,0,170,488,6,cfg.themeBorderDarkColor,cfg.themeBorderLightColor,3)
	ui.gameTabs.choose(cfg.gameModuleList[cfg.activeGameTab])
	ui.gameTabs.setFont("s12")
	ui.gameTabs.onEvent("Change",gameTabChanged)
	ui.MainGui.GetPos(&winX,&winY,,)

 Loop cfg.gameList.length {
		try {
			runWait("./lib/lib" cfg.gameList[a_index])
			ui.gameTabs.value([cfg.gameList[a_index]])
			ui.gameTabs.useTab(cfg.gameList[a_index])
		}
	}
} ;End Game Profile List Modal Gui
 

	; ui.osd := gui()
	; ui.osd.opt("-caption +alwaysOnTop -Border 0x4000000 +owner" ui.MainGui.Hwnd)
	; ui.osd.color := "020301"
	; ui.osd.backColor := "020301"
	; ui.osdText := ui.osd.addText("w110 r9 background020301" ,"Text Here")
	; ui.osdText.setFont("c00FFFF")
	; ui.pauseIcon := ui.osd.addText("x108 y6 w10 h10 background880000"," ")
	; ui.pauseIcon.onEvent("Click",toggleOSD)
	; WinSetTransColor("020301",ui.osd.hwnd)
	; winSetTransparent(100,ui.osd.hwnd)
	; ui.osd.show("x10 y" A_ScreenHeight/2 "w130 noActivate")
	; ui.osdHidden := false
	; toggleOSD()
	; ui.osdText.text := "`n`n`n`n`n`n`n`n`n"
	; tmpStatusText := ""



	ui.gameTabs.useTab("Destiny2") 
	ui.d2Sliding := false
	ui.d2HoldingRun := false

	ui.gameSettingsGui.setFont("s12")
	drawOutlineNamed("d2AlwaysRunOutline",ui.gameSettingsGui,10,5,470,65,cfg.themeBright1Color,cfg.themeBright2Color,2)
	ui.gameSettingsGui.addText("x20 y-5 w80 h20 c" cfg.themeFont1Color " background" cfg.themeBackgroundColor," Always Run")
	;UI.alwaysRunGb := ui.gameSettingsGui.addGroupbox("x10 y0 w270 h70","Always Run")
	
	ui.d2AlwaysRun := ui.gameSettingsGui.addPicture("x20 y20 w60 h26 section vd2AlwaysRun " 
		((cfg.d2AlwaysRunEnabled) 
			? ("Background" cfg.ThemeButtonOnColor) 
				: ("Background" cfg.themeButtonReadyColor)),
		((cfg.d2AlwaysRunEnabled) 
			? (cfg.toggleOn) 
				: (cfg.toggleOff)))


	ui.d2SprintKey				:= ui.gameSettingsGui.AddPicture("xs+67 ys+1 w90 h25 section backgroundTrans","./img/keyboard_key_up.png")
	ui.d2SprintKeyData 			:= ui.gameSettingsGui.addText("xs y+-24 w90 h20 center c" cfg.themeButtonAlertColor " backgroundTrans",strUpper(cfg.d2SprintKey))
	ui.d2SprintKeyLabel			:= ui.gameSettingsGui.addText("xs-2 y+3 w90 h20 center c" cfg.themeFont1Color " backgroundTrans","Sprint")
	ui.d2CrouchKey				:= ui.gameSettingsGui.addPicture("x+8 ys w90 h25 section backgroundTrans","./img/keyboard_key_up.png")
	ui.d2CrouchKeyData 			:= ui.gameSettingsGui.addText("xs y+-24 w90 h20 center c" cfg.themeButtonAlertColor " backgroundTrans",strUpper(cfg.d2CrouchKey))
	ui.d2CrouchKeyLabel 		:= ui.gameSettingsGui.addText("xs-2 y+3 w90 h20 center c" cfg.themeFont1Color " backgroundTrans","Crouch")
	ui.d2ToggleWalkKey			:= ui.gameSettingsGui.addPicture("x+8 ys w90 h25 section backgroundTrans","./img/keyboard_key_up.png")
	ui.d2ToggleWalkKeyData 		:= ui.gameSettingsGui.addText("xs y+-24 w90 h20 center c" cfg.themeButtonAlertColor " backgroundTrans",strUpper(cfg.d2ToggleWalkKey))
	ui.d2ToggleWalkKeyLabel		:= ui.gameSettingsGui.addText("xs-2 y+3 w90 h20 center c" cfg.themeFont1Color " backgroundTrans","Toggle Walk")
	ui.d2HoldWalkKey			:= ui.gameSettingsGui.addPicture("x+8 ys w90 h25 section backgroundTrans","./img/keyboard_key_up.png")
	ui.d2HoldWalkKeyData 		:= ui.gameSettingsGui.addText("xs y+-24 w90 h20 center c" cfg.themeButtonAlertColor " backgroundTrans",strUpper(cfg.d2HoldWalkKey))
	ui.d2HoldWalkKeyLabel		:= ui.gameSettingsGui.addText("xs-2 y+3 w90 h20 center c" cfg.themeFont1Color " backgroundTrans","Hold to Walk")
	ui.d2LaunchDIMbutton		:= ui.gameSettingsGui.addPicture("xs-370 y+10 section w140 h60","./Img/button_launchDIM.png")
	ui.d2LaunchLightGGbutton	:= ui.gameSettingsGui.addPicture("ys w140 h60","./Img/button_launchLightGG.png")

	ui.d2AlwaysRun.ToolTip := "Toggles holdToCrouch"
	ui.d2SprintKey.ToolTip 		:= "Click to Assign"
	ui.d2SprintKeyData.ToolTip  := "Click to Assign"
	ui.d2SprintKeyLabel.ToolTip	:= "Click to Assign"
	ui.d2CrouchKey.ToolTip		:= "Click to Assign"
	ui.d2CrouchKeyData.ToolTip  := "Click to Assign"
	ui.d2CrouchKeyLabel.ToolTip	:= "Click to Assign"
	ui.d2ToggleWalkKey.ToolTip		:= "Click to Assign"
	ui.d2ToggleWalkKeyData.ToolTip  := "Click to Assign"
	ui.d2ToggleWalkKeyLabel.ToolTip	:= "Click to Assign"
	ui.d2HoldWalkKey.ToolTip		:= "Click to Assign"
	ui.d2HoldWalkKeyData.ToolTip  := "Click to Assign"
	ui.d2HoldWalkKeyLabel.ToolTip	:= "Click to Assign"

	ui.d2CrouchKeyData.setFont("s13")
	ui.d2SprintKeyData.setFont("s13")
	ui.d2ToggleWalkKeyData.setFont("s13")
	ui.d2ToggleWalkKeyData.setFont("s13")
	ui.d2CrouchKeyLabel.setFont("s12")
	ui.d2SprintKeyLabel.setFont("s12")
	ui.d2ToggleWalkKeyLabel.setFont("s12")
	ui.d2HoldWalkKeyLabel.setFont("s12")
	
	ui.d2AlwaysRun.OnEvent("Click", toggleChanged)
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
	

d2LaunchDIMButtonClicked(*) {
	ui.d2LaunchDIMbutton.value := "./Img/button_launchDIM_down.png"
	setTimer () => ui.d2LaunchDIMbutton.value := "./Img/button_launchDIM.png",-400
	
	run("chrome.exe http://app.destinyitemmanager.com")
}

d2LaunchLightGGbuttonClicked(*) {
	ui.d2LaunchLightGGbutton.value := "./Img/button_launchLightGG_down.png"
	setTimer () => ui.d2LaunchLightGGbutton.value := "./Img/button_launchLightGG.png",-400
	run("chrome.exe http://www.light.gg")	
}
d2SprintKeyClicked(*) {
	DialogBox('Press "Hold to Sprint" Key`n Bound in Destiny 2',"Center")
	Sleep(100)
	d2SprintInput := InputHook("L1 T6", "{All}{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}{Tab}{Enter}","+V")
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
		ui.d2SprintKeyData.text := strUpper(cfg.d2SprintKey)
	}

	DialogBoxClose()
}

d2CrouchKeyClicked(*) {
	DialogBox('Press "Hold to Crouch" Key`nBound in Destiny 2',"Center")
	Sleep(100)
	d2CrouchInput := InputHook("L1 T6", "{All}{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}{Tab}","+V")
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
		ui.d2CrouchKeyData.text := strUpper(cfg.d2CrouchKey)
	}
	DialogBoxClose()
}

d2ToggleWalkKeyClicked(*) {
	DialogBox('Press Key to Assign to: `n"Toggle Walk"',"Center")
	Sleep(100)
	d2ToggleWalkInput := InputHook("L1 T6", "{All}{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}{Tab}","+V")
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
		ui.d2ToggleWalkKeyData.text := strUpper(cfg.d2ToggleWalkKey)
	}
	DialogBoxClose()
}

d2HoldWalkKeyClicked(*) {
	DialogBox('Press Key to Assign to: `n"Hold to Walk"',"Center")
	Sleep(100)
	d2HoldWalkInput := InputHook("L1 T6", "{All}{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}{Tab}","+V")
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
		ui.d2HoldWalkKeyData.text := strUpper(cfg.d2HoldWalkKey)
	}
	DialogBoxClose()
}

#HotIf ui.d2Running
LAlt::
{
send("{" strLower(cfg.d2SprintKey) " up}")
send("{LAlt}")
keyWait("LAlt")
send("{LAlt Up}")
send("{" strLower(cfg.d2SprintKey) " down}")
}

w up::
{
	ui.d2Running := false
	send("{" strLower(cfg.d2SprintKey) " up}{w up}")
}
#HotIf

#HotIf winActive("ahk_exe destiny2.exe") && cfg.d2AlwaysRunEnabled && !ui.d2Running && !ui.d2reloading
w::
{
	global
	if !getKeyState("LButton") && !getKeyState(cfg.d2HoldWalkKey) && !ui.d2ToggleWalkEnabled {
		ui.d2Running := true
		send("{w down}{" strLower(cfg.d2sprintKey) " down}")

	} else {
		send("{w down}")
		keyWait("w")
		send("{w}")
	}
}
#HotIf

#HotIf winActive("ahk_exe destiny.exe")  && cfg.d2AlwaysRunEnabled		

CapsLock::
{
	(ui.d2ToggleWalkEnabled := !ui.d2ToggleWalkEnabled)
	send("{CapsLock}")
	keyWait("CapsLock")
	send("{CapsLock Up}")
	SetCapsLockState("Off")
}

r::
{
	send("{r}")
	ui.d2Reloading := true
	setTimer () => ui.d2Reloading := false, -2000
}
#HotIf
	
ui.gameTabs.useTab("Fortnite")
	ui.holdToCrouchToggle := ui.gameSettingsGui.AddPicture("x15 y15 w60 h25 section vHoldToCrouch " ((cfg.holdToCrouchEnabled) 
		? ("Background" cfg.ThemeButtonOnColor) 
			: ("Background" cfg.ThemeButtonReadyColor)),((cfg.holdToCrouchEnabled) 
		? (cfg.toggleOn) 
			: (cfg.toggleOff)))

	ui.holdToCrouchToggle.OnEvent("Click", toggleChanged)
	ui.holdToCrouchToggle.ToolTip := "Toggles holdToCrouch"
	ui.leeabelToolTips := ui.gameSettingsGui.AddText("x+3 ys+3 BackgroundTrans","Hold to Crouch")
	ToggleHoldToCrouch(*)
	{
		ui.toggleHoldToCrouch.Opt((cfg.holdToCrouch := !cfg.holdToCrouchEnabled) ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor))
		ui.ToggleHoldToCrouch.Redraw()
	}


	ui.gameTabs.useTab("CS2")
	ui.cs2holdScope := ui.gameSettingsGui.addPicture("x15 y15 w60 h25 section vAholdScope " 
		((cfg.d2AlwaysRunEnabled) 
			? ("Background" cfg.ThemeButtonOnColor) 
				: ("Background" cfg.themeButtonReadyColor)),((cfg.cs2holdToScopeEnabled) 
			? (cfg.toggleOn) 
				: (cfg.toggleOff)))

	ui.cs2holdScope.OnEvent("Click", toggleChanged)
	ui.cs2holdScope.ToolTip := "Toggles holdToScope"
	ui.labelToolTips := ui.gameSettingsGui.AddText("x+3 ys-1 BackgroundTrans","Hold to Scope")	

; drawOutlineNamed("osdMessage",ui.osd,2,2,120,126,"FF55bb","BB00fF",2)
; drawOutlineNamed("gameSettingsExterior",ui.gameSettingsGui,5,0,485,170,cfg.themeBorderDarkColor,cfg.themeBorderLightColor,2)	
	
; osdMessage(msgText) {
	; global
	; tmpOsdText := SubStr(ui.osdText.text, InStr(ui.osdText.text,"`n") + 1)
	; ui.osdText.text := tmpOsdText "`n" msgText
; }

; toggleOSD(*) {
	; (ui.osdHidden := !ui.osdHidden) ? winSetTransparent(0,ui.osd) : (winSetTransparent(255,ui.osd),WinSetTransColor("020301",ui.osd))
; }

gameTabChanged(*) {
	cfg.activeGameTab := ui.gametabs.value
}	
;ui.gameTabs.useTab("")
;drawOutlineNamed("GameSettingsOutline",ui.gameSettingsGui,5,0,485,173,cfg.themeFont3Color,cfg.themeFont3Color,3)
	ui.gameTabs.useTab("World//Zero")

	ui.gameSettingsGui.setFont("s10")
	ui.w0dualPerkSwap := ui.gameSettingsGui.addPicture("x20 y15 w60 h25 section "
		((cfg.w0DualPerkSwapEnabled)
			? ("Background" cfg.ThemeButtonOnColor)
				: ("Background" cfg.themeButtonReadyColor)),((cfg.w0DualPerkSwapEnabled)
			? (cfg.toggleOn)
				: (cfg.toggleOff)))
				
	ui.w0dualPerkSwap.onEvent("Click",PerkSwapToggleChanged)
	ui.w0DualPerkSwap.toolTip := "Ctrl+Alt+LeftClick swaps effective perks between weapons (dual wielders only)"
	ui.labelW0DualPerkSwap := ui.gameSettingsGui.addText("ys w80 backgroundTrans","Perk Swap")
	
	perkSwapToggleChanged(toggleControl,*) {
		toggleControl.value := 
			(cfg.w0DualPerkSwapEnabled := !cfg.w0DualPerkSwapEnabled)
				? (toggleControl.Opt("Background" cfg.ThemeButtonOnColor),cfg.toggleOn)
				: (toggleControl.Opt("Background" cfg.ThemeButtonReadyColor),cfg.toggleOff)
		
	}	
	ui.toggleCelestialTower := ui.gameSettingsGui.AddPicture("xs  w60 h25 section vCelestialTower " (cfg.CelestialTowerEnabled ? ("Background" cfg.ThemeButtonAlertColor) : ("Background" cfg.ThemeButtonAlertColor)),((cfg.CelestialTowerEnabled) ? "./img/towerToggle_celestial.png" : "./img/towerToggle_infinite.png"))
	ui.toggleCelestialTower.OnEvent("Click", towerToggleChanged)
	ui.toggleCelestialTower.ToolTip := "Toggles between Infinite and Celestial Towers."
	ui.labelCelestialTower:= ui.gameSettingsGui.AddText("x+3 ys+3 backgroundTrans","Tower Settings")	
	
	
	ui.towerIntervalSlider := ui.gameSettingsGui.addSlider("xs y+10 w160 h20 Range1-50  Left background" ui.transparentColor " ToolTipTop",cfg.towerInterval)
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
	ui.toggleSilentIdle := ui.gameSettingsGui.AddPicture("xs w60 h25 section vSilentIdle " (cfg.SilentIdleEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),((cfg.SilentIdleEnabled) ? (cfg.toggleOn) : (cfg.toggleOff)))
	ui.toggleSilentIdle.OnEvent("Click", toggleChanged)
	ui.toggleSilentIdle.ToolTip := "Minimizes Roblox Windows While Anti-Idling"
	ui.labelSilentIdle:= ui.gameSettingsGui.AddText("x+3 ys+3 backgroundTrans","Silent AntiIdle")
	