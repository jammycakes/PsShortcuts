if (Test-Path Function:\TabExpansion) {
	Rename-Item Function:\TabExpansion PsShortcuts-TabExpansionBackup
}


function getSuggestions($destinations, $lastWord) {
	$location = Get-Location

	for ($i = 1; $i -lt ($destinations.length - 1); $i++) {
		$location = Get-Target ($destinations[$i]) $location
		if ($location -eq $False) {
			return
		}
	}

	(Get-AllGoTargetsForLocation $location).Keys | Where-Object { $_.ToLower().StartsWith($lastWord.ToLower()) } | Sort-Object
}


function TabExpansion($line, $lastWord) {
	$aliases = @('Goto-Target') + @(get-alias | Where-Object { $_.Definition -eq 'Goto-Target' } | Select-Object -Exp Name)
	$lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()
	if ($aliases | Where-Object { $lastBlock.StartsWith($_ + ' ') }) {
		$destinations = [regex]::Split($lastBlock, '\s+')
		getSuggestions $destinations $lastWord
	}
	elseif (Test-Path Function:\PsShortcuts-TabExpansionBackup) {
		PsShortcuts-TabExpansionBackup $line $lastWord
	}
}
