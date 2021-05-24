# For validation of the $VARIANTS object
function Get-VariantsPrototype {
    [CmdletBinding()]
    param ()

    $VARIANTS_PROTOTYPE = @(
        @{
            tag = ''
            distro = ''
            tag_as_latest = $false
            tag_without_distro = ''
            components = @( 'foo' )
            build_dir_rel = ''
            build_dir = ''
            buildContextFiles = @{
                templates = @{
                    'baz' = @{
                        common = $false
                        includeHeader = $false
                        includeFooter = $false
                        passes = @(
                            @{
                                generatedFileNameOverride = ''
                                variables = @{
                                    foo = 'bar'
                                }

                                # Added dynamically
                                file = ''
                                templateFile = ''
                            }
                        )
                        # Added dynamically
                        file = 'baz'
                        subTemplates = @()
                        templateDirectory = ''
                    }
                }
                copies = @(
                    'foo'
                )
            }
        }
    )

    ,$VARIANTS_PROTOTYPE
}
