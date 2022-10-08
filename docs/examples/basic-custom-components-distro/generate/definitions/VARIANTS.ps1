$VARIANTS = @(
    @{
        tag = 'foo-curl-bar-alpine'
        distro = 'alpine'
        components = @( 'curl' )
        tag_as_latest = $true
    }

    @{
        tag = 'foo-curl-bar-ubuntu'
        distro = 'ubuntu'
        components = @( 'curl' )
    }
)

$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $false
                includeHeader = $false
                includeFooter = $false
                passes = @(
                    @{
                        variables = @{}
                    }
                )
            }
        }
    }
}
