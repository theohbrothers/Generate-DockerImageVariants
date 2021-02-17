# Docker image variants' definitions
$VARIANTS = @(
    # Our first variant
    @{
        # Specifies the docker image tag
        tag = 'curl'

        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        distro = ''

        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        # components = @( 'curl' )

        # Specifies that this variant should be tagged ':latest'. This property will be useful in generation of content in README.md or ci files. Automatically populated as $false if unspecified
        # tag_as_latest = $false
    }

    # Our second variant
    @{
        # Specifies the docker image tag
        tag = 'curl-git'

        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        distro = ''

        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        # components = @( 'curl', 'git' )

        # Specifies that this variant should be tagged ':latest'. This property will be useful in generation of content in README.md or ci files. Automatically populated as $false if unspecified
        # tag_as_latest = $false
    }

    # Our third variant
    @{
        # Specifies the docker image tag
        tag = 'my-cool-variant'

        # Specifies a distro (optional). If you dont define a distro, templates will be sourced from /generate/templates/<file> folder
        # In contrast, if a distro is specified, templates will be sourced from /generate/templates/<file>/<distro> folder
        # distro = ''

        # Specifies an list of components to process. If undefined, the components will be determined from the tag.
        # If unspecified, this is automatically populated
        components = @( 'curl', 'git' )

        # Specifies that this variant should be tagged ':latest'. This property will be useful in generation of content in README.md or ci files. Automatically populated as $false if unspecified
        tag_as_latest = $true
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
                common = $true
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
