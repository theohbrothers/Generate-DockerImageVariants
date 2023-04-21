# This function generates the each Docker image variants' build context files' in ./variants/<variant>, or if a distro is specified, in ./variants/<distro>/<variant>
function Generate-DockerImageVariants {
    [CmdletBinding(DefaultParameterSetName='Generate')]
    param (
        [Parameter(ParameterSetName='Init',Position=0)]
        [ValidateNotNullOrEmpty()]
        [switch]
        $Init
    ,
        [Parameter(ParameterSetName='Init',Position=1)]
        [Parameter(ParameterSetName='Generate',Position=0)]
        [ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectPath
    )
    process {
        try {
            # Create the Config
            $GenerateConfig = New-GenerateConfig -ModulePath (Convert-Path $PSScriptRoot/..) -TargetRepositoryPath $ProjectPath

            if ($PSCmdlet.ParameterSetName -eq 'Init') {
                New-GenerationFolder -GenerateConfig $GenerateConfig
            }

            if ($PSCmdlet.ParameterSetName -eq 'Generate') {
                # Get variants' definition (mandatory)
                if ($definition = Get-Definition -Path $GenerateConfig['GENERATE_DEFINITIONS_VARIANTS_FILE'] -VariableName 'VARIANTS') {
                    $GenerateConfig['VARIANTS'] = $definition
                }

                # Get variants' shared definition (optional)
                $definition = Get-Definition -Path $GenerateConfig['GENERATE_DEFINITIONS_VARIANTS_FILE'] -VariableName 'VARIANTS_SHARED' -Optional
                $GenerateConfig['VARIANTS_SHARED'] = if ( $definition -is [hashtable] ) {
                                                        $definition
                                                    }else {
                                                        $GenerateConfig['VARIANTS_SHARED']
                                                    }

                # Get files' definition (optional)
                if ( Test-Path $GenerateConfig['GENERATE_DEFINITIONS_FILES_FILE'] ) {
                    if ($definition = Get-Definition -Path $GenerateConfig['GENERATE_DEFINITIONS_FILES_FILE'] -VariableName 'FILES') {
                        $GenerateConfig['FILES'] = $definition
                    }
                }

                # Validate the VARIANTS and FILES defintion objects
                "Validating `$VARIANTS definition" | Write-Verbose
                Validate-Object -Prototype (Get-VariantsPrototype) -TargetObject $GenerateConfig['VARIANTS'] -Mandatory:$false
                "Validating `$FILES definition" | Write-Verbose
                Validate-Object -Prototype (Get-FilesPrototype) -TargetObject $GenerateConfig['FILES'] -Mandatory:$false

                # Populate and normalize definitions
                $GenerateConfig = Populate-GenerateConfig -GenerateConfig $GenerateConfig

                # Generate each Docker image variant's build context files
                & {
                    # Make VARIANTS global variable available to the template script
                    $global:VARIANTS = $GenerateConfig['VARIANTS']

                    $GenerateConfig['VARIANTS'] | New-RepositoryVariantBuildContext
                }

                # Generate other repo files. E.g. README.md
                $GenerateConfig['FILES'] | New-RepositoryFile
            }
        }catch {
            if ($ErrorActionPreference -eq 'Stop') {
                throw
            }else {
                Write-Error -ErrorRecord $_
            }
        }
    }
}
