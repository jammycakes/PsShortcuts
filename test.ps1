Import-Module Pester -PassThru > $null

$PesterVersion = $(Get-Module Pester).Version

if ($PesterVersion.Major -lt 5) {
    Write-Output "Pester version is $($PesterVersion.ToString()). Version 5 or above is required."
    exit
}

$TestRoot = Join-Path $PSScriptRoot tests
Invoke-Pester -Path $TestRoot
