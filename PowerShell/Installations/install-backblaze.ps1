$uri = "https://secure.backblaze.com/win32/install_backblaze.exe"
$out = "$HOME\Downloads\Backblaze.exe"
Invoke-WebRequest -Uri $uri -OutFile $out
Set-Location "$HOME\Downloads"
.\Backblaze.exe


$MSIUri = "https://secure.backblaze.com/win32/install_backblazemsi.msi"
$MSIOut = "$HOME\Downloads\install_backblazemsi.msi"
pwsh.exe -NoProfile -Command { Invoke-WebRequest -Uri $MSIUri -OutFile $MSIOut }
msiexec.exe /I $MSIOut BZEMAIL='jimmy.briggs@jimbrig.com'
