#Requires -RunAsAdministrator
#Requires -Modules Pester

Import-Module Pester

# Specify the path to the current script's directory
$CurrDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Pester Configuration
$PesterConfig = [PesterConfiguration]::Default

# Configure Pester - Run
$PesterConfig.Run = @{
    Path     = Join-Path $PSScriptRoot "Tests"
    PassThru = $true
}

# Configure Pester - Output
$PesterConfig.Output = @{
    Verbosity                = 'Detailed'
    OutputPath               = "$CurrDir\PesterTestResults.xml"
    CodeCoverageOutputPath   = "$CurrDir\CodeCoverage.xml"
    CodeCoverageOutputFormat = 'Cobertura'
}

# Run Pester
$Results = Invoke-Pester -Configuration $PesterConfig

# Output Results
$ResultsTable = $Results.Tests | Select-Object ExpandedPath, Executed, Passed | Sort-Object ExpandedPath | Format-Table -AutoSize
$ResultsTable | Export-Csv -Path "$CurrDir\PesterTestResults.csv" -NoTypeInformation -Force
$ResultsTable | Out-String | Write-Host

# Output Code Coverage
$Results.CodeCoverage | Out-String | Write-Host

# Exit with the number of failed tests
Exit $Results.FailedCount
