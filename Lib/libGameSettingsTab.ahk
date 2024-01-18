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
loop cfg.gameList.length {
	if fileExist("./lib/lib" cfg.gameList[A_Index])
		runWait("./lib/lib" cfg.gameList[A_Index])
}

	ui.gameSettingsGui := Gui()
	ui.gameSettingsGui.Name := "nControl Game Settings"
	ui.gameSettingsGui.BackColor := cfg.themeBackgroundColor
	ui.gameSettingsGui.Color := ui.TransparentColor
	ui.gameSettingsGui.MarginX := 5
	ui.gameSettingsGui.Opt("-Caption -Border +AlwaysOnTop +ToolWindow +Owner" ui.MainGui.Hwnd)
	ui.gameSettingsGui.SetFont("s14 c" cfg.ThemeFont1Color,"Calibri")
	WinSetTransparent(0,ui.gameSettingsGui)
	ui.gameTabs := ui.gameSettingsGui.addTab3("x5 y5 w480 h165 bottom buttons 0x8000 choose" cfg.activeGameTab " background" cfg.themeBackgroundColor,cfg.gameList)
	ui.gameTabs.choose(cfg.gameList[cfg.activeGameTab])
	ui.gameTabs.setFont("s12")
	ui.gameTabs.onEvent("Change",gameTabChanged)
	ui.MainGui.GetPos(&winX,&winY,,)
	ui.gameSettingsGui.show("x" winx+35 " y" winy+35 " w" 400 " h" 170)

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


	ui.gameTabs.useTab("Roblox")
	ui.gameSettingsGui.setFont("s10")
	ui.worldZeroBox := ui.gameSettingsGui.AddGroupBox("x5 y+-2 section 	w200 h80","World//Zero")
	ui.w0dualPerkSwap := ui.gameSettingsGui.addPicture("x+5 y+-40 section w60 h25 section "
		((cfg.w0DualPerkSwapEnabled)
			? ("Background" cfg.ThemeButtonOnColor)
				: ("Background" cfg.themeButtonReadyColor)),((cfg.w0DualPerkSwapEnabled)
			? (cfg.toggleOn)
				: (cfg.toggleOff)))
				
	ui.w0dualPerkSwap.onEvent("Click",toggleChanged)
	ui.w0DualPerkSwap.toolTip := "Ctrl+Alt+LeftClick swaps effective perks between weapons (dual wielders only)"
	ui.w0DualPerkSwapLabel := ui.gameSettingsGui.addText("ys w80 backgroundTrans","Perk Swap")

	ui.gameTabs.useTab("Destiny2") 

	ui.d2Sliding := false
	ui.d2HoldingRun := false

	ui.gameSettingsGui.setFont("s12")
	UI.alwaysRunGb := ui.gameSettingsGui.addGroupbox("x10 y0 w210 h70","Always Run")
	ui.d2AlwaysRun := ui.gameSettingsGui.addPicture("x20 y20 w60 h26 section vd2AlwaysRun " 
		((cfg.d2AlwaysRunEnabled) 
			? ("Background" cfg.ThemeButtonOnColor) 
				: ("Background" cfg.themeButtonReadyColor)),
		((cfg.d2AlwaysRunEnabled) 
			? (cfg.toggleOn) 
				: (cfg.toggleOff)))


	ui.d2SprintKey				:= ui.gameSettingsGui.AddPicture("xs+67 ys+1 w60 h25 section backgroundTrans","./img/keyboard_key_up.png")
	ui.d2SprintKeyData 			:= ui.gameSettingsGui.addText("xs y+-24 w60 h20 center c" cfg.themeFont3Color " backgroundTrans",strUpper(cfg.d2SprintKey))
	ui.d2SprintKeyLabel			:= ui.gameSettingsGui.addText("xs-2 y+3 w60 h20 center c" cfg.themeFont1Color " backgroundTrans","Sprint")
	ui.d2CrouchKey				:= ui.gameSettingsGui.addPicture("x+8 ys w60 h25 section backgroundTrans","./img/keyboard_key_up.png")
	ui.d2CrouchKeyData 			:= ui.gameSettingsGui.addText("xs y+-24 w60 h20 center c" cfg.themeFont3Color " backgroundTrans",strUpper(cfg.d2CrouchKey))
	ui.d2CrouchKeyLabel 		:= ui.gameSettingsGui.addText("xs-2 y+3 w60 h20 center c" cfg.themeFont1Color " backgroundTrans","Crouch")

	ui.d2AlwaysRun.ToolTip := "Toggles holdToCrouch"
	ui.d2SprintKey.ToolTip 		:= "Click to Assign"
	ui.d2SprintKeyData.ToolTip  := "Click to Assign"
	ui.d2SprintKeyLabel.ToolTip	:= "Click to Assign"
	ui.d2CrouchKey.ToolTip		:= "Click to Assign"
	ui.d2CrouchKeyData.ToolTip  := "Click to Assign"
	ui.d2CrouchKeyLabel.ToolTip	:= "Click to Assign"

	ui.d2CrouchKeyData.setFont("s13")
	ui.d2SprintKeyData.setFont("s13")
	ui.d2CrouchKeyLabel.setFont("s12")
	ui.d2SprintKeyLabel.setFont("s12")
	
	ui.d2AlwaysRun.OnEvent("Click", toggleChanged)
	ui.d2CrouchKey.onEvent("click",d2CrouchKeyClicked)
	ui.d2SprintKey.onEvent("click",d2SprintKeyClicked)
	ui.d2CrouchKeyData.onEvent("click",d2CrouchKeyClicked)
	ui.d2SprintKeyData.onEvent("click",d2SprintKeyClicked)


