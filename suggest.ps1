if (Test-Path Function:\TabExpansion) {
	Rename-Item Function:\TabExpansion Function:\PsShortcuts-TabExpansionBackup
}


function getSuggestions($destinations, $lastWord) {
	$location = Get-Location

	for ($i = 1; $i -lt ($destinations.length - 1); $i++) {
		$location = Get-Target ($destinations[$i]) $location
		if ($location -eq $False) {
			return
		}
	}

	(Get-AllGoTargetsForLocation $location).Keys | where { $_.ToLower().StartsWith($lastWord.ToLower()) } | sort
}


function TabExpansion($line, $lastWord) {
	$aliases = @('go') + @(get-alias | where { $_.Definition -eq 'go' } | select -Exp Name)
	$lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()
	if ($aliases | where { $lastBlock.StartsWith($_ + ' ') }) {
		$destinations = [regex]::Split($lastBlock, '\s+')
		getSuggestions $destinations $lastWord
	}
	elseif (Test-Path Function:\PsShortcuts-TabExpansionBackup) {
		PsShortcuts-TabExpansionBackup $line $lastWord
	}
}
