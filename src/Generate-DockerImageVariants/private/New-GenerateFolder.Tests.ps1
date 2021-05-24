$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "New-GenerationFolder" -Tag 'Unit' {

    Context 'Behavior' {

        $GenerateConfig = @{
            GENERATE_BASE_DIR = 'foo'
            GENERATE_DEFINITIONS_DIR = 'bar'
            GENERATE_TEMPLATES_DIR = 'baz'
            MODULE_SAMPLES_GENERATE_DEFINITIONS_DIR = 'foobar'
            MODULE_SAMPLES_GENERATE_TEMPLATES_DIR = 'foobaz'
        }

        It 'Creates folders and files' {
            Mock Test-Path { $false }
            Mock Get-ChildItem {
                [pscustomobject]@{
                    Name = 'foo.ps1'
                    FullName = '/path/to/foo.ps1'
                }
            }
            Mock New-Item {
                [pscustomobject]@{
                    Name = 'somedef.ps1'
                    FullName = '/path/to/repository/somedef.ps1'
                }
            }
            Mock Get-Content { 'somecontent' }
            function Out-File {}
            Mock Out-File {}

            New-GenerationFolder -GenerateConfig $GenerateConfig 6>$null

            Assert-MockCalled New-Item -Times 5
            Assert-MockCalled Get-Content -Times 2
            Assert-MockCalled Out-File -Times 2
        }

        It 'Does not recreate existing folders and files' {
            Mock Test-Path { $true }
            Mock Get-ChildItem {
                [pscustomobject]@{
                    Name = 'foo.ps1'
                    FullName = '/path/to/foo.ps1'
                }
            }
            Mock New-Item {}

            $consoleOutput = New-GenerationFolder -GenerateConfig $GenerateConfig 6>&1
            $consoleOutput | %  {
                $_ | Should -Match 'Not creating'
            }
        }

    }

}
