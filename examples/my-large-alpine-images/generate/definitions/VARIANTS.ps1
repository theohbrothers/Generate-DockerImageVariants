# Docker image variants' definitions
$VARIANTS_VERSION = "1.0.0"
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
    }
)

# This is a special variable that sets a common buildContextFiles definition for all variants
# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    version = $VARIANTS_VERSION
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
        }
        copies = @(
            '/app'
        )
    }
}