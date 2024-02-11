#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

if (InStr(A_LineFile,A_ScriptFullPath)) {
	Run(A_ScriptDir "/../nControl.ahk")
	ExitApp
	Return
}

GuiAudioTab(&ui,&cfg,&audio)
{

	audioDevices := array()
	
	loop
	{
		; For each loop iteration, try to get the corresponding device.
		try
		{
			devName := SoundGetName(,devIndex := A_Index)
			audioDevices.Push(devName)
		}
		catch
			break
	}
	
	ui.MainGuiTabs.UseTab("Audio")
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont2Color,"Calibri")
	ui.toggleGameAudio := ui.MainGui.AddPicture("x40 y35 w80 h30 section vGameAudio " (cfg.gameAudioEnabled ? ("Background" cfg.ThemeButtonOnColor) : ("Background" cfg.ThemeButtonReadyColor)),((cfg.gameAudioEnabled) ? (cfg.toggleOn) : (cfg.toggleOff)))
	ui.toggleGameAudio.OnEvent("Click", toggleGameAudio)
	ui.toggleGameAudio.ToolTip := "Force these settings as system audio defaults."
	;ui.labelGameAudio:= ui.MainGui.AddText("x+3 ys+3"," Enable")
		
	ui.MainGui.AddText("x+15","Mode ")
	ui.MainGui.SetFont("s11 c" cfg.ThemeFont1Color,"Calibri")
	HiddenEdit := ui.MainGui.AddEdit("w0 backgroundF1F2F3","")
	
	audioModeDDL := ui.MainGui.Add("DDL","ys w150 r20 Background" cfg.ThemeEditboxColor " AltSubmit Choose" cfg.Mode,["Speakers","Headset"])
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont2Color,"Calibri")
	ui.MainGui.AddText("x45 y66 w80 section","Mic`t")	
	ui.ButtonSetMic := ui.MainGui.AddPicture("ys w25 h25","./Img/button_ready.png")
	ui.MainGui.SetFont("s11 c" cfg.ThemeFont1Color,"Calibri")
	ui.MicNameDDL		:= ui.MainGui.AddDropDownList("ys w210  Background" cfg.ThemeEditboxColor,audioDevices)
	ui.MicVolumeSlider := ui.MainGui.AddSlider("ys w170 h25 Range0-100",cfg.MicVolume)
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont2Color,"Calibri")
	ui.MainGui.AddText("xs+0 y+0 w80 section","Speakers")
	ui.ButtonSetSpeaker := ui.MainGui.AddPicture("ys+0 x+0 w25 h25","./Img/button_ready.png")
	ui.MainGui.SetFont("s11 c" cfg.ThemeFont1Color,"Calibri")
	ui.SpeakerNameDDL	:= ui.MainGui.AddDropDownList("ys+0 x+0 w210 h25 Background" cfg.ThemeEditboxColor,audioDevices)
	ui.SpeakerVolumeSlider := ui.MainGui.AddSlider("ys+0 x+0 w170 AltSubmit Range0-100",cfg.SpeakerVolume)
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont2Color,"Calibri")
	ui.MainGui.AddText("xs+0 y+-8 w80 section","Headset")
	ui.ButtonSetHeadset := ui.MainGui.AddPicture("ys+0 x+0 w25 h25","./Img/button_ready.png")
	ui.MainGui.SetFont("s11 c" cfg.ThemeFont1Color,"Calibri")
	ui.HeadsetNameDDL	:= ui.MainGui.AddDropDownList("ys x+0 w210 Background" cfg.ThemeEditboxColor,audioDevices)
	
	
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri Bold")
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont2Color,"Calibri")
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri Bold")
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont2Color,"Calibri")
	ui.MainGui.SetFont("s12 c" cfg.ThemeFont1Color,"Calibri Bold")
	ui.MainGui.SetFont("s14 c" cfg.ThemeFont2Color,"Calibri")
	
	ui.ButtonSetMic.OnEvent("Click",ChooseaudioInput)
	ui.ButtonSetSpeaker.OnEvent("Click",ChooseAudioOutput)
	ui.ButtonSetSpeaker.OnEvent("Click",ChooseHeadsetOutput)
	ui.micVolumeSlider.onEvent("Change",setInputVol)
	ui.speakerVolumeSlider.onEvent("Change",setOutputVol)

}

