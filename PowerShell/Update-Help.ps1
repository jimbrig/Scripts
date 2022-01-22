Start-Job -Name "UpdateHelp" -ScriptBlock { Update-Help -Force } | Out-Null
Write-Host "Updating Help in background (Get-Help to check)" -ForegroundColor Yellow