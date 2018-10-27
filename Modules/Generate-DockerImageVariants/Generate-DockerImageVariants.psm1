$GENERATE_DOCKERIMAGEVARIANTS_VERSION = 'v0.1.0'
function Get-ContentFromTemplate {
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path
    ,
        [ValidateRange(1,100)]
        [int]$PrependNewLines
    )
    $content = & $Path
    if ($PrependNewLines -gt 0) {
        1..($PrependNewLine) | % {
            $content = "`n$content"
        }
    }
    $content
}

function Get-ContextFileContent {
    param (
        [ValidateNotNullOrEmpty()]
        [string]$TemplateFile
    ,
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$TemplateDirectory
    ,
        [switch]$Header
    ,
        [array]$SubTemplates
    ,
        [switch]$Footer
    ,
        [hashtable]$TemplatePassVariables
    )

    # This special variable will be used throughout templates
    $PASS_VARIABLES = if ($TemplatePassVariables) { $TemplatePassVariables } else { @{} }

    $params = @{}
    if ( $Header ) {
        Get-ContentFromTemplate -Path "$TemplateDirectory/$TemplateFile.header.ps1"
        $params['PrependNewLines'] = 2
    }

    if ( $SubTemplates -is [array] -and $SubTemplates.Count -gt 0) {
        $SubTemplates | % {
            Get-ContentFromTemplate -Path "$TemplateDirectory/$_/$_.ps1" @params
        }
    }else {
        Get-ContentFromTemplate -Path "$TemplateDirectory/$TemplateFile.ps1" @params
    }

    if ( $Footer ) {
        Get-ContentFromTemplate -Path "$TemplateDirectory/$TemplateFile.footer.ps1" @params
    }
}

