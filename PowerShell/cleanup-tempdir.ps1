
<#
    Description: Cleaning up TEMP folder
    Author: Jimmy Briggs <jimbrig1993@outlook.com>
    Date: July 17, 2021
    Using -ErrorAction switch to disable all errors and continue to delete
    inside the TEMP folder.
#>

Remove-Item -Path $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue
