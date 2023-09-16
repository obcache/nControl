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

;###########WINDOW EVENTS##############
WM_ACTIVATE(wparam) {
   OnMessage(0x200, "WM_MOUSEMOVE", !!wparam)
}

WM_WINDOWPOSCHANGED(wParam, lParam, msg, Hwnd)
{
	Global		

	try 
	{
		if (Hwnd = ui.MainGui.Hwnd)
		{
			ui.MainGui.GetPos(&winX,&winY,,)
<<<<<<< HEAD
			ui.AfkGui.Move(winX+10,winY+35,,)
			ui.titleBarButtonGui.Opt("Owner" ui.MainGui.Hwnd)
			ui.titleBarButtonGui.Move(winX+425,WinY-7) 
		} 
		if (ui.AfkDocked) && (Hwnd = ui.AfkGui.Hwnd) {
				WinGetPos(&AfkGuiX,&AfkGuiY,,,ui.AfkGui)
				;MsgBox(AfkGuiX "`n" AfkGuiY)
				ui.titleBarButtonGui.Opt("Owner" ui.AfkGui.Hwnd)
				ui.titleBarButtonGui.Move(AfkGuiX+155,AfkGuiY-5)
		}
	}
}
=======
			ui.AfkGui.Move(winX+10,winY+35,,)	
		 }
	}
}

>>>>>>> 169606a70753258dc2f103a2ec48e6d3aac9edc4
; OnMessage(WM_ACTIVATEAPP := 0x1C, OnActivate)

; OnActivate(wparam, lParam, msg, Hwnd) {
    
	; if (lParam != ui.MainGui.Hwnd) && (lParam != ui.AfkGui.Hwnd) && (lParam != ui.LastWindowHwnd) {
		; ui.LastWindowHwnd := lParam
		; MsgBox(lParam)
	; }
; }

;###########MOUSE EVENTS##############
WM_LBUTTONDOWN(wParam, lParam, msg, Hwnd)
{
	;ShowMouseClick()
	if (Hwnd = ui.MainGui.hwnd)
		PostMessage("0xA1",2)
}

; ShowMouseClick()
; {
	; Global
	; ui.MouseClickStatus.Value := "Left Click"
	; SetTimer () => ClearMouseClick(), -1500
; }

; ClearMouseClick()
; {
	; ui.MouseClickStatus.Value := ""
; }

WM_MOUSEMOVE(wParam, lParam, msg, Hwnd)
{
    static PrevHwnd := 0
    if (Hwnd != PrevHwnd)
    {
        Text := ""
		ToolTip()
        CurrControl := GuiCtrlFromHwnd(Hwnd)
		if cfg.ToolTipsEnabled && CurrControl.HasProp("ToolTip")
        {
            Text := CurrControl.ToolTip
            SetTimer () => ToolTip(Text), -400
			
            SetTimer () => ToolTip(), -5500
        }
        PrevHwnd := Hwnd
    }
}

StartPIP(&ui)
{
	ui.HwndWin1.Text
;	MonitorGetWorkArea(cfg.GameDisplayNum, &cfg.GameDisplayL, &cfg.GameDisplayT, &cfg.GameDisplayR, &cfg.GameDisplayB)
;	cfg.GameDisplayL, cfg.GameDisplayT, cfg.GameDisplayR, cfg.GameDisplayB, 
	WindowID := ui.HwndWin1.Text
	if (WinGetTransparent(WindowID) < 150)
	{
		WinMove(0,0,A_ScreenWidth,A_ScreenHeight,WindowID)
		WinSetAlwaysOnTop(0)
		WinSetStyle("+0xC00000")
		WinSetTransparent(255)
		WindowID := ui.HwndWin2.Text
		WinMove(10,A_ScreenHeight-650,800,600,WindowID)
		WinSetAlwaysOnTop(1)
		WinSetStyle("-0xC00000")
		WinSetTransparent(125)
	} else {
		WindowID := ui.HwndWin2.Text
		WinMove(0,0,A_ScreenWidth,A_ScreenHeight,WindowID)
		WinSetAlwaysOnTop(0)
		WinSetStyle("+0xC00000")
		WinSetTransparent(255)
		WindowID := ui.HwndWin1.Text
		WinMove(10,A_ScreenHeight-650,800,600,WindowID)
		WinSetAlwaysOnTop(1)
		WinSetStyle("-0xC00000")
		WinSetTransparent(125)
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


