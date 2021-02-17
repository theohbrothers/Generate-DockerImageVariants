# Docker image variants' definitions
$VARIANTS = @(
    @{
        # Specifies the docker image tag
        tag = 'curl-alpine'
        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        distro = 'alpine'
        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        # components = @( 'foo' )
    }

    @{
        # Specifies the docker image tag
        tag = 'curl-ubuntu'
        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        distro = 'ubuntu'
        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        # components = @( 'foo' )
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
                        variables = @{}
                    }
                )
            }
        }
    }
}
