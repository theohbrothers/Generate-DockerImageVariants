# Docker image variants' definitions
$VARIANTS = @(
    @{
        # The tag is the Docker Image tag.
        tag = 'curl-alpine'
        # Defining a distro is optional. If you dont define a distro, you assume all your variants use the same distro.
        # In contrast, if you do define a distro, variants will be generated in their respective distro folder, in this case, '/variants/alpine'
        distro = 'alpine'
    }
    @{
        # The tag is the Docker Image tag.
        tag = 'curl-git-alpine'
        # Defining a distro is optional. If you dont define a distro, you assume all your variants use the same distro.
        # In contrast, if you do define a distro, variants will be generated in their respective distro folder, in this case, '/variants/alpine'
        distro = 'alpine'
    }

    @{
        # The tag is the Docker Image tag.
        tag = 'curl-ubuntu'
        # Defining a distro is optional. If you dont define a distro, you assume all your variants use the same distro.
        # In contrast, if you do define a distro, variants will be generated in their respective distro folder, in this case, '/variants/alpine'
        distro = 'ubuntu'
    }

    @{
        # The tag is the Docker Image tag.
        tag = 'curl-git-ubuntu'
        # Defining a distro is optional. If you dont define a distro, you assume all your variants use the same distro.
        # In contrast, if you do define a distro, variants will be generated in their respective distro folder, in this case, '/variants/alpine'
        distro = 'ubuntu'
    }
)

# This is a special global that sets a common buildContextFiles definition for all variants
# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $false
                includeHeader = $true
                includeFooter = $true
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
        }
    }
}
