function Populate-GenerateConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [object]
        $GenerateConfig
    )

    $GenerateConfig['VARIANTS'] | % {
        $VARIANT = $_
        $GenerateConfig['VARIANTS_SHARED'].GetEnumerator() | % {
            # Override only if it doesn't already exist in the variant definition
            if (!$VARIANT.Contains($_.Name)) {
                $VARIANT[$_.Name] = New-Clone -InputObject $_.Value
            }
        }
        $VARIANT['tag_as_latest'] = if ($VARIANT.Contains('tag_as_latest')) { $variant['tag_as_latest'] } else { $false }
        $VARIANT['tag_without_distro'] = if ( $VARIANT.Contains('distro') -and $VARIANT['distro'] ) {
                                            # The variant's build directory name, stripped of the distro name if present
                                            # E.g. 'git-perl-alpine', 'git-alpine-perl', or 'alpine-git-perl' -> 'git-perl'
                                            $variant_distro_regex = [regex]::Escape( $VARIANT['distro'] )
                                            if ( $VARIANT['tag'] -match "^(.*)$variant_distro_regex(.*)$" ) {
                                                "$( $matches[1].Trim('-') )-$( $matches[2].Trim('-') )".Trim('-')
                                            }else {
                                                $VARIANT['tag']
                                            }
                                        }else {
                                            $VARIANT['tag']
                                        }
        # Dynamically determine the components from the tag of the variant. (E.g. 'foo-bar' have 2 componets: 'foo' and 'bar')
        $VARIANT['components'] = @(
                                    if ($VARIANT.Contains('components') -and $null -ne $VARIANT['components']) {
                                        $VARIANT['components']
                                    }else {
                                        $VARIANT['tag_without_distro'] -split '-' | % { $_.Trim() } | ? { $_ }
                                    }
                                )
        $VARIANT['build_dir_rel'] = [IO.Path]::Combine( 'variants', $VARIANT['tag'] )
        $VARIANT['build_dir'] = Join-Path $GenerateConfig['REPOSITORY_BASE_DIR'] $VARIANT['build_dir_rel']

        if ($VARIANT.Contains('buildContextFiles')) {
            # Populate the templates object
            if ($VARIANT['buildContextFiles'].Contains('templates')) {
                foreach ($k in $VARIANT['buildContextFiles']['templates'].Keys) {
                    $VARIANT['buildContextFiles']['templates'][$k]['file'] = $k
                    # Dynamically determine the sub templates from the name of the variant. (E.g. 'foo-bar' will comprise of foo and bar variant sub templates for this template file)
                    $VARIANT['buildContextFiles']['templates'][$k]['subTemplates'] = @(
                        if ( ! $VARIANT['buildContextFiles']['templates'][$k]['common'] ) {
                            $VARIANT['components']
                        }
                    )
                    $VARIANT['buildContextFiles']['templates'][$k]['templateDirectory'] = if ( $VARIANT['buildContextFiles']['templates'][$k]['common'] ) {
                                                                                            $GenerateConfig['GENERATE_TEMPLATES_DIR']
                                                                                        }else {
                                                                                            if ( $VARIANT['distro'] ) {
                                                                                                Join-Path (Join-Path $GenerateConfig['GENERATE_TEMPLATES_DIR'] $k) $VARIANT['distro']
                                                                                            }else {
                                                                                                Join-Path $GenerateConfig['GENERATE_TEMPLATES_DIR'] $k
                                                                                            }
                                                                                        }


                    # Populate the pass objects
                    foreach ($pass in $VARIANT['buildContextFiles']['templates'][$k]['passes']) {
                        $pass['file'] = if ( $pass.Contains('generatedFileNameOverride') ) {
                                            Join-Path $VARIANT['build_dir'] $pass['generatedFileNameOverride']
                                        }else {
                                            Join-Path $VARIANT['build_dir'] $k
                                        }
                    }
                }
            }
            # Populate the copies object
            if ($VARIANT['buildContextFiles'].Contains('copies')) {
                $VARIANT['buildContextFiles']['copies'] = @(
                    $VARIANT['buildContextFiles']['copies'] | % {
                        # if ([System.IO.Path]::IsPathRooted($_.Trim()) {
                        #     $_.Trim()
                        # }else {
                            Join-Path $GenerateConfig['REPOSITORY_BASE_DIR'] $_.Trim()
                        # }
                    }
                )
            }

        }
    }


    # Create File objects
    $GenerateConfig['FILES'] = @(
        $GenerateConfig['FILES'] | % {
            $file = $_
            @{
                file = [IO.Path]::Combine($GenerateConfig['REPOSITORY_BASE_DIR'], $file)
                templateFile = [IO.Path]::Combine($GenerateConfig['GENERATE_TEMPLATES_DIR'], "$file.ps1")
            }
        }
    )

    $GenerateConfig
}
