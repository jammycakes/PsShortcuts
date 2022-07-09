BeforeAll {
    . $PSScriptRoot\common.ps1
    . $modulePath\Reader.ps1
}

Describe "Get-ShortcutFilePath" {
    It "Should handle spaces properly" {
        $locations = Get-ShortcutFilePath "$PSScriptRoot\data\with spaces"
        $locations | Should -Match "\\data\\with spaces"
    }

    It "Should resolve relative paths properly" {
        $location = Get-Location
        $shortcut = Get-ShortcutFilePath "foo\bar"
        $shortcut | Should -Be "$location\foo\bar\.shortcuts"
    }
}

Describe "Get-ShortcutFileLocations" {
    It "Given no parameters, should start at the current directory" {
        Push-Location "$PSScriptRoot\data\with spaces"
        try {
            $locations = Get-ShortcutFileLocations
            $locations[0] | Should -Be "$PSScriptRoot\data\with spaces\.shortcuts"
            $locations[1] | Should -Be "$PSScriptRoot\data\.shortcuts"
        }
        finally {
            Pop-Location
        }
    }

    It "Given an absolute path, should start at that directory" {
        $locations = Get-ShortcutFileLocations "$PSScriptRoot\data\with spaces"
        $locations[0] | Should -Be "$PSScriptRoot\data\with spaces\.shortcuts"
        $locations[1] | Should -Be "$PSScriptRoot\data\.shortcuts"
    }

    It "Given a relative path, should start at that directory" {
        Push-Location $PSScriptRoot
        try {
            $locations = Get-ShortcutFileLocations "data\with spaces"
            $locations[0] | Should -Be "$PSScriptRoot\data\with spaces\.shortcuts"
            $locations[1] | Should -Be "$PSScriptRoot\data\.shortcuts"
        }
        finally {
            Pop-Location
        }
    }

    It "Should include the standard file locations" {
        $locations = Get-ShortcutFileLocations "$PSScriptRoot\data\sub"
        $count = $locations.Length

        $userPath = "$(Get-UserShortcuts)"
        $systemPath = "$(Get-SystemShortcuts)"
        $installedPath = "$(Get-InstalledShortcuts)"

        # Should include the user's file descriptor
        $locations[$count - 3] | Should -Be "$userPath"
        $locations[$count - 2] | Should -Be "$systemPath"
        $locations[$count - 1] | Should -Be "$installedPath"
    }
}

Describe "Read-ShortcutFile" {
    BeforeAll {
        $paths = Read-ShortcutFile "$PsScriptRoot\data\.shortcuts"
    }

    It "Should read the absolute path correctly" {
        $paths["winetc"] | Should -Be "c:\windows\system32\drivers\etc"
    }

    It "Should read the relative path correctly" {
        $paths["subdata"] | Should -Be "$PSScriptRoot\data\with spaces"
    }

    It "Should read the home directory correctly" {
        $paths["home"] | Should -Be $HOME
    }

    It "Should read a nonexistent directory correctly" {
        $paths["nonexistent-relative"] | Should -Be "$PSScriptRoot\data\does not exist"
    }

    It "Should read a nonexistent directory in home correctly" {
        $paths["nonexistent-home"] | Should -Be "$HOME\does not exist"
    }

    It "Should read a nonexistent directory with a dot correctly" {
        $paths["nonexistent-withdot"] | Should -Be "$PSScriptRoot\data\does not exist"
    }

    It "Should read a nonexistent directory with two dots correctly" {
        $paths["nonexistent-withtwodots"] | Should -Be "$PSScriptRoot\does not exist"
    }

    It "Should not read a commented out path" {
        $paths["commented-out"] | Should -Be $null
    }
}

Describe "Read-NonexistentShortcutFile" {
    It "Should return an empty dictionary" {
        $paths = Read-ShortcutFile "$PSScriptRoot\data\does not exist\.shortcuts"
        $paths.Keys.Length | Should -Be $null
    }
}

Describe "Read-AllShortcuts" {
    It "Should prioritise inner shortcuts over outer ones" {
        $shortcuts = Read-AllShortcuts "$PSScriptRoot\data\with spaces"
        $shortcuts["common"] | Should -Match 'inner$'
    }
}

Describe "Get-ShortcutLocation" {
    It "Should resolve recursive shortcuts" {
        $location = Get-ShortcutLocation subdata common -path "$PSScriptRoot\data"
        $location | Should -Be "$PSScriptRoot\data\with spaces\inner"
    }

    It "Should get the location when there are no targets" {
        $location = "$PSScriptRoot\data\with spaces"
        $targets = @()
        $final = Get-ShortcutLocation -path $location -targets $targets
        $final | Should -Be $location
    }

    It "Should resolve an absolute path" {
        $location = Get-ShortcutLocation winetc -Path "$PSScriptRoot\data\with spaces"
        $location | Should -Be "c:\windows\system32\drivers\etc"
    }
}