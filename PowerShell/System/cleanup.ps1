# empty recycle bin
Write-Verbose -Message 'Emptying Recycle Bin'
(New-Object -ComObject Shell.Application).Namespace(0xA).items() | %{ rm $_.path -Recurse -Confirm:$false}

Write-Verbose 'Removing Windows %TEMP% files'
rm c:\Windows\Temp\* -Recurse -Force -ErrorAction SilentlyContinue

Write-Verbose 'Removing User %TEMP% files'
rm “C:\Users\*\Appdata\Local\Temp\*” -Recurse -Force -ErrorAction SilentlyContinue

Write-Verbose 'Removing Custome Temp Files (C:/Temp and C:/tmp)'
rm c:\Temp\* -Recurse -Force -ErrorAction SilentlyContinue
rm c:\Tmp\* -Recurse -Force -ErrorAction SilentlyContinue

Write-Verbose 'Launchin cleanmgr'
cleanmgr /sagerun:1 | out-Null

