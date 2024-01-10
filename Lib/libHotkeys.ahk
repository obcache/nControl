#Requires AutoHotKey v2.0+
#SingleInstance
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}

!^Backspace::
{
ui.MainGui.Move(30,A_ScreenHeight-ui.TaskbarHeight-GuiH)
ui.MainGui.GetPos(,,,&GuiH)
ToggleGuiCollapse()
}

+^Delete::
{
resetDefaultThemes()
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

; HotIfWinActive("ahk_exe FortniteClient-Win64-Shipping.exe")
; hotkey("{LCtrl}", crouchDown)

; hotkey("{LCtrl Up}", crouchUp)
; crouchDown(*) {
	; if (cfg.holdToCrouchEnabled)
	; {
		; send("{LShift}")
		; keyWait("{LShift}")
		; Return
	; }
; }
; crouchUp(*) {
	; if (cfg.holdToCrouchEnabled)
	; {
		; send("{LShift}")
		; Return
	; }
; }
; HotIfWinActive