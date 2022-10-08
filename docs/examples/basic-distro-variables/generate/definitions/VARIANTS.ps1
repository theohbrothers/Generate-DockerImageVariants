$VARIANTS = @(
    @{
        tag = 'curl'
        distro = 'alpine'
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
                            'foo' = 'bar'
                        }
                    }
                    @{
                        variables = @{
                            'foo' = 'bar2'
                        }
                        generatedFileNameOverride = 'Dockerfile.dev'
                    }
                )
            }
        }
    }
}
