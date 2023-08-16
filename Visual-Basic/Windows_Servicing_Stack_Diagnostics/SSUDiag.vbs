'-------------------------------------------------------------------------------------
'SSUDiag.vbs v1.1 - Written by Ramesh Srinivasan for Winhelponline.com
'Gathers information about the latest Servicing Stack files installed on the computer.
'The log is written to %temp%\ssudiag.txt
'Created: Jan 21, 2023
'Updated: Jan 26, 2023 - Uses PowerShell to calculate Hashes
'More info: https://www.winhelponline.com/blog/servicing-stack-diagnosis-dism-sfc/
'-------------------------------------------------------------------------------------

Option Explicit

If WScript.Arguments.length = 0 Then
   Dim objShell: Set objShell = CreateObject("Shell.Application")
   objShell.ShellExecute "wscript.exe", Chr(34) & _
   WScript.ScriptFullName & Chr(34) & " uac", "", "runas", 1
Else
   
   Const HKEY_LOCAL_MACHINE = &H80000002
   Const ForReading = 1
   Const ForWriting = 2
   Const ForAppending = 8
   
   Dim WshShell, objFSO, sLog, f, sWinDir, i, sStackVer, sStackFldr, c, t, sLine, sAll
   Dim oReg, strKeyPath, arrValueNames, arrValueTypes, sHashLog, sCmd, arrLines, strText
   Dim objFile, objFolder, colFiles, arrFolders, fol
   Dim arrFiles, fn, sVal, sLastErr, sRegInfo, sDFlags
   
   Set WshShell = CreateObject ("WScript.Shell")
   Set objFSO = CreateObject ("Scripting.FileSystemObject")
   
   sLog = WshShell.ExpandEnvironmentStrings("%TEMP%") & "\ssudiag.txt"
   sHashLog = WshShell.ExpandEnvironmentStrings("%TEMP%") & "\hash.txt"
   
   Set f = objFSO.CreateTextFile(sLog, 1)
   f.WriteLine "SERVICING STACK DIAGNOSTICS"
   f.WriteLine String(134,"-")
   
   sWinDir = wshshell.ExpandEnvironmentStrings("%SYSTEMROOT%") & "\"
   sStackVer = 0
   c = vbCrLf
   t = vbTab
   
   'Get current servicing stack version from the Registry.
   Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & _ 
   "." & "\root\default:StdRegProv")
   strKeyPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Version"
   oReg.EnumValues HKEY_LOCAL_MACHINE, strKeyPath,_
   arrValueNames, arrValueTypes
   For i = 0 To UBound(arrValueNames)
      If Replace(arrValueNames(i), ".", "") > sStackVer Then sStackVer = arrValueNames(i)
   Next
   
   On Error Resume Next
   sStackFldr = WshShell.RegRead ("HKLM\" & strKeyPath & "\" & sStackVer)
   On Error GoTo 0
   
   sStackFldr = wshshell.ExpandEnvironmentStrings(sStackFldr)
   
   arrFolders = Array ( _
   sStackFldr, _
   sWinDir & "Servicing", _
   sWinDir & "System32\Dism" _
   )
   
   f.Writeline "Stack Version: " & sStackVer
   f.WriteLine "Stack Path: " & sStackFldr
   f.WriteLine String(134,"-")
   
   For Each fol In arrFolders
      Call GetFileInfo(fol)	
      f.WriteLine "Modules in [" & fol & "] (" & (colFiles.Count) & " Files)"
      f.WriteLine String(134,"-")
      '      f.WriteLine "Filename" & t & t & t & _
      '      "Modified" & t & t & t & "Version"
      
      f.WriteLine "Filename" & t & t & t & _
      "Modified" & t & t & "Version"& t & t & t & "Size (bytes)"
      
      f.WriteLine String(134,"-")
      f.Write sAll
      f.WriteLine String(134,"-")
      
      Call GetFileHash(fol)
      f.WriteLine String(134,"-")
      
   Next
   
   Sub GetFileInfo(sFldr)
      sAll=""
      Set objFolder = objFSO.GetFolder(sFldr)
      Set colFiles = objFolder.Files
      For Each objFile In colFiles
         sAll = sAll & objFile.Name & Space(30 - Len(objFile.Name)) & _
         t & objFile.DateLastModified & _
         t & objFSO.GetFileVersion(objFile) & Space(15 - Len(objFSO.GetFileVersion(objFile))) & _
         t & t & Space(11 - Len(FormatNumber(objFile.Size, 0))) & FormatNumber(objFile.Size, 0) & c
      Next
   End Sub
   
   Sub GetFileHash(sFldr)
      If objFSO.FileExists (sHashLog) Then objFSO.DeleteFile sHashLog, 1
      sCmd = "powershell -WindowStyle Minimized -command GCI -Path " & sFldr & _
      " | get-filehash -algorithm SHA256 | select hash, path | ft | " & _
      "out-file -Width 512 $env:TEMP\hash.txt  -Encoding UTF8"
      
      WshShell.Run sCmd, 0, 1
      
      Set f = objFSO.OpenTextFile(sHashLog, ForReading)
      strText = f.ReadAll
      f.Close
      arrLines = Split(strText, c)   
      
      'Write File Hashes to the log file
      Set f = objFSO.OpenTextFile(sLog, ForAppending)
      sAll = ""
      f.WriteLine "File Hash [SHA256]  - " & sFldr
      f.WriteLine String(134,"-")
      
      arrLines = Split(strText, c)
      Dim line, arrSplit
      For Each line In arrLines
         If InStr(line, ":") > 0 Then
            line = Replace(line, sFldr & "\", "")
            arrSplit = Split(line, " ")
            line = Trim(arrSplit(1)) & Space(30 - Len(arrSplit(1))) & t & Trim(arrSplit(0))
            sAll = sAll & line & c
         End If
      Next
      f.WriteLine sAll
   End Sub
   
   'Check for IFEO entries   
   arrFiles = Array ( _ 
   "dismhost.exe", _
   "trustedinstaller.exe", _
   "tiworker.exe", _
   "dism.exe", _
   "TiFileFetcher.exe" _
   )
   
   For Each fn In arrFiles
      
      On Error Resume Next
      sVal = WshShell.RegRead _
      ("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\" & _
      fn & "\Debugger")
      
      sLastErr = err.number
      err.Clear
      On Error GoTo 0
      
      If hex(sLastErr) <> "80070002" Then
         sDFlags = 1
         sRegInfo = sRegInfo & c & fn & " (IFEO points to) => " & sVal         
      End If
   Next 
   
   If sDFlags = 0 Then
      sRegInfo = "No IFEO Overrides present for core servicing files. Good!"
   Else
      sRegInfo = "REGISTRY ISSUES" & c & String(134,"-") & c & _
      "::IMPORTANT:: Some IFEO entries are present. Please remove them!!" & c & sRegInfo & c & _ 
      string(134,"-")
   End If
   
   f.WriteLine "REGISTRY: " & sRegInfo
   f.WriteLine string(134,"-")
   f.Close
   
   WshShell.Run "cmd.exe /c ver >> " & sLog, 0, 1
   WshShell.Run "cmd.exe /c wmic qfe get hotfixid,installedon | sort >> " & sLog, 0, 1
   
   If objFSO.FileExists (sHashLog) Then objFSO.DeleteFile sHashLog, 1
   Set f = objFSO.OpenTextFile(sLog, ForAppending)
   
   f.WriteLine string(134,"-")
   f.WriteLine "LOADED MODULES (Before starting DISM SCANHEALTH) at " & Now
   f.WriteLine string(134,"-")
   f.WriteLine t & "See [%TEMP%\modules1.txt]"
   WshShell.Run "cmd /c tasklist.exe /m /fo list >%temp%\modules1.txt", 0, 1
   WshShell.Run "dism.exe /online /cleanup-image /scanhealth", 1, 0
   WScript.Sleep 10000
   f.WriteLine string(134,"-")
   f.WriteLine "LOADED MODULES (During DISM SCANHEALTH) at " & Now
   f.WriteLine string(134,"-")
   f.WriteLine t & "See [%TEMP%\modules2.txt]"
   WshShell.Run "cmd /c tasklist.exe /m /fo list >%temp%\modules2.txt", 0, 1
   f.WriteLine string(62,"-") & "END OF LOG" & string(62,"-")
   f.Close
   WshShell.Run sLog
   
   Set WshShell = Nothing
   Set objFSO = Nothing
   Set oReg = Nothing
End If