Write-Host "Outlook Settings and Configuration Export" -ForegroundColor Magenta

$exportdir = "$env:HOMEPATH\OneDrive\Documents\Outlook"
Write-Host "Creating Backup directories for Outlook at ~/OneDrive/Documents/Outlook" -ForegroundColor Magenta

if (!(Test-Path $exportdir)) {
  mkdir $exportdir
  Write-Host "Created root directory for Outlook Backups." -ForegroundColor Green
}
else {
  Write-Host "Directory already setup, skipping creation." -ForegroundColor Green
}

$profileexportdir = "$exportdir\OutlookProfile"

if (!(Test-Path $profileexportdir)) {
  mkdir $profileexportdir
  Write-Host "Created Profile Export Directory" -ForegroundColor Green
}
else {
  Write-Host "Directory already setup, skipping creation." -ForegroundColor Green
}

$dataexportdir = "$exportdir\OutlookData"

if (!(Test-Path $dataexportdir)) {
  mkdir $dataexportdir
  Write-Host "Created Data Export Directory" -ForegroundColor Green
}
else {
  Write-Host "Directory already setup, skipping creation." -ForegroundColor Green
}

Write-Host "Backing up Registry for Outlook Profile into Profile Directory" -ForegroundColor Magenta
reg export HKCU\Software\Microsoft\Office\16.0\Outlook\Profiles $profileexportdir\OutlookProfiles.reg
Write-Host "Registry key backed up." -ForegroundColor Green

Write-Host "Backing up Registry for Token Broker" -ForegroundColor Magenta
reg export "HKCU\Software\Microsoft\Windows NT\CurrentVersion\TokenBroker" $profileexportdir\TokenBroker.reg
Write-Host "Registry key backed up." -ForegroundColor Green

Write-Host "Checking if Outlook is currently running" -ForegroundColor Magenta
$exepath = "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
$isrunning = (get-wmiobject win32_process | ? { $_.Path -eq $exepath } | measure-object | % { $_.Count }) -gt 0

if ($isrunning) {
  Write-Host "Detected a running instance of Outlook. Stopping the process.." -ForegroundColor Magenta
  Get-Process OUTLOOK | Stop-Process
  Write-Host "Outlook Process Stopped." -ForegroundColor Green
}

Write-Host "Backing up user data from %LOCALAPPDATA%\Microsoft\Outlook\*" -ForegroundColor Magenta
xcopy $env:localappdata\Microsoft\Outlook\* $dataexportdir
Write-Host "Data files backed up." -ForegroundColor Green

Write-Host "Backing up archive.ps1 from ~/OneDrive/Documents/Outlook Files/archive.ps1" -ForegroundColor Magenta
xcopy "$env:HOMEPATH\OneDrive\Documents\Outlook Files\*" $dataexportdir
Write-Host "Archive backed up." -ForegroundColor Green

Write-Host "Opening Explorer to backed up location to examine files..." -ForegroundColor Green
explorer.exe $exportdir