d2SprintKeyClicked(*) {
	DialogBox('Press Key or Button Assigned for:`n"Hold to Sprint"`nin Destiny2')
	Sleep(750)
	d2SprintInput := InputHook("L1", "{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}")
	d2SprintInput.start()
	d2SprintInput.wait()
	cfg.d2SprintKey := d2SprintInput.input
	ui.d2SprintKeyData.text := strUpper(cfg.d2SprintKey)

	if (cfg.d2SprintKey == 0) {
		DialogBoxClose()
		DialogBox('Timed Out Waiting for:`nDestiny2 Sprint Key Bind`nPlease Try Again')
	}
	DialogBoxClose()
}

d2CrouchKeyClicked(*) {
	DialogBox('Press Key or Button Assigned for:`n"Hold to Crouch"`nin Destiny2')
	Sleep(750)
	d2CrouchInput := InputHook("L1", "{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{NumLock}{PrintScreen}{Pause}")
	d2CrouchInput.start()
	d2CrouchInput.wait()
	cfg.d2CrouchKey := d2CrouchInput.input
	ui.d2CrouchKeyData.text := strUpper(cfg.d2CrouchKey)

	if (cfg.d2CrouchKey == 0) {
		DialogBoxClose()
		DialogBox('Timed Out Waiting for:`nDestiny2 Crouch Key Bind`nPlease Try Again')
	}
	DialogBoxClose()	
}

