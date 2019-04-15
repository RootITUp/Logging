Get-Module Logging | Remove-Module -Force
$moduleManifestPath = '{0}\..\Logging\Logging.psd1' -f $PSScriptRoot
Import-Module -Name $moduleManifestPath -Force
Set-StrictMode -Version Latest

# These tests verify that Write-Log determines the correct values for the tokens whose values are taken from
# the callstack: 'pathname', 'filename', 'lineno', and 'caller'.
#
# Since Write-Log doesn't produce output directly, we use the File target to generate files containing these
# tokens and then inspect the files to verify that they have the expected contents.
#
# If we call Write-Log directly from within a Pester test, we can't predict exactly what the callstack will be,
# since it will include some of our code and some of Pester's code. This makes it impossible to predict which
# values Write-Log will use for the tokens.
#
# In order to create an environment where we can predict the contents of the callstack, we need to create scripts
# that call Write-Log and then run those scripts using the PowerShell executable. In that environment, we can
# predict the contents of the callstack and therefore what the values of the tokens should be.
#
# Accordingly, these tests use Pester to create scripts that call Write-Log, and then run those scripts using
# the PowerShell executable, instead of calling Write-Log from directly within the tests. These tests will run
# relatively slowly as a result of this.
Describe 'CallerScope' {
    BeforeAll {
        # Set to $true to enable output of additional debugging information for this test code.
        $debugTests = $false

        $logPath = Join-Path -Path $TestDrive -ChildPath 'log.txt'

        $scriptName = 'script.ps1'
        $scriptPath = Join-Path -Path $TestDrive -ChildPath $scriptName

        $codeLineImportModule   = "Import-Module -Name '$moduleManifestPath'"
        $codeLineSetCallerScope = 'Set-LoggingCallerScope -CallerScope {0}'
        $codeLineAddTarget      = ("Add-LoggingTarget -Name 'File' -Configuration @{ Path = '$logPath'; " +
                                   "Format = '[%{pathname}] [%{filename}] [%{lineno}] [%{caller}]' }")
        $codeLineWriteLog       = 'Write-Log -Message ''Test Message'''
        $codeLineRemoveModule   = 'Remove-Module -Name Logging'

        $codeSetup = @(
            $codeLineImportModule
            $codeLineSetCallerScope
            $codeLineAddTarget
        )
        $codeCleanup = @(
            $codeLineRemoveModule
        )

        function InvokePowerShellExe {
            param (
                [string]$Path = $scriptPath,
                [string]$Command
            )

            if ($PSBoundParameters.ContainsKey('Command')) {
                $run = "-Command `"$Command`""
            } else {
                $run = "-File `"$Path`""
            }

            if ($PSVersionTable.PSEdition -eq 'Desktop') {
                $powershell_exe = 'powershell.exe'
            } else {
                $powershell_exe = 'pwsh'
            }
            $powershell_exe = Join-Path -Path $PSHOME -ChildPath $powershell_exe

            $params = @{
                Wait = $true
                NoNewWindow = $true
                FilePath = $powershell_exe
                ArgumentList = @('-NoLogo','-NoProfile','-NonInteractive',$run)
            }

            Start-Process @params
        }

        # Reads through an array of code lines to determine which one contains the line that calls
        # Set-LoggingCallerScope, then replaces the "{0}" on that line with the value of the $Scope
        # parameter and returns a new array containing the modified line.
        function InjectScopeInCode {
            param (
                [string[]]$Code,
                [int]$Scope
            )

            # Clone the array that contains the code so that we don't modify the
            # original when we inject the scope.
            $injectedCode = $Code.Clone()

            $scopeIndex = $injectedCode.IndexOf($codeLineSetCallerScope)
            if ($scopeIndex -eq -1) {
                throw "Could not determine where to inject scope [$Scope]."
            }
            $injectedCode[$scopeIndex] = $injectedCode[$scopeIndex] -f $Scope

            if ($debugTests) {
                Write-Host -ForegroundColor Magenta -Object 'Code with scope injected:'
                foreach ($line in $injectedCode) {
                    Write-Host -ForegroundColor Magenta -Object $line
                }
            }

            $injectedCode
        }

        function SetScriptFile {
            param (
                [string]$Path = $scriptPath,
                [string[]]$Code,
                [int]$Scope
            )

            $codeToWrite = $Code
            if ($PSBoundParameters.ContainsKey('Scope')) {
                $codeToWrite = InjectScopeInCode -Code $codeToWrite -Scope $Scope
            }

            Set-Content -Path $Path -Value $codeToWrite
        }

        function InvokeShould {
            param (
                [string]$ExpectedValue
            )

            if ($debugTests) {
                Write-Host -ForegroundColor Magenta -Object 'Contents of log file:'
                Write-Host -ForegroundColor Magenta -Object (Get-Content -Path $logPath)
            }

            $logPath | Should -FileContentMatch ([regex]::Escape($ExpectedValue))
        }
    }

    AfterEach {
        if (Test-Path -Path $logPath) {
            Remove-Item -Path $logPath
        }

        $testScope++
    }

    Context 'Tests that don''t use a wrapper' {
        BeforeAll {
            $codeWriteNoWrapper = $codeSetup + $codeLineWriteLog + $codeCleanup
            $lineNumWriteLog = $codeWriteNoWrapper.IndexOf($codeLineWriteLog) + 1
        }

        Context 'Write-Log called directly rather than from a script file' {
            BeforeAll {
                $testScope = 1
            }

            BeforeEach {
                $injectedCode = InjectScopeInCode -Scope $testScope -Code $codeWriteNoWrapper
                $commands = $injectedCode -join "; "
                InvokePowerShellExe -Command $commands
            }

            It 'Scope 1' {
                InvokeShould "[] [] [1] [<ScriptBlock>]"
            }
        }

        Context 'Script File -> Write-Log' {
            BeforeAll {
                $testScope = 1
            }

            BeforeEach {
                SetScriptFile -Code $codeWriteNoWrapper -Scope $testScope
                InvokePowerShellExe
            }

            It 'Scope 1' {
                InvokeShould "[$scriptPath] [$scriptName] [$lineNumWriteLog] [$scriptName]"
            }
        }

        Context 'Caller Script File -> Script File -> Write-Log' {
            BeforeAll {
                $testScope = 1

                $callerScriptName = 'caller.ps1'
                $callerScriptPath = Join-Path -Path $TestDrive -ChildPath $callerScriptName
                $callerScriptCode = @(
                    "& $scriptPath"
                )
                SetScriptFile -Path $callerScriptPath -Code $callerScriptCode
            }

            BeforeEach {
                SetScriptFile -Code $codeWriteNoWrapper -Scope $testScope
                InvokePowerShellExe -Path $callerScriptPath
            }

            It 'Scope 1 - Script File Calling Write-Log' {
                InvokeShould "[$scriptPath] [$scriptName] [$lineNumWriteLog] [$scriptName]"
            }

            It 'Scope 2 - Caller Script File Calling Script File' {
                InvokeShould "[$callerScriptPath] [$callerScriptName] [1] [$callerScriptName]"
            }
        }
    }

    Context 'Tests that do use a wrapper' {
        BeforeAll {
            $wrapperFunctionName = 'Wrapper'
            $codeLineCallWrapper = $wrapperFunctionName
            $codeLineCallWriteLogInWrapper = "function $wrapperFunctionName { $codeLineWriteLog }"
        }

        Context 'Script File -> Wrapper -> Write-Log' {
            BeforeAll {
                $testScope = 1
            }

            BeforeEach {
                $code =
                    $codeSetup +
                    $codeLineCallWriteLogInWrapper +
                    $codeLineCallWrapper +
                    $codeCleanup
                SetScriptFile -Code $code -Scope $testScope
                InvokePowerShellExe
            }

            It 'Scope 1 - Wrapper Calling Write-Log' {
                $lineNumWriteLogCall = $code.IndexOf($codeLineCallWriteLogInWrapper) + 1
                InvokeShould "[$scriptPath] [$scriptName] [$lineNumWriteLogCall] [$wrapperFunctionName]"
            }

            It 'Scope 2 - Script File Calling Wrapper' {
                $lineNumWrapperCall = $code.IndexOf($codeLineCallWrapper) + 1
                InvokeShould "[$scriptPath] [$scriptName] [$lineNumWrapperCall] [$scriptName]"
            }
        }

        Context 'Script File -> Business Logic -> Wrapper -> Write-Log' {
            BeforeAll {
                $testScope = 1
            }

            BeforeEach {
                $businessLogicFunctionName = 'BusinessLogic'
                $codeLineCallBusinessLogicInScript = $businessLogicFunctionName
                $codeLineCallWrapperInBusinessLogic =
                    "function $businessLogicFunctionName { $codeLineCallWrapper }"
                $code =
                    $codeSetup +
                    $codeLineCallWriteLogInWrapper +
                    $codeLineCallWrapperInBusinessLogic +
                    $codeLineCallBusinessLogicInScript +
                    $codeCleanup
                SetScriptFile -Code $code -Scope $testScope
                InvokePowerShellExe
            }

            It 'Scope 1 - Wrapper Calling Write-Log' {
                $lineNumWriteLogCall = $code.IndexOf($codeLineCallWriteLogInWrapper) + 1
                InvokeShould "[$scriptPath] [$scriptName] [$lineNumWriteLogCall] [$wrapperFunctionName]"
            }

            It 'Scope 2 - Business Logic Calling Wrapper' {
                $lineNumWrapperCall = $code.IndexOf($codeLineCallWrapperInBusinessLogic) + 1
                InvokeShould "[$scriptPath] [$scriptName] [$lineNumWrapperCall] [$businessLogicFunctionName]"
            }

            It 'Scope 3 - Script File Calling Business Logic' {
                $lineNumBusinessLogicCall = $code.IndexOf($codeLineCallBusinessLogicInScript) + 1
                InvokeShould "[$scriptPath] [$scriptName] [$lineNumBusinessLogicCall] [$scriptName]"
            }
        }
    }
}
