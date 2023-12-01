$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "New-RepositoryVariantBuildContext" -Tag 'Unit' {

    BeforeEach {
        function Get-ContextFileContent {}
        Mock Get-ContextFileContent { 'some content' }
        function Test-Path {}
        Mock Test-Path { $false }
        function New-Item {}
        Mock New-Item {}
        function Set-Content {}
        Mock Set-Content {
            param (
                [string]$Path,
                [string]$Value
            )
            if ($Value -ne (Get-ContextFileContent)) {
                throw
            }
        }
    }

    Context 'Parameters' {

        It 'Receives input from pipeline' {
            $variant = @{
                tag = 'foo'
                build_dir = '/path/to/repo/foo'
            }

            $variant | New-RepositoryVariantBuildContext 6>$null

            Assert-MockCalled New-Item -Times 1 -Scope It

        }

    }

    Context 'Behavior' {

        It "Creates a build context directory" {
            $variant = @{
                tag = 'foo'
                build_dir = '/path/to/repo/foo'
            }

            New-RepositoryVariantBuildContext -Variant $variant 6>$null

            Assert-MockCalled New-Item -Times 1 -Scope It
        }

        It "Creates files from templates" {
            $variant = @{
                build_dir = '/path/to/repo/foo'
                buildContextFiles = @{
                    templates = @{
                        'foo' = @{
                            common = $false
                            includeHeader = $false
                            includeFooter = $false
                            passes = @(
                                @{
                                    generatedFileNameOverride = ''
                                    variables = @{
                                        foo = 'bar'
                                    }
                                }
                            )
                        }
                    }
                }
            }
            Mock Test-Path { $true }
            Mock New-Item { $true }

            New-RepositoryVariantBuildContext -Variant $variant 6>$null

            Assert-MockCalled New-Item -Times 1 -Scope It
            Assert-MockCalled Set-Content -Times 1 -Scope It
        }

        It "Creates files from copies" {
            $variant = @{
                build_dir = '/path/to/repo/foo'
                buildContextFiles = @{
                    copies = @(
                        '/bar'
                    )
                }
            }
            Mock Test-Path { $true }
            Mock Copy-Item {}

            New-RepositoryVariantBuildContext -Variant $variant 6>$null

            Assert-MockCalled Copy-Item -Times 1 -Scope It
        }

    }

}
