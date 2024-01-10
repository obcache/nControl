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
	ui.gameSettingsGui.BackColor := cfg.ThemeBackgroundColor
	ui.gameSettingsGui.Color := ui.TransparentColor
	ui.gameSettingsGui.MarginX := 5
	ui.gameSettingsGui.Opt("-Caption -Border +AlwaysOnTop +ToolWindow +0x4000000 +Owner" ui.MainGui.Hwnd)
	ui.gameSettingsGui.SetFont("s14 c" cfg.ThemeFont1Color,"Calibri")
	WinSetTransparent(0,ui.gameSettingsGui)
	ui.gameTabs := ui.gameSettingsGui.addTab3("x5 y5 w480 h165 bottom buttons",cfg.gameList)
	ui.gameTabs.setFont("s12")
	ui.MainGui.GetPos(&winX,&winY,,)
	ui.gameSettingsGui.show("x" winx+35 " y" winy+35 " w" 400 " h" 170)
		; Loop cfg.gameList.length {
		; try {
			; runWait("./lib/lib" cfg.gameList[a_index])
			; ui.gameTabs.value([cfg.gameList[a_index]])
			; ui.gameTabs.useTab(cfg.gameList[a_index])
		; }
	; }
} ;End Game Profile List Modal Gui
 

	ui.osd := gui()
	ui.osd.opt("-caption +alwaysOnTop -Border 0x4000000 +owner" ui.MainGui.Hwnd)
	ui.osd.color := "020301"
	ui.osd.backColor := "020301"
	ui.osdText := ui.osd.addText("w110 r9 background020301" ,"Text Here")
	ui.osdText.setFont("c00FFFF")
	ui.pauseIcon := ui.osd.addText("x108 y6 w10 h10 background880000"," ")
	ui.pauseIcon := ui.osd.addText("x108 y6 w10 h10 background880000"," ")
	WinSetTransColor("020301",ui.osd.hwnd)
	winSetTransparent(100,ui.osd.hwnd)
	ui.osd.show("x10 y" A_ScreenHeight/2 "w130 noActivate")
	ui.osdHidden := false
	toggleOSD()
	drawOutlineNamed("alwaysRunStatus",ui.osd,2,2,120,126,"FF55bb","BB00fF",2)
	drawOutlineNamed("gameSettingsExterior",ui.gameSettingsGui,5,0,485,170,cfg.themeBorderDarkColor,cfg.themeBorderLightColor,2)	
	osdMsg(msgText) {
		
	}

	statusText := "`n`n`n`n`n`n`n`n`n"
	tmpStatusText := ""
	


	ui.gameSettingsGui.show()
	ui.gameTabs.useTab("Destiny2") 
	
	ui.alwaysRunToggle := ui.gameSettingsGui.addPicture("x5 y5 w60 h25 section vAlwaysRun " 
		((cfg.alwaysRunEnabled) 
			? ("Background" cfg.ThemeButtonOnColor) 
				: ("Background" cfg.themeButtonReadyColor)),((cfg.alwaysRunEnabled) 
			? (cfg.toggleOn) 
				: (cfg.toggleOff)))

	ui.alwaysRunToggle.OnEvent("Click", toggleChanged)
	ui.alwaysRunToggle.ToolTip := "Toggles holdToCrouch"
	ui.labelToolTips := ui.gameSettingsGui.AddText("x+3 ys-1 BackgroundTrans","Always Run")	

alwaysRunStatus(key) {
		global
		tmpStatusText := statusText
		statusText := SubStr(tmpStatusText, InStr(tmpStatusText,"`n") + 1)
		ui.osdText.text := key
	}
	
	#HotIf (WinGetProcessName("ahk_id " winGetID("A")) == "destiny2.exe") && (cfg.alwaysRunEnabled)
	setCapsLockState("AlwaysOff")
	enter::
	{
		(ui.pauseAlwaysRun := !ui.pauseAlwaysRun) ? pauseAlwaysRun() : unpauseAlwaysRun()
		send("{Enter}") 
		
		pauseAlwaysRun() {
			ui.pauseIcon.opt("-hidden")
		}
		unpauseAlwaysRun() {
			ui.pauseIcon.opt("hidden") 
		}
	}
	
	r::
	{
		ui.pauseAlwaysRun := true
		SetTimer () => ui.pauseAlwaysRun := false,-2000
	}
	
	w::
	{
		d2holdRun()
	}
	d2holdRun() {
		global
		if !(ui.pauseAlwaysRun) {
			alwaysRunStatus("`ninput: w-down")
			send("{w down}")
			alwaysRunStatus("`ninjecting: " ui.runKey " down")
			send("{" ui.runKey " down}")
			keywait("w")
			alwaysRunStatus("`ninput: w-up")
			send("{" UI.runKey " up}")
			alwaysRunStatus("`ninjecting: " ui.runKey)
			send("{w up}")
		} else {
			alwaysRunStatus("alwaysRun is paused. using default key behavior")
			send("{w}")
		}
	}

	LShift::
	{
		global
		if !(ui.pauseAlwaysRun)
		{
			;notifyOSD("received: crouch`ninjecting: wait 300ms + " ui.runkey)
			send("{LShift Down}")
			statusText .= "`ninput: shift-down"
			alwaysRunStatus(statusText)
			keyWait("LShift")
			statusText .= "`ninput: shift-up"
			alwaysRunStatus(statusText)
			send("{LShift Up}")
			sleep(300)
			send("{" ui.runKey "}")
			statusText .= "`ninjecting: " ui.runKey
			alwaysRunStatus(statusText)
		} else {
			send("{LShift}")
		}
		
	}
	#HotIf
	
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
		((cfg.alwaysRunEnabled) 
			? ("Background" cfg.ThemeButtonOnColor) 
				: ("Background" cfg.themeButtonReadyColor)),((cfg.holdToScopeEnabled) 
			? (cfg.toggleOn) 
				: (cfg.toggleOff)))

	ui.cs2holdScope.OnEvent("Click", toggleChanged)
	ui.cs2holdScope.ToolTip := "Toggles holdToScope"
	ui.labelToolTips := ui.gameSettingsGui.AddText("x+3 ys-1 BackgroundTrans","Hold to Scope")	
	
^+d::
{
	global
	toggleOSD()
}

toggleOSD() {
	(ui.osdHidden := !ui.osdHidden) ? winSetTransparent(0,ui.osd) : (winSetTransparent(255,ui.osd),WinSetTransColor("020301",ui.osd))
}