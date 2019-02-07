; gdi+ ahk analogue clock example written by derRaphael
; Parts based on examples from Tic's GDI+ Tutorials and of course on his GDIP.ahk
 
; This code has been licensed under the terms of EUPL 1.0
 #NoTrayIcon
#SingleInstance, Force
#NoEnv
SetBatchLines, -1
 
;RegWrite, REG_DWORD, HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer, HideSCAHealth , 1

 ControlGet, hClock, Hwnd,, TrayClockWClass1, ahk_class Shell_TrayWnd
 hShell := DllCall("GetAncestor", "UInt", hClock, "UInt", 2)
ControlGet, hTray, Hwnd,, TrayNotifyWnd1, ahk_class Shell_TrayWnd
WinHide, ahk_id %hClock%
DllCall("UpdateWindow", "UInt", hTray)
DllCall("SendMessage", "UInt", hShell, "UInt", 0x5, "UInt", 0, "UInt", 0x0)

; Uncomment if Gdip.ahk is not in your standard library
#Include, Gdip.ahk
 
If !pToken := Gdip_Startup()
{
   MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
   ExitApp
}
OnExit, Exit
 
 ShowClock:
SysGet, MonitorPrimary, MonitorPrimary
SysGet, WA, MonitorWorkArea, %MonitorPrimary%
WAWidth := WARight-WALeft
WAHeight := WABottom-WATop
 
;Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
Gui, 1: Show, NA
WinSet, ExStyle, +0x20, % "ahk_pid " . DllCall("GetCurrentProcessId")
hwnd1 := WinExist()
 
ClockDiameter := 180
Width := Height := ClockDiameter + 2         ; make width and height slightly bigger to avoid cut away edges
CenterX := CenterY := floor(ClockDiameter/2) ; Center x
 
; Prepare our pGraphic so we have a 'canvas' to work upon
   hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC()
   obm := SelectObject(hdc, hbm), G := Gdip_GraphicsFromHDC(hdc)
   Gdip_SetSmoothingMode(G, 4)
 
