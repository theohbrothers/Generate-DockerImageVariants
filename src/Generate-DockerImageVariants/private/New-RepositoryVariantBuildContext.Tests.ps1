$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "New-RepositoryVariantBuildContext" -Tag 'Unit' {

    BeforeEach {
        function Get-ContextFileContent {}
        function New-Item {}
        function Out-File {}
    }

    Context 'Parameters' {

        It 'Receives input from pipeline' {
            $variant = @{
                tag = 'foo'
                build_dir = '/path/to/repo/foo'
            }
            Mock Test-Path { $false }
            Mock New-Item {}

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
            Mock Test-Path { $false }
            Mock New-Item {}

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
            Mock Get-ContextFileContent { 'some content' }
            Mock New-Item { $true }
            Mock Out-File {}

            New-RepositoryVariantBuildContext -Variant $variant 6>$null

            Assert-MockCalled New-Item -Times 1 -Scope It
            Assert-MockCalled Out-File -Times 1 -Scope It
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
