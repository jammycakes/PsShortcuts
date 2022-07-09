. $PSScriptRoot\Reader.ps1

function Get-Suggestions-ForTabExpansion {
    param (
        [string] $location,
        [string] $line,
        [string] $lastWord
    )

    $aliases = @(
        'Set-LocationToShortcut'
    ) + @(
        Get-Alias |
        Where-Object { $_.Definition -eq 'Set-LocationToShortcut' } |
        Select-Object -Exp Name
    )

    $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()

    if ($aliases | Where-Object { $lastBlock.StartsWith($_ + ' ') }) {
        $targets = [regex]::Split($lastBlock, '\s+') | Select-Object -Skip 1
        return Get-Suggestions-ForLocation $location $targets $lastWord
    }
    else {
        return $null
    }
}

function Get-Suggestions-ForLocation {
    param (
        [string] $location,
        [string[]] $targets,
        [string] $lastWord
    )

    if ($lastWord -eq $targets[-1]) {
        $targets = $targets | Select-Object -SkipLast 1
    }

    $final = Get-ShortcutLocation -path $location -targets $targets
    if ($null -eq $final) {
        return $null
    }

    $shortcuts = $(Read-AllShortcuts -path $final).Keys |
        Where-Object { $_.ToLower().StartsWith($lastWord.ToLower()) } |
        Sort-Object

    if ($shortcuts.Length -gt 0) {
        return $shortcuts
    }
    else {
        return $shortcuts
    }
}