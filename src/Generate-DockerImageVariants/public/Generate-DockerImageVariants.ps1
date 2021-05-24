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
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]
        $ProjectPath
    ,
        [Parameter(ParameterSetName='Version')]
        [switch]
        $Version
    )
    begin {
        # PS Defaults
        $PSDefaultParameterValues['Get-Content:Force'] = $true
        $PSDefaultParameterValues['Get-Item:Force'] = $true
        $PSDefaultParameterValues['Get-ChildItem:Force'] = $true
        $PSDefaultParameterValues['Out-File:Force'] = $true
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Version') {
            $script:GENERATE_DOCKERIMAGEVARIANTS_VERSION
            return
        }
        try {
            # Create the Config
            $GenerateConfig = New-GenerateConfig -ModulePath (Convert-Path $PSScriptRoot/..) -TargetRepositoryPath $ProjectPath

            if ($PSCmdlet.ParameterSetName -eq 'Init') {
                New-GenerationFolder -GenerateConfig $GenerateConfig
            }

            if ($PSCmdlet.ParameterSetName -eq 'Generate') {

                # Get variants' definition (mandatory)
                if ($definition = Get-Definition -Path $GenerateConfig['GENERATE_DEFINITIONS_VARIANTS_FILE'] -VariableName 'VARIANTS') {
                    # Normalize definitions
                    $GenerateConfig['VARIANTS'] = @(
                        $definition | % {
                            $_
                        }

                    )

                }

                # Get variants' shared definition (mandatory)
                if ($definition = Get-Definition -Path $GenerateConfig['GENERATE_DEFINITIONS_VARIANTS_FILE'] -VariableName 'VARIANTS_SHARED') {
                    $GenerateConfig['VARIANTS_SHARED'] = if ( $definition -is [hashtable] ) {
                                                            $definition
                                                        }else {
                                                            $GenerateConfig['VARIANTS_SHARED']
                                                        }
                }

                # Get files' definition (optional)
                if ( Test-Path $GenerateConfig['GENERATE_DEFINITIONS_FILES_FILE'] ) {
                    if ($definition = Get-Definition -Path $GenerateConfig['GENERATE_DEFINITIONS_FILES_FILE'] -VariableName 'FILES') {
                        $GenerateConfig['FILES'] = @(
                            $definition | % { $_ }
                        )
                    }
                }

                # Validate the VARIANTS and FILES defintion objects
                "Validating `$VARIANTS definition" | Write-Verbose
                Validate-Object -Prototype (Get-VariantsPrototype) -TargetObject $GenerateConfig['VARIANTS'] -Mandatory:$false
                if ($GenerateConfig['FILES']) {
                    "Validating `$FILES definition" | Write-Verbose
                    Validate-Object -Prototype (Get-FilesPrototype) -TargetObject $GenerateConfig['FILES'] -Mandatory:$false
                }

                # Populate and normalize definitions
                Populate-GenerateConfig -GenerateConfig $GenerateConfig

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
            if ($ErrorActionPreference = 'stop') {
                throw
            }else {
                Write-Error -ErrorRecord $_
            }
        }
    }
}
