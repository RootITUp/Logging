#Requires -Modules psake

Properties {
    $ModuleName = 'Logging'

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
    $SrcDir = '{0}\{1}' -f $PSScriptRoot, $ModuleName

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
    $ReleaseDir = '{0}\Release' -f $PSScriptRoot

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
    $TestDir = '{0}\test' -f $PSScriptRoot

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
    $TestOutputFile = '{0}\TestResults.xml' -f $PSScriptRoot

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
    $DocRoot = '{0}\docs' -f $PSScriptRoot

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
    $DefaultLocale = 'en-US'

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
    $ModuleDir = '{0}\{1}' -f $ReleaseDir, $ModuleName

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssigments', '')]
    $UpdatableHelpDir = '{0}\UpdatableHelp' -f $ReleaseDir
}

Task default -depends BuildHelp, Test

Task Build -depends Clean, Init -requiredVariables SrcDir, ReleaseDir {
    Copy-Item -Recurse -Force -Path $SrcDir -Destination $ReleaseDir | Out-Null
}

Task BuildHelp -depends Build -requiredVariables $DocRoot {
    Import-Module platyPS
    Import-Module -Global -Force $ModuleDir\$ModuleName.psd1

    if (Get-ChildItem -Path $DocRoot -Recurse -Filter *.md) {
        Get-ChildItem -Path $DocRoot -Directory | ForEach-Object {
            Update-MarkdownHelp -Path $_.FullName | Out-Null
        }
    } else {
        New-MarkdownHelp -Module $ModuleName -Locale $DefaultLocale -OutputFolder $DocRoot\$DefaultLocale -WithModulePage
    }

    foreach ($locale in (Get-ChildItem -Path $DocRoot -Directory).Name) {
        New-ExternalHelp -Path $DocRoot\$locale -OutputPath $ModuleDir\$locale -Force | Out-Null
        New-ExternalHelpCab -CabFilesFolder $ModuleDir\$locale -LandingPagePath $DocRoot\$locale\$ModuleName.md -OutputFolder $UpdatableHelpDir | Out-Null
    }

    Remove-Module $ModuleName
}

Task Test -depends Build -requiredVariables $TestDir {
    $TestResults = if ($env:APPVEYOR) {
        Import-Module Pester
        Invoke-Pester -Path $TestDir -OutputFormat NUnitXml -OutputFile $TestOutputFile -PassThru

        $uri = 'https://ci.appveyor.com/api/testresults/nunit/{0}' -f $env:APPVEYOR_JOB_ID
        (New-Object 'System.Net.WebClient').UploadFile($uri, $TestOutputFile)
    } else {
        Invoke-Pester -Path $TestDir -PassThru
    }

    if($TestResults.FailedCount -gt 0) {
        Throw 'Build Failed! ({0} failed Pester tests)' -f $TestResults.FailedCount
    }
}

Task Release -depends Build, Test {
    Import-Module PowershellGet
    Publish-Module -NuGetApiKey $env:APPVEYOR_NUGET_API_KEY -Path $ModuleDir
}

Task Init -requiredVariables $ReleaseDir {
    if (-not (Test-Path $ReleaseDir)) {
        New-Item -ItemType Directory -Path $ReleaseDir | Out-Null
    }
}

Task Clean -requiredVariables $ReleaseDir {
    if (Test-Path $ReleaseDir) {
        Remove-Item -Recurse -Force -Path $ReleaseDir | Out-Null
    }
}