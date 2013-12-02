Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

Import-Module .\PsShortcuts.psm1

Pop-Location
