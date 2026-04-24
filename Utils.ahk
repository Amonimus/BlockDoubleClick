#Requires AutoHotkey v2.0

if (A_ScriptName = "Utils.ahk") {
	MsgBox "This script is meant to be included, not run directly."
	ExitApp
}

join_str(strArr){
	str := ""
	Loop strArr.Length
		if(A_Index==1) {
			str .= strArr[A_Index]
		} else {
			str .= "`n" . strArr[A_Index]
		}
	return str
}

extend_array(arr1, arr2){
	Loop arr2.Length
		arr1.Push(arr2[A_Index])
}

get_array_sum(intArr){
	sum := 0
	Loop intArr.Length
		sum += intArr[A_Index]
	return sum
}

set_var(struct, var, val) {
	struct.%var% := val
}