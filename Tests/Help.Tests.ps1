Remove-Module Logging -Force -ErrorAction SilentlyContinue

$ManifestPath = '{0}\..\Logging\Logging.psd1' -f $PSScriptRoot
$ChangeLogPath = '{0}\..\CHANGELOG.md' -f $PSScriptRoot

Import-Module $ManifestPath -Force

Describe "Help tests for $moduleName" -Tags Build {

    $Functions = Get-Command -Module Logging -CommandType Function

    foreach ($Function in $Functions) {
        $help = Get-Help $Function.name
        Context $help.name {
            It "Has a HelpUri" {
                $Function.HelpUri | Should Not BeNullOrEmpty
            }

            It "Has related Links" {
                $help.relatedLinks.navigationLink.uri.count | Should BeGreaterThan 0
            }

            It "Has a description" {
                $help.description | Should Not BeNullOrEmpty
            }

            It "Has an example" {
                $help.examples | Should Not BeNullOrEmpty
            }

            foreach ($parameter in $help.parameters.parameter) {
                if ($parameter -notmatch 'whatif|confirm') {
                    It "Has a Parameter description for '$($parameter.name)'" {
                        $parameter.Description.text | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}
