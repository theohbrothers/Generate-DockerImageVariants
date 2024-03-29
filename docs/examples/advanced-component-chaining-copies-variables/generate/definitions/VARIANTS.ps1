# Docker image variants' definitions
$VARIANTS = @(
    @{
        tag = 'perl'
        distro = 'alpine'
    }
    @{
        tag = 'python'
        distro = 'alpine'
    }
    @{
        tag = 'git'
        distro = 'alpine'
    }
    @{
        tag = 'perl-git'
        distro = 'alpine'
    }
    @{
        tag = 'python-git'
        distro = 'alpine'
    }
    @{
        tag = 'perl-python-git'
        distro = 'alpine'
        tag_as_latest = $true
    }
)

$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $false
                includeHeader = $true
                includeFooter = $true
                passes = @(
                    @{
                        variables = @{
                            maintainer = 'The Oh Brothers'
                        }
                    }
                )
            }
            'config/config.yml' = @{
                common = $true
                includeHeader = $false
                includeFooter = $false
                passes = @(
                    @{
                        variables = @{
                            foo = 'bar'
                        }
                    }
                )
            }
        }
        copies = @(
            '/app'
        )
    }
}
