
if (A_IsCompiled)
{
	CurrColor := A_Args.1
	X := A_Args.2
	Y := A_Args.3

} else {
	CurrColor := 0x000000
	X := (A_ScreenWidth/2)-150
	Y := (A_ScreenHeight/2)-100
}

CustomColors := [0x00FFFF,0xFF00FF,0xCCCCCC]  ; Red, Green, Blue

Gui, New, +HwndhWnd
Gui, Show, x%X% y%Y% w1 h1 Hide
Gui, +AlwaysOnTop
ExitApp, Format("{:i}", "0x" ChooseColor(CustomColors, hWnd)) 


; https://msdn.microsoft.com/en-us/library/windows/desktop/ms646912(v=vs.85).aspx
; https://docs.microsoft.com/en-us/windows/desktop/api/commdlg/ns-commdlg-tagchoosecolorw
; https://docs.microsoft.com/en-us/windows/desktop/gdi/colorref

ChooseColor(CustomRGBs := "", hWnd := 0x0, Flags := 0x3) {  ; CC_RGBINIT = 0x1, CC_FULLOPEN = 0x2
  
   Global CurrColor
   VarSetCapacity(CustomColors, 64, 0)
   NumPut(VarSetCapacity(CC, A_PtrSize = 8 ? 72 : 36, 0), CC, 0, "UInt")
   NumPut(hWnd ? hWnd : A_ScriptHwnd, CC, A_PtrSize = 8 ? 8 : 4, "Ptr")
   NumPut(COLORREF(CurrColor), CC, A_PtrSize = 8 ? 24 : 12, "UInt")
   NumPut(&CustomColors, CC, A_PtrSize = 8 ? 32 : 16, "Ptr")
   NumPut(Flags, CC, A_PtrSize = 8 ? 40 : 20, "UInt")
   if IsObject(CustomRGBs)
      for each, RGB in CustomRGBs
         NumPut(COLORREF(RGB), CustomColors, (each-1)*4, "UInt")
      Until each = 16
   if DllCall("comdlg32\ChooseColor", "Ptr", &CC, "Int") {
      if IsObject(CustomRGBs)
         Loop, 16
            CustomRGBs[A_Index] := COLORREF(NumGet(CustomColors, (A_Index-1)*4, "UInt"))
      Offset := A_PtrSize = 8 ? 24 : 12
	  if NumGet(CC, Offset, "UChar") == 0
		rColor := 1
	  else
		rColor := NumGet(CC, Offset, "UChar")
	  if NumGet(CC, Offset+1, "UChar") == 0
		gColor := 1
	  else
	    gColor := NumGet(CC, Offset+1, "UChar")
	  if NumGet(CC, Offset+2, "UChar") == 0
		bColor := 1
	  else
	    bColor := NumGet(CC, Offset+2, "UChar")
      Return Format("{:02X}{:02X}{:02X}", rColor, gColor, bColor)
   }
}

COLORREF(RGB) {  ; Switches red and blue
   Return ((RGB & 0xFF) << 16) + (RGB & 0xFF00) + ((RGB >> 16) & 0xFF)
}

/*
typedef struct tagCHOOSECOLOR {     Type  Offset  Length
  DWORD        lStructSize;         UInt   0      4
  HWND         hwndOwner;           Ptr    4/8    4/8
  HWND         hInstance;           Ptr    8/16   4/8
  COLORREF     rgbResult;           UInt  12/24   4
  COLORREF     *lpCustColors;       Ptr   16/32   4/8
  DWORD        Flags;               UInt  20/40   4
  LPARAM       lCustData;           Ptr   24/48   4/8
  LPCCHOOKPROC lpfnHook;            Ptr   28/56   4/8
  LPCWSTR      lpTemplateName;      Ptr   32/64   4/8
} CHOOSECOLORW, *LPCHOOSECOLORW;          36/72
*/