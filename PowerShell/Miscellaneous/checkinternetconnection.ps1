while ($true) {
    if (Test-Connection -Count 4 -Quiet -Delay 3 www.github.com) {
        Write-Output "Internet Connection is good to go."
    }
    else {
        Write-Output "Not connected to the internet."
        # Get-Date | Out-File -Append Reconnect_fritzbox.log
        netsh wlan disconnect; Start-Sleep 2;
        netsh wlan connect name=vino-enhanced-5G-2;
    }
    # Get-Date
    # Start-Sleep 3
}
