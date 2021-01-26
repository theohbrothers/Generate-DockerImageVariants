$PSDefaultParameterValues['New-Item:Force'] = $true
$PSDefaultParameterValues['Get-Item:Force'] = $true
$PROJECT_DIR = Split-Path $PSScriptRoot -Parent
Get-Module Generate-DockerImageVariants | Remove-Module -Force
Import-Module ( Join-Path ( Join-Path ( Join-Path $PROJECT_DIR 'src' ) 'Generate-DockerImageVariants' ) 'Generate-DockerImageVariants.psm1' ) -Force 3>$null

# Generate examples
Describe 'Generate-DockerImageVariants' -Tag 'Integration tests' {

    Context 'Parameters' {

        It 'Outputs version' {
            $versionRegex = 'v\d\.\d\.\d+'

            $version = Generate-DockerImageVariants -Version

            $version -match $versionRegex | Should -Be $true
        }

        It 'Initializes the /generate directory' {
            # Mock project
            $testProjectDir = "TestDrive:\test-project"
            New-Item $testProjectDir -ItemType Directory > $null

            # Expected folders
            $testProjectGenerateDir = Join-Path $testProjectDir 'generate'
            $testProjectGenerateDefinitionsDir = Join-Path $testProjectGenerateDir 'definitions'
            $testProjectGenerateTemplatesDir = Join-Path $testProjectGenerateDir 'templates'

            # Expected definition files
            $testProjectGenerateDefinitionsFiles = Join-Path $testProjectGenerateDefinitionsDir 'FILES.ps1'
            $testProjectGenerateDefinitionsVariants = Join-Path $testProjectGenerateDefinitionsDir 'VARIANTS.ps1'

            # Expected templates files
            $testProjectGenerateTemplatesDockerfile = Join-Path $testProjectGenerateTemplatesDir 'Dockerfile.ps1'
            $testProjectGenerateTemplatesReadmeMd =  Join-Path $testProjectGenerateTemplatesDir 'README.md.ps1'
            $testProjectGenerateTemplatesGitlabCiYml =  Join-Path $testProjectGenerateTemplatesDir '.gitlab-ci.yml.ps1'

            Generate-DockerImageVariants -Init -ProjectPath $testProjectDir > $null

            $testProjectGenerateDir | Get-Item | Should -BeOfType [System.IO.DirectoryInfo]
            $testProjectGenerateDefinitionsDir | Get-Item | Should -BeOfType [System.IO.DirectoryInfo]
            $testProjectGenerateTemplatesDir | Get-Item | Should -BeOfType [System.IO.DirectoryInfo]

            $testProjectGenerateDefinitionsFiles | Get-Item | Should -BeOfType [System.IO.FileInfo]
            $testProjectGenerateDefinitionsVariants | Get-Item | Should -BeOfType [System.IO.FileInfo]

            $testProjectGenerateTemplatesDockerfile | Get-Item | Should -BeOfType [System.IO.FileInfo]
            $testProjectGenerateTemplatesReadmeMd | Get-Item | Should -BeOfType [System.IO.FileInfo]
            $testProjectGenerateTemplatesGitlabCiYml | Get-Item | Should -BeOfType [System.IO.FileInfo]

            # Cleanup
            Remove-Item $testProjectDir -Recurse -Force
        }

        It 'Does not override existing files in the /generate directory' {
            # Mock project
            $testProjectDir = "TestDrive:\test-project"
            New-Item $testProjectDir -ItemType Directory > $null

            # Expected folders
            $testProjectGenerateDir = Join-Path $testProjectDir 'generate'
            $testProjectGenerateDefinitionsDir = Join-Path $testProjectGenerateDir 'definitions'
            $testProjectGenerateTemplatesDir = Join-Path $testProjectGenerateDir 'templates'

            # Expected definition files
            $testProjectGenerateDefinitionsFiles = Join-Path $testProjectGenerateDefinitionsDir 'FILES.ps1'
            $testProjectGenerateDefinitionsVariants = Join-Path $testProjectGenerateDefinitionsDir 'VARIANTS.ps1'

            # Expected templates files
            $testProjectGenerateTemplatesDockerfile = Join-Path $testProjectGenerateTemplatesDir 'Dockerfile.ps1'
            $testProjectGenerateTemplatesReadmeMd =  Join-Path $testProjectGenerateTemplatesDir 'README.md.ps1'
            $testProjectGenerateTemplatesGitlabCiYml =  Join-Path $testProjectGenerateTemplatesDir '.gitlab-ci.yml.ps1'

            # Create all folders, one definition file, one template file
            $testProjectGenerateDefinitionsFiles,
            $testProjectGenerateTemplatesDockerfile | % {
                New-Item $_ -ItemType File > $null
            }

            $infoStream = Generate-DockerImageVariants -Init -ProjectPath $testProjectDir 6>&1

            @( $infoStream | ? { $_.MessageData.Message -cmatch '^Not creating folder' }).Count | Should -Be 3
            @( $infoStream | ? { $_.MessageData.Message -cmatch '^Not creating definition file' }).Count |Should -Be 1
            @( $infoStream | ? { $_.MessageData.Message -cmatch '^Creating definition file' }).Count | Should -Be 1
            @( $infoStream | ? { $_.MessageData.Message -cmatch '^Not creating template file' }).Count | Should -Be 1
            @( $infoStream | ? { $_.MessageData.Message -cmatch '^Creating template file' }).Count | Should -Be 2
        }

        It 'Should generate files for exmaple: basic' {
            {
                $exampleProjectPath = Join-Path ( Join-Path $PROJECT_DIR 'examples' ) 'basic'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }

        It 'Should generate files for exmaple: basic-distro' {
            {
                $exampleProjectPath = Join-Path ( Join-Path $PROJECT_DIR 'examples' ) 'basic-distro'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }

        It 'Should generate files for exmaple: basic-distro-variables' {
            {
                $exampleProjectPath = Join-Path ( Join-Path $PROJECT_DIR 'examples' ) 'basic-distro-variables'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }

        It 'Should generate files for exmaple: basic-distro-component-chaining' {
            {
                $exampleProjectPath = Join-Path ( Join-Path $PROJECT_DIR 'examples' ) 'basic-distro-component-chaining'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }

        It 'Should generate files for exmaple: advanced-component-chaining-copies-variables' {
            {
                $exampleProjectPath = Join-Path ( Join-Path $PROJECT_DIR 'examples' ) 'advanced-component-chaining-copies-variables'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
    }
}
