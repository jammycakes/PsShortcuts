function Get-AllGoTargetDescriptors {
	$dirs = @()
	$thisdir = Get-Location
	while ($thisdir) {
		$file = Join-Path $thisdir '.go'
		if (Test-Path $file -PathType Leaf) {
			$dirs += @($file)
		}
		$thisdir = Split-Path -parent $thisdir
	}
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

function Get-AllGoTargets {
	$targets = @{}

	Get-AllGoTargetDescriptors | foreach -process {
		Get-Content $_ | foreach {
			if (-not $_.StartsWith("#")) {
				$bits = $_ -split '=',2
				if ($bits.length -eq 2) {
					$key = $bits[0].Trim().ToLower()
					$val = $bits[1].Trim()
					if (-not $targets.ContainsKey($key)) {
						$targets[$bits[0].Trim().ToLower()] = $bits[1].Trim()
					}
				}
			}
		}
	}
	return $targets
}


function Goto-Target($targetName) {
	$targets = Get-AllGoTargets
	if ($targets.ContainsKey($targetName)) {
		$target = $targets[$targetName]
		if ($target.StartsWith('http://') -or $target.StartsWith('https://')) {
			Start-Process $target
		}
		elseif ([System.IO.Path]::IsPathRooted($target) -or ($target -eq '~')) {
			Set-Location $target
		}
		else {
			Set-Location Join-Path (Split-Path -parent $_) $target
		}
	}
	else {
		Write-Output "This target has not been defined."
	}
}

function List-GoTargets {
	$targets = Get-AllGoTargets
	$targets.GetEnumerator() | Sort-Object Name
}

# ====== Commands ====== #

function go {
	if ($args.Length -eq 0) {
		List-GoTargets
	}
	else {
		Goto-Target $args[0]
	}
}

function here {
	$target = Convert-Path(Get-Location -PSProvider FileSystem)
	Start-Process explorer "/e,$target"
}
