#Requires -Module PSDevOps

$Params = @{
    Name        = "UsePSDevOps"
    Description = "PowerShell Tools for DevOps (including a PowerShell wrapper for the GitHub REST API)"
    Action      = PSDevOpsAction
    Icon        = activity
}

New-GitHubAction @Params | Set-Content $PSCommandPath\action.yml -Encoding UTF8 -PassThru
