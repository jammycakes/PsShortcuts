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

function Get-LocalGoTargetDescriptor {
	$thisdir = Get-Location
	return Join-Path $thisdir '.go'
}

function Get-InstalledGoTargetDescriptor {
	$thisdir = Split-Path -Parent $MyInvocation.ScriptName
	return Join-Path $thisdir '.go'
}

function Get-GoTargetFromFile($targetName, $fileName) {
	Get-Content $fileName | foreach {
		$bits = $_ -split '=',2
		if (($bits.length -eq 2) -and ($bits[0] -eq $targetName)) {
			return $bits[1]
		}
	}
}

function Get-GoTarget($targetName) {
	$found = $FALSE
	Get-AllGoTargetDescriptors | foreach -process {
		$target = Get-GoTargetFromFile $targetName $_
		if ($target) {
			if (-not $found) {
				$found = $TRUE
				if ([System.IO.Path]::IsPathRooted($target) -or $target.StartsWith('http://') -or $target.StartsWith('https://') -or ($target -eq '~')) {
					return $target
				}
				else {
					return Join-Path (Split-Path -parent $_) $target
				}
			}
		}
	}
}

function List-GoTargets {
	Get-AllGoTargetDescriptors | foreach -process {
		Get-Content $_ | foreach {
			$bits = $_ -split '=',2
			if ($bits.length -eq 2) {
				if ($bits[0].length -gt 15) {
					Write-Output $bits[0]
					Write-Output ('                ' + $bits[1])
				}
				else {
					Write-Output ($bits[0]+(New-Object String ' ',(16-$bits[0].Length)) + $bits[1])
				}
			}
		}
	}
}

function Goto-Target($targetName) {
	$target = Get-GoTarget($targetName)
	if ($target) {
		if ($target.StartsWith('http://') -or $target.StartsWith('https://')) {
			Start-Process $target
		}
		else {
			Set-Location $target
		}
	}
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
