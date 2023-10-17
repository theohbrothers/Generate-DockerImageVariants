$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Populate-GenerateConfig" -Tag 'Unit' {

    BeforeEach {
        function New-Clone {
            param (
                [object]$InputObject
            )
            $InputObject
        }
    }

    Context 'Behavior' {

        It 'Populates variant' {
            $GenerateConfig = @{
                REPOSITORY_BASE_DIR = '/repo'
                VARIANTS = @(
                    @{
                        tag = 'foo'
                    }
                )
                VARIANTS_SHARED = @{}
            }
            $GenerateConfigAfter = Populate-GenerateConfig -GenerateConfig $GenerateConfig

            $GenerateConfigAfter['VARIANTS'][0]['tag'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['tag_as_latest'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['tag_without_distro'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['components'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir_rel'].Replace('\', '/') | Should -Be 'variants/foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir'].Replace('\', '/') | Should -Be '/repo/variants/foo'
        }

        It 'Populates variant with specified distro (behind)' {
            $GenerateConfig = @{
                REPOSITORY_BASE_DIR = '/repo'
                VARIANTS = @(
                    @{
                        tag = 'foo-alpine'
                        distro = 'alpine'
                    }
                )
                VARIANTS_SHARED = @{}
            }
            $GenerateConfigAfter = Populate-GenerateConfig -GenerateConfig $GenerateConfig

            $GenerateConfigAfter['VARIANTS'][0]['tag'] | Should -Be 'foo-alpine'
            $GenerateConfigAfter['VARIANTS'][0]['distro'] | Should -Be 'alpine'
            $GenerateConfigAfter['VARIANTS'][0]['tag_as_latest'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['tag_without_distro'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['components'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir_rel'].Replace('\', '/') | Should -Be 'variants/foo-alpine'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir'].Replace('\', '/') | Should -Be '/repo/variants/foo-alpine'
        }

        It 'Populates variant with specified distro (middle)' {
            $GenerateConfig = @{
                REPOSITORY_BASE_DIR = '/repo'
                VARIANTS = @(
                    @{
                        tag = 'foo-alpine-bar'
                        distro = 'alpine'
                    }
                )
                VARIANTS_SHARED = @{}
            }
            $GenerateConfigAfter = Populate-GenerateConfig -GenerateConfig $GenerateConfig

            $GenerateConfigAfter['VARIANTS'][0]['tag'] | Should -Be 'foo-alpine-bar'
            $GenerateConfigAfter['VARIANTS'][0]['distro'] | Should -Be 'alpine'
            $GenerateConfigAfter['VARIANTS'][0]['tag_as_latest'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['tag_without_distro'] | Should -Be 'foo-bar'
            $GenerateConfigAfter['VARIANTS'][0]['components'] | Should -Be 'foo', 'bar'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir_rel'].Replace('\', '/') | Should -Be 'variants/foo-alpine-bar'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir'].Replace('\', '/') | Should -Be '/repo/variants/foo-alpine-bar'
        }

        It 'Populates variant with specified distro (front)' {
            $GenerateConfig = @{
                REPOSITORY_BASE_DIR = '/repo'
                VARIANTS = @(
                    @{
                        tag = 'alpine-foo'
                        distro = 'alpine'
                    }
                )
                VARIANTS_SHARED = @{}
            }
            $GenerateConfigAfter = Populate-GenerateConfig -GenerateConfig $GenerateConfig

            $GenerateConfigAfter['VARIANTS'][0]['tag'] | Should -Be 'alpine-foo'
            $GenerateConfigAfter['VARIANTS'][0]['distro'] | Should -Be 'alpine'
            $GenerateConfigAfter['VARIANTS'][0]['tag_as_latest'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['tag_without_distro'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['components'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir_rel'].Replace('\', '/') | Should -Be 'variants/alpine-foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir'].Replace('\', '/') | Should -Be '/repo/variants/alpine-foo'
        }

        It 'Populates variant with tag_as_latest' {
            $GenerateConfig = @{
                REPOSITORY_BASE_DIR = '/repo'
                VARIANTS = @(
                    @{
                        tag = 'foo'
                        tag_as_latest = $true
                    }
                )
                VARIANTS_SHARED = @{}
            }
            $GenerateConfigAfter = Populate-GenerateConfig -GenerateConfig $GenerateConfig

            $GenerateConfigAfter['VARIANTS'][0]['tag'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['tag_as_latest'] | Should -Be $true
            $GenerateConfigAfter['VARIANTS'][0]['tag_without_distro'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['components'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir_rel'].Replace('\', '/') | Should -Be 'variants/foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir'].Replace('\', '/') | Should -Be '/repo/variants/foo'
        }

        It 'Populates variant with specified components' {
            $GenerateConfig = @{
                REPOSITORY_BASE_DIR = '/repo'
                VARIANTS = @(
                    @{
                        tag = 'foo'
                        components = @(
                            'john'
                            'doe'
                        )
                    }
                )
                VARIANTS_SHARED = @{}
            }
            $GenerateConfigAfter = Populate-GenerateConfig -GenerateConfig $GenerateConfig

            $GenerateConfigAfter['VARIANTS'][0]['tag'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['tag_as_latest'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['tag_without_distro'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['components'] | Should -Be 'john', 'doe'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir_rel'].Replace('\', '/') | Should -Be 'variants/foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir'].Replace('\', '/') | Should -Be '/repo/variants/foo'
        }

        It 'Populates variant with specified distro and components' {
            $GenerateConfig = @{
                REPOSITORY_BASE_DIR = '/repo'
                VARIANTS = @(
                    @{
                        tag = 'foo-alpine'
                        distro = 'alpine'
                        components = @(
                            'john'
                            'doe'
                        )
                    }
                )
                VARIANTS_SHARED = @{}
            }
            $GenerateConfigAfter = Populate-GenerateConfig -GenerateConfig $GenerateConfig

            $GenerateConfigAfter['VARIANTS'][0]['tag'] | Should -Be 'foo-alpine'
            $GenerateConfigAfter['VARIANTS'][0]['distro'] | Should -Be 'alpine'
            $GenerateConfigAfter['VARIANTS'][0]['tag_as_latest'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['tag_without_distro'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['components'] | Should -Be 'john', 'doe'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir_rel'].Replace('\', '/') | Should -Be 'variants/foo-alpine'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir'].Replace('\', '/') | Should -Be '/repo/variants/foo-alpine'
        }

        It 'Populates variant definition with buildContextFiles' {
            $GenerateConfig = @{
                REPOSITORY_BASE_DIR = '/repo'
                GENERATE_TEMPLATES_DIR = '/repo/path/to/templates'
                VARIANTS = @(
                    @{
                        tag = 'foo'
                        buildContextFiles = @{
                            templates = @{
                                Dockerfile = @{
                                    common = $true
                                    includeHeader = $true
                                    includeFooter = $true
                                    passes = @(
                                        @{
                                            variables = @{
                                                john = 'doe'
                                            }
                                        }
                                        @{
                                            variables = @{
                                                john = 'doe'
                                            }
                                            generatedFileNameOverride = 'Dockerfile2'
                                        }
                                    )
                                }
                            }
                            copies = @(
                                '/bar'
                            )
                        }
                    }
                )
                VARIANTS_SHARED = @{}
            }
            $GenerateConfigAfter = Populate-GenerateConfig -GenerateConfig $GenerateConfig

            $GenerateConfigAfter['VARIANTS'][0]['tag'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['tag_as_latest'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['tag_without_distro'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['components'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir_rel'].Replace('\', '/') | Should -Be 'variants/foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir'].Replace('\', '/') | Should -Be '/repo/variants/foo'

            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['common'] | Should -Be $true
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['includeHeader'] | Should -Be $true
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['includeFooter'] | Should -Be $true
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['passes'][0]['variables']['john'] | Should -Be 'doe'
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['passes'][0]['file'].Replace('\', '/') | Should -Be '/repo/variants/foo/Dockerfile'
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['passes'][1]['variables']['john'] | Should -Be 'doe'
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['passes'][1]['file'].Replace('\', '/') | Should -Be '/repo/variants/foo/Dockerfile2'
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['templateDirectory'].Replace('\', '/') | Should -Be '/repo/path/to/templates'
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['subTemplates'] | Should -Be  @()

            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['copies'][0].Replace('\', '/') | Should -Be '/repo/bar'
        }

        It 'Populates variant definition with shared definition' {
            $GenerateConfig = @{
                REPOSITORY_BASE_DIR = '/repo'
                GENERATE_TEMPLATES_DIR = '/repo/path/to/templates'
                VARIANTS = @(
                    @{
                        tag = 'foo'
                    }
                )
                VARIANTS_SHARED = @{
                    buildContextFiles = @{
                        templates = @{
                            Dockerfile = @{
                                common = $true
                                includeHeader = $true
                                includeFooter = $true
                                passes = @(
                                    @{
                                        # These variables will be available in $PASS_VARIABLES hashtable when this template is processed
                                        variables = @{
                                            john = 'doe'
                                        }
                                    }
                                )
                            }
                        }
                        copies = @(
                            '/bar'
                        )
                    }
                }
            }
            $GenerateConfigAfter = Populate-GenerateConfig -GenerateConfig $GenerateConfig

            $GenerateConfigAfter['VARIANTS'][0]['tag'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['tag_as_latest'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['tag_without_distro'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['components'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir_rel'].Replace('\', '/') | Should -Be 'variants/foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir'].Replace('\', '/') | Should -Be '/repo/variants/foo'

            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['common'] | Should -Be $true
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['includeHeader'] | Should -Be $true
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['includeFooter'] | Should -Be $true
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['passes'][0]['variables']['john'] | Should -Be 'doe'

            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['copies'][0].Replace('\', '/') | Should -Be '/repo/bar'
        }

        It 'Prioritises variant definition over shared definition' {
            $GenerateConfig = @{
                REPOSITORY_BASE_DIR = '/repo'
                GENERATE_TEMPLATES_DIR = '/repo/path/to/templates'
                VARIANTS = @(
                    @{
                        tag = 'foo'
                        buildContextFiles = @{
                            templates = @{
                                Dockerfile = @{
                                    common = $false
                                    includeHeader = $false
                                    includeFooter = $false
                                    passes = @(
                                        @{
                                            # These variables will be available in $PASS_VARIABLES hashtable when this template is processed
                                            variables = @{
                                                john = ''
                                            }
                                        }
                                    )
                                }
                            }
                            copies = @(
                                '/bar'
                            )
                        }
                    }
                )
                VARIANTS_SHARED = @{
                    buildContextFiles = @{
                        templates = @{
                            Dockerfile = @{
                                common = $true
                                includeHeader = $true
                                includeFooter = $true
                                passes = @(
                                    @{
                                        # These variables will be available in $PASS_VARIABLES hashtable when this template is processed
                                        variables = @{
                                            john = 'doe'
                                        }
                                    }
                                )
                            }
                        }
                        copies = @(
                            '/baz'
                        )
                    }
                }
            }
            $GenerateConfigAfter = Populate-GenerateConfig -GenerateConfig $GenerateConfig

            $GenerateConfigAfter['VARIANTS'][0]['tag'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['tag_as_latest'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['tag_without_distro'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['components'] | Should -Be 'foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir_rel'].Replace('\', '/') | Should -Be 'variants/foo'
            $GenerateConfigAfter['VARIANTS'][0]['build_dir'].Replace('\', '/') | Should -Be '/repo/variants/foo'

            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['common'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['includeHeader'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['includeFooter'] | Should -Be $false
            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['templates']['Dockerfile']['passes'][0]['variables']['john'] | Should -Be ''

            $GenerateConfigAfter['VARIANTS'][0]['buildContextFiles']['copies'][0].Replace('\', '/') | Should -Be '/repo/bar'
        }

        It 'Populates variant with files' {
            $GenerateConfig = @{
                REPOSITORY_BASE_DIR = '/repo'
                GENERATE_TEMPLATES_DIR = '/repo/path/to/templates'
                VARIANTS = @()
                FILES = @(
                    'foo'
                )
            }
            $GenerateConfigAfter = Populate-GenerateConfig -GenerateConfig $GenerateConfig

            $GenerateConfigAfter['FILES'][0]['file'].Replace('\', '/') | Should -Be '/repo/foo'
            $GenerateConfigAfter['FILES'][0]['templateFile'].Replace('\', '/') | Should -Be '/repo/path/to/templates/foo.ps1'
        }

    }

}
