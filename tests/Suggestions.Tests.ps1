BeforeAll {
    . $PSScriptRoot\common.ps1
    . $modulePath\Suggestions.ps1
}

Describe "Get-Suggestions-ForLocation" {
    It "Should get the targets" {
        $location = "$PSScriptRoot\data\with spaces"
        $targets = @()
        $lastWord = ""
        Get-Suggestions-ForLocation $location $targets $lastWord | Should -Contain "winetc"
    }
}

Describe "Get-Suggestions-ForTabExpansion" {
    It "Should return suggestions" {
        $location = "$PSScriptRoot\data\with spaces"
        $suggestions = Get-Suggestions-ForTabExpansion $location "goto " ""
        $suggestions | Should -Contain "winetc"
    }
}