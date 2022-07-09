. $PSScriptRoot\Commands.ps1
. $PSScriptRoot\Suggestions.ps1

if (-Not (Test-Path Get-PsShortcuts-TabExpansionBackup)) {
    if (Test-Path Function:\TabExpansion) {
        Rename-Item Function:\TabExpansion Get-PsShortcuts-TabExpansionBackup
    }
    else {
        function Get-PsShortcuts-TabExpansionBackup {
            return @()
        }
    }
}

function TabExpansion {
    param (
        [string] $line,
        [string] $lastWord
    )

    $suggestions = Get-Suggestions-ForTabExpansion $(Get-Location) $line $lastWord
    if ($null -eq $suggestions) {
        return Get-PsShortcuts-TabExpansionBackup $line $lastWord
    }
    else {
        return $suggestions
    }
}
