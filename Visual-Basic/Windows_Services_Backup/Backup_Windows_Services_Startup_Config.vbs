'Description: This script backs up the Windows Services startup configuration to Batch & REG files.
'For Windows 10/11, Windows Server 2016/2019/2022
'Original Script From:
'https://gist.github.com/winhelponline/1c1acec1bbbc185eae5c23e8340c8966

Option Explicit

If WScript.Arguments.length = 0 Then
   Dim objShell : Set objShell = CreateObject("Shell.Application")
   objShell.ShellExecute "wscript.exe", Chr(34) & _
   WScript.ScriptFullName & Chr(34) & " uac", "", "runas", 1
Else
   Dim WshShell, objFSO, objFile, sNow, iSvcType, iStartupType, iSvcCnt, iPerUserSvcCnt
   Dim sREGFile, sBATFile, r, b, objWMIService, colListOfServices, objService, sSvcKey
   Dim sStartState, sSvcName, sSkippedSvc
   Set WshShell = CreateObject("Wscript.Shell")
   Set objFSO = Wscript.CreateObject("Scripting.FilesystemObject")
   Set objFile = objFSO.GetFile(WScript.ScriptFullName)

   'Set files names for REG and Batch files
   sNow = Year(Date) & Right("0" & Month(Date), 2) & Right("0" & Day(Date), 2)
   sREGFile = objFSO.GetParentFolderName(objFile) & "\svc_curr_state_" & sNow & ".reg"
   sBATFile = objFSO.GetParentFolderName(objFile) & "\svc_curr_state_" & sNow & ".bat"
   sSvcKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\"

   Set r = objFSO.CreateTextFile (sREGFile, True)
   r.WriteLine "Windows Registry Editor Version 5.00"
   r.WriteBlankLines 1
   r.WriteLine ";Services Startup Configuration Backup " & Now
   r.WriteBlankLines 1

   Set b = objFSO.CreateTextFile (sBATFile, True)
   b.WriteLine "@echo Restore Service Startup State saved at " & Now
   b.WriteBlankLines 1

   iSvcCnt=0
   iPerUserSvcCnt=0

   Set objWMIService = GetObject("winmgmts:" _
   & "{impersonationLevel=impersonate}!\\" & "." & "\root\cimv2")

   Set colListOfServices = objWMIService.ExecQuery ("Select * from Win32_Service")

   For Each objService In colListOfServices
      iSvcCnt=iSvcCnt + 1
      sStartState = lcase(objService.StartMode)
      sSvcName = objService.Name

      'Check if it's a per-user service. The service type will be "Unknown"
      If objService.ServiceType = "Unknown" Then
         'Get the corresponding Template Service's name from the Per-user service name
         Dim sSvcTemplateName
         sSvcTemplateName = Split(sSvcName, "_")

         On Error Resume Next
         iSvcType = WshShell.RegRead (sSvcKey & sSvcTemplateName(0) & "\Type")
         On Error GoTo 0
         If Err.number = 0 Then
            'Template service will be of type 96 or 80.
            If iSvcType = "96" Or iSvcType = "80" Then
               'It's a Per-user service
               iPerUserSvcCnt = iPerUserSvcCnt + 1
               sSvcName = sSvcTemplateName(0)
            End If
         End If
      End If

      r.WriteLine "[" & sSvcKey & sSvcName & "]"

      'If the service name contains spaces, enclose it in double quotes
      If InStr(sSvcName, " ") > 0  Then
         sSvcName = """" & sSvcName & """"
      End If

      Select Case sStartState
         Case "boot"

         r.WriteLine chr(34) & "Start" & Chr(34) & "=dword:00000000"
         b.WriteLine "sc.exe config " & sSvcName & " start= boot"

         Case "system"
         r.WriteLine chr(34) & "Start" & Chr(34) & "=dword:00000001"
         b.WriteLine "sc.exe config " & sSvcName & " start= system"

         Case "auto"
         'Check if it's Automatic (Delayed start)
         r.WriteLine chr(34) & "Start" & Chr(34) & "=dword:00000002"
         If objService.DelayedAutoStart = True Then
            r.WriteLine chr(34) & "DelayedAutostart" & Chr(34) & "=dword:00000001"
            b.WriteLine "sc.exe config " & sSvcName & " start= delayed-auto"
         Else
            r.WriteLine chr(34) & "DelayedAutostart" & Chr(34) & "=-"
            b.WriteLine "sc.exe config " & sSvcName & " start= auto"
         End If

         Case "manual"

         r.WriteLine chr(34) & "Start" & Chr(34) & "=dword:00000003"
         b.WriteLine "sc.exe config " & sSvcName & " start= demand"

         Case "disabled"

         r.WriteLine chr(34) & "Start" & Chr(34) & "=dword:00000004"
         b.WriteLine "sc.exe config " & sSvcName & " start= disabled"

         Case "unknown"	sSkippedSvc = sSkippedSvc & vbcrlf & sSvcName

         'Case Else
      End Select
      r.WriteBlankLines 1
   Next

   If trim(sSkippedSvc) <> "" Then
      WScript.Echo iSvcCnt & "  - Total # of Services." & _
      "(including " & iPerUserSvcCnt & " Per-user Services)" & _
      vbCrLf & vbCrLf & "The following services could not be backed up:" & _
      vbcrlf & vbCrLf & sSkippedSvc
   Else
      WScript.Echo iSvcCnt & " Services found " & _
      "(including " & iPerUserSvcCnt & " Per-user Services)" & _
      " and their startup configuration has been backed up."
   End If

   r.Close
   b.WriteLine "@pause"
   b.Close
   'WshShell.Run "notepad.exe " & sREGFile
   'WshShell.Run "notepad.exe " & sBATFile
   Set objFSO = Nothing
   Set WshShell = Nothing
End If
