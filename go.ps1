Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

if (Get-Module PsShortcuts) { Remove-Module PsShortcuts }
Import-Module .\PsShortcuts.psm1 -DisableNameChecking

Pop-Location
