#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)){
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}

initTrayMenu(*) {
	A_TrayMenu.Delete
	A_TrayMenu.Add
	A_TrayMenu.Add("Show Window", ShowGui)
	A_TrayMenu.Add("Hide Window", HideGui)
	A_TrayMenu.Add("Reset Window Position",ResetWindowPosition)
	A_TrayMenu.Add("Toggle Dock", DockApps)
	A_TrayMenu.Add()
	A_TrayMenu.Add("Toggle Log Window",toggleConsole)
	A_TrayMenu.Add()
	A_TrayMenu.Add("Exit App",KillMe)
	A_TrayMenu.Default := "Show Window"
	Try
		persistLog("Tray Initialized")
}

preAutoExec(InstallDir,ConfigFileName) {
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
					pbNotify("Cannot Create Folder at the Install Location. `nSuspect permissions issue with the desired install location",3000)
					ExitApp
				}
				persistLog("Successfully created install location at " InstallDir)
			}
			persistLog("Copying executable to install location")
			try{
				FileCopy(A_ScriptFullPath, InstallDir "/" A_AppName ".exe", true)
			}

			if (FileExist(InstallDir "/nControl.ini"))
			{
				msgBoxResult := MsgBox("Previous install detected. `nAttempt to preserve your existing settings?",, "Y/N T10")
				
				switch msgBoxResult {
					case "No": 
					{
						pbNotify("Replacing existing configuration files with updated and clean files",3000)
						FileInstall("./nControl.ini",InstallDir "/nControl.ini",1)
						FileInstall("./nControl.themes",InstallDir "/nControl.themes",1)
						FileInstall("./AfkData.csv",InstallDir "/AfkData.csv",1)
					} 
					case "Yes": 
					{
						cfg.ThemeFont1Color := "00FFFF"
						pbNotify("Using Existing Configuration Files`n`nIf you encounter issues,`nTry installing again and `nchoose 'No' when prompted to `npreserve your existing files.",3000)
						if !(FileExist(InstallDir "/AfkData.csv"))
							FileInstall("./AfkData.csv",InstallDir "/AfkData.csv",1)
						if !(FileExist(InstallDir "/nControl.themes"))
							FileInstall("./nControl.themes",InstallDir "/nControl.themes",1)
					}
					case "Timeout":
					{
						pbNotify("Timed out waiting for your response. `nExiting program",5000)
						Sleep(5000)
						exitApp
					}
				}
			} else {
				pbNotify("This seems to be the first time you're running nControl. `nA fresh install to [YourUserProfilePath]\Documents\nControl is being performed.")

						FileInstall("./nControl.ini",InstallDir "/nControl.ini",1)
						FileInstall("./nControl.themes",InstallDir "/nControl.themes",1)
						FileInstall("./AfkData.csv",InstallDir "/AfkData.csv",1)

			}
			if !(DirExist(InstallDir "\lib"))
			{
				DirCreate(InstallDir "\lib")
			}			
			if !(DirExist(InstallDir "\Img"))
			{
				DirCreate(InstallDir "\Img")
			}
			if !(DirExist(InstallDir "\Redist"))
			{
				DirCreate(InstallDir "\Redist")
			}
			persistLog("Created Img folder")
			
			; if (FileExist(InstallDir "nControl.ini")) 
			; || (FileExist(InstallDir "/nControl.themes"))
			; || (FileExist(InstallDir "/AfkData.csv"))
			; {
				; pbNotify("
				; (
				; Data files have been found from previous 
				; installations and can usually be used 
				; to preserve your settings and AFK profiles.
				; )"
				; ,3000)
			; }
			; Sleep(3000)
			; if (FileExist(InstallDir "nControl.ini")) 
			; && (FileFound("./nControl.ini",InstallDir "/nControl.ini","General Settings")) {
				; FileInstall("./nControl.ini",InstallDir "./nControl.ini",1)
			; }
				
			; if (FileExist(InstallDir "/nControl.themes")) 
			; && (FileFound("./nControl.themes",InstallDir "/nControl.themes","Color Theme Data")) {
				; FileInstall("./nControl.themes",InstallDir "/nControl.themes",1)
			; }
			
			; if (FileExist(InstallDir "/AfkData.csv"))
			; && (FileFound("./AfkData.csv",InstallDir "/afkData.csv","AFK Automation Data")) {
				; FileInstall("./AfkData.csv",InstallDir "/afkData.csv",1)
			; }
		
			; FileInstall("./nControl.ini",InstallDir "./nControl.ini",1)
			; FileInstall("./nControl.themes",InstallDir "/nControl.themes",1)
			; FileInstall("./AfkData.csv",InstallDir "/afkData.csv",1)
			FileInstall("./Img/button_update.png",InstallDir "/img/button_update.png",1)
			FileInstall("./Img/button_exit_gaming.png",InstallDir "/img/button_exit_gaming.png",1)
			FileInstall("./Img/keyboard_key_up.png",InstallDir "/img/keyboard_key_up.png",1)
			FileInstall("./Img/keyboard_key_down.png",InstallDir "/img/keyboard_key_down.png",1)
			FileInstall("./Img/button_ready.png",InstallDir "/Img/button_ready.png",1)
			FileInstall("./Img/button_on.png",InstallDir "/Img/button_on.png",1)
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
			FileInstall("./Img/attack_icon.png",InstallDir "/Img/attack_icon.png",true)
			FileInstall("./Img/sleep_icon.png",InstallDir "/Img/sleep_icon.png",true)
			FileInstall("./Img/arrow_left.png",InstallDir "/Img/arrow_left.png",true)
			FileInstall("./Img/arrow_right.png",InstallDir "/Img/arrow_right.png",true)
			FileInstall("./Img/button_execute.png",InstallDir "/Img/button_execute.png",true)
			FileInstall("./Img/status_stopped.png",InstallDir "/Img/status_stopped.png",true)
			FileInstall("./Img/status_running.png",InstallDir "/Img/status_running.png",true)
			FileInstall("./Img/label_left_trim.png",InstallDir "/Img/label_left_trim.png",true)
			FileInstall("./Img/label_right_trim.png",InstallDir "/Img/label_right_trim.png",true)
			FileInstall("./Img/label_timer_off.png",InstallDir "/Img/label_timer_off.png",true)
			FileInstall("./Img/label_anti_idle_timer.png",InstallDir "/Img/label_anti_idle_timer.png",true)
			FileInstall("./Img/label_infinite_tower.png",InstallDir "/Img/label_infinite_tower.png",true)
			FileInstall("./Img/label_celestial_tower.png",InstallDir "/Img/label_celestial_tower.png",true)			
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
			FileInstall("./Img/towerToggle_celestial.png",InstallDir "/Img/towerToggle_celestial.png",1)
			FileInstall("./Img/towerToggle_infinite.png",InstallDir "/Img/towerToggle_infinite.png",1)
			FileInstall("./Img/toggle_off.png",InstallDir "/Img/toggle_off.png",1)
			FileInstall("./Img/toggle_on.png",InstallDir "/Img/toggle_on.png",1)
			FileInstall("./Img/toggle_left.png",InstallDir "/Img/toggle_left.png",1)
			FileInstall("./Img/toggle_right.png",InstallDir "/Img/toggle_right.png",1)
			FileInstall("./Img/button_popout_ready.png",InstallDir "/Img/button_popout_ready.png",1)
			FileInstall("./Img/button_popout_on.png",InstallDir "/Img/button_popout_on.png",1)
			FileInstall("./Img/button_refresh.png",InstallDir "/Img/button_refresh.png",1)
			FileInstall("./Img/button_hide.png",InstallDir "/Img/button_hide.png",1)
			FileInstall("./Img/button_autoFire1_on.png",InstallDir "/Img/button_autoFire1_on.png",1)
			FileInstall("./Img/button_autoFire1_ready.png",InstallDir "/Img/button_autoFire1_ready.png",1)
			FileInstall("./Img/button_autoFire2_on.png",InstallDir "/Img/button_autoFire2_on.png",1)
			FileInstall("./Img/button_autoFire2_ready.png",InstallDir "/Img/button_autoFire2_ready.png",1)			
			FileInstall("./Img/button_autoFire1_disabled.png",InstallDir "/Img/button_autoFire1_disabled.png",1)			
			FileInstall("./Img/button_autoFire2_disabled.png",InstallDir "/Img/button_autoFire2_disabled.png",1)
			FileInstall("./Img/button_swapHwnd.png",InstallDir "/Img/button_swapHwnd.png",1)
			FileInstall("./Img/button_autoFire_ready.png",InstallDir "/Img/button_autoFire_ready.png",1)
			FileInstall("./Img/button_autoFire1_on.png",InstallDir "/Img/button_autoFire1_on.png",1)
			FileInstall("./Img/button_autoFire2_on.png",InstallDir "/Img/button_autoFire2_on.png",1)
			FileInstall("./Img/button_autoClicker_ready.png",InstallDir "/Img/button_autoClicker_ready.png",1)
			FileInstall("./Img/button_swapHwnd_enabled.png",InstallDir "/Img/button_swapHwnd_enabled.png",1)
			FileInstall("./Img/button_swapHwnd_disabled.png",InstallDir "/Img/button_swapHwnd_disabled.png",1)
			FileInstall("./Img/button_autoClicker_on.png",InstallDir "/Img/button_autoClicker_on.png",1)
			FileInstall("./Img/help.png",InstallDir "/Img/help.png",1)
			FileInstall("./Img/button_save_up.png",InstallDir "/Img/button_save_up.png",1)
			FileInstall("./Img/button_up.png",InstallDir "/Img/button_up.png",1)
			FileInstall("./Img/button_down.png",InstallDir "/Img/button_down.png",1)
			FileInstall("./Img/button_help.png",InstallDir "/Img/button_help.png",1)
			FileInstall("./Img/button_help_ready.png",InstallDir "/Img/button_help_ready.png",1)
			FileInstall("./Img/button_help_on.png",InstallDir "/Img/button_help_on.png",1)			
			FileInstall("./Img/button_console_ready.png",InstallDir "/Img/button_console_ready.png",1)
			FileInstall("./Img/button_console_on.png",InstallDir "/Img/button_console_on.png",1)
			FileInstall("./lib/ColorChooser.exe",InstallDir "/lib/ColorChooser.exe",1)
			FileInstall("./Redist/nircmd.exe",InstallDir "/Redist/nircmd.exe",1)
			FileInstall("./Img/button_power.png",InstallDir "/Img/button_power.png",1)
			FileInstall("./Img/button_power_on.png",InstallDir "/Img/button_power_on.png",1)
			FileInstall("./Img/button_power_ready.png",InstallDir "/Img/button_power_ready.png",1)
			FileInstall("./nControl_currentBuild.dat",InstallDir "/nControl_currentBuild.dat",1)
			FileInstall("./Img/keyboard_key_up.png",InstallDir "/img/keyboard_key_up.png",1)
			FileInstall("./Img/keyboard_key_down.png",InstallDir "/img/keyboard_key_down.png",1)
			FileInstall("./nControl_updater.exe",InstallDir "/nControl_updater.exe",1)
			FileInstall("./Img/button_launchLightGG.png",InstallDir "/Img/button_launchLightGG.png",1)
			FileInstall("./Img/button_launchLightGG_down.png",InstallDir "/Img/button_launchLightGG_down.png",1)
			FileInstall("./Img/button_launchDIM.png",InstallDir "/Img/button_launchDIM.png",1)
			FileInstall("./Img/button_launchDIM_down.png",InstallDir "/Img/button_launchDIM_down.png",1)
			
			persistLog("Copied Assets to: " InstallDir)
			

			Run(InstallDir "\" A_AppName ".exe")
		ExitApp
		
		}
	}
}

