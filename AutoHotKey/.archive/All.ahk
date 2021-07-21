
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.

;*******************************************************************************
; Extract a list of Hotstrings and Hotkeys from this script and display them
;*******************************************************************************
KeyList:
  AutoTrim,off
  Loop,Read,%A_ScriptFullPath%
  {
    Line=%A_LoopReadLine%
    ; Only show lines that contain double semicolons
    IfInString,Line,`;`;
    {
      StringLeft,C2,Line,2
      ; Insert blank or comment lines (start with double semicolon)
      IfEqual,C2,`;`;
      {
        StringTrimLeft,Desc,Line,2
        KeyList=%KeyList%%Desc%`n
        Continue
      }
      ; Insert Hotkeys and Hotstrings (must contain double colon)
      IfInString,Line,`:`:
        {
          ; Extract description (after last semicolon)
          StringSplit,Desc,Line,`;`:
          StringTrimLeft,Desc,Desc%Desc0%,0
          ; If description is blank, use command or hotstring text instead
          If Desc=
          {
            EnvSub,Desc0,2
            StringTrimLeft,Desc,Desc%Desc0%,0
          }
          ; Extract keys
          StringSplit,Keys,Line,`:
            ; Hotstrings (start with double colon)
          IfEqual,C2,`:`:
            {
              Keys=%Keys3%
              IfEqual,Desc,,SetEnv,Desc,%Keys5%
            }
            ; Hotkeys (start with anything else)
            Else
            {
              StringReplace,Keys,Keys1,#,Win-
              StringReplace,Keys,Keys,!,Alt-
              StringReplace,Keys,Keys,^,Ctrl-
              StringReplace,Keys,Keys,+,Shift-
              StringReplace,Keys,Keys,`;,
            }
            ; Add to the list
            ; Make keys 15 long with trailing spaces to keep the list neatly formatted

            Keys=%Keys% !
            StringLeft,Keys,Keys,15
            Desc=%Keys% %Desc%
            KeyList=%KeyList%%Desc%`n
            ; Keep track of longest line to set window width later
            StringLen,Len,Desc
            If Len > %MaxLen%
              MaxLen = %Len%
          }
        }
      }
      ; Now show the list
      EnvMult,MaxLen,8.0 ; pixel width of 1 character
      EnvAdd,MaxLen,20 ; + 2 x 10 pixel margins
      StringTrimRight,KeyList,KeyList,1
      ;  Sort, KeyList, P16 ; sort the comments
      Progress, M2 C00 ZH0 FS10 W%MaxLen%,%KeyList%,,Hotkeys and Hotstrings list,courier new
      KeyList=
      MaxLen=
      ;****************************************************
      ;Add the List to the AHK Menu
      ;****************************************************
      Menu,Tray,Add,Hot&keys list,KeyList
      Menu,Tray,Default,Hot&keys list
      Return

      ;****************************************************
      ;Add Hotkeys and Hotstrings Below
      ;****************************************************
      ;;  HotKeys

      ^Z:: ;;Show This List
        GoSub KeyList
        KeyWait, z
        Progress, off
      return

      ;;
      ;;  Global HotStrings (Will work in any program)
      ::me2::jimbrig1993@outlook.com ;;Quickly enter your email address.

      ^!+n::
        if WinExist("md - Obsidian")
        {
          WinActivate md - Obsidian
          Sleep, 200
          WinMaximize md - Obsidian
        }
        else
        {
          Run, obsidian://vault/Notebook
          Sleep, 1500
          WinMaximize md - Obsidian
        }
        ; close any previous note
        SendInput ^w
        ; txt size
        ; SendInput ^0
        ; SendInput ^{=}
        ; SendInput ^{=}
        ; SendInput ^{=}
        ; SendInput ^{=}
        ; SendInput ^{=}
        ; SendInput ^{=}
        ; SendInput ^{=}
        ; SendInput ^{=}
        ; ; make full screen
        ; SendInput {F11}

        ; check if left sidebar is open
        ; and close it
        ; (depends on my current theme!)
        ; CoordMode, Pixel
        ; PixelGetColor, color, 93, 115
        ; if (color = "0x000000") ; sidebar is closed
        ; {
        ;   ; nothing
        ; }
        ; else ; sidebar is open
        ; {
        ;   SendInput ^k
        ; }

        ; open new note
        SendInput ^n

        ; move cursor from name field into file itself
        Sleep, 400
        SendInput {Tab}
      return

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;
      ; CtrlAltShift + F 		- Obsidian: search all notes
      ;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      ^!+f::
        if WinExist("md - Obsidian")
        {
          WinActivate md - Obsidian
          Sleep, 200
          WinMaximize md - Obsidian
        }
        else
        {
          Run, C:\Users\jimbr\AppData\Local\Obsidian\Obsidian.exe
          Sleep, 1500
          WinMaximize md - Obsidian
        }
        SendInput ^w
        SendInput ^0
        SendInput ^{=}
        SendInput ^{=}
        SendInput ^{=}
        SendInput ^{=}
        SendInput ^+f
      return

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;
      ; CtrlAltShift + O 		- Obsidian: open note by name
      ;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      ^!+o::
        if WinExist("md - Obsidian")
        {
          WinActivate md - Obsidian
          Sleep, 200
          WinMaximize md - Obsidian
        }
        else
        {
          Run, C:\Users\jimbr\AppData\Local\Obsidian\Obsidian.exe
          Sleep, 1500
          WinMaximize md - Obsidian
        }
        SendInput ^w
        SendInput ^0
        SendInput ^{=}
        SendInput ^{=}
        SendInput ^{=}
        SendInput ^{=}
        SendInput {F11}

        CoordMode, Pixel
        PixelGetColor, color, 93, 115

        if (color = "0x000000") ; sidebar is closed
        {
          ; nothing
        }
        else ; sidebar is open
        {
          SendInput ^k
        }

        SendInput ^o
      return

      id := "com.todoist" ; AppUserModelid
      Title := "Todoist: To-Do List and Task Manager" ; Todoist window title

      #NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
      ; #Warn  ; Enable warnings to assist with detecting common errors.
      SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
      SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

      ;----------TODOIST global shortcuts WIN10 workaround----------
      ; *Created on 05/07/2017 by Rick Staa - Version 1.0.0*
      ;
      ; This AutoHotkey script adds global TODOIST shortcuts to WIN 10
      ;     - alt+ctrl+a (Add new task)
      ;     - alt+ctrl+t (open todoist)
      ;
      ; For questions, issues and suggestions go to: https://rickstaa.github.io/Todoist_Global_Shortcuts_WIN10/
      ;
      ;--INSTRUCTIONS--
      ; 1. Download AutoHotkey from https://autohotkey.com/
      ; 2. Install AutoHotkey
      ; 3. Download the Workaround.
      ; 4. Unzip the Workaround file
      ; 5. Go to Todoist_Global_Shortcuts_WIN10\TODOIST_AHK
      ; 6. Drag the "WinStoreAppLinks" folder into the "Program Files Shortcut"
      ; 7. Drag the "Todoist_global_Shortcuts.ahk" file into the "Startup Folder Shortcut
      ;
      ;--NOTES--
      ; Make sure AutoHotkey is running on startup

      ;--SCRIPT SETTINGS--
      WaitTime := 1100 ; Adjust this time if the script is not working on program startup

      ;!DO NOT CHANGE THE CODE AND SETTINGS BELOW UNLESS YOU KNOW WHAT YOU ARE DOING!
      SetTitleMatchMode, 2 ; IfWinExist settings
      DetectHiddenWindows, On

      ;--Shortkey code--

      ; Open todoist with alt+ctrl+t shortcut
      !^t::

        ; Since Windows apps are hard to run the install.vbs script first need to find your unique UserAppModelid
        if (id = ""){
          MsgBox, 4,, For the shortcuts to work you need to run the installer.vbs. Do you want to run it now?
            IfMsgBox, Yes
          try{
            Run, installer.vbs
          } catch{
            MsgBox, Hey there! It look like you either moved the AutoHotKeyScript file or you didn't install the todoist WINDOWS 10 app. Please download the workaround again and run the installer. This is needed since Windows Store Apps are hard to run due to the current Windows 10 Store Apps installation protocol.
          }
          Exit
        }

        Process, Exist, Todoist.Universal.exe
        IfWinNotExist, ahk_exe Todoist.Universal.exe
        {
          Run, shell:AppsFolder\%id%
          return
        }
        else
        {
          IfWinActive, %Title%
            WinMinimize, %Title%
          else
            Run, shell:AppsFolder\%id%
        }
      return

      ; Open todoist and add task shortcut
      !^a::

        ; Since Windows apps are hard to run the install.vbs script first need to find your unique UserAppModelid
        if (id = ""){
          MsgBox, 4,, For the shortcuts to work you need to run the installer.vbs. Do you want to run it now?
            IfMsgBox, Yes
          try{
            Run, installer.vbs
          } catch{
            MsgBox, Hey there! It look like you either moved the AutoHotKeyScript file or you didn't install the todoist WINDOWS 10 app. Please download the workaround again and run the installer. This is needed since Windows Store Apps are hard to run due to the current Windows 10 Store Apps installation protocol.
          }
          Exit
        }

        Process, Exist, Todoist.Universal.exe
        IfWinNotExist, ahk_exe Todoist.Universal.exe
        {
          RunWait, shell:AppsFolder\%id%
          sleep, WaitTime ; Waits for Todoist to load
          WinActivate, %Title%
          {
            send, {q}
            return
          }
        }
        else
        {
          IfWinActive, %Title%
            WinMinimize, %Title%
          else
            Run, shell:AppsFolder\%id%
          sleep, WaitTime ; Waits for Todoist to load
          WinActivate, %Title%
          {
            send, {q}
            return
          }
        }
      return

      ^F2::GoSub,CheckActiveWindow

      CheckActiveWindow:
        ID := WinExist("A")
        WinGetClass,Class, ahk_id %ID%
        WClasses := "CabinetWClass ExploreWClass"
        IfInString, WClasses, %Class%
          GoSub, Toggle_HiddenFiles_Display
      Return

      Toggle_HiddenFiles_Display:
        RootKey = HKEY_CURRENT_USER
        SubKey = Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced

        RegRead, HiddenFiles_Status, % RootKey, % SubKey, Hidden

        if HiddenFiles_Status = 2
          RegWrite, REG_DWORD, % RootKey, % SubKey, Hidden, 1
        else
          RegWrite, REG_DWORD, % RootKey, % SubKey, Hidden, 2
        PostMessage, 0x111, 41504,,, ahk_id %ID%
      Return
