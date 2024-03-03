#Requires AutoHotkey >=2.0
#SingleInstance

winGetPos(&x,&y,&w,&h,"ahk_pid 13612")
;winMove(1,1,,,"ahk_pid 13612")
winSetTransparent(255,"ahk_pid 13612")
msgBox("x: " x "`ny: " y "`nw: " w "`nh: " h)