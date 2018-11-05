function Get-CallerNameInScope {
    [CmdletBinding()]
    param()

    (Get-PSCallStack)[$Logging.CallerScope + 1].Command
}