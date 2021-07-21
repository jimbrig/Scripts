#NoEnv
#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

; #### Master Script

; Global Shortcuts for Programs
Run, "Global-Shortcuts\Obsidian-Global-Shortcut.ahk"
Run, "Global-Shortcuts\Todoist-Global-Shortcut.ahk"
Run, "Global-Shortcuts\Keeper-Global-Shortcut.ahk"

; Custom Scripts
Run, "Custom\Custom-Text-Expanders.ahk"
Run, "Custom\Toggle-Hidden-Files-and-Folders.ahk"

; HotKeyHelp - List and Configure AHK Scripts/Hotkeys
Run, "HotKeyHelp\HotkeyHelp.ahk"

; ### Archives
; Run, ListHotKeys.ahk

; WinClip
; Run, "WinClip\WinClip.ahk"
