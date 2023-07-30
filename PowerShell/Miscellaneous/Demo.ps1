<#
    .SYNOPSIS
        This is a script showcasing the "ShowDemo" module.
    .DESCRIPTION
        This is a script showcasing the "ShowDemo" module.
    .LINK
        - https://github.com/StartAutomating/ShowDemo/blob/main/demo.ps1
        - https://showdemo.start-automating.com/demo/
    .NOTES
        - You can create *.demo.ps1 files to create demos which are rendered to Markdown.
#>

# 1. Install/Import the 'ShowDemo' Module
If (-Not (Get-Module -Name ShowDemo -ListAvailable)) {
    Install-Module -Name ShowDemo -Scope CurrentUser -Force
}

Import-Module -Name ShowDemo -Force -PassThru

# 2. Demonstrate Some Examples

# 2.1 Feedback Helpers

Function Write-Success ($text) {
    $msg = "✔️ Success: " + $text
    Write-Host $msg -ForegroundColor Green
}

Function Write-Begin ($text) {
    $msg = "🕜 Begin: " + $text
    Write-Host $msg -ForegroundColor Cyan
}

## 2.1.1 Use Write-Begin

Write-Begin "Starting Operation..."

## 2.1.2 Use Write-Success

Write-Success "Successfully Completed Operation."

# Learn PowerShell.
# Write Scripts.
# Make Money.
