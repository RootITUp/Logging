#Requires -Modules psake

###############################################################################
# Dot source the user's customized properties and extension tasks.
###############################################################################
. $PSScriptRoot\build.settings.ps1

Task default -depends Build, Test, Release

Task Build {}

Task Test -depends Build {}

Task Release -depends Build, Test {}