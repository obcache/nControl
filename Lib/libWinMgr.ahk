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

	if (ui.AfkDocked) && (Hwnd = ui.AfkGui.Hwnd) {
		WinGetPos(&AfkGuiX,&AfkGuiY,,,ui.AfkGui)
		;MsgBox(AfkGuiX "`n" AfkGuiY)
		ui.titleBarButtonGui.Move(AfkGuiX+154,AfkGuiY-3)
	} else {
		if (Hwnd = ui.MainGui.Hwnd)
		{
			ui.MainGui.GetPos(&winX,&winY,,)
			ui.AfkGui.Move(winX+45,winY+35,,)
			ui.titleBarButtonGui.Move(winX+2,WinY-5)
		} 	
	}
}

WM_LBUTTONDOWN_callback(*) {
	WM_LBUTTONDOWN(0,0,0,ui.MainGui.Hwnd)
}

;###########MOUSE EVENTS##############
WM_LBUTTONDOWN(wParam, lParam, msg, Hwnd) {
	;ShowMouseClick()
	if (Hwnd = ui.MainGui.hwnd) || (Hwnd = ui.titleBarButtonGui.Hwnd)
		PostMessage("0xA1",2)
}

wmAfkLButtonDown(wParam, lParam, msg, hwnd) {
	if !(ui.AfkAnchoredToGui)
		PostMessage(0xA1, 2)
}

WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
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