FileFound(fileName,destination,fileDescription) {
	source := fileName
	dest := destination
	PreserveData := pbNotify('
	(
	' fileName ' - (' fileDescription ')
	from previous installation found. 
	Would you like to preserve it?
	)'
	,,1)
	
	if !(PreserveData) {
		MsgBox("FileInstall('" source "','" dest "',1)")
	} else {
		pbNotify('
		(
			If you encounter any issues with your saved data
			please re-run this install and answer "No" when
			asked if you would like to preserve the file.
		)'
		,3000)
	}
}
			
persistLog(LogMsg) {
	Global
	if !(DirExist(InstallDir "\Logs"))
	{
		DirCreate(InstallDir "\Logs")
		FileAppend(A_YYYY A_MM A_DD " [" A_Hour ":" A_Min ":" A_Sec "] Created Logs Folder`n",InstallDir "/Logs/persist.log")
	}

	FileAppend(A_YYYY A_MM A_DD " [" A_Hour ":" A_Min ":" A_Sec "] " LogMsg "`n",InstallDir "/Logs/persist.log")
}
autoUpdate() {
	checkForUpdates(0)
}

CheckForUpdates(msg,*) {
		winSetAlwaysOnTop(0,ui.mainGui.hwnd)
		whr := ComObject("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", "https://raw.githubusercontent.com/obcache/nControl/main/nControl_currentBuild.dat", true)
		whr.Send()
		whr.WaitForResponse()
		latestVersion := whr.ResponseText
		currentVersion := fileRead("./nControl_currentBuild.dat")
		if (currentVersion < latestVersion) {
			run("./nControl_updater.exe")
		} else {
			 if(msg)
				pbNotify("No upgraded needed`nCurrent Version: " currentVersion "`nLatest Version: " latestVersion,3000)
		}
		winSetAlwaysOnTop(cfg.AlwaysOnTopEnabled,ui.mainGui.hwnd)
} 

