#Requires AutoHotkey v2.0
#SingleInstance
#Include "Utils.ahk"
#Include "Win32.ahk"

; ============ MAIN ============

; When True, the LMB hotkey is consuming, when False, the hotkey is passthrough.
block := False

; Kills the script on Esc press.
~Esc::ExitApp

#HotIf block == True
*LButton:: {
	; Mouse blocking. Some code can be run here, 
	data := Main()
	
	;Debug.
	;data_str := object_to_string(data)
	;ToolTip(join_str(data_str))
		
	; Lifts the block depending on how fast the second click was
	double_click_time := DllCall("GetDoubleClickTime")
	if (A_TimeSincePriorHotkey AND double_click_time - A_TimeSincePriorHotkey > 0) {
		Sleep (double_click_time - A_TimeSincePriorHotkey) * 2
	}
	Global block := False
	
	; The mouse signal is consumed and isn't passed to Windows
	return
}
#HotIf block == False
~*LButton:: {
	data := Main()
	
	;Debug.
	;data_str := object_to_string(data)
	;ToolTip(join_str(data_str))
		
	; Block condition
	if(data.ON_ICON == True){
		Global block := True
	}
	
	; Automatically lifts th block
	Sleep DllCall("GetDoubleClickTime")
	Global block := False
}

Main() {
	; Get mouse and the window under the mouse, coordinates are relative to the window.
	MouseGetPos(&mouseX, &mouseY, &hwnd, &hwnd_control)
	data := {
		mouseX: mouseX,
		mouseY: mouseY,
	}
	
	if(hwnd){
		; Check if this is a window
		if !DllCall("IsWindow", "Ptr", hwnd) {
			data.ON_ICON := False
			return data
		}
		
		; Check if it's visible
		if !DllCall("IsWindowVisible", "Ptr", hwnd) {
			data.ON_ICON := False
			return data
		}
		
		; Collect data.
		extend_object(data, GetHwndInfo(hwnd, hwnd_control))
		;extend_object(data, GetSystemMetrics())
		;extend_object(data, GetTitleBarInfo(hwnd))
		;extend_object(data, GetWindowInfo(hwnd))
		
		; Check if not the dekstop
		if (data.class == "Progman" || data.class == "WorkerW" || data.class == "Shell_TrayWnd") {
			data.ON_ICON := False
			return data
		}
	
		if(data.mouseX <= 48 and data.mouseY <= 48){
			data.ON_ICON := True
		} else {
			data.ON_ICON := False
		}
	
		;Turns out calculating absolute coordinates was unnecessary
		;if (data.mouseX > data.rcClientLeft AND data.mouseX < data.rcClientLeft + 40 AND data.mouseY > data.rcClientTop AND data.mouseY < data.rcClientTop + 40) {
		;	data.ON_ICON := True
		;} else {
		;	data.ON_ICON := False
		;}
	} else {
		ToolTip("Failed to get window")
		SetTimer(ToolTip, -5000)
	}
		
	return data
}