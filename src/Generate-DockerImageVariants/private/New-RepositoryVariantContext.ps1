function New-RepositoryVariantBuildContext {
    [CmdletBinding(DefaultParameterSetName='default')]
    param (
        [Parameter(ParameterSetName='default')]
        [ValidateNotNullOrEmpty()]
        [object]
        $Variant
    ,
        [Parameter(ParameterSetName='pipeline',ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [object]
        $InputObject
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'default') {
            # Same variable. Casing does not create a new variable
            $Variant = $Variant
        }
        if ($PSCmdlet.ParameterSetName -eq 'pipeline') {
            $Variant = $InputObject
        }
        "Generating build context of variant '$( $Variant['tag'] )': $( $Variant['build_dir'] )" | Write-Host -ForegroundColor Green
        if ( ! (Test-Path $Variant['build_dir']) ) {
            New-Item -Path $Variant['build_dir'] -ItemType Directory -Force > $null
        }

        if ($Variant.Contains('buildContextFiles')) {
            # Generate files from templates
            if ( $Variant['buildContextFiles'].Contains('templates') -and $Variant['buildContextFiles']['templates'] -is [hashtable] ) {
                foreach ($k in $Variant['buildContextFiles']['templates'].Keys) {
                    $template = $Variant['buildContextFiles']['templates'][$k]
                    foreach ($pass in $template['passes']) {
                        $params = @{
                            Template = $template
                            TemplatePassVariables = $pass['variables']
                        }
                        "Generating build context file: $( $pass['file'] )" | Write-Verbose
                        $content = & {
                            # Make VARIANTS global variable available to the template script
                            $global:VARIANT = $Variant # This does nothing, it's just to be clear we are making the variable available

                            # Get content
                            Get-ContextFileContent @params
                        }
                        New-Item $pass['file'] -ItemType File -Force > $null
                        $content | Out-File $pass['file'] -Encoding Utf8 -Force -NoNewline
                    }
                }
            }

            # Generate files from copies
            if ($Variant['buildContextFiles'].Contains('copies')) {
                foreach ($copy in $Variant['buildContextFiles']['copies']) {
                    "Copying file(s) into build context from: $copy" | Write-Verbose
                    if (! (Test-Path $copy) ) {
                        throw "No such file or folder: $copy"
                    }
                    Copy-Item -Path $copy -Destination $Variant['build_dir'] -Force -Recurse
                }
            }
        }
    }
}
