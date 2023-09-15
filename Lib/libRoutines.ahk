#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}


RobloxLauncher()
{
	BlockInput(true)
	BlockInput("SendAndMouse")
	SetTitleMatchMode(3)
	CoordMode("Mouse","Client")
	debugLog("Executing Roblox")
	Win1Exec := "explorer.exe shell:appsFolder\ROBLOXCORPORATION.ROBLOX_55nm5eh3cm0pr!App"
	Win2Exec := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Roblox\Roblox Player.lnk"
	Run(Win1Exec)
	Run(Win2Exec)
	debugLog("Pausing 10 seconds for Roblox to start")
	Sleep(10000)

	debugLog("Getting Roblox App ID")
	CurrWin := "ahk_exe ApplicationFrameHost.exe"
	ClickX := 140
	ClickY := 615
	WinActivate(CurrWin)
	Sleep(1000)
	debugLog("Maximizing Roblox App")

	WinMaximize(CurrWin)
	Sleep(2000)
	SendEvent("{LWin Down}{Right}{LWin Up}")
	Sleep(3000)
	debugLog("Clicking Start on Roblox App")
	MouseMove(ClickX,ClickY,5)
	Sleep(1000)
	MouseMove(ClickX+5,ClickY,5)
	Sleep(1000)
	MouseClick("Left",ClickX,ClickY)
	Sleep(1000)
	MouseClick("Left",ClickX,ClickY)

	CurrWin := "ahk_exe RobloxPlayerBeta.exe"
	ClickX := 140
	ClickY := 585
	WinActivate(CurrWin)
	Sleep(1000)
	debugLog("Maximizing Roblox Client")

	WinMaximize(CurrWin)
	Sleep(2000)
	SendEvent("{LWin Down}{Left}{LWin Up}")
	Sleep(3000)
	debugLog("Clicking Start on World//Zero for Roblox Client")
	MouseMove(ClickX,ClickY,5)
	Sleep(1000)
	MouseMove(ClickX+5,ClickY,5)
	Sleep(1000)
	MouseClick("Left",ClickX,ClickY)
	Sleep(1000)
	MouseClick("Left",ClickX,ClickY)
	Sleep(10000)

	debugLog("Clicking Play in World//Zero on Roblox App")
	CurrWin := "ahk_exe ApplicationFrameHost.exe"
	WinActivate(CurrWin)
	WinGetPos(&WinX,&WinY,&WinW,&WinH,CurrWin)
	SendEvent("{CLick " WinW/2 " " WinH-85 " Left}")
	Sleep(1000)
	SendEvent("{CLick " WinW/2 " " WinH-85 " Left}")
	Sleep(6000)

	debugLog("Clicking Play in World//Zero on Roblox Client")
	CurrWin := "ahk_exe RobloxPlayerBeta.exe"
	WinActivate(CurrWin)
	WinGetPos(&WinX,&WinY,&WinW,&WinH,CurrWin)
	SendEvent("{CLick " WinW/2 " " WinH-115 " Left}")
	Sleep(1000)
	SendEvent("{CLick " WinW/2 " " WinH-115 " Left}")
	BlockInput(false)
	BlockInput("Off")
	RefreshWinHwnd()
}
