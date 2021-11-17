$uri = "https://secure.backblaze.com/win32/install_backblaze.exe"
$out = "$HOME\Downloads\Backblaze.exe"
Invoke-WebRequest -Uri $uri -OutFile $out
Set-Location "$HOME\Downloads"
.\Backblaze.exe 
