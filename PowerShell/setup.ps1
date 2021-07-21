$scriptDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$isadmin = (new-object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole("Administrators")

Write-Host "Configuring system to support development environment" -ForegroundColor Blue

# Support Long Paths
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
Write-Host "Long Path Support has been enabled via the registry." -ForegroundColor Green

# Tweak Defender
Add-MpPreference -ExclusionPath 'C:\Users\jimbr\scoop'
Add-MpPreference -ExclusionPath 'C:\ProgramData\scoop'
Add-MpPreference -ExclusionPath 'C:\ProgramData\chocolatey'

Write-Host "Added Windows Defender Exclusions." -ForegroundColor Green

# powershell config
Write-Host "Setting up powershell" -ForegroundColor Blue
$exepolicy = Get-ExecutionPolicy
if ($exepolicy -ne 'Unrestricted') {
  Write-Host "Setting Execution Policy to Unrestricted for System and User" -ForegroundColor Green
  Set-ExecutionPolicy Unrestricted
  Set-ExecutionPolicy Unrestricted -scope CurrentUser
}

# create powershell profile
if (!(Test-Path -Path $PROFILE)) {
  Write-Host "Creating Powershell Profile" -ForegroundColor Green
  New-Item -ItemType File -Path $PROFILE -Force
}

function Install-NeededFor {
  param(
    [string] $packageName = ''
    , [bool] $defaultAnswer = $true
  )
  if ($packageName -eq '') { return $false }

  $yes = '6'
  $no = '7'
  $msgBoxTimeout = '-1'
  $defaultAnswerDisplay = 'Yes'
  $buttonType = 0x4;
  if (!$defaultAnswer) { $defaultAnswerDisplay = 'No'; $buttonType = 0x104; }

  $answer = $msgBoxTimeout
  try {
    $timeout = 10
    $question = "Do you need to install $($packageName)? Defaults to `'$defaultAnswerDisplay`' after $timeout seconds"
    $msgBox = New-Object -ComObject WScript.Shell
    $answer = $msgBox.Popup($question, $timeout, "Install $packageName", $buttonType)
  }
  catch {
  }

  if ($answer -eq $yes -or ($answer -eq $msgBoxTimeout -and $defaultAnswer -eq $true)) {
    write-host "Installing $packageName"
    return $true
  }

  write-host "Not installing $packageName"
  return $false
}

# chocolatey
if (-not (Test-Path "C:\ProgramData\Chocolatey\bin\choco.exe")) {
  Write-Host "Chocolatey missing, preparing for install" -ForegroundColor Red

  if (Install-NeededFor 'chocolatey') {
    Invoke-Expression ((new-object net.webclient).DownloadString("http://chocolatey.org/install.ps1"))
  }



  RefreshEnv.cmd










