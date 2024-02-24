A_FileVersion := "1.1.1.4"
/*
	CustomFont v2.01 (2018-8-25)
	---------------------------------------------------------
	Description: Load font from file or resource, without needed install to system.
	---------------------------------------------------------
	Useage Examples:

		* Load From File
			font1 := New CustomFont("ewatch.ttf")
			Gui, Font, s100, ewatch

		* Load From Resource
			Gui, Add, Text, HWNDhCtrl w400 h200, 12345
			font2 := New CustomFont("res:ewatch.ttf", "ewatch", 80) ; <- Add a res: prefix to the resource name.
			font2.ApplyTo(hCtrl)

		* The fonts will removed automatically when script exits.
		  To remove a font manually, just clear the variable (e.g. font1 := "").
*/
class CustomFont {
    static FR_PRIVATE := 0x10

    __New(FontFile, FontName := "", FontSize := 30) {
        if RegExMatch(FontFile, "i)res:\K.*", _FontFile)
            this.AddFromResource(_FontFile, FontName, FontSize)
        else
            this.AddFromFile(FontFile)
    }

    AddFromFile(FontFile) {
        if !FileExist(FontFile) {
            throw "Unable to find font file: " FontFile
        }
        DllCall("AddFontResourceEx", FontFile, this.FR_PRIVATE, 0)
        this.data := FontFile
    }

    AddFromResource(ResourceName, FontName, FontSize := 30) {
        static FW_NORMAL := 400, DEFAULT_CHARSET := 0x1

        nSize := this.ResRead(fData, ResourceName)
        fh := DllCall("AddFontMemResourceEx", &fData, nSize, 0, &nFonts)
        hFont := DllCall("CreateFont", FontSize, 0, 0, 0, FW_NORMAL, 0
            , 0, 0, DEFAULT_CHARSET, 0, 0, 0, 0, FontName)

        this.data := {fh: fh, hFont: hFont}
    }

    ApplyTo(hCtrl) {
        SendMessage(0x30, this.data.hFont, 1,, "ahk_id " hCtrl)
    }

    __Delete() {
        if IsObject(this.data) {
            DllCall("RemoveFontMemResourceEx", this.data.fh)
            DllCall("DeleteObject", this.data.hFont)
        } else {
            DllCall("RemoveFontResourceEx", this.data, this.FR_PRIVATE, 0)
        }
    }

    ResRead(ByRef Var, Key) {
        VarSetCapacity(Var, 128), VarSetCapacity(Var, 0)
        if !(A_IsCompiled) {
            FileGetSize nSize, %Key%
            FileRead Var, *c %Key%
            return nSize
        }

        if hMod := DllCall("GetModuleHandle", 0)
            if hRes := DllCall("FindResource", hMod, Key, 10)
                if hData := DllCall("LoadResource", hMod, hRes)
                    if pData := DllCall("LockResource", hData)
                        return VarSetCapacity(Var, nSize := DllCall("SizeofResource", hMod, hRes))
                            , DllCall("RtlMoveMemory", &Var, pData, nSize)
        return 0
    }
}
