Describe 'Generate-DockerImageVariants' -Tag 'Integration' {

    BeforeEach {
        Get-Module Generate-DockerImageVariants | Remove-Module
        Import-Module $PSScriptRoot 3>$null

        $PROJECT_DIR = Convert-Path "$PSScriptRoot/../../"
        $DOCS_DIR = Join-Path $PROJECT_DIR 'docs'
        $DOCS_EXAMPLES_DIR = Join-Path $DOCS_DIR 'examples'

        $PSDefaultParameterValues['New-Item:Force'] = $true
        $PSDefaultParameterValues['Get-Item:Force'] = $true

        # Mock project
        $testProjectDir = "TestDrive:\test-project"
        New-Item $testProjectDir -ItemType Directory > $null
    }

    AfterEach {
        Get-Item $testProjectDir | Remove-Item -Recurse -Force
    }

    Context 'Parameters' {

        BeforeEach {
            $testProjectGenerateDir = Join-Path $testProjectDir 'generate'
            $testProjectGenerateDefinitionsDir = Join-Path $testProjectGenerateDir 'definitions'
            $testProjectGenerateFunctionsDir = Join-Path $testProjectGenerateDir 'functions'
            $testProjectGenerateTemplatesDir = Join-Path $testProjectGenerateDir 'templates'

            # Definition files
            $testProjectGenerateDefinitionsFiles = Join-Path $testProjectGenerateDefinitionsDir 'FILES.ps1'
            $testProjectGenerateDefinitionsVariants = Join-Path $testProjectGenerateDefinitionsDir 'VARIANTS.ps1'

            # Templates files
            $testProjectGenerateTemplatesDockerfile = Join-Path $testProjectGenerateTemplatesDir 'Dockerfile.ps1'
            $testProjectGenerateTemplatesReadmeMd =  Join-Path $testProjectGenerateTemplatesDir 'README.md.ps1'
        }

        It '-Init initializes the /generate directory' {
            Generate-DockerImageVariants -Init -ProjectPath $testProjectDir 6>&1 > $null

            $testProjectGenerateDir | Get-Item -Force | Should -BeOfType [System.IO.DirectoryInfo]
            $testProjectGenerateDefinitionsDir | Get-Item -Force | Should -BeOfType [System.IO.DirectoryInfo]
            $testProjectGenerateTemplatesDir | Get-Item -Force| Should -BeOfType [System.IO.DirectoryInfo]

            $testProjectGenerateDefinitionsFiles | Get-Item -Force | Should -BeOfType [System.IO.FileInfo]
            $testProjectGenerateDefinitionsVariants | Get-Item -Force | Should -BeOfType [System.IO.FileInfo]

            $testProjectGenerateTemplatesDockerfile | Get-Item -Force | Should -BeOfType [System.IO.FileInfo]
            $testProjectGenerateTemplatesReadmeMd | Get-Item -Force | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Does not override existing files in the /generate directory' {
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
            @( $infoStream | ? { $_.MessageData.Message -cmatch '^Creating template file' }).Count | Should -Be 1
        }

        It 'Should treat definition file FILES.ps1 as optional' {
            Generate-DockerImageVariants -ProjectPath $testProjectDir -Init -ErrorAction Stop #6>$null
            Remove-Item $testProjectGenerateDefinitionsFiles
            Generate-DockerImageVariants -ProjectPath $testProjectDir -ErrorAction Stop 6>$null
        }

        It 'Should treat functions as optional' {
            Generate-DockerImageVariants -ProjectPath $testProjectDir -Init -ErrorAction Stop #6>$null
            Remove-Item $testProjectGenerateFunctionsDir -Recurse -Force
            Generate-DockerImageVariants -ProjectPath $testProjectDir -ErrorAction Stop 6>$null
        }

        It 'Should generate files for default prototypes created by -Init' {
            Generate-DockerImageVariants -ProjectPath $testProjectDir -Init -ErrorAction Stop #6>$null
            Generate-DockerImageVariants -ProjectPath $testProjectDir -ErrorAction Stop 6>$null

            Test-Path $testProjectDir/variants/curl/Dockerfile | Should -Be $true
            Test-Path $testProjectDir/variants/curl-git/Dockerfile | Should -Be $true
            Test-Path $testProjectDir/variants/my-cool-variant/Dockerfile | Should -Be $true
        }

        It 'Should generate files for example: advanced-component-chaining-copies-variables' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'advanced-component-chaining-copies-variables'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
        It 'Should generate files for example: basic' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'basic'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
        It 'Should generate files for example: basic-component-chaining' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'basic-component-chaining'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
        It 'Should generate files for example: basic-copies' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'basic-copies'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
        It 'Should generate files for example: basic-custom-components' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'basic-custom-components'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
        It 'Should generate files for example: basic-custom-components-distro' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'basic-custom-components-distro'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
        It 'Should generate files for example: basic-distro' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'basic-distro'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
        It 'Should generate files for example: basic-distro-component-chaining' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'basic-distro-component-chaining'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
        It 'Should generate files for example: basic-distro-variables' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'basic-distro-variables'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
        It 'Should generate files for example: basic-functions' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'basic-functions'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
        It 'Should generate files for example: basic-multiple-variants' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'basic-multiple-variants'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
        It 'Should generate files for example: basic-variables' {
            {
                $exampleProjectPath = Join-Path $DOCS_EXAMPLES_DIR 'basic-variables'

                Generate-DockerImageVariants -ProjectPath $exampleProjectPath -ErrorAction Stop 6>$null
            } | Should -Not -Throw
        }
    }
}
