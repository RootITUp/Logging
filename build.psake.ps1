#Requires -Modules psake

###############################################################################
# Dot source the user's customized properties and extension tasks.
###############################################################################
. $PSScriptRoot\build.settings.ps1

Task default -depends Build, Test

Task Build -depends Clean, Init -requiredVariables SrcDir, ReleaseDir {
    Copy-Item -Recurse -Force -Path $SrcDir -Destination $ReleaseDir | Out-Null
}

Task Test -depends Build -requiredVariables $TestDir {
    if ($env:APPVEYOR) {
        Import-Module Pester
        Invoke-Pester -Path $TestDir -OutputFormat NUnitXml -OutputFile $TestOutputFile

        $uri = 'https://ci.appveyor.com/api/testresults/nunit/{0}' -f $env:APPVEYOR_JOB_ID
        Invoke-RestMethod -Method POST -Uri $uri -InFile $TestOutputFile -ContentType 'multipart/form-data'
    } else {
        Invoke-Pester -Path $TestDir
    }
}

Task Release -depends Build, Test {

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