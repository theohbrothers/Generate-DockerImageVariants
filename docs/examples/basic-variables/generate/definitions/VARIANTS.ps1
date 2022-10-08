$VARIANTS = @(
    @{
        tag = 'curl'
    }
    @{
        tag = 'git'
    }
)

$VARIANTS_SHARED = @{
    buildContextFiles = @{
        templates = @{
            'Dockerfile' = @{
                common = $true
                passes = @(
                    @{
                        variables = @{
                            'foo' = 'bar'
                        }
                    }
                )
            }
        }
    }
}