#HotIf (WinGetProcessName("ahk_id " winGetID("A")) == "destiny2.exe") && (cfg.d2AlwaysRunEnabled)

	w::
	{
		global
		send("{w down}")
		send("{z Down}")
	}
		
	
	w up::
	{
		global
		send("{z}")
		send("{w up}")
		
	}
	
	r::
	{
		send("{r}")
		ui.reloading := true
		setTimer () => ui.reloading := false, -2000
	}
	#HotIf		
	
	; enter::
	; {
		; global
		; (ui.inGameChat := !ui.inGameChat)
		; send("{Enter}") 
	; }
	
	
	
	; ~l up::
	; {
		; global
		; ui.pauseAlwaysRun := false
		; if getKeyState("w") {
			; send("{w up}")
			; sleep(200)
			; send("{w down}")
		; }
	; }
	
	; r::
	; {
		; global
		; send("{r}")
		; ui.pauseAlwaysRun := true
		; SetTimer () => ui.pauseAlwaysRun := false,-2000
	; }
	
	; ~w down::
	; {
		; global
		; if !(ui.pauseAlwaysRun) && !(ui.d2HoldingRun)
		; {
			; ui.d2HoldingRun := true
			; send("{w down}")
			; send("{LShift Down}")
			; osdMessage("input: w-down")
			; osdMessage("injecting: " cfg.d2SprintHoldKey " Down")
		; }
			
	; }
	
	; ~w up::
	; {
		; global
		; if (ui.d2HoldingRun) {
			; osdMessage("input: w-up")
			; osdMessage("injecting: " cfg.d2SprintHoldKey)
			; send("{LShift Up}")
			; send("{w Up}")
			; ui.d2HoldingRun := false
			; SetCapsLockState("Off")
		; } else {
			; send("{w wup}")
		; }
	; }



		
	; }
	
	; ~LShift Up::
	; {
		; global
		; if (ui.d2Sliding) {
			; send("{LShift Up}")
			; send("{" cfg.d2SprintHoldKey " Down}")
			; ui.d2HoldingRun := true
			; ui.d2Sliding := false
		; } else {
			; send("{LShift Up}")
		; }
	; }

	
	ui.gameTabs.useTab("Fortnite")
	ui.holdToCrouchToggle := ui.gameSettingsGui.AddPicture("x5 y5 w60 h25 section vHoldToCrouch " ((cfg.holdToCrouchEnabled) 
		? ("Background" cfg.ThemeButtonOnColor) 
			: ("Background" cfg.ThemeButtonReadyColor)),((cfg.holdToCrouchEnabled) 
		? (cfg.toggleOn) 
			: (cfg.toggleOff)))

	ui.holdToCrouchToggle.OnEvent("Click", toggleChanged)
	ui.holdToCrouchToggle.ToolTip := "Toggles holdToCrouch"
	ui.leeabelToolTips := ui.gameSettingsGui.AddText("x+3 ys+3 BackgroundTrans","Hold to Crouch")


	ui.gameTabs.useTab("CounterStrike2")
	ui.cs2holdScope := ui.gameSettingsGui.addPicture("x5 y5 w60 h25 section vAholdScope " 
		((cfg.d2AlwaysRunEnabled) 
			? ("Background" cfg.ThemeButtonOnColor) 
				: ("Background" cfg.themeButtonReadyColor)),((cfg.cs2holdToScopeEnabled) 
			? (cfg.toggleOn) 
				: (cfg.toggleOff)))

	ui.cs2holdScope.OnEvent("Click", toggleChanged)
	ui.cs2holdScope.ToolTip := "Toggles holdToScope"
	ui.labelToolTips := ui.gameSettingsGui.AddText("x+3 ys-1 BackgroundTrans","Hold to Scope")	

; drawOutlineNamed("osdMessage",ui.osd,2,2,120,126,"FF55bb","BB00fF",2)
drawOutlineNamed("gameSettingsExterior",ui.gameSettingsGui,5,0,485,170,cfg.themeBorderDarkColor,cfg.themeBorderLightColor,2)	
	
osdMessage(msgText) {
	global
	tmpOsdText := SubStr(ui.osdText.text, InStr(ui.osdText.text,"`n") + 1)
	ui.osdText.text := tmpOsdText "`n" msgText
}

toggleOSD(*) {
	(ui.osdHidden := !ui.osdHidden) ? winSetTransparent(0,ui.osd) : (winSetTransparent(255,ui.osd),WinSetTransColor("020301",ui.osd))
}

gameTabChanged(*) {
	cfg.activeGameTab := ui.gametabs.value
}