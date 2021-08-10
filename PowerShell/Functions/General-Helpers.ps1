function Write-Log([String]$msg) {
  [String]$outString = (Get-Date -Format "MM/dd/yy HH:mm:ss") + ": $msg";
  $outString | Out-File -FilePath ($env:appdata + "\Migrate-User-Data.log") -Append;
}
