A_FileVersion := "1.1.1.2"
A_AppName := "cacheApp_updater"
;@Ahk2Exe-Let FileVersion=%A_PriorLine~U)^(.+"){1}(.+)".*$~$2% 

;@Ahk2Exe-SetName cacheApp
;@Ahk2Exe-SetVersion %U_FileVersion%
;@Ahk2Exe-SetFileVersion %U_FileVersion%

#Requires AutoHotkey v2.0
#SingleInstance
#Warn All, Off

InstallMouseHook()
InstallKeybdHook()
KeyHistory(10)
SetWorkingDir(A_ScriptDir)

cfg				:= Object()
ui 				:= Object()

runWait("cmd /C start /b /wait ping -n 1 8.8.8.8 > " a_scriptDir "/.tmp",,"Hide")
if !inStr(fileRead(a_scriptDir "/.tmp"),"100% loss") {
	checkForUpdates()
} else {
	setTimer () => pbNotify("Network Down. Can't update now.",2000),-100
	sleep(2000)
	exitApp
}
try
	fileDelete("/.tmp")
	
checkForUpdates() {

	msgBoxAnswer := MsgBox("nControl has been deprecated and replaced with cacheApp.`nWould you like to migrate now?",,"YN")

	if (msgBoxAnswer == "Yes")
	{ 	
		appDir := a_myDocuments "\cacheApp\"
		dirCreate(appDir)
		dirCreate(appDir "lib")
		dirCreate(appDir "versions")
		dirCreate(appDir "redist")
		dirCreate(appDir "img")
		dirCreate(appDir "img2")				


		whr := ComObject("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", "https://raw.githubusercontent.com/obcache/cacheApp/main/cacheApp_currentBuild.dat", true)
		whr.Send()
		whr.WaitForResponse()
		latestVersion := whr.ResponseText
		fileAppend(latestVersion,appDir "cacheApp_latestBuild.dat")
		fileAppend(latestVersion,appDir "cacheApp_currentBuild.dat")
		pbNotify("Upgrading to cacheApp version: " latestVersion)	
		runWait("cmd /C start /b /wait curl.exe https://raw.githubusercontent.com/obcache/cacheApp/main/Bin/cacheApp_" latestVersion ".exe -o " appDir  "versions/cacheApp_" latestVersion ".exe")
		
		sleep(3000)
			
		if fileExist(appDir "versions/cacheApp_" latestVersion ".exe") {
			fileCopy("./nControl.ini",appDir "cacheApp.ini",1)
			fileCopy("./nControl.themes",appDir "cacheApp.themes",1)
			fileCopy("./afkData.csv",appDir "afkData.csv",1)
			
			run(appDir "versions/cacheApp_" latestVersion ".exe")
			
		} else 
			pbNotify("Problem downloading the app. `nCheck your antivirus to ensure that it is not being blocked.")
	} else {
		pbNotify("Skipping migration and exiting.")
	} 
}


pbNotify(NotifyMsg,Duration := 10,YN := "")
{
	Transparent := 250
	ui.notifyGui			:= Gui()
	ui.notifyGui.Title 		:= "Notify"

	ui.notifyGui.Opt("+AlwaysOnTop -Caption +ToolWindow")  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	ui.notifyGui.BackColor := "353535" ; Can be any RGB color (it will be made transparent below).
	ui.notifyGui.SetFont("s16")  ; Set a large font size (32-point).
	ui.notifyGui.AddText("c00FFFF center BackgroundTrans",NotifyMsg)  ; XX & YY serve to 00auto-size the window.
	ui.notifyGui.AddText("xs hidden")
	
	if (YN) {
		ui.notifyGui.AddText("xs hidden")
		ui.notifyGui.SetFont("s10")
		ui.notifyYesButton := ui.notifyGui.AddButton("ys section w60 h25","Yes")
		ui.notifyYesButton.OnEvent("Click",notifyConfirm)
		ui.notifyNoButton := ui.notifyGui.AddButton("xs w60 h25","No")
		ui.notifyNoButton.OnEvent("Click",notifyCancel)
	}
	
	ui.notifyGui.Show("AutoSize")
	winGetPos(&x,&y,&w,&h,ui.notifyGui.hwnd)
	drawOutline(ui.notifyGui,0,0,w,h,"202020","808080",3)
	drawOutline(ui.notifyGui,5,5,w-10,h-10,"BBBBBB","DDDDDD",2)
	if !(YN) {
		Sleep(5000)
		FadeOSD()
	} else {
		SetTimer(pbWaitOSD,-10000)
	}
	
	notifyConfirm(*) {
		return 1
	}
	notifyCancel(*) {
		return 0
	}
}
pbWaitOSD() {
	ui.notifyGui.destroy()
	pbNotify("Timed out waiting for response.`nPlease try your action again",-1000)
}
	
drawOutline(guiName, X, Y, W, H, Color1 := "Black", Color2 := "Black", Thickness := 1) {	
	
	guiName.AddProgress("x" X " y" Y " w" W " h" Thickness " Background" Color1) 
	guiName.AddProgress("x" X " y" Y " w" Thickness " h" H " Background" Color1) 
	guiName.AddProgress("x" X " y" Y + H - Thickness " w" W " h" Thickness " Background" Color2) 
	guiName.AddProgress("x" X + W - Thickness " y" Y " w" Thickness " h" H " Background" Color2) 	
}	
	
	
fadeOSD() {
	ui.transparent := 250
	While ui.Transparent > 10 { 	
		WinSetTransparent(ui.Transparent,ui.notifyGui)
		ui.Transparent -= 3
		Sleep(1)
	}
	ui.Transparent := ""
	ui.notifyGui.Destroy()
}
