#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}

GetTaskbarHeight()
{
	MonitorGet(MonitorGetPrimary(),,,,&TaskbarBottom)
	MonitorGetWorkArea(MonitorGetPrimary(),,,,&TaskbarTop)
		
	TaskbarHeight := TaskbarBottom - TaskbarTop
	Return TaskbarHeight
}

WM_WINDOWPOSCHANGED(wParam, lParam, msg, Hwnd)
{
	try {
		switch hwnd {
			case ui.mainGui.hwnd:
				if (!ui.afkDocked) {
					winGetPos(&winX,&winY,,,ui.mainGui)
					ui.AfkGui.Move(winX+40,winY+50,,)
					ui.titleBarButtonGui.Move(winX,WinY-5)
					ui.gameSettingsGui.move(winx+35,winy+35)
				}
			case ui.titleBarButtonGui.hwnd:
				if (!ui.afkDocked) {
					winGetPos(&winX,&winY,,,ui.titleBarButtonGui)
					ui.gameSettingsGui.move(winx+35,winy+40)
					ui.afkGui.move(winX+40,winY+55,,)
					ui.mainGui.move(winX,winY+5,,)
				}
			case ui.dividerGui.hwnd:
				if (Hwnd == ui.dividerGui.hwnd) {
					MonitorGetWorkArea(cfg.nControlMonitor, &Left, &Top, &Right, &Bottom)
					winGetPos(&divX,&divY,&divW,&divH,ui.dividerGui)
					ui.dividerGui.move(Left,,Right-Left,)	
					winMove(,,,divY,"ahk exe " ui.app1filename.text)
					winMove(,divY,,,"ahk_exe " ui.app2filename.text)
				}
			case ui.afkGui.hwnd:
				if (ui.afkdocked || !ui.afkAnchoredToGui) {
					winGetPos(&AfkGuiX,&AfkGuiY,,,ui.afkGui)
					ui.titleBarButtonGui.move(afkGuiX+185,afkGuiY)
					ui.mainGui.move(afkGuiX-40,afkGuiX-50)
				}
		} 
			
	}
}

WM_LBUTTONDOWN_callback(*) {
	WM_LBUTTONDOWN(0,0,0,ui.MainGui.Hwnd)
}

;###########MOUSE EVENTS##############
WM_LBUTTONDOWN(wParam, lParam, msg, Hwnd) {
	;ShowMouseClick()
	if !(hwnd == ui.afkGui.hwnd && ui.afkAnchoredToGui) {
		
		
		if !ui.topDockEnabled && ((Hwnd = ui.MainGui.hwnd) || (Hwnd = ui.titleBarButtonGui.Hwnd) || (hwnd == ui.dividerGui.hwnd) || (hwnd == ui.afkGui.hwnd))
			PostMessage("0xA1",2)

		if (hwnd == ui.dividerGui.hwnd)
		{
		keyWait("LButton")
		MonitorGetWorkArea(cfg.nControlMonitor, &Left, &Top, &Right, &Bottom)
		coordMode("mouse","screen")
		MouseGetPos(&mX,&mY,&currWin)
		winMove(,mY,,Bottom-mY+8,"ahk_exe " ui.app2filename.text)
		winMove(,Top,,mY-Top,"ahk_exe " ui.app1filename.text)
		winActivate(ui.dividerGui)
		}
	}
}

; WM_LBUTTONUP(wParam, lParam, msg, Hwnd) {

; }	

wmAfkLButtonDown(wParam, lParam, msg, hwnd) {
	if !(ui.AfkAnchoredToGui)
		PostMessage(0xA1, 2)
}

WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
	static prevHwnd := 0
    if (Hwnd != PrevHwnd) {
        text := ""
		toolTip()
        currControl := GuiCtrlFromHwnd(Hwnd)
		if cfg.toolTipsEnabled && currControl.hasProp("ToolTip") {
            text := currControl.ToolTip
            setTimer () => toolTip(text), -400
            setTimer () => toolTip(), -5500
        }
        prevHwnd := Hwnd
    }
}
	; (hwnd != prevHwnd) 
		; ? (Hnwd == ui.stopGamingButton.hwnd 
			; ? stopGamingButtonHover() 
			; : stopGamingButtonNormal()) 
		; : doNothing()
	
	; (hwnd != prevHwnd)
		; ? (Hnwd == ui.startGamingButton.hwnd 
			; ? startGamingButtonHover() 
			; : startGamingButtonNormal()) 
		; : doNothing()
		
; }
; stopGamingButtonHover() {
	; ui.stopGamingButton.opt("background" cfg.themeButtonAlertColor)
; }
; stopGamingButtonNormal() {
	; ui.stopGamingButton.opt("background" cfg.themeButtonReadyColor)
; }
; startGamingButtonHover() {
	; ui.startGamingButton.opt("background" cfg.themeButtonAlertColor)
; }
; startGamingButtonNormal() {
	; ui.startGamingButton.opt("background" cfg.themeButtonReadyColor)
; }
; doNothing() {
; }



