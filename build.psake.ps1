function Update-AdditionalReleaseArtifact {
    param(
        [string] $Version,
        [string] $CommitDate
    )

    $PSVersion = $Version -replace '^(\d+\.\d+\.\d+).*$', '$1'
    Write-Host ('Updating Module Manifest version number to: {0}' -f $PSVersion)
    Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $PSVersion

    Write-Host 'Getting release notes'
    $ReleaseDescription = (gc $ReleaseFile) -join "`r`n"
    Clear-Content -Path $ReleaseFile

    if ($env:APPVEYOR) {
        Set-AppveyorBuildVariable -Name ReleaseDescription -Value $ReleaseDescription
    }

    $Changelog = (gc $ChangelogFile | select -Skip 2) -join "`r`n"

    "# CHANGELOG`r`n" | Out-File $ChangelogTemp -Encoding ascii
    ("## {0} ({1})`r`n" -f $Version, $CommitDate) | Out-File $ChangelogTemp -Append -Encoding ascii
    ("{0}`r`n" -f $ReleaseDescription) | Out-File $ChangelogTemp -Append -Encoding ascii
    ("{0}`r`n" -f $Changelog) | Out-File $ChangelogTemp -Append -Encoding ascii

    Copy-Item $ChangelogTemp $ChangelogFile -Force
}

Properties {
    $BranchName = $env:GitVersion_BranchName
    $SemVer = $env:GitVersion_SemVer
    $StableVersion = $env:GitVersion_MajorMinorPatch

    $TestsFolder = '.\Tests'
    $TestsFile = Join-Path $env:BHBuildOutput ('tests-{0}-{1}.xml' -f $env:GitVersion_ShortSha, $SemVer)

    $Artifact = '{0}-{1}.zip' -f $env:BHProjectName.ToLower(), $SemVer
    $BuildBaseModule = Join-Path $env:BHBuildOutput $env:BHProjectName
    $BuildVersionedModule = Join-Path $BuildBaseModule $StableVersion
    $ArtifactPath = Join-Path $env:BHBuildOutput $Artifact

    $ReleaseFile = Join-Path $env:BHProjectPath 'docs\RELEASE.md'
    $ChangelogFile = Join-Path $env:BHProjectPath 'docs\CHANGELOG.md'
    $ChangelogTemp = Join-Path $env:BHBuildOutput 'CHANGELOG.md.tmp'

    Import-Module $env:BHPSModuleManifest -Global
    $ExportedFunctions = Get-Command -Module $env:BHProjectName | select -ExpandProperty Name
    Remove-Module $env:BHProjectName -Force
}

FormatTaskName (('-' * 25) + ('[ {0,-28} ]') + ('-' * 25))

Task Default -Depends PublishModule, Build

Task Init {
    Set-Location $env:BHProjectPath

    New-Item -Path $env:BHBuildOutput -ItemType Directory | Out-Null

    Write-Host ('Working folder: {0}' -f $PWD)
    Write-Host ('Build output: {0}' -f $env:BHBuildOutput)
    Write-Host ('Git Version: {0}' -f $SemVer)
    Write-Host ('Git Version (Stable): {0}' -f $StableVersion)
    Write-Host ('Git Branch: {0}' -f $BranchName)

    Exec {git config --global credential.helper store}

    Add-Content "$HOME\.git-credentials" "https://$($env:APPVEYOR_PERSONAL_ACCESS_TOKEN):x-oauth-basic@github.com`n"

    # Exec {git config --global user.email "$env:APPVEYOR_GITHUB_EMAIL"}
    Exec {git config --global user.name "$env:APPVEYOR_GITHUB_USERNAME"}

    if ($env:APPVEYOR) {
        Set-AppveyorBuildVariable -Name 'ReleaseVersion' -Value $SemVer
    }

    $PendingChanges = git status --porcelain
    if ($null -ne $PendingChanges) {
        throw 'You have pending changes, aborting release'
    }

    Write-Host 'Git: Fetchin origin'
    Exec {git fetch origin}

    Write-Host "Git: Merging origin/$BranchName"
    Exec {git merge origin/$BranchName --ff-only}
}

