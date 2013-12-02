if (Get-Module PsShortcuts) { return }

Push-Location $PsScriptRoot

. .\shortcuts.ps1
. .\suggest.ps1

Pop-Location

Export-ModuleMember `
	-Function @(
		'TabExpansion',
		'Get-UserGoTargetDescriptor',
		'go',
		'here'
	)