; Draw outer circle
   Diameter := ClockDiameter
   pBrush := Gdip_BrushCreateSolid(0x66000080)
   ;Gdip_FillEllipse(G, pBrush, CenterX-(Diameter//2), CenterY-(Diameter//2),Diameter, Diameter)
   Gdip_DeleteBrush(pBrush)

   Diameter := ClockDiameter
   pBrush := Gdip_BrushCreateSolid(0x88FFFFFF)
   Gdip_FillEllipse(G, pBrush, CenterX-(Diameter//2)+7, CenterY-(Diameter//2)+7,Diameter-15, Diameter-15)
   Gdip_DeleteBrush(pBrush)
 
; Draw inner circle
   Diameter := ceil(ClockDiameter - ClockDiameter*0.08)  ; inner circle is 8 % smaller than clock's diameter
   pBrush := Gdip_BrushCreateSolid(0x80000080)
   ;Gdip_FillEllipse(G, pBrush, CenterX-(Diameter//2), CenterY-(Diameter//2),Diameter, Diameter)
   Gdip_DeleteBrush(pBrush)
 
; Draw Second Marks
   R1 := Diameter//2-1                        ; outer position
   R2 := Diameter//2-1-ceil(Diameter//2*0.05) ; inner position
   Items := 60                                ; we have 60 seconds
   pPen := Gdip_CreatePen(0xff0000a0, floor((ClockDiameter/100)*1.2)) ; 1.2 % of total diameter is our pen width
   GoSub, DrawClockMarks
   Gdip_DeletePen(pPen)
 
; Draw Hour Marks
   R1 := Diameter//2-1                       ; outer position
   R2 := Diameter//2-1-ceil(Diameter//2*0.1) ; inner position
   Items := 12                               ; we have 12 hours
   pPen := Gdip_CreatePen(0xc0000080, ceil((ClockDiameter//100)*2.3)) ; 2.3 % of total diameter is our pen width
   GoSub, DrawClockMarks
   Gdip_DeletePen(pPen)

   ; Draw Hour Marks 2
   R1 := Diameter//2-1                       ; outer position
   R2 := Diameter//2-1-ceil(Diameter//2*0.15) ; inner position
   Items := 4                               ; we have 12 hours
   pPen := Gdip_CreatePen(0xc000F0F0, ceil((ClockDiameter//100)*3.4)) ; 2.3 % of total diameter is our pen width
   GoSub, DrawClockMarks
   Gdip_DeletePen(pPen)
 
   ; The OnMessage will let us drag the clock
   OnMessage(0x201, "WM_LBUTTONDOWN")
   ;UpdateLayeredWindow(hwnd1, hdc, WALeft+((WAWidth-Width)//2), WATop+((WAHeight-Height)//2), Width, Height)
      UpdateLayeredWindow(hwnd1, hdc, (WALeft+WAWidth-Width), (WATop+WAHeight-Height), Width, Height)
   SetTimer, sec, 1000
 
sec:
; prepare to empty previously drawn stuff
   Gdip_SetSmoothingMode(G, 1)   ; turn off aliasing
   Gdip_SetCompositingMode(G, 1) ; set to overdraw
 
; delete previous graphic and redraw background
   Diameter := ceil(ClockDiameter - ClockDiameter*0.18)  ; 18 % less than clock's outer diameter
 
   ; delete whatever has been drawn here
   pBrush := Gdip_BrushCreateSolid(0x00000000) ; fully transparent brush 'eraser'
   Gdip_FillEllipse(G, pBrush, CenterX-(Diameter//2), CenterY-(Diameter//2),Diameter, Diameter)
   Gdip_DeleteBrush(pBrush)
 
   Gdip_SetCompositingMode(G, 0) ; switch off overdraw
   pBrush := Gdip_BrushCreateSolid(0x66000080)
   ;Gdip_FillEllipse(G, pBrush, CenterX-(Diameter//2), CenterY-(Diameter//2),Diameter, Diameter)
   Gdip_DeleteBrush(pBrush)
   ;pBrush := Gdip_BrushCreateSolid(0x80000080)
if(WhiteInnerBackground)
   pBrush := Gdip_BrushCreateSolid(0x80ffffff) ; Inner white background
else
   pBrush := Gdip_BrushCreateSolid(0x00ffffff) ;
   Gdip_FillEllipse(G, pBrush, CenterX-(Diameter//2), CenterY-(Diameter//2),Diameter, Diameter)
   Gdip_DeleteBrush(pBrush)
 
; Draw HoursPointer
   Gdip_SetSmoothingMode(G, 4)   ; turn on antialiasing
   t := A_Hour*360//12 + (A_Min*360//60)//12 +90 
   R1 := ClockDiameter//2-ceil((ClockDiameter//2)*0.5) ; outer position
   FormatTime, TimeString,, HHmm
If (( ( TimeString >= 1300 and TimeString <= 1359 ) || ( TimeString >= 2000 and TimeString <= 2059 ) || ( TimeString >= 2200 || TimeString <= 59 ) || ( TimeString >= 700 and TimeString <= 759 ) ) && !TimerTimeString)
   pPen := Gdip_CreatePen(0xa0800000, floor((ClockDiameter/100)*3.5))
else
   pPen := Gdip_CreatePen(0xa0000080, floor((ClockDiameter/100)*3.5))
   Gdip_DrawLine(G, pPen, CenterX, CenterY
      , ceil(CenterX - (R1 * Cos(t * Atan(1) * 4 / 180)))
      , ceil(CenterY - (R1 * Sin(t * Atan(1) * 4 / 180))))
   Gdip_DeletePen(pPen)
 
; Draw MinutesPointer
   t := A_Min*360//60+90 
   If(TimerTimeString)
   {
      TimerTimeString:=SubStr("0000" . TimerTimeString, -4)
      TimerTime:=SubStr(TimerTimeString, -1, 2) + SubStr(TimerTimeString, -3, 2)*60
      CurrentTimeString:=SubStr("0000" . TimeString, -4)
      CurrentTime:=SubStr(CurrentTimeString, -1, 2) + SubStr(CurrentTimeString, -3, 2)*60
      if((TimerTime<=CurrentTime))
      {
         if((CurrentTime-TimerTime<=5))
         {
            if(TimerTime=CurrentTime)
            {
               if(mod(A_Sec, 2)=0)
                  pPen := Gdip_CreatePen(0xa0800000, floor((ClockDiameter/100)*2.7))
               else
                  pPen := Gdip_CreatePen(0xa0F0F000, floor((ClockDiameter/100)*2.7))
            }
            else
            {
               pPen := Gdip_CreatePen(0xa0800000, floor((ClockDiameter/100)*2.7))
               MinuteMark:=SubStr(TimerTimeString, -1, 2)
               GoSub, DrawClockMark
               pPen := Gdip_CreatePen(0xa0000080, floor((ClockDiameter/100)*2.7))
            }
         }
         else
         {
            TimerTimeString:=0
            SetTimer, sec, Off
            GoSub, ShowClock
         }
      }
      else If(TimerTime-CurrentTime<=5)
      {
         pPen := Gdip_CreatePen(0xa0800000, floor((ClockDiameter/100)*2.7))
      }
      else If(TimerTime-CurrentTime<=10)
      {
         pPen := Gdip_CreatePen(0xa0F0F000, floor((ClockDiameter/100)*2.7))
      }
      else If(TimerTime-CurrentTime<=60)
      {
         pPen := Gdip_CreatePen(0xa0008000, floor((ClockDiameter/100)*2.7))
      }
      else
      {
         pPen := Gdip_CreatePen(0xa0005050, floor((ClockDiameter/100)*2.7))
      }
   }
   else
      pPen := Gdip_CreatePen(0xa0000080, floor((ClockDiameter/100)*2.7))
   R1 := ClockDiameter//2-ceil((ClockDiameter//2)*0.25) ; outer position
   Gdip_DrawLine(G, pPen, CenterX, CenterY
      , ceil(CenterX - (R1 * Cos(t * Atan(1) * 4 / 180)))
      , ceil(CenterY - (R1 * Sin(t * Atan(1) * 4 / 180))))
   Gdip_DeletePen(pPen)
 
; Draw SecondsPointer
   t := A_Sec*360//60+90 
   R1 := ClockDiameter//2-ceil((ClockDiameter//2)*0.2) ; outer position
   pPen := Gdip_CreatePen(0xa00000FF, floor((ClockDiameter/100)*1.2))
   ; Gdip_DrawLine(G, pPen, CenterX, CenterY
   ;    , ceil(CenterX - (R1 * Cos(t * Atan(1) * 4 / 180)))
   ;    , ceil(CenterY - (R1 * Sin(t * Atan(1) * 4 / 180))))
   Gdip_DeletePen(pPen)
 
   UpdateLayeredWindow(hwnd1, hdc) ;, xPos, yPos, ClockDiameter, ClockDiameter)
   Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
return
 
DrawClockMarks:
   Loop, % Items
      Gdip_DrawLine(G, pPen
         , CenterX - ceil(R1 * Cos(((a_index-1)*360//Items) * Atan(1) * 4 / 180))
         , CenterY - ceil(R1 * Sin(((a_index-1)*360//Items) * Atan(1) * 4 / 180))
         , CenterX - ceil(R2 * Cos(((a_index-1)*360//Items) * Atan(1) * 4 / 180))
         , CenterY - ceil(R2 * Sin(((a_index-1)*360//Items) * Atan(1) * 4 / 180)) )
return

DrawClockMark:
   MinuteMark2:=MinuteMark+15
   R1 := Diameter//2-1+10.5                        ; outer position
   R2 := Diameter//2-1+10.5-ceil(Diameter//2*0.15) ; inner position
      Gdip_DrawLine(G, pPen
         , CenterX - ceil(R1 * Cos(((MinuteMark2)*360//60) * Atan(1) * 4 / 180))
         , CenterY - ceil(R1 * Sin(((MinuteMark2)*360//60) * Atan(1) * 4 / 180))
         , CenterX - ceil(R2 * Cos(((MinuteMark2)*360//60) * Atan(1) * 4 / 180))
         , CenterY - ceil(R2 * Sin(((MinuteMark2)*360//60) * Atan(1) * 4 / 180)) )
return
 
WM_LBUTTONDOWN() {
   PostMessage, 0xA1, 2
   return
}
 
;esc::
Exit:
   GoSub, RestoreClock
   SelectObject(hdc, obm)
   DeleteObject(hbm)
   DeleteDC(hdc)
   Gdip_DeleteGraphics(G)
   Gdip_Shutdown(pToken)
   ExitApp
Return

RestoreClock:
WinShow, ahk_id %hClock%
DllCall("SendMessage", "UInt", hShell, "UInt", 0x5, "UInt", 0, "UInt", 0x0)
return

^#+t::
GoSub, SetTimerTimeString
return

^#+w::
WhiteInnerBackground:=!WhiteInnerBackground
GoSub, ShowClock
return

SetTimerTimeString:
InputBox, TimerTimeString, Timer Time String, , , 400, 100
If ErrorLevel
        Return
if(TimerTimeString="")
{
   GoSub, ShowClock
   TimerTimeString:=0
}
if (!(TimerTimeString is number))
   TimerTimeString:=0
return