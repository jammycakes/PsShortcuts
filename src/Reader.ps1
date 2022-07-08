<# ====== Shortcut Files ====== #>
<#
    Utilities to locate and load in shortcut files.
#>

$shortcutFileName = '.shortcuts'

function Get-ShortcutFileLocations {
    param(
        [string] $location
    )

    $thisdir = $location
    if ($location -eq "") {
        $thisdir = "$(Get-Location)"
    }

    $thisdir = Get-AbsolutePath $thisdir

    $dirs = @()
    
    while ($thisdir -and ($thisdir -ne '')) {
        $file = $(Get-ShortcutFilePath $thisdir)
        if (Test-Path $file -PathType Leaf) {
            $dirs += @($file)
        }
        $thisdir = Split-Path -parent $thisdir
    }

    $dirs += @(
        Get-UserShortcuts
        Get-SystemShortcuts
        Get-InstalledShortcuts
    )

    return $dirs
}

function Get-AbsolutePath {
    param (
        [string] $path
    )

    $resolved = Resolve-Path $path -ErrorAction SilentlyContinue -ErrorVariable _error
    if (-not($resolved)) {
        $resolved = $_error[0].TargetObject
    }

    return $resolved
}

function Get-ShortcutFilePath {
    param (
        [string] $path
    )

    return Get-AbsolutePath (Join-Path $path $shortcutFileName)
}

function Get-UserShortcuts {
    return Get-ShortcutFilePath (Resolve-Path ~)
}

function Get-SystemShortcuts {
    $appdata = [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonApplicationData)
    return Get-ShortcutFilePath $appdata
}

function Get-InstalledShortcuts {
    return Get-ShortcutFilePath $PSScriptRoot\$shortcutFileName
}


<# ====== Reading shortcut files ====== #>

function Read-ShortcutFile {
    param (
        [string] $path
    )

    $directory = Split-Path -Path $path

    $targets = @{}

    if (-not (Test-Path $path)) {
        return $targets
    }

    Get-Content $path | Foreach-Object {
        if (-not $_.StartsWith("#")) {
            $bits = $_ -split '=',2
            if ($bits.length -eq 2) {
                $key = $bits[0].Trim().ToLower()
                $val = $bits[1].Trim()

                if (-not $val.StartsWith("~") -and
                    -not [System.IO.Path]::IsPathRooted($val)) {
                    $val = Join-Path $directory $val
                }

                $val = Get-AbsolutePath $val

                if (-not $targets.ContainsKey($key)) {
                    $targets[$key] = $val
                }
            }
        }
    }

    return $targets
}

function Read-AllShortcuts {
    param (
        [string] $path
    )

    $targets = @{}

    Get-ShortcutFileLocations $path | ForEach-Object {
        $contents = Read-ShortcutFile $_
        $contents.Keys | ForEach-Object {
            $key = $_
            $val = $contents[$_]
            if (-not $targets.ContainsKey($key)) {
                $targets[$key] = $val
            }
        }
    }

    return $targets
}

function Get-ShortcutLocation {
    param (
        [Parameter(Position=$false)]
        [string]
        $path,
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]
        $targets
    )

    $location = $path

    foreach ($target in $targets) {
        $all = Read-AllShortcuts -path $location
        $location = $all[$target]

        if ($null -eq $location) {
            return $null
        }
    }

    return $location
}
