;libUtil
#SingleInstance
#Requires AutoHotKey v2.0+
#Warn All, Off

ConfigFile := (!A_Compiled ? FilesIn("../" A_ScriptFullPath,"*.ini"))[1] 
if (ConfigFile := FilesIn("../" A_ScriptFullPath,"*.ini")[1]) {
	SplitPath(ConfigFile,&selectedFilename,&selectedPath,&selectedExt,&selectedName,&selectedDrive)
	AppName := SelectedName
} 

if (InStr(A_LineFile,A_ScriptFullPath))
{
	Run(A_ScriptDir selectedPath "/" selectedFileName ".ahk")
	ExitApp
	Return
}

HasVal(haystack, needle) {
	if !(IsObject(haystack)) || (haystack.Length() = 0)
		return 0
	for index, value in haystack
		if (value = needle)
			return index
	return 0
}


; FilesIn(Path,Mask := "*.*")
; {
	; FileList := Array()
	; Loop %Path%\%Mask%
	; {
		; FileList.Push(%A_LoopFileName% 
	; Return FileList
; }

