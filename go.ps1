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
	if (Test-Path $local -PathType Leaf) {
		$dirs += @($local)
	}
	if (Test-Path $system -PathType Leaf) {
		$dirs += @($system)
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
				if ([System.IO.Path]::IsPathRooted($target)) {
					return $target
				}
				else {
					return Join-Path (Split-Path -parent $_) $target
				}
			}
		}
	}
}

function Goto-Target($targetName) {
	$target = Get-GoTarget($targetName)
	if ($target) {
		Set-Location $target
	}
}

function go ($target) {
	Goto-Target $target
}
