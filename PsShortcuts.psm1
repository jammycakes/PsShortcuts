if (Get-Module PsShortcuts) { return }

Push-Location $PsScriptRoot

. .\shortcuts.ps1

Pop-Location

Export-ModuleMember `
	-Function @(
		'Get-UserGoTargetDescriptor',
		'go'
	)
