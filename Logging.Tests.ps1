Import-Module Logging

Describe 'Write-Log' {
    Mock Write-Host -Verifiable -ModuleName Logging
    Mock Out-File -Verifiable -ModuleName Logging

    Context 'Logging disabled' {
        $Global:Logging = @{Destinations = @{}}

        It "doesn't print anything" {
            Write-Log 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }

        It "doesn't print anything [ERROR]" {
            Write-Log -Level ERROR 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }

        It "doesn't print anything [WARN]" {
            Write-Log -Level WARN 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }
        
        It "doesn't print anything [INFO]" {
            Write-Log -Level INFO 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }
        
        It "doesn't print anything [DEBUG]" {
            Write-Log -Level DEBUG 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }

    }

    Context 'Console logging enabled [ERROR]' {
        $Global:Logging = @{Destinations = @{Console = @{Level = 'ERROR'}}}

        It 'print message to console [ERROR]' {
            Write-Log -Level ERROR 'Test'
            Assert-MockCalled Write-Host -ModuleName Logging -Scope It
        }

        It "doesn't print message to console [WARN]" {
            Write-Log 'Test' -Level WARN
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }

        It "doesn't print message to console [INFO]" {
            Write-Log -Level INFO 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }

        It "doesn't print message to console [DEBUG]" {
            Write-Log -Level DEBUG 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }
    }

    Context 'Console logging enabled [WARN]' {
        $Global:Logging = @{Destinations = @{Console = @{Level = 'WARN'}}}

        It 'print message to console [ERROR]' {
            Write-Log -Level ERROR 'Test'
            Assert-MockCalled Write-Host -ModuleName Logging -Scope It
        }

        It 'print message to console [WARN]' {
            Write-Log 'Test' -Level WARN
            Assert-MockCalled Write-Host -ModuleName Logging -Scope It
        }

        It "doesn't print message to console [INFO]" {
            Write-Log -Level INFO 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }

        It "doesn't print message to console [DEBUG]" {
            Write-Log -Level DEBUG 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }
    }

    Context 'Console logging enabled [INFO]' {
        $Global:Logging = @{Destinations = @{Console = @{Level = 'INFO'}}}

        It 'print message to console [ERROR]' {
            Write-Log -Level ERROR 'Test'
            Assert-MockCalled Write-Host -ModuleName Logging -Scope It
        }

        It 'print message to console [WARN]' {
            Write-Log 'Test' -Level WARN
            Assert-MockCalled Write-Host -ModuleName Logging -Scope It
        }

        It 'print message to console [INFO]' {
            Write-Log -Level INFO 'Test'
            Assert-MockCalled Write-Host -ModuleName Logging -Scope It
        }

        It "doesn't print message to console [DEBUG]" {
            Write-Log -Level DEBUG 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }
    }

    Context 'Console logging enabled [INFO]' {
        $Global:Logging = @{Destinations = @{Console = @{Level = 'DEBUG'}}}

        It 'print message to console [ERROR]' {
            Write-Log -Level ERROR 'Test'
            Assert-MockCalled Write-Host -ModuleName Logging -Scope It
        }

        It 'print message to console [WARN]' {
            Write-Log 'Test' -Level WARN
            Assert-MockCalled Write-Host -ModuleName Logging -Scope It
        }

        It 'print message to console [INFO]' {
            Write-Log -Level INFO 'Test'
            Assert-MockCalled Write-Host -ModuleName Logging -Scope It
        }

        It 'print message to console [DEBUG]' {
            Write-Log -Level DEBUG 'Test'
            Assert-MockCalled Write-Host -ModuleName Logging -Scope It
        }
    }

    Context 'Console logging enabled [ERROR]' {
        $Global:Logging = @{Destinations = @{File = @{Level = 'ERROR'; Path = 'TestDrive:\test.log'}}}

        It 'print message to file [ERROR]' {
            Write-Log -Level ERROR 'Test'
            Assert-MockCalled Write-Host -ModuleName Logging -Scope It
        }

        It "doesn't print message to file [WARN]" {
            Write-Log 'Test' -Level WARN
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }

        It "doesn't print message to file [INFO]" {
            Write-Log -Level INFO 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }

        It "doesn't print message to file [DEBUG]" {
            Write-Log -Level DEBUG 'Test'
            Assert-MockCalled Write-Host 0 -ModuleName Logging -Scope It
        }
    }

}