# This function generates the each Docker image variants' build context files' in ./variants/<variant>, or if a distro is specified, in ./variants/<distro>/<variant>
function Generate-DockerImageVariants {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$ProjectPath
    ,
        [switch]$Version
    )
    begin {
    }
    process {
        if ($Version) {
            $GENERATE_DOCKERIMAGEVARIANTS_VERSION
            return
        }
        try {
            $PROJECT_BASE_DIR = Resolve-Path $ProjectPath | Select-Object -ExpandProperty Path
            $GENERATE_BASE_DIR = Join-Path $PROJECT_BASE_DIR 'generate'
            $GENERATE_TEMPLATES_DIR = Join-Path $GENERATE_BASE_DIR "templates"
            $GENERATE_DEFINITIONS_DIR = Join-Path $GENERATE_BASE_DIR "definitions"

            $ErrorActionPreference = 'Stop'

            Push-Location $GENERATE_BASE_DIR

            # Get variants' definition
            . ( Join-Path $GENERATE_DEFINITIONS_DIR "VARIANTS.ps1" ) > $null

            # Get files' definition
            . ( Join-Path $GENERATE_DEFINITIONS_DIR "FILES.ps1" ) > $null

            # Normalize globals
            $VARIANTS = if ( $VARIANTS -isnot [array] ) { @() } else { $VARIANTS }
            $VARIANTS_SHARED = if ( $VARIANTS_SHARED -isnot [hashtable] ) { @{} } else { $VARIANTS_SHARED }
            $FILES = if ( $FILES -isnot [array] ) { @() } else { $FILES }

            # Intelligently add properties
            $VARIANTS | % {
                $VARIANT = $_
                $VARIANTS_SHARED.GetEnumerator() | % {
                    $VARIANT[$_.Name] =  $_.Value
                }
                $VARIANT['tag_without_distro'] = if ( $VARIANT['distro'] ) {
                                                    # The variant's build directory name, stripped of the distro name if present
                                                    # E.g. ':git-perl-alpine' or 'alpine-git-perl' becomes ':git-perl'
                                                    $variant_distro_regex = [regex]::Escape( $VARIANT['distro'] )
                                                    if ( $VARIANT['tag'] -match "^(.*)$variant_distro_regex(.*)$" ) {
                                                        "$( $matches[1] )-$( $matches[2] )".Trim('-')
                                                    }else {
                                                        $VARIANT['tag']
                                                    }
                                                }else {
                                                        $VARIANT['tag']
                                                }
                # Dynamically determine the components from the tag of the variant. (E.g. 'foo-bar' have 2 componets: 'foo' and 'bar')
                $VARIANT['components'] = @(
                                            $VARIANT['tag_without_distro'] -split '-' | % { $_.Trim() } | ? { $_ }
                                        )
                $VARIANT['build_dir_rel'] = if ( $VARIANT['distro'] ) {
                                            "variants/$( $VARIANT['distro'] )/$( $VARIANT['tag_without_distro'] )"
                                        }else {
                                            "variants/$($VARIANT['tag'])"
                                        }
                $VARIANT['build_dir'] = Join-Path "$PROJECT_BASE_DIR" $VARIANT['build_dir_rel']
            }

            # Generate each Docker image variant's build context files
            $VARIANTS | % {
                $VARIANT = $_

                "Generating variant of name $( $VARIANT['tag'] ), variant dir: $( $VARIANT['build_dir'] )" | Write-Host -ForegroundColor Green
                "Generating variant of name $( $VARIANT['tag'] ), variant dir: $( $VARIANT['build_dir'] )" | Write-Host -ForegroundColor Green
                if ( ! (Test-Path $VARIANT['build_dir']) ) {
                    New-Item -Path $VARIANT['build_dir'] -ItemType Directory -Force > $null
                }

                # Generate Docker build context files
                if ( $VARIANT['buildContextFiles'] ) {
                    # Templates
                    if ( $VARIANT['buildContextFiles']['templates'] -and $VARIANT['buildContextFiles']['templates'] -is [hashtable] ) {
                        $VARIANT['buildContextFiles']['templates'].GetEnumerator() | % {
                            $templateFile = $_.Key
                            $templateFileConfig = $_.Value
                            $templateObject = @{
                                TemplateFile = $templateFile
                                TemplateDirectory = if ( $templateFileConfig['common'] ) {
                                                        $GENERATE_TEMPLATES_DIR
                                                    }else {
                                                        if ( $VARIANT['distro'] ) {
                                                            "$GENERATE_TEMPLATES_DIR/$templateFile/$( $VARIANT['distro'] )"
                                                        }else {
                                                            "$GENERATE_TEMPLATES_DIR/$templateFile/"
                                                        }
                                                    }
                                Header = if ( $templateFileConfig['includeHeader'] ) { $true } else { $false }
                                # Dynamically determine the sub templates from the name of the variant. (E.g. 'foo-bar' will comprise of foo and bar variant sub templates for this template file)
                                SubTemplates =  if ( ! $templateFileConfig['common'] ) {
                                                    $VARIANT['components']
                                                }else { @() }
                                Footer = if ( $templateFileConfig['includeFooter'] ) { $true } else { $false }
                            }

                            $generatedFile = "$( $VARIANT['build_dir'] )/$templateFile"
                            $templateFileConfig['passes'] | % {
                                $pass = $_
                                $templateObject['TemplatePassVariables'] = if ( $pass['variables'] ) { $pass['variables'] } else { @() }
                                $generatedFile = if ( $pass['generatedFileNameOverride'] ) { "$( $VARIANT['build_dir'] )/$( $pass['generatedFileNameOverride'] )" } else { $generatedFile }
                                $generatedFileContent = Get-ContextFileContent @templateObject
                                $generatedFileContent | Out-File $generatedFile -Encoding Utf8 -Force -NoNewline
                            }
                        }
                    }

                    # Copies
                    if ( $VARIANT['buildContextFiles']['copies'] ) {
                        $VARIANT['buildContextFiles']['copies'] | % {
                            $blob = $_.Trim()
                            # Any blob starting with '/' means we will
                            if ($blob -match '^\/') {
                                $fullPathBlob = Join-Path $PROJECT_BASE_DIR $blob
                            }else {
                                $fullPathBlob = "$GENERATE_TEMPLATES_DIR/variants/$( $VARIANT['tag'] )/$blob"
                            }
                            Copy-Item -Path $fullPathBlob -Destination $VARIANT['build_dir'] -Force -Recurse
                        }
                    }
                }

            }

            # Generate other repo files
            $FILES | % {
                # Generate README.md
                Get-ContentFromTemplate -Path (Join-Path $GENERATE_TEMPLATES_DIR "$_.ps1") | Out-File (Join-Path $PROJECT_BASE_DIR $_) -Encoding utf8 -NoNewline
            }
        }catch {
            if ($VerbosePreference) { "Failed with errors. Exception: $( $_.Exception.Message ). Stacktrace: $( $_.ScriptStackTrace )" | Write-Warning }
            throw
        }finally {
            Pop-Location
        }
    }
}

Export-ModuleMember -Function 'Generate-DockerImageVariants'