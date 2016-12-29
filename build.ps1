param (
    [string[]] $Task = 'default'
)

if ($env:APPVEYOR) {
    $TestOutputFile = Join-Path $PWD -ChildPath "$PSScriptRoot\TestResults.xml"

    Invoke-psake .\build.psake.ps1 -taskList Build, Test, Release -properties @{TestOutputFile = $TestOutputFile}

    if ($psake.build_success -and (Test-Path $TestOutputFile)) {
        Add-AppveyorMessage -Message 'Uploading Test Results' -Category Information
        $uri = 'https://ci.appveyor.com/api/testresults/nunit/{0}' -f $env:APPVEYOR_JOB_ID
        Invoke-RestMethod -Method POST -Uri $uri -InFile $TestOutputFile -ContentType 'multipart/form-data'
    } else {
        $Error | Format-List * -Force
        exit 1
    }
} else {
    Invoke-psake .\build.psake.ps1 -taskList $Task
}