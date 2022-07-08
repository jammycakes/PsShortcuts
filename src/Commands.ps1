. $PSScriptRoot\Reader.ps1

function Set-LocationToShortcut {
    param (
        [Parameter(Position=$False)]
        [string]
        $From = '',

        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]
        $Targets
    )

    if ($From -eq '') {
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
