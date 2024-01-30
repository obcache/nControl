#Requires AutoHotKey v2.0+
#SingleInstance
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}



^+/::
{
	mx := 0
	coordMode("mouse","screen")
	while (mx < a_screenwidth) {
		if (getKeyState("Escape"))
			Return
		mouseMove(mx,-10,2)
		mx += 1
		sleep(1)
	}
}

!+F::
{
	keyWait("F")
	if getKeyState("D") {
		run('C:\Users\cashm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\5) Utilities\Discord.lnk')
		launchSuccessful := false
		timeoutCount := 0
		while !launchSuccessful and timeoutCount < 60 {
			timeoutCount += 1
			sleep(1000)
			if winExist("ahk_exe discord.exe")
				launchSuccessful := true
		}
		if (launchSuccessful) {
			winActivate("ahk_exe discord.exe")
		} else {
			notifyOSD("Problems launching Discord",2000)
			Return
		}
	}	
	
	run('E:\Music\foobar2000\foobar2000.exe')
	launchSuccessful := false
	timeoutCount := 0
	while !launchSuccessful and timeoutCount < 60 {
		timeoutCount += 1
		sleep(1000)
		if winExist("ahk_exe foobar2000.exe") {
			launchSuccessful := true
		}
	}
	if (launchSuccessful) {
		winActivate("ahk_exe foobar2000.exe")

	} else {
		notifyOSD("Problems launching Foobar2000",2000)
		Return
	}
	if winExist("ahk_exe discord.exe") && winExist("ahk_exe foobar2000.exe")
		dockApps()
		
}		


!^Backspace::
{
ui.MainGui.Move(30,A_ScreenHeight-ui.TaskbarHeight-GuiH)
ui.MainGui.GetPos(,,,&GuiH)
ToggleGuiCollapse()
}



^Enter::
{
		togglePip()
	
	}

!^m::
{
	getClick(&clickX,&clickY,&activeWindow)
}


!^F1::
{
	Global
	RobloxLauncher()
}	

;AFK Hotkeys
!^F::
{
	autoFire()
}

!^c::
{
	ToggleAutoClicker()
}

!^a::
{
	ToggleAFK()
}

!^t::
{
	ToggleTower()
}

!^w::
{
	ReturnToWorld()
}
	
!^d::
{
	ToggleAfkDock()
}

;GameSettings HotKeys	
^+d::
{
	global
	toggleOSD()
}