Task CodeAnalisys -Depends Init {
    Write-Host 'ScriptAnalyzer: Running'
    Invoke-ScriptAnalyzer -Path $env:BHModulePath -Recurse -Severity Warning
}

Task Tests -Depends CodeAnalisys {
    $TestResults = Invoke-Pester -Path $TestsFolder -PassThru -OutputFormat NUnitXml -OutputFile $TestsFile

    switch ($env:BHBuildSystem) {
        'AppVeyor' {
            Get-ChildItem -Path $env:BHBuildOutput -Filter 'tests-*.xml' -File | ForEach-Object {
                (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", "$($_.FullName)")
            }
        }
        Default {
            Write-Warning "Publish test result not implemented for build system '$($ENV:BHBuildSystem)'"
        }
    }

    if ($TestResults.FailedCount -gt 0) {
        Write-Error "Build failed. [$($TestResults.FailedCount) Errors]"
    }
}

Task BuildDocs -Depends Tests {
    Import-Module $env:BHPSModuleManifest -Global

    Write-Host 'BuildDocs: Generating Help for exported functions'
    New-MarkdownHelp -Module $env:BHProjectName -OutputFolder .\docs\functions -Force

    Copy-Item -Path .\header-mkdocs.yml -Destination mkdocs.yml -Force
    $ExportedFunctions | %{
        ("    - {0}: {0}.md" -f $_) | Out-File .\mkdocs.yml -Append -Encoding ascii
    }

    Remove-Module $env:BHProjectName -Force

    Write-Host 'Git: Committing updated docs'
    Exec {git add --all}
    Exec {git commit -am "Updated docs [skip ci]" --allow-empty}
}

Task IncrementVersion -Depends BuildDocs {
    Update-AdditionalReleaseArtifact -Version $SemVer -CommitDate $env:GitVersion_CommitDate

    Write-Host 'Git: Committing new release'
    Exec {git commit -am "Create release $SemVer [skip ci]" --allow-empty}

    Write-Host 'Git: Tagging branch'
    Exec {git tag $SemVer}

    if ($LASTEXITCODE -ne 0) {
        Exec {git reset --hard HEAD^}
        throw 'No changes detected since last release'
    }

    Write-Host 'Git: Pushing tags to origin'
    Exec {git push -q origin $BranchName --tags}

    Pop-Location
}

Task Build -Depends IncrementVersion {
    if (-not (Test-Path $BuildBaseModule)) {New-Item -Path $BuildBaseModule -ItemType Directory | Out-Null}
    if (-not (Test-Path $BuildVersionedModule)) {New-Item -Path $BuildVersionedModule -ItemType Directory | Out-Null}

    Write-Host "Build: Copying module to $ArtifactFolder"
    Copy-Item -Path $env:BHModulePath\* -Destination $BuildVersionedModule -Recurse

    # Write-Host "Build: Generating catalog file"
    # $CatalogFilePath = '{0}\{1}.cat' -f $BuildVersionedModule, $env:BHProjectName
    # New-FileCatalog -CatalogVersion 2 -CatalogFilePath $CatalogFilePath -Path $env:BHModulePath

    Write-Host "Build: Compressing release to $ArtifactPath"
    Compress-Archive -Path $BuildBaseModule -DestinationPath $ArtifactPath

    Write-Host "Build: Pushing release to Appveyor"
    Push-AppveyorArtifact -Path $ArtifactPath
}

Task PublishModule -Depends Build -precondition {$BranchName -eq 'master'} {
    Write-Host "PublishModule: Publishing module to powershellgallery"
    Publish-Module -Path $BuildVersionedModule -NuGetApiKey $env:APPVEYOR_NUGET_API_KEY
}
