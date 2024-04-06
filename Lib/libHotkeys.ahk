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



; hotIf(SLCapsOn)
	; hotKey("w down",SLBHop)
; hotIf()

SLCapsOn(*) {
	if getKeyState("CapsLock","T") && winActive("ahk_exe shatterline.exe")
		return 1
	else
		return 0
}

SLBHop(*) {
	CoordMode("Mouse","Client")
	send("{w down}")
	sleep(400)
	send("{LShift}")
	Sleep(400)
	MouseMove(-100,0,30,"R")
	MouseMove(100,0,30,"R")
	send("{Space}")
	sleep(300)
	while getKeyState("W") {
		send("{Space}")
		sleep(50)
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


!^Backspace:: {
	ui.MainGui.Move(30,A_ScreenHeight-ui.TaskbarHeight-GuiH)
	winGetPos(,,,&GuiH,,ui.mainGui)
	ToggleGuiCollapse()
}

+Esc:: {
	resetWindowPosition()
}



^+[:: {
	static currOutputDeviceNum := 1
	ui.audioDevices := array()
	
	; loop
	; {
		; try {
			; ui.audioDevices.push(SoundGetName(, devIndex := A_Index))
		; } catch
			; break
	; }
	
	; loop ui.audioDevices.length {
		; audioListStr .= ui.audioDevices[a_index] "`n"
	; }
	;msgBox(audioListStr)

audioOutputDevices := ["S2MASTER (Traktor Kontrol S2 MK3 WDM Audio)","Speakers (Logitech G432 Gaming Headset)","Realtek HD Audio 2nd output (Realtek(R) Audio)","Speakers (Yeti Classic)","Headphones (Tango TRX)"]

audioDeviceName := regRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render\{e4301939-df7b-41b3-81d5-a8930d8b94aa}\Properties","{b3f8fa53-0004-438e-9003-51a46e139bfc},6")


Run("./Redist/nircmd.exe setdefaultsounddevice " audioOutputDevices[currOutputDeviceNum])
debugLog("setting audio device: " audioOutputDevices[currOutputDeviceNum])


if currOutputDeviceNum == 5
	currOutputDeviceNum := 1
else
	currOutputDeviceNum += 1

}


^+]:: {
	
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
	autoFire(0)
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



