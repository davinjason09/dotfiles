#SingleInstance Force
#Requires AutoHotkey v2.0

; Run MemReduct
Send("^{F1}")

^+Esc::ExitApp()

; App Launcher
Lwin & Space::Send("^+{Space}")

~LWin::{
  LWinDown := true
  Send("{Blind}{vkE8}")
}

; YASB Power Menu
#^q::Send("^+q")

; YASB Wallpaper Menu
#^w::Send("^+w")

; Terminal
#Enter::RunWait("wezterm", , "Hide")

; Browser
#b::RunWait("zen", , "Hide")
