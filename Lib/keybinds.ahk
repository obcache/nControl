#Requires AutoHotKey v2.0+
#SingleInstance


cfg 		:= object()
cfg.file	:= "./ncontrol.ini"

ui 			:= object()
ui.bindGui 	:= gui()

ui.bindGui.opt("-caption -border +toolWindow +0x4000000")
ui.backColor := "353535"
ui.buttonAddBind := ui.bindGui.addPic("x2 y2 section w50 h25","./img/button_add.png")
ui.buttonChangeBind := ui.bindGui.addPic("ys w80 h25","./img/button_change.png")
ui.buttonDelete := ui.bindGui.addPic("ys w90 h25","./img/button_delete.png")

ui.mapTable := ui.bindGui.addListView("xs y+5 w500 h400",["idx","keybind","action","actionType","description","misc"])
ui.bindGui.show("w520 h420")

OnMessage(0x0201, WM_LBUTTONDOWN)


	
	
	
	
;###########MOUSE EVENTS##############
WM_LBUTTONDOWN(wParam, lParam, msg, Hwnd) {
	;ShowMouseClick()
	if (Hwnd = ui.bindGui.Hwnd)
		PostMessage("0xA1",2)
}