if (cfg.gameAudioEnabled) {
	enableGameAudio()
}

toggleGameAudio(*) {
		(cfg.gameAudioEnabled := !cfg.gameAudioEnabled) 
			? enableGameAudio() 
			: disableGameAudio()
		
}

enableGameAudio() {
	ui.toggleGameAudio.Opt("Background" cfg.ThemeButtonOnColor)
	ui.toggleGameAudio.value := cfg.toggleOn 
	setVol(ui.SpeakerVolumeSlider.value)
	setVol(ui.MicVolumeSlider.value,"in")
	; setTimer(setOutputVol,10000)
	; setTimer(setInputVol,10000)	
}

disableGameAudio() {
	ui.toggleGameAudio.Opt("Background" cfg.ThemeButtonReadyColor)
	ui.toggleGameAudio.Value := cfg.toggleOff
	setTimer(setOutputVol,0)
	setTimer(setInputVol,0)
}

setVol(vol, audioIn := false) {
	;MsgBox(audioIn ? 1 : 0)
	Run("./Redist/nircmd.exe setvolume " (audioIn ? 1 : 0) " " (vol*.01*65535) " " (vol*.01*65535),,"Hide")
;	setvolume " audioIn ? 1 : 0 " (" vol*65535 ")",,"Hide")
}

setOutputVol(*) {
	if (cfg.gameAudioEnabled)
		setVol(ui.SpeakerVolumeSlider.value)
		cfg.speakerVolume := ui.speakerVolumeSlider.value`
}

setInputVol(*) {
	if (cfg.gameAudioEnabled)
		setVol(ui.MicVolumeSlider.value,"in")
		cfg.micVolume := ui.micVolumeSlider.value
}

ChooseAudioInput(*)
{
	global
	scGui := Gui(, "Select audio Input")


	loop
	{
		; For each loop iteration, try to get the corresponding device.
		try
			devName := SoundGetName(, devIndex := A_Index)
		catch
			break

		ui.dev%A_Index% := scGui.addButton(,devName)
		ui.dev%A_Index%.OnEvent("Click", audioInputSelected)
	}
	scGui.Show("NoActivate")
}

audioInputSelected(obj,idx,*)
{
	ui.micNameEdit.text := cfg.MicName := obj.text
	Run("./Redist/nircmd.exe setdefaultsounddevice " cfg.MicName)
	scGui.Destroy()
	MsgBox("Mic set to: " cfg.MicName)
}

ChooseAudioOutput(*)
{
	global
	scGui := Gui(, "Select audio output")


	loop
	{
		; For each loop iteration, try to get the corresponding device.
		try
			devName := SoundGetName(, devIndex := A_Index)
		catch
			break

		scGui.add("Button",,devName).OnEvent("Click", (*) => audioOutputSelected(A_Index, &audio, &scGui, &cfg,&ui))
	}
	scGui.Show("NoActivate")
}

audioOutputSelected(devName,&audio,&scGui,&cfg,&ui)
{
	cfg.MicName := devName
	Run("./Redist/nircmd.exe setdefaultsounddevice " cfg.MicName)
	scGui.Destroy()
	MsgBox("Mic set to: " cfg.MicName)
}

ChooseHeadsetOutput(*)
{
	global
	scGui := Gui(, "Select audio output")


	loop
	{
		; For each loop iteration, try to get the corresponding device.
		try
			devName := SoundGetName(, devIndex := A_Index)
		catch
			break

		scGui.add("Button",,devName).OnEvent("Click", (*) => headsetOutputSelected(A_Index, &audio, &scGui, &cfg,&ui))
	}
	scGui.Show("NoActivate")
}

headsetOutputSelected(devName,&audio,&scGui,&cfg,&ui)
{
	cfg.MicName := devName
	Run("./Redist/nircmd.exe setdefaultsounddevice " cfg.MicName)
	scGui.Destroy()
	MsgBox("Mic set to: " cfg.MicName)
}


