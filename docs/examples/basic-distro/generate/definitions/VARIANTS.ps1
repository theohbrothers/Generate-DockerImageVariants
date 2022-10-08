$VARIANTS = @(
    @{
        tag = 'curl-alpine'
        distro = 'alpine'
        tag_as_latest = $true
    }

    @{
        tag = 'curl-ubuntu'
        distro = 'ubuntu'
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
                        variables = @{}
                    }
                )
            }
        }
    }
}
