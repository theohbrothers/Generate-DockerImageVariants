$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
Set-StrictMode -Version latest
Describe "Generate-DockerImageVariants" -Tag 'Unit' {

    function New-GenerateConfig {}
    function New-GenerationFolder {}
    function Get-Definition {}

    function Get-VariantsPrototype {}
    function Get-FilesPrototype {}
    function Validate-Object {}
    function Populate-GenerateConfig {
        param (
            $GenerateConfig
        )
        $GenerateConfig
    }
    function New-RepositoryVariantBuildContext {}
    function New-RepositoryFile {}

    Context 'Behavior' {

        It 'Initializes the /generate folder' {
            $projectPath = 'foo'
            Mock Test-Path -ParameterFilter { $Path -eq $projectPath } { $true }
            Mock New-GenerationFolder {}

            Generate-DockerImageVariants -ProjectPath $projectPath -Init

            Assert-MockCalled New-GenerationFolder -Times 1 -Scope It
        }

        It 'Gets variants definitions' {
            $projectPath = 'foo'
            Mock Test-Path -ParameterFilter { $Path -eq $projectPath } { $true }
            Mock New-GenerateConfig  {
                $GenerateConfig = [ordered]@{
                    GENERATE_DEFINITIONS_VARIANTS_FILE = 'variants.ps1'
                    GENERATE_DEFINITIONS_FILES_FILE = 'files.ps1'
                    VARIANTS = @()
                    # VARIANTS_SHARED = @{}
                    # FILES = @()
                }
                $GenerateConfig
            }
            Mock Test-Path -ParameterFilter { $Path -eq 'files.ps1' } { $false }
            Mock Get-Definition {}

            Generate-DockerImageVariants -ProjectPath $projectPath

            Assert-MockCalled Get-Definition -Times 2 -Scope It
        }

        It 'Gets variants and files definitions' {
            $projectPath = 'foo'
            Mock Test-Path -ParameterFilter { $Path -eq $projectPath } { $true }
            Mock New-GenerateConfig  {
                $GenerateConfig = [ordered]@{
                    GENERATE_DEFINITIONS_VARIANTS_FILE = 'variants.ps1'
                    GENERATE_DEFINITIONS_FILES_FILE = 'files.ps1'
                    VARIANTS = @()
                    # VARIANTS_SHARED = @{}
                    # FILES = @()
                }
                $GenerateConfig
            }
            Mock Test-Path -ParameterFilter { $Path -eq 'files.ps1' } { $true }
            Mock Get-Definition {}

            Generate-DockerImageVariants -ProjectPath $projectPath

            Assert-MockCalled Get-Definition -Times 3 -Scope It
        }

        It 'Gets variants and files definitions' {
            $projectPath = 'foo'
            Mock Test-Path -ParameterFilter { $Path -eq $projectPath } { $true }
            Mock New-GenerateConfig  {
                $GenerateConfig = [ordered]@{
                    GENERATE_DEFINITIONS_VARIANTS_FILE = 'variants.ps1'
                    GENERATE_DEFINITIONS_FILES_FILE = 'files.ps1'
                    VARIANTS = @()
                    # VARIANTS_SHARED = @{}
                    # FILES = @()
                }
                $GenerateConfig
            }
            Mock Test-Path -ParameterFilter { $Path -eq 'files.ps1' } { $true }
            Mock Get-Definition {}

            Generate-DockerImageVariants -ProjectPath $projectPath

            Assert-MockCalled Get-Definition -Times 3 -Scope It
        }

        It 'Validates variants definitions' {
            $projectPath = 'foo'
            Mock Test-Path -ParameterFilter { $Path -eq $projectPath } { $true }
            Mock New-GenerateConfig  {
                $GenerateConfig = [ordered]@{
                    GENERATE_DEFINITIONS_VARIANTS_FILE = 'variants.ps1'
                    GENERATE_DEFINITIONS_FILES_FILE = 'files.ps1'
                    VARIANTS = @()
                    # VARIANTS_SHARED = @{}
                    # FILES = @()
                }
                $GenerateConfig
            }
            Mock Test-Path -ParameterFilter { $Path -eq 'files.ps1' } { $true }
            Mock Validate-Object{}

            Generate-DockerImageVariants -ProjectPath $projectPath

            Assert-MockCalled Validate-Object -Times 1 -Scope It
        }

        It 'Validates variants and files definition' {
            $projectPath = 'foo'
            Mock Test-Path -ParameterFilter { $Path -eq $projectPath } { $true }
            Mock New-GenerateConfig  {
                $GenerateConfig = [ordered]@{
                    GENERATE_DEFINITIONS_VARIANTS_FILE = 'variants.ps1'
                    GENERATE_DEFINITIONS_FILES_FILE = 'files.ps1'
                    VARIANTS = @()
                    # VARIANTS_SHARED = @{}
                    FILES = @(
                        'foo'
                    )
                }
                $GenerateConfig
            }
            Mock Test-Path -ParameterFilter { $Path -eq 'files.ps1' } { $true }
            Mock Validate-Object {}

            Generate-DockerImageVariants -ProjectPath $projectPath

            Assert-MockCalled Validate-Object -Times 2 -Scope It
        }

        It 'Populates variants and files definition' {
            $projectPath = 'foo'
            Mock Test-Path -ParameterFilter { $Path -eq $projectPath } { $true }
            Mock New-GenerateConfig  {
                $GenerateConfig = [ordered]@{
                    GENERATE_DEFINITIONS_VARIANTS_FILE = 'variants.ps1'
                    GENERATE_DEFINITIONS_FILES_FILE = 'files.ps1'
                    VARIANTS = @()
                    # VARIANTS_SHARED = @{}
                    FILES = @(
                        'foo'
                    )
                }
                $GenerateConfig
            }
            Mock Test-Path -ParameterFilter { $Path -eq 'files.ps1' } { $true }
            Mock Populate-GenerateConfig {
                param (
                    $GenerateConfig
                )
                $GenerateConfig
            }

            Generate-DockerImageVariants -ProjectPath $projectPath

            Assert-MockCalled Populate-GenerateConfig -Times 1 -Scope It
        }

        It 'Generates target repository variant build context' {
            $projectPath = 'foo'
            Mock Test-Path -ParameterFilter { $Path -eq $projectPath } { $true }
            Mock New-GenerateConfig  {
                $GenerateConfig = [ordered]@{
                    GENERATE_DEFINITIONS_VARIANTS_FILE = 'variants.ps1'
                    GENERATE_DEFINITIONS_FILES_FILE = 'files.ps1'
                    VARIANTS = @(
                        @{
                            tag = 'foo'
                        }
                    )
                    # VARIANTS_SHARED = @{}
                    # FILES = @()
                }
                $GenerateConfig
            }
            Mock New-RepositoryVariantBuildContext {}

            Generate-DockerImageVariants -ProjectPath $projectPath

            Assert-MockCalled New-RepositoryVariantBuildContext -Times 1 -Scope It
        }

        It 'Generates target repository files' {
            $projectPath = 'foo'
            Mock Test-Path -ParameterFilter { $Path -eq $projectPath } { $true }
            Mock New-GenerateConfig  {
                $GenerateConfig = [ordered]@{
                    GENERATE_DEFINITIONS_VARIANTS_FILE = 'variants.ps1'
                    GENERATE_DEFINITIONS_FILES_FILE = 'files.ps1'
                    VARIANTS = @()
                    # VARIANTS_SHARED = @{}
                    FILES = @(
                        'foo'
                    )
                }
                $GenerateConfig
            }
            Mock Test-Path -ParameterFilter { $Path -eq 'files.ps1' } { $true }
            Mock New-RepositoryFile {}

            Generate-DockerImageVariants -ProjectPath $projectPath

            Assert-MockCalled New-RepositoryFile -Times 1 -Scope It
        }

    }
}
