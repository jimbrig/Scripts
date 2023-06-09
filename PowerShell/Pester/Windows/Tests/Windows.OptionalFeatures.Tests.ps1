BeforeDiscovery {
    $script:OptionalFeaturesStatus = @(
        @{FeatureName = 'Microsoft-Hyper-V-All'; MissingOK = $False; Enabled = $True }
    )
}

BeforeAll {
    $script:OptionalFeatures = Get-WindowsOptionalFeature -Online
}

Describe "Verify Windows Optional Features Status" {

    It "Verfies Windows Feature '<FeatureName>' Should be '<State>'" -TestCases $OptionalFeaturesStatus {

        Param(
            [string]$FeatureName,
            [bool]$MissingOK,
            [bool]$Enabled
        )

        $Feature = $OptionalFeatures | Where-Object { $_.FeatureName -eq $FeatureName }

        if ($Feature -eq $null) {
            if ($MissingOK) {
                Write-Host "Optional Feature '$FeatureName' is missing (as expected)"
            }
            else {
                Write-Error "Optional Feature '$FeatureName' is missing"
            }
        }
        else {
            if ($Feature.State -eq 'Enabled') {
                if ($Enabled) {
                    Write-Host "Optional Feature '$FeatureName' is enabled (as expected)"
                }
                else {
                    Write-Error "Optional Feature '$FeatureName' is enabled"
                }
            }
            else {
                if ($Enabled) {
                    Write-Error "Optional Feature '$FeatureName' is disabled"
                }
                else {
                    Write-Host "Optional Feature '$FeatureName' is disabled (as expected)"
                }
            }
        }

    }

}
