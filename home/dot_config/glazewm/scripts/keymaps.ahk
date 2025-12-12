#SingleInstance Force
#Requires AutoHotkey v2.0

^+Esc:: {
  ExitApp
}

LauncherHotkey := "!{Space}"
Lwin & Space::Send(LauncherHotkey)

~LWin:: {
  LWinDown := true
  Send "{Blind}{vkE8}"
}

#^q:: {
  RunWait("yasbc toggle-widget powermenu --follow-focus", ,"Hide")
}

#^w:: {
  RunWait("yasbc toggle-widget wallpapers --follow-focus", , "Hide")
}

#Enter:: {
  RunWait("wezterm", , "Hide")
}

#b:: {
  RunWait("zen", , "Hide")
}
