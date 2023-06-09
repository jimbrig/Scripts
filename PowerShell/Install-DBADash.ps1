$InstallPath = "C:\tools\DBADash"

$Repo = "trimble-oss/dba-dash"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Tag = (Invoke-WebRequest "https://api.github.com/repos/$Repo/releases/latest" | ConvertFrom-Json).tag_name

if (!(Test-Path -Path $InstallPath)) {
    New-Item -Path $InstallPath -ItemType Directory -Force
}

if ((Get-ChildItem -Path $InstallPath | Measure-Object).Count -gt 0) {
    throw "Destination folder is not empty"
}

cd $InstallPath
$zip = "DBADash_$Tag.zip"

$download = "https://github.com/$Repo/releases/download/$Tag/$zip"
Invoke-WebRequest $download -Out $zip

Expand-Archive -Path $zip -DestinationPath $InstallPath -Force -ErrorAction Stop

Start-Process DBADashServiceConfigTool.exe
