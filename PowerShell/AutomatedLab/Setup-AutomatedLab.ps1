If (!(Get-Module -Name AutomatedLab)) { Install-Module -Name AutomatedLab -Force -AllowClobber }

$AutoLabDir = "E:\LabSources"
$AutoLabISODir = Join-Path $AutoLabDir "ISOs"

Get-LabAvailableOperatingSystem -Path $AutoLabDir




