# Docker image variants' definitions
$VARIANTS = @(
    @{
        # Specifies the docker image tag
        tag = 'curl'
        # Specifies a distro (optional). If you dont define a distro, you assume all your variants use the same distro.
        # In contrast, if a distro is specified, variants will be generated in their respective distro folder, in this case, '/variants/alpine'
        distro = 'alpine'
    }
)

# This is a special global that sets a common buildContextFiles definition for all variants
# Docker image variants' definitions (shared)
$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            # The path of the template to process, relative to the templates directory, omitting the '.ps1' extension
            'Dockerfile' = @{
                # Specifies whether the template is common (shared) across distros
                common = $false
                # Specifies whether the template <file>.header.ps1 will be processed. Useful for Dockerfiles
                includeHeader = $true
                # Specifies whether the template <file>.footer.ps1 will be processed. Useful for Dockerfiles
                includeFooter = $true
                # Specifies a list of passes the template will be undergo, where each pass generates a file
                passes = @(
                    @{
                        # These variables will be available in $PASS_VARIABLES hashtable when this template is processed
                        variables = @{
                            'foo' = 'bar'
                        }
                    }
                    # The second pass. The Generated file name will be 'Dockerfile.dev'
                    @{
                        # These variables will be available in $PASS_VARIABLES hashtable when this template is processed
                        variables = @{
                            'foo' = 'bar2'
                        }
                        # The generated file will be 'Dockerfile.dev'
                        generatedFileNameOverride = 'Dockerfile.dev'
                    }
                )
            }
        }
    }
}
