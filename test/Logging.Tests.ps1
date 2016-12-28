$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$manifestPath   = "$here\..\src\Logging.psd1"
$changeLogPath = "$here\..\CHANGELOG.md"

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

        foreach ($line in (Get-Content $changeLogPath))
        {
            if ($line -match '^\D*(?<Version>(\d+\.){1,3}\d+)')
            {
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

    if (Get-Command git.exe -ErrorAction SilentlyContinue)
    {
        $skipVersionTest = -not [bool]((git remote -v 2>&1) -match 'github.com/EsOsO/')
        $script:tagVersion = $null
        It 'is tagged with a valid version' -skip:$skipVersionTest {
            $thisCommit = git.exe log --decorate --oneline HEAD~1..HEAD

            if ($thisCommit -match 'tag:\s*(\d+(?:\.\d+)*)')
            {
                $script:tagVersion = $matches[1]
            }

            $script:tagVersion                  | Should Not BeNullOrEmpty
            $script:tagVersion -as [Version]    | Should Not BeNullOrEmpty
        }

        It 'all versions are the same' -skip:$skipVersionTest {
            $script:changelogVersion -as [Version] | Should be ( $script:manifest.Version -as [Version] )
            $script:manifest.Version -as [Version] | Should be ( $script:tagVersion -as [Version] )
        }

    }
}