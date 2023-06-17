BeforeDiscovery {
    $OptionalFeaturesToEnable = @(
        HypervisorPlatform
        VirtualMachinePlatform
        Microsoft-Hyper-V-All
        Microsoft-Hyper-V-Tools-All
        Microsoft-Hyper-V-Management-PowerShell
        Microsoft-Hyper-V-Hypervisor
        Microsoft-Hyper-V-Services
        Microsoft-Hyper-V-Management-Clients
        HostGuardian
        Containers-DisposableClientVM
        Windows-Defender-ApplicationGuard
        Containers
        Containers-HNS
        Containers-SDN
        SmbDirect
        Microsoft-Windows-Subsystem-Linux
        Microsoft-Windows-Subsystem-Linux-All
        Windows-Identity-Foundation
        NetFx3        
    )

     

    $OptionalFeaturesDesiredState = @(
        @{FeatureName = 'Microsoft-Hyper-V-All'; State = 'Enabled'; MissingOK = $False },
        @{FeatureName = 'Microsoft-Windows-Subsystem-Linux'; State = 'Enabled'; MissingOK = $False },
        @{FeatureName = 'Microsoft-Windows-Subsystem-Linux-All'; State = 'Enabled'; MissingOK = $False },
        @{FeatureName = 'Microsoft-Windows-Subsystem-Linux-WslOptionalFeature'; State = 'Enabled'; MissingOK = $False },
        @{FeatureName = 'SearchEngine-Client-Package'; State = 'Enabled'; MissingOK = $False },
        @{FeatureName = 'HypervisorPlatform'; State = 'Enabled'; MissingOK = $False },

    )
}

BeforeAll {
    $script:OptionalFeatures = Get-WindowsOptionalFeature -Online
}

$EnabledFeatures = Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' }

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
