$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "New-RepositoryFile" -Tag 'Unit' {

    function Get-ContentFromTemplate {}

    Context 'Parameters' {

        It 'Receives input from pipeline' {
            $File = @{
                file = '/path/to/foo'
                templateFile = '/path/to/bar.ps1'
            }
            Mock Split-Path {
                '/path/to'
            }
            Mock Test-Path { $true }
            Mock Get-ContentFromTemplate { 'some content' }
            function Out-File {}
            Mock Out-File {}

            $file | New-RepositoryFile  6>$null

            Assert-MockCalled Out-File -Times 1
        }

    }

    Context 'Behavior' {

        It "Creates a file's folder if it does not exist" {
            $File = @{
                file = '/path/to/foo'
                templateFile = '/path/to/bar.ps1'
            }
            Mock Split-Path {
                '/path/to'
            }
            Mock Test-Path { $false }
            Mock New-Item { $true }
            Mock Get-ContentFromTemplate {}
            function Out-File {}
            Mock Out-File {}

            New-RepositoryFile -File $file 6>$null

            Assert-MockCalled New-Item -Times 1
        }

        It "Creates a file" {
            $File = @{
                file = '/path/to/foo'
                templateFile = '/path/to/bar.ps1'
            }
            Mock Split-Path {
                '/path/to'
            }
            Mock Test-Path { $true }
            Mock Get-ContentFromTemplate {}
            function Out-File {}
            Mock Out-File {}

            New-RepositoryFile -File $file 6>$null

            Assert-MockCalled Get-ContentFromTemplate -Times 1
        }

    }

}
