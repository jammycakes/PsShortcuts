if (Get-Module PsShortcuts) { return }

Push-Location $PsScriptRoot

. .\shortcuts.ps1
. .\suggest.ps1

Pop-Location

Set-Alias go Goto-Target
Set-Alias here Explore-CurrentLocation

Export-ModuleMember `
	-Function @(
		'TabExpansion',
		'Get-UserGoTargetDescriptor',
		'List-GoTargets',
		'Goto-Target',
		'Save-Target',
		'Explore-CurrentLocation'
	) `
	-Alias @(
		'go',
		'here'
	)
