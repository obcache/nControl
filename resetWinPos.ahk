#requires autoHotKey v2.0+
#singleInstance

monitorGetWorkArea(monitorGetPrimary(),&L,&T,&R,&B)

winMove(L,T,a_screenWidth,a_screenHeight,"ahk_exe destiny2.exe")
winActivate("ahk_exe destiny2.exe")
winSetAlwaysOnTop("ahk_exe destiny2.exe")