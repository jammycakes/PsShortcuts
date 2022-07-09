. "$PSScriptRoot\Reader.ps1"

function Write-PsShortcutEntry {
    param (
        [string] $filename,
        [string] $name,
        [string] $value
    )

    $name = $name.Trim().ToLower()

    if ([regex]::Match($name, "[#=\s]").Success) {
        throw "Shortcut names cannot contain spaces or # or = characters."
    }

    if (Test-Path $filename) {
        $content = Get-Content $filename
        Clear-Content $filename
    }
    else {
        $content = @()
    }

    $count = 0
    $content | ForEach-Object {
        $line = $_
        if (-not $line.StartsWith('#')) {
            $bits = $line -Split '=', 2
            if ($bits.Length -eq 2) {
                $key = $bits[0].Trim().ToLower()
                if ($key -eq $name) {
                    if ($null -eq $value) {
                        $newline = $null
                    }
                    else {
                        $line = "$key=$value"
                    }
                    $count++
                }
            }
        }

        if ($null -ne $line) {
            Write-Output $line | Add-Content -Path $filename -Encoding UTF8
        }
    }

    if (($count -eq 0) -and ($null -ne $value))  {
        Write-Output "$name=$value" | Add-Content -Path $filename -Encoding UTF8
    }
}

function Get-RelativePath {
    param (
        [string] $root,
        [string] $target
    )

    if (-not ($target.StartsWith($root))) {
        return Get-AbsolutePath $target
    }

    Push-Location $root
    try {
        $result = Resolve-Path -Relative $target -ErrorAction SilentlyContinue -ErrorVariable _error
        if (-not $result) {
            $result = $_error[0].TargetObject
        }
    }
    finally {
        Pop-Location
    }

    return $result
}

function Write-PsShortcut {
    param (
        [Parameter(Mandatory=$true)][string] $name,
        [string] $destination,
        [string] $location
    )

    if (($null -eq $destination) -or ('' -eq $destination)) {
        $destination = Get-Location
    }

    if (($null -eq $location) -or ('' -eq $location)) {
        $filename = $(Get-ShortcutFileLocations $destination)[0]
        $location = Split-Path -Path $filename
    }
    elseif (Test-Path $location -PathType Container) {
        $filename = Join-Path $location $shortcutFileName 
    }

    $destination = Get-RelativePath $location $destination
    Write-PsShortcutEntry -filename $filename -name $name -value $destination

    Write-Host 'Shortcut "' -NoNewline
    Write-Host $name -NoNewline -ForegroundColor Magenta
    Write-Host '" written to ' -NoNewline
    Write-Host $filename -NoNewline -ForegroundColor Green
    Write-Host '.'
}

function Remove-PsShortcut {
    param (
        [Parameter(Mandatory=$true)][string] $name,
        [string] $location
   )

    if (($null -eq $location) -or ('' -eq $location)) {
        $filename = $(Get-ShortcutFileLocations $destination)[0]
    }
    elseif (Test-Path $location -PathType Container) {
        $filename = Join-Path $location $shortcutFileName 
    }
    else {
        $filename = $location
    }

    Write-PsShortcutEntry -filename $filename -name $name -value $null

    Write-Host 'Shortcut "' -NoNewline
    Write-Host $name -NoNewline -ForegroundColor Magenta
    Write-Host '" removed from ' -NoNewline
    Write-Host $filename -NoNewline -ForegroundColor Green
    Write-Host '.'
}