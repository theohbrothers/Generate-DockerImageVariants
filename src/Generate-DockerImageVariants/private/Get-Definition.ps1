function Get-Definition {
    [CmdletBinding()]
    param (
        # Path to the definition file
        [Parameter()]
        [ValidateScript({ Test-Path $_ })]
        [ValidateNotNullOrEmpty()]
        [object]
        $Path
    ,
        # Variable name to get
        [Parameter()]
        [string]
        $VariableName
    )
    . $Path > $null

    # Send the variable down the pipeline
    Get-Variable -Name $VariableName -ValueOnly -ErrorAction SilentlyContinue
}
