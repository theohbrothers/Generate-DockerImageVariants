# Docker image variants' definitions
$VARIANTS = @(
    @{
        # The tag is the Docker Image tag.
        tag = 'curl'
        # Defining a distro is optional. If you dont define a distro, you assume all your variants use the same distro.
        distro = ''
    }
)

# This is a special global that sets a common buildContextFiles definition for all variants
# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                # Specifies that the template file is common (shared) across distros
                common = $true
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
        }
    }
}