cfgLoad(&cfg, &ui) {
	global


	cfg.gamingStopProcString	:= "foobar2000.exe,discord.exe,shatterline.exe,rocketLeague.exe,destiny2.exe,robloxPlayerBeta.exe,applicationFrameHost.exe,steam.exe,epicGamesLauncher.exe"
	cfg.gamingStartProcString 	:= "E:\Music\foobar2000\foobar2000.exe,C:\Users\cashm\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\5) Utilities\Discord.lnk,C:\Program Files (x86)\Steam\steam.exe,C:\Program Files (x86)\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"
		
	cfg.gamingStartProc 	:= strSplit(IniRead(cfg.file,"System","GamingStartProcesses",cfg.gamingStartProcString),",")
	cfg.gamingStopProc 		:= strSplit(IniRead(cfg.file,"System","GamingStopProcesses",cfg.gamingStopProcString),",")
	ui.d2AlwaysRunPaused 	:= false
	ui.d2Running			:= false
	ui.d2Sliding			:= false
	ui.d2Reloading			:= false
	ui.d2ToggleWalkEnabled	:= false
	ui.gameWindowsList 		:= array()
	cfg.gameWindowsList 	:= array()
	cfg.mainGui				:= IniRead(cfg.file,"System","MainGui","MainGui")
	cfg.startMinimizedEnabled	:= iniRead(cfg.file,"System","StartMinimizedEnabled",false)
	ui.guiH					:= 220  	;430 for Console Mode
	ui.clockTimerStarted 	:= false
	ui.clockMode			:= "Clock"
	ui.autoFire1Enabled		:= false
	ui.autoFire2Enabled		:= false
	ui.autoClickerEnabled 	:= false
	ui.antiIdle_enabled 	:= false
	ui.antiIdle1_enabled 	:= false
	ui.antiIdle2_enabled 	:= false
	ui.antiIdleInterval		:= 900000
	ui.previousTab			:= ""
	ui.activeTab			:= ""
	ui.lastWindowHwnd		:= 0
	ui.colorChanged 		:= false 
	ui.guiCollapsed			:= false
	ui.afkDocked 			:= false
	ui.afkAnchoredToGui 	:= true
	ui.afkEnabled 			:= false
	ui.towerEnabled 		:= false
	ui.helpActive			:= false
	ui.dockApp_enabled		:= false
	ui.themeResetScheduled 	:= false
	ui.win1Hwnd				:= ""
	ui.win2Hwnd				:= ""
	ui.pipEnabled			:= false
	ui.pauseAlwaysRun		:= false
	ui.inGameChat			:= false
	ui.reloading			:= false
	
	afk						:= object()
	ui.profileList			:= array()
	ui.profileListStr		:= ""
	win1afk 				:= object()
	win2afk					:= object()
	win1afk.steps			:= array()
	win2afk.steps			:= array()
	win1afk.nextStep		:= ""
	win2afk.nextStep 		:= ""
	win1afk.waits 			:= array()
	win2afk.waits			:= array()
	win1afk.nextWait		:= ""
	win2afk.nextWait		:= ""
	win1afk.waiting			:= false
	win2afk.waiting			:= false
	win1afk.currStepNum		:= ""
	win2afk.currStepNum 	:= ""
	
	ui.dividerGui			:= gui()
	cfg.excludedApps		:= IniRead(cfg.file,"System","ExcludedApps","Windows10Universal.exe,explorer.exe,RobloxPlayerInstaller.exe,RobloxPlayerLauncher.exe,Chrome.exe,msedge.exe")
	cfg.MainGui				:= IniRead(cfg.file,"System","MainGui","MainGui")
	cfg.InstallDir			:= IniRead(cfg.file,"System","InstallDir", A_MyDocuments "\nControl")
	cfg.MainScriptName		:= IniRead(cfg.file,"System","MainScriptName", "nControl")
	cfg.debugEnabled		:= IniRead(cfg.file,"System","debugEnabled",false)
	cfg.consoleVisible		:= IniRead(cfg.file,"System","consoleVisible",false)
	cfg.ToolTipsEnabled 	:= IniRead(cfg.file,"System","ToolTipsEnabled",true)
	cfg.releaseChannel		:= IniRead(cfg.file,"System","ReleaseChannel","Stable")
	cfg.toggleOn			:= IniRead(cfg.file,"Interface","ToggleOnImage","./Img/toggle_on.png")
	cfg.toggleOff			:= IniRead(cfg.file,"Interface","ToggleOffImage","./Img/toggle_off.png")
	cfg.activeMainTab		:= IniRead(cfg.file,"Interface","activeMainTab",1)
	cfg.activeGameTab  		:= IniRead(cfg.file,"Interface","ActiveGameTab",1)
	cfg.AlwaysOnTopEnabled	:= IniRead(cfg.file,"Interface","AlwaysOnTopEnabled",true)
	cfg.AnimationsEnabled	:= IniRead(cfg.file,"Interface","AnimationsEnabled",true)
	cfg.ColorPickerEnabled 	:= IniRead(cfg.file,"Interface","ColorPickerEnabled",true)
	cfg.GuiX 				:= IniRead(cfg.file,"Interface","GuiX",PrimaryWorkAreaLeft + 200)
	cfg.GuiY 				:= IniRead(cfg.file,"Interface","GuiY",PrimaryWorkAreaTop + 200)
	cfg.GuiW				:= IniRead(cfg.file,"Interface","GuiW",545)
	cfg.GuiH				:= IniRead(cfg.file,"Interface","GuiH",210)

	MonitorGet(MonitorGetPrimary(),&L,&T,&R,&B)
	if (cfg.GuiX < L)
		cfg.GuiX := 200
	if (cfg.GuiY > B)
		cfg.GuiY := 200
		
	cfg.AfkX					:= IniRead(cfg.file,"Interface","AfkX",cfg.GuiX+10)
	cfg.AfkY					:= IniRead(cfg.file,"Interface","AfkY",cfg.GuiY+35)
	cfg.AfkSnapEnabled			:= IniRead(cfg.file,"Interface","AfkSnapEnabled",false)
	cfg.GuiSnapEnabled			:= IniRead(cfg.file,"Interface","GuiSnapEnabled",true)


	cfg.AutoDetectGame			:= IniRead(cfg.file,"Game","AutoDetectGame",true)
	cfg.gameModuleList			:= strSplit(iniRead(cfg.file,"Game","GameModuleList","World//Zero,Destiny2,CS2,Fortnite"),",")
	cfg.GameList				:= StrSplit(IniRead(cfg.file,"Game","GameList","Roblox,Rocket League"),",")
	cfg.mainTabList				:= strSplit(IniRead(cfg.file,"Interface","MainTabList","Sys,AFK,Game,Dock,Setup,Audio"),",")
	cfg.game					:= IniRead(cfg.file,"Game","Game","2")
	cfg.HwndSwapEnabled			:= IniRead(cfg.file,"Game","HwndSwapEnabled",false)
	ui.win1enabled 				:= IniRead(cfg.file,"Game","Win1Enabled",true)
	ui.win2enabled 				:= IniRead(cfg.file,"Game","Win2Enabled",true)	
	cfg.win1Disabled 			:= IniRead(cfg.file,"Game","win1disabled",false)
	cfg.win2Disabled 			:= IniRead(cfg.file,"Game","win2disabled",false)
	cfg.w0DualPerkSwapEnabled	:= IniRead(cfg.file,"Game","w0DualPerkSwap",true)
	cfg.AfkDataFile				:= IniRead(cfg.file,"AFK","AfkDataFile","./AfkData.csv")
	cfg.Profile					:= IniRead(cfg.file,"AFK","Profile","1")
	cfg.win1Class				:= IniRead(cfg.file,"AFK","Win1Class",1)
	cfg.win2Class				:= IniRead(cfg.file,"AFK","Win2Class",1)
	cfg.antiIdleWin1Cmd			:= IniRead(cfg.file,"AFK","AntiIdleWin1Cmd","5")
	cfg.antiIdleWin2Cmd			:= IniRead(cfg.file,"AFK","AntiIdleWin2Cmd","5")
	cfg.towerInterval			:= iniRead(cfg.file,"AFK","TowerInterval","270000")
	cfg.antiIdleInterval		:= IniRead(cfg.file,"AFK","AntiIdleInterval","1250")
	cfg.SilentIdleEnabled 		:= IniRead(cfg.file,"AFK","SilentIdleEnabled",true)
	cfg.AutoClickerSpeed 		:= IniRead(cfg.file,"AFK","AutoClickerSpeed",50)
	cfg.CelestialTowerEnabled	:= IniRead(cfg.file,"AFK","CelestialTowerEnabled",false)
	cfg.nControlMonitor 		:= IniRead(cfg.file,"nControl","nControlMonitor","1")	
	cfg.app1filename			:= IniRead(cfg.file,"nControl","app1filename","")
	cfg.app1path				:= IniRead(cfg.file,"nControl","app1path","")
	cfg.app2filename			:= IniRead(cfg.file,"nControl","app2filename","")
	cfg.app2path				:= IniRead(cfg.file,"nControl","app2path","")
	
	cfg.DockHeight 				:= IniRead(cfg.file,"nControl","DockHeight","240")
	cfg.DockMarginSize 			:= IniRead(cfg.file,"nControl","DockMarginSize","8")
	cfg.UndockedX 				:= IniRead(cfg.file,"nControl","UndockedX","150")
	cfg.UndockedY 				:= IniRead(cfg.file,"nControl","UndockedY","150")
	cfg.UndockedW 				:= IniRead(cfg.file,"nControl","UndockedW","1600")
	cfg.UndockedH 				:= IniRead(cfg.file,"nControl","UndockedH","1000")

	cfg.gameAudioEnabled		:= IniRead(cfg.file,"audio","gameAudioEnabled","false")
	cfg.MicName					:= IniRead(cfg.file,"audio","MicName","Yeti")
	cfg.SpeakerName				:= IniRead(cfg.file,"audio","SpeakerName","S2MASTER")
	cfg.HeadsetName				:= IniRead(cfg.file,"audio","HeadsetName","G432")
	cfg.MicVolume				:= IniRead(cfg.file,"audio","MicVolume",".80")
	cfg.SpeakerVolume	 		:= IniRead(cfg.file,"audio","SpeakerVolume",".50")
	cfg.HeadsetVolume			:= IniRead(cfg.file,"audio","HeadsetVolume",".80")
	cfg.Mode					:= IniRead(cfg.file,"audio","Mode","1")

	cfg.Theme					:= IniRead(cfg.file,"Interface","Theme","Modern Class")
	cfg.ThemeList				:= StrSplit(IniRead(cfg.themeFile,"Interface","ThemeList","Modern Class,Cold Steel,Militarized,Custom"),",")
	cfg.ThemeBackgroundColor	:= IniRead(cfg.themeFile,cfg.Theme,"ThemeBackgroundColor","414141")
	cfg.ThemeFont1Color			:= IniRead(cfg.themeFile,cfg.Theme,"ThemeFont1Color","1FFFF0")
	cfg.ThemeFont2Color			:= IniRead(cfg.themeFile,cfg.Theme,"ThemeFont2Color","FBD58E")
	cfg.ThemeFont3Color			:= IniRead(cfg.themeFile,cfg.Theme,"ThemeFont3Color","1FFFF0")
	cfg.ThemeFont4Color			:= IniRead(cfg.themeFile,cfg.Theme,"ThemeFont4Color","FBD58E")
	cfg.ThemeBright2Color		:= IniRead(cfg.themeFile,cfg.Theme,"ThemeBright2Color","C0C0C0")
	cfg.ThemeBright1Color		:= IniRead(cfg.themeFile,cfg.Theme,"ThemeBright1Color","FFFFFF")
	cfg.ThemeDark2Color			:= IniRead(cfg.themeFile,cfg.Theme,"ThemeDark2Color","C0C0C0")
	cfg.ThemeDark1Color			:= IniRead(cfg.themeFile,cfg.Theme,"ThemeDark1Color","FFFFFF")
	cfg.ThemeBorderLightColor	:= IniRead(cfg.themeFile,cfg.Theme,"ThemeBorderLightColor","888888")
	cfg.ThemeBorderDarkColor	:= IniRead(cfg.themeFile,cfg.Theme,"ThemeBorderDarkColor","333333")
	cfg.ThemePanel1Color		:= IniRead(cfg.themeFile,cfg.Theme,"ThemePanel1Color","204040")
	cfg.ThemePanel2Color		:= IniRead(cfg.themeFile,cfg.Theme,"ThemePanel2Color","804001")
	cfg.ThemePanel3Color		:= IniRead(cfg.themeFile,cfg.Theme,"ThemePanel3Color","204040")
	cfg.ThemePanel4Color		:= IniRead(cfg.themeFile,cfg.Theme,"ThemePanel4Color","804001")
	cfg.ThemeEditboxColor		:= IniRead(cfg.themeFile,cfg.Theme,"ThemeEditboxColor","292929")
	cfg.ThemeProgressColor		:= IniRead(cfg.themeFile,cfg.Theme,"ThemeProgressColor","292929")
	cfg.ThemeDisabledColor		:= IniRead(cfg.themeFile,cfg.Theme,"ThemeDisabledColor","212121")
	cfg.ThemeButtonAlertColor	:= IniRead(cfg.themeFile,cfg.Theme,"ThemeButtonAlertColor","3C3C3C")
	cfg.ThemeButtonOnColor		:= IniRead(cfg.themeFile,cfg.Theme,"ThemeButtonOnColor","FF01FF")
	cfg.ThemeButtonReadyColor	:= IniRead(cfg.themeFile,cfg.Theme,"ThemeButtonReadyColor","1FFFF0")
	
	cfg.holdToCrouchEnabled 	:= IniRead(cfg.file,"game","HoldToCrouch",true)
	cfg.cs2HoldToScopeEnabled	:= IniRead(cfg.file,"game","cs2HoldToScopeEnabled",true)
	cfg.d2AlwaysRunEnabled		:= IniRead(cfg.file,"Game","d2AlwaysRunEnabled",false)
	cfg.d2SprintKey				:= IniRead(cfg.file,"Game","d2SprintKey","<UNSET>")
	cfg.d2CrouchKey				:= IniRead(cfg.file,"Game","d2CrouchKey","<UNSET>")
	cfg.d2ToggleWalkKey			:= IniRead(cfg.file,"Game","d2ToggleWalkKey","<UNSET>")
	cfg.d2HoldWalkKey			:= IniRead(cfg.file,"Game","d2HoldWalkKey","<UNSET>")
}
WriteConfig() {
	Global
	tmpGameList := ""
	cfg.gamingStartProcString := ""
	loop cfg.gamingStartProc.length {
		cfg.gamingStartProcString .= cfg.gamingStartProc[a_index] ","
	}
	cfg.gamingStopProcString := ""
	loop cfg.gamingStopProc.length {
		cfg.gamingStopProcString .= cfg.gamingStopProc[a_index] ","
	}
	iniWrite(rtrim(cfg.gamingStartProcString,","),cfg.file,"System","GamingStartProcesses")
	iniWrite(rtrim(cfg.gamingStopProcString,","),cfg.file,"System","GamingStopProcesses")
	IniWrite(cfg.autoDetectGame,cfg.file,"Game","AutoDetectGame")
	iniWrite(cfg.excludedApps,cfg.file,"System","ExcludedApps")
	IniWrite(cfg.game,cfg.file,"Game","Game")
	IniWrite(cfg.mainScriptName,cfg.file,"System","ScriptName")
	IniWrite(cfg.installDir,cfg.file,"System","InstallDir")
	IniWrite(cfg.mainGui,cfg.file,"System","MainGui")
	iniWrite(cfg.startMinimizedEnabled,cfg.file,"System","StartMinimizedEnabled")
	IniWrite(ui.releaseChannelDDL.value,cfg.file,"System","ReleaseChannel")
	IniWrite(arr2str(cfg.gameModuleList),cfg.file,"Game","GameModuleList")
	IniWrite(arr2str(cfg.gameList),cfg.file,"Game","GameList")
	IniWrite(ui.gameDDL.value,cfg.file,"Game","Game")
	IniWrite(ui.win1enabled,cfg.file,"Game","Win1Enabled")
	IniWrite(ui.win2enabled,cfg.file,"Game","Win2Enabled")	
	IniWrite(cfg.win1disabled,cfg.file,"Game","win1disabled")
	IniWrite(cfg.win2disabled,cfg.file,"Game","win2disabled")
	IniWrite(cfg.hwndSwapEnabled,cfg.file,"Game","HwndSwapEnabled")
	IniWrite(cfg.cs2HoldToScopeEnabled,cfg.file,"Game","cs2HoldToScope")
	IniWrite(cfg.nControlMonitor,cfg.file,"nControl","nControlMonitor")
	IniWrite(cfg.dockHeight,cfg.file,"nControl","DockHeight")
	IniWrite(cfg.dockMarginSize,cfg.file,"nControl","DockMarginSize")

	IniWrite(cfg.undockedX,cfg.file,"nControl","UndockedX")
	IniWrite(cfg.undockedY,cfg.file,"nControl","UndockedY")
	IniWrite(cfg.undockedW,cfg.file,"nControl","UndockedW")
	IniWrite(cfg.undockedH,cfg.file,"nControl","UndockedH")

	IniWrite(ui.app2path.text,cfg.file,"nControl","app2path")
	IniWrite(ui.app2filename.text,cfg.file,"nControl","app2filename")
	IniWrite(ui.app1path.text,cfg.file,"nControl","app1path")
	IniWrite(ui.app1filename.text,cfg.file,"nControl","app1filename")

	IniWrite(cfg.gameAudioEnabled,cfg.file,"Audio","gameAudioEnabled")
	IniWrite(cfg.micName,cfg.file,"Audio","Mic")
	IniWrite(cfg.speakerName,cfg.file,"Audio","Speaker")
	IniWrite(cfg.headsetName,cfg.file,"Audio","Headset")
	IniWrite(cfg.micVolume,cfg.file,"Audio","MicVolume")
	IniWrite(cfg.speakerVolume,cfg.file,"Audio","SpeakerVolume")
	IniWrite(cfg.headsetVolume,cfg.file,"Audio","HeadsetVolume")
	IniWrite(cfg.mode,cfg.file,"Audio","Mode")

	if (ui.themeResetScheduled) {
		FileDelete(cfg.themeFile)
		FileAppend(ui.defaultThemes,cfg.themeFile)
		ui.themeResetSchedule := false
	} else {
		IniWrite(ui.themeDDL.text,cfg.file,"Interface","Theme")
		IniWrite(arr2str(cfg.themeList),cfg.themeFile,"Interface","ThemeList")
		IniWrite(cfg.themeBright2Color,cfg.themeFile,"Custom","ThemeBright2Color")
		IniWrite(cfg.themeBright1Color,cfg.themeFile,"Custom","ThemeBright1Color")
		IniWrite(cfg.themeDark2Color,cfg.themeFile,"Custom","ThemeDark2Color")
		IniWrite(cfg.themeDark1Color,cfg.themeFile,"Custom","ThemeDark1Color")
		IniWrite(cfg.themeBorderDarkColor,cfg.themeFile,"Custom","ThemeBorderDarkColor")
		IniWrite(cfg.themeBorderLightColor,cfg.themeFile,"Custom","ThemeBorderLightColor")
		IniWrite(cfg.themeBackgroundColor,cfg.themeFile,"Custom","ThemeBackgroundColor")
		IniWrite(cfg.themeFont1Color,cfg.themeFile,"Custom","ThemeFont1Color")
		IniWrite(cfg.themeFont2Color,cfg.themeFile,"Custom","ThemeFont2Color")
		IniWrite(cfg.themeFont3Color,cfg.themeFile,"Custom","ThemeFont3Color")
		IniWrite(cfg.themeFont4Color,cfg.themeFile,"Custom","ThemeFont4Color")
		IniWrite(cfg.themePanel1Color,cfg.themeFile,"Custom","ThemePanel1Color")
		IniWrite(cfg.themePanel3Color,cfg.themeFile,"Custom","ThemePanel3Color")
		IniWrite(cfg.themePanel2Color,cfg.themeFile,"Custom","ThemePanel2Color")
		IniWrite(cfg.themePanel4Color,cfg.themeFile,"Custom","ThemePanel4Color")
		IniWrite(cfg.themeEditboxColor,cfg.themeFile,"Custom","ThemeEditboxColor")
		IniWrite(cfg.themeProgressColor,cfg.themeFile,"Custom","ThemeProgressColor")
		IniWrite(cfg.themeDisabledColor,cfg.themeFile,"Custom","ThemeDisabledColor")
		IniWrite(cfg.themeButtonOnColor,cfg.themeFile,"Custom","ThemeButtonOnColor")
		IniWrite(cfg.themeButtonReadyColor,cfg.themeFile,"Custom","ThemeButtonReadyColor")
		IniWrite(cfg.themeButtonAlertColor,cfg.themeFile,"Custom","ThemeButtonAlertColor")
		IniWrite(cfg.holdToCrouchEnabled,cfg.file,"game","HoldToCrouch")
		IniWrite(cfg.d2AlwaysRunEnabled,cfg.file,"Game","d2AlwaysRunEnabled")
		IniWrite(cfg.d2SprintKey,cfg.file,"Game","d2SprintKey")
		IniWrite(cfg.d2CrouchKey,cfg.file,"Game","d2CrouchKey")
		IniWrite(cfg.d2ToggleWalkKey,cfg.file,"Game","d2ToggleWalkKey")
		IniWrite(cfg.d2HoldWalkKey,cfg.file,"Game","d2HoldWalkKey")
		IniWrite(cfg.activeMainTab,cfg.file,"Interface","ActiveMainTab")
		IniWrite(cfg.activeGameTab,cfg.file,"Interface","ActiveGameTab")
		ui.mainTabListString := ""
		loop cfg.mainTabList.length {
			ui.mainTabListString .= cfg.mainTabList[a_index] ','
		}
		IniWrite(rtrim(ui.mainTabListString,","),cfg.file,"Interface","MainTabList")
	}
	
	ui.MainGui.GetPos(&GuiX,&GuiY,,)
	ui.AfkGui.GetPos(&AfkX,&AfkY,,)
	cfg.GuiX := GuiX
	cfg.GuiY := GuiY
	cfg.AfkX := AfkX
	cfg.AfkY := AfkY
	try {
			if (ui.AfkDocked)
			{
				cfg.GuiX := ui.GuiPrevX
				cfg.GuiY := ui.GuiPrevY
			} 
		} catch {
			cfg.GuiX := 200
			cfg.GuiY := 200
		}
		
	IniWrite(cfg.GuiX,cfg.file,"Interface","GuiX")
	IniWrite(cfg.GuiY,cfg.file,"Interface","GuiY")
	IniWrite(cfg.AfkX,cfg.file,"Interface","AfkX")
	IniWrite(cfg.AfkY,cfg.file,"Interface","AfkY")
	IniWrite(cfg.AfkSnapEnabled,cfg.file,"Interface","AfkSnapEnabled")
	IniWrite(cfg.GuiSnapEnabled,cfg.file,"Interface","GuiSnapEnabled")
	IniWrite(cfg.toggleOn,cfg.file,"Interface","ToggleOnImage")
	IniWrite(cfg.toggleOff,cfg.file,"Interface","ToggleOffImage")
	IniWrite(cfg.ConsoleVisible,cfg.file,"System","ConsoleVisible")
	IniWrite(cfg.consoleVisible,cfg.file,"System","consoleVisible")
	IniWrite(cfg.ToolTipsEnabled,cfg.file,"System","ToolTipsEnabled")
	IniWrite(cfg.AlwaysOnTopEnabled,cfg.file,"Interface","AlwaysOnTopEnabled")
	IniWrite(cfg.AnimationsEnabled,cfg.file,"Interface","AnimationsEnabled")
	IniWrite(cfg.ColorPickerEnabled,cfg.file,"Interface","ColorPickerEnabled")

	IniWrite(cfg.AfkDataFile,cfg.file,"AFK","AfkDataFile")
	IniWrite(cfg.SilentIdleEnabled,cfg.file,"AFK","SilentIdleEnabled")
	iniWrite(cfg.towerInterval,cfg.file,"AFK","TowerInterval")
	iniWrite(cfg.CelestialTowerEnabled,cfg.file,"AFK","CelestialTowerEnabled")
	IniWrite(ui.AutoClickerSpeedSlider.Value,cfg.file,"AFK","AutoClickerSpeed")
	IniWrite(ui.win1classDDL.value,cfg.file,"AFK","Win1Class")
	if (ui.win2ClassDDL.Text != "N/A")
		IniWrite(ui.win2classDDL.value,cfg.file,"AFK","Win2Class")
	if !(DirExist("./Logs"))
	{
		DirCreate("./Logs")
	}
	
	; if (cfg.ConsoleVisible)
	; {
		; FileAppend(ui.gvConsole.Value,"./Logs/gvLog_" A_YYYY A_MM A_DD A_Hour A_Min A_Sec ".txt")
	; }
	ui.MainGui.Destroy()
	BlockInput("Off")
}


