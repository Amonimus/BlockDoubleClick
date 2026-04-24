#Requires AutoHotkey v2.0
#SingleInstance
#Include "Utils.ahk"
#Include "Win32.ahk"

; ============ MAIN ============

block := False

~Esc::ExitApp

#HotIf block == True
*LButton:: {
	Main()
	double_click_time := DllCall("GetDoubleClickTime")
	if (A_TimeSincePriorHotkey AND double_click_time - A_TimeSincePriorHotkey > 0) {
		Sleep double_click_time - A_TimeSincePriorHotkey
	}
	Global block := False
	return
}
#HotIf block == False
~*LButton:: {
	if(GetKeyState("Ctrl")){
		Global block := True
	}
	
	Main()
	Sleep DllCall("GetDoubleClickTime")
	Global block := False
}

Main() {
	MouseGetPos(&mouseX, &mouseY, &hwnd, &hwnd_control)
	data := [
		"mouseX: " mouseX,
		"mouseY: " mouseY,
	]
	extend_array(data, GetHwndInfo(hwnd, hwnd_control))
	extend_array(data, GetSystemMetrics())
	extend_array(data, GetTitleBarInfo(hwnd))
	extend_array(data, GetWindowInfo(hwnd))
	ToolTip(join_str(data))
	SetTimer(ToolTip, -5000)
}