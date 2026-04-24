#Requires AutoHotkey v2.0
#Include "Utils.ahk"

if (A_ScriptName = "Win32.ahk") {
	MsgBox "This script is meant to be included, not run directly."
	ExitApp
}

Class TypedVariable {
	Static get_buffer_size() {
		sum := 0
		Loop This.variables.Length
			sum += This.variables[A_Index].var_type.size
		return sum
	}
}
Class NamedVariable {
	__New(name, var_type){
		This.name := name
		This.var_type := var_type
	}
}

; ============ Variables ============

Class TypeInt extends TypedVariable {
	Static name := "INT"
	Static num_type := "Int"
	Static size := 4
}
Class TypeUint extends TypedVariable {
	Static name := "UINT"
	Static num_type := "UInt"
	Static size := 4
}
Class TypeUshort extends TypedVariable {
	Static name := "USHORT"
	Static num_type := "UShort"
	Static size := 2
}

Class TypeWord extends TypeUshort {
	Static name := "WORD"
}
Class TypeDWord extends TypeUint {
	Static name := "DWORD"
}
Class TypeLong extends TypeInt {
	Static name := "LONG"
}
Class TypeAtom extends TypeUshort {
	Static name := "ATOM"
}

Class TypeRect extends TypedVariable {
	Static name := "RECT"
	Static variables := [
		NamedVariable("left", TypeLong),
		NamedVariable("top", TypeLong),
		NamedVariable("right", TypeLong),
		NamedVariable("bottom", TypeLong),
	]
	Static size := This.get_buffer_size()
}

Class TypeTitleBarInfo extends TypedVariable {
	Static name := "TITLEBARINFO"
	Static variables := [
		NamedVariable("cbSize", TypeDWord),
		NamedVariable("rcTitleBar", TypeRect),
		NamedVariable("rgstate", TypeDWord),
	]
	Static size := This.get_buffer_size()
}

Class TypeWindowInfo extends TypedVariable {
	Static name := "WINDOWINFO"
	Static variables := [
		NamedVariable("cbSize", TypeDWord),
		NamedVariable("rcWindow", TypeRect),
		NamedVariable("rcClient", TypeRect),
		NamedVariable("dwStyle", TypeDWord),
		NamedVariable("dwExStyle", TypeDWord),
		NamedVariable("dwWindowStatus", TypeDWord),
		NamedVariable("cxWindowBorders", TypeUint),
		NamedVariable("cyWindowBorders", TypeUint),
		NamedVariable("atomWindowType", TypeAtom),
		NamedVariable("wCreatorVersion", TypeWord),
	]
	Static size := This.get_buffer_size()
}


; ============ Win32 API ============

NewUIntBuffer(size){
	uint_buffer := Buffer(size)
	NumPut("UInt", size, uint_buffer, 0)
	return uint_buffer
}

addNextBufferVariableToStruct(struct, buff, offset, var) {
	val := NumGet(buff, offset, var.var_type.num_type)
	set_var(struct, var.name, val)
	return var.var_type.size
}

injectStruct(parent_struct, buff, offset, var){
	struct := {}
	offset := injectLoop(struct, buff, offset, var.var_type)
	parent_struct.%var.name% := struct
	return offset
}

injectLoop(struct, buff, offset, var_type){
	Loop var_type.variables.Length {
		var := var_type.variables[A_Index]
		if(HasProp(var.var_type, "variables")){
			offset := injectStruct(struct, buff, offset, var)
		} else {
			offset += addNextBufferVariableToStruct(struct, buff, offset, var)
		}
	}
	return offset
}

FetchWin32Object(dll_call, hwnd, var_type) {
	buff := NewUIntBuffer(var_type.size)
	result := DllCall(dll_call, "Ptr", hwnd, "Ptr", buff)
	if(result) {
		struct := {}
		injectLoop(struct, buff, 0, var_type)
		return struct
	}
}

; ============ Data fetchers ============

GetHwndInfo(hwnd, hwnd_control){
	if (hwnd) {
		hwnd_title := WinGetTitle("ahk_id " hwnd)
		hwnd_class := WinGetClass("ahk_id " hwnd)
		processName := WinGetProcessName("ahk_id " hwnd)
		
		data := [
			"hwnd: " hwnd,
			"title: " hwnd_title,
			"control: " hwnd_control,
			"class: " hwnd_class,
			"process: " processName,
		]
		return data
	} else {
		return []
	}
}

GetSystemMetrics(){
	titleBarHeight := DllCall("GetSystemMetrics", "Int", SM_CYSIZE := 31) ; The height of a title bar
	borderWidth := DllCall("GetSystemMetrics", "Int", SM_CYBORDER := 6) ; The width of the horizontal border
	padding := DllCall("GetSystemMetrics", "Int", SM_CXPADDEDBORDER := 92) ; The amount of border padding
	iconSize := DllCall("GetSystemMetrics", "Int", SM_CXSMICON := 49) ; The system small width of an icon
	
	data := [
		"titleBarHeight: " titleBarHeight,
		"borderWidth: " borderWidth,
		"padding: " padding,
		"iconSize: " iconSize
	]
	return data
}

GetTitleBarInfo(hwnd){
	titlebar_info := FetchWin32Object("GetTitleBarInfo", hwnd, TypeTitleBarInfo)
	if(titlebar_info) {
		data := [
			"tbLeft: " titlebar_info.rcTitleBar.left,
			"tbTop: " titlebar_info.rcTitleBar.top,
			"tbRight: " titlebar_info.rcTitleBar.right,
			"tbBottom: " titlebar_info.rcTitleBar.bottom,
		]
		return data
	} else {
		return []
	}
}

GetWindowInfo(hwnd){
	window_info := FetchWin32Object("GetWindowInfo", hwnd, TypeWindowInfo)
	if(window_info) {
		data := [
			"rcWindowLeft: " window_info.rcWindow.left,
			"rcWindowTop: " window_info.rcWindow.top,
			"rcWindowRight: " window_info.rcWindow.right,
			"rcWindowBottom: " window_info.rcWindow.bottom,
			"rcClientLeft: " window_info.rcClient.left,
			"rcClientTop: " window_info.rcClient.top,
			"rcClientRight: " window_info.rcClient.right,
			"rcClientBottom: " window_info.rcClient.bottom
		]
		return data
	} else {
		return []
	}
}

;GetStyle(hwnd) {
;	style := DllCall("GetWindowLong", "Ptr", hwnd, "Int", GWL_STYLE := -16)
;	ToolTip(style)
;}