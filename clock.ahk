#singleinstance force

OnMessage(0x404, "AHK_NOTIFYICON")
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x204, "WM_RBUTTONDOWN")

Gui, +AlwaysOnTop +ToolWindow -SysMenu -Caption
Gui, Color, CCCCCC
Gui, Color, 000000
;Gui, Margin, 2, 2
;Gui, Font, c0000FF s12 tBold , verdana ;red
Gui, Margin, 0, 0
Gui, Font, c0000FF s12 tBold , Merryweather
;Gui, Font, c000000 s7 , verdana ;black
;Gui, Font, cFFFFFF s7 , verdana  ;white
Gui, Add, Text, vD y0 BackgroundTrans, %A_YYYY%-%A_MM%-%A_DD% %a_hour%:%a_min%:%a_sec%
Gui, Show, NoActivate x1850 y2,uptime  ; screen position here
;WinSet, TransColor, CCCCCC 255,uptime
SetTimer, RefreshD, 1000
return

RefreshD:
GuiControl, , D, %a_hour%:%a_min%
;%A_YYYY%-%A_MM%-%A_DD% %a_sec%
return

AHK_NOTIFYICON(wParam, lParam)
{
    global silentmode
    
    if (lParam = 0x202) ; WM_LBUTTONUP
	{
        controlClick,Button2,ahk_class Shell_TrayWnd
		Return 1
	}
    else if (lParam = 0x205) ; WM_RBUTTONUP
	{
        Menu, Tray, Show
        return 1
	}
    if (lParam = 513) {
        controlClick,Button2,ahk_class Shell_TrayWnd
        return 1
    }
}

WM_LBUTTONDOWN(wParam, lParam)
{
   controlClick,Button2,ahk_class Shell_TrayWnd
}

WM_RBUTTONDOWN(wParam, lParam)
{
   Menu, Tray, Show
}