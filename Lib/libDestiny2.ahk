#Requires AutoHotKey v2.0+
#SingleInstance


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
	ui.gameSettingsGui.show()

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
	
	w::
	{
		global
		if !(ui.pauseAlwaysRun) {
			statusText .= "`ninput: w-down"
			alwaysRunStatus(statusText)
			send("{w down}")
			statusText .= "`ninjecting: " ui.runKey
			alwaysRunStatus(statusText)
			send("{" ui.runKey "}")
			keywait("w")
			statusText .= "`ninput: w-up"
			alwaysRunStatus(statusText)
			send("{w up}")
		} else {
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
