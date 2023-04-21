function Get-Definition {
    [CmdletBinding()]
    param (
        # Path to the definition file
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [object]
        $Path
    ,
        # Variable name to get
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VariableName
    ,
        # Path to the definition file
        [Parameter()]
        [switch]
        $Optional
    )
    try {
        & {
            "Reading file: $Path" | Write-Verbose
            . $Path > $null

            # Send the variable down the pipeline
            if ($Optional) {
                $v = Get-Variable -Name $VariableName -ValueOnly -ErrorAction SilentlyContinue
            }else {
                $v = Get-Variable -Name $VariableName -ValueOnly -ErrorAction Stop
            }
            ,$v
        }
    }catch {
        Write-Error "There was an error in definition file $Path. Exception: " -ErrorAction Continue
        throw
    }
}
