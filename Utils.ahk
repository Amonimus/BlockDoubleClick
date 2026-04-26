#Requires AutoHotkey v2.0

; Prevents the cript from running on its own.
if (A_ScriptName = "Utils.ahk") {
	MsgBox "This script is meant to be included, not run directly."
	ExitApp
}

; Accepts an array of String, returns a String with all elements separated by a newline.
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

; Appends one array to the other.
extend_array(arr1, arr2){
	Loop arr2.Length
		arr1.Push(arr2[A_Index])
}

; Gives a sum of the Array of integers.
get_array_sum(intArr){
	sum := 0
	Loop intArr.Length
		sum += intArr[A_Index]
	return sum
}

; Sets an object's specified property to be the specified value.
set_var(struct, var, val) {
	struct.%var% := val
}

; Appends one object to the other.
extend_object(struct1, struct2){
	For key, value in struct2.OwnProps()
		set_var(struct1, key, value)
}

; Makes an array of object's properties.
object_to_string(struct){
	arr := []
	For key, value in struct.OwnProps()
		arr.Push(key ": " value)
	return arr
}