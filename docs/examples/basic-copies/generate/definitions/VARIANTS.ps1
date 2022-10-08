$VARIANTS = @(
    @{
        tag = 'curl'
    }
)

$VARIANTS_SHARED = @{
    buildContextFiles = @{
        copies = @(
            '/app'
        )
    }
}
