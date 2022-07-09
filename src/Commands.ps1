. $PSScriptRoot\Reader.ps1

function Set-LocationToShortcut {
    param (
        [Parameter(ValueFromRemainingArguments=$true, Position=0)]
        [string[]]
        $Targets,

        [string]
        $From = ''
    )

    if (($From -eq '') -or ($null -eq $From)) {
        $path = Get-Location
    }
    else {
        $path = $From
    }

    $destination = Get-ShortcutLocation -Path $path -targets $Targets

    if ($null -eq $destination) {
        Write-Host -ForegroundColor Red "This shortcut was not found."
    }
    else {
        Set-Location $destination
    }
}

Set-Alias goto Set-LocationToShortcut
