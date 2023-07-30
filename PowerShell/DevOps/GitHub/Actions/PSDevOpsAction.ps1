<#
    .SYNOPSIS
        GitHub Action for PSDevOps
    .DESCRIPTION
        GitHub Action for PSDevOps.

        This will:

            - Import PSDevOps and Connect-GitHub (giving easy access to every GitHub API)
            - Run all *.PSDevOps.ps1 files beneath the workflow directory
            - Run a .PSDevOpsScript parameter.

        Notes:

            - If you will be making changes using the GitHubAPI, you should provide a -GitHubToken
            - If none is provided, and ENV:GITHUB_TOKEN is set, this will be used instead.
            - Any files changed can be outputted by the script, and those changes can be checked back into the repo.
            - Make sure to use the "persistCredentials" option with checkout.

#>

Param(
    # A PowerShell Script that uses PSDevOps.
    # Any files outputted from the script will be added to the repository.
    # If those files have a .Message attached to them, they will be committed with that message.
    [string]
    $PSDevOpsScript,

    # If set, will not process any files named *.PSDevOps.ps1
    [switch]
    $SkipPSDevOpsPS1,

    # If provided, will use this GitHubToken when running Connect-GitHub
    [string]
    $GitHubToken,

    [PSObject]
    $Parameter,

    # If provided, will commit any remaining changes made to the workspace with this commit message.
    [string]
    $CommitMessage,

    # The user email associated with a git commit.
    [string]
    $UserEmail,

    # The user name associated with a git commit.
    [string]
    $UserName
)

#region Initial Logging

# Output the parameters passed to this script (for debugging)
"::group::Parameters" | Out-Host
[PSCustomObject]$PSBoundParameters | Format-List | Out-Host
"::endgroup::" | Out-Host

# Get the GitHub Event
$gitHubEvent =
if ($env:GITHUB_EVENT_PATH) {
    [IO.File]::ReadAllText($env:GITHUB_EVENT_PATH) | ConvertFrom-Json
}
else { $null }

# Log the GitHub Event
@"
::group::GitHubEvent
$($gitHubEvent | ConvertTo-Json -Depth 100)
::endgroup::
"@ | Out-Host

# Check that there is a workspace (and throw if there is not)
if (-not $env:GITHUB_WORKSPACE) { throw "No GitHub workspace" }

#endregion Initial Logging

# Check to ensure we are on a branch
$branchName = git rev-parse --abrev-ref HEAD
# If we were not, return.
if (-not $branchName) {
    "::warning::Not on a branch" | Out-Host
    return
}

#region Configure UserName and Email
if (-not $UserName) {
    $UserName =
    if ($env:GITHUB_TOKEN) {
        Invoke-RestMethod -uri "https://api.github.com/user" -Headers @{
            Authorization = "token $env:GITHUB_TOKEN"
        } |
        Select-Object -First 1 -ExpandProperty name
    }
    else {
        $env:GITHUB_ACTOR
    }
}

if (-not $UserEmail) {
    $GitHubUserEmail =
    if ($env:GITHUB_TOKEN) {
        Invoke-RestMethod -uri "https://api.github.com/user/emails" -Headers @{
            Authorization = "token $env:GITHUB_TOKEN"
        } |
        Select-Object -First 1 -ExpandProperty email
    }
    else { '' }
    $UserEmail =
    if ($GitHubUserEmail) {
        $GitHubUserEmail
    }
    else {
        "$UserName@github.com"
    }
}
git config --global user.email $UserEmail
git config --global user.name  $UserName
#endregion Configure UserName and Email

git pull | Out-Host


#region Load Action Module
$ActionModuleName = "EZOut"
$ActionModuleFileName = "$ActionModuleName.psd1"

# Try to find a local copy of the action's module.
# This allows the action to use the current branch's code instead of the action's implementation.
$PSD1Found = Get-ChildItem -Recurse -Filter "*.psd1" |
Where-Object Name -eq $ActionModuleFileName |
Select-Object -First 1

$ActionModulePath, $ActionModule =
# If there was a .PSD1 found
if ($PSD1Found) {
    $PSD1Found.FullName # import from there.
    Import-Module $PSD1Found.FullName -Force -PassThru
}
# Otherwise, if we have a GITHUB_ACTION_PATH
elseif ($env:GITHUB_ACTION_PATH) {
    $actionModulePath = Join-Path $env:GITHUB_ACTION_PATH $ActionModuleFileName
    if (Test-path $actionModulePath) {
        $actionModulePath
        Import-Module $actionModulePath -Force -PassThru
    }
    else {
        throw "$actionModuleName not found"
    }
}
elseif (-not (Get-Module $ActionModuleName)) {
    throw "$actionModulePath could not be loaded."
}

