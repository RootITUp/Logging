Properties {
    # Find the build folder based on build system
    $LINES = '----------------------------------------------------------------------'

    $ProjectRoot = $ENV:BHProjectPath

    if (-not $ProjectRoot) {
        $ProjectRoot = $PSScriptRoot
    }

    $ModuleFolder = Split-Path -Path $ENV:BHPSModuleManifest -Parent

    $PSVersion = $PSVersionTable.PSVersion.Major

    $Timestamp = Get-date -UFormat "%Y%m%d-%H%M%S"

    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"

    $Verbose = @{ }

    if ($ENV:BHCommitMessage -match "!verbose") {
        $Verbose = @{ Verbose = $True }
    }

    $CurrentVersion = [version](Get-Metadata -Path $env:BHPSModuleManifest)

    $StepVersion = [version] (Step-Version $CurrentVersion)

    $GalleryVersion = Get-NextNugetPackageVersion -Name $env:BHProjectName

    $BuildVersion = $StepVersion

    If ($GalleryVersion -gt $StepVersion) {
        $BuildVersion = $GalleryVersion
    }

    $BuildVersion = [version]::New($BuildVersion.Major, $BuildVersion.Minor, $BuildVersion.Build, $env:BHBuildNumber)

    $BuildDate = Get-Date -UFormat '%Y-%m-%d'

    $ReleaseNotes = "$ProjectRoot\RELEASE.md"

    $ChangeLog = "$ProjectRoot\docs\ChangeLog.md"
}

Task Default -Depends PostDeploy

Task Init {
    $LINES

    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH* | Format-List
    "`n"
    "Current Version: $CurrentVersion`n"
    "Build Version: $BuildVersion`n"
}

Task UnitTests -Depends Init {
    $LINES
    "Running Pre-build unit tests`n"

    $Parameters = @{
        Script = "$ProjectRoot\Tests"
        PassThru = $true
        Tag = 'Unit'
        OutputFormat = 'NUnitXml'
        OutputFile = "$ProjectRoot\$TestFile"
    }

    $TestResults =Invoke-Pester @Parameters

    if ($TestResults.FailedCount -gt 0) {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }

    "`n"

    if ($ENV:BHBuildSystem -eq 'AppVeyor') {
        "Uploading $ProjectRoot\$TestFile to AppVeyor"
        "JobID: $env:APPVEYOR_JOB_ID"

        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path "$ProjectRoot\$TestFile"))
    }

    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue
}

Task Build -Depends UnitTests {
    $LINES

    "Populating AliasesToExport and FunctionsToExport"
    # Load the module, read the exported functions and aliases, update the psd1
    $ExportFunctions = Get-Command -Module  $env:BHProjectName | select -ExpandProperty Name
    $ExportAliases = Get-Alias | ? Source -eq $env:BHProjectName

    if ($ExportFunctions) {Set-ModuleFunctions -Name $env:BHPSModuleManifest -FunctionsToExport $ExportFunctions}
    if ($ExportAliases) {Update-Metadata -Path $env:BHPSModuleManifest -PropertyName AliasesToExport -Value $ExportAliases}

    # Bump the module version
    "Bump the module version"
    Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $BuildVersion

    # Update release notes with Version info and set the PSD1 release notes
    $parameters = @{
        Path = $ReleaseNotes
        ErrorAction = 'SilentlyContinue'
    }
    $ReleaseText = (Get-Content @parameters | Where-Object {$_ -notmatch '^# Version '}) -join "`r`n"

    if (-not $ReleaseText) {
        "Skipping realse notes`n"
        "Consider adding a RELEASE.md to your project.`n"
        return
    }

    $Header = "# Version {0} ({1})`r`n" -f $BuildVersion, $BuildDate
    $ReleaseText = $Header + $ReleaseText
    $ReleaseText | Set-Content $ReleaseNotes
    Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ReleaseNotes -Value $ReleaseText

    # Update the ChangeLog with the current release notes
    $releaseparameters = @{
        Path = $ReleaseNotes
        ErrorAction = 'SilentlyContinue'
    }
    $changeparameters = @{
        Path = $ChangeLog
        ErrorAction = 'SilentlyContinue'
    }
    (Get-Content @releaseparameters),"`r`n`r`n", (Get-Content @changeparameters) | Set-Content $ChangeLog
}