runApp(appName) {
	global
	For app in ComObject('Shell.Application').NameSpace('shell:AppsFolder').Items
	(app.Name = appName) && RunWait('explorer shell:appsFolder\' app.Path,,,&appPID)
}

getClick(&clickX,&clickY,&activeWindow) {
	DialogBox("Click to get information about a pixel")
	Sleep(750)
	CoordMode("Mouse","Client")
	MonitorSelectStatus := KeyWait("LButton", "D T15")
	DialogBoxClose()
	if (MonitorSelectStatus = 0)
	{	
		MsgBox("A monitor was not selected in time.`nPlease try again.")
		Return
	} else {
		MouseGetPos(&clickX,&clickY,&pixelColor,&activeWindow)
		pixelColor := PixelGetColor(clickX,clickY)
		activeWindow := winWait("A")
		fileAppend("Window: [" activeWindow "] " WinGetTitle("ahk_id " activeWindow) " `nx: " clickX " y: " clickY "`nColor: " pixelColor "`n`n", "./capturedPixels.txt")
		debugLog("Window: [" activeWindow "] " WinGetTitle("ahk_id " activeWindow) ", x: " clickX " y: " clickY ", Color: " pixelColor)
	}
}

GetWinNumber() {
	 Try {
		debugLog("GetWinNumber Comparing " ui.Win1Hwnd " and " ui.Win2Hwnd " to " WinExist("A"))
		Return (ui.Win1Hwnd == WinExist("A")) ? 1 : (ui.Win2Hwnd == WinExist("A") ? 2 : 0)
	 } Catch {
		 Return 0
	 }
}

debugLog(LogMsg) {
	Global
	ui.gvConsole.Add([A_YYYY A_MM A_DD " [" A_Hour ":" A_Min ":" A_Sec "] " LogMsg])
	PostMessage("0x115",7,,,"ahk_id " ui.gvConsole.hwnd) 
}


DialogBox(Msg,Alignment := "Left")
{
	Global
	if !InStr("LeftRightCenter",Alignment)
		Alignment := "Left"
		
	Transparent := 250
	
	ui.notifyGui			:= Gui()
	ui.notifyGui.Title 		:= "Notify"

	ui.notifyGui.Opt("+AlwaysOnTop -Caption +ToolWindow +Owner" ui.mainGui.hwnd)  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	ui.notifyGui.BackColor := cfg.ThemePanel2Color  ; Can be any RGB color (it will be made transparent below).
	ui.notifyGui.SetFont("s16")  ; Set a large font size (32-point).
	ui.notifyGui.AddText("c" cfg.ThemeFont2Color " " Alignment " BackgroundTrans",Msg)  ; XX & YY serve to 00auto-size the window.
	ui.notifyGui.AddText("xs hidden")
	
	WinSetTransparent(0,ui.notifyGui)
	ui.notifyGui.Show("NoActivate Autosize")  ; NoActivate avoids deactivating the currently active window.
	ui.notifyGui.GetPos(&x,&y,&w,&h)
	
	ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
	ui.notifyGui.Show("x" (GuiX+(GuiW/2)-(w/2)) " y" GuiY+(100-(h/2)) " NoActivate")
	drawOutlineNotifyGui(0,0,w,h,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,3)
	drawOutlineNotifyGui(5,5,w-10,h-10,cfg.ThemeBright1Color,cfg.ThemeBright2Color,2)
	
	Transparency := 0
	
	While Transparency < 253
	{
		Transparency += 5
		WinSetTransparent(Round(Transparency),ui.notifyGui)
	}
}

DialogBoxClose(*)
{
	Global
	ui.notifyGui.Destroy()
}

NotifyOSD(NotifyMsg,Duration := 10,Alignment := "Left",YN := "")
{
	if !InStr("LeftRightCenter",Alignment)
		Alignment := "Left"
		
	Transparent := 250
	
	ui.notifyGui			:= Gui()
	ui.notifyGui.Title 		:= "Notify"

	ui.notifyGui.Opt("+AlwaysOnTop -Caption +ToolWindow +Owner" ui.mainGui.hwnd)  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	ui.notifyGui.BackColor := cfg.ThemePanel2Color  ; Can be any RGB color (it will be made transparent below).
	ui.notifyGui.SetFont("s16")  ; Set a large font size (32-point).
	ui.notifyGui.AddText("c" cfg.ThemeFont2Color " " Alignment " BackgroundTrans",NotifyMsg)  ; XX & YY serve to 00auto-size the window.
	ui.notifyGui.AddText("xs hidden")
	
	WinSetTransparent(0,ui.notifyGui)
	ui.notifyGui.Show("NoActivate Autosize")  ; NoActivate avoids deactivating the currently active window.
	ui.notifyGui.GetPos(&x,&y,&w,&h)
	
	ui.MainGui.GetPos(&GuiX,&GuiY,&GuiW,&GuiH)
	ui.notifyGui.Show("x" (GuiX+(GuiW/2)-(w/2)) " y" GuiY+(100-(h/2)) " NoActivate")
	drawOutlineNotifyGui(0,0,w,h,cfg.ThemeBorderDarkColor,cfg.ThemeBorderLightColor,3)
	drawOutlineNotifyGui(5,5,w-10,h-10,cfg.ThemeBright1Color,cfg.ThemeBright2Color,2)
	
	if (YN) {
		ui.notifyGui.AddText("xs hidden")
		ui.notifyYesButton := ui.notifyGui.AddPicture("ys x30 y30","./Img/button_yes.png")
		ui.notifyYesButton.OnEvent("Click",notifyConfirm)
		ui.notifyNoButton := ui.notifyGui.AddPicture("ys","/Img/button_no.png")
		ui.notifyNoButton.OnEvent("Click",notifyCancel)
		SetTimer(waitOSD,-10000)
	} else {
		ui.Transparent := 250
		WinSetTransparent(ui.Transparent,ui.notifyGui)
		sleep(duration)
		fadeOSD()
	}

	waitOSD() {
		ui.notifyGui.destroy()
		notifyOSD("Timed out waiting for response.`nPlease try your action again",-1000)
	}



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


hasVal(haystack, needle) {
	if !(IsObject(haystack)) || (haystack.Length() = 0)
		return 0
	for index, value in haystack
		if (value = needle)
			return index
	return 0
}

killMe(*) {
	ExitApp
}

resetWindowPosition(*) {
	guiVis(ui.titleBarButtonGui,false)
	guiVis(ui.afkGui,false)
	guiVis(ui.gameSettingsGui,false)
	guiVis(ui.mainGui,false)
	
	ui.MainGui.Move(200,200,,)
	Reload()
}

exitFunc(ExitReason,ExitCode) {
	debugLog("Exit Command Received")
	ui.MainGui.Opt("-AlwaysOnTop")

	If !InStr("Logoff Shutdown Reload Single Close",ExitReason)
	{
		Result := MsgBox("Are you sure you want to`nTERMINATE nControl?",,4)
		if Result = "No"
			Return 1
	}
	WriteConfig()
	Return
}

restartApp(*) {
	reload()
}

arr2str(arrayName) {
	loop arrayName.Length
	{
		stringFromArray .= arrayName[a_index] ","
	}
	return rtrim(stringFromArray,",")
}