"::notice title=ModuleLoaded::$actionModuleName Loaded from Path - $($actionModulePath)" | Out-Host
#endregion Load Action Module


$anyFilesChanged = $false
filter ProcessScriptOutput {
    $out = $_
    $outItem = Get-Item -Path $out -ErrorAction SilentlyContinue
    $fullName, $shouldCommit =
    if ($out -is [IO.FileInfo]) {
        $out.FullName, (git status $out.Fullname -s)
    }
    elseif ($outItem) {
        $outItem.FullName, (git status $outItem.Fullname -s)
    }
    if ($shouldCommit) {
        git add $fullName
        if ($out.Message) {
            git commit -m "$($out.Message)"
        }
        elseif ($out.CommitMessage) {
            git commit -m "$($out.CommitMessage)"
        }
        elseif ($gitHubEvent.head_commit.message) {
            git commit -m "$($gitHubEvent.head_commit.message)"
        }
        $anyFilesChanged = $true
    }
    $out
}

#endregion Declare Functions and Variables

$ght =
if ($GitHubToken) {
    $GitHubToken
}
elseif ($env:GITHUB_TOKEN) {
    $env:GITHUB_TOKEN
}
"::group::Connecting to Github" | Out-Host
$connectStart = [DateTime]::now
Connect-GitHub -PersonalAccessToken $GitHubToken -PassThru |
ForEach-Object {
    $githubModule = $_
    "::notice title=Connected::Connect-GitHub finished - $($githubModule.ExportedCommands.Count) Commands Imported" | Out-Host
    $githubModule.ExportedCommands.Keys -join [Environment]::Newline | Out-Host
} |
Out-Host
"::endgroup::" | Out-Host


if (-not $UserName) { $UserName = $env:GITHUB_ACTOR }
if (-not $UserEmail) { $UserEmail = "$UserName@github.com" }
git config --global user.email $UserEmail
git config --global user.name  $UserName

if (-not $env:GITHUB_WORKSPACE) { throw "No GitHub workspace" }

git pull | Out-Host

$PSDevOpsScriptStart = [DateTime]::Now
if ($PSDevOpsScript) {
    Invoke-Expression -Command $PSDevOpsScript |
    ProcessScriptOutput |
    Out-Host
}
$PSDevOpsScriptTook = [Datetime]::Now - $PSDevOpsScriptStart
# "::set-output name=PSDevOpsScriptRuntime::$($PSDevOpsScriptTook.TotalMilliseconds)"   | Out-Host

$PSDevOpsPS1Start = [DateTime]::Now
$PSDevOpsPS1List = @()
if (-not $SkipPSDevOpsPS1) {
    Get-ChildItem -Recurse -Path $env:GITHUB_WORKSPACE |
    Where-Object Name -Match '\.PSDevOps\.ps1$' |

    ForEach-Object {
        $PSDevOpsPS1List += $_.FullName.Replace($env:GITHUB_WORKSPACE, '').TrimStart('/')
        $PSDevOpsPS1Count++
        "::notice title=Running::$($_.Fullname)" | Out-Host
        . $_.FullName |
        ProcessScriptOutput  |
        Out-Host
    }
}
$PSDevOpsPS1EndStart = [DateTime]::Now
$PSDevOpsPS1Took = [Datetime]::Now - $PSDevOpsPS1Start
# "::set-output name=PSDevOpsPS1Count::$($PSDevOpsPS1List.Length)"   | Out-Host
# "::set-output name=PSDevOpsPS1Files::$($PSDevOpsPS1List -join ';')"   | Out-Host
# "::set-output name=PSDevOpsPS1Runtime::$($PSDevOpsPS1Took.TotalMilliseconds)"   | Out-Host
if ($CommitMessage -or $anyFilesChanged) {
    if ($CommitMessage) {
        dir $env:GITHUB_WORKSPACE -Recurse |
        ForEach-Object {
            $gitStatusOutput = git status $_.Fullname -s
            if ($gitStatusOutput) {
                git add $_.Fullname
            }
        }

        git commit -m $ExecutionContext.SessionState.InvokeCommand.ExpandString($CommitMessage)
    }

    $checkDetached = git symbolic-ref -q HEAD
    if (-not $LASTEXITCODE) {
        "::notice::Pushing Changes" | Out-Host
        $gitPushed = git push
        "Git Push Output: $($gitPushed  | Out-String)"
    }
    else {
        "::notice::Not pushing changes (on detached head)" | Out-Host
        $LASTEXITCODE = 0
        exit 0
    }
}
