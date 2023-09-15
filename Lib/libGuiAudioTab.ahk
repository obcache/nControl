;libGuiAudioTab

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir "/../nControl.ahk")
	Return
}

GuiAudioTab(&ui,&audio)
{
	ui.MainGuiTabs.UseTab("Audio")
	ui.MainGui.SetFont("s14 c00FFFF","Calibri")
	ButtonGameaudio := ui.MainGui.AddPicture("x15 y+10 w30 h30 section","./Img/button_ready.png")
	ui.MainGui.AddText("ys","Enable`t")
		
	ui.MainGui.AddText("x+15","Mode")
	ui.MainGui.SetFont("s12 cFF00FF","Calibri Bold")
	HiddenEdit := ui.MainGui.AddEdit("w0 backgroundF1F2F3","")
	
	audioModeDDL := ui.MainGui.Add("DDL","ys w150 BackgroundF1F2F3 AltSubmit Choose" cfg.Mode,["Speakers","Headset"])

	ui.MainGui.SetFont("s14 c00FFFF","Calibri")	
	ButtonSetMic := ui.MainGui.AddPicture("x15 y+10 w30 h30 section","./Img/button_ready.png")
	ButtonSetMic.OnEvent("Click",ChooseaudioInput)
	ui.MainGui.AddText("ys","Mic`t")
	ui.MainGui.SetFont("s12 cFF00FF","Calibri Bold")
	MicNameEdit	:= ui.MainGui.AddEdit("x+-7 ys w110 r1 BackgroundF1F2F3",cfg.MicName)
	ui.MainGui.SetFont("s14 c00FFFF","Calibri")
	ui.MainGui.AddText("","`t")
	ui.MainGui.AddText("x+40 ys","Volume")
	MicVolumeSlider := ui.MainGui.AddSlider("x+10 ys w150 AltSubmit Range0-100",cfg.MicVolume)

	ButtonSetSpeaker := ui.MainGui.AddPicture("xs y+-2 w30 h30 section","./Img/button_ready.png")
	ui.MainGui.AddText("ys","Speakers`t")
	ui.MainGui.SetFont("s12 cFF00FF","Calibri Bold")
	SpeakerNameEdit	:= ui.MainGui.AddEdit("x+-7 ys w110 r1 BackgroundF1F2F3",cfg.SpeakerName)
	ui.MainGui.SetFont("s14 c00FFFF","Calibri")
	ui.MainGui.AddText("","`t")
	ui.MainGui.AddText("x+40 ys","Volume")
	SpeakerVolumeSlider := ui.MainGui.AddSlider("x+10 ys w150 AltSubmit Range0-100",cfg.SpeakerVolume)

	ButtonSetHeadset := ui.MainGui.AddPicture("xs y+-2 w30 h30 section","./Img/button_ready.png")
	ui.MainGui.AddText("ys","Headset`t")
	ui.MainGui.SetFont("s12 cFF00FF","Calibri Bold")
	HeadsetNameEdit	:= ui.MainGui.AddEdit("x+-7 ys w110 r1 BackgroundF1F2F3",cfg.HeadsetName)
	ui.MainGui.SetFont("s14 c00FFFF","Calibri")
	ui.MainGui.AddText("","`t")
	ui.MainGui.AddText("x+40 ys","Volume")
	HeadsetVolumeSlider := ui.MainGui.AddSlider("x+10 ys-5 w150 AltSubmit Range0-100",cfg.HeadsetVolume)
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

		scGui.add("Button",,devName).OnEvent("Click", (*) => audioInputSelected(A_Index, &audio, &scGui))
	}
	scGui.Show("NoActivate")
}

audioInputSelected(devName,&audio,&scGui)
{
	cfg.MicName := devName
	Run("./Redist/nircmd.exe setdefaultsounddevice " cfg.MicName)
	scGui.Destroy()
	MsgBox("Mic set to: " cfg.MicName)
}