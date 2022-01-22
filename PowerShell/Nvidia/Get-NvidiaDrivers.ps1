# Most logic taken from https://github.com/ElPumpo/TinyNvidiaUpdateChecker/blob/master/TinyNvidiaUpdateChecker/MainConsole.cs

# ensure windows powershell:
PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Unrestricted -File ""$PSScriptRoot\NvidiaScript.ps1""' -Verb RunAs}";
