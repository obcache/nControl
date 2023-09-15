#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}

; class Toggle extends  {
	; __New(enabled,pictureValue,backgroundColor,buttonName,position,options)
		; {
			; this.enabled := enabled
			; this.pictureValue := pictureValue
			; this.backgroundColor := backgroundColor
			; this.buttonName := buttonName
			; this.position := position
			; this.options := options
		; }

	; __Push()
	; {
		; this.enabled := !this.enabled
		; this.buttonName.Value := t
	; }
; }

InitTrayMenu(&ThisTray)
{
	ThisTray := A_TrayMenu
	ThisTray.Delete
	ThisTray.Add
	ThisTray.Add("Show Window", ShowGui)
	ThisTray.Add("Hide Window", HideGui)
	ThisTray.Add("Reset Window Position",ResetWindowPosition)
	ThisTray.Add("Toggle Dock", DockApps)
	ThisTray.Add()
	ThisTray.Add("Toggle Log Window",ToggleDebug)
	ThisTray.Add()
	ThisTray.Add("Exit App",KillMe)
	ThisTray.Default := "Show Window"
	Try
		persistLog("Tray Initialized")
}

PreAutoExec(InstallDir,ConfigFileName)
{
	Global

	if (A_IsCompiled)
	{
		; if !(FileExist("./nControl.ini"))
		; {
			; SelectedFolder := DirSelect(,1,"No Installation Found. Select a folder or cancel for default.")
			; if (SelectedFolder)
				; InstallDir := SelectedFolder
		; }
		if StrCompare(A_ScriptDir,InstallDir)
		{
			persistLog("Running standalone executable, attempting to auto-install")
			if !(DirExist(InstallDir))
			{
				persistLog("Attempting to create install folder")
				try
				{
					DirCreate(InstallDir)
					SetWorkingDir(InstallDir)
				} catch {
					persistLog("Couldn't create install location")
					MsgBox("Cannot Create Folder at the Install Location. Suspect permissions issue with the desired install location")
					ExitApp
				}
				persistLog("Successfully created install location at " InstallDir)
			}
			persistLog("Copying executable to install location")
			try{
				FileCopy(A_ScriptFullPath, InstallDir "/" A_ScriptName, true)
			}

			; if !(FileExist(InstallDir "/nControl.ini"))
			; {
				; if !(MsgBox("Previous install detected. Attempt to preserve your existing settings?",, "YesNo"))
				; {
					; FileInstall("./nControl.ini",InstallDir "./nControl.ini",1)
					
					; FileInstall("./AfkData.csv",InstallDir "/AfkData.csv",true)
				; } else {
					; cfg.ThemeFont1Color := "00FFFF"
					; NotifyOSD("Using Existing Configuration Files`nIf you encounter issues, please retry and choose [Replace Existing Config]",3000)
					; if !(FileExist("/AfkData.csv"))
						; FileInstall("./AfkData.csv",InstallDir "/AfkData.csv",true)
				; }
			; }
			if !(DirExist(InstallDir "\lib"))
			{
				DirCreate(InstallDir "\lib")
			}			
			if !(DirExist(InstallDir "\Img"))
			{
				DirCreate(InstallDir "\Img")
			}
			persistLog("Created Img folder")
	
			FileInstall("./AfkData.csv",InstallDir "/AfkData.csv",true)			
			FileInstall("./nControl.ini",InstallDir "./nControl.ini",1)	
			FileInstall("./Img/button_ready.png",InstallDir "/Img/button_ready.png",1)
			FileInstall("./Img/button_on.png",InstallDir "/Img/button_on.png",1)
			FileInstall("./Img/pin_down.png",InstallDir "/Img/pin_down.png",1)
			FileInstall("./Img/pin_up.png",InstallDir "/Img/pin_up.png",1)
			FileInstall("./Img/up_up.png",InstallDir "/Img/up_up.png",1)
			FileInstall("./Img/up_down.png",InstallDir "/Img/up_down.png",1)
			FileInstall("./Img/down_up.png",InstallDir "/Img/down_up.png",1)
			FileInstall("./Img/down_down.png",InstallDir "/Img/down_down.png",1)
			FileInstall("./Img/close_up.png",InstallDir "/Img/close_up.png",1)
			FileInstall("./Img/button_plus.png",InstallDir "/Img/button_plus.png",1)
			FileInstall("./Img/button_power.png",InstallDir "/Img/button_power.png",1)
			FileInstall("./Img/button_minus.png",InstallDir "/Img/button_minus.png",1)
			FileInstall("./Img/button_x.png",InstallDir "/Img/button_x.png",1)
			FileInstall("./Img/button_x2.png",InstallDir "/Img/button_x2.png",1)
			FileInstall("./Img/button_change.png",InstallDir "/Img/button_change.png",1)
			FileInstall("./Img/button_select.png",InstallDir "/Img/button_select.png",1)
			FileInstall("./Img/button_set.png",InstallDir "/Img/button_set.png",1)
			FileInstall("./Img/button_add.png",InstallDir "/Img/button_add.png",1)
			FileInstall("./Img/button_remove.png",InstallDir "/Img/button_remove.png",1)
			FileInstall("./Img/cc_close.png",InstallDir "/Img/cc_close.png",true)
			FileInstall("./Img/down3.png",InstallDir "/Img/down3.png",true)
			FileInstall("./Img/button_stop.png",InstallDir "/Img/button_stop.png",true)
			FileInstall("./Img/button_start.png",InstallDir "/Img/button_start.png",true)
			FileInstall("./Img/button_started.png",InstallDir "/Img/button_started.png",true)
			FileInstall("./Img/button_repeat.png",InstallDir "/Img/button_repeat.png",true)
			FileInstall("./Img/button_repeating.png",InstallDir "/Img/button_repeating.png",true)
			FileInstall("./Img/attack_icon.png",InstallDir "/Img/attack_icon.png",true)
			FileInstall("./Img/sleep_icon.png",InstallDir "/Img/sleep_icon.png",true)
			FileInstall("./Img/arrow_left.png",InstallDir "/Img/arrow_left.png",true)
			FileInstall("./Img/arrow_right.png",InstallDir "/Img/arrow_right.png",true)
			FileInstall("./Img/button_popout.png",InstallDir "/Img/button_popout.png",true)
			FileInstall("./Img/button_execute.png",InstallDir "/Img/button_execute.png",true)
			FileInstall("./Img/status_stopped.png",InstallDir "/Img/status_stopped.png",true)
			FileInstall("./Img/status_running.png",InstallDir "/Img/status_running.png",true)
			FileInstall("./Img/timer_off.png",InstallDir "/Img/timer_off.png",true)
			FileInstall("./Img/timer_antiIdle.png",InstallDir "/Img/timer_antiIdle.png",true)
			FileInstall("./Img/timer_infiniteTower.png",InstallDir "/Img/timer_infiniteTower.png",true)
			FileInstall("./Img/handlebar_vertical.png",InstallDir "/Img/handlebar_vertical.png",true)
			FileInstall("./Img/button_quit.png",InstallDir "/Img/button_quit.png",true)
			FileInstall("./Img/button_minimize.png",InstallDir "/Img/button_minimize.png",true)
			FileInstall("./Img/button_tower.png",InstallDir "/Img/button_tower.png",true)
			FileInstall("./Img/button_afk.png",InstallDir "/Img/button_afk.png",true)
			FileInstall("./Img/button_antiIdle.png",InstallDir "/Img/button_antiIdle.png",true)
			FileInstall("./Img/button_dockleft_ready.png",InstallDir "/Img/button_dockleft_ready.png",true)
			FileInstall("./Img/button_dockleft_on.png",InstallDir "/Img/button_dockleft_on.png",true)
			FileInstall("./Img/button_dockleft.png",InstallDir "/Img/button_dockleft.png",true)
			FileInstall("./Img/button_dockright_ready.png",InstallDir "/Img/button_dockright_ready.png",true)
			FileInstall("./Img/button_dockright_on.png",InstallDir "/Img/button_dockright_on.png",true)
			FileInstall("./Img/button_tower_ready.png",InstallDir "/Img/button_tower_ready.png",true)
			FileInstall("./Img/button_tower_on.png",InstallDir "/Img/button_tower_on.png",true)
			FileInstall("./Img/button_dockright.png",InstallDir "/Img/button_dockright.png",true)
			FileInstall("./Img/button_afk_ready.png",InstallDir "/Img/button_afk_ready.png",true)
			FileInstall("./Img/button_afk_on.png",InstallDir "/Img/button_afk_on.png",true)
			FileInstall("./Img/button_antiIdle_ready.png",InstallDir "/Img/button_antiIdle_ready.png",true)
			FileInstall("./Img/button_antiIdle_on.png",InstallDir "/Img/button_antiIdle_on.png",true)
			FileInstall("./Img/button_plus_ready.png",InstallDir "/Img/button_plus_ready.png",true)
			FileInstall("./Img/button_plus_on.png",InstallDir "/Img/button_plus_on.png",true)
			FileInstall("./Img/button_minus_ready.png",InstallDir "/Img/button_minus_ready.png",true)
			FileInstall("./Img/button_minus_on.png",InstallDir "/Img/button_minus_on.png",true)
			FileInstall("./Img/button_OpsDock.png",InstallDir "/Img/button_OpsDock.png",true)
			FileInstall("./Img/color_swatches.png",InstallDir "/Img/color_swatches.png",1)
			FileInstall("./Img/toggle_left.png",InstallDir "/Img/toggle_left.png",1)
			FileInstall("./Img/toggle_right.png",InstallDir "/Img/toggle_right.png",1)
			FileInstall("./Img/button_viewlog_down.png",InstallDir "/Img/button_viewlog_down.png",1)
			FileInstall("./Img/button_viewlog_up.png",InstallDir "/Img/button_viewlog_up.png",1)
			FileInstall("./Img/button_popout_ready.png",InstallDir "/Img/button_popout_ready.png",1)
			FileInstall("./Img/button_popout_on.png",InstallDir "/Img/button_popout_on.png",1)
			FileInstall("./Img/button_refresh.png",InstallDir "/Img/button_refresh.png",1)
			FileInstall("./Img/button_hide.png",InstallDir "/Img/button_hide.png",1)
			FileInstall("./Img/button_autoFire1_on.png",InstallDir "/Img/button_autoFire1_on.png",1)
			FileInstall("./Img/button_autoFire1_ready.png",InstallDir "/Img/button_autoFire1_ready.png",1)
			FileInstall("./Img/button_autoFire2_on.png",InstallDir "/Img/button_autoFire2_on.png",1)
			FileInstall("./Img/button_autoFire2_ready.png",InstallDir "/Img/button_autoFire2_ready.png",1)
			FileInstall("./Img/button_swapHwnd.png",InstallDir "/Img/button_swapHwnd.png",1)
			FileInstall("./Img/button_autoFire_ready.png",InstallDir "/Img/button_autoFire_ready.png",1)
			FileInstall("./Img/button_autoFire1_on.png",InstallDir "/Img/button_autoFire1_on.png",1)
			FileInstall("./Img/button_autoFire2_on.png",InstallDir "/Img/button_autoFire2_on.png",1)
			FileInstall("./Img/button_autoClicker_ready.png",InstallDir "/Img/button_autoClicker_ready.png",1)
			FileInstall("./Img/button_swapHwnd_enabled.png",InstallDir "/Img/button_swapHwnd_enabled.png",1)
			FileInstall("./Img/button_swapHwnd_disabled.png",InstallDir "/Img/button_swapHwnd_disabled.png",1)
			FileInstall("./Img/button_autoClicker_on.png",InstallDir "/Img/button_autoClicker_on.png",1)
			FileInstall("./lib/ColorChooser.exe",InstallDir "./lib/ColorChooser.exe",1)




			
			persistLog("Copied Assets to: " InstallDir)
			
			if !(DirExist(InstallDir "\Redist"))
			{
				DirCreate(InstallDir "\Redist")
				persistLog("Created Redist Folder")
			}
			
		Run(InstallDir "\" A_ScriptName)
		ExitApp
		
		}
	}
}

persistLog(LogMsg)
{
	Global
	if !(DirExist(InstallDir "\Logs"))
	{
		DirCreate(InstallDir "\Logs")
		FileAppend(A_YYYY A_MM A_DD " [" A_Hour ":" A_Min ":" A_Sec "] Created Logs Folder`n",InstallDir "/Logs/persist.log")
	}

	FileAppend(A_YYYY A_MM A_DD " [" A_Hour ":" A_Min ":" A_Sec "] " LogMsg "`n",InstallDir "/Logs/persist.log")
}

CfgLoad(&cfg, &ui)
{
	cfg.GameWindowsList 		:= array()

	cfg.MainGui			:= IniRead(cfg.file,"System","MainGui","MainGui")
	ui.GuiH					:= 220  	;430 for Console Mode
	ui.ClockTimerStarted 	:= false
	ui.AutoFire1Enabled		:= false
	ui.AutoFire2Enabled		:= false
	ui.AutoClickerEnabled 	:= false
	ui.LastWindowHwnd		:= 0
	ui.ColorChanged := false
	
	cfg.InstallDir			:= IniRead(cfg.file,"System","InstallDir", A_MyDocuments "\nControl")
	cfg.MainScriptName		:= IniRead(cfg.file,"System","MainScriptName", "nControl")
	cfg.MainScriptName		:= IniRead(cfg.file,"System","ScriptName","nControl")
	cfg.LogPanelEnabled		:= IniRead(cfg.file,"System","LogPanelEnabled",true)
	
	cfg.debugEnabled		:= IniRead(cfg.file,"System","DebugEnabled",true)
	cfg.ToolTipsEnabled 	:= IniRead(cfg.file,"System","ToolTipsEnabled",true)
	cfg.AlwaysOnTopEnabled	:= IniRead(cfg.file,"Interface","AlwaysOnTopEnabled",true)
	cfg.AnimationsEnabled	:= IniRead(cfg.file,"Interface","AnimationsEnabled",true)
	cfg.ColorPickerEnabled 	:= IniRead(cfg.file,"Interface","ColorPickerEnabled",true)
	cfg.GuiX 				:= IniRead(cfg.file,"Interface","GuiX",200)
	cfg.GuiY 				:= IniRead(cfg.file,"Interface","GuiY",200)
	MonitorGet(MonitorGetPrimary(),&L,&T,&R,&B)
	if (cfg.GuiX > L-600)
		cfg.GuiX := 200
	if (cfg.GuiY > B-500)
		cfg.GuiY := 200
	cfg.AfkX				:= IniRead(cfg.file,"Interface","AfkX",cfg.GuiX+10)
	cfg.AfkY				:= IniRead(cfg.file,"Interface","AfkY",cfg.GuiY+35)
	cfg.AfkSnapEnabled		:= IniRead(cfg.file,"Interface","AfkSnapEnabled",false)
	cfg.GuiSnapEnabled		:= IniRead(cfg.file,"Interface","GuiSnapEnabled",true)

	cfg.AutoDetectGame			:= IniRead(cfg.file,"Game","AutoDetectGame",true)
	cfg.GameList				:= StrSplit(IniRead(cfg.file,"Game","GameList","Roblox,Rocket League"),",")
	cfg.Game					:= IniRead(cfg.file,"Game","Game","2")
	cfg.HwndSwapEnabled			:= IniRead(cfg.file,"Game","HwndSwapEnabled",false)

	cfg.Game1StatusEnabled 		:= IniRead(cfg.file,"Game","Game1Enabled",true)
	cfg.Game2StatusEnabled 		:= IniRead(cfg.file,"Game","Game2Enabled",true)
	cfg.AfkDataFile				:= IniRead(cfg.file,"AFK","AfkDataFile","./AfkData.csv")
	cfg.Profile					:= IniRead(cfg.file,"AFK","Profile","1")
	cfg.Win1Class				:= IniRead(cfg.file,"AFK","Win1Class","Summoner1")
	cfg.Win2Class				:= IniRead(cfg.file,"AFK","Win2Class","Summoner2")
	cfg.SilentIdleEnabled := IniRead(cfg.file,"AFK","SilentIdleEnabled",true)
	cfg.AutoClickerSpeed := IniRead(cfg.file,"AFK","AutoClickerSpeed",50)
	
	cfg.nControlMonitor 	:= IniRead(cfg.file,"nControl","nControlMonitor","1")
	cfg.app1filename		:= IniRead(cfg.file,"nControl","app1filename","")
	cfg.app1path			:= IniRead(cfg.file,"nControl","app1path","")
	cfg.app2filename		:= IniRead(cfg.file,"nControl","app2filename","")
	cfg.app2path			:= IniRead(cfg.file,"nControl","app2path","")
	
	cfg.DockHeight 			:= IniRead(cfg.file,"nControl","DockHeight","240")
	cfg.DockMarginSize 		:= IniRead(cfg.file,"nControl","DockMarginSize","8")
	cfg.UndockedX 			:= IniRead(cfg.file,"nControl","UndockedX","150")
	cfg.UndockedY 			:= IniRead(cfg.file,"nControl","UndockedY","150")
	cfg.UndockedW 			:= IniRead(cfg.file,"nControl","UndockedW","1600")
	cfg.UndockedH 			:= IniRead(cfg.file,"nControl","UndockedH","1000")

	cfg.MicName				:= IniRead(cfg.file,"audio","MicName","Yeti")
	cfg.SpeakerName			:= IniRead(cfg.file,"audio","SpeakerName","S2MASTER")
	cfg.HeadsetName			:= IniRead(cfg.file,"audio","HeadsetName","G432")
	cfg.MicVolume			:= IniRead(cfg.file,"audio","MicVolume","80")
	cfg.SpeakerVolume	 	:= IniRead(cfg.file,"audio","SpeakerVolume","50")
	cfg.HeadsetVolume		:= IniRead(cfg.file,"audio","HeadsetVolume","80")
	cfg.Mode				:= IniRead(cfg.file,"audio","Mode","1")

	cfg.Theme							:= IniRead(cfg.file,"Interface","Theme","Modern Class")
	cfg.ThemeList						:= StrSplit(IniRead(cfg.file,"Interface","ThemeList","Modern Class,Cold Steel,Militarized,Custom"),",")
	cfg.ThemeBrightBorderBottomColor	:= IniRead(cfg.file,cfg.Theme,"ThemeBrightBorderBottomColor","C0C0C0")
	cfg.ThemeBrightBorderTopColor		:= IniRead(cfg.file,cfg.Theme,"ThemeBrightBorderTopColor","FFFFFF")
	cfg.Theme3dBorderLightColor			:= IniRead(cfg.file,cfg.Theme,"Theme3dBorderLightColor","888888")
	cfg.Theme3dBorderShadowColor		:= IniRead(cfg.file,cfg.Theme,"Theme3dBorderShadowColor","333333")
	cfg.ThemeBackgroundColor			:= IniRead(cfg.file,cfg.Theme,"ThemeBackgroundColor","414141")
	cfg.ThemeFont1Color					:= IniRead(cfg.file,cfg.Theme,"ThemeFont1Color","1FFFF")
	cfg.ThemeFont2Color					:= IniRead(cfg.file,cfg.Theme,"ThemeFont2Color","FBD58E")
	cfg.ThemeConsoleBgColor				:= IniRead(cfg.file,cfg.Theme,"ThemeConsoleBgColor","204040")
	cfg.ThemeConsoleBg2Color			:= IniRead(cfg.file,cfg.Theme,"ThemeConsoleBg2Color","804001")
	cfg.ThemeEditboxColor				:= IniRead(cfg.file,cfg.Theme,"ThemeEditboxColor","292929")
	cfg.ThemeDisabledColor				:= IniRead(cfg.file,cfg.Theme,"ThemeDisabledColor","212121")
	cfg.ThemeButtonDisabledColor		:= IniRead(cfg.file,cfg.Theme,"ThemeButtonDisabledColor","3C3C3C")
	cfg.ThemeButtonOnColor				:= IniRead(cfg.file,cfg.Theme,"ThemeButtonOnColor","FF01FF")
	cfg.ThemeButtonReadyColor			:= IniRead(cfg.file,cfg.Theme,"ThemeButtonReadyColor","1FFFF")
}


WriteConfig()
{
	Global
	tmpGameList := ""

	IniWrite(cfg.AutoDetectGame,cfg.file,"Game","AutoDetectGame")
	IniWrite(cfg.Game,cfg.file,"Game","Game")
	IniWrite(cfg.MainScriptName,cfg.file,"System","ScriptName")
	IniWrite(cfg.InstallDir,cfg.file,"System","InstallDir")
	IniWrite(cfg.MainGui,cfg.file,"System","MainGui")
	Loop cfg.GameList.Length
	{
		if !(tmpGameList)
			tmpGameList := cfg.GameList[A_Index]
		else
			tmpGameList := tmpGameList "," cfg.GameList[A_Index]
	}
	IniWrite(tmpGameList,cfg.file,"Game","GameList")
	IniWrite(cfg.Game,cfg.file,"Game","Game")
	IniWrite(cfg.Game1StatusEnabled,cfg.file,"Game","Game1StatusEnabled")
	IniWrite(cfg.Game2StatusEnabled,cfg.file,"Game","Game2StatusEnabled")
	IniWrite(cfg.HwndSwapEnabled,cfg.file,"Game","HwndSwapEnabled")
	IniWrite(cfg.nControlMonitor,cfg.file,"nControl","nControlMonitor")
	IniWrite(cfg.DockHeight,cfg.file,"nControl","DockHeight")
	IniWrite(cfg.DockMarginSize,cfg.file,"nControl","DockMarginSize")

	IniWrite(cfg.UndockedX,cfg.file,"nControl","UndockedX")
	IniWrite(cfg.UndockedY,cfg.file,"nControl","UndockedY")
	IniWrite(cfg.UndockedW,cfg.file,"nControl","UndockedW")
	IniWrite(cfg.UndockedH,cfg.file,"nControl","UndockedH")

	IniWrite(ui.app2path.text,cfg.file,"nControl","app2path")
	IniWrite(ui.app2filename.text,cfg.file,"nControl","app2filename")
	IniWrite(ui.app1path.text,cfg.file,"nControl","app1path")
	IniWrite(ui.app1filename.text,cfg.file,"nControl","app1filename")

	IniWrite(cfg.MicName,cfg.file,"Audio","Mic")
	IniWrite(cfg.SpeakerName,cfg.file,"Audio","Speaker")
	IniWrite(cfg.HeadsetName,cfg.file,"Audio","Headset")
	IniWrite(cfg.MicVolume,cfg.file,"Audio","MicVolume")
	IniWrite(cfg.SpeakerVolume,cfg.file,"Audio","SpeakerVolume")
	IniWrite(cfg.HeadsetVolume,cfg.file,"Audio","HeadsetVolume")
	IniWrite(cfg.Mode,cfg.file,"Audio","Mode")

	IniWrite(ui.ThemeDDL.Text,cfg.file,"Interface","Theme")
	
	if (ui.ThemeDDL.Text == "Custom") {
		IniWrite(cfg.Theme3dBorderLightColor,cfg.file,"Custom","Theme3dBorderLightColor")
		IniWrite(cfg.Theme3dBorderShadowColor,cfg.file,"Custom","Theme3dBorderShadowColor")
		IniWrite(cfg.ThemeBrightBorderTopColor,cfg.file,"Custom","ThemeBrightBorderTopColor")
		IniWrite(cfg.ThemeBrightBorderBottomColor,cfg.file,"Custom","ThemeBrightBorderBottomColor")
		IniWrite(cfg.ThemeBackgroundColor,cfg.file,"Custom","ThemeBackgroundColor")
		IniWrite(cfg.ThemeFont1Color,cfg.file,"Custom","ThemeFont1Color")
		IniWrite(cfg.ThemeFont2Color,cfg.file,"Custom","ThemeFont2Color")
		IniWrite(cfg.ThemeConsoleBgColor,cfg.file,"Custom","ThemeConsoleBgColor")
		IniWrite(cfg.ThemeConsoleBg2Color,cfg.file,"Custom","ThemeConsoleBg2Color")
		IniWrite(cfg.ThemeEditboxColor,cfg.file,"Custom","ThemeEditboxColor")
		IniWrite(cfg.ThemeDisabledColor,cfg.file,"Custom","ThemeDisabledColor")
		IniWrite(cfg.ThemeButtonOnColor,cfg.file,"Custom","ThemeButtonOnColor")
		IniWrite(cfg.ThemeButtonReadyColor,cfg.file,"Custom","ThemeButtonReadyColor")
		IniWrite(cfg.ThemeButtonDisabledColor,cfg.file,"Custom","ThemeButtonDisabledColor")
	}
	
	ui.MainGui.GetPos(&GuiX,&GuiY,,)
	ui.AfkGui.GetPos(&AfkX,&AfkY,,)
	cfg.GuiX := GuiX
	cfg.GuiY := GuiY
	cfg.AfkX := AfkX
	cfg.AfkY := AfkY
	
	if (ui.AfkDocked)
	{
		cfg.GuiX := ui.GuiPrevX
		cfg.GuiY := ui.GuiPrevY
	}
	IniWrite(cfg.GuiX,cfg.file,"Interface","GuiX")
	IniWrite(cfg.GuiY,cfg.file,"Interface","GuiY")
	IniWrite(cfg.AfkX,cfg.file,"Interface","AfkX")
	IniWrite(cfg.AfkY,cfg.file,"Interface","AfkY")
	IniWrite(cfg.AfkSnapEnabled,cfg.file,"Interface","AfkSnapEnabled")
	IniWrite(cfg.GuiSnapEnabled,cfg.file,"Interface","GuiSnapEnabled")
	IniWrite(cfg.debugEnabled,cfg.file,"System","DebugEnabled")
	IniWrite(cfg.LogPanelEnabled,cfg.file,"System","LogPanelEnabled")
	IniWrite(cfg.ToolTipsEnabled,cfg.file,"System","ToolTipsEnabled")
	IniWrite(cfg.AlwaysOnTopEnabled,cfg.file,"Interface","AlwaysOnTopEnabled")
	IniWrite(cfg.AnimationsEnabled,cfg.file,"Interface","AnimationsEnabled")
	IniWrite(cfg.ColorPickerEnabled,cfg.file,"Interface","ColorPickerEnabled")

	IniWrite(cfg.AfkDataFile,cfg.file,"AFK","AfkDataFile")
	IniWrite(cfg.SilentIdleEnabled,cfg.file,"AFK","SilentIdleEnabled")
	IniWrite(ui.AutoClickerSpeedSlider.Value,cfg.file,"AFK","AutoClickerSpeed")
	IniWrite(ui.Win1ClassDDL.Text,cfg.file,"AFK","Win1Class")
	if (ui.Win2ClassDDL.Text != "N/A")
		IniWrite(ui.Win2ClassDDL.Text,cfg.file,"AFK","Win2Class")
	if !(DirExist("./Logs"))
	{
		DirCreate("./Logs")
	}
	FileAppend(ui.gvConsole.Value,"./Logs/gvLog_" A_YYYY A_MM A_DD A_Hour A_Min A_Sec ".txt")
	ui.MainGui.Destroy()
	BlockInput("Off")
}

	; toggleButton(name,tab := "",opts := "xs y+0",toolTip := "Default",guiName := "ui.MainGui",tabControl := "ui.MainGuiTabs") 
	; {
		
		; Toggle%name%(*) 
		; {
			; ui.toggle%name%.Opt((cfg.%name%Enabled := !cfg.%name%Enabled) ? ("Background" cfg.ThemeButtonColor) : ("Background" cfg.ThemeButtonReadyColor))
			; ui.toggle%name%.Redraw()
		; }
	
		; %tabControl%.Use(%tab%)
		; ui.toggle%name% := %guiName%.AddPicture(opts " section " (cfg.%name%Enabled ? ("Background" cfg.ThemeButtonOnColor) :("Background" cfg.ThemeButtonReadyColor)),"./Img/button_ready.png")
		; ui.toggle%name%.OnEvent("Click",Toggle%name%)
		; if (toolTip == "Default")
			; ui.toggle%name%ToolTip := "Toggle " %name%
		; else
			; ui.toggle%name%.ToolTip := toolTip
	
		; ui.label%name% := ui.%guiName%.AddText("x+3 ys+3 s10 BackgroundTrans",%name%)
	; }
	
	
GetWinNumber() {
	Try {
		debugLog("GetWinNumber Comparing " ui.Win1Hwnd.Text " and " ui.Win2Hwnd.Text " to " WinExist("A"))
		Return (ui.Win1Hwnd.Text == WinExist("A")) ? 1 : (ui.Win2Hwnd.Text == WinExist("A") ? 2 : 0)
	} Catch {
		Return 0
	}
}

debugLog(LogMsg)
{
	Global
	ui.gvConsole.Add([A_YYYY A_MM A_DD " [" A_Hour ":" A_Min ":" A_Sec "] " LogMsg])
	PostMessage("0x115",7,,,"ahk_id " ui.gvConsole.hwnd) 
}

DialogBox(DialogText, DialogTitle := "")
{
	Global
	ui.dialogBoxGui := Gui()
	ui.dialogBoxGui.Name := "DialogBox"
	ui.dialogBoxGui.BackColor := cfg.ThemeBackgroundColor
	ui.dialogBoxGui.Color := cfg.ThemeFont1Color
	ui.dialogBoxGui.Opt("-Caption -Border +AlwaysOnTop +Owner" ui.MainGui.Hwnd)
	ui.dialogBoxGui.SetFont("s16 c" cfg.ThemeFont2Color, "Calibri Bold")
	ui.dialogBoxText := ui.dialogBoxGui.AddText("y6 w300 r4 +Center section","")
	drawOutlineDialogBoxGui(5,5,330,125,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)

	ui.dialogBoxGui.Title := DialogTitle
	WinSetTransparent(0,ui.dialogBoxGui)
	ui.DialogBoxText.Text := DialogText
	ui.MainGui.GetPos(&MainGuiX,&MainGuiY,&MainGuiW,&MainGuiH)
	
	ui.dialogBoxGui.Show("x" (MainGuiX + 80) " y" MainGuiY + 45 " w340 h130 NoActivate")	
	
	Transparency := 0
	
	While Transparency < 253
	{
		Transparency += 5
		WinSetTransparent(Round(Transparency),ui.dialogBoxGui)
	}
}

DialogBoxClose(*)
{
	Global
	ui.dialogBoxGui.Destroy()
}

HasVal(haystack, needle) {
	if !(IsObject(haystack)) || (haystack.Length() = 0)
		return 0
	for index, value in haystack
		if (value = needle)
			return index
	return 0
}

NotifyOSD(NotifyMsg,Duration := 10)
{
	Transparent := 250

	try
		debugLog(NotifyMsg)
	
	ui.notifyGui			:= Gui()
	ui.notifyGui.Title 	:= "Notify"

	ui.notifyGui.Opt("+AlwaysOnTop -Caption +ToolWindow")  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	ui.notifyGui.BackColor := cfg.ThemeBackgroundColor  ; Can be any RGB color (it will be made transparent below).
	ui.notifyGui.SetFont("s16")  ; Set a large font size (32-point).
	ui.notifyGui.AddText("c" cfg.ThemeFont1Color " BackgroundTrans",NotifyMsg)  ; XX & YY serve to 00auto-size the window.
	WinSetTransparent(0,ui.notifyGui)
	ui.notifyGui.Show("x100 y" A_ScreenHeight-450 " NoActivate")  ; NoActivate avoids deactivating the currently active window.
	ui.notifyGui.GetPos(&x,&y,&w,&h)
	drawOutlineNotifyGui(x+2,y+2,w-4,h-6,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)
	drawOutlineNotifyGui(x+5,y+5,w-10,h-10,cfg.Theme3dBorderShadowColor,cfg.Theme3dBorderLightColor,2)
	Transparent := 250
	WinSetTransparent(Transparent,ui.notifyGui)
	Sleep(500)
	While Transparent > 10 { 	
		WinSetTransparent(Transparent,ui.notifyGui)
		Transparent -= 3
		Sleep(1)
	}
	Transparent := ""
	ui.notifyGui.Destroy()
	
}


KillMe(*)
{
	ExitApp
}


ResetWindowPosition(*)
{
	WinSetTransparent(0,ui.MainGui)
	ui.MainGui.Move(200,200,,)
	Reload()
}

ExitFunc(ExitReason,ExitCode)	
{
	debugLog("Exit Command Received")
	ui.MainGui.Opt("-AlwaysOnTop")

	If !InStr("Logoff Shutdown Reload Single",ExitReason)
	{
		Result := MsgBox("Are you sure you want to`nTERMINATE nControl?",,4)
		if Result = "No"
			Return 1
	}
	WriteConfig()
	Return
}
