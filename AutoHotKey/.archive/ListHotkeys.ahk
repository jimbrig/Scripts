; !q::
; HSList =
; (
; + = Shift
; # = Win
; ! = Alt
; ^ = Strg

; ~ = native Funktion des Hotkeys bleibt erhalten
; $ = Send-Kommando führt den eigenen Hotkey nicht aus
; )
; MouseGetPos, Px, Py
; ToolTip, %HSList%, % Px - 125, % Py - 125
; SetTimer, RemoveTlTip, 5000
; return
; RemoveTlTip:
; SetTimer, RemoveTlTip, Off
; ToolTip
; return

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
