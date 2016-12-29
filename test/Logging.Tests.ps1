$manifestPath   = '{0}\..\Logging\Logging.psd1' -f $PSScriptRoot
$changeLogPath  = '{0}\..\CHANGELOG.md' -f $PSScriptRoot

Describe -Tags 'VersionChecks' 'Logging manifest and changelog' {
    $script:manifest = $null
    It 'has a valid manifest' {
        {
            $script:manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It 'has a valid name in the manifest' {
        $script:manifest.Name | Should Be Logging
    }

    It 'has a valid guid in the manifest' {
        $script:manifest.Guid | Should Be '25a60f1d-85dd-4ad6-9efc-35fd3894f6c1'
    }

    It 'has a valid version in the manifest' {
        $script:manifest.Version -as [Version] | Should Not BeNullOrEmpty
    }

    $script:changelogVersion = $null
    It 'has a valid version in the changelog' {

        foreach ($line in (Get-Content $changeLogPath)) {
            if ($line -match '^\D*(?<Version>(\d+\.){1,3}\d+)') {
                $script:changelogVersion = $matches.Version
                break
            }
        }
        $script:changelogVersion                | Should Not BeNullOrEmpty
        $script:changelogVersion -as [Version]  | Should Not BeNullOrEmpty
    }

    It 'changelog and manifest versions are the same' {
        $script:changelogVersion -as [Version] | Should be ( $script:manifest.Version -as [Version] )
    }

}
