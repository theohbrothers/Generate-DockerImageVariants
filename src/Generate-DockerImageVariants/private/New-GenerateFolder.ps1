function New-GenerationFolder {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [object]
        $GenerateConfig
    )

    # Create repository definitions and templates folders
    $GenerateConfig['GENERATE_BASE_DIR'], $GenerateConfig['GENERATE_DEFINITIONS_DIR'], $GenerateConfig['GENERATE_FUNCTIONS_DIR'], $GenerateConfig['GENERATE_TEMPLATES_DIR'] | % {
        $destinationFullName = $_
        if (Test-Path -LiteralPath $destinationFullName) {
            "Not creating folder $destinationFullName because a file or folder already exists with that name." | Write-Host -ForegroundColor Magenta
        }else {
            "Creating folder $destinationFullName" | Write-Host -ForegroundColor Green
            $item = New-Item $destinationFullName -ItemType Container -Force
        }
    }

    # Create repository definition files
    Get-ChildItem $GenerateConfig['MODULE_SAMPLES_GENERATE_DEFINITIONS_DIR'] -Include '*.ps1' -Recurse -Force | % {
        $sourceItem = $_
        $destinationFullName = Join-Path $GenerateConfig['GENERATE_DEFINITIONS_DIR'] $sourceItem.Name
        if (Test-Path -LiteralPath $destinationFullName) {
            "Not creating definition file $destinationFullName because a file or folder already exists with that name." | Write-Host -ForegroundColor Magenta
        }else {
            "Creating definition file $destinationFullName" | Write-Host -ForegroundColor Green
            if ($item = New-Item $destinationFullName -ItemType File) {
                Get-Content $sourceItem.FullName -Force | Out-File $item.FullName -Encoding utf8 -Force
            }
        }
    }

    # Create repository functions files
    Get-ChildItem $GenerateConfig['MODULE_SAMPLES_GENERATE_FUNCTIONS_DIR'] -Include '*.ps1' -Recurse -Force | % {
        $sourceItem = $_
        $destinationFullName = Join-Path $GenerateConfig['GENERATE_FUNCTIONS_DIR'] $sourceItem.Name
        if (Test-Path -LiteralPath $destinationFullName) {
            "Not creating functions file $destinationFullName because a file or folder already exists with that name." | Write-Host -ForegroundColor Magenta
        }else {
            "Creating functions file $destinationFullName" | Write-Host -ForegroundColor Green
            if ($item = New-Item $destinationFullName -ItemType File) {
                Get-Content $sourceItem.FullName -Force | Out-File $item.FullName -Encoding utf8 -Force
            }
        }
    }

    # Create repository template files based on module's samples
    Get-ChildItem $GenerateConfig['MODULE_SAMPLES_GENERATE_TEMPLATES_DIR'] -Include '*.ps1' -Recurse -Force | % {
        $sourceItem = $_
        $destinationFullName = Join-Path $GenerateConfig['GENERATE_TEMPLATES_DIR'] $sourceItem.Name
        if (Test-Path -LiteralPath $destinationFullName) {
            "Not creating template file $destinationFullName because a file or folder already exists with that name." | Write-Host -ForegroundColor Magenta
        }else {
            "Creating template file $destinationFullName" | Write-Host -ForegroundColor Green
            if ($item = New-Item $destinationFullName -ItemType File) {
                Get-Content $sourceItem.FullName -Force | Out-File $item.FullName -Encoding utf8 -Force
            }
        }
    }
}
