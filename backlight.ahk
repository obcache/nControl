#requires AutoHotKey v2.0+
#singleInstance
#warn all,off

persistent()
installMouseHook()
installKeybdHook()
keyHistory(10)
setWorkingDir(A_ScriptDir)

ui		:= object()
ui.transparent		:= "010203"
ui.lightGuiWidth := 500

ui.lightGui := gui()
ui.lightGui.opt("-caption")
ui.lightGui.backColor := "010203"
ui.lightGui.addPicture("w500 h100 backgroundTrans","./img/lightBurst.png")
winSetTransColor(ui.transparent,ui.lightGui)
ui.lightGui.show("x" (a_screenWidth/2)-(ui.lightGuiWidth/2) " y0 autosize noActivate")