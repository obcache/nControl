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
ui.MainGui.GetPos(,,,&GuiH)
ui.MainGui.Move(30,A_ScreenHeight-ui.TaskbarHeight-GuiH)
ToggleGuiCollapse()
}

+^Delete::
{
resetDefaultThemes()
}

!^
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