togglePIP()
{
	if (!WinExist("ahk_id " ui.Win2Hwnd) 
		|| !WinExist("ahk_id " ui.Win1Hwnd)) {
		debugLog("PiP: Can't find 2 Game Windows.")
		try {
		stopPip()
		}
		Return
	}

	if (WinGetTransparent("ahk_id " ui.Win1Hwnd)) {
		if (WinGetTransparent("ahk_id " ui.Win1Hwnd) < 150) {
			WinMove(0,0,A_ScreenWidth,A_ScreenHeight,"ahk_id " ui.Win1Hwnd)
			WinSetAlwaysOnTop(0,"ahk_id " ui.Win1Hwnd)
			WinSetStyle("+0xC00000","ahk_id " ui.Win1Hwnd)
			WinSetTransparent(255,"ahk_id " ui.Win1Hwnd)

			WinMove(10,A_ScreenHeight-650,800,600,"ahk_id " ui.Win2Hwnd)
			WinSetAlwaysOnTop(1,"ahk_id " ui.Win2Hwnd)
			WinSetStyle("-0xC00000","ahk_id " ui.Win2Hwnd)
			WinSetTransparent(125,"ahk_id " ui.Win2Hwnd)
		} else {
			WinMove(0,0,A_ScreenWidth,A_ScreenHeight,"ahk_id " ui.Win2Hwnd)
			WinSetAlwaysOnTop(0,"ahk_id " ui.Win2Hwnd)
			WinSetStyle("+0xC00000","ahk_id " ui.Win2Hwnd)
			WinSetTransparent(255,"ahk_id " ui.Win2Hwnd)

			WinMove(10,A_ScreenHeight-650,800,600,WindowswID)
			WinSetAlwaysOnTop(1,"ahk_id " ui.Win1Hwnd)
			WinSetStyle("-0xC00000","ahk_id " ui.Win1Hwnd)
			WinSetTransparent(125,"ahk_id " ui.Win1Hwnd)
		}
	} else {
			WinMove(0,0,A_ScreenWidth,A_ScreenHeight,"ahk_id " ui.Win1Hwnd)
			WinSetAlwaysOnTop(0,"ahk_id " ui.Win1Hwnd)
			WinSetStyle("+0xC00000","ahk_id " ui.Win1Hwnd)
			WinSetTransparent(255,"ahk_id " ui.Win1Hwnd)

			WinMove(10,A_ScreenHeight-650,800,600,"ahk_id " ui.Win2Hwnd)
			WinSetAlwaysOnTop(1,"ahk_id " ui.Win2Hwnd)
			WinSetStyle("-0xC00000","ahk_id " ui.Win2Hwnd)
			WinSetTransparent(125,"ahk_id " ui.Win2Hwnd)
	}

		WinSetAlwaysOnTop(0,"ahk_id " ui.Win2Hwnd)
			WinSetStyle("+0xC00000","ahk_id " ui.Win2Hwnd)
			WinSetTransparent(255,"ahk_id " ui.Win2Hwnd)
			
	StopPip() {
		WinMove(0,0,(A_ScreenWidth/2),(A_ScreenHeight-getTaskbarHeight()),"ahk_id " ui.win1Hwnd)
		WinMove(A_ScreenWidth/2,0,(A_ScreenWidth/2),(A_ScreenHeight-getTaskbarHeight()),"ahk_id " ui.win2Hwnd)
		WinSetAlwaysOnTop(0,"ahk_id " ui.win1Hwnd)
		WinSetAlwaysOnTop(0,"ahk_id " ui.win2Hwnd)
		WinSetTransparent(255,"ahk_id " ui.win1Hwnd)
		WinSetTransparent(255,"ahk_id " ui.win2Hwnd)

	}
}
	

ChangeWindowFocus()
{
	CoordMode("Mouse","Screen")
	if WinExist("A") == WinGetID("ahk_exe RobloxPlayerBeta.exe")
	{
		CoordMode("Mouse","Screen")
		MouseClick("Right",A_ScreenWidth-50,A_ScreenHeight-100)
		WinActivate("ahk_exe ApplicationFrameHost.exe")

	} else {
		CoordMode("Mouse","Screen")
		MouseClick("Left",(A_ScreenWidth/2)-50,A_ScreenHeight-100)
		WinActivate("ahk_exe RobloxPlayerBeta.exe")
	}
}


; Gui +LastFound 
; hWnd := WinExist()
; DllCall( "RegisterShellHookWindow", UInt,Hwnd )
; MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
; OnMessage( MsgNum, "ShellMessage" )
; Return

; ShellMessage( wParam,lParam )
; {
 ; WinGetTitle, title, ahk_id %lParam%
 ; If (wParam=4) { ;HSHELL_WINDOWACTIVATED
  ; ToolTip WinActivated`n%Title%
  ; sleep 1000
  ; ToolTip
 ; }
; }