function Get-LocalGoTargetDescriptorsForLocation($location) {
	$thisdir = $location
	$dirs = @()
	while ($thisdir -and ($thisdir -ne '')) {
		$file = Join-Path $thisdir '.go'
		if (Test-Path $file -PathType Leaf) {
			$dirs += @($file)
		}
		$thisdir = Split-Path -parent $thisdir
	}
	return $dirs
}

function Get-AllGoTargetDescriptorsForLocation($location) {
	$dirs = @(Get-LocalGoTargetDescriptorsForLocation $location)

	$local = Get-UserGoTargetDescriptor
	$system = Get-SystemGoTargetDescriptor
	$installed = Get-InstalledGoTargetDescriptor
	if ((Test-Path $local -PathType Leaf) -and ($dirs -inotcontains @($local))) {
		$dirs += @($local)
	}
	if ((Test-Path $system -PathType Leaf) -and ($dirs -inotcontains @($system))) {
		$dirs += @($system)
	}
	if ((Test-Path $installed -PathType Leaf) -and ($dirs -inotcontains @($installed))) {
		$dirs += @($installed)
	}
	return $dirs
}

function Get-AllGoTargetDescriptors {
	$location = Get-Location
	return Get-AllGoTargetDescriptorsForLocation $location
}

function Get-UserGoTargetDescriptor {
	return join-path (resolve-path ~) '.go'
}

function Get-SystemGoTargetDescriptor {
	$common = [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonApplicationData)
	return join-path $common '.go'
}

function Get-InstalledGoTargetDescriptor {
	$thisdir = Split-Path -Parent $MyInvocation.ScriptName
	return Join-Path $thisdir '.go'
}

function Get-AllGoTargetsForLocation($location) {
	$targets = @{}

	Get-AllGoTargetDescriptorsForLocation($location) | foreach -process {
		$dir = Split-Path -parent $_
		$dir = [System.IO.Path]::GetFullPath($dir)
		Get-Content $_ | foreach {
			if (-not $_.StartsWith("#")) {
				$bits = $_ -split '=',2
				if ($bits.length -eq 2) {
					$key = $bits[0].Trim().ToLower()
					$val = $bits[1].Trim()
					if ((-not ($val -match "^~([/\\]|$)")) `
						-and (-not ($val.StartsWith('http://'))) `
						-and (-not ($val.StartsWith('https://'))) `
						-and (-not [System.IO.Path]::IsPathRooted($val))) {
						$val = Join-Path $dir $val
					}
					if (-not $targets.ContainsKey($key)) {
						$targets[$key] = $val
					}
				}
			}
		}
	}
	return $targets
}

function Get-AllGoTargets {
	$location = Get-Location
	return Get-AllGoTargetsForLocation $location
}

function Goto-SingleTarget($targetName) {
	$targets = Get-AllGoTargets
	if ($targets.ContainsKey($targetName)) {
		$target = $targets[$targetName]
		if ($target.StartsWith('http://') -or $target.StartsWith('https://')) {
			Start-Process $target
		}
		else {
			Set-Location $target
		}
	}
	else {
		Write-Output "This target has not been defined."
	}
}

function Get-Target($targetName, $location) {
	$targets = Get-AllGoTargetsForLocation $location
	if ($targets.ContainsKey($targetName)) {
		$target = $targets[$targetName]
		if ($target.StartsWith('http://') -or $target.StartsWith('https://')) {
			return $False
		}
		else {
			return $target
		}
	}
	return $False
}

function List-Targets {
	$targets = Get-AllGoTargets
	$targets.GetEnumerator() | Sort-Object Name
}

function Explore-CurrentLocation {
	$target = Convert-Path(Get-Location -PSProvider FileSystem)
	Start-Process explorer "/e,$target"
}

function Goto-Target {
	if ($args.Length -eq 0) {
		List-Targets
	}
	else {
		$args | foreach -process { Goto-SingleTarget $_ }
	}
}

function Update-Descriptor {
	param (
		[string]$Name,
		[string]$Descriptor,
		[string]$Target
	)

	if (Test-Path $Descriptor) {
		$content = Get-Content $Descriptor
		Clear-Content $Descriptor
	}
	else {
		$content = @('')
	}
	
	$count = 0
	$content | foreach {
		$line = $_
		if (-not $line.StartsWith("#")) {
			$bits = $line -split '=',2
			if ($bits.length -eq 2) {
				$key = $bits[0].Trim().ToLower()
				if ($name.Trim().ToLower() -eq $key) {
					$line = "$key=$Target"
					$count++
				}
			}
		}
		echo $line >> $Descriptor
	}
	if ($count -eq 0) {
		$key = $Name.Trim().ToLower()
		echo "$key=$Target" >> $Descriptor
	}
}

function Save-Target {
	param (
		[Parameter(Mandatory)][string]$Name,
		[string[]]$Location,
		[string]$Target,
		[switch]$Global = $false,
		[switch]$Local = $false,
		[switch]$User = $false
	)

	# If any locations are specified, use them

	$descriptors = @()
	if ($Global) { $descriptors += @(Get-SystemGoTargetDescriptor) }
	if ($User) { $descriptors += @(Get-UserGoTargetDescriptor) }
	if ($Local) { $descriptors += @(Join-Path $(Get-Location) '.go') }
	if ($Location) { $descriptors += $(Resolve-Path $Location).ToString() }

	# Otherwise get the most local descriptor (recurse through directories, then go for user)

	if ($descriptors.Length -eq 0) {
		$descriptors = @(Get-LocalGoTargetDescriptorsForLocation $(Get-Location))[0..0]
	}

	if ($descriptors.Length -eq 0) {
		$descriptors = @(Get-UserGoTargetDescriptor)
	}

	if (-not $Target) {
		$Target = $(Resolve-Path $(Get-Location)).ToString()
	}

	$descriptors | foreach { 
		$path = $_
		if (-not $path.EndsWith('.go')) {
			$path = Join-Path $path '.go'
		}
		Update-Descriptor -Name $Name -Descriptor $path -Target $Target
	}
}