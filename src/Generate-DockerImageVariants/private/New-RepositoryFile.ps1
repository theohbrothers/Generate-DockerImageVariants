function New-RepositoryFile {
    [CmdletBinding(DefaultParameterSetName='default')]
    param (
        [Parameter(ParameterSetName='default')]
        [ValidateNotNullOrEmpty()]
        [object]
        $File
    ,
        [Parameter(ParameterSetName='pipeline',ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [object]
        $InputObject
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'default') {
            # Same variable. Casing does not create a new variable
            $File = $File
        }
        if ($PSCmdlet.ParameterSetName -eq 'pipeline') {
            $File = $InputObject
        }

        "Generating repository file: $($File.file)" | Write-Host -ForegroundColor Green

        $fileParentAbsolutePath = Split-Path $File.file -Parent
        if ( ! (Test-Path $fileParentAbsolutePath -PathType Container) ) {
            New-Item $fileParentAbsolutePath -ItemType Directory -Force > $null
        }

        "Processing template file: $($File.templateFile)" | Write-Verbose

        Get-ContentFromTemplate -Path $File.templateFile | Out-File $File.file -Encoding utf8 -NoNewline
    }
}
