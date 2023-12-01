function New-GenerateConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModulePath
    ,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $TargetRepositoryPath
    )
    $GenerateConfig = [ordered]@{}

    # Module paths
    $GenerateConfig['MODULE_BASE_DIR'] = $ModulePath
    $GenerateConfig['MODULE_SAMPLES_DIR'] = Join-Path $GenerateConfig['MODULE_BASE_DIR'] 'samples'
    $GenerateConfig['MODULE_SAMPLES_GENERATE_DIR'] = Join-Path $GenerateConfig['MODULE_SAMPLES_DIR'] 'generate'
    $GenerateConfig['MODULE_SAMPLES_GENERATE_DEFINITIONS_DIR'] = Join-Path $GenerateConfig['MODULE_SAMPLES_GENERATE_DIR'] 'definitions'
    # $GenerateConfig['MODULE_SAMPLES_GENERATE_DEFINITIONS_FILES_FILE'] = Join-Path $GenerateConfig['MODULE_SAMPLES_GENERATE_DEFINITIONS_DIR'] 'FILES.ps1'
    # $GenerateConfig['MODULE_SAMPLES_GENERATE_DEFINITIONS_VARIANTS_FILE'] = Join-Path $GenerateConfig['MODULE_SAMPLES_GENERATE_DEFINITIONS_DIR'] 'VARIANTS.ps1'
    $GenerateConfig['MODULE_SAMPLES_GENERATE_FUNCTIONS_DIR'] = Join-Path $GenerateConfig['MODULE_SAMPLES_GENERATE_DIR'] 'functions'
    $GenerateConfig['MODULE_SAMPLES_GENERATE_TEMPLATES_DIR'] = Join-Path $GenerateConfig['MODULE_SAMPLES_GENERATE_DIR'] 'templates'

    # Target repository paths
    $GenerateConfig['REPOSITORY_BASE_DIR'] = Resolve-Path $TargetRepositoryPath | Select-Object -ExpandProperty Path
    $GenerateConfig['GENERATE_BASE_DIR'] = Join-Path $GenerateConfig['REPOSITORY_BASE_DIR'] 'generate'
    $GenerateConfig['GENERATE_DEFINITIONS_DIR'] = Join-Path $GenerateConfig['GENERATE_BASE_DIR'] "definitions"
    $GenerateConfig['GENERATE_FUNCTIONS_DIR'] = Join-Path $GenerateConfig['GENERATE_BASE_DIR'] "functions"
    $GenerateConfig['GENERATE_DEFINITIONS_VARIANTS_FILE'] = Join-Path $GenerateConfig['GENERATE_DEFINITIONS_DIR'] 'VARIANTS.ps1'
    $GenerateConfig['GENERATE_DEFINITIONS_FILES_FILE'] = Join-Path $GenerateConfig['GENERATE_DEFINITIONS_DIR'] 'FILES.ps1'
    $GenerateConfig['GENERATE_TEMPLATES_DIR'] = Join-Path $GenerateConfig['GENERATE_BASE_DIR'] "templates"


    $GenerateConfig['VARIANTS'] = @()
    $GenerateConfig['VARIANTS_SHARED'] = @{}
    $GenerateConfig['FILES'] = @()
    $GenerateConfig['FUNCTIONS'] = @()

    $GenerateConfig
}
