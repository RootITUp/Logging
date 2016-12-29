Properties {
    $ModuleName = 'Logging'
    $SrcDir = '{0}\{1}' -f $PSScriptRoot, $ModuleName
    $ReleaseDir = '{0}\Release' -f $PSScriptRoot
    $TestDir = '{0}\test' -f $PSScriptRoot
    $TestOutputFile = '{0}\TestResults.xml' -f $PSScriptRoot
}