Task Test -Depends Build  {
    $LINES
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $parameters = @{
        Script = "$ProjectRoot\Tests"
        PassThru = $true
        OutputFormat = 'NUnitXml'
        OutputFile = "$ProjectRoot\$TestFile"
    }
    $TestResults = Invoke-Pester @parameters

    # In Appveyor?  Upload our tests! #Abstract this into a function?
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        "Uploading $ProjectRoot\$TestFile to AppVeyor"
        "JobID: $env:APPVEYOR_JOB_ID"
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path "$ProjectRoot\$TestFile"))
    }

    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if ($TestResults.FailedCount -gt 0) {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task BuildDocs -depends Test {
    $LINES

    "Loading Module from $ENV:BHPSModuleManifest"
    Remove-Module $ENV:BHProjectName -Force -ea SilentlyContinue
    # platyPS + AppVeyor requires the module to be loaded in Global scope
    Import-Module $ENV:BHPSModuleManifest -force -Global

    #Build YAMLText starting with the header
    $YMLtext = (Get-Content "$ProjectRoot\header-mkdocs.yml") -join "`n"
    $YMLtext = "$YMLtext`n"

    $parameters = @{
        Path = $ReleaseNotes
        ErrorAction = 'SilentlyContinue'
    }
    $ReleaseText = (Get-Content @parameters) -join "`n"

    if ($ReleaseText) {
        $ReleaseText | Set-Content "$ProjectRoot\docs\RELEASE.md"
        $YMLText = "$YMLtext  - Realse Notes: RELEASE.md`n"
    }

    if ((Test-Path -Path $ChangeLog)) {
        $YMLText = "$YMLtext  - Change Log: ChangeLog.md`n"
    }

    $YMLText = "$YMLtext  - Functions:`n"
    # Drain the swamp
    $parameters = @{
        Recurse = $true
        Force = $true
        Path = "$ProjectRoot\docs\functions"
        ErrorAction = 'SilentlyContinue'
    }
    $null = Remove-Item @parameters

    $Params = @{
        Path = "$ProjectRoot\docs\functions"
        type = 'directory'
        ErrorAction = 'SilentlyContinue'
    }
    $null = New-Item @Params

    $Params = @{
        Module = $ENV:BHProjectName
        Force = $true
        OutputFolder = "$ProjectRoot\docs\functions"
        NoMetadata = $true
    }
    New-MarkdownHelp @Params | foreach-object {
        $Function = $_.Name -replace '\.md', ''
        $Part = "    - {0}: functions/{1}" -f $Function, $_.Name
        $YMLText = "{0}{1}`n" -f $YMLText, $Part
        $Part
    }
    $YMLtext | Set-Content -Path "$ProjectRoot\mkdocs.yml"
}

Task Deploy -Depends BuildDocs {
    $LINES

    # Gate deployment
    if (
        $ENV:BHBuildSystem -ne 'Unknown' -and
        $ENV:BHBranchName -eq "master" -and
        $ENV:BHCommitMessage -match '!deploy'
    ) {
        $Params = @{
            Path = $ProjectRoot
            Force = $true
        }

        Invoke-PSDeploy @Verbose @Params
    }
    else {
        "Skipping deployment: To deploy, ensure that...`n" +
        "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
        "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
        "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)"
    }
}

Task PostDeploy -depends Deploy {
    $LINES
    if ($ENV:APPVEYOR_REPO_PROVIDER -notlike 'github') {
        "Repo provider '$ENV:APPVEYOR_REPO_PROVIDER'. Skipping PostDeploy"
        return
    }
    If ($ENV:BHBuildSystem -eq 'AppVeyor') {
        "git config --global credential.helper store"
        cmd /c "git config --global credential.helper store 2>&1"

        Add-Content "$env:USERPROFILE\.git-credentials" "https://$($env:access_token):x-oauth-basic@github.com`n"

        "git config --global user.email"
        cmd /c "git config --global user.email ""${ENV:email}"" 2>&1"

        "git config --global user.name"
        cmd /c "git config --global user.name ""AppVeyor"" 2>&1"

        "git config --global core.autocrlf true"
        cmd /c "git config --global core.autocrlf true 2>&1"
    }

    "git checkout $ENV:BHBranchName"
    cmd /c "git checkout $ENV:BHBranchName 2>&1"

    "git add -A"
    cmd /c "git add -A 2>&1"

    "git commit -m"
    cmd /c "git commit -m ""AppVeyor post-build commit[ci skip]"" 2>&1"

    "git status"
    cmd /c "git status 2>&1"

    "git push origin $ENV:BHBranchName"
    cmd /c "git push origin $ENV:BHBranchName 2>&1"
    # if this is a !deploy on master, create GitHub release
    if (
        $ENV:BHBuildSystem -ne 'Unknown' -and
        $ENV:BHBranchName -eq "master" -and
        $ENV:BHCommitMessage -match '!deploy'
    ) {
        "Publishing Release 'v$BuildVersion' to Github"

        $parameters = @{
            Path = $ReleaseNotes
            ErrorAction = 'SilentlyContinue'
        }
        $ReleaseText = (Get-Content @parameters) -join "`r`n"
                if (-not $ReleaseText) {
            $ReleaseText = "Release version $BuildVersion ($BuildDate)"
        }

        $Body = @{
            "tag_name" = "v$BuildVersion"
            "target_commitish"= "master"
            "name" = "v$BuildVersion"
            "body"= $ReleaseText
            "draft" = $false
            "prerelease"= $false
        } | ConvertTo-Json

        $releaseParams = @{
            Uri = "https://api.github.com/repos/{0}/releases" -f $ENV:APPVEYOR_REPO_NAME
            Method = 'POST'
            Headers = @{
                Authorization = 'Basic ' + [Convert]::ToBase64String(
                    [Text.Encoding]::ASCII.GetBytes($env:access_token + ":x-oauth-basic"));
            }
            ContentType = 'application/json'
            Body = $Body
        }
        $Response = Invoke-RestMethod @releaseParams
        $Response | Format-List *
    }
}